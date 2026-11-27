import 'package:flutter/material.dart';

/// Helper to safely parse doubles from int, double, or String (e.g. "4000.00", "4000", 4000).
double parseDouble(dynamic val, [double defaultValue = 0.0]) {
  if (val == null) return defaultValue;
  if (val is num) return val.toDouble();
  if (val is String) {
    final cleaned = val.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return defaultValue;
    return double.tryParse(cleaned) ?? defaultValue;
  }
  return defaultValue;
}

/// Helper to safely parse integer IDs or values.
int parseInt(dynamic val, [int defaultValue = 0]) {
  if (val == null) return defaultValue;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? defaultValue;
  }
  return defaultValue;
}

/// Helper to safely parse DateTime from dynamic strings or objects.
DateTime? parseDateTime(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) return val;
  if (val is String && val.trim().isNotEmpty) {
    return DateTime.tryParse(val.trim());
  }
  return null;
}

/// Dynamic color palette generation for avatars based on person/group name.
Color getAvatarBgColor(String name) {
  final hash = name.trim().toLowerCase().codeUnits.fold(0, (sum, c) => sum + c);
  const bgColors = [
    Color(0xFFF3E8FF), // Purple
    Color(0xFFFCE7F3), // Pink
    Color(0xFFFEF3C7), // Amber
    Color(0xFFFFE4E6), // Rose
    Color(0xFFD1FAE5), // Emerald
    Color(0xFFE0E7FF), // Indigo
    Color(0xFFCFFAFE), // Cyan
    Color(0xFFDCFCE7), // Green
  ];
  return bgColors[hash % bgColors.length];
}

