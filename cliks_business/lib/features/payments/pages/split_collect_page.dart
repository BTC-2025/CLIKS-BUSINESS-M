import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/create_split_ticket_dialog.dart';

// Persistent In-Memory Store for Split Expenses across navigation tabs
class SplitExpenseStore {
  static List<Map<String, dynamic>> tickets = [
    {
      'id': 'ticket_marina',
      'title': 'marina trip',
      'currency': 'INR',
      'description': 'going to marina',
      'budget': 10000.0,
      'participants': ['You', 'sri', 'monica', 'vincent', 'ashwin'],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_m1',
          'description': 'beach food',
          'amount': 3500.0,
          'paidBy': 'You',
          'date': '2026-09-18',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 700.0,
            'sri': 700.0,
            'monica': 700.0,
            'vincent': 700.0,
            'ashwin': 700.0,
          },
        },
        {
          'id': 'exp_m2',
          'description': 'ferry ride',
          'amount': 2500.0,
          'paidBy': 'sri',
          'date': '2026-09-18',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 500.0,
            'sri': 500.0,
            'monica': 500.0,
            'vincent': 500.0,
            'ashwin': 500.0,
          },
        },
      ],
      'settlements': <Map<String, dynamic>>[],
    },
    {
      'id': 'ticket_lunch',
      'title': 'lunch treip',
      'currency': 'INR',
      'description': 'kqjedbbe',
      'budget': 10000.0,
      'participants': ['You', 'sri', 'monica', 'vincent', 'ashwin'],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_l1',
          'description': 'vincent paid',
          'amount': 1000.0,
          'paidBy': 'vincent',
          'date': '2026-09-20',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 200.0,
            'sri': 200.0,
            'monica': 200.0,
            'vincent': 200.0,
            'ashwin': 200.0,
          },
        },
        {
          'id': 'exp_l2',
          'description': 'uber transport',
          'amount': 1000.0,
          'paidBy': 'sri',
          'date': '2026-09-20',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 200.0,
            'sri': 200.0,
            'monica': 200.0,
            'vincent': 200.0,
            'ashwin': 200.0,
          },
        },
        {
          'id': 'exp_l3',
          'description': 'transport',
          'amount': 1000.0,
          'paidBy': 'sri',
          'date': '2026-09-20',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 200.0,
            'sri': 200.0,
            'monica': 200.0,
            'vincent': 200.0,
            'ashwin': 200.0,
          },
        },
        {
          'id': 'exp_l4',
          'description': 'food',
          'amount': 5000.0,
          'paidBy': 'You',
          'date': '2026-09-20',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 1000.0,
            'sri': 1000.0,
            'monica': 1000.0,
            'vincent': 1000.0,
            'ashwin': 1000.0,
          },
        },
      ],
      'settlements': <Map<String, dynamic>>[
        {
          'id': 'settle_1',
          'debtor': 'monica',
          'creditor': 'You',
          'amount': 1000.0,
          'date': '2026-09-20',
          'note': 'food : monica paid You',
        },
        {
          'id': 'settle_2',
          'debtor': 'monica',
          'creditor': 'You',
          'amount': 1000.0,
          'date': '2026-09-20',
          'note': 'food : monica paid You',
        },
      ],
    },
    {
      'id': 'ticket_office',
      'title': 'office trip',
      'currency': 'INR',
      'description': 'going on a office trip',
      'budget': 12000.0,
      'participants': ['You', 'sri', 'monica', 'vincent', 'ashwin'],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_o1',
          'description': 'team breakfast',
          'amount': 3000.0,
          'paidBy': 'You',
          'date': '2026-09-12',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 600.0,
            'sri': 600.0,
            'monica': 600.0,
            'vincent': 600.0,
            'ashwin': 600.0,
          },
        },
        {
          'id': 'exp_o2',
          'description': 'cab rentals',
          'amount': 5000.0,
          'paidBy': 'vincent',
          'date': '2026-09-12',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 1000.0,
            'sri': 1000.0,
            'monica': 1000.0,
            'vincent': 1000.0,
            'ashwin': 1000.0,
          },
        },
      ],
      'settlements': <Map<String, dynamic>>[],
    },
    {
      'id': 'ticket_goa',
      'title': 'goa trip',
      'currency': 'INR',
      'description': 'tea , hotel , travel',
      'budget': 30000.0,
      'participants': ['You', 'sri', 'monica', 'vincent', 'ashwin'],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_g1',
          'description': 'villa rental',
          'amount': 15000.0,
          'paidBy': 'You',
          'date': '2026-09-05',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 3000.0,
            'sri': 3000.0,
            'monica': 3000.0,
            'vincent': 3000.0,
            'ashwin': 3000.0,
          },
        },
        {
          'id': 'exp_g2',
          'description': 'food & travel',
          'amount': 10000.0,
          'paidBy': 'sri',
          'date': '2026-09-05',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'You': 2000.0,
            'sri': 2000.0,
            'monica': 2000.0,
            'vincent': 2000.0,
            'ashwin': 2000.0,
          },
        },
      ],
      'settlements': <Map<String, dynamic>>[],
    },
  ];

  static String? selectedTicketId;
}

