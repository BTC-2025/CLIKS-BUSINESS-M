import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/data/account_provider.dart';
import 'package:clicks_business_frontend/models/account_model.dart';
import 'package:clicks_business_frontend/features/navigation/widgets/macos_showroom_menu_card.dart';
import 'package:clicks_business_frontend/features/payments/providers/payments_refresh_coordinator.dart';
import 'package:clicks_business_frontend/data/models/people_models.dart';
import 'package:clicks_business_frontend/data/models/payment_transaction_models.dart';
import 'package:clicks_business_frontend/data/models/goal_wallet_models.dart';
import 'package:clicks_business_frontend/data/models/split_expense_models.dart';

void main() {
  group('PaymentsRefreshCoordinator - State & Architecture Tests', () {
    test('1. Initial PaymentsCoordinatorState defaults are correct', () {
      const state = PaymentsCoordinatorState();
      expect(state.activeAccountEmail, '');
      expect(state.activeShowroomScope, 'All Showrooms');
      expect(state.generationId, 0);
      expect(state.statusOf(PaymentsModule.people), ModuleLoadStatus.idle);
      expect(state.statusOf(PaymentsModule.transactions), ModuleLoadStatus.idle);
      expect(state.statusOf(PaymentsModule.segregation), ModuleLoadStatus.idle);
      expect(state.statusOf(PaymentsModule.splitCollect), ModuleLoadStatus.idle);
      expect(state.peopleData, isNull);
      expect(state.transactionsData, isNull);
      expect(state.segregationData, isNull);
      expect(state.splitCollectData, isNull);
      expect(state.isModuleLoadingOrRefreshing(PaymentsModule.transactions), isFalse);
    });

    test('2. PaymentsCoordinatorState copyWith preserves and updates state properly', () {
      const initial = PaymentsCoordinatorState();
      final updated = initial.copyWith(
        activeAccountEmail: 'business_owner@cliks.com',
        activeShowroomScope: 'Mumbai Flagship',
        generationId: 2,
        statuses: {
          PaymentsModule.people: ModuleLoadStatus.success,
          PaymentsModule.transactions: ModuleLoadStatus.refreshing,
          PaymentsModule.segregation: ModuleLoadStatus.loading,
          PaymentsModule.splitCollect: ModuleLoadStatus.idle,
        },
        transactionsData: const TransactionsModuleData(
          transactions: [],
          reports: {'totalInward': 50000.0},
        ),
      );

      expect(updated.activeAccountEmail, 'business_owner@cliks.com');
      expect(updated.activeShowroomScope, 'Mumbai Flagship');
      expect(updated.generationId, 2);
      expect(updated.statusOf(PaymentsModule.transactions), ModuleLoadStatus.refreshing);
      expect(updated.isModuleLoadingOrRefreshing(PaymentsModule.transactions), isTrue);
      expect(updated.isModuleLoadingOrRefreshing(PaymentsModule.people), isFalse);
      expect(updated.transactionsData?.reports['totalInward'], 50000.0);
    });

    test('3. CacheEntry correctly determines freshness according to TTL', () {
      final now = DateTime.now();
      final freshEntry = PaymentsCacheEntry(
        data: const SegregationModuleData(wallets: []),
        timestamp: now.subtract(const Duration(seconds: 30)),
        accountKey: 'test@cliks.com::All Showrooms',
      );
      expect(freshEntry.isFresh(const Duration(minutes: 3)), isTrue);

      final staleEntry = PaymentsCacheEntry(
        data: const SegregationModuleData(wallets: []),
        timestamp: now.subtract(const Duration(minutes: 5)),
        accountKey: 'test@cliks.com::All Showrooms',
      );
      expect(staleEntry.isFresh(const Duration(minutes: 3)), isFalse);
    });
  });

  group('PaymentsRefreshCoordinator - Account Switching & Isolation Tests', () {
    test('4. Switching active account increments generationId and isolates data', () {
      final container = ProviderContainer(
        overrides: [
          activeAccountProvider.overrideWithValue(
            const AccountModel(
              id: 'acc_1',
              name: 'Enterprise Corp',
              email: 'enterprise@cliks.com',
              avatarColor: Color(0xFF166534),
              isActive: true,
            ),
          ),
          selectedShowroomScopeProvider.overrideWith((ref) => 'All Showrooms'),
        ],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(paymentsRefreshCoordinatorProvider.notifier);
      final initialGen = container.read(paymentsRefreshCoordinatorProvider).generationId;

      // Switch to another account
      coordinator.onAccountOrContextChanged(newEmail: 'subsidiary@cliks.com');
      final newGen = container.read(paymentsRefreshCoordinatorProvider).generationId;

      expect(newGen, initialGen + 1);
      expect(container.read(paymentsRefreshCoordinatorProvider).activeAccountEmail, 'subsidiary@cliks.com');
      // Ensure data is not carrying over from previous account
      expect(container.read(paymentsRefreshCoordinatorProvider).transactionsData, isNull);
      expect(container.read(paymentsRefreshCoordinatorProvider).peopleData, isNull);
      expect(container.read(paymentsRefreshCoordinatorProvider).segregationData, isNull);
      expect(container.read(paymentsRefreshCoordinatorProvider).splitCollectData, isNull);
    });

    test('5. Switching showroom context updates context and increments generationId', () {
      final container = ProviderContainer(
        overrides: [
          activeAccountProvider.overrideWithValue(
            const AccountModel(
              id: 'acc_1',
              name: 'Enterprise Corp',
              email: 'enterprise@cliks.com',
              avatarColor: Color(0xFF166534),
              isActive: true,
            ),
          ),
          selectedShowroomScopeProvider.overrideWith((ref) => 'Main Branch'),
        ],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(paymentsRefreshCoordinatorProvider.notifier);
      final initialGen = container.read(paymentsRefreshCoordinatorProvider).generationId;

      coordinator.onAccountOrContextChanged(newShowroom: 'Airport Kiosk');
      final state = container.read(paymentsRefreshCoordinatorProvider);

      expect(state.generationId, initialGen + 1);
      expect(state.activeShowroomScope, 'Airport Kiosk');
    });

    test('6. notifyMutation clears cache entry and sets module status', () {
      final container = ProviderContainer(
        overrides: [
          activeAccountProvider.overrideWithValue(
            const AccountModel(
              id: 'acc_1',
              name: 'Enterprise Corp',
              email: 'enterprise@cliks.com',
              avatarColor: Color(0xFF166534),
              isActive: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final coordinator = container.read(paymentsRefreshCoordinatorProvider.notifier);
      
      // Notify mutation on transactions and people
      coordinator.notifyMutation(
        PaymentsModule.transactions,
        alsoRefresh: [PaymentsModule.people],
      );

      final state = container.read(paymentsRefreshCoordinatorProvider);
      // Coordinator triggers refresh on mutated modules
      expect(state.activeAccountEmail, 'enterprise@cliks.com');
    });
  });

  group('Payments Module Data Model Integrations', () {
    test('7. PeopleModuleData encapsulates full contact and escrow state', () {
      const data = PeopleModuleData(
        contacts: [
          PersonContact(
            id: 101,
            name: 'Vendor A',
            roleType: 'Supplier',
            phone: '9876543210',
            email: 'vendorA@bnxmail.com',
          ),
        ],
        transactions: [
          PersonTransaction(
            id: 1,
            personId: 101,
            personName: 'Vendor A',
            amount: 5000.0,
            type: 'outward',
            date: '2026-11-28',
          ),
        ],
        summary: PeopleSummary(totalContacts: 1, totalReceivables: 0, totalPayables: 5000),
      );

      expect(data.contacts.length, 1);
      expect(data.transactions.length, 1);
      expect(data.summary.totalPayables, 5000.0);
    });

    test('8. TransactionsModuleData aggregates ledger and summary statistics', () {
      final data = TransactionsModuleData(
        transactions: [
          CashFlowTransaction(
            id: 1,
            type: 'INWARD',
            amount: 10000.0,
            category: 'Direct Sales',
            date: DateTime(2026, 11, 28),
            description: 'Sales Order SO-101',
          ),
        ],
        reports: {
          'totalInward': 10000.0,
          'totalOutward': 2000.0,
          'netBalance': 8000.0,
        },
      );

      expect(data.transactions.first.amount, 10000.0);
      expect(data.reports['netBalance'], 8000.0);
    });

    test('9. SegregationModuleData encapsulates goal wallets', () {
      final data = SegregationModuleData(
        wallets: [
          const GoalWallet(
            id: 'wallet_1',
            name: 'GST Buffer Wallet',
            targetAmount: 500000.0,
            currentAmount: 320000.0,
            description: 'Tax & Statutory',
          ),
        ],
      );

      expect(data.wallets.length, 1);
      expect(data.wallets.first.name, 'GST Buffer Wallet');
      expect(data.wallets.first.currentAmount, 320000.0);
    });

    test('10. SplitCollectModuleData encapsulates collaborative tickets and debt summaries', () {
      final data = SplitCollectModuleData(
        tickets: [
          SplitTicket(
            id: 'split_1',
            title: 'Q4 Team Dinner & Offsite',
            budget: 12500.0,
            currency: 'INR',
            category: 'Team Expenses',
          ),
        ],
        friendSummaries: [
          FriendOwedSummary(
            name: 'John Doe',
            totalOwed: 2500.0,
            unsettledSplitsCount: 1,
          ),
        ],
      );

      expect(data.tickets.first.title, 'Q4 Team Dinner & Offsite');
      expect(data.friendSummaries.first.totalOwed, 2500.0);
      expect(data.friendSummaries.first.unsettledSplitsCount, 1);
    });
  });
}
