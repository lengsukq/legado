import '../entities/book_source_model.dart';
import '../entities/search_book_model.dart';
import '../entities/session_book.dart';
import '../network/legado_http_client.dart';
import 'web_book_content_service.dart';
import 'web_book_search_service.dart';
import 'web_book_toc_service.dart';

/// Orchestrates search → book info → toc → content (subset of `WebBook.kt`).
class WebBookService {
  WebBookService(LegadoHttpClient http)
      : _search = WebBookSearchService(http),
        _toc = WebBookTocService(http),
        _content = WebBookContentService(http);

  final WebBookSearchService _search;
  final WebBookTocService _toc;
  final WebBookContentService _content;

  WebBookSearchService get searchService => _search;
  WebBookTocService get tocService => _toc;
  WebBookContentService get contentService => _content;

  Future<List<SearchBookModel>> search(
    BookSourceModel source,
    String keyword, {
    int page = 1,
  }) {
    return _search.search(source, keyword, page: page);
  }

  Future<SessionBook> loadBookDetailFromHtml({
    required BookSourceModel source,
    required String baseUrl,
    required String html,
  }) {
    return _search.loadBookDetailFromHtml(
      source: source,
      baseUrl: baseUrl,
      html: html,
    );
  }

  Future<SessionBook> loadBookDetail(
    BookSourceModel source,
    SearchBookModel hit,
  ) async {
    return _search.loadBookDetail(source, hit);
  }

  Future<List<ChapterItem>> loadChapters(SessionBook book) async {
    return _toc.loadChapters(book);
  }

  Future<String> loadChapterContent(SessionBook book, ChapterItem ch) async {
    return _content.loadChapterContent(book, ch);
  }
}
