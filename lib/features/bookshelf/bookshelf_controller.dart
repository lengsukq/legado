import 'package:flutter/foundation.dart';

import '../../core/book_source_codec.dart';
import '../../core/book_source_import_service.dart';
import '../../core/entities/book_source_model.dart';
import '../../core/entities/search_book_model.dart';
import '../../core/entities/session_book.dart';
import '../../core/history/read_record_model.dart';
import '../../core/history/history_repository.dart';
import '../../core/models/source_subscribe.dart';
import '../../core/source_subscribe/source_subscribe_service.dart';
import '../../core/tools/book_source_inspector.dart';
import '../../core/web_book/web_book_service.dart';

class BookshelfController extends ChangeNotifier {
  BookshelfController(
    this._webBook,
    this._subscribeService,
  ) : _importService = const BookSourceImportService();

  final WebBookService _webBook;
  final BookSourceImportService _importService;
  final SourceSubscribeService _subscribeService;
  List<BookSourceModel> _sources = [];
  BookSourceModel? _selected;
  List<SearchBookModel> _hits = [];
  bool _loading = false;
  String? _error;
  List<ReadRecordModel> _recent = const [];
  final Map<BookSourceModel, BookSourceInspectionResult> _inspections = {};
  HistoryRepository? _historyRepository;
  List<SourceSubscribe> _subscribes = [];

  List<SourceSubscribe> get subscribes => List.unmodifiable(_subscribes);

  List<BookSourceModel> get sources => _sources;
  BookSourceModel? get selectedSource => _selected;
  List<SearchBookModel> get hits => _hits;
  bool get isLoading => _loading;
  String? get errorMessage => _error;
  List<ReadRecordModel> get recentReads => _recent;
  WebBookService get webBookService => _webBook;

  Map<BookSourceModel, BookSourceInspectionResult> get inspections =>
      Map.unmodifiable(_inspections);

  BookSourceInspectionResult? get selectedInspection {
    final s = _selected;
    if (s == null) return null;
    return _inspections[s];
  }

  Future<void> initialize(HistoryRepository historyRepository) async {
    _historyRepository = historyRepository;
    await _loadHistory();
  }

  Future<void> parseSources(String rawInput) async {
    _error = null;
    _hits = [];
    _inspections.clear();

    try {
      final result = await _importService.import(
        rawInput,
        existing: _sources,
      );
      _sources = result.allSources;
      _selected = _sources.isNotEmpty ? _sources.first : null;
      if (_sources.isNotEmpty) {
        const inspector = BookSourceInspector();
        for (final s in _sources) {
          _inspections[s] = inspector.inspect(s);
        }
      }
    } catch (e) {
      _sources = [];
      _selected = null;
      _inspections.clear();
      _error = '解析失败: $e';
    }

    notifyListeners();
  }

  Future<void> loadSubscriptions() async {
    _subscribes = await _subscribeService.listAll();
    notifyListeners();
  }

  Future<void> addCurrentInputAsSubscribe(String input) async {
    final url = input.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    final name = uri?.host.isNotEmpty == true ? uri!.host : url;
    final now = DateTime.now().millisecondsSinceEpoch;
    final sub = SourceSubscribe(
      name: name,
      url: url,
      enabled: true,
      lastUpdateTime: now,
    );
    await _subscribeService.addOrUpdate(sub);
    await loadSubscriptions();
  }

  Future<void> refreshAllSubscribes() async {
    try {
      final result = await _subscribeService.refreshAll(existing: _sources);
      _sources = result;
      _selected = _sources.isNotEmpty ? _sources.first : null;
      if (_sources.isNotEmpty) {
        const inspector = BookSourceInspector();
        _inspections
          ..clear();
        for (final s in _sources) {
          _inspections[s] = inspector.inspect(s);
        }
      }
      await loadSubscriptions();
    } catch (e) {
      _error = '$e';
      notifyListeners();
    }
  }

  void selectSource(BookSourceModel? source) {
    _selected = source;
    _hits = [];
    notifyListeners();
  }

  Future<void> search(String keyword) async {
    final src = _selected;
    if (src == null) {
      _error = '请先粘贴并解析书源 JSON';
      notifyListeners();
      return;
    }

    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      _error = '请输入关键词';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;
    _hits = [];

    try {
      final list = await _webBook.search(src, trimmed);
      _hits = list;
    } catch (e) {
      _error = '$e';
    } finally {
      _setLoading(false);
    }

    notifyListeners();
  }

  Future<SessionBook?> openBook(SearchBookModel hit) async {
    final src = _selected;
    if (src == null) return null;

    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      final session = await _webBook.loadBookDetail(src, hit);
      await _loadHistory();
      return session;
    } catch (e) {
      _error = '$e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _loadHistory() async {
    final repo = _historyRepository;
    if (repo == null) return;
    _recent = repo.getRecentReads();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
  }
}

