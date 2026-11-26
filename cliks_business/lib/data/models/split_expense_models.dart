/// Represents a participant in a Split Ticket.
class SplitParticipant {
  final dynamic id;
  final String name;
  final String? email;
  final String role;
  final String status;
  final bool isAdmin;
  final double shareAmount;
  final bool settled;

  SplitParticipant({
    this.id,
    required this.name,
    this.email,
    this.role = 'viewer',
    this.status = 'accepted',
    this.isAdmin = false,
    this.shareAmount = 0.0,
    this.settled = false,
  });

  bool get isCreator => isAdmin || role.toLowerCase().contains('admin');
  bool get isPending => status.toLowerCase() == 'pending';

  factory SplitParticipant.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    final rawRole = json['role']?.toString() ?? 'viewer';
    final rawAdmin = json['isAdmin'] == true ||
        rawRole.toLowerCase() == 'admin' ||
        rawRole.toLowerCase().contains('admin');
    final rawSettled = json['settled'];
    final isSettled = rawSettled == true || rawSettled == 1 || rawSettled == '1';

    return SplitParticipant(
      id: json['id'] ?? json['member_id'],
      name: json['name']?.toString() ?? json['email']?.toString() ?? 'Member',
      email: json['email']?.toString(),
      role: rawRole,
      status: json['status']?.toString() ?? 'accepted',
      isAdmin: rawAdmin,
      shareAmount: parseNum(json['share_amount'] ?? json['shareAmount'] ?? 0.0),
      settled: isSettled,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (email != null && email!.isNotEmpty) 'email': email,
        'role': role,
        'status': status,
        'isAdmin': isAdmin,
        'share_amount': shareAmount,
        'settled': settled ? 1 : 0,
      };

  Map<String, dynamic> toMap() => {
        'id': id?.toString() ?? name,
        'name': name,
        'email': email ?? '',
        'role': isAdmin ? 'Admin' : (role == 'admin' ? 'Admin' : 'View Only'),
        'isCreator': isCreator,
        'isPending': isPending,
        'shareAmount': shareAmount,
        'settled': settled,
      };
}

/// Represents an individual logged expense inside a Split Ticket.
class SplitExpenseItem {
  final String id;
  final String splitTicketId;
  final dynamic userId;
  final String title;
  final String description;
  final double amount;
  final String date;
  final String paidBy;
  final String category;
  final String splitType;
  final Map<String, double> shares;
  final dynamic attachment;
  final String? documentName;
  final String? documentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SplitExpenseItem({
    required this.id,
    this.splitTicketId = '',
    this.userId,
    required this.title,
    this.description = '',
    required this.amount,
    required this.date,
    required this.paidBy,
    this.category = 'General',
    this.splitType = 'equal',
    this.shares = const {},
    this.attachment,
    this.documentName,
    this.documentUrl,
    this.createdAt,
    this.updatedAt,
  });

  bool get isSettlement =>
      id.startsWith('exp-settle-') ||
      title.toLowerCase().startsWith('settlement') ||
      category.toLowerCase() == 'settlement';

  factory SplitExpenseItem.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    final rawShares = json['shares'];
    final sharesMap = <String, double>{};
    if (rawShares is Map) {
      rawShares.forEach((k, v) {
        sharesMap[k.toString()] = parseNum(v);
      });
    }

    final rawTitle = json['title']?.toString() ??
        json['description']?.toString() ??
        'Expense';
    final rawDesc = json['description']?.toString() ?? rawTitle;

    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    }
    DateTime? updated;
    if (json['updated_at'] != null) {
      updated = DateTime.tryParse(json['updated_at'].toString());
    }

    return SplitExpenseItem(
      id: json['id']?.toString() ??
          'exp_${DateTime.now().millisecondsSinceEpoch}',
      splitTicketId: json['split_ticket_id']?.toString() ?? '',
      userId: json['user_id'],
      title: rawTitle,
      description: rawDesc,
      amount: parseNum(json['amount']),
      date: json['date']?.toString() ??
          DateTime.now().toIso8601String().split('T').first,
      paidBy: json['paidBy']?.toString() ??
          json['paid_by']?.toString() ??
          'Admin',
      category: json['category']?.toString() ?? 'General',
      splitType: json['splitType']?.toString() ??
          json['split_type']?.toString() ??
          'equal',
      shares: sharesMap,
      attachment: json['attachment'],
      documentName: json['documentName']?.toString() ??
          json['document_name']?.toString(),
      documentUrl: json['documentUrl']?.toString() ??
          json['document_url']?.toString(),
      createdAt: created,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'split_ticket_id': splitTicketId,
        'title': title,
        'description': description,
        'amount': amount,
        'date': date,
        'paid_by': paidBy,
        'paidBy': paidBy,
        'category': category,
        'split_type': splitType,
        'splitType': splitType,
        'shares': shares,
        if (documentName != null) 'documentName': documentName,
        if (documentUrl != null) 'documentUrl': documentUrl,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'splitTicketId': splitTicketId,
        'title': title,
        'description': description.isNotEmpty ? description : title,
        'amount': amount,
        'paidBy': paidBy,
        'category': category,
        'date': date,
        'splitMode': splitType.toLowerCase() == 'equal' ? 'Equal Split' : 'Custom Split',
        'shares': Map<String, double>.from(shares),
        if (documentName != null && documentName!.isNotEmpty)
          'receipt': {'name': documentName, 'url': documentUrl ?? '', 'size': ''},
      };
}

