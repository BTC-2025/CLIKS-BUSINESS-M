import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widgets/setup_target_wallet_dialog.dart';
import '../../../widgets/app_ui_kit.dart';

class SegregationPage extends StatefulWidget {
  const SegregationPage({super.key});

  @override
  State<SegregationPage> createState() => _SegregationPageState();
}

class _SegregationPageState extends State<SegregationPage> {
  String _selectedFilter = 'all'; // 'all', 'growing', 'met', 'claimed'

  final List<Map<String, dynamic>> _wallets = [
    {
      'id': '1',
      'title': 'pen',
      'status': 'TARGET MET',
      'statusColor': const Color(0xFFE11D48),
      'saved': 50000.0,
      'target': 50000.0,
      'notes': 'Dedicated supplies & stationery reserve',
      'isClaimed': false,
    },
    {
      'id': '2',
      'title': 'future stock',
      'status': 'FULLY CLAIMED',
      'statusColor': const Color(0xFF3B82F6),
      'saved': 50000.0,
      'target': 50000.0,
      'notes': 'Reserve pool to procure upcoming seasonal inventory',
      'isClaimed': true,
    },
    {
      'id': '3',
      'title': 'Office Upgrade',
      'status': 'IN PROGRESS',
      'statusColor': const Color(0xFF059669),
      'saved': 32000.0,
      'target': 100000.0,
      'notes': 'Ergonomic workstations and office improvement reserve',
      'isClaimed': false,
    },
  ];

  /// Indian currency format helper (e.g. 451000 -> 4,51,000)
  String _formatCurrency(double val) {
    if (val == 0) return '0';
    final isNegative = val < 0;
    final clampedVal =
        val.abs() > 999999999999.99 ? 999999999999.99 : val.abs();
    final absVal = clampedVal.round();
    final s = absVal.toString();
    if (s.length <= 3) {
      return isNegative ? '-$s' : s;
    }
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    final result = '$formattedRest,$last3';
    return isNegative ? '-$result' : result;
  }

  void _addNewWallet(Map<String, dynamic> wallet) {
    setState(() {
      _wallets.add(wallet);
    });
    AppSnackbar.show(
      context,
      "New purpose wallet '${wallet['title']}' created successfully!",
      type: SnackType.success,
    );
  }

  void _showConfirmClaimSheet(int index) {
    final wallet = _wallets[index];
    final title = wallet['title'] as String;
    final savedFormatted = _formatCurrency(wallet['saved'] as double);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 24),

