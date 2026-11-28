import 'dart:convert';

/// Represents a single cash flow transaction record from `GET /api/v1/transactions`.
class CashFlowTransaction {
  final dynamic id;
  final int? userId;
  final dynamic accountId;
  final String type; // 'income' or 'expense'
  final double amount;
  final String? category;
  final String? description;
  final DateTime? date;
  final String? schedule;
  final String? title;
  final String? reference;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CashFlowTransaction({
    required this.id,
    this.userId,
    this.accountId,
    required this.type,
    required this.amount,
    this.category,
    this.description,
    this.date,
    this.schedule,
    this.title,
    this.reference,
    this.createdAt,
    this.updatedAt,
  });

  bool get isIncome =>
      type.toLowerCase() == 'income' || type.toLowerCase() == 'inward';
  bool get isExpense =>
      type.toLowerCase() == 'expense' || type.toLowerCase() == 'outward';

  String get flowTypeLabel => isIncome ? 'INWARD' : 'OUTWARD';

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    if (schedule != null && schedule!.trim().isNotEmpty) return schedule!.trim();
    if (description != null && description!.trim().isNotEmpty) return description!.trim();
    if (category != null && category!.trim().isNotEmpty) return category!.trim();
    return isIncome ? 'Customer Income Receipt' : 'Expense Outlay';
  }

  String get displayReference {
    if (reference != null && reference!.trim().isNotEmpty) return reference!.trim();
    if (schedule != null && schedule!.contains('Invoice')) {
      final match = RegExp(r'Invoice\s+([A-Za-z0-9\-_]+)').firstMatch(schedule!);
      if (match != null) return match.group(1)!;
    }
    if (schedule != null && schedule!.contains('procurement')) {
      final match = RegExp(r'procurement\s+([A-Za-z0-9\-_]+)').firstMatch(schedule!);
      if (match != null) return match.group(1)!;
    }
    return 'TX-$id';
  }

  String get displayCategory {
    if (category != null && category!.trim().isNotEmpty) return category!.trim();
    return isIncome ? 'Direct Sales' : 'General Expense';
  }

  String get formattedDate {
    final d = date ?? createdAt;
    if (d == null) return '';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  String get isoDateString {
    final d = date ?? createdAt;
    if (d == null) return '';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$year-$month-$day';
  }

  factory CashFlowTransaction.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return CashFlowTransaction(
      id: json['id'] ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] is num ? (json['user_id'] as num).toInt() : null,
      accountId: json['account_id'],
      type: (json['type']?.toString().toLowerCase() == 'expense' ||
              json['type']?.toString().toLowerCase() == 'outward')
          ? 'expense'
          : 'income',
      amount: parseAmount(json['amount']),
      category: json['category']?.toString(),
      description: json['description']?.toString(),
      date: parseDate(json['date']),
      schedule: json['schedule']?.toString(),
      title: json['title']?.toString(),
      reference: json['reference']?.toString() ?? json['reference_number']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'account_id': accountId,
        'type': type,
        'amount': amount,
        'category': category,
        'description': description,
        'date': date?.toIso8601String(),
        'schedule': schedule,
        'title': title,
        'reference': reference,
      };
}

/// Represents a bank account or cash register connected to the business.
class CashFlowAccount {
  final dynamic id;
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final double currentBalance;
  final String type; // 'bank' or 'cash'
  final String status;
  final String? ifsc;
  final String? branch;

  CashFlowAccount({
    required this.id,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.currentBalance,
    required this.type,
    required this.status,
    this.ifsc,
    this.branch,
  });

  bool get isCash => type.toLowerCase() == 'cash';
  bool get isActive => status.toLowerCase() == 'active' || status.isEmpty;
  double get balance => currentBalance;

  String get displayName => bankName.isNotEmpty ? bankName : (isCash ? 'Cash Register' : 'Bank Account');