/// Represents a settlement recorded between participants.
class SplitSettlement {
  final String id;
  final String debtor;
  final String creditor;
  final double amount;
  final String date;
  final String title;
  final String note;

  SplitSettlement({
    required this.id,
    required this.debtor,
    required this.creditor,
    required this.amount,
    required this.date,
    this.title = '',
    this.note = '',
  });

  factory SplitSettlement.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return SplitSettlement(
      id: json['id']?.toString() ??
          'settle_${DateTime.now().millisecondsSinceEpoch}',
      debtor: json['debtor']?.toString() ??
          json['from']?.toString() ??
          'Debtor',
      creditor: json['creditor']?.toString() ??
          json['to']?.toString() ??
          'Creditor',
      amount: parseNum(json['amount']),
      date: json['date']?.toString() ??
          DateTime.now().toIso8601String().split('T').first,
      title: json['title']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'debtor': debtor,
        'creditor': creditor,
        'amount': amount,
        'date': date,
        'title': title,
        'note': note,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'debtor': debtor,
        'creditor': creditor,
        'amount': amount,
        'date': date,
        'title': title.isNotEmpty ? title : 'Payment: $debtor paid $creditor',
        'note': note,
      };
}

/// Represents a complete Split Expense Ticket.
class SplitTicket {
  final String id;
  final dynamic userId;
  final String title;
  final String currency;
  final String currencySymbol;
  final String description;
  final double budget;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? creatorName;
  final String? creatorEmail;
  final List<SplitParticipant> participants;
  final List<SplitExpenseItem> expenses;
  final List<SplitSettlement> settlements;

  SplitTicket({
    required this.id,
    this.userId,
    required this.title,
    this.currency = 'INR',
    this.currencySymbol = '₹',
    this.description = '',
    this.budget = 0.0,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.creatorName,
    this.creatorEmail,
    this.participants = const [],
    this.expenses = const [],
    this.settlements = const [],
  });

  /// Total calculated from expenses excluding settlements
  double get totalExpenseAmount => expenses
      .where((e) => !e.isSettlement)
      .fold(0.0, (sum, e) => sum + e.amount);

  factory SplitTicket.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    // Parse participants
    final rawParticipants = json['participants'];
    final participantsList = <SplitParticipant>[];
    if (rawParticipants is List) {
      for (var p in rawParticipants) {
        if (p is Map) {
          participantsList.add(
            SplitParticipant.fromJson(Map<String, dynamic>.from(p)),
          );
        } else if (p is String && p.isNotEmpty) {
          participantsList.add(SplitParticipant(name: p));
        }
      }
    }

    // Parse expenses and extract settlements if embedded
    final rawExpenses = json['expenses'];
    final expensesList = <SplitExpenseItem>[];
    final settlementsList = <SplitSettlement>[];

    if (rawExpenses is List) {
      for (var e in rawExpenses) {
        if (e is Map) {
          final item = SplitExpenseItem.fromJson(Map<String, dynamic>.from(e));
          if (item.isSettlement) {
            // Find who was paid
            String creditor = '';
            for (var entry in item.shares.entries) {
              if (entry.value > 0) {
                creditor = entry.key;
                break;
              }
            }
            settlementsList.add(
              SplitSettlement(
                id: item.id,
                debtor: item.paidBy,
                creditor: creditor.isNotEmpty ? creditor : 'Admin',
                amount: item.amount,
                date: item.date,
                title: item.title,
              ),
            );
          } else {
            expensesList.add(item);
          }
        }
      }
    }

