### Flutter 模块架构概览

- `lib/app.dart`：应用入口 Shell，负责构建 `MaterialApp` 与底部导航。
- `lib/app_dependencies.dart`：通过 `InheritedWidget` 注入核心依赖，包括 `LegadoHttpClient`、`WebBookService` 以及懒加载的 `HistoryRepository`。
- `lib/core/`：领域与基础设施层，不依赖 Flutter UI。
  - `core/entities/`：实体与模型定义。
  - `core/history/`：阅读历史仓储 `HistoryRepository` 及其模型。
  - `core/web_book/`：网络书源解析相关服务（搜索、目录、正文等）。
  - `core/network/`：HTTP 客户端封装 `LegadoHttpClient`。
  - `core/backup/`、`core/webdav/`：备份与 WebDAV 同步相关逻辑。
- `lib/features/`：按功能划分的 UI 层。
  - `features/bookshelf/`：书架页 `BookshelfScreen` 与业务控制器 `BookshelfController`。
  - `features/reader/`：阅读页 `ReaderScreen`。
  - `features/sync/`：同步相关页面。

### 状态管理与依赖注入

- 控制器基于 `ChangeNotifier` 实现（例如 `BookshelfController`），负责处理业务状态和异步流程。
- UI 组件通过 `AnimatedBuilder` 或其他监听方式订阅控制器状态，仅负责渲染与路由跳转。
- 所有跨页面共享的核心服务通过 `AppDependencies` 统一创建和注入，避免在 Widget 中直接构造网络客户端或仓储。

### 目录与扩展约定

- 新增功能建议按以下方式组织：
  - 在 `lib/features/<feature_name>/` 下放置页面和与 UI 紧密相关的组件/控制器。
  - 在 `lib/core/<domain>/` 下放置对应的服务、仓储和领域模型。
- 遵循高内聚、低耦合原则，控制器/服务之间通过构造函数注入依赖，方便测试与替换实现。

