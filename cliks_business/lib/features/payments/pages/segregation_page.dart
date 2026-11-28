import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widgets/setup_target_wallet_dialog.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/account_model.dart';
import '../../../data/account_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/goal_wallet_models.dart';
import '../../../data/repositories/goal_wallet_repository.dart';
import '../../navigation/widgets/macos_showroom_menu_card.dart';
import '../providers/payments_refresh_coordinator.dart';

class SegregationPage extends ConsumerStatefulWidget {
  const SegregationPage({super.key});

  @override
  ConsumerState<SegregationPage> createState() => _SegregationPageState();
}

class _SegregationPageState extends ConsumerState<SegregationPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  List<GoalWallet> _wallets = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    final cached = ref.read(paymentsSegregationDataProvider);
    if (cached != null) {
      _wallets = cached.wallets;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Indian currency format helper (e.g. 451000 -> 4,51,000)
  String _formatCurrency(double val) {
    if (val == 0) return '0';
    final isNegative = val < 0;
    final clampedVal = val.abs() > 999999999999.99
        ? 999999999999.99
        : val.abs();
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

  Future<void> _loadData({bool isManualReload = false}) async {
    final version = ++_loadVersion;

    if (mounted) {
      setState(() {
        _isLoading = _wallets.isEmpty;
        _errorMessage = null;
      });
    }

    try {
      await ref.read(paymentsRefreshCoordinatorProvider.notifier).loadModule(
            PaymentsModule.segregation,
            isManualReload: isManualReload,
          );
      final data = ref.read(paymentsSegregationDataProvider);
      if (version != _loadVersion || !mounted) return;

      if (data != null) {
        setState(() {
          _wallets = data.wallets;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (version != _loadVersion || !mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (version == _loadVersion && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<GoalWallet> get _filteredWallets {
    if (_searchQuery.trim().isEmpty) return _wallets;
    final q = _searchQuery.trim().toLowerCase();
    return _wallets.where((w) {
      final nameMatch = w.name.toLowerCase().contains(q);
      final descMatch = w.description.toLowerCase().contains(q);
      return nameMatch || descMatch;
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DIALOGS & ACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  void _openSetupTargetWalletDialog() {
    final activeEmail = ref
        .read(activeAccountProvider)
        .email
        .trim()
        .toLowerCase();
    showDialog(
      context: context,
      builder: (context) => SetupTargetWalletDialog(
        activeEmail: activeEmail,
        onWalletCreated: (created) {
          _loadData(isManualReload: true);
          ref.read(paymentsRefreshCoordinatorProvider.notifier).notifyMutation(PaymentsModule.segregation);
        },
      ),
    );
  }

  void _openAllocationLedgerDialog(GoalWallet wallet) {
    final activeEmail = ref
        .read(activeAccountProvider)
        .email
        .trim()
        .toLowerCase();
    showDialog(
      context: context,
      builder: (ctx) =>
          AllocationLedgerDialog(wallet: wallet, activeEmail: activeEmail),
    );
  }

  void _showConfirmClaimSheet(GoalWallet wallet) {
    final title = wallet.name;
    final savedFormatted = _formatCurrency(wallet.currentAmount);
    bool isClaiming = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
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

                // Trophy Icon Badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFEE2E8),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.trophy,
                    color: Color(0xFFE11D48),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Claim & Extract Goal',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Extract ₹$savedFormatted accumulated for "$title" and release it into active business reserves?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 26),

                // Buttons (Cancel & Confirm)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isClaiming ? null : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isClaiming
                            ? null
                            : () async {
                                setModalState(() => isClaiming = true);
                                final activeEmail = ref
                                    .read(activeAccountProvider)
                                    .email
                                    .trim()
                                    .toLowerCase();
                                try {
                                  await GoalWalletRepository.claimGoalWallet(
                                    wallet.id,
                                    email: activeEmail,
                                  );
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  AppSnackbar.show(
                                    context,
                                    "Successfully extracted ₹$savedFormatted for \"$title\" into reserves!",
                                    type: SnackType.success,
                                  );
                                  _loadData(isManualReload: true);
                                  ref.read(paymentsRefreshCoordinatorProvider.notifier).notifyMutation(PaymentsModule.segregation);
                                } catch (e) {
                                  setModalState(() => isClaiming = false);
                                  final msg = e is ApiException
                                      ? e.message
                                      : e.toString();
                                  AppSnackbar.show(
                                    ctx,
                                    'Failed to claim goal: $msg',
                                    type: SnackType.error,
                                  );
                                }
                              },
                        icon: isClaiming
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(LucideIcons.checkCircle2, size: 16),
                        label: Text(
                          isClaiming ? 'Claiming...' : 'Confirm Release',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.stylishDarkGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openAddCashDialog(GoalWallet wallet) {
    final isClaimed = wallet.isClaimed;
    final currentSaved = wallet.currentAmount;
    final target = wallet.targetAmount;
    final remaining = wallet.remainingAmount;

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

    final controller = TextEditingController();
    bool isSubmitting = false;

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
          final entered =
              double.tryParse(controller.text.replaceAll(',', '').trim()) ??
              0.0;
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
                      child: const Icon(
                        LucideIcons.plusCircle,
                        color: Color(0xFF059669),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Cash to ${wallet.name}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Saved: ₹${_formatCurrency(currentSaved)} of ₹${_formatCurrency(target)}  •  Remaining: ₹${_formatCurrency(remaining)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
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
                      color: isOverCap
                          ? const Color(0xFFE11D48)
                          : const Color(0xFFCBD5E1),
                      width: isOverCap ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                          onChanged: (_) => setSheetState(() {}),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Max deposit ₹${_formatCurrency(remaining)}',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            controller.clear();
                            setSheetState(() {});
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Chips Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.text = remaining.toInt().toString();
                        setSheetState(() {});
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.zap,
                              size: 12,
                              color: Color(0xFFE11D48),
                            ),
                            const SizedBox(width: 4),
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
                    ...quickChips
                        .where((chip) => (chip['val'] as double) <= remaining)
                        .map((chip) {
                          return InkWell(
                            onTap: () {
                              setSheetState(() {
                                final currentVal =
                                    double.tryParse(
                                      controller.text
                                          .replaceAll(',', '')
                                          .trim(),
                                    ) ??
                                    0.0;
                                final newVal =
                                    (currentVal + (chip['val'] as double))
                                        .clamp(0.0, remaining);
                                controller.text = newVal.toInt().toString();
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFA7F3D0),
                                ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          size: 14,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Exceeds goal ceiling! You only need ₹${_formatCurrency(remaining)} to complete this goal.',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (entered > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '₹${_formatCurrency(projectedTotal)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: projectedTotal >= target
                                ? const Color(0xFF059669)
                                : const Color(0xFF0F172A),
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
                        onPressed: isSubmitting
                            ? null
                            : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: (isOverCap || isSubmitting)
                            ? null
                            : () async {
                                final added =
                                    double.tryParse(
                                      controller.text
                                          .replaceAll(',', '')
                                          .trim(),
                                    ) ??
                                    0;
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

                                setSheetState(() => isSubmitting = true);
                                final activeEmail = ref
                                    .read(activeAccountProvider)
                                    .email
                                    .trim()
                                    .toLowerCase();

                                try {
                                  final req = AddMoneyGoalWalletRequest(
                                    amount: added,
                                  );
                                  await GoalWalletRepository.addMoney(
                                    wallet.id,
                                    req,
                                    email: activeEmail,
                                  );
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  if (currentSaved + added >= target) {
                                    AppSnackbar.show(
                                      context,
                                      "Goal Achieved! '${wallet.name}' reached 100% target and is ready to claim!",
                                      type: SnackType.success,
                                    );
                                  } else {
                                    AppSnackbar.show(
                                      context,
                                      "Deposited ₹${_formatCurrency(added)} into '${wallet.name}'. ₹${_formatCurrency(target - (currentSaved + added))} remaining.",
                                      type: SnackType.success,
                                    );
                                  }
                                  _loadData(isManualReload: true);
                                  ref.read(paymentsRefreshCoordinatorProvider.notifier).notifyMutation(PaymentsModule.segregation);
                                } catch (e) {
                                  setSheetState(() => isSubmitting = false);
                                  final msg = e is ApiException
                                      ? e.message
                                      : e.toString();
                                  AppSnackbar.show(
                                    ctx,
                                    'Failed to add money: $msg',
                                    type: SnackType.error,
                                  );
                                }
                              },
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(LucideIcons.check, size: 16),
                        label: Text(
                          isSubmitting ? 'Depositing...' : 'Deposit Cash',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5B2E),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

  void _openEditWalletDialog(GoalWallet wallet) {
    final titleController = TextEditingController(text: wallet.name);
    final targetController = TextEditingController(
      text: wallet.targetAmount.toInt().toString(),
    );
    final notesController = TextEditingController(text: wallet.description);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setEditState) {
          return Padding(
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
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.pencil,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Purpose Container',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'PURPOSE / ITEM NAME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'TARGET CAP AMOUNT (INR)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: targetController,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'DESCRIPTIVE NOTES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final newTitle = titleController.text.trim();
                              final newTarget =
                                  double.tryParse(
                                    targetController.text
                                        .replaceAll(',', '')
                                        .trim(),
                                  ) ??
                                  wallet.targetAmount;
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

                              setEditState(() => isSaving = true);
                              final activeEmail = ref
                                  .read(activeAccountProvider)
                                  .email
                                  .trim()
                                  .toLowerCase();

                              try {
                                final req = UpdateGoalWalletRequest(
                                  name: newTitle,
                                  targetAmount: newTarget,
                                  description: newNotes,
                                );
                                await GoalWalletRepository.updateGoalWallet(
                                  wallet.id,
                                  req,
                                  email: activeEmail,
                                );
                                if (!mounted) return;
                                Navigator.pop(ctx);
                                AppSnackbar.show(
                                  context,
                                  "Purpose wallet '$newTitle' updated successfully!",
                                  type: SnackType.success,
                                );
                                _loadData(isManualReload: true);
                                ref.read(paymentsRefreshCoordinatorProvider.notifier).notifyMutation(PaymentsModule.segregation);
                              } catch (e) {
                                setEditState(() => isSaving = false);
                                final msg = e is ApiException
                                    ? e.message
                                    : e.toString();
                                AppSnackbar.show(
                                  ctx,
                                  'Failed to update wallet: $msg',
                                  type: SnackType.error,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5B2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteWallet(GoalWallet wallet) {
    final title = wallet.name;
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Delete Purpose Wallet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Are you sure you want to delete '$title'? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
              ElevatedButton(
                onPressed: isDeleting
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);
                        final activeEmail = ref
                            .read(activeAccountProvider)
                            .email
                            .trim()
                            .toLowerCase();
                        try {
                          await GoalWalletRepository.deleteGoalWallet(
                            wallet.id,
                            email: activeEmail,
                          );
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          AppSnackbar.show(
                            context,
                            "Purpose wallet '$title' deleted.",
                            type: SnackType.info,
                          );
                          _loadData(isManualReload: true);
                          ref.read(paymentsRefreshCoordinatorProvider.notifier).notifyMutation(PaymentsModule.segregation);
                        } catch (e) {
                          setDialogState(() => isDeleting = false);
                          final msg = e is ApiException
                              ? e.message
                              : e.toString();
                          AppSnackbar.show(
                            ctx,
                            'Failed to delete wallet: $msg',
                            type: SnackType.error,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final coordinatorState = ref.watch(paymentsRefreshCoordinatorProvider);
    final isRefreshing = coordinatorState.statusOf(PaymentsModule.segregation) == ModuleLoadStatus.refreshing;
    final cached = coordinatorState.segregationData;
    if (cached != null && _wallets.isEmpty) {
      _wallets = cached.wallets;
    }

    ref.listen<AccountModel>(activeAccountProvider, (previous, next) {
      final prevEmail = previous?.email.trim().toLowerCase() ?? '';
      final nextEmail = next.email.trim().toLowerCase();
      if (prevEmail.isNotEmpty && nextEmail.isNotEmpty && prevEmail != nextEmail) {
        ApiClient.clearCliksToken();
        setState(() {
          _wallets = [];
          _isLoading = true;
        });
        _loadData(isManualReload: true);
      }
    });

    ref.listen<String>(selectedShowroomScopeProvider, (previous, next) {
      if (previous != null && previous.isNotEmpty && previous != next) {
        setState(() {
          _wallets = [];
          _isLoading = true;
        });
        _loadData(isManualReload: true);
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final paddingVal = isMobile ? 12.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          paddingVal,
          isMobile ? 16 : 24,
          paddingVal,
          isMobile ? 80 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile) ...[
              // Mobile Hero Summary & Compact Action Row (Expenses-style)
              _buildMobileHeroSummary(isRefreshing),
              const SizedBox(height: 12),
              _buildMobileActionRow(context, isMobile, isRefreshing),
              const SizedBox(height: 14),
            ] else ...[
              // Top Section Header (matching screenshot)
              _buildPageHeader(context, isMobile, isRefreshing: isRefreshing),
              const SizedBox(height: 12),
            ],

            // Optional Expandable Search Input
            if (_isSearchExpanded) ...[
              SizedBox(
                height: 42,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search purpose wallets...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 14),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F5B2E),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Content Area: Loading, Error, Empty, or Wallet Cards Grid
            _buildContentArea(context, isMobile),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MOBILE OS REDESIGN: HERO SUMMARY & COMPACT ACTION ROW (Expenses-style)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileHeroSummary(bool isRefreshing) {
    double totalAllocated = 0;
    double totalTarget = 0;
    for (final w in _wallets) {
      totalAllocated += w.currentAmount;
      totalTarget += w.targetAmount;
    }
    final progress = totalTarget > 0
        ? ((totalAllocated / totalTarget) * 100).clamp(0, 100).toStringAsFixed(1)
        : '100';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.heroGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Section Category + Live Sync Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        LucideIcons.shieldCheck,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'PURPOSE WALLETS & RESERVES',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.activity,
                      size: 11,
                      color: Colors.greenAccent.shade100,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'TREASURY ACTIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildHeroKpiChip(
                  'Active',
                  '${_wallets.length} Wallets',
                  LucideIcons.wallet,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'Allocated',
                  '₹${_formatCurrency(totalAllocated)}',
                  LucideIcons.shieldCheck,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'Target',
                  '₹${_formatCurrency(totalTarget)}',
                  LucideIcons.target,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'Progress',
                  '$progress%',
                  LucideIcons.trendingUp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroKpiChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionRow(BuildContext context, bool isMobile, bool isRefreshing) {
    return Row(
      children: [
        IconButton(
          key: const Key('header_reload_segregation_button'),
          onPressed: () => _loadData(isManualReload: true),
          icon: isRefreshing
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F5B2E)),
                )
              : const Icon(LucideIcons.refreshCw, size: 14, color: Color(0xFF0F5B2E)),
          tooltip: 'Reload Wallets',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              _isSearchExpanded = !_isSearchExpanded;
            });
          },
          icon: Icon(
            _isSearchExpanded ? LucideIcons.x : LucideIcons.search,
            size: 14,
            color: _isSearchExpanded ? const Color(0xFF0F5B2E) : const Color(0xFF475569),
          ),
          tooltip: 'Search wallets',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _openSetupTargetWalletDialog,
            icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Setup Purpose Wallet',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: Colors.white),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5B2E),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPageHeader(BuildContext context, bool isMobile, {bool isRefreshing = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circular Target Icon
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF0F5B2E),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.target, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Flexible(
                    child: Text(
                      'Segregation Wallets',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F5B2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = !_isSearchExpanded;
                      });
                    },
                    icon: Icon(
                      LucideIcons.search,
                      size: 18,
                      color: _isSearchExpanded
                          ? const Color(0xFF0F5B2E)
                          : const Color(0xFF475569),
                    ),
                    tooltip: 'Search wallets',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Create target-based wallets to isolate and secure funds for specific business needs.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 16),
          IconButton(
            key: const Key('header_reload_segregation_button'),
            onPressed: () => _loadData(isManualReload: true),
            icon: isRefreshing
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F5B2E)),
                  )
                : const Icon(LucideIcons.refreshCw, size: 15, color: Color(0xFF0F5B2E)),
            tooltip: 'Reload Wallets',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _openSetupTargetWalletDialog,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text(
              'Setup Purpose Wallet',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5B2E),
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
  // CONTENT AREA
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildContentArea(BuildContext context, bool isMobile) {
    if (_isLoading && _wallets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0F5B2E),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_errorMessage != null && _wallets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.alertCircle,
              color: Color(0xFFE11D48),
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE11D48),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadData(),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F5B2E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredWallets.isEmpty) {
      return _buildEmptyStateCard(context, isMobile);
    }

    return _buildWalletCardsSection(isMobile);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WALLET CARDS SECTION (GRID)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildWalletCardsSection(bool isMobile) {
    final cardWidgets = _filteredWallets.map((w) {
      final saved = w.currentAmount;
      final target = w.targetAmount;
      final isClaimed = w.isClaimed;
      final isTargetMet = w.isTargetMet;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, History Icon, More Vert Options
            Row(
              children: [
                Expanded(
                  child: Text(
                    w.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Allocation Ledger History Icon
                IconButton(
                  icon: const Icon(
                    LucideIcons.history,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  tooltip: 'Allocation Ledger',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _openAllocationLedgerDialog(w),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(
                    LucideIcons.moreVertical,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'history') {
                      _openAllocationLedgerDialog(w);
                    } else if (value == 'add') {
                      _openAddCashDialog(w);
                    } else if (value == 'claim') {
                      _showConfirmClaimSheet(w);
                    } else if (value == 'edit') {
                      _openEditWalletDialog(w);
                    } else if (value == 'delete') {
                      _deleteWallet(w);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem<String>(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.history,
                            size: 16,
                            color: Color(0xFF0F5B2E),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Allocation Ledger',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isTargetMet && !isClaimed)
                      const PopupMenuItem<String>(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.plusCircle,
                              size: 16,
                              color: Color(0xFF059669),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Deposit Cash',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isTargetMet && !isClaimed)
                      const PopupMenuItem<String>(
                        value: 'claim',
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.trophy,
                              size: 16,
                              color: Color(0xFFE11D48),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Claim Goal',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: Color(0xFF3B82F6),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Edit Purpose Wallet',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Status Badge below title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isClaimed
                    ? const Color(0xFFEFF6FF)
                    : (isTargetMet
                          ? const Color(0xFFFFF1F2)
                          : const Color(0xFFECFDF5)),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isClaimed
                      ? const Color(0xFFBFDBFE)
                      : (isTargetMet
                            ? const Color(0xFFFECDD3)
                            : const Color(0xFFA7F3D0)),
                ),
              ),
              child: Text(
                isClaimed
                    ? '🎉 FULLY CLAIMED'
                    : (isTargetMet ? '🎯 TARGET MET' : '🌱 IN PROGRESS'),
                style: TextStyle(
                  color: isClaimed
                      ? const Color(0xFF2563EB)
                      : (isTargetMet
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF047857)),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Descriptive notes
            Text(
              w.description.isNotEmpty ? w.description : 'descriptive notes',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            // Allocation Metrics Box (Saved Allocated & Target Ceiling)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saved Allocated',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '₹${_formatCurrency(saved)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Target Ceiling',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '₹${_formatCurrency(target)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Goal Status & Percent (Protected against NaN, Infinity, scientific notation)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Goal Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${w.progressPercent}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: w.progressRatio,
                minHeight: 7,
                backgroundColor: const Color(0xFFCBD5E1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isClaimed
                      ? const Color(0xFF94A3B8)
                      : (isTargetMet
                            ? const Color(0xFF047857)
                            : const Color(0xFF0F5B2E)),
                ),
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.check, size: 16, color: Color(0xFF047857)),
                    SizedBox(width: 6),
                    Text(
                      'Claimed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
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
                  onPressed: () => _showConfirmClaimSheet(w),
                  icon: const Icon(LucideIcons.trophy, size: 16),
                  label: const Text(
                    'Claim Goal',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5B2E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () => _openAddCashDialog(w),
                        icon: const Icon(LucideIcons.plus, size: 15),
                        label: const Text(
                          'Deposit Cash',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5B2E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '₹${_formatCurrency(w.remainingAmount)} left',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
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
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: c,
              ),
            )
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
              .map((c) => SizedBox(width: cardWidth, child: c))
              .toList(),
        );
      },
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
              color: const Color(0xFF0F5B2E).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.target,
              color: Color(0xFF0F5B2E),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Segregation Wallets',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: const Text(
              'Setup isolated purpose-driven buckets! For example, reserve money sequentially for office equipment, tax deposits, or inventory buffers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openSetupTargetWalletDialog,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text(
              'Create Purpose Wallet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5B2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ALLOCATION LEDGER DIALOG (Connected to API timing & transactions)
// ══════════════════════════════════════════════════════════════════════════════
class AllocationLedgerDialog extends StatefulWidget {
  final GoalWallet wallet;
  final String? activeEmail;

  const AllocationLedgerDialog({
    super.key,
    required this.wallet,
    this.activeEmail,
  });

  @override
  State<AllocationLedgerDialog> createState() => _AllocationLedgerDialogState();
}

class _AllocationLedgerDialogState extends State<AllocationLedgerDialog> {
  bool _isLoading = true;
  GoalWallet? _walletDetails;

  @override
  void initState() {
    super.initState();
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    setState(() => _isLoading = true);
    try {
      final details = await GoalWalletRepository.getGoalWalletDetails(
        widget.wallet.id,
        email: widget.activeEmail,
      );
      if (!mounted) return;
      setState(() {
        _walletDetails = details ?? widget.wallet;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _walletDetails = widget.wallet;
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double val) {
    if (val == 0) return '0';
    final isNegative = val < 0;
    final clampedVal = val.abs() > 999999999999.99
        ? 999999999999.99
        : val.abs();
    final absVal = clampedVal.round();
    final s = absVal.toString();
    if (s.length <= 3) return isNegative ? '-$s' : s;
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    final result = '$formattedRest,$last3';
    return isNegative ? '-$result' : result;
  }

  @override
  Widget build(BuildContext context) {
    final currentWallet = _walletDetails ?? widget.wallet;
    final transactions = currentWallet.transactions;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 460,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.history,
                      size: 18,
                      color: Color(0xFF0F5B2E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Allocation Ledger',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F5B2E),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      LucideIcons.x,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected Wallet Info Card
                    Container(
                      width: double.infinity,
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
                            'SELECTED WALLET',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentWallet.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Isolated',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                '₹${_formatCurrency(currentWallet.currentAmount)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Allocation History Header
                    const Text(
                      'ALLOCATION HISTORY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF0F5B2E),
                          ),
                        ),
                      )
                    else if (transactions.isNotEmpty)
                      ...transactions.map((tx) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.isCredit
                                        ? '✦ IN / CREDIT'
                                        : '✦ OUT / DEBIT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: tx.isCredit
                                          ? const Color(0xFF047857)
                                          : const Color(0xFFE11D48),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tx.formattedDate.isNotEmpty
                                        ? tx.formattedDate
                                        : (currentWallet.createdAt != null
                                              ? GoalWalletTransaction.formatLedgerDate(
                                                  currentWallet.createdAt!
                                                      .toLocal(),
                                                )
                                              : 'Recent allocation'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${tx.isCredit ? '+' : '-'} ₹${_formatCurrency(tx.amount)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    else if (currentWallet.currentAmount > 0)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '✦ IN / CREDIT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentWallet.createdAt != null
                                      ? GoalWalletTransaction.formatLedgerDate(
                                          currentWallet.createdAt!.toLocal(),
                                        )
                                      : 'Initial deposit',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '+ ₹${_formatCurrency(currentWallet.currentAmount)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Text(
                            'No allocation transactions recorded for this wallet yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
