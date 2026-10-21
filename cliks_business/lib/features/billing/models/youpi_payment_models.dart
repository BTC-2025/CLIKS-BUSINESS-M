
/// Status constants representing payment lifecycle in YOUPI PG V2.
class YoupiPaymentStatus {
  static const String initiated = 'INITIATED';
  static const String active = 'ACTIVE';
  static const String queued = 'QUEUED';
  static const String processing = 'PROCESSING';
  static const String success = 'SUCCESS';
  static const String failed = 'FAILED';
  static const String expired = 'EXPIRED';
  static const String cancelled = 'CANCELLED';

  static bool isTerminal(String status) {
    final s = status.toUpperCase();
    return s == success || s == failed || s == expired || s == cancelled;
  }

  static bool isPending(String status) {
    final s = status.toUpperCase();
    return s == initiated || s == active || s == queued || s == processing;
  }
}

/// Verification level returned by YOUPI PG observation mesh.
class YoupiVerificationLevel {
  static const int unverified = 0;
  static const int singleSource = 1; // e.g. Bank SMS observed
  static const int dualSource = 2;   // e.g. Dual SMS + Gmail verified
}

/// Request payload to initialize a payment session with YOUPI PG.
/// Matches OpenAPI POST /api/v1/payments contract.
class YoupiPaymentRequest {
  final String orderId;
  final String amount;
  final String currency;
  final String? description;
  final String? returnUrl;
  final YoupiCustomer? customer;
  final Map<String, dynamic>? metadata;

  const YoupiPaymentRequest({
    required this.orderId,
    required this.amount,
    this.currency = 'INR',
    this.description,
    this.returnUrl,
    this.customer,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      if (description != null) 'description': description,
      if (returnUrl != null) 'returnUrl': returnUrl,
      if (customer != null) 'customer': customer!.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Customer profile for payment session initialization.
class YoupiCustomer {
  final String? name;
  final String? email;
  final String? phoneNumber;

  const YoupiCustomer({
    this.name,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null && name!.isNotEmpty) 'name': name,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (phoneNumber != null && phoneNumber!.isNotEmpty)
        'phoneNumber': phoneNumber,
    };
  }

  factory YoupiCustomer.fromJson(Map<String, dynamic> json) {
    return YoupiCustomer(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: (json['phoneNumber'] ?? json['mobileNumber'])?.toString(),
    );
  }
}

/// Response returned by POST /api/v1/payments.
class YoupiPaymentSession {
  final String paymentId;
  final String orderId;
  final String amount;
  final String? amountPaise;
  final String currency;
  final String status;
  final int queuePosition;
  final String checkoutUrl;
  final bool activeSessionDetected;
  final String? upiUri;
  final String? payeeVpa;
  final String? payeeName;

  const YoupiPaymentSession({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    this.amountPaise,
    this.currency = 'INR',
    required this.status,
    this.queuePosition = 0,
    required this.checkoutUrl,
    this.activeSessionDetected = false,
    this.upiUri,
    this.payeeVpa,
    this.payeeName,
  });

  factory YoupiPaymentSession.fromJson(Map<String, dynamic> json) {
    return YoupiPaymentSession(
      paymentId: json['paymentId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      amountPaise: json['amountPaise']?.toString(),
      currency: json['currency']?.toString() ?? 'INR',
      status: json['status']?.toString() ?? YoupiPaymentStatus.initiated,
      queuePosition: json['queuePosition'] is num
          ? (json['queuePosition'] as num).toInt()
          : 0,
      checkoutUrl: json['checkoutUrl']?.toString() ?? '',
      activeSessionDetected: json['activeSessionDetected'] == true,
      upiUri: json['upiUri']?.toString(),
      payeeVpa: json['payeeVpa']?.toString(),
      payeeName: json['payeeName']?.toString(),
    );
  }
}

/// Response returned by GET /api/v1/payments/{id}.
class YoupiPaymentVerification {
  final String paymentId;
  final String orderId;
  final String amount;
  final String? amountPaise;
  final String currency;
  final String status;
  final String? internalStatus;
  final String? method;
  final int verificationLevel;
  final List<String> verificationSources;
  final String verificationTag;
  final DateTime? completedAt;
  final String? returnUrl;
  final Map<String, dynamic>? metadata;
  final String? utr;

  const YoupiPaymentVerification({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    this.amountPaise,
    this.currency = 'INR',
    required this.status,
    this.internalStatus,
    this.method,
    this.verificationLevel = 0,
    this.verificationSources = const [],
    this.verificationTag = 'UNVERIFIED',
    this.completedAt,
    this.returnUrl,
    this.metadata,
    this.utr,
  });

  bool get isSuccess => status.toUpperCase() == YoupiPaymentStatus.success;

  bool get isAuthoritativelyVerified =>
      isSuccess && (verificationLevel > 0 || verificationTag != 'UNVERIFIED');

  bool get isFailed => status.toUpperCase() == YoupiPaymentStatus.failed;
  bool get isExpired => status.toUpperCase() == YoupiPaymentStatus.expired;
  bool get isCancelled => status.toUpperCase() == YoupiPaymentStatus.cancelled;
  bool get isPending => YoupiPaymentStatus.isPending(status);

  factory YoupiPaymentVerification.fromJson(Map<String, dynamic> json) {
    List<String> sources = [];
    if (json['verificationSources'] is List) {
      sources = (json['verificationSources'] as List)
          .map((e) => e.toString())
          .toList();
    }

    DateTime? completed;
    if (json['completedAt'] != null) {
      completed = DateTime.tryParse(json['completedAt'].toString());
    }

    return YoupiPaymentVerification(
      paymentId: json['paymentId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      amountPaise: json['amountPaise']?.toString(),
      currency: json['currency']?.toString() ?? 'INR',
      status: json['status']?.toString() ?? YoupiPaymentStatus.initiated,
      internalStatus: json['internalStatus']?.toString(),
      method: json['method']?.toString(),
      verificationLevel: json['verificationLevel'] is num
          ? (json['verificationLevel'] as num).toInt()
          : 0,
      verificationSources: sources,
      verificationTag: json['verificationTag']?.toString() ?? 'UNVERIFIED',
      completedAt: completed,
      returnUrl: json['returnUrl']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      utr: json['utr']?.toString() ?? json['bankReferenceNumber']?.toString(),
    );
  }
}