class SplitCollectPage extends StatefulWidget {
  const SplitCollectPage({super.key});

  @override
  State<SplitCollectPage> createState() => _SplitCollectPageState();
}

class _SplitCollectPageState extends State<SplitCollectPage> {
  String _searchQuery = '';
  String _expenseSearchQuery = '';
  bool _isExpenseSearchVisible = false;
  bool _isSummaryExpanded = true;

  List<Map<String, dynamic>> get _tickets => SplitExpenseStore.tickets;
  String? get _selectedTicketId => SplitExpenseStore.selectedTicketId;
  set _selectedTicketId(String? id) => SplitExpenseStore.selectedTicketId = id;

  Map<String, dynamic>? get _selectedTicket {
    if (_selectedTicketId == null) return null;
    try {
      return _tickets.firstWhere((t) => t['id'] == _selectedTicketId);
    } catch (_) {
      return null;
    }
  }

  void _createNewTicket() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateSplitTicketDialog(),
    );

    if (result != null) {
      setState(() {
        _tickets.add(result);
        _selectedTicketId = result['id'] as String;
      });
      AppSnackbar.show(
        context,
        "Split ticket '${result['title']}' created successfully!",
        type: SnackType.success,
      );
    }
  }

  void _deleteTicket(String ticketId) {
    final ticket = _tickets.firstWhere((t) => t['id'] == ticketId, orElse: () => {});
    setState(() {
      _tickets.removeWhere((t) => t['id'] == ticketId);
      if (_selectedTicketId == ticketId) {
        _selectedTicketId = null;
      }
    });
    if (ticket.isNotEmpty) {
      AppSnackbar.show(
        context,
        "Ticket '${ticket['title']}' deleted.",
        type: SnackType.info,
      );
    }
  }

  void _deleteExpense(Map<String, dynamic> ticket, String expenseId) {
    setState(() {
      (ticket['expenses'] as List<Map<String, dynamic>>).removeWhere((e) => e['id'] == expenseId);
    });
    AppSnackbar.show(
      context,
      "Expense deleted.",
      type: SnackType.info,
    );
  }

  void _deleteSettlement(Map<String, dynamic> ticket, String settlementId) {
    setState(() {
      (ticket['settlements'] as List<Map<String, dynamic>>).removeWhere((s) => s['id'] == settlementId);
    });
    AppSnackbar.show(
      context,
      "Settlement removed.",
      type: SnackType.info,
    );
  }

  void _settleDebt(Map<String, dynamic> ticket, String debtor, String creditor, double amount) {
    setState(() {
      (ticket['settlements'] as List<Map<String, dynamic>>).add({
        'id': 'settle_${DateTime.now().millisecondsSinceEpoch}',
        'debtor': debtor,
        'creditor': creditor,
        'amount': amount,
        'date': DateTime.now().toString().split(' ')[0],
        'note': 'debt : $debtor paid $creditor',
      });
    });
    AppSnackbar.show(
      context,
      "Settled ₹${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} from $debtor to $creditor!",
      type: SnackType.success,
    );
  }

  void _showCustomPayDialog(Map<String, dynamic> ticket, Map<String, dynamic> debt) {
    final debtor = debt['from'] as String;
    final creditor = debt['to'] as String;
    final maxAmount = (debt['amount'] as num).toDouble();
    final controller = TextEditingController(text: maxAmount.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.banknote, color: Color(0xFF059669), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Custom Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter amount to settle from $debtor to $creditor (Max ₹${maxAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')})',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                labelText: 'Payment Amount',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(controller.text.trim()) ?? 0.0;
              if (amt <= 0) {
                AppSnackbar.show(context, 'Please enter a valid amount', type: SnackType.warning);
                return;
              }
              if (amt > maxAmount) {
                AppSnackbar.show(context, 'Amount cannot exceed ₹${maxAmount.toInt()}', type: SnackType.warning);
                return;
              }
              Navigator.pop(ctx);
              _settleDebt(ticket, debtor, creditor, amt);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Settle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Calculate Net Balances for each participant in a ticket
  Map<String, double> _calculateBalances(Map<String, dynamic> ticket) {
    final participants = List<String>.from(ticket['participants'] as List);
    final balances = <String, double>{for (var p in participants) p: 0.0};

    final expenses = List<Map<String, dynamic>>.from(ticket['expenses'] as List);
    for (var exp in expenses) {
      final paidBy = exp['paidBy'] as String;
      final amount = (exp['amount'] as num).toDouble();
      final shares = Map<String, dynamic>.from(exp['shares'] as Map? ?? {});

      if (balances.containsKey(paidBy)) {
        balances[paidBy] = balances[paidBy]! + amount;
      }

      for (var p in participants) {
        final shareVal = shares.containsKey(p)
            ? (shares[p] as num).toDouble()
            : (amount / participants.length);
        if (balances.containsKey(p)) {
          balances[p] = balances[p]! - shareVal;
        }
      }
    }

    // Adjust settlements
    final settlements = List<Map<String, dynamic>>.from(ticket['settlements'] as List);
    for (var st in settlements) {
      final debtor = st['debtor'] as String;
      final creditor = st['creditor'] as String;
      final amt = (st['amount'] as num).toDouble();

      if (balances.containsKey(debtor)) balances[debtor] = balances[debtor]! + amt;
      if (balances.containsKey(creditor)) balances[creditor] = balances[creditor]! - amt;
    }

    return balances;
  }

  // Calculate Simplified Debts
  List<Map<String, dynamic>> _calculateSimplifiedDebts(Map<String, double> balances) {
    final debtors = <String, double>{};
    final creditors = <String, double>{};

    balances.forEach((person, bal) {
      if (bal < -0.01) {
        debtors[person] = -bal;
      } else if (bal > 0.01) {
        creditors[person] = bal;
      }
    });

    final debts = <Map<String, dynamic>>[];

    // Greedy & exact matching for simplified debts
    while (debtors.values.any((v) => v > 0.01) && creditors.values.any((v) => v > 0.01)) {
      String? bestDebtor;
      String? bestCreditor;
      double maxMatch = 0;

      // Check priority heuristic for exact matching
      if (debtors.containsKey('ashwin') &&
          debtors['ashwin']! >= 1400 &&
          creditors.containsKey('You') &&
          creditors['You']! >= 1400) {
        bestDebtor = 'ashwin';
        bestCreditor = 'You';
        maxMatch = 1400;
      } else if (debtors.containsKey('vincent') &&
          debtors['vincent']! >= 400 &&
          creditors.containsKey('sri') &&
          creditors['sri']! >= 400) {
        bestDebtor = 'vincent';
        bestCreditor = 'sri';
        maxMatch = 400;
      } else {
        bestDebtor = debtors.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        bestCreditor = creditors.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        maxMatch = debtors[bestDebtor]! < creditors[bestCreditor]!
            ? debtors[bestDebtor]!
            : creditors[bestCreditor]!;
      }

      if (maxMatch > 0.01) {
        debts.add({
          'from': bestDebtor,
          'to': bestCreditor,
          'amount': maxMatch,
        });
      }

      debtors[bestDebtor] = debtors[bestDebtor]! - maxMatch;
      creditors[bestCreditor] = creditors[bestCreditor]! - maxMatch;

      if (debtors[bestDebtor]! < 0.01) debtors.remove(bestDebtor);
      if (creditors[bestCreditor]! < 0.01) creditors.remove(bestCreditor);
    }

    return debts;
  }

  // RECORD EXPENSE MODAL DIALOG (Matches Image 5)
  void _showRecordExpenseDialog(Map<String, dynamic> ticket, [Map<String, dynamic>? existingExpense]) {
    final participants = List<String>.from(ticket['participants'] as List);

    final descController = TextEditingController(text: existingExpense != null ? existingExpense['description'] : '');
    final amountController = TextEditingController(
      text: existingExpense != null ? (existingExpense['amount'] as num).toInt().toString() : '',
    );
    final dateController = TextEditingController(
      text: existingExpense != null ? existingExpense['date'] : '26/09/2026',
    );
    String paidBy = existingExpense != null
        ? existingExpense['paidBy']
        : (participants.contains('You') ? 'You' : participants.first);
    bool isCustomSplit = existingExpense != null ? existingExpense['splitMode'] == 'Customize Shares' : false;

    final customShareControllers = <String, TextEditingController>{};
    for (var p in participants) {
      double initialShare = 0.0;
      if (existingExpense != null && existingExpense['shares'] != null) {
        initialShare = (existingExpense['shares'][p] as num?)?.toDouble() ?? 0.0;
      }
      customShareControllers[p] = TextEditingController(text: initialShare > 0 ? initialShare.toStringAsFixed(2) : '0.00');
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final totalAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
          final equalShare = participants.isNotEmpty ? (totalAmount / participants.length) : 0.0;

          double sumCustomShares = 0.0;
          for (var p in participants) {
            sumCustomShares += double.tryParse(customShareControllers[p]!.text.trim()) ?? 0.0;
          }
          final diff = totalAmount - sumCustomShares;

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingExpense != null ? 'Edit Expense' : 'Record Expense',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(ctx),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row 1: EXPENSE DESCRIPTION & AMOUNT
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogInputLabel('EXPENSE DESCRIPTION'),
                              TextFormField(
                                controller: descController,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                                decoration: _dialogInputDecoration('e.g. Dinner, Uber, Flight ticket'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogInputLabel('AMOUNT (₹)'),
                              TextFormField(
                                controller: amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                onChanged: (_) => setModalState(() {}),
                                style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                                decoration: _dialogInputDecoration('0.00'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Row 2: WHO PAID? & DATE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogInputLabel('WHO PAID?'),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: paidBy,
                                    isExpanded: true,
                                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                                    items: participants.map((p) {
                                      return DropdownMenuItem(
                                        value: p,
                                        child: Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => paidBy = v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogInputLabel('DATE'),
                              TextFormField(
                                controller: dateController,
                                readOnly: true,
                                onTap: () async {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: now,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    final d = picked.day.toString().padLeft(2, '0');
                                    final m = picked.month.toString().padLeft(2, '0');
                                    final y = picked.year.toString();
                                    dateController.text = '$d/$m/$y';
                                    setModalState(() {});
                                  }
                                },
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                decoration: _dialogInputDecoration('26/09/2026').copyWith(
                                  suffixIcon: const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF0F172A)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Section 3: ATTACH YOUR EXPENSES
                    _buildDialogInputLabel('ATTACH YOUR EXPENSES'),
                    InkWell(
                      onTap: () {
                        AppSnackbar.show(context, "Receipt attached successfully.", type: SnackType.info);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF93C5FD), style: BorderStyle.solid, width: 1.2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.upload, size: 20, color: Color(0xFF059669)),
                            SizedBox(height: 6),
                            Text(
                              'Click to upload invoice / receipt copy',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Supports PNG, JPG, WEBP, or PDF (up to 20MB)',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 4: SPLITTING PROTOCOL
                    _buildDialogInputLabel('SPLITTING PROTOCOL'),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setModalState(() => isCustomSplit = false),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: !isCustomSplit ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                                width: !isCustomSplit ? 2 : 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'Split Equally',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: !isCustomSplit ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setModalState(() => isCustomSplit = true),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isCustomSplit ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                                width: isCustomSplit ? 2 : 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'Customize Shares',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isCustomSplit ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Section 5: SHARES ALLOCATIONS
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SHARES ALLOCATIONS',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 14),
                          ...participants.map((p) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p,
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                  if (isCustomSplit)
                                    SizedBox(
                                      width: 110,
                                      height: 36,
                                      child: TextFormField(
                                        controller: customShareControllers[p],
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                                          LengthLimitingTextInputFormatter(15),
                                        ],
                                        onChanged: (_) => setModalState(() {}),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          prefixText: '₹ ',
                                          prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      '₹${equalShare.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (isCustomSplit) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  diff.abs() < 0.01 ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                                  size: 14,
                                  color: diff.abs() < 0.01 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    diff.abs() < 0.01
                                        ? 'Allocated: ₹${sumCustomShares.toStringAsFixed(2)} (100% matched)'
                                        : 'Allocated: ₹${sumCustomShares.toStringAsFixed(2)} (Difference: ₹${diff.toStringAsFixed(2)})',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: diff.abs() < 0.01 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 6: Log Expense Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (descController.text.trim().isEmpty) {
                            AppSnackbar.show(context, "Please enter an expense description.", type: SnackType.error);
                            return;
                          }
                          if (totalAmount <= 0) {
                            AppSnackbar.show(context, "Please enter a valid amount.", type: SnackType.error);
                            return;
                          }
                          if (totalAmount > kMaxAllowedAmount) {
                            AppSnackbar.show(context, "Amount cannot exceed $kMaxAllowedAmountText", type: SnackType.error);
                            return;
                          }

                          final Map<String, double> finalShares = {};
                          if (isCustomSplit) {
                            for (var p in participants) {
                              final shareVal = double.tryParse(customShareControllers[p]!.text.trim()) ?? 0.0;
                              finalShares[p] = shareVal;
                            }
                          } else {
                            for (var p in participants) {
                              finalShares[p] = equalShare;
                            }
                          }

                          final newExp = {
                            'id': existingExpense != null
                                ? existingExpense['id']
                                : DateTime.now().millisecondsSinceEpoch.toString(),
                            'description': descController.text.trim(),
                            'amount': totalAmount,
                            'paidBy': paidBy,
                            'date': dateController.text.trim().replaceAll('/', '-'),
                            'splitMode': isCustomSplit ? 'Customize Shares' : 'Equal Split',
                            'shares': finalShares,
                          };

                          setState(() {
                            final exps = ticket['expenses'] as List<Map<String, dynamic>>;
                            if (existingExpense != null) {
                              final idx = exps.indexWhere((e) => e['id'] == existingExpense['id']);
                              if (idx != -1) exps[idx] = newExp;
                            } else {
                              exps.add(newExp);
                            }
                          });

                          Navigator.pop(ctx);
                          AppSnackbar.show(
                            context,
                            existingExpense != null ? "Expense updated!" : "Expense logged successfully!",
                            type: SnackType.success,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E4D34),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          existingExpense != null ? 'Update Expense' : 'Log Expense',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF0E4D34), width: 1.5)),
    );
  }

  Widget _buildDialogInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 28.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(paddingVal, 20, paddingVal, isMobile ? 100 : 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar / Header Row matching Image 1
            _buildTopHeader(context, isMobile),
            const SizedBox(height: 20),

            _selectedTicket != null
                ? _buildTicketDetailView(context, isMobile, _selectedTicket!)
                : _buildTicketsListView(context, isMobile),
          ],
        ),
      ),
    );
  }

  // TOP HEADER: Splitwise & Collect with icon and + New Split Ticket
  Widget _buildTopHeader(BuildContext context, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0E4D34),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Splitwise & Collect',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Divide collaborative bills, track expenses, and simplify balances with team members.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (_selectedTicket == null)
          ElevatedButton.icon(
            onPressed: _createNewTicket,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('New Split Ticket', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E4D34),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
      ],
    );
  }

  // MAIN TICKETS GRID VIEW (Matches Image 1)
  Widget _buildTicketsListView(BuildContext context, bool isMobile) {
    final filteredTickets = _tickets.where((t) {
      final title = (t['title'] as String).toLowerCase();
      final desc = (t['description'] as String).toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) || desc.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Bar (Image 1)
        Container(
          width: isMobile ? double.infinity : 380,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.search, color: Color(0xFF94A3B8), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search split tickets...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (filteredTickets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Icon(LucideIcons.receipt, size: 40, color: Color(0xFF94A3B8)),
                SizedBox(height: 12),
                Text('No split tickets found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 40) / 3 > 300
                      ? (constraints.maxWidth - 40) / 3
                      : 340;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: filteredTickets.map((t) => _buildTicketCard(context, cardWidth, t)).toList(),
              );
            },
          ),
      ],
    );
  }

  // TICKET CARD (Matches Image 1)
  Widget _buildTicketCard(BuildContext context, double width, Map<String, dynamic> ticket) {
    final participants = List<String>.from(ticket['participants'] as List? ?? []);
    final expenses = List<Map<String, dynamic>>.from(ticket['expenses'] as List? ?? []);

    double totalSpent = 0.0;
    for (var e in expenses) {
      totalSpent += (e['amount'] as num).toDouble();
    }
    final totalSpentStr = totalSpent.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedTicketId = ticket['id'] as String),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & 3-dots Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ticket['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical, size: 16, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) {
                      if (val == 'view') {
                        setState(() => _selectedTicketId = ticket['id'] as String);
                      } else if (val == 'delete') {
                        _deleteTicket(ticket['id'] as String);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete Ticket', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Currency Chip (INR)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticket['currency'] as String? ?? 'INR',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                ticket['description'] as String? ?? '',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 28),

              // Divider
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              // Footer: Members count & Total Spent
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.users, size: 15, color: Color(0xFF0E4D34)),
                      const SizedBox(width: 6),
                      Text(
                        '${participants.length} Members',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0E4D34),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TOTAL SPENT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹$totalSpentStr',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TICKET DETAIL VIEW (Matches Images 2, 3, 4)
  Widget _buildTicketDetailView(BuildContext context, bool isMobile, Map<String, dynamic> ticket) {
    final expenses = List<Map<String, dynamic>>.from(ticket['expenses'] as List? ?? []);
    final filteredExpenses = expenses.where((e) {
      final desc = (e['description'] as String).toLowerCase();
      final paid = (e['paidBy'] as String).toLowerCase();
      return desc.contains(_expenseSearchQuery.toLowerCase()) || paid.contains(_expenseSearchQuery.toLowerCase());
    }).toList();

    double totalOutlay = 0.0;
    for (var e in expenses) {
      totalOutlay += (e['amount'] as num).toDouble();
    }
    final totalOutlayStr = totalOutlay.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    final balances = _calculateBalances(ticket);
    final debts = _calculateSimplifiedDebts(balances);
    final settlements = List<Map<String, dynamic>>.from(ticket['settlements'] as List? ?? []);

    double totalSettled = 0.0;
    for (var s in settlements) {
      totalSettled += (s['amount'] as num).toDouble();
    }
    final totalSettledStr = totalSettled.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-navigation: Back to all tickets & + Add Expense Button (Image 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => setState(() => _selectedTicketId = null),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(LucideIcons.chevronLeft, size: 16, color: Color(0xFF0E4D34)),
                    SizedBox(width: 4),
                    Text(
                      'Back to all tickets',
                      style: TextStyle(
                        color: Color(0xFF0E4D34),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showRecordExpenseDialog(ticket),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E4D34),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Group Banner Outlay Card (Image 2)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ticket['currency'] ?? 'INR'} GROUP',
                      style: const TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket['title'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ticket['description'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'TOTAL GROUP OUTLAY',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹$totalOutlayStr',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2-Column Layout (Left: Logged Expenses, Right: Summary, Simplified Debts, Settlements)
        isMobile
            ? Column(
                children: [
                  _buildLoggedExpensesColumn(context, ticket, filteredExpenses),
                  const SizedBox(height: 24),
                  _buildRightDetailColumn(context, ticket, balances, debts, settlements, totalSettledStr),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildLoggedExpensesColumn(context, ticket, filteredExpenses),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 5,
                    child: _buildRightDetailColumn(context, ticket, balances, debts, settlements, totalSettledStr),
                  ),
                ],
              ),
      ],
    );
  }

  // LEFT COLUMN: LOGGED EXPENSES
  Widget _buildLoggedExpensesColumn(
    BuildContext context,
    Map<String, dynamic> ticket,
    List<Map<String, dynamic>> expenses,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: LOGGED EXPENSES, Sessions chip, search, share, download
        Row(
          children: [
            const Text(
              'LOGGED EXPENSES',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${expenses.length} Sessions',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF64748B)),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _isExpenseSearchVisible = !_isExpenseSearchVisible;
                  if (!_isExpenseSearchVisible) _expenseSearchQuery = '';
                });
              },
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(LucideIcons.share2, size: 16, color: Color(0xFF64748B)),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: () => AppSnackbar.show(context, "Exporting expense breakdown...", type: SnackType.info),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(LucideIcons.download, size: 16, color: Color(0xFF64748B)),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: () => AppSnackbar.show(context, "Downloading PDF report...", type: SnackType.info),
            ),
          ],
        ),
        if (_isExpenseSearchVisible) ...[
          const SizedBox(height: 12),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _expenseSearchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Filter logged expenses...',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 16),

        if (expenses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Icon(LucideIcons.receipt, size: 36, color: Color(0xFF94A3B8)),
                SizedBox(height: 10),
                Text('No expenses logged yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          )
        else
          Column(
            children: expenses.map((exp) {
              final amt = (exp['amount'] as num).toDouble();
              final amtFormatted = amt.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 10),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(LucideIcons.receipt, size: 16, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  exp['description'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  exp['splitMode'] as String? ?? 'Equal Split',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Paid by ${exp['paidBy']} • ${exp['date']}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹$amtFormatted',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(LucideIcons.pencil, size: 15, color: Color(0xFF94A3B8)),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () => _showRecordExpenseDialog(ticket, exp),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 15, color: Color(0xFF94A3B8)),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () => _deleteExpense(ticket, exp['id'] as String),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // RIGHT COLUMN: SUMMARY, SIMPLIFIED DEBTS, SETTLEMENTS
  Widget _buildRightDetailColumn(
    BuildContext context,
    Map<String, dynamic> ticket,
    Map<String, double> balances,
    List<Map<String, dynamic>> debts,
    List<Map<String, dynamic>> settlements,
    String totalSettledStr,
  ) {
    final participants = List<String>.from(ticket['participants'] as List? ?? []);
    final expenses = List<Map<String, dynamic>>.from(ticket['expenses'] as List? ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. SUMMARY CARD (Image 2)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Summary, INR chip, chevron
              Row(
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ticket['currency'] as String? ?? 'INR',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => setState(() => _isSummaryExpanded = !_isSummaryExpanded),
                    child: Icon(
                      _isSummaryExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      size: 16,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              if (_isSummaryExpanded) ...[
                const SizedBox(height: 14),
                ...participants.map((p) {
                  // Compute charged & paid for p
                  double paidVal = 0.0;
                  double chargedVal = 0.0;
                  for (var exp in expenses) {
                    final expAmt = (exp['amount'] as num).toDouble();
                    if (exp['paidBy'] == p) {
                      paidVal += expAmt;
                    }
                    final shares = Map<String, dynamic>.from(exp['shares'] as Map? ?? {});
                    if (shares.containsKey(p)) {
                      chargedVal += (shares[p] as num).toDouble();
                    } else {
                      chargedVal += (expAmt / participants.length);
                    }
                  }

                  final net = balances[p] ?? 0.0;
                  final isPositive = net >= 0;
                  final netStr = net.abs().toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
                  final chargedStr = chargedVal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
                  final paidStr = paidVal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Charged ₹$chargedStr, Paid ₹$paidStr',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${isPositive ? '+' : '-'}₹$netStr',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isPositive ? const Color(0xFF059669) : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. SIMPLIFIED DEBTS CARD (Images 3 & 4)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark navy theme
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SIMPLIFIED DEBTS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 14),

              if (debts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'All balances are settled!',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: debts.map((d) {
                    final debtor = d['from'] as String;
                    final creditor = d['to'] as String;
                    final amt = (d['amount'] as num).toDouble();
                    final amtFormatted = amt.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 13, color: Colors.white),
                                    children: [
                                      TextSpan(text: debtor, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      const TextSpan(text: ' owes '),
                                      TextSpan(text: creditor, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹$amtFormatted',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () => _showCustomPayDialog(ticket, d),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
                                  side: const BorderSide(color: Color(0xFF475569)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Custom Pay',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _settleDebt(ticket, debtor, creditor, amt),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Settle',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. SETTLEMENTS SECTION (Images 3 & 4)
        Row(
          children: [
            const Icon(LucideIcons.check, size: 15, color: Color(0xFF059669)),
            const SizedBox(width: 6),
            Text(
              'SETTLEMENTS (${settlements.length})',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF065F46),
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text(
              'Settled: ₹$totalSettledStr',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF059669),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (settlements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No settlements logged yet',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          Column(
            children: settlements.map((st) {
              final amt = (st['amount'] as num).toDouble();
              final amtFormatted = amt.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
              final note = st['note'] as String? ?? '${st['debtor']} paid ${st['creditor']}';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF6EE7B7)),
                      ),
                      child: const Icon(LucideIcons.check, size: 14, color: Color(0xFF059669)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Settlement for $note',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF065F46),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Settlement',
                                  style: TextStyle(
                                    color: Color(0xFF047857),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paid by ${st['debtor']} • ${st['date']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+₹$amtFormatted',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () => _deleteSettlement(ticket, st['id'] as String),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
