import 'dart:convert';

import 'entities/book_source_model.dart';

/// Single book source JSON or array (as exported by Legado / `bookSource.json`).
List<BookSourceModel> decodeBookSourceJson(String raw) {
  final d = jsonDecode(raw);
  if (d is List) {
    return d
        .map((e) => BookSourceModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((s) => s.bookSourceUrl.isNotEmpty)
        .toList();
  }
  if (d is Map) {
    return [BookSourceModel.fromJson(Map<String, dynamic>.from(d))];
  }
  throw const FormatException('书源 JSON 须为对象或数组');
}
