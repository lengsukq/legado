import 'dart:convert';

import '../entities/book_source_model.dart';
import '../js/quickjs_runtime.dart';
import '../legado_errors.dart';
import '../utils/url_utils.dart';

class LegadoPreparedRequest {
  LegadoPreparedRequest({
    required this.url,
    this.method = 'GET',
    this.body,
    this.extraHeaders = const {},
    this.type,
    this.origin,
    this.retry,
    this.serverId,
    this.webViewDelayTime,
  });

  final String url;
  final String method;
  final String? body;
  final Map<String, String> extraHeaders;
  final String? type;
  final String? origin;
  final int? retry;
  final int? serverId;
  final int? webViewDelayTime;
}

/// Subset of `AnalyzeUrl.kt`: no Rhino, no WebView, no loginCheckJs.
class AnalyzeUrlLite {
  static final _js = RegExp(
    r'<js>([\s\S]*?)</js>|@js:([\s\S]*)',
    caseSensitive: false,
  );
  static final _pageGroup = RegExp(r'<([^<>]+)>');
  static final _optSplit = RegExp(r',\s*(?=\{)');
  static final _percentEncoded = RegExp(r'%[0-9A-Fa-f]{2}');

  /// 执行 URL 模板中的 `<js>...</js>` 或 `@js:...` 片段。
  static String _evalJsSegments(
    String ctx,
    String input, {
    required Map<String, Object?> args,
  }) {
    return input.replaceAllMapped(_js, (m) {
      final body = m.group(1) ?? m.group(2);
      if (body == null || body.trim().isEmpty) return '';
      try {
        final v = QuickJsRuntime.instance.eval(body, args: args);
        return v?.toString() ?? '';
      } catch (e) {
        throw LegadoJsRequiredException('$ctx JS 执行失败: $e');
      }
    });
  }

  static String _encodeForm(String params, {String? charset}) {
    // 已包含 %XX 的视为已经编码，直接返回。
    if (_percentEncoded.hasMatch(params)) return params;
    final parts = params.split('&');
    final encoded = <String>[];
    for (final p in parts) {
      if (p.isEmpty) continue;
      final eq = p.indexOf('=');
      if (eq < 0) {
        encoded.add(Uri.encodeQueryComponent(p));
      } else {
        final k = p.substring(0, eq);
        final v = p.substring(eq + 1);
        encoded.add(
          '${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent(v)}',
        );
      }
    }
    return encoded.join('&');
  }

