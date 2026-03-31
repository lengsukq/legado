import 'dart:io';

import '../models/source_subscribe.dart';
import '../storage/legado_paths.dart';

class SourceSubscribeRepository {
  const SourceSubscribeRepository();

  Future<List<SourceSubscribe>> loadAll() async {
    await LegadoPaths.ensureBaseDirs();
    final file = LegadoPaths.sourceSubscribeFile;
    if (!await file.exists()) {
      return <SourceSubscribe>[];
    }
    final text = await file.readAsString();
    if (text.trim().isEmpty) {
      return <SourceSubscribe>[];
    }
    return SourceSubscribe.listFromJsonString(text);
  }

  Future<void> saveAll(List<SourceSubscribe> items) async {
    await LegadoPaths.ensureBaseDirs();
    final file = LegadoPaths.sourceSubscribeFile;
    final text = SourceSubscribe.listToJsonString(items);
    await file.writeAsString(text);
  }
}