    // Parse explicit settlements if any
    final rawSettlements = json['settlements'];
    if (rawSettlements is List) {
      for (var s in rawSettlements) {
        if (s is Map) {
          settlementsList.add(
            SplitSettlement.fromJson(Map<String, dynamic>.from(s)),
          );
        }
      }
    }

    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    }
    DateTime? updated;
    if (json['updated_at'] != null) {
      updated = DateTime.tryParse(json['updated_at'].toString());
    }

    final rawBudget = json['budget'] ?? json['total_amount'] ?? 0.0;

    return SplitTicket(
      id: json['id']?.toString() ??
          'ticket_${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] ?? json['created_by'],
      title: json['title']?.toString() ?? 'Split Ticket',
      currency: json['currency']?.toString() ?? 'INR',
      currencySymbol: json['currencySymbol']?.toString() ??
          (json['currency']?.toString() == 'USD' ? '\$' : '₹'),
      description: json['description']?.toString() ?? '',
      budget: parseNum(rawBudget),
      category: json['category']?.toString(),
      createdAt: created,
      updatedAt: updated,
      creatorName: json['creator_name']?.toString(),
      creatorEmail: json['creator_email']?.toString(),
      participants: participantsList,
      expenses: expensesList,
      settlements: settlementsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'currency': currency,
        'currencySymbol': currencySymbol,
        'description': description,
        'budget': budget,
        'total_amount': budget,
        if (category != null) 'category': category,
        'participants': participants.map((p) => p.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'settlements': settlements.map((s) => s.toJson()).toList(),
      };

  /// Converts the model into a UI-friendly map matching the existing schema of split_collect_page.dart
  Map<String, dynamic> toMap() {
    final participantNames = participants.map((p) => p.name).toList();
    if (participantNames.isEmpty) {
      participantNames.add('You');
    }

    return {
      'id': id,
      'title': title,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'description': description,
      'budget': budget > 0 ? budget : totalExpenseAmount,
      'category': category ?? 'General',
      'participants': participantNames,
      'members': participants.map((p) => p.toMap()).toList(),
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'settlements': settlements.map((s) => s.toMap()).toList(),
      'debts': <Map<String, dynamic>>[],
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  SplitTicket copyWith({
    String? id,
    dynamic userId,
    String? title,
    String? currency,
    String? currencySymbol,
    String? description,
    double? budget,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creatorName,
    String? creatorEmail,
    List<SplitParticipant>? participants,
    List<SplitExpenseItem>? expenses,
    List<SplitSettlement>? settlements,
  }) {
    return SplitTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creatorName: creatorName ?? this.creatorName,
      creatorEmail: creatorEmail ?? this.creatorEmail,
      participants: participants ?? this.participants,
      expenses: expenses ?? this.expenses,
      settlements: settlements ?? this.settlements,
    );
  }
}

/// Per-Friend Owed Summary item from `GET /api/v1/split-expenses/summary`.
class FriendOwedSummary {
  final String name;
  final double totalOwed;
  final int unsettledSplitsCount;

  FriendOwedSummary({
    required this.name,
    required this.totalOwed,
    required this.unsettledSplitsCount,
  });

  factory FriendOwedSummary.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return FriendOwedSummary(
      name: json['name']?.toString() ?? 'Friend',
      totalOwed: parseNum(json['total_owed'] ?? json['totalOwed']),
      unsettledSplitsCount: parseInt(
        json['unsettled_splits_count'] ?? json['unsettledSplitsCount'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'total_owed': totalOwed,
        'unsettled_splits_count': unsettledSplitsCount,
      };
}

/// Request DTO for creating a Split Expense Ticket (`POST /api/v1/split-expenses`).
class CreateSplitExpenseRequest {
  final String title;
  final double totalAmount;
  final String category;
  final String splitType;
  final String currency;
  final String description;
  final List<Map<String, dynamic>> participants;

  CreateSplitExpenseRequest({
    required this.title,
    required this.totalAmount,
    this.category = 'General',
    this.splitType = 'equal',
    this.currency = 'INR',
    this.description = '',
    required this.participants,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'total_amount': totalAmount,
        'budget': totalAmount,
        'category': category,
        'split_type': splitType,
        'currency': currency,
        'description': description,
        'participants': participants,
      };
}

/// Request DTO for adding an expense inside a ticket (`POST /api/v1/split-expenses/:id/expenses`).
class AddExpenseItemRequest {
  final String description;
  final double amount;
  final String paidBy;
  final String category;
  final String splitType;
  final Map<String, double> shares;
  final String? date;
  final String? documentName;
  final String? documentUrl;

  AddExpenseItemRequest({
    required this.description,
    required this.amount,
    required this.paidBy,
    this.category = 'General',
    this.splitType = 'equal',
    this.shares = const {},
    this.date,
    this.documentName,
    this.documentUrl,
  });

  Map<String, dynamic> toJson() => {
        // Backend expects title and amount
        'title': description,
        'description': description,
        'amount': amount,
        'paid_by': paidBy,
        'paidBy': paidBy,
        'category': category,
        'split_type': splitType,
        'splitType': splitType,
        'shares': shares,
        'date': date ?? DateTime.now().toIso8601String().split('T').first,
        if (documentName != null) 'documentName': documentName,
        if (documentUrl != null) 'documentUrl': documentUrl,
      };
}

/// Request DTO for adding a participant (`POST /api/v1/split-expenses/:id/participants`).
class AddSplitParticipantRequest {
  final String name;
  final double shareAmount;
  final String? email;
  final String? role;

  AddSplitParticipantRequest({
    required this.name,
    required this.shareAmount,
    this.email,
    this.role = 'viewer',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'share_amount': shareAmount,
        if (email != null && email!.isNotEmpty) 'email': email,
        if (role != null) 'role': role,
      };
}

/// Request DTO for inviting a member (`POST /api/v1/split-expenses/:id/invite`).
class InviteMemberRequest {
  final String email;
  final String role;

  InviteMemberRequest({
    required this.email,
    this.role = 'editor',
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role,
      };
}
