import 'package:flutter_test/flutter_test.dart';
import 'package:ex1/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KelimeAvcisiApp());
    expect(find.text('KELİME\nAVCISI'), findsOneWidget);
  });
}
