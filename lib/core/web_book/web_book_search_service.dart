import '../analyze/analyze_url_lite.dart';
import '../analyze/rule_analyzer_lite.dart';
import '../entities/book_source_model.dart';
import '../entities/search_book_model.dart';
import '../entities/session_book.dart';
import '../json_helpers.dart';
import '../network/legado_http_client.dart';
import '../utils/url_utils.dart';
import '../legado_errors.dart';

enum WebBookListMode {
  search,
  explore,
}

class WebBookSearchService {
  WebBookSearchService(this._http);

  final LegadoHttpClient _http;

  Future<List<SearchBookModel>> search(
    BookSourceModel source,
    String keyword, {
    int page = 1,
  }) async {
    return _listInternal(
      source: source,
      mode: WebBookListMode.search,
      keyword: keyword,
      page: page,
    );
  }

  Future<List<SearchBookModel>> explore(
    BookSourceModel source, {
    required String exploreUrl,
    int page = 1,
  }) async {
    return _listInternal(
      source: source,
      mode: WebBookListMode.explore,
      explicitUrl: exploreUrl,
      page: page,
    );
  }

  Future<List<SearchBookModel>> _listInternal({
    required BookSourceModel source,
    required WebBookListMode mode,
    String? keyword,
    String? explicitUrl,
    int page = 1,
  }) async {
    final url = switch (mode) {
      WebBookListMode.search => source.searchUrl,
      WebBookListMode.explore => explicitUrl ?? source.exploreUrl,
    };
    if (url == null || url.isEmpty) {
      throw StateError('书源未配置 searchUrl');
    }
    if (mode == WebBookListMode.search) {
      _checkLoginJs(source);
    }
    final req = AnalyzeUrlLite.build(
      source: source,
      template: url,
      searchKey: mode == WebBookListMode.search ? keyword : null,
      page: page,
    );
    final res = await _fetchPrepared(source, req);
    final ruleData = switch (mode) {
      WebBookListMode.search => source.effectiveSearchRule(),
      WebBookListMode.explore => source.effectiveExploreRule(),
    };

    final pattern = source.bookUrlPattern;
    if (pattern != null && pattern.isNotEmpty) {
      final re = RegExp(pattern);
      if (re.hasMatch(res.finalUrl)) {
        final detail = await loadBookDetailFromHtml(
          source: source,
          baseUrl: res.finalUrl,
          html: res.body,
        );
        return [
          SearchBookModel(
            origin: source.bookSourceUrl,
            originName: source.bookSourceName,
            name: detail.name,
            author: detail.author,
            intro: detail.intro,
            coverUrl: detail.coverUrl,
          )..bookUrl = detail.bookUrl,
        ];
      }
    }

    var listRule = ruleData.bookList;
    var reverse = false;
    if (listRule != null && listRule.isNotEmpty) {
      if (listRule.startsWith('-')) {
        reverse = true;
        listRule = listRule.substring(1);
      } else if (listRule.startsWith('+')) {
        listRule = listRule.substring(1);
      }
    }

    final cells = RuleAnalyzerLite().getElementsListRule(
      listRule ?? '',
      res.body,
    );
    if (cells.isEmpty && (pattern == null || pattern.isEmpty)) {
      final detail = await loadBookDetailFromHtml(
        source: source,
        baseUrl: res.finalUrl,
        html: res.body,
      );
      return [
        SearchBookModel(
          origin: source.bookSourceUrl,
          originName: source.bookSourceName,
          name: detail.name,
          author: detail.author,
          intro: detail.intro,
          coverUrl: detail.coverUrl,
        )..bookUrl = detail.bookUrl,
      ];
    }

    final out = <SearchBookModel>[];
    for (var i = 0; i < cells.length; i++) {
      final cell = cells[i];
      final ar = RuleAnalyzerLite()..bindItem(cell);
      final name = ar.getString(ruleData.name);
      if (name.isEmpty) continue;
      final sb = SearchBookModel(
        origin: source.bookSourceUrl,
        originName: source.bookSourceName,
        name: name,
        author: ar.getString(ruleData.author),
        kind: ar.getString(ruleData.kind),
        coverUrl: _nullIfEmpty(
          legadoAbsoluteUrl(res.finalUrl, ar.getString(ruleData.coverUrl)),
        ),
        intro: _nullIfEmpty(ar.getString(ruleData.intro)),
        wordCount: _nullIfEmpty(ar.getString(ruleData.wordCount)),
        latestChapterTitle: _nullIfEmpty(ar.getString(ruleData.lastChapter)),
      );
      sb.bookUrl = ar.getString(ruleData.bookUrl, isUrl: true);
      if (sb.bookUrl.isEmpty) sb.bookUrl = res.finalUrl;
      out.add(sb);
    }
    if (reverse) {
      return out.reversed.toList();
    }
    return out;
  }

