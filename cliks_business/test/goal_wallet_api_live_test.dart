import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/core/network/api_exception.dart';
import 'package:clicks_business_frontend/data/models/goal_wallet_models.dart';
import 'package:clicks_business_frontend/data/repositories/goal_wallet_repository.dart';

void main() {
  test('Live Goal Wallets API - Full End-to-End Integration Lifecycle', () async {
    // 1. Authenticate with active account token
    const bnxToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhcHBfbmFtZSI6IkJOWCBNYWlsIiwic3ViIjoicmF2aW5ldzIwMDRAYm54bWFpbC5jb20iLCJpYXQiOjE3OTMwODM2MTEsImV4cCI6MTc5NTY3NTYxMX0.neyvYkB7aY5zXgI-ehOp36vlaAeuI5BPR0Ho_X1OlV4';
    await TokenService.saveTokens(accessToken: bnxToken, refreshToken: '');
    await TokenService.saveUserInfo(
      email: 'ravinew2004@bnxmail.com',
      name: 'Ravi Kumar',
    );

    // 2. LIST ALL GOAL WALLETS (GET /api/v1/goal-wallets)
    final initialList = await GoalWalletRepository.getGoalWallets();
    print('[LIVE TEST] Initial goal wallets count: ${initialList.length}');
    expect(initialList, isA<List<GoalWallet>>());

    // 3. CREATE GOAL WALLET (POST /api/v1/goal-wallets)
    final createReq = CreateGoalWalletRequest(
      name: 'E2E Advance Tax Q4',
      targetAmount: 20000.0,
      description: 'End-to-End Automated QA Goal Wallet',
    );
    final createdWallet = await GoalWalletRepository.createGoalWallet(
      createReq,
    );
    print(
      '[LIVE TEST] Created Wallet ID: ${createdWallet.id}, Name: ${createdWallet.name}',
    );
    expect(createdWallet.id, isNotEmpty);
    expect(createdWallet.name, 'E2E Advance Tax Q4');
    expect(createdWallet.targetAmount, 20000.0);

    final walletId = createdWallet.id;

    try {
      // 4. GET GOAL WALLET DETAILS (GET /api/v1/goal-wallets/:id)
      final details = await GoalWalletRepository.getGoalWalletDetails(walletId);
      print(
        '[LIVE TEST] Fetched details for ID $walletId: ${details?.name}, balance: ${details?.currentAmount}',
      );
      expect(details, isNotNull);
      expect(details!.id, walletId);

      // 5. UPDATE GOAL WALLET (PATCH /api/v1/goal-wallets/:id)
      final updateReq = UpdateGoalWalletRequest(
        name: 'E2E Advance Tax Q4 - Revised',
        targetAmount: 25000.0,
        description: 'Updated tax reserve note',
      );
      final updatedWallet = await GoalWalletRepository.updateGoalWallet(
        walletId,
        updateReq,
      );
      print(
        '[LIVE TEST] Updated Wallet Name: ${updatedWallet.name}, Target: ${updatedWallet.targetAmount}',
      );
      expect(updatedWallet.name, 'E2E Advance Tax Q4 - Revised');

      // 6. ADD MONEY / ISOLATE FUNDS (POST /api/v1/goal-wallets/:id/add-money)
      final addMoneyReq = AddMoneyGoalWalletRequest(amount: 10000.0);
      final afterAdd = await GoalWalletRepository.addMoney(
        walletId,
        addMoneyReq,
      );
      print(
        '[LIVE TEST] Added Money: current_amount: ${afterAdd.currentAmount}',
      );
      expect(afterAdd.currentAmount, 10000.0);

      // 7. NEGATIVE CLAIM TEST: Attempting to claim before target is met should fail with 400
      try {
        await GoalWalletRepository.claimGoalWallet(walletId);
        fail('Expected premature claim to be rejected by backend');
      } on ApiException catch (e) {
        print(
          '[LIVE TEST] Expected rejection of premature claim: ${e.message}',
        );
        expect(e.statusCode, 400);
        expect(e.message, contains('Target not reached'));
      }

      // Add remaining funds so target is reached (needs ₹15000 more)
      final addRemainingReq = AddMoneyGoalWalletRequest(amount: 15000.0);
      final fullyFunded = await GoalWalletRepository.addMoney(
        walletId,
        addRemainingReq,
      );
      print(
        '[LIVE TEST] Added remaining: current_amount: ${fullyFunded.currentAmount}, target: ${fullyFunded.targetAmount}',
      );
      expect(fullyFunded.currentAmount, 25000.0);
      expect(fullyFunded.isTargetMet, isTrue);

      // 8. CLAIM / RELEASE SEGREGATED VAULT FUNDS (POST /api/v1/goal-wallets/:id/claim)
      final claimRes = await GoalWalletRepository.claimGoalWallet(walletId);
      print('[LIVE TEST] Claim response: $claimRes');
      expect(
        claimRes['status'],
        anyOf(equals('claimed'), equals('success'), isNotNull),
      );

      // Verify status in listing after claim
      final listAfterClaim = await GoalWalletRepository.getGoalWallets();
      final claimedItem = listAfterClaim.firstWhere((w) => w.id == walletId);
      print('[LIVE TEST] Wallet status after claim: ${claimedItem.status}');
      expect(claimedItem.isClaimed, isTrue);
    } finally {
      // 9. DELETE GOAL WALLET (DELETE /api/v1/goal-wallets/:id)
      final deleted = await GoalWalletRepository.deleteGoalWallet(walletId);
      print('[LIVE TEST] Deleted Wallet ID: $walletId, success: $deleted');
      expect(deleted, isTrue);

      final finalList = await GoalWalletRepository.getGoalWallets();
      final exists = finalList.any((w) => w.id == walletId);
      expect(exists, isFalse);
      print('[LIVE TEST] Confirmed wallet $walletId is deleted from backend.');
    }
  });
}
