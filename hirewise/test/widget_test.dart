import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App structure test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(child: Text('HireWise')))));
    expect(find.text('HireWise'), findsOneWidget);
  });
}
