import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/people_models.dart';

/// Central repository for Payments -> People Network & Escrow.
/// Interacts directly with backend routes `/api/v1/people/*`.
class PeopleRepository {
  // ───────────────────────────────────────────────────────────────────────────
  // 1–5: CONTACT CRUD OPERATIONS
  // ───────────────────────────────────────────────────────────────────────────

  /// 1. List People & Contacts
  /// GET `/api/v1/people`
  static Future<List<PersonContact>> getPeople({String? email}) async {
    final res = await ApiClient.get('/api/v1/people', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to retrieve people',
        );
      }
      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => PersonContact.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => PersonContact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 1b. Fetch summary metadata if returned, or computed from contacts
  static Future<PeopleSummary> getPeopleSummary({String? email}) async {
    final res = await ApiClient.get('/api/v1/people', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      final meta = map['meta'];
      if (meta is Map && meta['summary'] is Map) {
        return PeopleSummary.fromJson(Map<String, dynamic>.from(meta['summary']));
      }
      final data = map['data'];
      if (data is List) {
        final contacts = data
            .whereType<Map>()
            .map((e) => PersonContact.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return PeopleSummary.fromContacts(contacts);
      }
    }
    return const PeopleSummary();
  }

  /// 2. Create Contact / Person
  /// POST `/api/v1/people`
  static Future<PersonContact> createPerson(
    CreatePersonRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/people',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to create person',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return PersonContact.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from person creation',
    );
  }

  /// 3. Get Person Details
  /// GET `/api/v1/people/:id`
  static Future<PersonContact?> getPersonDetails(
    dynamic id, {
    String? email,
  }) async {
    final res = await ApiClient.get('/api/v1/people/$id', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 404,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Contact not found',
        );
      }
      final data = map['data'];
      if (data is Map && data.isNotEmpty) {
        return PersonContact.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return null;
  }

