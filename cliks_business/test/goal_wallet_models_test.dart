import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/data/models/goal_wallet_models.dart';

void main() {
  group('GoalWallet Model & Serialization Tests', () {
    test('GoalWallet fromJson parses full JSON correctly', () {
      final json = {
        'id': 3,
        'name': 'Advance Tax Q4',
        'target_amount': 100000.00,
        'current_amount': 65000.00,
        'description': 'Income tax advance deposit segregation',
        'status': 'active',
        'created_at': '2026-10-01T00:00:00.000Z',
      };

      final wallet = GoalWallet.fromJson(json);

      expect(wallet.id, '3');
      expect(wallet.name, 'Advance Tax Q4');
      expect(wallet.targetAmount, 100000.0);
      expect(wallet.currentAmount, 65000.0);
      expect(wallet.description, 'Income tax advance deposit segregation');
      expect(wallet.status, 'active');
      expect(wallet.isActive, isTrue);
      expect(wallet.isClaimed, isFalse);
      expect(wallet.isInProgress, isTrue);
      expect(wallet.isTargetMet, isFalse);
      expect(wallet.remainingAmount, 35000.0);
      expect(wallet.progressPercent, 65);
      expect(wallet.statusDisplay, 'IN PROGRESS');
    });

    test(
      'GoalWallet handles missing optional fields and null descriptions',
      () {
        final json = {
          'id': 'w_empty',
          'name': 'Buffer',
          'target_amount': 5000,
          'current_amount': 0,
        };

        final wallet = GoalWallet.fromJson(json);

        expect(wallet.id, 'w_empty');
        expect(wallet.name, 'Buffer');
        expect(wallet.targetAmount, 5000.0);
        expect(wallet.currentAmount, 0.0);
        expect(wallet.description, '');
        expect(wallet.status, 'active');
        expect(wallet.createdAt, isNull);
      },
    );

    test('GoalWallet identifies TARGET MET and FULLY CLAIMED states', () {
      final metJson = {
        'id': '10',
        'name': 'Goal Reached',
        'target_amount': 50000.0,
        'current_amount': 50000.0,
        'status': 'active',
      };
      final metWallet = GoalWallet.fromJson(metJson);
      expect(metWallet.isTargetMet, isTrue);
      expect(metWallet.isInProgress, isFalse);
      expect(metWallet.statusDisplay, 'TARGET MET');
      expect(metWallet.remainingAmount, 0.0);
      expect(metWallet.progressPercent, 100);

      final claimedJson = {
        'id': '11',
        'name': 'Claimed Goal',
        'target_amount': 50000.0,
        'current_amount': 50000.0,
        'claimed_amount': 50000.0,
        'status': 'claimed',
      };
      final claimedWallet = GoalWallet.fromJson(claimedJson);
      expect(claimedWallet.isClaimed, isTrue);
      expect(claimedWallet.isTargetMet, isFalse);
      expect(claimedWallet.statusDisplay, 'FULLY CLAIMED');
    });

    test(
      'GoalWallet handles division by zero safely without producing NaN or Infinity or scientific notation',
      () {
        final json = {
          'id': 'zero',
          'name': 'Zero Target',
          'target_amount': 0,
          'current_amount': 0,
        };
        final wallet = GoalWallet.fromJson(json);
        expect(wallet.progressRatio, 0.0);
        expect(wallet.progressPercent, 0);
        expect(wallet.remainingAmount, 0.0);

        final jsonOverflow = {
          'id': 'overflow',
          'name': 'Printer Overfill',
          'target_amount': 3000,
          'current_amount': 5000,
        };
        final overflowWallet = GoalWallet.fromJson(jsonOverflow);
        expect(overflowWallet.progressPercent, 167);
      },
    );

    test('GoalWalletTransaction parses correctly and formats ledger dates', () {
      final txJson = {
        'id': 109,
        'wallet_id': 71,
        'user_id': 93,
        'amount': '4000',
        'type': 'credit',
        'created_at': '2026-11-26T09:04:43.043Z',
      };

      final tx = GoalWalletTransaction.fromJson(txJson);
      expect(tx.id, '109');
      expect(tx.walletId, '71');
      expect(tx.amount, 4000.0);
      expect(tx.isCredit, isTrue);
      expect(tx.formattedDate, contains('2026'));
      expect(tx.formattedDate, contains('Nov'));

      final dt = DateTime(2026, 9, 25, 14, 14);
      final formatted = GoalWalletTransaction.formatLedgerDate(dt);
      expect(formatted, '25 Sept 2026, 02:14 pm');
    });

    test('CreateGoalWalletRequest serializes valid payload', () {
      final req = CreateGoalWalletRequest(
        name: 'New Asset',
        targetAmount: 75000.0,
        description: 'New workstation fund',
      );
      final json = req.toJson();
      expect(json['name'], 'New Asset');
      expect(json['target_amount'], 75000.0);
      expect(json['description'], 'New workstation fund');
    });
  });
}
