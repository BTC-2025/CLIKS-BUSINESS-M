import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

// ─── DATA MODELS ──────────────────────────────────────────────

class ExpenseRecordItem {
  final String voucherNo;
  final String date;
  String category;
  String description;
  String payee;
  double subtotal;
  String gstRate;
  double gstAmount;
  double itcClaim;
  double totalPaid;
  String paymentMode;
  String ref;

  ExpenseRecordItem({
    required this.voucherNo,
    required this.date,
    required this.category,
    required this.description,
    required this.payee,
    required this.subtotal,
    required this.gstRate,
    required this.gstAmount,
    required this.itcClaim,
    required this.totalPaid,
    required this.paymentMode,
    required this.ref,
  });
}

class SubscriptionRecordItem {
  final String id;
  String name;
  String vendor;
  String category;
  String frequency;
  String nextDueDate;
  String status;
  String autoPost;
  double cost;

  SubscriptionRecordItem({
    required this.id,
    required this.name,
    required this.vendor,
    required this.category,
    required this.frequency,
    required this.nextDueDate,
    required this.status,
    required this.autoPost,
    required this.cost,
  });
}

class BudgetRecordItem {
  String categoryGroup;
  String teamMembers;
  double monthlyBudget;
  double actualSpent;
  double remainingBudget;
  String status;

  BudgetRecordItem({
    required this.categoryGroup,
    required this.teamMembers,
    required this.monthlyBudget,
    required this.actualSpent,
    required this.remainingBudget,
    this.status = 'OPTIMAL',
  });
}

class ReimbursementClaimItem {
  final String claimId;
  String employee;
  String description;
  String date;
  String time;
  double amount;
  String receipt;
  String status;

  ReimbursementClaimItem({
    required this.claimId,
    required this.employee,
    required this.description,
    required this.date,
    required this.time,
    required this.amount,
    required this.receipt,
    this.status = 'UNDER REVIEW',
  });
}

class _TabConfig {
  final String title;
  final IconData icon;
  final Color activeColor;

  _TabConfig({
    required this.title,
    required this.icon,
    required this.activeColor,
  });
}

// ─── HELPER: INDIAN CURRENCY FORMATTER ────────────────────────

String _formatIndianCurrency(double amount) {
  if (amount == 0) return '₹0';
  final isNeg = amount < 0;
  final absAmt = amount.abs();
  final integerPart = absAmt.toInt().toString();
  if (integerPart.length <= 3) {
    return '${isNeg ? '-' : ''}₹$integerPart';
  }
  final last3 = integerPart.substring(integerPart.length - 3);
  final remaining = integerPart.substring(0, integerPart.length - 3);
  final buffer = StringBuffer();
  for (int i = 0; i < remaining.length; i++) {
    if (i > 0 && (remaining.length - i) % 2 == 0) {
      buffer.write(',');
    }
    buffer.write(remaining[i]);
  }
  return '${isNeg ? '-' : ''}₹${buffer.toString()},$last3';
}

