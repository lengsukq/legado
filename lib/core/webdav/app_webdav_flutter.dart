import 'dart:convert';

import '../models/book_progress.dart';
import '../entities/session_book.dart';
import 'webdav_client.dart';
import 'webdav_paths.dart';

class AppWebDavFlutter {
  AppWebDavFlutter(this._client);

  final WebDavClient _client;

  Future<void> uploadBookProgress(BookProgress p) {
    return _client.uploadBookProgress(p);
  }

  Future<BookProgress?> getBookProgressFor(SessionBook book) async {
    final fileName =
        '${book.name}_${book.author}'.replaceAll('/', '_').replaceAll('\\', '_');
    final path = '${WebDavPaths.progressDir}$fileName.json';
    try {
      final txt = await _client.getFile(path);
      final j = jsonDecode(txt) as Map<String, dynamic>;
      return BookProgress.fromJson(j);
    } catch (_) {
      return null;
    }
  }
}

