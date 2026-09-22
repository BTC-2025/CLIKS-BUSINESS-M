import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/modals/finance_modals.dart';
import '../providers/accounting_provider.dart';
import '../providers/expenses_provider.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  int _activeTab = 0; // 0: Expenses & ITC, 1: Subscriptions, 2: Budgets & Limits, 3: Reimbursements

  final List<_ExpenseModuleItem> _modules = [
    const _ExpenseModuleItem(
      id: 0,
      label: 'Expenses & ITC',
      subtitle: 'Recorded operational costs & tax credit',
      icon: LucideIcons.tag,
      accentColor: Color(0xFF166534),
      bgColor: Color(0xFFF0FDF4),
    ),
    const _ExpenseModuleItem(
      id: 1,
      label: 'Subscriptions',
      subtitle: 'Recurring software & vendor bills',
      icon: LucideIcons.calendar,
      accentColor: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    const _ExpenseModuleItem(
      id: 2,
      label: 'Budgets & Limits',
      subtitle: 'Department spending caps & usage',
      icon: LucideIcons.barChart3,
      accentColor: Color(0xFF7C3AED),
      bgColor: Color(0xFFF3E8FF),
    ),
    const _ExpenseModuleItem(
      id: 3,
      label: 'Reimbursements',
      subtitle: 'Employee travel & out-of-pocket claims',
      icon: LucideIcons.user,
      accentColor: Color(0xFFD63384),
      bgColor: Color(0xFFFCE7F3),
    ),
  ];

  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openLodgeStaffClaimModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LodgeStaffClaimModal(),
    );
  }

  void _openRecordExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RecordExpenseModal(),
    );
  }

  void _openSetTeamBudgetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SetTeamBudgetModal(),
    );
  }

  void _openAddSubscriptionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddRecurringSubscriptionModal(),
    );
  }

  // Bottom Sheet for switching Expense Modules cleanly on mobile
  void _showModulePickerSheet(BuildContext context) {
    final subscriptions = ref.read(expensesSubscriptionsProvider);
    final reimbursements = ref.read(expensesReimbursementsProvider);
    final budgets = ref.read(expensesBudgetsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Expense Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                Text('Select View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
              ],
            ),
            const SizedBox(height: 16),
            ..._modules.map((m) {
              final isSelected = _activeTab == m.id;
              String countBadge = '';
              if (m.id == 1) countBadge = '${subscriptions.length} active';
              if (m.id == 2) countBadge = '${budgets.length} teams';
              if (m.id == 3) countBadge = '${reimbursements.length} claims';

              return GestureDetector(
                onTap: () {
                  ref.read(expenseActiveTabProvider.notifier).state = m.id;
                  setState(() => _activeTab = m.id);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? m.bgColor : const Color(0xFFFAFAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? m.accentColor : const Color(0xFFE5E7EB),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? m.accentColor : m.bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(m.icon, size: 18, color: isSelected ? Colors.white : m.accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  m.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? m.accentColor : AppColors.darkText,
                                  ),
                                ),
                                if (countBadge.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? m.accentColor.withValues(alpha: 0.15) : const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      countBadge,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? m.accentColor : AppColors.secondaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              m.subtitle,
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(LucideIcons.check, size: 18, color: m.accentColor),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Filter Sheet for category search & filter options
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter Expenses', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All Categories';
                          _searchController.clear();
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search field inside filter sheet
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search title, category or vendor...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.secondaryText),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF166534))),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Categories', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['All Categories', 'Rent & Utilities', 'Office Expenses', 'Salary & Wages', 'Marketing & Advertising', 'Travel & Meals', 'Software / SaaS'].map((cat) {
                    final isActive = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() => _selectedCategory = cat);
                        setState(() => _selectedCategory = cat);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF166534) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _activeTab = ref.watch(expenseActiveTabProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final activeModule = _modules[_activeTab];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // FAB removed from page content as primary action is now in the top right header!
      floatingActionButton: null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: isMobile ? 90 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── HERO FINANCIAL CARD ───
            isMacOS
                ? _buildHeroSummary(isMobile)
                : _buildHeroSummary(isMobile)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.05, end: 0),

            const SizedBox(height: 12),

            // ─── MOBILE-FIRST MODULE SELECTOR BAR (Replaces Desktop Tabs!) ───
            isMacOS
                ? _buildMobileModuleBar(context, isMobile, activeModule)
                : _buildMobileModuleBar(context, isMobile, activeModule)
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 80.ms),

            const SizedBox(height: 12),

            // ─── ACTIVE MODULE CONTENT VIEW ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
              child: _buildMainContent(isMobile),
            ),
          ],
        ),
      ),
    );
  }



  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    final entries = ref.watch(accountingEntriesProvider);
    final totalExpenses = entries
        .where((e) => e.entryType == 'Expense' || e.entryType == 'Office Expenses')
        .fold(42500.0, (sum, item) => sum + item.amount);
    final itcCredit = totalExpenses * 0.18;
    final subscriptions = ref.watch(expensesSubscriptionsProvider);
    final reimbursements = ref.watch(expensesReimbursementsProvider);

    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 8 : 16, isMobile ? 14 : 24, 0),
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
          // Total Expenses Hero Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL OPERATIONAL EXPENSES',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_formatCurrency(totalExpenses)}',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              // Live Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.trendingDown, size: 13, color: Colors.amberAccent.shade100),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 Stat Chips inside hero card
          Row(
            children: [
              _buildHeroChip('GST ITC', '₹${_formatCurrency(itcCredit)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Subs', '${subscriptions.length} Active', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Claims', '${reimbursements.length} Lodged', isMobile),
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
  // MOBILE MODULE SELECTOR BAR (Replaces Desktop Tabs!)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileModuleBar(BuildContext context, bool isMobile, _ExpenseModuleItem activeModule) {
    final hasActiveFilter = _selectedCategory != 'All Categories' || _searchController.text.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
      child: Row(
        children: [
          // View Switcher Pill Dropdown (Tapping opens Module Sheet)
          Expanded(
            child: GestureDetector(
              onTap: () => _showModulePickerSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: activeModule.accentColor.withValues(alpha: 0.4), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: activeModule.accentColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: activeModule.bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(activeModule.icon, size: 16, color: activeModule.accentColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                activeModule.label,
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.secondaryText),
                            ],
                          ),
                          Text(
                            activeModule.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Filter Button (Opens Search & Category Sheet)
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasActiveFilter ? activeModule.accentColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasActiveFilter ? activeModule.accentColor : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.slidersHorizontal,
                size: 18,
                color: hasActiveFilter ? Colors.white : const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAIN CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile) {
    switch (_activeTab) {
      case 1: return _buildSubscriptionsView(isMobile);
      case 2: return _buildBudgetsView(isMobile);
      case 3: return _buildReimbursementsView(isMobile);
      default: return _buildRegistryView(isMobile);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SUB-TAB 0: EXPENSES REGISTRY & ITC
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRegistryView(bool isMobile) {
    final entries = ref
        .watch(accountingEntriesProvider)
        .where((e) => e.entryType == 'Expense' || e.category.toLowerCase().contains('expense') || e.entryType.toLowerCase().contains('office'))
        .toList();

    final filteredEntries = entries.where((e) {
      final query = _searchController.text.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          e.category.toLowerCase().contains(query) ||
          e.notes.toLowerCase().contains(query);
      final matchesCat = _selectedCategory == 'All Categories' ||
          e.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCat;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expenses Registry & ITC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _openRecordExpenseModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.plus, size: 12, color: Color(0xFF374151)),
                        SizedBox(width: 4),
                        Text('Add Expense', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_selectedCategory != 'All Categories' || _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Text('Active filter: ', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(6)),
                    child: Text(_selectedCategory, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                  ),
                ],
              ),
            ),

          // List Items
          if (filteredEntries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.tag, size: 28, color: Color(0xFF9CA3AF)),
                    SizedBox(height: 8),
                    Text('No recorded expenses found', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                  ],
                ),
              ),
            )
          else
            ...filteredEntries.map((item) {
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(LucideIcons.arrowDownLeft, size: 14, color: Color(0xFFEF4444)),
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
                          "-₹${item.amount.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.category.length > 14 ? '${item.category.substring(0, 14)}…' : item.category,
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUB-TAB 1: RECURRING SUBSCRIPTIONS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSubscriptionsView(bool isMobile) {
    final subscriptions = ref.watch(expensesSubscriptionsProvider);

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
                const Text('Recurring Subscriptions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _openAddSubscriptionModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.plus, size: 12, color: Color(0xFF374151)),
                        SizedBox(width: 4),
                        Text('Add Subs', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (subscriptions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No recurring subscriptions added.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))),
            )
          else
            ...subscriptions.map((item) {
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${item['vendor']} • Next Due: ${item['nextDue']}",
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
                          item['cost'],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['status'],
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUB-TAB 2: DEPARTMENT BUDGETS & LIMITS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBudgetsView(bool isMobile) {
    final budgets = ref.watch(expensesBudgetsProvider);

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
                const Text('Department Budgets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _openSetTeamBudgetModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.plus, size: 12, color: Color(0xFF374151)),
                        SizedBox(width: 4),
                        Text('Set Budget', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (budgets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No department budgets configured.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))),
            )
          else
            ...budgets.map((item) {
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(LucideIcons.barChart3, size: 14, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['team'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Limit: ${item['limit']} • Used: ${item['index']}",
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
                          item['spent'],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['status'],
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUB-TAB 3: STAFF REIMBURSEMENTS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReimbursementsView(bool isMobile) {
    final reimbursements = ref.watch(expensesReimbursementsProvider);

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
                const Text('Staff Reimbursements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _openLodgeStaffClaimModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.plus, size: 12, color: Color(0xFF374151)),
                        SizedBox(width: 4),
                        Text('Lodge Claim', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (reimbursements.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No staff reimbursements lodged.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))),
            )
          else
            ...reimbursements.map((item) {
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE7F3),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(LucideIcons.user, size: 14, color: Color(0xFFD63384)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['employee'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${item['id']} • Purpose: ${item['purpose']}",
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
                          item['amount'],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD63384)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['status'],
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
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
}

// ─── Helper Data Class for Expense Modules ───
class _ExpenseModuleItem {
  final int id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;

  const _ExpenseModuleItem({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
  });
}
