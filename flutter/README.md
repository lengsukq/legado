# Legado Flutter（迁移中）

- **只读参考源码**：上一级目录的 `legado-master/`（请勿在此仓库内修改该文件夹）。
- **本目录**：可运行的 Flutter 壳与后续业务实现。

## 环境

1. 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)（stable）。
2. 本目录首次若缺少 `android/` / `ios/`：在 `flutter/` 下执行：

```bash
flutter create . --project-name legado_flutter --org io.legado --platforms=android,ios
```

若已存在 `android/` 且冲突，请先备份再合并；或仅补充缺失平台。

3. 依赖与检查：

```bash
cd flutter
flutter pub get
flutter analyze
flutter run
```

## 文档

- `docs/SYNC_AND_BACKUP_SPEC.md`：与官方 App 互导备份 / WebDAV 的约定。
- `docs/SOURCE_MAP.md`：`legado-master` 与 Flutter 目录的对应关系。

## 书源与阅读（当前能力）

已实现与官方 **书源 JSON** 对齐的数据结构，以及 **无 JS / 无 XPath / 无 WebView** 场景下的：

- `searchUrl` 模板（`{{key}}`、`{{page}}`、`<页码,页码>`、`Url` 后的 `,{...}` GET/POST）
- 列表/详情/目录/正文：`$.` / `@Json:` + **json_path**，或 **CSS 选择器**（`@CSS:` / `@@` / 默认）
- **书架 tab**：粘贴书源 → 搜索 → 目录 → 正文（`SelectableText`）

仍未兼容（会抛出明确错误）的规则与能力：`<js>` / `@js:`、`loginCheckJs`、`XPath`、`webView`、目录/正文多页链、`ruleBookInfo.init` 的 JSON 正文分支等。完整兼容需要接入 QuickJS 等与 Rhino 对等的运行时（参考 `legado-master/modules/rhino`）。

## Android applicationId

生成工程时使用包名 `io.legado.legadoFlutter`（或你选定的 suffix），避免与官方 `io.legado.app` 冲突。
