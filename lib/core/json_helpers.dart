import 'dart:convert';

Map<String, dynamic>? coerceToMap(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, e) => MapEntry(k.toString(), e));
  if (v is String) {
    try {
      final d = jsonDecode(v);
      if (d is Map) return Map<String, dynamic>.from(d);
    } catch (_) {}
  }
  return null;
}

List<dynamic>? coerceToList(dynamic v) {
  if (v == null) return null;
  if (v is List) return v;
  if (v is String) {
    try {
      final d = jsonDecode(v);
      if (d is List) return d;
    } catch (_) {}
  }
  return null;
}

bool looksLikeJson(String s) {
  final t = s.trimLeft();
  return t.startsWith('{') || t.startsWith('[');
}
