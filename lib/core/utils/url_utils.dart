String legadoAbsoluteUrl(String base, String rel) {
  final t = rel.trim();
  if (t.startsWith('http://') || t.startsWith('https://')) return t;
  var b = base.trim();
  if (b.isEmpty) b = 'http://_/';
  return Uri.parse(b).resolve(t).toString();
}