  /// `searchUrl` / explore url / chapter url template.
  static LegadoPreparedRequest build({
    required BookSourceModel source,
    required String template,
    String? searchKey,
    int page = 1,
  }) {
    var rule = template.trim();
    if (rule.isEmpty) {
      throw ArgumentError('空 URL 模板');
    }

    // 先跑 URL 级 JS 片段，给 JS 传入基础参数。
    rule = _evalJsSegments(
      'URL',
      rule,
      args: {
        'key': searchKey ?? '',
        'page': page,
        'sourceUrl': source.bookSourceUrl,
      },
    );

    // {{ key }} templates — only whitelisted literals without JS engine.
    rule = rule.replaceAllMapped(RegExp(r'\{\{([^{}]+)\}\}'), (m) {
      final inner = m.group(1)!.trim();
      if (inner == 'key') {
        if (searchKey == null) throw ArgumentError('需要搜索关键词');
        return Uri.encodeQueryComponent(searchKey);
      }
      if (inner == 'page') return '$page';
      // 其他 {{...}} 交给 JS：视为表达式，对应 __args 上下文。
      final code = inner;
      try {
        final v = QuickJsRuntime.instance.eval(code, args: {
          'key': searchKey ?? '',
          'page': page,
          'sourceUrl': source.bookSourceUrl,
        });
        return v?.toString() ?? '';
      } catch (e) {
        throw LegadoJsRequiredException('URL 模板 {{...}} JS 执行失败: $e');
      }
    });

    rule = rule.replaceAllMapped(_pageGroup, (m) {
      final parts = m
          .group(1)!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (parts.isEmpty) return m.group(0)!;
      if (page < parts.length) return parts[page - 1];
      return parts.last;
    });

    String urlPart = rule;
    Map<String, dynamic>? urlOption;

    final opt = _optSplit.firstMatch(rule);
    if (opt != null) {
      urlPart = rule.substring(0, opt.start).trim();
      final jsonStr = rule.substring(opt.start + 1).trim();
      try {
        final d = jsonDecode(jsonStr);
        if (d is Map) urlOption = Map<String, dynamic>.from(d);
      } catch (e) {
        throw FormatException('URL 可选 JSON 解析失败: $e');
      }
    }

    var url = legadoAbsoluteUrl(source.bookSourceUrl, urlPart);
    var method = 'GET';
    String? body;
    final hdr = <String, String>{};
    String? type;
    String? origin;
    int? retry;
    int? serverId;
    int? webViewDelay;

    if (urlOption != null) {
      final m = (urlOption['method'] ?? urlOption['Method']) as String?;
      if (m != null && m.toUpperCase() == 'POST') method = 'POST';

      final headersRaw = urlOption['headers'] ?? urlOption['header'];
      if (headersRaw is Map) {
        headersRaw.forEach((k, v) {
          hdr[k.toString()] = v.toString();
        });
      } else if (headersRaw is String && headersRaw.isNotEmpty) {
        final d = jsonDecode(headersRaw);
        if (d is Map) {
          d.forEach((k, v) => hdr[k.toString()] = v.toString());
        }
      }

      final b = urlOption['body'];
      if (b != null) body = b is String ? b : jsonEncode(b);

      origin = urlOption['origin']?.toString();
      type = urlOption['type']?.toString();
      final retryRaw = urlOption['retry']?.toString();
      if (retryRaw != null && retryRaw.isNotEmpty) {
        retry = int.tryParse(retryRaw);
      }
      final sidRaw = urlOption['serverID']?.toString();
      if (sidRaw != null && sidRaw.isNotEmpty) {
        serverId = int.tryParse(sidRaw);
      }
      final delayRaw = urlOption['webViewDelayTime']?.toString();
      if (delayRaw != null && delayRaw.isNotEmpty) {
        webViewDelay = int.tryParse(delayRaw);
      }

      // webView / webJs 仍不直接支持，这里保留降级（不误认为已实现）。
      final webView = urlOption['webView'];
      final wv = webView == true ||
          webView == 1 ||
          (webView is String && webView.toLowerCase() == 'true');
      if (wv) {
        throw LegadoUnsupportedException('webView 加载 URL 尚未实现');
      }
      final wjs = urlOption['webJs'];
      if (wjs != null && '$wjs'.isNotEmpty) {
        throw LegadoUnsupportedException('webJs 尚未实现');
      }
      final js = urlOption['js'];
      if (js != null && '$js'.isNotEmpty) {
        try {
          final v = QuickJsRuntime.instance.eval(
            js.toString(),
            args: {
              'url': url,
              'sourceUrl': source.bookSourceUrl,
            },
          );
          if (v is String && v.isNotEmpty) {
            url = v;
          }
        } catch (e) {
          throw LegadoJsRequiredException('UrlOption.js 执行失败: $e');
        }
      }

      // 对未声明 Content-Type 且形如 a=b&c=d 的 body 做表单编码，模拟 AnalyzeUrl.encodeParams/analyzeFields。
      if (method == 'POST' && body != null) {
        final ct = hdr['Content-Type'] ?? hdr['content-type'];
        final looksLikeForm = body.contains('=') &&
            !body.trimLeft().startsWith('{') &&
            !body.trimLeft().startsWith('[');
        if ((ct == null || ct.isEmpty) && looksLikeForm) {
          body = _encodeForm(body);
          hdr['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8';
        }
      }
    }

    if (method == 'POST' && (body == null || body.isEmpty)) {
      throw StateError('POST 但 body 为空');
    }

    return LegadoPreparedRequest(
      url: url,
      method: method,
      body: body,
      extraHeaders: hdr,
      type: type,
      origin: origin,
      retry: retry,
      serverId: serverId,
      webViewDelayTime: webViewDelay,
    );
  }
}
