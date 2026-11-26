import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/models/split_expense_models.dart';
import 'package:clicks_business_frontend/data/repositories/split_collect_repository.dart';

void main() {
  test('Live Split & Collect API - Full End-to-End Integration Lifecycle', () async {
    // 1. Authenticate with active account token
    const bnxToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhcHBfbmFtZSI6IkJOWCBNYWlsIiwic3ViIjoicmF2aW5ldzIwMDRAYm54bWFpbC5jb20iLCJpYXQiOjE3OTMwODM2MTEsImV4cCI6MTc5NTY3NTYxMX0.neyvYkB7aY5zXgI-ehOp36vlaAeuI5BPR0Ho_X1OlV4';
    await TokenService.saveTokens(accessToken: bnxToken, refreshToken: '');
    await TokenService.saveUserInfo(email: 'ravinew2004@bnxmail.com', name: 'Ravi Kumar');

    // 2. LIST ALL SPLIT EXPENSES (GET /api/v1/split-expenses)
    final initialList = await SplitCollectRepository.getSplitExpenses();
    print('[LIVE TEST] Initial tickets count: ${initialList.length}');
    expect(initialList, isA<List<SplitTicket>>());

    // 3. PER-FRIEND SUMMARY (GET /api/v1/split-expenses/summary)
    final summaries = await SplitCollectRepository.getFriendOwedSummary();
    print('[LIVE TEST] Friend summaries count: ${summaries.length}');
    expect(summaries, isA<List<FriendOwedSummary>>());

    // 4. CREATE SPLIT EXPENSE TICKET (POST /api/v1/split-expenses)
    final createReq = CreateSplitExpenseRequest(
      title: 'E2E Test Split Outing',
      totalAmount: 4000.0,
      category: 'Food & Dining',
      splitType: 'equal',
      currency: 'INR',
      description: 'End-to-End QA Automation Test Ticket',
      participants: [
        {'name': 'Ravi Kumar', 'share_amount': 2000.0},
        {'name': 'Arun Kumar', 'share_amount': 2000.0},
      ],
    );
    final createdTicket = await SplitCollectRepository.createSplitExpense(createReq);
    print('[LIVE TEST] Created Ticket ID: ${createdTicket.id}, Title: ${createdTicket.title}');
    expect(createdTicket.id, isNotEmpty);
    expect(createdTicket.title, 'E2E Test Split Outing');

    final ticketId = createdTicket.id;

    try {
      // 5. GET SPLIT EXPENSE DETAILS (GET /api/v1/split-expenses/:id)
      final details = await SplitCollectRepository.getSplitExpenseDetails(ticketId);
      print('[LIVE TEST] Fetched details for ID $ticketId: ${details?.title}');
      expect(details, isNotNull);

      // 6. UPDATE SPLIT EXPENSE (PATCH /api/v1/split-expenses/:id)
      final updatedTicket = await SplitCollectRepository.updateSplitExpense(
        ticketId,
        {
          'title': 'E2E Test Split Outing (Updated)',
          'category': 'Client Relations',
        },
      );
      print('[LIVE TEST] Updated Ticket Title: ${updatedTicket.title}');
      expect(updatedTicket.title, 'E2E Test Split Outing (Updated)');

      // 7. ADD EXPENSE ITEM (POST /api/v1/split-expenses/:id/expenses)
      final expReq = AddExpenseItemRequest(
        description: 'Appetizers & Drinks',
        amount: 2000.0,
        paidBy: 'Ravi Kumar',
        category: 'Food',
        splitType: 'equal',
        shares: {'Ravi Kumar': 1000.0, 'Arun Kumar': 1000.0},
      );
      final addedExpense = await SplitCollectRepository.addExpenseItem(ticketId, expReq);
      print('[LIVE TEST] Added Expense Item: ${addedExpense.id}, Amount: ${addedExpense.amount}');
      expect(addedExpense.id, isNotEmpty);
      expect(addedExpense.amount, 2000.0);

      // 8. ADD PARTICIPANT (POST /api/v1/split-expenses/:id/participants)
      final partReq = AddSplitParticipantRequest(
        name: 'Suresh Raina',
        shareAmount: 1000.0,
      );
      final addedParticipant = await SplitCollectRepository.addParticipant(ticketId, partReq);
      print('[LIVE TEST] Added Participant: ${addedParticipant.name}');
      expect(addedParticipant.name, 'Suresh Raina');

      // 9. SETTLE FRIEND (PATCH /api/v1/split-expenses/settle-friend)
      await SplitCollectRepository.settleFriend('Arun Kumar');
      print('[LIVE TEST] Settle friend executed for Arun Kumar');

      // 10. INVITE MEMBER (POST /api/v1/split-expenses/:id/invite)
      final invReq = InviteMemberRequest(
        email: 'collaborator_test@bnxmail.com',
        role: 'editor',
      );
      await SplitCollectRepository.inviteMember(ticketId, invReq);
      print('[LIVE TEST] Member invitation sent to collaborator_test@bnxmail.com');

      // 11. DELETE EXPENSE ITEM (DELETE /api/v1/split-expenses/:id/expenses/:expenseId)
      await SplitCollectRepository.deleteExpenseItem(ticketId, addedExpense.id);
      print('[LIVE TEST] Deleted Expense Item: ${addedExpense.id}');
    } finally {
      // 12. CLEAN UP: DELETE SPLIT EXPENSE (DELETE /api/v1/split-expenses/:id)
      await SplitCollectRepository.deleteSplitExpense(ticketId);
      print('[LIVE TEST] Deleted Ticket ID: $ticketId successfully.');
    }
  });
}
