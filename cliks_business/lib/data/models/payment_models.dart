/// Representation of a Bank or Cash Account returned by `/api/v1/payments/reports`.
class PaymentAccount {
  final dynamic id; // Can be int or string (e.g. "cash-register")
  final dynamic bankAccountId;
  final String bankName;
  final String bankAccountName;
  final String? accountHolderName;
  final String accountNumber;
  final String? ifscCode;
  final String? branchName;
  final double currentBalance;
  final String type; // 'bank' or 'cash'
  final String status;

  PaymentAccount({
    required this.id,
    this.bankAccountId,
    required this.bankName,
    required this.bankAccountName,
    this.accountHolderName,
    required this.accountNumber,
    this.ifscCode,
    this.branchName,
    required this.currentBalance,
    required this.type,
    required this.status,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) {
    final rawBalance = json['current_balance'] ?? json['balance'] ?? json['currentBalance'];
    final bal = (rawBalance is num)
        ? rawBalance.toDouble()
        : double.tryParse(rawBalance?.toString() ?? '') ?? 0.0;

    return PaymentAccount(
      id: json['id'] ?? json['bank_account_id'] ?? json['bankAccountId'],
      bankAccountId: json['bank_account_id'] ?? json['bankAccountId'] ?? json['id'],
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString() ?? 'Bank Account',
      bankAccountName: json['bank_account_name']?.toString() ??
          json['bankAccountName']?.toString() ??
          json['bank_name']?.toString() ??
          'Account',
      accountHolderName: json['account_holder']?.toString() ?? json['accountHolder']?.toString(),
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifsc_code']?.toString() ?? json['ifscCode']?.toString() ?? json['ifsc']?.toString(),
      branchName: json['branch_name']?.toString() ?? json['branchName']?.toString() ?? json['branch']?.toString(),
      currentBalance: bal,
      type: json['type']?.toString() ??
          (json['account_number']?.toString().toLowerCase().contains('cash') == true ? 'cash' : 'bank'),
      status: json['status']?.toString() ?? 'Active',
    );
  }

  bool get isCash => type.toLowerCase() == 'cash';
  bool get isActive => status.toLowerCase() == 'active' || status.isEmpty;
  String get displayName => bankAccountName.isNotEmpty ? bankAccountName : bankName;
  double get balance => currentBalance;
  String get accountHolder => accountHolderName ?? bankAccountName;
  String get accountName => bankAccountName;
  String? get ifsc => ifscCode;
  String? get branch => branchName;
  String get accountType => type;

  /// Helper to get masked account number or description
  String get displayAccountNumber {
    if (isCash) return accountNumber.isNotEmpty ? accountNumber : 'Cash Register';
    if (accountNumber.length > 4) {
      return '•••• ${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber;
  }
}

/// Ledger item representing an Inward (Receive) or Outward (Pay) transaction.
class PaymentTransaction {
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

  PaymentTransaction({
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
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json, {String defaultType = 'receive'}) {
    final rawAmount = json['amount'];
    final rawPaid = json['paid_amount'] ?? json['paidAmount'] ?? json['paid'];
    final rawTotal = json['total_original'] ??
        json['totalOriginalAmount'] ??
        json['total_original_amount'] ??
        json['total'] ??
        json['amount'];
    final rawPending = json['pending_amount'] ?? json['pendingAmount'];

    double parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final amt = parseNum(rawAmount);
    final paid = parseNum(rawPaid != null && parseNum(rawPaid) > 0 ? rawPaid : rawAmount);
    final total = parseNum(rawTotal != null && parseNum(rawTotal) > 0 ? rawTotal : (paid > 0 ? paid : amt));
    final pending = rawPending != null ? parseNum(rawPending) : (total - paid > 0 ? total - paid : 0.0);

    final party = json['party_name']?.toString() ??
        json['customer_name']?.toString() ??
        json['customerProfile']?.toString() ??
        json['customer']?.toString() ??
        json['supplier_name']?.toString() ??
        json['supplierProfile']?.toString() ??
        json['client_name']?.toString() ??
        'General Party';

    final inv = json['invoice_id']?.toString() ??
        json['invoiceLinkedId']?.toString() ??
        json['invoice_number']?.toString() ??
        json['invoice']?.toString();

    final pur = json['purchase_id']?.toString() ??
        json['purchaseLinkedId']?.toString() ??
        json['purchase']?.toString();

    DateTime? date;
    final rawDate = json['created_at'] ?? json['payment_date'] ?? json['date'];
    if (rawDate != null) {
      date = DateTime.tryParse(rawDate.toString());
    }

    final rawStatus = json['status']?.toString() ?? (paid >= total && total > 0 ? 'completed' : 'pending');
    final rawReconciliation = json['reconciliation_status']?.toString() ??
        (paid >= total && total > 0 ? 'matched' : (rawStatus.toLowerCase() == 'completed' ? 'matched' : 'pending'));

    return PaymentTransaction(
      id: json['id']?.toString() ?? 'REC-${DateTime.now().millisecondsSinceEpoch}',
      type: json['type']?.toString() ?? defaultType,
      partyName: party,
      amount: amt,
      paidAmount: paid,
      totalOriginal: total,
      pendingAmount: pending,
      paymentMode: json['payment_mode']?.toString() ?? json['mode']?.toString() ?? 'UPI',
      referenceNumber: json['reference_number']?.toString() ?? json['ref_id']?.toString() ?? '',
      status: rawStatus,
      reconciliationStatus: rawReconciliation,
      invoiceId: inv,
      purchaseId: pur,
      createdAt: date,
    );
  }

  String get formattedDate {
    if (createdAt != null) {
      return '${createdAt!.year}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}';
    }
    return '';
  }

  String get displayReference => invoiceId ?? purchaseId ?? (id.toString());
  String get customerName => partyName;
  String get supplierName => partyName;
  bool get isReconciled =>
      reconciliationStatus.toLowerCase() == 'matched' ||
      status.toLowerCase() == 'completed' ||
      status.toLowerCase() == 'reconciled';
}

/// Overdue invoice item from `/api/v1/payments/reports`.
class OverdueInvoice {
  final dynamic id;
  final String invoiceNumber;
  final String clientName;
  final String? clientEmail;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String? dueDate;
  final String status;

  OverdueInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    this.clientEmail,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    this.dueDate,
    required this.status,
  });

  factory OverdueInvoice.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return OverdueInvoice(
      id: json['id'],
      invoiceNumber: json['invoice_number']?.toString() ?? 'INV-${json['id']}',
      clientName: json['client_name']?.toString() ?? 'General Customer',
      clientEmail: json['client_email']?.toString(),
      totalAmount: parseNum(json['total_amount']),
      paidAmount: parseNum(json['paid_amount']),
      dueAmount: parseNum(json['due_amount']),
      dueDate: json['due_date']?.toString(),
      status: json['status']?.toString() ?? 'Overdue',
    );
  }
}

