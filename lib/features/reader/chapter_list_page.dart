import 'package:flutter/material.dart';

import '../../core/entities/session_book.dart';
import '../../core/history/history_repository.dart';
import '../../core/models/book_progress.dart';
import '../../core/web_book/web_book_service.dart';
import 'chapter_read_page.dart';

class ChapterListPage extends StatefulWidget {
  const ChapterListPage({super.key, required this.book, required this.webBook});

  final SessionBook book;
  final WebBookService webBook;

  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  late Future<List<ChapterItem>> _future;
  BookProgress? _progress;

  @override
  void initState() {
    super.initState();
    _future = widget.webBook.loadChapters(widget.book);
    HistoryRepository.load().then(
      (repo) => repo.getBookProgress(widget.book.bookUrl),
    ).then((p) {
      if (!mounted) return;
      setState(() {
        _progress = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name.isEmpty ? '目录' : widget.book.name),
        actions: [
          if (_progress != null)
            IconButton(
              tooltip: '继续阅读',
              icon: const Icon(Icons.play_arrow),
              onPressed: () async {
                final p = _progress!;
                final chapters = await _future;
                if (p.durChapterIndex < 0 ||
                    p.durChapterIndex >= chapters.length) {
                  return;
                }
                final ch = chapters[p.durChapterIndex];
                if (!mounted) return;
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ChapterReadPage(
                      book: widget.book,
                      chapter: ch,
                      webBook: widget.webBook,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: FutureBuilder<List<ChapterItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final list = snap.data ?? [];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final ch = list[i];
              return ListTile(
                title: Text(ch.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ChapterReadPage(
                        book: widget.book,
                        chapter: ch,
                        webBook: widget.webBook,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
