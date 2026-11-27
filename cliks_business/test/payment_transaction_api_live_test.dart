import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/models/payment_transaction_models.dart';
import 'package:clicks_business_frontend/data/repositories/payment_transaction_repository.dart';

void main() {
  test(
    'Live Payments & Transactions API - Full End-to-End Integration Lifecycle',
    timeout: const Timeout(Duration(seconds: 120)),
    () async {
    // 1. Authenticate with active account session token
    const bnxToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhcHBfbmFtZSI6IkJOWCBNYWlsIiwic3ViIjoicmF2aW5ldzIwMDRAYm54bWFpbC5jb20iLCJpYXQiOjE3OTMwODM2MTEsImV4cCI6MTc5NTY3NTYxMX0.neyvYkB7aY5zXgI-ehOp36vlaAeuI5BPR0Ho_X1OlV4';
    await TokenService.saveTokens(accessToken: bnxToken, refreshToken: '');
    await TokenService.saveUserInfo(email: 'ravinew2004@bnxmail.com', name: 'Ravi Kumar');

    // 2. GET OUTSTANDING SUMMARY STATS (GET /api/v1/payments/outstanding)
    final stats = await PaymentTransactionRepository.getOutstandingStats(email: 'ravinew2004@bnxmail.com');
    print('[LIVE TEST] Outstanding Stats - Receivables: ₹${stats.receivables}, Payables: ₹${stats.payables}, Processed: ₹${stats.totalProcessed}');
    expect(stats, isA<OutstandingSummaryStats>());

    // 3. GET PAYMENT REPORTS (GET /api/v1/payments/reports)
    final reports = await PaymentTransactionRepository.getPaymentReports(email: 'ravinew2004@bnxmail.com');
    print('[LIVE TEST] Payment Reports Keys: ${reports.keys.toList()}');
    print('[LIVE TEST] Overdue Invoices: ${reports['overdueInvoices']}');
    print('[LIVE TEST] Invoices: ${reports['invoices']}');
    print('[LIVE TEST] Receivables: ${reports['receivables']}');
    expect(reports.containsKey('receivables') || reports.containsKey('accounts'), isTrue);

    // 4. GET BANK ACCOUNTS (GET /api/v1/bank-accounts)
    final bankAccounts = await PaymentTransactionRepository.getBankAccounts(email: 'ravinew2004@bnxmail.com');
    print('[LIVE TEST] Bank Accounts Count: ${bankAccounts.length}');
    expect(bankAccounts, isA<List<CashFlowAccount>>());

    // 5. LIST TRANSACTIONS (GET /api/v1/transactions)
    final initialTxList = await PaymentTransactionRepository.getTransactions(email: 'ravinew2004@bnxmail.com');
    print('[LIVE TEST] Initial Transactions Count: ${initialTxList.length}');
    expect(initialTxList, isA<List<CashFlowTransaction>>());

    // 6. CREATE CASH FLOW TRANSACTION (POST /api/v1/transactions)
    final createReq = CreateCashFlowTransactionRequest(
      amount: 1250.0,
      type: 'income',
      category: 'Consulting',
      description: 'E2E QA Automated Test Payment',
      date: '2026-11-26',
    );
    final createdTx = await PaymentTransactionRepository.createTransaction(
      createReq,
      email: 'ravinew2004@bnxmail.com',
    );
    print('[LIVE TEST] Created Transaction ID: ${createdTx.id}, Category: ${createdTx.category}, Amount: ₹${createdTx.amount}');
    expect(createdTx.id, isNotNull);
    expect(createdTx.isIncome, isTrue);

    final txId = createdTx.id;

    try {
      // 7. GET TRANSACTION BY ID (GET /api/v1/transactions/:id)
      final fetchedTx = await PaymentTransactionRepository.getTransactionById(
        txId,
        email: 'ravinew2004@bnxmail.com',
      );
      expect(fetchedTx, isNotNull);
      print('[LIVE TEST] Fetched Transaction: ${fetchedTx!.displayTitle}, Flow: ${fetchedTx.flowTypeLabel}');
      expect(fetchedTx.id.toString(), txId.toString());

      // 8. UPDATE TRANSACTION (PATCH /api/v1/transactions/:id)
      final updateReq = UpdateCashFlowTransactionRequest(
        amount: 1500.0,
        description: 'E2E QA Automated Test Payment (Verified & Updated)',
      );
      final updatedTx = await PaymentTransactionRepository.updateTransaction(
        txId,
        updateReq,
        email: 'ravinew2004@bnxmail.com',
      );
      print('[LIVE TEST] Updated Transaction Amount: ₹${updatedTx.amount}, Desc: ${updatedTx.description}');
      expect(updatedTx.amount, 1500.0);
    } finally {
      // 9. DELETE TRANSACTION (DELETE /api/v1/transactions/:id)
      final deleted = await PaymentTransactionRepository.deleteTransaction(
        txId,
        email: 'ravinew2004@bnxmail.com',
      );
      print('[LIVE TEST] Deleted Transaction $txId Status: $deleted');
      expect(deleted, isTrue);
    }

    // 10. CREATE PAYMENT GATEWAY ORDER (POST /api/v1/payments/create-order)
    final orderReq = CreateGatewayOrderRequest(
      orderId: 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
      amount: 100.0,
    );
    final orderRes = await PaymentTransactionRepository.createPaymentOrder(
      orderReq,
      email: 'ravinew2004@bnxmail.com',
    );
    print('[LIVE TEST] Gateway Order Result: $orderRes');
    expect(orderRes, isA<Map<String, dynamic>>());
  });
}
