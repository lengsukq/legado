import 'package:flutter/material.dart';

import '../../core/backup/backup_constants.dart';
import '../../core/webdav/webdav_paths.dart';

/// Backup / WebDAV. Reference: `legado-master/.../help/AppWebDav.kt`, `help/storage/Backup.kt`.
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  static const route = '/sync';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('与官方 Legado 对齐的契约摘要（详见 docs/SYNC_AND_BACKUP_SPEC.md）：'),
        const SizedBox(height: 12),
        Text('备份 ZIP 内条目: ${BackupConstants.zipEntryNames.take(8).join(", ")}…'),
        const SizedBox(height: 8),
        Text('WebDAV 子路径: ${WebDavPaths.progressDir}, ${WebDavPaths.booksDir}, …'),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('尚未实现'),
                content: const Text('下一步：实现 WebDAV 客户端与 ZIP 解压导入。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            );
          },
          child: const Text('从 WebDAV 恢复（占位）'),
        ),
      ],
    );
  }
}
