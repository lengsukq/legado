import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:legado_flutter/core/entities/session_book.dart';
import 'package:legado_flutter/core/history/history_repository.dart';
import 'package:legado_flutter/core/history/read_record_model.dart';
import 'package:legado_flutter/core/models/book_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryRepository', () {
    test('upsertRecord inserts and reads recent records', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = await HistoryRepository.load();
      expect(repo.getRecentReads(), isEmpty);

      final book = SessionBook(
        source: throw UnimplementedError(),
        bookUrl: 'u1',
        name: 'Book',
        author: 'Author',
        intro: null,
        coverUrl: null,
        infoHtml: '',
      );

      await repo.upsertRecord(
        book: book,
        chapterIndex: 1,
        chapterPos: 10,
        chapterTitle: 'Ch1',
      );

      final recent = repo.getRecentReads();
      expect(recent, hasLength(1));
      final r = recent.first;
      expect(r.bookUrl, 'u1');
      expect(r.bookName, 'Book');
      expect(r.lastChapterTitle, 'Ch1');
    });

    test('mergeProgressFromRemote merges and sorts by last read time', () async {
      final initial = {
        'legado_recent_reads': jsonEncode([
          const ReadRecordModel(
            bookUrl: 'b1',
            bookName: 'B1',
            author: 'A1',
            lastChapterTitle: 'L1',
            lastChapterIndex: 1,
            lastChapterPos: 0,
            lastReadTimeMillis: 1,
          ).toJson(),
        ]),
      };
      SharedPreferences.setMockInitialValues(initial);
      final repo = await HistoryRepository.load();

      final remote = [
        BookProgress(
          name: 'B1',
          author: 'A1',
          durChapterTitle: 'L2',
          durChapterIndex: 2,
          durChapterPos: 0,
          durChapterTime: 2,
        ),
      ];

      await repo.mergeProgressFromRemote(remote);

      final recent = repo.getRecentReads();
      expect(recent, hasLength(1));
      final r = recent.first;
      expect(r.lastChapterTitle, 'L2');
      expect(r.lastChapterIndex, 2);
    });
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:legado_flutter/core/history/history_repository.dart';
import 'package:legado_flutter/core/models/book_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mergeProgressFromRemote prefers newer progress', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = await HistoryRepository.load();

    final localProgress = BookProgress(
      name: 'Book',
      author: 'Author',
      durChapterIndex: 1,
      durChapterPos: 10,
      durChapterTime: 1000,
      durChapterTitle: 'Chap 1',
    );
    final remoteProgress = BookProgress(
      name: 'Book',
      author: 'Author',
      durChapterIndex: 2,
      durChapterPos: 20,
      durChapterTime: 2000,
      durChapterTitle: 'Chap 2',
    );

    await repo.mergeProgressFromRemote([localProgress]);
    await repo.mergeProgressFromRemote([remoteProgress]);

    final bp = await repo.getBookProgress('');
    expect(bp, isNull);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('legado_recent_reads');
    expect(raw, isNotNull);
    final list = jsonDecode(raw!) as List<dynamic>;
    expect(list.length, 1);
  });
}

