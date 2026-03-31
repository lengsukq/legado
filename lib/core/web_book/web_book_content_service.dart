import '../analyze/analyze_url_lite.dart';
import '../analyze/rule_analyzer_lite.dart';
import '../entities/book_source_model.dart';
import '../entities/session_book.dart';
import '../json_helpers.dart';
import '../legado_errors.dart';
import '../network/legado_http_client.dart';

class WebBookContentService {
  WebBookContentService(this._http);

  final LegadoHttpClient _http;

  Future<String> loadChapterContent(SessionBook book, ChapterItem ch) async {
    final source = book.source;
    final cr = source.effectiveContentRule();
    if ((cr.webJs != null && cr.webJs!.trim().isNotEmpty) ||
        (cr.imageDecode != null && cr.imageDecode!.trim().isNotEmpty)) {
      throw LegadoJsRequiredException('正文 webJs / imageDecode 需要 JS');
    }

    final req =
        AnalyzeUrlLite.build(source: source, template: ch.url, page: 1);
    final res = await _fetchPrepared(source, req);
    final ar = RuleAnalyzerLite();
    if (looksLikeJson(res.body)) {
      ar.setRootJson(res.body, redirectUrl: res.finalUrl);
    } else {
      ar.setRootHtml(res.body, redirectUrl: res.finalUrl);
    }
    final raw = cr.content;
    if (raw == null || raw.trim().isEmpty) {
      throw StateError('ruleContent.content 为空');
    }
    var text = ar.getString(raw);
    final rr = cr.replaceRegex;
    if (rr != null && rr.contains('##')) {
      final p = rr.split('##');
      if (p.isNotEmpty) {
        try {
          text = text.replaceAll(RegExp(p[0]), p.length > 1 ? p[1] : '');
        } catch (_) {}
      }
    } else if (rr != null && rr.isNotEmpty) {
      try {
        text = text.replaceAll(RegExp(rr), '');
      } catch (_) {}
    }
    if (text.trim().isEmpty) {
      throw StateError('正文为空（检查 content 规则或登录/翻页）');
    }
    final nu = cr.nextContentUrl;
    if (nu != null && nu.trim().isNotEmpty) {
      throw LegadoUnsupportedException('正文 nextContentUrl 翻页链尚未实现');
    }
    return text;
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

