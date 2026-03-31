import 'dart:convert';

/// Compatible with Gson serialization of
/// `legado-master/.../data/entities/BookProgress.kt`
class BookProgress {
  const BookProgress({
    required this.name,
    required this.author,
    required this.durChapterIndex,
    required this.durChapterPos,
    required this.durChapterTime,
    this.durChapterTitle,
  });

  final String name;
  final String author;
  final int durChapterIndex;
  final int durChapterPos;
  final int durChapterTime;
  final String? durChapterTitle;

  Map<String, dynamic> toJson() => {
        'name': name,
        'author': author,
        'durChapterIndex': durChapterIndex,
        'durChapterPos': durChapterPos,
        'durChapterTime': durChapterTime,
        'durChapterTitle': durChapterTitle,
      };

  factory BookProgress.fromJson(Map<String, dynamic> j) => BookProgress(
        name: j['name'] as String,
        author: j['author'] as String,
        durChapterIndex: j['durChapterIndex'] as int,
        durChapterPos: j['durChapterPos'] as int,
        durChapterTime: (j['durChapterTime'] as num).toInt(),
        durChapterTitle: j['durChapterTitle'] as String?,
      );

  factory BookProgress.fromJsonString(String s) =>
      BookProgress.fromJson(json.decode(s) as Map<String, dynamic>);
}