Color getAvatarFgColor(String name) {
  final hash = name.trim().toLowerCase().codeUnits.fold(0, (sum, c) => sum + c);
  const fgColors = [
    Color(0xFF7C3AED), // Purple
    Color(0xFFDB2777), // Pink
    Color(0xFFD97706), // Amber
    Color(0xFFE11D48), // Rose
    Color(0xFF059669), // Emerald
    Color(0xFF4F46E5), // Indigo
    Color(0xFF0891B2), // Cyan
    Color(0xFF15803D), // Green
  ];
  return fgColors[hash % fgColors.length];
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. PERSON CONTACT MODEL
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class PersonContact {
  final int id;
  final int? userId;
  final String name;
  final String roleType;
  final String? relationship;
  final String phone;
  final String email;
  final String? company;
  final String? notes;
  final String status;
  final double totalLent;
  final double totalBorrowed;
  final double netBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PersonTransaction> transactions;
  final List<RepaymentAlert> repaymentAlerts;

  const PersonContact({
    required this.id,
    this.userId,
    required this.name,
    required this.roleType,
    this.relationship,
    required this.phone,
    required this.email,
    this.company,
    this.notes,
    this.status = 'active',
    this.totalLent = 0.0,
    this.totalBorrowed = 0.0,
    this.netBalance = 0.0,
    this.createdAt,
    this.updatedAt,
    this.transactions = const [],
    this.repaymentAlerts = const [],
  });

  factory PersonContact.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'];
    final txList = <PersonTransaction>[];
    if (rawTransactions is List) {
      for (final item in rawTransactions) {
        if (item is Map) {
          txList.add(PersonTransaction.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawAlerts = json['repaymentAlerts'] ?? json['reminders'];
    final alertList = <RepaymentAlert>[];
    if (rawAlerts is List) {
      for (final item in rawAlerts) {
        if (item is Map) {
          alertList.add(RepaymentAlert.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final contactId = parseInt(json['id']);
    final lent = parseDouble(json['total_lent'] ?? json['totalLent']);
    final borrowed = parseDouble(json['total_borrowed'] ?? json['totalBorrowed']);
    final balance = parseDouble(json['net_balance'] ?? json['netBalance'], lent - borrowed);

    return PersonContact(
      id: contactId,
      userId: json['user_id'] != null ? parseInt(json['user_id']) : null,
      name: (json['name'] ?? '').toString().trim(),
      roleType: (json['role_type'] ?? json['roleType'] ?? 'Friend').toString().trim(),
      relationship: json['relationship']?.toString().trim(),
      phone: (json['phone'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      company: json['company']?.toString().trim(),
      notes: json['notes']?.toString().trim(),
      status: (json['status'] ?? 'active').toString().trim().toLowerCase(),
      totalLent: lent,
      totalBorrowed: borrowed,
      netBalance: balance,
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
      transactions: txList,
      repaymentAlerts: alertList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'role_type': roleType,
      if (relationship != null) 'relationship': relationship,
      'phone': phone,
      'email': email,
      if (company != null) 'company': company,
      if (notes != null) 'notes': notes,
      'status': status,
      'total_lent': totalLent,
      'total_borrowed': totalBorrowed,
      'net_balance': netBalance,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'repaymentAlerts': repaymentAlerts.map((a) => a.toJson()).toList(),
    };
  }

  PersonContact copyWith({
    int? id,
    int? userId,
    String? name,
    String? roleType,
    String? relationship,
    String? phone,
    String? email,
    String? company,
    String? notes,
    String? status,
    double? totalLent,
    double? totalBorrowed,
    double? netBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PersonTransaction>? transactions,
    List<RepaymentAlert>? repaymentAlerts,
  }) {
    return PersonContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      roleType: roleType ?? this.roleType,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      totalLent: totalLent ?? this.totalLent,
      totalBorrowed: totalBorrowed ?? this.totalBorrowed,
      netBalance: netBalance ?? this.netBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactions: transactions ?? this.transactions,
      repaymentAlerts: repaymentAlerts ?? this.repaymentAlerts,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Color get avatarBg => getAvatarBgColor(name);
  Color get avatarColor => getAvatarFgColor(name);

  String get displayCompany => (company != null && company!.isNotEmpty) ? company! : '-';

  String get classification => (relationship != null && relationship!.isNotEmpty)
      ? relationship!.toUpperCase()
      : roleType.toUpperCase();

  bool get isConnected => status == 'accepted' || status == 'connected' || status == 'active';

  String get formattedPhone {
    if (phone.trim().isEmpty || phone.trim() == 'N/A') return 'N/A';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return phone;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. PEOPLE SUMMARY METRICS
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class PeopleSummary {
  final int totalContacts;
  final double totalReceivables;
  final double totalPayables;
  final double totalLent;
  final double totalBorrowed;

  const PeopleSummary({
    this.totalContacts = 0,
    this.totalReceivables = 0.0,
    this.totalPayables = 0.0,
    this.totalLent = 0.0,
    this.totalBorrowed = 0.0,
  });

  factory PeopleSummary.fromJson(Map<String, dynamic> json) {
    return PeopleSummary(
      totalContacts: parseInt(json['total_contacts'] ?? json['totalContacts']),
      totalReceivables: parseDouble(json['total_receivables'] ?? json['totalReceivables']),
      totalPayables: parseDouble(json['total_payables'] ?? json['totalPayables']),
      totalLent: parseDouble(json['total_lent'] ?? json['totalLent']),
      totalBorrowed: parseDouble(json['total_borrowed'] ?? json['totalBorrowed']),
    );
  }

  factory PeopleSummary.fromContacts(List<PersonContact> contacts) {
    double receivables = 0.0;
    double payables = 0.0;
    double lent = 0.0;
    double borrowed = 0.0;

    for (final c in contacts) {
      lent += c.totalLent;
      borrowed += c.totalBorrowed;
      if (c.netBalance > 0) {
        receivables += c.netBalance;
      } else if (c.netBalance < 0) {
        payables += c.netBalance.abs();
      }
    }

    return PeopleSummary(
      totalContacts: contacts.length,
      totalReceivables: receivables,
      totalPayables: payables,
      totalLent: lent,
      totalBorrowed: borrowed,
    );
  }

  /// Safe calculation of collection percentage: (repaid / total) * 100
  /// Handled safely without zero division.
  double get collectionPercentage {
    if (totalLent <= 0) return 0.0;
    final received = (totalLent - totalReceivables).clamp(0.0, totalLent);
    return (received / totalLent) * 100.0;
  }

  /// Safe calculation of settlement percentage: (paid / total) * 100
  double get settlementPercentage {
    if (totalBorrowed <= 0) return 0.0;
    final paid = (totalBorrowed - totalPayables).clamp(0.0, totalBorrowed);
    return (paid / totalBorrowed) * 100.0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. PERSON TRANSACTION MODEL (Global Ledger)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class PersonTransaction {
  final int id;
  final int personId;
  final int? userId;
  final String personName;
  final String type; // "lent" or "borrowed"
  final double amount;
  final String date;
  final String status;
  final String? notes;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PersonTransaction({
    required this.id,
    required this.personId,
    this.userId,
    required this.personName,
    required this.type,
    required this.amount,
    required this.date,
    this.status = 'active',
    this.notes,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory PersonTransaction.fromJson(Map<String, dynamic> json) {
    return PersonTransaction(
      id: parseInt(json['id']),
      personId: parseInt(json['person_id'] ?? json['personId']),
      userId: json['user_id'] != null ? parseInt(json['user_id']) : null,
      personName: (json['person_name'] ?? json['personName'] ?? '').toString().trim(),
      type: (json['type'] ?? 'lent').toString().trim().toLowerCase(),
      amount: parseDouble(json['amount']),
      date: (json['date'] ?? '').toString().trim(),
      status: (json['status'] ?? 'active').toString().trim().toLowerCase(),
      notes: (json['notes'] ?? json['description'] ?? json['memo'])?.toString().trim(),
      category: json['category']?.toString().trim(),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person_id': personId,
      if (userId != null) 'user_id': userId,
      'person_name': personName,
      'type': type,
      'amount': amount,
      'date': date,
      'status': status,
      if (notes != null) 'notes': notes,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  bool get isLent => type == 'lent';
  bool get isBorrowed => type == 'borrowed';
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. REPAYMENT ALERT MODEL
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class RepaymentAlert {
  final int id;
  final int? userId;
  final int contactId;
  final String targetContact;
  final double claimCap;
  final String maturityDate;
  final String memoLabel;
  final String status;
  final String? contactPhone;
  final DateTime? createdAt;

  const RepaymentAlert({
    required this.id,
    this.userId,
    required this.contactId,
    required this.targetContact,
    required this.claimCap,
    required this.maturityDate,
    required this.memoLabel,
    this.status = 'Pending',
    this.contactPhone,
    this.createdAt,
  });

  factory RepaymentAlert.fromJson(Map<String, dynamic> json) {
    return RepaymentAlert(
      id: parseInt(json['id']),
      userId: json['user_id'] != null ? parseInt(json['user_id']) : null,
      contactId: parseInt(json['contact_id'] ?? json['contactId'] ?? json['person_id'] ?? json['personId']),
      targetContact: (json['target_contact'] ?? json['targetContact'] ?? json['person_name'] ?? json['personName'] ?? '').toString().trim(),
      claimCap: parseDouble(json['claim_cap'] ?? json['claimCap'] ?? json['amount']),
      maturityDate: (json['maturity_date'] ?? json['maturityDate'] ?? json['due_date'] ?? json['dueDate'] ?? json['date'] ?? '').toString().trim(),
      memoLabel: (json['memo_label'] ?? json['memoLabel'] ?? json['title'] ?? json['memo'] ?? '').toString().trim(),
      status: (json['status'] ?? 'Pending').toString().trim(),
      contactPhone: json['contact_phone']?.toString().trim(),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'contact_id': contactId,
      'target_contact': targetContact,
      'claim_cap': claimCap,
      'maturity_date': maturityDate,
      'memo_label': memoLabel,
      'status': status,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  bool get isSettled => status.trim().toLowerCase() == 'settled';
  bool get isPending => status.trim().toLowerCase() == 'pending';
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. CONNECTION REQUEST MODEL
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ConnectionRequest {
  final int id;
  final int fromUserId;
  final String fromName;
  final String fromEmail;
  final DateTime? createdAt;

  const ConnectionRequest({
    required this.id,
    required this.fromUserId,
    required this.fromName,
    required this.fromEmail,
    this.createdAt,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: parseInt(json['id']),
      fromUserId: parseInt(json['from_user_id'] ?? json['fromUserId']),
      fromName: (json['from_name'] ?? json['fromName'] ?? '').toString().trim(),
      fromEmail: (json['from_email'] ?? json['fromEmail'] ?? '').toString().trim(),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'from_name': fromName,
      'from_email': fromEmail,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5B. GROUP INVITATION MODEL (Incoming Financial Group Requests)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class GroupInvitation {
  final int membershipId;
  final int groupId;
  final String groupName;
  final String groupType;
  final String? groupDescription;
  final String? inviterBusinessName;
  final String? inviterUsername;
  final String? inviterEmail;
  final String role;
  final double targetAmount;
  final String currency;
  final DateTime? createdAt;

  const GroupInvitation({
    required this.membershipId,
    required this.groupId,
    required this.groupName,
    this.groupType = 'syndicate',
    this.groupDescription,
    this.inviterBusinessName,
    this.inviterUsername,
    this.inviterEmail,
    this.role = 'member',
    this.targetAmount = 0.0,
    this.currency = 'INR',
    this.createdAt,
  });

  factory GroupInvitation.fromJson(Map<String, dynamic> json) {
    return GroupInvitation(
      membershipId: parseInt(json['membership_id'] ?? json['membershipId'] ?? json['id']),
      groupId: parseInt(json['group_id'] ?? json['groupId'] ?? json['id']),
      groupName: (json['group_name'] ?? json['groupName'] ?? json['name'] ?? json['title'] ?? '').toString().trim(),
      groupType: (json['group_type'] ?? json['groupType'] ?? 'syndicate').toString().trim(),
      groupDescription: json['group_description']?.toString().trim() ?? json['description']?.toString().trim(),
      inviterBusinessName: json['inviter_business_name']?.toString().trim(),
      inviterUsername: json['inviter_username']?.toString().trim(),
      inviterEmail: json['inviter_email']?.toString().trim(),
      role: (json['role'] ?? 'member').toString().trim(),
      targetAmount: parseDouble(json['target_amount'] ?? json['targetAmount']),
      currency: (json['currency'] ?? 'INR').toString().trim(),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  String get inviterName =>
      inviterBusinessName ?? (inviterUsername ?? (inviterEmail ?? 'Partner'));

  String get inviterDisplayEmail => inviterEmail ?? 'partner@bnxmail.com';

  FinancialGroup toFinancialGroup() {
    return FinancialGroup(
      id: groupId,
      membershipId: membershipId,
      name: groupName,
      description: groupDescription,
      groupType: groupType,
      currency: currency,
      targetAmount: targetAmount,
      myRole: role,
      myMembershipStatus: 'pending',
      invitedByName: inviterName,
      invitedByEmail: inviterDisplayEmail,
      createdAt: createdAt,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. FINANCIAL GROUP MODEL
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class FinancialGroup {
  final int id;
  final int? membershipId;
  final int? createdBy;
  final String name;
  final String? description;
  final String groupType;
  final String currency;
  final double targetAmount;
  final String status;
  final String? myRole;
  final String? myMembershipStatus;
  final int memberCount;
  final int pendingMemberCount;
  final int totalMembers;
  final double totalContributed;
  final double totalExpenses;
  final double totalLoans;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<GroupMember> members;
  final List<GroupTransaction> transactions;
  final String? invitedByName;
  final String? invitedByEmail;

  const FinancialGroup({
    required this.id,
    this.membershipId,
    this.createdBy,
    required this.name,
    this.description,
    this.groupType = 'syndicate',
    this.currency = 'INR',
    this.targetAmount = 0.0,
    this.status = 'active',
    this.myRole,
    this.myMembershipStatus,
    this.memberCount = 0,
    this.pendingMemberCount = 0,
    this.totalMembers = 0,
    this.totalContributed = 0.0,
    this.totalExpenses = 0.0,
    this.totalLoans = 0.0,
    this.createdAt,
    this.updatedAt,
    this.members = const [],
    this.transactions = const [],
    this.invitedByName,
    this.invitedByEmail,
  });

  factory FinancialGroup.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    final memberList = <GroupMember>[];
    if (rawMembers is List) {
      for (final m in rawMembers) {
        if (m is Map) {
          memberList.add(GroupMember.fromJson(Map<String, dynamic>.from(m)));
        }
      }
    }

    final rawTx = json['transactions'];
    final txList = <GroupTransaction>[];
    if (rawTx is List) {
      for (final t in rawTx) {
        if (t is Map) {
          txList.add(GroupTransaction.fromJson(Map<String, dynamic>.from(t)));
        }
      }
    }

    final target = parseDouble(json['target_amount'] ?? json['targetAmount']);
    final contributed = parseDouble(json['total_contributed'] ?? json['totalContributed'] ?? json['summary']?['total_contributed']);
    final expenses = parseDouble(json['total_expenses'] ?? json['totalExpenses'] ?? json['summary']?['total_expenses']);
    final loans = parseDouble(json['total_loans'] ?? json['totalLoans'] ?? json['summary']?['total_loans']);

    final mCount = parseInt(json['member_count'] ?? json['memberCount'], memberList.where((m) => m.isAccepted).length);
    final pCount = parseInt(json['pending_member_count'] ?? json['pendingMemberCount'], memberList.where((m) => !m.isAccepted).length);
    final totCount = parseInt(json['total_members'] ?? json['totalMembers'], memberList.length);

    final invByName = json['invited_by_name']?.toString() ??
        json['created_by_name']?.toString() ??
        json['creator']?['name']?.toString() ??
        json['invited_by']?['name']?.toString();
    final invByEmail = json['invited_by_email']?.toString() ??
        json['created_by_email']?.toString() ??
        json['creator']?['email']?.toString() ??
        json['invited_by']?['email']?.toString();

    final adminMember = memberList.where((m) => m.role == 'admin').firstOrNull;
    final finalInvName = invByName ?? adminMember?.name;
    final finalInvEmail = invByEmail ?? adminMember?.email;

    final mId = json['membership_id'] != null
        ? parseInt(json['membership_id'])
        : (json['my_membership']?['id'] != null ? parseInt(json['my_membership']['id']) : null);

    return FinancialGroup(
      id: parseInt(json['id']),
      membershipId: mId,
      createdBy: json['created_by'] != null ? parseInt(json['created_by']) : null,
      name: (json['name'] ?? json['title'] ?? '').toString().trim(),
      description: json['description']?.toString().trim(),
      groupType: (json['group_type'] ?? json['groupType'] ?? json['category'] ?? 'syndicate').toString().trim(),
      currency: (json['currency'] ?? 'INR').toString().trim(),
      targetAmount: target,
      status: (json['status'] ?? 'active').toString().trim().toLowerCase(),
      myRole: json['my_role']?.toString().trim() ?? json['my_membership']?['role']?.toString().trim(),
      myMembershipStatus: json['my_membership_status']?.toString().trim() ?? json['my_membership']?['status']?.toString().trim(),
      memberCount: mCount > 0 ? mCount : totCount,
      pendingMemberCount: pCount,
      totalMembers: totCount > 0 ? totCount : (mCount + pCount),
      totalContributed: contributed,
      totalExpenses: expenses,
      totalLoans: loans,
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
      members: memberList,
      transactions: txList,
      invitedByName: finalInvName,
      invitedByEmail: finalInvEmail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (membershipId != null) 'membership_id': membershipId,
      if (createdBy != null) 'created_by': createdBy,
      'name': name,
      if (description != null) 'description': description,
      'group_type': groupType,
      'currency': currency,
      'target_amount': targetAmount,
      'status': status,
      if (myRole != null) 'my_role': myRole,
      if (myMembershipStatus != null) 'my_membership_status': myMembershipStatus,
      'member_count': memberCount,
      'pending_member_count': pendingMemberCount,
      'total_members': totalMembers,
      'total_contributed': totalContributed,
      'total_expenses': totalExpenses,
      'total_loans': totalLoans,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (invitedByName != null) 'invited_by_name': invitedByName,
      if (invitedByEmail != null) 'invited_by_email': invitedByEmail,
      'members': members.map((m) => m.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  bool get isRejectedOrDeclined {
    final s = (myMembershipStatus ?? '').toLowerCase().trim();
    final st = status.toLowerCase().trim();
    return s == 'rejected' || s == 'declined' || st == 'rejected' || st == 'declined';
  }

  bool get isPendingInvitation {
    if (isRejectedOrDeclined) return false;
    final s = (myMembershipStatus ?? '').toLowerCase().trim();
    final st = status.toLowerCase().trim();
    return s == 'pending' || st == 'pending_invite' || st == 'invited';
  }

  bool get isAcceptedMember {
    final s = (myMembershipStatus ?? '').toLowerCase().trim();
    final r = (myRole ?? '').toLowerCase().trim();
    return s == 'accepted' ||
        r == 'admin' ||
        r == 'owner' ||
        r == 'creator' ||
        (createdBy != null && myMembershipStatus == null);
  }

  double get completionPercentage {
    if (targetAmount <= 0) return 0.0;
    return ((totalContributed / targetAmount) * 100).clamp(0.0, 100.0);
  }

  double get netFundInHand => (totalContributed - totalExpenses).clamp(0.0, double.infinity);

  double get totalPrivateMoneyToGive {
    double sum = 0.0;
    for (final m in members) {
      if (m.privateNote != null && m.privateNote!.amount > 0) {
        sum += m.privateNote!.amount;
      }
    }
    return sum;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. GROUP MEMBER & PRIVATE NOTE MODELS
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class GroupPrivateNote {
  final int? id;
  final int? groupId;
  final int? memberId;
  final double amount;
  final String notes;
  final DateTime? updatedAt;

  const GroupPrivateNote({
    this.id,
    this.groupId,
    this.memberId,
    this.amount = 0.0,
    this.notes = '',
    this.updatedAt,
  });

  factory GroupPrivateNote.fromJson(Map<String, dynamic> json) {
    return GroupPrivateNote(
      id: json['id'] != null ? parseInt(json['id']) : null,
      groupId: json['group_id'] != null ? parseInt(json['group_id']) : null,
      memberId: json['member_id'] != null ? parseInt(json['member_id']) : null,
      amount: parseDouble(json['amount']),
      notes: (json['notes'] ?? json['note'] ?? '').toString().trim(),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (memberId != null) 'member_id': memberId,
      'amount': amount,
      'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

@immutable
class GroupMember {
  final int id;
  final int groupId;
  final int? userId;
  final String email;
  final String name;
  final String role; // "admin", "member", "manager"
  final String status; // "accepted", "pending"
  final int? invitedBy;
  final GroupPrivateNote? privateNote;
  final double totalContributed;
  final double totalPaid;
  final double totalOwed;
  final double netBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GroupMember({
    required this.id,
    required this.groupId,
    this.userId,
    required this.email,
    required this.name,
    this.role = 'member',
    this.status = 'pending',
    this.invitedBy,
    this.privateNote,
    this.totalContributed = 0.0,
    this.totalPaid = 0.0,
    this.totalOwed = 0.0,
    this.netBalance = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    GroupPrivateNote? note;
    if (json['private_note'] is Map) {
      note = GroupPrivateNote.fromJson(Map<String, dynamic>.from(json['private_note']));
    }

    return GroupMember(
      id: parseInt(json['id']),
      groupId: parseInt(json['group_id'] ?? json['groupId']),
      userId: json['user_id'] != null ? parseInt(json['user_id']) : null,
      email: (json['email'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      role: (json['role'] ?? 'member').toString().trim().toLowerCase(),
      status: (json['status'] ?? 'pending').toString().trim().toLowerCase(),
      invitedBy: json['invited_by'] != null ? parseInt(json['invited_by']) : null,
      privateNote: note,
      totalContributed: parseDouble(json['total_contributed'] ?? json['contributed']),
      totalPaid: parseDouble(json['total_paid'] ?? json['totalPaid']),
      totalOwed: parseDouble(json['total_owed'] ?? json['owed']),
      netBalance: parseDouble(json['net_balance'] ?? json['netBalance']),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      if (userId != null) 'user_id': userId,
      'email': email,
      'name': name,
      'role': role,
      'status': status,
      if (invitedBy != null) 'invited_by': invitedBy,
      if (privateNote != null) 'private_note': privateNote!.toJson(),
      'total_contributed': totalContributed,
      'total_paid': totalPaid,
      'total_owed': totalOwed,
      'net_balance': netBalance,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  bool get isAccepted => status == 'accepted';
  bool get isActive => status == 'active' || status == 'accepted' || status == 'connected';
  bool get isAdmin => role == 'admin';
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. GROUP TRANSACTION MODEL
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class GroupTransaction {
  final int id;
  final int groupId;
  final int? createdBy;
  final int? paidByMemberId;
  final String? recordedBy;
  final String type; // "expense", "contribution", "loan"
  final double amount;
  final String title;
  final String? category;
  final String? splitType;
  final String? notes;
  final String? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GroupTransaction({
    required this.id,
    required this.groupId,
    this.createdBy,
    this.paidByMemberId,
    this.recordedBy,
    required this.type,
    required this.amount,
    required this.title,
    this.category,
    this.splitType,
    this.notes,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory GroupTransaction.fromJson(Map<String, dynamic> json) {
    return GroupTransaction(
      id: parseInt(json['id']),
      groupId: parseInt(json['group_id'] ?? json['groupId']),
      createdBy: json['created_by'] != null ? parseInt(json['created_by']) : null,
      paidByMemberId: json['paid_by_member_id'] != null ? parseInt(json['paid_by_member_id']) : null,
      recordedBy: (json['recorded_by'] ?? json['payer_name'] ?? json['created_by_name'] ?? json['paid_by_name'] ?? json['payer'])?.toString().trim(),
      type: (json['type'] ?? 'expense').toString().trim().toLowerCase(),
      amount: parseDouble(json['amount']),
      title: (json['title'] ?? '').toString().trim(),
      category: json['category']?.toString().trim(),
      splitType: json['split_type']?.toString().trim(),
      notes: json['notes']?.toString().trim(),
      date: json['date']?.toString().trim(),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      if (createdBy != null) 'created_by': createdBy,
      if (paidByMemberId != null) 'paid_by_member_id': paidByMemberId,
      if (recordedBy != null) 'recorded_by': recordedBy,
      'type': type,
      'amount': amount,
      'title': title,
      if (category != null) 'category': category,
      if (splitType != null) 'split_type': splitType,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. REQUEST DTOs
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class CreatePersonRequest {
  final String name;
  final String roleType;
  final String? relationship;
  final String phone;
  final String email;
  final String? company;
  final String? notes;

  const CreatePersonRequest({
    required this.name,
    required this.roleType,
    this.relationship,
    required this.phone,
    required this.email,
    this.company,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'role_type': roleType.trim(),
      if (relationship != null && relationship!.trim().isNotEmpty) 'relationship': relationship!.trim(),
      'phone': phone.replaceAll(RegExp(r'\s+'), '').trim(),
      'email': email.trim().toLowerCase(),
      if (company != null && company!.trim().isNotEmpty) 'company': company!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}

@immutable
class UpdatePersonRequest {
  final String? name;
  final String? phone;
  final String? relationship;
  final String? roleType;
  final String? company;
  final String? notes;

  const UpdatePersonRequest({
    this.name,
    this.phone,
    this.relationship,
    this.roleType,
    this.company,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null && name!.trim().isNotEmpty) map['name'] = name!.trim();
    if (phone != null && phone!.trim().isNotEmpty) map['phone'] = phone!.replaceAll(RegExp(r'\s+'), '').trim();
    if (relationship != null && relationship!.trim().isNotEmpty) map['relationship'] = relationship!.trim();
    if (roleType != null && roleType!.trim().isNotEmpty) map['role_type'] = roleType!.trim();
    if (company != null && company!.trim().isNotEmpty) map['company'] = company!.trim();
    if (notes != null && notes!.trim().isNotEmpty) map['notes'] = notes!.trim();
    return map;
  }
}

@immutable
class CreateRepaymentAlertRequest {
  final int contactId;
  final String targetContact;
  final double claimCap;
  final String maturityDate;
  final String memoLabel;
  final String status;

  const CreateRepaymentAlertRequest({
    required this.contactId,
    required this.targetContact,
    required this.claimCap,
    required this.maturityDate,
    required this.memoLabel,
    this.status = 'Pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'contact_id': contactId,
      'target_contact': targetContact.trim(),
      'claim_cap': claimCap,
      'maturity_date': maturityDate.trim(),
      'memo_label': memoLabel.trim(),
      'status': status.trim(),
    };
  }
}

@immutable
class CreateFinancialGroupRequest {
  final String name;
  final String? description;
  final String currency;
  final double targetAmount;
  final String groupType;

  const CreateFinancialGroupRequest({
    required this.name,
    this.description,
    this.currency = 'INR',
    this.targetAmount = 0.0,
    this.groupType = 'syndicate',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'title': name.trim(), // Provide both for schema compatibility
      if (description != null && description!.trim().isNotEmpty) 'description': description!.trim(),
      'currency': currency.trim(),
      'target_amount': targetAmount,
      'group_type': groupType.trim(),
    };
  }
}

@immutable
class UpdateFinancialGroupRequest {
  final String name;
  final String? description;
  final String currency;
  final double targetAmount;

  const UpdateFinancialGroupRequest({
    required this.name,
    this.description,
    this.currency = 'INR',
    this.targetAmount = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'title': name.trim(),
      if (description != null && description!.trim().isNotEmpty) 'description': description!.trim(),
      'currency': currency.trim(),
      'target_amount': targetAmount,
    };
  }
}

@immutable
class InviteGroupMemberRequest {
  final String email;
  final String role;
  final String? name;

  const InviteGroupMemberRequest({
    required this.email,
    this.role = 'member',
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'role': role.trim().toLowerCase(),
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
    };
  }
}

@immutable
class AddGroupTransactionRequest {
  final String title;
  final double amount;
  final String type; // "expense", "contribution", "loan"
  final String? category;
  final String splitType;

  const AddGroupTransactionRequest({
    required this.title,
    required this.amount,
    this.type = 'expense',
    this.category,
    this.splitType = 'equal',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'amount': amount,
      'type': type.trim().toLowerCase(),
      if (category != null && category!.trim().isNotEmpty) 'category': category!.trim(),
      'split_type': splitType.trim().toLowerCase(),
    };
  }
}

@immutable
class SetPrivateNoteRequest {
  final String note;
  final double amount;

  const SetPrivateNoteRequest({
    required this.note,
    this.amount = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'note': note.trim(),
      'notes': note.trim(), // Support both note and notes
      'amount': amount,
    };
  }
}
