/// Exceptions aligned with gaps vs `legado-master` Rhino/AnalyzeRule stack.

class LegadoJsRequiredException implements Exception {
  LegadoJsRequiredException(this.message);
  final String message;

  @override
  String toString() => 'LegadoJsRequiredException: $message';
}

class LegadoUnsupportedException implements Exception {
  LegadoUnsupportedException(this.message);
  final String message;

  @override
  String toString() => 'LegadoUnsupportedException: $message';
}
