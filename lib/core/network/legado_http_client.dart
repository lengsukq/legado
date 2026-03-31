import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import '../entities/book_source_model.dart';

class LegadoHttpResponse {
  LegadoHttpResponse({required this.body, required this.finalUrl});

  final String body;
  final String finalUrl;
}

/// Per-source cookie jar (memory). Mirrors OkHttp cookieJar flag on `BookSource`.
class LegadoHttpClient {
  LegadoHttpClient() {
    _baseOptions = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.plain,
      followRedirects: true,
      validateStatus: (s) => s != null && s < 500,
    );
  }

  late final BaseOptions _baseOptions;
  final Map<String, CookieJar> _jars = {};
  final Map<String, Dio> _clients = {};

  CookieJar _jarFor(BookSourceModel s) =>
      _jars.putIfAbsent(s.bookSourceUrl, () => CookieJar());

  Dio _clientFor(BookSourceModel s) {
    return _clients.putIfAbsent(
      s.bookSourceUrl,
      () {
        final dio = Dio(_baseOptions);
        if (s.enabledCookieJar == true) {
          dio.interceptors.add(CookieManager(_jarFor(s)));
        }
        return dio;
      },
    );
  }

  Map<String, String> parseHeaderBlock(String? raw) {
    if (raw == null || raw.trim().isEmpty) return {};
    final m = <String, String>{};
    for (final line in raw.split(RegExp(r'\r?\n'))) {
      final t = line.trim();
      if (t.isEmpty) continue;
      final i = t.indexOf(':');
      if (i <= 0) continue;
      final k = t.substring(0, i).trim();
      final v = t.substring(i + 1).trim();
      m[k] = v;
    }
    return m;
  }

  Future<LegadoHttpResponse> get(
    String url, {
    required BookSourceModel source,
    Map<String, String>? extraHeaders,
  }) async {
    final h = <String, String>{
      ...parseHeaderBlock(source.header),
      ...?extraHeaders,
    };
    final dio = _clientFor(source);
    final r = await dio.get<String>(url, options: Options(headers: h));
    final text = r.data ?? '';
    final uri = r.realUri;
    return LegadoHttpResponse(body: text, finalUrl: uri.toString());
  }

  Future<LegadoHttpResponse> post(
    String url, {
    required BookSourceModel source,
    required String body,
    Map<String, String>? extraHeaders,
  }) async {
    final h = <String, String>{
      ...parseHeaderBlock(source.header),
      ...?extraHeaders,
    };
    final dio = _clientFor(source);
    final r = await dio.post<String>(
      url,
      data: body,
      options: Options(headers: h, contentType: Headers.textPlainContentType),
    );
    final text = r.data ?? '';
    return LegadoHttpResponse(body: text, finalUrl: r.realUri.toString());
  }
}
