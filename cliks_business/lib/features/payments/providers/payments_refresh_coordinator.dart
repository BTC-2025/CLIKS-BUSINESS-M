import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/navigation_provider.dart';
import '../../../data/account_provider.dart';
import '../../../models/account_model.dart';
import '../../../data/models/goal_wallet_models.dart';
import '../../../data/models/payment_transaction_models.dart';
import '../../../data/models/people_models.dart';
import '../../../data/models/split_expense_models.dart';
import '../../../data/repositories/goal_wallet_repository.dart';
import '../../../data/repositories/payment_transaction_repository.dart';
import '../../../data/repositories/people_repository.dart';
import '../../../data/repositories/split_collect_repository.dart';
import '../../navigation/widgets/macos_showroom_menu_card.dart';

/// The 4 main modules comprising the Payments section.
enum PaymentsModule {
  people,
  transactions,
  segregation,
  splitCollect,
}

/// Loading status for an individual Payments module.
enum ModuleLoadStatus {
  idle,
  loading,
  refreshing,
  success,
  error,
}

// ─────────────────────────────────────────────────────────────────────────────
// MODULE DATA SNAPSHOTS (Immutable)
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class PeopleModuleData {
  final List<PersonContact> contacts;
  final List<PersonTransaction> transactions;
  final List<RepaymentAlert> reminders;
  final List<ConnectionRequest> incomingRequests;
  final List<FinancialGroup> groups;
  final List<GroupInvitation> incomingGroupRequests;
  final PeopleSummary summary;

  const PeopleModuleData({
    this.contacts = const [],
    this.transactions = const [],
    this.reminders = const [],
    this.incomingRequests = const [],
    this.groups = const [],
    this.incomingGroupRequests = const [],
    this.summary = const PeopleSummary(),
  });
}

@immutable
class TransactionsModuleData {
  final List<CashFlowTransaction> transactions;
  final Map<String, dynamic> reports;
  final List<CashFlowAccount> bankAccounts;
  final OutstandingSummaryStats? stats;
  final List<CashFlowAccount> combinedAccounts;
  final List<Map<String, dynamic>> overdueInvoices;

  const TransactionsModuleData({
    this.transactions = const [],
    this.reports = const {},
    this.bankAccounts = const [],
    this.stats,
    this.combinedAccounts = const [],
    this.overdueInvoices = const [],
  });
}

@immutable
class SegregationModuleData {
  final List<GoalWallet> wallets;

  const SegregationModuleData({
    this.wallets = const [],
  });
}

@immutable
class SplitCollectModuleData {
  final List<SplitTicket> tickets;
  final List<FriendOwedSummary> friendSummaries;

