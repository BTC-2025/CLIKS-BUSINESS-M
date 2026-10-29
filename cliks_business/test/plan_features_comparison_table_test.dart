import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/billing/widgets/plan_features_comparison_table.dart';

void main() {
  group('PlanFeaturesComparisonTable Widget Tests', () {
    testWidgets('Renders Plan Features Comparison header, tags, and 4 tier columns',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlanFeaturesComparisonTable(
                activeTierNumber: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Plan Features Comparison'), findsOneWidget);
      expect(find.text('30 Features Matrix'), findsOneWidget);
      expect(
        find.text(
          'Compare exact features, usage quotas, and capabilities across all subscription tiers.',
        ),
        findsOneWidget,
      );

      // Verify 4 Tier Columns in Table Header
      expect(find.text('Starter'), findsWidgets);
      expect(find.text('Standard'), findsWidgets);
      expect(find.text('Growth'), findsWidgets);
      expect(find.text('Elite'), findsWidgets);

      // Verify Pricing
      expect(find.text('₹1,188 / year'), findsOneWidget);
      expect(find.text('(~₹99/month)'), findsOneWidget);
      expect(find.text('BEST FOR SMALL BUSINESS'), findsOneWidget);

      expect(find.text('₹2,988 / year'), findsOneWidget);
      expect(find.text('(~₹249/month)'), findsOneWidget);
      expect(find.text('BEST FOR GROWING BUSINESS'), findsOneWidget);

      expect(find.text('₹6,588 / year'), findsOneWidget);
      expect(find.text('(~₹549/month)'), findsOneWidget);
      expect(find.text('HIGH-VELOCITY AUTOMATION'), findsOneWidget);

      expect(find.text('₹11,988 / year'), findsOneWidget);
      expect(find.text('(~₹999/month)'), findsOneWidget);
      expect(find.text('BEST FOR LARGE / ADVANCED BUSINESS'), findsOneWidget);
    });

    testWidgets('Displays features from multiple modules', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlanFeaturesComparisonTable(
                activeTierNumber: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check key features from different modules
      expect(find.text('Organization User Seats'), findsOneWidget);
      expect(find.text('Role-Based Access & Permissions'), findsOneWidget);
      expect(find.text('Annual Sales Invoices Cap'), findsOneWidget);
      expect(find.text('Customer Directory (CRM)'), findsOneWidget);
      expect(find.text('Customer Support & Uptime SLA'), findsOneWidget);

      // Verify removed features are NOT present
      expect(find.text('Simultaneous Device Sessions'), findsNothing);
      expect(find.text('Price Lists (Wholesale vs. Retail)'), findsNothing);
      expect(find.text('Bill of Materials (BOM) & Work Orders'), findsNothing);
      expect(find.text('Multi-Currency Accounting'), findsNothing);

      // Verify user seats values: 0, 2, 7, 15
      expect(find.text('0 Users'), findsOneWidget);
      expect(find.text('2 Users'), findsOneWidget);
      expect(find.text('7 Users'), findsOneWidget);
      expect(find.text('15 Users'), findsOneWidget);
    });

    testWidgets('Search input filters features correctly', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlanFeaturesComparisonTable(
                activeTierNumber: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search term "barcode"
      await tester.enterText(find.byType(TextField), 'barcode');
      await tester.pumpAndSettle();

      expect(find.text('Barcode & Thermal QR Label Engine'), findsOneWidget);
      expect(find.text('Organization User Seats'), findsNothing);
    });

    testWidgets('Category chips filter features correctly', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlanFeaturesComparisonTable(
                activeTierNumber: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Purchases" chip
      await tester.tap(find.text('Purchases'));
      await tester.pumpAndSettle();

      expect(find.text('Annual Purchase Bills & Expenses Cap'), findsOneWidget);
      expect(find.text('Purchase Orders (PO) & Debit Notes'), findsOneWidget);
      expect(find.text('Supplier / Vendor Directory'), findsOneWidget);
      expect(find.text('Organization User Seats'), findsNothing);
    });

    testWidgets('Upgrade button calls onUpgrade callback', (tester) async {
      tester.view.physicalSize = const Size(1400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int upgradedTier = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlanFeaturesComparisonTable(
                activeTierNumber: 1,
                onUpgrade: (tier) {
                  upgradedTier = tier;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to the bottom actions row
      final upgradeStandardBtn = find.text('Upgrade to Standard');
      await tester.ensureVisible(upgradeStandardBtn);
      await tester.pumpAndSettle();

      await tester.tap(upgradeStandardBtn);
      await tester.pumpAndSettle();

      expect(upgradedTier, 2);
    });
  });
}

