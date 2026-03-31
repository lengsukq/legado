import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:json_path/json_path.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

import '../json_helpers.dart';
import '../legado_errors.dart';
import '../js/quickjs_runtime.dart';
import '../utils/url_utils.dart';

/// Ported subset of `AnalyzeRule.kt` + `BookList.kt` (HTML + JSON only).
class RuleAnalyzerLite {
  RuleAnalyzerLite();

  String _redirect = '';
  dynamic _item; // search: Element or Map; root: null until setContentRoot
  final Map<String, String> _vars = {};

  void setRootHtml(String html, {required String redirectUrl}) {
    _item = null;
    _redirect = redirectUrl;
    _rootDoc = htmlparser.parse(html);
    _jsonRoot = null;
  }

  void setRootJson(String raw, {required String redirectUrl}) {
    _item = null;
    _redirect = redirectUrl;
    _rootDoc = null;
    _jsonRoot = jsonDecode(raw);
  }

  void bindItem(dynamic item) {
    _item = item;
  }

  /// 允许外部预置 @get:xxx 使用的变量表。
  void setVariables(Map<String, String> vars) {
    _vars
      ..clear()
      ..addAll(vars);
  }

  htmlparser.Document? _rootDoc;
  dynamic _jsonRoot;

  static final _js = RegExp(
    r'<js>([\s\S]*?)</js>|@js:([\s\S]*)',
    caseSensitive: false,
  );

  static final _getPattern = RegExp(r'@get:([^@{}#]+)');
  static final _inlineJsPattern = RegExp(r'\{\{([\s\S]*?)\}\}');

  static void _rejectJs(String rule) {
    if (_js.hasMatch(rule)) {
      throw LegadoJsRequiredException('规则含 JS: $rule');
    }
  }

  String _applyInlineGetAndJs(String rule) {
    var out = rule;
    // @get:key → 变量表取值
    out = out.replaceAllMapped(_getPattern, (m) {
      final key = m.group(1)!.trim();
      return _vars[key] ?? '';
    });
    // {{ ... }} → QuickJS 执行简单表达式
    out = out.replaceAllMapped(_inlineJsPattern, (m) {
      final body = m.group(1);
      if (body == null || body.trim().isEmpty) return '';
      try {
        final v = QuickJsRuntime.instance.eval(body, args: const {});
        return v?.toString() ?? '';
      } catch (e) {
        throw LegadoJsRequiredException('规则 {{...}} JS 执行失败: $e');
      }
    });
    return out;
  }

  /// Search result list cells.
  List<dynamic> getElementsListRule(String? ruleStr, String rawBody) {
    if (ruleStr == null || ruleStr.trim().isEmpty) return [];
    final decoded = looksLikeJson(rawBody) ? jsonDecode(rawBody) : null;
    for (final alt in ruleStr.split('||')) {
      var r = alt.trim();
      if (r.isEmpty) continue;
      var reverse = false;
      if (r.startsWith('-')) {
        reverse = true;
        r = r.substring(1);
      }
      if (r.startsWith('+')) r = r.substring(1);
      _rejectJs(r);
      List<dynamic> items;
      if (decoded != null) {
        if (_looksLikeXPath(r)) {
          throw LegadoUnsupportedException('XPath / @XPath: 不适用于 JSON 响应: $r');
        }
        try {
          items = _jsonCollect(decoded, r);
        } catch (_) {
          items = [];
        }
        if (items.isEmpty && !_looksExplicitJson(r)) {
          throw LegadoUnsupportedException(
            '响应为 JSON 时，请使用 $. / @Json: 形式的路径作为列表规则',
          );
        }
      } else if (_looksLikeXPath(r)) {
        items = _xpathCollect(rawBody, r);
      } else {
        items = _cssCollect(rawBody, r);
      }
      if (items.isNotEmpty) {
        if (reverse) return items.reversed.toList();
        return items;
      }
    }
    return [];
  }

  bool _looksExplicitJson(String r) =>
      r.startsWith(r'$.') || r.startsWith(r'$[') || r.toLowerCase().startsWith('@json:');

  bool _looksLikeXPath(String r) {
    if (r.startsWith('@XPath:') || r.startsWith('@xpath:')) return true;
    return r.startsWith('//') || (r.startsWith('/') && !r.startsWith('//') && r.length > 1);
  }

  List<dynamic> _cssCollect(String html, String rule) {
    final doc = htmlparser.parse(html);
    final sel = _normalizeCss(rule);
    // ignore: cast_nullable_to_non_nullable
    return doc.querySelectorAll(sel);
  }

  List<Node> _xpathCollect(String html, String rule) {
    try {
      final xp = HtmlXPath.html(html);
      final res = xp.queryXPath(rule);
      return res.nodes.map((n) => n.node).toList();
    } catch (_) {
      return <Node>[];
    }
  }