  Future<SessionBook> loadBookDetailFromHtml({
    required BookSourceModel source,
    required String baseUrl,
    required String html,
  }) async {
    final book = SessionBook(
      source: source,
      bookUrl: baseUrl,
      name: '',
      author: '',
      intro: null,
      coverUrl: null,
      infoHtml: html,
    );

    final ar = RuleAnalyzerLite();
    if (looksLikeJson(html)) {
      ar.setRootJson(html, redirectUrl: baseUrl);
    } else {
      ar.setRootHtml(html, redirectUrl: baseUrl);
    }

    final ir = source.effectiveBookInfoRule();
    final init = ir.init;
    if (init != null && init.trim().isNotEmpty && !looksLikeJson(html)) {
      final slice = ar.selectOneElement(init, html);
      if (slice != null) {
        ar.setRootHtml(slice.outerHtml, redirectUrl: baseUrl);
      }
    }

    final n = ar.getString(ir.name);
    if (n.isNotEmpty) book.name = n;
    final a = ar.getString(ir.author);
    if (a.isNotEmpty) book.author = a;
    final intro = ar.getString(ir.intro);
    if (intro.isNotEmpty) book.intro = intro;
    final cover = ar.getString(ir.coverUrl);
    if (cover.isNotEmpty) {
      book.coverUrl = legadoAbsoluteUrl(baseUrl, cover);
    }
    book.tocUrl = ar.getString(ir.tocUrl, isUrl: true);
    if (book.tocUrl.isEmpty) book.tocUrl = baseUrl;
    book.tocHtml = book.tocUrl == baseUrl ? html : null;
    return book;
  }

  Future<SessionBook> loadBookDetail(
    BookSourceModel source,
    SearchBookModel hit,
  ) async {
    final targetUrl = hit.bookUrl.isNotEmpty ? hit.bookUrl : hit.tocUrl;
    if (targetUrl.isEmpty) {
      throw StateError('搜索结果缺少书籍详情 URL');
    }
    final req = AnalyzeUrlLite.build(
      source: source,
      template: targetUrl,
      page: 1,
    );
    final res = await _fetchPrepared(source, req);
    return loadBookDetailFromHtml(
      source: source,
      baseUrl: res.finalUrl,
      html: res.body,
    );
  }

  void _checkLoginJs(BookSourceModel s) {
    final c = s.loginCheckJs;
    if (c != null && c.trim().isNotEmpty) {
      throw LegadoJsRequiredException('书源含 loginCheckJs，需 JS 引擎');
    }
  }

  String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

  Future<LegadoHttpResponse> _fetchPrepared(
    BookSourceModel source,
    LegadoPreparedRequest req,
  ) async {
    if (req.method.toUpperCase() == 'POST') {
      return _http.post(
        req.url,
        source: source,
        body: req.body ?? '',
        extraHeaders: req.extraHeaders,
      );
    }
    return _http.get(req.url, source: source, extraHeaders: req.extraHeaders);
  }
}

