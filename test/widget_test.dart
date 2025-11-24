import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomize/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AtomizeApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('Atomize'), findsOneWidget);
    expect(find.text('Atomize V1.2'), findsOneWidget);
    expect(find.text('Small habits. Big change.'), findsOneWidget);

    // Verify score demos are present
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });
}
