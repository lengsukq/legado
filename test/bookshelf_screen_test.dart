import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:legado_flutter/app.dart';

void main() {
  testWidgets('BookshelfScreen shows source and keyword inputs',
      (tester) async {
    await tester.pumpWidget(const LegadoApp());

    expect(find.textContaining('书源 JSON'), findsOneWidget);
    expect(find.text('搜索关键词'), findsOneWidget);
  });
}

