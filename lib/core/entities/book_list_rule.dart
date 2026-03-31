import '../json_helpers.dart';

/// Common list fields: `SearchRule` / `ExploreRule`
mixin BookListRuleMixin {
  String? bookList;
  String? name;
  String? author;
  String? intro;
  String? kind;
  String? lastChapter;
  String? updateTime;
  String? bookUrl;
  String? coverUrl;
  String? wordCount;
}

class SearchRule with BookListRuleMixin {
  SearchRule({
    this.checkKeyWord,
    String? bookList,
    String? name,
    String? author,
    String? intro,
    String? kind,
    String? lastChapter,
    String? updateTime,
    String? bookUrl,
    String? coverUrl,
    String? wordCount,
  }) {
    this.bookList = bookList;
    this.name = name;
    this.author = author;
    this.intro = intro;
    this.kind = kind;
    this.lastChapter = lastChapter;
    this.updateTime = updateTime;
    this.bookUrl = bookUrl;
    this.coverUrl = coverUrl;
    this.wordCount = wordCount;
  }

  String? checkKeyWord;

  static SearchRule? fromJson(dynamic j) {
    final m = coerceToMap(j);
    if (m == null) return null;
    return SearchRule(
      checkKeyWord: m['checkKeyWord'] as String?,
      bookList: m['bookList'] as String?,
      name: m['name'] as String?,
      author: m['author'] as String?,
      intro: m['intro'] as String?,
      kind: m['kind'] as String?,
      lastChapter: m['lastChapter'] as String?,
      updateTime: m['updateTime'] as String?,
      bookUrl: m['bookUrl'] as String?,
      coverUrl: m['coverUrl'] as String?,
      wordCount: m['wordCount'] as String?,
    );
  }
}

class ExploreRule with BookListRuleMixin {
  ExploreRule({
    String? bookList,
    String? name,
    String? author,
    String? intro,
    String? kind,
    String? lastChapter,
    String? updateTime,
    String? bookUrl,
    String? coverUrl,
    String? wordCount,
  }) {
    this.bookList = bookList;
    this.name = name;
    this.author = author;
    this.intro = intro;
    this.kind = kind;
    this.lastChapter = lastChapter;
    this.updateTime = updateTime;
    this.bookUrl = bookUrl;
    this.coverUrl = coverUrl;
    this.wordCount = wordCount;
  }

  static ExploreRule? fromJson(dynamic j) {
    final m = coerceToMap(j);
    if (m == null) return null;
    return ExploreRule(
      bookList: m['bookList'] as String?,
      name: m['name'] as String?,
      author: m['author'] as String?,
      intro: m['intro'] as String?,
      kind: m['kind'] as String?,
      lastChapter: m['lastChapter'] as String?,
      updateTime: m['updateTime'] as String?,
      bookUrl: m['bookUrl'] as String?,
      coverUrl: m['coverUrl'] as String?,
      wordCount: m['wordCount'] as String?,
    );
  }
}

class BookInfoRule {
  BookInfoRule({
    this.init,
    this.name,
    this.author,
    this.intro,
    this.kind,
    this.lastChapter,
    this.updateTime,
    this.coverUrl,
    this.tocUrl,
    this.wordCount,
    this.canReName,
    this.downloadUrls,
  });

  String? init;
  String? name;
  String? author;
  String? intro;
  String? kind;
  String? lastChapter;
  String? updateTime;
  String? coverUrl;
  String? tocUrl;
  String? wordCount;
  String? canReName;
  String? downloadUrls;

  static BookInfoRule? fromJson(dynamic j) {
    final m = coerceToMap(j);
    if (m == null) return null;
    return BookInfoRule(
      init: m['init'] as String?,
      name: m['name'] as String?,
      author: m['author'] as String?,
      intro: m['intro'] as String?,
      kind: m['kind'] as String?,
      lastChapter: m['lastChapter'] as String?,
      updateTime: m['updateTime'] as String?,
      coverUrl: m['coverUrl'] as String?,
      tocUrl: m['tocUrl'] as String?,
      wordCount: m['wordCount'] as String?,
      canReName: m['canReName'] as String?,
      downloadUrls: m['downloadUrls'] as String?,
    );
  }
}

class TocRule {
  TocRule({
    this.preUpdateJs,
    this.chapterList,
    this.chapterName,
    this.chapterUrl,
    this.formatJs,
    this.isVolume,
    this.isVip,
    this.isPay,
    this.updateTime,
    this.nextTocUrl,
  });

  String? preUpdateJs;
  String? chapterList;
  String? chapterName;
  String? chapterUrl;
  String? formatJs;
  String? isVolume;
  String? isVip;
  String? isPay;
  String? updateTime;
  String? nextTocUrl;

  static TocRule? fromJson(dynamic j) {
    final m = coerceToMap(j);
    if (m == null) return null;
    return TocRule(
      preUpdateJs: m['preUpdateJs'] as String?,
      chapterList: m['chapterList'] as String?,
      chapterName: m['chapterName'] as String?,
      chapterUrl: m['chapterUrl'] as String?,
      formatJs: m['formatJs'] as String?,
      isVolume: m['isVolume'] as String?,
      isVip: m['isVip'] as String?,
      isPay: m['isPay'] as String?,
      updateTime: m['updateTime'] as String?,
      nextTocUrl: m['nextTocUrl'] as String?,
    );
  }
}

class ContentRule {
  ContentRule({
    this.content,
    this.title,
    this.nextContentUrl,
    this.webJs,
    this.sourceRegex,
    this.replaceRegex,
    this.imageStyle,
    this.imageDecode,
    this.payAction,
  });

  String? content;
  String? title;
  String? nextContentUrl;
  String? webJs;
  String? sourceRegex;
  String? replaceRegex;
  String? imageStyle;
  String? imageDecode;
  String? payAction;

  static ContentRule? fromJson(dynamic j) {
    final m = coerceToMap(j);
    if (m == null) return null;
    return ContentRule(
      content: m['content'] as String?,
      title: m['title'] as String?,
      nextContentUrl: m['nextContentUrl'] as String?,
      webJs: m['webJs'] as String?,
      sourceRegex: m['sourceRegex'] as String?,
      replaceRegex: m['replaceRegex'] as String?,
      imageStyle: m['imageStyle'] as String?,
      imageDecode: m['imageDecode'] as String?,
      payAction: m['payAction'] as String?,
    );
  }
}

class ReviewRule {
  ReviewRule({
    this.reviewUrl,
    this.avatarRule,
    this.contentRule,
    this.postTimeRule,
    this.reviewQuoteUrl,
  });

  String? reviewUrl;
  String? avatarRule;
  String? contentRule;
  String? postTimeRule;
  String? reviewQuoteUrl;

  static ReviewRule? fromJson(dynamic j) {
    final m = coerceToMap(j);
    if (m == null) return null;
    return ReviewRule(
      reviewUrl: m['reviewUrl'] as String?,
      avatarRule: m['avatarRule'] as String?,
      contentRule: m['contentRule'] as String?,
      postTimeRule: m['postTimeRule'] as String?,
      reviewQuoteUrl: m['reviewQuoteUrl'] as String?,
    );
  }
}
