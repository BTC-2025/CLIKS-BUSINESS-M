import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- RECURRING SUBSCRIPTIONS ---
class SubscriptionsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  SubscriptionsNotifier()
      : super([
          {
            'id': 'SUB-101',
            'name': 'AWS Cloud Hosting',
            'vendor': 'Amazon Web Services',
            'category': 'Software / SaaS',
            'freq': 'Monthly',
            'nextDue': '15-08-2026',
            'status': 'Active',
            'autoPost': 'Auto-Create',
            'cost': '₹12,500'
          },
          {
            'id': 'SUB-102',
            'name': 'Office Broadband Internet',
            'vendor': 'Airtel Enterprise',
            'category': 'Utilities',
            'freq': 'Monthly',
            'nextDue': '20-08-2026',
            'status': 'Active',
            'autoPost': 'Auto-Create',
            'cost': '₹3,500'
          },
          {
            'id': 'SUB-103',
            'name': 'Google Workspace Pro',
            'vendor': 'Google Cloud',
            'category': 'Software / SaaS',
            'freq': 'Monthly',
            'nextDue': '01-09-2026',
            'status': 'Active',
            'autoPost': 'Manual Review',
            'cost': '₹4,800'
          },
        ]);

  void addSubscription(Map<String, dynamic> sub) {
    state = [sub, ...state];
  }
}

final expensesSubscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, List<Map<String, dynamic>>>((ref) {
  return SubscriptionsNotifier();
});

// --- DEPARTMENT BUDGETS ---
class BudgetsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  BudgetsNotifier()
      : super([
          {
            'team': 'Engineering & IT',
            'limit': '₹1,50,000',
            'spent': '₹45,000',
            'index': '30.0%',
            'status': 'Within Limit'
          },
          {
            'team': 'Marketing & Ads',
            'limit': '₹80,000',
            'spent': '₹62,000',
            'index': '77.5%',
            'status': 'Near Limit'
          },
          {
            'team': 'Operations & HR',
            'limit': '₹50,000',
            'spent': '₹18,000',
            'index': '36.0%',
            'status': 'Within Limit'
          },
        ]);

  void addBudget(Map<String, dynamic> b) {
    state = [b, ...state];
  }
}

final expensesBudgetsProvider =
    StateNotifierProvider<BudgetsNotifier, List<Map<String, dynamic>>>((ref) {
  return BudgetsNotifier();
});

// --- STAFF REIMBURSEMENTS ---
class ReimbursementsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ReimbursementsNotifier()
      : super([
          {
            'id': 'CLM-882',
            'employee': 'Karan Mehra (Inventory)',
            'purpose': 'Client Sample Box Dispatches',
            'date': '08-08-2026',
            'amount': '₹2,450',
            'receipt': 'receipt_77.pdf',
            'status': 'Under Review'
          },
          {
            'id': 'CLM-875',
            'employee': 'Ananya Sharma (Sales)',
            'purpose': 'Outstation Client Travel Fare',
            'date': '04-08-2026',
            'amount': '₹5,800',
            'receipt': 'travel_ticket.pdf',
            'status': 'Approved'
          },
        ]);

  void addReimbursement(Map<String, dynamic> r) {
    state = [r, ...state];
  }
}

final expensesReimbursementsProvider =
    StateNotifierProvider<ReimbursementsNotifier, List<Map<String, dynamic>>>((ref) {
  return ReimbursementsNotifier();
});

// --- ACTIVE EXPENSE TAB PROVIDER ---
final expenseActiveTabProvider = StateProvider<int>((ref) => 0);