/// Unified reports response model from `GET /api/v1/payments/reports`.
class PaymentReports {
  final List<PaymentTransaction> receivables;
  final List<PaymentTransaction> payables;
  final List<PaymentAccount> accounts;
  final List<OverdueInvoice> overdueInvoices;

  PaymentReports({
    required this.receivables,
    required this.payables,
    required this.accounts,
    required this.overdueInvoices,
  });

  factory PaymentReports.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final recList = (data['receivables'] as List<dynamic>?)
            ?.map((e) => PaymentTransaction.fromJson(e as Map<String, dynamic>, defaultType: 'receive'))
            .toList() ??
        [];

    final payList = (data['payables'] as List<dynamic>?)
            ?.map((e) => PaymentTransaction.fromJson(e as Map<String, dynamic>, defaultType: 'pay'))
            .toList() ??
        [];

    final accList = (data['accounts'] as List<dynamic>?)
            ?.map((e) => PaymentAccount.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final odList = (data['overdueInvoices'] as List<dynamic>?)
            ?.map((e) => OverdueInvoice.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PaymentReports(
      receivables: recList,
      payables: payList,
      accounts: accList,
      overdueInvoices: odList,
    );
  }
}

/// Aggregated stats from `GET /api/v1/payments/outstanding`.
class OutstandingStats {
  final double receivables;
  final double payables;
  final double totalProcessed;

  OutstandingStats({
    required this.receivables,
    required this.payables,
    required this.totalProcessed,
  });

  factory OutstandingStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return OutstandingStats(
      receivables: parseNum(data['receivables']),
      payables: parseNum(data['payables']),
      totalProcessed: parseNum(data['total_processed'] ?? data['totalProcessed']),
    );
  }
}

/// Request body for `POST /api/v1/payments/receive`.
class ReceivePaymentRequest {
  final double amount;
  final String? customerName;
  final String? invoiceId;
  final String paymentMode;
  final String? referenceNumber;
  final dynamic accountId;
  final String? notes;
  final double? totalOriginalAmount;
  final double? paidAmount;

