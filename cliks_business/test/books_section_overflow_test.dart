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
import 'package:clicks_business_frontend/widgets/bento/bento_chart_card.dart';
import 'package:clicks_business_frontend/widgets/bento/bento_card.dart';
import 'package:clicks_business_frontend/features/billing/pages/subscription_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:clicks_business_frontend/features/billing/pages/accounting_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/expenses_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/gst_page.dart';

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

    testWidgets('StaffPage renders on 360px without overflow across all tabs and dialogs', (tester) async {
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

      // Scroll down to table
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      // Verify Tab 0: Employee Profiles Table and drag horizontally
      expect(find.text('EMPLOYEE PROFILE'), findsOneWidget);
      expect(find.text('PERSONAL INFO'), findsOneWidget);
      final horizontalScrolls = find.byType(SingleChildScrollView);
      if (horizontalScrolls.evaluate().length > 2) {
        // Drag table horizontally to reveal RESIDENTIAL ADDRESS and ACTION
        await tester.drag(horizontalScrolls.last, const Offset(-900, 0), warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Open Edit Employee dialog
      final editIcon = find.byIcon(LucideIcons.pencil);
      if (editIcon.evaluate().isNotEmpty) {
        await tester.tap(editIcon.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.textContaining('Edit Employee'), findsOneWidget);
        await tester.tap(find.byIcon(LucideIcons.x).last, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Scroll back up to header
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, 600));
      await tester.pumpAndSettle();

      // Open Onboard Staff Employee dialog
      final onboardBtn = find.text('Onboard Staff Employee');
      if (onboardBtn.evaluate().isNotEmpty) {
        await tester.tap(onboardBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Personal Details'), findsOneWidget);
        expect(find.text('Payroll & Financial Structure'), findsOneWidget);
        expect(find.text('Address & Emergency Details'), findsOneWidget);
        // Close dialog via X icon
        await tester.tap(find.byIcon(LucideIcons.x).last, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Open File Appraisal Review dialog
      final appraisalBtn = find.text('File Appraisal Review');
      if (appraisalBtn.evaluate().isNotEmpty) {
        await tester.tap(appraisalBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('File Performance Review'), findsOneWidget);
        await tester.tap(find.byIcon(LucideIcons.x).last, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Switch to Leaves & Shifts Rosters tab
      final shiftTab = find.text('Leaves & Shifts Rosters');
      if (shiftTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(shiftTab);
        await tester.pumpAndSettle();
        await tester.tap(shiftTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Leaves Balance, Pays & Assigned Roster Shifts'), findsOneWidget);
      }

      // Switch to Performance Appraisals tab
      final appraisalTab = find.text('Performance Appraisals');
      if (appraisalTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(appraisalTab);
        await tester.pumpAndSettle();
        await tester.tap(appraisalTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Personnel Appraisal & Rating scorecard'), findsOneWidget);
      }

      // Switch to Staff Reimbursements tab
      final reimbTab = find.text('Staff Reimbursements');
      if (reimbTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(reimbTab);
        await tester.pumpAndSettle();
        await tester.tap(reimbTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Employee Reimbursements & Travel claims'), findsOneWidget);
        expect(find.text('Lodge Staff Claim'), findsOneWidget);

        // Open Lodge Staff Claim dialog
        final lodgeBtn = find.text('Lodge Staff Claim');
        if (lodgeBtn.evaluate().isNotEmpty) {
          await tester.tap(lodgeBtn.first, warnIfMissed: false);
          await tester.pumpAndSettle();
          expect(find.text('EMPLOYEE PROFILE NAME'), findsOneWidget);
          await tester.tap(find.byIcon(LucideIcons.x).last, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('StaffPage renders on 320px ultra-narrow mobile without overflow across all tabs', (tester) async {
      tester.view.physicalSize = const Size(320, 680);
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

      // Verify Tab 0: Employee Profiles Table and scroll down to it
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('EMPLOYEE PROFILE'), findsOneWidget);

      // Drag table horizontally
      final horizontalScrolls = find.byType(SingleChildScrollView);
      if (horizontalScrolls.evaluate().length > 2) {
        await tester.drag(horizontalScrolls.last, const Offset(-900, 0), warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Scroll back to tab bar
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, 300));
      await tester.pumpAndSettle();

      final shiftTab = find.text('Leaves & Shifts Rosters');
      if (shiftTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(shiftTab);
        await tester.pumpAndSettle();
        await tester.tap(shiftTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Leaves Balance, Pays & Assigned Roster Shifts'), findsOneWidget);
      }

      final appraisalTab = find.text('Performance Appraisals');
      if (appraisalTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(appraisalTab);
        await tester.pumpAndSettle();
        await tester.tap(appraisalTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Personnel Appraisal & Rating scorecard'), findsOneWidget);
      }

      final reimbTab = find.text('Staff Reimbursements');
      if (reimbTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(reimbTab);
        await tester.pumpAndSettle();
        await tester.tap(reimbTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Employee Reimbursements & Travel claims'), findsOneWidget);
      }
    });

    testWidgets('PayrollPage renders on 360px without overflow and opens Process Monthly Payroll dialog', (tester) async {
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

      // Open Process Monthly Payroll dialog
      final payrollBtn = find.text('Process Monthly Payroll');
      if (payrollBtn.evaluate().isNotEmpty) {
        await tester.tap(payrollBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Select Employee'), findsOneWidget);
        expect(find.text('ESI Deduction'), findsOneWidget);
        expect(find.text('Estimated TDS'), findsOneWidget);
        expect(find.text('Deduct 12% PF'), findsOneWidget);
        // Close dialog via X icon
        await tester.tap(find.byIcon(LucideIcons.x).last, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('PayrollPage renders on 320px ultra-narrow mobile without overflow across all tabs', (tester) async {
      tester.view.physicalSize = const Size(320, 680);
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

      // Verify tabs switch without overflow
      final structureTab = find.text('Salary Structures (CTC)');
      if (structureTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(structureTab);
        await tester.pumpAndSettle();
        await tester.tap(structureTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Compensation Breakdown Structure (Annual CTC)'), findsOneWidget);
      }

      final complianceTab = find.text('Compliance (PF / ESI / PAN)');
      if (complianceTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(complianceTab);
        await tester.pumpAndSettle();
        await tester.tap(complianceTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Statutory EPF, ESI, PAN Compliance Identifiers'), findsOneWidget);
      }

      final loansTab = find.text('Loans & Salary Advances');
      if (loansTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(loansTab);
        await tester.pumpAndSettle();
        await tester.tap(loansTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('Active Loans & Salary Advance Balances'), findsOneWidget);
      }
    });

    testWidgets('BentoChartCard with large turnover renders on 360px and 320px without overflow', (tester) async {
      for (final size in [const Size(360, 780), const Size(320, 640)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BentoChartCard(
                  title: 'Sales Performance Analytics',
                  subtitle: 'Interactive monthly sales aggregation graph & revenue trends',
                  metricLabel: 'Aggregated Turnover',
                  metricValue: '₹10,21,25,50,71,294',
                  changePercentage: '+18.4%',
                  xLabels: const ['Jan', 'Feb', 'Mar'],
                  values: const [100.0, 200.0, 300.0],
                  maxY: 500.0,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(BentoChartCard), findsOneWidget);
        expect(find.text('₹10,21,25,50,71,294'), findsOneWidget);
        expect(find.text('+18.4%'), findsOneWidget);
      }
    });

    testWidgets('BentoCard with trailing button and volume matrix badge renders on 360px and 320px without overflow', (tester) async {
      for (final size in [const Size(360, 780), const Size(320, 640)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BentoCard(
                  title: 'Top Performing Products',
                  subtitle: 'Highest volume contributors & sales velocity matrix',
                  icon: LucideIcons.package,
                  badge: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: const Text('VOLUME MATRIX'),
                  ),
                  trailing: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.arrowRight, size: 13),
                    label: const Text('View All Products'),
                  ),
                  child: const SizedBox(height: 100, child: Text('Product Content')),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(BentoCard), findsOneWidget);
        expect(find.text('Top Performing Products'), findsOneWidget);
        expect(find.text('View All Products'), findsOneWidget);
      }
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

    testWidgets('SubscriptionPage renders on 360px without overflow across Business, Fin-Pro, and Partner tabs', (tester) async {
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
              body: SubscriptionPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SubscriptionPage), findsOneWidget);

      // Check Fin-Pro tab
      final finProTab = find.text('FIN-PRO');
      expect(finProTab, findsOneWidget);
      await tester.tap(finProTab);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Upgrade Fin-Pro Practice Tier'), findsOneWidget);

      // Check Partner Launch Desk tab
      final partnerTab = find.text('PARTNER LAUNCH DESK');
      expect(partnerTab, findsOneWidget);
      await tester.ensureVisible(partnerTab);
      await tester.tap(partnerTab);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Investor Club'), findsOneWidget);
      expect(find.text('Products & Ideas'), findsOneWidget);

      // Check sub-tab: Products & Ideas
      final productsTab = find.text('Products & Ideas');
      await tester.ensureVisible(productsTab);
      await tester.tap(productsTab);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Upgrade Workspace Tier'), findsOneWidget);

      // Return to Investor Club
      final investorTab = find.text('Investor Club');
      await tester.ensureVisible(investorTab);
      await tester.tap(investorTab);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Upgrade Investor Club Tier'), findsOneWidget);
    });

    testWidgets('SubscriptionPage renders on 320px ultra-compact mobile without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
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
      expect(find.byType(SubscriptionPage), findsOneWidget);

      // Switch to Partner Launch Desk
      final partnerTab = find.text('PARTNER LAUNCH DESK');
      expect(partnerTab, findsOneWidget);
      await tester.ensureVisible(partnerTab);
      await tester.tap(partnerTab);
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Products & Ideas
      final productsTab = find.text('Products & Ideas');
      await tester.ensureVisible(productsTab);
      await tester.tap(productsTab);
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Fin-Pro
      final finProTab = find.text('FIN-PRO');
      await tester.ensureVisible(finProTab);
      await tester.tap(finProTab);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('PurchaseInvoicePage on mobile OS renders hero card, sticky tabs and switches tabs without overflow', (tester) async {
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
            body: PurchaseInvoicePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PURCHASES & PROCUREMENT'), findsOneWidget);
      expect(find.text('Purchase Invoices & Orders'), findsOneWidget);
      expect(find.text('LIVE SYNC'), findsOneWidget);

      // Verify tabs exist
      expect(find.text('Purchase Orders (PO)'), findsOneWidget);
      expect(find.text('Purchase Bills & Invoices'), findsOneWidget);
      expect(find.text('Purchase Returns (Suppliers)'), findsOneWidget);

      // Switch to Purchase Bills & Invoices tab
      final billsTab = find.text('Purchase Bills & Invoices');
      await tester.ensureVisible(billsTab);
      await tester.tap(billsTab);
      await tester.pumpAndSettle();
      expect(find.text('Purchase Bills'), findsOneWidget);

      // Switch to Purchase Returns tab
      final returnsTab = find.text('Purchase Returns (Suppliers)');
      await tester.ensureVisible(returnsTab);
      await tester.tap(returnsTab);
      await tester.pumpAndSettle();
      expect(find.text('Purchase Returns (Suppliers)'), findsWidgets);
    });

    testWidgets('PurchaseInvoicePage on macOS platform preserves original desktop UI', (tester) async {
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

      // Desktop header
      expect(find.text('Purchases Hub'), findsOneWidget);
      expect(find.text('OUTWARD PROCUREMENT (AT COST)'), findsOneWidget);
    });

    testWidgets('SuppliersPage on mobile OS renders hero card, sticky tabs and switches tabs without overflow', (tester) async {
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
            body: SuppliersPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SUPPLIERS & VENDORS'), findsOneWidget);
      expect(find.text('Suppliers Master Suite'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Verify tabs exist
      expect(find.text('Suppliers Master Base'), findsOneWidget);
      expect(find.text('Running Ledger Statements'), findsOneWidget);
      expect(find.text('Payables Aging & Reminders'), findsOneWidget);

      // Switch to Running Ledger Statements tab
      final ledgerTab = find.text('Running Ledger Statements');
      await tester.ensureVisible(ledgerTab);
      await tester.tap(ledgerTab);
      await tester.pumpAndSettle();
      expect(find.text('Select Supplier'), findsOneWidget);

      // Switch to Payables Aging tab
      final agingTab = find.text('Payables Aging & Reminders');
      await tester.ensureVisible(agingTab);
      await tester.tap(agingTab);
      await tester.pumpAndSettle();
      expect(find.text('Outstanding Payables Aging Breakdown'), findsOneWidget);
    });

    testWidgets('SuppliersPage on macOS platform preserves original desktop UI', (tester) async {
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

      // Desktop header
      expect(find.text('Suppliers Master Suite'), findsOneWidget);
      expect(find.text('Manage vendor demographics, credit limits, purchase ledgers, and outward payables aging summaries.'), findsOneWidget);
    });

    testWidgets('ProductsPage on macOS preserves original desktop UI', (tester) async {
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
      expect(find.text('Products & Inventory Suite'), findsOneWidget);
      expect(find.text('TOTAL CATALOG SKUS'), findsOneWidget);
    });

    testWidgets('StockPage on macOS preserves original desktop UI', (tester) async {
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
      expect(find.text('Stock & Inventory Valuation'), findsOneWidget);
      expect(find.text('TOTAL INVENTORY VALUATION (COST BASIS)'), findsOneWidget);
    });

    testWidgets('WarehousePage on macOS preserves original desktop UI', (tester) async {
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
      expect(find.text('Warehouse, Godowns & Logistics'), findsOneWidget);
      expect(find.text('ACTIVE GODOWN FACILITIES'), findsOneWidget);
    });

    testWidgets('StaffPage on macOS preserves original desktop UI', (tester) async {
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
      expect(find.text('HR Staff & Employees Database'), findsOneWidget);
      expect(find.text('TOTAL ACTIVE HEADCOUNT'), findsOneWidget);
    });

    testWidgets('PayrollPage on macOS preserves original desktop UI', (tester) async {
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
      expect(find.text('Workforce Payroll Engine'), findsOneWidget);
      expect(find.text('MONTHLY SALARY EXPENSE'), findsOneWidget);
    });

    testWidgets('AccountingPage renders on mobile without overflow and converts tables to cards', (tester) async {
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
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AccountingPage), findsOneWidget);

      // Tap Day Book tab
      final dayBookTab = find.text('Day Book');
      if (dayBookTab.evaluate().isNotEmpty) {
        await tester.tap(dayBookTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        // Verify no horizontal DataTable on mobile Day Book
        expect(find.byType(DataTable), findsNothing);
      }

      // Switch to Receivables & Payables tab
      final recTab = find.text('Receivables & Payables');
      if (recTab.evaluate().isNotEmpty) {
        await tester.tap(recTab, warnIfMissed: false);
        await tester.pumpAndSettle();
        // Verify no horizontal DataTable on mobile Receivables & Payables
        expect(find.byType(DataTable), findsNothing);
      }
    });

    testWidgets('AccountingPage on 320px narrow mobile renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AccountingPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AccountingPage on macOS platform preserves original desktop DataTable', (tester) async {
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
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AccountingPage), findsOneWidget);
      // On macOS desktop, tap Day Book tab to view Day Book DataTable
      final dayBookTab = find.text('Day Book');
      if (dayBookTab.evaluate().isNotEmpty) {
        await tester.tap(dayBookTab);
        await tester.pumpAndSettle();
        expect(find.byType(DataTable), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('ExpensesPage renders on mobile without overflow and converts tables to cards', (tester) async {
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
              body: ExpensesPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpensesPage), findsOneWidget);
      expect(find.text('Expenses & Budget Control'), findsOneWidget);

      // Verify tabs can be switched on mobile without errors or overflows
      final tabs = [
        'Expenses Registry & ITC',
        'Recurring Subscriptions',
        'Department Budgets & Limits',
        'Staff Reimbursements',
      ];
      for (final tab in tabs) {
        final tabFinder = find.text(tab);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.tap(tabFinder, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('ExpensesPage on 320px narrow mobile renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExpensesPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ExpensesPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ExpensesPage on macOS platform preserves original desktop UI', (tester) async {
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
              body: ExpensesPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpensesPage), findsOneWidget);
      expect(find.text('Expenses & Operational Costs'), findsOneWidget);
    });

    testWidgets('GstPage renders on mobile without overflow and converts tables to cards', (tester) async {
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
              body: GstPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GstPage), findsOneWidget);

      // Switch to GSTR-1 tab
      final gstr1Tab = find.text('GSTR-1 (Sales)');
      if (gstr1Tab.evaluate().isNotEmpty) {
        await tester.tap(gstr1Tab, warnIfMissed: false);
        await tester.pumpAndSettle();
        // Verify GSTR-1 mobile cards render
        expect(find.text('E-Invoice QR'), findsWidgets);
      }

      // Switch to GSTR-2 tab
      final gstr2Tab = find.text('GSTR-2 (Purchase)');
      if (gstr2Tab.evaluate().isNotEmpty) {
        await tester.tap(gstr2Tab, warnIfMissed: false);
        await tester.pumpAndSettle();
        // Verify GSTR-2 mobile cards render
        expect(find.text('Verify / Reconcile'), findsWidgets);
      }

      // Switch to GSTR-3B tab
      final gstr3bTab = find.text('GSTR-3B (Liability)');
      if (gstr3bTab.evaluate().isNotEmpty) {
        await tester.tap(gstr3bTab, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Switch to GSTR-9 tab
      final gstr9Tab = find.text('GSTR-9 (Annual)');
      if (gstr9Tab.evaluate().isNotEmpty) {
        await tester.tap(gstr9Tab, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('GstPage on 320px narrow mobile renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GstPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GstPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GstPage on macOS platform preserves original desktop UI', (tester) async {
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
              body: GstPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GstPage), findsOneWidget);
      // Tap GSTR-1 tab to view desktop table
      final gstr1Tab = find.text('GSTR-1 (Sales)');
      if (gstr1Tab.evaluate().isNotEmpty) {
        await tester.tap(gstr1Tab, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.text('INVOICE NO'), findsOneWidget);
        expect(find.text('PLACE OF SUPPLY'), findsOneWidget);
      }
    });
  });
}

