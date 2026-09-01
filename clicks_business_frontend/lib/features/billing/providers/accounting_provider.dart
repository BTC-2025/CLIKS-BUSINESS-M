import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountingEntry {
  final String id;
  final String title;
  final String category;
  final String entryType; // 'Income / Sales', 'Expense', 'Journal Entry', 'Transfer', 'Asset Purchase'
  final double amount;
  final String paymentMode;
  final String date;
  final String notes;

  AccountingEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.entryType,
    required this.amount,
    required this.paymentMode,
    required this.date,
    required this.notes,
  });
}

class AccountingEntriesNotifier extends StateNotifier<List<AccountingEntry>> {
  AccountingEntriesNotifier()
      : super([
          AccountingEntry(
            id: '1',
            title: 'Office Rent & Facilities',
            category: 'Rent & Utilities',
            entryType: 'Expense',
            amount: 15000.0,
            paymentMode: 'Bank Transfer',
            date: '08-08-2026',
            notes: 'August 2026 Office Space Rent',
          ),
          AccountingEntry(
            id: '2',
            title: 'Monthly Staff Tea & Coffee Supplies',
            category: 'Office Expenses',
            entryType: 'Expense',
            amount: 4500.0,
            paymentMode: 'UPI',
            date: '07-08-2026',
            notes: 'Pantry restocking',
          ),
          AccountingEntry(
            id: '3',
            title: 'Engineering Team Wages & Payroll',
            category: 'Salary & Wages',
            entryType: 'Expense',
            amount: 18000.0,
            paymentMode: 'Bank Transfer',
            date: '05-08-2026',
            notes: 'August Part Salary Release',
          ),
          AccountingEntry(
            id: '4',
            title: 'Digital Marketing & Ads Campaign',
            category: 'Marketing & Advertising',
            entryType: 'Expense',
            amount: 3000.0,
            paymentMode: 'Credit Card',
            date: '03-08-2026',
            notes: 'Google Ads budget',
          ),
          AccountingEntry(
            id: '5',
            title: 'Client Travel Allowance & Meals',
            category: 'Travel & Meals',
            entryType: 'Expense',
            amount: 2000.0,
            paymentMode: 'Cash in Hand',
            date: '02-08-2026',
            notes: 'Client meeting in Pune',
          ),
        ]);

  void addEntry(AccountingEntry entry) {
    state = [entry, ...state];
  }
}

final accountingEntriesProvider =
    StateNotifierProvider<AccountingEntriesNotifier, List<AccountingEntry>>((ref) {
  return AccountingEntriesNotifier();
});