  /// 4. Update Person
  /// PATCH `/api/v1/people/:id`
  static Future<PersonContact> updatePerson(
    dynamic id,
    UpdatePersonRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/people/$id',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to update person',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return PersonContact.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from person update',
    );
  }

  /// 5. Delete Person
  /// DELETE `/api/v1/people/:id`
  static Future<bool> deletePerson(
    dynamic id, {
    String? email,
  }) async {
    final res = await ApiClient.delete('/api/v1/people/$id', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to delete person',
        );
      }
      return true;
    }
    return true;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 6: PEOPLE TRANSACTIONS (Global Ledger)
  // ───────────────────────────────────────────────────────────────────────────

  /// 6. List All People Transactions
  /// GET `/api/v1/people/transactions`
  static Future<List<PersonTransaction>> getPeopleTransactions({
    String? email,
  }) async {
    final res = await ApiClient.get('/api/v1/people/transactions', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to retrieve people transactions',
        );
      }
      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => PersonTransaction.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => PersonTransaction.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 6b. Record Peer Transaction
  /// POST `/api/v1/people/:id/transactions`
  static Future<PersonTransaction> recordPersonTransaction(
    dynamic personId, {
    required String type,
    required double amount,
    required String date,
    String? description,
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/people/$personId/transactions',
      body: {
        'type': type,
        'amount': amount,
        'date': date,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to record peer transaction',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return PersonTransaction.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from peer transaction recording',
    );
  }

  /// 6c. Delete Peer Transaction
  /// DELETE `/api/v1/people/:id/transactions/:txId`
  static Future<bool> deletePersonTransaction(
    dynamic personId,
    dynamic txId, {
    String? email,
  }) async {
    final res = await ApiClient.delete(
      '/api/v1/people/$personId/transactions/$txId',
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to delete peer transaction',
        );
      }
      return true;
    }
    return true;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 7–10: REPAYMENT ALERTS / REMINDERS
  // ───────────────────────────────────────────────────────────────────────────

  /// 7. List Repayment Alerts
  /// GET `/api/v1/people/reminders`
  static Future<List<RepaymentAlert>> getRepaymentAlerts({
    String? email,
  }) async {
    final res = await ApiClient.get('/api/v1/people/reminders', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to retrieve repayment alerts',
        );
      }
      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => RepaymentAlert.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => RepaymentAlert.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 8. Create Repayment Alert
  /// POST `/api/v1/people/reminders`
  static Future<RepaymentAlert> createRepaymentAlert(
    CreateRepaymentAlertRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/people/reminders',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to create repayment alert',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return RepaymentAlert.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from repayment alert creation',
    );
  }

  /// 9. Update Alert Status (e.g. "Settled")
  /// PATCH `/api/v1/people/reminders/:id`
  static Future<bool> updateAlertStatus(
    dynamic id,
    String status, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/people/reminders/$id',
      body: {'status': status.trim()},
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to update alert status',
        );
      }
      return true;
    }
    return true;
  }

  /// 10. Delete / Dismiss Repayment Alert
  /// DELETE `/api/v1/people/reminders/:id`
  static Future<bool> deleteRepaymentAlert(
    dynamic id, {
    String? email,
  }) async {
    final res = await ApiClient.delete('/api/v1/people/reminders/$id', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to delete repayment alert',
        );
      }
      return true;
    }
    return true;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 11–12: CONNECTION REQUESTS
  // ───────────────────────────────────────────────────────────────────────────

  /// 11. Get Incoming Connection Requests
  /// GET `/api/v1/people/requests/incoming`
  static Future<List<ConnectionRequest>> getIncomingRequests({
    String? email,
  }) async {
    final res = await ApiClient.get('/api/v1/people/requests/incoming', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to retrieve connection requests',
        );
      }
      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => ConnectionRequest.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => ConnectionRequest.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 12. Respond to Connection Request ("accept" or "reject")
  /// PATCH `/api/v1/people/requests/:id/respond`
  static Future<bool> respondToConnectionRequest(
    dynamic id,
    String action, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/people/requests/$id/respond',
      body: {'action': action.trim().toLowerCase()},
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to respond to connection request',
        );
      }
      return true;
    }
    return true;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 13–17: FINANCIAL GROUPS CRUD
  // ───────────────────────────────────────────────────────────────────────────

  /// 13. List Financial Groups
  /// GET `/api/v1/people/groups`
  static Future<List<FinancialGroup>> getFinancialGroups({
    String? email,
  }) async {
    final res = await ApiClient.get('/api/v1/people/groups', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to retrieve financial groups',
        );
      }
      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => FinancialGroup.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => FinancialGroup.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 14. Create Financial Group
  /// POST `/api/v1/people/groups`
  static Future<FinancialGroup> createFinancialGroup(
    CreateFinancialGroupRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/people/groups',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to create financial group',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return FinancialGroup.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from financial group creation',
    );
  }

  /// 15. Get Group Details / Open Ledger
  /// GET `/api/v1/people/groups/:id`
  static Future<FinancialGroup?> getGroupDetails(
    dynamic id, {
    String? email,
  }) async {
    final res = await ApiClient.get('/api/v1/people/groups/$id', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 404,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Financial group not found',
        );
      }
      final data = map['data'];
      if (data is Map && data.isNotEmpty) {
        return FinancialGroup.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return null;
  }

  /// 16. Update Group
  /// PUT `/api/v1/people/groups/:id`
  static Future<FinancialGroup> updateFinancialGroup(
    dynamic id,
    UpdateFinancialGroupRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.put(
      '/api/v1/people/groups/$id',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to update financial group',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return FinancialGroup.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from group update',
    );
  }

  /// 17. Delete Group
  /// DELETE `/api/v1/people/groups/:id`
  static Future<bool> deleteFinancialGroup(
    dynamic id, {
    String? email,
  }) async {
    final res = await ApiClient.delete('/api/v1/people/groups/$id', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to delete financial group',
        );
      }
      return true;
    }
    return true;
  }

  /// Get Incoming Financial Group Invitations
  /// GET `/api/v1/people/groups/requests/incoming`
  static Future<List<GroupInvitation>> getIncomingGroupRequests({
    String? email,
  }) async {
    final res = await ApiClient.get('/api/v1/people/groups/requests/incoming', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to retrieve group invitations',
        );
      }
      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => GroupInvitation.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => GroupInvitation.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// Respond to Financial Group Invitation ("accept" or "reject")
  /// POST `/api/v1/people/groups/requests/:membershipId/respond`
  static Future<bool> respondToGroupRequest(
    dynamic membershipId,
    String action, {
    String? email,
  }) async {
    final act = action.trim().toLowerCase();
    final apiAction = (act == 'decline' || act == 'declined' || act == 'reject' || act == 'rejected')
        ? 'reject'
        : 'accept';
    final res = await ApiClient.post(
      '/api/v1/people/groups/requests/$membershipId/respond',
      body: {'action': apiAction},
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to respond to group invitation',
        );
      }
      return true;
    }
    return true;
  }

  /// Join / Accept Financial Group Invitation
  static Future<bool> joinFinancialGroup(dynamic id, {String? email}) async {
    try {
      return await respondToGroupRequest(id, 'accept', email: email);
    } catch (_) {
      try {
        await ApiClient.post(
          '/api/v1/people/groups/$id/join',
          body: {'action': 'accept'},
          email: email,
        );
        return true;
      } catch (_) {
        try {
          await ApiClient.patch(
            '/api/v1/people/requests/$id/respond',
            body: {'action': 'accept'},
            email: email,
          );
        } catch (_) {}
        return true;
      }
    }
  }

  /// Decline Financial Group Invitation
  static Future<bool> declineFinancialGroup(dynamic id, {String? email}) async {
    try {
      return await respondToGroupRequest(id, 'reject', email: email);
    } catch (_) {
      try {
        await ApiClient.post(
          '/api/v1/people/groups/$id/decline',
          body: {'action': 'reject'},
          email: email,
        );
        return true;
      } catch (_) {
        try {
          await ApiClient.patch(
            '/api/v1/people/requests/$id/respond',
            body: {'action': 'reject'},
            email: email,
          );
        } catch (_) {}
        return true;
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 18–19: GROUP MEMBERS
  // ───────────────────────────────────────────────────────────────────────────

  /// 18. Invite Member
  /// POST `/api/v1/people/groups/:id/members`
  static Future<GroupMember> inviteGroupMember(
    dynamic groupId,
    InviteGroupMemberRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/people/groups/$groupId/members',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to invite member',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return GroupMember.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from member invitation',
    );
  }

  /// 19. Remove Member
  /// DELETE `/api/v1/people/groups/:id/members/:memberId`
  static Future<bool> removeGroupMember(
    dynamic groupId,
    dynamic memberId, {
    String? email,
  }) async {
    final res = await ApiClient.delete(
      '/api/v1/people/groups/$groupId/members/$memberId',
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to remove group member',
        );
      }
      return true;
    }
    return true;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 20–21: GROUP TRANSACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  /// 20. Add Group Transaction
  /// POST `/api/v1/people/groups/:id/transactions`
  static Future<GroupTransaction> addGroupTransaction(
    dynamic groupId,
    AddGroupTransactionRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/people/groups/$groupId/transactions',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to add group transaction',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return GroupTransaction.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from group transaction creation',
    );
  }

  /// 21. Delete Group Transaction
  /// DELETE `/api/v1/people/groups/:id/transactions/:txId`
  static Future<bool> deleteGroupTransaction(
    dynamic groupId,
    dynamic txId, {
    String? email,
  }) async {
    final res = await ApiClient.delete(
      '/api/v1/people/groups/$groupId/transactions/$txId',
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to delete group transaction',
        );
      }
      return true;
    }
    return true;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 22–23: PRIVATE MEMBER NOTES
  // ───────────────────────────────────────────────────────────────────────────

  /// 22. Set Private Member Note
  /// POST `/api/v1/people/groups/:id/members/:memberId/private-note`
  static Future<GroupPrivateNote> setPrivateMemberNote(
    dynamic groupId,
    dynamic memberId,
    SetPrivateNoteRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/people/groups/$groupId/members/$memberId/private-note',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to save private note',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return GroupPrivateNote.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from setting private note',
    );
  }

  /// 23. Delete Private Member Note
  /// DELETE `/api/v1/people/groups/:id/members/:memberId/private-note`
  static Future<bool> deletePrivateMemberNote(
    dynamic groupId,
    dynamic memberId, {
    String? email,
  }) async {
    final res = await ApiClient.delete(
      '/api/v1/people/groups/$groupId/members/$memberId/private-note',
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['success'] == false || map['status'] == 'error') {
        throw ApiException(
          statusCode: 400,
          message: map['error']?['message']?.toString() ??
              map['message']?.toString() ??
              'Failed to delete private note',
        );
      }
      return true;
    }
    return true;
  }
}
