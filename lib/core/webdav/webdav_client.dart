import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/book_progress.dart';
import 'webdav_paths.dart';

class WebDavClient {
  WebDavClient({
    Dio? dio,
    required this.rootUrl,
    this.username,
    this.password,
  }) : _dio = dio ?? Dio() {
    if (username != null && password != null) {
      final basic =
          base64Encode(utf8.encode('$username:$password'));
      _dio.options.headers['Authorization'] = 'Basic $basic';
    }
  }

  final Dio _dio;
  final String rootUrl;
  final String? username;
  final String? password;

  String _join(String path) {
    final base = rootUrl.endsWith('/') ? rootUrl : '$rootUrl/';
    return '$base$path';
  }

  Future<List<String>> list(String dir) async {
    final url = _join(dir);
    final res = await _dio.request<void>(
      url,
      options: Options(method: 'PROPFIND'),
    );
    return res.statusCode == 207 ? <String>[] : <String>[];
  }

  Future<String> getFile(String path) async {
    final url = _join(path);
    final res = await _dio.get<String>(url);
    if (res.statusCode != 200 || res.data == null) {
      throw StateError('WebDAV GET 失败: $url status=${res.statusCode}');
    }
    return res.data!;
  }

  Future<void> putFile(String path, String content) async {
    final url = _join(path);
    final res = await _dio.put<void>(url, data: content);
    if (res.statusCode != 200 && res.statusCode != 201 &&
        res.statusCode != 204) {
      throw StateError('WebDAV PUT 失败: $url status=${res.statusCode}');
    }
  }

  Future<void> deleteFile(String path) async {
    final url = _join(path);
    await _dio.delete<void>(url);
  }

  Future<void> uploadBookProgress(BookProgress p) async {
    final fileName =
        '${p.name}_${p.author}'.replaceAll('/', '_').replaceAll('\\', '_');
    final path = '${WebDavPaths.progressDir}$fileName.json';
    await putFile(path, jsonEncode(p.toJson()));
  }
}

