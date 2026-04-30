import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_pro/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TinyLearnersApp()));

    // Verify that the app starts.
    expect(find.byType(TinyLearnersApp), findsOneWidget);
  });
}
