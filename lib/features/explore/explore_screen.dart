import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../core/entities/book_source_model.dart';
import '../bookshelf/bookshelf_controller.dart';
import 'explore_controller.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  static const route = '/explore';

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreController _controller;

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.of(context);
    _controller = ExploreController(deps.webBookService);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookshelf = _findBookshelfController(context);
      if (bookshelf != null) {
        _controller.setSources(bookshelf.sources);
      }
    });
  }

  BookshelfController? _findBookshelfController(BuildContext context) {
    // In this minimal implementation, we expect the bookshelf screen to be in the tree
    // and expose its controller via an inherited widget or similar.
    // For now, we just return null if not found; wiring can be refined later.
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller;
        return Column(
          children: [
            if (state.sources.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '暂无可用发现源，请先在书架页导入包含 exploreUrl 的书源。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButtonFormField<BookSourceModel>(
                  value: state.selectedSource,
                  decoration: const InputDecoration(labelText: '发现源'),
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
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >=
                          n.metrics.maxScrollExtent - 200 &&
                      state.hasMore &&
                      !state.isLoading) {
                    state.loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: state.books.length,
                  itemBuilder: (_, i) {
                    final b = state.books[i];
                    return ListTile(
                      title: Text(b.name),
                      subtitle: Text(
                        '${b.author} · ${b.latestChapterTitle ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        );
      },
    );
  }
}

