import '../analyze/analyze_url_lite.dart';
import '../analyze/rule_analyzer_lite.dart';
import '../entities/book_source_model.dart';
import '../entities/session_book.dart';
import '../json_helpers.dart';
import '../legado_errors.dart';
import '../network/legado_http_client.dart';

class WebBookTocService {
  WebBookTocService(this._http);

  final LegadoHttpClient _http;

  Future<List<ChapterItem>> loadChapters(SessionBook book) async {
    final source = book.source;
    final tocRule = source.effectiveTocRule();
    final pre = tocRule.preUpdateJs;
    if (pre != null && pre.trim().isNotEmpty) {
      throw LegadoJsRequiredException('目录 preUpdateJs 需要 JS');
    }

    late String body;
    if (book.tocHtml != null && book.tocHtml!.isNotEmpty) {
      body = book.tocHtml!;
    } else {
      final req = AnalyzeUrlLite.build(
        source: source,
        template: book.tocUrl,
        page: 1,
      );
      final res = await _fetchPrepared(source, req);
      body = res.body;
    }

    final listRule = tocRule.chapterList;
    if (listRule == null || listRule.trim().isEmpty) {
      throw StateError('ruleToc.chapterList 为空');
    }

    final cells = RuleAnalyzerLite().getElementsListRule(listRule, body);
    final chapters = <ChapterItem>[];
    final ar = RuleAnalyzerLite();
    for (var i = 0; i < cells.length; i++) {
      ar.bindItem(cells[i]);
      final title = ar.getString(tocRule.chapterName);
      final u = ar.getString(tocRule.chapterUrl, isUrl: true);
      if (title.isEmpty || u.isEmpty) continue;
      chapters.add(
        ChapterItem(
          title: title,
          url: u,
          index: i,
          bookUrl: book.bookUrl,
        ),
      );
    }
    if (chapters.isEmpty) {
      throw StateError('未解析到目录（检查 chapterList / chapterName / chapterUrl 规则）');
    }
    if (tocRule.nextTocUrl != null && tocRule.nextTocUrl!.trim().isNotEmpty) {
      throw LegadoUnsupportedException('分卷/多页目录 nextTocUrl 尚未实现');
    }
    book.chapters = chapters;
    return chapters;
  }

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

