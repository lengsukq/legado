import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:legado_flutter/features/reader/reader_screen.dart';

void main() {
  testWidgets('ReaderScreen renders hint text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ReaderScreen(),
      ),
    );

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.textContaining('在「书架」页粘贴书源 JSON'), findsOneWidget);
  });
}

