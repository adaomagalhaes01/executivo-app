import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:executivo/main.dart';

void main() {
  testWidgets('ExecutivoApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ExecutivoApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
