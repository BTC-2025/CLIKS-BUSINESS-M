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

  group('TransactionPage UI Widget Tests (Images 2, 3, 4)', () {
    testWidgets('Renders Header, Top 4 KPI Cards, 3 Tabs, and Inward/Outward Table', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // 1. Verify Page Title and Action Buttons in Header (Image 2)
      expect(find.text('Payments & Cash Flow Engine'), findsOneWidget);
      expect(find.byKey(const Key('header_send_payment_button')), findsOneWidget);
      expect(find.byKey(const Key('header_receive_payment_button')), findsOneWidget);

      // 2. Verify Top 4 KPI Metric Cards (Image 2)
      expect(find.text('OUTSTANDING RECEIVABLES'), findsOneWidget);
      expect(find.text('DAILY COLLECTIONS'), findsOneWidget);
      expect(find.text('COMBINED BALANCES'), findsOneWidget);
      expect(find.text('EFFICIENCY RATE'), findsOneWidget);

      // 3. Verify Segmented Tabs
      expect(find.text('Total Inward & Outward'), findsOneWidget);
      expect(find.text('Overdue Collections & Reminders'), findsOneWidget);
      expect(find.text('Bank & Cash Registers'), findsOneWidget);

      // 4. Verify Tab 0 Stat Cards (Image 2)
      expect(find.text('TOTAL INWARD (+₹)'), findsOneWidget);
      expect(find.text('TOTAL OUTWARD (-₹)'), findsOneWidget);
      expect(find.text('NET BALANCE (INWARD - OUTWARD)'), findsOneWidget);

      // 5. Verify Table or Empty State (when offline/empty)
      expect(
        find.text('No Transactions Found').evaluate().isNotEmpty ||
            find.text('ENTRY ID').evaluate().isNotEmpty,
        isTrue,
      );
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

      // Verify Tab 2 is visible with accounts wrap
      expect(find.byType(Wrap), findsWidgets);

      // Switch back to Tab 0
      final inwardTab = find.text('Total Inward & Outward');
      expect(inwardTab, findsOneWidget);
      await tester.tap(inwardTab);
      await tester.pump();

      expect(find.text('TOTAL INWARD (+₹)'), findsOneWidget);
    });

    testWidgets('Opens and dismisses Receive Customer Payment modal dialog (Image 4)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final receiveBtn = find.byKey(const Key('header_receive_payment_button'));
      expect(receiveBtn, findsOneWidget);
      await tester.tap(receiveBtn);
      await tester.pumpAndSettle();

      // Verify Image 4 elements
      expect(find.text('Record Customer Payment'), findsOneWidget);
      expect(find.text('Select Customer Profile'), findsOneWidget);
      expect(find.text('Invoice Linked ID'), findsOneWidget);
      expect(find.text('Original Amount (₹)'), findsOneWidget);
      expect(find.text('Paid amount (Receipt worth, ₹)'), findsOneWidget);
      expect(find.text('Payment Mode'), findsOneWidget);
      expect(find.text('Ref ID / UPI reference'), findsOneWidget);
      expect(find.text('Finalize Payment Collection'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byKey(const Key('close_customer_payment_dialog')));
      await tester.pumpAndSettle();
      expect(find.text('Record Customer Payment'), findsNothing);
    });

    testWidgets('Opens and dismisses Send Payment modal dialog (Image 3)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final sendBtn = find.byKey(const Key('header_send_payment_button'));
      expect(sendBtn, findsOneWidget);
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      // Verify Image 3 elements
      expect(find.text('Record Supplier Disbursement'), findsOneWidget);
      expect(find.text('Select Supplier Profile'), findsOneWidget);
      expect(find.text('Purchase Bill Linked ID'), findsOneWidget);
      expect(find.text('Original Due Amount (₹)'), findsOneWidget);
      expect(find.text('Paid Amount (Outflow worth, ₹)'), findsOneWidget);
      expect(find.text('Disbursement Mode'), findsOneWidget);
      expect(find.text('Cheque / Ref No'), findsOneWidget);
      expect(find.text('Disburse Supplier Funds'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byKey(const Key('close_supplier_disbursement_dialog')));
      await tester.pumpAndSettle();
      expect(find.text('Record Supplier Disbursement'), findsNothing);
    });

    testWidgets('Validates transfer requires at least 2 accounts in Bank & Cash Registers', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Switch to Tab 2 (Bank & Cash Registers)
      final bankTab = find.text('Bank & Cash Registers');
      await tester.tap(bankTab);
      await tester.pump();

      final transferBtn = find.widgetWithText(OutlinedButton, 'Transfer Funds');
      if (transferBtn.evaluate().isNotEmpty) {
        await tester.tap(transferBtn.first);
        await tester.pump();
        expect(find.text('At least 2 accounts are required to perform an internal transfer'), findsOneWidget);
      }
    });
  });
}
