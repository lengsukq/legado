# 原 Android 客户端（Legado）

本目录为从仓库根目录迁入的 **Gradle 多模块工程**，与根目录的 `modules/web`（Vue 书架/源编辑前端）分离，便于与 Flutter 等新客户端并存。

## 布局

- `app/`：阅读主应用
- `modules/book/`：EPUB、UMD 等本地书解析
- `modules/rhino/`：书源规则 JS 引擎封装
- `gradle/`、`gradlew*`、`settings.gradle`、`build.gradle`、`gradle.properties`：构建入口

## 构建

在项目根目录执行（需 JDK 17）：

```bash
cd native
./gradlew assembleAppRelease
```

Windows：`native\gradlew.bat assembleAppRelease`

首次请在 `native/local.properties` 中配置 `sdk.dir`；若使用 Android Studio，打开 **`native` 目录** 作为 Gradle 项目即可。