  String _normalizeCss(String rule) {
    var r = rule.trim();
    if (r.toLowerCase().startsWith('@css:')) r = r.substring(5);
    if (r.startsWith('@@')) r = r.substring(2);
    return r.trim();
  }

  String _normalizeJsonPath(String rule) {
    var r = rule.trim();
    if (r.toLowerCase().startsWith('@json:')) r = r.substring(6);
    return r.trim();
  }

  List<dynamic> _jsonCollect(dynamic root, String rule) {
    final path = _normalizeJsonPath(rule);
    final jp = JsonPath(path);
    final out = <dynamic>[];
    for (final m in jp.read(root)) {
      out.add(m.value);
    }
    return out;
  }

  String getString(String? ruleStr, {bool isUrl = false}) {
    if (ruleStr == null || ruleStr.trim().isEmpty) return '';
    for (final alt in ruleStr.split('||')) {
      var one = alt.trim();
      if (one.isEmpty) continue;
      one = _applyInlineGetAndJs(one);
      _rejectJs(one);
      final segs = one.split('##');
      final main = segs.first.trim();
      var v = _extractOne(main);
      if (segs.length >= 2) {
        v = _replaceBlock(v, segs);
      }
      if (v.isNotEmpty) {
        if (isUrl) return legadoAbsoluteUrl(_redirect, v);
        return v;
      }
    }
    return '';
  }

  String _replaceBlock(String input, List<String> segs) {
    if (segs.length < 2) return input;
    final pat = segs[1];
    final rep = segs.length > 2 ? segs[2] : '';

    RegExp? compiled;
    try {
      compiled = RegExp(pat);
    } catch (_) {
      compiled = null;
    }

    // ##match##replace[##first] 语义：当有 fourth 段时，只取首个匹配并返回其替换结果；无匹配时返回 replacement。
    if (segs.length >= 4) {
      if (compiled != null) {
        try {
          final m = compiled.firstMatch(input);
          if (m == null) {
            return rep;
          }
          return m.group(0)!.replaceFirst(compiled, rep);
        } catch (_) {
          return rep;
        }
      }
      return rep;
    }

    // ##match##replace：全局替换，失败时退回字符串替换。
    if (compiled != null) {
      try {
        return input.replaceAll(compiled, rep);
      } catch (_) {
        // fall through
      }
    }
    return input.replaceAll(pat, rep);
  }

  String _extractOne(String rule) {
    if (_item is Map || _item is List) {
      final path = _normalizeJsonPath(rule);
      final jp = JsonPath(path);
      final vals = jp.read(_item!).map((e) => e.value).whereType<Object>().toList();
      if (vals.isEmpty) return '';
      return _stringifyLeaf(vals.first);
    }

    if (_item is Element) {
      if (_looksLikeXPath(rule)) {
        // XPath on current element.
        try {
          final res = HtmlXPath.node(_item as Node).queryXPath(rule);
          final attr = res.attr;
          if (attr != null) return attr.trim();
          final node = res.node;
          return node?.text?.trim() ?? '';
        } catch (_) {
          throw LegadoUnsupportedException('XPath');
        }
      }
      final sel = _normalizeCss(rule);
      final el = (_item! as Element).querySelector(sel);
      return el?.text.trim() ?? '';
    }

    if (_item == null && _jsonRoot != null && _looksExplicitJson(rule)) {
      final path = _normalizeJsonPath(rule);
      final vals = JsonPath(path).read(_jsonRoot!).map((e) => e.value).whereType<Object>().toList();
      if (vals.isEmpty) return '';
      return _stringifyLeaf(vals.first);
    }

    if (_item == null && _rootDoc != null) {
      if (_looksLikeXPath(rule)) {
        try {
          final html = _rootDoc!.outerHtml;
          final res = HtmlXPath.html(html).queryXPath(rule);
          final attr = res.attr;
          if (attr != null) return attr.trim();
          final node = res.node;
          return node?.text?.trim() ?? '';
        } catch (_) {
          throw LegadoUnsupportedException('XPath');
        }
      }
      final sel = _normalizeCss(rule);
      final el = _rootDoc!.querySelector(sel);
      return el?.text.trim() ?? '';
    }

    return '';
  }

  String _stringifyLeaf(Object v) {
    if (v is String) return v;
    if (v is num || v is bool) return '$v';
    return jsonEncode(v);
  }

  /// Init rule on book info: pick one node then re-bind as item.
  Element? selectOneElement(String? rule, String rawHtml) {
    if (rule == null || rule.trim().isEmpty) return null;
    _rejectJs(rule);
    final doc = htmlparser.parse(rawHtml);
    final sel = _normalizeCss(rule);
    return doc.querySelector(sel);
  }
}
