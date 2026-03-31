# Legado 迁移工程

- **`legado-master/`**  
  官方 Android 源码镜像（**不在此仓库中修改**，仅作阅读与行为对齐参考）。

- **`flutter/`**  
  Flutter 客户端：壳工程、路由占位、与官方互导备份/WebDAV 的约定文档（`flutter/docs/`）。

## 本地运行 Flutter

```bash
cd flutter
# 配置 android/local.properties：flutter.sdk 与 sdk.dir，参见 flutter/README.md
flutter pub get
flutter run
```

若无 `gradle-wrapper.jar`，请使用本机安装的 Flutter SDK 对 `flutter/android` 执行一次官方模板的同步，或重新在空目录 `flutter create` 再合并 `lib/` 与 `docs/`。
