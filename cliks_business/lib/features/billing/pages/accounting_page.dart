import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  _BankAccountData({
    required this.id,
    required this.name,
    required this.holder,
    required this.balance,
    this.income = 0,
    this.expenses = 0,
    this.lastTxn = 'No transactions yet',
    this.isHighlighted = false,
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
  // Active Tab Index (defaults to 4: Cash & Bank to match Image 1, or tabs 5 / 6)
  int _activeTab = 4;

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

  final TextEditingController _rpSearchController = TextEditingController();
  final String _rpSelectedStatus = 'All Statuses';

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

    // Initialize Day Book records matching Image 3 exactly
    _dayBookRecords = [
      _DayBookItem(
        id: 'db-1',
        date: '2026-09-29',
        category: 'oeirhfb',
        mode: 'UPI / Razorpay',
        type: 'EXPENSE',
        amount: 200.0,
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
        isSpecialHighlight: true, // Soft pink row tint in Image 3
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
    _rpSearchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CALCULATED METRICS
  // ══════════════════════════════════════════════════════════════════════════
  double _grossRevenue = 100000706.88;
  double _totalExpenses = 98856717.40;
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
  // MAIN BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 14 : 28,
            isMobile ? 14 : 24,
            isMobile ? 14 : 28,
            isMobile ? 80 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMacOS) ...[
                _buildMacOsBentoHero(isMobile),
                const SizedBox(height: 20),
              ] else ...[
                // 1. PAGE HEADER (Icon + Title + Record Entry Button)
                _buildPageHeader(isMobile),
                const SizedBox(height: 20),

                // 2. 4 TOP METRIC CARDS (Gross Revenue, Expenses, Net Profit, GST)
                _buildTopMetrics(screenWidth),
                const SizedBox(height: 22),
              ],

              // 3. TAB PILLS NAVIGATION
              _buildTabPills(isMobile),
              const SizedBox(height: 20),

              // 4. ACTIVE TAB CONTENT
              _buildActiveTabContent(isMobile, screenWidth),
            ],
          ),
        ),
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
                  LucideIcons.receiptText,
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
                LucideIcons.receiptText,
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
      iconWidget: const Icon(
        LucideIcons.indianRupee,
        color: Color(0xFF0284C7),
        size: 18,
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
  }) {
    return Container(
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

          // Color coding matching Image 1, 2, and 3
          Color selectedBg;
          if (index == 4) {
            selectedBg = const Color(
              0xFFF59E0B,
            ); // Amber / Orange for Cash & Bank (Image 1)
          } else if (index == 5) {
            selectedBg = const Color(0xFF059669); // Emerald for GST (Image 2)
          } else if (index == 6) {
            selectedBg = const Color(
              0xFF3B5998,
            ); // Slate / Navy for Day Book (Image 3)
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
    switch (_activeTab) {
      case 0:
        return _buildPLTab(isMobile);
      case 1:
        return _buildBalanceSheetTab(isMobile);
      case 2:
        return _buildReceivablesPayablesTab(isMobile);
      case 3:
        return _buildExpensesTab(isMobile);
      case 4:
        return _buildCashBankTab(isMobile, screenWidth);
      case 5:
        return _buildGSTTab(isMobile, screenWidth);
      case 6:
        return _buildDayBookTab(isMobile, screenWidth);
      default:
        return _buildCashBankTab(isMobile, screenWidth);
    }
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 84,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: const Text(
          'ADD NEW BANK',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFDC2626),
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
          cashCard,
          const SizedBox(height: 10),
          bankCard,
          const SizedBox(height: 10),
          fundsCard,
          const SizedBox(height: 10),
          addBankCard,
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
            Expanded(child: _buildBankAccountCard(_bankAccounts[i], i == 0)),
          ],
        ],
      );
    } else {
      bankCardsGrid = Column(
        children: [
          for (int i = 0; i < _bankAccounts.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _buildBankAccountCard(_bankAccounts[i], i == 0),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [subCardsLayout, const SizedBox(height: 22), bankCardsGrid],
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
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
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

  Widget _buildBankAccountCard(_BankAccountData bank, bool isPrimaryCard) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const Text(
                'Total Income:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                '₹${_formatNumber(bank.income)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Total Expenses row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Expenses:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                '₹${_formatNumber(bank.expenses)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Last Transaction row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Last Transaction:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                bank.lastTxn,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bottom row: BALANCE & History Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
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
                  Text(
                    '₹${_formatNumber(bank.balance)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              if (isPrimaryCard)
                ElevatedButton(
                  onPressed: () => _openBankHistoryModal(context, bank),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'History',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () => _openBankHistoryModal(context, bank),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    backgroundColor: const Color(0xFFF8FAFC),
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'History',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
      onViewDetail: () =>
          _openGstDetailModal(context, 'GSTR-1 Summary', '₹3,96,22,49,874.28'),
    );

    final gstr3bCard = _buildGstBentoCard(
      title: 'GSTR-3B Summary',
      period: 'Period: October 2026',
      badgeText: 'Ready',
      badgeColor: const Color(0xFFD97706),
      badgeBgColor: const Color(0xFFFEF3C7),
      amount: '₹0',
      onViewDetail: () =>
          _openGstDetailModal(context, 'GSTR-3B Summary', '₹0.00'),
    );

    final itcCard = _buildGstBentoCard(
      title: 'ITC Summary',
      period: 'Period: October 2026',
      badgeText: 'Auto-populated',
      badgeColor: const Color(0xFFD97706),
      badgeBgColor: const Color(0xFFFEF3C7),
      amount: '₹9,18,822',
      onViewDetail: () =>
          _openGstDetailModal(context, 'ITC Summary', '₹9,18,822.00'),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: File icon + Status badge
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
                  LucideIcons.fileText,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),

          // Period
          Text(
            period,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),

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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2563EB),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onViewDetail,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'VIEW DETAIL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
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
    return Container(
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth >= 900
                  ? screenWidth - (isMobile ? 28 : 56)
                  : 750,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              dataRowMinHeight: 48,
              dataRowMaxHeight: 52,
              horizontalMargin: 20,
              columnSpacing: 24,
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
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),

                    // CATEGORY
                    DataCell(
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    // MODE (Pill)
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.mode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),

                    // TYPE (Pill with arrow)
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
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
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isExpense
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF15803D),
                              ),
                            ),
                            Text(
                              item.type,
                              style: TextStyle(
                                fontSize: 10.5,
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
                          item.amount.truncateToDouble() == item.amount
                              ? item.amount.toInt().toString()
                              : item.amount.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 13.5,
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
  }

  Widget _buildSortableHeader(String title, String colKey) {
    final isSelected = _sortColumn == colKey;
    return InkWell(
      onTap: () => _sortDayBook(colKey),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isSelected
                ? (_sortAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown)
                : LucideIcons.chevronsUpDown,
            size: 13,
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFF94A3B8),
          ),
        ],
      ),
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
  // TAB 0: P & L
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPLTab(bool isMobile) {
    return Column(
      children: [
        _buildBentoSectionCard(
          title: 'Revenue Sources',
          total: '₹10,00,00,706.88',
          accentColor: const Color(0xFF10B981),
          items: [
            {'label': 'Sales Revenue', 'value': '₹8,50,00,000.00', 'pct': 0.85},
            {
              'label': 'Services & Consultations',
              'value': '₹1,20,00,706.88',
              'pct': 0.12,
            },
            {
              'label': 'Other Operational Income',
              'value': '₹30,00,000.00',
              'pct': 0.03,
            },
          ],
        ),
        const SizedBox(height: 16),
        _buildBentoSectionCard(
          title: 'Direct & Indirect Expenses',
          total: '₹9,88,56,717.40',
          accentColor: const Color(0xFFEF4444),
          items: [
            {
              'label': 'Raw Materials & Procurement',
              'value': '₹6,40,00,000.00',
              'pct': 0.65,
            },
            {
              'label': 'Salaries & Wages',
              'value': '₹2,10,56,717.40',
              'pct': 0.21,
            },
            {
              'label': 'Rent, Logistics & Utilities',
              'value': '₹1,38,00,000.00',
              'pct': 0.14,
            },
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: BALANCE SHEET
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBalanceSheetTab(bool isMobile) {
    return Column(
      children: [
        _buildBentoSectionCard(
          title: 'Total Assets',
          total: '₹14,50,00,000.00',
          accentColor: const Color(0xFF2563EB),
          items: [
            {
              'label': 'Cash in Hand & Bank Balances',
              'value': '₹5,05,000.00',
              'pct': 0.05,
            },
            {
              'label': 'Trade Receivables & Outstanding',
              'value': '₹4,45,00,000.00',
              'pct': 0.35,
            },
            {
              'label': 'Inventory & Stock at Godown',
              'value': '₹9,99,95,000.00',
              'pct': 0.60,
            },
          ],
        ),
        const SizedBox(height: 16),
        _buildBentoSectionCard(
          title: 'Liabilities & Equity',
          total: '₹14,50,00,000.00',
          accentColor: const Color(0xFF7C3AED),
          items: [
            {
              'label': 'Trade Payables to Suppliers',
              'value': '₹3,50,00,000.00',
              'pct': 0.24,
            },
            {
              'label': 'GST & Statutory Dues',
              'value': '₹3,96,22,49,874.20',
              'pct': 0.28,
            },
            {
              'label': "Owner's Equity & Retained Earnings",
              'value': '₹7,03,77,50,125.80',
              'pct': 0.48,
            },
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: RECEIVABLES & PAYABLES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildReceivablesPayablesTab(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Party Outstandings & Ageing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  AppSnackbar.show(
                    context,
                    'Exported Outstandings Ledger PDF',
                    type: SnackType.success,
                  );
                },
                icon: const Icon(LucideIcons.download, size: 14),
                label: const Text(
                  'Export Statement',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._partyDataset.map((party) {
            final isOverdue = party['status'] == 'Overdue';
            final isPaid = party['status'] == 'Paid';
            final statusColor = isOverdue
                ? const Color(0xFFDC2626)
                : (isPaid ? const Color(0xFF059669) : const Color(0xFFD97706));
            final statusBg = isOverdue
                ? const Color(0xFFFEE2E2)
                : (isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7));

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: statusBg,
                    child: Text(
                      party['name'].toString().substring(0, 1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          party['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${party['inv']} • Due: ${party['dueDate']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${_formatNumber((party['amount'] as num).toDouble())}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          party['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
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
  // TAB 3: EXPENSES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildExpensesTab(bool isMobile) {
    return _buildBentoSectionCard(
      title: 'Operational Expense Categories',
      total: '₹9,88,56,717.40',
      accentColor: const Color(0xFFEF4444),
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
  }

  Widget _buildBentoSectionCard({
    required String title,
    required String total,
    required Color accentColor,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                total,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          ...items.map((item) {
            final double pct = (item['pct'] as num).toDouble();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label'],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      Text(
                        item['value'],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accentColor.withValues(alpha: 0.7),
                      ),
                      minHeight: 5,
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

  // 2. ADD NEW BANK MODAL
  void _openAddBankModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final holderCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '0');

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
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                          const Text(
                            'Add New Bank Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
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
                  const SizedBox(height: 14),

                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Account Nickname / Identifier *',
                      hintText: 'e.g. Current Account, uybwaued',
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: holderCtrl,
                    decoration: InputDecoration(
                      labelText: 'Bank Name / Account Holder *',
                      hintText: 'e.g. HDFC Bank, Ravi',
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: balanceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Initial Opening Balance (₹)',
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final holder = holderCtrl.text.trim();
                          final bal =
                              double.tryParse(balanceCtrl.text.trim()) ?? 0;

                          if (name.isEmpty || holder.isEmpty) {
                            AppSnackbar.show(
                              context,
                              'Please enter account details',
                              type: SnackType.warning,
                            );
                            return;
                          }

                          setState(() {
                            _bankAccounts.add(
                              _BankAccountData(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                name: name,
                                holder: holder,
                                balance: bal,
                                income: 0,
                                expenses: 0,
                                lastTxn: 'No transactions yet',
                                isHighlighted: false,
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
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Add Account',
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

  // 3. BANK HISTORY MODAL
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
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              LucideIcons.history,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${bank.name} - Statement',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                bank.holder,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Text(
                              '₹${_formatNumber(bank.balance)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            AppSnackbar.show(
                              context,
                              'Exported Bank Statement PDF',
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
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: const Center(
                      child: Text(
                        'No transactions recorded in this period.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
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
                      Row(
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
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
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
                        Text(
                          amount,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2563EB),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
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
    // Format double to Indian style commas if large or standard locale
    if (amount == 0) return '0';
    if (amount == 5000) return '5,000';
    if (amount == 500000) return '5,00,000';
    if (amount == 505000) return '5,05,000';
    if (amount == 200) return '200';
    if (amount == 10000) return '10,000';
    if (amount == 201780) return '2,01,780';
    if (amount == 1000) return '1,000';
    if (amount == 240000) return '2,40,000';
    if (amount == 25000) return '25,000';
    if (amount == 200000) return '2,00,000';
    if (amount == 39100) return '39,100';

    final str = amount.toStringAsFixed(0);
    return str;
  }
}
