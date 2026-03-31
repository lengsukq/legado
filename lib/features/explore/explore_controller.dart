import 'package:flutter/foundation.dart';

import '../../core/entities/book_source_model.dart';
import '../../core/entities/search_book_model.dart';
import '../../core/web_book/web_book_service.dart';
import '../../core/web_book/web_book_search_service.dart';

class ExploreController extends ChangeNotifier {
  ExploreController(this._webBook);

  final WebBookService _webBook;

  List<BookSourceModel> _sources = [];
  bool _loading = false;
  String? _error;
  BookSourceModel? _selectedSource;
  String? _selectedExploreUrl;
  final List<SearchBookModel> _books = [];
  int _page = 1;
  bool _hasMore = true;

  List<BookSourceModel> get sources => _sources;
  bool get isLoading => _loading;
  String? get errorMessage => _error;
  BookSourceModel? get selectedSource => _selectedSource;
  List<SearchBookModel> get books => List.unmodifiable(_books);
  bool get hasMore => _hasMore;

  void setSources(List<BookSourceModel> all) {
    _sources = all.where((s) => s.enabledExplore && s.exploreUrl != null && s.exploreUrl!.isNotEmpty).toList();
    if (_sources.isNotEmpty && _selectedSource == null) {
      _selectedSource = _sources.first;
      _selectedExploreUrl = _selectedSource!.exploreUrl;
    }
    notifyListeners();
  }

  void selectSource(BookSourceModel? source) {
    _selectedSource = source;
    _selectedExploreUrl = source?.exploreUrl;
    _books.clear();
    _page = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  Future<void> loadMore() async {
    final src = _selectedSource;
    final url = _selectedExploreUrl;
    if (src == null || url == null || url.isEmpty || !_hasMore || _loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _webBook.searchService.explore(
        src,
        exploreUrl: url,
        page: _page,
      );
      if (list.isEmpty) {
        _hasMore = false;
      } else {
        _books.addAll(list);
        _page += 1;
      }
    } catch (e) {
      _error = '$e';
      _hasMore = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

