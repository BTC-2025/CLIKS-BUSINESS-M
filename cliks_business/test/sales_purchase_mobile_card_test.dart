import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/billing/pages/billing_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/customers_page.dart';
import 'package:clicks_business_frontend/features/purchases/pages/purchase_invoice_page.dart';
import 'package:clicks_business_frontend/features/purchases/pages/suppliers_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('Sales & Purchase Sections - Mobile Card vs Desktop Table Verification', () {
    // ═════════════════════════════════════════════════════════════════════════
    // 1. BILLING PAGE (Sales Invoices & Challans)
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('BillingPage on Android (360x780): Renders mobile cards across tabs without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: const Scaffold(
              body: BillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BillingPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify mobile cards in Tab 0 (Invoices List)
      expect(find.text('Invoices List'), findsOneWidget);
      expect(find.byIcon(LucideIcons.printer), findsWidgets);
      expect(find.byIcon(LucideIcons.share2), findsWidgets);

      // Switch to Tab 1: Sales Returns
      final returnsTab = find.text('Sales Returns & Credit Notes');
      if (returnsTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(returnsTab);
        await tester.tap(returnsTab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 2: Warranty & Replacement Claims
      final warrantyTab = find.text('Warranty & Replacement Claims');
      if (warrantyTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(warrantyTab);
        await tester.tap(warrantyTab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 3: DELIVERY CHALLAN
      final challanTab = find.text('DELIVERY CHALLAN');
      if (challanTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(challanTab);
        await tester.tap(challanTab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('BillingPage on macOS (1200x800): Preserves original desktop layout and tables', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: BillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BillingPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verifies desktop-specific navigation or headers
      expect(find.text('Invoices List'), findsWidgets);
    });

    // ═════════════════════════════════════════════════════════════════════════
    // 2. CUSTOMERS PAGE (Sales Customers)
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('CustomersPage on Android (360x780): Renders mobile customer cards and ledger modal', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(
            body: CustomersPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomersPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify mobile customer cards are rendered with 'View Ledger' button
      final viewLedgerBtn = find.text('View Ledger');
      expect(viewLedgerBtn, findsWidgets);

      // Open ledger modal to verify mobile ledger cards
      await tester.ensureVisible(viewLedgerBtn.first);
      await tester.tap(viewLedgerBtn.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Ledger Statement'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Close modal
      final closeBtn = find.byIcon(LucideIcons.x);
      if (closeBtn.evaluate().isNotEmpty) {
        await tester.tap(closeBtn.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('CustomersPage on macOS (1200x800): Preserves original desktop directory table', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: const Scaffold(
            body: CustomersPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomersPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      // Desktop header
      expect(find.text('Customers & Udhaar Ledger'), findsOneWidget);
    });

    // ═════════════════════════════════════════════════════════════════════════
    // 3. PURCHASE INVOICE PAGE (Purchase Orders, Bills & Returns)
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('PurchaseInvoicePage on Android (360x1000): Renders mobile cards across PO, Bills & Returns', (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(
            body: PurchaseInvoicePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PurchaseInvoicePage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 0: PO tab (initially empty list, shows mobile empty state)
      expect(find.text('Purchase Orders (PO)'), findsOneWidget);
      expect(find.text('No active purchase orders found'), findsOneWidget);

      // Switch to Bills tab (contains mock purchase bills rendered as mobile cards)
      final billsTab = find.text('Purchase Bills & Invoices');
      await tester.ensureVisible(billsTab);
      await tester.tap(billsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('jeni fancy 5050'), findsWidgets);
      expect(find.text('Total Payable'), findsWidgets);

      // Switch to Returns tab (contains mock returns rendered as mobile cards)
      final returnsTab = find.text('Purchase Returns (Suppliers)');
      await tester.ensureVisible(returnsTab);
      await tester.tap(returnsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('RET-'), findsWidgets);
      expect(find.text('Credit Note Applied'), findsWidgets);
    });

    testWidgets('PurchaseInvoicePage on macOS (1200x800): Preserves original desktop tables', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: const Scaffold(
            body: PurchaseInvoicePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PurchaseInvoicePage), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.text('Purchases Hub'), findsOneWidget);
      expect(find.text('OUTWARD PROCUREMENT (AT COST)'), findsOneWidget);
    });

    // ═════════════════════════════════════════════════════════════════════════
    // 4. SUPPLIERS PAGE (Suppliers Master Base & Ledger)
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('SuppliersPage on Android (360x1000): Renders mobile supplier cards and ledger cards', (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(
            body: SuppliersPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SuppliersPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify supplier cards in Master Base (default tab)
      expect(find.text('Suppliers Master Base'), findsOneWidget);
      expect(find.text('CREDIT LIMIT'), findsWidgets);
      final viewLedgerBtn = find.text('View Ledger');
      expect(viewLedgerBtn, findsWidgets);

      // Tap 'View Ledger' on first supplier to view their running ledger statements
      await tester.ensureVisible(viewLedgerBtn.first);
      await tester.tap(viewLedgerBtn.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Bal: '), findsWidgets);
    });

    testWidgets('SuppliersPage on macOS (1200x800): Preserves original desktop UI', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: const Scaffold(
            body: SuppliersPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SuppliersPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.text('Suppliers Master Suite'), findsOneWidget);
      expect(find.text('Manage vendor demographics, credit limits, purchase ledgers, and outward payables aging summaries.'), findsOneWidget);
    });

    // ═════════════════════════════════════════════════════════════════════════
    // 5. ULTRA-COMPACT 320px MOBILE VIEWPORT CHECKS
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('All 4 pages render without RenderFlex overflow on ultra-compact 320px viewport', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. BillingPage
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: const Scaffold(body: BillingPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BillingPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. CustomersPage
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(body: CustomersPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CustomersPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. PurchaseInvoicePage
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(body: PurchaseInvoicePage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PurchaseInvoicePage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 4. SuppliersPage
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(body: SuppliersPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SuppliersPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
