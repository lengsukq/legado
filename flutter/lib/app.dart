import 'package:flutter/material.dart';

import 'core/network/legado_http_client.dart';
import 'core/web_book/web_book_service.dart';
import 'features/bookshelf/bookshelf_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/sync/sync_screen.dart';
import 'features/explore/explore_screen.dart';
import 'app_dependencies.dart';

/// Shell app: routes map to future feature modules.
/// Kotlin reference: `legado-master/app/src/main/java/io/legado/app/ui/main/`
class LegadoApp extends StatelessWidget {
  const LegadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final http = LegadoHttpClient();
    final webBook = WebBookService(http);
    return AppDependencies(
      httpClient: http,
      webBookService: webBook,
      child: MaterialApp(
        title: 'Legado',
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
        ),
        home: const _MainShell(),
        routes: {
          BookshelfScreen.route: (_) => const BookshelfScreen(),
          ReaderScreen.route: (_) => const ReaderScreen(),
          SyncScreen.route: (_) => const SyncScreen(),
        },
      ),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;

  static const _titles = ['书架', '发现', '阅读', '备份与同步'];

  @override
  Widget build(BuildContext context) {
    const pages = [
      BookshelfScreen(),
      ExploreScreen(),
      ReaderScreen(),
      SyncScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '书架',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '发现',
          ),
          NavigationDestination(
            icon: Icon(Icons.chrome_reader_mode_outlined),
            selectedIcon: Icon(Icons.chrome_reader_mode),
            label: '阅读',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_sync_outlined),
            selectedIcon: Icon(Icons.cloud_sync),
            label: '同步',
          ),
        ],
      ),
    );
  }
}