            // Warning Icon Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFEE2E8), width: 2),
              ),
              child: const Icon(LucideIcons.trophy, color: Color(0xFFE11D48), size: 28),
            ),
            const SizedBox(height: 16),

            const Text(
              'Claim & Extract Goal',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),

            Text(
              'Extract ₹$savedFormatted accumulated for "$title" and release it into active business reserves?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 26),

            // Buttons (Cancel & Confirm)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        wallet['isClaimed'] = true;
                        wallet['status'] = 'FULLY CLAIMED';
                        wallet['statusColor'] = const Color(0xFF3B82F6);
                      });
                      Navigator.pop(ctx);
                      AppSnackbar.show(
                        context,
                        "Successfully extracted ₹$savedFormatted for \"$title\" into reserves!",
                        type: SnackType.success,
                      );
                    },
                    icon: const Icon(LucideIcons.checkCircle2, size: 16),
                    label: const Text(
                      'Confirm Release',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5B2E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openAddCashDialog(int index) {
    final wallet = _wallets[index];
    final isClaimed = wallet['isClaimed'] == true;
    final currentSaved = wallet['saved'] as double;
    final target = wallet['target'] as double;
    final remaining = (target - currentSaved).clamp(0.0, double.infinity);

    // Strict guard: Completed or Claimed goals cannot receive any more cash!
    if (isClaimed) {
      AppSnackbar.show(
        context,
        "This goal has already been fully claimed and extracted to reserves.",
        type: SnackType.info,
      );
      return;
    }

    if (remaining <= 0) {
      AppSnackbar.show(
        context,
        "Target ceiling reached! This goal is completed. Please claim it.",
        type: SnackType.warning,
      );
      return;
    }

    // Starts completely empty - user can enter directly or tap quick fill!
    final controller = TextEditingController();

    final quickChips = [
      {'label': '+₹1,000', 'val': 1000.0},
      {'label': '+₹5,000', 'val': 5000.0},
      {'label': '+₹10,000', 'val': 10000.0},
      {'label': '+₹25,000', 'val': 25000.0},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final entered = double.tryParse(controller.text.trim()) ?? 0.0;
          final projectedTotal = currentSaved + entered;
          final isOverCap = entered > remaining;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 22,
              right: 22,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.plusCircle, color: Color(0xFF059669), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Cash to ${wallet['title']}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Saved: ₹${_formatCurrency(currentSaved)} of ₹${_formatCurrency(target)}  •  Remaining: ₹${_formatCurrency(remaining)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Amount Field with ₹ INR Badge
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOverCap ? const Color(0xFFE11D48) : const Color(0xFFCBD5E1),
                      width: isOverCap ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '₹ INR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F5B2E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                            LengthLimitingTextInputFormatter(15),
                          ],
                          onChanged: (_) => setSheetState(() {}),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Max deposit ₹${_formatCurrency(remaining)}',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Addition Chips (Including "Fill Remaining")
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    // Highlighted Fill Remaining chip
                    InkWell(
                      onTap: () {
                        setSheetState(() {
                          controller.text = remaining.toInt().toString();
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.target, size: 12, color: Color(0xFFE11D48)),
                            const SizedBox(width: 5),
                            Text(
                              'Fill Remaining (₹${_formatCurrency(remaining)})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...quickChips.where((chip) => (chip['val'] as double) <= remaining).map((chip) {
                      return InkWell(
                        onTap: () {
                          setSheetState(() {
                            final currentVal = double.tryParse(controller.text.trim()) ?? 0.0;
                            final newVal = (currentVal + (chip['val'] as double)).clamp(0.0, remaining);
                            controller.text = newVal.toInt().toString();
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            chip['label'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                if (isOverCap) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertTriangle, size: 14, color: Color(0xFFE11D48)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Exceeds goal ceiling! You only need ₹${_formatCurrency(remaining)} to complete this goal.',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE11D48)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (entered > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Projected Balance After Deposit:',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Text(
                          '₹${_formatCurrency(projectedTotal)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: projectedTotal >= target ? const Color(0xFF059669) : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: isOverCap
                            ? null
                            : () {
                                final added = double.tryParse(controller.text.trim()) ?? 0;
                                if (added <= 0) {
                                  AppSnackbar.show(
                                    ctx,
                                    'Please enter a valid amount greater than ₹0',
                                    type: SnackType.warning,
                                  );
                                  return;
                                }
                                if (added > remaining) {
                                  AppSnackbar.show(
                                    ctx,
                                    'Cannot exceed target ceiling! Only ₹${_formatCurrency(remaining)} is needed to complete this goal.',
                                    type: SnackType.warning,
                                  );
                                  return;
                                }
                                if (added > kMaxAllowedAmount) {
                                  AppSnackbar.show(
                                    ctx,
                                    'Deposit amount cannot exceed $kMaxAllowedAmountText',
                                    type: SnackType.warning,
                                  );
                                  return;
                                }
                                setState(() {
                                  final newSaved = (wallet['saved'] as double) + added;
                                  final targetVal = wallet['target'] as double;
                                  wallet['saved'] = newSaved.clamp(0.0, targetVal);
                                  if (wallet['saved'] >= targetVal && wallet['isClaimed'] != true) {
                                    wallet['status'] = 'TARGET MET';
                                    wallet['statusColor'] = const Color(0xFFE11D48);
                                  }
                                });
                                Navigator.pop(ctx);
                                if (wallet['saved'] >= wallet['target']) {
                                  AppSnackbar.show(
                                    context,
                                    "Goal Achieved! '${wallet['title']}' has reached 100% target and is ready to claim!",
                                    type: SnackType.success,
                                  );
                                } else {
                                  AppSnackbar.show(
                                    context,
                                    "Deposited ₹${_formatCurrency(added)} into '${wallet['title']}'. ₹${_formatCurrency((wallet['target'] as double) - (wallet['saved'] as double))} remaining.",
                                    type: SnackType.success,
                                  );
                                }
                              },
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('Deposit Cash', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5B2E),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openEditWalletDialog(int index) {
    final wallet = _wallets[index];
    final titleController = TextEditingController(text: wallet['title'] as String);
    final targetController = TextEditingController(text: (wallet['target'] as double).toInt().toString());
    final notesController = TextEditingController(text: wallet['notes'] as String);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Purpose Wallet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              const Text('PURPOSE / CONTAINER NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              const Text('TARGET CAP AMOUNT (INR)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                  LengthLimitingTextInputFormatter(15),
                ],
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              const Text('DESCRIPTIVE NOTES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final newTitle = titleController.text.trim();
                    final newTarget = double.tryParse(targetController.text.trim()) ?? (wallet['target'] as double);
                    final newNotes = notesController.text.trim();

                    if (newTitle.isEmpty) {
                      AppSnackbar.show(
                        context,
                        'Please enter a purpose / container name',
                        type: SnackType.warning,
                      );
                      return;
                    }
                    if (newTarget <= 0) {
                      AppSnackbar.show(
                        context,
                        'Please enter a target amount greater than ₹0',
                        type: SnackType.warning,
                      );
                      return;
                    }
                    if (newTarget > kMaxAllowedAmount) {
                      AppSnackbar.show(
                        context,
                        'Target cap cannot exceed $kMaxAllowedAmountText',
                        type: SnackType.warning,
                      );
                      return;
                    }

                    if (newTarget < (wallet['saved'] as double)) {
                      AppSnackbar.show(
                        context,
                        'Target ceiling cannot be less than already saved amount (₹${_formatCurrency(wallet['saved'] as double)})',
                        type: SnackType.warning,
                      );
                      return;
                    }

                    setState(() {
                      wallet['title'] = newTitle;
                      wallet['target'] = newTarget;
                      wallet['notes'] = newNotes;
                      final saved = wallet['saved'] as double;
                      if (saved >= newTarget && wallet['isClaimed'] != true) {
                        wallet['status'] = 'TARGET MET';
                        wallet['statusColor'] = const Color(0xFFE11D48);
                      } else if (saved < newTarget) {
                        wallet['status'] = 'IN PROGRESS';
                        wallet['statusColor'] = const Color(0xFF059669);
                        wallet['isClaimed'] = false;
                      }
                    });
                    AppSnackbar.show(
                      context,
                      "Purpose wallet '$newTitle' updated successfully!",
                      type: SnackType.success,
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5B2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteWallet(int index) {
    final title = _wallets[index]['title'] as String;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Purpose Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '$title'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _wallets.removeAt(index);
              });
              Navigator.pop(ctx);
              AppSnackbar.show(
                context,
                "Purpose wallet '$title' deleted.",
                type: SnackType.info,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SetupTargetWalletDialog(onWalletCreated: _addNewWallet),
                  );
                },
                backgroundColor: const Color(0xFF0F5B2E),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Setup Purpose Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(paddingVal, isMobile ? 12 : 20, paddingVal, isMobile ? 80 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Summary (Gradient Stats & Actions)
            _buildHeroSummary(context, isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
            const SizedBox(height: 20),

            // Quick Filter Tabs Bar
            _buildFilterBar(isMobile),
            const SizedBox(height: 18),

            // Purpose Wallets List or Empty State
            if (_filteredWallets.isEmpty)
              _buildEmptyStateCard(context, isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms)
            else
              _buildWalletCardsSection(isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms),

            const SizedBox(height: 28),

            // Financial Goals Section
            _buildFinancialGoalsCard(isMobile).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredWallets {
    switch (_selectedFilter) {
      case 'growing':
        return _wallets.where((w) => (w['saved'] as double) < (w['target'] as double) && w['isClaimed'] != true).toList();
      case 'met':
        return _wallets.where((w) => (w['saved'] as double) >= (w['target'] as double) && w['isClaimed'] != true).toList();
      case 'claimed':
        return _wallets.where((w) => w['isClaimed'] == true).toList();
      default:
        return _wallets;
    }
  }

  Widget _buildFilterBar(bool isMobile) {
    final growingCount = _wallets.where((w) => (w['saved'] as double) < (w['target'] as double) && w['isClaimed'] != true).length;
    final metCount = _wallets.where((w) => (w['saved'] as double) >= (w['target'] as double) && w['isClaimed'] != true).length;
    final claimedCount = _wallets.where((w) => w['isClaimed'] == true).length;

    final filters = [
      {'id': 'all', 'label': 'All Containers', 'count': _wallets.length},
      {'id': 'growing', 'label': 'In Progress', 'count': growingCount},
      {'id': 'met', 'label': 'Target Met', 'count': metCount},
      {'id': 'claimed', 'label': 'Claimed', 'count': claimedCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = f['id'] as String;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F5B2E) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0F5B2E) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F5B2E).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      f['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${f['count']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    final double totalSaved = _wallets.fold(0.0, (sum, item) => sum + (item['saved'] as double));
    final double totalTarget = _wallets.fold(0.0, (sum, item) => sum + (item['target'] as double));
    final int accomplishment = totalTarget > 0 ? ((totalSaved / totalTarget).clamp(0.0, 1.0) * 100).toInt() : 0;
    final int targetMetCount = _wallets.where((w) => (w['saved'] as double) >= (w['target'] as double) && w['isClaimed'] != true).length;

    final setupWalletBtn = ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => SetupTargetWalletDialog(onWalletCreated: _addNewWallet),
        );
      },
      icon: const Icon(LucideIcons.plus, size: 14),
      label: const Text(
        'Setup Purpose Wallet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F5B2E),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06381B), Color(0xFF0D542B), Color(0xFF14753D)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06381B).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag badge + Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.shieldCheck, color: Color(0xFFA7F3D0), size: 13),
                    SizedBox(width: 6),
                    Text(
                      'PURPOSE-DRIVEN ISOLATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA7F3D0),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) setupWalletBtn,
            ],
          ),
          const SizedBox(height: 16),

          // Total Isolated Funds Figure
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹ ${_formatCurrency(totalSaved)}',
                style: TextStyle(
                  fontSize: isMobile ? 30 : 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'INR',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Stat Chips in a responsive row
          Row(
            children: [
              _buildHeroChip(
                icon: LucideIcons.target,
                label: 'Goal Target',
                value: '₹ ${_formatCurrency(totalTarget)}',
                isMobile: isMobile,
              ),
              const SizedBox(width: 8),
              _buildHeroChip(
                icon: LucideIcons.trendingUp,
                label: 'Accomplishment',
                value: '$accomplishment%',
                isMobile: isMobile,
              ),
              const SizedBox(width: 8),
              _buildHeroChip(
                icon: LucideIcons.walletCards,
                label: 'Active Containers',
                value: '${_wallets.length}',
                isMobile: isMobile,
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                _buildHeroChip(
                  icon: LucideIcons.trophy,
                  label: 'Ready to Claim',
                  value: '$targetMetCount Goals',
                  isMobile: isMobile,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isMobile,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: isMobile ? 11 : 13, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 9 : 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 17,
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

  Widget _buildWalletCardsSection(bool isMobile) {
    final displayedWallets = _filteredWallets;

    final cardWidgets = displayedWallets.map((w) {
      final originalIndex = _wallets.indexOf(w);
      final isClaimed = w['isClaimed'] == true;
      final saved = w['saved'] as double;
      final target = w['target'] as double;
      final isTargetMet = saved >= target;

      final String statusText;
      final Color statusColor;
      final Color statusBgColor;
      final IconData statusIcon;

      if (isClaimed) {
        statusText = 'FULLY CLAIMED';
        statusColor = const Color(0xFF2563EB);
        statusBgColor = const Color(0xFFEFF6FF);
        statusIcon = LucideIcons.checkCheck;
      } else if (isTargetMet) {
        statusText = 'TARGET MET';
        statusColor = const Color(0xFFE11D48);
        statusBgColor = const Color(0xFFFFF1F2);
        statusIcon = LucideIcons.trophy;
      } else {
        statusText = 'IN PROGRESS';
        statusColor = const Color(0xFF059669);
        statusBgColor = const Color(0xFFECFDF5);
        statusIcon = LucideIcons.sprout;
      }

      final percent = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
      final percentDisplay = (percent * 100).toInt();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Accent Bar
            Container(
              height: 3.5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row: Avatar, Title, Status & Actions
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, size: 18, color: Color(0xFF64748B)),
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'add') {
                      _openAddCashDialog(originalIndex);
                    } else if (value == 'claim') {
                      _showConfirmClaimSheet(originalIndex);
                    } else if (value == 'edit') {
                      _openEditWalletDialog(originalIndex);
                    } else if (value == 'delete') {
                      _deleteWallet(originalIndex);
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (!isTargetMet && !isClaimed)
                      const PopupMenuItem<String>(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(LucideIcons.plusCircle, size: 16, color: Color(0xFF059669)),
                            SizedBox(width: 12),
                            Text('Deposit Cash', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    if (isTargetMet && !isClaimed)
                      const PopupMenuItem<String>(
                        value: 'claim',
                        child: Row(
                          children: [
                            Icon(LucideIcons.trophy, size: 16, color: Color(0xFFE11D48)),
                            SizedBox(width: 12),
                            Text('Claim Goal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE11D48))),
                          ],
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(LucideIcons.pencil, size: 16, color: Color(0xFF3B82F6)),
                          SizedBox(width: 12),
                          Text('Edit Container', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Notes / Rationale
            Text(
              w['notes'] as String,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            // Allocation Metrics Split Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saved Allocated',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹ ${_formatCurrency(saved)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target Ceiling',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹ ${_formatCurrency(target)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Goal Progress Bar & Dynamic Status Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isClaimed
                      ? 'Goal Extracted to Reserves'
                      : isTargetMet
                          ? 'Target Achieved 🎉'
                          : '₹${_formatCurrency(target - saved)} remaining',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isClaimed
                        ? const Color(0xFF2563EB)
                        : isTargetMet
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '$percentDisplay%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 7,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 18),

            // Bottom Action Area
            if (isClaimed) ...[
              Container(
                height: 42,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.checkCheck, size: 15, color: Color(0xFF2563EB)),
                    SizedBox(width: 7),
                    Text(
                      'Fully Claimed & Released to Reserves',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isTargetMet) ...[
              SizedBox(
                height: 42,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showConfirmClaimSheet(originalIndex),
                  icon: const Icon(LucideIcons.trophy, size: 15),
                  label: Text(
                    'Claim Goal! (₹${_formatCurrency(saved)})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openAddCashDialog(originalIndex),
                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text(
                        'Add Cash',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFECFDF5),
                        foregroundColor: const Color(0xFF059669),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFFA7F3D0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.lock, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '₹${_formatCurrency(target - saved)} left',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }).toList();

    if (isMobile) {
      return Column(
        children: cardWidgets
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: c,
                ))
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 20) / 2;
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: cardWidgets
              .map((c) => SizedBox(
                    width: cardWidth,
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildFinancialGoalsCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: const Icon(LucideIcons.sparkles, color: Color(0xFF9333EA), size: 22),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated Cash Segregation Insights',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 3),
                Text(
                  'Maintain separate reserves for GST liabilities, payroll safety nets, and capital equipment.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SetupTargetWalletDialog(onWalletCreated: _addNewWallet),
              );
            },
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Add Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3E8FF),
              foregroundColor: const Color(0xFF7E22CE),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.walletCards, color: Color(0xFF059669), size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Purpose Wallets Found',
            style: TextStyle(color: Color(0xFF0F172A), fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: const Text(
              'No segregated containers match this filter. Create purpose-driven containers to ringfence money for tax deposits, equipment, or future inventory.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SetupTargetWalletDialog(onWalletCreated: _addNewWallet),
              );
            },
            icon: const Icon(LucideIcons.plus, size: 16),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5B2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            label: const Text(
              'Create First Purpose Wallet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

