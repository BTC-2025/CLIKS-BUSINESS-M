import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../providers/accounting_provider.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../widgets/modals/finance_modals.dart';

class AccountingPage extends ConsumerStatefulWidget {
  const AccountingPage({super.key});

  @override
  ConsumerState<AccountingPage> createState() => _AccountingPageState();
}

class _AccountingPageState extends ConsumerState<AccountingPage>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0;

  final List<_TabItem> _tabs = [
    _TabItem('P & L', LucideIcons.barChart3),
    _TabItem('Balance', LucideIcons.scale),
    _TabItem('Receivables', LucideIcons.handCoins),
    _TabItem('Expenses', LucideIcons.receiptText),
    _TabItem('Cash & Bank', LucideIcons.landmark),
    _TabItem('GST', LucideIcons.shieldCheck),
    _TabItem('Day Book', LucideIcons.bookOpen),
  ];

  // Receivables & Payables Filter State
  final TextEditingController _rpSearchController = TextEditingController();
  String _rpSelectedStatus = 'All Statuses';

  // Party Outstanding Dataset
  final List<Map<String, dynamic>> _partyDataset = [
    {'name': 'Acme Technologies', 'inv': 'INV-2026-041', 'dueDate': '12-08-2026', 'amount': 45000.0, 'status': 'Pending', 'phone': '+91 98765 43210'},
    {'name': 'Ravi Traders', 'inv': 'INV-2026-038', 'dueDate': '01-08-2026', 'amount': 18500.0, 'status': 'Overdue', 'phone': '+91 98123 45678'},
    {'name': 'Global Logistics', 'inv': 'INV-2026-045', 'dueDate': '18-08-2026', 'amount': 28000.0, 'status': 'Pending', 'phone': '+91 99887 76655'},
    {'name': 'Zenith Retail', 'inv': 'INV-2026-029', 'dueDate': '25-07-2026', 'amount': 12000.0, 'status': 'Overdue', 'phone': '+91 97654 32109'},
    {'name': 'Metro Suppliers', 'inv': 'INV-2026-015', 'dueDate': '10-07-2026', 'amount': 0.0, 'status': 'Paid', 'phone': '+91 91234 56789'},
  ];

  @override
  void initState() {
    super.initState();
    _rpSearchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _rpSearchController.dispose();
    super.dispose();
  }

  // Filtered party list calculation
  List<Map<String, dynamic>> _getFilteredParties() {
    return _partyDataset.where((party) {
      final query = _rpSearchController.text.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          party['name'].toString().toLowerCase().contains(query) ||
          party['inv'].toString().toLowerCase().contains(query);
      final matchesStatus = _rpSelectedStatus == 'All Statuses' ||
          party['status'].toString().toLowerCase() == _rpSelectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showAllPartiesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(LucideIcons.users, color: Color(0xFF4F46E5), size: 20),
                    SizedBox(width: 10),
                    Text('All Party Outstandings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _partyDataset.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final party = _partyDataset[index];
                    final isOverdue = party['status'] == 'Overdue';
                    final isPaid = party['status'] == 'Paid';
                    final statusColor = isOverdue ? const Color(0xFFDC2626) : (isPaid ? const Color(0xFF059669) : const Color(0xFFD97706));
                    final statusBg = isOverdue ? const Color(0xFFFEE2E2) : (isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7));
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                party['name'].toString().substring(0, 1),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(party['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text("${party['phone']} • ${party['inv']}", style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("₹${(party['amount'] as num).toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                child: Text(party['status'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportReport(String format) {
    AppSnackbar.show(
      context,
      "Report exported as Party_Report.$format",
      type: SnackType.success,
    );
  }

  void _showCategoryDetails(String categoryName, String amount) {
    AppSnackbar.show(
      context,
      "Viewing ledger: $categoryName ($amount)",
      type: SnackType.info,
    );
  }

  void _showGSTDetailsModal(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _buildGSTDetailRow('Filing Period', 'July 2026'),
            _buildGSTDetailRow('Total Taxable Supplies', '₹1,85,000'),
            _buildGSTDetailRow('CGST (9%)', '₹16,650'),
            _buildGSTDetailRow('SGST (9%)', '₹16,650'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(LucideIcons.checkCircle, size: 16, color: Color(0xFF059669)),
                  SizedBox(width: 8),
                  Text('Verified & Audit-Ready', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGSTDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // Floating Action Button for Record Entry
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.extended(
                onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.recordAccountingEntry),
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── FINANCIAL SUMMARY HERO CARD ───
          SliverToBoxAdapter(
            child: _buildHeroSummary(isMobile)
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
              height: isMobile ? 50 : 56,
              child: Container(
                color: const Color(0xFFF8F9FB),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _buildTabNav(isMobile),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // ─── TAB CONTENT ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 90 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildMainContent(isMobile),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY (replaces action strip + stat cards)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    final entries = ref.watch(accountingEntriesProvider);
    final totalExpenses = entries
        .where((e) => e.entryType == 'Expense' || e.entryType == 'Office Expenses')
        .fold(0.0, (sum, item) => sum + item.amount);
    final grossRevenue = entries
        .where((e) => e.entryType == 'Income / Sales')
        .fold(185000.0, (sum, item) => sum + item.amount);
    final netProfit = grossRevenue - totalExpenses;
    final gstPayable = (totalExpenses * 0.18) > 0 ? (totalExpenses * 0.18) : 33300.0;

    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 8 : 16, isMobile ? 14 : 24, 0),
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F5B2E), Color(0xFF1A7A42), Color(0xFF22905A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5B2E).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Net Profit Hero Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NET PROFIT',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_formatCurrency(netProfit)}',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              // Decorative trend indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.trendingUp, size: 13, color: Colors.greenAccent.shade100),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 Stat Chips in a row
          Row(
            children: [
              _buildHeroChip('Revenue', '₹${_formatCurrency(grossRevenue)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Expenses', '₹${_formatCurrency(totalExpenses)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('GST', '₹${_formatCurrency(gstPayable)}', isMobile),
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
                  fontSize: isMobile ? 14 : 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB NAVIGATION (icon + text chips)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabNav(bool isMobile) {
    return Container(
      height: isMobile ? 46 : 52,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 6),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _activeTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF166534) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF166534) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: const Color(0xFF166534).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _tabs[index].icon,
                      size: isMobile ? 13 : 15,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _tabs[index].label,
                      style: TextStyle(
                        fontSize: isMobile ? 11.5 : 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF374151),
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

  // ═══════════════════════════════════════════════════════════════
  // CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile) {
    switch (_activeTab) {
      case 1: return _buildBalanceSheet(isMobile);
      case 2: return _buildReceivablesPayables(isMobile);
      case 3: return _buildExpensesTab(isMobile);
      case 4: return _buildCashBankTab(isMobile);
      case 5: return _buildGSTTab(isMobile);
      case 6: return _buildDayBookTab(isMobile);
      default: return _buildPLTab(isMobile);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 0: P & L
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPLTab(bool isMobile) {
    final revenueItems = [
      _PLItem('Sales Revenue', 150000, 0.81),
      _PLItem('Service Income', 25000, 0.135),
      _PLItem('Other Income', 10000, 0.055),
    ];
    final expenseItems = [
      _PLItem('Salary & Wages', 18000, 0.424),
      _PLItem('Rent & Utilities', 15000, 0.353),
      _PLItem('Office Expenses', 4500, 0.106),
      _PLItem('Marketing', 3000, 0.07),
      _PLItem('Travel & Meals', 2000, 0.047),
    ];

    return Column(
      children: [
        _buildPLSection(
          'Revenue',
          '₹1,85,000',
          LucideIcons.trendingUp,
          const Color(0xFF059669),
          const Color(0xFFF0FDF4),
          revenueItems,
          isMobile,
        ),
        const SizedBox(height: 14),
        _buildPLSection(
          'Expenses',
          '₹42,500',
          LucideIcons.trendingDown,
          const Color(0xFFDC2626),
          const Color(0xFFFEF2F2),
          expenseItems,
          isMobile,
        ),
      ],
    );
  }

  Widget _buildPLSection(
    String title,
    String total,
    IconData icon,
    Color accent,
    Color bg,
    List<_PLItem> items,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: accent),
                    const SizedBox(width: 8),
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accent)),
                  ],
                ),
                Text(total, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: accent)),
              ],
            ),
          ),
          // Items with progress bars
          ...items.map((item) => InkWell(
            onTap: () => _showCategoryDetails(item.label, '₹${item.amount.toInt()}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.darkText),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${_formatCurrency(item.amount)}',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Mini progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: item.percent,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(accent.withValues(alpha: 0.5)),
                      minHeight: 3.5,
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: BALANCE SHEET
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBalanceSheet(bool isMobile) {
    return Column(
      children: [
        _buildBalanceCard(
          'Assets',
          LucideIcons.wallet,
          const Color(0xFF2563EB),
          const Color(0xFFEFF6FF),
          [
            _BSItem('Cash in Hand', '₹25,000'),
            _BSItem('Bank Balance', '₹1,20,000'),
            _BSItem('Inventory Value', '₹45,000'),
            _BSItem('Accounts Receivable', '₹1,03,500'),
            _BSItem('Fixed Assets', '₹2,50,000'),
          ],
          '₹5,43,500',
        ),
        const SizedBox(height: 14),
        _buildBalanceCard(
          'Liabilities & Equity',
          LucideIcons.building2,
          const Color(0xFFDC2626),
          const Color(0xFFFEF2F2),
          [
            _BSItem('Accounts Payable', '₹28,000'),
            _BSItem('GST Payable', '₹33,300'),
            _BSItem('Loans / Credit', '₹50,000'),
            _BSItem('Owner\'s Equity', '₹4,32,200'),
          ],
          '₹5,43,500',
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    String title,
    IconData icon,
    Color accent,
    Color bg,
    List<_BSItem> items,
    String total,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accent)),
              ],
            ),
          ),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.label, style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText))),
                Text(item.value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              ],
            ),
          )),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accent, letterSpacing: 0.6)),
                Text(total, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: RECEIVABLES & PAYABLES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReceivablesPayables(bool isMobile) {
    final filteredParties = _getFilteredParties();

    return Column(
      children: [
        // Summary chips row (horizontal scroll)
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildRPChip('Receivable', '₹1,03,500', '4 pending', const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
              _buildRPChip('Overdue', '₹30,500', '2 invoices', const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
              _buildRPChip('This Week', '₹45,000', '1 due', const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
              _buildRPChip('Customers', '4', 'with dues', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Aging Report
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Text('Aging Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
              ),
              _buildAgingBar('Current (Not Due)', 73000, 103500, const Color(0xFF10B981)),
              _buildAgingBar('1–30 Days', 18500, 103500, const Color(0xFFF59E0B)),
              _buildAgingBar('31–60 Days', 12000, 103500, const Color(0xFFF97316)),
              _buildAgingBar('61–90 Days', 0, 103500, const Color(0xFFEF4444)),
              _buildAgingBar('90+ Days', 0, 103500, const Color(0xFFB91C1C)),
              const SizedBox(height: 8),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Party Outstanding Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Party Outstanding', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        _buildSmallActionBtn('All', LucideIcons.users, () => _showAllPartiesDialog(context)),
                        const SizedBox(width: 6),
                        _buildSmallActionBtn('Excel', LucideIcons.download, () => _exportReport('xlsx')),
                      ],
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _rpSearchController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search client or invoice...',
                      hintStyle: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                      prefixIcon: const Icon(LucideIcons.search, size: 14, color: AppColors.secondaryText),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF166534))),
                    ),
                  ),
                ),
              ),

              // Status filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: ['All Statuses', 'Overdue', 'Pending', 'Paid'].map((s) {
                      final isActive = _rpSelectedStatus == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _rpSelectedStatus = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF166534) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Party cards
              if (filteredParties.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: Text('No invoices found.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))),
                )
              else
                ...filteredParties.map((party) {
                  final isOverdue = party['status'] == 'Overdue';
                  final isPaid = party['status'] == 'Paid';
                  final statusColor = isOverdue ? const Color(0xFFDC2626) : (isPaid ? const Color(0xFF059669) : const Color(0xFFD97706));
                  final statusBg = isOverdue ? const Color(0xFFFEE2E2) : (isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7));
                  return Container(
                    margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Text(
                              party['name'].toString().substring(0, 1),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                party['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${party['inv']} • Due: ${party['dueDate']}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${(party['amount'] as num).toInt()}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(5)),
                              child: Text(party['status'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRPChip(String title, String value, String sub, Color accent, Color bg) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: accent, letterSpacing: 0.3)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: accent)),
          ),
          const SizedBox(height: 1),
          Text(sub, style: TextStyle(fontSize: 9, color: accent.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildAgingBar(String label, double amount, double total, Color color) {
    final pct = total > 0 ? amount / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.darkText))),
              Text('₹${_formatCurrency(amount)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: const Color(0xFF6B7280)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: EXPENSES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildExpensesTab(bool isMobile) {
    final entries = ref.watch(accountingEntriesProvider);
    final totalExpense = entries
        .where((e) => e.entryType == 'Expense' || e.entryType == 'Office Expenses')
        .fold(0.0, (sum, item) => sum + item.amount);

    return Column(
      children: [
        // Quick stats
        Row(
          children: [
            _buildExpStatChip('Total MTD', '₹${_formatCurrency(totalExpense)}', const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
            const SizedBox(width: 8),
            _buildExpStatChip('Operating', '₹${_formatCurrency(totalExpense * 0.6)}', const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildExpStatChip('Top Cat.', entries.isNotEmpty ? entries.first.category.split(' ').first : 'Rent', const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
            const SizedBox(width: 8),
            _buildExpStatChip('Payables', '₹28,000', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
          ],
        ),

        const SizedBox(height: 14),

        // Entries list
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(
                  'Transactions (${entries.length})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(LucideIcons.receipt, size: 28, color: Color(0xFF9CA3AF)),
                        SizedBox(height: 8),
                        Text('No expenses recorded', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                )
              else
                ...entries.map((item) {
                  final isExpense = item.entryType == 'Expense' || item.entryType == 'Office Expenses';
                  final isIncome = item.entryType == 'Income / Sales';
                  final iconData = isExpense ? LucideIcons.arrowDownLeft : (isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowLeftRight);
                  final accentColor = isExpense ? const Color(0xFFEF4444) : (isIncome ? const Color(0xFF10B981) : const Color(0xFF2563EB));
                  final accentBg = isExpense ? const Color(0xFFFEE2E2) : (isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFEFF6FF));
                  final prefix = isExpense ? '- ' : (isIncome ? '+ ' : '');

                  return Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: accentBg,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(iconData, size: 14, color: accentColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${item.date} • ${item.paymentMode}",
                                style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "$prefix₹${item.amount.toStringAsFixed(0)}",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category.length > 12 ? '${item.category.substring(0, 12)}…' : item.category,
                                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: accentColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpStatChip(String label, String value, Color accent, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: accent, letterSpacing: 0.3)),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: accent)),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4: CASH & BANK
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCashBankTab(bool isMobile) {
    return Column(
      children: [
        // 3 stat cards
        Row(
          children: [
            _buildCBChip('Cash', '₹0', LucideIcons.banknote, const Color(0xFF16A34A), const Color(0xFFF0FDF4)),
            const SizedBox(width: 8),
            _buildCBChip('Bank', '₹0', LucideIcons.landmark, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
            const SizedBox(width: 8),
            _buildCBChip('Total', '₹0', LucideIcons.wallet, const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
          ],
        ),

        const SizedBox(height: 16),

        // Empty state
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.landmark, size: 32, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 16),
              const Text(
                'No bank accounts',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add your first account to start tracking finances.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.secondaryText, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const AddNewBankAccountModal(),
                    );
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add Bank Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCBChip(String label, String value, IconData icon, Color accent, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: accent, letterSpacing: 0.2)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: accent)),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 5: GST
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGSTTab(bool isMobile) {
    return Column(
      children: [
        _buildGSTCard('GSTR-1 Summary', 'Outward Supplies', 'Action Needed', const Color(0xFFD97706), const Color(0xFFFFFBEB), LucideIcons.fileText, 'July 2026'),
        const SizedBox(height: 10),
        _buildGSTCard('GSTR-3B Summary', 'Monthly Returns', 'Ready', const Color(0xFF059669), const Color(0xFFF0FDF4), LucideIcons.fileCheck, 'July 2026'),
        const SizedBox(height: 10),
        _buildGSTCard('ITC Summary', 'Input Tax Credit', 'Auto-populated', const Color(0xFF2563EB), const Color(0xFFEFF6FF), LucideIcons.database, 'July 2026'),
      ],
    );
  }

  Widget _buildGSTCard(String title, String subtitle, String status, Color statusColor, Color bg, IconData icon, String period) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                      const SizedBox(height: 1),
                      Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Period: $period', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                GestureDetector(
                  onTap: () => _showGSTDetailsModal(context, title),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('View Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 6: DAY BOOK
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDayBookTab(bool isMobile) {
    final entries = ref.watch(accountingEntriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Day Book', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Latest', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                      SizedBox(width: 2),
                      Icon(LucideIcons.chevronDown, size: 12, color: AppColors.secondaryText),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No transactions', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))),
            )
          else
            ...entries.map((e) {
              final isIncome = e.entryType == 'Income / Sales';
              final accent = isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626);
              final bg = isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
              final prefix = isIncome ? '+' : '-';
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Date badge
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            e.date.split('-').first,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          ),
                          Text(
                            _monthAbbr(e.date),
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title.isNotEmpty ? e.title : e.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.paymentMode,
                            style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$prefix₹${e.amount.toStringAsFixed(0)}",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accent),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            isIncome ? 'Income' : 'Expense',
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: accent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  String _formatCurrency(double val) {
    if (val >= 100000) {
      return '${(val / 100000).toStringAsFixed(1)}L';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}K';
    }
    return val.toStringAsFixed(0);
  }

  String _monthAbbr(String date) {
    final parts = date.split('-');
    if (parts.length >= 2) {
      final m = int.tryParse(parts[1]) ?? 1;
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[m - 1];
    }
    return '';
  }

}


// ─── Helper Data Classes ───
class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem(this.label, this.icon);
}

class _PLItem {
  final String label;
  final double amount;
  final double percent;
  const _PLItem(this.label, this.amount, this.percent);
}

class _BSItem {
  final String label;
  final String value;
  const _BSItem(this.label, this.value);
}

// ─── Sticky Header Delegate ───
class _StickyTabNavDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyTabNavDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8F9FB),
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickyTabNavDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

