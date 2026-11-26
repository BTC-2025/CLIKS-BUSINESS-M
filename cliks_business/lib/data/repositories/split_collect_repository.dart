import 'dart:typed_data';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/split_expense_models.dart';

/// Central repository for Split & Collect (Splitwise) feature.
/// Interacts directly with backend prefix `/api/v1/split-expenses/*`.
class SplitCollectRepository {
  /// 4.1 List All Split Expenses
  /// Calls: `GET /api/v1/split-expenses`
  static Future<List<SplitTicket>> getSplitExpenses({String? email}) async {
    final res = await ApiClient.get('/api/v1/split-expenses', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => SplitTicket.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return [];
  }

  /// 4.2 Create Split Expense Ticket
  /// Calls: `POST /api/v1/split-expenses`
  static Future<SplitTicket> createSplitExpense(
    CreateSplitExpenseRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/split-expenses',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false && map['error'] != null) {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ?? 'Failed to create split ticket',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return SplitTicket.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(statusCode: 500, message: 'Invalid response from split ticket creation');
  }

  /// 4.3 Get Split Expense Details
  /// Calls: `GET /api/v1/split-expenses/:id`
  static Future<SplitTicket?> getSplitExpenseDetails(
    dynamic id, {
    String? email,
  }) async {
    try {
      final res = await ApiClient.get('/api/v1/split-expenses/$id', email: email);
      if (res is Map) {
        final map = Map<String, dynamic>.from(res);
        final data = map['data'];
        if (data is Map && data.isNotEmpty) {
          return SplitTicket.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (_) {}
    // Fallback to getSplitExpenses if single-ticket endpoint returned an empty object
    final all = await getSplitExpenses(email: email);
    try {
      return all.firstWhere((t) => t.id.toString() == id.toString());
    } catch (_) {
      return null;
    }
  }

  /// 4.4 Update Split Expense
  /// Calls: `PATCH /api/v1/split-expenses/:id`
  static Future<SplitTicket> updateSplitExpense(
    dynamic id,
    Map<String, dynamic> fields, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/split-expenses/$id',
      body: fields,
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false && map['error'] != null) {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ?? 'Failed to update split ticket',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return SplitTicket.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(statusCode: 500, message: 'Invalid response updating split ticket');
  }

  /// 4.5 Delete Split Expense
  /// Calls: `DELETE /api/v1/split-expenses/:id`
  static Future<void> deleteSplitExpense(
    dynamic id, {
    String? email,
  }) async {
    final res = await ApiClient.delete(
      '/api/v1/split-expenses/$id',
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to delete split ticket',
      );
    }
  }

  /// 4.6 Per-Friend Owed Summary
  /// Calls: `GET /api/v1/split-expenses/summary`
  static Future<List<FriendOwedSummary>> getFriendOwedSummary({
    String? email,
  }) async {
    try {
      final res = await ApiClient.get('/api/v1/split-expenses/summary', email: email);
      if (res is Map) {
        final map = Map<String, dynamic>.from(res);
        final data = map['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => FriendOwedSummary.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// 4.7 Settle All Shares for Friend
  /// Calls: `PATCH /api/v1/split-expenses/settle-friend`
  static Future<void> settleFriend(
    String friendName, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/split-expenses/settle-friend',
      body: {'name': friendName},
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to settle shares for friend',
      );
    }
  }

  /// 4.8 Upload Receipt Attachment
  /// Calls: `POST /api/v1/split-expenses/upload` (multipart/form-data)
  static Future<Map<String, String>> uploadReceiptAttachment({
    String? filePath,
    Uint8List? bytes,
    String? filename,
    String? email,
  }) async {
    try {
      final res = await ApiClient.uploadMultipart(
        '/api/v1/split-expenses/upload',
        filePath: filePath,
        bytes: bytes,
        filename: filename,
        fieldName: 'file',
        email: email,
      );
      if (res['data'] is Map) {
        final data = Map<String, dynamic>.from(res['data'] as Map);
        return {
          'url': data['url']?.toString() ?? '',
          'filename': data['filename']?.toString() ?? (filename ?? 'receipt.pdf'),
        };
      }
    } catch (e) {
      print('[RECEIPT UPLOAD NOTE] Server upload failed: $e');
    }
    // Safe graceful fallback metadata when backend storage service is offline
    return {
      'url': '',
      'filename': filename ?? 'receipt.pdf',
    };
  }

  /// 4.9 Add Participant
  /// Calls: `POST /api/v1/split-expenses/:id/participants`
  static Future<SplitParticipant> addParticipant(
    dynamic ticketId,
    AddSplitParticipantRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/split-expenses/$ticketId/participants',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false && map['error'] != null) {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ?? 'Failed to add participant',
        );
      }
      final data = map['data'];
      if (data is Map && data.isNotEmpty) {
        return SplitParticipant.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return SplitParticipant(name: req.name, shareAmount: req.shareAmount);
  }

  /// 4.10 Settle Participant Share
  /// Calls: `PATCH /api/v1/split-expenses/:id/participants/:participantId/settle`
  static Future<void> settleParticipant(
    dynamic ticketId,
    dynamic participantId, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/split-expenses/$ticketId/participants/$participantId/settle',
      body: {},
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to mark participant share as settled',
      );
    }
  }

  /// 4.11 Remove Participant
  /// Calls: `DELETE /api/v1/split-expenses/:id/participants/:participantId`
  static Future<void> removeParticipant(
    dynamic ticketId,
    dynamic participantId, {
    String? email,
  }) async {
    final res = await ApiClient.delete(
      '/api/v1/split-expenses/$ticketId/participants/$participantId',
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to remove participant',
      );
    }
  }

  /// 4.12 Expense Sub-Items: Add Expense Item
  /// Calls: `POST /api/v1/split-expenses/:id/expenses`
  static Future<SplitExpenseItem> addExpenseItem(
    dynamic ticketId,
    AddExpenseItemRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/split-expenses/$ticketId/expenses',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false && map['error'] != null) {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ?? 'Failed to add expense item',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return SplitExpenseItem.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(statusCode: 500, message: 'Invalid response adding expense item');
  }

  /// 4.12 Expense Sub-Items: Update Expense Item
  /// Calls: `PATCH /api/v1/split-expenses/:id/expenses/:expenseId`
  static Future<void> updateExpenseItem(
    dynamic ticketId,
    dynamic expenseId,
    Map<String, dynamic> fields, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/split-expenses/$ticketId/expenses/$expenseId',
      body: fields,
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to update expense item',
      );
    }
  }

  /// 4.12 Expense Sub-Items: Delete Expense Item
  /// Calls: `DELETE /api/v1/split-expenses/:id/expenses/:expenseId`
  static Future<void> deleteExpenseItem(
    dynamic ticketId,
    dynamic expenseId, {
    String? email,
  }) async {
    final res = await ApiClient.delete(
      '/api/v1/split-expenses/$ticketId/expenses/$expenseId',
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to delete expense item',
      );
    }
  }

  /// 4.13 Invitations: Invite Member
  /// Calls: `POST /api/v1/split-expenses/:id/invite`
  static Future<void> inviteMember(
    dynamic ticketId,
    InviteMemberRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/split-expenses/$ticketId/invite',
      body: req.toJson(),
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to invite member',
      );
    }
  }

  /// 4.13 Invitations: Respond to Invite
  /// Calls: `PATCH /api/v1/split-expenses/:id/respond-invite`
  static Future<void> respondInvite(
    dynamic ticketId,
    String action, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/split-expenses/$ticketId/respond-invite',
      body: {'action': action},
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to respond to invite',
      );
    }
  }

  /// 4.13 Member Roles: Update Member Role
  /// Calls: `PATCH /api/v1/split-expenses/:id/member-role`
  static Future<void> updateMemberRole(
    dynamic ticketId,
    dynamic memberId,
    String role, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/split-expenses/$ticketId/member-role',
      body: {'member_id': memberId, 'role': role},
      email: email,
    );
    if (res is Map && res['success'] == false) {
      throw ApiException(
        statusCode: 400,
        message: res['message']?.toString() ?? 'Failed to update member role',
      );
    }
  }
}
