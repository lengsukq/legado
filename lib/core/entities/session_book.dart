import 'book_source_model.dart';

class ChapterItem {
  ChapterItem({
    required this.title,
    required this.url,
    required this.index,
    required this.bookUrl,
  });

  final String title;
  final String url;
  final int index;
  final String bookUrl;
}

/// Mutable book used for read pipeline (in-memory).
class SessionBook {
  SessionBook({
    required this.source,
    required this.bookUrl,
    required this.name,
    required this.author,
    this.tocUrl = '',
    this.intro,
    this.coverUrl,
    this.infoHtml,
    this.tocHtml,
  });

  final BookSourceModel source;
  String bookUrl;
  String name;
  String author;
  String tocUrl;
  String? intro;
  String? coverUrl;
  String? infoHtml;
  String? tocHtml;
  List<ChapterItem> chapters = [];
}
