// Basic smoke test for the Mayfair Rwanda app.

import 'package:flutter_test/flutter_test.dart';

import 'package:mayfair_rwanda/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MayfairApp());

    // Hero headline and a product category should be present on first frame.
    expect(find.text('Our insurance solutions'), findsOneWidget);
    expect(find.text('Motor Insurance'), findsWidgets);

    // Bottom navigation tabs are present.
    expect(find.text('Products'), findsWidgets);
    expect(find.text('Contact'), findsWidgets);
  });
}
