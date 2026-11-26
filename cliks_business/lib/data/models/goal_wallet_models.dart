import 'package:flutter/foundation.dart';

/// Represents a single allocation transaction in a Segregation / Goal Wallet.
@immutable
class GoalWalletTransaction {
  final String id;
  final String walletId;
  final String? userId;
  final double amount;
  final String type;
  final DateTime? createdAt;

  const GoalWalletTransaction({
    required this.id,
    required this.walletId,
    this.userId,
    required this.amount,
    required this.type,
    this.createdAt,
  });

  factory GoalWalletTransaction.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) {
        return double.tryParse(val.replaceAll(',', '').trim()) ?? 0.0;
      }
      return 0.0;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String && val.trim().isNotEmpty) {
        return DateTime.tryParse(val.trim());
      }
      return null;
    }

    return GoalWalletTransaction(
      id: (json['id'] ?? '').toString(),
      walletId: (json['wallet_id'] ?? json['walletId'] ?? '').toString(),
      userId: json['user_id']?.toString(),
      amount: parseDouble(json['amount']),
      type: (json['type'] ?? 'credit').toString().toLowerCase(),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      if (userId != null) 'user_id': userId,
      'amount': amount,
      'type': type,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get formattedDate {
    if (createdAt == null) return '';
    return formatLedgerDate(createdAt!.toLocal());
  }

  static String formatLedgerDate(DateTime dt) {
    final day = dt.day;
    final month = _months[dt.month - 1];
    final year = dt.year;
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final hourStr = hour12.toString().padLeft(2, '0');
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '$day $month $year, $hourStr:$minuteStr $ampm';
  }

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
}

/// Represents a single Segregation / Goal Wallet.
@immutable
class GoalWallet {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double? claimedAmount;
  final String description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<GoalWalletTransaction> transactions;

  const GoalWallet({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.claimedAmount,
    this.description = '',
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.transactions = const [],
  });

  /// Factory constructor to safely parse JSON from the backend.
  factory GoalWallet.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) {
        final parsed = double.tryParse(val.replaceAll(',', '').trim());
        return parsed ?? 0.0;
      }
      return 0.0;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String && val.trim().isNotEmpty) {
        return DateTime.tryParse(val.trim());
      }
      return null;
    }

    List<GoalWalletTransaction> parseTransactions(dynamic val) {
      if (val == null || val is! List) return const [];
      return val
          .whereType<Map>()
          .map(
            (item) =>
                GoalWalletTransaction.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    final rawId = json['id'] ?? json['_id'] ?? json['wallet_id'] ?? '';
    final rawName = json['name'] ?? json['title'] ?? json['wallet_name'] ?? '';
    final rawDesc = json['description'] ?? json['notes'] ?? json['desc'] ?? '';
    final rawStatus = (json['status'] ?? 'active')
        .toString()
        .toLowerCase()
        .trim();

    return GoalWallet(
      id: rawId.toString(),
      name: rawName.toString().trim().isNotEmpty
          ? rawName.toString().trim()
          : 'Purpose Wallet',
      targetAmount: parseDouble(
        json['target_amount'] ?? json['targetAmount'] ?? json['target'],
      ),
      currentAmount: parseDouble(
        json['current_amount'] ??
            json['currentAmount'] ??
            json['saved'] ??
            json['balance'],
      ),
      claimedAmount: json['claimed_amount'] != null
          ? parseDouble(json['claimed_amount'])
          : null,
      description: rawDesc.toString().trim(),
      status: rawStatus.isNotEmpty ? rawStatus : 'active',
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
      transactions: parseTransactions(json['transactions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      if (claimedAmount != null) 'claimed_amount': claimedAmount,
      'description': description,
      'status': status,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  /// Converts to Map compatible with UI state.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': name,
      'name': name,
      'status': statusDisplay,
      'rawStatus': status,
      'saved': currentAmount,
      'target': targetAmount,
      'current_amount': currentAmount,
      'target_amount': targetAmount,
      'notes': description,
      'description': description,
      'isClaimed': isClaimed,
      'createdAt': createdAt,
    };
  }

  GoalWallet copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    double? claimedAmount,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<GoalWalletTransaction>? transactions,
  }) {
    return GoalWallet(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      claimedAmount: claimedAmount ?? this.claimedAmount,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactions: transactions ?? this.transactions,
    );
  }

  // ── Business Logic & UI Helpers ──────────────────────────────────────────

  bool get isClaimed =>
      status.toLowerCase() == 'claimed' || status.toLowerCase() == 'completed';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isTargetMet =>
      !isClaimed && (currentAmount >= targetAmount && targetAmount > 0);
  bool get isInProgress => !isClaimed && !isTargetMet;

  String get statusDisplay {
    if (isClaimed) return 'FULLY CLAIMED';
    if (isTargetMet) return 'TARGET MET';
    return 'IN PROGRESS';
  }

  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  double get progressRatio =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  int get progressPercent {
    if (targetAmount <= 0) {
      return currentAmount > 0 ? 100 : 0;
    }
    final raw = (currentAmount / targetAmount) * 100;
    if (raw.isNaN || raw.isInfinite) return 0;
    return raw.clamp(0, 9999).round();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalWallet &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          targetAmount == other.targetAmount &&
          currentAmount == other.currentAmount &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(id, name, targetAmount, currentAmount, status);
}

/// DTO for POST /api/v1/goal-wallets
class CreateGoalWalletRequest {
  final String name;
  final double targetAmount;
  final String? description;

  const CreateGoalWalletRequest({
    required this.name,
    required this.targetAmount,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name.trim(),
      'target_amount': targetAmount,
    };
    if (description != null && description!.trim().isNotEmpty) {
      map['description'] = description!.trim();
    }
    return map;
  }
}

/// DTO for PATCH /api/v1/goal-wallets/:id
class UpdateGoalWalletRequest {
  final String? name;
  final double? targetAmount;
  final String? description;

  const UpdateGoalWalletRequest({
    this.name,
    this.targetAmount,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null && name!.trim().isNotEmpty) {
      map['name'] = name!.trim();
    }
    if (targetAmount != null && targetAmount! > 0) {
      map['target_amount'] = targetAmount;
    }
    if (description != null) {
      map['description'] = description!.trim();
    }
    return map;
  }
}

/// DTO for POST /api/v1/goal-wallets/:id/add-money
class AddMoneyGoalWalletRequest {
  final double amount;

  const AddMoneyGoalWalletRequest({required this.amount});

  Map<String, dynamic> toJson() {
    return {'amount': amount};
  }
}
