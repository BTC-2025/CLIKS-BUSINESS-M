import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/billing/pages/showrooms_page.dart';

void main() {
  group('Showrooms & Multi-Branch Page - Layout, Modals & Multi-OS Tests', () {
    testWidgets('Renders all headers, metric cards, tabs, and cards on macOS Desktop (1280x800)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Header Banner
        expect(find.text('Showrooms & Multi-Branch'), findsOneWidget);
        expect(find.text('Multi-outlet inventory control, showroom billing separation, and inter-branch stock transfers.'), findsOneWidget);

        // Header Buttons
        expect(find.text('Showroom Managers'), findsOneWidget);
        expect(find.text('Transfer Stock'), findsOneWidget);
        expect(find.text('Return Goods to Main'), findsOneWidget);
        expect(find.text('+ Add Showroom'), findsOneWidget);

        // 2. 5 Metric Cards
        expect(find.text('TOTAL SHOWROOMS'), findsOneWidget);
        expect(find.text('SELECTED BRANCH'), findsOneWidget);
        expect(find.text('ITEMS IN BRANCH'), findsOneWidget);
        expect(find.text('LOW STOCK ALERTS'), findsOneWidget);
        expect(find.text('8 critical'), findsOneWidget);
        expect(find.text('TRANSFERS & RETURNS'), findsOneWidget);

        // 3. Segmented Tabs
        expect(find.text('Showrooms List (1)'), findsOneWidget);
        expect(find.text('Branch Stock Matrix'), findsOneWidget);
        expect(find.text('Low Stock & Auto-Reorder'), findsOneWidget);
        expect(find.text('Transfers & Returns Log (0)'), findsOneWidget);

        // 4. Showroom Card
        expect(find.text('Main Showroom'), findsAtLeast(1));
        expect(find.text('HQ / MAIN'), findsOneWidget);
        expect(find.text('Code: MAIN-01 | Prefix: MS-'), findsOneWidget);
        expect(find.text('Central Commercial Hub, Chennai'), findsOneWidget);
        expect(find.text('STOCK ITEMS'), findsOneWidget);
        expect(find.text('TOTAL UNITS'), findsOneWidget);
        expect(find.text('Add Manager'), findsOneWidget);
        expect(find.text('View Stock'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Renders cleanly on Windows Desktop (1024x577 matching reference resolution)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      tester.view.physicalSize = const Size(1024, 577);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Showrooms & Multi-Branch'), findsOneWidget);
        expect(find.text('Transfer Stock'), findsOneWidget);
        expect(find.text('+ Add Showroom'), findsOneWidget);
        expect(find.text('TOTAL SHOWROOMS'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Renders cleanly on Android Mobile (360x780) without overflow',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Showrooms & Multi-Branch'), findsOneWidget);
        expect(find.text('TOTAL SHOWROOMS'), findsOneWidget);
        expect(find.text('Main Showroom'), findsAtLeast(1));
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Renders cleanly on iOS Mobile (390x844) without overflow',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Showrooms & Multi-Branch'), findsOneWidget);
        expect(find.text('TOTAL SHOWROOMS'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Modal 1: Transfer Goods Across Showrooms opens and submits transfer',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap 'Transfer Stock' button
        final transferBtn = find.text('Transfer Stock');
        expect(transferBtn, findsOneWidget);
        await tester.tap(transferBtn);
        await tester.pumpAndSettle();

        // Dialog should be visible (Image 3)
        expect(find.text('Transfer Goods Across Showrooms'), findsOneWidget);
        expect(find.text('Source Showroom (From)'), findsOneWidget);
        expect(find.text('Destination (To)'), findsOneWidget);
        expect(find.text('Select Product'), findsOneWidget);
        expect(find.text('Transfer Quantity'), findsOneWidget);
        expect(find.text('Transfer Notes / Reason'), findsOneWidget);
        expect(find.text('Confirm & Dispatch Transfer'), findsOneWidget);

        // Tap Confirm & Dispatch Transfer
        await tester.tap(find.text('Confirm & Dispatch Transfer'));
        await tester.pumpAndSettle();

        // Dialog closed and transfer logged
        expect(find.text('Transfer Goods Across Showrooms'), findsNothing);
        expect(find.text('TRANSFERS & RETURNS'), findsOneWidget);
        expect(find.text('1'), findsAtLeast(1)); // Transfers count updated to 1
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Modal 2: Return Goods to Main Warehouse opens and submits return',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap 'Return Goods to Main' button
        final returnBtn = find.text('Return Goods to Main');
        expect(returnBtn, findsOneWidget);
        await tester.tap(returnBtn);
        await tester.pumpAndSettle();

        // Dialog should be visible (Image 4)
        expect(find.text('Return Goods to Main Warehouse'), findsOneWidget);
        expect(find.text('Reverse inventory transfer for damaged, dead, or consolidated showroom stock.'), findsOneWidget);
        expect(find.text('Origin Showroom (Returning From) *'), findsOneWidget);
        expect(find.text('Destination (Central Hub)'), findsOneWidget);
        expect(find.text('Return Classification / Reason *'), findsOneWidget);
        expect(find.text('Product to Return *'), findsOneWidget);
        expect(find.text('Return Quantity *'), findsOneWidget);
        expect(find.text('Inspection Notes / Reason Details'), findsOneWidget);
        expect(find.text('Confirm & Dispatch Return to Main Showroom'), findsOneWidget);

        // Tap Confirm & Dispatch Return
        await tester.tap(find.text('Confirm & Dispatch Return to Main Showroom'));
        await tester.pumpAndSettle();

        // Dialog closed
        expect(find.text('Return Goods to Main Warehouse'), findsNothing);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Modal 3: Register New Showroom opens, creates showroom, updates count',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap '+ Add Showroom' button
        final addBtn = find.text('+ Add Showroom');
        expect(addBtn, findsOneWidget);
        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        // Dialog should be visible (Image 5)
        expect(find.text('Register New Showroom'), findsOneWidget);
        expect(find.text('Showroom Name *'), findsOneWidget);
        expect(find.text('Branch Code *'), findsOneWidget);
        expect(find.text('Invoice Prefix'), findsOneWidget);
        expect(find.text('Address'), findsOneWidget);
        expect(find.text('City'), findsOneWidget);
        expect(find.text('Phone Number'), findsOneWidget);
        expect(find.text('Branch GSTIN (Optional)'), findsOneWidget);
        expect(find.text('Set as Primary / Main Showroom (HQ)'), findsOneWidget);
        expect(find.text('Register Showroom'), findsOneWidget);

        // Tap Register Showroom
        await tester.tap(find.text('Register Showroom'));
        await tester.pumpAndSettle();

        // New showroom added, count becomes 2
        expect(find.text('Register New Showroom'), findsNothing);
        expect(find.text('Showrooms List (2)'), findsOneWidget);
        expect(find.text('Tambaram Showroom'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Segmented tabs switch content correctly and Adjust Stock dialog functions',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Switch to Branch Stock Matrix (Image 1)
        await tester.tap(find.text('Branch Stock Matrix'));
        await tester.pumpAndSettle();
        expect(find.text('Current Showroom:'), findsOneWidget);
        expect(find.text('a new digit product'), findsOneWidget);
        expect(find.text('apple'), findsOneWidget);
        expect(find.text('Adjust Stock'), findsWidgets);

        // Open Adjust Stock Dialog (Image 2)
        await tester.tap(find.text('Adjust Stock').first);
        await tester.pumpAndSettle();
        expect(find.text('Adjust Stock for Showroom'), findsOneWidget);
        expect(find.textContaining('Updating stock for a new digit product at Main Showroom'), findsOneWidget);
        expect(find.text('Quantity Available'), findsOneWidget);
        expect(find.text('Save Stock'), findsOneWidget);

        // Cancel dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Adjust Stock for Showroom'), findsNothing);

        // 2. Switch to Low Stock & Auto-Reorder (Images 3 & 4)
        await tester.tap(find.textContaining('Low Stock & Auto-Reorder'));
        await tester.pumpAndSettle();
        expect(find.text('Showroom Stock Depletion & Automated Replenishment'), findsOneWidget);
        expect(find.text('TOTAL SHORTAGES'), findsOneWidget);
        expect(find.text('CRITICAL OUT-OF-STOCK'), findsOneWidget);
        expect(find.text('MAIN SHOWROOM READY'), findsOneWidget);
        expect(find.text('Items Requiring Replenishment'), findsOneWidget);
        expect(find.text('Indent Now'), findsWidgets);

        // 3. Switch to Transfers & Returns Log (Image 5)
        await tester.tap(find.textContaining('Transfers & Returns Log'));
        await tester.pumpAndSettle();
        expect(find.text('Showroom Stock Movements & Return Logistics'), findsOneWidget);
        expect(find.text('+ New Transfer'), findsOneWidget);
        expect(find.text('Return Damaged / Dead Stock'), findsOneWidget);
        expect(find.textContaining('No inter-branch transfers recorded yet'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Showroom Promos & Discounts tab, empty state, request dialog, and promo creation (Images 1, 2, 3)',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShowroomsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Switch to Showroom Promos & Discounts (Image 1)
        await tester.tap(find.text('Showroom Promos & Discounts'));
        await tester.pumpAndSettle();

        // Banner elements (Image 1)
        expect(find.text('LOCAL PRICING & PROMOTIONS'), findsOneWidget);
        expect(find.text('Showroom-Specific Pricing & Festive Discounts'), findsOneWidget);
        expect(find.text('Request Local Discount'), findsOneWidget);

        // Filter elements (Image 1)
        expect(find.text('Showroom:'), findsOneWidget);
        expect(find.text('Status:'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Pending Approval'), findsOneWidget);
        expect(find.text('Approved / Active'), findsOneWidget);
        expect(find.text('Rejected'), findsOneWidget);
        expect(find.text('0 promotions recorded'), findsOneWidget);

        // Empty state (Image 3)
        expect(find.text('No Showroom Promotions Found'), findsOneWidget);
        expect(find.text('Request First Promotion'), findsOneWidget);

        // 2. Open Request Showroom Promotion dialog from button (Image 2)
        await tester.tap(find.text('Request Local Discount'));
        await tester.pumpAndSettle();

        expect(find.text('Request Showroom Promotion'), findsOneWidget);
        expect(find.text('Local showroom discounts require Main Branch approval'), findsOneWidget);
        expect(find.text('Target Showroom *'), findsOneWidget);
        expect(find.text('Promotion Campaign Title *'), findsOneWidget);
        expect(find.text('Discount Type *'), findsOneWidget);
        expect(find.text('Applicable Scope *'), findsOneWidget);
        expect(find.text('Minimum Bill Amount'), findsOneWidget);
        expect(find.text('Start Date *'), findsOneWidget);
        expect(find.text('End Date *'), findsOneWidget);
        expect(find.text('Business Justification & Local Market Reason *'), findsOneWidget);
        expect(find.textContaining('Strict Showroom Isolation:'), findsOneWidget);
        expect(find.text('Submit Promotion Request'), findsOneWidget);

        // Fill Title
        final inputs = find.byType(TextFormField);
        await tester.enterText(inputs.first, 'Diwali Festive Rush 10%');
        await tester.pumpAndSettle();

        // Submit Promotion Request
        await tester.tap(find.text('Submit Promotion Request'));
        await tester.pumpAndSettle();

        // Dialog closes, promotion added to list
        expect(find.text('Request Showroom Promotion'), findsNothing);
        expect(find.text('1 promotions recorded'), findsOneWidget);
        expect(find.text('Diwali Festive Rush 10%'), findsOneWidget);
        expect(find.text('PENDING APPROVAL'), findsOneWidget);
        expect(find.text('Approve'), findsOneWidget);
        expect(find.text('Reject'), findsOneWidget);

        // Approve promotion
        await tester.ensureVisible(find.text('Approve'));
        await tester.tap(find.text('Approve'));
        await tester.pumpAndSettle();
        expect(find.text('APPROVED / ACTIVE'), findsOneWidget);
        expect(find.text('Deactivate'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });
  });
}
