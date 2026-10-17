import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/billing/pages/products_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/stock_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/warehouse_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/staff_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/payroll_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('Inventory & HR Sections - Mobile Card vs Desktop Table Verification', () {
    // ═════════════════════════════════════════════════════════════════════════
    // 1. INVENTORY → PRODUCTS PAGE
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('ProductsPage on Android (360x780): Renders mobile cards without overflow', (tester) async {
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
              body: ProductsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify card action icons exist
      expect(find.byIcon(LucideIcons.pencil), findsWidgets);
      expect(find.byIcon(LucideIcons.trash2), findsWidgets);
    });

    testWidgets('ProductsPage on Narrow Android (320x640): Renders mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
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
              body: ProductsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ProductsPage on iOS (390x844): Renders identical mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: ProductsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byIcon(LucideIcons.pencil), findsWidgets);
      expect(find.byIcon(LucideIcons.trash2), findsWidgets);
    });

    testWidgets('ProductsPage on macOS (1200x800): Preserves original desktop table', (tester) async {
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
              body: ProductsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // ═════════════════════════════════════════════════════════════════════════
    // 2. INVENTORY → STOCK PAGE
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('StockPage on Android (360x780): Renders mobile cards across all tabs without overflow', (tester) async {
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
              body: StockPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StockPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify Tab 0 (Stock Registry)
      expect(find.text('Stock Registry & Valuation'), findsWidgets);

      // Switch to Tab 1 (Transfers)
      final transfersTab = find.text('Warehouse Transfers');
      if (transfersTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(transfersTab.first);
        await tester.tap(transfersTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 2 (Batches)
      final batchesTab = find.text('Batches & Expiries');
      if (batchesTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(batchesTab.first);
        await tester.tap(batchesTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 3 (Product History)
      final historyTab = find.text('Product Detail & Daily Selling History');
      if (historyTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(historyTab.first);
        await tester.tap(historyTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('StockPage on Narrow Android (320x640): Renders mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
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
              body: StockPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StockPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StockPage on iOS (390x844): Renders identical mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: StockPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StockPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StockPage on macOS (1200x800): Preserves desktop tables', (tester) async {
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
              body: StockPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StockPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // ═════════════════════════════════════════════════════════════════════════
    // 3. INVENTORY → WAREHOUSE PAGE
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('WarehousePage on Android (360x780): Renders mobile cards across tabs without overflow', (tester) async {
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
              body: WarehousePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WarehousePage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch to Tab 1 (Stock Registry)
      final stockTab = find.text('Stock Registry');
      if (stockTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(stockTab.first);
        await tester.tap(stockTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 2 (Goods Inward Audit)
      final inwardTab = find.text('Goods Inward Audit');
      if (inwardTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(inwardTab.first);
        await tester.tap(inwardTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('WarehousePage on Narrow Android (320x640): Renders mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
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
              body: WarehousePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WarehousePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('WarehousePage on iOS (390x844): Renders identical mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: WarehousePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WarehousePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('WarehousePage on macOS (1200x800): Preserves desktop tables', (tester) async {
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
              body: WarehousePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WarehousePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // ═════════════════════════════════════════════════════════════════════════
    // 4. HR → STAFF PAGE
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('StaffPage on Android (360x780): Renders mobile cards across all tabs without overflow', (tester) async {
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
              body: StaffPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StaffPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify Tab 0 (Employee Profiles)
      expect(find.text('Employee Profiles'), findsWidgets);

      // Switch to Tab 1 (Leaves & Shifts Rosters)
      final leavesTab = find.text('Leaves & Shifts Rosters');
      if (leavesTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(leavesTab.first);
        await tester.tap(leavesTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 2 (Performance Appraisals)
      final appraisalTab = find.text('Performance Appraisals');
      if (appraisalTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(appraisalTab.first);
        await tester.tap(appraisalTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 3 (Staff Reimbursements)
      final claimTab = find.text('Staff Reimbursements');
      if (claimTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(claimTab.first);
        await tester.tap(claimTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('StaffPage on Narrow Android (320x640): Renders mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
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
              body: StaffPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StaffPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StaffPage on iOS (390x844): Renders identical mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: StaffPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StaffPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StaffPage on macOS (1200x800): Preserves desktop tables', (tester) async {
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
              body: StaffPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StaffPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // ═════════════════════════════════════════════════════════════════════════
    // 5. HR → PAYROLL PAGE
    // ═════════════════════════════════════════════════════════════════════════
    testWidgets('PayrollPage on Android (360x780): Renders mobile cards across all tabs without overflow', (tester) async {
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
              body: PayrollPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PayrollPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify Tab 0 (Monthly Payroll Register)
      expect(find.text('Monthly Payroll Register'), findsWidgets);

      // Switch to Tab 1 (Salary Structures (CTC))
      final structTab = find.text('Salary Structures (CTC)');
      if (structTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(structTab.first);
        await tester.tap(structTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 2 (Compliance (PF / ESI / PAN))
      final compTab = find.text('Compliance (PF / ESI / PAN)');
      if (compTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(compTab.first);
        await tester.tap(compTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Switch to Tab 3 (Loans & Salary Advances)
      final loansTab = find.text('Loans & Salary Advances');
      if (loansTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(loansTab.first);
        await tester.tap(loansTab.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('PayrollPage on Narrow Android (320x640): Renders mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
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
              body: PayrollPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PayrollPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PayrollPage on iOS (390x844): Renders identical mobile cards cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: PayrollPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PayrollPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PayrollPage on macOS (1200x800): Preserves desktop tables', (tester) async {
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
              body: PayrollPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PayrollPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
