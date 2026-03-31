import 'dart:convert';
import 'dart:io';

import '../history/history_repository.dart';
import '../models/book_progress.dart';

class BackupImport {
  static Future<void> importReadRecordJson(File file) async {
    final txt = await file.readAsString();
    final list = jsonDecode(txt) as List<dynamic>;
    final repo = await HistoryRepository.load();
    final progresses = <BookProgress>[];
    for (final item in list.whereType<Map<String, dynamic>>()) {
      try {
        progresses.add(BookProgress.fromJson(item));
      } catch (_) {
        continue;
      }
    }
    await repo.mergeProgressFromRemote(progresses);
  }
}

