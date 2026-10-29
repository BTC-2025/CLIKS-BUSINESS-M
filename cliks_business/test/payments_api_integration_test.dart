import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/data/models/payment_models.dart';
import 'package:clicks_business_frontend/data/repositories/payments_repository.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';

void main() {
  group('Payment Models & API Serialization Tests', () {
    test('PaymentAccount parses numeric and string IDs accurately', () {
      final bankJson = {
        'id': 1,
        'bank_account_id': 1,
        'bank_name': 'HDFC Bank',
        'bank_account_name': 'HDFC Current Account',
        'account_number': '50200012345678',
        'ifsc_code': 'HDFC0001234',
        'branch_name': 'Indiranagar',
        'current_balance': 184500.00,
        'type': 'bank',
        'status': 'Active',
      };

      final bankAccount = PaymentAccount.fromJson(bankJson);
      expect(bankAccount.id, equals(1));
      expect(bankAccount.isCash, isFalse);
      expect(bankAccount.isActive, isTrue);
      expect(bankAccount.displayName, equals('HDFC Current Account'));
      expect(bankAccount.currentBalance, equals(184500.00));
      expect(bankAccount.displayAccountNumber, equals('•••• 5678'));

      final cashJson = {
        'id': 'cash-register',
        'bank_account_id': 'cash-register',
        'bank_name': 'Cash Register',
        'bank_account_name': 'Cash Register (Cash in Hand)',
        'account_number': 'Cash Counter',
        'current_balance': 32000,
        'type': 'cash',
        'status': 'Active',
      };

      final cashAccount = PaymentAccount.fromJson(cashJson);
      expect(cashAccount.id, equals('cash-register'));
      expect(cashAccount.isCash, isTrue);
      expect(cashAccount.currentBalance, equals(32000.0));
      expect(cashAccount.displayAccountNumber, equals('Cash Counter'));
    });

    test('PaymentTransaction parses camelCase and snake_case correctly', () {
      final json = {
        'id': 108,
        'amount': 5000,
        'paidAmount': 5000,
        'paid_amount': 5000,
        'totalOriginalAmount': 10000,
        'total_original': 10000,
        'customerProfile': 'Ramesh Traders',
        'customer_name': 'Ramesh Traders',
        'invoiceLinkedId': 'INV-2026-0042',
        'invoice_id': 'INV-2026-0042',
        'payment_mode': 'UPI',
        'reference_number': 'UPI/9876543210/PAY',
        'status': 'completed',
        'reconciliation_status': 'matched',
        'created_at': '2026-10-27T10:30:00.000Z',
      };

      final tx = PaymentTransaction.fromJson(json);
      expect(tx.id, equals('108'));
      expect(tx.partyName, equals('Ramesh Traders'));
      expect(tx.amount, equals(5000.0));
      expect(tx.paidAmount, equals(5000.0));
      expect(tx.totalOriginal, equals(10000.0));
      expect(tx.pendingAmount, equals(5000.0));
      expect(tx.paymentMode, equals('UPI'));
      expect(tx.invoiceId, equals('INV-2026-0042'));
      expect(tx.isReconciled, isTrue);
      expect(tx.formattedDate, equals('2026-10-27'));
    });

    test('PaymentReports parses receivables, payables, accounts, and overdue', () {
      final json = {
        'success': true,
        'data': {
          'receivables': [
            {
              'id': 1,
              'type': 'receive',
              'party_name': 'Ramesh Traders',
              'amount': 5000,
              'paid_amount': 5000,
              'total_original': 10000,
              'payment_mode': 'UPI',
            }
          ],
          'payables': [
            {
              'id': 2,
              'type': 'pay',
              'party_name': 'Metro Steel Supplies',
              'amount': 12500,
              'paid_amount': 12500,
              'total_original': 12500,
              'payment_mode': 'Bank Transfer',
            }
          ],
          'accounts': [
            {
              'id': 1,
              'bank_name': 'HDFC Bank',
              'bank_account_name': 'HDFC Current Account',
              'account_number': '50200012345678',
              'current_balance': 184500.00,
              'type': 'bank',
            }
          ],
          'overdueInvoices': [
            {
              'id': 14,
              'invoice_number': 'INV-2026-0014',
              'client_name': 'Shree Enterprises',
              'total_amount': 25000,
              'paid_amount': 10000,
              'due_amount': 15000,
              'status': 'Partially Paid',
            }
          ]
        }
      };

      final reports = PaymentReports.fromJson(json);
      expect(reports.receivables.length, equals(1));
      expect(reports.payables.length, equals(1));
      expect(reports.accounts.length, equals(1));
      expect(reports.overdueInvoices.length, equals(1));

      expect(reports.receivables.first.partyName, equals('Ramesh Traders'));
      expect(reports.payables.first.partyName, equals('Metro Steel Supplies'));
      expect(reports.accounts.first.currentBalance, equals(184500.0));
      expect(reports.overdueInvoices.first.dueAmount, equals(15000.0));
    });

    test('OutstandingStats parses totals correctly', () {
      final json = {
        'success': true,
        'data': {
          'receivables': 12000,
          'payables': 5000,
          'total_processed': 145000,
        }
      };

      final stats = OutstandingStats.fromJson(json);
      expect(stats.receivables, equals(12000.0));
      expect(stats.payables, equals(5000.0));
      expect(stats.totalProcessed, equals(145000.0));
    });

    test('ReceivePaymentRequest generates exact documented JSON payload', () {
      final req = ReceivePaymentRequest(
        amount: 5000.00,
        customerName: 'Ramesh Traders',
        invoiceId: 'INV-2026-0042',
        paymentMode: 'UPI',
        referenceNumber: 'UPI/9876543210/PAY',
        accountId: 1,
        notes: 'Payment received via PhonePe QR code',
        totalOriginalAmount: 5000.00,
        paidAmount: 5000.00,
      );

      final map = req.toJson();
      expect(map['amount'], equals(5000.00));
      expect(map['customer_name'], equals('Ramesh Traders'));
      expect(map['invoice_id'], equals('INV-2026-0042'));
      expect(map['payment_mode'], equals('UPI'));
      expect(map['reference_number'], equals('UPI/9876543210/PAY'));
      expect(map['account_id'], equals(1));
      expect(map['notes'], equals('Payment received via PhonePe QR code'));
      expect(map['total_original_amount'], equals(5000.00));
      expect(map['paid_amount'], equals(5000.00));
    });

    test('PaySupplierRequest generates exact documented JSON payload with string accountId', () {
      final req = PaySupplierRequest(
        amount: 12500.00,
        supplierName: 'Metro Steel Supplies',
        purchaseId: 'PUR-2026-015',
        paymentMode: 'Bank Transfer',
        referenceNumber: 'NEFT-HDFC-991283',
        accountId: 'cash-register',
        notes: 'Advance for raw materials shipment',
      );

      final map = req.toJson();
      expect(map['amount'], equals(12500.00));
      expect(map['supplier_name'], equals('Metro Steel Supplies'));
      expect(map['purchase_id'], equals('PUR-2026-015'));
      expect(map['payment_mode'], equals('Bank Transfer'));
      expect(map['reference_number'], equals('NEFT-HDFC-991283'));
      expect(map['account_id'], equals('cash-register'));
      expect(map['notes'], equals('Advance for raw materials shipment'));
    });
  });

  group('PaymentsRepository API & Account Fetching Tests', () {
    test('getPaymentReports returns unified reports and accounts', () async {
      final reports = await PaymentsRepository.getPaymentReports();
      expect(reports, isNotNull);
      expect(reports.accounts, isNotEmpty);
      final firstAcc = reports.accounts.first;
      expect(firstAcc.displayName, isNotEmpty);
      expect(firstAcc.currentBalance, isNonNegative);
    });

    test('getBankAccounts fetches all connected bank and cash registers', () async {
      final accounts = await PaymentsRepository.getBankAccounts();
      expect(accounts, isNotEmpty);
      expect(accounts.any((a) => a.id == 1), isTrue);
      expect(accounts.any((a) => a.id == 'cash-register'), isTrue);
    });

    test('getAccountById fetches specific account by numeric ID (1)', () async {
      final acc = await PaymentsRepository.getAccountById(1);
      expect(acc, isNotNull);
      expect(acc!.id, equals(1));
      expect(acc.displayName, equals('HDFC Current Account'));
      expect(acc.currentBalance, isPositive);
    });

    test('getAccountById fetches specific cash account by string ID ("cash-register")', () async {
      final acc = await PaymentsRepository.getAccountById('cash-register');
      expect(acc, isNotNull);
      expect(acc!.id, equals('cash-register'));
      expect(acc.isCash, isTrue);
      expect(acc.displayName, equals('Main Cash Register'));
    });

    test('getOutstandingStats fetches valid financial stats', () async {
      final stats = await PaymentsRepository.getOutstandingStats();
      expect(stats, isNotNull);
      expect(stats!.receivables, isNonNegative);
      expect(stats.payables, isNonNegative);
    });

    test('receivePayment records customer receipt and updates account balance', () async {
      final accBefore = await PaymentsRepository.getAccountById(1);
      final balBefore = accBefore?.currentBalance ?? 0.0;

      final req = ReceivePaymentRequest(
        amount: 2500.0,
        customerName: 'Karan Tech',
        invoiceId: 'INV-2026-999',
        paymentMode: 'UPI',
        referenceNumber: 'UPI/TEST/123',
        accountId: 1,
        notes: 'Test payment receipt',
      );

      final res = await PaymentsRepository.receivePayment(req);
      expect(res['success'], isTrue);

      final accAfter = await PaymentsRepository.getAccountById(1);
      expect(accAfter?.currentBalance, equals(balBefore + 2500.0));
    });

    test('paySupplier records supplier disbursement and deducts account balance', () async {
      final accBefore = await PaymentsRepository.getAccountById(1);
      final balBefore = accBefore?.currentBalance ?? 0.0;

      final req = PaySupplierRequest(
        amount: 1500.0,
        supplierName: 'National Steel Corp',
        purchaseId: 'PUR-2026-888',
        paymentMode: 'Bank Transfer',
        referenceNumber: 'NEFT-TEST-456',
        accountId: 1,
        notes: 'Test vendor disbursement',
      );

      final res = await PaymentsRepository.paySupplier(req);
      expect(res['success'], isTrue);

      final accAfter = await PaymentsRepository.getAccountById(1);
      expect(accAfter?.currentBalance, equals(balBefore - 1500.0));
    });

    test('transferFunds settles internal transfer between accounts (2.3)', () async {
      final req = AccountTransferRequest(
        fromAccountId: 1,
        toAccountId: 'cash-register',
        amount: 5000.0,
      );

      final res = await PaymentsRepository.transferFunds(req);
      expect(res['success'], isTrue);
      expect(res['data']['amount'], equals(5000.0));
    });

    test('createPaymentOrder initiates Cashfree / UPI order session (2.6)', () async {
      final req = CreatePaymentOrderRequest(
        amount: 1499.00,
        orderId: 'ORDER_MOBILE_10293',
        currency: 'INR',
      );

      final res = await PaymentsRepository.createPaymentOrder(req);
      expect(res['success'], isTrue);
      expect(res['data']['order_id'], equals('ORDER_MOBILE_10293'));
      expect(res['data']['payment_session_id'], isNotEmpty);
    });

    test('createBankAccount creates new account via POST /api/v1/bank-accounts (Section 6)', () async {
      final req = CreateBankAccountRequest(
        bankName: 'ICICI Current Account',
        accountHolder: 'Tech Corp India',
        accountNumber: '000105001234',
        ifsc: 'ICIC0000001',
        branch: 'MG Road',
        openingBalance: 125000.0,
        accountType: 'CURRENT',
      );

      final created = await PaymentsRepository.createBankAccount(req);
      expect(created, isNotNull);
      expect(created.bankName, equals('ICICI Current Account'));
      expect(created.balance, equals(125000.0));
      expect(created.accountNumber, equals('000105001234'));

      final allAccounts = await PaymentsRepository.getBankAccounts();
      expect(allAccounts.any((a) => a.accountNumber == '000105001234'), isTrue);
    });

    test('recordInvoicePayment and getInvoicePayments manage invoice direct payments (Section 3)', () async {
      const invId = 'INV-2026-0042';
      final req = RecordInvoicePaymentRequest(
        amount: 3500.0,
        paymentMode: 'UPI',
        referenceNumber: 'UPI/INV/777',
        notes: 'Partial settlement for invoice',
      );

      final res = await PaymentsRepository.recordInvoicePayment(invId, req);
      expect(res['success'], isTrue);

      final payments = await PaymentsRepository.getInvoicePayments(invId);
      expect(payments, isNotEmpty);
      expect(payments.first.amount, equals(3500.0));
      expect(payments.first.invoiceId, equals(invId));
    });

    test('recordPurchasePayment and getPurchasePayments manage supplier purchase payments (Section 4)', () async {
      const purchaseId = 'PUR-2026-0099';
      final req = RecordPurchasePaymentRequest(
        amount: 8000.0,
        paymentMode: 'Bank Transfer',
        referenceNumber: 'NEFT/PUR/999',
        accountId: 1,
        notes: 'Material purchase payment',
      );

      final res = await PaymentsRepository.recordPurchasePayment(purchaseId, req);
      expect(res['success'], isTrue);

      final payment = await PaymentsRepository.getPurchasePayments(purchaseId);
      expect(payment, isNotNull);
      expect(payment!.purchaseId, equals(purchaseId));
      expect(payment.amount, equals(8000.0));
    });

    test('Planned Payments CRUD (Section 5)', () async {
      // 1. Create Planned Payment
      final createReq = CreatePlannedPaymentRequest(
        name: 'Office Internet Bill',
        amount: 2499.0,
        dueDate: '2026-11-05',
        type: 'SEND',
        category: 'Utilities',
        frequency: 'MONTHLY',
        description: 'Airtel Broadband Office',
      );

      final created = await PaymentsRepository.createPlannedPayment(createReq);
      expect(created, isNotNull);
      expect(created.name, equals('Office Internet Bill'));
      expect(created.amount, equals(2499.0));
      expect(created.status, equals('PENDING'));

      // 2. Fetch Planned Payments
      final list = await PaymentsRepository.getPlannedPayments();
      expect(list.any((p) => p.name == 'Office Internet Bill'), isTrue);

      // 3. Update Planned Payment
      final updated = await PaymentsRepository.updatePlannedPayment(created.id, {
        'amount': 2699.0,
        'description': 'Airtel Broadband High Speed',
      });
      expect(updated.amount, equals(2699.0));

      // 4. Mark Planned Payment as Paid
      await PaymentsRepository.markPlannedPaymentPaid(created.id);
      final listAfterPaid = await PaymentsRepository.getPlannedPayments();
      final paidItem = listAfterPaid.firstWhere((p) => p.id.toString() == created.id.toString());
      expect(paidItem.status, equals('COMPLETED'));

      // 5. Delete Planned Payment
      await PaymentsRepository.deletePlannedPayment(created.id);
      final listAfterDelete = await PaymentsRepository.getPlannedPayments();
      expect(listAfterDelete.any((p) => p.id.toString() == created.id.toString()), isFalse);
    });

    test('Business Account Isolation verifies separate data per user email session', () async {
      // User A session
      await TokenService.saveUserInfo(email: 'businessA@bnxmail.com', name: 'Business Alpha');
      final reportsA = await PaymentsRepository.getPaymentReports();
      expect(reportsA.accounts.first.accountHolder.toLowerCase(), contains('businessa'));

      final statsBeforeA = await PaymentsRepository.getOutstandingStats();
      final recvBeforeA = statsBeforeA?.receivables ?? 0.0;

      // Create a payment under User A
      await PaymentsRepository.receivePayment(ReceivePaymentRequest(
        amount: 9999.0,
        customerName: 'Customer Alpha',
        paymentMode: 'UPI',
        accountId: 1,
      ));
      final statsA = await PaymentsRepository.getOutstandingStats();
      expect(statsA?.receivables, equals(recvBeforeA + 9999.0));

      // Switch to User B session
      await TokenService.saveUserInfo(email: 'businessB@bnxmail.com', name: 'Business Beta');
      final reportsB = await PaymentsRepository.getPaymentReports();
      expect(reportsB.accounts.first.accountHolder.toLowerCase(), contains('businessb'));

      // User B must NOT see User A's Customer Alpha receipt or User A's updated receivable total!
      expect(reportsB.receivables.any((r) => r.customerName == 'Customer Alpha'), isFalse);
      final statsB = await PaymentsRepository.getOutstandingStats();
      expect(statsB?.receivables, isNot(equals(statsA?.receivables)));
    });
  });
}