  ReceivePaymentRequest({
    required this.amount,
    this.customerName,
    this.invoiceId,
    required this.paymentMode,
    this.referenceNumber,
    this.accountId,
    this.notes,
    this.totalOriginalAmount,
    this.paidAmount,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'payment_mode': paymentMode,
    };
    if (customerName != null && customerName!.trim().isNotEmpty) {
      map['customer_name'] = customerName!.trim();
    }
    if (invoiceId != null && invoiceId!.trim().isNotEmpty) {
      map['invoice_id'] = invoiceId!.trim();
    }
    if (referenceNumber != null && referenceNumber!.trim().isNotEmpty) {
      map['reference_number'] = referenceNumber!.trim();
    }
    if (accountId != null) {
      map['account_id'] = accountId;
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    if (totalOriginalAmount != null && totalOriginalAmount! > 0) {
      map['total_original_amount'] = totalOriginalAmount;
    }
    if (paidAmount != null && paidAmount! > 0) {
      map['paid_amount'] = paidAmount;
    }
    return map;
  }
}

/// Request body for `POST /api/v1/payments/pay`.
class PaySupplierRequest {
  final double amount;
  final String? supplierName;
  final String? purchaseId;
  final String paymentMode;
  final String? referenceNumber;
  final dynamic accountId;
  final String? notes;

