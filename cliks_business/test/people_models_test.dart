import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/data/models/people_models.dart';

void main() {
  group('People Module Models Unit Tests', () {
    test('1. PersonContact json serialization and deserialization with string numbers', () {
      final json = {
        'id': 82,
        'user_id': 93,
        'name': 'Shafrin',
        'role_type': 'friend',
        'relationship': 'Colleague',
        'phone': '6381741303',
        'email': 'shafrinm002@bnxmail.com',
        'company': 'Beta Corp',
        'notes': 'Key client partner',
        'status': 'accepted',
        'total_lent': '4000.50',
        'total_borrowed': '1500.00',
        'net_balance': '2500.50',
        'created_at': '2026-11-17T04:50:05.379Z',
      };

      final person = PersonContact.fromJson(json);
      expect(person.id, 82);
      expect(person.userId, 93);
      expect(person.name, 'Shafrin');
      expect(person.roleType, 'friend');
      expect(person.relationship, 'Colleague');
      expect(person.classification, 'COLLEAGUE');
      expect(person.phone, '6381741303');
      expect(person.formattedPhone, '+91 63817 41303');
      expect(person.email, 'shafrinm002@bnxmail.com');
      expect(person.company, 'Beta Corp');
      expect(person.totalLent, 4000.50);
      expect(person.totalBorrowed, 1500.00);
      expect(person.netBalance, 2500.50);
      expect(person.isConnected, isTrue);
      expect(person.initials, 'SH');

      final serialized = person.toJson();
      expect(serialized['id'], 82);
      expect(serialized['name'], 'Shafrin');
      expect(serialized['total_lent'], 4000.50);
    });

    test('2. PersonContact handles nulls and fallback values gracefully', () {
      final json = <String, dynamic>{
        'id': '99',
        'name': 'Only Name',
        'phone': '9876543210',
        'email': 'test@bnxmail.com',
      };

      final person = PersonContact.fromJson(json);
      expect(person.id, 99);
      expect(person.roleType, 'Friend');
      expect(person.relationship, isNull);
      expect(person.classification, 'FRIEND');
      expect(person.company, isNull);
      expect(person.displayCompany, '-');
      expect(person.totalLent, 0.0);
      expect(person.totalBorrowed, 0.0);
      expect(person.netBalance, 0.0);
      expect(person.initials, 'ON');
    });

    test('3. PeopleSummary calculates metrics and percentages safely', () {
      final contacts = [
        const PersonContact(
          id: 1,
          name: 'Person 1',
          roleType: 'friend',
          phone: '1111111111',
          email: 'p1@bnxmail.com',
          totalLent: 10000.0,
          totalBorrowed: 2000.0,
          netBalance: 8000.0,
        ),
        const PersonContact(
          id: 2,
          name: 'Person 2',
          roleType: 'partner',
          phone: '2222222222',
          email: 'p2@bnxmail.com',
          totalLent: 5000.0,
          totalBorrowed: 9000.0,
          netBalance: -4000.0,
        ),
      ];

      final summary = PeopleSummary.fromContacts(contacts);
      expect(summary.totalContacts, 2);
      expect(summary.totalReceivables, 8000.0);
      expect(summary.totalPayables, 4000.0);
      expect(summary.totalLent, 15000.0);
      expect(summary.totalBorrowed, 11000.0);

      // Collection %: (totalLent - totalReceivables) / totalLent * 100
      // (15000 - 8000) / 15000 * 100 = 7000 / 15000 * 100 = 46.666%
      expect(summary.collectionPercentage, closeTo(46.67, 0.01));

      // Settlement %: (totalBorrowed - totalPayables) / totalBorrowed * 100
      // (11000 - 4000) / 11000 * 100 = 7000 / 11000 * 100 = 63.636%
      expect(summary.settlementPercentage, closeTo(63.64, 0.01));

      // Zero denominator check
      const zeroSummary = PeopleSummary();
      expect(zeroSummary.collectionPercentage, 0.0);
      expect(zeroSummary.settlementPercentage, 0.0);
    });

    test('4. PersonTransaction parses correctly from backend response', () {
      final json = {
        'id': 109,
        'person_id': 82,
        'user_id': 93,
        'type': 'lent',
        'amount': '4000.00',
        'description': 'Short-term equipment advance',
        'category': 'Equipment',
        'date': '2026-11-17',
        'status': 'pending',
        'person_name': 'Shafrin',
      };

      final tx = PersonTransaction.fromJson(json);
      expect(tx.id, 109);
      expect(tx.personId, 82);
      expect(tx.personName, 'Shafrin');
      expect(tx.type, 'lent');
      expect(tx.isLent, isTrue);
      expect(tx.isBorrowed, isFalse);
      expect(tx.amount, 4000.0);
      expect(tx.notes, 'Short-term equipment advance');
      expect(tx.date, '2026-11-17');
    });

    test('5. RepaymentAlert parses and serializes correctly', () {
      final json = {
        'id': 14,
        'contact_id': 5,
        'target_contact': 'Kiran Kumar',
        'claim_cap': '25000.00',
        'maturity_date': '2026-12-15',
        'memo_label': 'Q4 Short-term Bridge Repayment',
        'status': 'Pending',
      };

      final alert = RepaymentAlert.fromJson(json);
      expect(alert.id, 14);
      expect(alert.contactId, 5);
      expect(alert.targetContact, 'Kiran Kumar');
      expect(alert.claimCap, 25000.00);
      expect(alert.maturityDate, '2026-12-15');
      expect(alert.memoLabel, 'Q4 Short-term Bridge Repayment');
      expect(alert.isPending, isTrue);
      expect(alert.isSettled, isFalse);
    });

    test('6. ConnectionRequest parses from incoming API response', () {
      final json = {
        'id': 8,
        'from_user_id': 22,
        'from_name': 'Suresh Raina',
        'from_email': 'suresh@bnxmail.com',
        'created_at': '2026-11-22T08:00:00.000Z',
      };

      final req = ConnectionRequest.fromJson(json);
      expect(req.id, 8);
      expect(req.fromUserId, 22);
      expect(req.fromName, 'Suresh Raina');
      expect(req.fromEmail, 'suresh@bnxmail.com');
      expect(req.createdAt, isNotNull);
    });

    test('7. FinancialGroup parses with nested members and transactions', () {
      final json = {
        'id': 5,
        'created_by': 93,
        'name': 'Retail Syndicate',
        'description': 'Shared expense pool',
        'group_type': 'syndicate',
        'currency': 'INR',
        'target_amount': '500000.00',
        'total_contributed': '150000.00',
        'total_expenses': '25000.00',
        'total_loans': '0',
        'status': 'active',
        'members': [
          {
            'id': 14,
            'group_id': 5,
            'user_id': 93,
            'email': 'user@cliks.com',
            'name': 'user',
            'role': 'admin',
            'status': 'accepted',
            'total_contributed': 100000.0,
            'net_balance': 100000.0,
          },
          {
            'id': 15,
            'group_id': 5,
            'email': 'shafrin@bnxmail.com',
            'name': 'Shafrin',
            'role': 'member',
            'status': 'accepted',
            'total_contributed': 50000.0,
            'net_balance': 50000.0,
            'private_note': {
              'id': 6,
              'amount': 30000.0,
              'notes': 'Agreed contribution commitment',
            },
          },
        ],
        'transactions': [
          {
            'id': 61,
            'group_id': 5,
            'type': 'expense',
            'amount': 400.0,
            'title': 'Blueprint Fee',
            'category': 'Design',
          },
        ],
      };

      final group = FinancialGroup.fromJson(json);
      expect(group.id, 5);
      expect(group.name, 'Retail Syndicate');
      expect(group.targetAmount, 500000.0);
      expect(group.totalContributed, 150000.0);
      expect(group.totalExpenses, 25000.0);
      expect(group.completionPercentage, 30.0);
      expect(group.netFundInHand, 125000.0);
      expect(group.members.length, 2);
      expect(group.members[0].isAdmin, isTrue);
      expect(group.members[1].privateNote?.amount, 30000.0);
      expect(group.transactions.length, 1);
      expect(group.transactions[0].title, 'Blueprint Fee');
    });

    test('8. Request DTOs serialize valid schemas', () {
      final createPerson = CreatePersonRequest(
        name: 'Kiran Kumar',
        roleType: 'partner',
        relationship: 'Investor',
        phone: '9876543210',
        email: 'kiran@bnxmail.com',
        company: 'Kiran Ventures',
        notes: 'Angel investor',
      );
      final personJson = createPerson.toJson();
      expect(personJson['name'], 'Kiran Kumar');
      expect(personJson['email'], 'kiran@bnxmail.com');

      final updateGroup = UpdateFinancialGroupRequest(
        name: 'Updated Group',
        description: 'New notes',
        targetAmount: 75000.0,
      );
      final groupJson = updateGroup.toJson();
      expect(groupJson['name'], 'Updated Group');
      expect(groupJson['title'], 'Updated Group');
      expect(groupJson['target_amount'], 75000.0);

      final inviteReq = InviteGroupMemberRequest(
        email: 'partner@bnxmail.com',
        role: 'member',
      );
      expect(inviteReq.toJson()['email'], 'partner@bnxmail.com');

      final addTxReq = AddGroupTransactionRequest(
        title: 'Architectural Blueprint',
        amount: 40000.0,
        type: 'expense',
      );
      expect(addTxReq.toJson()['title'], 'Architectural Blueprint');
      expect(addTxReq.toJson()['type'], 'expense');
    });
  });
}
