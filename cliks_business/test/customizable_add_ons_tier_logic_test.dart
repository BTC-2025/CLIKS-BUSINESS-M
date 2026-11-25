import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/billing/pages/subscription_page.dart';

void main() {
  group('Customizable Add-Ons & Tier 3+ Logic Tests', () {
    testWidgets('Customizable add-ons are active on Tier 5 and allow adding to plan', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubscriptionPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify sub-selector tabs exist
      expect(find.text('Standard Tiers'), findsOneWidget);
      expect(find.text('✦ Customizable Plan & Add-Ons'), findsOneWidget);

      // Scroll to Optional Capability Add-ons section
      final addOnsHeader = find.text('Cliks Business — Optional Capability Add-ons');
      expect(addOnsHeader, findsOneWidget);
      await tester.ensureVisible(addOnsHeader);
      await tester.pump(const Duration(milliseconds: 300));

      // Since default tier is Tier 5 (Elite), it should show Applicable badge
      expect(find.text('Tier 5 Active'), findsOneWidget);

      // Verify Action buttons show "Add to Plan"
      final addButtons = find.text('Add to Plan');
      expect(addButtons, findsWidgets);

      // Tap the first "Add to Plan" button (Extra Sub IDs)
      await tester.ensureVisible(addButtons.first);
      await tester.tap(addButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog opens
      expect(find.text('Add Extra Sub IDs'), findsOneWidget);
      expect(find.text('Confirm & Add to Plan'), findsOneWidget);

      // Confirm add-on
      await tester.tap(find.text('Confirm & Add to Plan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Successfully added snackbar appears and button changes to Added ✓
      expect(find.text('Successfully activated Extra Sub IDs (1 user) for your workspace!'), findsOneWidget);
      expect(find.text('Added ✓'), findsOneWidget);

      // Active Add-ons summary banner appears
      expect(find.text('Active Add-ons (1):'), findsOneWidget);
    });

    testWidgets('Before Tier 3 (Tier 1 & Tier 2), add-ons show Requires Tier 3+ and allow instant upgrade to unlock', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubscriptionPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Select Micro (Tier 1) via Upgrade Plan button on Micro card
      final upgradeButtons = find.widgetWithText(ElevatedButton, 'Upgrade Plan');
      expect(upgradeButtons, findsWidgets);
      await tester.ensureVisible(upgradeButtons.first);
      await tester.tap(upgradeButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Confirm upgrade to Micro
      final confirmBtn = find.text('Confirm Upgrade to Micro');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now workspace is on Tier 1 (Micro)
      // Scroll to Optional Capability Add-ons section
      final addOnsHeader = find.text('Cliks Business — Optional Capability Add-ons');
      await tester.ensureVisible(addOnsHeader);
      await tester.pump(const Duration(milliseconds: 300));

      // Badge should show "Tier 3+ Only"
      expect(find.text('Tier 3+ Only'), findsOneWidget);

      // Buttons must show "Requires Tier 3+"
      final requiresTier3Buttons = find.text('Requires Tier 3+');
      expect(requiresTier3Buttons, findsWidgets);

      // Tap on "Requires Tier 3+"
      await tester.ensureVisible(requiresTier3Buttons.first);
      await tester.tap(requiresTier3Buttons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog opens explaining that Tier 3 is required
      expect(find.text('Tier 3 Required for Add-ons'), findsOneWidget);
      final upgradeToTier3Btn = find.widgetWithText(ElevatedButton, 'Upgrade to Standard (Tier 3)');
      expect(upgradeToTier3Btn, findsOneWidget);

      // Click "Upgrade to Standard (Tier 3)"
      await tester.tap(upgradeToTier3Btn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Upgraded to Tier 3 and buttons immediately become "Add to Plan"
      expect(find.text('Successfully upgraded to Standard (Tier 3)! Customizable add-ons are now unlocked.'), findsOneWidget);
      expect(find.text('Add to Plan'), findsWidgets);
      expect(find.text('Tier 3 Active'), findsOneWidget);
    });

    testWidgets('Toggling sub-tabs switches between Standard Tiers and Customizable Plan Builder', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubscriptionPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to ✦ Customizable Plan & Add-Ons
      final customTab = find.text('✦ Customizable Plan & Add-Ons');
      expect(customTab, findsOneWidget);
      await tester.tap(customTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Optional Capability Add-ons is rendered alone without boosters
      expect(find.text('Cliks Business — Optional Capability Add-ons'), findsOneWidget);
      expect(find.text('Customize Workspace & Add-On Boosters'), findsNothing);

      // Switch back to Standard Tiers
      await tester.tap(find.text('Standard Tiers'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify standard tiers view rendered
      expect(find.text('Upgrade Workspace Tier'), findsOneWidget);
    });

    testWidgets('Customizable add-ons support multi-quantity stepper, billing frequency, and removal', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubscriptionPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll to add-ons
      final addOnsHeader = find.text('Cliks Business — Optional Capability Add-ons');
      await tester.ensureVisible(addOnsHeader);
      await tester.pump(const Duration(milliseconds: 300));

      // Find Extra Branches row (second "Add to Plan" button)
      final addButtons = find.text('Add to Plan');
      expect(addButtons, findsWidgets);

      await tester.ensureVisible(addButtons.at(1));
      await tester.tap(addButtons.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog opens for Extra Branches
      expect(find.text('Add Extra Branches'), findsOneWidget);
      expect(find.text('Select Quantity:'), findsOneWidget);

      // Increment quantity with stepper [+]
      final plusIcons = find.byIcon(Icons.add);
      // LucideIcons.plus:
      final plusStepper = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(IconButton),
      );
      // The second IconButton in stepper is [+]
      await tester.tap(plusStepper.last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('2 branches'), findsOneWidget);

      // Select Annual frequency
      await tester.tap(find.text('Annual'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Confirm add-on
      await tester.tap(find.text('Confirm & Add to Plan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify button shows Added (2x) ✓
      expect(find.text('Added (2x) ✓'), findsOneWidget);

      // Open manage dialog by tapping Added (2x) ✓
      await tester.tap(find.text('Added (2x) ✓'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Manage Extra Branches'), findsOneWidget);
      expect(find.text('Remove Add-On'), findsOneWidget);

      // Remove add-on
      await tester.tap(find.text('Remove Add-On'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Button reverts back to Add to Plan
      expect(find.text('Removed Extra Branches add-on from workspace.'), findsOneWidget);
    });
  });
}
