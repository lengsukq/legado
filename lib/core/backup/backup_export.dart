import 'dart:convert';
import 'dart:io';

import '../history/history_repository.dart';

class BackupExport {
  static Future<File> exportReadingStateToJsonFile(String path) async {
    final repo = await HistoryRepository.load();
    final records = repo.getRecentReads();
    final jsonList =
        records.map((e) => e.toJson()).toList(growable: false);
    final file = File(path);
    await file.writeAsString(jsonEncode(jsonList));
    return file;
  }
}

