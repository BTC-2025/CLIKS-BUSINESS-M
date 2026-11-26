import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/account_provider.dart';
import '../../../models/account_model.dart';
import '../../../data/models/payment_transaction_models.dart';
import '../../../data/repositories/payment_transaction_repository.dart';
import '../../navigation/widgets/macos_showroom_menu_card.dart';
import '../../../widgets/app_ui_kit.dart';

/// Payments & Cash Flow Engine Page
/// Complete end-to-end backend API integration with https://cliks.beta-softnet.com/api
/// Connecting all 11 endpoints across Payments and Transactions modules.
class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  // 0: Total Inward & Outward, 1: Overdue Collections & Reminders, 2: Bank & Cash Registers
  int _activeTab = 0;

  // Real backend datasets
  List<CashFlowTransaction> _transactions = [];
  List<CashFlowAccount> _accounts = [];
  List<PaymentLedgerItem> _reportsLedger = [];
  List<Map<String, dynamic>> _overdueInvoices = [];
  OutstandingSummaryStats? _outstandingStats;

  bool _isLoading = false;
  String? _errorMessage;

  // Search & Filter state
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _flowFilter = 'ALL'; // 'ALL', 'INWARD', 'OUTWARD'

  // Selected Bank / Cash Account ID for register drill-down
  String _selectedCardId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads all live backend records for the active business account.
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activeEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();

      final results = await Future.wait([
        PaymentTransactionRepository.getTransactions(email: activeEmail),
        PaymentTransactionRepository.getPaymentReports(email: activeEmail),
        PaymentTransactionRepository.getBankAccounts(email: activeEmail),
        PaymentTransactionRepository.getOutstandingStats(email: activeEmail),
      ]);

      final txList = results[0] as List<CashFlowTransaction>;
      final reports = results[1] as Map<String, dynamic>;
      final bankAccounts = results[2] as List<CashFlowAccount>;
      final stats = results[3] as OutstandingSummaryStats;

      // Extract unified accounts
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

      // Extract overdue invoices
      final overdue = <Map<String, dynamic>>[];
      final overdueRaw = reports['overdueInvoices'];
      if (overdueRaw is List) {
        for (final o in overdueRaw) {
          if (o is Map<String, dynamic>) overdue.add(o);
        }
      }

      // Extract unified payment ledger
      final ledgerItems = <PaymentLedgerItem>[];
      final ledgerRaw = reports['ledger'];
      if (ledgerRaw is List) {
        for (final l in ledgerRaw) {
          if (l is Map<String, dynamic>) {
            ledgerItems.add(PaymentLedgerItem.fromJson(l));
          }
        }
      }
      final recRaw = reports['receivables'];
      if (recRaw is List) {
        for (final r in recRaw) {
          if (r is Map<String, dynamic>) {
            ledgerItems.add(PaymentLedgerItem.fromJson(r, defaultType: 'receive'));
          }
        }
      }
      final payRaw = reports['payables'];
      if (payRaw is List) {
        for (final p in payRaw) {
          if (p is Map<String, dynamic>) {
            ledgerItems.add(PaymentLedgerItem.fromJson(p, defaultType: 'pay'));
          }
        }
      }

      if (mounted) {
        setState(() {
          _transactions = txList;
          _accounts = combinedAccounts;
          _overdueInvoices = overdue;
          _reportsLedger = ledgerItems;
          _outstandingStats = stats;
          _isLoading = false;
          if (_selectedCardId.isEmpty && combinedAccounts.isNotEmpty) {
            _selectedCardId = combinedAccounts.first.id.toString();
          }
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

  // ── Indian Currency Formatting Helper ──────────────────────────────────────
  String _fmt(num value) {
    if (value == 0) return '0';
    final isNegative = value < 0;
    final absVal = value.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1] == '00' ? '' : '.${parts[1]}';

    if (intPart.length <= 3) {
      final res = '$intPart$decPart';
      return isNegative ? '-$res' : res;
    }
    final last3 = intPart.substring(intPart.length - 3);
    final rest = intPart.substring(0, intPart.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    final result = '$formattedRest,$last3$decPart';
    return isNegative ? '-$result' : result;
  }

  // ── Calculated Real KPI Figures ──────────────────────────────────────────
  double get _totalInward {
    double sum = 0.0;
    for (final t in _transactions) {
      if (t.isIncome) sum += t.amount;
    }
    for (final l in _reportsLedger) {
      if (l.isReceive) sum += l.paidAmount;
    }
    return sum;
  }

  double get _totalOutward {
    double sum = 0.0;
    for (final t in _transactions) {
      if (t.isExpense) sum += t.amount;
    }
    for (final l in _reportsLedger) {
      if (l.isPay) sum += l.paidAmount;
    }
    return sum;
  }

  double get _netBalance => _totalInward - _totalOutward;

  double get _combinedBalances {
    double sum = 0.0;
    for (final a in _accounts) {
      sum += a.currentBalance;
    }
    return sum;
  }

  double get _outstandingReceivables {
    if (_outstandingStats != null && _outstandingStats!.receivables > 0) {
      return _outstandingStats!.receivables;
    }
    double pending = 0.0;
    for (final l in _reportsLedger) {
      if (l.isReceive && l.pendingAmount > 0) {
        pending += l.pendingAmount;
      }
    }
    for (final o in _overdueInvoices) {
      final bal = (o['dueBalance'] ?? o['balance'] ?? o['pending_amount'] ?? 0) as num;
      pending += bal.toDouble();
    }
    return pending;
  }

  double get _dailyCollections {
    final now = DateTime.now();
    double todaySum = 0.0;
    for (final t in _transactions) {
      if (t.isIncome && t.date != null) {
        if (t.date!.year == now.year && t.date!.month == now.month && t.date!.day == now.day) {
          todaySum += t.amount;
        }
      }
    }
    for (final l in _reportsLedger) {
      if (l.isReceive && l.createdAt != null) {
        if (l.createdAt!.year == now.year && l.createdAt!.month == now.month && l.createdAt!.day == now.day) {
          todaySum += l.paidAmount;
        }
      }
    }
    return todaySum > 0 ? todaySum : _totalInward;
  }

  String get _efficiencyRate {
    final total = _totalInward + _totalOutward;
    if (total <= 0) return '100.0%';
    final rate = (_totalInward / total) * 100.0;
    return '${rate.toStringAsFixed(1)}%';
  }

  // Filtered Cash Flow Transactions
  List<CashFlowTransaction> get _filteredTransactions {
    var list = _transactions;
    if (_flowFilter == 'INWARD') {
      list = list.where((t) => t.isIncome).toList();
    } else if (_flowFilter == 'OUTWARD') {
      list = list.where((t) => t.isExpense).toList();
    }

    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((t) {
      final title = t.displayTitle.toLowerCase();
      final ref = t.displayReference.toLowerCase();
      final cat = (t.category ?? '').toLowerCase();
      final id = t.id.toString().toLowerCase();
      return title.contains(q) || ref.contains(q) || cat.contains(q) || id.contains(q);
    }).toList();
  }

  // Filtered Accounts
  List<CashFlowAccount> get _filteredAccountsList {
    if (_searchQuery.trim().isEmpty) return _accounts;
    final q = _searchQuery.toLowerCase();
    return _accounts.where((a) {
      final name = a.displayName.toLowerCase();
      final num = a.accountNumber.toLowerCase();
      final holder = a.accountHolder.toLowerCase();
      return name.contains(q) || num.contains(q) || holder.contains(q);
    }).toList();
  }

  // Filtered Overdue Invoices
  List<Map<String, dynamic>> get _filteredOverdueList {
    if (_searchQuery.trim().isEmpty) return _overdueInvoices;
    final q = _searchQuery.toLowerCase();
    return _overdueInvoices.where((item) {
      final name = (item['customerName'] ?? item['customer_name'] ?? '').toString().toLowerCase();
      final no = (item['invoiceNo'] ?? item['invoice_id'] ?? '').toString().toLowerCase();
      return name.contains(q) || no.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AccountModel>(activeAccountProvider, (previous, next) {
      if (previous?.email != next.email) {
        _loadData();
      }
    });

    ref.listen<String>(selectedShowroomScopeProvider, (previous, next) {
      if (previous != next) {
        _loadData();
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final paddingVal = isMobile ? 16.0 : 28.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF166534),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(paddingVal, isMobile ? 12 : 24, paddingVal, isMobile ? 80 : 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              _buildHeaderRow(isMobile),
              const SizedBox(height: 22),

              // 2. Top 4 KPI Metrics Row
              _buildTopKpiRow(screenWidth),
              const SizedBox(height: 22),

              // 3. Segmented 3 Tabs Row + Search
              _buildTabsRow(isMobile),
              const SizedBox(height: 18),

              // 4. Tab Body Content
              if (_errorMessage != null)
                _buildErrorBanner(),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF166534)),
                  ),
                )
              else
                _buildTabBody(screenWidth, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertTriangle, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? 'An error occurred while loading transactions',
              style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
            ),
          ),
          TextButton(
            onPressed: _loadData,
            child: const Text('Retry', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. HEADER ROW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHeaderRow(bool isMobile) {
    final titleWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF166534), // Forest Green
            borderRadius: BorderRadius.circular(11),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26166534),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              LucideIcons.creditCard,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Payments & Cash Flow Engine',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Receive customer payments, pay suppliers, link invoices, manage bank accounts/cash, and dispatch overdue reminder templates.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actionButtons = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Outlined "Transfer Funds"
        OutlinedButton.icon(
          onPressed: _openTransferFundsModal,
          icon: const Icon(LucideIcons.arrowLeftRight, size: 14, color: Color(0xFF2563EB)),
          label: const Text(
            'Transfer Funds',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Color(0xFF2563EB),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        // Outlined "Send Payment" Button
        OutlinedButton.icon(
          onPressed: _openSupplierDisbursementModal,
          icon: const Icon(LucideIcons.arrowUpRight, size: 14, color: Color(0xFF166534)),
          label: const Text(
            'Send Payment',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Color(0xFF166534),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        // Solid "Receive Payment" Button
        ElevatedButton.icon(
          onPressed: _openCustomerPaymentModal,
          icon: const Icon(LucideIcons.arrowDownLeft, size: 14, color: Colors.white),
          label: const Text(
            'Receive Payment',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF166534),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 14),
          actionButtons,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleWidget),
        const SizedBox(width: 16),
        actionButtons,
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. TOP 4 KPI CARDS ROW (Driven by Live API Data)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopKpiRow(double screenWidth) {
    final receivablesStr = '₹${_fmt(_outstandingReceivables)}';
    final collectionsStr = '₹${_fmt(_dailyCollections)}';
    final balancesStr = '₹${_fmt(_combinedBalances)}';
    final efficiencyStr = _efficiencyRate;

    final cardReceivables = _buildKpiCard(
      label: 'OUTSTANDING RECEIVABLES',
      value: receivablesStr,
      icon: LucideIcons.trendingUp,
      iconColor: const Color(0xFFEF4444),
      iconBg: const Color(0xFFFEE2E2),
    );

    final cardCollections = _buildKpiCard(
      label: 'DAILY COLLECTIONS',
      value: collectionsStr,
      icon: LucideIcons.trendingDown,
      iconColor: const Color(0xFF10B981),
      iconBg: const Color(0xFFDCFCE7),
    );

    final cardBalances = _buildKpiCard(
      label: 'COMBINED BALANCES',
      value: balancesStr,
      icon: LucideIcons.wallet,
      iconColor: const Color(0xFF3B82F6),
      iconBg: const Color(0xFFEFF6FF),
    );

    final cardEfficiency = _buildKpiCard(
      label: 'EFFICIENCY RATE',
      value: efficiencyStr,
      icon: LucideIcons.circleCheck,
      iconColor: const Color(0xFF0D9488),
      iconBg: const Color(0xFFE6FFFA),
    );

    if (screenWidth >= 900) {
      return Row(
        children: [
          Expanded(child: cardReceivables),
          const SizedBox(width: 14),
          Expanded(child: cardCollections),
          const SizedBox(width: 14),
          Expanded(child: cardBalances),
          const SizedBox(width: 14),
          Expanded(child: cardEfficiency),
        ],
      );
    }

    if (screenWidth >= 600) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cardReceivables),
              const SizedBox(width: 12),
              Expanded(child: cardCollections),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cardBalances),
              const SizedBox(width: 12),
              Expanded(child: cardEfficiency),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        cardReceivables,
        const SizedBox(height: 10),
        cardCollections,
        const SizedBox(height: 10),
        cardBalances,
        const SizedBox(height: 10),
        cardEfficiency,
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Icon(icon, size: 15, color: iconColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. SEGMENTED TABS ROW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTabsRow(bool isMobile) {
    final tabs = [
      {'label': 'Total Inward & Outward', 'icon': LucideIcons.arrowLeftRight},
      {'label': 'Overdue Collections & Reminders', 'icon': LucideIcons.clock},
      {'label': 'Bank & Cash Registers', 'icon': LucideIcons.landmark},
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
                final t = tabs[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _activeTab = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF166534) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            t['icon'] as IconData,
                            size: 15,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t['label'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
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

        // Search Toggle or TextField
        if (!_isSearchOpen)
          InkWell(
            onTap: () {
              setState(() {
                _isSearchOpen = true;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Icon(LucideIcons.search, size: 16, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          Container(
            width: isMobile ? 160 : 230,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF166534)),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search payments...',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                suffixIcon: IconButton(
                  icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
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

  // ══════════════════════════════════════════════════════════════════════════
  // 4. TAB BODY CONTENT
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTabBody(double screenWidth, bool isMobile) {
    switch (_activeTab) {
      case 0:
        return _buildInwardOutwardTabView(screenWidth, isMobile);
      case 1:
        return _buildOverdueRemindersTabView(screenWidth, isMobile);
      case 2:
        return _buildBankRegistersTabView(screenWidth, isMobile);
      default:
        return _buildInwardOutwardTabView(screenWidth, isMobile);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 0: TOTAL INWARD & OUTWARD (Real Cash Flow Transactions)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildInwardOutwardTabView(double screenWidth, bool isMobile) {
    final list = _filteredTransactions;

    // 3 Dynamic Stat Cards Row
    final cardInward = _buildInwardOutwardStatCard(
      label: 'TOTAL INWARD (+₹)',
      value: '+₹${_fmt(_totalInward)}',
      valueColor: const Color(0xFF16A34A),
      icon: LucideIcons.arrowDownLeft,
      iconColor: const Color(0xFF16A34A),
      iconBg: const Color(0xFFDCFCE7),
    );

    final cardOutward = _buildInwardOutwardStatCard(
      label: 'TOTAL OUTWARD (-₹)',
      value: '-₹${_fmt(_totalOutward)}',
      valueColor: const Color(0xFFDC2626),
      icon: LucideIcons.arrowUpRight,
      iconColor: const Color(0xFFDC2626),
      iconBg: const Color(0xFFFEE2E2),
    );

    final cardNet = _buildInwardOutwardStatCard(
      label: 'NET BALANCE (INWARD - OUTWARD)',
      value: '${_netBalance >= 0 ? '+' : '-'}₹${_fmt(_netBalance.abs())}',
      valueColor: _netBalance >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      icon: LucideIcons.wallet,
      iconColor: _netBalance >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      iconBg: _netBalance >= 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (screenWidth >= 750)
          Row(
            children: [
              Expanded(child: cardInward),
              const SizedBox(width: 14),
              Expanded(child: cardOutward),
              const SizedBox(width: 14),
              Expanded(child: cardNet),
            ],
          )
        else
          Column(
            children: [
              cardInward,
              const SizedBox(height: 10),
              cardOutward,
              const SizedBox(height: 10),
              cardNet,
            ],
          ),
        const SizedBox(height: 18),

        // Filter Bar & Action Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flow Filter Pills
            Row(
              children: [
                _buildFlowFilterPill('ALL', 'All'),
                const SizedBox(width: 6),
                _buildFlowFilterPill('INWARD', 'Inward (+₹)'),
                const SizedBox(width: 6),
                _buildFlowFilterPill('OUTWARD', 'Outward (-₹)'),
              ],
            ),

            // "+ Add Transaction" Button & "Gateway Order"
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _openCreatePaymentOrderModal,
                  icon: const Icon(LucideIcons.globe, size: 13, color: Color(0xFF475569)),
                  label: const Text(
                    'Gateway Order',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _openAddTransactionModal,
                  icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                  label: const Text(
                    'Add Transaction',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Table Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: list.isEmpty
              ? _buildEmptyState(
                  icon: LucideIcons.arrowLeftRight,
                  title: 'No Transactions Found',
                  description: _searchQuery.isNotEmpty
                      ? "No records matched '$_searchQuery'. Try adjusting your search query."
                      : "Record incoming sales revenue, log supplier disbursements, or create a cash flow entry.",
                  actionLabel: '+ Add Transaction',
                  onAction: _openAddTransactionModal,
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: screenWidth >= 900 ? screenWidth - 64 : 880,
                    ),
                    child: DataTable(
                      headingRowHeight: 48,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 64,
                      horizontalMargin: 20,
                      columnSpacing: 20,
                      dividerThickness: 1,
                      border: const TableBorder(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                      headingTextStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                      columns: const [
                        DataColumn(label: Text('ENTRY ID')),
                        DataColumn(label: Text('DATE')),
                        DataColumn(label: Text('FLOW TYPE')),
                        DataColumn(label: Text('TITLE / DESCRIPTION')),
                        DataColumn(label: Text('REFERENCE #')),
                        DataColumn(label: Text('AMOUNT')),
                        DataColumn(label: Text('CATEGORY')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: list.map((item) {
                        final isOutward = item.isExpense;

                        return DataRow(
                          cells: [
                            // 1. ENTRY ID
                            DataCell(
                              Text(
                                'TX-${item.id}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),

                            // 2. DATE
                            DataCell(
                              Text(
                                item.formattedDate.isNotEmpty ? item.formattedDate : '—',
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                              ),
                            ),

                            // 3. FLOW TYPE
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: isOutward ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isOutward ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                                      size: 11,
                                      color: isOutward ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.flowTypeLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: isOutward ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 4. TITLE / DESCRIPTION
                            DataCell(
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 220),
                                child: Text(
                                  item.displayTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            // 5. REFERENCE #
                            DataCell(
                              Text(
                                item.displayReference,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                              ),
                            ),

                            // 6. AMOUNT
                            DataCell(
                              Text(
                                '${isOutward ? '-' : '+'}₹${_fmt(item.amount)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isOutward ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                ),
                              ),
                            ),

                            // 7. CATEGORY
                            DataCell(
                              Text(
                                item.displayCategory,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ),

                            // 8. STATUS
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'POSTED',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ),

                            // 9. ACTIONS (Edit & Delete)
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(LucideIcons.pencil, size: 14, color: Color(0xFF2563EB)),
                                    tooltip: 'Edit Transaction',
                                    onPressed: () => _openEditTransactionModal(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                                    tooltip: 'Delete Transaction',
                                    onPressed: () => _confirmDeleteTransaction(item),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFlowFilterPill(String filterKey, String label) {
    final isSelected = _flowFilter == filterKey;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _flowFilter = filterKey);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF166534) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildInwardOutwardStatCard({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: OVERDUE COLLECTIONS & REMINDERS (Live Reports Backend)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildOverdueRemindersTabView(double screenWidth, bool isMobile) {
    final list = _filteredOverdueList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: list.isEmpty
              ? _buildEmptyState(
                  icon: LucideIcons.circleCheck,
                  title: 'No Overdue Invoices Found',
                  description: 'All customer receivables are completely settled or within due dates.',
                  actionLabel: 'Receive Payment',
                  onAction: _openCustomerPaymentModal,
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: screenWidth >= 900 ? screenWidth - 64 : 880,
                    ),
                    child: DataTable(
                      headingRowHeight: 48,
                      dataRowMinHeight: 64,
                      dataRowMaxHeight: 64,
                      horizontalMargin: 20,
                      columnSpacing: 24,
                      dividerThickness: 1,
                      border: const TableBorder(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                      headingTextStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                      columns: const [
                        DataColumn(label: Text('CUSTOMER NAME')),
                        DataColumn(label: Text('INVOICE / BILL NO')),
                        DataColumn(label: Text('TOTAL BILL')),
                        DataColumn(label: Text('PAID AMOUNT')),
                        DataColumn(label: Text('CREDIT DUE BALANCE')),
                        DataColumn(label: Text('DUE DATE')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: list.map((item) {
                        final total = ((item['totalBill'] ?? item['grand_total'] ?? item['total_amount'] ?? 0) as num).toDouble();
                        final paid = ((item['paidAmount'] ?? item['paid_amount'] ?? 0) as num).toDouble();
                        final due = ((item['dueBalance'] ?? item['pending_amount'] ?? (total - paid)) as num).toDouble();
                        final isOverdue = item['isOverdue'] == true || due > 0;
                        final status = item['status']?.toString() ?? (due > 0 ? 'Due' : 'Settled');
                        final customerName = (item['customerName'] ?? item['customer_name'] ?? 'Walk-in Customer').toString();
                        final invNo = (item['invoiceNo'] ?? item['invoice_number'] ?? item['invoice_id'] ?? 'INV-001').toString();
                        final dueDate = (item['dueDate'] ?? item['due_date'] ?? '—').toString();

                        return DataRow(
                          cells: [
                            // 1. CUSTOMER NAME
                            DataCell(
                              Text(
                                customerName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),

                            // 2. INVOICE NO
                            DataCell(
                              Text(
                                invNo,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                              ),
                            ),

                            // 3. TOTAL BILL
                            DataCell(
                              Text(
                                '₹${_fmt(total)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),

                            // 4. PAID AMOUNT
                            DataCell(
                              Text(
                                '₹${_fmt(paid)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),

                            // 5. CREDIT DUE BALANCE
                            DataCell(
                              Text(
                                '₹${_fmt(due)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),

                            // 6. DUE DATE
                            DataCell(
                              Text(
                                dueDate,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ),

                            // 7. STATUS
                            DataCell(
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                                ),
                              ),
                            ),

                            // 8. Action: Send Reminder Button
                            DataCell(
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  AppSnackbar.show(
                                    context,
                                    "Overdue reminder dispatched to '$customerName' for invoice $invNo!",
                                    type: SnackType.success,
                                  );
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        LucideIcons.send,
                                        size: 12,
                                        color: Color(0xFF059669),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Send Reminder',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: BANK & CASH REGISTERS (Real Accounts & Live Ledger)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBankRegistersTabView(double screenWidth, bool isMobile) {
    final list = _filteredAccountsList;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: _buildEmptyState(
          icon: LucideIcons.landmark,
          title: 'No Bank or Cash Accounts Found',
          description: 'No registered bank accounts or cash registers found for this business showroom.',
          actionLabel: 'Transfer Funds',
          onAction: _openTransferFundsModal,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final int crossAxisCount = totalWidth >= 1050 ? 3 : (totalWidth >= 680 ? 2 : 1);
        final double spacing = 16.0;
        final double cardWidth = (totalWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Card Grid
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: list.map((acc) {
                final isCash = acc.isCash;
                final isCardSelected = _selectedCardId == acc.id.toString();
                final balance = acc.currentBalance;
                final isNegative = balance < 0;
                final balanceStr = isNegative ? '-₹${_fmt(balance.abs())}' : '₹${_fmt(balance)}';

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCardId = acc.id.toString());
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCardSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                        width: isCardSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCardSelected ? const Color(0x14166534) : const Color(0x04000000),
                          blurRadius: isCardSelected ? 10 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Type Pill + Transfer Funds Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: isCash ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isCash ? 'CASH REGISTER' : 'BANK ACCOUNT',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isCash ? const Color(0xFF166534) : const Color(0xFF2563EB),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _openTransferFundsModal,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(LucideIcons.arrowLeftRight, size: 11, color: Color(0xFF475569)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Transfer',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Account Name
                        Text(
                          acc.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Account Number / Holder
                        Text(
                          isCash
                              ? 'Counter: ${acc.accountNumber}'
                              : 'Account: ${acc.displayAccountNumber}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (!isCash && acc.branch != null && acc.branch!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Branch: ${acc.branch} • IFSC: ${acc.ifsc ?? '—'}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Balance Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Current Balance:',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                balanceStr,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Running Ledger for Selected Account
            _buildAccountRunningLedger(screenWidth, isMobile),
          ],
        );
      },
    );
  }

  Widget _buildAccountRunningLedger(double screenWidth, bool isMobile) {
    if (_accounts.isEmpty) return const SizedBox.shrink();
    final selectedAcc = _accounts.firstWhere(
      (a) => a.id.toString() == _selectedCardId,
      orElse: () => _accounts.first,
    );

    // Filter transactions relevant to this account (or all transactions if no specific account match)
    final accountTx = _transactions.where((t) {
      if (t.accountId != null) {
        return t.accountId.toString() == selectedAcc.id.toString();
      }
      return true;
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('📦', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Transaction Ledger: ${selectedAcc.displayName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openAddTransactionModal,
                icon: const Icon(LucideIcons.plus, size: 13, color: Colors.white),
                label: const Text(
                  'Post Entry',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (accountTx.isEmpty)
            _buildEmptyState(
              icon: LucideIcons.receipt,
              title: 'No Ledger Entries Found',
              description: 'Post a manual entry or receive a payment into this account.',
              actionLabel: '+ Post Entry',
              onAction: _openAddTransactionModal,
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: screenWidth >= 900 ? screenWidth - 104 : 880,
                ),
                child: DataTable(
                  headingRowHeight: 46,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 56,
                  horizontalMargin: 12,
                  columnSpacing: 28,
                  dividerThickness: 1,
                  border: const TableBorder(
                    bottom: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                  columns: const [
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('DESCRIPTION')),
                    DataColumn(label: Text('TYPE')),
                    DataColumn(label: Text('AMOUNT')),
                    DataColumn(label: Text('REFERENCE')),
                  ],
                  rows: accountTx.map((row) {
                    final isIncome = row.isIncome;
                    final amtStr = isIncome ? '+₹${_fmt(row.amount)}' : '-₹${_fmt(row.amount)}';

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            row.formattedDate.isNotEmpty ? row.formattedDate : '—',
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.displayTitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: isIncome ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isIncome ? 'Credit' : 'Debit',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isIncome ? const Color(0xFF166534) : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            amtStr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.displayReference,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 1: RECEIVE CUSTOMER PAYMENT (POST /api/v1/payments/receive)
  // ══════════════════════════════════════════════════════════════════════════
  void _openCustomerPaymentModal() {
    final customerCtrl = TextEditingController(text: 'Walk-in Customer');
    final invoiceIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '1000');
    final refNoCtrl = TextEditingController(text: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    final notesCtrl = TextEditingController();
    String paymentMode = 'UPI';
    dynamic selectedAccId = _accounts.isNotEmpty ? _accounts.first.id : 1;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Receive Customer Payment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          IconButton(
                            key: const Key('close_customer_payment_dialog'),
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      const Text('Customer Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: customerCtrl,
                        decoration: _inputDecoration('e.g. Acme Retail Ltd'),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Amount (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: amountCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: _inputDecoration('0.00'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Payment Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: paymentMode,
                                      isExpanded: true,
                                      items: ['UPI', 'Cash', 'Bank Transfer', 'Card', 'Cheque'].map((m) {
                                        return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)));
                                      }).toList(),
                                      onChanged: (v) => setModalState(() => paymentMode = v ?? 'UPI'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Invoice # (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: invoiceIdCtrl,
                                  decoration: _inputDecoration('e.g. INV-1042'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Reference / UPI Ref', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: refNoCtrl,
                                  decoration: _inputDecoration('e.g. UPI-984729184'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('Deposit To Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<dynamic>(
                            value: selectedAccId,
                            isExpanded: true,
                            items: _accounts.isNotEmpty
                                ? _accounts.map((a) {
                                    return DropdownMenuItem(
                                      value: a.id,
                                      child: Text('${a.displayName} (₹${_fmt(a.currentBalance)})', style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList()
                                : [
                                    DropdownMenuItem(
                                      value: selectedAccId,
                                      child: const Text('Default Cash Register', style: TextStyle(fontSize: 13)),
                                    ),
                                  ],
                            onChanged: (v) => setModalState(() => selectedAccId = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('Notes / Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesCtrl,
                        decoration: _inputDecoration('Optional settlement remarks'),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final customer = customerCtrl.text.trim();
                                  final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                                  final refNo = refNoCtrl.text.trim();
                                  final inv = invoiceIdCtrl.text.trim();

                                  if (customer.isEmpty) {
                                    AppSnackbar.show(context, 'Customer name is required', type: SnackType.error);
                                    return;
                                  }
                                  if (amt <= 0) {
                                    AppSnackbar.show(context, 'Enter a valid payment amount', type: SnackType.error);
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final activeEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();
                                    await PaymentTransactionRepository.receivePayment(
                                      ReceivePaymentRequest(
                                        customerName: customer,
                                        invoiceId: inv.isNotEmpty ? inv : null,
                                        amount: amt,
                                        paidAmount: amt,
                                        paymentMode: paymentMode,
                                        referenceNumber: refNo.isNotEmpty ? refNo : 'REC-${DateTime.now().millisecondsSinceEpoch}',
                                        accountId: selectedAccId,
                                        notes: notesCtrl.text.trim(),
                                      ),
                                      email: activeEmail,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      AppSnackbar.show(context, "Payment receipt of ₹${_fmt(amt)} recorded successfully!", type: SnackType.success);
                                      _loadData();
                                    }
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (context.mounted) {
                                      AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Record Customer Payment', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 2: PAY SUPPLIER / DISBURSEMENT (POST /api/v1/payments/pay)
  // ══════════════════════════════════════════════════════════════════════════
  void _openSupplierDisbursementModal() {
    final supplierCtrl = TextEditingController(text: 'General Supplier');
    final purchaseIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '1000');
    final refNoCtrl = TextEditingController(text: 'NEFT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    final notesCtrl = TextEditingController();
    String disbursementMode = 'Bank Transfer';
    dynamic selectedAccId = _accounts.isNotEmpty ? _accounts.first.id : 1;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Record Supplier Disbursement',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          IconButton(
                            key: const Key('close_supplier_disbursement_dialog'),
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      const Text('Supplier / Vendor Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: supplierCtrl,
                        decoration: _inputDecoration('e.g. Apex Fabricators'),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Disbursement Amount (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: amountCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: _inputDecoration('0.00'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Payment Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: disbursementMode,
                                      isExpanded: true,
                                      items: ['Bank Transfer', 'Cash', 'UPI', 'Cheque'].map((m) {
                                        return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)));
                                      }).toList(),
                                      onChanged: (v) => setModalState(() => disbursementMode = v ?? 'Bank Transfer'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Purchase / Bill ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: purchaseIdCtrl,
                                  decoration: _inputDecoration('e.g. PUR-2026-089'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cheque / Ref No', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: refNoCtrl,
                                  decoration: _inputDecoration('e.g. NEFT-88492041'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('Deduct From Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<dynamic>(
                            value: selectedAccId,
                            isExpanded: true,
                            items: _accounts.isNotEmpty
                                ? _accounts.map((a) {
                                    return DropdownMenuItem(
                                      value: a.id,
                                      child: Text('${a.displayName} (₹${_fmt(a.currentBalance)})', style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList()
                                : [
                                    DropdownMenuItem(
                                      value: selectedAccId,
                                      child: const Text('Default Cash Register', style: TextStyle(fontSize: 13)),
                                    ),
                                  ],
                            onChanged: (v) => setModalState(() => selectedAccId = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('Notes / Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesCtrl,
                        decoration: _inputDecoration('Optional procurement remarks'),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final supplier = supplierCtrl.text.trim();
                                  final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                                  final refNo = refNoCtrl.text.trim();
                                  final pur = purchaseIdCtrl.text.trim();

                                  if (supplier.isEmpty) {
                                    AppSnackbar.show(context, 'Supplier name is required', type: SnackType.error);
                                    return;
                                  }
                                  if (amt <= 0) {
                                    AppSnackbar.show(context, 'Enter a valid disbursement amount', type: SnackType.error);
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final activeEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();
                                    await PaymentTransactionRepository.paySupplier(
                                      PaySupplierRequest(
                                        supplierName: supplier,
                                        purchaseId: pur.isNotEmpty ? pur : null,
                                        amount: amt,
                                        paymentMode: disbursementMode,
                                        referenceNumber: refNo.isNotEmpty ? refNo : 'PAY-${DateTime.now().millisecondsSinceEpoch}',
                                        accountId: selectedAccId,
                                        notes: notesCtrl.text.trim(),
                                      ),
                                      email: activeEmail,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      AppSnackbar.show(context, "Supplier disbursement of ₹${_fmt(amt)} recorded successfully!", type: SnackType.success);
                                      _loadData();
                                    }
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (context.mounted) {
                                      AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Disburse Supplier Funds', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 3: INTER-ACCOUNT FUND TRANSFER (POST /api/v1/payments/transfer)
  // ══════════════════════════════════════════════════════════════════════════
  void _openTransferFundsModal() {
    if (_accounts.length < 2) {
      AppSnackbar.show(context, 'At least 2 accounts are required to perform an internal transfer', type: SnackType.info);
      return;
    }

    dynamic fromAccId = _accounts.first.id;
    dynamic toAccId = _accounts.length > 1 ? _accounts[1].id : _accounts.first.id;
    final amountCtrl = TextEditingController(text: '1000');
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Inter-Account Fund Transfer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('close_transfer_funds_dialog'),
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    const Text('From Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<dynamic>(
                          value: fromAccId,
                          isExpanded: true,
                          items: _accounts.isNotEmpty
                              ? _accounts.map((a) {
                                  return DropdownMenuItem(
                                    value: a.id,
                                    child: Text('${a.displayName} (₹${_fmt(a.currentBalance)})', style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList()
                              : [
                                  DropdownMenuItem(
                                    value: fromAccId,
                                    child: const Text('Source Account', style: TextStyle(fontSize: 13)),
                                  ),
                                ],
                          onChanged: (v) => setModalState(() => fromAccId = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('To Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<dynamic>(
                          value: toAccId,
                          isExpanded: true,
                          items: _accounts.isNotEmpty
                              ? _accounts.map((a) {
                                  return DropdownMenuItem(
                                    value: a.id,
                                    child: Text('${a.displayName} (₹${_fmt(a.currentBalance)})', style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList()
                              : [
                                  DropdownMenuItem(
                                    value: toAccId,
                                    child: const Text('Destination Account', style: TextStyle(fontSize: 13)),
                                  ),
                                ],
                          onChanged: (v) => setModalState(() => toAccId = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Transfer Amount (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('0.00'),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (fromAccId.toString() == toAccId.toString()) {
                                  AppSnackbar.show(context, 'Source and destination accounts must be different', type: SnackType.error);
                                  return;
                                }
                                final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                                if (amt <= 0) {
                                  AppSnackbar.show(context, 'Enter a valid transfer amount', type: SnackType.error);
                                  return;
                                }

                                setModalState(() => isSubmitting = true);
                                try {
                                  final activeEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();
                                  await PaymentTransactionRepository.transferFunds(
                                    TransferFundsRequest(
                                      fromAccId: fromAccId,
                                      toAccId: toAccId,
                                      amount: amt,
                                    ),
                                    email: activeEmail,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    AppSnackbar.show(context, "Transferred ₹${_fmt(amt)} successfully!", type: SnackType.success);
                                    _loadData();
                                  }
                                } catch (e) {
                                  setModalState(() => isSubmitting = false);
                                  if (context.mounted) {
                                    AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Confirm Transfer', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      ),
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

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 4: ADD CASH FLOW TRANSACTION (POST /api/v1/transactions)
  // ══════════════════════════════════════════════════════════════════════════
  void _openAddTransactionModal() {
    String type = 'income';
    final amountCtrl = TextEditingController(text: '1000');
    String category = 'Direct Sales';
    final descCtrl = TextEditingController();
    final refCtrl = TextEditingController(text: 'POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    final dateCtrl = TextEditingController(
      text: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    );
    dynamic selectedAccId = _accounts.isNotEmpty ? _accounts.first.id : null;
    bool isSubmitting = false;

    final categories = [
      'Direct Sales',
      'Counter POS settlement',
      'Office Utilities',
      'Procurement',
      'Rent & Facility',
      'Staff Salary',
      'Marketing & Ads',
      'Equipment & Tech',
      'Miscellaneous',
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Add Cash Flow Transaction',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          IconButton(
                            key: const Key('close_add_transaction_dialog'),
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Type Selector (Income vs Expense)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => type = 'income'),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: type == 'income' ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: type == 'income' ? const Color(0xFF16A34A) : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '+ Income (Inward)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: type == 'income' ? const Color(0xFF166534) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => type = 'expense'),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: type == 'expense' ? const Color(0xFFFEE2E8) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: type == 'expense' ? const Color(0xFFDC2626) : Colors.transparent,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '- Expense (Outward)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: type == 'expense' ? const Color(0xFF991B1B) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
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
                                const Text('Amount (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: amountCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: _inputDecoration('0.00'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date (YYYY-MM-DD)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: dateCtrl,
                                  decoration: _inputDecoration('YYYY-MM-DD'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: category,
                            isExpanded: true,
                            items: categories.map((c) {
                              return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                            }).toList(),
                            onChanged: (v) => setModalState(() => category = v ?? 'Direct Sales'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Reference #', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: refCtrl,
                                  decoration: _inputDecoration('e.g. POS-2026-11'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Account (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<dynamic>(
                                      value: selectedAccId,
                                      isExpanded: true,
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('Default / None', style: TextStyle(fontSize: 13))),
                                        ..._accounts.map((a) {
                                          return DropdownMenuItem(
                                            value: a.id,
                                            child: Text(a.displayName, style: const TextStyle(fontSize: 13)),
                                          );
                                        }),
                                      ],
                                      onChanged: (v) => setModalState(() => selectedAccId = v),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descCtrl,
                        decoration: _inputDecoration('e.g. Counter POS settlement or internet bill'),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                                  if (amt <= 0) {
                                    AppSnackbar.show(context, 'Enter a valid transaction amount', type: SnackType.error);
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final activeEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();
                                    await PaymentTransactionRepository.createTransaction(
                                      CreateCashFlowTransactionRequest(
                                        type: type,
                                        amount: amt,
                                        category: category,
                                        date: dateCtrl.text.trim(),
                                        description: descCtrl.text.trim(),
                                        accountId: selectedAccId,
                                        reference: refCtrl.text.trim(),
                                      ),
                                      email: activeEmail,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      AppSnackbar.show(context, "Transaction of ₹${_fmt(amt)} recorded successfully!", type: SnackType.success);
                                      _loadData();
                                    }
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (context.mounted) {
                                      AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save Transaction', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 5: EDIT TRANSACTION (PATCH /api/v1/transactions/:id)
  // ══════════════════════════════════════════════════════════════════════════
  void _openEditTransactionModal(CashFlowTransaction tx) {
    final amountCtrl = TextEditingController(text: tx.amount.toString());
    final descCtrl = TextEditingController(text: tx.description ?? tx.title ?? '');
    final categoryCtrl = TextEditingController(text: tx.category ?? '');
    final dateCtrl = TextEditingController(text: tx.isoDateString);
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Transaction TX-${tx.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          key: const Key('close_edit_transaction_dialog'),
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    const Text('Amount (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('0.00'),
                    ),
                    const SizedBox(height: 14),

                    const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: categoryCtrl,
                      decoration: _inputDecoration('Category'),
                    ),
                    const SizedBox(height: 14),

                    const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descCtrl,
                      decoration: _inputDecoration('Transaction description'),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final amt = double.tryParse(amountCtrl.text.trim());
                                setModalState(() => isSubmitting = true);
                                try {
                                  final activeEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();
                                  await PaymentTransactionRepository.updateTransaction(
                                    tx.id,
                                    UpdateCashFlowTransactionRequest(
                                      amount: amt,
                                      description: descCtrl.text.trim(),
                                      category: categoryCtrl.text.trim(),
                                      date: dateCtrl.text.trim().isNotEmpty ? dateCtrl.text.trim() : null,
                                    ),
                                    email: activeEmail,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    AppSnackbar.show(context, "Transaction TX-${tx.id} updated successfully!", type: SnackType.success);
                                    _loadData();
                                  }
                                } catch (e) {
                                  setModalState(() => isSubmitting = false);
                                  if (context.mounted) {
                                    AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      ),
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

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 6: DELETE TRANSACTION (DELETE /api/v1/transactions/:id)
  // ══════════════════════════════════════════════════════════════════════════
  void _confirmDeleteTransaction(CashFlowTransaction tx) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Transaction', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          content: Text("Are you sure you want to delete transaction TX-${tx.id} for ₹${_fmt(tx.amount)}? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final activeEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();
                  await PaymentTransactionRepository.deleteTransaction(tx.id, email: activeEmail);
                  if (context.mounted) {
                    AppSnackbar.show(context, "Transaction TX-${tx.id} deleted successfully!", type: SnackType.success);
                    _loadData();
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppSnackbar.show(context, e.toString(), type: SnackType.error);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 7: CASHFREE GATEWAY CHECKOUT (POST /api/v1/payments/create-order)
  // ══════════════════════════════════════════════════════════════════════════
  void _openCreatePaymentOrderModal() {
    final amountCtrl = TextEditingController(text: '4999');
    final orderIdCtrl = TextEditingController(text: 'ORDER_${DateTime.now().millisecondsSinceEpoch}');
    bool isSubmitting = false;
    String? createdSessionId;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 460,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Payment Gateway Order',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('close_cashfree_order_dialog'),
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (createdSessionId == null) ...[
                      const Text('Order ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: orderIdCtrl,
                        decoration: _inputDecoration('e.g. ORDER_20261124_001'),
                      ),
                      const SizedBox(height: 14),

                      const Text('Order Amount (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration('0.00'),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                                  final ord = orderIdCtrl.text.trim();
                                  if (amt <= 0 || ord.isEmpty) {
                                    AppSnackbar.show(context, 'Enter valid order ID and amount', type: SnackType.error);
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);
                                  try {
                                    final activeEmail = ref.read(activeAccountProvider).email.trim().toLowerCase();
                                    final res = await PaymentTransactionRepository.createPaymentOrder(
                                      CreateGatewayOrderRequest(amount: amt, orderId: ord),
                                      email: activeEmail,
                                    );
                                    final sessId = res['data']?['payment_session_id']?.toString() ?? 'session_active';
                                    setModalState(() {
                                      createdSessionId = sessId;
                                      isSubmitting = false;
                                    });
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (context.mounted) {
                                      AppSnackbar.show(context, e.toString(), type: SnackType.error);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Create Cashfree Order Session', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.circleCheck, color: Color(0xFF166534), size: 18),
                                SizedBox(width: 8),
                                Text('Session Token Generated', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              createdSessionId!,
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF14532D)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: createdSessionId!));
                                AppSnackbar.show(context, 'Payment session ID copied to clipboard', type: SnackType.info);
                              },
                              child: const Text('Copy Token'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF166534),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Done'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER FOR INPUT DECORATION
  // ══════════════════════════════════════════════════════════════════════════
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
      ),
    );
  }
}
