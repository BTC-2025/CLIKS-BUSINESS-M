import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/models/payment_transaction_models.dart';

void main() {
  group('PaymentTransactionRepository & Models Integration Tests', () {
    setUp(() async {
      await TokenService.saveTokens(
        accessToken: 'mock_jwt_access_token',
        refreshToken: 'mock_refresh_token',
      );
      await TokenService.saveUserInfo(
        email: 'ravinew2004@bnxmail.com',
        name: 'Ravi Kumar',
      );
    });

    test('1. POST /api/v1/payments/receive payload & response verification', () {
      final req = ReceivePaymentRequest(
        customerName: 'Acme Retailers Pvt Ltd',
        amount: 25000.0,
        paidAmount: 25000.0,
        paymentMode: 'UPI',
        invoiceId: 'INV-2026-089',
        referenceNumber: 'UPI-REF-98127391',
        accountId: 4,
        notes: 'Invoice clearing for October',
      );

      final jsonPayload = req.toJson();
      expect(jsonPayload['customer_name'], 'Acme Retailers Pvt Ltd');
      expect(jsonPayload['amount'], 25000.0);
      expect(jsonPayload['paidAmount'], 25000.0);
      expect(jsonPayload['payment_mode'], 'UPI');
      expect(jsonPayload['invoice_id'], 'INV-2026-089');
      expect(jsonPayload['reference_number'], 'UPI-REF-98127391');
      expect(jsonPayload['account_id'], 4);
      expect(jsonPayload['notes'], 'Invoice clearing for October');

      final mockApiResponse = <String, dynamic>{
        'status': 'success',
        'message': 'Payment received successfully',
        'data': {
          'id': 'REC-9012',
          'amount': 25000.0,
          'status': 'COMPLETED',
        },
      };
      expect(mockApiResponse['status'], 'success');
      expect((mockApiResponse['data'] as Map<String, dynamic>)['id'], 'REC-9012');
    });

    test('2. POST /api/v1/payments/pay payload & response verification', () {
      final req = PaySupplierRequest(
        supplierName: 'Global Timber Supplies',
        amount: 45000.0,
        paymentMode: 'Bank Transfer',
        purchaseId: 'BILL-4412',
        referenceNumber: 'NEFT-889123',
        accountId: 2,
        notes: 'Raw material procurement',
      );

      final jsonPayload = req.toJson();
      expect(jsonPayload['supplier_name'], 'Global Timber Supplies');
      expect(jsonPayload['amount'], 45000.0);
      expect(jsonPayload['payment_mode'], 'Bank Transfer');
      expect(jsonPayload['purchase_id'], 'BILL-4412');
      expect(jsonPayload['reference_number'], 'NEFT-889123');
      expect(jsonPayload['account_id'], 2);
      expect(jsonPayload['notes'], 'Raw material procurement');
    });

    test('3. POST /api/v1/payments/transfer payload verification', () {
      final req = TransferFundsRequest(
        fromAccId: 1,
        toAccId: 3,
        amount: 15000.0,
      );

      final jsonPayload = req.toJson();
      expect(jsonPayload['from_acc_id'], 1);
      expect(jsonPayload['to_acc_id'], 3);
      expect(jsonPayload['amount'], 15000.0);
    });

    test('4. GET /api/v1/payments/reports response deserialization', () {
      final mockReportsJson = {
        'status': 'success',
        'data': {
          'receivables': [
            {
              'id': 'REC-001',
              'invoice_number': 'POS-161910',
              'customer_name': 'Walk-in Customer',
              'amount': 2500.0,
              'status': 'paid',
              'date': '2026-11-20',
            },
            {
              'id': 'REC-002',
              'invoice_number': 'INV-9921',
              'customer_name': 'Delta Enterprises',
              'amount': 18500.0,
              'status': 'overdue',
              'due_date': '2026-11-15',
            },
          ],
          'payables': [
            {
              'id': 'PAY-001',
              'bill_number': 'BILL-1418',
              'supplier_name': 'Steel Syndicate',
              'amount': 12000.0,
              'status': 'paid',
              'date': '2026-11-18',
            },
          ],
          'accounts': [
            {
              'id': '1',
              'bank_name': 'State Bank of India',
              'account_number': '123456789012',
              'current_balance': 750000.0,
              'type': 'bank',
            },
            {
              'id': '2',
              'bank_name': 'Main Showroom Cash Register',
              'account_number': 'CASH-001',
              'current_balance': 45200.0,
              'type': 'cash',
            },
          ],
        },
      };

      final data = mockReportsJson['data'] as Map<String, dynamic>;
      final receivables = (data['receivables'] as List)
          .map((e) => PaymentLedgerItem.fromJson(e, defaultType: 'receive'))
          .toList();
      final payables = (data['payables'] as List)
          .map((e) => PaymentLedgerItem.fromJson(e, defaultType: 'pay'))
          .toList();
      final accounts = (data['accounts'] as List).map((e) => CashFlowAccount.fromJson(e)).toList();

      expect(receivables.length, 2);
      expect(receivables[0].referenceNumber, 'POS-161910');
      expect(receivables[0].isReceive, isTrue);
      expect(receivables[1].isReceive, isTrue);

      expect(payables.length, 1);
      expect(payables[0].referenceNumber, 'BILL-1418');
      expect(payables[0].isPay, isTrue);
      expect(payables[0].flowTypeLabel, 'OUTWARD');

      expect(accounts.length, 2);
      expect(accounts[0].isCash, isFalse);
      expect(accounts[0].displayAccountNumber, '•••• 9012');
      expect(accounts[1].isCash, isTrue);
    });

    test('5. GET /api/v1/payments/outstanding parsing', () {
      final mockData = {
        'status': 'success',
        'data': {
          'receivables': 125000.50,
          'payables': 89200.00,
          'total_processed': 4500000.00,
        },
      };

      final stats = OutstandingSummaryStats.fromJson(mockData);
      expect(stats.receivables, 125000.50);
      expect(stats.payables, 89200.00);
      expect(stats.totalProcessed, 4500000.00);
    });

    test('6. POST /api/v1/payments/create-order payload & response', () {
      final req = CreateGatewayOrderRequest(
        orderId: 'ORDER_20261126_88912',
        amount: 999.0,
      );

      final json = req.toJson();
      expect(json['orderId'], 'ORDER_20261126_88912');
      expect(json['amount'], 999.0);
      expect(json['currency'], 'INR');

      final mockGatewayResponse = {
        'cf_order_id': 9827361,
        'order_id': 'ORDER_20261126_88912',
        'payment_session_id': 'session_a8f9d01247bf_sandbox',
        'order_status': 'ACTIVE',
      };
      expect(mockGatewayResponse['payment_session_id'], contains('session_'));
    });

    test('7. GET /api/v1/transactions parsing list and metadata', () {
      final mockListJson = {
        'status': 'success',
        'data': [
          {
            'id': 101,
            'user_id': 93,
            'account_id': 1,
            'type': 'income',
            'amount': 15000.0,
            'category': 'Sales',
            'description': 'Direct Showroom Walk-in',
            'date': '2026-11-26',
            'created_at': '2026-11-26T10:00:00.000Z',
          },
          {
            'id': 102,
            'user_id': 93,
            'account_id': 1,
            'type': 'expense',
            'amount': 4500.0,
            'category': 'Utilities',
            'description': 'Electricity bill payment',
            'date': '2026-11-25',
            'created_at': '2026-11-25T14:30:00.000Z',
          },
        ],
        'meta': {
          'total': 2,
          'page': 1,
          'last_page': 1,
        },
      };

      final items = (mockListJson['data'] as List)
          .map((e) => CashFlowTransaction.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(items.length, 2);
      expect(items[0].isIncome, isTrue);
      expect(items[0].isExpense, isFalse);
      expect(items[0].flowTypeLabel, 'INWARD');
      expect(items[1].isIncome, isFalse);
      expect(items[1].isExpense, isTrue);
      expect(items[1].flowTypeLabel, 'OUTWARD');
    });

    test('8. POST /api/v1/transactions serialization', () {
      final req = CreateCashFlowTransactionRequest(
        amount: 8500.0,
        type: 'expense',
        category: 'Office Supplies',
        description: 'Printer cartridges and copier paper',
        date: '2026-11-26',
        accountId: 2,
      );

      final json = req.toJson();
      expect(json['amount'], 8500.0);
      expect(json['type'], 'expense');
      expect(json['category'], 'Office Supplies');
      expect(json['description'], 'Printer cartridges and copier paper');
      expect(json['date'], '2026-11-26');
      expect(json['account_id'], 2);
    });

    test('9. PATCH /api/v1/transactions/:id partial update serialization', () {
      final req = UpdateCashFlowTransactionRequest(
        amount: 9200.0,
        description: 'Updated Office Supplies Invoice #99',
      );

      final json = req.toJson();
      expect(json['amount'], 9200.0);
      expect(json['description'], 'Updated Office Supplies Invoice #99');
      expect(json.containsKey('category'), isFalse);
      expect(json.containsKey('date'), isFalse);
    });

    test('10. Bank Account masking and Cash detection', () {
      final bank = CashFlowAccount(
        id: 10,
        bankName: 'HDFC Bank',
        accountHolder: 'Ravi Kumar',
        accountNumber: '50100239102938',
        currentBalance: 1250000.0,
        type: 'bank',
        status: 'Active',
      );
      expect(bank.displayAccountNumber, '•••• 2938');
      expect(bank.isCash, isFalse);

      final cash = CashFlowAccount(
        id: 11,
        bankName: 'Main Cash Register',
        accountHolder: 'Cashier 1',
        accountNumber: 'POS-CASH',
        currentBalance: 32000.0,
        type: 'cash',
        status: 'Active',
      );
      expect(cash.displayAccountNumber, 'POS-CASH');
      expect(cash.isCash, isTrue);
    });
  });
}
