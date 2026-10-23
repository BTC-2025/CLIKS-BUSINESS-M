import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/billing/pages/subscription_page.dart';

void main() {
  group('SubscriptionPage without Payment Gateway', () {
    testWidgets('SubscriptionPage renders without payment gateway banner on Desktop (macOS)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      try {
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

        // Ensure page rendered
        expect(find.byType(SubscriptionPage), findsOneWidget);

        // Verify NO payment gateway banners or mentions
        expect(find.text('YOUPI PG Gateway Live Test Mode'), findsNothing);
        expect(find.text('Test ₹1 Payment'), findsNothing);
        expect(find.text('Payment Gateway Ready'), findsNothing);

        // Verify core workspace tiers are present
        expect(find.text('Upgrade Workspace Tier'), findsOneWidget);
        expect(find.text('Tier 1 (Starter)'), findsWidgets);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('SubscriptionPage renders without payment gateway banner on Mobile (Android)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      try {
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

        // Ensure page rendered
        expect(find.byType(SubscriptionPage), findsOneWidget);

        // Verify NO payment gateway banners or mentions
        expect(find.text('YOUPI PG Gateway Live Test Mode'), findsNothing);
        expect(find.text('Test ₹1 Payment'), findsNothing);
        expect(find.text('Payment Gateway Ready'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('Tapping Upgrade Plan opens confirmation dialog and directly activates tier without payment gateway',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      try {
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

        // Find all Upgrade Plan buttons (Tier 2 Standard is first available upgrade)
        final upgradeButtons = find.widgetWithText(ElevatedButton, 'Upgrade Plan');
        expect(upgradeButtons, findsWidgets);

        // Scroll to button to ensure it is visible and hit-testable
        await tester.ensureVisible(upgradeButtons.first);
        await tester.pump(const Duration(milliseconds: 300));

        // Tap the first available upgrade button
        await tester.tap(upgradeButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Confirmation dialog should appear for Tier 2 (Standard)
        expect(find.textContaining('Upgrade Plan -'), findsOneWidget);
        final confirmButton = find.widgetWithText(ElevatedButton, 'Confirm Upgrade to Tier 2 (Standard)');
        expect(confirmButton, findsOneWidget);

        // Confirm upgrade
        await tester.tap(confirmButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Dialog is dismissed and snackbar appears directly with success
        expect(find.text('Successfully upgraded to Tier 2 (Standard)!'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
