# Kotlin → Flutter 模块映射（阅读路线图）

源代码根目录：`legado-master/`（只读参考）。

## 同步与存储

| Kotlin | Flutter（本仓库） |
|--------|---------------------|
| `help/AppWebDav.kt` | `lib/core/webdav/`（待实现客户端） |
| `help/storage/Backup.kt` | `lib/core/backup/` |
| `help/storage/Restore.kt` | `lib/core/backup/` |
| `help/storage/BackupConfig.kt` | 恢复忽略策略与备份口径 |
| `help/storage/BackupAES.kt` | `servers.json` 解密 |

## 书源与网络书

| Kotlin | Flutter（本仓库 `flutter/lib`） |
|--------|----------------------------------|
| `data/entities/BookSource.kt` + `data/entities/rule/*` | `core/entities/book_source_model.dart`、`book_list_rule.dart`（字段/规则 JSON 一一对应，`effectiveXxxRule` 对应 Kotlin `getXxxRule`） |
| `model/webBook/WebBook.kt` 及 `BookList/BookInfo/BookChapterList/BookContent` | `core/web_book/web_book_service.dart` |
| `model/analyzeRule/AnalyzeUrl.kt`（无 JS/WebView） | `core/analyze/analyze_url_lite.dart` |
| `model/analyzeRule/AnalyzeRule.kt`（HTML/CSS + JSONPath） | `core/analyze/rule_analyzer_lite.dart`         |
| `help/http/*` + Cookie | `core/network/legado_http_client.dart`（Dio + CookieJar） |
| `modules/rhino/` | Flutter Lite 中仅在 URL 模板内通过 QuickJS 执行少量 JS；`loginCheckJs`、正文 `webJs` / `imageDecode`、目录/正文多页 `nextTocUrl`、XPath 等高级特性目前统一在 `BookSourceInspector` 与 `WebBook*Service` 中标记为不支持或抛异常 |

## 阅读

| Kotlin | Flutter |
|--------|---------|
| `model/ReadBook.kt` | 阅读状态机、章节预加载 |
| `ui/book/read/*` | 排版、动画、菜单 |
| `modules/book/`（EPUB/UMD 等） | 本地书解析库或 FFI |

## 书架与发现

| Kotlin | Flutter |
|--------|---------|
| `ui/main/bookshelf/*` | `features/bookshelf/` |
| `ui/main/explore/*` | 发现页 |
| `data/entities/Book.kt` 等 | drift/sqflite 实体 |

## Web 与移动端共用前端（可选参考）

| 路径 | 说明 |
|------|------|
| `legado-master/modules/web/` | Vue 源编辑/书架（API 形态参考） |
