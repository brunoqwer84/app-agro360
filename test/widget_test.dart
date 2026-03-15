import 'package:flutter_test/flutter_test.dart';
import 'package:agro360/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that splash screen is shown
    expect(find.text('Agro360'), findsWidgets);
  });
}
