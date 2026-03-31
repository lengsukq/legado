import '../entities/book_source_model.dart';
import '../entities/book_list_rule.dart';

/// Lightweight compatibility inspection for a single book source.
///
/// The goal is to answer: “在当前 Flutter lite 引擎下，
/// 这个书源大致可用吗？有哪些明显不兼容点？”
class BookSourceInspectionResult {
  BookSourceInspectionResult({
    required this.source,
    required this.supported,
    required this.issues,
  });

  final BookSourceModel source;

  /// Whether the source does not rely on obviously unsupported features.
  final bool supported;

  /// Human‑readable reasons, aligned with Android full engine features.
  final List<String> issues;
}

class BookSourceInspector {
  const BookSourceInspector();

  /// Run inspection on a list of decoded sources.
  List<BookSourceInspectionResult> inspectAll(List<BookSourceModel> sources) {
    return sources.map(inspect).toList();
  }

  /// Inspect a single source for features that Flutter lite cannot handle.
  BookSourceInspectionResult inspect(BookSourceModel source) {
    final issues = <String>[];

    // Top‑level JS related fields.
    if (!_isBlank(source.loginCheckJs)) {
      issues.add('含 loginCheckJs，当前 Flutter 版不支持登录 JS 校验');
    }
    if (!_isBlank(source.jsLib)) {
      issues.add('配置了 jsLib，当前 Flutter 版未加载自定义 JS 库');
    }

    // Search / explore rules – look for obvious JS / XPath usage.
    _checkListRule('搜索列表', source.ruleSearch, issues);
    _checkListRule('发现列表', source.ruleExplore, issues);

    // Book info rules.
    final info = source.ruleBookInfo;
    if (info != null) {
      if (_containsJsSnippet(info.init)) {
        issues.add('书籍详情 init 含 <js> / @js: 片段，当前未支持');
      }
    }

    // TOC rules.
    final toc = source.ruleToc;
    if (toc != null) {
      if (!_isBlank(toc.preUpdateJs)) {
        issues.add('目录 preUpdateJs 需要 JS，引擎尚未接入');
      }
      if (!_isBlank(toc.nextTocUrl)) {
        issues.add('目录 nextTocUrl 表示多页/分卷目录，当前未实现多页目录');
      }
      if (_containsJsSnippet(toc.chapterList) ||
          _containsJsSnippet(toc.chapterName) ||
          _containsJsSnippet(toc.chapterUrl)) {
        issues.add('目录规则含 <js> / @js: 片段，当前未支持');
      }
      if (_looksLikeXPath(toc.chapterList) ||
          _looksLikeXPath(toc.chapterName) ||
          _looksLikeXPath(toc.chapterUrl)) {
        issues.add('目录规则使用 XPath，当前仅推荐 CSS / JSONPath');
      }
    }

    // Content rules.
    final cr = source.ruleContent;
    if (cr != null) {
      if (!_isBlank(cr.webJs)) {
        issues.add('正文 webJs 需要 JS 引擎，当前 Flutter 版不支持');
      }
      if (!_isBlank(cr.imageDecode)) {
        issues.add('正文 imageDecode 需要 JS 参与图片解码，当前不支持');
      }
      if (!_isBlank(cr.nextContentUrl)) {
        issues.add('正文 nextContentUrl 表示多页正文，当前未实现翻页链');
      }
      if (_containsJsSnippet(cr.content) ||
          _containsJsSnippet(cr.title) ||
          _containsJsSnippet(cr.sourceRegex) ||
          _containsJsSnippet(cr.replaceRegex)) {
        issues.add('正文规则含 <js> / @js: 片段，当前未支持');
      }
      if (_looksLikeXPath(cr.content) ||
          _looksLikeXPath(cr.title) ||
          _looksLikeXPath(cr.sourceRegex) ||
          _looksLikeXPath(cr.replaceRegex)) {
        issues.add('正文规则使用 XPath，当前仅推荐 CSS / JSONPath');
      }
    }

    final supported = issues.isEmpty;
    return BookSourceInspectionResult(
      source: source,
      supported: supported,
      issues: issues,
    );
  }

  void _checkListRule(
    String label,
    dynamic rule, // SearchRule / ExploreRule
    List<String> out,
  ) {
    if (rule is! BookListRuleMixin) return;
    final list = rule.bookList;
    if (_containsJsSnippet(list)) {
      out.add('$label 列表规则含 <js> / @js: 片段，当前未支持');
    }
    if (_looksLikeXPath(list)) {
      out.add('$label 列表规则使用 XPath，当前仅推荐 CSS / JSONPath');
    }
  }

  bool _isBlank(String? s) => s == null || s.trim().isEmpty;

  bool _containsJsSnippet(String? rule) {
    if (_isBlank(rule)) return false;
    final r = rule!.toLowerCase();
    return r.contains('<js>') || r.contains('@js:');
  }

  bool _looksLikeXPath(String? rule) {
    if (_isBlank(rule)) return false;
    final r = rule!.trim();
    if (r.toLowerCase().startsWith('@xpath:')) return true;
    return r.startsWith('//') || (r.startsWith('/') && r.length > 1);
  }
}

