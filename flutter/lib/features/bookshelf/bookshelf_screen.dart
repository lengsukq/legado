import 'package:flutter/material.dart';

import '../../core/entities/search_book_model.dart';
import '../../app_dependencies.dart';
import 'bookshelf_controller.dart';
import '../reader/chapter_list_page.dart';

/// Import Legado book sources (JSON), search network, open reader flow.
/// Full rules require JS / XPath / WebView are reported as clear errors.
class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  static const route = '/bookshelf';

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  final _sourceCtrl = TextEditingController();
  final _keywordCtrl = TextEditingController();
  late final BookshelfController _controller;

  @override
  void dispose() {
    _controller.dispose();
    _sourceCtrl.dispose();
    _keywordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.of(context);
    _controller = BookshelfController(deps.webBookService);
    deps.historyRepository().then((repo) {
      if (mounted) {
        _controller.initialize(repo);
      }
    });
  }

  Future<void> _parseSources() async {
    await _controller.parseSources(_sourceCtrl.text);
  }

  Future<void> _search() async {
    await _controller.search(_keywordCtrl.text);
  }

  Future<void> _openBook(SearchBookModel hit) async {
    final session = await _controller.openBook(hit);
    if (!mounted || session == null) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChapterListPage(
          book: session,
          webBook: _controller.webBookService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _sourceCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '书源 JSON（官方导出或单源对象）',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FilledButton(
                onPressed: _parseSources,
                child: Text('解析 ${state.sources.length} 个书源'),
              ),
            ),
            if (state.sources.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: DropdownButtonFormField<BookSourceModel>(
                  value: state.selectedSource,
                  decoration: const InputDecoration(labelText: '当前书源'),
                  items: state.sources
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.bookSourceName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: state.selectSource,
                ),
              ),
            if (state.selectedInspection != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Builder(
                  builder: (context) {
                    final insp = state.selectedInspection!;
                    if (insp.supported || insp.issues.isEmpty) {
                      return Text(
                        '当前书源在 Flutter lite 模式下未检测到明显不兼容项。',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor),
                      );
                    }
                    final text = StringBuffer()
                      ..writeln('当前书源存在以下可能不兼容点：');
                    for (final issue in insp.issues) {
                      text.writeln('· $issue');
                    }
                    return Text(
                      text.toString().trimRight(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    );
                  },
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _keywordCtrl,
                      decoration: const InputDecoration(
                        labelText: '搜索关键词',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton.filled(
                          onPressed: _search,
                          icon: const Icon(Icons.search),
                        ),
                ),
              ],
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      itemCount: state.hits.length,
                      itemBuilder: (_, i) {
                        final h = state.hits[i];
                        return ListTile(
                          title: Text(h.name),
                          subtitle: Text(
                            '${h.author} · ${h.latestChapterTitle ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _openBook(h),
                        );
                      },
                    ),
                  ),
                  if (state.recentReads.isNotEmpty)
                    VerticalDivider(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                  if (state.recentReads.isNotEmpty)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              '最近阅读',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.recentReads.length,
                              itemBuilder: (_, i) {
                                final r = state.recentReads[i];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    r.bookName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    r.lastChapterTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