// ─── MAIN EXPENSES PAGE ───────────────────────────────────────

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  // 0: Expenses Registry & ITC (Magenta #BE185D - Image 1)
  // 1: Recurring Subscriptions (Royal Blue #2563EB - Image 2)
  // 2: Department Budgets & Limits (Solid Purple #7C3AED - Image 6)
  // 3: Staff Reimbursements (Solid Emerald Green #059669 - Image 8)
  int _activeTab = 2;

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All Categories';
  String _selectedMode = 'All Modes';

  late List<ExpenseRecordItem> _expenses;
  late List<SubscriptionRecordItem> _subscriptions;
  late List<BudgetRecordItem> _budgets;
  late List<ReimbursementClaimItem> _claims;

  @override
  void initState() {
    super.initState();
    _expenses = [];
    _subscriptions = [];
    _budgets = [
      BudgetRecordItem(
        categoryGroup: 'oeirhfb',
        teamMembers: '2 Members',
        monthlyBudget: 1000.0,
        actualSpent: 200.0,
        remainingBudget: 800.0,
        status: 'OPTIMAL',
      ),
      BudgetRecordItem(
        categoryGroup: 'Hr team',
        teamMembers: '2 Members',
        monthlyBudget: 1000000.0,
        actualSpent: 0.0,
        remainingBudget: 1000000.0,
        status: 'OPTIMAL',
      ),
    ];
    _claims = [];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  double get _totalOperationalCosts {
    return _expenses.fold<double>(0, (sum, e) => sum + e.totalPaid);
  }

  double get _totalItcCredits {
    return _expenses.fold<double>(0, (sum, e) => sum + e.itcClaim);
  }

  int get _activeSubscriptionsCount {
    return _subscriptions.where((s) => s.status.toLowerCase() == 'active').length;
  }

  List<ExpenseRecordItem> get _filteredExpenses {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _expenses.where((e) {
      final matchesQuery = q.isEmpty ||
          e.voucherNo.toLowerCase().contains(q) ||
          e.date.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q) ||
          e.payee.toLowerCase().contains(q) ||
          e.paymentMode.toLowerCase().contains(q);

      final matchesCategory = _selectedCategory == 'All Categories' || e.category == _selectedCategory;
      final matchesMode = _selectedMode == 'All Modes' || e.paymentMode == _selectedMode;

      return matchesQuery && matchesCategory && matchesMode;
    }).toList();
  }

  // ─── ACTION MODALS ──────────────────────────────────────────

  void _openRecordExpenseDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _RecordExpenseDialog(
        onSave: (newExpense) {
          setState(() {
            _expenses.insert(0, newExpense);
            _activeTab = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Expense "${newExpense.voucherNo}" posted successfully.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openLodgeStaffClaimDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _LodgeStaffClaimDialog(
        onLodge: (newClaim) {
          setState(() {
            _claims.insert(0, newClaim);
            _activeTab = 3; // Switch to reimbursements
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reimbursement claim "${newClaim.claimId}" lodged.'),
              backgroundColor: const Color(0xFF7C3AED),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openAddSubscriptionDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _AddRecurringSubscriptionDialog(
        onAdd: (newSub) {
          setState(() {
            _subscriptions.insert(0, newSub);
            _activeTab = 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subscription "${newSub.name}" created.'),
              backgroundColor: const Color(0xFF2563EB),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openSetTeamBudgetDialog({BudgetRecordItem? initialBudget}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _SetTeamBudgetDialog(
        initialBudget: initialBudget,
        onSave: (savedBudget) {
          setState(() {
            if (initialBudget == null) {
              _budgets.insert(0, savedBudget);
            }
            _activeTab = 2; // Stay on budgets
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(initialBudget == null
                  ? 'Budget limit for "${savedBudget.categoryGroup}" set successfully.'
                  : 'Budget for "${savedBudget.categoryGroup}" updated successfully.'),
              backgroundColor: const Color(0xFF7C3AED),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openRecordSpendingDialog(BudgetRecordItem b) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _RecordSpendingDialog(
        budget: b,
        onConfirm: (amount, desc) {
          setState(() {
            b.actualSpent += amount;
            b.remainingBudget = math.max(0, b.monthlyBudget - b.actualSpent);
            final voucherNum = 100 + math.Random().nextInt(900);
            final now = DateTime.now();
            final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
            _expenses.insert(
              0,
              ExpenseRecordItem(
                voucherNo: 'VCH-2026-$voucherNum',
                date: dateStr,
                category: b.categoryGroup,
                description: desc.isNotEmpty ? desc : '${b.categoryGroup} operational expense',
                payee: b.categoryGroup,
                subtotal: amount,
                gstRate: '0% Excluded',
                gstAmount: 0.0,
                itcClaim: 0.0,
                totalPaid: amount,
                paymentMode: 'Net Banking',
                ref: 'SPEND/AUTO',
              ),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Spending of ${_formatIndianCurrency(amount)} recorded for ${b.categoryGroup}.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  // ─── BUILD ROOT ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMacOS) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 24,
            isMobile ? 12 : 20,
            isMobile ? 12 : 24,
            isMobile ? 80 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. TOP HEADER & ACTION BUTTONS (Image 1 & 2) ───
              _buildTopHeader(isMobile),
              const SizedBox(height: 20),

              // ─── 2. METRIC STAT CARDS (Image 1 & 2 vs Image 6 & 8) ───
              _buildMetricCards(isMobile),
              const SizedBox(height: 20),

              // ─── 3. FOUR TAB NAVIGATION BAR ───
              _buildTabBar(isMobile),
              const SizedBox(height: 18),

              // ─── 4. ACTIVE TAB CONTENT VIEW ───
              if (_activeTab == 0) _buildRegistryContent(isMobile),
              if (_activeTab == 1) _buildSubscriptionsContent(isMobile),
              if (_activeTab == 2) _buildBudgetsContent(isMobile),
              if (_activeTab == 3) _buildReimbursementsContent(isMobile),
            ],
          ),
        ),
      );
    }

    // ─── MOBILE OS REDESIGN (Android & iOS) ───
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton.extended(
          heroTag: 'mobile_expenses_record_fab',
          onPressed: _openRecordExpenseDialog,
          backgroundColor: const Color(0xFF166534),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text(
            'Record Expense',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: _buildMobileHeroSummary(),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabNavDelegate(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: _buildMobileTabNav(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
              sliver: SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    if (_activeTab == 0) return _buildRegistryContent(true);
                    if (_activeTab == 1) return _buildSubscriptionsContent(true);
                    if (_activeTab == 2) return _buildBudgetsContent(true);
                    if (_activeTab == 3) return _buildReimbursementsContent(true);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeroSummary() {
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
                        LucideIcons.receipt,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'EXPENSES & COST AUDIT',
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildHeroKpiChip(
                  'Total Paid',
                  _formatIndianCurrency(_totalOperationalCosts),
                  LucideIcons.trendingDown,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'Total ITC',
                  _formatIndianCurrency(_totalItcCredits),
                  LucideIcons.receipt,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'Subscriptions',
                  '$_activeSubscriptionsCount Active',
                  LucideIcons.calendar,
                ),
                const SizedBox(width: 6),
                _buildHeroKpiChip(
                  'Budgets',
                  '${_budgets.length} Depts',
                  LucideIcons.pieChart,
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

  Widget _buildMobileTabNav() {
    final tabs = [
      const _ExpensesTabItem('Expenses Registry & ITC', LucideIcons.receipt),
      const _ExpensesTabItem('Recurring Subscriptions', LucideIcons.calendar),
      const _ExpensesTabItem('Department Budgets & Limits', LucideIcons.pieChart),
      const _ExpensesTabItem('Staff Reimbursements', LucideIcons.userCheck),
    ];

    return SizedBox(
      height: 38,
      child: SingleChildScrollView(
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
                      duration: const Duration(milliseconds: 220),
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

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP HEADER (Image 1 & 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.trendingUp,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Expenses & Operational Costs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Add operational spendings, manage departmental budgets, track GST Input Tax Credit (ITC), automate recurring bills, and process staff reimbursement claims.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHeaderActionButton(
                  label: 'Lodge Staff Claim',
                  icon: LucideIcons.user,
                  color: const Color(0xFFBE185D),
                  borderColor: const Color(0xFFFDA4AF),
                  bgColor: const Color(0xFFFFF1F2),
                  onPressed: _openLodgeStaffClaimDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openRecordExpenseDialog,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text(
                    'Record Expense',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE185D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Magenta icon container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            LucideIcons.trendingUp,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        // Title & subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Expenses & Operational Costs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Add operational spendings, manage departmental budgets, track GST Input Tax Credit (ITC), automate recurring bills, and process staff reimbursement claims.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Top right action buttons (Image 1 & 2)
        _buildHeaderActionButton(
          label: 'Lodge Staff Claim',
          icon: LucideIcons.user,
          color: const Color(0xFFBE185D),
          borderColor: const Color(0xFFFDA4AF),
          bgColor: const Color(0xFFFFF1F2),
          onPressed: _openLodgeStaffClaimDialog,
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _openRecordExpenseDialog,
          icon: const Icon(LucideIcons.plus, size: 14),
          label: const Text(
            'Record Expense',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBE185D),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required Color bgColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. METRIC STAT CARDS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMetricCards(bool isMobile) {
    // In Tab 2 (Department Budgets) and Tab 3 (Staff Reimbursements),
    // display the single wide card matching Image 6 & 8:
    if (_activeTab == 2 || _activeTab == 3) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL OPERATIONAL COSTS (MTD)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _totalOperationalCosts > 0
                    ? _formatIndianCurrency(_totalOperationalCosts)
                    : '₹3,14,61,64,99,53,93,93,80,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // In Tab 0 and Tab 1, display 3 cards matching Image 1 & 2:
    return LayoutBuilder(
      builder: (context, constraints) {
        final card1 = _buildSingleMetricCard(
          title: 'TOTAL OPERATIONAL COSTS (MTD)',
          value: _formatIndianCurrency(_totalOperationalCosts),
          icon: LucideIcons.trendingUp,
          iconColor: const Color(0xFFE11D48),
          iconBgColor: const Color(0xFFFFF1F2),
        );

        final card2 = _buildSingleMetricCard(
          title: 'GST INPUT TAX CREDITS (ITC)',
          value: _formatIndianCurrency(_totalItcCredits),
          icon: LucideIcons.percent,
          iconColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
        );

        final card3 = _buildSingleMetricCard(
          title: 'ACTIVE MONTHLY RECURRINGS',
          value: '$_activeSubscriptionsCount Automation',
          icon: LucideIcons.calendar,
          iconColor: const Color(0xFF7C3AED),
          iconBgColor: const Color(0xFFF3E8FF),
        );

        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              card1,
              const SizedBox(height: 10),
              card2,
              const SizedBox(height: 10),
              card3,
            ],
          );
        }

        if (constraints.maxWidth < 950) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 12),
                  Expanded(child: card2),
                ],
              ),
              const SizedBox(height: 12),
              card3,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 14),
            Expanded(child: card2),
            const SizedBox(width: 14),
            Expanded(child: card3),
          ],
        );
      },
    );
  }

  Widget _buildSingleMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
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
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. FOUR TAB NAVIGATION BAR (Image 1, 2, 6, 8)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isMobile) {
    final tabs = [
      _TabConfig(
        title: 'Expenses Registry & ITC',
        icon: LucideIcons.tag,
        activeColor: const Color(0xFFBE185D), // Magenta (Image 1)
      ),
      _TabConfig(
        title: 'Recurring Subscriptions',
        icon: LucideIcons.calendar,
        activeColor: const Color(0xFF2563EB), // Royal Blue (Image 2)
      ),
      _TabConfig(
        title: 'Department Budgets & Limits',
        icon: LucideIcons.barChart3,
        activeColor: const Color(0xFF7C3AED), // Solid Purple (Image 6)
      ),
      _TabConfig(
        title: 'Staff Reimbursements',
        icon: LucideIcons.user,
        activeColor: const Color(0xFF059669), // Solid Emerald Green (Image 8)
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isActive = _activeTab == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _activeTab = index),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? tab.activeColor : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive ? tab.activeColor : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: tab.activeColor.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 14,
                        color: isActive ? Colors.white : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tab.title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          color: isActive ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 0: EXPENSES REGISTRY & ITC (Image 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRegistryContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Search Bar Row (Image 1)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 680;

              final searchField = Container(
                height: isMobile ? 36 : 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(fontSize: isMobile ? 12 : 13, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'Search any column (date, payee, amour',
                    hintStyle: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF94A3B8)),
                    prefixIcon: Icon(LucideIcons.search, size: isMobile ? 14 : 16, color: const Color(0xFF94A3B8)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(LucideIcons.x, size: isMobile ? 13 : 14, color: const Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 8 : 11),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              );

              final categoriesDropdown = Container(
                height: isMobile ? 36 : 42,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: Icon(LucideIcons.chevronDown, size: isMobile ? 13 : 14, color: const Color(0xFF64748B)),
                    items: [
                      'All Categories',
                      'Rent',
                      'Utilities',
                      'Office Supplies',
                      'Software',
                      'Marketing',
                      'Travel',
                      'Maintenance',
                    ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF334155)), overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              );

              final modesDropdown = Container(
                height: isMobile ? 36 : 42,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMode,
                    isExpanded: true,
                    icon: Icon(LucideIcons.chevronDown, size: isMobile ? 13 : 14, color: const Color(0xFF64748B)),
                    items: [
                      'All Modes',
                      'UPI',
                      'Net Banking',
                      'Credit Card',
                      'Debit Card',
                      'Cash',
                    ].map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF334155))))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMode = val);
                    },
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    searchField,
                    SizedBox(height: isMobile ? 8 : 10),
                    Row(
                      children: [
                        Expanded(child: categoriesDropdown),
                        SizedBox(width: isMobile ? 8 : 10),
                        Expanded(child: modesDropdown),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  categoriesDropdown,
                  const SizedBox(width: 10),
                  modesDropdown,
                ],
              );
            },
          ),
          SizedBox(height: isMobile ? 10 : 20),

          // Registry Table (Image 1): mobile card list on mobile, table on desktop/macOS
          if (isMobile)
            _buildMobileExpenseRegisterList()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth = 1040.0;
                final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      // Header Row with Sort/Filter Pills (Image 1)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 20,
                          vertical: isMobile ? 8 : 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 14, child: _buildSortableHeader('VOUCHER NO')),
                            Expanded(flex: 12, child: _buildSortableHeader('DATE')),
                            Expanded(flex: 20, child: _buildSortableHeader('CATEGORY DESCRIPTION')),
                            Expanded(flex: 16, child: _buildSortableHeader('PAYEE / MERCHANT')),
                            Expanded(flex: 14, child: _buildSortableHeader('GST SUBTOTAL')),
                            Expanded(flex: 14, child: _buildSortableHeader('ITC TAX CLAIM')),
                            Expanded(flex: 14, child: _buildSortableHeader('TOTAL PAID')),
                            Expanded(flex: 12, child: _buildSortableHeader('MODE')),
                          ],
                        ),
                      ),

                      // Rows
                      if (_filteredExpenses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(LucideIcons.fileSpreadsheet, size: 22, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No operational expenses recorded yet.',
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Click "+ Record Expense" at the top to log operational costs and ITC claims.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._filteredExpenses.map((exp) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 20,
                              vertical: isMobile ? 7 : 16,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 14,
                                  child: Text(
                                    exp.voucherNo,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11.5 : 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 12,
                                  child: Text(
                                    exp.date,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12.5,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.description,
                                        style: TextStyle(
                                          fontSize: isMobile ? 11.5 : 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        exp.category,
                                        style: TextStyle(
                                          fontSize: isMobile ? 10 : 11,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 16,
                                  child: Text(
                                    exp.payee,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11.5 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 14,
                                  child: Text(
                                    _formatIndianCurrency(exp.subtotal),
                                    style: TextStyle(
                                      fontSize: isMobile ? 11.5 : 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 14,
                                  child: Text(
                                    _formatIndianCurrency(exp.itcClaim),
                                    style: TextStyle(
                                      fontSize: isMobile ? 11.5 : 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 14,
                                  child: Text(
                                    _formatIndianCurrency(exp.totalPaid),
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 12,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 6 : 8,
                                        vertical: isMobile ? 2 : 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        exp.paymentMode,
                                        style: TextStyle(
                                          fontSize: isMobile ? 9.5 : 11,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: RECURRING SUBSCRIPTIONS (Image 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSubscriptionsContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and + Add Subscription button (Image 2)
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Recurring bills & Subscriptions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openAddSubscriptionDialog,
                    icon: const Icon(LucideIcons.plus, size: 13),
                    label: const Text(
                      '+ Add Subscription',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Recurring bills & Subscriptions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddSubscriptionDialog,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text(
                    '+ Add Subscription',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          SizedBox(height: isMobile ? 10 : 18),

          // Subscriptions Table (Image 2): mobile card list on mobile, table on desktop/macOS
          if (isMobile)
            _buildMobileSubscriptionsList()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth = 980.0;
                final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 16,
                          vertical: isMobile ? 8 : 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 18, child: _TableHeaderText('ID / NAME')),
                            Expanded(flex: 18, child: _TableHeaderText('VENDOR')),
                            Expanded(flex: 16, child: _TableHeaderText('CATEGORY NAME')),
                            Expanded(flex: 14, child: _TableHeaderText('FREQUENCY')),
                            Expanded(flex: 16, child: _TableHeaderText('NEXT DUE DATE')),
                            Expanded(flex: 12, child: _TableHeaderText('STATUS')),
                            Expanded(flex: 18, child: _TableHeaderText('AUTO-POST')),
                            Expanded(flex: 16, child: _TableHeaderText('RECURRING COST')),
                            Expanded(flex: 10, child: _TableHeaderText('ACTIONS')),
                          ],
                        ),
                      ),

                      // Rows
                      if (_subscriptions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(LucideIcons.calendarClock, size: 28, color: Color(0xFF94A3B8)),
                                SizedBox(height: 12),
                                Text(
                                  'No active recurring subscriptions found.',
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Click "+ Add Subscription" to automate vendor and tool bills.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._subscriptions.map((sub) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 16,
                              vertical: isMobile ? 7 : 16,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 18,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sub.name,
                                        style: TextStyle(
                                          fontSize: isMobile ? 11.5 : 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        sub.id,
                                        style: TextStyle(
                                          fontSize: isMobile ? 10 : 11,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 18,
                                  child: Text(
                                    sub.vendor,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 13,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 16,
                                  child: Text(
                                    sub.category,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12.5,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 14,
                                  child: Text(
                                    sub.frequency,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12.5,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 16,
                                  child: Text(
                                    sub.nextDueDate,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12.5,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 12,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 6 : 8,
                                        vertical: isMobile ? 2 : 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        sub.status,
                                        style: TextStyle(
                                          fontSize: isMobile ? 9.5 : 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF166534),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 18,
                                  child: Text(
                                    sub.autoPost,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 16,
                                  child: Text(
                                    _formatIndianCurrency(sub.cost),
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: IconButton(
                                    icon: Icon(
                                      LucideIcons.trash2,
                                      size: isMobile ? 13 : 15,
                                      color: const Color(0xFFDC2626),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() => _subscriptions.remove(sub));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Subscription "${sub.name}" removed.'),
                                          backgroundColor: const Color(0xFFDC2626),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: DEPARTMENT BUDGETS & LIMITS (Image 6)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBudgetsContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and + Set Budget Limit (Image 6)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                'Departmental Budgets & Spending Limits',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openSetTeamBudgetDialog,
                icon: Icon(LucideIcons.plus, size: isMobile ? 13 : 14),
                label: Text(
                  'Set Budget Limit',
                  style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBE185D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: isMobile ? 7 : 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 18),

          // Budgets Table: mobile card list on mobile, table on desktop/macOS
          if (isMobile)
            _buildMobileBudgetsList()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth = 980.0;
                final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 16,
                          vertical: isMobile ? 8 : 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 18, child: _TableHeaderText('CATEGORY GROUP')),
                            Expanded(flex: 16, child: _TableHeaderText('TEAM MEMBERS')),
                            Expanded(flex: 16, child: _TableHeaderText('MONTHLY BUDGET')),
                            Expanded(flex: 14, child: _TableHeaderText('ACTUAL SPENT')),
                            Expanded(flex: 16, child: _TableHeaderText('REMAINING BUDGET')),
                            Expanded(flex: 12, child: _TableHeaderText('STATUS')),
                            Expanded(flex: 16, child: _TableHeaderText('SPEND')),
                            Expanded(flex: 14, child: _TableHeaderText('ACTIONS')),
                          ],
                        ),
                      ),
                      ..._budgets.map((b) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: isMobile ? 7 : 16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          child: Row(
                            children: [
                              // CATEGORY GROUP (Purple/indigo link style)
                              Expanded(
                                flex: 18,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _openSetTeamBudgetDialog(initialBudget: b),
                                    child: Text(
                                      b.categoryGroup,
                                      style: TextStyle(
                                        fontSize: isMobile ? 11.5 : 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF6D28D9),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // TEAM MEMBERS
                              Expanded(
                                flex: 16,
                                child: Text(
                                  b.teamMembers,
                                  style: TextStyle(fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                ),
                              ),
                              // MONTHLY BUDGET (Dark green)
                              Expanded(
                                flex: 16,
                                child: Text(
                                  _formatIndianCurrency(b.monthlyBudget),
                                  style: TextStyle(fontSize: isMobile ? 12 : 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF065F46)),
                                ),
                              ),
                              // ACTUAL SPENT (Purple)
                              Expanded(
                                flex: 14,
                                child: Text(
                                  _formatIndianCurrency(b.actualSpent),
                                  style: TextStyle(fontSize: isMobile ? 12 : 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF7C3AED)),
                                ),
                              ),
                              // REMAINING BUDGET (Green)
                              Expanded(
                                flex: 16,
                                child: Text(
                                  _formatIndianCurrency(b.remainingBudget),
                                  style: TextStyle(fontSize: isMobile ? 12 : 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                                ),
                              ),
                              // STATUS (OPTIMAL badge)
                              Expanded(
                                flex: 12,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2.5 : 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      b.status,
                                      style: TextStyle(
                                        fontSize: isMobile ? 9.5 : 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // SPEND button ($ Record Spending)
                              Expanded(
                                flex: 16,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _openRecordSpendingDialog(b),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 3 : 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('\$ ', style: TextStyle(fontSize: isMobile ? 9.5 : 11, fontWeight: FontWeight.bold, color: const Color(0xFF166534))),
                                              Text('Record Spending', style: TextStyle(fontSize: isMobile ? 9.5 : 11, fontWeight: FontWeight.bold, color: const Color(0xFF166534))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // ACTIONS (Edit & Delete)
                              Expanded(
                                flex: 14,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _openSetTeamBudgetDialog(initialBudget: b),
                                          borderRadius: BorderRadius.circular(4),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 7, vertical: isMobile ? 2.5 : 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text('Edit', style: TextStyle(fontSize: isMobile ? 9.5 : 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? 4 : 6),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() => _budgets.remove(b));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Budget for "${b.categoryGroup}" deleted.'),
                                              backgroundColor: const Color(0xFFDC2626),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 7, vertical: isMobile ? 2.5 : 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text('Delete', style: TextStyle(fontSize: isMobile ? 9.5 : 11, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: STAFF REIMBURSEMENTS (Image 8)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReimbursementsContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header inside white card (Image 8)
          Text(
            'Employee Reimbursements & Travel claims',
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: isMobile ? 10 : 18),

          // Claims Table: mobile card list on mobile, table on desktop/macOS
          if (isMobile)
            _buildMobileClaimsList()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth = 980.0;
                final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: isMobile ? 8 : 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 14, child: _TableHeaderText('CLAIM ID')),
                            Expanded(flex: 18, child: _TableHeaderText('EMPLOYEE PROFILE')),
                            Expanded(flex: 22, child: _TableHeaderText('CLAIM PURPOSE DESCRIPTION')),
                            Expanded(flex: 14, child: _TableHeaderText('LODGE DATE')),
                            Expanded(flex: 16, child: _TableHeaderText('RECEIPT DETAILS')),
                            Expanded(flex: 12, child: _TableHeaderText('STATUS')),
                            Expanded(flex: 14, child: _TableHeaderText('CLAIM AMOUNT')),
                            Expanded(flex: 12, child: _TableHeaderText('ACTIONS')),
                          ],
                        ),
                      ),
                      if (_claims.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(LucideIcons.receipt, size: 28, color: Color(0xFF94A3B8)),
                                SizedBox(height: 12),
                                Text(
                                  'No staff reimbursement claims lodged yet.',
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Click "Lodge Staff Claim" at the top to file an employee expense reimbursement.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._claims.map((c) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: isMobile ? 7 : 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 14, child: Text(c.claimId, style: TextStyle(fontSize: isMobile ? 11.5 : 13, fontWeight: FontWeight.bold, color: const Color(0xFF065F46)))),
                                Expanded(flex: 18, child: Text(c.employee, style: TextStyle(fontSize: isMobile ? 11.5 : 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)))),
                                Expanded(flex: 22, child: Text(c.description, style: TextStyle(fontSize: isMobile ? 11 : 12.5, color: const Color(0xFF475569)))),
                                Expanded(flex: 14, child: Text(c.date, style: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFF64748B)))),
                                Expanded(flex: 16, child: Text(c.receipt, style: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFF2563EB)))),
                                Expanded(
                                  flex: 12,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2.5 : 3),
                                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                      child: Text(c.status, style: TextStyle(fontSize: isMobile ? 9.5 : 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF166534))),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 14, child: Text(_formatIndianCurrency(c.amount), style: TextStyle(fontSize: isMobile ? 12 : 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)))),
                                Expanded(
                                  flex: 12,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(LucideIcons.trash2, size: isMobile ? 13 : 15, color: const Color(0xFFDC2626)),
                                    onPressed: () {
                                      setState(() => _claims.remove(c));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Claim "${c.claimId}" deleted.'),
                                          backgroundColor: const Color(0xFFDC2626),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileExpenseRegisterList() {
    if (_filteredExpenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  LucideIcons.fileSpreadsheet,
                  size: 22,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No operational expenses recorded yet.',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Click "+ Record Expense" at the top to log operational costs and ITC claims.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredExpenses.map((exp) {
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
              // Row 1: Description & Total Paid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      exp.description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatIndianCurrency(exp.totalPaid),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Category, Voucher & Mode
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      exp.voucherNo,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    exp.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      exp.paymentMode,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 3: Payee & Date
              Row(
                children: [
                  const Icon(LucideIcons.store, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      exp.payee,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.calendar, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    exp.date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Row 4: Subtotal & ITC Claim
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GST Subtotal: ${_formatIndianCurrency(exp.subtotal)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ITC Claim: ${_formatIndianCurrency(exp.itcClaim)}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
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

  Widget _buildMobileSubscriptionsList() {
    if (_subscriptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.calendarClock, size: 28, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'No active recurring subscriptions found.',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Click "+ Add Subscription" to automate vendor and tool bills.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _subscriptions.map((sub) {
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
              // Row 1: Name & Cost & Delete action
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          sub.id,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatIndianCurrency(sub.cost),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 14,
                      color: Color(0xFFDC2626),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() => _subscriptions.remove(sub));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Subscription "${sub.name}" deleted.'),
                          backgroundColor: const Color(0xFFDC2626),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: Vendor, Status & Frequency
              Row(
                children: [
                  const Icon(LucideIcons.store, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      sub.vendor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sub.status,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sub.frequency,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Row 3: Category, Next Due Date & Auto-Post
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sub.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.calendar, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${sub.nextDueDate}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sub.autoPost,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
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

  Widget _buildMobileBudgetsList() {
    return Column(
      children: _budgets.map((b) {
        final spentPct = b.monthlyBudget > 0
            ? (b.actualSpent / b.monthlyBudget).clamp(0.0, 1.0)
            : 0.0;
        final isOptimal = b.status.toUpperCase() == 'OPTIMAL';

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
              // Row 1: Category Group & Status & Edit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _openSetTeamBudgetDialog(initialBudget: b),
                      child: Text(
                        b.categoryGroup,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6D28D9),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: isOptimal
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      b.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOptimal
                            ? const Color(0xFF166534)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Team Members
              Row(
                children: [
                  const Icon(LucideIcons.users, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    'Team: ${b.teamMembers}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 3: Financial metrics with flexible layout
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Budget',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatIndianCurrency(b.monthlyBudget),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Actual Spent',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatIndianCurrency(b.actualSpent),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Remaining',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatIndianCurrency(b.remainingBudget),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: spentPct,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    spentPct > 0.9
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                  ),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 10),

              // Row 4: Actions (Record Spending + Edit + Delete)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _openRecordSpendingDialog(b),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              LucideIcons.wallet,
                              size: 12,
                              color: Color(0xFF166534),
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Record Spending',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          LucideIcons.penSquare,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () =>
                            _openSetTeamBudgetDialog(initialBudget: b),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        onPressed: () {
                          setState(() => _budgets.remove(b));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Budget for "${b.categoryGroup}" removed.',
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileClaimsList() {
    if (_claims.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.receipt, size: 28, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'No staff reimbursement claims lodged yet.',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Click "Lodge Staff Claim" at the top to file an employee expense reimbursement.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _claims.map((c) {
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
              // Row 1: Employee, Amount & Delete
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.employee,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Claim: ${c.claimId}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatIndianCurrency(c.amount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 14,
                      color: Color(0xFFDC2626),
                    ),
                    onPressed: () {
                      setState(() => _claims.remove(c));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Claim "${c.claimId}" deleted.'),
                          backgroundColor: const Color(0xFFDC2626),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: Purpose description
              Text(
                c.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Row 3: Date, Receipt details & Status
              Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    c.date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.fileText, size: 12, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      c.receipt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      c.status,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
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

  Widget _buildSortableHeader(String text) {
    final isMobile = Theme.of(context).platform != TargetPlatform.macOS;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 10.5 : 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 4, vertical: isMobile ? 1.5 : 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.filter, size: 8.5, color: Color(0xFF94A3B8)),
              SizedBox(width: 2),
              Icon(LucideIcons.arrowUpDown, size: 8.5, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── TABLE HEADER TEXT HELPER ─────────────────────────────────

class _TableHeaderText extends StatelessWidget {
  final String text;
  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.2,
      ),
    );
  }
}

// ─── 1. RECORD BUSINESS EXPENSE MODAL (Image 5) ───────────────

class _RecordExpenseDialog extends StatefulWidget {
  final void Function(ExpenseRecordItem newExpense) onSave;

  const _RecordExpenseDialog({required this.onSave});

  @override
  State<_RecordExpenseDialog> createState() => _RecordExpenseDialogState();
}

class _RecordExpenseDialogState extends State<_RecordExpenseDialog> {
  String _category = 'Rent';
  String _gstRate = '0% Excluded';
  String _paymentMode = 'UPI';

  final _descCtrl = TextEditingController();
  final _payeeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();

  @override
  void dispose() {
    _descCtrl.dispose();
    _payeeCtrl.dispose();
    _amountCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final subtotal = double.tryParse(_amountCtrl.text.trim()) ?? 5000.0;
    double gstPct = 0;
    if (_gstRate.contains('5%')) gstPct = 0.05;
    if (_gstRate.contains('12%')) gstPct = 0.12;
    if (_gstRate.contains('18%')) gstPct = 0.18;
    if (_gstRate.contains('28%')) gstPct = 0.28;

    final gstAmount = subtotal * gstPct;
    final itcClaim = gstAmount;
    final totalPaid = subtotal + gstAmount;

    final voucherNum = 100 + math.Random().nextInt(900);
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final exp = ExpenseRecordItem(
      voucherNo: 'VCH-2026-$voucherNum',
      date: dateStr,
      category: _category,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : 'Office space rent',
      payee: _payeeCtrl.text.trim().isNotEmpty ? _payeeCtrl.text.trim() : 'Jino Merchant',
      subtotal: subtotal,
      gstRate: _gstRate,
      gstAmount: gstAmount,
      itcClaim: itcClaim,
      totalPaid: totalPaid,
      paymentMode: _paymentMode,
      ref: _refCtrl.text.trim().isNotEmpty ? _refCtrl.text.trim() : 'UPI/123456',
    );

    widget.onSave(exp);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 480,
          constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 5)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Record Business Expense',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Expense Category
                const Text('Expense Category', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildDropdownContainer(
                  value: _category,
                  items: ['Rent', 'Utilities', 'Software', 'Office Supplies', 'Salaries', 'Marketing', 'Maintenance'],
                  onChanged: (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 16),

                // Subcategory / Spares description
                const Text('Subcategory / Spares description', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_descCtrl, 'Example : Office space rent'),
                const SizedBox(height: 16),

                // Payee / Merchant Profile
                const Text('Payee / Merchant Profile', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_payeeCtrl, 'Example : Jino Merchant'),
                const SizedBox(height: 16),

                // Expense Amount & GST % (Image 5)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expense Amount (INR)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_amountCtrl, 'Example : 5000', isNumeric: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GST % Percentage', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildDropdownContainer(
                            value: _gstRate,
                            items: ['0% Excluded', '5% GST', '12% GST', '18% GST', '28% GST'],
                            onChanged: (v) => setState(() => _gstRate = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Mode & Ref / UPI Reference (Image 5)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment Mode', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildDropdownContainer(
                            value: _paymentMode,
                            items: ['UPI', 'Net Banking', 'Credit Card', 'Debit Card', 'Cash'],
                            onChanged: (v) => setState(() => _paymentMode = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ref / UPI reference', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_refCtrl, 'Example : UPI/123456'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Settle & Post Expense (Purple #7C3AED as in Image 5)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Settle & Post Expense',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, {bool isNumeric = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

// ─── 2. LODGE STAFF CLAIM MODAL (Image 4) ─────────────────────

class _LodgeStaffClaimDialog extends StatefulWidget {
  final void Function(ReimbursementClaimItem newClaim) onLodge;

  const _LodgeStaffClaimDialog({required this.onLodge});

  @override
  State<_LodgeStaffClaimDialog> createState() => _LodgeStaffClaimDialogState();
}

class _LodgeStaffClaimDialogState extends State<_LodgeStaffClaimDialog> {
  final _employeeCtrl = TextEditingController(text: 'Karan Mehra (Inventory)');
  final _descCtrl = TextEditingController(text: 'Client Sample Box Dispatches');
  final _dateCtrl = TextEditingController(text: '14/10/2026');
  final _timeCtrl = TextEditingController(text: '11:29 AM');
  final _amountCtrl = TextEditingController();
  final _receiptCtrl = TextEditingController();

  @override
  void dispose() {
    _employeeCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _amountCtrl.dispose();
    _receiptCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 1500.0;
    final claimNum = 800 + math.Random().nextInt(199);

    final newClaim = ReimbursementClaimItem(
      claimId: 'CLM-$claimNum',
      employee: _employeeCtrl.text.trim().isNotEmpty ? _employeeCtrl.text.trim() : 'Karan Mehra (Inventory)',
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : 'Client Sample Box Dispatches',
      date: _dateCtrl.text.trim(),
      time: _timeCtrl.text.trim(),
      amount: amt,
      receipt: _receiptCtrl.text.trim().isNotEmpty ? _receiptCtrl.text.trim() : 'Receipt_Ref.pdf',
    );

    widget.onLodge(newClaim);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 480,
          constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lodge Staff Claim',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Employee Profile Name
                const Text('Employee Profile Name', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_employeeCtrl, 'Karan Mehra (Inventory)'),
                const SizedBox(height: 16),

                // Out-of-pocket Description
                const Text('Out-of-pocket Description', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_descCtrl, 'Client Sample Box Dispatches'),
                const SizedBox(height: 16),

                // Date & Time (Image 4)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildIconField(_dateCtrl, '14/10/2026', LucideIcons.calendar),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Time', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildIconField(_timeCtrl, '11:29 AM', LucideIcons.clock),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Claim Amount (INR)
                const Text('Claim Amount (INR)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_amountCtrl, 'e.g. 1500', isNumeric: true),
                const SizedBox(height: 16),

                // Receipt / Reference #1 (Optional)
                const Text('Receipt / Reference #1 (Optional)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _receiptCtrl,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            hintText: 'e.g. UPI Ref No, Bank Txn ID, Receipt No.,',
                            hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(LucideIcons.plus, size: 16, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // + Add Another Receipt / Proof (Dashed button)
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC084FC), style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Text(
                      '+ Add Another Receipt / Proof',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Lodge Reimbursement Claim (Purple #7C3AED as in Image 4)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Lodge Reimbursement Claim',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, {bool isNumeric = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildIconField(TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          suffixIcon: Icon(icon, size: 15, color: const Color(0xFF64748B)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

// ─── 3. ADD RECURRING SUBSCRIPTION MODAL (Image 3) ────────────

class _AddRecurringSubscriptionDialog extends StatefulWidget {
  final void Function(SubscriptionRecordItem newSub) onAdd;

  const _AddRecurringSubscriptionDialog({required this.onAdd});

  @override
  State<_AddRecurringSubscriptionDialog> createState() => _AddRecurringSubscriptionDialogState();
}

class _AddRecurringSubscriptionDialogState extends State<_AddRecurringSubscriptionDialog> {
  final _nameCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: '14/10/2026');

  String _category = 'Rent';
  String _frequency = 'Monthly';
  String _autoPost = 'Active (Auto-Create)';
  String _status = 'Active';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _vendorCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'AWS Cloud Server';
    final vendor = _vendorCtrl.text.trim().isNotEmpty ? _vendorCtrl.text.trim() : 'Amazon Web Services';
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 5000.0;
    final subId = 101 + math.Random().nextInt(899);

    final sub = SubscriptionRecordItem(
      id: 'SUB-$subId',
      name: name,
      vendor: vendor,
      category: _category,
      frequency: _frequency,
      nextDueDate: _dateCtrl.text.trim(),
      status: _status,
      autoPost: _autoPost,
      cost: amt,
    );

    widget.onAdd(sub);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 480,
          constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Recurring Subscription',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Subscription Name
                const Text('Subscription Name', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_nameCtrl, 'e.g. AWS Cloud Server'),
                const SizedBox(height: 16),

                // Vendor Name
                const Text('Vendor Name', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_vendorCtrl, 'e.g. Amazon Web Services'),
                const SizedBox(height: 16),

                // Category & Amount (INR) *
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildDropdownContainer(
                            value: _category,
                            items: ['Rent', 'Utilities', 'Software / SaaS', 'Office Expenses', 'Marketing', 'Travel', 'Maintenance'],
                            onChanged: (v) => setState(() => _category = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount (INR) *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_amountCtrl, 'e.g. 5000', isNumeric: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Frequency & Next Due Date
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Frequency', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildDropdownContainer(
                            value: _frequency,
                            items: ['Monthly', 'Quarterly', 'Yearly', 'Weekly'],
                            onChanged: (v) => setState(() => _frequency = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Next Due Date', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              controller: _dateCtrl,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                              decoration: const InputDecoration(
                                suffixIcon: Icon(LucideIcons.calendar, size: 15, color: Color(0xFF64748B)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Auto-Post & Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Auto-Post', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildDropdownContainer(
                            value: _autoPost,
                            items: ['Active (Auto-Create)', 'Manual Review'],
                            onChanged: (v) => setState(() => _autoPost = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildDropdownContainer(
                            value: _status,
                            items: ['Active', 'Paused', 'Cancelled'],
                            onChanged: (v) => setState(() => _status = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Create Subscription button (Slate-blue style as in Image 3)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64748B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Create Subscription',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, {bool isNumeric = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

// ─── 4. SET TEAM BUDGET MODAL (Image 7) ───────────────────────

class _SetTeamBudgetDialog extends StatefulWidget {
  final BudgetRecordItem? initialBudget;
  final void Function(BudgetRecordItem newBudget) onSave;

  const _SetTeamBudgetDialog({this.initialBudget, required this.onSave});

  @override
  State<_SetTeamBudgetDialog> createState() => _SetTeamBudgetDialogState();
}

class _SetTeamBudgetDialogState extends State<_SetTeamBudgetDialog> {
  late final TextEditingController _teamNameCtrl;
  late final TextEditingController _budgetCtrl;
  int _memberCount = 0;

  @override
  void initState() {
    super.initState();
    _teamNameCtrl = TextEditingController(text: widget.initialBudget?.categoryGroup ?? '');
    _budgetCtrl = TextEditingController(
      text: widget.initialBudget != null ? widget.initialBudget!.monthlyBudget.toInt().toString() : '',
    );
    if (widget.initialBudget != null) {
      final match = RegExp(r'(\d+)').firstMatch(widget.initialBudget!.teamMembers);
      _memberCount = match != null ? int.tryParse(match.group(1)!) ?? 2 : 2;
    }
  }

  @override
  void dispose() {
    _teamNameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final teamName = _teamNameCtrl.text.trim().isNotEmpty ? _teamNameCtrl.text.trim() : 'HR Team';
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 50000.0;
    final membersText = _memberCount > 0 ? '$_memberCount Members' : '2 Members';

    if (widget.initialBudget != null) {
      widget.initialBudget!.categoryGroup = teamName;
      widget.initialBudget!.monthlyBudget = budget;
      widget.initialBudget!.teamMembers = membersText;
      widget.initialBudget!.remainingBudget = math.max(0, budget - widget.initialBudget!.actualSpent);
      widget.onSave(widget.initialBudget!);
    } else {
      final b = BudgetRecordItem(
        categoryGroup: teamName,
        teamMembers: membersText,
        monthlyBudget: budget,
        actualSpent: 0.0,
        remainingBudget: budget,
        status: 'OPTIMAL',
      );
      widget.onSave(b);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 460,
          constraints: BoxConstraints(maxWidth: 480, maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 7)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialBudget != null ? 'Edit Team Budget' : 'Set Team Budget',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Team / Department Name
                const Text('Team / Department Name', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_teamNameCtrl, 'e.g. HR Team'),
                const SizedBox(height: 16),

                // Monthly Budget (INR) *
                const Text('Monthly Budget (INR) *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_budgetCtrl, 'e.g. 50000', isNumeric: true),
                const SizedBox(height: 16),

                // Team Members (0) & + Add Member (Image 7)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Team Members ($_memberCount)', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    InkWell(
                      onTap: () => setState(() => _memberCount++),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(LucideIcons.plus, size: 12, color: Color(0xFF7C3AED)),
                            SizedBox(width: 4),
                            Text('Add Member', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _memberCount == 0 ? 'No team members assigned yet.' : '$_memberCount members assigned to this department budget.',
                  style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),

                // Settle Budget Target (Image 7)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B9CB2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      widget.initialBudget != null ? 'Update Budget Target' : 'Settle Budget Target',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, {bool isNumeric = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

// ─── 5. RECORD SPENDING DIALOG ────────────────────────────────

class _RecordSpendingDialog extends StatefulWidget {
  final BudgetRecordItem budget;
  final void Function(double amount, String description) onConfirm;

  const _RecordSpendingDialog({
    required this.budget,
    required this.onConfirm,
  });

  @override
  State<_RecordSpendingDialog> createState() => _RecordSpendingDialogState();
}

class _RecordSpendingDialogState extends State<_RecordSpendingDialog> {
  final _amountCtrl = TextEditingController(text: '200');
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 200.0;
    widget.onConfirm(amt, _descCtrl.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 440,
          constraints: BoxConstraints(maxWidth: 460, maxHeight: MediaQuery.of(context).size.height * 0.9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Record Spending',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Department', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(widget.budget.categoryGroup, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Remaining Budget', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(_formatIndianCurrency(widget.budget.remainingBudget), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Spending Amount (INR) *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'e.g. 500',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Expense Description (Optional)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _descCtrl,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Team lunch / hardware purchase',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Record & Settle Spending', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── MOBILE TAB HELPER DATA ───────────────────────────────────

class _ExpensesTabItem {
  final String label;
  final IconData icon;
  const _ExpensesTabItem(this.label, this.icon);
}

class _StickyTabNavDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabNavDelegate({required this.child});

  @override
  double get minExtent => 42.0;
  @override
  double get maxExtent => 42.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyTabNavDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
