import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/people_models.dart';
import '../../../data/repositories/people_repository.dart';

@immutable
class PeopleState {
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final List<PersonContact> contacts;
  final PeopleSummary summary;
  final List<PersonTransaction> transactions;
  final List<RepaymentAlert> reminders;
  final List<ConnectionRequest> incomingRequests;
  final List<GroupInvitation> incomingGroupRequests;
  final List<FinancialGroup> groups;
  final PersonContact? selectedContact;
  final FinancialGroup? selectedGroup;

  const PeopleState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.contacts = const [],
    this.summary = const PeopleSummary(),
    this.transactions = const [],
    this.reminders = const [],
    this.incomingRequests = const [],
    this.incomingGroupRequests = const [],
    this.groups = const [],
    this.selectedContact,
    this.selectedGroup,
  });

  PeopleState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    List<PersonContact>? contacts,
    PeopleSummary? summary,
    List<PersonTransaction>? transactions,
    List<RepaymentAlert>? reminders,
    List<ConnectionRequest>? incomingRequests,
    List<GroupInvitation>? incomingGroupRequests,
    List<FinancialGroup>? groups,
    PersonContact? selectedContact,
    bool clearSelectedContact = false,
    FinancialGroup? selectedGroup,
    bool clearSelectedGroup = false,
  }) {
    return PeopleState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      contacts: contacts ?? this.contacts,
      summary: summary ?? this.summary,
      transactions: transactions ?? this.transactions,
      reminders: reminders ?? this.reminders,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      incomingGroupRequests: incomingGroupRequests ?? this.incomingGroupRequests,
      groups: groups ?? this.groups,
      selectedContact: clearSelectedContact ? null : (selectedContact ?? this.selectedContact),
      selectedGroup: clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
    );
  }
}

class PeopleNotifier extends StateNotifier<PeopleState> {
  PeopleNotifier() : super(const PeopleState());

  /// Load all 5 sub-sections in parallel on initial load or manual refresh
  Future<void> loadAll({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final results = await Future.wait([
        PeopleRepository.getPeople(),
        PeopleRepository.getPeopleTransactions(),
        PeopleRepository.getRepaymentAlerts(),
        PeopleRepository.getIncomingRequests(),
        PeopleRepository.getFinancialGroups(),
        PeopleRepository.getIncomingGroupRequests(),
      ]);

      final contacts = results[0] as List<PersonContact>;
      final transactions = results[1] as List<PersonTransaction>;
      final reminders = results[2] as List<RepaymentAlert>;
      final requests = results[3] as List<ConnectionRequest>;
      final rawGroups = results[4] as List<FinancialGroup>;
      final groups = rawGroups.where((g) => !g.isRejectedOrDeclined).toList();
      final groupInvs = results[5] as List<GroupInvitation>;

      final summary = PeopleSummary.fromContacts(contacts);

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        clearError: true,
        contacts: contacts,
        summary: summary,
        transactions: transactions,
        reminders: reminders,
        incomingRequests: requests,
        incomingGroupRequests: groupInvs,
        groups: groups,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
    }
  }

  // ── Contact Operations ──────────────────────────────────────────────────

  Future<PersonContact?> createContact(CreatePersonRequest req) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final created = await PeopleRepository.createPerson(req);
      final updatedContacts = [created, ...state.contacts];
      final updatedSummary = PeopleSummary.fromContacts(updatedContacts);
      state = state.copyWith(
        isLoading: false,
        contacts: updatedContacts,
        summary: updatedSummary,
      );
      // Background sync to ensure all server balances are consistent
      await loadContacts();
      return created;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<void> loadContacts() async {
    try {
      final contacts = await PeopleRepository.getPeople();
      final summary = PeopleSummary.fromContacts(contacts);
      state = state.copyWith(contacts: contacts, summary: summary);
    } catch (e) {
      // Keep existing data on background refresh failure
    }
  }

