import 'package:flutter/foundation.dart';

import '../entities/session_book.dart';
import '../web_book/web_book_service.dart';

enum ReadSessionStatus { idle, loading, ready, error }

class ReadSession extends ChangeNotifier {
  ReadSession({
    required this.book,
    required this.webBook,
    required int initialIndex,
    this.onChapterOpened,
  }) : _currentIndex = initialIndex;

  final SessionBook book;
  final WebBookService webBook;
  final void Function(SessionBook book, ChapterItem chapter)? onChapterOpened;

  int _currentIndex;
  ReadSessionStatus _status = ReadSessionStatus.idle;
  String _content = '';
  Object? _error;
  int _position = 0;

  int get currentIndex => _currentIndex;
  ReadSessionStatus get status => _status;
  String get content => _content;
  Object? get error => _error;
  int get position => _position;

  List<ChapterItem> get _chapters {
    final list = book.chapters;
    if (list == null || list.isEmpty) {
      throw StateError('SessionBook.chapters 为空，先调用 WebBookService.loadChapters');
    }
    return list;
  }

  ChapterItem get currentChapter => _chapters[_currentIndex];

  bool get canPrev => _currentIndex > 0;
  bool get canNext => _currentIndex + 1 < _chapters.length;

  Future<void> openChapter(int index) async {
    if (index < 0 || index >= _chapters.length) {
      throw RangeError.index(index, _chapters, 'index');
    }
    _currentIndex = index;
    _position = 0;
    _setStatus(ReadSessionStatus.loading);
    try {
      final ch = _chapters[_currentIndex];
      final text = await webBook.loadChapterContent(book, ch);
      _content = text;
      _error = null;
      onChapterOpened?.call(book, ch);
      _setStatus(ReadSessionStatus.ready);
    } catch (e) {
      _content = '';
      _error = e;
      _setStatus(ReadSessionStatus.error);
    }
  }

  Future<void> nextChapter() async {
    if (!canNext) return;
    await openChapter(_currentIndex + 1);
  }

  Future<void> prevChapter() async {
    if (!canPrev) return;
    await openChapter(_currentIndex - 1);
  }

  void updatePosition(int pos) {
    if (pos == _position) return;
    _position = pos;
    // 不立即通知 UI，留给上层决定是否关心精细位置变更。
  }

  void _setStatus(ReadSessionStatus value) {
    if (_status == value) return;
    _status = value;
    notifyListeners();
  }
}

