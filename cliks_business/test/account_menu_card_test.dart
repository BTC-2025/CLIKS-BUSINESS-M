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

    // Verify avatar initial 'R' exists
    expect(find.text('R'), findsAtLeast(1));

    // Verify username or email
    expect(find.text('Manage Branches'), findsOneWidget);

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

      // Find and tap the user profile capsule button by tooltip
      final profileButton = find.byTooltip('Account Settings');
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

  testWidgets('TopNavBar & ShellLayout show Account Card on macOS and click Manage Branches',
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
      final profileButton = find.byTooltip('Account Settings');
      expect(profileButton, findsOneWidget);
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Account menu is now visible on macOS!
      expect(find.byType(MacOSAccountMenuCard), findsOneWidget);
      final manageBranchesBtn = find.text('Manage Branches');
      expect(manageBranchesBtn, findsOneWidget);

      // Tap 'Manage Branches'
      await tester.tap(manageBranchesBtn);
      await tester.pumpAndSettle();

      // Showrooms & Multi-Branch page is now shown!
      expect(find.text('Showrooms & Multi-Branch'), findsOneWidget);
      expect(find.text('TOTAL SHOWROOMS'), findsOneWidget);
      expect(find.text('LOW STOCK ALERTS'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('TopNavBar & ShellLayout show Account Card on macOS and click Manage SubIDs',
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
      final profileButton = find.byTooltip('Account Settings');
      expect(profileButton, findsOneWidget);
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Account menu is now visible
      expect(find.byType(MacOSAccountMenuCard), findsOneWidget);
      final manageSubIdsBtn = find.text('Manage SubIDs');
      expect(manageSubIdsBtn, findsOneWidget);

      // Tap 'Manage SubIDs'
      await tester.tap(manageSubIdsBtn);
      await tester.pumpAndSettle();

      // Sub-IDs & Manage Permissions page is now displayed!
      expect(find.text('Manage Permissions'), findsOneWidget);
      expect(find.text('Sub-IDs'), findsAtLeast(1));
      expect(find.text('ravi kumar'), findsOneWidget);
      expect(find.text('Only Generate Invoice Control (Strict Mode)'), findsOneWidget);
      expect(find.text('ACCESS CONTROL HIERARCHY'), findsOneWidget);
      expect(find.text('Finance'), findsAtLeast(1));
      expect(find.text('Sales'), findsAtLeast(1));
    } finally {
      debugDefaultTargetPlatformOverride = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
}