  String get displayAccountNumber {
    if (isCash) return accountNumber.isNotEmpty ? accountNumber : 'Cash Register';
    if (accountNumber.length > 4) {
      return '•••• ${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber.isNotEmpty ? accountNumber : 'Account';
  }

  factory CashFlowAccount.fromJson(Map<String, dynamic> json) {
    double parseBalance(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final rawBalance = json['current_balance'] ??
        json['balance'] ??
        json['opening_balance'] ??
        json['currentBalance'];

    final rawType = json['type']?.toString().toLowerCase() ??
        (json['account_number']?.toString().toLowerCase().contains('cash') == true ||
                json['bank_name']?.toString().toLowerCase().contains('cash') == true ||
                json['id']?.toString().toLowerCase().contains('cash') == true
            ? 'cash'
            : 'bank');

    return CashFlowAccount(
      id: json['id'] ?? json['bank_account_id'] ?? 'acc_${DateTime.now().millisecondsSinceEpoch}',
      bankName: json['bank_name']?.toString() ??
          json['bank_account_name']?.toString() ??
          (rawType == 'cash' ? 'Cash Register (Cash in Hand)' : 'Bank Account'),
      accountHolder: json['account_holder']?.toString() ??
          json['accountHolder']?.toString() ??
          'Account Holder',
      accountNumber: json['account_number']?.toString() ??
          json['accountNumber']?.toString() ??
          (rawType == 'cash' ? 'Cash Counter' : ''),
      currentBalance: parseBalance(rawBalance),
      type: rawType,
      status: json['status']?.toString() ?? 'Active',
      ifsc: json['ifsc']?.toString() ?? json['ifsc_code']?.toString(),
      branch: json['branch']?.toString() ?? json['branch_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bank_name': bankName,
        'account_holder': accountHolder,
        'account_number': accountNumber,
        'current_balance': currentBalance,
        'type': type,
        'status': status,
        'ifsc': ifsc,
        'branch': branch,
      };
}

/// Represents an aggregated summary of outstanding receivables, payables, and processed totals.
class OutstandingSummaryStats {
  final double receivables;
  final double payables;
  final double totalProcessed;

  OutstandingSummaryStats({
    required this.receivables,
    required this.payables,
    required this.totalProcessed,
  });

  factory OutstandingSummaryStats.fromJson(Map<String, dynamic> json) {
    double parseVal(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return OutstandingSummaryStats(
      receivables: parseVal(data['receivables']),
      payables: parseVal(data['payables']),
      totalProcessed: parseVal(data['total_processed'] ?? data['totalProcessed']),
    );
  }

  Map<String, dynamic> toJson() => {
        'receivables': receivables,
        'payables': payables,
        'total_processed': totalProcessed,
      };
}

/// Represents a unified ledger item returned by `/api/v1/payments/reports`.
class PaymentLedgerItem {
  final dynamic id;
  final String type; // 'receive' or 'pay'
  final String partyName;
  final double amount;
  final double paidAmount;
  final double totalOriginal;
  final double pendingAmount;
  final String paymentMode;
  final String referenceNumber;
  final String status;
  final String reconciliationStatus;
  final String? invoiceId;
  final String? purchaseId;
  final DateTime? createdAt;
  final String? notes;

  PaymentLedgerItem({
    required this.id,
    required this.type,
    required this.partyName,
    required this.amount,
    required this.paidAmount,
    required this.totalOriginal,
    required this.pendingAmount,
    required this.paymentMode,
    required this.referenceNumber,
    required this.status,
    required this.reconciliationStatus,
    this.invoiceId,
    this.purchaseId,
    this.createdAt,
    this.notes,
  });

  bool get isReceive =>
      type.toLowerCase() == 'receive' || type.toLowerCase() == 'inward';
  bool get isPay =>
      type.toLowerCase() == 'pay' || type.toLowerCase() == 'outward';

  String get flowTypeLabel => isReceive ? 'INWARD' : 'OUTWARD';

  String get entryDisplayId {
    final refStr = referenceNumber.trim();
    if (refStr.startsWith('REC-') || refStr.startsWith('PAY-')) {
      return refStr;
    }
    final yr = (createdAt ?? DateTime.now()).year;
    if (isReceive) {
      if (refStr.toUpperCase().contains('REF')) {
        return 'REC-REF-$id';
      }
      return 'REC-$yr-$id';
    } else {
      if (refStr.toUpperCase().contains('REF')) {
        return 'PAY-REF-$id';
      }
      return 'PAY-$yr-$id';
    }
  }

  String get displayReference =>
      referenceNumber.isNotEmpty ? referenceNumber : (invoiceId ?? purchaseId ?? 'REF-$id');

  double get displayOriginalAmount {
    if (totalOriginal > 0) return totalOriginal;
    if (amount > 0) return amount;
    return paidAmount;
  }

  double get displayTransactedAmount {
    if (paidAmount > 0) return paidAmount;
    return amount;
  }

  String get dateFormatted {
    final d = createdAt;
    if (d == null) return '—';
    final yr = d.year.toString();
    final mo = d.month.toString().padLeft(2, '0');
    final dy = d.day.toString().padLeft(2, '0');
    return '$yr-$mo-$dy';
  }

  String get formattedDate {
    if (createdAt == null) return '';
    final day = createdAt!.day.toString().padLeft(2, '0');
    final month = createdAt!.month.toString().padLeft(2, '0');
    final year = createdAt!.year.toString();
    return '$day/$month/$year';
  }

  factory PaymentLedgerItem.fromJson(Map<String, dynamic> json, {String defaultType = 'receive'}) {
    double parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    double amt = parseNum(json['amount']);
    double paid = parseNum(json['paid_amount'] ?? json['paidAmount'] ?? amt);
    double total = parseNum(json['total_original'] ??
        json['total_original_amount'] ??
        json['totalOriginalAmount'] ??
        (paid > 0 ? paid : amt));
    double pending = parseNum(json['pending_amount'] ?? (total - paid > 0 ? total - paid : 0.0));

    String party = json['party_name']?.toString() ??
        json['customer_name']?.toString() ??
        json['customerProfile']?.toString() ??
        json['supplier_name']?.toString() ??
        '';

    String ref = json['reference_number']?.toString() ??
        json['receipt_number']?.toString() ??
        json['invoice_number']?.toString() ??
        json['bill_number']?.toString() ??
        json['cheque_number']?.toString() ??
        '';

    String? invId = json['invoice_id']?.toString() ?? json['invoiceLinkedId']?.toString();
    String? purId = json['purchase_id']?.toString() ?? json['purchaseBillLinkedId']?.toString();
    final rawNotes = json['notes']?.toString();

    if (rawNotes != null && rawNotes.trim().isNotEmpty) {
      try {
        if (rawNotes.trim().startsWith('{')) {
          final parsed = jsonDecode(rawNotes.trim());
          if (parsed is Map<String, dynamic>) {
            final nParty = parsed['customerProfile'] ?? parsed['supplierProfile'] ?? parsed['party_name'];
            if (nParty != null && nParty.toString().trim().isNotEmpty) {
              party = nParty.toString().trim();
            }
            final nInv = parsed['invoiceLinkedId'] ?? parsed['invoice_id'];
            if (nInv != null && nInv.toString().trim().isNotEmpty) {
              invId = nInv.toString().trim();
            }
            final nPur = parsed['purchaseBillLinkedId'] ?? parsed['purchase_id'];
            if (nPur != null && nPur.toString().trim().isNotEmpty) {
              purId = nPur.toString().trim();
            }
            final nTotal = parsed['totalOriginalAmount'] ??
                parsed['total_original'] ??
                parsed['total_original_amount'] ??
                parsed['originalDueAmount'] ??
                parsed['original_due_amount'];
            if (nTotal != null) {
              final parsedTotal = parseNum(nTotal);
              if (parsedTotal > 0) total = parsedTotal;
            }
            final nPaid = parsed['paidAmount'] ?? parsed['paid_amount'];
            if (nPaid != null) {
              final parsedPaid = parseNum(nPaid);
              if (parsedPaid > 0) paid = parsedPaid;
            }
          }
        }
      } catch (_) {}
    }

    if (party.isEmpty) {
      party = 'General Party';
    }

    DateTime? date;
    final rawDate = json['created_at'] ?? json['date'];
    if (rawDate != null) {
      date = DateTime.tryParse(rawDate.toString());
    }

    final rawType = json['type']?.toString().toLowerCase() ?? defaultType;

    return PaymentLedgerItem(
      id: json['id'] ?? json['payment_id'] ?? 'ledger_${DateTime.now().millisecondsSinceEpoch}',
      type: (rawType == 'pay' || rawType == 'outward') ? 'pay' : 'receive',
      partyName: party,
      amount: amt,
      paidAmount: paid,
      totalOriginal: total,
      pendingAmount: pending,
      paymentMode: json['payment_mode']?.toString() ?? 'Cash',
      referenceNumber: ref,
      status: json['status']?.toString() ?? 'Completed',
      reconciliationStatus: json['reconciliation_status']?.toString() ?? 'matched',
      invoiceId: invId,
      purchaseId: purId,
      createdAt: date,
      notes: rawNotes,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REQUEST DTOs (Data Transfer Objects)
// ─────────────────────────────────────────────────────────────────────────────

/// Request payload for `POST /api/v1/payments/receive`.
class ReceivePaymentRequest {
  final String customerName;
  final dynamic invoiceId;
  final double amount;
  final double paidAmount;
  final String paymentMode;
  final String referenceNumber;
  final dynamic accountId;
  final String? notes;

  ReceivePaymentRequest({
    required this.customerName,
    this.invoiceId,
    required this.amount,
    required this.paidAmount,
    required this.paymentMode,
    required this.referenceNumber,
    this.accountId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'customer_name': customerName,
      'amount': amount,
      'paidAmount': paidAmount,
      'payment_mode': paymentMode,
      'reference_number': referenceNumber,
    };
    if (invoiceId != null && invoiceId.toString().isNotEmpty) {
      map['invoice_id'] = invoiceId;
    }
    if (accountId != null && accountId.toString().isNotEmpty) {
      map['account_id'] = accountId;
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

/// Request payload for `POST /api/v1/payments/pay`.
class PaySupplierRequest {
  final String supplierName;
  final dynamic purchaseId;
  final double amount;
  final String paymentMode;
  final String referenceNumber;
  final dynamic accountId;
  final String? notes;

  PaySupplierRequest({
    required this.supplierName,
    this.purchaseId,
    required this.amount,
    required this.paymentMode,
    required this.referenceNumber,
    this.accountId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'supplier_name': supplierName,
      'amount': amount,
      'payment_mode': paymentMode,
      'reference_number': referenceNumber,
    };
    if (purchaseId != null && purchaseId.toString().isNotEmpty) {
      map['purchase_id'] = purchaseId;
    }
    if (accountId != null && accountId.toString().isNotEmpty) {
      map['account_id'] = accountId;
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

/// Request payload for `POST /api/v1/payments/transfer`.
class TransferFundsRequest {
  final dynamic fromAccId;
  final dynamic toAccId;
  final double amount;

  TransferFundsRequest({
    required this.fromAccId,
    required this.toAccId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'from_acc_id': fromAccId,
        'to_acc_id': toAccId,
        'amount': amount,
      };
}

/// Request payload for `POST /api/v1/transactions`.
class CreateCashFlowTransactionRequest {
  final String type; // 'income' or 'expense'
  final double amount;
  final String? category;
  final String date; // YYYY-MM-DD
  final String? description;
  final dynamic accountId;
  final String? reference;

  CreateCashFlowTransactionRequest({
    required this.type,
    required this.amount,
    this.category,
    required this.date,
    this.description,
    this.accountId,
    this.reference,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'amount': amount,
      'date': date,
    };
    if (category != null && category!.trim().isNotEmpty) {
      map['category'] = category!.trim();
    }
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    if (accountId != null && accountId.toString().isNotEmpty) {
      map['account_id'] = accountId;
    }
    if (reference != null && reference!.trim().isNotEmpty) {
      map['reference'] = reference!.trim();
    }
    return map;
  }
}

/// Request payload for `PATCH /api/v1/transactions/:id`.
class UpdateCashFlowTransactionRequest {
  final double? amount;
  final String? description;
  final String? category;
  final String? date;
  final dynamic accountId;
  final String? reference;

  UpdateCashFlowTransactionRequest({
    this.amount,
    this.description,
    this.category,
    this.date,
    this.accountId,
    this.reference,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (amount != null) map['amount'] = amount;
    if (description != null) map['description'] = description;
    if (category != null) map['category'] = category;
    if (date != null) map['date'] = date;
    if (accountId != null) map['account_id'] = accountId;
    if (reference != null) map['reference'] = reference;
    return map;
  }
}

/// Request payload for `POST /api/v1/payments/create-order`.
class CreateGatewayOrderRequest {
  final double amount;
  final String orderId;
  final String currency;

  CreateGatewayOrderRequest({
    required this.amount,
    required this.orderId,
    this.currency = 'INR',
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'orderId': orderId,
        'currency': currency,
      };
}
