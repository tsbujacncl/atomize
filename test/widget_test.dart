import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomize/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AtomizeApp(),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify that the app bar shows "Today"
    expect(find.text('Today'), findsOneWidget);
  });
}
