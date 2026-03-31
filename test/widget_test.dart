import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/app.dart';

void main() {
  testWidgets('shell shows bookshelf tab', (tester) async {
    await tester.pumpWidget(const LegadoApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('书架'), findsWidgets);
  });
}
