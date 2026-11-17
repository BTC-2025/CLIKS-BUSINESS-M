import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/create_split_ticket_dialog.dart';

// Persistent In-Memory Store for Split Expenses across navigation tabs
class SplitExpenseStore {
  static List<Map<String, dynamic>> tickets = [
    {
      'id': 'ticket_new_split',
      'title': 'edkcbuhev',
      'currency': 'INR',
      'description': 'new split',
      'budget': 2000000.0,
      'participants': ['You', 'kamesh'],
      'members': <Map<String, dynamic>>[
        {
          'name': 'You',
          'email': 'you@bnxmail.com',
          'role': 'Admin',
          'isCreator': true,
          'isPending': false,
        },
        {
          'name': 'kamesh',
          'email': 'kamesh@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': false,
        },
      ],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_e1',
          'description': 'new purchase',
          'amount': 1001000.0,
          'paidBy': 'You',
          'category': 'Shopping',
          'date': '2026-11-12',
          'splitMode': 'Equal Split',
          'receipt': {'name': 'purchase_receipt.pdf', 'size': '1.2 MB'},
          'shares': <String, double>{'You': 500500.0, 'kamesh': 500500.0},
        },
      ],
      'debts': <Map<String, dynamic>>[],
      'settlements': <Map<String, dynamic>>[],
    },
    {
      'id': 'ticket_marina',
      'title': 'marina trip',
      'currency': 'INR',
      'description': 'going to marina',
      'budget': 10000.0,
      'participants': ['Admin', 'vincent', 'monica', 'sri', 'ashwin'],
      'members': <Map<String, dynamic>>[
        {
          'name': 'Admin',
          'email': 'admin@bnxmail.com',
          'role': 'Creator & Admin',
          'isCreator': true,
          'isPending': false,
        },
        {
          'name': 'vincent',
          'email': 'vincent@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'monica',
          'email': 'monica@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'sri',
          'email': 'sri@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'ashwin',
          'email': 'ashwin@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
      ],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_m1',
          'description': 'transport',
          'amount': 1000.0,
          'paidBy': 'sri',
          'category': 'Transport',
          'date': '2026-09-21',
          'splitMode': 'Equal Split',
          'receipt': {'name': 'cab_receipt_marina.png', 'size': '850 KB'},
          'shares': <String, double>{
            'Admin': 200.0,
            'vincent': 200.0,
            'monica': 200.0,
            'sri': 200.0,
            'ashwin': 200.0,
          },
        },
        {
          'id': 'exp_m2',
          'description': 'food',
          'amount': 5000.0,
          'paidBy': 'Admin',
          'category': 'Food',
          'date': '2026-09-21',
          'splitMode': 'Equal Split',
          'receipt': {'name': 'beach_diner_bill.pdf', 'size': '2.1 MB'},
          'shares': <String, double>{
            'Admin': 1000.0,
            'vincent': 1000.0,
            'monica': 1000.0,
            'sri': 1000.0,
            'ashwin': 1000.0,
          },
        },
      ],
      'debts': <Map<String, dynamic>>[],
      'settlements': <Map<String, dynamic>>[
        {
          'id': 'settle_1',
          'title': 'transport : sri paid Admin',
          'debtor': 'sri',
          'creditor': 'Admin',
          'amount': 200.0,
          'date': '2026-09-21',
        },
      ],
    },
    {
      'id': 'ticket_lunch',
      'title': 'lunch treip',
      'currency': 'INR',
      'description': 'kqjedbbe',
      'budget': 10000.0,
      'participants': ['Admin', 'sri', 'monica', 'vincent', 'ashwin'],
      'members': <Map<String, dynamic>>[
        {
          'name': 'Admin',
          'email': 'admin@bnxmail.com',
          'role': 'Creator & Admin',
          'isCreator': true,
          'isPending': false,
        },
        {
          'name': 'sri',
          'email': 'sri@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': false,
        },
        {
          'name': 'monica',
          'email': 'monica@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'vincent',
          'email': 'vincent@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'ashwin',
          'email': 'ashwin@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
      ],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_l1',
          'description': 'vincent paid',
          'amount': 1000.0,
          'paidBy': 'vincent',
          'category': 'Food',
          'date': '2026-09-20',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'Admin': 200.0,
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
          'category': 'Transport',
          'date': '2026-09-20',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'Admin': 200.0,
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
          'category': 'Transport',
          'date': '2026-09-20',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'Admin': 200.0,
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
          'paidBy': 'Admin',
          'category': 'Food',
          'date': '2026-09-20',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'Admin': 1000.0,
            'sri': 1000.0,
            'monica': 1000.0,
            'vincent': 1000.0,
            'ashwin': 1000.0,
          },
        },
      ],
      'debts': <Map<String, dynamic>>[],
      'settlements': <Map<String, dynamic>>[],
    },
    {
      'id': 'ticket_office',
      'title': 'office trip',
      'currency': 'INR',
      'description': 'going on a office trip',
      'budget': 12000.0,
      'participants': ['Admin', 'vincent', 'monica', 'sri', 'ashwin'],
      'members': <Map<String, dynamic>>[
        {
          'name': 'Admin',
          'email': 'admin@bnxmail.com',
          'role': 'Creator & Admin',
          'isCreator': true,
          'isPending': false,
        },
        {
          'name': 'vincent',
          'email': 'vincent@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'monica',
          'email': 'monica@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'sri',
          'email': 'sri@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'ashwin',
          'email': 'ashwin@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
      ],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_o1',
          'description': 'team breakfast',
          'amount': 3000.0,
          'paidBy': 'Admin',
          'category': 'Food',
          'date': '2026-09-12',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'Admin': 600.0,
            'vincent': 600.0,
            'monica': 600.0,
            'sri': 600.0,
            'ashwin': 600.0,
          },
        },
        {
          'id': 'exp_o2',
          'description': 'cab rentals',
          'amount': 5000.0,
          'paidBy': 'vincent',
          'category': 'Transport',
          'date': '2026-09-12',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'Admin': 1000.0,
            'vincent': 1000.0,
            'monica': 1000.0,
            'sri': 1000.0,
            'ashwin': 1000.0,
          },
        },
      ],
      'debts': <Map<String, dynamic>>[],
      'settlements': <Map<String, dynamic>>[],
    },
    {
      'id': 'ticket_goa',
      'title': 'goa trip',
      'currency': 'INR',
      'description': 'tea , hotel , travel',
      'budget': 30000.0,
      'participants': ['Admin', 'santhosh', 'ashwin', 'sree', 'kamesh'],
      'members': <Map<String, dynamic>>[
        {
          'name': 'Admin',
          'email': 'admin@bnxmail.com',
          'role': 'Creator & Admin',
          'isCreator': true,
          'isPending': false,
        },
        {
          'name': 'santhosh',
          'email': 'santhosh@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'ashwin',
          'email': 'ashwin@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'sree',
          'email': 'sree@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
        {
          'name': 'kamesh',
          'email': 'kamesh@bnxmail.com',
          'role': 'View Only',
          'isCreator': false,
          'isPending': true,
        },
      ],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_g1',
          'description': 'villa rental',
          'amount': 15000.0,
          'paidBy': 'Admin',
          'category': 'Stay',
          'date': '2026-09-05',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'Admin': 3000.0,
            'santhosh': 3000.0,
            'ashwin': 3000.0,
            'sree': 3000.0,
            'kamesh': 3000.0,
          },
        },
        {
          'id': 'exp_g2',
          'description': 'food & travel',
          'amount': 10000.0,
          'paidBy': 'kamesh',
          'category': 'Food',
          'date': '2026-09-05',
          'splitMode': 'Equal Split',
          'shares': <String, double>{
            'Admin': 2000.0,
            'santhosh': 2000.0,
            'ashwin': 2000.0,
            'sree': 2000.0,
            'kamesh': 2000.0,
          },
        },
      ],
      'debts': <Map<String, dynamic>>[],
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
  bool _isMembersExpanded = true;
  String _selectedCategoryFilter = 'All';
  final Set<String> _expandedExpenseIds = <String>{};

  List<Map<String, dynamic>> get _tickets => SplitExpenseStore.tickets;
  String? get _selectedTicketId => SplitExpenseStore.selectedTicketId;
  set _selectedTicketId(String? id) => SplitExpenseStore.selectedTicketId = id;

  String _formatAmount(double amt) {
    if (amt % 1 == 0) {
      return amt.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    } else {
      return amt
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
  }

  Map<String, dynamic>? get _selectedTicket {
    if (_selectedTicketId == null) return null;
    try {
      return _tickets.firstWhere((t) => t['id'] == _selectedTicketId);
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DYNAMIC ACCOUNTING ENGINE
  // ══════════════════════════════════════════════════════════════════════════

  /// Dynamically computes paid, charged, and net balance for every participant.
  /// Formula:
  ///   paid(m)    = sum(expense.amount where expense.paidBy == m)
  ///   charged(m) = sum(shares[m] across all expenses)
  ///   balance(m) = paid(m) - charged(m) + sum(settlements where m is debtor) - sum(settlements where m is creditor)
  /// Sum of all balances across the ticket is ALWAYS 0.0.
  Map<String, Map<String, double>> _calculateMemberStats(
    Map<String, dynamic> ticket,
  ) {
    final participants = List<String>.from(
      ticket['participants'] as List? ?? [],
    );
    final stats = <String, Map<String, double>>{
      for (var p in participants)
        p: {'paid': 0.0, 'charged': 0.0, 'balance': 0.0},
    };

    final expenses = List<Map<String, dynamic>>.from(
      ticket['expenses'] as List? ?? [],
    );
    for (var exp in expenses) {
      final paidBy = exp['paidBy'] as String? ?? '';
      final amount = (exp['amount'] as num?)?.toDouble() ?? 0.0;
      final shares = Map<String, dynamic>.from(exp['shares'] as Map? ?? {});

      if (paidBy.isNotEmpty) {
        stats.putIfAbsent(
          paidBy,
          () => {'paid': 0.0, 'charged': 0.0, 'balance': 0.0},
        );
        stats[paidBy]!['paid'] = stats[paidBy]!['paid']! + amount;
      }

      if (shares.isNotEmpty) {
        shares.forEach((person, shareVal) {
          final s = (shareVal as num?)?.toDouble() ?? 0.0;
          stats.putIfAbsent(
            person,
            () => {'paid': 0.0, 'charged': 0.0, 'balance': 0.0},
          );
          stats[person]!['charged'] = stats[person]!['charged']! + s;
        });
      } else if (participants.isNotEmpty) {
        final eq = amount / participants.length;
        for (var p in participants) {
          stats[p]!['charged'] = stats[p]!['charged']! + eq;
        }
      }
    }

    // Adjust for settlements
    final settlements = List<Map<String, dynamic>>.from(
      ticket['settlements'] as List? ?? [],
    );
    for (var st in settlements) {
      final debtor = (st['debtor'] ?? st['from']) as String? ?? '';
      final creditor = (st['creditor'] ?? st['to']) as String? ?? '';
      final amt = (st['amount'] as num?)?.toDouble() ?? 0.0;

      if (debtor.isNotEmpty) {
        stats.putIfAbsent(
          debtor,
          () => {'paid': 0.0, 'charged': 0.0, 'balance': 0.0},
        );
        stats[debtor]!['balance'] = stats[debtor]!['balance']! + amt;
      }
      if (creditor.isNotEmpty) {
        stats.putIfAbsent(
          creditor,
          () => {'paid': 0.0, 'charged': 0.0, 'balance': 0.0},
        );
        stats[creditor]!['balance'] = stats[creditor]!['balance']! - amt;
      }
    }

    stats.forEach((person, map) {
      final baseBalance = map['paid']! - map['charged']!;
      map['balance'] = baseBalance + map['balance']!;
    });

    return stats;
  }

  /// Extracts net balances map for simplified debts algorithm
  Map<String, double> _calculateBalances(Map<String, dynamic> ticket) {
    final stats = _calculateMemberStats(ticket);
    return stats.map((k, v) => MapEntry(k, v['balance']!));
  }

  /// Calculates simplified debts using optimal Minimum Cash Flow
  List<Map<String, dynamic>> _calculateSimplifiedDebts(
    Map<String, double> balances,
  ) {
    final debtors = <String, double>{};
    final creditors = <String, double>{};

    balances.forEach((person, bal) {
      final roundedBal = (bal * 100).roundToDouble() / 100.0;
      if (roundedBal < -0.005) {
        debtors[person] = -roundedBal;
      } else if (roundedBal > 0.005) {
        creditors[person] = roundedBal;
      }
    });

    final debts = <Map<String, dynamic>>[];

    while (debtors.isNotEmpty && creditors.isNotEmpty) {
      String? bestDebtor;
      String? bestCreditor;
      double matchAmount = 0.0;

      // 1. Exact match priority
      for (final d in debtors.entries) {
        for (final c in creditors.entries) {
          if ((d.value - c.value).abs() < 0.005) {
            bestDebtor = d.key;
            bestCreditor = c.key;
            matchAmount = d.value;
            break;
          }
        }
        if (bestDebtor != null) break;
      }

      // 2. Greedy match
      if (bestDebtor == null || bestCreditor == null) {
        bestDebtor = debtors.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        bestCreditor = creditors.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        final dVal = debtors[bestDebtor]!;
        final cVal = creditors[bestCreditor]!;
        matchAmount = dVal < cVal ? dVal : cVal;
      }

      if (matchAmount > 0.005) {
        debts.add({
          'from': bestDebtor,
          'to': bestCreditor,
          'amount': matchAmount,
        });

        debtors[bestDebtor] = debtors[bestDebtor]! - matchAmount;
        creditors[bestCreditor] = creditors[bestCreditor]! - matchAmount;
      }

      if (debtors[bestDebtor]! < 0.005) {
        debtors.remove(bestDebtor);
      }
      if (creditors[bestCreditor]! < 0.005) {
        creditors.remove(bestCreditor);
      }
    }

    debts.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
    return debts;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTIONS & DIALOGS
  // ══════════════════════════════════════════════════════════════════════════

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

  void _showEditTicketDialog(Map<String, dynamic> ticket) {
    final titleCtrl = TextEditingController(text: ticket['title'] as String);
    final descCtrl = TextEditingController(
      text: ticket['description'] as String? ?? '',
    );
    final budgetCtrl = TextEditingController(
      text: (ticket['budget'] as num?) != null
          ? (ticket['budget'] as num).toInt().toString()
          : '',
    );
    String selectedCurrency = ticket['currency'] as String? ?? 'INR';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.pencil,
                  size: 18,
                  color: Color(0xFF0E4D34),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Edit Ticket Details',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogInputLabel('TICKET TITLE'),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: _dialogInputDecoration('Ticket Title'),
                ),
                const SizedBox(height: 14),
                _buildDialogInputLabel('DESCRIPTION'),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: _dialogInputDecoration('Description or Notes'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogInputLabel('TARGET BUDGET (₹)'),
                          TextField(
                            controller: budgetCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: _dialogInputDecoration('Budget Amount'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogInputLabel('CURRENCY'),
                          Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCurrency,
                                isExpanded: true,
                                items: ['INR', 'USD', 'EUR', 'GBP']
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null)
                                    setDialogState(() => selectedCurrency = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final t = titleCtrl.text.trim();
                if (t.isEmpty) {
                  AppSnackbar.show(
                    context,
                    'Title cannot be empty',
                    type: SnackType.warning,
                  );
                  return;
                }
                setState(() {
                  ticket['title'] = t;
                  ticket['description'] = descCtrl.text.trim();
                  ticket['currency'] = selectedCurrency;
                  ticket['budget'] =
                      double.tryParse(budgetCtrl.text.trim()) ?? 0.0;
                });
                Navigator.pop(ctx);
                AppSnackbar.show(
                  context,
                  'Ticket details updated successfully!',
                  type: SnackType.success,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E4D34),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateTicket(Map<String, dynamic> ticket) {
    final clonedId = 'ticket_${DateTime.now().millisecondsSinceEpoch}';
    final clonedTitle = '${ticket['title']} (Copy)';
    final cloned = {
      'id': clonedId,
      'title': clonedTitle,
      'currency': ticket['currency'] ?? 'INR',
      'description': ticket['description'] ?? '',
      'budget': ticket['budget'] ?? 0.0,
      'participants': List<String>.from(ticket['participants'] as List? ?? []),
      'members': (ticket['members'] as List? ?? [])
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList(),
      'expenses': <Map<String, dynamic>>[],
      'debts': <Map<String, dynamic>>[],
      'settlements': <Map<String, dynamic>>[],
    };

    setState(() {
      _tickets.add(cloned);
      _selectedTicketId = clonedId;
    });
    AppSnackbar.show(
      context,
      "Duplicated ticket as '$clonedTitle'!",
      type: SnackType.success,
    );
  }

  void _deleteTicket(String ticketId) {
    final ticket = _tickets.firstWhere(
      (t) => t['id'] == ticketId,
      orElse: () => {},
    );
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
      (ticket['expenses'] as List<Map<String, dynamic>>).removeWhere(
        (e) => e['id'] == expenseId,
      );
      _expandedExpenseIds.remove(expenseId);
    });
    AppSnackbar.show(
      context,
      "Expense deleted and debts recalculated.",
      type: SnackType.info,
    );
  }

  void _deleteSettlement(Map<String, dynamic> ticket, String settlementId) {
    setState(() {
      (ticket['settlements'] as List<Map<String, dynamic>>).removeWhere(
        (s) => s['id'] == settlementId,
      );
    });
    AppSnackbar.show(
      context,
      "Settlement removed. Debts and balances restored.",
      type: SnackType.info,
    );
  }

  void _settleDebt(
    Map<String, dynamic> ticket,
    String debtor,
    String creditor,
    double amount,
  ) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    setState(() {
      (ticket['settlements'] as List<Map<String, dynamic>>).insert(0, {
        'id': 'settle_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'payment : $debtor paid $creditor',
        'debtor': debtor,
        'creditor': creditor,
        'amount': amount,
        'date': dateStr,
        'note': 'Full settlement',
      });
    });
    AppSnackbar.show(
      context,
      "Settled ₹${_formatAmount(amount)} from $debtor to $creditor!",
      type: SnackType.success,
    );
  }

  void _sendDebtReminder(String debtor, String creditor, double amount) {
    AppSnackbar.show(
      context,
      "🔔 Payment reminder & UPI link sent to $debtor for ₹${_formatAmount(amount)}!",
      type: SnackType.info,
    );
  }

  void _showCustomPayDialog(
    Map<String, dynamic> ticket,
    Map<String, dynamic> debt,
  ) {
    final debtor = (debt['from'] ?? debt['debtor']) as String;
    final creditor = (debt['to'] ?? debt['creditor']) as String;
    final maxAmount = (debt['amount'] as num).toDouble();
    final controller = TextEditingController(
      text: maxAmount % 1 == 0
          ? maxAmount.toInt().toString()
          : maxAmount.toStringAsFixed(2),
    );

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
              child: const Icon(
                LucideIcons.banknote,
                color: Color(0xFF059669),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Custom Pay',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter amount to settle from $debtor to $creditor (Max ₹${_formatAmount(maxAmount)})',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  const CurrencyInputFormatter(
                    integerDigits: 12,
                    decimalDigits: 2,
                  ),
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  labelText: 'Payment Amount',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final amt =
                  double.tryParse(controller.text.trim().replaceAll(',', '')) ??
                  0.0;
              if (amt <= 0) {
                AppSnackbar.show(
                  context,
                  'Please enter a valid amount',
                  type: SnackType.warning,
                );
                return;
              }
              if (amt > maxAmount + 0.005) {
                AppSnackbar.show(
                  context,
                  'Amount cannot exceed ₹${_formatAmount(maxAmount)}',
                  type: SnackType.warning,
                );
                return;
              }
              Navigator.pop(ctx);
              _settleDebt(ticket, debtor, creditor, amt);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Confirm Settle',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RECORD EXPENSE MODAL DIALOG (Matches Image 9 & 10)
  // ══════════════════════════════════════════════════════════════════════════
  void _showRecordExpenseDialog(
    Map<String, dynamic> ticket, [
    Map<String, dynamic>? existingExpense,
  ]) {
    final participants = List<String>.from(
      ticket['participants'] as List? ?? [],
    );

    final descController = TextEditingController(
      text: existingExpense != null ? existingExpense['description'] : '',
    );
    final amountController = TextEditingController(
      text: existingExpense != null
          ? (existingExpense['amount'] as num).toInt().toString()
          : '0.00',
    );
    final dateController = TextEditingController(
      text: existingExpense != null ? existingExpense['date'] : '17/11/2026',
    );
    String paidBy = existingExpense != null
        ? existingExpense['paidBy']
        : (participants.contains('Admin')
              ? 'Admin'
              : (participants.contains('You') ? 'You' : participants.first));
    String selectedCategory = existingExpense != null
        ? (existingExpense['category'] ?? 'Food')
        : 'Food';
    bool isCustomSplit = existingExpense != null
        ? existingExpense['splitMode'] == 'Customize Shares'
        : false;
    Map<String, dynamic>? attachedReceipt = existingExpense != null
        ? existingExpense['receipt']
        : null;

    final customShareControllers = <String, TextEditingController>{};
    for (var p in participants) {
      double initialShare = 0.0;
      if (existingExpense != null && existingExpense['shares'] != null) {
        initialShare =
            (existingExpense['shares'][p] as num?)?.toDouble() ?? 0.0;
      }
      customShareControllers[p] = TextEditingController(
        text: initialShare > 0 ? initialShare.toStringAsFixed(2) : '0.00',
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final totalAmount =
              double.tryParse(
                amountController.text.trim().replaceAll(',', ''),
              ) ??
              0.0;
          final equalShare = participants.isNotEmpty
              ? (totalAmount / participants.length)
              : 0.0;

          double sumCustomShares = 0.0;
          for (var p in participants) {
            sumCustomShares +=
                double.tryParse(
                  customShareControllers[p]!.text.trim().replaceAll(',', ''),
                ) ??
                0.0;
          }
          final diff = totalAmount - sumCustomShares;
          final bool isButtonDisabled =
              isCustomSplit && (totalAmount <= 0 || diff.abs() > 0.01);

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingExpense != null
                              ? 'Edit Expense'
                              : 'Record Expense',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

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
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: _dialogInputDecoration(
                                  'e.g. Dinner, Uber, Flight ticket',
                                ),
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  const CurrencyInputFormatter(
                                    integerDigits: 12,
                                    decimalDigits: 2,
                                  ),
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                onChanged: (_) => setModalState(() {}),
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: _dialogInputDecoration('0.00'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 2: WHO PAID?, CATEGORY & DATE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogInputLabel('WHO PAID?'),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: paidBy,
                                    isExpanded: true,
                                    icon: const Icon(
                                      LucideIcons.chevronDown,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                    items: participants.map((p) {
                                      return DropdownMenuItem(
                                        value: p,
                                        child: Text(
                                          p,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      if (v != null)
                                        setModalState(() => paidBy = v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogInputLabel('CATEGORY'),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    isExpanded: true,
                                    icon: const Icon(
                                      LucideIcons.chevronDown,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                    items:
                                        [
                                          'Food',
                                          'Transport',
                                          'Stay',
                                          'Shopping',
                                          'Office',
                                          'Misc',
                                        ].map((cat) {
                                          return DropdownMenuItem(
                                            value: cat,
                                            child: Text(
                                              cat,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (v) {
                                      if (v != null)
                                        setModalState(
                                          () => selectedCategory = v,
                                        );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
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
                                    final d = picked.day.toString().padLeft(
                                      2,
                                      '0',
                                    );
                                    final m = picked.month.toString().padLeft(
                                      2,
                                      '0',
                                    );
                                    final y = picked.year.toString();
                                    dateController.text = '$d/$m/$y';
                                    setModalState(() {});
                                  }
                                },
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: _dialogInputDecoration('17/11/2026')
                                    .copyWith(
                                      suffixIcon: const Icon(
                                        LucideIcons.calendar,
                                        size: 16,
                                        color: Color(0xFF0F172A),
                                      ),
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
                        setModalState(() {
                          attachedReceipt = {
                            'name':
                                'receipt_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}.pdf',
                            'size': '1.4 MB',
                          };
                        });
                        AppSnackbar.show(
                          context,
                          "Receipt attached successfully.",
                          type: SnackType.info,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: attachedReceipt != null
                                ? const Color(0xFF10B981)
                                : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              attachedReceipt != null
                                  ? LucideIcons.fileCheck
                                  : LucideIcons.upload,
                              size: 20,
                              color: const Color(0xFF059669),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              attachedReceipt != null
                                  ? 'Attached: ${attachedReceipt!['name']} (${attachedReceipt!['size']})'
                                  : 'Click to upload invoice / receipt copy',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: attachedReceipt != null
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              attachedReceipt != null
                                  ? 'Click again to replace receipt copy'
                                  : 'Supports PNG, JPG, WEBP, or PDF (up to 20MB)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
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
                            onPressed: () =>
                                setModalState(() => isCustomSplit = false),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: !isCustomSplit
                                    ? const Color(0xFF0E4D34)
                                    : const Color(0xFFE2E8F0),
                                width: !isCustomSplit ? 1.8 : 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Split Equally',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: !isCustomSplit
                                    ? const Color(0xFF0E4D34)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setModalState(() => isCustomSplit = true),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isCustomSplit
                                    ? const Color(0xFF0E4D34)
                                    : const Color(0xFFE2E8F0),
                                width: isCustomSplit ? 1.8 : 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Customize Shares',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isCustomSplit
                                    ? const Color(0xFF0E4D34)
                                    : const Color(0xFF64748B),
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
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
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
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  if (isCustomSplit)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '₹',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 80,
                                          height: 36,
                                          child: TextFormField(
                                            controller:
                                                customShareControllers[p],
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            textAlign: TextAlign.center,
                                            onChanged: (_) =>
                                                setModalState(() {}),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 8,
                                                  ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFCBD5E1),
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFCBD5E1),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF0E4D34),
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      '₹${equalShare.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (isCustomSplit) ...[
                            const SizedBox(height: 10),
                            if (diff.abs() <= 0.01)
                              const Row(
                                children: [
                                  Icon(
                                    LucideIcons.info,
                                    size: 14,
                                    color: Color(0xFF059669),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'All allocations match total perfectly!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.alertCircle,
                                    size: 14,
                                    color: Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    diff > 0
                                        ? 'Remaining unallocated: ₹${_formatAmount(diff)}'
                                        : 'Overallocated by: ₹${_formatAmount(diff.abs())}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Log Expense Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isButtonDisabled
                            ? null
                            : () {
                                if (totalAmount <= 0) {
                                  AppSnackbar.show(
                                    context,
                                    'Please enter a valid expense amount',
                                    type: SnackType.warning,
                                  );
                                  return;
                                }
                                if (descController.text.trim().isEmpty) {
                                  AppSnackbar.show(
                                    context,
                                    'Please enter an expense description',
                                    type: SnackType.warning,
                                  );
                                  return;
                                }
                                if (isCustomSplit && diff.abs() > 0.01) {
                                  AppSnackbar.show(
                                    context,
                                    'Custom allocations must sum exactly to ₹${_formatAmount(totalAmount)}',
                                    type: SnackType.warning,
                                  );
                                  return;
                                }

                                final Map<String, double> finalShares = {};
                                if (isCustomSplit) {
                                  for (var p in participants) {
                                    final shareVal =
                                        double.tryParse(
                                          customShareControllers[p]!.text
                                              .trim()
                                              .replaceAll(',', ''),
                                        ) ??
                                        0.0;
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
                                      : 'exp_${DateTime.now().millisecondsSinceEpoch}',
                                  'description': descController.text.trim(),
                                  'amount': totalAmount,
                                  'paidBy': paidBy,
                                  'category': selectedCategory,
                                  'date': dateController.text.trim().replaceAll(
                                    '/',
                                    '-',
                                  ),
                                  'splitMode': isCustomSplit
                                      ? 'Customize Shares'
                                      : 'Equal Split',
                                  'receipt': attachedReceipt,
                                  'shares': finalShares,
                                };

                                setState(() {
                                  final exps =
                                      ticket['expenses']
                                          as List<Map<String, dynamic>>;
                                  if (existingExpense != null) {
                                    final idx = exps.indexWhere(
                                      (e) => e['id'] == existingExpense['id'],
                                    );
                                    if (idx != -1) exps[idx] = newExp;
                                  } else {
                                    exps.insert(0, newExp);
                                  }
                                });

                                Navigator.pop(ctx);
                                AppSnackbar.show(
                                  context,
                                  existingExpense != null
                                      ? "Expense updated!"
                                      : "Expense logged successfully!",
                                  type: SnackType.success,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E4D34),
                          disabledBackgroundColor: const Color(0xFFCBD5E1),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          existingExpense != null
                              ? 'Update Expense'
                              : 'Log Expense',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
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

  // ══════════════════════════════════════════════════════════════════════════
  // INVITE MEMBER DIALOG WITH RETROACTIVE SPLIT RECALCULATION
  // ══════════════════════════════════════════════════════════════════════════
  void _showInviteMemberDialog(Map<String, dynamic> ticket) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String selectedPermission = 'View Only';
    bool includeInPreviousExpenses = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invite Member to Split',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Send an invite code or email notification to collaborate on this split ticket.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 18),

                    // Field 1: EMAIL ADDRESS *
                    const Text(
                      'EMAIL ADDRESS *',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'colleague@bnxmail.com',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0E4D34),
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 2: DISPLAY NAME (OPTIONAL)
                    const Text(
                      'DISPLAY NAME (OPTIONAL)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. John Doe',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0E4D34),
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Field 3: ACCESS PERMISSION
                    const Text(
                      'ACCESS PERMISSION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3 Permission Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildPermissionCard(
                            title: 'Edit Access',
                            icon: LucideIcons.pencil,
                            subtitle:
                                'Can add expenses, edit details & record settlements',
                            isSelected: selectedPermission == 'Edit Access',
                            onTap: () => setDialogState(
                              () => selectedPermission = 'Edit Access',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPermissionCard(
                            title: 'View Only',
                            icon: LucideIcons.eye,
                            subtitle:
                                'Can only view expenses and their own balances',
                            isSelected: selectedPermission == 'View Only',
                            onTap: () => setDialogState(
                              () => selectedPermission = 'View Only',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPermissionCard(
                            title: 'Admin',
                            icon: LucideIcons.crown,
                            subtitle:
                                'Full control over members, expenses and settings',
                            isSelected: selectedPermission == 'Admin',
                            onTap: () => setDialogState(
                              () => selectedPermission = 'Admin',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Field 4: Include in previous expenses Checkbox
                    InkWell(
                      onTap: () => setDialogState(
                        () => includeInPreviousExpenses =
                            !includeInPreviousExpenses,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: includeInPreviousExpenses,
                            onChanged: (v) => setDialogState(
                              () => includeInPreviousExpenses = v ?? true,
                            ),
                            activeColor: const Color(0xFF0E4D34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Include in previous expenses',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Retroactively adds this member to past equal-split expenses',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions: Cancel & Send Invite
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final email = emailController.text.trim();
                            if (email.isEmpty) {
                              AppSnackbar.show(
                                context,
                                "Please enter a valid email address",
                                type: SnackType.error,
                              );
                              return;
                            }
                            final name = nameController.text.trim().isNotEmpty
                                ? nameController.text.trim()
                                : email.split('@').first;

                            setState(() {
                              final members = List<Map<String, dynamic>>.from(
                                ticket['members'] as List? ?? [],
                              );
                              final participants = List<String>.from(
                                ticket['participants'] as List? ?? [],
                              );

                              final newM = {
                                'name': name,
                                'email': email,
                                'role': selectedPermission,
                                'isCreator': selectedPermission == 'Admin',
                                'isPending': true,
                              };

                              members.add(newM);
                              ticket['members'] = members;

                              if (!participants.contains(name)) {
                                participants.add(name);
                                ticket['participants'] = participants;
                              }

                              // Retroactive share recalculation if requested
                              if (includeInPreviousExpenses) {
                                final expenses =
                                    List<Map<String, dynamic>>.from(
                                      ticket['expenses'] as List? ?? [],
                                    );
                                for (var exp in expenses) {
                                  if (exp['splitMode'] == 'Equal Split') {
                                    final amt = (exp['amount'] as num)
                                        .toDouble();
                                    final newEq = amt / participants.length;
                                    final newShares = <String, double>{};
                                    for (var p in participants) {
                                      newShares[p] = newEq;
                                    }
                                    exp['shares'] = newShares;
                                  }
                                }
                              }
                            });

                            Navigator.pop(ctx);
                            AppSnackbar.show(
                              context,
                              "Invitation sent to $email successfully!",
                              type: SnackType.success,
                            );
                          },
                          icon: const Icon(LucideIcons.send, size: 14),
                          label: const Text(
                            'Send Invite',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E4D34),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
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

  // ══════════════════════════════════════════════════════════════════════════
  // EXPORT SUMMARY & AUDIT MODAL (New Functionality)
  // ══════════════════════════════════════════════════════════════════════════
  void _showExportSummaryDialog(Map<String, dynamic> ticket) {
    final memberStats = _calculateMemberStats(ticket);
    final balances = _calculateBalances(ticket);
    final debts = _calculateSimplifiedDebts(balances);
    final expenses = List<Map<String, dynamic>>.from(
      ticket['expenses'] as List? ?? [],
    );
    final settlements = List<Map<String, dynamic>>.from(
      ticket['settlements'] as List? ?? [],
    );

    double totalSpent = 0.0;
    for (var e in expenses) {
      totalSpent += (e['amount'] as num).toDouble();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.fileSpreadsheet,
                size: 18,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ticket['title']} • Summary Report',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Complete ledger & balance audit',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Summary Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'TOTAL EXPENSES',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${_formatAmount(totalSpent)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 28,
                        width: 1,
                        color: const Color(0xFFCBD5E1),
                      ),
                      Column(
                        children: [
                          const Text(
                            'SESSIONS',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${expenses.length}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 28,
                        width: 1,
                        color: const Color(0xFFCBD5E1),
                      ),
                      Column(
                        children: [
                          const Text(
                            'SETTLEMENTS',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${settlements.length}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Member Balances Table
                const Text(
                  'MEMBER POSITIONS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                ...memberStats.entries.map((entry) {
                  final name = entry.key;
                  final p = entry.value['paid']!;
                  final c = entry.value['charged']!;
                  final b = entry.value['balance']!;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Paid: ₹${_formatAmount(p)} | Charged: ₹${_formatAmount(c)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          b.abs() <= 0.005
                              ? 'Settled'
                              : '${b > 0 ? '+' : '-'}₹${_formatAmount(b.abs())}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: b > 0.005
                                ? const Color(0xFF059669)
                                : (b < -0.005
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Pending Debts
                const Text(
                  'SIMPLIFIED DEBT INSTRUCTIONS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                if (debts.isEmpty)
                  const Text(
                    'All debts have been completely settled! ✨',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  ...debts.map((d) {
                    final from = d['from'];
                    final to = d['to'];
                    final amt = (d['amount'] as num).toDouble();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '• $from pays $to: ₹${_formatAmount(amt)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF334155),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              final buffer = StringBuffer();
              buffer.writeln('📋 SPLIT TICKET SUMMARY: ${ticket['title']}');
              buffer.writeln(
                'Total Spent: ₹${_formatAmount(totalSpent)} (${ticket['currency']})',
              );
              buffer.writeln('\nMember Net Balances:');
              memberStats.forEach((name, st) {
                final b = st['balance']!;
                buffer.writeln(
                  '• $name: ${b >= 0 ? '+' : '-'}₹${_formatAmount(b.abs())}',
                );
              });
              buffer.writeln('\nPending Debts:');
              for (var d in debts) {
                buffer.writeln(
                  '• ${d['from']} owes ${d['to']} ₹${_formatAmount((d['amount'] as num).toDouble())}',
                );
              }
              Clipboard.setData(ClipboardData(text: buffer.toString()));
              Navigator.pop(ctx);
              AppSnackbar.show(
                context,
                'Summary copied to clipboard for WhatsApp/Slack!',
                type: SnackType.success,
              );
            },
            icon: const Icon(LucideIcons.copy, size: 14),
            label: const Text(
              'Copy Text Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0E4D34),
              side: const BorderSide(color: Color(0xFF0E4D34)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppSnackbar.show(
                context,
                'CSV statement downloaded successfully.',
                type: SnackType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E4D34),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RECEIPT PREVIEW MODAL (New Functionality)
  // ══════════════════════════════════════════════════════════════════════════
  void _showReceiptPreviewDialog(Map<String, dynamic> expense) {
    final receipt = expense['receipt'] as Map<String, dynamic>?;
    final fileName = receipt != null ? receipt['name'] : 'receipt.pdf';
    final fileSize = receipt != null ? receipt['size'] : '1.2 MB';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.receipt,
                size: 18,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipt: ${expense['description']}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$fileName • $fileSize',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Container(
          width: 380,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.fileCheck,
                size: 48,
                color: Color(0xFF059669),
              ),
              const SizedBox(height: 12),
              Text(
                fileName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Amount: ₹${_formatAmount((expense['amount'] as num).toDouble())} • Paid by ${expense['paidBy']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✓ Verified Digital Proof',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              AppSnackbar.show(
                context,
                'Downloading $fileName...',
                type: SnackType.info,
              );
            },
            icon: const Icon(LucideIcons.download, size: 14),
            label: const Text(
              'Download',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E4D34),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN BUILD METHODS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 28.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          paddingVal,
          20,
          paddingVal,
          isMobile ? 100 : 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

  Widget _buildTopHeader(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E4D34),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.creditCard,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Splitwise & Collect',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Divide collaborative bills, track expenses, and simplify balances with team members.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedTicket == null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createNewTicket,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text(
                  'New Split Ticket',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E4D34),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      );
    }

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
          child: const Icon(
            LucideIcons.creditCard,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Splitwise & Collect',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Divide collaborative bills, track expenses, and simplify balances with team members.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (_selectedTicket == null) ...[
          ElevatedButton.icon(
            onPressed: _createNewTicket,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text(
              'New Split Ticket',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E4D34),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TICKETS LIST VIEW (Matches Image 8)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTicketsListView(BuildContext context, bool isMobile) {
    final filteredTickets = _tickets.where((t) {
      final title = (t['title'] as String).toLowerCase();
      final desc = (t['description'] as String).toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) ||
          desc.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              const Icon(
                LucideIcons.search,
                color: Color(0xFF94A3B8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search split tickets...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
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
                Text(
                  'No split tickets found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final int crossAxisCount = constraints.maxWidth > 1050
                  ? 3
                  : (constraints.maxWidth > 680 ? 2 : 1);
              final double cardWidth =
                  (constraints.maxWidth - (crossAxisCount - 1) * 20) /
                  crossAxisCount;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: filteredTickets
                    .map((t) => _buildTicketCard(context, cardWidth, t))
                    .toList(),
              );
            },
          ),
      ],
    );
  }

  // TICKET CARD
  Widget _buildTicketCard(
    BuildContext context,
    double width,
    Map<String, dynamic> ticket,
  ) {
    final participants = List<String>.from(
      ticket['participants'] as List? ?? [],
    );
    final expenses = List<Map<String, dynamic>>.from(
      ticket['expenses'] as List? ?? [],
    );

    double totalSpent = 0.0;
    for (var e in expenses) {
      totalSpent += (e['amount'] as num).toDouble();
    }
    final totalSpentStr = _formatAmount(totalSpent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedTicketId = ticket['id'] as String),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      LucideIcons.ellipsisVertical,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) {
                      if (val == 'view') {
                        setState(
                          () => _selectedTicketId = ticket['id'] as String,
                        );
                      } else if (val == 'edit') {
                        _showEditTicketDialog(ticket);
                      } else if (val == 'duplicate') {
                        _duplicateTicket(ticket);
                      } else if (val == 'export') {
                        _showExportSummaryDialog(ticket);
                      } else if (val == 'delete') {
                        _deleteTicket(ticket['id'] as String);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Ticket'),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate Ticket'),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('Export Summary'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete Ticket',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Currency & Admin Badge Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
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
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.crown,
                          size: 11,
                          color: Color(0xFF7E22CE),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: Color(0xFF7E22CE),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              const SizedBox(height: 16),

              // Member chips row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...participants.take(4).map((name) {
                    final isCreator = name == 'You' || name == 'Admin';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCreator) ...[
                            const Icon(
                              LucideIcons.crown,
                              size: 10,
                              color: Color(0xFF7E22CE),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (participants.length > 4)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '+${participants.length - 4} more',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Divider
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              // Footer: Members count & Total Spent
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.users,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${participants.length} Members',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
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
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹$totalSpentStr',
                        style: const TextStyle(
                          fontSize: 16.5,
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

  // ══════════════════════════════════════════════════════════════════════════
  // TICKET DETAIL VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTicketDetailView(
    BuildContext context,
    bool isMobile,
    Map<String, dynamic> ticket,
  ) {
    final expenses = List<Map<String, dynamic>>.from(
      ticket['expenses'] as List? ?? [],
    );

    // Filter expenses by search query & category
    final filteredExpenses = expenses.where((e) {
      final desc = (e['description'] as String).toLowerCase();
      final paid = (e['paidBy'] as String).toLowerCase();
      final cat = (e['category'] as String? ?? 'Misc').toLowerCase();
      final matchesSearch =
          desc.contains(_expenseSearchQuery.toLowerCase()) ||
          paid.contains(_expenseSearchQuery.toLowerCase());
      final matchesCat =
          _selectedCategoryFilter == 'All' ||
          cat == _selectedCategoryFilter.toLowerCase();
      return matchesSearch && matchesCat;
    }).toList();

    double totalOutlay = 0.0;
    for (var e in expenses) {
      totalOutlay += (e['amount'] as num).toDouble();
    }
    final totalOutlayStr = _formatAmount(totalOutlay);

    final balances = _calculateBalances(ticket);
    final debts = _calculateSimplifiedDebts(balances);
    final settlements = List<Map<String, dynamic>>.from(
      ticket['settlements'] as List? ?? [],
    );

    double totalSettled = 0.0;
    for (var s in settlements) {
      totalSettled += (s['amount'] as num).toDouble();
    }
    final totalSettledStr = _formatAmount(totalSettled);

    final budget = (ticket['budget'] as num?)?.toDouble() ?? 0.0;
    final budgetPercent = budget > 0
        ? (totalOutlay / budget).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-navigation: Back to all tickets & Right Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: InkWell(
                onTap: () => setState(() => _selectedTicketId = null),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.chevronLeft,
                        size: 16,
                        color: Color(0xFF0E4D34),
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Back to all tickets',
                          style: TextStyle(
                            color: Color(0xFF0E4D34),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showInviteMemberDialog(ticket),
                  icon: const Icon(LucideIcons.userPlus, size: 14),
                  label: const Text(
                    'Invite Member',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0E4D34),
                    side: const BorderSide(color: Color(0xFF0E4D34)),
                    backgroundColor: const Color(0xFFF0FDF4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showRecordExpenseDialog(ticket),
                  icon: const Icon(LucideIcons.plus, size: 15),
                  label: const Text(
                    'Add Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E4D34),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Group Banner Outlay Card (with Budget bar)
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${ticket['currency'] ?? 'INR'} GROUP',
                                style: const TextStyle(
                                  color: Color(0xFF15803D),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.crown,
                                    size: 11,
                                    color: Color(0xFF7E22CE),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'ADMIN / CREATOR',
                                    style: TextStyle(
                                      color: Color(0xFF7E22CE),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                        if ((ticket['description'] as String? ?? '')
                            .isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            ticket['description'] as String,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TOTAL GROUP OUTLAY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹$totalOutlayStr',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (budget > 0) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Utilization: ${(budgetPercent * 100).toInt()}% of ₹${_formatAmount(budget)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      totalOutlay > budget
                          ? 'Over budget by ₹${_formatAmount(totalOutlay - budget)}'
                          : 'Remaining: ₹${_formatAmount(budget - totalOutlay)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: totalOutlay > budget
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budgetPercent,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      totalOutlay > budget
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF0E4D34),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2-Column or Stacked Details Layout
        isMobile
            ? Column(
                children: [
                  _buildLoggedExpensesColumn(
                    context,
                    isMobile,
                    ticket,
                    filteredExpenses,
                  ),
                  const SizedBox(height: 24),
                  _buildRightDetailColumn(
                    context,
                    isMobile,
                    ticket,
                    balances,
                    debts,
                    settlements,
                    totalSettledStr,
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildLoggedExpensesColumn(
                      context,
                      isMobile,
                      ticket,
                      filteredExpenses,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 5,
                    child: _buildRightDetailColumn(
                      context,
                      isMobile,
                      ticket,
                      balances,
                      debts,
                      settlements,
                      totalSettledStr,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEFT COLUMN: LOGGED EXPENSES (with Categories, Expandable Drawer, Receipts)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildLoggedExpensesColumn(
    BuildContext context,
    bool isMobile,
    Map<String, dynamic> ticket,
    List<Map<String, dynamic>> expenses,
  ) {
    final allExpenses = List<Map<String, dynamic>>.from(
      ticket['expenses'] as List? ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: LOGGED EXPENSES, Sessions chip, search, share, download
        Row(
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Flexible(
                    child: Text(
                      'LOGGED EXPENSES',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${allExpenses.length} Sessions',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    LucideIcons.search,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _isExpenseSearchVisible = !_isExpenseSearchVisible;
                      if (!_isExpenseSearchVisible) _expenseSearchQuery = '';
                    });
                  },
                ),
                const SizedBox(width: 2),
                IconButton(
                  icon: const Icon(
                    LucideIcons.share2,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  onPressed: () => _showExportSummaryDialog(ticket),
                ),
                const SizedBox(width: 2),
                IconButton(
                  icon: const Icon(
                    LucideIcons.download,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  onPressed: () => _showExportSummaryDialog(ticket),
                ),
              ],
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
        const SizedBox(height: 12),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children:
                [
                  'All',
                  'Food',
                  'Transport',
                  'Stay',
                  'Shopping',
                  'Office',
                  'Misc',
                ].map((cat) {
                  final isSelected = _selectedCategoryFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedCategoryFilter = cat),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0E4D34)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0E4D34)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
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
                Text(
                  'No expenses matched your filter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: expenses.map((exp) {
              final amt = (exp['amount'] as num).toDouble();
              final amtFormatted = _formatAmount(amt);
              final isExpanded = _expandedExpenseIds.contains(exp['id']);
              final shares = Map<String, dynamic>.from(
                exp['shares'] as Map? ?? {},
              );
              final hasReceipt = exp['receipt'] != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Main Expense Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedExpenseIds.remove(exp['id']);
                                } else {
                                  _expandedExpenseIds.add(exp['id'] as String);
                                }
                              });
                            },
                            child: Icon(
                              isExpanded
                                  ? LucideIcons.chevronDown
                                  : LucideIcons.chevronRight,
                              size: 16,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.receipt,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        exp['splitMode'] as String? ??
                                            'Equal Split',
                                        style: const TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (hasReceipt) ...[
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () =>
                                            _showReceiptPreviewDialog(exp),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.paperclip,
                                                size: 10,
                                                color: Color(0xFF15803D),
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                'Receipt',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF15803D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Paid by ${exp['paidBy']} • ${exp['date']} • ${exp['category'] ?? 'Misc'}',
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
                            icon: const Icon(
                              LucideIcons.pencil,
                              size: 15,
                              color: Color(0xFF94A3B8),
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () =>
                                _showRecordExpenseDialog(ticket, exp),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(
                              LucideIcons.x,
                              size: 15,
                              color: Color(0xFF94A3B8),
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () =>
                                _deleteExpense(ticket, exp['id'] as String),
                          ),
                        ],
                      ),
                    ),

                    // Expandable Shares Breakdown Drawer
                    if (isExpanded)
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                        color: const Color(0xFFF8FAFC),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 12),
                            const Text(
                              'PARTICIPANT SHARE ALLOCATIONS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: shares.entries.map((s) {
                                final isPayer = s.key == exp['paidBy'];
                                final shareVal = (s.value as num).toDouble();
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        s.key,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      if (isPayer) ...[
                                        const SizedBox(width: 4),
                                        const Text(
                                          '(Payer)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      Text(
                                        '₹${_formatAmount(shareVal)}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0E4D34),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RIGHT COLUMN: MEMBERS & BALANCES, SIMPLIFIED DEBTS, SETTLEMENTS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRightDetailColumn(
    BuildContext context,
    bool isMobile,
    Map<String, dynamic> ticket,
    Map<String, double> balances,
    List<Map<String, dynamic>> debts,
    List<Map<String, dynamic>> settlements,
    String totalSettledStr,
  ) {
    final participants = List<String>.from(
      ticket['participants'] as List? ?? [],
    );
    final memberStats = _calculateMemberStats(ticket);

    final members =
        (ticket['members'] != null && (ticket['members'] as List).isNotEmpty)
        ? List<Map<String, dynamic>>.from(ticket['members'] as List)
        : participants
              .map(
                (p) => {
                  'name': p,
                  'role': (p == 'Admin' || p == 'You')
                      ? 'Creator & Admin'
                      : 'View Only',
                  'isCreator': (p == 'Admin' || p == 'You'),
                  'isPending': !(p == 'Admin' || p == 'You'),
                },
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. MEMBERS & BALANCES CARD (Matches Image 3)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Text(
                    'Members & Balances (${members.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ticket['currency'] as String? ?? 'INR',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => _showInviteMemberDialog(ticket),
                    icon: const Icon(
                      LucideIcons.userPlus,
                      size: 12,
                      color: Color(0xFF059669),
                    ),
                    label: const Text(
                      'Invite',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF10B981)),
                      backgroundColor: const Color(0xFFECFDF5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(
                      () => _isMembersExpanded = !_isMembersExpanded,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        _isMembersExpanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),

              // Expandable Member Cards List
              if (_isMembersExpanded) ...[
                const SizedBox(height: 16),
                ...members.map((member) {
                  final name = member['name'] as String;
                  final isCreator =
                      member['isCreator'] == true ||
                      member['role'] == 'Creator & Admin';
                  final stats =
                      memberStats[name] ??
                      {'paid': 0.0, 'charged': 0.0, 'balance': 0.0};
                  final balance = stats['balance']!;
                  final charged = stats['charged']!;
                  final paid = stats['paid']!;
                  final isPending = member['isPending'] == true;

                  if (isCreator) {
                    // Solid White Card for Creator / Admin
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF065F46),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.crown,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Creator & Admin',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                balance.abs() <= 0.005
                                    ? 'Settled'
                                    : '${balance > 0 ? '+' : '-'}₹${_formatAmount(balance.abs())}',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: balance > 0.005
                                      ? const Color(0xFF059669)
                                      : (balance < -0.005
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Charged ₹${_formatAmount(charged)}, Paid ₹${_formatAmount(paid)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Dashed Amber Card for Invited Member
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Name, Role Dropdown, Make Admin, Pending Invite, Balance
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  // Role dropdown: 👁 View Only ▾
                                  PopupMenuButton<String>(
                                    tooltip: 'Change role',
                                    onSelected: (newRole) {
                                      setState(() {
                                        member['role'] = newRole;
                                        if (newRole == 'Admin') {
                                          member['isCreator'] = true;
                                        }
                                      });
                                      AppSnackbar.show(
                                        context,
                                        "$name role updated to $newRole",
                                        type: SnackType.success,
                                      );
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'View Only',
                                        child: Text('View Only'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'Edit Access',
                                        child: Text('Edit Access'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'Admin',
                                        child: Text('Admin'),
                                      ),
                                    ],
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            member['role'] == 'Edit Access'
                                                ? LucideIcons.pencil
                                                : (member['role'] == 'Admin'
                                                      ? LucideIcons.crown
                                                      : LucideIcons.eye),
                                            size: 11,
                                            color: const Color(0xFF92400E),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            member['role'] as String? ??
                                                'View Only',
                                            style: const TextStyle(
                                              color: Color(0xFF92400E),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            LucideIcons.chevronDown,
                                            size: 11,
                                            color: Color(0xFF92400E),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 👑 Make Admin button
                                  if (member['role'] != 'Admin')
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          member['role'] = 'Admin';
                                          member['isCreator'] = true;
                                        });
                                        AppSnackbar.show(
                                          context,
                                          "$name is now an Admin!",
                                          type: SnackType.success,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFCCFBF1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              LucideIcons.crown,
                                              size: 11,
                                              color: Color(0xFF0F766E),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Make Admin',
                                              style: TextStyle(
                                                color: Color(0xFF0F766E),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  // ⏱ Pending Invite badge
                                  if (isPending)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.clock,
                                            size: 11,
                                            color: Color(0xFFD97706),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Pending Invite',
                                            style: TextStyle(
                                              color: Color(0xFFD97706),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              balance.abs() <= 0.005
                                  ? 'Settled'
                                  : '${balance > 0 ? '+' : '-'}₹${_formatAmount(balance.abs())}',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: balance > 0.005
                                    ? const Color(0xFF059669)
                                    : (balance < -0.005
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Row 2: Action links if pending
                        if (isPending) ...[
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    member['isPending'] = false;
                                  });
                                  AppSnackbar.show(
                                    context,
                                    "Accepted invite on behalf of $name",
                                    type: SnackType.success,
                                  );
                                },
                                child: const Text(
                                  '✓ Accept on Behalf',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              InkWell(
                                onTap: () {
                                  AppSnackbar.show(
                                    context,
                                    "Invitation resent to $name",
                                    type: SnackType.info,
                                  );
                                },
                                child: const Text(
                                  'Resend Invite',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              InkWell(
                                onTap: () {
                                  if (paid > 0) {
                                    AppSnackbar.show(
                                      context,
                                      "Cannot remove $name because they have logged payments.",
                                      type: SnackType.warning,
                                    );
                                    return;
                                  }
                                  setState(() {
                                    (ticket['members'] as List).remove(member);
                                    (ticket['participants'] as List).remove(
                                      name,
                                    );
                                    // Rebalance equal split expenses
                                    final remaining = List<String>.from(
                                      ticket['participants'] as List,
                                    );
                                    if (remaining.isNotEmpty) {
                                      final exps =
                                          List<Map<String, dynamic>>.from(
                                            ticket['expenses'] as List? ?? [],
                                          );
                                      for (var exp in exps) {
                                        if (exp['splitMode'] == 'Equal Split') {
                                          final amt = (exp['amount'] as num)
                                              .toDouble();
                                          final eq = amt / remaining.length;
                                          final s = <String, double>{
                                            for (var r in remaining) r: eq,
                                          };
                                          exp['shares'] = s;
                                        }
                                      }
                                    }
                                  });
                                  AppSnackbar.show(
                                    context,
                                    "Removed $name and rebalanced past equal expenses.",
                                    type: SnackType.info,
                                  );
                                },
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],

                        // Row 3: Charged & Paid
                        Text(
                          'Charged ₹${_formatAmount(charged)}, Paid ₹${_formatAmount(paid)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
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
        const SizedBox(height: 18),

        // 2. SIMPLIFIED DEBTS CARD (Matches Image 3)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
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
              const Row(
                children: [
                  Icon(
                    LucideIcons.sparkles,
                    size: 14,
                    color: Color(0xFF38BDF8),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'SIMPLIFIED DEBTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Smart algorithm calculates the fewest transactions to settle all debts.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),

              if (debts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.checkCircle2,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'All balances are settled!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: debts.map((d) {
                    final debtor = (d['from'] ?? d['debtor']) as String;
                    final creditor = (d['to'] ?? d['creditor']) as String;
                    final amt = (d['amount'] as num).toDouble();
                    final amtFormatted = _formatAmount(amt);

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
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: debtor,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const TextSpan(text: ' owes '),
                                      TextSpan(
                                        text: creditor,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Send Payment Reminder',
                                icon: const Icon(
                                  LucideIcons.bell,
                                  size: 15,
                                  color: Color(0xFF38BDF8),
                                ),
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    _sendDebtReminder(debtor, creditor, amt),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                onPressed: () =>
                                    _showCustomPayDialog(ticket, d),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
                                  side: const BorderSide(
                                    color: Color(0xFF475569),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Custom Pay',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _settleDebt(ticket, debtor, creditor, amt),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Settle',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
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
        const SizedBox(height: 18),

        // 3. SETTLEMENTS SECTION (Matches Image 3 & 4)
        Row(
          children: [
            const Icon(LucideIcons.check, size: 15, color: Color(0xFF059669)),
            const SizedBox(width: 6),
            Text(
              'SETTLEMENTS (${settlements.length})',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF065F46),
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Settled: ₹$totalSettledStr',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (settlements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No recorded settlements yet.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ),
          )
        else
          Column(
            children: settlements.map((st) {
              final amt = (st['amount'] as num).toDouble();
              final amtFormatted = _formatAmount(amt);
              final debtor = st['debtor'] ?? st['from'] ?? 'Someone';
              final creditor = st['creditor'] ?? st['to'] ?? 'Someone';
              final title =
                  st['title'] as String? ?? 'payment : $debtor paid $creditor';
              final dateStr = st['date'] as String? ?? '2026-11-17';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.check,
                        size: 16,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📅 $dateStr',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '₹$amtFormatted',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          _deleteSettlement(ticket, st['id'] as String),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required IconData icon,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 110,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 13,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  const Icon(
                    LucideIcons.checkCircle2,
                    size: 14,
                    color: Color(0xFF2563EB),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isSelected
                      ? const Color(0xFF1E40AF)
                      : const Color(0xFF64748B),
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF0E4D34), width: 1.5),
      ),
    );
  }

  Widget _buildDialogInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
