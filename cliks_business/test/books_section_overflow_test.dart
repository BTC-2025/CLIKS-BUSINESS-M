import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/billing/pages/customers_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/simple_billing_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/new_invoice_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/orders_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/returns_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/products_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/stock_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/warehouse_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/reports_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/attendance_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/payroll_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/staff_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/pos_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/fintech_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/barcode_gen_page.dart';
import 'package:clicks_business_frontend/features/dashboard/dashboard_page.dart';
import 'package:clicks_business_frontend/widgets/modals/sales_modals.dart';
import 'package:clicks_business_frontend/features/purchases/pages/purchase_invoice_page.dart';
import 'package:clicks_business_frontend/features/purchases/pages/suppliers_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('Books Section Mobile Pages & Tabs Overflow Checks', () {
    testWidgets('CustomersPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomersPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomersPage), findsOneWidget);

      // Check Aging & Collection Reports Tab
      final agingTab = find.textContaining('Aging & Collection');
      if (agingTab.evaluate().isNotEmpty) {
        await tester.tap(agingTab, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('DashboardPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DashboardPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('SimpleBillingPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SimpleBillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SimpleBillingPage), findsOneWidget);
    });

    testWidgets('NewInvoicePage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NewInvoicePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NewInvoicePage), findsOneWidget);
    });

    testWidgets('OrdersPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: OrdersPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OrdersPage), findsOneWidget);
    });

    testWidgets('ReturnsPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ReturnsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReturnsPage), findsOneWidget);
    });

    testWidgets('ProductsPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProductsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProductsPage), findsOneWidget);
    });

    testWidgets('StockPage renders on 360px without overflow across all tabs', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StockPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StockPage), findsOneWidget);

      // Verify Tab 1: Warehouse Branch Transfers
      final tab1 = find.text('Warehouse Branch Transfers');
      if (tab1.evaluate().isNotEmpty) {
        await tester.tap(tab1, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Warehouse Branch transfers'), findsOneWidget);
        expect(find.text('Transfer Stock'), findsOneWidget);
      }

      // Verify Tab 3: Historical Product Stock Ledger
      final tab3 = find.text('Historical Product Stock Ledger');
      if (tab3.evaluate().isNotEmpty) {
        await tester.tap(tab3, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.textContaining('Interval:'), findsOneWidget);
        expect(find.text('Customize View'), findsOneWidget);
      }
    });

    testWidgets('WarehousePage renders on 360px without overflow across all tabs and opens dialogs', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WarehousePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WarehousePage), findsOneWidget);

      // Open Register Warehouse Facility dialog
      final regWhBtn = find.text('Register Warehouse');
      if (regWhBtn.evaluate().isNotEmpty) {
        await tester.tap(regWhBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Register New Warehouse Facility'), findsOneWidget);
        // Close dialog
        await tester.tap(find.byIcon(LucideIcons.x));
        await tester.pumpAndSettle();
      }

      // Open Goods Inward Receiving dialog
      final inwardBtn = find.text('Goods Inward Receiving');
      if (inwardBtn.evaluate().isNotEmpty) {
        await tester.tap(inwardBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Goods Inward Receipt'), findsOneWidget);
        // Close dialog
        await tester.tap(find.byIcon(LucideIcons.x));
        await tester.pumpAndSettle();
      }

      // Switch to Goods Inward Historical logs tab
      final auditTab = find.text('Goods Inward Historical logs');
      if (auditTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(auditTab);
        await tester.pumpAndSettle();
        await tester.tap(auditTab);
        await tester.pumpAndSettle();
        expect(find.text('Goods Inwards Audit Trail'), findsOneWidget);
      }
    });

    testWidgets('ReportsPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ReportsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReportsPage), findsOneWidget);
    });

    testWidgets('AddCustomerModal renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AddCustomerModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AddCustomerModal), findsOneWidget);
    });

    testWidgets('StaffPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StaffPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StaffPage), findsOneWidget);
    });

    testWidgets('PayrollPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PayrollPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PayrollPage), findsOneWidget);
    });

    testWidgets('AttendancePage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AttendancePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AttendancePage), findsOneWidget);
    });

    testWidgets('PosPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PosPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PosPage), findsOneWidget);
    });

    testWidgets('FintechPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FintechPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FintechPage), findsOneWidget);
    });

    testWidgets('BarcodeGenPage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BarcodeGenPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BarcodeGenPage), findsOneWidget);
    });

    testWidgets('PurchaseInvoicePage renders on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PurchaseInvoicePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PurchaseInvoicePage), findsOneWidget);

      // Open New Purchase Order / Invoice dialog
      final addBtn = find.text('+ New PO');
      if (addBtn.evaluate().isNotEmpty) {
        await tester.tap(addBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('ITEMIZED PRODUCTS'), findsOneWidget);
      }
    });

    testWidgets('SuppliersPage renders on 360px without overflow and opens dialogs', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SuppliersPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SuppliersPage), findsOneWidget);

      // Open Bulk Import dialog
      final bulkBtn = find.text('Bulk Import (CSV)');
      if (bulkBtn.evaluate().isNotEmpty) {
        await tester.tap(bulkBtn, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Bulk Import Suppliers (CSV)'), findsOneWidget);
        // Close dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      }

      // Open Register Vendor dialog
      final registerBtn = find.textContaining('Register Supplier');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.textContaining('Vendor Profile'), findsWidgets);
        expect(find.text('Basic Information'), findsOneWidget);
        expect(find.text('Address Details'), findsOneWidget);
      }
    });

    testWidgets('ProductsPage opens Add Product modal on 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProductsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProductsPage), findsOneWidget);

      // Open Add Product / Service dialog
      final addProdBtn = find.text('Add Product / Service');
      if (addProdBtn.evaluate().isNotEmpty) {
        await tester.tap(addProdBtn, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('New Product Registration'), findsOneWidget);
        expect(find.text('Physical Product'), findsOneWidget);
        expect(find.text('Service Offering'), findsOneWidget);

        // Tap Service Offering tab
        await tester.tap(find.text('Service Offering'), warnIfMissed: false);
        await tester.pumpAndSettle();

        // Tap Physical Product tab back
        await tester.tap(find.text('Physical Product'), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Books pages (Stock, Warehouse, Purchases, Suppliers) render on ultra-compact 320px without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. StockPage on 320px
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StockPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StockPage), findsOneWidget);

      // 2. WarehousePage on 320px
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WarehousePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WarehousePage), findsOneWidget);

      // 3. PurchaseInvoicePage on 320px
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PurchaseInvoicePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PurchaseInvoicePage), findsOneWidget);

      // 4. SuppliersPage on 320px
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SuppliersPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SuppliersPage), findsOneWidget);
    });
  });
}
