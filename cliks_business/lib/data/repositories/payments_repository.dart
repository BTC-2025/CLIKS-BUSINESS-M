import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/payment_models.dart';

/// Central repository for interacting with Cliks Business Payment APIs.
class PaymentsRepository {
  /// Fetches unified reports including receivables, payables, accounts, and overdue invoices.
  /// Calls: `GET /api/v1/payments/reports`
  static Future<PaymentReports> getPaymentReports() async {
    final res = await ApiClient.get('/api/v1/payments/reports');
    if (res is Map<String, dynamic>) {
      final reports = PaymentReports.fromJson(res);
      if (reports.accounts.isEmpty) {
        try {
          final accounts = await getBankAccounts();
          if (accounts.isNotEmpty) {
            return PaymentReports(
              receivables: reports.receivables,
              payables: reports.payables,
              accounts: accounts,
              overdueInvoices: reports.overdueInvoices,
            );
          }
        } catch (_) {}
      }
      return reports;
    }
    return PaymentReports(
      receivables: [],
      payables: [],
      accounts: [],
      overdueInvoices: [],
    );
  }

  /// Fetches all registered bank and cash accounts.
  /// Calls: `GET /api/v1/bank-accounts`
  static Future<List<PaymentAccount>> getBankAccounts() async {
    final res = await ApiClient.get('/api/v1/bank-accounts');
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => PaymentAccount.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  /// Fetches a specific bank or cash account by its unique identifier.
  /// Calls: `GET /api/v1/bank-accounts/$id` with fallback to `getPaymentReports()`.
  static Future<PaymentAccount?> getAccountById(dynamic id) async {
    try {
      final res = await ApiClient.get('/api/v1/bank-accounts/$id');
      if (res is Map<String, dynamic>) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          return PaymentAccount.fromJson(data);
        }
      }
    } catch (_) {}

    final reports = await getPaymentReports();
    try {
      return reports.accounts.firstWhere(
        (a) => a.id.toString() == id.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Fetches aggregated outstanding statistics.
  /// Calls: `GET /api/v1/payments/outstanding`
  static Future<OutstandingStats?> getOutstandingStats() async {
    try {
      final res = await ApiClient.get('/api/v1/payments/outstanding');
      if (res is Map<String, dynamic>) {
        return OutstandingStats.fromJson(res);
      }
    } catch (_) {}
    return null;
  }

  /// Records an incoming customer payment receipt.
  /// Calls: `POST /api/v1/payments/receive`
  static Future<Map<String, dynamic>> receivePayment(ReceivePaymentRequest req) async {
    final res = await ApiClient.post(
      '/api/v1/payments/receive',
      body: req.toJson(),
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['message']?.toString() ?? 'Failed to record customer payment',
        );
      }
      return res;
    }
    return {'success': true};
  }