  Future<PersonContact?> selectContactForDetail(dynamic id) async {
    try {
      final details = await PeopleRepository.getPersonDetails(id);
      if (details != null) {
        state = state.copyWith(selectedContact: details);
        return details;
      }
    } catch (_) {}
    final fallback = state.contacts.firstWhere(
      (c) => c.id.toString() == id.toString(),
      orElse: () => state.contacts.first,
    );
    state = state.copyWith(selectedContact: fallback);
    return fallback;
  }

  void clearSelectedContact() {
    state = state.copyWith(clearSelectedContact: true);
  }

  Future<PersonContact?> updateContact(dynamic id, UpdatePersonRequest req) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await PeopleRepository.updatePerson(id, req);
      final list = state.contacts.map((c) {
        if (c.id.toString() == id.toString()) {
          return updated.copyWith(
            totalLent: c.totalLent,
            totalBorrowed: c.totalBorrowed,
            netBalance: c.netBalance,
          );
        }
        return c;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        contacts: list,
        selectedContact: state.selectedContact?.id.toString() == id.toString()
            ? updated
            : state.selectedContact,
      );
      await loadContacts();
      return updated;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> deleteContact(dynamic id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await PeopleRepository.deletePerson(id);
      if (ok) {
        final list = state.contacts
            .where((c) => c.id.toString() != id.toString())
            .toList();
        final summary = PeopleSummary.fromContacts(list);
        state = state.copyWith(
          isLoading: false,
          contacts: list,
          summary: summary,
          clearSelectedContact: state.selectedContact?.id.toString() == id.toString(),
        );
        // Refresh transactions and reminders as well, since deletion cascades
        await Future.wait([
          loadTransactions(),
          loadReminders(),
        ]);
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  // ── Transactions (Global Ledger) ────────────────────────────────────────

  Future<void> loadTransactions() async {
    try {
      final txs = await PeopleRepository.getPeopleTransactions();
      state = state.copyWith(transactions: txs);
    } catch (_) {}
  }

  // ── Repayment Alerts / Reminders ────────────────────────────────────────

  Future<void> loadReminders() async {
    try {
      final reminders = await PeopleRepository.getRepaymentAlerts();
      state = state.copyWith(reminders: reminders);
    } catch (_) {}
  }

  Future<RepaymentAlert> createRepaymentAlert(CreateRepaymentAlertRequest req) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final created = await PeopleRepository.createRepaymentAlert(req);
      state = state.copyWith(
        isLoading: false,
        reminders: [created, ...state.reminders],
      );
      await loadReminders();
      return created;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> updateAlertStatus(dynamic id, String status) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await PeopleRepository.updateAlertStatus(id, status);
      if (ok) {
        final list = state.reminders.map((r) {
          if (r.id.toString() == id.toString()) {
            return RepaymentAlert(
              id: r.id,
              userId: r.userId,
              contactId: r.contactId,
              targetContact: r.targetContact,
              claimCap: r.claimCap,
              maturityDate: r.maturityDate,
              memoLabel: r.memoLabel,
              status: status,
              contactPhone: r.contactPhone,
              createdAt: r.createdAt,
            );
          }
          return r;
        }).toList();
        state = state.copyWith(isLoading: false, reminders: list);
        await loadReminders();
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> deleteRepaymentAlert(dynamic id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await PeopleRepository.deleteRepaymentAlert(id);
      if (ok) {
        final list = state.reminders
            .where((r) => r.id.toString() != id.toString())
            .toList();
        state = state.copyWith(isLoading: false, reminders: list);
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  // ── Connection Requests ─────────────────────────────────────────────────

  Future<void> loadIncomingRequests() async {
    try {
      final reqs = await PeopleRepository.getIncomingRequests();
      state = state.copyWith(incomingRequests: reqs);
    } catch (_) {}
  }

  Future<bool> respondConnectionRequest(dynamic id, String action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await PeopleRepository.respondToConnectionRequest(id, action);
      if (ok) {
        final list = state.incomingRequests
            .where((r) => r.id.toString() != id.toString())
            .toList();
        state = state.copyWith(isLoading: false, incomingRequests: list);
        // Refresh contacts since accepting creates a contact relationship
        await loadContacts();
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  // ── Financial Groups ────────────────────────────────────────────────────

  Future<void> loadGroups() async {
    try {
      final results = await Future.wait([
        PeopleRepository.getFinancialGroups(),
        PeopleRepository.getIncomingGroupRequests(),
      ]);
      final rawGroups = results[0] as List<FinancialGroup>;
      final activeGroups = rawGroups.where((g) => !g.isRejectedOrDeclined).toList();
      state = state.copyWith(
        groups: activeGroups,
        incomingGroupRequests: results[1] as List<GroupInvitation>,
      );
    } catch (_) {}
  }

  Future<FinancialGroup> createFinancialGroup(CreateFinancialGroupRequest req) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final created = await PeopleRepository.createFinancialGroup(req);
      state = state.copyWith(
        isLoading: false,
        groups: [created, ...state.groups],
      );
      await loadGroups();
      return created;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<FinancialGroup?> selectGroupForDetail(dynamic id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final details = await PeopleRepository.getGroupDetails(id);
      if (details != null) {
        state = state.copyWith(isLoading: false, selectedGroup: details);
        return details;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
    }
    final fallback = state.groups.firstWhere(
      (g) => g.id.toString() == id.toString(),
      orElse: () => state.groups.first,
    );
    state = state.copyWith(isLoading: false, selectedGroup: fallback);
    return fallback;
  }

  void clearSelectedGroup() {
    state = state.copyWith(clearSelectedGroup: true);
  }

  Future<FinancialGroup> updateFinancialGroup(
    dynamic id,
    UpdateFinancialGroupRequest req,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await PeopleRepository.updateFinancialGroup(id, req);
      final list = state.groups.map((g) {
        return g.id.toString() == id.toString() ? updated : g;
      }).toList();
      state = state.copyWith(
        isLoading: false,
        groups: list,
        selectedGroup: state.selectedGroup?.id.toString() == id.toString()
            ? updated
            : state.selectedGroup,
      );
      return updated;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> deleteFinancialGroup(dynamic id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await PeopleRepository.deleteFinancialGroup(id);
      if (ok) {
        final list = state.groups
            .where((g) => g.id.toString() != id.toString())
            .toList();
        state = state.copyWith(
          isLoading: false,
          groups: list,
          clearSelectedGroup: state.selectedGroup?.id.toString() == id.toString(),
        );
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  /// Respond to incoming financial group invitation ("accept" or "reject")
  /// Calls `POST /api/v1/people/groups/requests/:membershipId/respond`
  Future<bool> respondToGroupRequest(dynamic id, String action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final isReject = action.trim().toLowerCase() == 'reject' ||
          action.trim().toLowerCase() == 'decline' ||
          action.trim().toLowerCase() == 'declined';
      final apiAction = isReject ? 'reject' : 'accept';

      // 1. Resolve membership ID and target group ID
      dynamic membershipId = id;
      dynamic targetGroupId = id;

      final matchingInv = state.incomingGroupRequests.where(
        (inv) =>
            inv.membershipId.toString() == id.toString() ||
            inv.groupId.toString() == id.toString(),
      ).firstOrNull;

      if (matchingInv != null) {
        membershipId = matchingInv.membershipId;
        targetGroupId = matchingInv.groupId;
      } else {
        final matchingGroup = state.groups.where(
          (g) =>
              g.id.toString() == id.toString() ||
              (g.membershipId != null &&
                  g.membershipId.toString() == id.toString()),
        ).firstOrNull;
        if (matchingGroup != null) {
          targetGroupId = matchingGroup.id;
          if (matchingGroup.membershipId != null) {
            membershipId = matchingGroup.membershipId;
          }
        }
      }

      // 2. Optimistically remove from incomingGroupRequests
      final updatedInvs = state.incomingGroupRequests.where(
        (inv) =>
            inv.membershipId.toString() != membershipId.toString() &&
            inv.groupId.toString() != targetGroupId.toString() &&
            inv.groupId.toString() != id.toString(),
      ).toList();

      // 3. Optimistically update groups list
      final List<FinancialGroup> updatedGroups;
      if (isReject) {
        // If rejected/declined, remove the group completely from groups!
        updatedGroups = state.groups.where((g) {
          final matchesId = g.id.toString() == targetGroupId.toString() ||
              g.id.toString() == id.toString();
          final matchesMembership = g.membershipId != null &&
              (g.membershipId.toString() == membershipId.toString() ||
                  g.membershipId.toString() == id.toString());
          return !matchesId && !matchesMembership;
        }).toList();
      } else {
        // If accepted, update membership status to accepted
        updatedGroups = state.groups.map((g) {
          if (g.id.toString() == targetGroupId.toString() ||
              g.id.toString() == id.toString() ||
              (g.membershipId != null &&
                  g.membershipId.toString() == membershipId.toString())) {
            return FinancialGroup(
              id: g.id,
              membershipId: g.membershipId ??
                  (membershipId is int
                      ? membershipId
                      : int.tryParse(membershipId.toString())),
              createdBy: g.createdBy,
              name: g.name,
              description: g.description,
              groupType: g.groupType,
              currency: g.currency,
              targetAmount: g.targetAmount,
              status: g.status,
              myRole: g.myRole ?? 'member',
              myMembershipStatus: 'accepted',
              memberCount: g.memberCount + 1,
              pendingMemberCount: (g.pendingMemberCount - 1).clamp(0, 999),
              totalMembers: g.totalMembers,
              totalContributed: g.totalContributed,
              totalExpenses: g.totalExpenses,
              totalLoans: g.totalLoans,
              createdAt: g.createdAt,
              updatedAt: g.updatedAt,
              members: g.members,
              transactions: g.transactions,
              invitedByName: g.invitedByName,
              invitedByEmail: g.invitedByEmail,
            );
          }
          return g;
        }).toList();
      }

      state = state.copyWith(
        isLoading: false,
        incomingGroupRequests: updatedInvs,
        groups: updatedGroups,
      );

      final ok = await PeopleRepository.respondToGroupRequest(membershipId, apiAction);
      await loadGroups();
      await loadContacts();
      return ok;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> joinFinancialGroup(dynamic id) async {
    return await respondToGroupRequest(id, 'accept');
  }

  Future<bool> declineFinancialGroup(dynamic id) async {
    return await respondToGroupRequest(id, 'reject');
  }

  Future<GroupMember> inviteGroupMember(
    dynamic groupId,
    InviteGroupMemberRequest req,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final member = await PeopleRepository.inviteGroupMember(groupId, req);
      state = state.copyWith(isLoading: false);
      await selectGroupForDetail(groupId);
      await loadGroups();
      return member;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> removeGroupMember(dynamic groupId, dynamic memberId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await PeopleRepository.removeGroupMember(groupId, memberId);
      if (ok) {
        state = state.copyWith(isLoading: false);
        await selectGroupForDetail(groupId);
        await loadGroups();
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<GroupTransaction> addGroupTransaction(
    dynamic groupId,
    AddGroupTransactionRequest req,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tx = await PeopleRepository.addGroupTransaction(groupId, req);
      state = state.copyWith(isLoading: false);
      await selectGroupForDetail(groupId);
      await loadGroups();
      return tx;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> deleteGroupTransaction(dynamic groupId, dynamic txId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await PeopleRepository.deleteGroupTransaction(groupId, txId);
      if (ok) {
        state = state.copyWith(isLoading: false);
        await selectGroupForDetail(groupId);
        await loadGroups();
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<GroupPrivateNote> setPrivateMemberNote(
    dynamic groupId,
    dynamic memberId,
    SetPrivateNoteRequest req,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final note = await PeopleRepository.setPrivateMemberNote(
        groupId,
        memberId,
        req,
      );
      state = state.copyWith(isLoading: false);
      await selectGroupForDetail(groupId);
      return note;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<bool> deletePrivateMemberNote(dynamic groupId, dynamic memberId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ok = await PeopleRepository.deletePrivateMemberNote(groupId, memberId);
      if (ok) {
        state = state.copyWith(isLoading: false);
        await selectGroupForDetail(groupId);
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      rethrow;
    }
  }
}

final peopleProvider = StateNotifierProvider<PeopleNotifier, PeopleState>((ref) {
  return PeopleNotifier();
});
