import 'package:flutter_test/flutter_test.dart';
import 'package:hirewise/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HireWiseApp());
    expect(find.text('HireWise'), findsWidgets);
  });
}
