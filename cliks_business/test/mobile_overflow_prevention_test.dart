import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/payments/pages/transaction_page.dart';
import 'package:clicks_business_frontend/features/payments/pages/split_collect_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/accounting_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/expenses_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/gst_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/billing_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/customers_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('Mobile UI & Overflow Prevention Tests', () {
    testWidgets('TransactionPage renders without overflow on mobile viewport (390x844)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TransactionPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TransactionPage), findsOneWidget);
      expect(find.text('COMBINED BALANCES'), findsOneWidget);
    });

    testWidgets('TransactionPage renders and switches tabs on narrow 360px viewport without overflow', (WidgetTester tester) async {
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
              body: TransactionPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TransactionPage), findsOneWidget);

      // Switch to Bank & Cash Registers tab
      final bankTab = find.text('Bank & Cash Registers');
      if (bankTab.evaluate().isNotEmpty) {
        await tester.tap(bankTab, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Switch to Overdue tab
      final overdueTab = find.text('Overdue Collections & Reminders');
      if (overdueTab.evaluate().isNotEmpty) {
        await tester.tap(overdueTab, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('SplitCollectPage tickets list renders without overflow on mobile viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SplitCollectPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SplitCollectPage), findsOneWidget);
      expect(find.text('Splitwise & Collect'), findsOneWidget);
    });

    testWidgets('SplitCollectPage ticket detail renders without overflow on mobile viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SplitCollectPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the first ticket to open detail view
      final ticketCard = find.text('marina trip');
      if (ticketCard.evaluate().isNotEmpty) {
        await tester.tap(ticketCard);
        await tester.pumpAndSettle();

        expect(find.text('Back to all tickets'), findsOneWidget);
        expect(find.text('LOGGED EXPENSES'), findsOneWidget);
      }
    });

    testWidgets('SplitCollectPage works on smaller 360px Android viewport with Summary expanded without overflow', (WidgetTester tester) async {
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
              body: SplitCollectPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ticketCard = find.text('marina trip');
      if (ticketCard.evaluate().isNotEmpty) {
        await tester.tap(ticketCard);
        await tester.pumpAndSettle();

        expect(find.text('Back to all tickets'), findsOneWidget);

        // Tap summary chevron to expand or collapse
        final summaryHeader = find.text('Summary');
        if (summaryHeader.evaluate().isNotEmpty) {
          await tester.tap(summaryHeader);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('AccountingPage Balance Sheet tab renders without overflow on 360px viewport (flutter_06.png)', (WidgetTester tester) async {
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

      final tab = find.text('Balance Sheet');
      expect(tab, findsOneWidget);
      await tester.tap(tab);
      await tester.pumpAndSettle();

      expect(find.text('Liabilities & Equity'), findsOneWidget);
      expect(find.text('Owner\'s Equity'), findsOneWidget);
    });

    testWidgets('AccountingPage Receivables & Payables tab filter bar renders without overflow on 360px viewport (flutter_07.png)', (WidgetTester tester) async {
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

      final tab = find.text('Receivables & Payables');
      expect(tab, findsOneWidget);
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();

      expect(find.text('All Statuses'), findsOneWidget);
      expect(find.text('Min ₹'), findsOneWidget);
      expect(find.text('Max ₹'), findsOneWidget);
    });

    testWidgets('AccountingPage Expenses tab Operational Expense Categories renders without overflow on 360px viewport (flutter_08.png)', (WidgetTester tester) async {
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

      final tab = find.text('Expenses');
      expect(tab, findsOneWidget);
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();

      expect(find.text('Operational Expense Categories'), findsOneWidget);
    });

    testWidgets('AccountingPage Cash & Bank tab renders full-width metric cards without overflow on 360px viewport (flutter_09.png)', (WidgetTester tester) async {
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

      final tab = find.text('Cash & Bank');
      expect(tab, findsOneWidget);
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();

      expect(find.text('TOTAL CASH'), findsOneWidget);
      expect(find.text('TOTAL BANK BALANCE'), findsOneWidget);
      expect(find.text('TOTAL AVAILABLE FUNDS'), findsOneWidget);
    });

    testWidgets('AccountingPage Bank Statement History Dialog renders without overflow on 360px viewport (flutter_10.png)', (WidgetTester tester) async {
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

      final tab = find.text('Cash & Bank');
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();

      final historyBtn = find.text('History').first;
      expect(historyBtn, findsOneWidget);
      await tester.ensureVisible(historyBtn);
      await tester.pumpAndSettle();
      await tester.tap(historyBtn);
      await tester.pumpAndSettle();

      expect(find.text('CURRENT BALANCE'), findsOneWidget);
      expect(find.text('Export Statement'), findsOneWidget);
    });

    testWidgets('ExpensesPage Recurring Subscriptions tab renders without overflow on 360px viewport (flutter_11.png)', (WidgetTester tester) async {
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

      // Tap 'Recurring Subscriptions' tab
      final tab = find.text('Recurring Subscriptions');
      expect(tab, findsOneWidget);
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();

      expect(find.text('Active Recurring bills & Subscriptions'), findsOneWidget);
      expect(find.text('+ Add Subscription'), findsOneWidget);
    });

    testWidgets('GstCompliancePage GSTR-2 Purchase tab renders without overflow on 360px viewport (flutter_12.png)', (WidgetTester tester) async {
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

      // Tap 'GSTR-2 (Purchase)' tab
      final tab = find.text('GSTR-2 (Purchase)');
      expect(tab, findsOneWidget);
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();

      expect(find.text('GSTR-2B Purchase ITC Reconciliations'), findsOneWidget);
      expect(find.text('Verify Vendor Invoice'), findsOneWidget);
    });

    testWidgets('GstCompliancePage GSTR-9 Annual tab renders without overflow on 360px viewport (flutter_13.png)', (WidgetTester tester) async {
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

      // Tap 'GSTR-9 (Annual)' tab
      final tab = find.text('GSTR-9 (Annual)');
      expect(tab, findsOneWidget);
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      await tester.tap(tab);
      await tester.pumpAndSettle();

      expect(find.text('GSTR-9 Annual Return'), findsOneWidget);
      expect(find.text('Export Annual PDF'), findsOneWidget);
    });

    testWidgets('BillingPage DELIVERY CHALLAN Sub-tab 0 (Shipments & Real-Time Status) renders without overflow on 360px viewport (flutter_14.png)', (WidgetTester tester) async {
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
              body: BillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BillingPage), findsOneWidget);

      // Tap 'DELIVERY CHALLAN' main tab
      final challanTab = find.text('DELIVERY CHALLAN');
      expect(challanTab, findsOneWidget);
      await tester.ensureVisible(challanTab);
      await tester.pumpAndSettle();
      await tester.tap(challanTab);
      await tester.pumpAndSettle();

      // Verify Metric Cards and Shipments Sub-tab 0
      expect(find.text('DELIVERY SUCCESS RATE'), findsOneWidget);
      expect(find.text('ONGOING SHIPMENTS'), findsOneWidget);
      expect(find.text('Shipments & Real-Time Status'), findsOneWidget);
      expect(find.text('Dispatch Shipment'), findsAtLeastNWidgets(1));
    });

    testWidgets('BillingPage Dispatch Shipment modal dialog renders without overflow on 360px viewport (flutter_15.png)', (WidgetTester tester) async {
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
              body: BillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'DELIVERY CHALLAN' main tab
      final challanTab = find.text('DELIVERY CHALLAN');
      await tester.ensureVisible(challanTab);
      await tester.pumpAndSettle();
      await tester.tap(challanTab);
      await tester.pumpAndSettle();

      // Tap Dispatch Shipment button to open modal
      final dispatchBtn = find.widgetWithText(ElevatedButton, 'Dispatch Shipment').first;
      await tester.ensureVisible(dispatchBtn);
      await tester.pumpAndSettle();
      await tester.tap(dispatchBtn);
      await tester.pumpAndSettle();

      // Verify modal opened and Card 1 header with trailingText rendered without overflow
      expect(find.text('Dispatch Shipment & Issue Challan'), findsOneWidget);
      expect(find.text('📌 1. LINK SALES INVOICE & BASIC DETAILS'), findsOneWidget);
      expect(find.text('Quick auto-fill from current orders'), findsOneWidget);
      expect(find.text('Generate Challan & Dispatch Shipment'), findsOneWidget);

      // Close modal
      final closeBtn = find.byIcon(LucideIcons.x);
      if (closeBtn.evaluate().isNotEmpty) {
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('BillingPage DELIVERY CHALLAN Sub-tab 1 (Delivery Challans Table) renders without overflow on 360px viewport (flutter_16.png)', (WidgetTester tester) async {
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
              body: BillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Delivery Challan
      final challanTab = find.text('DELIVERY CHALLAN');
      await tester.ensureVisible(challanTab);
      await tester.pumpAndSettle();
      await tester.tap(challanTab);
      await tester.pumpAndSettle();

      // Switch to Sub-tab 1: Delivery Challans
      final subTab1 = find.text('Delivery Challans');
      expect(subTab1, findsOneWidget);
      await tester.ensureVisible(subTab1);
      await tester.pumpAndSettle();
      await tester.tap(subTab1);
      await tester.pumpAndSettle();

      expect(find.text('Generated Delivery Challans (Product Dispatches)'), findsOneWidget);
      expect(find.text('New Challan'), findsOneWidget);
    });

    testWidgets('BillingPage DELIVERY CHALLAN Sub-tab 2 (Driver Performance) renders without overflow on 360px viewport (flutter_17.png)', (WidgetTester tester) async {
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
              body: BillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Delivery Challan
      final challanTab = find.text('DELIVERY CHALLAN');
      await tester.ensureVisible(challanTab);
      await tester.pumpAndSettle();
      await tester.tap(challanTab);
      await tester.pumpAndSettle();

      // Switch to Sub-tab 2: Delivery Staff & Driver Performance
      final subTab2 = find.text('Delivery Staff & Driver Performance');
      expect(subTab2, findsOneWidget);
      await tester.ensureVisible(subTab2);
      await tester.pumpAndSettle();
      await tester.tap(subTab2);
      await tester.pumpAndSettle();

      expect(find.text('Delivery Staff Performance & Fleet Assignments'), findsOneWidget);
      expect(find.text('Satish Yadav'), findsOneWidget);
      expect(find.text('Rajesh Patil'), findsOneWidget);
    });

    testWidgets('BillingPage DELIVERY CHALLAN Sub-tab 3 (Reverse Logistics) renders without overflow on 360px viewport (flutter_18.png)', (WidgetTester tester) async {
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
              body: BillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Delivery Challan
      final challanTab = find.text('DELIVERY CHALLAN');
      await tester.ensureVisible(challanTab);
      await tester.pumpAndSettle();
      await tester.tap(challanTab);
      await tester.pumpAndSettle();

      // Switch to Sub-tab 3: Reverse Logistics (Returns)
      final subTab3 = find.text('Reverse Logistics (Returns)');
      expect(subTab3, findsOneWidget);
      await tester.ensureVisible(subTab3);
      await tester.pumpAndSettle();
      await tester.tap(subTab3);
      await tester.pumpAndSettle();

      expect(find.text('Reverse Logistics (Return pick-ups & Failures)'), findsOneWidget);
      expect(find.text('Rahul Varma'), findsOneWidget);
      expect(find.text('Reschedule Pickup'), findsOneWidget);
    });

    testWidgets('AccountingPage mobile tabs are arranged left-to-right correctly and can navigate sections via footer', (WidgetTester tester) async {
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

      // Verify initial tab 0 is P & L and footer shows next tab 'Balance Sheet ›'
      expect(find.text('Gross Revenue'), findsOneWidget);
      expect(find.text('Balance Sheet ›'), findsOneWidget);

      // Tap 'Balance Sheet' tab in sticky tab bar
      final balanceSheetTab = find.text('Balance Sheet');
      expect(balanceSheetTab, findsOneWidget);
      await tester.tap(balanceSheetTab);
      await tester.pumpAndSettle();

      // On Balance Sheet (tab 1), footer shows previous '‹ P & L' and next 'Receivables & Payables ›'
      expect(find.text('‹ P & L'), findsOneWidget);
      expect(find.text('Receivables & Payables ›'), findsOneWidget);
      expect(find.text('Liabilities & Equity'), findsOneWidget);

      // Tap 'Receivables & Payables' tab in sticky tab bar
      final rpTab = find.text('Receivables & Payables');
      expect(rpTab, findsOneWidget);
      await tester.ensureVisible(rpTab);
      await tester.pumpAndSettle();
      await tester.tap(rpTab);
      await tester.pumpAndSettle();

      // On Receivables & Payables (tab 2), next is Cash & Bank (tab 3)
      expect(find.text('Cash & Bank ›'), findsOneWidget);
      expect(find.text('‹ Balance Sheet'), findsOneWidget);

      // Tap 'Cash & Bank' tab in sticky tab bar
      final cashTab = find.text('Cash & Bank');
      expect(cashTab, findsOneWidget);
      await tester.ensureVisible(cashTab);
      await tester.pumpAndSettle();
      await tester.tap(cashTab);
      await tester.pumpAndSettle();

      // On Cash & Bank (tab 3), next is Day Book (tab 4)
      expect(find.text('Day Book ›'), findsOneWidget);
      expect(find.text('‹ Receivables & Payables'), findsOneWidget);
      expect(find.text('TOTAL AVAILABLE FUNDS'), findsOneWidget);

      // Tap 'Day Book' tab in sticky tab bar
      final dayBookTab = find.text('Day Book');
      expect(dayBookTab, findsOneWidget);
      await tester.ensureVisible(dayBookTab);
      await tester.pumpAndSettle();
      await tester.tap(dayBookTab);
      await tester.pumpAndSettle();

      // On Day Book (tab 4), next is Expenses (tab 5)
      expect(find.text('Expenses ›'), findsOneWidget);
      expect(find.text('‹ Cash & Bank'), findsOneWidget);

      // Tap 'Expenses' tab in sticky tab bar
      final expensesTab = find.text('Expenses');
      expect(expensesTab, findsOneWidget);
      await tester.ensureVisible(expensesTab);
      await tester.pumpAndSettle();
      await tester.tap(expensesTab);
      await tester.pumpAndSettle();

      // On Expenses (tab 5), Dedicated Expenses Section banner is present with Open button
      expect(find.text('Dedicated Expenses Section'), findsOneWidget);
      expect(find.text('Operational Expense Categories'), findsOneWidget);
      expect(find.text('GST ›'), findsOneWidget);
      expect(find.text('‹ Day Book'), findsOneWidget);

      // Tap 'GST' tab in sticky tab bar
      final gstTab = find.text('GST');
      expect(gstTab, findsOneWidget);
      await tester.ensureVisible(gstTab);
      await tester.pumpAndSettle();
      await tester.tap(gstTab);
      await tester.pumpAndSettle();

      // On GST (tab 6), Full GST Compliance Portal banner is present
      expect(find.text('Full GST Compliance Portal'), findsOneWidget);
      expect(find.text('GSTR-1 Summary'), findsOneWidget);
      expect(find.text('‹ Expenses'), findsOneWidget);
    });

    testWidgets('AccountingPage on macOS platform preserves original desktop UI without mobile changes', (WidgetTester tester) async {
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

      // On macOS desktop, mobile footer is not present
      expect(find.text('Balance Sheet ›'), findsNothing);
      expect(find.text('‹ P & L'), findsNothing);
      expect(find.text('Dedicated Expenses Section'), findsNothing);
    });

    testWidgets('BillingPage on mobile OS platform renders redesigned hero summary card, sticky tab bar, and mobile FAB', (WidgetTester tester) async {
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

      // Hero Card elements
      expect(find.text('SALES & BILLING HUB'), findsOneWidget);
      expect(find.text('LIVE SYNC'), findsOneWidget);
      expect(find.text('TOTAL INVOICED'), findsOneWidget);
      expect(find.text('PAID REVENUE'), findsOneWidget);
      expect(find.text('UNPAID DUES'), findsOneWidget);

      // Mobile FAB
      expect(find.text('Generate Invoice'), findsOneWidget);

      // Tabs
      expect(find.text('Invoices List'), findsOneWidget);
      expect(find.text('Warranty & Replacement Claims'), findsOneWidget);
      expect(find.text('DELIVERY CHALLAN'), findsOneWidget);
    });

    testWidgets('BillingPage on macOS platform preserves original desktop UI without mobile changes', (WidgetTester tester) async {
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

      // On macOS desktop, mobile hero header and mobile FAB are not present
      expect(find.text('SALES & BILLING HUB'), findsNothing);
      expect(find.text('LIVE SYNC'), findsNothing);
      expect(find.text('Billing Center'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('CustomersPage on mobile OS platform renders redesigned hero summary card, sticky tab bar, and mobile FAB', (WidgetTester tester) async {
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
              body: CustomersPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hero Card elements
      expect(find.text('CUSTOMER & UDHAAR LEDGER'), findsOneWidget);
      expect(find.text('LIVE STATUS'), findsOneWidget);
      expect(find.text('ACTIVE CUSTOMERS'), findsOneWidget);
      expect(find.text('TOTAL OUTSTANDING'), findsOneWidget);
      expect(find.text('COLLECTION EFFICIENCY'), findsOneWidget);

      // Mobile FAB
      expect(find.text('Add Customer'), findsOneWidget);

      // Sticky Tabs
      expect(find.text('Customers List'), findsOneWidget);
      expect(find.text('Aging & Collection Reports 📊'), findsOneWidget);
      expect(find.text('Points Rules & Ratio'), findsOneWidget);
    });

    testWidgets('CustomersPage on macOS platform preserves original desktop UI without mobile changes', (WidgetTester tester) async {
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
              body: CustomersPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // On macOS desktop, mobile hero header is not present
      expect(find.text('CUSTOMER & UDHAAR LEDGER'), findsNothing);
      expect(find.text('LIVE STATUS'), findsNothing);
      expect(find.text('Customers & Udhaar Ledger'), findsOneWidget);
    });

    testWidgets('BillingPage renders on 320px ultra-compact mobile without overflow across all tabs', (WidgetTester tester) async {
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
              body: BillingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BillingPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 1: Warranty & Replacement Claims
      final warrantyTab = find.text('Warranty & Replacement Claims');
      await tester.ensureVisible(warrantyTab);
      await tester.pumpAndSettle();
      await tester.tap(warrantyTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tab 2: DELIVERY CHALLAN
      final challanTab = find.text('DELIVERY CHALLAN');
      await tester.ensureVisible(challanTab);
      await tester.pumpAndSettle();
      await tester.tap(challanTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Sub-tab: Fleet & Route Tracking
      final fleetTab = find.text('Fleet & Route Tracking');
      if (fleetTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(fleetTab);
        await tester.pumpAndSettle();
        await tester.tap(fleetTab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      // Return to Tab 0: Invoices List
      final invoicesTab = find.text('Invoices List');
      await tester.ensureVisible(invoicesTab);
      await tester.pumpAndSettle();
      await tester.tap(invoicesTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('CustomersPage renders on 320px ultra-compact mobile without overflow across all tabs', (WidgetTester tester) async {
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
              body: CustomersPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomersPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 1: Aging & Collection Reports
      final agingTab = find.text('Aging & Collection Reports 📊');
      await tester.ensureVisible(agingTab);
      await tester.pumpAndSettle();
      await tester.tap(agingTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tab 2: Points Rules & Ratio
      final pointsTab = find.text('Points Rules & Ratio');
      await tester.ensureVisible(pointsTab);
      await tester.pumpAndSettle();
      await tester.tap(pointsTab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}


