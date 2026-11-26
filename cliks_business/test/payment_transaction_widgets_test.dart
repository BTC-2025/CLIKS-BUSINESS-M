import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/data/account_provider.dart';
import 'package:clicks_business_frontend/models/account_model.dart';
import 'package:clicks_business_frontend/features/payments/pages/transaction_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        activeAccountProvider.overrideWith(
          (ref) => const AccountModel(
            id: '1',
            email: 'ravinew2004@bnxmail.com',
            name: 'Ravi Kumar',
            avatarColor: Colors.green,
            accountType: 'BUSINESS',
          ),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: TransactionPage(),
        ),
      ),
    );
  }

  group('TransactionPage UI Widget Tests', () {
    testWidgets('Renders Header, Top 4 KPI Cards, and 3 Tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // 1. Verify Page Title and Action Buttons in Header
      expect(find.text('Payments & Cash Flow Engine'), findsOneWidget);
      expect(find.text('Send Payment'), findsOneWidget);
      expect(find.text('Receive Payment'), findsOneWidget);
      expect(find.text('Transfer Funds'), findsWidgets);

      // 2. Verify Top 4 KPI Metric Cards
      expect(find.text('OUTSTANDING RECEIVABLES'), findsOneWidget);
      expect(find.text('DAILY COLLECTIONS'), findsOneWidget);
      expect(find.text('COMBINED BALANCES'), findsOneWidget);
      expect(find.text('EFFICIENCY RATE'), findsOneWidget);

      // 3. Verify Segmented Tabs
      expect(find.text('Total Inward & Outward'), findsOneWidget);
      expect(find.text('Overdue Collections & Reminders'), findsOneWidget);
      expect(find.text('Bank & Cash Registers'), findsOneWidget);

      // 4. Verify Tab 0 Stat Cards
      expect(find.text('TOTAL INWARD (+₹)'), findsOneWidget);
      expect(find.text('TOTAL OUTWARD (-₹)'), findsOneWidget);
      expect(find.text('NET BALANCE (INWARD - OUTWARD)'), findsOneWidget);
    });

    testWidgets('Switches tabs between Tab 0, Tab 1, and Tab 2', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Switch to Tab 1 (Overdue Collections & Reminders)
      final overdueTab = find.text('Overdue Collections & Reminders');
      expect(overdueTab, findsOneWidget);
      await tester.tap(overdueTab);
      await tester.pump();

      // Verify Tab 1 view or empty state
      expect(
        find.text('No Overdue Invoices Found').evaluate().isNotEmpty ||
            find.text('CUSTOMER NAME').evaluate().isNotEmpty,
        isTrue,
      );

      // Switch to Tab 2 (Bank & Cash Registers)
      final bankTab = find.text('Bank & Cash Registers');
      expect(bankTab, findsOneWidget);
      await tester.tap(bankTab);
      await tester.pump();

      // Verify Tab 2 is visible
      expect(find.byType(Wrap), findsWidgets);

      // Switch back to Tab 0
      final inwardTab = find.text('Total Inward & Outward');
      expect(inwardTab, findsOneWidget);
      await tester.tap(inwardTab);
      await tester.pump();

      expect(find.text('TOTAL INWARD (+₹)'), findsOneWidget);
    });

    testWidgets('Toggles flow filter pills (All, Inward, Outward)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final inwardPill = find.text('Inward (+₹)');
      expect(inwardPill, findsOneWidget);
      await tester.tap(inwardPill);
      await tester.pump();

      final outwardPill = find.text('Outward (-₹)');
      expect(outwardPill, findsOneWidget);
      await tester.tap(outwardPill);
      await tester.pump();

      final allPill = find.text('All');
      expect(allPill, findsOneWidget);
      await tester.tap(allPill);
      await tester.pump();
    });

    testWidgets('Opens and dismisses Receive Customer Payment modal dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final receiveBtn = find.text('Receive Payment');
      expect(receiveBtn, findsOneWidget);
      await tester.tap(receiveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Receive Customer Payment'), findsOneWidget);
      expect(find.text('Customer Name'), findsOneWidget);
      expect(find.text('Deposit To Account'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byKey(const Key('close_customer_payment_dialog')));
      await tester.pumpAndSettle();
      expect(find.text('Receive Customer Payment'), findsNothing);
    });

    testWidgets('Opens and dismisses Send Payment modal dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final sendBtn = find.text('Send Payment');
      expect(sendBtn, findsOneWidget);
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      expect(find.text('Record Supplier Disbursement'), findsOneWidget);
      expect(find.text('Supplier / Vendor Name'), findsOneWidget);
      expect(find.text('Deduct From Account'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byKey(const Key('close_supplier_disbursement_dialog')));
      await tester.pumpAndSettle();
      expect(find.text('Record Supplier Disbursement'), findsNothing);
    });

    testWidgets('Validates transfer requires at least 2 accounts or opens dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final transferBtn = find.widgetWithText(OutlinedButton, 'Transfer Funds');
      expect(transferBtn, findsOneWidget);
      await tester.tap(transferBtn);
      await tester.pump();

      // With 0 loaded accounts in offline test, it informs user that 2 accounts are required
      expect(find.text('At least 2 accounts are required to perform an internal transfer'), findsOneWidget);
    });

    testWidgets('Opens and dismisses Gateway Order modal dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final gatewayBtn = find.text('Gateway Order');
      expect(gatewayBtn, findsOneWidget);
      await tester.tap(gatewayBtn);
      await tester.pumpAndSettle();

      expect(find.text('Payment Gateway Order'), findsOneWidget);
      expect(find.text('Order ID'), findsOneWidget);
      expect(find.text('Order Amount (₹)'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byKey(const Key('close_cashfree_order_dialog')));
      await tester.pumpAndSettle();
      expect(find.text('Payment Gateway Order'), findsNothing);
    });
  });
}
