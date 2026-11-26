import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/data/models/split_expense_models.dart';

void main() {
  group('Split & Collect Data Models and Serialization Tests', () {
    test('SplitParticipant serialization and deserialization', () {
      final json = {
        'id': 1,
        'name': 'Ravi Kumar',
        'email': 'ravinew2004@bnxmail.com',
        'role': 'admin',
        'status': 'accepted',
        'isAdmin': true,
        'share_amount': 2500.0,
        'settled': 1,
      };

      final p = SplitParticipant.fromJson(json);
      expect(p.id, 1);
      expect(p.name, 'Ravi Kumar');
      expect(p.email, 'ravinew2004@bnxmail.com');
      expect(p.isAdmin, isTrue);
      expect(p.isCreator, isTrue);
      expect(p.isPending, isFalse);
      expect(p.shareAmount, 2500.0);
      expect(p.settled, isTrue);

      final map = p.toMap();
      expect(map['name'], 'Ravi Kumar');
      expect(map['role'], 'Admin');
      expect(map['isCreator'], isTrue);
    });

    test('SplitExpenseItem serialization and settlement detection', () {
      final jsonNormal = {
        'id': 'exp-12345',
        'split_ticket_id': 'split-999',
        'title': 'Dinner Bill',
        'amount': 4000.0,
        'paidBy': 'Ravi',
        'category': 'Food',
        'splitType': 'equal',
        'shares': {'Ravi': 2000.0, 'Arun': 2000.0},
        'documentName': 'bill.pdf',
        'documentUrl': 'https://cliks.beta-softnet.com/uploads/bill.pdf',
      };

      final item = SplitExpenseItem.fromJson(jsonNormal);
      expect(item.id, 'exp-12345');
      expect(item.title, 'Dinner Bill');
      expect(item.amount, 4000.0);
      expect(item.shares['Arun'], 2000.0);
      expect(item.isSettlement, isFalse);
      expect(item.documentName, 'bill.pdf');

      final jsonSettlement = {
        'id': 'exp-settle-123',
        'title': 'Settlement for Dinner: Arun paid Ravi',
        'amount': 2000.0,
        'paidBy': 'Arun',
        'category': 'Settlement',
        'shares': {'Ravi': 2000.0},
      };

      final settleItem = SplitExpenseItem.fromJson(jsonSettlement);
      expect(settleItem.isSettlement, isTrue);
    });

    test('SplitTicket complete parsing with expenses and settlements', () {
      final json = {
        'id': 'split-100',
        'user_id': 73,
        'title': 'Goa Offsite Trip',
        'currency': 'INR',
        'description': 'Team annual gathering',
        'total_amount': 50000.0,
        'participants': [
          {'name': 'Ravi', 'role': 'admin', 'status': 'accepted', 'isAdmin': true},
          {'name': 'Arun', 'role': 'viewer', 'status': 'accepted', 'isAdmin': false},
        ],
        'expenses': [
          {
            'id': 'exp-1',
            'title': 'Hotel Resort Stay',
            'amount': 30000.0,
            'paidBy': 'Ravi',
            'shares': {'Ravi': 15000.0, 'Arun': 15000.0},
          },
          {
            'id': 'exp-settle-1',
            'title': 'Settlement: Arun paid Ravi',
            'amount': 15000.0,
            'paidBy': 'Arun',
            'shares': {'Ravi': 15000.0},
          },
        ],
      };

      final ticket = SplitTicket.fromJson(json);
      expect(ticket.id, 'split-100');
      expect(ticket.title, 'Goa Offsite Trip');
      expect(ticket.currency, 'INR');
      expect(ticket.participants.length, 2);
      expect(ticket.expenses.length, 1); // regular expense
      expect(ticket.settlements.length, 1); // extracted settlement
      expect(ticket.settlements.first.debtor, 'Arun');
      expect(ticket.settlements.first.creditor, 'Ravi');
      expect(ticket.totalExpenseAmount, 30000.0);

      final uiMap = ticket.toMap();
      expect(uiMap['id'], 'split-100');
      expect(uiMap['participants'], ['Ravi', 'Arun']);
      expect(uiMap['budget'], 50000.0);
      expect((uiMap['expenses'] as List).length, 1);
      expect((uiMap['settlements'] as List).length, 1);
    });

    test('FriendOwedSummary deserialization', () {
      final json = {
        'name': 'Arun Kumar',
        'total_owed': 2000.0,
        'unsettled_splits_count': 1,
      };

      final summary = FriendOwedSummary.fromJson(json);
      expect(summary.name, 'Arun Kumar');
      expect(summary.totalOwed, 2000.0);
      expect(summary.unsettledSplitsCount, 1);
    });

    test('DTO request JSON schemas match API specifications', () {
      final createReq = CreateSplitExpenseRequest(
        title: 'Vendor Dinner',
        totalAmount: 6000.0,
        category: 'Food & Dining',
        splitType: 'equal',
        participants: [
          {'name': 'Ravi Kumar', 'share_amount': 2000.0},
          {'name': 'Arun Kumar', 'share_amount': 2000.0},
        ],
      );
      final createJson = createReq.toJson();
      expect(createJson['title'], 'Vendor Dinner');
      expect(createJson['total_amount'], 6000.0);
      expect(createJson['split_type'], 'equal');
      expect((createJson['participants'] as List).length, 2);

      final addExpReq = AddExpenseItemRequest(
        description: 'Starters & Mocktails',
        amount: 2500.0,
        paidBy: 'Ravi Kumar',
      );
      final addExpJson = addExpReq.toJson();
      expect(addExpJson['title'], 'Starters & Mocktails');
      expect(addExpJson['description'], 'Starters & Mocktails');
      expect(addExpJson['amount'], 2500.0);
      expect(addExpJson['paid_by'], 'Ravi Kumar');

      final inviteReq = InviteMemberRequest(
        email: 'colleague@bnxmail.com',
        role: 'editor',
      );
      final inviteJson = inviteReq.toJson();
      expect(inviteJson['email'], 'colleague@bnxmail.com');
      expect(inviteJson['role'], 'editor');
    });
  });
}
