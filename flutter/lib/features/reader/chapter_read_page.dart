import 'package:flutter/material.dart';

import '../../core/entities/session_book.dart';
import '../../core/reader/read_session.dart';
import '../../core/history/history_repository.dart';
import '../../core/web_book/web_book_service.dart';

class ChapterReadPage extends StatefulWidget {
  const ChapterReadPage({
    super.key,
    required this.book,
    required this.chapter,
    required this.webBook,
  });

  final SessionBook book;
  final ChapterItem chapter;
  final WebBookService webBook;

  @override
  State<ChapterReadPage> createState() => _ChapterReadPageState();
}

class _ChapterReadPageState extends State<ChapterReadPage> {
  late ReadSession _session;

  @override
  void initState() {
    super.initState();
    _session = ReadSession(
      book: widget.book,
      webBook: widget.webBook,
      initialIndex: widget.chapter.index,
      onChapterOpened: (book, chapter) {
        HistoryRepository.load().then(
          (repo) => repo.upsertRecord(
            book: book,
            chapterIndex: chapter.index,
            chapterPos: 0,
            chapterTitle: chapter.title,
          ),
        );
      },
    );
    _session.openChapter(widget.chapter.index);
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _session.currentChapter.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _session.canPrev ? () => _session.prevChapter() : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: '上一章',
          ),
          IconButton(
            onPressed: _session.canNext ? () => _session.nextChapter() : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: '下一章',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _session,
        builder: (context, _) {
          switch (_session.status) {
            case ReadSessionStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ReadSessionStatus.error:
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${_session.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _session.openChapter(_session.currentIndex),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              );
            case ReadSessionStatus.ready:
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _session.content,
                  style: const TextStyle(height: 1.5),
                ),
              );
            case ReadSessionStatus.idle:
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
