import 'package:flutter_test/flutter_test.dart';
import 'package:stipend_sign_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StipendSignApp());
    expect(find.text('Stipend Sign'), findsWidgets);
  });
}
