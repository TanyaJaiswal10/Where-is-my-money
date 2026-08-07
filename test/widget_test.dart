import 'package:flutter_test/flutter_test.dart';
import 'package:where_is_my_money/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WhereIsMyMoneyApp());

    // Verify that onboarding title renders.
    expect(find.text("Where's My Money?"), findsWidgets);
  });
}
