import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/navigation/widgets/macos_account_menu_card.dart';
import 'package:clicks_business_frontend/features/navigation/shell_layout.dart';

void main() {
  testWidgets('MacOSAccountMenuCard renders all items correctly matching reference design',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: MacOSAccountMenuCard(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify avatar initial 'R'
    expect(find.text('R'), findsOneWidget);

    // Verify username and email
    expect(find.text('ravinew2004'), findsOneWidget);
    expect(find.text('ravinew2004@bnxmail.com'), findsOneWidget);

    // Verify status
    expect(find.text('Make it Primary'), findsOneWidget);

    // Verify buttons and menu items
    expect(find.text('Manage your account'), findsOneWidget);
    expect(find.text('Manage Branches'), findsOneWidget);
    expect(find.text('Manage SubIDs'), findsOneWidget);
    expect(find.text('Add another account'), findsOneWidget);
    expect(find.text('Sign out of all accounts'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('TopNavBar & ShellLayout show Account Card on Windows OS',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
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

      // Account menu is initially closed
      expect(find.byType(MacOSAccountMenuCard), findsNothing);

      // Find and tap the user profile capsule button
      final profileButton = find.text('ravinew2004');
      expect(profileButton, findsOneWidget);
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Account menu is now visible on Windows OS!
      expect(find.byType(MacOSAccountMenuCard), findsOneWidget);
      expect(find.text('Manage Branches'), findsOneWidget);
      expect(find.text('Manage SubIDs'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('TopNavBar & ShellLayout show Account Card on macOS',
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

      // Account menu is initially closed
      expect(find.byType(MacOSAccountMenuCard), findsNothing);

      // Find and tap the user profile capsule button
      final profileButton = find.text('ravinew2004');
      expect(profileButton, findsOneWidget);
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Account menu is now visible on macOS!
      expect(find.byType(MacOSAccountMenuCard), findsOneWidget);
      expect(find.text('Manage Branches'), findsOneWidget);
      expect(find.text('Manage SubIDs'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
}
