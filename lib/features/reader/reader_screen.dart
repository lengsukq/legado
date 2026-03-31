import 'package:flutter/material.dart';

/// Reader. Reference: `legado-master/.../model/ReadBook.kt`, `ReadBookActivity`.
class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  static const route = '/reader';

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '在「书架」页粘贴书源 JSON 并搜索。\n'
        '打开书籍后在此可进行阅读排版扩展（分页/主题后续再加）。',
        textAlign: TextAlign.center,
      ),
    );
  }
}
