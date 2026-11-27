import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/data/models/people_models.dart';
import 'package:clicks_business_frontend/features/people/providers/people_providers.dart';

void main() {
  group('PeopleState & PeopleSummary State Management Tests', () {
    test('1. Initial PeopleState defaults are correct', () {
      const state = PeopleState();
      expect(state.isLoading, isFalse);
      expect(state.isRefreshing, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.contacts, isEmpty);
      expect(state.summary.totalContacts, 0);
      expect(state.summary.totalReceivables, 0.0);
      expect(state.summary.totalPayables, 0.0);
      expect(state.summary.totalLent, 0.0);
      expect(state.summary.totalBorrowed, 0.0);
      expect(state.transactions, isEmpty);
      expect(state.reminders, isEmpty);
      expect(state.incomingRequests, isEmpty);
      expect(state.groups, isEmpty);
      expect(state.selectedContact, isNull);
      expect(state.selectedGroup, isNull);
    });

    test('2. PeopleState copyWith updates fields correctly', () {
      const initialState = PeopleState();

      final updatedState = initialState.copyWith(
        isLoading: true,
        isRefreshing: true,
        errorMessage: 'Connection timeout',
        contacts: const [
          PersonContact(
            id: 1,
            name: 'Kiran Kumar',
            roleType: 'Partner',
            relationship: 'Investor',
            phone: '+919876543210',
            email: 'kiran@bnxmail.com',
            totalLent: 50000.0,
            totalBorrowed: 10000.0,
            netBalance: 40000.0,
          )
        ],
        summary: const PeopleSummary(
          totalContacts: 1,
          totalReceivables: 50000.0,
          totalPayables: 10000.0,
          totalLent: 50000.0,
          totalBorrowed: 10000.0,
        ),
      );

      expect(updatedState.isLoading, isTrue);
      expect(updatedState.isRefreshing, isTrue);
      expect(updatedState.errorMessage, 'Connection timeout');
      expect(updatedState.contacts.length, 1);
      expect(updatedState.contacts.first.name, 'Kiran Kumar');
      expect(updatedState.summary.totalReceivables, 50000.0);

      // Test clear flags
      final clearedState = updatedState.copyWith(
        clearError: true,
        isLoading: false,
        isRefreshing: false,
      );
      expect(clearedState.errorMessage, isNull);
      expect(clearedState.isLoading, isFalse);
      expect(clearedState.isRefreshing, isFalse);
      expect(clearedState.contacts.length, 1);
    });

    test('3. PeopleState selectedContact and selectedGroup selection and clearing', () {
      const contact = PersonContact(
        id: 5,
        name: 'Anita Roy',
        roleType: 'Director',
        relationship: 'Board Member',
        phone: '+919888877777',
        email: 'anita@bnxmail.com',
      );

      const group = FinancialGroup(
        id: 10,
        name: 'Angel Syndicate Alpha',
        currency: 'INR',
        targetAmount: 500000.0,
      );

      var state = const PeopleState().copyWith(
        selectedContact: contact,
        selectedGroup: group,
      );

      expect(state.selectedContact?.name, 'Anita Roy');
      expect(state.selectedGroup?.name, 'Angel Syndicate Alpha');

      // Clear selected contact
      state = state.copyWith(clearSelectedContact: true);
      expect(state.selectedContact, isNull);
      expect(state.selectedGroup, isNotNull);

      // Clear selected group
      state = state.copyWith(clearSelectedGroup: true);
      expect(state.selectedGroup, isNull);
    });

    test('4. PeopleSummary.fromContacts calculates correct totals and ratios', () {
      final contacts = [
        const PersonContact(
          id: 1,
          name: 'Partner A',
          roleType: 'Partner',
          phone: '+919000000001',
          email: 'partnera@bnxmail.com',
          totalLent: 100000.0,
          totalBorrowed: 20000.0,
          netBalance: 80000.0,
        ),
        const PersonContact(
          id: 2,
          name: 'Vendor B',
          roleType: 'Vendor',
          phone: '+919000000002',
          email: 'vendorb@bnxmail.com',
          totalLent: 20000.0,
          totalBorrowed: 50000.0,
          netBalance: -30000.0,
        ),
        const PersonContact(
          id: 3,
          name: 'Client C',
          roleType: 'Client',
          phone: '+919000000003',
          email: 'clientc@bnxmail.com',
          totalLent: 30000.0,
          totalBorrowed: 0.0,
          netBalance: 30000.0,
        ),
      ];

      final summary = PeopleSummary.fromContacts(contacts);

      expect(summary.totalContacts, 3);
      expect(summary.totalReceivables, 110000.0);
      expect(summary.totalPayables, 30000.0);
      expect(summary.totalLent, 150000.0);
      expect(summary.totalBorrowed, 70000.0);
      expect(summary.collectionPercentage, closeTo(26.67, 0.05));
      expect(summary.settlementPercentage, closeTo(57.14, 0.05));
    });

    test('5. PeopleSummary handles zero amounts safely without NaN or Infinity', () {
      final emptyContacts = <PersonContact>[];
      final emptySummary = PeopleSummary.fromContacts(emptyContacts);

      expect(emptySummary.totalContacts, 0);
      expect(emptySummary.totalReceivables, 0.0);
      expect(emptySummary.totalPayables, 0.0);
      expect(emptySummary.collectionPercentage.isNaN, isFalse);
      expect(emptySummary.collectionPercentage.isInfinite, isFalse);
      expect(emptySummary.collectionPercentage, 0.0);
      expect(emptySummary.settlementPercentage.isNaN, isFalse);
      expect(emptySummary.settlementPercentage.isInfinite, isFalse);
      expect(emptySummary.settlementPercentage, 0.0);
    });

    test('6. Contact local search & filtering verification', () {
      final contacts = [
        const PersonContact(
          id: 1,
          name: 'Kiran Kumar',
          roleType: 'Partner',
          relationship: 'Investor',
          company: 'Kiran Ventures',
          phone: '+919876543210',
          email: 'kiran@bnxmail.com',
        ),
        const PersonContact(
          id: 2,
          name: 'Dev Sharma',
          roleType: 'Vendor',
          relationship: 'Supplier',
          company: 'Sharma Logistics',
          phone: '+919123456780',
          email: 'dev@bnxmail.com',
        ),
        const PersonContact(
          id: 3,
          name: 'Anita Roy',
          roleType: 'Advisor',
          relationship: 'Legal',
          company: 'Roy & Associates',
          phone: '+919555444333',
          email: 'anita@bnxmail.com',
        ),
      ];

      List<PersonContact> filter(String q) {
        final query = q.toLowerCase().trim();
        if (query.isEmpty) return contacts;
        return contacts.where((c) {
          final comp = c.company?.toLowerCase() ?? '';
          final rel = c.relationship?.toLowerCase() ?? '';
          return c.name.toLowerCase().contains(query) ||
              comp.contains(query) ||
              c.email.toLowerCase().contains(query) ||
              c.phone.toLowerCase().contains(query) ||
              c.roleType.toLowerCase().contains(query) ||
              rel.contains(query);
        }).toList();
      }

      expect(filter('kiran').length, 1);
      expect(filter('kiran').first.id, 1);

      expect(filter('logistics').length, 1);
      expect(filter('logistics').first.name, 'Dev Sharma');

      expect(filter('bnxmail.com').length, 3);
      expect(filter('+919555').length, 1);
      expect(filter('legal').length, 1);
      expect(filter('nonexistent').length, 0);
    });

    test('7. RepaymentAlert status transitions & parsing', () {
      final alertJson = {
        'id': 42,
        'user_id': 100,
        'contact_id': 1,
        'target_contact': 'Kiran Kumar',
        'claim_cap': 25000.0,
        'maturity_date': '2026-06-30',
        'memo_label': 'Advance Dividend',
        'status': 'Pending',
        'contact_phone': '+919876543210',
        'created_at': '2026-03-01T10:00:00Z',
      };

      final alert = RepaymentAlert.fromJson(alertJson);
      expect(alert.id, 42);
      expect(alert.targetContact, 'Kiran Kumar');
      expect(alert.claimCap, 25000.0);
      expect(alert.status, 'Pending');

      final settledAlert = RepaymentAlert(
        id: alert.id,
        userId: alert.userId,
        contactId: alert.contactId,
        targetContact: alert.targetContact,
        claimCap: alert.claimCap,
        maturityDate: alert.maturityDate,
        memoLabel: alert.memoLabel,
        status: 'settled',
        contactPhone: alert.contactPhone,
        createdAt: alert.createdAt,
      );

      expect(settledAlert.status, 'settled');
    });

    test('8. FinancialGroup member and transaction relationships', () {
      const member1 = GroupMember(
        id: 1,
        groupId: 10,
        userId: 101,
        name: 'Ravi Kumar',
        email: 'ravi@bnxmail.com',
        role: 'Admin',
      );

      const member2 = GroupMember(
        id: 2,
        groupId: 10,
        userId: 102,
        name: 'Kiran Kumar',
        email: 'kiran@bnxmail.com',
        role: 'Member',
      );

      const tx1 = GroupTransaction(
        id: 1,
        groupId: 10,
        title: 'Initial Seed Contribution',
        amount: 50000.0,
        type: 'contribution',
      );

      final group = FinancialGroup(
        id: 10,
        name: 'Core Founders Fund',
        currency: 'INR',
        targetAmount: 200000.0,
        memberCount: 2,
        members: const [member1, member2],
        transactions: const [tx1],
      );

      expect(group.members.length, 2);
      expect(group.memberCount, 2);
      expect(group.transactions.length, 1);
      expect(group.transactions.first.amount, 50000.0);
    });

    test('9. FinancialGroup rejection and decline state handling', () {
      const activeGroup = FinancialGroup(
        id: 1,
        name: 'Active Group',
        myMembershipStatus: 'accepted',
      );
      const pendingGroup = FinancialGroup(
        id: 2,
        name: 'Pending Group',
        myMembershipStatus: 'pending',
      );
      const rejectedGroup = FinancialGroup(
        id: 3,
        name: 'Rejected Group',
        myMembershipStatus: 'rejected',
      );
      const declinedGroup = FinancialGroup(
        id: 4,
        name: 'Declined Group',
        myMembershipStatus: 'declined',
      );

      expect(activeGroup.isRejectedOrDeclined, isFalse);
      expect(activeGroup.isPendingInvitation, isFalse);

      expect(pendingGroup.isPendingInvitation, isTrue);
      expect(pendingGroup.isRejectedOrDeclined, isFalse);

      expect(rejectedGroup.isRejectedOrDeclined, isTrue);
      expect(rejectedGroup.isPendingInvitation, isFalse);

      expect(declinedGroup.isRejectedOrDeclined, isTrue);
      expect(declinedGroup.isPendingInvitation, isFalse);

      // Filtering active groups
      final all = [activeGroup, pendingGroup, rejectedGroup, declinedGroup];
      final activeOnly = all.where((g) => !g.isPendingInvitation && !g.isRejectedOrDeclined).toList();
      expect(activeOnly.length, 1);
      expect(activeOnly.first.id, 1);
    });
  });
}
