import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/account_provider.dart';
import '../../../models/account_model.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/repositories/payments_repository.dart';
import '../../navigation/widgets/macos_showroom_menu_card.dart';
import '../../../widgets/app_ui_kit.dart';

/// Payments & Cash Flow Engine Page
/// Pixel-perfect matching of the Modern Payments & Cash Flow Engine UI
/// Supporting all operating systems (macOS, Windows, Linux, Web, Android, iOS).
class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  // 0: Total Inward & Outward, 1: Overdue Collections & Reminders, 2: Bank & Cash Registers
  int _activeTab = 0;

  PaymentReports? _reports;
  OutstandingStats? _outstandingStats;
  bool _isLoading = false;
  String? _errorMessage;

  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Track which account card menu is currently open or selected
  String _selectedCardId = 'acc_1';

  // ───────────────────────────────────────────────────────────────────────────
  // DEFAULT INWARD & OUTWARD DATASET (Matching Screenshots 1 & 4)
  // ───────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _inwardOutwardList = [
    {
      'entryId': 'REC-2026-inv-1138',
      'date': '2026-11-12',
      'flowType': 'INWARD',
      'isLent': true,
      'party': 'Walk-in Customer',
      'reference': 'DKSJCS-052957',
      'originalAmount': 71.0,
      'transactedAmount': 71.0,
      'mode': 'Cash',
      'status': 'MATCHED',
    },
    {
      'entryId': 'REC-128626',
      'date': '2026-11-11',
      'flowType': 'INWARD',
      'isLent': true,
      'party': 'ravinew',
      'reference': 'INV-128626',
      'originalAmount': 6700.0,
      'transactedAmount': 6700.0,
      'mode': 'Cash in Hand',
      'status': 'MATCHED',
    },
    {
      'entryId': 'REC-2026-inv-1128',
      'date': '2026-11-11',
      'flowType': 'INWARD',
      'isLent': true,
      'party': 'ravinew2004',
      'reference': 'DKSJCS-353226',
      'originalAmount': 212.0,
      'transactedAmount': 212.0,
      'mode': 'Cash',
      'status': 'MATCHED',
    },
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // DEFAULT OVERDUE ACCOUNTS REMINDERS DATASET (Matching Screenshot 5 & Image 1)
  // ───────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _overdueList = [
    {
      'customerName': 'revinew2004',
      'invoiceNo': 'INV-162912',
      'totalBill': 7000.0,
      'paidAmount': 0.0,
      'dueBalance': 7000.0,
      'dueDate': '2026-12-11',
      'status': 'Credit Due',
      'isOverdue': false,
    },
    {
      'customerName': 'ramani',
      'invoiceNo': 'MS--005949',
      'totalBill': 7074.0,
      'paidAmount': 1000.0,
      'dueBalance': 6074.0,
      'dueDate': '2026-11-06',
      'status': '12 Days Overdue',
      'isOverdue': true,
    },
    {
      'customerName': 'Walk-in Customer',
      'invoiceNo': 'MS--037600',
      'totalBill': 94400.0,
      'paidAmount': 0.0,
      'dueBalance': 94400.0,
      'dueDate': '2026-11-06',
      'status': '12 Days Overdue',
      'isOverdue': true,
    },
    {
      'customerName': 'santhoshhhhhhh',
      'invoiceNo': 'INV-CN-9933',
      'totalBill': 10620.0,
      'paidAmount': 0.0,
      'dueBalance': 10620.0,
      'dueDate': '2026-09-27',
      'status': '52 Days Overdue',
      'isOverdue': true,
    },
    {
      'customerName': 'santhoshhhhhhh',
      'invoiceNo': 'INV-PO-1541',
      'totalBill': 169920.0,
      'paidAmount': 0.0,
      'dueBalance': 169920.0,
      'dueDate': '2026-09-26',
      'status': '53 Days Overdue',
      'isOverdue': true,
    },
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // DEFAULT CONNECTED FINANCIAL ACCOUNTS & CASH DRAWERS (Matching Screenshot 2 & 3)
  // ───────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _accountsList = [
    {
      'id': 'acc_1',
      'name': 'Cash Register (Cash in Hand)',
      'type': 'Cash Register (Cash in Hand)',
      'accountType': 'Cash',
      'accountNumber': 'CASH-REG-01',
      'bank': '',
      'branch': '',
      'ifsc': '',
      'balance': 0.0,
      'isCash': true,
      'status': 'Active',
    },
    {
      'id': 'acc_2',
      'name': 'djwfnwjnfjwnkjs',
      'type': 'Bank Account',
      'accountType': 'Bank Account',
      'accountNumber': '549494887',
      'bank': 'karnataka bank',
      'branch': 'Main Showroom',
      'ifsc': 'KARjk dkdfdsc',
      'balance': 700506000.0,
      'isCash': false,
      'status': 'Active',
    },
    {
      'id': 'acc_3',
      'name': 'uybwaued',
      'type': 'Bank Account',
      'accountType': 'Bank Account',
      'accountNumber': 'wagvghsvchgsdchgvsdhcgvshgdc',
      'bank': 'Ravi',
      'branch': 'Main Showroom',
      'ifsc': 'Idkmclkmekcx',
      'balance': -123451790.0,
      'isCash': false,
      'status': 'Active',
    },
    {
      'id': 'acc_4',
      'name': 'Ravi kumar',
      'type': 'Bank Account',
      'accountType': 'Bank Account',
      'accountNumber': '98938473984394872',
      'bank': 'karnataka bank',
      'branch': 'tiruvvallur',
      'ifsc': 'HDFC0000001',
      'balance': 740000.0,
      'isCash': false,
      'status': 'Active',
    },
    {
      'id': 'acc_5',
      'name': 'icic',
      'type': 'Bank Account',
      'accountType': 'Bank Account',
      'accountNumber': '44865892476',
      'bank': 'icic',
      'branch': 'east',
      'ifsc': 'HDFC0000001',
      'balance': 500.0,
      'isCash': false,
      'status': 'Active',
    },
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // TRANSACTION LEDGER ENTRIES (Matching Screenshot 1 & 2)
  // ───────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _ledgerEntries = [
    {
      'date': '12/11/2026',
      'description': 'Receipt from ramani (Invoice: MS--005949)',
      'type': 'Credit',
      'amount': 2000.0,
      'balanceAfter': '₹9,99,20,56,111',
    },
    {
      'date': '12/11/2026',
      'description': 'Receipt from ramani (Invoice: MS--005949)',
      'type': 'Credit',
      'amount': 6074.0,
      'balanceAfter': '₹9,99,20,54,111',
    },
    {
      'date': '12/11/2026',
      'description': 'Receipt from ramani (Invoice: MS--005949)',
      'type': 'Credit',
      'amount': 7074.0,
      'balanceAfter': '₹9,99,20,48,037',
    },
    {
      'date': '12/11/2026',
      'description': 'Receipt from santhoshhhhhhh (Invoice: INV-CN-9933)',
      'type': 'Credit',
      'amount': 10620.0,
      'balanceAfter': '₹9,99,20,40,963',
    },
    {
      'date': '12/11/2026',
      'description': 'Staff claim reimbursement: ravi kumar - sample poscket description',
      'type': 'Debit',
      'amount': -5000.0,
      'balanceAfter': '₹9,99,20,30,343',
    },
    {
      'date': '12/11/2026',
      'description': 'Travel & Meals',
      'type': 'Debit',
      'amount': -5000.0,
      'balanceAfter': '₹9,99,20,35,343',
    },
    {
      'date': '12/11/2026',
      'description': 'notes office',
      'type': 'Credit',
      'amount': 60000.0,
      'balanceAfter': '₹9,99,20,40,343',
    },
    {
      'date': '12/11/2026',
      'description': 'dwuch',
      'type': 'Debit',
      'amount': -700000000.0,
      'balanceAfter': '₹9,99,20,19,80,343',
    },
    {
      'date': '12/11/2026',
      'description': 'inv ref 83',
      'type': 'Debit',
      'amount': -61.0,
      'balanceAfter': '₹9,99,90,19,80,343',
    },
    {
      'date': '12/11/2026',
      'description': 'notes',
      'type': 'Debit',
      'amount': -6000.0,
      'balanceAfter': '₹9,99,90,19,80,404',
    },
    {
      'date': '21/08/2026',
      'description': '46465',
      'type': 'Credit',
      'amount': 10000000000.0,
      'balanceAfter': '₹9,99,90,19,86,404',
    },
    {
      'date': '21/08/2026',
      'description': 'Purchase #PO-6193',
      'type': 'Debit',
      'amount': -10000.0,
      'balanceAfter': '₹-9,80,13,596',
    },
    {
      'date': '20/08/2026',
      'description': 'Sales Revenue',
      'type': 'Credit',
      'amount': 25000.0,
      'balanceAfter': '₹-9,80,03,596',
    },
    {
      'date': '14/08/2026',
      'description': 'Sales Revenue',
      'type': 'Credit',
      'amount': 200000.0,
      'balanceAfter': '₹-9,80,28,596',
    },
    {
      'date': '14/08/2026',
      'description': 'Expense #EXP-2026-042',
      'type': 'Debit',
      'amount': -5200.0,
      'balanceAfter': '₹-9,82,28,596',
    },
    {
      'date': '13/08/2026',
      'description': 'Purchase #PO-1928',
      'type': 'Debit',
      'amount': -10000.0,
      'balanceAfter': '₹-9,82,23,396',
    },
    {
      'date': '08/08/2026',
      'description': 'qedceqr',
      'type': 'Debit',
      'amount': -98498496.0,
      'balanceAfter': '₹-9,82,13,396',
    },
    {
      'date': '08/08/2026',
      'description': 'office expense',
      'type': 'Credit',
      'amount': 5000.0,
      'balanceAfter': '₹2,85,100',
    },
  ];

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

  // ── Indian Currency Formatting Helper ──────────────────────────────────────
  String _fmt(num value) {
    if (value == 0) return '0';
    final isNegative = value < 0;
    final absVal = value.abs().round();
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

  // Filtered Inward & Outward Transactions
  List<Map<String, dynamic>> get _filteredInwardOutward {
    final list = List<Map<String, dynamic>>.from(_inwardOutwardList);

    if (_reports != null) {
      for (final rec in _reports!.receivables) {
        if (!list.any((item) => item['reference'] == rec.displayReference || item['party'] == rec.partyName)) {
          list.add({
            'entryId': rec.id.toString().startsWith('REC') ? rec.id.toString() : 'REC-${rec.id}',
            'date': rec.formattedDate,
            'flowType': 'INWARD',
            'isLent': true,
            'party': rec.partyName,
            'reference': rec.displayReference,
            'originalAmount': rec.totalOriginal > 0 ? rec.totalOriginal : rec.paidAmount,
            'transactedAmount': rec.paidAmount,
            'mode': rec.paymentMode,
            'status': rec.isReconciled ? 'MATCHED' : rec.status.toUpperCase(),
          });
        }
      }
      for (final pay in _reports!.payables) {
        if (!list.any((item) => item['reference'] == pay.displayReference || item['party'] == pay.partyName)) {
          list.add({
            'entryId': pay.id.toString().startsWith('PAY') ? pay.id.toString() : 'PAY-${pay.id}',
            'date': pay.formattedDate,
            'flowType': 'OUTWARD',
            'isLent': false,
            'party': pay.partyName,
            'reference': pay.displayReference,
            'originalAmount': pay.totalOriginal > 0 ? pay.totalOriginal : pay.paidAmount,
            'transactedAmount': pay.paidAmount,
            'mode': pay.paymentMode,
            'status': pay.isReconciled ? 'MATCHED' : pay.status.toUpperCase(),
          });
        }
      }
    }

    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((item) {
      final id = (item['entryId'] as String? ?? '').toLowerCase();
      final party = (item['party'] as String? ?? '').toLowerCase();
      final ref = (item['reference'] as String? ?? '').toLowerCase();
      final mode = (item['mode'] as String? ?? '').toLowerCase();
      return id.contains(q) || party.contains(q) || ref.contains(q) || mode.contains(q);
    }).toList();
  }

  // Filtered Overdue Reminders
  List<Map<String, dynamic>> get _filteredOverdueList {
    final list = List<Map<String, dynamic>>.from(_overdueList);

    if (_reports != null && _reports!.overdueInvoices.isNotEmpty) {
      for (final inv in _reports!.overdueInvoices) {
        if (!list.any((item) => item['invoiceNo'] == inv.invoiceNumber)) {
          list.add({
            'customerName': inv.clientName,
            'invoiceNo': inv.invoiceNumber,
            'totalBill': inv.totalAmount,
            'paidAmount': inv.paidAmount,
            'dueBalance': inv.dueAmount,
            'dueDate': inv.dueDate ?? '2026-11-06',
            'status': inv.status,
            'isOverdue': inv.status.toLowerCase().contains('overdue'),
          });
        }
      }
    }

    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((item) {
      final name = (item['customerName'] as String? ?? '').toLowerCase();
      final inv = (item['invoiceNo'] as String? ?? '').toLowerCase();
      return name.contains(q) || inv.contains(q);
    }).toList();
  }

  // Filtered Accounts
  List<Map<String, dynamic>> get _filteredAccountsList {
    final list = List<Map<String, dynamic>>.from(_accountsList);

    if (_reports != null && _reports!.accounts.isNotEmpty) {
      for (final acc in _reports!.accounts) {
        if (!list.any((item) => item['id'] == acc.id.toString() || item['name'] == acc.displayName)) {
          list.add({
            'id': acc.id.toString(),
            'name': acc.displayName,
            'type': acc.isCash ? 'Cash Register (Cash in Hand)' : 'Bank Account',
            'accountType': acc.isCash ? 'Cash' : 'Bank Account',
            'accountNumber': acc.displayAccountNumber,
            'bank': acc.bankName,
            'branch': acc.branchName ?? '',
            'ifsc': acc.ifscCode ?? '',
            'balance': acc.currentBalance,
            'isCash': acc.isCash,
            'status': acc.status,
          });
        }
      }
    }

    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((item) {
      final name = (item['name'] as String? ?? '').toLowerCase();
      final num = (item['accountNumber'] as String? ?? '').toLowerCase();
      return name.contains(q) || num.contains(q);
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
              _buildTabBody(screenWidth, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. HEADER ROW (Matching Images 1, 4, 5)
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

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Outlined "Send Payment" Button
        OutlinedButton.icon(
          onPressed: _openSupplierDisbursementModal,
          icon: const Icon(LucideIcons.arrowUpRight, size: 15, color: Color(0xFF166534)),
          label: const Text(
            'Send Payment',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF166534),
              letterSpacing: -0.2,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 10),

        // Solid "Receive Payment" Button
        ElevatedButton.icon(
          onPressed: _openCustomerPaymentModal,
          icon: const Icon(LucideIcons.arrowDownLeft, size: 15, color: Colors.white),
          label: const Text(
            'Receive Payment',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF166534),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: const Color(0x33166534),
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
  // 2. TOP 4 KPI CARDS ROW (Matching Images 1, 2, 4, 5)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopKpiRow(double screenWidth) {
    // If on Tab 1 (Overdue) or Tab 2 (Registers), display exact values from Screenshot 2 & 5
    // Else (Tab 0), display exact values from Screenshot 1 & 4
    final isOverdueOrBank = _activeTab == 1 || _activeTab == 2;

    final receivablesStr = isOverdueOrBank ? '₹10,43,300' : '₹0';
    final collectionsStr = '₹0';
    final balancesStr = isOverdueOrBank ? '₹57,77,94,710' : '₹1,48,93,112';
    final efficiencyStr = '100.0%';

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
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: iconColor),
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
  // 3. SEGMENTED TABS ROW (Matching Images 1, 2, 4, 5)
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

        // Far Right Search Toggle Button
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
  // TAB 0: TOTAL INWARD & OUTWARD (Matching Images 1 & 4)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildInwardOutwardTabView(double screenWidth, bool isMobile) {
    final list = _filteredInwardOutward;

    // 3 Summary Cards Row
    final cardInward = _buildInwardOutwardStatCard(
      label: 'TOTAL INWARD (+₹)',
      value: '+₹8,612',
      valueColor: const Color(0xFF16A34A),
      icon: LucideIcons.arrowDownLeft,
      iconColor: const Color(0xFF16A34A),
      iconBg: const Color(0xFFDCFCE7),
    );

    final cardOutward = _buildInwardOutwardStatCard(
      label: 'TOTAL OUTWARD (-₹)',
      value: '-₹5,000',
      valueColor: const Color(0xFFDC2626),
      icon: LucideIcons.arrowUpRight,
      iconColor: const Color(0xFFDC2626),
      iconBg: const Color(0xFFFEE2E2),
    );

    final cardNet = _buildInwardOutwardStatCard(
      label: 'NET BALANCE (INWARD - OUTWARD)',
      value: '+₹3,612',
      valueColor: const Color(0xFF16A34A),
      icon: LucideIcons.wallet,
      iconColor: const Color(0xFF16A34A),
      iconBg: const Color(0xFFDCFCE7),
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

        // Table Card Container (Images 1 & 4)
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
          child: SingleChildScrollView(
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
                columns: [
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('ENTRY ID'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('DATE'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('FLOW TYPE'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('PARTY (CUSTOMER / SUPPLIER)'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('REFERENCE #'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('ORIGINAL AMOUNT'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('TRANSACTED AMOUNT'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('MODE'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('STATUS'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ],
                rows: list.map((item) {
                  final isLent = item['isLent'] == true;
                  final origAmt = (item['originalAmount'] as num).toDouble();
                  final txAmt = (item['transactedAmount'] as num).toDouble();
                  final isOutward = item['flowType'] == 'OUTWARD';

                  return DataRow(
                    cells: [
                      // 1. ENTRY ID
                      DataCell(
                        Text(
                          item['entryId'] as String,
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
                          item['date'] as String,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                        ),
                      ),

                      // 3. FLOW TYPE (Soft pill badge)
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
                                item['flowType'] as String,
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

                      // 4. PARTY
                      DataCell(
                        Text(
                          item['party'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),

                      // 5. REFERENCE #
                      DataCell(
                        Text(
                          item['reference'] as String,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ),

                      // 6. ORIGINAL AMOUNT
                      DataCell(
                        Text(
                          '₹${_fmt(origAmt)}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),

                      // 7. TRANSACTED AMOUNT (+₹71 in green)
                      DataCell(
                        Text(
                          '${isOutward ? '-' : '+'}₹${_fmt(txAmt)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isOutward ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                          ),
                        ),
                      ),

                      // 8. MODE (Cash in bold green)
                      DataCell(
                        Text(
                          item['mode'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),

                      // 9. STATUS (MATCHED in blue)
                      DataCell(
                        Text(
                          item['status'] as String,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
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
  // TAB 1: OVERDUE COLLECTIONS & REMINDERS (Matching Image 1 & 5)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildOverdueRemindersTabView(double screenWidth, bool isMobile) {
    final list = _filteredOverdueList;

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
          // Section Title
          const Text(
            'Overdue Customer Accounts Reminders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Overdue Table with horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: screenWidth >= 900 ? screenWidth - 104 : 880,
              ),
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 64,
                horizontalMargin: 12,
                columnSpacing: 26,
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
                columns: [
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('CUSTOMER NAME'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('INVOICE / BILL NO'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('TOTAL BILL'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('PAID AMOUNT'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('CREDIT DUE BALANCE'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('DUE DATE'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('STATUS'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('ACTIONS'),
                        SizedBox(width: 4),
                        Icon(LucideIcons.filter, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ],
                rows: list.map((item) {
                  final total = (item['totalBill'] as num).toDouble();
                  final paid = (item['paidAmount'] as num).toDouble();
                  final due = (item['dueBalance'] as num).toDouble();
                  final isOverdue = item['isOverdue'] == true;
                  final status = item['status'] as String;
                  final customerName = item['customerName'] as String;

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

                      // 2. INVOICE / BILL NO
                      DataCell(
                        Text(
                          item['invoiceNo'] as String,
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

                      // 5. CREDIT DUE BALANCE (Bold red)
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
                          item['dueDate'] as String,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ),

                      // 7. STATUS (Credit Due in Amber, Overdue in Red)
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

                      // 8. Action: Send Reminder Pill Button (Matching Image 1)
                      DataCell(
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            AppSnackbar.show(
                              context,
                              "Overdue reminder dispatched to '$customerName' via @bnxmail.com!",
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
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: BANK & CASH REGISTERS (Matching Images 1, 2, 3, 4, 5)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBankRegistersTabView(double screenWidth, bool isMobile) {
    final list = _filteredAccountsList;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Determine columns: 3 columns if width >= 1050, 2 columns if >= 680, else 1
        final int crossAxisCount = totalWidth >= 1050 ? 3 : (totalWidth >= 680 ? 2 : 1);
        final double spacing = 16.0;
        final double cardWidth = (totalWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Card Grid (Matching Image 1 & 2)
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: list.map((acc) {
                final isCash = acc['isCash'] == true;
                final isCardSelected = _selectedCardId == acc['id'];
                final balance = (acc['balance'] as num).toDouble();
                final isNegative = balance < 0;
                final balanceStr = isNegative ? '-₹${_fmt(balance.abs())}' : '₹${_fmt(balance)}';

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCardId = acc['id'] as String);
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
                        // Top Row: Type Pill + 3-dots Menu Button (Matching Images 2 & 3)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF), // Soft Blue
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isCash ? 'CASH' : 'BANK',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                cardColor: Colors.white,
                              ),
                              child: PopupMenuButton<String>(
                                onOpened: () => setState(() => _selectedCardId = acc['id'] as String),
                                icon: const Icon(LucideIcons.ellipsisVertical, size: 16, color: Color(0xFF64748B)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                elevation: 3,
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    height: 38,
                                    child: Row(
                                      children: const [
                                        Icon(LucideIcons.pencil, size: 14, color: Color(0xFF2563EB)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    height: 38,
                                    child: Row(
                                      children: const [
                                        Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _openEditAccountModal(acc);
                                  } else if (val == 'delete') {
                                    _confirmDeleteAccount(acc);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Account Name
                        Text(
                          acc['name'] as String,
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

                        // Subtitle 1: Type or Account No
                        Text(
                          isCash
                              ? 'Type: ${acc['type']}'
                              : 'Account No: ${acc['accountNumber']}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Subtitle 2: Bank details for Bank cards
                        if (!isCash && (acc['bank'] as String).isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Bank: ${acc['bank']} • Branch: ${acc['branch']} • IFSC: ${acc['ifsc']}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 22),

                        // Bottom Row: Current Balance
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

            // ══════════════════════════════════════════════════════════════════════
            // TRANSACTION LEDGER SECTION (Matching Image 1 & 2)
            // ══════════════════════════════════════════════════════════════════════
            _buildTransactionLedgerSection(screenWidth, isMobile),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TRANSACTION LEDGER TABLE (Matching Screenshot 1 & 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTransactionLedgerSection(double screenWidth, bool isMobile) {
    final selectedAcc = _accountsList.firstWhere(
      (a) => a['id'] == _selectedCardId,
      orElse: () => _accountsList.first,
    );
    final selectedName = selectedAcc['name'] as String;

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
          // Section Header Row: Title + ATTACH YOUR TRANSACTION DETAILS button
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
                        'Transaction Ledger: $selectedName',
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
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _openReconciliationWorkspaceModal(selectedAcc),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2563EB), width: 1.0),
                  backgroundColor: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'ATTACH YOUR TRANSACTION DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Ledger Table with horizontal scrolling
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
                  DataColumn(label: Text('BALANCE AFTER')),
                ],
                rows: _ledgerEntries.map((row) {
                  final isCredit = row['type'] == 'Credit';
                  final amt = (row['amount'] as num).toDouble();
                  final amtStr = isCredit ? '+₹${_fmt(amt)}' : '-₹${_fmt(amt.abs())}';

                  return DataRow(
                    cells: [
                      // DATE
                      DataCell(
                        Text(
                          row['date'] as String,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                      ),
                      // DESCRIPTION
                      DataCell(
                        Text(
                          row['description'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      // TYPE (Credit / Debit pill)
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            row['type'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isCredit ? const Color(0xFF166534) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                      // AMOUNT (+ in green, - in red)
                      DataCell(
                        Text(
                          amtStr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                      // BALANCE AFTER
                      DataCell(
                        Text(
                          row['balanceAfter'] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
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

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL: BANK STATEMENT RECONCILIATION WORKSPACE (Matching Screenshots 1, 2, 3, 4, 5)
  // ══════════════════════════════════════════════════════════════════════════
  void _openReconciliationWorkspaceModal(Map<String, dynamic> account) {
    int reconTab = 0; // 0: OVERALL, 1: PLATFORM SALES, 2: BANK STATEMENT
    bool isMatchedListView = false; // Toggled by "Matched List" button (Screenshot 2)
    String targetBank = '${account['name']} (${account['isCash'] == true ? 'Cash Register' : 'Bank'})';
    String statementPeriod = 'All Dates';
    String platformPeriod = 'All Dates';

    final List<Map<String, dynamic>> matchItems = [
      {
        'id': 'm1',
        'matched': false,
        'stmtDesc': 'Cash received for retail counter slip',
        'stmtType': 'Credit',
        'stmtAmt': 1200.0,
        'stmtDate': '18/05/2025, 02:00 pm',
        'platDesc': 'cash sale invoice retail counter slip',
        'platRef': 'INV-2025-003',
        'platAmt': 1200.0,
        'platDate': '18/05/2025, 01:50 pm',
      },
      {
        'id': 'm2',
        'matched': false,
        'stmtDesc': 'Office tea and refreshments pantry payout',
        'stmtType': 'Debit',
        'stmtAmt': 350.0,
        'stmtDate': '19/05/2025, 04:30 pm',
        'platDesc': 'petty cash voucher tea & snacks pantry',
        'platRef': 'VCH-2025-090',
        'platAmt': 350.0,
        'platDate': '19/05/2025, 04:15 pm',
      },
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final dialogWidth = math.min(1060.0, screenWidth - 32);
            final matchedCount = matchItems.where((m) => m['matched'] == true).length;
            final matchedItemsList = matchItems.where((m) => m['matched'] == true).toList();

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: dialogWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. TOP HEADER (Dark green banner - Protected from RenderFlex overflow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      color: const Color(0xFF0F3E2E), // Dark forest green matching screenshots
                      child: LayoutBuilder(
                        builder: (context, headerConstraints) {
                          final isNarrow = headerConstraints.maxWidth < 920;

                          // Left branding widget
                          final brandingWidget = Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(LucideIcons.landmark, color: Colors.white, size: 18),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Bank Statement Reconciliation Workspace',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: -0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Multi-Bank',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Account-isolated statement parsing, platform transaction matching & reconciliation ledger',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFFA7F3D0),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );

                          // Right controls widget (Target Bank + Matched List + Close)
                          final controlsWidget = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Target Bank dropdown pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A2B1E),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF166534)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'TARGET BANK: ',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF86EFAC),
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: isNarrow ? 100 : 140),
                                      child: Text(
                                        targetBank,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(LucideIcons.chevronDown, size: 12, color: Colors.white70),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Matched List Button (Toggles Screenshot 2 view)
                              InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setModalState(() {
                                    isMatchedListView = !isMatchedListView;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isMatchedListView ? const Color(0xFF059669) : const Color(0xFF0A2B1E),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isMatchedListView ? const Color(0xFF10B981) : const Color(0xFF166534),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.archive, size: 13, color: Colors.white70),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Matched List',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isMatchedListView ? const Color(0xFF047857) : Colors.black38,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$matchedCount',
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Close button
                              InkWell(
                                onTap: () => Navigator.pop(ctx),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(LucideIcons.x, size: 13, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: brandingWidget),
                                    InkWell(
                                      onTap: () => Navigator.pop(ctx),
                                      child: const Icon(LucideIcons.x, size: 16, color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: controlsWidget,
                                ),
                              ],
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: brandingWidget),
                              const SizedBox(width: 12),
                              controlsWidget,
                            ],
                          );
                        },
                      ),
                    ),

                    // 2. MODAL SCROLLABLE BODY
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info sub-bar (Pending statements vs platform records)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Currently Reconciling: ',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFBBF7D0)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(LucideIcons.fileText, size: 12, color: Color(0xFF16A34A)),
                                              const SizedBox(width: 5),
                                              Text(
                                                account['name'] as String,
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          '(Ledger Balance: ₹0.00)',
                                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: const TextSpan(
                                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                      children: [
                                        TextSpan(text: 'Pending: '),
                                        TextSpan(
                                          text: '2 statements',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                        ),
                                        TextSpan(text: ' vs '),
                                        TextSpan(
                                          text: '2 platform records',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // If user clicked "Matched List" -> Render Screenshot 2 View
                            if (isMatchedListView)
                              _buildMatchedListView(
                                account: account,
                                matchedItems: matchedItemsList,
                                onBackToMatrix: () {
                                  setModalState(() {
                                    isMatchedListView = false;
                                  });
                                },
                                onUnmatch: (item) {
                                  setModalState(() {
                                    item['matched'] = false;
                                  });
                                  AppSnackbar.show(
                                    context,
                                    "Item returned to reconciliation matrix",
                                    type: SnackType.info,
                                  );
                                },
                              )
                            else ...[
                              // Upload Container (Dashed box)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                child: InkWell(
                                  onTap: () {
                                    AppSnackbar.show(
                                      context,
                                      "Statement upload dialog ready (.csv, .xlsx, .xls, .pdf)",
                                      type: SnackType.info,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F9FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF93C5FD),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDBEAFE),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Icon(LucideIcons.uploadCloud, color: Color(0xFF2563EB), size: 20),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Upload statement for ${account['name']}',
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        const Text(
                                          'Drag and drop statement file (.csv, .xlsx, .xls, .pdf) or click to browse from your device',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 3 Tabs (Segmented bar matching Screenshot 1 & 3)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Row(
                                    children: [
                                      _buildReconTabPill(
                                        title: '1  OVERALL',
                                        isSelected: reconTab == 0,
                                        onTap: () => setModalState(() => reconTab = 0),
                                      ),
                                      const SizedBox(width: 4),
                                      _buildReconTabPill(
                                        title: '2  PLATFORM SALES & TRANSACTION HISTORY',
                                        badge: '2',
                                        isSelected: reconTab == 1,
                                        onTap: () => setModalState(() => reconTab = 1),
                                      ),
                                      const SizedBox(width: 4),
                                      _buildReconTabPill(
                                        title: '3  BANK STATEMENT (UPLOADED DATA)',
                                        badge: '2',
                                        isSelected: reconTab == 2,
                                        onTap: () => setModalState(() => reconTab = 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Period Filter Row
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    if (reconTab == 0 || reconTab == 2) ...[
                                      _buildPeriodFilterDropdown(
                                        label: 'STATEMENT PERIOD:',
                                        value: statementPeriod,
                                        onChanged: (v) {
                                          if (v != null) setModalState(() => statementPeriod = v);
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    if (reconTab == 0 || reconTab == 1) ...[
                                      _buildPeriodFilterDropdown(
                                        label: 'PLATFORM PERIOD:',
                                        value: platformPeriod,
                                        onChanged: (v) {
                                          if (v != null) setModalState(() => platformPeriod = v);
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Tab Body Content with Navigation Arrows
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Tab content
                                    Column(
                                      children: [
                                        if (reconTab == 0)
                                          _buildReconTab0Overall(
                                            matchItems: matchItems,
                                            setModalState: setModalState,
                                            onMatched: () => setModalState(() {}),
                                          )
                                        else if (reconTab == 1)
                                          _buildReconTab1Platform(matchItems)
                                        else
                                          _buildReconTab2BankStatement(matchItems),
                                      ],
                                    ),

                                    // Floating Left Arrow
                                    if (reconTab > 0)
                                      Positioned(
                                        left: -6,
                                        child: _buildCircleArrowNavButton(
                                          icon: LucideIcons.arrowLeft,
                                          onTap: () => setModalState(() => reconTab--),
                                        ),
                                      ),

                                    // Floating Right Arrow
                                    if (reconTab < 2)
                                      Positioned(
                                        right: -6,
                                        child: _buildCircleArrowNavButton(
                                          icon: LucideIcons.arrowRight,
                                          onTap: () => setModalState(() => reconTab++),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // 3. BOTTOM FOOTER BAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF16A34A)),
                              SizedBox(width: 8),
                              Text(
                                'Reconciliation changes are preserved in active session state.',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Close Workspace',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
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
  // VIEW: MATCHED LIST (Screenshot 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMatchedListView({
    required Map<String, dynamic> account,
    required List<Map<String, dynamic>> matchedItems,
    required VoidCallback onBackToMatrix,
    required void Function(Map<String, dynamic>) onUnmatch,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          // Header Row: Title & Subtitle + ⚡ Back to Reconciliation Matrix button (Matching Screenshot 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reconciliation Register — ${account['name']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Audit register of resolved statements and platform ledger entries',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onBackToMatrix,
                icon: const Icon(LucideIcons.zap, size: 13, color: Colors.white),
                label: const Text('Back to Reconciliation Matrix'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Content: Empty State (Matching Screenshot 2) OR Matched Table
          if (matchedItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.fileText, color: Color(0xFF94A3B8), size: 22),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No matched records found for this account.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Switch to the 3-column Reconciliation Matrix to compare\nuploaded bank statement lines against platform transactions\nand accept matches.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
                    ),
                  ],
                ),
              ),
            )
          else
            // Matched records table
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 800),
                  child: DataTable(
                    headingRowHeight: 44,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 56,
                    columns: const [
                      DataColumn(label: Text('STATEMENT LINE')),
                      DataColumn(label: Text('PLATFORM INVOICE')),
                      DataColumn(label: Text('AMOUNT')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: matchedItems.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item['stmtDesc'] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                          DataCell(Text(item['platRef'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.bold))),
                          DataCell(Text('₹${_fmt((item['stmtAmt'] as num).toDouble())}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                              child: const Text('Reconciled', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                            ),
                          ),
                          DataCell(
                            TextButton(
                              onPressed: () => onUnmatch(item),
                              child: const Text('Unmatch', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReconTabPill({
    required String title,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF166534) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  letterSpacing: 0.3,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodFilterDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.calendar, size: 13, color: Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF64748B)),
              items: const [
                DropdownMenuItem(value: 'All Dates', child: Text('All Dates', style: TextStyle(fontSize: 12))),
                DropdownMenuItem(value: 'This Month', child: Text('This Month', style: TextStyle(fontSize: 12))),
                DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days', style: TextStyle(fontSize: 12))),
                DropdownMenuItem(value: 'Custom Range', child: Text('Custom Range', style: TextStyle(fontSize: 12))),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleArrowNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFF166534),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  // Subview for Tab 0: OVERALL (Side by Side match cards - Screenshot 3)
  Widget _buildReconTab0Overall({
    required List<Map<String, dynamic>> matchItems,
    required void Function(void Function()) setModalState,
    required VoidCallback onMatched,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.max(constraints.maxWidth, 720.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: matchItems.map((item) {
                final isMatched = item['matched'] == true;
                final isCredit = item['stmtType'] == 'Credit';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: isMatched ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMatched ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left half: Bank Statement Record
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['stmtDesc'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['stmtType'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isCredit ? const Color(0xFF166534) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '₹${_fmt((item['stmtAmt'] as num).toDouble())}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['stmtDate'] as String,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),
                      // Center / Right half: Platform Record
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['platDesc'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['platRef'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '₹${_fmt((item['platAmt'] as num).toDouble())}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['platDate'] as String,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),
                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isMatched
                                ? null
                                : () {
                                    setModalState(() {
                                      item['matched'] = true;
                                    });
                                    onMatched();
                                    AppSnackbar.show(
                                      context,
                                      "Reconciliation record matched successfully!",
                                      type: SnackType.success,
                                    );
                                  },
                            icon: const Icon(LucideIcons.check, size: 14),
                            label: Text(isMatched ? 'Matched' : 'Match'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: isMatched
                                ? null
                                : () {
                                    AppSnackbar.show(
                                      context,
                                      "Reconciliation match rejected",
                                      type: SnackType.info,
                                    );
                                  },
                            icon: const Icon(LucideIcons.x, size: 14),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              foregroundColor: const Color(0xFFDC2626),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Subview for Tab 1: PLATFORM SALES & TRANSACTION HISTORY (Screenshot 4)
  Widget _buildReconTab1Platform(List<Map<String, dynamic>> matchItems) {
    return Column(
      children: matchItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['platDesc'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['platRef'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '₹${_fmt((item['platAmt'] as num).toDouble())}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.badgeCheck, size: 12, color: Color(0xFF16A34A)),
                        SizedBox(width: 4),
                        Text(
                          'Exact Match',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item['platDate'] as String,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Subview for Tab 2: BANK STATEMENT (UPLOADED DATA) (Screenshot 5)
  Widget _buildReconTab2BankStatement(List<Map<String, dynamic>> matchItems) {
    return Column(
      children: matchItems.map((item) {
        final isCredit = item['stmtType'] == 'Credit';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['stmtDesc'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['stmtType'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isCredit ? const Color(0xFF166534) : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${_fmt((item['stmtAmt'] as num).toDouble())}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.calendar, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      item['stmtDate'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  // ══════════════════════════════════════════════════════════════════════════
  // MODAL: EDIT ACCOUNT (Matching Images 4 & 5)
  // ══════════════════════════════════════════════════════════════════════════
  void _openEditAccountModal(Map<String, dynamic> acc) {
    final nameCtrl = TextEditingController(text: acc['name'] as String);
    final accountNumCtrl = TextEditingController(text: acc['accountNumber'] as String);
    String selectedType = acc['accountType'] as String? ?? 'Cash';
    final balanceCtrl = TextEditingController(text: (acc['balance'] as num).toInt().toString());
    String selectedStatus = acc['status'] as String? ?? 'Active';

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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF), // Soft Blue
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(LucideIcons.pencil, size: 17, color: Color(0xFF2563EB)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Edit Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Update registered account details and balance',
                                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Account Name *
                    const Text(
                      'Account Name *',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: _inputDecoration('Account Name'),
                    ),
                    const SizedBox(height: 16),

                    // Row: Account / UPI Number & Account Type
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account / UPI Number',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: accountNumCtrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: _inputDecoration('CASH-REG-01'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Type',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedType,
                                    isExpanded: true,
                                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                                    items: const [
                                      DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Bank Account', child: Text('Bank Account', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Wallet / UPI', child: Text('Wallet / UPI', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Savings', child: Text('Savings', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Current', child: Text('Current', style: TextStyle(fontSize: 13))),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => selectedType = v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row: Current Balance (₹) * & Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Balance (₹) *',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: balanceCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: _inputDecoration('0'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedStatus,
                                    isExpanded: true,
                                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                                    items: const [
                                      DropdownMenuItem(value: 'Active', child: Text('Active', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Archived', child: Text('Archived', style: TextStyle(fontSize: 13))),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => selectedStatus = v);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Actions Row: Cancel & Save Changes
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newName = nameCtrl.text.trim();
                              final newNumber = accountNumCtrl.text.trim();
                              final newBal = double.tryParse(balanceCtrl.text.trim()) ?? 0.0;

                              setState(() {
                                acc['name'] = newName.isNotEmpty ? newName : acc['name'];
                                acc['accountNumber'] = newNumber.isNotEmpty ? newNumber : acc['accountNumber'];
                                acc['accountType'] = selectedType;
                                acc['isCash'] = selectedType.toLowerCase() == 'cash';
                                acc['balance'] = newBal;
                                acc['status'] = selectedStatus;
                              });

                              Navigator.pop(ctx);
                              AppSnackbar.show(
                                context,
                                "Account '${acc['name']}' updated successfully!",
                                type: SnackType.success,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
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
        );
      },
    );
  }

  void _confirmDeleteAccount(Map<String, dynamic> acc) {
    setState(() {
      _accountsList.removeWhere((item) => item['id'] == acc['id']);
    });
    AppSnackbar.show(
      context,
      "Account '${acc['name']}' removed from registers",
      type: SnackType.info,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 1: RECORD SUPPLIER DISBURSEMENT (Matching Screenshot 2)
  // ══════════════════════════════════════════════════════════════════════════
  void _openSupplierDisbursementModal() {
    String selectedSupplier = 'drfchgv';
    final billIdCtrl = TextEditingController();
    final origDueCtrl = TextEditingController(text: '0');
    final paidAmountCtrl = TextEditingController(text: '0');
    String disbursementMode = 'Cash';
    final refNoCtrl = TextEditingController(text: 'REF-181');

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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Record Supplier Disbursement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Select Supplier Profile
                    const Text(
                      'Select Supplier Profile',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSupplier,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(value: 'drfchgv', child: Text('drfchgv', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'kamesh mmotors', child: Text('kamesh mmotors', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'testing cliks business supplier', child: Text('testing cliks business supplier', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) {
                            if (v != null) setModalState(() => selectedSupplier = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Row: Purchase Bill Linked ID & Original Due Amount (₹)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Purchase Bill Linked ID',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: billIdCtrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: _inputDecoration(''),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Original Due Amount (₹)',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: origDueCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: _inputDecoration('0'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Paid Amount (Outflow worth, ₹)
                    const Text(
                      'Paid Amount (Outflow worth, ₹)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: paidAmountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: _inputDecoration('0'),
                    ),
                    const SizedBox(height: 16),

                    // Row: Disbursement Mode & Cheque / Ref No
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Disbursement Mode',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: disbursementMode,
                                    isExpanded: true,
                                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                                    items: const [
                                      DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Cheque', child: Text('Cheque', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'UPI', child: Text('UPI', style: TextStyle(fontSize: 13))),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => disbursementMode = v);
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
                              const Text(
                                'Cheque / Ref No',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: refNoCtrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: _inputDecoration('REF-181'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Full-width Action: Disburse Supplier Funds
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final amt = double.tryParse(paidAmountCtrl.text.trim()) ?? 0.0;
                          final billId = billIdCtrl.text.trim();
                          final refNo = refNoCtrl.text.trim();

                          setState(() {
                            _inwardOutwardList.insert(0, {
                              'entryId': 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              'date': '2026-11-17',
                              'flowType': 'OUTWARD',
                              'isLent': false,
                              'party': selectedSupplier,
                              'reference': refNo.isNotEmpty ? refNo : 'REF-${DateTime.now().millisecond}',
                              'originalAmount': double.tryParse(origDueCtrl.text.trim()) ?? amt,
                              'transactedAmount': amt > 0 ? amt : 5000.0,
                              'mode': disbursementMode,
                              'status': 'MATCHED',
                            });
                          });

                          Navigator.pop(ctx);
                          AppSnackbar.show(
                            context,
                            "Supplier disbursement of ₹${_fmt(amt > 0 ? amt : 5000.0)} recorded for '$selectedSupplier'!",
                            type: SnackType.success,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Disburse Supplier Funds',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
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
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODAL 2: RECORD CUSTOMER PAYMENT (Matching Screenshot 3)
  // ══════════════════════════════════════════════════════════════════════════
  void _openCustomerPaymentModal() {
    String selectedCustomer = 'ravinew2004';
    final invoiceIdCtrl = TextEditingController(text: 'DKSJCS-353226');
    final origAmountCtrl = TextEditingController(text: '212');
    final paidAmountCtrl = TextEditingController();
    String paymentMode = 'Cash';
    final refIdCtrl = TextEditingController();

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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Record Customer Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.x, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Select Customer Profile
                    const Text(
                      'Select Customer Profile',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCustomer,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(value: 'ravinew2004', child: Text('ravinew2004', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Walk-in Customer', child: Text('Walk-in Customer', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'ravinew', child: Text('ravinew', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'kamesh', child: Text('kamesh', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) {
                            if (v != null) setModalState(() => selectedCustomer = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Row: Invoice Linked ID & Original Amount (₹)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Invoice Linked ID',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: invoiceIdCtrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: _inputDecoration('DKSJCS-353226'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Original Amount (₹)',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: origAmountCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: _inputDecoration('212'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Paid amount (Receipt worth, ₹)
                    const Text(
                      'Paid amount (Receipt worth, ₹)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: paidAmountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: _inputDecoration('0.00'),
                    ),
                    const SizedBox(height: 16),

                    // Row: Payment Mode & Ref ID / UPI reference
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment Mode',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: paymentMode,
                                    isExpanded: true,
                                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                                    items: const [
                                      DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'UPI', child: Text('UPI', style: TextStyle(fontSize: 13))),
                                      DropdownMenuItem(value: 'Cheque', child: Text('Cheque', style: TextStyle(fontSize: 13))),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) setModalState(() => paymentMode = v);
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
                              const Text(
                                'Ref ID / UPI reference',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: refIdCtrl,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                decoration: _inputDecoration(''),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Full-width Action: Finalize Payment Collection
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          final amt = double.tryParse(paidAmountCtrl.text.trim()) ?? 0.0;
                          final invId = invoiceIdCtrl.text.trim();
                          final orig = double.tryParse(origAmountCtrl.text.trim()) ?? amt;

                          setState(() {
                            _inwardOutwardList.insert(0, {
                              'entryId': 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              'date': '2026-11-17',
                              'flowType': 'INWARD',
                              'isLent': true,
                              'party': selectedCustomer,
                              'reference': invId.isNotEmpty ? invId : 'INV-${DateTime.now().millisecond}',
                              'originalAmount': orig > 0 ? orig : amt,
                              'transactedAmount': amt > 0 ? amt : 212.0,
                              'mode': paymentMode,
                              'status': 'MATCHED',
                            });
                          });

                          Navigator.pop(ctx);
                          AppSnackbar.show(
                            context,
                            "Payment receipt of ₹${_fmt(amt > 0 ? amt : 212.0)} collected from '$selectedCustomer'!",
                            type: SnackType.success,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Finalize Payment Collection',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
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
