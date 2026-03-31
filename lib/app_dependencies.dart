import 'package:flutter/widgets.dart';

import 'core/history/history_repository.dart';
import 'core/network/legado_http_client.dart';
import 'core/web_book/web_book_service.dart';

class AppDependencies extends InheritedWidget {
  AppDependencies({
    super.key,
    required super.child,
    required this.httpClient,
    required this.webBookService,
  });

  final LegadoHttpClient httpClient;
  final WebBookService webBookService;

  HistoryRepository? _historyRepository;

  static AppDependencies of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppDependencies>();
    assert(scope != null, 'AppDependencies not found in widget tree');
    return scope!;
  }

  Future<HistoryRepository> historyRepository() async {
    final existing = _historyRepository;
    if (existing != null) return existing;
    final loaded = await HistoryRepository.load();
    _historyRepository = loaded;
    return loaded;
  }

  @override
  bool updateShouldNotify(covariant AppDependencies oldWidget) {
    return httpClient != oldWidget.httpClient ||
        webBookService != oldWidget.webBookService;
  }
}

