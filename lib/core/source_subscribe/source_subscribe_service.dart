import '../book_source_codec.dart';
import '../book_source_import_service.dart';
import '../entities/book_source_model.dart';
import '../models/source_subscribe.dart';
import 'source_subscribe_repository.dart';

class SourceSubscribeService {
  SourceSubscribeService(
    this._repo,
    this._importService,
  );

  final SourceSubscribeRepository _repo;
  final BookSourceImportService _importService;

  Future<List<SourceSubscribe>> listAll() {
    return _repo.loadAll();
  }

  Future<void> saveAll(List<SourceSubscribe> items) {
    return _repo.saveAll(items);
  }

  Future<void> addOrUpdate(SourceSubscribe sub) async {
    final list = await _repo.loadAll();
    final existingIndex = list.indexWhere((e) => e.url == sub.url);
    if (existingIndex >= 0) {
      list[existingIndex] = sub;
    } else {
      list.add(sub);
    }
    await _repo.saveAll(list);
  }

  Future<void> remove(SourceSubscribe sub) async {
    final list = await _repo.loadAll();
    list.removeWhere((e) => e.url == sub.url);
    await _repo.saveAll(list);
  }

  Future<BookSourceImportResult> refreshOne(
    SourceSubscribe sub, {
    required List<BookSourceModel> existing,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    try {
      final result = await _importService.import(
        sub.url,
        existing: existing,
      );
      final updated = sub.copyWith(
        lastUpdateTime: now,
        failCount: 0,
      );
      await addOrUpdate(updated);
      return result;
    } catch (_) {
      final failed = sub.copyWith(
        lastUpdateTime: now,
        failCount: sub.failCount + 1,
      );
      await addOrUpdate(failed);
      rethrow;
    }
  }

  Future<List<BookSourceModel>> refreshAll({
    required List<BookSourceModel> existing,
  }) async {
    final subs = await _repo.loadAll();
    var all = List<BookSourceModel>.from(existing);
    for (final s in subs.where((e) => e.enabled)) {
      final r = await refreshOne(s, existing: all);
      all = r.allSources;
    }
    return all;
  }
}

