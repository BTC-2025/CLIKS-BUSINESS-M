import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/account_provider.dart';
import '../../../models/account_model.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/repositories/payments_repository.dart';
import '../../navigation/widgets/macos_showroom_menu_card.dart';
import '../widgets/customer_payment_dialog.dart';
import '../widgets/supplier_disbursement_dialog.dart';
import '../../../core/network/api_exception.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../widgets/bento/bento.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  // 0: Receivables, 1: Payables, 2: Registers, 3: Overdue, 4: Total Inward & Outward
  int _activeTab = 0;

  PaymentReports? _reports;
  OutstandingStats? _outstandingStats;
  bool _isLoading = true;
  String? _errorMessage;

  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reports = await PaymentsRepository.getPaymentReports();
      final stats = await PaymentsRepository.getOutstandingStats();

      if (mounted) {
        setState(() {
          _reports = reports;
          _outstandingStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openTransactionSheet(PaymentTransaction? item, {bool isSupplier = false}) {
    final isOutward = item != null ? (item.type.toLowerCase() == 'pay') : isSupplier;
    final accounts = _reports?.accounts ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (isOutward) {
          final supplierOptions = _reports?.payables
                  .map((p) => p.partyName)
                  .where((name) => name.isNotEmpty)
                  .toSet()
                  .toList() ??
              [];

          return RecordSupplierDisbursementDialog(
            transaction: item,
            accounts: accounts,
            supplierOptions: supplierOptions,
            onDisbursementSuccess: () {
              _loadData();
            },
          );
        } else {
          final customerOptions = _reports?.receivables
                  .map((r) => r.partyName)
                  .where((name) => name.isNotEmpty)
                  .toSet()
                  .toList() ??
              [];

          return RecordCustomerPaymentDialog(
            transaction: item,
            accounts: accounts,
            customerOptions: customerOptions,
            onPaymentSuccess: () {
              _loadData();
            },
          );
        }
      },
    );
  }

  void _openTransferDialog(BuildContext context) {
    final accounts = _reports?.accounts ?? [];
    if (accounts.length < 2) {
      AppSnackbar.show(
        context,
        'At least two accounts (e.g. Bank and Cash Register) are required to perform a transfer.',
        type: SnackType.warning,
      );
      return;
    }

    PaymentAccount fromAcc = accounts.first;
    PaymentAccount toAcc = accounts.length > 1 ? accounts[1] : accounts.first;
    final amountCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.arrowLeftRight, size: 20, color: Color(0xFF1E40AF)),
                            SizedBox(width: 8),
                            Text(
                              'Internal Account Transfer',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(LucideIcons.x, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Move funds between registered bank accounts and cash registers.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 18),

                    // From Account
                    const Text(
                      'From Account (Deducted)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<PaymentAccount>(
                      value: fromAcc,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      items: accounts.map((a) {
                        return DropdownMenuItem<PaymentAccount>(
                          value: a,
                          child: Text(
                            '${a.bankAccountName} (Bal: ₹${_formatCurrency(a.currentBalance)})',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            fromAcc = val;
                            if (toAcc.id == fromAcc.id) {
                              toAcc = accounts.firstWhere((a) => a.id != fromAcc.id);
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // To Account
                    const Text(
                      'To Account (Credited)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<PaymentAccount>(
                      value: toAcc,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      items: accounts.where((a) => a.id != fromAcc.id).map((a) {
                        return DropdownMenuItem<PaymentAccount>(
                          value: a,
                          child: Text(
                            '${a.bankAccountName} (Bal: ₹${_formatCurrency(a.currentBalance)})',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => toAcc = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Amount
                    const Text(
                      'Transfer Amount (₹)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: const TextStyle(fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                                    if (amt <= 0) {
                                      AppSnackbar.show(
                                        context,
                                        'Please enter an amount greater than zero',
                                        type: SnackType.warning,
                                      );
                                      return;
                                    }
                                    if (amt > fromAcc.currentBalance) {
                                      AppSnackbar.show(
                                        context,
                                        'Amount exceeds available balance of ₹${_formatCurrency(fromAcc.currentBalance)}',
                                        type: SnackType.warning,
                                      );
                                      return;
                                    }
                                    setModalState(() => isSubmitting = true);
                                    try {
                                      final req = AccountTransferRequest(
                                        fromAccId: fromAcc.id,
                                        toAccId: toAcc.id,
                                        amount: amt,
                                      );
                                      final res = await PaymentsRepository.transferFunds(req);
                                      Navigator.pop(ctx);
                                      final msg = res['message']?.toString() ?? 'Fund transfer settled successfully';
                                      AppSnackbar.show(context, msg, type: SnackType.success);
                                      _loadData();
                                    } on ApiException catch (e) {
                                      setModalState(() => isSubmitting = false);
                                      AppSnackbar.show(context, e.message, type: SnackType.error);
                                    } catch (e) {
                                      setModalState(() => isSubmitting = false);
                                      AppSnackbar.show(context, 'Transfer failed: $e', type: SnackType.error);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E40AF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Execute Transfer',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Calculated Hero Metrics ────────────────────────────────────────────────
  double get _combinedBalance {
    if (_reports != null && _reports!.accounts.isNotEmpty) {
      return _reports!.accounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);
    }
    return _outstandingStats?.totalProcessed ?? 0.0;
  }

  double get _receivablesTotal {
    if (_outstandingStats != null && _outstandingStats!.receivables > 0) {
      return _outstandingStats!.receivables;
    }
    if (_reports != null && _reports!.receivables.isNotEmpty) {
      return _reports!.receivables.fold(0.0, (sum, item) => sum + item.pendingAmount);
    }
    return 0.0;
  }

  double get _dailyCollections {
    if (_outstandingStats != null && _outstandingStats!.totalProcessed > 0) {
      return _outstandingStats!.totalProcessed;
    }
    if (_reports != null && _reports!.receivables.isNotEmpty) {
      return _reports!.receivables.fold(0.0, (sum, item) => sum + item.paidAmount);
    }
    return 0.0;
  }

  String get _efficiencyRate {
    final coll = _dailyCollections;
    final total = _combinedBalance + _receivablesTotal;
    if (total > 0) {
      final rate = (coll / total * 100).clamp(0.0, 100.0);
      return rate.toStringAsFixed(1);
    }
    return '100.0';
  }

  String _formatCurrency(num value) {
    return value
        .toInt()
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  // ── Filtered Records for Active Tab ───────────────────────────────────────
  List<PaymentTransaction> get _activeTransactions {
    if (_reports == null) return [];

    List<PaymentTransaction> list = [];
    if (_activeTab == 0) {
      list = _reports!.receivables;
    } else if (_activeTab == 1) {
      list = _reports!.payables;
    } else if (_activeTab == 4) {
      list = [..._reports!.receivables, ..._reports!.payables];
    } else {
      return [];
    }

    if (_searchQuery.trim().isEmpty) return list;

    final q = _searchQuery.toLowerCase();
    return list.where((t) {
      return t.partyName.toLowerCase().contains(q) ||
          t.id.toString().toLowerCase().contains(q) ||
          t.paymentMode.toLowerCase().contains(q) ||
          (t.invoiceId?.toLowerCase().contains(q) ?? false) ||
          (t.purchaseId?.toLowerCase().contains(q) ?? false) ||
          t.referenceNumber.toLowerCase().contains(q);
    }).toList();
  }

  List<OverdueInvoice> get _activeOverdueInvoices {
    if (_reports == null) return [];
    final list = _reports!.overdueInvoices;
    if (_searchQuery.trim().isEmpty) return list;

    final q = _searchQuery.toLowerCase();
    return list.where((inv) {
      return inv.clientName.toLowerCase().contains(q) ||
          inv.invoiceNumber.toLowerCase().contains(q) ||
          inv.status.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AccountModel>(activeAccountProvider, (previous, next) {
      if (previous?.email != next.email) {
        setState(() {
          _reports = null;
          _outstandingStats = null;
        });
        _loadData();
      }
    });

    ref.listen<String>(selectedShowroomScopeProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          _reports = null;
          _outstandingStats = null;
        });
        _loadData();
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(paddingVal, isMobile ? 12 : 20, paddingVal, isMobile ? 80 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Summary (Gradient Stats & Actions)
              isMacOS
                  ? _buildMacOsBentoHero(context, isMobile)
                  : _buildHeroSummary(context, isMobile)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.05, end: 0),
              SizedBox(height: isMobile ? 14 : 28),

              // Segment Tabs Row
              _buildTabsRow(isMobile).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              SizedBox(height: isMobile ? 14 : 20),

              // Records Table Card
              _buildRecordsCard(isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MACOS SOFT UI BENTO HERO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMacOsBentoHero(BuildContext context, bool isMobile) {
    final combinedFmt = _formatCurrency(_combinedBalance);
    final receivablesFmt = _formatCurrency(_receivablesTotal);
    final dailyCollFmt = _formatCurrency(_dailyCollections);
    final efficiency = _efficiencyRate;

    return MacOsSoftUiBentoHero(
      margin: EdgeInsets.zero,
      title: 'Settlements & Cashflow Ledger',
      mainValue: '₹ $combinedFmt',
      subtitle: 'Net merchant collections, vendor disbursements & automated clearing cycles',
      badgeText: 'SETTLEMENTS LIVE',
      badgeIcon: LucideIcons.arrowLeftRight,
      isMobile: isMobile,
      chips: [
        MacOsBentoHeroChip(
          label: 'Pending Receivables',
          value: '₹ $receivablesFmt',
          icon: LucideIcons.arrowDownLeft,
          accentColor: const Color(0xFF166534),
        ),
        MacOsBentoHeroChip(
          label: 'Total Collected',
          value: '₹ $dailyCollFmt',
          icon: LucideIcons.badgeCheck,
          accentColor: const Color(0xFF2563EB),
        ),
        MacOsBentoHeroChip(
          label: 'Recovery Ratio',
          value: '$efficiency%',
          icon: LucideIcons.percent,
          accentColor: const Color(0xFFD97706),
        ),
      ],
      trailingAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            onPressed: () => _openTransferDialog(context),
            icon: const Icon(LucideIcons.arrowLeftRight, size: 13),
            label: const Text('Transfer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E40AF),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _openTransactionSheet(null, isSupplier: true),
            icon: const Icon(LucideIcons.arrowUpRight, size: 13),
            label: const Text('Pay Supplier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF166534),
              side: const BorderSide(color: Color(0xFFBBF7D0)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _openTransactionSheet(null, isSupplier: false),
            icon: const Icon(LucideIcons.arrowDownLeft, size: 13),
            label: const Text('Receive Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context, bool isMobile) {
    final transferBtn = OutlinedButton.icon(
      onPressed: () => _openTransferDialog(context),
      icon: const Icon(LucideIcons.arrowLeftRight, size: 14),
      label: const Text('Transfer', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final paySupplierBtn = OutlinedButton.icon(
      onPressed: () => _openTransactionSheet(null, isSupplier: true),
      icon: const Icon(LucideIcons.arrowUpRight, size: 14),
      label: const Text('Pay Supplier', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final receivePaymentBtn = ElevatedButton.icon(
      onPressed: () => _openTransactionSheet(null, isSupplier: false),
      icon: const Icon(LucideIcons.arrowDownLeft, size: 14),
      label: const Text('Receive Payment', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.stylishDarkGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );

    final combinedFmt = _formatCurrency(_combinedBalance);
    final receivablesFmt = _formatCurrency(_receivablesTotal);
    final dailyCollFmt = _formatCurrency(_dailyCollections);
    final efficiency = _efficiencyRate;

    final actionsWidget = isMobile
        ? Row(
            children: [
              Expanded(child: transferBtn),
              const SizedBox(width: 6),
              Expanded(child: paySupplierBtn),
              const SizedBox(width: 6),
              Expanded(child: receivePaymentBtn),
            ],
          )
        : Row(
            children: [
              transferBtn,
              const SizedBox(width: 8),
              paySupplierBtn,
              const SizedBox(width: 8),
              receivePaymentBtn,
            ],
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
                      'COMBINED BALANCES',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ $combinedFmt',
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
              if (!isMobile) actionsWidget,
            ],
          ),
          if (isMobile) const SizedBox(height: 16),
          if (isMobile) actionsWidget,
          const SizedBox(height: 16),
          // 3 Stat Chips in a row
          Row(
            children: [
              _buildHeroChip('Receivables', '₹ $receivablesFmt', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Daily Coll.', '₹ $dailyCollFmt', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Efficiency', '$efficiency%', isMobile),
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

  Widget _buildTabsRow(bool isMobile) {
    final tabs = [
      {'title': 'Customer Receivables (Inward)', 'icon': LucideIcons.arrowDownLeft},
      {'title': 'Supplier Payables (Outward)', 'icon': LucideIcons.arrowUpRight},
      {'title': 'Bank & Cash Registers', 'icon': LucideIcons.landmark},
      {'title': 'Overdue Collections & Reminders', 'icon': LucideIcons.alertCircle},
      {'title': 'Total Inward & Outward', 'icon': LucideIcons.arrowLeftRight},
    ];

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = _activeTab == index;
                final tabItem = tabs[index];
                final icon = tabItem['icon'] as IconData;
                final title = tabItem['title'] as String;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF166534) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF166534) : const Color(0xFFE5E7EB),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF166534).withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 14,
                            color: isSelected ? Colors.white : AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.secondaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Search trigger button or search bar
        if (!_isSearchOpen)
          IconButton(
            icon: const Icon(LucideIcons.search, size: 18, color: AppColors.secondaryText),
            onPressed: () => setState(() => _isSearchOpen = true),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          )
        else
          Container(
            width: isMobile ? 150 : 220,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF166534)),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 13, color: AppColors.darkText),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search records...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                suffixIcon: IconButton(
                  icon: const Icon(LucideIcons.x, size: 14, color: AppColors.secondaryText),
                  onPressed: () {
                    setState(() {
                      _isSearchOpen = false;
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecordsCard(bool isMobile) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 64),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tableBorder),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2.5),
              SizedBox(height: 16),
              Text(
                'Loading payments data from server...',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _reports == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 36, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text(
                'Failed to load payment reports',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(LucideIcons.rotateCcw, size: 14),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_activeTab == 2) {
      return _buildBankRegistersView(isMobile);
    }

    if (_activeTab == 3) {
      return _buildOverdueInvoicesView(isMobile);
    }

    final txList = _activeTransactions;

    if (isMobile) {
      return _buildMobileTransactionsList(txList);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = math.max(constraints.maxWidth, 980.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(1.8), // RECEIPT ID
                      1: FlexColumnWidth(1.2), // DATE
                      2: FlexColumnWidth(2.0), // PARTY (CUSTOMER / SUPPLIER)
                      3: FlexColumnWidth(1.4), // INVOICE / PURCHASE LINKED
                      4: FlexColumnWidth(1.5), // TOTAL ORIGINAL
                      5: FlexColumnWidth(1.5), // PAID AMOUNT
                      6: FlexColumnWidth(1.5), // MODE
                      7: FlexColumnWidth(1.6), // RECONCILIATION
                      8: FlexColumnWidth(1.2), // ACTIONS
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                        ),
                        children: [
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('RECEIPT ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('DATE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Text(
                              _activeTab == 1 ? 'SUPPLIER' : 'CUSTOMER',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Text(
                              _activeTab == 1 ? 'PURCHASE LINKED' : 'INVOICE LINKED',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('TOTAL ORIGINAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('PAID AMOUNT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('MODE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('RECONCILIATION', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('ACTIONS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                        ],
                      ),
                      ...txList.map((tx) {
                        final isReconciled = tx.isReconciled;
                        final totalFmt = _formatCurrency(tx.totalOriginal);
                        final paidFmt = _formatCurrency(tx.paidAmount);

                        return TableRow(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text(tx.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text(tx.formattedDate, style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text(tx.partyName, style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text(tx.displayReference, style: const TextStyle(fontSize: 13, color: AppColors.secondaryText))),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), child: Text('₹ $totalFmt', style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Text(
                                '₹ $paidFmt',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tx.type.toLowerCase() == 'pay' ? const Color(0xFFDC2626) : AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                  child: Text(tx.paymentMode, style: const TextStyle(fontSize: 12, color: AppColors.darkText), overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isReconciled ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isReconciled ? 'MATCHED' : tx.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isReconciled ? const Color(0xFF065F46) : const Color(0xFF92400E),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(LucideIcons.pencil, size: 15, color: AppColors.blue),
                                  onPressed: () => _openTransactionSheet(tx, isSupplier: tx.type.toLowerCase() == 'pay'),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          if (txList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.receipt, size: 28, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No transactions matching "$_searchQuery".'
                          : 'No transaction records found.',
                      style: const TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Processed payments and receipts will appear here.',
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileTransactionsList(List<PaymentTransaction> txList) {
    if (txList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.receipt, color: Color(0xFF94A3B8), size: 24),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Transaction Records Found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Transactions recorded will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: txList.map((tx) {
        final mode = tx.paymentMode;
        final isUPI = mode.toLowerCase().contains('upi');
        final isBank = mode.toLowerCase().contains('bank');
        final isCash = mode.toLowerCase().contains('cash');
        final isReconciled = tx.isReconciled;
        final isOutward = tx.type.toLowerCase() == 'pay';

        final iconColor = isUPI
            ? const Color(0xFF6366F1)
            : isBank
                ? const Color(0xFF2563EB)
                : isCash
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706);
        final iconBg = iconColor.withValues(alpha: 0.12);
        final modeIcon = isUPI
            ? LucideIcons.smartphone
            : isBank
                ? LucideIcons.landmark
                : isCash
                    ? LucideIcons.banknote
                    : LucideIcons.creditCard;

        final totalStr = _formatCurrency(tx.totalOriginal);
        final paidStr = _formatCurrency(tx.paidAmount);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
              // Top Row: Avatar + Customer & Subtitle (Mode/Date) + Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(modeIcon, size: 18, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.partyName,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tx.paymentMode} • ${tx.formattedDate}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹ $paidStr',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: isOutward ? const Color(0xFFDC2626) : const Color(0xFF166534),
                        ),
                      ),
                      if (tx.totalOriginal != tx.paidAmount && tx.totalOriginal > 0) ...[
                        const SizedBox(height: 1),
                        Text(
                          'of ₹ $totalStr',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Bottom Row: Status Badge & Reference Chip + Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isReconciled ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isReconciled ? LucideIcons.checkCheck : LucideIcons.clock,
                                size: 11,
                                color: isReconciled ? const Color(0xFF166534) : const Color(0xFF92400E),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isReconciled ? 'MATCHED' : tx.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isReconciled ? const Color(0xFF166534) : const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tx.displayReference,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _openTransactionSheet(tx, isSupplier: isOutward),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(LucideIcons.pencil, size: 14, color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BANK & CASH REGISTERS TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBankRegistersView(bool isMobile) {
    final accounts = _reports?.accounts ?? [];

    if (accounts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tableBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(LucideIcons.landmark, size: 28, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Bank or Cash Accounts Connected',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Accounts registered via /api/v1/bank-accounts will appear here dynamically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid/Wrap of all real backend accounts
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: accounts.map((acc) {
                  return SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: _buildAccountCard(acc),
                  );
                }).toList(),
              );
            }
            return Column(
              children: accounts.map((acc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildAccountCard(acc),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildInternalTransferCard(),
      ],
    );
  }

  Widget _buildAccountCard(PaymentAccount account) {
    final isCash = account.isCash;
    final balanceFmt = _formatCurrency(account.currentBalance);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.hoverBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ACC-${account.id}',
                  style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCash
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCash ? 'CASH' : 'BANK',
                  style: TextStyle(
                    color: isCash ? const Color(0xFF047857) : const Color(0xFF1D4ED8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            account.displayName,
            style: const TextStyle(color: AppColors.darkText, fontSize: 17, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Account No: ${account.displayAccountNumber}',
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (account.branchName != null && account.branchName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Branch: ${account.branchName} • IFSC: ${account.ifscCode ?? "N/A"}',
              style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Balance:',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
              Text(
                '₹ $balanceFmt',
                style: const TextStyle(color: AppColors.primaryGreen, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInternalTransferCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.arrowLeftRight, color: AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              'Internal Account Transfers',
              style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Move money internally between Cash Register and connected Bank Accounts via /api/v1/payments/transfer',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // OVERDUE INVOICES TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOverdueInvoicesView(bool isMobile) {
    final list = _activeOverdueInvoices;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tableBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(LucideIcons.badgeCheck, size: 28, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Overdue Invoices',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'All customer billing schedules are current and settled.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = math.max(constraints.maxWidth, 850.0);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(1.6), // INVOICE #
                  1: FlexColumnWidth(2.2), // CLIENT
                  2: FlexColumnWidth(1.4), // TOTAL
                  3: FlexColumnWidth(1.4), // PAID
                  4: FlexColumnWidth(1.4), // DUE
                  5: FlexColumnWidth(1.4), // DUE DATE
                  6: FlexColumnWidth(1.4), // STATUS
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('INVOICE #', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('CLIENT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('TOTAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('PAID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('DUE AMOUNT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('DUE DATE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('STATUS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                    ],
                  ),
                  ...list.map((inv) {
                    return TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                      children: [
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkText))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text(inv.clientName, style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('₹ ${_formatCurrency(inv.totalAmount)}', style: const TextStyle(fontSize: 13, color: AppColors.darkText))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('₹ ${_formatCurrency(inv.paidAmount)}', style: const TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w600))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text('₹ ${_formatCurrency(inv.dueAmount)}', style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626), fontWeight: FontWeight.w700))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Text(inv.dueDate ?? 'N/A', style: const TextStyle(fontSize: 13, color: AppColors.secondaryText))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              inv.status.toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
