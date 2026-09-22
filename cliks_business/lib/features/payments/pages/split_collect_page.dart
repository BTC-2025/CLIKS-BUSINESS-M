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
      'id': 'ticket_1',
      'title': 'kjnkjn',
      'currency': 'INR (₹)',
      'description': 'kjnkj',
      'budget': 10000.0,
      'participants': ['You', 'knknkn', 'kjnjhbnjhb', 'kjnjnkjn'],
      'expenses': <Map<String, dynamic>>[
        {
          'id': 'exp_1',
          'description': 'food',
          'amount': 5000.0,
          'paidBy': 'You',
          'date': '2026-08-07',
          'splitMode': 'Custom Split',
          'shares': <String, double>{
            'You': 2000.0,
            'knknkn': 500.0,
            'kjnjhbnjhb': 2000.0,
            'kjnjnkjn': 500.0,
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

  void _showEditBudgetDialog(Map<String, dynamic> ticket) {
    final budgetVal = (ticket['budget'] != null && (ticket['budget'] as num) > 0)
        ? (ticket['budget'] as num).toInt().toString()
        : '';
    final controller = TextEditingController(text: budgetVal);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.wallet, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Set Trip Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set a target spending limit for this trip to track group outlay progress.',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
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
                labelText: 'Trip Budget Amount (₹)',
                hintText: 'e.g. 10000',
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
              final newBudget = double.tryParse(controller.text.trim()) ?? 0.0;
              if (newBudget > kMaxAllowedAmount) {
                AppSnackbar.show(
                  context,
                  'Trip budget cannot exceed $kMaxAllowedAmountText',
                  type: SnackType.warning,
                );
                return;
              }
              setState(() {
                ticket['budget'] = newBudget;
              });
              Navigator.pop(ctx);
              AppSnackbar.show(
                context,
                newBudget > 0
                    ? "Trip budget set to ₹${newBudget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}!"
                    : "Trip budget cleared.",
                type: SnackType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Budget', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
        "Ticket '${ticket['title']}' removed.",
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

  void _settleDebt(Map<String, dynamic> ticket, String debtor, String creditor, double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Settle Debt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Mark ₹${amount.toStringAsFixed(0)} settlement from $debtor to $creditor as completed?',
          style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                (ticket['settlements'] as List<Map<String, dynamic>>).add({
                  'debtor': debtor,
                  'creditor': creditor,
                  'amount': amount,
                  'date': DateTime.now().toString().split(' ')[0],
                });
              });
              AppSnackbar.show(
                context,
                "Debt of ₹${amount.toStringAsFixed(0)} between $debtor and $creditor settled!",
                type: SnackType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
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
      final shares = Map<String, double>.from(exp['shares'] as Map);

      if (balances.containsKey(paidBy)) {
        balances[paidBy] = balances[paidBy]! + amount;
      }

      shares.forEach((person, shareVal) {
        if (balances.containsKey(person)) {
          balances[person] = balances[person]! - shareVal;
        }
      });
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
    final debtorKeys = debtors.keys.toList();
    final creditorKeys = creditors.keys.toList();

    int dIdx = 0;
    int cIdx = 0;

    while (dIdx < debtorKeys.length && cIdx < creditorKeys.length) {
      final dName = debtorKeys[dIdx];
      final cName = creditorKeys[cIdx];

      final dAmt = debtors[dName]!;
      final cAmt = creditors[cName]!;

      final transfer = dAmt < cAmt ? dAmt : cAmt;

      debts.add({
        'from': dName,
        'to': cName,
        'amount': transfer,
      });

      debtors[dName] = dAmt - transfer;
      creditors[cName] = cAmt - transfer;

      if (debtors[dName]! < 0.01) dIdx++;
      if (creditors[cName]! < 0.01) cIdx++;
    }

    return debts;
  }

  void _showRecordExpenseSheet(Map<String, dynamic> ticket, [Map<String, dynamic>? existingExpense]) {
    final participants = List<String>.from(ticket['participants'] as List);

    final descController = TextEditingController(text: existingExpense != null ? existingExpense['description'] : '');
    final amountController = TextEditingController(text: existingExpense != null ? (existingExpense['amount'] as num).toStringAsFixed(0) : '');
    final dateController = TextEditingController(text: existingExpense != null ? existingExpense['date'] : '07 - 08 - 2026');
    String paidBy = existingExpense != null ? existingExpense['paidBy'] : (participants.contains('You') ? 'You' : participants.first);
    bool isCustomSplit = existingExpense != null ? existingExpense['splitMode'] == 'Custom Split' : false;

    final customShareControllers = <String, TextEditingController>{};
    for (var p in participants) {
      double initialShare = 0.0;
      if (existingExpense != null && existingExpense['shares'] != null) {
        initialShare = (existingExpense['shares'][p] as num?)?.toDouble() ?? 0.0;
      }
      customShareControllers[p] = TextEditingController(text: initialShare > 0 ? initialShare.toStringAsFixed(0) : '0');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final totalAmount = double.tryParse(amountController.text.trim()) ?? 0.0;

          // Compute equal shares if in Split Equally mode
          final equalShare = participants.isNotEmpty ? (totalAmount / participants.length) : 0.0;

          // Compute sum of custom shares
          double sumCustomShares = 0.0;
          for (var p in participants) {
            sumCustomShares += double.tryParse(customShareControllers[p]!.text.trim()) ?? 0.0;
          }

          final diff = totalAmount - sumCustomShares;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 12,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle Bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existingExpense != null ? 'Edit Expense' : 'Record Expense',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18, color: Colors.black54),
                        onPressed: () => Navigator.pop(ctx),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel('EXPENSE DESCRIPTION'),
                                    TextFormField(
                                      controller: descController,
                                      decoration: _inputDecoration('e.g. food, cab, groceries'),
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
                                    _buildInputLabel('AMOUNT (₹)'),
                                    TextFormField(
                                      controller: amountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                                        LengthLimitingTextInputFormatter(15),
                                      ],
                                      onChanged: (_) => setModalState(() {}),
                                      decoration: _inputDecoration('5000'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel('WHO PAID?'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE5EAF4)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: paidBy,
                                          isExpanded: true,
                                          items: participants.map((p) {
                                            return DropdownMenuItem(
                                              value: p,
                                              child: Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel('DATE'),
                                    TextFormField(
                                      controller: dateController,
                                      decoration: _inputDecoration('07 - 08 - 2026').copyWith(
                                        suffixIcon: const Icon(LucideIcons.calendar, size: 16, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('EXPENSE ATTACHMENT'),
                          InkWell(
                            onTap: () {
                              AppSnackbar.show(context, "Attachment picker simulated.", type: SnackType.info);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.upload, size: 16, color: AppColors.primaryGreen),
                                  SizedBox(width: 8),
                                  Text(
                                    'Click to upload invoice / receipt copy',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkText),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildInputLabel('SPLITTING PROTOCOL'),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setModalState(() => isCustomSplit = false),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: !isCustomSplit ? const Color(0xFFF0FDF4) : Colors.white,
                                    side: BorderSide(color: !isCustomSplit ? AppColors.primaryGreen : const Color(0xFFE2E8F0)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    'Split Equally',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: !isCustomSplit ? AppColors.primaryGreen : AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setModalState(() => isCustomSplit = true),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isCustomSplit ? const Color(0xFFF0FDF4) : Colors.white,
                                    side: BorderSide(color: isCustomSplit ? AppColors.primaryGreen : const Color(0xFFE2E8F0)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    'Customize Shares',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isCustomSplit ? AppColors.primaryGreen : AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Shares Allocations Container
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SHARES ALLOCATIONS',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 12),
                                ...participants.map((p) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            p,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText),
                                          ),
                                        ),
                                        const Text('₹ ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                                        SizedBox(
                                          width: 100,
                                          height: 38,
                                          child: isCustomSplit
                                              ? TextFormField(
                                                  controller: customShareControllers[p],
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                  inputFormatters: [
                                                    const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                                                    LengthLimitingTextInputFormatter(15),
                                                  ],
                                                  onChanged: (_) => setModalState(() {}),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                  decoration: InputDecoration(
                                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                                  ),
                                                  child: Text(
                                                    equalShare.toStringAsFixed(0),
                                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                if (isCustomSplit) ...[
                                  const SizedBox(height: 8),
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
                                              ? '✓ Allocated: ₹${sumCustomShares.toStringAsFixed(2)} (100% matched)'
                                              : '⚠️ Allocated: ₹${sumCustomShares.toStringAsFixed(2)} (Remaining: ₹${diff.toStringAsFixed(2)})',
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

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
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
                                    if (shareVal > kMaxAllowedAmount) {
                                      AppSnackbar.show(context, "Share for $p cannot exceed $kMaxAllowedAmountText", type: SnackType.error);
                                      return;
                                    }
                                    finalShares[p] = shareVal;
                                  }
                                } else {
                                  for (var p in participants) {
                                    finalShares[p] = equalShare;
                                  }
                                }

                                final newExp = {
                                  'id': existingExpense != null ? existingExpense['id'] : DateTime.now().millisecondsSinceEpoch.toString(),
                                  'description': descController.text.trim(),
                                  'amount': totalAmount,
                                  'paidBy': paidBy,
                                  'date': dateController.text.trim(),
                                  'splitMode': isCustomSplit ? 'Custom Split' : 'Equal Split',
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
                                backgroundColor: const Color(0xFF084421),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                existingExpense != null ? 'Update Expense' : 'Log Expense',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: isMobile && _selectedTicket == null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.extended(
                onPressed: _createNewTicket,
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('New Split Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(paddingVal, 16, paddingVal, isMobile ? 100 : 32),
        child: _selectedTicket != null
            ? _buildTicketDetailView(context, isMobile, _selectedTicket!)
            : _buildTicketsListView(context, isMobile),
      ),
    );
  }

  // TICKET DETAIL VIEW (Matches Screenshot 3)
  Widget _buildTicketDetailView(BuildContext context, bool isMobile, Map<String, dynamic> ticket) {
    final expenses = List<Map<String, dynamic>>.from(ticket['expenses'] as List);
    final filteredExpenses = expenses.where((e) {
      final desc = (e['description'] as String).toLowerCase();
      final paid = (e['paidBy'] as String).toLowerCase();
      return desc.contains(_searchQuery.toLowerCase()) || paid.contains(_searchQuery.toLowerCase());
    }).toList();

    double totalOutlay = 0.0;
    for (var e in expenses) {
      totalOutlay += (e['amount'] as num).toDouble();
    }

    final balances = _calculateBalances(ticket);
    final debts = _calculateSimplifiedDebts(balances);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Link Row & Add Expense Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => setState(() => _selectedTicketId = null),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.primaryGreen),
                    SizedBox(width: 4),
                    Text(
                      'Back to all tickets',
                      style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showRecordExpenseSheet(ticket),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ticket Outlay Card Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${ticket['currency']} GROUP',
                                style: const TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showEditBudgetDialog(ticket),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.pencil, size: 10, color: AppColors.secondaryText),
                                    const SizedBox(width: 4),
                                    Text(
                                      (ticket['budget'] != null && (ticket['budget'] as num) > 0)
                                          ? 'Budget: ₹${(ticket['budget'] as num).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                                          : '+ Set Budget',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkText),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket['title'] as String,
                          style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket['description'] as String,
                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TOTAL GROUP OUTLAY',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹${totalOutlay.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: TextStyle(fontSize: isMobile ? 20 : 26, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Trip Budget Progress & Alert Bar
              if (ticket['budget'] != null && (ticket['budget'] as num) > 0) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final double budget = (ticket['budget'] as num).toDouble();
                    final double progress = (totalOutlay / budget).clamp(0.0, 1.0);
                    final bool isExceeded = totalOutlay > budget;
                    final double remaining = (budget - totalOutlay);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isExceeded ? LucideIcons.alertTriangle : LucideIcons.checkCircle2,
                                  size: 14,
                                  color: isExceeded ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isExceeded
                                      ? '⚠️ Budget Exceeded by ₹${(totalOutlay - budget).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
                                      : '✓ Within Budget (₹${remaining.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} remaining)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isExceeded ? const Color(0xFFEF4444) : const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${(progress * 100).toInt()}% Used',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isExceeded ? const Color(0xFFEF4444) : AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isExceeded ? const Color(0xFFEF4444) : AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Main Content Row (Left: Logged Expenses, Right: Individual Balances & Simplified Debts)
        isMobile
            ? Column(
                children: [
                  _buildLoggedExpensesColumn(context, ticket, filteredExpenses),
                  const SizedBox(height: 24),
                  _buildBalancesAndDebtsColumn(context, ticket, balances, debts),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _buildLoggedExpensesColumn(context, ticket, filteredExpenses)),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: _buildBalancesAndDebtsColumn(context, ticket, balances, debts)),
                ],
              ),
      ],
    );
  }

  Widget _buildLoggedExpensesColumn(BuildContext context, Map<String, dynamic> ticket, List<Map<String, dynamic>> expenses) {
    final isMobile = MediaQuery.of(context).size.width < 950;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LOGGED EXPENSES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText, letterSpacing: 0.5),
              ),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(LucideIcons.share2, size: 16, color: Colors.black54),
                    onPressed: () => AppSnackbar.show(context, "Exporting expense breakdown...", type: SnackType.info),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(LucideIcons.download, size: 16, color: Colors.black54),
                    onPressed: () => AppSnackbar.show(context, "Downloading PDF report...", type: SnackType.info),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.search, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search logged expenses...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LOGGED EXPENSES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText, letterSpacing: 0.5),
              ),
              Row(
                children: [
                  Container(
                    width: 140,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.search, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: const InputDecoration(
                              hintText: 'Search...',
                              hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.share2, size: 16, color: Colors.black54),
                    onPressed: () => AppSnackbar.show(context, "Exporting expense breakdown...", type: SnackType.info),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.download, size: 16, color: Colors.black54),
                    onPressed: () => AppSnackbar.show(context, "Downloading PDF report...", type: SnackType.info),
                  ),
                ],
              ),
            ],
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
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(LucideIcons.receipt, size: 36, color: Colors.grey),
                SizedBox(height: 12),
                Text('No logged expenses yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.secondaryText)),
                SizedBox(height: 4),
                Text('Click + Add Expense to split a bill.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        else
          Column(
            children: expenses.map((exp) {
              final amtFormatted = (exp['amount'] as num).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.receipt, size: 18, color: AppColors.darkText),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp['description'] as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paid by ${exp['paidBy']} • ${exp['date']}',
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹$amtFormatted',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (exp['splitMode'] as String).toUpperCase(),
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(LucideIcons.pencil, size: 14, color: Colors.grey),
                      onPressed: () => _showRecordExpenseSheet(ticket, exp),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: const Icon(LucideIcons.x, size: 14, color: Colors.redAccent),
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

  Widget _buildBalancesAndDebtsColumn(BuildContext context, Map<String, dynamic> ticket, Map<String, double> balances, List<Map<String, dynamic>> debts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // INDIVIDUAL BALANCES CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INDIVIDUAL BALANCES',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 0.5),
              ),
              const SizedBox(height: 16),
              ...balances.entries.map((entry) {
                final isPositive = entry.value >= 0;
                final valFormatted = entry.value.abs().toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText),
                      ),
                      Text(
                        '${isPositive ? '+' : '-'}₹$valFormatted.00',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // SIMPLIFIED DEBTS CARD (Dark Navy Theme matching Screenshot 3)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0A192F), // Dark navy blue background
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SIMPLIFIED DEBTS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5),
              ),
              const SizedBox(height: 16),

              if (debts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'All balances are settled!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
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
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
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
                                      TextSpan(text: debtor, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: ' owes '),
                                      TextSpan(text: creditor, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹$amtFormatted',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _settleDebt(ticket, debtor, creditor, amt),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Settle Debt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
    );
  }

  // TICKETS LIST VIEW (Main Page)
  Widget _buildTicketsListView(BuildContext context, bool isMobile) {
    final filteredTickets = _tickets.where((t) {
      final title = (t['title'] as String).toLowerCase();
      final desc = (t['description'] as String).toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) || desc.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroSummary(context, isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
        const SizedBox(height: 24),
        _buildSearchBar(isMobile),
        const SizedBox(height: 24),

        if (filteredTickets.isEmpty)
          _buildEmptyStateCard(context, isMobile)
        else
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: filteredTickets.map((t) => _buildTicketCard(context, isMobile, t)).toList(),
          ),
      ],
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    int totalTickets = _tickets.length;
    double myShareTotal = 0.0;
    double toCollectTotal = 0.0;
    double totalSettled = 0.0;

    for (var t in _tickets) {
      final balances = _calculateBalances(t);
      if (balances.containsKey('You')) {
        final val = balances['You']!;
        if (val > 0) toCollectTotal += val;
        if (val < 0) myShareTotal += val.abs();
      }

      final stList = List<Map<String, dynamic>>.from(t['settlements'] as List);
      for (var st in stList) {
        totalSettled += (st['amount'] as num).toDouble();
      }
    }

    final newTicketBtn = ElevatedButton.icon(
      onPressed: _createNewTicket,
      icon: const Icon(LucideIcons.plus, size: 14),
      label: const Text('New Split Ticket', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.stylishDarkGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SPLITS',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalTickets',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 34,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) newTicketBtn,
            ],
          ),
          const SizedBox(height: 16),
          // 3 Stat Chips in a row
          Row(
            children: [
              _buildHeroChip('To Collect', '₹ ${toCollectTotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('My Share', '₹ ${myShareTotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Settled', '₹ ${totalSettled.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, String value, bool isMobile) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 280,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.search, color: AppColors.secondaryText, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search split tickets...',
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, bool isMobile, Map<String, dynamic> ticket) {
    final participants = List<String>.from(ticket['participants'] as List);
    final expenses = List<Map<String, dynamic>>.from(ticket['expenses'] as List);

    double totalOutlay = 0.0;
    for (var e in expenses) {
      totalOutlay += (e['amount'] as num).toDouble();
    }
    final totalOutlayStr = totalOutlay.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return Container(
      width: isMobile ? double.infinity : 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ticket['currency']}',
                      style: const TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (ticket['budget'] != null && (ticket['budget'] as num) > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        'Budget: ₹${(ticket['budget'] as num).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(color: Color(0xFF2563EB), fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.grey),
                onPressed: () => _deleteTicket(ticket['id'] as String),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            ticket['title'] as String,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 4),
          Text(
            ticket['description'] as String,
            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.users, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 6),
                  Text(
                    '${participants.length} Participants',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'OUTLAY',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                  ),
                  Text(
                    '₹$totalOutlayStr',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _selectedTicketId = ticket['id'] as String),
              icon: const Icon(LucideIcons.arrowRight, size: 16),
              label: const Text('View Ticket & Balances', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.hoverBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.users, color: AppColors.secondaryText, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Active Split Tickets',
            style: TextStyle(color: AppColors.darkText, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: const Text(
              'Create a new split ticket to begin tracking collaborative expenses with your co-workers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
