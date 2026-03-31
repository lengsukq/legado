/// Result row from search / discover. Aligns with `SearchBook` essential fields.
class SearchBookModel {
  SearchBookModel({
    required this.origin,
    required this.originName,
    required this.name,
    required this.author,
    this.bookUrl = '',
    this.kind,
    this.coverUrl,
    this.intro,
    this.wordCount,
    this.latestChapterTitle,
    this.tocUrl = '',
  });

  String bookUrl;
  String origin;
  String originName;
  String name;
  String author;
  String? kind;
  String? coverUrl;
  String? intro;
  String? wordCount;
  String? latestChapterTitle;
  String tocUrl;
}
