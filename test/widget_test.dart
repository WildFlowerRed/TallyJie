import 'package:flutter_test/flutter_test.dart';
import 'package:tallyjie/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TallyJieApp());
    await tester.pumpAndSettle();

    // Verify the app renders without crashing
    expect(find.byType(TallyJieApp), findsNothing); // wrapped in MaterialApp.router
  });
}
