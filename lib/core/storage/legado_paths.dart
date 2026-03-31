import 'dart:io';

import 'package:path/path.dart' as p;

/// 提供与原版大致等价的工作目录结构。
///
/// 桌面端暂时放在用户目录下的 `Legado` 子目录中，
/// 后续可根据需要与 Android 端备份目录打通。
class LegadoPaths {
  LegadoPaths._();

  static Directory get _rootDir {
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    return Directory(p.join(home, 'Legado'));
  }

  static Directory get bookSourceDir =>
      Directory(p.join(_rootDir.path, 'bookSource'));

  static File get sourceSubscribeFile =>
      File(p.join(_rootDir.path, 'sourceSubscribe.json'));

  static Future<void> ensureBaseDirs() async {
    if (!await _rootDir.exists()) {
      await _rootDir.create(recursive: true);
    }
    if (!await bookSourceDir.exists()) {
      await bookSourceDir.create(recursive: true);
    }
  }
}

