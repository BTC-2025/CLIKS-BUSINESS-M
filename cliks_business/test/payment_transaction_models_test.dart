import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/data/models/payment_transaction_models.dart';

void main() {
  group('CashFlowTransaction Model Tests', () {
    test('CashFlowTransaction parses income record from backend JSON', () {
      final json = {
        'id': 105,
        'user_id': 93,
        'account_id': 1,
        'type': 'income',
        'amount': 15000.00,
        'category': 'Direct Sales',
        'date': '2026-11-24T00:00:00.000Z',
        'description': 'Counter POS settlement',
        'reference': 'POS-2026-11',
      };

      final tx = CashFlowTransaction.fromJson(json);

      expect(tx.id, equals(105));
      expect(tx.userId, equals(93));
      expect(tx.accountId, equals(1));
      expect(tx.isIncome, isTrue);
      expect(tx.isExpense, isFalse);
      expect(tx.flowTypeLabel, equals('INWARD'));
      expect(tx.amount, equals(15000.00));
      expect(tx.category, equals('Direct Sales'));
      expect(tx.displayTitle, equals('Counter POS settlement'));
      expect(tx.displayReference, equals('POS-2026-11'));
      expect(tx.formattedDate, equals('24/11/2026'));
      expect(tx.isoDateString, equals('2026-11-24'));
    });

    test('CashFlowTransaction parses expense record with string amount and null description', () {
      final json = {
        'id': 439,
        'user_id': 93,
        'account_id': null,
        'type': 'expense',
        'amount': '200000',
        'category': null,
        'description': null,
        'date': '2026-11-17T06:05:11.467Z',
        'schedule': 'BILL Payment for procurement BILL-1418',
        'title': '',
      };

      final tx = CashFlowTransaction.fromJson(json);

      expect(tx.id, equals(439));
      expect(tx.isIncome, isFalse);
      expect(tx.isExpense, isTrue);
      expect(tx.flowTypeLabel, equals('OUTWARD'));
      expect(tx.amount, equals(200000.00));
      expect(tx.displayTitle, equals('BILL Payment for procurement BILL-1418'));
      expect(tx.displayReference, equals('BILL-1418'));
      expect(tx.displayCategory, equals('General Expense'));
    });

    test('CashFlowTransaction extracts Invoice reference from schedule string', () {
      final json = {
        'id': 440,
        'type': 'income',
        'amount': '6500',
        'schedule': 'Sales Payment received for Invoice INV-000001',
      };

      final tx = CashFlowTransaction.fromJson(json);

      expect(tx.isIncome, isTrue);
      expect(tx.amount, equals(6500.0));
      expect(tx.displayReference, equals('INV-000001'));
      expect(tx.displayTitle, equals('Sales Payment received for Invoice INV-000001'));
    });

    test('CashFlowTransaction serializes to JSON correctly', () {
      final tx = CashFlowTransaction(
        id: 'tx_999',
        type: 'income',
        amount: 5000.0,
        category: 'Consulting',
        date: DateTime(2026, 11, 26),
        description: 'Client payment',
        reference: 'REF-999',
      );

      final map = tx.toJson();
      expect(map['id'], equals('tx_999'));
      expect(map['type'], equals('income'));
      expect(map['amount'], equals(5000.0));
      expect(map['category'], equals('Consulting'));
      expect(map['reference'], equals('REF-999'));
    });
  });

  group('CashFlowAccount Model Tests', () {
    test('CashFlowAccount parses Bank Account with masking', () {
      final json = {
        'id': 1,
        'bank_name': 'karnataka bank',
        'account_holder': 'Ravi kumar',
        'account_number': '98938473984394872',
        'ifsc': 'HDFC0000001',
        'branch': 'tiruvvallur',
        'current_balance': '800000',
        'status': 'Active',
      };

      final acc = CashFlowAccount.fromJson(json);

      expect(acc.id, equals(1));
      expect(acc.displayName, equals('karnataka bank'));
      expect(acc.accountHolder, equals('Ravi kumar'));
      expect(acc.isCash, isFalse);
      expect(acc.isActive, isTrue);
      expect(acc.currentBalance, equals(800000.0));
      expect(acc.displayAccountNumber, equals('•••• 4872'));
    });

    test('CashFlowAccount parses Cash Register account', () {
      final json = {
        'id': 'cash-register',
        'bank_account_id': 'cash-register',
        'bank_account_name': 'Cash Register (Cash in Hand)',
        'bank_name': 'Cash Register',
        'account_number': 'Cash Counter',
        'current_balance': 55000.0,
        'type': 'cash',
        'status': 'Active',
      };

      final acc = CashFlowAccount.fromJson(json);

      expect(acc.id, equals('cash-register'));
      expect(acc.isCash, isTrue);
      expect(acc.currentBalance, equals(55000.0));
      expect(acc.displayAccountNumber, equals('Cash Counter'));
      expect(acc.displayName, equals('Cash Register'));
    });
  });

  group('OutstandingSummaryStats Model Tests', () {
    test('OutstandingSummaryStats parses nested data and root data', () {
      final rootJson = {
        'receivables': 12500.0,
        'payables': 8300.0,
        'total_processed': 45000.0,
      };
      final stats = OutstandingSummaryStats.fromJson(rootJson);
      expect(stats.receivables, equals(12500.0));
      expect(stats.payables, equals(8300.0));
      expect(stats.totalProcessed, equals(45000.0));

      final nestedJson = {
        'status': 'success',
        'data': {
          'receivables': 0,
          'payables': 0,
          'total_processed': 43500.00,
        },
      };
      final nestedStats = OutstandingSummaryStats.fromJson(nestedJson);
      expect(nestedStats.receivables, equals(0.0));
      expect(nestedStats.totalProcessed, equals(43500.0));
    });
  });

  group('PaymentLedgerItem Model Tests', () {
    test('PaymentLedgerItem parses receive and pay vouchers', () {
      final receiveJson = {
        'id': 85,
        'type': 'receive',
        'party_name': 'Acme Retail Ltd',
        'invoice_id': 'INV-1042',
        'amount': 15000.00,
        'paidAmount': 15000.00,
        'payment_mode': 'UPI',
        'reference_number': 'UPI-984729184',
        'status': 'completed',
        'reconciliation_status': 'matched',
        'created_at': '2026-11-24T10:00:00.000Z',
      };
      final item = PaymentLedgerItem.fromJson(receiveJson);
      expect(item.id, equals(85));
      expect(item.isReceive, isTrue);
      expect(item.isPay, isFalse);
      expect(item.flowTypeLabel, equals('INWARD'));
      expect(item.partyName, equals('Acme Retail Ltd'));
      expect(item.amount, equals(15000.00));
      expect(item.formattedDate, equals('24/11/2026'));
      expect(item.displayReference, equals('UPI-984729184'));
    });
  });

  group('Request DTOs Tests', () {
    test('ReceivePaymentRequest generates documented JSON payload', () {
      final req = ReceivePaymentRequest(
        customerName: 'Acme Retail Ltd',
        invoiceId: 1042,
        amount: 15000.0,
        paidAmount: 15000.0,
        paymentMode: 'UPI',
        referenceNumber: 'UPI-984729184',
        accountId: 1,
        notes: 'Settlement of invoice INV-1042',
      );

      final json = req.toJson();
      expect(json['customer_name'], equals('Acme Retail Ltd'));
      expect(json['invoice_id'], equals(1042));
      expect(json['amount'], equals(15000.0));
      expect(json['paidAmount'], equals(15000.0));
      expect(json['payment_mode'], equals('UPI'));
      expect(json['reference_number'], equals('UPI-984729184'));
      expect(json['account_id'], equals(1));
      expect(json['notes'], equals('Settlement of invoice INV-1042'));
    });

    test('PaySupplierRequest generates documented JSON payload', () {
      final req = PaySupplierRequest(
        supplierName: 'Apex Fabricators',
        purchaseId: 'PUR-2026-089',
        amount: 28500.0,
        paymentMode: 'Bank Transfer',
        referenceNumber: 'NEFT-88492041',
        accountId: 2,
        notes: 'Settlement for PO #108 raw materials',
      );

      final json = req.toJson();
      expect(json['supplier_name'], equals('Apex Fabricators'));
      expect(json['purchase_id'], equals('PUR-2026-089'));
      expect(json['amount'], equals(28500.0));
      expect(json['payment_mode'], equals('Bank Transfer'));
      expect(json['reference_number'], equals('NEFT-88492041'));
      expect(json['account_id'], equals(2));
    });

    test('TransferFundsRequest generates documented JSON payload', () {
      final req = TransferFundsRequest(
        fromAccId: 1,
        toAccId: 2,
        amount: 50000.0,
      );

      final json = req.toJson();
      expect(json['from_acc_id'], equals(1));
      expect(json['to_acc_id'], equals(2));
      expect(json['amount'], equals(50000.0));
    });

    test('CreateCashFlowTransactionRequest generates documented JSON payload', () {
      final req = CreateCashFlowTransactionRequest(
        type: 'expense',
        amount: 3500.0,
        category: 'Office Utilities',
        date: '2026-11-24',
        description: 'High-speed internet bill',
        accountId: 1,
        reference: 'ACT-84920',
      );

      final json = req.toJson();
      expect(json['type'], equals('expense'));
      expect(json['amount'], equals(3500.0));
      expect(json['category'], equals('Office Utilities'));
      expect(json['date'], equals('2026-11-24'));
      expect(json['description'], equals('High-speed internet bill'));
      expect(json['account_id'], equals(1));
      expect(json['reference'], equals('ACT-84920'));
    });

    test('UpdateCashFlowTransactionRequest omits null fields', () {
      final req = UpdateCashFlowTransactionRequest(
        amount: 3800.0,
        description: 'High-speed internet bill + router lease',
      );

      final json = req.toJson();
      expect(json['amount'], equals(3800.0));
      expect(json['description'], equals('High-speed internet bill + router lease'));
      expect(json.containsKey('category'), isFalse);
      expect(json.containsKey('date'), isFalse);
    });

    test('CreateGatewayOrderRequest generates documented Cashfree payload', () {
      final req = CreateGatewayOrderRequest(
        amount: 4999.0,
        orderId: 'ORDER_20261124_001',
      );

      final json = req.toJson();
      expect(json['amount'], equals(4999.0));
      expect(json['orderId'], equals('ORDER_20261124_001'));
      expect(json['currency'], equals('INR'));
    });
  });
}