  const SplitCollectModuleData({
    this.tickets = const [],
    this.friendSummaries = const [],
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CACHE CONTAINER
// ─────────────────────────────────────────────────────────────────────────────

class PaymentsCacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final String accountKey;

  const PaymentsCacheEntry({
    required this.data,
    required this.timestamp,
    required this.accountKey,
  });

  bool isFresh(Duration ttl) =>
      DateTime.now().difference(timestamp) < ttl;
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE OF THE COORDINATOR
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class PaymentsCoordinatorState {
  final String activeAccountEmail;
  final String activeShowroomScope;
  final int generationId;
  final Map<PaymentsModule, ModuleLoadStatus> statuses;
  final Map<PaymentsModule, String?> errorMessages;
  final Map<PaymentsModule, DateTime?> lastUpdated;

  final PeopleModuleData? peopleData;
  final TransactionsModuleData? transactionsData;
  final SegregationModuleData? segregationData;
  final SplitCollectModuleData? splitCollectData;

  const PaymentsCoordinatorState({
    this.activeAccountEmail = '',
    this.activeShowroomScope = 'All Showrooms',
    this.generationId = 0,
    this.statuses = const {
      PaymentsModule.people: ModuleLoadStatus.idle,
      PaymentsModule.transactions: ModuleLoadStatus.idle,
      PaymentsModule.segregation: ModuleLoadStatus.idle,
      PaymentsModule.splitCollect: ModuleLoadStatus.idle,
    },
    this.errorMessages = const {
      PaymentsModule.people: null,
      PaymentsModule.transactions: null,
      PaymentsModule.segregation: null,
      PaymentsModule.splitCollect: null,
    },
    this.lastUpdated = const {
      PaymentsModule.people: null,
      PaymentsModule.transactions: null,
      PaymentsModule.segregation: null,
      PaymentsModule.splitCollect: null,
    },
    this.peopleData,
    this.transactionsData,
    this.segregationData,
    this.splitCollectData,
  });

  ModuleLoadStatus statusOf(PaymentsModule module) =>
      statuses[module] ?? ModuleLoadStatus.idle;

  bool isModuleLoadingOrRefreshing(PaymentsModule module) {
    final s = statusOf(module);
    return s == ModuleLoadStatus.loading || s == ModuleLoadStatus.refreshing;
  }

  PaymentsCoordinatorState copyWith({
    String? activeAccountEmail,
    String? activeShowroomScope,
    int? generationId,
    Map<PaymentsModule, ModuleLoadStatus>? statuses,
    Map<PaymentsModule, String?>? errorMessages,
    Map<PaymentsModule, DateTime?>? lastUpdated,
    PeopleModuleData? peopleData,
    bool clearPeopleData = false,
    TransactionsModuleData? transactionsData,
    bool clearTransactionsData = false,
    SegregationModuleData? segregationData,
    bool clearSegregationData = false,
    SplitCollectModuleData? splitCollectData,
    bool clearSplitCollectData = false,
  }) {
    return PaymentsCoordinatorState(
      activeAccountEmail: activeAccountEmail ?? this.activeAccountEmail,
      activeShowroomScope: activeShowroomScope ?? this.activeShowroomScope,
      generationId: generationId ?? this.generationId,
      statuses: statuses ?? this.statuses,
      errorMessages: errorMessages ?? this.errorMessages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      peopleData: clearPeopleData ? null : (peopleData ?? this.peopleData),
      transactionsData: clearTransactionsData ? null : (transactionsData ?? this.transactionsData),
      segregationData: clearSegregationData ? null : (segregationData ?? this.segregationData),
      splitCollectData: clearSplitCollectData ? null : (splitCollectData ?? this.splitCollectData),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CENTRAL COORDINATOR NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class PaymentsRefreshCoordinator extends StateNotifier<PaymentsCoordinatorState> {
  final Ref ref;

  /// In-memory cache keyed by "${accountEmail}::${showroomScope}::${module.name}"
  final Map<String, PaymentsCacheEntry<dynamic>> _cache = {};

  /// In-flight dedup map keyed by "${generationId}::${module.name}"
  final Map<String, Future<dynamic>> _inFlight = {};

  /// Freshness threshold before stale-while-revalidate triggers
  static const Duration defaultFreshnessTtl = Duration(minutes: 3);

  /// Concurrency limit for background API calls
  static const int maxConcurrentRequests = 2;
  int _activeRequests = 0;
  final List<_QueuedTask> _requestQueue = [];

  PaymentsRefreshCoordinator(this.ref) : super(const PaymentsCoordinatorState()) {
    _initObservers();
  }

  void _initObservers() {
    // 1. Observe active account switch
    ref.listen<AccountModel>(activeAccountProvider, (prev, next) {
      final prevEmail = prev?.email.trim().toLowerCase() ?? '';
      final nextEmail = next.email.trim().toLowerCase();
      if (prevEmail != nextEmail) {
        onAccountOrContextChanged(newEmail: nextEmail);
      }
    });

    // 2. Observe showroom scope change
    ref.listen<String>(selectedShowroomScopeProvider, (prev, next) {
      if (prev != next) {
        onAccountOrContextChanged(newShowroom: next);
      }
    });

    // 3. Observe navigation to Payments routes to trigger prefetch
    ref.listen<NavigationState>(navigationProvider, (prev, next) {
      if (next.currentModule == AppModule.payments) {
        final activeModule = _routeToModule(next.currentRoute);
        if (activeModule != null) {
          warmupPayments(activeModule: activeModule);
        }
      }
    });

    // Initial sync
    final initialEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();
    final initialShowroom = ref.read(selectedShowroomScopeProvider);
    state = state.copyWith(
      activeAccountEmail: initialEmail,
      activeShowroomScope: initialShowroom,
    );
  }

  PaymentsModule? _routeToModule(AppRoute route) {
    switch (route) {
      case AppRoute.people:
        return PaymentsModule.people;
      case AppRoute.transaction:
        return PaymentsModule.transactions;
      case AppRoute.segregation:
      case AppRoute.wallet:
        return PaymentsModule.segregation;
      case AppRoute.splitCollect:
        return PaymentsModule.splitCollect;
      default:
        return null;
    }
  }

  String _buildContextKey([String? email, String? showroom]) {
    final em = (email ?? state.activeAccountEmail).trim().toLowerCase();
    final sh = (showroom ?? state.activeShowroomScope).trim();
    return '$em::$sh';
  }

  String _buildCacheKey(PaymentsModule module, [String? email, String? showroom]) {
    return '${_buildContextKey(email, showroom)}::${module.name}';
  }

  /// Called whenever account or showroom changes.
  /// 1. Increments generation ID to reject any in-flight response from the old account.
  /// 2. Clears in-memory data for the new account unless cached.
  /// 3. Eagerly starts background fetch for the new account.
  void onAccountOrContextChanged({String? newEmail, String? newShowroom}) {
    final targetEmail = (newEmail ?? state.activeAccountEmail).trim().toLowerCase();
    final targetShowroom = (newShowroom ?? state.activeShowroomScope).trim();

    final nextGeneration = state.generationId + 1;
    _inFlight.clear();
    _requestQueue.clear();

    final newCtxKey = '$targetEmail::$targetShowroom';

    // Check if new account already has warm cache entries
    final peopleEntry = _cache['$newCtxKey::${PaymentsModule.people.name}'];
    final txEntry = _cache['$newCtxKey::${PaymentsModule.transactions.name}'];
    final segEntry = _cache['$newCtxKey::${PaymentsModule.segregation.name}'];
    final splitEntry = _cache['$newCtxKey::${PaymentsModule.splitCollect.name}'];

    state = PaymentsCoordinatorState(
      activeAccountEmail: targetEmail,
      activeShowroomScope: targetShowroom,
      generationId: nextGeneration,
      statuses: const {
        PaymentsModule.people: ModuleLoadStatus.idle,
        PaymentsModule.transactions: ModuleLoadStatus.idle,
        PaymentsModule.segregation: ModuleLoadStatus.idle,
        PaymentsModule.splitCollect: ModuleLoadStatus.idle,
      },
      errorMessages: const {},
      lastUpdated: {
        PaymentsModule.people: peopleEntry?.timestamp,
        PaymentsModule.transactions: txEntry?.timestamp,
        PaymentsModule.segregation: segEntry?.timestamp,
        PaymentsModule.splitCollect: splitEntry?.timestamp,
      },
      peopleData: peopleEntry?.data as PeopleModuleData?,
      transactionsData: txEntry?.data as TransactionsModuleData?,
      segregationData: segEntry?.data as SegregationModuleData?,
      splitCollectData: splitEntry?.data as SplitCollectModuleData?,
    );

    // If currently in Payments, prefetch immediately for the new account
    final nav = ref.read(navigationProvider);
    if (nav.currentModule == AppModule.payments) {
      final active = _routeToModule(nav.currentRoute) ?? PaymentsModule.people;
      warmupPayments(activeModule: active);
    }
  }

  /// Warmup / lazy prefetch: loads the active module first, then queues remaining modules.
  Future<void> warmupPayments({required PaymentsModule activeModule}) async {
    // 1. High priority for currently visible module
    loadModule(activeModule);

    // 2. Low priority background prefetch for remaining modules
    for (final mod in PaymentsModule.values) {
      if (mod != activeModule) {
        _queueLowPriorityPrefetch(mod);
      }
    }
  }

  void _queueLowPriorityPrefetch(PaymentsModule module) {
    final cacheKey = _buildCacheKey(module);
    final cached = _cache[cacheKey];
    if (cached != null && cached.isFresh(defaultFreshnessTtl)) {
      return; // Already fresh in memory
    }
    // Schedule asynchronously without blocking UI
    Future.microtask(() {
      if (!mounted) return;
      loadModule(module, isManualReload: false);
    });
  }

  /// Triggers loading or refreshing for an individual Payments module.
  /// If [isManualReload] is true:
  /// - Bypasses cache
  /// - Sets status to `refreshing` (spinning indicator)
  /// - Replaces cached data on success
  /// - Retains existing UI data on error with message
  Future<void> loadModule(
    PaymentsModule module, {
    bool isManualReload = false,
  }) async {
    final currentGen = state.generationId;
    final targetEmail = state.activeAccountEmail;
    final targetShowroom = state.activeShowroomScope;
    final cacheKey = _buildCacheKey(module, targetEmail, targetShowroom);
    final inFlightKey = '$currentGen::${module.name}';

    // 1. Check existing cache if not manual reload
    if (!isManualReload) {
      final cached = _cache[cacheKey];
      if (cached != null) {
        _applyCachedDataToState(module, cached.data);
        if (cached.isFresh(defaultFreshnessTtl)) {
          // Fresh: serve immediately, no network needed
          _updateModuleStatus(module, ModuleLoadStatus.success);
          return;
        }
        // Stale-while-revalidate: served cached data above, now revalidate in background
      }
    }

    // 2. Request deduplication: return existing in-flight future if already running
    if (_inFlight.containsKey(inFlightKey)) {
      await _inFlight[inFlightKey];
      return;
    }

    // 3. Mark status
    _updateModuleStatus(
      module,
      isManualReload ? ModuleLoadStatus.refreshing : ModuleLoadStatus.loading,
    );

    // 4. Concurrency-controlled execution
    final completer = Completer<dynamic>();
    _inFlight[inFlightKey] = completer.future;

    _enqueueRequest(() async {
      try {
        final result = await _executeModuleFetch(module, targetEmail);

        if (!mounted) {
          completer.complete(result);
          return;
        }

        // Discard response if account context or generation changed in the meantime
        if (currentGen != state.generationId ||
            targetEmail != state.activeAccountEmail ||
            targetShowroom != state.activeShowroomScope) {
          completer.complete(null);
          return;
        }

        // Store in cache
        _cache[cacheKey] = PaymentsCacheEntry(
          data: result,
          timestamp: DateTime.now(),
          accountKey: '$targetEmail::$targetShowroom',
        );

        // Apply result to state
        _applyCachedDataToState(module, result);
        _updateModuleStatus(module, ModuleLoadStatus.success);
        _updateModuleTimestamp(module, DateTime.now());

        completer.complete(result);
      } catch (err) {
        if (mounted &&
            currentGen == state.generationId &&
            targetEmail == state.activeAccountEmail) {
          _updateModuleStatus(
            module,
            ModuleLoadStatus.error,
            errorMessage: err.toString(),
          );
        }
        completer.completeError(err);
      } finally {
        _inFlight.remove(inFlightKey);
      }
    });

    try {
      await completer.future;
    } catch (_) {
      // Handled in state
    }
  }

  /// Dispatches the exact, unmodified backend repository calls for the specified module.
  Future<dynamic> _executeModuleFetch(PaymentsModule module, String activeEmail) async {
    switch (module) {
      case PaymentsModule.people:
        final results = await Future.wait([
          PeopleRepository.getPeople().catchError((_) => <PersonContact>[]),
          PeopleRepository.getPeopleTransactions().catchError((_) => <PersonTransaction>[]),
          PeopleRepository.getRepaymentAlerts().catchError((_) => <RepaymentAlert>[]),
          PeopleRepository.getIncomingRequests().catchError((_) => <ConnectionRequest>[]),
          PeopleRepository.getFinancialGroups().catchError((_) => <FinancialGroup>[]),
          PeopleRepository.getIncomingGroupRequests().catchError((_) => <GroupInvitation>[]),
        ]);
        final contacts = results[0] as List<PersonContact>;
        final txs = results[1] as List<PersonTransaction>;
        final reminders = results[2] as List<RepaymentAlert>;
        final reqs = results[3] as List<ConnectionRequest>;
        final rawGroups = results[4] as List<FinancialGroup>;
        final groups = rawGroups.where((g) => !g.isRejectedOrDeclined).toList();
        final groupInvs = results[5] as List<GroupInvitation>;
        final summary = PeopleSummary.fromContacts(contacts);
        return PeopleModuleData(
          contacts: contacts,
          transactions: txs,
          reminders: reminders,
          incomingRequests: reqs,
          groups: groups,
          incomingGroupRequests: groupInvs,
          summary: summary,
        );

      case PaymentsModule.transactions:
        final results = await Future.wait([
          PaymentTransactionRepository.getTransactions(email: activeEmail)
              .catchError((_) => <CashFlowTransaction>[]),
          PaymentTransactionRepository.getPaymentReports(email: activeEmail)
              .catchError((_) => <String, dynamic>{}),
          PaymentTransactionRepository.getBankAccounts(email: activeEmail)
              .catchError((_) => <CashFlowAccount>[]),
          PaymentTransactionRepository.getOutstandingStats(email: activeEmail)
              .catchError((_) => OutstandingSummaryStats(receivables: 0, payables: 0, totalProcessed: 0)),
        ]);
        final txList = results[0] as List<CashFlowTransaction>;
        final reports = results[1] as Map<String, dynamic>;
        final bankAccounts = results[2] as List<CashFlowAccount>;
        final stats = results[3] as OutstandingSummaryStats;

        final combinedAccounts = <CashFlowAccount>[];
        final reportAccountsRaw = reports['accounts'];
        if (reportAccountsRaw is List) {
          for (final a in reportAccountsRaw) {
            if (a is Map<String, dynamic>) {
              combinedAccounts.add(CashFlowAccount.fromJson(a));
            }
          }
        }
        for (final b in bankAccounts) {
          if (!combinedAccounts.any((a) => a.id.toString() == b.id.toString())) {
            combinedAccounts.add(b);
          }
        }
        if (combinedAccounts.isEmpty) {
          combinedAccounts.add(CashFlowAccount(
            id: 'cash-register',
            bankName: 'Cash Register (Cash in Hand)',
            accountHolder: activeEmail.isNotEmpty ? activeEmail.split('@').first : 'Cash Counter',
            accountNumber: 'Cash Counter',
            currentBalance: 0.0,
            type: 'cash',
            status: 'Active',
          ));
        }

        final overdue = <Map<String, dynamic>>[];
        final overdueRaw = reports['overdueInvoices'];
        if (overdueRaw is List) {
          for (final o in overdueRaw) {
            if (o is Map<String, dynamic>) {
              overdue.add(o);
            }
          }
        }

        return TransactionsModuleData(
          transactions: txList,
          reports: reports,
          bankAccounts: bankAccounts,
          stats: stats,
          combinedAccounts: combinedAccounts,
          overdueInvoices: overdue,
        );

      case PaymentsModule.segregation:
        final wallets = await GoalWalletRepository.getGoalWallets(email: activeEmail)
            .catchError((_) => <GoalWallet>[]);
        return SegregationModuleData(wallets: wallets);

      case PaymentsModule.splitCollect:
        final results = await Future.wait([
          SplitCollectRepository.getSplitExpenses(email: activeEmail)
              .catchError((_) => <SplitTicket>[]),
          SplitCollectRepository.getFriendOwedSummary(email: activeEmail)
              .catchError((_) => <FriendOwedSummary>[]),
        ]);
        return SplitCollectModuleData(
          tickets: results[0] as List<SplitTicket>,
          friendSummaries: results[1] as List<FriendOwedSummary>,
        );
    }
  }

  void _applyCachedDataToState(PaymentsModule module, dynamic data) {
    if (!mounted) return;
    switch (module) {
      case PaymentsModule.people:
        if (data is PeopleModuleData) {
          state = state.copyWith(peopleData: data);
        }
        break;
      case PaymentsModule.transactions:
        if (data is TransactionsModuleData) {
          state = state.copyWith(transactionsData: data);
        }
        break;
      case PaymentsModule.segregation:
        if (data is SegregationModuleData) {
          state = state.copyWith(segregationData: data);
        }
        break;
      case PaymentsModule.splitCollect:
        if (data is SplitCollectModuleData) {
          state = state.copyWith(splitCollectData: data);
        }
        break;
    }
  }

  void _updateModuleStatus(
    PaymentsModule module,
    ModuleLoadStatus status, {
    String? errorMessage,
  }) {
    if (!mounted) return;
    final updatedStatuses = Map<PaymentsModule, ModuleLoadStatus>.from(state.statuses);
    final updatedErrors = Map<PaymentsModule, String?>.from(state.errorMessages);
    updatedStatuses[module] = status;
    updatedErrors[module] = errorMessage;
    state = state.copyWith(
      statuses: updatedStatuses,
      errorMessages: updatedErrors,
    );
  }

  void _updateModuleTimestamp(PaymentsModule module, DateTime timestamp) {
    if (!mounted) return;
    final updated = Map<PaymentsModule, DateTime?>.from(state.lastUpdated);
    updated[module] = timestamp;
    state = state.copyWith(lastUpdated: updated);
  }

  /// Post-mutation trigger: automatically clears cache for the module and re-fetches
  void notifyMutation(PaymentsModule module, {List<PaymentsModule> alsoRefresh = const []}) {
    final targetEmail = state.activeAccountEmail;
    final targetShowroom = state.activeShowroomScope;
    _cache.remove(_buildCacheKey(module, targetEmail, targetShowroom));
    for (final extra in alsoRefresh) {
      _cache.remove(_buildCacheKey(extra, targetEmail, targetShowroom));
    }
    // Reload freshly
    loadModule(module, isManualReload: true);
    for (final extra in alsoRefresh) {
      loadModule(extra, isManualReload: true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONCURRENCY CONTROLLER
  // ─────────────────────────────────────────────────────────────────────────

  void _enqueueRequest(Future<void> Function() task) {
    if (_activeRequests < maxConcurrentRequests) {
      _runTask(task);
    } else {
      _requestQueue.add(_QueuedTask(task));
    }
  }

  void _runTask(Future<void> Function() task) {
    _activeRequests++;
    task().whenComplete(() {
      _activeRequests--;
      if (_requestQueue.isNotEmpty) {
        final next = _requestQueue.removeAt(0);
        _runTask(next.task);
      }
    });
  }
}

class _QueuedTask {
  final Future<void> Function() task;
  _QueuedTask(this.task);
}

// ─────────────────────────────────────────────────────────────────────────────
// RIVERPOD PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Main provider for the Payments Refresh Coordinator.
final paymentsRefreshCoordinatorProvider =
    StateNotifierProvider<PaymentsRefreshCoordinator, PaymentsCoordinatorState>((ref) {
  return PaymentsRefreshCoordinator(ref);
});

/// Convenience provider for transactions module data.
final paymentsTransactionsDataProvider = Provider<TransactionsModuleData?>((ref) {
  return ref.watch(paymentsRefreshCoordinatorProvider).transactionsData;
});

/// Convenience provider for segregation module data.
final paymentsSegregationDataProvider = Provider<SegregationModuleData?>((ref) {
  return ref.watch(paymentsRefreshCoordinatorProvider).segregationData;
});

/// Convenience provider for split & collect module data.
final paymentsSplitCollectDataProvider = Provider<SplitCollectModuleData?>((ref) {
  return ref.watch(paymentsRefreshCoordinatorProvider).splitCollectData;
});

/// Convenience provider for people module data.
final paymentsPeopleDataProvider = Provider<PeopleModuleData?>((ref) {
  return ref.watch(paymentsRefreshCoordinatorProvider).peopleData;
});
