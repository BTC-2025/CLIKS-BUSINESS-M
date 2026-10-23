import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../widgets/bento/bento.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DATA MODELS FOR BENTO ACCOUNTING DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════

class _BankAccountData {
  final String id;
  String name;
  String holder;
  double balance;
  double income;
  double expenses;
  String lastTxn;
  bool isHighlighted;
  String? accountNumber;
  String? ifsc;
  String? branch;
  String? accountType;
  String? status;

  _BankAccountData({
    required this.id,
    required this.name,
    required this.holder,
    required this.balance,
    this.income = 0,
    this.expenses = 0,
    this.lastTxn = 'No transactions yet',
    this.isHighlighted = false,
    this.accountNumber,
    this.ifsc,
    this.branch,
    this.accountType,
    this.status,
  });
}

class _DayBookItem {
  final String id;
  final String date;
  final String category;
  final String mode;
  final String type; // 'EXPENSE' or 'INCOME'
  final double amount;
  final bool isSpecialHighlight;

  _DayBookItem({
    required this.id,
    required this.date,
    required this.category,
    required this.mode,
    required this.type,
    required this.amount,
    this.isSpecialHighlight = false,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// ACCOUNTING PAGE WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class AccountingPage extends ConsumerStatefulWidget {
  const AccountingPage({super.key});

  @override
  ConsumerState<AccountingPage> createState() => _AccountingPageState();
}

class _AccountingPageState extends ConsumerState<AccountingPage> {
  // Active Tab Index (defaults to 0: P & L to match Image 1 & 2)
  int _activeTab = 0;

  final List<String> _tabLabels = [
    'P & L',
    'Balance Sheet',
    'Receivables & Payables',
    'Expenses',
    'Cash & Bank',
    'GST',
    'Day Book',
  ];

  // Bank accounts dataset (Image 1)
  final List<_BankAccountData> _bankAccounts = [
    _BankAccountData(
      id: 'bank-1',
      name: 'uybwaued',
      holder: 'Ravi',
      balance: 5000.0,
      income: 0.0,
      expenses: 0.0,
      lastTxn: 'No transactions yet',
      isHighlighted: true,
    ),
    _BankAccountData(
      id: 'bank-2',
      name: 'djwfnwjnfjwnkjs',
      holder: 'karnataka bank',
      balance: 500000.0,
      income: 0.0,
      expenses: 0.0,
      lastTxn: 'No transactions yet',
      isHighlighted: false,
    ),
  ];

  // Day Book dataset (Image 3)
  late List<_DayBookItem> _dayBookRecords;

  // Sorting state for Day Book table
  String _sortColumn = 'date';
  bool _sortAscending = false;

  // Receivables & Payables state (Images 4 & 5)
  final ScrollController _mobileTabScrollController = ScrollController();
  final TextEditingController _rpSearchController = TextEditingController();
  final TextEditingController _rpMinController = TextEditingController();
  final TextEditingController _rpMaxController = TextEditingController();
  String _rpSelectedStatus = 'All Statuses';
  DateTime? _rpFromDate;
  DateTime? _rpToDate;

  int _overdueInvoicesCount = 25;
  double _overdueAmount = 918822.0;
  final double _totalReceivables = 918822.0;

  // Invoice dataset matching Image 5 exactly
  final List<Map<String, dynamic>> _invoicesList = [
    {
      'partyName': 'Walk-in Customer',
      'invNumber': 'POS-604969',
      'dueDate': '2026-10-12',
      'pendingAmount': 0.0,
      'status': 'Paid',
    },
    {
      'partyName': 'sanjay123',
      'invNumber': 'POS-480307',
      'dueDate': '2026-09-29',
      'pendingAmount': 0.0,
      'status': 'Paid',
    },
    {
      'partyName': 'Walk-in Customer',
      'invNumber': 'POS-540526',
      'dueDate': '2026-09-28',
      'pendingAmount': 0.0,
      'status': 'Paid',
    },
    {
      'partyName': 'Walk-in Customer',
      'invNumber': 'POS-530310',
      'dueDate': '2026-09-28',
      'pendingAmount': 0.0,
      'status': 'Paid',
    },
    {
      'partyName': 'santhoshhhhhh',
      'invNumber': 'INV-CN-9933',
      'dueDate': '2026-09-27',
      'pendingAmount': 10620.0,
      'status': 'Overdue',
    },
  ];

  List<Map<String, dynamic>> get _filteredInvoices {
    return _invoicesList.where((inv) {
      if (_rpSearchController.text.isNotEmpty) {
        final query = _rpSearchController.text.toLowerCase().trim();
        final party = (inv['partyName'] ?? '').toString().toLowerCase();
        final numStr = (inv['invNumber'] ?? '').toString().toLowerCase();
        if (!party.contains(query) && !numStr.contains(query)) {
          return false;
        }
      }
      if (_rpSelectedStatus != 'All Statuses') {
        if (inv['status'] != _rpSelectedStatus) return false;
      }
      if (_rpMinController.text.isNotEmpty) {
        final minVal = double.tryParse(_rpMinController.text.trim());
        if (minVal != null &&
            (inv['pendingAmount'] as num).toDouble() < minVal) {
          return false;
        }
      }
      if (_rpMaxController.text.isNotEmpty) {
        final maxVal = double.tryParse(_rpMaxController.text.trim());
        if (maxVal != null &&
            (inv['pendingAmount'] as num).toDouble() > maxVal) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  final List<Map<String, dynamic>> _partyDataset = [
    {
      'name': 'Acme Technologies',
      'inv': 'INV-2026-041',
      'dueDate': '12-08-2026',
      'amount': 45000.0,
      'status': 'Pending',
      'phone': '+91 98765 43210',
    },
    {
      'name': 'Ravi Traders',
      'inv': 'INV-2026-038',
      'dueDate': '01-08-2026',
      'amount': 18500.0,
      'status': 'Overdue',
      'phone': '+91 98123 45678',
    },
    {
      'name': 'Global Logistics',
      'inv': 'INV-2026-045',
      'dueDate': '18-08-2026',
      'amount': 28000.0,
      'status': 'Pending',
      'phone': '+91 99887 76655',
    },
    {
      'name': 'Zenith Retail',
      'inv': 'INV-2026-029',
      'dueDate': '25-07-2026',
      'amount': 12000.0,
      'status': 'Overdue',
      'phone': '+91 97654 32109',
    },
    {
      'name': 'Metro Suppliers',
      'inv': 'INV-2026-015',
      'dueDate': '10-07-2026',
      'amount': 0.0,
      'status': 'Paid',
      'phone': '+91 91234 56789',
    },
  ];

  @override
  void initState() {
    super.initState();
    _rpSearchController.addListener(() => setState(() {}));
    _rpMinController.addListener(() => setState(() {}));
    _rpMaxController.addListener(() => setState(() {}));

    // Initialize Day Book records matching Image 3 exactly
    _dayBookRecords = [
      _DayBookItem(
        id: 'db-0',
        date: '2026-10-14',
        category: 'Rent',
        mode: 'UPI / Razorpay',
        type: 'EXPENSE',
        amount: 10000.0,
      ),
      _DayBookItem(
        id: 'db-1',
        date: '2026-09-29',
        category: 'oeirhfb',
        mode: 'UPI / Razorpay',
        type: 'EXPENSE',
        amount: 200.0,
        isSpecialHighlight: true, // Soft pink row tint in Image 3
      ),
      _DayBookItem(
        id: 'db-2',
        date: '2026-09-14',
        category: 'Rent',
        mode: 'UPI / Razorpay',
        type: 'EXPENSE',
        amount: 10000.0,
      ),
      _DayBookItem(
        id: 'db-3',
        date: '2026-09-15',
        category: 'Sales Revenue',
        mode: 'UPI / Razorpay',
        type: 'INCOME',
        amount: 201780.0,
      ),
      _DayBookItem(
        id: 'db-4',
        date: '2026-08-02',
        category: 'Sales Revenue',
        mode: 'Cash in Hand',
        type: 'INCOME',
        amount: 1000.0,
      ),
      _DayBookItem(
        id: 'db-5',
        date: '2026-08-01',
        category: 'Sales Revenue',
        mode: 'Cash in Hand',
        type: 'INCOME',
        amount: 240000.0,
      ),
      _DayBookItem(
        id: 'db-6',
        date: '2026-08-20',
        category: 'Sales Revenue',
        mode: 'Cash in Hand',
        type: 'INCOME',
        amount: 25000.0,
      ),
      _DayBookItem(
        id: 'db-7',
        date: '2026-08-14',
        category: 'Sales Revenue',
        mode: 'Cash in Hand',
        type: 'INCOME',
        amount: 200000.0,
      ),
      _DayBookItem(
        id: 'db-8',
        date: '2026-08-04',
        category: 'Sales Revenue',
        mode: 'Cash in Hand',
        type: 'INCOME',
        amount: 39100.0,
      ),
    ];
  }

  @override
  void dispose() {
    _mobileTabScrollController.dispose();
    _rpSearchController.dispose();
    _rpMinController.dispose();
    _rpMaxController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CALCULATED METRICS
  // ══════════════════════════════════════════════════════════════════════════
  double _grossRevenue = 1000000706880.0;
  double _totalExpenses = 98866717.40;
  double get _netProfit => _grossRevenue - _totalExpenses;
  final double _gstPayable = 3962249874.20;
  double _totalCashBalance = 0.0;

  double get _totalBankBalance {
    return _bankAccounts.fold(0.0, (sum, b) => sum + b.balance);
  }

  double get _totalAvailableFunds {
    return _totalCashBalance + _totalBankBalance;
  }

  double get _combinedBalance => _totalAvailableFunds;

  // ══════════════════════════════════════════════════════════════════════════
  // MODERNIZED MACOS DESKTOP ACCOUNTING DASHBOARD UI
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildMacOsLayout(BuildContext context, double screenWidth) {
    final double horizontalPadding = screenWidth >= 1440
        ? 36.0
        : (screenWidth >= 1100 ? 30.0 : 22.0);
    final double verticalPadding = screenWidth >= 1440 ? 30.0 : 22.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            44,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMacOsPageHeader(context),
              const SizedBox(height: 22),
              _buildMacOsTopMetrics(screenWidth),
              const SizedBox(height: 24),
              _buildMacOsTabNavigation(),
              const SizedBox(height: 20),
              _buildMacOsActiveTabContent(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacOsPageHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48), // Rose/Magenta
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x28E11D48),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Accounting',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.6,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Compliance-ready financial management and GST reporting.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: () => _openRecordEntryModal(context),
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text(
            'Record Entry',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            shadowColor: const Color(0x332563EB),
          ),
        ),
      ],
    );
  }

  Widget _buildMacOsTopMetrics(double screenWidth) {
    final card1 = _buildMacOsKpiCard(
      label: 'GROSS REVENUE',
      formattedValue: '₹${_formatNumber(_grossRevenue)}',
      accentColor: const Color(0xFF8B5CF6), // Purple
      iconBgColor: const Color(0xFFF3E8FF),
      iconWidget: const Icon(
        LucideIcons.trendingUp,
        color: Color(0xFF8B5CF6),
        size: 17,
      ),
    );

    final card2 = _buildMacOsKpiCard(
      label: 'TOTAL EXPENSES',
      formattedValue: '₹${_formatNumber(_totalExpenses)}',
      accentColor: const Color(0xFFEF4444), // Red
      iconBgColor: const Color(0xFFFEE2E2),
      iconWidget: const Icon(
        LucideIcons.trendingDown,
        color: Color(0xFFEF4444),
        size: 17,
      ),
    );

    final card3 = _buildMacOsKpiCard(
      label: 'NET PROFIT',
      formattedValue: '₹${_formatNumber(_netProfit)}',
      accentColor: const Color(0xFF0EA5E9), // Cyan / Sky
      iconBgColor: const Color(0xFFE0F2FE),
      iconWidget: const Text(
        '₹',
        style: TextStyle(
          color: Color(0xFF0284C7),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    final card4 = _buildMacOsKpiCard(
      label: 'GST PAYABLE',
      formattedValue: '₹${_formatNumber(_gstPayable)}',
      accentColor: const Color(0xFF10B981), // Mint / Green
      iconBgColor: const Color(0xFFDCFCE7),
      iconWidget: const Icon(
        LucideIcons.shieldCheck,
        color: Color(0xFF10B981),
        size: 17,
      ),
      onTap: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.gst),
    );

    if (screenWidth >= 1050) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 16),
          Expanded(child: card2),
          const SizedBox(width: 16),
          Expanded(child: card3),
          const SizedBox(width: 16),
          Expanded(child: card4),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 14),
            Expanded(child: card2),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: card3),
            const SizedBox(width: 14),
            Expanded(child: card4),
          ],
        ),
      ],
    );
  }

  Widget _buildMacOsKpiCard({
    required String label,
    required String formattedValue,
    required Color accentColor,
    required Color iconBgColor,
    required Widget iconWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 126,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Top accent indicator bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(height: 3.5, color: accentColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Label and Icon Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.7,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: iconWidget),
                      ),
                    ],
                  ),
                  // Financial Amount Value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formattedValue,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.6,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  // Bottom Live Position Badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE POSITION',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacOsTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_tabLabels.length, (index) {
            final isSelected = _activeTab == index;

            Color selectedBg;
            if (index == 0) {
              selectedBg = const Color(0xFF4F46E5); // Indigo for P & L
            } else if (index == 1) {
              selectedBg = const Color(0xFF2563EB); // Blue for Balance Sheet
            } else if (index == 2) {
              selectedBg = const Color(0xFF7C3AED); // Purple for Receivables & Payables
            } else if (index == 3) {
              selectedBg = const Color(0xFFEF4444); // Red for Expenses
            } else if (index == 4) {
              selectedBg = const Color(0xFFF59E0B); // Amber for Cash & Bank
            } else if (index == 5) {
              selectedBg = const Color(0xFF059669); // Emerald for GST
            } else if (index == 6) {
              selectedBg = const Color(0xFF3B5998); // Slate for Day Book
            } else {
              selectedBg = const Color(0xFF166534);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => setState(() => _activeTab = index),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8.5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: selectedBg.withValues(alpha: 0.28),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _tabLabels[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMacOsActiveTabContent(double screenWidth) {
    switch (_activeTab) {
      case 0:
        if (screenWidth >= 1050) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildMacOsRevenueBreakdown()),
              const SizedBox(width: 20),
              Expanded(flex: 6, child: _buildMacOsExpenseBreakdown()),
            ],
          );
        }
        return Column(
          children: [
            _buildMacOsRevenueBreakdown(),
            const SizedBox(height: 20),
            _buildMacOsExpenseBreakdown(),
          ],
        );
      case 1:
        return _buildBalanceSheetTab(false, screenWidth);
      case 2:
        return _buildReceivablesPayablesTab(false, screenWidth);
      case 3:
        return _buildExpensesTab(false);
      case 4:
        return _buildCashBankTab(false, screenWidth);
      case 5:
        return _buildGSTTab(false, screenWidth);
      case 6:
        return _buildDayBookTab(false, screenWidth);
      default:
        if (screenWidth >= 1050) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildMacOsRevenueBreakdown()),
              const SizedBox(width: 20),
              Expanded(flex: 6, child: _buildMacOsExpenseBreakdown()),
            ],
          );
        }
        return Column(
          children: [
            _buildMacOsRevenueBreakdown(),
            const SizedBox(height: 20),
            _buildMacOsExpenseBreakdown(),
          ],
        );
    }
  }

  Widget _buildMacOsRevenueBreakdown() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
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
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.arrowUpRight,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Revenue Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3 Sources',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          _buildMacOsRevenueItem(
            label: 'Sales Revenue',
            amount: '₹10,00,00,07,06,880',
            pct: '100%',
          ),
          _buildMacOsRevenueItem(
            label: 'Service Income',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsRevenueItem(
            label: 'Other Income',
            amount: '₹0',
            pct: '0%',
          ),
        ],
      ),
    );
  }

  Widget _buildMacOsRevenueItem({
    required String label,
    required String amount,
    required String pct,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  fontFeatures: [FontFeature.tabularFigures()],
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: pct == '0%' ? const Color(0xFFF1F5F9) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  pct,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: pct == '0%' ? const Color(0xFF64748B) : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacOsExpenseBreakdown() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
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
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.arrowDownRight,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Expense Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '13 Categories',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          _buildMacOsExpenseItem(
            label: 'Office Expenses',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Rent & Utilities',
            amount: '₹30,000',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Salary & Wages',
            amount: '₹65,200',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Marketing & Advertising',
            amount: '₹50,000',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Travel & Meals',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Vehicle Expenses',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Software & Subscription',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Repairs & Maintenance',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Bank Charges',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Taxes & Government Fees',
            amount: '₹2,02,821.4',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Insurance',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Inventory Purchase',
            amount: '₹0',
            pct: '0%',
          ),
          _buildMacOsExpenseItem(
            label: 'Miscellaneous',
            amount: '₹9,85,18,696',
            pct: '100%',
          ),
        ],
      ),
    );
  }

  Widget _buildMacOsExpenseItem({
    required String label,
    required String amount,
    required String pct,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF991B1B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  fontFeatures: [FontFeature.tabularFigures()],
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: pct == '0%' ? const Color(0xFFFDE8E8) : const Color(0xFFFECDD3),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  pct,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAIN BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    // Modernized macOS Desktop Finance Dashboard
    if (isMacOS) {
      return _buildMacOsLayout(context, screenWidth);
    }

    // ─── MOBILE OS REDESIGNED VIEW (Matching Reports / Barcode / Marketing) ───
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton.extended(
          onPressed: () => _openRecordEntryModal(context),
          backgroundColor: const Color(0xFF166534),
          elevation: 4,
          icon: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
          label: const Text(
            'Record Entry',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting Style Header) ───
          SliverToBoxAdapter(
            child: _buildMobileHeroSummary()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.05, end: 0),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 6),
          ),

          // ─── STICKY TAB NAVIGATION BAR ───
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabNavDelegate(
              height: 42,
              child: Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _buildMobileTabNav(),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 6),
          ),

          // ─── MAIN CONTENT AREA ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 140),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0.0;
                  if (velocity < -250) {
                    if (_activeTab < 6) {
                      _changeMobileTab(_activeTab + 1);
                    }
                  } else if (velocity > 250) {
                    if (_activeTab > 0) {
                      _changeMobileTab(_activeTab - 1);
                    }
                  }
                },
                child: _buildActiveTabContent(true, screenWidth),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE HERO SUMMARY CARD (Matching Reports & Marketing)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileHeroSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
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
                        LucideIcons.calculator,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'FINANCE & GENERAL LEDGER',
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
                    const SizedBox(width: 3),
                    Text(
                      'LIVE AUDIT',
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
          // Horizontal scrollable KPI chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildHeroKpiChip(
                  'Gross Revenue',
                  '₹${_formatNumber(_grossRevenue)}',
                  LucideIcons.trendingUp,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'Total Expenses',
                  '₹${_formatNumber(_totalExpenses)}',
                  LucideIcons.trendingDown,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'Net Profit',
                  '₹${_formatNumber(_netProfit)}',
                  LucideIcons.lineChart,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'GST Payable',
                  '₹${_formatNumber(_gstPayable)}',
                  LucideIcons.percent,
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
                  fontSize: 8.5,
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

  // ═══════════════════════════════════════════════════════════════
  // MOBILE STICKY TAB NAVIGATION (Matching Reports / Marketing)
  // ═══════════════════════════════════════════════════════════════
  void _changeMobileTab(int index) {
    if (index < 0 || index > 6) return;
    setState(() => _activeTab = index);
    if (_mobileTabScrollController.hasClients) {
      final approxTabWidth = 105.0;
      final target = (index * approxTabWidth) - 50.0;
      _mobileTabScrollController.animateTo(
        target.clamp(0.0, _mobileTabScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildMobileTabNav() {
    final tabs = [
      const _AccountingTabItem('P & L', LucideIcons.lineChart),
      const _AccountingTabItem('Balance Sheet', LucideIcons.scale),
      const _AccountingTabItem('Receivables & Payables', LucideIcons.arrowLeftRight),
      const _AccountingTabItem('Expenses', LucideIcons.trendingDown),
      const _AccountingTabItem('Cash & Bank', LucideIcons.wallet),
      const _AccountingTabItem('GST', LucideIcons.percent),
      const _AccountingTabItem('Day Book', LucideIcons.bookOpen),
    ];

    return SizedBox(
      height: 38,
      child: SingleChildScrollView(
        controller: _mobileTabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _activeTab == index;
            final isLast = index == tabs.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 6),
              child: Builder(
                builder: (tabContext) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeTab = index);
                      Scrollable.ensureVisible(
                        tabContext,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: 0.5,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF166534) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF166534)
                              : const Color(0xFFE5E7EB),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF166534).withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[index].icon,
                            size: 12,
                            color: isSelected ? Colors.white : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tabs[index].label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMobileSectionFooter(int currentIndex) {
    const tabs = [
      _AccountingTabItem('P & L', LucideIcons.lineChart),
      _AccountingTabItem('Balance Sheet', LucideIcons.scale),
      _AccountingTabItem('Receivables & Payables', LucideIcons.arrowLeftRight),
      _AccountingTabItem('Expenses', LucideIcons.trendingDown),
      _AccountingTabItem('Cash & Bank', LucideIcons.wallet),
      _AccountingTabItem('GST', LucideIcons.percent),
      _AccountingTabItem('Day Book', LucideIcons.bookOpen),
    ];

    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < tabs.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasPrev)
            Expanded(
              child: InkWell(
                onTap: () => _changeMobileTab(currentIndex - 1),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.chevronLeft, size: 14, color: Color(0xFF166534)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'PREVIOUS',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '‹ ${tabs[currentIndex - 1].label}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 10),
          if (hasNext)
            Expanded(
              child: InkWell(
                onTap: () => _changeMobileTab(currentIndex + 1),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'NEXT',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${tabs[currentIndex + 1].label} ›',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF166534)),
                    ],
                  ),
                ),
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MACOS SOFT UI BENTO HERO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMacOsBentoHero(bool isMobile) {
    return MacOsSoftUiBentoHero(
      title: 'Accounting & Ledger',
      mainValue: '₹${_formatNumber(_netProfit)}',
      subtitle: 'Compliance-ready financial management and GST reporting',
      badgeText: 'AUDIT SYNCED',
      badgeIcon: LucideIcons.receiptText,
      isMobile: isMobile,
      chips: [
        MacOsBentoHeroChip(
          label: 'Gross Revenue',
          value: '₹${_formatNumber(_grossRevenue)}',
          icon: LucideIcons.trendingUp,
          accentColor: const Color(0xFF166534),
        ),
        MacOsBentoHeroChip(
          label: 'Total Expenses',
          value: '₹${_formatNumber(_totalExpenses)}',
          icon: LucideIcons.trendingDown,
          accentColor: const Color(0xFFEF4444),
        ),
        MacOsBentoHeroChip(
          label: 'GST Payable',
          value: '₹${_formatNumber(_gstPayable)}',
          icon: LucideIcons.percent,
          accentColor: const Color(0xFF2563EB),
        ),
        MacOsBentoHeroChip(
          label: 'Combined Balance',
          value: '₹${_formatNumber(_combinedBalance)}',
          icon: LucideIcons.wallet,
          accentColor: const Color(0xFFD97706),
        ),
      ],
      trailingAction: ElevatedButton.icon(
        onPressed: () => _openRecordEntryModal(context),
        icon: const Icon(LucideIcons.plus, size: 14),
        label: const Text(
          'Record Entry',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF166534),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. PAGE HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPageHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48), // Magenta/rose square
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Accounting',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Compliance-ready financial management and GST reporting.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openRecordEntryModal(context),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text(
                'Record Entry',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.fileText,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Accounting',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Compliance-ready financial management and GST reporting.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _openRecordEntryModal(context),
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text(
            'Record Entry',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. TOP 4 BENTO METRIC CARDS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopMetrics(double screenWidth) {
    final card1 = _buildTopKpiCard(
      label: 'GROSS REVENUE',
      value: '₹${_formatNumber(_grossRevenue)}',
      accentColor: const Color(0xFF8B5CF6), // Purple
      iconBgColor: const Color(0xFFF3E8FF),
      iconWidget: const Icon(
        LucideIcons.trendingUp,
        color: Color(0xFF8B5CF6),
        size: 18,
      ),
    );

    final card2 = _buildTopKpiCard(
      label: 'TOTAL EXPENSES',
      value: '₹${_formatNumber(_totalExpenses)}',
      accentColor: const Color(0xFFEF4444), // Red
      iconBgColor: const Color(0xFFFEE2E2),
      iconWidget: const Icon(
        LucideIcons.trendingDown,
        color: Color(0xFFEF4444),
        size: 18,
      ),
    );

    final card3 = _buildTopKpiCard(
      label: 'NET PROFIT',
      value: '₹${_formatNumber(_netProfit)}',
      accentColor: const Color(0xFF0EA5E9), // Cyan / Sky
      iconBgColor: const Color(0xFFE0F2FE),
      iconWidget: const Text(
        '₹',
        style: TextStyle(
          color: Color(0xFF0284C7),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    final card4 = _buildTopKpiCard(
      label: 'GST PAYABLE',
      value: '₹${_formatNumber(_gstPayable)}',
      accentColor: const Color(0xFF10B981), // Mint / Green
      iconBgColor: const Color(0xFFDCFCE7),
      iconWidget: const Icon(
        LucideIcons.shieldCheck,
        color: Color(0xFF10B981),
        size: 18,
      ),
      onTap: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.gst),
    );

    // Wide screen: 4 cards in a single row
    if (screenWidth >= 1100) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 14),
          Expanded(child: card2),
          const SizedBox(width: 14),
          Expanded(child: card3),
          const SizedBox(width: 14),
          Expanded(child: card4),
        ],
      );
    }

    // Tablet / Medium screen: 2x2 grid
    if (screenWidth >= 650) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 14),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 14),
              Expanded(child: card4),
            ],
          ),
        ],
      );
    }

    // Mobile: Stacked vertically
    return Column(
      children: [
        card1,
        const SizedBox(height: 12),
        card2,
        const SizedBox(height: 12),
        card3,
        const SizedBox(height: 12),
        card4,
      ],
    );
  }

  Widget _buildTopKpiCard({
    required String label,
    required String value,
    required Color accentColor,
    required Color iconBgColor,
    required Widget iconWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Top accent border indicator
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(height: 3.5, color: accentColor),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: iconWidget),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 5.5,
                        height: 5.5,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'LIVE POSITION',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ══════════════════════════════════════════════════════════════════════════
  // 3. TAB PILLS NAVIGATION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTabPills(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_tabLabels.length, (index) {
          final isSelected = _activeTab == index;

          // Color coding matching Image 1, 2, 3, 4, 5
          Color selectedBg;
          if (index == 0) {
            selectedBg = const Color(0xFF4F46E5); // Indigo for P & L (Image 1 & 2)
          } else if (index == 1) {
            selectedBg = const Color(0xFF2563EB); // Blue for Balance Sheet (Image 3)
          } else if (index == 2) {
            selectedBg = const Color(0xFF7C3AED); // Purple for Receivables & Payables (Image 4 & 5)
          } else if (index == 3) {
            selectedBg = const Color(0xFFEF4444); // Red for Expenses
          } else if (index == 4) {
            selectedBg = const Color(0xFFF59E0B); // Amber for Cash & Bank
          } else if (index == 5) {
            selectedBg = const Color(0xFF059669); // Emerald for GST
          } else if (index == 6) {
            selectedBg = const Color(0xFF3B5998); // Slate for Day Book
          } else {
            selectedBg = const Color(0xFF166534); // Forest Green for others
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _activeTab = index),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBg : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? selectedBg : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: selectedBg.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                ),
                child: Text(
                  _tabLabels[index],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. CONTENT ROUTER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildActiveTabContent(bool isMobile, double screenWidth) {
    Widget content;
    switch (_activeTab) {
      case 0:
        content = _buildPLTab(isMobile, screenWidth);
        break;
      case 1:
        content = _buildBalanceSheetTab(isMobile, screenWidth);
        break;
      case 2:
        content = _buildReceivablesPayablesTab(isMobile, screenWidth);
        break;
      case 3:
        content = _buildExpensesTab(isMobile);
        break;
      case 4:
        content = _buildCashBankTab(isMobile, screenWidth);
        break;
      case 5:
        content = _buildGSTTab(isMobile, screenWidth);
        break;
      case 6:
        content = _buildDayBookTab(isMobile, screenWidth);
        break;
      default:
        content = _buildPLTab(isMobile, screenWidth);
        break;
    }

    if (!isMobile) {
      return content;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content,
        const SizedBox(height: 12),
        _buildMobileSectionFooter(_activeTab),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 4: CASH & BANK (IMAGE 1)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCashBankTab(bool isMobile, double screenWidth) {
    // 4 Sub-metrics / Action cards:
    // 1. TOTAL CASH (₹0)
    // 2. TOTAL BANK BALANCE (₹5,05,000)
    // 3. TOTAL AVAILABLE FUNDS (₹5,05,000)
    // 4. ADD NEW BANK (Button)
    final cashCard = _buildCashBankMetricCard(
      label: 'TOTAL CASH',
      value: '₹${_formatNumber(_totalCashBalance)}',
      labelColor: const Color(0xFF16A34A),
      valueColor: const Color(0xFF15803D),
      bgColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFDCFCE7),
    );

    final bankCard = _buildCashBankMetricCard(
      label: 'TOTAL BANK BALANCE',
      value: '₹${_formatNumber(_totalBankBalance)}',
      labelColor: const Color(0xFF2563EB),
      valueColor: const Color(0xFF1D4ED8),
      bgColor: const Color(0xFFEFF6FF),
      borderColor: const Color(0xFFBFDBFE),
    );

    final fundsCard = _buildCashBankMetricCard(
      label: 'TOTAL AVAILABLE FUNDS',
      value: '₹${_formatNumber(_totalAvailableFunds)}',
      labelColor: const Color(0xFF4F46E5),
      valueColor: const Color(0xFF4338CA),
      bgColor: const Color(0xFFEEF2FF),
      borderColor: const Color(0xFFC7D2FE),
    );

    final addBankCard = InkWell(
      onTap: () => _openAddBankModal(context),
      borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
      child: Container(
        height: isMobile ? 64 : 84,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Text(
          'ADD NEW BANK',
          style: TextStyle(
            fontSize: isMobile ? 12 : 13.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFDC2626),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );

    Widget subCardsLayout;
    if (screenWidth >= 1050) {
      subCardsLayout = Row(
        children: [
          Expanded(child: cashCard),
          const SizedBox(width: 14),
          Expanded(child: bankCard),
          const SizedBox(width: 14),
          Expanded(child: fundsCard),
          const SizedBox(width: 14),
          Expanded(child: addBankCard),
        ],
      );
    } else if (screenWidth >= 600) {
      subCardsLayout = Column(
        children: [
          Row(
            children: [
              Expanded(child: cashCard),
              const SizedBox(width: 14),
              Expanded(child: bankCard),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: fundsCard),
              const SizedBox(width: 14),
              Expanded(child: addBankCard),
            ],
          ),
        ],
      );
    } else {
      subCardsLayout = Column(
        children: [
          Row(
            children: [
              Expanded(child: cashCard),
              const SizedBox(width: 8),
              Expanded(child: bankCard),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: fundsCard),
              const SizedBox(width: 8),
              Expanded(child: addBankCard),
            ],
          ),
        ],
      );
    }

    // Bank Accounts Grid (Cards 1 and 2 in Image 1)
    Widget bankCardsGrid;
    if (screenWidth >= 850) {
      bankCardsGrid = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _bankAccounts.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: _buildBankAccountCard(_bankAccounts[i], i == 0, isMobile)),
          ],
        ],
      );
    } else {
      bankCardsGrid = Column(
        children: [
          for (int i = 0; i < _bankAccounts.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildBankAccountCard(_bankAccounts[i], i == 0, isMobile),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [subCardsLayout, SizedBox(height: isMobile ? 14 : 22), bankCardsGrid],
    );
  }

  Widget _buildCashBankMetricCard({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: valueColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountCard(_BankAccountData bank, bool isPrimaryCard, [bool isMobile = false]) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: isPrimaryCard
              ? const Color(0xFF3B82F6)
              : const Color(0xFFE2E8F0),
          width: isPrimaryCard ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Bank Icon + 3 dots menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.landmark,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  LucideIcons.moreHorizontal,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
                onSelected: (val) {
                  if (val == 'history') {
                    _openBankHistoryModal(context, bank);
                  } else if (val == 'delete') {
                    setState(
                      () => _bankAccounts.removeWhere((b) => b.id == bank.id),
                    );
                    AppSnackbar.show(
                      context,
                      'Bank account removed',
                      type: SnackType.info,
                    );
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'history',
                    child: Text('View Statements'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Account Name
          Text(
            bank.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),

          // Holder / Branch
          Text(
            bank.holder,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Total Income row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total Income:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '₹${_formatNumber(bank.income)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Total Expenses row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Total Expenses:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '₹${_formatNumber(bank.expenses)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Last Transaction row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Last Transaction:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    bank.lastTxn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bottom row: BALANCE & History Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BALANCE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹${_formatNumber(bank.balance)}',
                        style: TextStyle(
                          fontSize: isMobile ? 17 : 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2563EB),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isPrimaryCard)
                ElevatedButton(
                  onPressed: () => _openBankHistoryModal(context, bank),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 18,
                      vertical: isMobile ? 6 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'History',
                    style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () => _openBankHistoryModal(context, bank),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: const Color(0xFFF8FAFC),
                    foregroundColor: const Color(0xFF2563EB),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 18,
                      vertical: isMobile ? 6 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'History',
                    style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 5: GST (IMAGE 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildGSTTab(bool isMobile, double screenWidth) {
    final gstr1Card = _buildGstBentoCard(
      title: 'GSTR-1 Summary',
      period: 'Period: October 2026',
      badgeText: 'Action Needed',
      badgeColor: const Color(0xFFD97706),
      badgeBgColor: const Color(0xFFFEF3C7),
      amount: '₹3,96,22,49,874.28',
      isMobile: isMobile,
      onViewDetail: () =>
          ref.read(navigationProvider.notifier).setRoute(AppRoute.gst),
    );

    final gstr3bCard = _buildGstBentoCard(
      title: 'GSTR-3B Summary',
      period: 'Period: October 2026',
      badgeText: 'Ready',
      badgeColor: const Color(0xFFD97706),
      badgeBgColor: const Color(0xFFFEF3C7),
      amount: '₹0',
      isMobile: isMobile,
      onViewDetail: () =>
          ref.read(navigationProvider.notifier).setRoute(AppRoute.gst),
    );

    final itcCard = _buildGstBentoCard(
      title: 'ITC Summary',
      period: 'Period: October 2026',
      badgeText: 'Auto-populated',
      badgeColor: const Color(0xFFD97706),
      badgeBgColor: const Color(0xFFFEF3C7),
      amount: '₹9,18,822',
      isMobile: isMobile,
      onViewDetail: () =>
          ref.read(navigationProvider.notifier).setRoute(AppRoute.gst),
    );

    if (screenWidth >= 980) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: gstr1Card),
          const SizedBox(width: 16),
          Expanded(child: gstr3bCard),
          const SizedBox(width: 16),
          Expanded(child: itcCard),
        ],
      );
    }

    return Column(
      children: [
        if (isMobile)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.percent, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full GST Compliance Portal',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'File GSTR-1, GSTR-3B & Reconcile GSTR-2A/2B',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.gst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  icon: const Icon(LucideIcons.arrowRight, size: 12),
                  label: const Text('Open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        gstr1Card,
        const SizedBox(height: 14),
        gstr3bCard,
        const SizedBox(height: 14),
        itcCard,
      ],
    );
  }

  Widget _buildGstBentoCard({
    required String title,
    required String period,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBgColor,
    required String amount,
    required VoidCallback onViewDetail,
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: File icon + Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: isMobile ? 30 : 36,
                height: isMobile ? 30 : 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.fileText,
                  color: const Color(0xFF2563EB),
                  size: isMobile ? 15 : 18,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 10,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: isMobile ? 9.5 : 10.5,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 16),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 13.5 : 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),

          // Period
          Text(
            period,
            style: TextStyle(fontSize: isMobile ? 10.5 : 11.5, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: isMobile ? 14 : 22),

          // Bottom Row: Amount + VIEW DETAIL link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2563EB),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onViewDetail,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'VIEW DETAIL',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 6: DAY BOOK TABLE (IMAGE 3)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDayBookTab(bool isMobile, double screenWidth) {
    final tableWidget = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: math.max(
                screenWidth - (isMobile ? 24 : 56),
                isMobile ? 620 : 750,
              ),
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              dataRowMinHeight: isMobile ? 48 : 50,
              dataRowMaxHeight: isMobile ? 52 : 54,
              headingRowHeight: isMobile ? 42 : 46,
              horizontalMargin: isMobile ? 14 : 20,
              columnSpacing: isMobile ? 18 : 28,
              border: const TableBorder(
                horizontalInside: BorderSide(
                  color: Color(0xFFF1F5F9),
                  width: 1.0,
                ),
              ),
              columns: [
                DataColumn(
                  label: _buildSortableHeader('DATE', 'date'),
                  onSort: (columnIndex, ascending) => _sortDayBook('date'),
                ),
                DataColumn(
                  label: _buildSortableHeader('CATEGORY', 'category'),
                  onSort: (columnIndex, ascending) => _sortDayBook('category'),
                ),
                DataColumn(
                  label: _buildSortableHeader('MODE', 'mode'),
                  onSort: (columnIndex, ascending) => _sortDayBook('mode'),
                ),
                DataColumn(
                  label: _buildSortableHeader('TYPE', 'type'),
                  onSort: (columnIndex, ascending) => _sortDayBook('type'),
                ),
                DataColumn(
                  label: _buildSortableHeader('AMOUNT', 'amount'),
                  numeric: true,
                  onSort: (columnIndex, ascending) => _sortDayBook('amount'),
                ),
              ],
              rows: _dayBookRecords.map((item) {
                final isExpense = item.type == 'EXPENSE';

                // Row background: special soft pink tint if item.isSpecialHighlight
                final rowBgColor = item.isSpecialHighlight
                    ? const Color(0xFFFDF2F8)
                    : Colors.white;

                return DataRow(
                  color: WidgetStateProperty.all(rowBgColor),
                  cells: [
                    // DATE
                    DataCell(
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),

                    // CATEGORY
                    DataCell(
                      Text(
                        item.category,
                        style: TextStyle(
                          fontSize: isMobile ? 12.5 : 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    // MODE (Pill)
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 10,
                          vertical: isMobile ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.mode,
                          style: TextStyle(
                            fontSize: isMobile ? 10.5 : 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),

                    // TYPE (Pill with arrow)
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 10,
                          vertical: isMobile ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: isExpense
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isExpense ? '↘ ' : '↗ ',
                              style: TextStyle(
                                fontSize: isMobile ? 10.5 : 11,
                                fontWeight: FontWeight.bold,
                                color: isExpense
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF15803D),
                              ),
                            ),
                            Text(
                              item.type,
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 10.5,
                                fontWeight: FontWeight.w800,
                                color: isExpense
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF15803D),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // AMOUNT
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '₹${_formatIndianCurrency(item.amount)}',
                          style: TextStyle(
                            fontSize: isMobile ? 12.5 : 13.5,
                            fontWeight: FontWeight.w800,
                            color: isExpense
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF15803D),
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
    );

    if (!isMobile) {
      return tableWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(LucideIcons.arrowLeftRight, size: 12, color: Color(0xFF64748B)),
                  SizedBox(width: 5),
                  Text(
                    'Swipe horizontally to view all columns',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_dayBookRecords.length} records',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
        tableWidget,
      ],
    );
  }

  Widget _buildMobileDayBookCardList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort & Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildMobileSortChip('DATE', 'date'),
              const SizedBox(width: 6),
              _buildMobileSortChip('CATEGORY', 'category'),
              const SizedBox(width: 6),
              _buildMobileSortChip('MODE', 'mode'),
              const SizedBox(width: 6),
              _buildMobileSortChip('TYPE', 'type'),
              const SizedBox(width: 6),
              _buildMobileSortChip('AMOUNT', 'amount'),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (_dayBookRecords.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: const [
                Icon(LucideIcons.bookOpen, size: 32, color: Color(0xFF94A3B8)),
                SizedBox(height: 10),
                Text(
                  'No transactions recorded in Day Book.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          ..._dayBookRecords.map((item) {
            final isExpense = item.type == 'EXPENSE';
            final rowBgColor = item.isSpecialHighlight
                ? const Color(0xFFFDF2F8)
                : Colors.white;
            final borderColor = item.isSpecialHighlight
                ? const Color(0xFFFBCFE8)
                : const Color(0xFFE2E8F0);

            final formattedAmount = item.amount.truncateToDouble() == item.amount
                ? item.amount.toInt().toString()
                : item.amount.toStringAsFixed(2);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rowBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${isExpense ? '-' : '+'}₹$formattedAmount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isExpense
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Mode badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              item.mode,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isExpense
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isExpense ? '↘ ' : '↗ ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isExpense
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF15803D),
                                  ),
                                ),
                                Text(
                                  item.type,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: isExpense
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF15803D),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMobileSortChip(String label, String colKey) {
    final isSelected = _sortColumn == colKey;
    return InkWell(
      onTap: () => _sortDayBook(colKey),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 3),
              Icon(
                _sortAscending ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                size: 11,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortableHeader(String title, String colKey) {
    final isSelected = _sortColumn == colKey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? const Color(0xFF1E293B)
                : const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE2E8F0) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          child: Icon(
            isSelected
                ? (_sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown)
                : LucideIcons.chevronDown,
            size: 10,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  void _sortDayBook(String colKey) {
    setState(() {
      if (_sortColumn == colKey) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = colKey;
        _sortAscending = true;
      }

      _dayBookRecords.sort((a, b) {
        int cmp = 0;
        switch (colKey) {
          case 'date':
            cmp = a.date.compareTo(b.date);
            break;
          case 'category':
            cmp = a.category.compareTo(b.category);
            break;
          case 'mode':
            cmp = a.mode.compareTo(b.mode);
            break;
          case 'type':
            cmp = a.type.compareTo(b.type);
            break;
          case 'amount':
            cmp = a.amount.compareTo(b.amount);
            break;
        }
        return _sortAscending ? cmp : -cmp;
      });
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 0: P & L (IMAGES 1 & 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPLTab(bool isMobile, double screenWidth) {
    final revenueCard = Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.arrowUpRight,
                color: const Color(0xFF10B981),
                size: isMobile ? 17 : 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Revenue Breakdown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 18),
          _buildPLRevenueItem(
            label: 'Sales Revenue',
            amount: '₹10,00,00,07,06,880',
            pct: '100%',
            isMobile: isMobile,
          ),
          _buildPLRevenueItem(
            label: 'Service Income',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLRevenueItem(
            label: 'Other Income',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
        ],
      ),
    );

    final expenseCard = Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.arrowDownRight,
                color: const Color(0xFFEF4444),
                size: isMobile ? 17 : 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Expense Breakdown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 18),
          _buildPLExpenseItem(
            label: 'Office Expenses',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Rent & Utilities',
            amount: '₹30,000',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Salary & Wages',
            amount: '₹65,200',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Marketing & Advertising',
            amount: '₹50,000',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Travel & Meals',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Vehicle Expenses',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Software & Subscription',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Repairs & Maintenance',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Bank Charges',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Taxes & Government Fees',
            amount: '₹2,02,821.4',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Insurance',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Inventory Purchase',
            amount: '₹0',
            pct: '0%',
            isMobile: isMobile,
          ),
          _buildPLExpenseItem(
            label: 'Miscellaneous',
            amount: '₹9,85,18,696',
            pct: '100%',
            isMobile: isMobile,
          ),
        ],
      ),
    );

    if (screenWidth >= 950) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: revenueCard),
          const SizedBox(width: 20),
          Expanded(flex: 5, child: expenseCard),
        ],
      );
    }

    return Column(
      children: [
        revenueCard,
        SizedBox(height: isMobile ? 12 : 20),
        expenseCard,
      ],
    );
  }

  Widget _buildPLRevenueItem({
    required String label,
    required String amount,
    required String pct,
    bool isMobile = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 7 : 12),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 16,
        vertical: isMobile ? 8 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 11.5 : 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($pct)',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPLExpenseItem({
    required String label,
    required String amount,
    required String pct,
    bool isMobile = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 10),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 16,
        vertical: isMobile ? 7 : 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 11.5 : 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF991B1B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($pct)',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: BALANCE SHEET (IMAGE 3)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBalanceSheetTab(bool isMobile, double screenWidth) {
    final assetsCard = Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
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
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.briefcase,
                      color: const Color(0xFF2563EB),
                      size: isMobile ? 17 : 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Assets',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _openLedgerSettingsModal(context, 'Assets'),
                icon: Icon(
                  LucideIcons.settings,
                  color: const Color(0xFF94A3B8),
                  size: isMobile ? 15 : 17,
                ),
                tooltip: 'Asset Settings',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 18),
          _buildBalanceSheetRow(
            label: 'Cash in Hand',
            amount: '₹0',
            isPink: false,
            isMobile: isMobile,
          ),
          _buildBalanceSheetRow(
            label: 'Bank Balance',
            amount: '₹5,05,000',
            isPink: false,
            isMobile: isMobile,
          ),
          _buildBalanceSheetRow(
            label: 'Inventory Value',
            amount: '₹80,87,81,36,83,773.3',
            isPink: false,
            isMobile: isMobile,
          ),
          _buildBalanceSheetRow(
            label: 'Accounts Receivable',
            amount: '₹9,18,822',
            isPink: false,
            isMobile: isMobile,
          ),
          _buildBalanceSheetRow(
            label: 'Fixed Assets',
            amount: '₹0',
            isPink: false,
            isMobile: isMobile,
          ),
          const SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 16,
              vertical: isMobile ? 9 : 15,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Assets',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 12.5 : 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '₹80,87,81,51,07,595.3',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final liabilitiesCard = Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
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
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.scale,
                      color: const Color(0xFFEF4444),
                      size: isMobile ? 17 : 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Liabilities & Equity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    _openLedgerSettingsModal(context, 'Liabilities & Equity'),
                icon: Icon(
                  LucideIcons.settings,
                  color: const Color(0xFF94A3B8),
                  size: isMobile ? 15 : 17,
                ),
                tooltip: 'Liabilities Settings',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 18),
          _buildBalanceSheetRow(
            label: 'Accounts Payable',
            amount: '₹-9,71,63,707',
            isPink: true,
            isMobile: isMobile,
          ),
          _buildBalanceSheetRow(
            label: 'GST Payable',
            amount: '₹3,96,22,49,874.28',
            isPink: true,
            isMobile: isMobile,
          ),
          _buildBalanceSheetRow(
            label: 'Loans / Credit',
            amount: '₹0',
            isPink: true,
            isMobile: isMobile,
          ),
          _buildBalanceSheetRow(
            label: "Owner's Equity",
            amount: '₹90,83,84,88,49,264.62',
            isPink: true,
            isMobile: isMobile,
          ),
          _buildBalanceSheetRow(
            label: 'Retained Earnings',
            amount: '₹0',
            isPink: true,
            isMobile: isMobile,
          ),
          const SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 16,
              vertical: isMobile ? 9 : 15,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Liab. & Equity',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 12.5 : 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '₹90,87,71,39,35,431.9',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (screenWidth >= 950) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: assetsCard),
          const SizedBox(width: 20),
          Expanded(child: liabilitiesCard),
        ],
      );
    }

    return Column(
      children: [
        assetsCard,
        SizedBox(height: isMobile ? 12 : 20),
        liabilitiesCard,
      ],
    );
  }

  Widget _buildBalanceSheetRow({
    required String label,
    required String amount,
    required bool isPink,
    bool isMobile = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 10),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 16,
        vertical: isMobile ? 8 : 14,
      ),
      decoration: BoxDecoration(
        color: isPink ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: isPink ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 11.5 : 13.5,
                fontWeight: FontWeight.w600,
                color:
                    isPink ? const Color(0xFF991B1B) : const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                amount,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: RECEIVABLES & PAYABLES (IMAGES 4 & 5)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildReceivablesPayablesTab(bool isMobile, double screenWidth) {
    // 1. Top Overdue Reminder Banner (Image 4)
    final overdueBanner = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.bell,
            color: const Color(0xFFE11D48),
            size: isMobile ? 16 : 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have $_overdueInvoicesCount invoice(s) overdue for a total amount of ₹${_formatIndianCurrency(_overdueAmount)}. Please send reminders.',
              style: TextStyle(
                fontSize: isMobile ? 11.5 : 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFBE123C),
              ),
            ),
          ),
        ],
      ),
    );

    // 2. 5 Mini Summary Cards (Image 4)
    final card1 = _buildRpMiniCard(
      label: 'TOTAL RECEIVABLES',
      value: '₹${_formatIndianCurrency(_totalReceivables)}',
      subtitle: '25 Pending Invoices',
      labelColor: const Color(0xFF7C3AED),
      valueColor: const Color(0xFF5B21B6),
      bgColor: const Color(0xFFF5F3FF),
      borderColor: const Color(0xFFDDD6FE),
      isMobile: isMobile,
    );

    final card2 = _buildRpMiniCard(
      label: 'OVERDUE AMOUNT',
      value: '₹${_formatIndianCurrency(_overdueAmount)}',
      subtitle: '25 Overdue Invoices',
      labelColor: const Color(0xFFDC2626),
      valueColor: const Color(0xFF991B1B),
      bgColor: const Color(0xFFFEF2F2),
      borderColor: const Color(0xFFFECACA),
      isMobile: isMobile,
    );

    final card3 = _buildRpMiniCard(
      label: 'DUE TODAY',
      value: '₹0',
      subtitle: '0 Due Today',
      labelColor: const Color(0xFFCA8A04),
      valueColor: const Color(0xFF854D0E),
      bgColor: const Color(0xFFFEFCE8),
      borderColor: const Color(0xFFFEF08A),
      isMobile: isMobile,
    );

    final card4 = _buildRpMiniCard(
      label: 'DUE THIS WEEK',
      value: '₹0',
      subtitle: '0 Due in 7 days',
      labelColor: const Color(0xFF0284C7),
      valueColor: const Color(0xFF0369A1),
      bgColor: const Color(0xFFF0F9FF),
      borderColor: const Color(0xFFBAE6FD),
      isMobile: isMobile,
    );

    final card5 = _buildRpMiniCard(
      label: 'CUSTOMERS WITH DUES',
      value: '2',
      subtitle: 'Unique customer profiles',
      labelColor: const Color(0xFF16A34A),
      valueColor: const Color(0xFF15803D),
      bgColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFBBF7D0),
      isMobile: isMobile,
    );

    Widget miniCardsLayout;
    if (screenWidth >= 1150) {
      miniCardsLayout = Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 12),
          Expanded(child: card2),
          const SizedBox(width: 12),
          Expanded(child: card3),
          const SizedBox(width: 12),
          Expanded(child: card4),
          const SizedBox(width: 12),
          Expanded(child: card5),
        ],
      );
    } else if (screenWidth >= 650) {
      miniCardsLayout = Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 12),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 12),
              Expanded(child: card4),
              const SizedBox(width: 12),
              Expanded(child: card5),
            ],
          ),
        ],
      );
    } else {
      miniCardsLayout = Column(
        children: [
          Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 8),
              Expanded(child: card2),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: card3),
              const SizedBox(width: 8),
              Expanded(child: card4),
            ],
          ),
          const SizedBox(height: 8),
          card5,
        ],
      );
    }

    // 3. Lower Section: Left Aging Report + Right Party-wise Outstanding Table
    final agingReportCard = Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aging Report (Receivables)',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: isMobile ? 10 : 16),
          // Progress bar (Amber/Orange segment)
          Container(
            height: isMobile ? 8 : 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 18),
          _buildAgingRow(
            dotColor: const Color(0xFF10B981),
            label: 'Current (Not Due)',
            amount: '₹0',
            invCount: '0 inv',
            isMobile: isMobile,
          ),
          _buildAgingRow(
            dotColor: const Color(0xFFF59E0B),
            label: '1-30 Days',
            amount: '₹9,18,822',
            invCount: '25 inv',
            isMobile: isMobile,
          ),
          _buildAgingRow(
            dotColor: const Color(0xFFEF4444),
            label: '31-60 Days',
            amount: '₹0',
            invCount: '0 inv',
            isMobile: isMobile,
          ),
          _buildAgingRow(
            dotColor: const Color(0xFFDC2626),
            label: '61-90 Days',
            amount: '₹0',
            invCount: '0 inv',
            isMobile: isMobile,
          ),
          _buildAgingRow(
            dotColor: const Color(0xFF991B1B),
            label: 'Above 90 Days',
            amount: '₹0',
            invCount: '0 inv',
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 18),
          // Total Receivables Purple Summary Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(color: const Color(0xFFEDE9FE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL RECEIVABLES',
                  style: TextStyle(
                    fontSize: isMobile ? 9.5 : 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7C3AED),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '₹${_formatIndianCurrency(_totalReceivables)}',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF5B21B6),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '25 Pending Invoices',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 10.5 : 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Updated: 15:14:18',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final partyTableCard = Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title + 3 Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Party-wise Outstanding',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _rpSearchController.clear();
                        _rpMinController.clear();
                        _rpMaxController.clear();
                        _rpSelectedStatus = 'All Statuses';
                        _rpFromDate = null;
                        _rpToDate = null;
                      });
                      AppSnackbar.show(
                        context,
                        'Showing all party records',
                        type: SnackType.info,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: isMobile ? 5 : 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Text(
                        'VIEW ALL PARTY',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4F46E5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AppSnackbar.show(
                        context,
                        'Exporting Party Outstandings to Excel (.xlsx)...',
                        type: SnackType.success,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 5 : 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.fileSpreadsheet,
                            size: 14,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Excel',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AppSnackbar.show(
                        context,
                        'Exporting Party Outstandings to CSV (.csv)...',
                        type: SnackType.success,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 5 : 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.fileText,
                            size: 14,
                            color: Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CSV',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 16),

          // Filter Controls Container (Image 4)
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                if (isMobile) ...[
                  // Mobile Row 1: Search field (full width)
                  Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.search,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _rpSearchController,
                            style: const TextStyle(fontSize: 11.5),
                            decoration: const InputDecoration(
                              hintText: 'Search client/invoice...',
                              hintStyle: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
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
                  const SizedBox(height: 6),
                  // Mobile Row 2: Status dropdown + Date range picker
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _rpSelectedStatus,
                              isExpanded: true,
                              icon: const Icon(
                                LucideIcons.chevronDown,
                                size: 13,
                                color: Color(0xFF64748B),
                              ),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'All Statuses',
                                  child: Text('All Statuses', overflow: TextOverflow.ellipsis),
                                ),
                                DropdownMenuItem(
                                  value: 'Paid',
                                  child: Text('Paid'),
                                ),
                                DropdownMenuItem(
                                  value: 'Overdue',
                                  child: Text('Overdue'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _rpSelectedStatus = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              initialDateRange: _rpFromDate != null &&
                                      _rpToDate != null
                                  ? DateTimeRange(
                                      start: _rpFromDate!, end: _rpToDate!)
                                  : null,
                            );
                            if (picked != null) {
                              setState(() {
                                _rpFromDate = picked.start;
                                _rpToDate = picked.end;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _rpFromDate == null
                                        ? 'dd/mm/yyyy'
                                        : '${_rpFromDate!.day}/${_rpFromDate!.month}/${_rpFromDate!.year}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    LucideIcons.calendar,
                                    size: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      'to',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _rpToDate == null
                                        ? 'dd/mm/yyyy'
                                        : '${_rpToDate!.day}/${_rpToDate!.month}/${_rpToDate!.year}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    LucideIcons.calendar,
                                    size: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Mobile Row 3: Min ₹ & Max ₹
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: TextField(
                            controller: _rpMinController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 11.5),
                            decoration: InputDecoration(
                              hintText: 'Min ₹',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: TextField(
                            controller: _rpMaxController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 11.5),
                            decoration: InputDecoration(
                              hintText: 'Max ₹',
                              hintStyle: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Desktop Rows (Preserved completely)
                  Row(
                    children: [
                      // Search client/invoice
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.search,
                                size: 15,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _rpSearchController,
                                  style: const TextStyle(fontSize: 12.5),
                                  decoration: const InputDecoration(
                                    hintText: 'Search client/invoice...',
                                    hintStyle: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
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
                      ),
                      const SizedBox(width: 8),

                      // Status Dropdown
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _rpSelectedStatus,
                            icon: const Icon(
                              LucideIcons.chevronDown,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'All Statuses',
                                child: Text('All Statuses'),
                              ),
                              DropdownMenuItem(
                                value: 'Paid',
                                child: Text('Paid'),
                              ),
                              DropdownMenuItem(
                                value: 'Overdue',
                                child: Text('Overdue'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _rpSelectedStatus = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Date range picker
                      InkWell(
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDateRange: _rpFromDate != null &&
                                    _rpToDate != null
                                ? DateTimeRange(
                                    start: _rpFromDate!, end: _rpToDate!)
                                : null,
                          );
                          if (picked != null) {
                            setState(() {
                              _rpFromDate = picked.start;
                              _rpToDate = picked.end;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _rpFromDate == null
                                    ? 'dd/mm/yyyy'
                                    : '${_rpFromDate!.day}/${_rpFromDate!.month}/${_rpFromDate!.year}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                LucideIcons.calendar,
                                size: 13,
                                color: Color(0xFF64748B),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  'to',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              Text(
                                _rpToDate == null
                                    ? 'dd/mm/yyyy'
                                    : '${_rpToDate!.day}/${_rpToDate!.month}/${_rpToDate!.year}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                LucideIcons.calendar,
                                size: 13,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 36,
                        child: TextField(
                          controller: _rpMinController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Min ₹',
                            hintStyle: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        height: 36,
                        child: TextField(
                          controller: _rpMaxController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Max ₹',
                            hintStyle: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Invoices Table: mobile card list on mobile, horizontal scroll table on desktop/macOS
          if (isMobile)
            _buildMobileInvoicesList()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 780,
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: isMobile ? 8 : 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: isMobile ? 110 : 150,
                          child: Text(
                            'PARTY NAME',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 85 : 120,
                          child: Text(
                            'INV NUMBER',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 75 : 110,
                          child: Text(
                            'DUE DATE',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 95 : 130,
                          child: Text(
                            'PENDING AMOUNT',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 70 : 90,
                          child: Text(
                            'STATUS',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 180 : 200,
                          child: Text(
                            'ACTIONS',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Rows
                  if (_filteredInvoices.isEmpty)
                    Container(
                      width: isMobile ? 620 : 760,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: const [
                          Icon(
                            LucideIcons.searchX,
                            size: 32,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No matching invoices found.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._filteredInvoices.map((inv) {
                      final isOverdue = inv['status'] == 'Overdue';
                      final pendingAmt =
                          (inv['pendingAmount'] as num).toDouble();

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: isMobile ? 7 : 12,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: isMobile ? 110 : 150,
                              child: Text(
                                inv['partyName'] ?? '',
                                style: TextStyle(
                                  fontSize: isMobile ? 11.5 : 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? 85 : 120,
                              child: Text(
                                inv['invNumber'] ?? '',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? 75 : 110,
                              child: Text(
                                inv['dueDate'] ?? '',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? 95 : 130,
                              child: Text(
                                '₹${_formatIndianCurrency(pendingAmt)}',
                                style: TextStyle(
                                  fontSize: isMobile ? 11.5 : 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? 70 : 90,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 6 : 8,
                                    vertical: isMobile ? 2 : 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOverdue
                                        ? const Color(0xFFFEE2E2)
                                        : const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    inv['status'] ?? '',
                                    style: TextStyle(
                                      fontSize: isMobile ? 9.5 : 11,
                                      fontWeight: FontWeight.bold,
                                      color: isOverdue
                                          ? const Color(0xFF991B1B)
                                          : const Color(0xFF166534),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isMobile ? 180 : 200,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _showInvoiceDetailsModal(context, inv),
                                    icon: Icon(
                                      LucideIcons.eye,
                                      size: isMobile ? 14 : 16,
                                      color: const Color(0xFF64748B),
                                    ),
                                    tooltip: 'View Invoice',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  if (isOverdue) ...[
                                    SizedBox(width: isMobile ? 6 : 8),
                                    InkWell(
                                      onTap: () =>
                                          _showRecordPaymentModal(context, inv),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isMobile ? 6 : 8,
                                          vertical: isMobile ? 3 : 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEDE9FE),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFFDDD6FE),
                                          ),
                                        ),
                                        child: Text(
                                          'Record\nPayment',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isMobile ? 9 : 10,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF6D28D9),
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 6 : 8),
                                    InkWell(
                                      onTap: () {
                                        AppSnackbar.show(
                                          context,
                                          'Payment reminder sent to ${inv['partyName']} (${inv['invNumber']}) via WhatsApp & SMS',
                                          type: SnackType.success,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: EdgeInsets.all(isMobile ? 4 : 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFFBAE6FD),
                                          ),
                                        ),
                                        child: Icon(
                                          LucideIcons.send,
                                          size: isMobile ? 11 : 13,
                                          color: const Color(0xFF0284C7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        overdueBanner,
        const SizedBox(height: 16),
        miniCardsLayout,
        const SizedBox(height: 20),
        if (screenWidth >= 950)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: agingReportCard),
              const SizedBox(width: 20),
              Expanded(flex: 6, child: partyTableCard),
            ],
          )
        else
          Column(
            children: [
              agingReportCard,
              const SizedBox(height: 20),
              partyTableCard,
            ],
          ),
      ],
    );
  }

  Widget _buildMobileInvoicesList() {
    if (_filteredInvoices.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(LucideIcons.searchX, size: 32, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text(
              'No matching invoices found.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _filteredInvoices.map((inv) {
        final isOverdue = inv['status'] == 'Overdue';
        final pendingAmt = (inv['pendingAmount'] as num).toDouble();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Party name & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      inv['partyName'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      inv['status'] ?? '',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isOverdue
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Invoice No & Due Date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      inv['invNumber'] ?? '',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 11,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'Due: ${inv['dueDate'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹${_formatIndianCurrency(pendingAmt)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Row 3: Action Buttons
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  InkWell(
                    onTap: () => _showInvoiceDetailsModal(context, inv),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            LucideIcons.eye,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOverdue) ...[
                    InkWell(
                      onTap: () => _showRecordPaymentModal(context, inv),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              LucideIcons.creditCard,
                              size: 11,
                              color: Color(0xFF6D28D9),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Payment',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6D28D9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        AppSnackbar.show(
                          context,
                          'Payment reminder sent to ${inv['partyName']} (${inv['invNumber']}) via WhatsApp & SMS',
                          type: SnackType.success,
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              LucideIcons.send,
                              size: 11,
                              color: Color(0xFF0284C7),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Remind',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRpMiniCard({
    required String label,
    required String value,
    required String subtitle,
    required Color labelColor,
    required Color valueColor,
    required Color bgColor,
    required Color borderColor,
    bool isMobile = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 8.5 : 10,
              fontWeight: FontWeight.w800,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 14 : 18,
                fontWeight: FontWeight.w900,
                color: valueColor,
                letterSpacing: -0.4,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isMobile ? 9 : 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingRow({
    required Color dotColor,
    required String label,
    required String amount,
    required String invCount,
    bool isMobile = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
      child: Row(
        children: [
          Container(
            width: isMobile ? 6 : 7,
            height: isMobile ? 6 : 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($invCount)',
                    style: TextStyle(
                      fontSize: isMobile ? 9.5 : 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DIALOGS & ACTION HANDLERS
  // ══════════════════════════════════════════════════════════════════════════
  void _openLedgerSettingsModal(BuildContext context, String section) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$section Ledger Setup',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(LucideIcons.x, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage and customize account classification heads for $section.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Auto-reconcile balance with active ledger',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: true,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (v) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      AppSnackbar.show(
                        context,
                        '$section settings updated successfully',
                        type: SnackType.success,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInvoiceDetailsModal(
    BuildContext context,
    Map<String, dynamic> inv,
  ) {
    final isPaid = inv['status'] == 'Paid';
    final amt = (inv['pendingAmount'] as num).toDouble();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv['invNumber'] ?? 'Invoice Details',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Party: ${inv['partyName']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        inv['status'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPaid
                              ? const Color(0xFF166534)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Due Date',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            inv['dueDate'] ?? '',
                            style: const TextStyle(
                              fontSize: 12.5,
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
                          const Expanded(
                            child: Text(
                              'Pending Amount',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '₹${_formatIndianCurrency(amt)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          AppSnackbar.show(
                            context,
                            'Downloaded PDF for ${inv['invNumber']}',
                            type: SnackType.info,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Download PDF'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Close'),
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
  }

  void _showRecordPaymentModal(
    BuildContext context,
    Map<String, dynamic> inv,
  ) {
    final amtCtrl = TextEditingController(
      text: ((inv['pendingAmount'] as num).toDouble()).toStringAsFixed(0),
    );
    String paymentMode = 'UPI / Razorpay';
    final refCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Record Payment - ${inv['invNumber']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(LucideIcons.x, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Party: ${inv['partyName']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Amount (₹)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amtCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: paymentMode,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'UPI / Razorpay',
                          child: Text('UPI / Razorpay'),
                        ),
                        DropdownMenuItem(
                          value: 'Bank Transfer',
                          child: Text('Bank Transfer'),
                        ),
                        DropdownMenuItem(
                          value: 'Cash in Hand',
                          child: Text('Cash in Hand'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => paymentMode = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Transaction Reference / Notes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: refCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. UPI Ref / Bank Txn ID',
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final paidAmount =
                                  double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                              setState(() {
                                final currentPending =
                                    (inv['pendingAmount'] as num).toDouble();
                                final newPending =
                                    (currentPending - paidAmount).clamp(
                                  0.0,
                                  double.infinity,
                                );
                                inv['pendingAmount'] = newPending;
                                if (newPending == 0.0) {
                                  inv['status'] = 'Paid';
                                  _overdueInvoicesCount =
                                      (_overdueInvoicesCount - 1).clamp(0, 999);
                                  _overdueAmount =
                                      (_overdueAmount - paidAmount).clamp(
                                    0.0,
                                    double.infinity,
                                  );
                                }
                              });
                              Navigator.pop(ctx);
                              AppSnackbar.show(
                                context,
                                'Payment of ₹${_formatIndianCurrency(paidAmount)} recorded for ${inv['partyName']}',
                                type: SnackType.success,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Confirm Payment',
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

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3: EXPENSES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildExpensesTab(bool isMobile) {
    final bentoCard = _buildBentoSectionCard(
      title: 'Operational Expense Categories',
      total: '₹9,88,56,717.40',
      accentColor: const Color(0xFFEF4444),
      isMobile: isMobile,
      items: [
        {
          'label': 'Rent & Facility Management',
          'value': '₹1,50,00,000.00',
          'pct': 0.15,
        },
        {
          'label': 'Electricity, Water & Utilities',
          'value': '₹28,56,717.40',
          'pct': 0.03,
        },
        {
          'label': 'Staff Payroll & Retainers',
          'value': '₹5,60,00,000.00',
          'pct': 0.57,
        },
        {
          'label': 'Logistics, Freight & Delivery',
          'value': '₹1,80,00,000.00',
          'pct': 0.18,
        },
        {
          'label': 'Marketing & Brand Promotion',
          'value': '₹70,00,000.00',
          'pct': 0.07,
        },
      ],
    );

    if (!isMobile) return bentoCard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.trendingDown, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dedicated Expenses Section',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Manage claims, recurring subscriptions & budgets',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.expenses),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                icon: const Icon(LucideIcons.arrowRight, size: 12),
                label: const Text('Open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        bentoCard,
      ],
    );
  }

  Widget _buildBentoSectionCard({
    required String title,
    required String total,
    required Color accentColor,
    required List<Map<String, dynamic>> items,
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
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
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 13.5 : 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    total,
                    style: TextStyle(
                      fontSize: isMobile ? 14.5 : 16,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: isMobile ? 8 : 12),
          ...items.map((item) {
            final double pct = (item['pct'] as num).toDouble();
            return Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 5 : 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['label'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile ? 11.5 : 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            item['value'],
                            style: TextStyle(
                              fontSize: isMobile ? 11.5 : 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accentColor.withValues(alpha: 0.7),
                      ),
                      minHeight: isMobile ? 4 : 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MODALS & ACTIONS (ALL FUNCTIONAL)
  // ══════════════════════════════════════════════════════════════════════════

  // 1. RECORD ENTRY MODAL
  void _openRecordEntryModal(BuildContext context) {
    String entryType = 'Income / Sales';
    DateTime selectedDate = DateTime.now();
    final customerNameCtrl = TextEditingController();
    String category = 'Sales Revenue';
    String paymentMode = 'uybwaued';
    final amountCtrl = TextEditingController(text: '0.00');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final screenWidth = MediaQuery.of(dialogCtx).size.width;
            final isMobile = screenWidth < 500;

            Widget buildLabel(String text) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              );
            }

            final dateStr =
                '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 520,
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Title + Circular 'X' close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'New Financial Entry',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.x,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Row 1: Entry Type & Date
                      if (!isMobile)
                        Row(
                          children: [
                            // Entry Type
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabel('Entry Type'),
                                  DropdownButtonFormField<String>(
                                    value: entryType,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Income / Sales',
                                        child: Text('Income / Sales'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Expense',
                                        child: Text('Expense'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Transfer',
                                        child: Text('Transfer'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Journal Entry',
                                        child: Text('Journal Entry'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() => entryType = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabel('Date'),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: dialogCtx,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2035),
                                      );
                                      if (picked != null) {
                                        setModalState(
                                          () => selectedDate = picked,
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              color: Color(0xFF0F172A),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Icon(
                                            LucideIcons.calendar,
                                            size: 16,
                                            color: Color(0xFF334155),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        buildLabel('Entry Type'),
                        DropdownButtonFormField<String>(
                          value: entryType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Income / Sales',
                              child: Text('Income / Sales'),
                            ),
                            DropdownMenuItem(
                              value: 'Expense',
                              child: Text('Expense'),
                            ),
                            DropdownMenuItem(
                              value: 'Transfer',
                              child: Text('Transfer'),
                            ),
                            DropdownMenuItem(
                              value: 'Journal Entry',
                              child: Text('Journal Entry'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => entryType = val);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        buildLabel('Date'),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: dialogCtx,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.calendar,
                                  size: 16,
                                  color: Color(0xFF334155),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Row 2: Customer Name
                      buildLabel('Customer Name'),
                      TextField(
                        controller: customerNameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Customer Name',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Row 3: Category & Payment Mode
                      if (!isMobile)
                        Row(
                          children: [
                            // Category
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabel('Category'),
                                  DropdownButtonFormField<String>(
                                    value: category,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Sales Revenue',
                                        child: Text('Sales Revenue'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Rent',
                                        child: Text('Rent'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Consulting',
                                        child: Text('Consulting'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Raw Materials',
                                        child: Text('Raw Materials'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Salary & Wages',
                                        child: Text('Salary & Wages'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Office Expenses',
                                        child: Text('Office Expenses'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'oeirhfb',
                                        child: Text('oeirhfb'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Utilities',
                                        child: Text('Utilities'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Other',
                                        child: Text('Other'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() => category = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Payment Mode
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabel('Payment Mode'),
                                  DropdownButtonFormField<String>(
                                    value: paymentMode,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                    ),
                                    items: [
                                      for (final b in _bankAccounts)
                                        DropdownMenuItem(
                                          value: b.name,
                                          child: Text(b.name),
                                        ),
                                      const DropdownMenuItem(
                                        value: 'Cash in Hand',
                                        child: Text('Cash in Hand'),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'UPI / Razorpay',
                                        child: Text('UPI / Razorpay'),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'Bank Transfer',
                                        child: Text('Bank Transfer'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() => paymentMode = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        buildLabel('Category'),
                        DropdownButtonFormField<String>(
                          value: category,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Sales Revenue',
                              child: Text('Sales Revenue'),
                            ),
                            DropdownMenuItem(
                              value: 'Rent',
                              child: Text('Rent'),
                            ),
                            DropdownMenuItem(
                              value: 'Consulting',
                              child: Text('Consulting'),
                            ),
                            DropdownMenuItem(
                              value: 'Raw Materials',
                              child: Text('Raw Materials'),
                            ),
                            DropdownMenuItem(
                              value: 'Salary & Wages',
                              child: Text('Salary & Wages'),
                            ),
                            DropdownMenuItem(
                              value: 'Office Expenses',
                              child: Text('Office Expenses'),
                            ),
                            DropdownMenuItem(
                              value: 'oeirhfb',
                              child: Text('oeirhfb'),
                            ),
                            DropdownMenuItem(
                              value: 'Utilities',
                              child: Text('Utilities'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => category = val);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        buildLabel('Payment Mode'),
                        DropdownButtonFormField<String>(
                          value: paymentMode,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            for (final b in _bankAccounts)
                              DropdownMenuItem(
                                value: b.name,
                                child: Text(b.name),
                              ),
                            const DropdownMenuItem(
                              value: 'Cash in Hand',
                              child: Text('Cash in Hand'),
                            ),
                            const DropdownMenuItem(
                              value: 'UPI / Razorpay',
                              child: Text('UPI / Razorpay'),
                            ),
                            const DropdownMenuItem(
                              value: 'Bank Transfer',
                              child: Text('Bank Transfer'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => paymentMode = val);
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Row 4: Amount (₹)
                      buildLabel('Amount (₹)'),
                      TextField(
                        controller: amountCtrl,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Row 5: Notes / Reference
                      buildLabel('Notes / Reference'),
                      TextField(
                        controller: notesCtrl,
                        decoration: InputDecoration(
                          hintText: 'e.g. Inv #123 or Bill Reference',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Row 6: Save Financial Entry Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final rawAmt = amountCtrl.text
                                .replaceAll(',', '')
                                .trim();
                            final amt = double.tryParse(rawAmt) ?? 0.0;
                            if (amt <= 0) {
                              AppSnackbar.show(
                                context,
                                'Please enter a valid amount greater than 0',
                                type: SnackType.warning,
                              );
                              return;
                            }

                            final isExpense = entryType == 'Expense';
                            final typeStr = isExpense ? 'EXPENSE' : 'INCOME';
                            final dateFormatted =
                                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                            final itemCategory =
                                customerNameCtrl.text.trim().isNotEmpty
                                ? customerNameCtrl.text.trim()
                                : category;

                            setState(() {
                              _dayBookRecords.insert(
                                0,
                                _DayBookItem(
                                  id: 'db-${DateTime.now().millisecondsSinceEpoch}',
                                  date: dateFormatted,
                                  category: itemCategory,
                                  mode: paymentMode,
                                  type: typeStr,
                                  amount: amt,
                                ),
                              );

                              // Update bank balance if paymentMode matches a bank
                              for (int i = 0; i < _bankAccounts.length; i++) {
                                if (_bankAccounts[i].name.toLowerCase() ==
                                    paymentMode.toLowerCase()) {
                                  if (isExpense) {
                                    _bankAccounts[i].balance =
                                        (_bankAccounts[i].balance - amt).clamp(
                                          0,
                                          double.infinity,
                                        );
                                    _bankAccounts[i].expenses += amt;
                                  } else {
                                    _bankAccounts[i].balance += amt;
                                    _bankAccounts[i].income += amt;
                                  }
                                  _bankAccounts[i].lastTxn = 'Today';
                                }
                              }

                              if (paymentMode == 'Cash in Hand') {
                                if (isExpense) {
                                  _totalCashBalance = (_totalCashBalance - amt)
                                      .clamp(0, double.infinity);
                                } else {
                                  _totalCashBalance += amt;
                                }
                              }

                              if (isExpense) {
                                _totalExpenses += amt;
                              } else {
                                _grossRevenue += amt;
                              }
                            });

                            Navigator.pop(ctx);
                            AppSnackbar.show(
                              context,
                              'Financial entry saved successfully!',
                              type: SnackType.success,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF6D28D9,
                            ), // Vibrant purple matching screenshot
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Financial Entry',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
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
  // 2. ADD NEW BANK MODAL (EXACT MATCH TO SCREENSHOT)
  // ══════════════════════════════════════════════════════════════════════════
  void _openAddBankModal(BuildContext context) {
    final bankNameCtrl = TextEditingController();
    final accountNameCtrl = TextEditingController();
    final accountNumCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    final branchCtrl = TextEditingController();
    final openingBalCtrl = TextEditingController();

    String selectedAccountType = 'Savings';
    String selectedStatus = 'Active';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final mediaQuery = MediaQuery.of(context);
            final dialogWidth = mediaQuery.size.width;
            final isSmall = dialogWidth < 540;

            Widget buildFieldLabel(String label) {
              return Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              );
            }

            Widget buildTextInput({
              required TextEditingController controller,
              required String hint,
              TextInputType keyboardType = TextInputType.text,
            }) {
              return SizedBox(
                height: 42,
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  onChanged: (_) => setDialogState(() {}),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.normal,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            }

            Widget buildDropdown<T>({
              required T value,
              required List<T> items,
              required ValueChanged<T?> onChanged,
            }) {
              return Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                    items: items.map((T item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(item.toString()),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              );
            }

            Widget buildRow(Widget left, Widget right) {
              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    left,
                    const SizedBox(height: 14),
                    right,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 16),
                  Expanded(child: right),
                ],
              );
            }

            final hasValues = bankNameCtrl.text.trim().isNotEmpty &&
                accountNumCtrl.text.trim().isNotEmpty;

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 540),
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Add New Bank Account',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  LucideIcons.x,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Row 1: Bank Name * | Account Name *
                      buildRow(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFieldLabel('Bank Name *'),
                            const SizedBox(height: 6),
                            buildTextInput(
                              controller: bankNameCtrl,
                              hint: 'e.g. HDFC Bank',
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFieldLabel('Account Name *'),
                            const SizedBox(height: 6),
                            buildTextInput(
                              controller: accountNameCtrl,
                              hint: 'e.g. Main Business Savings',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Row 2: Account Number * | IFSC Code *
                      buildRow(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFieldLabel('Account Number *'),
                            const SizedBox(height: 6),
                            buildTextInput(
                              controller: accountNumCtrl,
                              hint: 'e.g. 501002938128',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFieldLabel('IFSC Code *'),
                            const SizedBox(height: 6),
                            buildTextInput(
                              controller: ifscCtrl,
                              hint: 'E.G. HDFC0000001',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Row 3: Branch Name (Optional) | Opening Balance (₹) *
                      buildRow(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFieldLabel('Branch Name (Optional)'),
                            const SizedBox(height: 6),
                            buildTextInput(
                              controller: branchCtrl,
                              hint: 'e.g. Bandra East',
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFieldLabel('Opening Balance (₹) *'),
                            const SizedBox(height: 6),
                            buildTextInput(
                              controller: openingBalCtrl,
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Row 4: Account Type | Status
                      buildRow(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFieldLabel('Account Type'),
                            const SizedBox(height: 6),
                            buildDropdown<String>(
                              value: selectedAccountType,
                              items: const [
                                'Savings',
                                'Current',
                                'Overdraft',
                                'Cash Credit',
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(
                                    () => selectedAccountType = val,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildFieldLabel('Status'),
                            const SizedBox(height: 6),
                            buildDropdown<String>(
                              value: selectedStatus,
                              items: const ['Active', 'Inactive'],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => selectedStatus = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Bank Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            final bName = bankNameCtrl.text.trim();
                            final accName = accountNameCtrl.text.trim();
                            final accNum = accountNumCtrl.text.trim();
                            final ifsc = ifscCtrl.text.trim();
                            final branch = branchCtrl.text.trim();
                            final bal =
                                double.tryParse(openingBalCtrl.text.trim()) ??
                                0.0;

                            if (bName.isEmpty &&
                                accNum.isEmpty &&
                                accName.isEmpty) {
                              AppSnackbar.show(
                                context,
                                'Please enter bank details before saving',
                                type: SnackType.warning,
                              );
                              return;
                            }

                            final effectiveHolder =
                                bName.isNotEmpty ? bName : 'Bank Account';
                            final effectiveName =
                                accName.isNotEmpty
                                    ? accName
                                    : (bName.isNotEmpty ? bName : 'Account');

                            setState(() {
                              _bankAccounts.add(
                                _BankAccountData(
                                  id:
                                      'bank-${DateTime.now().millisecondsSinceEpoch}',
                                  name: effectiveName,
                                  holder: effectiveHolder,
                                  balance: bal,
                                  income: 0.0,
                                  expenses: 0.0,
                                  lastTxn: 'Opening Balance',
                                  isHighlighted: false,
                                  accountNumber: accNum,
                                  ifsc: ifsc,
                                  branch: branch,
                                  accountType: selectedAccountType,
                                  status: selectedStatus,
                                ),
                              );
                            });

                            Navigator.pop(ctx);
                            AppSnackbar.show(
                              context,
                              'Bank account added successfully',
                              type: SnackType.success,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                hasValues
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFD6DFE8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save Bank Account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
  // 3. BANK HISTORY MODAL
  // ══════════════════════════════════════════════════════════════════════════
  void _openBankHistoryModal(BuildContext context, _BankAccountData bank) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620),
            padding: EdgeInsets.all(MediaQuery.of(ctx).size.width < 500 ? 16 : 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.landmark,
                                color: Color(0xFF2563EB),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${bank.name} - Statement',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${bank.holder}${bank.accountNumber != null && bank.accountNumber!.isNotEmpty ? ' • A/C: ${bank.accountNumber}' : ''}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
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
                      IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 280;
                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CURRENT BALANCE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '₹${_formatNumber(bank.balance)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    AppSnackbar.show(
                                      context,
                                      'Exported Bank Statement PDF for ${bank.name}',
                                      type: SnackType.success,
                                    );
                                  },
                                  icon: const Icon(LucideIcons.fileDown, size: 14),
                                  label: const Text(
                                    'Export Statement',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CURRENT BALANCE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '₹${_formatNumber(bank.balance)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                AppSnackbar.show(
                                  context,
                                  'Exported Bank Statement PDF for ${bank.name}',
                                  type: SnackType.success,
                                );
                              },
                              icon: const Icon(LucideIcons.fileDown, size: 14),
                              label: const Text(
                                'Export Statement',
                                style: TextStyle(fontSize: 11),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Recent Entries',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Aligned Table for bank entries (mobile card on mobile, table on desktop/macOS)
                  Builder(
                    builder: (context) {
                      final isMobile = Theme.of(context).platform != TargetPlatform.macOS &&
                          MediaQuery.of(context).size.width < 950;
                      if (isMobile) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
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
                                      bank.balance > 0 ? 'Opening Balance' : 'Account Created',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'CREDIT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(LucideIcons.calendar, size: 12, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '14 Oct 2026',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${_formatNumber(bank.balance)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Running Balance',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${_formatNumber(bank.balance)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 38,
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 44,
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFFF8FAFC),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Type',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            DataColumn(
                              numeric: true,
                              label: Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            DataColumn(
                              numeric: true,
                              label: Text(
                                'Balance',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                const DataCell(
                                  Text(
                                    '14 Oct 2026',
                                    style: TextStyle(fontSize: 11.5),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    bank.balance > 0
                                        ? 'Opening Balance'
                                        : 'Account Created',
                                    style: const TextStyle(fontSize: 11.5),
                                  ),
                                ),
                                const DataCell(
                                  Text(
                                    'CREDIT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '₹${_formatNumber(bank.balance)}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '₹${_formatNumber(bank.balance)}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
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
              ),
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
  }

  // 4. GST VIEW DETAIL MODAL
  void _openGstDetailModal(BuildContext context, String title, String amount) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.fileCheck,
                                color: Color(0xFF2563EB),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Reported Value (Period: October 2026)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    'Integrated GST (IGST)',
                    '₹2,37,73,49,924.52',
                  ),
                  _buildDetailRow('Central GST (CGST)', '₹79,24,49,974.84'),
                  _buildDetailRow('State GST (SGST)', '₹79,24,49,974.84'),
                  _buildDetailRow(
                    'B2B Taxable Invoices',
                    '142 Files Generated',
                  ),
                  _buildDetailRow(
                    'E-Way Bill Linked Supplies',
                    '100% Reconciled',
                  ),

                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          AppSnackbar.show(
                            context,
                            'Exported GST JSON for Government Portal upload',
                            type: SnackType.info,
                          );
                        },
                        icon: const Icon(LucideIcons.download, size: 14),
                        label: const Text(
                          'Export JSON',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          AppSnackbar.show(
                            context,
                            '$title return filed & synced successfully!',
                            type: SnackType.success,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'File / Confirm Return',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER FORMATTING
  // ══════════════════════════════════════════════════════════════════════════
  String _formatNumber(double amount) {
    return _formatIndianCurrency(amount);
  }

  String _formatIndianCurrency(double amount) {
    if (amount == 0) return '0';
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String fixedStr;
    if (absAmount == absAmount.roundToDouble()) {
      fixedStr = absAmount.toStringAsFixed(0);
    } else {
      fixedStr = absAmount.toStringAsFixed(2);
      if (fixedStr.endsWith('.00')) {
        fixedStr = fixedStr.substring(0, fixedStr.length - 3);
      } else if (fixedStr.endsWith('0')) {
        fixedStr = fixedStr.substring(0, fixedStr.length - 1);
      }
    }

    final parts = fixedStr.split('.');
    String intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (intPart.length > 3) {
      final lastThree = intPart.substring(intPart.length - 3);
      final remaining = intPart.substring(0, intPart.length - 3);
      final buffer = StringBuffer();
      for (int i = 0; i < remaining.length; i++) {
        if (i > 0 && (remaining.length - i) % 2 == 0) {
          buffer.write(',');
        }
        buffer.write(remaining[i]);
      }
      intPart = '${buffer.toString()},$lastThree';
    }
    return '${isNegative ? '-' : ''}$intPart$decPart';
  }
}

class _AccountingTabItem {
  final String label;
  final IconData icon;
  const _AccountingTabItem(this.label, this.icon);
}

class _StickyTabNavDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyTabNavDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabNavDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