  /// Records an outgoing payment to a vendor or supplier.
  /// Calls: `POST /api/v1/payments/pay`
  static Future<Map<String, dynamic>> paySupplier(PaySupplierRequest req) async {
    final res = await ApiClient.post(
      '/api/v1/payments/pay',
      body: req.toJson(),
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['message']?.toString() ?? 'Failed to disburse supplier payment',
        );
      }
      return res;
    }
    return {'success': true};
  }

  /// Transfers funds between internal bank and cash accounts.
  /// Calls: `POST /api/v1/payments/transfer`
  static Future<Map<String, dynamic>> transferFunds(AccountTransferRequest req) async {
    final res = await ApiClient.post(
      '/api/v1/payments/transfer',
      body: req.toJson(),
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['message']?.toString() ?? 'Failed to execute internal fund transfer',
        );
      }
      return res;
    }
    return {'success': true};
  }

  /// Initiates a secure payment gateway session for mobile SDK checkout (Cashfree UPI / Cards).
  /// Calls: `POST /api/v1/payments/create-order`
  static Future<Map<String, dynamic>> createPaymentOrder(CreatePaymentOrderRequest req) async {
    final res = await ApiClient.post(
      '/api/v1/payments/create-order',
      body: req.toJson(),
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['message']?.toString() ?? 'Failed to create payment gateway order',
        );
      }
      return res;
    }
    return {'success': true};
  }

  /// Adds a new bank or cash account.
  /// Calls: `POST /api/v1/bank-accounts`
  static Future<PaymentAccount> createBankAccount(CreateBankAccountRequest req) async {
    final res = await ApiClient.post(
      '/api/v1/bank-accounts',
      body: req.toJson(),
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['message']?.toString() ?? 'Failed to create bank account',
        );
      }
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return PaymentAccount.fromJson(data);
      }
    }
    throw ApiException(statusCode: 500, message: 'Invalid server response for bank account creation');
  }

  /// Records a direct payment against an invoice.
  /// Calls: `POST /api/v1/billing/:id/payments`
  static Future<Map<String, dynamic>> recordInvoicePayment(
    dynamic invoiceId,
    RecordInvoicePaymentRequest req,
  ) async {
    final res = await ApiClient.post(
      '/api/v1/billing/$invoiceId/payments',
      body: req.toJson(),
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['message']?.toString() ?? 'Failed to record invoice payment',
        );
      }
      return res;
    }
    return {'success': true};
  }

  /// Fetches payment history for an invoice.
  /// Calls: `GET /api/v1/billing/:id/payments`
  static Future<List<InvoicePayment>> getInvoicePayments(dynamic invoiceId) async {
    final res = await ApiClient.get('/api/v1/billing/$invoiceId/payments');
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => InvoicePayment.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  /// Records an outgoing payment against a supplier purchase bill.
  /// Calls: `POST /api/v1/purchases/:id/payments`
  static Future<Map<String, dynamic>> recordPurchasePayment(
    dynamic purchaseId,
    RecordPurchasePaymentRequest req,
  ) async {
    final res = await ApiClient.post(
      '/api/v1/purchases/$purchaseId/payments',
      body: req.toJson(),
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['message']?.toString() ?? 'Failed to record purchase bill payment',
        );
      }
      return res;
    }
    return {'success': true};
  }

  /// Fetches payment details for a purchase bill.
  /// Calls: `GET /api/v1/purchases/:id/payments`
  static Future<PurchasePayment?> getPurchasePayments(dynamic purchaseId) async {
    final res = await ApiClient.get('/api/v1/purchases/$purchaseId/payments');
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return PurchasePayment.fromJson(data);
      }
    }
    return null;
  }

  /// Fetches scheduled/planned payments with optional query filters.
  /// Calls: `GET /api/v1/planned-payments`
  static Future<List<PlannedPayment>> getPlannedPayments({
    String? status,
    String? category,
    String? search,
    String? type,
    int? page,
    int? limit,
    String? sort,
    String? order,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
    if (order != null && order.isNotEmpty) queryParams['order'] = order;

    final res = await ApiClient.get(
      '/api/v1/planned-payments',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => PlannedPayment.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  /// Creates a planned/scheduled payment.
  /// Calls: `POST /api/v1/planned-payments`
  static Future<PlannedPayment> createPlannedPayment(CreatePlannedPaymentRequest req) async {
    final res = await ApiClient.post(
      '/api/v1/planned-payments',
      body: req.toJson(),
    );
    if (res is Map<String, dynamic>) {
      if (res['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message: res['message']?.toString() ?? 'Failed to create planned payment',
        );
      }
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return PlannedPayment.fromJson(data);
      }
    }
    throw ApiException(statusCode: 500, message: 'Invalid response creating planned payment');
  }

  /// Updates an existing scheduled payment.
  /// Calls: `PATCH /api/v1/planned-payments/:id`
  static Future<PlannedPayment> updatePlannedPayment(
    dynamic id,
    Map<String, dynamic> fields,
  ) async {
    final res = await ApiClient.patch(
      '/api/v1/planned-payments/$id',
      body: fields,
    );
    if (res is Map<String, dynamic>) {
      final data = res['data'];
      if (data is Map<String, dynamic>) {
        return PlannedPayment.fromJson(data);
      }
    }
    throw ApiException(statusCode: 500, message: 'Failed to update planned payment');
  }

  /// Marks a scheduled payment as paid.
  /// Calls: `PATCH /api/v1/planned-payments/:id/mark-paid`
  static Future<void> markPlannedPaymentPaid(dynamic id) async {
    final res = await ApiClient.patch(
      '/api/v1/planned-payments/$id/mark-paid',
      body: {},
    );
    if (res is Map<String, dynamic> && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to mark planned payment as paid',
      );
    }
  }

  /// Deletes a scheduled payment.
  /// Calls: `DELETE /api/v1/planned-payments/:id`
  static Future<void> deletePlannedPayment(dynamic id) async {
    final res = await ApiClient.delete('/api/v1/planned-payments/$id');
    if (res is Map<String, dynamic> && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to delete planned payment',
      );
    }
  }
}