  PaySupplierRequest({
    required this.amount,
    this.supplierName,
    this.purchaseId,
    required this.paymentMode,
    this.referenceNumber,
    this.accountId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'payment_mode': paymentMode,
    };
    if (supplierName != null && supplierName!.trim().isNotEmpty) {
      map['supplier_name'] = supplierName!.trim();
    }
    if (purchaseId != null && purchaseId!.trim().isNotEmpty) {
      map['purchase_id'] = purchaseId!.trim();
    }
    if (referenceNumber != null && referenceNumber!.trim().isNotEmpty) {
      map['reference_number'] = referenceNumber!.trim();
    }
    if (accountId != null) {
      map['account_id'] = accountId;
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

/// Request body for `POST /api/v1/payments/transfer` (Internal vault / account transfer).
class AccountTransferRequest {
  final dynamic fromAccountId;
  final dynamic toAccountId;
  final double amount;

  AccountTransferRequest({
    dynamic fromAccountId,
    dynamic toAccountId,
    dynamic fromAccId,
    dynamic toAccId,
    required this.amount,
  })  : fromAccountId = fromAccountId ?? fromAccId,
        toAccountId = toAccountId ?? toAccId;

  Map<String, dynamic> toJson() => {
    'from_acc_id': fromAccountId,
    'to_acc_id': toAccountId,
    'amount': amount,
  };
}

/// Request body for `POST /api/v1/payments/create-order` (Cashfree / UPI checkout).
class CreatePaymentOrderRequest {
  final double amount;
  final String orderId;
  final String currency;

  CreatePaymentOrderRequest({
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

/// Representation of an Invoice Payment from `/api/v1/billing/:id/payments`.
class InvoicePayment {
  final dynamic id;
  final dynamic invoiceId;
  final double amount;
  final String paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final String? paymentDate;

  InvoicePayment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.paymentDate,
  });

  factory InvoicePayment.fromJson(Map<String, dynamic> json) {
    return InvoicePayment(
      id: json['id'],
      invoiceId: json['invoice_id'] ?? json['invoiceId'],
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      paymentMethod: (json['payment_method'] ?? json['paymentMethod'] ?? 'UPI').toString(),
      referenceNumber: json['reference_number']?.toString() ?? json['referenceNumber']?.toString(),
      notes: json['notes']?.toString(),
      paymentDate: json['payment_date']?.toString() ?? json['paymentDate']?.toString(),
    );
  }
}

/// Request body for `POST /api/v1/billing/:id/payments`.
class RecordInvoicePaymentRequest {
  final double amount;
  final String paymentMethod;
  final dynamic accountId;
  final String? referenceNumber;
  final String? notes;

  RecordInvoicePaymentRequest({
    required this.amount,
    String? paymentMethod,
    String? paymentMode,
    this.accountId,
    this.referenceNumber,
    this.notes,
  }) : paymentMethod = paymentMethod ?? paymentMode ?? 'UPI';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'amount': amount,
      'payment_method': paymentMethod,
    };
    if (accountId != null) {
      map['account_id'] = accountId;
    }
    if (referenceNumber != null && referenceNumber!.trim().isNotEmpty) {
      map['reference_number'] = referenceNumber!.trim();
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

/// Representation of a Purchase Payment from `/api/v1/purchases/:id/payments`.
class PurchasePayment {
  final String? purchaseId;
  final double paidAmount;
  final String paymentMode;
  final String paymentStatus;

  PurchasePayment({
    this.purchaseId,
    required this.paidAmount,
    required this.paymentMode,
    required this.paymentStatus,
  });

  double get amount => paidAmount;

  factory PurchasePayment.fromJson(Map<String, dynamic> json) {
    return PurchasePayment(
      purchaseId: json['purchase_id']?.toString() ?? json['purchaseId']?.toString(),
      paidAmount: ((json['paid_amount'] ?? json['paidAmount'] ?? json['amount'] ?? 0) as num).toDouble(),
      paymentMode: (json['payment_mode'] ?? json['paymentMode'] ?? 'Bank Transfer').toString(),
      paymentStatus: (json['payment_status'] ?? json['paymentStatus'] ?? 'completed').toString(),
    );
  }
}

/// Request body for `POST /api/v1/purchases/:id/payments`.
class RecordPurchasePaymentRequest {
  final double paidAmount;
  final String paymentMode;
  final dynamic accountId;
  final String? referenceNumber;
  final String? notes;

  RecordPurchasePaymentRequest({
    double? paidAmount,
    double? amount,
    required this.paymentMode,
    this.accountId,
    this.referenceNumber,
    this.notes,
  }) : paidAmount = paidAmount ?? amount ?? 0.0;

  double get amount => paidAmount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'paid_amount': paidAmount,
      'payment_mode': paymentMode,
    };
    if (accountId != null) {
      map['account_id'] = accountId;
    }
    if (referenceNumber != null && referenceNumber!.trim().isNotEmpty) {
      map['reference_number'] = referenceNumber!.trim();
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

/// Representation of a Planned or Scheduled Payment from `/api/v1/planned-payments`.
class PlannedPayment {
  final dynamic id;
  final String name;
  final double amount;
  final String dueDate;
  final String status;
  final String frequency;
  final String category;
  final String type; // 'bill', 'expense', 'subscription', 'loan'
  final String? description;
  final dynamic accountId;
  final dynamic personId;
  final String? personName;
  final String? createdAt;
  final String? updatedAt;

  PlannedPayment({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    this.status = 'pending',
    this.frequency = 'monthly',
    this.category = 'General',
    this.type = 'bill',
    this.description,
    this.accountId,
    this.personId,
    this.personName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isSend => type.toLowerCase() != 'receive';

  factory PlannedPayment.fromJson(Map<String, dynamic> json) {
    return PlannedPayment(
      id: json['id'],
      name: (json['name'] ?? 'Scheduled Item').toString(),
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      dueDate: (json['due_date'] ?? json['dueDate'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      frequency: (json['frequency'] ?? 'monthly').toString(),
      category: (json['category'] ?? 'General').toString(),
      type: (json['type'] ?? 'bill').toString(),
      description: json['description']?.toString(),
      accountId: json['account_id'] ?? json['accountId'],
      personId: json['person_id'] ?? json['personId'],
      personName: json['person_name']?.toString() ?? json['personName']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'due_date': dueDate,
    'status': status,
    'frequency': frequency,
    'category': category,
    'type': type,
    if (description != null) 'description': description,
    if (accountId != null) 'account_id': accountId,
    if (personId != null) 'person_id': personId,
    if (personName != null) 'person_name': personName,
  };
}

/// Request body for `POST /api/v1/planned-payments`.
class CreatePlannedPaymentRequest {
  final String name;
  final double amount;
  final String dueDate;
  final dynamic accountId;
  final String frequency;
  final String category;
  final String type;
  final String? description;

  CreatePlannedPaymentRequest({
    required this.name,
    required this.amount,
    required this.dueDate,
    this.accountId,
    this.frequency = 'monthly',
    this.category = 'General',
    this.type = 'bill',
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'amount': amount,
      'due_date': dueDate,
      'frequency': frequency,
      'category': category,
      'type': type,
    };
    if (accountId != null) map['account_id'] = accountId;
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    return map;
  }
}

/// Request body for `POST /api/v1/bank-accounts`.
class CreateBankAccountRequest {
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String branch;
  final double openingBalance;
  final String accountType;

  CreateBankAccountRequest({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.branch,
    this.openingBalance = 0.0,
    this.accountType = 'Current',
  });

  Map<String, dynamic> toJson() => {
    'bank_name': bankName,
    'account_holder': accountHolder,
    'account_number': accountNumber,
    'ifsc': ifsc,
    'branch': branch,
    'opening_balance': openingBalance,
    'account_type': accountType,
  };
}
