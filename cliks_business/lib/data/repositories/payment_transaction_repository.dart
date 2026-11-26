import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/payment_transaction_models.dart';

/// Central repository managing all 11 endpoints for Payments & Cash Flow Engine.
///
/// Route Prefixes:
/// - `/api/v1/payments/*`
/// - `/api/v1/transactions/*`
/// - `/api/v1/bank-accounts/*`
class PaymentTransactionRepository {
  // ── 1. RECEIVE CUSTOMER PAYMENT / RECEIPT (POST /api/v1/payments/receive) ──
  static Future<Map<String, dynamic>> receivePayment(
    ReceivePaymentRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '${ApiClient.paymentsBaseUrl}/v1/payments/receive',
      body: req.toJson(),
      email: email,
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['error']?['message']?.toString() ??
              res['message']?.toString() ??
              'Failed to record customer payment receipt',
        );
      }
      return res;
    }
    return {'success': true};
  }

  // ── 2. PAY SUPPLIER / VENDOR OUTLAY (POST /api/v1/payments/pay) ───────────
  static Future<Map<String, dynamic>> paySupplier(
    PaySupplierRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '${ApiClient.paymentsBaseUrl}/v1/payments/pay',
      body: req.toJson(),
      email: email,
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['error']?['message']?.toString() ??
              res['message']?.toString() ??
              'Failed to process supplier disbursement',
        );
      }
      return res;
    }
    return {'success': true};
  }

  // ── 3. VAULT / INTER-ACCOUNT FUND TRANSFER (POST /api/v1/payments/transfer)
  static Future<Map<String, dynamic>> transferFunds(
    TransferFundsRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '${ApiClient.paymentsBaseUrl}/v1/payments/transfer',
      body: req.toJson(),
      email: email,
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['error']?['message']?.toString() ??
              res['message']?.toString() ??
              'Failed to transfer funds between accounts',
        );
      }
      return res;
    }
    return {'success': true};
  }

  // ── 4. GET PAYMENT REPORTS & COMBINED LEDGER (GET /api/v1/payments/reports)
  static Future<Map<String, dynamic>> getPaymentReports({String? email}) async {
    final res = await ApiClient.get(
      '${ApiClient.paymentsBaseUrl}/v1/payments/reports',
      email: email,
    );
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return res;
    }
    return {};
  }

  // ── 5. GET OUTSTANDING SUMMARY STATS (GET /api/v1/payments/outstanding) ───
  static Future<OutstandingSummaryStats> getOutstandingStats({
    String? email,
  }) async {
    try {
      final res = await ApiClient.get(
        '${ApiClient.paymentsBaseUrl}/v1/payments/outstanding',
        email: email,
      );
      if (res is Map<String, dynamic>) {
        return OutstandingSummaryStats.fromJson(res);
      }
    } catch (_) {}
    return OutstandingSummaryStats(
      receivables: 0.0,
      payables: 0.0,
      totalProcessed: 0.0,
    );
  }

  // ── 6. CREATE CASHFREE PAYMENT ORDER (POST /api/v1/payments/create-order) ─
  static Future<Map<String, dynamic>> createPaymentOrder(
    CreateGatewayOrderRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '${ApiClient.paymentsBaseUrl}/v1/payments/create-order',
      body: req.toJson(),
      email: email,
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['error']?['message']?.toString() ??
              res['message']?.toString() ??
              'Failed to initiate payment gateway checkout session',
        );
      }
      return res;
    }
    return {'success': true};
  }

  // ── 7. LIST CASH FLOW TRANSACTIONS (GET /api/v1/transactions) ────────────
  static Future<List<CashFlowTransaction>> getTransactions({
    String? type,
    dynamic accountId,
    String? category,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
    String? email,
  }) async {
    final queryParams = <String, String>{};
    if (type != null && type.isNotEmpty && type.toLowerCase() != 'all') {
      queryParams['type'] = type.toLowerCase();
    }
    if (accountId != null && accountId.toString().isNotEmpty) {
      queryParams['account_id'] = accountId.toString();
    }
    if (category != null && category.isNotEmpty && category != 'All Categories') {
      queryParams['category'] = category;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final res = await ApiClient.get(
      '${ApiClient.paymentsBaseUrl}/v1/transactions',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      email: email,
    );

    if (res is Map<String, dynamic>) {
      var data = res['data'];
      if (data is Map<String, dynamic>) {
        data = data['data'] ?? data['transactions'] ?? data['items'];
      }
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => CashFlowTransaction.fromJson(e))
            .toList();
      }
    } else if (res is List) {
      return res
          .whereType<Map<String, dynamic>>()
          .map((e) => CashFlowTransaction.fromJson(e))
          .toList();
    }
    return [];
  }

  // ── 8. CREATE CASH FLOW TRANSACTION (POST /api/v1/transactions) ───────────
  static Future<CashFlowTransaction> createTransaction(
    CreateCashFlowTransactionRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '${ApiClient.paymentsBaseUrl}/v1/transactions',
      body: req.toJson(),
      email: email,
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['error']?['message']?.toString() ??
              res['message']?.toString() ??
              'Failed to create transaction',
        );
      }
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return CashFlowTransaction.fromJson(data);
      }
    }
    throw ApiException(statusCode: 500, message: 'Invalid response from server');
  }

  // ── 9. GET TRANSACTION BY ID (GET /api/v1/transactions/:id) ───────────────
  static Future<CashFlowTransaction?> getTransactionById(
    dynamic id, {
    String? email,
  }) async {
    try {
      final res = await ApiClient.get(
        '${ApiClient.paymentsBaseUrl}/v1/transactions/$id',
        email: email,
      );
      if (res is Map<String, dynamic>) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          return CashFlowTransaction.fromJson(data);
        }
      }
    } catch (_) {}
    return null;
  }

  // ── 10. UPDATE TRANSACTION (PATCH /api/v1/transactions/:id) ───────────────
  static Future<CashFlowTransaction> updateTransaction(
    dynamic id,
    UpdateCashFlowTransactionRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '${ApiClient.paymentsBaseUrl}/v1/transactions/$id',
      body: req.toJson(),
      email: email,
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['error']?['message']?.toString() ??
              res['message']?.toString() ??
              'Failed to update transaction',
        );
      }
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return CashFlowTransaction.fromJson(data);
      }
    }
    throw ApiException(statusCode: 500, message: 'Invalid response from server');
  }

  // ── 11. DELETE TRANSACTION (DELETE /api/v1/transactions/:id) ──────────────
  static Future<bool> deleteTransaction(
    dynamic id, {
    String? email,
  }) async {
    final res = await ApiClient.delete(
      '${ApiClient.paymentsBaseUrl}/v1/transactions/$id',
      email: email,
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['error']?['message']?.toString() ??
              res['message']?.toString() ??
              'Failed to delete transaction',
        );
      }
      return true;
    }
    return true;
  }

  // ── BONUS: GET BANK ACCOUNTS (GET /api/v1/bank-accounts) ───────────────────
  static Future<List<CashFlowAccount>> getBankAccounts({String? email}) async {
    final res = await ApiClient.get(
      '${ApiClient.paymentsBaseUrl}/v1/bank-accounts',
      email: email,
    );
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => CashFlowAccount.fromJson(e))
            .toList();
      }
    }
    return [];
  }
}
