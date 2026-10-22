import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/navigation/widgets/macos_showroom_menu_card.dart';
import 'package:clicks_business_frontend/features/navigation/shell_layout.dart';

void main() {
  testWidgets('MacOSShowroomMenuCard renders all items correctly matching reference design',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: MacOSShowroomMenuCard(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Scope Header
    expect(find.text('BRANCH / SHOWROOM'), findsOneWidget);
    expect(find.text('SCOPE'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('REGISTERED'), findsOneWidget);

    // Verify All Showrooms card
    expect(find.text('All Showrooms'), findsOneWidget);
    expect(find.text('Company-wide consolidated data'), findsOneWidget);

    // Verify Individual Showrooms section
    expect(find.text('INDIVIDUAL SHOWROOMS'), findsOneWidget);
    expect(find.text('Main Showroom'), findsOneWidget);
    expect(find.text('MAIN-01 • Chennai • Main HQ'), findsOneWidget);

    // Verify Bottom Action Button
    expect(find.text('Manage Showrooms & Stock'), findsOneWidget);
  });

  testWidgets('TopNavBar & ShellLayout show Showroom Card on macOS when tapped',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;

    try {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ShellLayout(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Showroom menu is initially closed
      expect(find.byType(MacOSShowroomMenuCard), findsNothing);

      // Find and tap the showroom selector pill
      final showroomPill = find.text('All Showrooms (Consoli...');
      expect(showroomPill, findsOneWidget);
      await tester.tap(showroomPill);
      await tester.pumpAndSettle();

      // Showroom menu is now open
      expect(find.byType(MacOSShowroomMenuCard), findsOneWidget);
      expect(find.text('BRANCH / SHOWROOM'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('REGISTERED'), findsOneWidget);
      expect(find.text('Manage Showrooms & Stock'), findsOneWidget);

      // Tap Main Showroom option
      await tester.tap(find.text('Main Showroom'));
      await tester.pumpAndSettle();

      // Card is dismissed and pill reflects selected scope
      expect(find.byType(MacOSShowroomMenuCard), findsNothing);
      expect(find.text('Main Showroom (MAIN-01)'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
}
