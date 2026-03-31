import '../entities/session_book.dart';
import '../models/book_progress.dart';

/// 最近阅读记录（Flutter 轻量版），对应 Kotlin ReadRecord 的子集。
class ReadRecordModel {
  const ReadRecordModel({
    required this.bookUrl,
    required this.bookName,
    required this.author,
    required this.lastChapterTitle,
    required this.lastChapterIndex,
    required this.lastChapterPos,
    required this.lastReadTimeMillis,
  });

  final String bookUrl;
  final String bookName;
  final String author;
  final String lastChapterTitle;
  final int lastChapterIndex;
  final int lastChapterPos;
  final int lastReadTimeMillis;

  Map<String, dynamic> toJson() => {
        'bookUrl': bookUrl,
        'bookName': bookName,
        'author': author,
        'lastChapterTitle': lastChapterTitle,
        'lastChapterIndex': lastChapterIndex,
        'lastChapterPos': lastChapterPos,
        'lastReadTimeMillis': lastReadTimeMillis,
      };

  factory ReadRecordModel.fromJson(Map<String, dynamic> j) => ReadRecordModel(
        bookUrl: j['bookUrl'] as String,
        bookName: j['bookName'] as String? ?? '',
        author: j['author'] as String? ?? '',
        lastChapterTitle: j['lastChapterTitle'] as String? ?? '',
        lastChapterIndex: (j['lastChapterIndex'] as num?)?.toInt() ?? 0,
        lastChapterPos: (j['lastChapterPos'] as num?)?.toInt() ?? 0,
        lastReadTimeMillis: (j['lastReadTimeMillis'] as num?)?.toInt() ?? 0,
      );

  BookProgress toBookProgress() => BookProgress(
        name: bookName,
        author: author,
        durChapterIndex: lastChapterIndex,
        durChapterPos: lastChapterPos,
        durChapterTime: lastReadTimeMillis,
        durChapterTitle: lastChapterTitle.isEmpty ? null : lastChapterTitle,
      );

  static ReadRecordModel fromSessionBook({
    required SessionBook book,
    required int chapterIndex,
    required int chapterPos,
    required String chapterTitle,
    required DateTime now,
  }) {
    return ReadRecordModel(
      bookUrl: book.bookUrl,
      bookName: book.name,
      author: book.author,
      lastChapterTitle: chapterTitle,
      lastChapterIndex: chapterIndex,
      lastChapterPos: chapterPos,
      lastReadTimeMillis: now.millisecondsSinceEpoch,
    );
  }
}

