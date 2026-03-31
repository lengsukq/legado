import 'dart:convert';

import 'package:dio/dio.dart';

import 'book_source_codec.dart';
import 'entities/book_source_model.dart';

class BookSourceImportResult {
  BookSourceImportResult({
    required this.allSources,
    required this.newSources,
    required this.updatedSources,
  });

  final List<BookSourceModel> allSources;
  final List<BookSourceModel> newSources;
  final List<BookSourceModel> updatedSources;
}

class BookSourceImportService {
  const BookSourceImportService();

  Future<BookSourceImportResult> import(
    String input, {
    List<BookSourceModel> existing = const [],
  }) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('书源内容不能为空');
    }

    final all = <BookSourceModel>[];

    if (_looksLikeJson(trimmed)) {
      all.addAll(decodeBookSourceJson(trimmed));
    } else if (_looksLikeHttpUrl(trimmed)) {
      all.addAll(await _loadFromUrl(trimmed));
    } else {
      throw const FormatException('不支持的书源格式，请粘贴 JSON 或远程 URL');
    }

    final existingByUrl = {
      for (final s in existing) s.bookSourceUrl: s,
    };
    final newSources = <BookSourceModel>[];
    final updatedSources = <BookSourceModel>[];

    for (final s in all) {
      final old = existingByUrl[s.bookSourceUrl];
      if (old == null) {
        newSources.add(s);
      } else if (s.lastUpdateTime > old.lastUpdateTime) {
        updatedSources.add(s);
      }
    }

    return BookSourceImportResult(
      allSources: all,
      newSources: newSources,
      updatedSources: updatedSources,
    );
  }

  bool _looksLikeJson(String text) {
    final t = text.trimLeft();
    return t.startsWith('{') || t.startsWith('[');
  }

  bool _looksLikeHttpUrl(String text) {
    final t = text.trimLeft();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  Future<List<BookSourceModel>> _loadFromUrl(String url) async {
    final dio = Dio();
    final res = await dio.get<String>(url);
    final body = res.data ?? '';
    if (body.isEmpty) {
      throw const FormatException('远程书源响应为空');
    }

    final d = jsonDecode(body);
    if (d is Map<String, dynamic> && d['sourceUrls'] is List) {
      final urls = (d['sourceUrls'] as List).cast<String>();
      final all = <BookSourceModel>[];
      for (final u in urls) {
        all.addAll(await _loadFromUrl(u));
      }
      return all;
    }

    return decodeBookSourceJson(body);
  }
}

