import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/session_book.dart';
import '../models/book_progress.dart';
import '../entities/entities_constants.dart';
import 'read_record_model.dart';

class HistoryRepository {
  HistoryRepository._(this._prefs);

  static const _kRecentReadsKey = 'legado_recent_reads';
  static const _kMaxRecent = 100;

  final SharedPreferences _prefs;

  static Future<HistoryRepository> load() async {
    final prefs = await SharedPreferences.getInstance();
    return HistoryRepository._(prefs);
  }

  List<ReadRecordModel> getRecentReads() {
    final raw = _prefs.getString(_kRecentReadsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(ReadRecordModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> upsertRecord({
    required SessionBook book,
    required int chapterIndex,
    required int chapterPos,
    required String chapterTitle,
    DateTime? now,
  }) async {
    final ts = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final rec = ReadRecordModel.fromSessionBook(
      book: book,
      chapterIndex: chapterIndex,
      chapterPos: chapterPos,
      chapterTitle: chapterTitle,
      now: DateTime.fromMillisecondsSinceEpoch(ts),
    );
    final current = getRecentReads();
    final filtered =
        current.where((e) => e.bookUrl != rec.bookUrl).toList(growable: true);
    filtered.insert(0, rec);
    if (filtered.length > _kMaxRecent) {
      filtered.removeRange(_kMaxRecent, filtered.length);
    }
    final payload =
        jsonEncode(filtered.map((e) => e.toJson()).toList(growable: false));
    await _prefs.setString(_kRecentReadsKey, payload);
  }

  Future<BookProgress?> getBookProgress(String bookUrl) async {
    final list = getRecentReads();
    final rec = list.firstWhere(
      (e) => e.bookUrl == bookUrl,
      orElse: () => const ReadRecordModel(
        bookUrl: EntitiesConstants.defaultEmpty,
        bookName: EntitiesConstants.defaultEmpty,
        author: EntitiesConstants.defaultEmpty,
        lastChapterTitle: EntitiesConstants.defaultEmpty,
        lastChapterIndex: 0,
        lastChapterPos: 0,
        lastReadTimeMillis: 0,
      ),
    );
    if (rec.bookUrl.isEmpty) return null;
    return rec.toBookProgress();
  }

  Future<void> mergeProgressFromRemote(List<BookProgress> remote) async {
    if (remote.isEmpty) return;
    final current = getRecentReads();
    final byUrl = <String, ReadRecordModel>{
      for (final r in current) r.bookUrl: r,
    };
    for (final p in remote) {
      final key = p.name.isEmpty ? '' : p.name;
      if (key.isEmpty) continue;
      final existing = byUrl.values.firstWhere(
      (e) => e.bookName == p.name && e.author == p.author,
      orElse: () => const ReadRecordModel(
          bookUrl: EntitiesConstants.defaultEmpty,
          bookName: EntitiesConstants.defaultEmpty,
          author: EntitiesConstants.defaultEmpty,
          lastChapterTitle: EntitiesConstants.defaultEmpty,
          lastChapterIndex: 0,
          lastChapterPos: 0,
          lastReadTimeMillis: 0,
        ),
      );
      final newer =
          (existing.lastReadTimeMillis >= p.durChapterTime) ? existing : ReadRecordModel(
            bookUrl: existing.bookUrl.isEmpty ? '' : existing.bookUrl,
            bookName: p.name,
            author: p.author,
            lastChapterTitle: p.durChapterTitle ?? '',
            lastChapterIndex: p.durChapterIndex,
            lastChapterPos: p.durChapterPos,
            lastReadTimeMillis: p.durChapterTime,
          );
      if (newer.bookUrl.isNotEmpty) {
        byUrl[newer.bookUrl] = newer;
      }
    }
    final merged = byUrl.values.toList(growable: true)
      ..sort((a, b) => b.lastReadTimeMillis.compareTo(a.lastReadTimeMillis));
    if (merged.length > _kMaxRecent) {
      merged.removeRange(_kMaxRecent, merged.length);
    }
    final payload =
        jsonEncode(merged.map((e) => e.toJson()).toList(growable: false));
    await _prefs.setString(_kRecentReadsKey, payload);
  }
}

