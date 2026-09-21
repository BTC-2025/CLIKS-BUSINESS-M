import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clicks_business_frontend/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: CliksBusinessApp(),
      ),
    );

    // Verify that the app widget renders.
    expect(find.byType(CliksBusinessApp), findsOneWidget);
  });
}

