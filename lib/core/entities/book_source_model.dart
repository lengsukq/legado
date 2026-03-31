import '../json_helpers.dart';
import 'book_list_rule.dart';

/// Mirrors `legado-master/.../data/entities/BookSource.kt` JSON shape (Gson camelCase).
class BookSourceModel {
  BookSourceModel({
    required this.bookSourceUrl,
    required this.bookSourceName,
    this.bookSourceGroup,
    this.bookSourceType = 0,
    this.bookUrlPattern,
    this.customOrder = 0,
    this.enabled = true,
    this.enabledExplore = true,
    this.jsLib,
    this.enabledCookieJar = true,
    this.concurrentRate,
    this.header,
    this.loginUrl,
    this.loginUi,
    this.loginCheckJs,
    this.coverDecodeJs,
    this.bookSourceComment,
    this.variableComment,
    this.lastUpdateTime = 0,
    this.respondTime = 180000,
    this.weight = 0,
    this.exploreUrl,
    this.exploreScreen,
    this.ruleExplore,
    this.searchUrl,
    this.ruleSearch,
    this.ruleBookInfo,
    this.ruleToc,
    this.ruleContent,
    this.ruleReview,
  });

  final String bookSourceUrl;
  final String bookSourceName;
  final String? bookSourceGroup;
  final int bookSourceType;
  final String? bookUrlPattern;
  final int customOrder;
  final bool enabled;
  final bool enabledExplore;
  final String? jsLib;
  final bool? enabledCookieJar;
  final String? concurrentRate;
  final String? header;
  final String? loginUrl;
  final String? loginUi;
  final String? loginCheckJs;
  final String? coverDecodeJs;
  final String? bookSourceComment;
  final String? variableComment;
  final int lastUpdateTime;
  final int respondTime;
  final int weight;
  final String? exploreUrl;
  final String? exploreScreen;
  final ExploreRule? ruleExplore;
  final String? searchUrl;
  final SearchRule? ruleSearch;
  final BookInfoRule? ruleBookInfo;
  final TocRule? ruleToc;
  final ContentRule? ruleContent;
  final ReviewRule? ruleReview;

  SearchRule effectiveSearchRule() => ruleSearch ?? SearchRule();

  ExploreRule effectiveExploreRule() => ruleExplore ?? ExploreRule();

  BookInfoRule effectiveBookInfoRule() => ruleBookInfo ?? BookInfoRule();

  TocRule effectiveTocRule() => ruleToc ?? TocRule();

  ContentRule effectiveContentRule() => ruleContent ?? ContentRule();

  static BookSourceModel fromJson(Map<String, dynamic> m) {
    return BookSourceModel(
      bookSourceUrl: m['bookSourceUrl'] as String? ?? '',
      bookSourceName: m['bookSourceName'] as String? ?? '',
      bookSourceGroup: m['bookSourceGroup'] as String?,
      bookSourceType: (m['bookSourceType'] as num?)?.toInt() ?? 0,
      bookUrlPattern: m['bookUrlPattern'] as String?,
      customOrder: (m['customOrder'] as num?)?.toInt() ?? 0,
      enabled: m['enabled'] as bool? ?? true,
      enabledExplore: m['enabledExplore'] as bool? ?? true,
      jsLib: m['jsLib'] as String?,
      enabledCookieJar: m['enabledCookieJar'] as bool?,
      concurrentRate: m['concurrentRate'] as String?,
      header: m['header'] as String?,
      loginUrl: m['loginUrl'] as String?,
      loginUi: m['loginUi'] as String?,
      loginCheckJs: m['loginCheckJs'] as String?,
      coverDecodeJs: m['coverDecodeJs'] as String?,
      bookSourceComment: m['bookSourceComment'] as String?,
      variableComment: m['variableComment'] as String?,
      lastUpdateTime: (m['lastUpdateTime'] as num?)?.toInt() ?? 0,
      respondTime: (m['respondTime'] as num?)?.toInt() ?? 180000,
      weight: (m['weight'] as num?)?.toInt() ?? 0,
      exploreUrl: m['exploreUrl'] as String?,
      exploreScreen: m['exploreScreen'] as String?,
      ruleExplore: ExploreRule.fromJson(m['ruleExplore']),
      searchUrl: m['searchUrl'] as String?,
      ruleSearch: SearchRule.fromJson(m['ruleSearch']),
      ruleBookInfo: BookInfoRule.fromJson(m['ruleBookInfo']),
      ruleToc: TocRule.fromJson(m['ruleToc']),
      ruleContent: ContentRule.fromJson(m['ruleContent']),
      ruleReview: ReviewRule.fromJson(m['ruleReview']),
    );
  }
}
