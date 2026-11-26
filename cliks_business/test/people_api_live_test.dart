import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/models/people_models.dart';
import 'package:clicks_business_frontend/data/repositories/people_repository.dart';

void main() {
  const activeEmail = 'ravinew2004@bnxmail.com';
  const bnxToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhcHBfbmFtZSI6IkJOWCBNYWlsIiwic3ViIjoicmF2aW5ldzIwMDRAYm54bWFpbC5jb20iLCJpYXQiOjE3OTMwODM2MTEsImV4cCI6MTc5NTY3NTYxMX0.neyvYkB7aY5zXgI-ehOp36vlaAeuI5BPR0Ho_X1OlV4';

  setUp(() async {
    await TokenService.saveTokens(accessToken: bnxToken, refreshToken: '');
    await TokenService.saveUserInfo(email: activeEmail, name: 'Ravi Kumar');
  });

  group('People Network & Escrow Live API E2E Integration Suite', () {
    test('1. Verify GET /api/v1/people contact list & summary retrieval', () async {
      final contacts = await PeopleRepository.getPeople(email: activeEmail);
      print('[LIVE TEST] Fetched ${contacts.length} live contacts');
      expect(contacts, isA<List<PersonContact>>());

      final summary = await PeopleRepository.getPeopleSummary(email: activeEmail);
      print(
        '[LIVE TEST] People Summary: ${summary.totalContacts} contacts, '
        'Receivables: ₹${summary.totalReceivables}, Payables: ₹${summary.totalPayables}',
      );
      expect(summary, isA<PeopleSummary>());
    });

    test('2. Full Contact CRUD Lifecycle (Create -> Get -> Update -> Delete)', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'e2e_contact_$ts@bnxmail.com';

      // 1. CREATE CONTACT
      final createReq = CreatePersonRequest(
        name: 'E2E Test Partner $ts',
        roleType: 'partner',
        relationship: 'Investor',
        phone: '98${(ts % 100000000).toString().padLeft(8, '0')}',
        email: uniqueEmail,
        company: 'Apex Seed Ventures',
        notes: 'Automated integration testing contact',
      );

      final created = await PeopleRepository.createPerson(createReq, email: activeEmail);
      print('[LIVE TEST] Created contact ID: ${created.id}, name: ${created.name}');
      expect(created.id, isNotNull);
      expect(created.name, contains('E2E Test Partner'));
      expect(created.email, uniqueEmail);

      final contactId = created.id;

      try {
        // 2. GET CONTACT DETAILS
        final details = await PeopleRepository.getPersonDetails(contactId, email: activeEmail);
        print('[LIVE TEST] Retrieved details for contact ID: $contactId');
        expect(details, isNotNull);
        expect(details!.id.toString(), contactId.toString());
        expect(details.company, 'Apex Seed Ventures');

        // 3. UPDATE CONTACT (PATCH)
        final updateReq = UpdatePersonRequest(
          relationship: 'Senior Strategic Partner',
          notes: 'Updated via live E2E integration test',
        );
        final updated = await PeopleRepository.updatePerson(contactId, updateReq, email: activeEmail);
        print('[LIVE TEST] Updated contact relationship: ${updated.relationship}');
        expect(updated.relationship, 'Senior Strategic Partner');
      } finally {
        // 4. DELETE CONTACT (DELETE)
        final deleted = await PeopleRepository.deletePerson(contactId, email: activeEmail);
        print('[LIVE TEST] Deleted contact ID $contactId status: $deleted');
        expect(deleted, isTrue);
      }
    });

    test('3. Verify GET /api/v1/people/transactions (Global Ledger)', () async {
      final txs = await PeopleRepository.getPeopleTransactions(email: activeEmail);
      print('[LIVE TEST] Fetched ${txs.length} transactions from Global Ledger');
      expect(txs, isA<List<PersonTransaction>>());
    });

    test('4. Full Repayment Alerts Lifecycle (Create -> Settle -> Delete)', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final tempEmail = 'e2e_rem_$ts@bnxmail.com';

      // First create a contact to associate the reminder with
      final contact = await PeopleRepository.createPerson(
        CreatePersonRequest(
          name: 'Reminder Partner $ts',
          roleType: 'partner',
          phone: '97${(ts % 100000000).toString().padLeft(8, '0')}',
          email: tempEmail,
        ),
        email: activeEmail,
      );

      final contactId = contact.id;

      try {
        // 1. CREATE REMINDER
        final alertReq = CreateRepaymentAlertRequest(
          contactId: contactId,
          targetContact: contact.name,
          claimCap: 15000.0,
          maturityDate: '2026-12-31',
          memoLabel: 'E2E Loan Tranche A',
          status: 'Pending',
        );

        final alert = await PeopleRepository.createRepaymentAlert(alertReq, email: activeEmail);
        print('[LIVE TEST] Created reminder ID: ${alert.id}, target: ${alert.targetContact}');
        expect(alert.id, isNotNull);

        final alertId = alert.id;

        try {
          // 2. UPDATE STATUS (PATCH)
          final updated = await PeopleRepository.updateAlertStatus(
            alertId,
            'settled',
            email: activeEmail,
          );
          print('[LIVE TEST] Updated reminder $alertId status to settled: $updated');
          expect(updated, isTrue);
        } finally {
          // 3. DELETE REMINDER
          final deleted = await PeopleRepository.deleteRepaymentAlert(alertId, email: activeEmail);
          print('[LIVE TEST] Deleted reminder $alertId status: $deleted');
          expect(deleted, isTrue);
        }
      } finally {
        await PeopleRepository.deletePerson(contactId, email: activeEmail);
      }
    });

    test('5. Verify GET /api/v1/people/requests/incoming', () async {
      final reqs = await PeopleRepository.getIncomingRequests(email: activeEmail);
      print('[LIVE TEST] Fetched ${reqs.length} incoming connection requests');
      expect(reqs, isA<List<ConnectionRequest>>());
    });

    test('6. Full Financial Groups Lifecycle (Create -> Update -> Invite -> Tx -> Note -> Delete)', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;

      // 1. CREATE GROUP
      final groupReq = CreateFinancialGroupRequest(
        name: 'E2E Founders Pool $ts',
        description: 'Automated E2E Test Syndicate',
        currency: 'INR',
        targetAmount: 100000.0,
        groupType: 'syndicate',
      );

      final group = await PeopleRepository.createFinancialGroup(groupReq, email: activeEmail);
      print('[LIVE TEST] Created financial group ID: ${group.id}, name: ${group.name}');
      expect(group.id, isNotNull);
      expect(group.name, contains('E2E Founders Pool'));

      final groupId = group.id;

      try {
        // 2. GET GROUP DETAILS
        final details = await PeopleRepository.getGroupDetails(groupId, email: activeEmail);
        print('[LIVE TEST] Retrieved group details for ID $groupId');
        expect(details, isNotNull);
        expect(details!.id.toString(), groupId.toString());

        // 3. UPDATE GROUP (PUT)
        final updateReq = UpdateFinancialGroupRequest(
          name: 'E2E Founders Pool $ts - Revised',
          description: 'Updated syndicate description',
        );
        final updated = await PeopleRepository.updateFinancialGroup(groupId, updateReq, email: activeEmail);
        print('[LIVE TEST] Updated group name: ${updated.name}');
        expect(updated.name, contains('Revised'));

        // 4. INVITE GROUP MEMBER
        final inviteReq = InviteGroupMemberRequest(
          email: 'partner_invite_$ts@bnxmail.com',
          role: 'member',
        );
        final member = await PeopleRepository.inviteGroupMember(groupId, inviteReq, email: activeEmail);
        print('[LIVE TEST] Invited member ID: ${member.id}, name: ${member.name}');
        expect(member.id, isNotNull);

        final memberId = member.id;

        try {
          // 5. ADD GROUP TRANSACTION
          final txReq = const AddGroupTransactionRequest(
            title: 'Initial Seed Capital',
            amount: 25000.0,
            type: 'contribution',
            category: 'Equity Pool',
          );
          final tx = await PeopleRepository.addGroupTransaction(groupId, txReq, email: activeEmail);
          print('[LIVE TEST] Added group transaction ID: ${tx.id}, amount: ₹${tx.amount}');
          expect(tx.id, isNotNull);
          expect(tx.amount, 25000.0);

          // 6. DELETE GROUP TRANSACTION
          final deletedTx = await PeopleRepository.deleteGroupTransaction(
            groupId,
            tx.id,
            email: activeEmail,
          );
          print('[LIVE TEST] Deleted group transaction ${tx.id}: $deletedTx');
          expect(deletedTx, isTrue);

          // 7. SET PRIVATE MEMBER NOTE
          final noteReq = const SetPrivateNoteRequest(
            note: 'Confidential angel investor commitment',
          );
          final note = await PeopleRepository.setPrivateMemberNote(
            groupId,
            memberId,
            noteReq,
            email: activeEmail,
          );
          print('[LIVE TEST] Set private note for member $memberId: ${note.notes}');
          expect(note.notes, 'Confidential angel investor commitment');

          // 8. DELETE PRIVATE MEMBER NOTE
          final deletedNote = await PeopleRepository.deletePrivateMemberNote(
            groupId,
            memberId,
            email: activeEmail,
          );
          print('[LIVE TEST] Deleted private note for member $memberId: $deletedNote');
          expect(deletedNote, isTrue);
        } finally {
          // 9. REMOVE MEMBER
          final removed = await PeopleRepository.removeGroupMember(groupId, memberId, email: activeEmail);
          print('[LIVE TEST] Removed group member $memberId status: $removed');
          expect(removed, isTrue);
        }
      } finally {
        // 10. DELETE GROUP
        final deletedGroup = await PeopleRepository.deleteFinancialGroup(groupId, email: activeEmail);
        print('[LIVE TEST] Deleted group $groupId status: $deletedGroup');
        expect(deletedGroup, isTrue);
      }
    });
  });
}
