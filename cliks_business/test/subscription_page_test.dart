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
        expect(find.text('Micro Plan'), findsWidgets);
        expect(find.text('Starter Plan'), findsWidgets);
        expect(find.text('Standard Plan'), findsWidgets);
        expect(find.text('Growth Plan'), findsWidgets);
        expect(find.text('Elite Suite'), findsWidgets);
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

        // Find all Upgrade Plan buttons
        final upgradeButtons = find.widgetWithText(ElevatedButton, 'Upgrade Plan');
        expect(upgradeButtons, findsWidgets);

        // Scroll to button to ensure it is visible and hit-testable
        await tester.ensureVisible(upgradeButtons.first);
        await tester.pump(const Duration(milliseconds: 300));

        // Tap the first available upgrade button
        await tester.tap(upgradeButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Confirmation dialog should appear
        expect(find.textContaining('Upgrade Plan -'), findsOneWidget);
        final confirmButton = find.widgetWithText(ElevatedButton, 'Confirm Upgrade to Micro Plan');
        expect(confirmButton, findsOneWidget);

        // Confirm upgrade
        await tester.tap(confirmButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Dialog is dismissed and snackbar appears directly with success
        expect(find.text('Successfully upgraded to Micro Plan!'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('SubscriptionPage 5-Tier pricing, cards and down table render without overflow across all screens',
        (tester) async {
      final screenSizes = [
        const Size(1920, 1080),
        const Size(1366, 768),
        const Size(1100, 800),
        const Size(800, 600),
        const Size(375, 812),
        const Size(320, 568),
      ];

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

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

        // Verify all 5 tiers exist
        expect(find.text('Micro Plan'), findsWidgets);
        expect(find.text('Starter Plan'), findsWidgets);
        expect(find.text('Standard Plan'), findsWidgets);
        expect(find.text('Growth Plan'), findsWidgets);
        expect(find.text('Elite Suite'), findsWidgets);

        // Verify active plan banner has Elite Suite by default
        expect(find.text('Elite Suite'), findsWidgets);
        expect(find.text('Currently Active Plan'), findsWidgets);

        // Verify prices
        expect(find.text('₹250'), findsWidgets);
        expect(find.text('₹583'), findsWidgets);
        expect(find.text('₹899'), findsWidgets);
        expect(find.text('₹1,499'), findsWidgets);
        expect(find.text('₹2,499'), findsWidgets);

        // Verify down table features comparison
        expect(find.text('Platform Features'), findsOneWidget);

        // Verify add-ons, zoho comparison, and billing history invoice
        expect(find.text('Cliks Business — Optional Capability Add-ons'), findsOneWidget);
        expect(find.text('Why Indian Businesses Choose Cliks Over Zoho Books'), findsOneWidget);
        expect(find.text('INV-2026-1137'), findsOneWidget);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
