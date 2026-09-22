import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

// ═══════════════════════════════════════════════════════════════
// DUMMY PAYROLL MODELS
// ═══════════════════════════════════════════════════════════════
class _PayrollRegisterItem {
  final String payslipRef;
  final String empName;
  final String empId;
  final String baseSalary;
  final String earnings;
  final String deductions;
  final String netTakeHome;
  final String bankAccount;
  final String status;
  final Color statusColor;

  _PayrollRegisterItem({
    required this.payslipRef,
    required this.empName,
    required this.empId,
    required this.baseSalary,
    required this.earnings,
    required this.deductions,
    required this.netTakeHome,
    required this.bankAccount,
    required this.status,
    required this.statusColor,
  });
}

class _SalaryStructureItem {
  final String empName;
  final String empId;
  final String basicBase;
  final String hra;
  final String specialAllowances;
  final String annualCtc;

  _SalaryStructureItem({
    required this.empName,
    required this.empId,
    required this.basicBase,
    required this.hra,
    required this.specialAllowances,
    required this.annualCtc,
  });
}

class _ComplianceItem {
  final String empName;
  final String empId;
  final String panNumber;
  final String uanNumber;
  final String esiNumber;
  final String monthlyEpf;

  _ComplianceItem({
    required this.empName,
    required this.empId,
    required this.panNumber,
    required this.uanNumber,
    required this.esiNumber,
    required this.monthlyEpf,
  });
}

class _LoanItem {
  final String empName;
  final String empId;
  final String grantedLoan;
  final String monthlyEmi;
  final String remainingBalance;
  final String salaryAdvance;

  _LoanItem({
    required this.empName,
    required this.empId,
    required this.grantedLoan,
    required this.monthlyEmi,
    required this.remainingBalance,
    required this.salaryAdvance,
  });
}

class PayrollPage extends ConsumerStatefulWidget {
  const PayrollPage({super.key});

  @override
  ConsumerState<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends ConsumerState<PayrollPage>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Monthly Payroll Register, 1: Salary Structures, 2: Compliance, 3: Loans & Advances
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<_TabItem> _tabs = [
    _TabItem('Monthly Payroll Register', LucideIcons.fileText),
    _TabItem('Salary Structures (CTC)', LucideIcons.wallet),
    _TabItem('Compliance (PF / ESI / PAN)', LucideIcons.shieldCheck),
    _TabItem('Loans & Salary Advances', LucideIcons.sliders),
  ];

  // Dummy Data
  final List<_PayrollRegisterItem> _payrollRegister = [
    _PayrollRegisterItem(
      payslipRef: 'PAY-2026-0801',
      empName: 'Ravi Kumar',
      empId: 'EMP-001',
      baseSalary: '₹65,000.00',
      earnings: '₹20,000.00',
      deductions: '₹7,800.00',
      netTakeHome: '₹77,200.00',
      bankAccount: 'HDFC Bank (****4912)',
      status: 'DISBURSED',
      statusColor: const Color(0xFF166534),
    ),
    _PayrollRegisterItem(
      payslipRef: 'PAY-2026-0802',
      empName: 'Ananya Sharma',
      empId: 'EMP-002',
      baseSalary: '₹55,000.00',
      earnings: '₹17,000.00',
      deductions: '₹6,600.00',
      netTakeHome: '₹65,400.00',
      bankAccount: 'ICICI Bank (****3102)',
      status: 'DISBURSED',
      statusColor: const Color(0xFF166534),
    ),
    _PayrollRegisterItem(
      payslipRef: 'PAY-2026-0803',
      empName: 'Rajesh Patel',
      empId: 'EMP-003',
      baseSalary: '₹40,000.00',
      earnings: '₹12,000.00',
      deductions: '₹4,800.00',
      netTakeHome: '₹47,200.00',
      bankAccount: 'SBI Bank (****8841)',
      status: 'DISBURSED',
      statusColor: const Color(0xFF166534),
    ),
    _PayrollRegisterItem(
      payslipRef: 'PAY-2026-0804',
      empName: 'Sneha Reddy',
      empId: 'EMP-004',
      baseSalary: '₹50,000.00',
      earnings: '₹15,000.00',
      deductions: '₹6,000.00',
      netTakeHome: '₹59,000.00',
      bankAccount: 'Axis Bank (****1190)',
      status: 'DISBURSED',
      statusColor: const Color(0xFF166534),
    ),
    _PayrollRegisterItem(
      payslipRef: 'PAY-2026-0805',
      empName: 'Vikram Singh',
      empId: 'EMP-005',
      baseSalary: '₹35,000.00',
      earnings: '₹10,000.00',
      deductions: '₹4,200.00',
      netTakeHome: '₹40,800.00',
      bankAccount: 'KVB Bank (****9021)',
      status: 'PROCESSING',
      statusColor: const Color(0xFFC2410C),
    ),
  ];

  final List<_SalaryStructureItem> _structures = [
    _SalaryStructureItem(empName: 'Ravi Kumar', empId: 'EMP-001', basicBase: '₹65,000.00', hra: '₹26,000.00', specialAllowances: '₹11,000.00', annualCtc: '₹12,24,000.00'),
    _SalaryStructureItem(empName: 'Ananya Sharma', empId: 'EMP-002', basicBase: '₹55,000.00', hra: '₹22,000.00', specialAllowances: '₹9,000.00', annualCtc: '₹10,32,000.00'),
    _SalaryStructureItem(empName: 'Rajesh Patel', empId: 'EMP-003', basicBase: '₹40,000.00', hra: '₹16,000.00', specialAllowances: '₹6,000.00', annualCtc: '₹7,44,000.00'),
    _SalaryStructureItem(empName: 'Sneha Reddy', empId: 'EMP-004', basicBase: '₹50,000.00', hra: '₹20,000.00', specialAllowances: '₹8,000.00', annualCtc: '₹9,36,000.00'),
    _SalaryStructureItem(empName: 'Vikram Singh', empId: 'EMP-005', basicBase: '₹35,000.00', hra: '₹14,000.00', specialAllowances: '₹5,000.00', annualCtc: '₹6,48,000.00'),
  ];

  final List<_ComplianceItem> _complianceList = [
    _ComplianceItem(empName: 'Ravi Kumar', empId: 'EMP-001', panNumber: 'ABCDE1234F', uanNumber: '100987654321', esiNumber: '31-00-123456-000-0001', monthlyEpf: '₹3,600.00'),
    _ComplianceItem(empName: 'Ananya Sharma', empId: 'EMP-002', panNumber: 'FGHIJ5678K', uanNumber: '100987654322', esiNumber: '31-00-123456-000-0002', monthlyEpf: '₹3,300.00'),
    _ComplianceItem(empName: 'Rajesh Patel', empId: 'EMP-003', panNumber: 'LMNOP9012Q', uanNumber: '100987654323', esiNumber: '31-00-123456-000-0003', monthlyEpf: '₹2,400.00'),
    _ComplianceItem(empName: 'Sneha Reddy', empId: 'EMP-004', panNumber: 'RSTUV3456W', uanNumber: '100987654324', esiNumber: '31-00-123456-000-0004', monthlyEpf: '₹3,000.00'),
    _ComplianceItem(empName: 'Vikram Singh', empId: 'EMP-005', panNumber: 'XYZAB7890C', uanNumber: '100987654325', esiNumber: '31-00-123456-000-0005', monthlyEpf: '₹2,100.00'),
  ];

  final List<_LoanItem> _loans = [
    _LoanItem(empName: 'Ravi Kumar', empId: 'EMP-001', grantedLoan: '₹1,00,000.00', monthlyEmi: '₹5,000.00', remainingBalance: '₹30,000.00', salaryAdvance: '₹0.00'),
    _LoanItem(empName: 'Ananya Sharma', empId: 'EMP-002', grantedLoan: '₹50,000.00', monthlyEmi: '₹4,000.00', remainingBalance: '₹20,000.00', salaryAdvance: '₹5,000.00'),
  ];

  List<_PayrollRegisterItem> get _filteredPayroll {
    if (_searchQuery.isEmpty) return _payrollRegister;
    final q = _searchQuery.toLowerCase();
    return _payrollRegister.where((p) => p.empName.toLowerCase().contains(q) || p.empId.toLowerCase().contains(q) || p.payslipRef.toLowerCase().contains(q)).toList();
  }

  void _triggerAllocateLoan() {
    ref.read(navigationProvider.notifier).setRoute(AppRoute.allocateEmployeeLoan);
  }

  void _triggerProcessPayroll() {
    ref.read(navigationProvider.notifier).setRoute(AppRoute.processMonthlyPayroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // Dropup Expandable FAB for Mobile
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: _ExpandableFab(
                onAllocateLoan: _triggerAllocateLoan,
                onProcessPayroll: _triggerProcessPayroll,
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting Style Header) ───
          SliverToBoxAdapter(
            child: isMacOS
                ? _buildHeroSummary(isMobile)
                : _buildHeroSummary(isMobile)
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

          // ─── MAIN CONTENT AREA ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 140 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDesktopActions(isMobile),
                  if (!isMobile) const SizedBox(height: 12),
                  isMacOS
                      ? _buildMainContent(isMobile, screenWidth)
                      : _buildMainContent(isMobile, screenWidth)
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 150.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP ACTIONS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopActions(bool isMobile) {
    if (isMobile) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _triggerAllocateLoan,
            icon: const Icon(LucideIcons.sliders, size: 14),
            label: const Text('Allocate Employee Loan', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD63384),
              side: const BorderSide(color: Color(0xFFF8D7DA)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _triggerProcessPayroll,
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Process Monthly Payroll', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY CARD (Accounting Style Header)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 12 : 16, isMobile ? 14 : 24, 0),
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
          // Header Title & Live Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.wallet, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'WORKFORCE PAYROLL ENGINE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

          const SizedBox(height: 14),

          // Main Hero Number
          Text(
            'TOTAL MONTHLY SALARY EXPENSE',
            style: TextStyle(
              fontSize: isMobile ? 9.5 : 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹3,45,400.00',
            style: TextStyle(
              fontSize: isMobile ? 26 : 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 16),

          // 3 Stat Chips in a row inside hero card
          Row(
            children: [
              _buildHeroChip('Statutory PF/ESI', '₹41,400 Filed', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Outstanding Loans', '₹50,000.00', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Generated Payslips', '5 Payslips', isMobile),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
  // TAB NAVIGATION (Accounting Style)
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
                duration: Theme.of(context).platform == TargetPlatform.macOS ? Duration.zero : const Duration(milliseconds: 220),
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
  // MAIN CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile, double screenWidth) {
    String sectionTitle = "";
    Widget? searchRow;

    switch (_activeTab) {
      case 0:
        sectionTitle = "Monthly Salary Register";
        searchRow = _buildSearchRow(isMobile);
        break;
      case 1:
        sectionTitle = "Compensation Breakdown Structure (Annual CTC)";
        break;
      case 2:
        sectionTitle = "Statutory EPF, ESI, PAN Compliance Identifiers";
        break;
      case 3:
        sectionTitle = "Active Loans & Salary Advance Balances";
        break;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4)),
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
                  sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen),
                ),
              ),
              if (_activeTab == 3 && !isMobile)
                ElevatedButton.icon(
                  onPressed: _triggerAllocateLoan,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text('Grant Employee Loan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
            ],
          ),
          if (searchRow != null) ...[
            const SizedBox(height: 16),
            searchRow,
          ],
          const SizedBox(height: 20),
          _buildActiveTabContent(isMobile),
        ],
      ),
    );
  }

  Widget _buildSearchRow(bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 340,
      height: 42,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(LucideIcons.search, size: 16, color: AppColors.secondaryText),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Search salary register...',
                  hintStyle: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Icon(LucideIcons.x, size: 14, color: AppColors.secondaryText),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(bool isMobile) {
    if (isMobile) {
      return _buildMobilePayrollCards();
    }

    switch (_activeTab) {
      case 0:
        return _buildDesktopRegisterTable(_filteredPayroll);
      case 1:
        return _buildDesktopStructuresTable();
      case 2:
        return _buildDesktopComplianceTable();
      case 3:
        return _buildDesktopLoansTable();
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE PAYROLL CARDS (Zero Scroll, Native Mobile Fit)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobilePayrollCards() {
    if (_activeTab == 0) {
      return Column(
        children: _filteredPayroll.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF166534).withValues(alpha: 0.12),
                      child: Text(
                        item.empName.substring(0, 2).toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                          Text('${item.empId} • ${item.payslipRef}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: item.statusColor.withValues(alpha: 0.25)),
                      ),
                      child: Text(item.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildMobileBadge('BASE SALARY', item.baseSalary, const Color(0xFFF8FAFC), AppColors.darkText)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMobileBadge('NET TAKE HOME', item.netTakeHome, const Color(0xFFECFDF5), const Color(0xFF047857))),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.plusCircle, 'Earnings', item.earnings),
                _buildMobileField(LucideIcons.minusCircle, 'Deductions', item.deductions),
                _buildMobileField(LucideIcons.landmark, 'Bank Account', item.bankAccount),
              ],
            ),
          );
        }).toList(),
      );
    } else if (_activeTab == 1) {
      return Column(
        children: _structures.map((s) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                      child: Text('CTC: ${s.annualCtc}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.banknote, 'Basic Base Salary', s.basicBase),
                _buildMobileField(LucideIcons.home, 'House Rent Allowance (HRA)', s.hra),
                _buildMobileField(LucideIcons.sparkles, 'Special Allowances', s.specialAllowances),
              ],
            ),
          );
        }).toList(),
      );
    } else if (_activeTab == 2) {
      return Column(
        children: _complianceList.map((c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c.empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                      child: Text('EPF: ${c.monthlyEpf}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.creditCard, 'PAN Number', c.panNumber),
                _buildMobileField(LucideIcons.fingerprint, 'UAN Number', c.uanNumber),
                _buildMobileField(LucideIcons.shieldAlert, 'ESI Identification No', c.esiNumber),
              ],
            ),
          );
        }).toList(),
      );
    } else if (_activeTab == 3) {
      return Column(
        children: _loans.map((l) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(6)),
                      child: Text('EMI: ${l.monthlyEmi}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC2410C))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.coins, 'Granted Loan Amount', l.grantedLoan),
                _buildMobileField(LucideIcons.hourglass, 'Remaining Loan Balance', l.remainingBalance),
                _buildMobileField(LucideIcons.arrowUpRight, 'Salary Advance', l.salaryAdvance),
              ],
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMobileField(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: AppColors.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11.5, color: AppColors.darkText),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                  TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBadge(String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: fg.withValues(alpha: 0.7))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP TABLES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopRegisterTable(List<_PayrollRegisterItem> list) {
    final headers = ['PAYSLIP REF', 'EMPLOYEE', 'BASE SALARY', 'EARNINGS', 'DEDUCTIONS', 'NET TAKE HOME', 'BANK ACCOUNT', 'STATUS', 'ACTIONS'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 1050),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(110),
            1: FixedColumnWidth(180),
            2: FixedColumnWidth(110),
            3: FixedColumnWidth(100),
            4: FixedColumnWidth(100),
            5: FixedColumnWidth(130),
            6: FixedColumnWidth(160),
            7: FixedColumnWidth(110),
            8: FixedColumnWidth(80),
          },
          children: [
            _buildTableHeaderRow(headers),
            ...list.map((item) => TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(item.payslipRef, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.empName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                      Text(item.empId, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(item.baseSalary, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(item.earnings, style: const TextStyle(fontSize: 11, color: Color(0xFF166534)))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(item.deductions, style: const TextStyle(fontSize: 11, color: Color(0xFFC2410C)))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(item.netTakeHome, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(item.bankAccount, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: item.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(item.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.statusColor)),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Icon(LucideIcons.download, size: 16, color: Color(0xFF1D4ED8))),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopStructuresTable() {
    final headers = ['EMPLOYEE NAME', 'BASIC BASE SALARY', 'HOUSE RENT ALLOWANCE (HRA)', 'SPECIAL ALLOWANCES', 'APPROX ANNUAL COST (CTC)'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 950),
        child: Table(
          children: [
            _buildTableHeaderRow(headers),
            ..._structures.map((s) => TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.empName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.basicBase, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.hra, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.specialAllowances, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.annualCtc, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopComplianceTable() {
    final headers = ['EMPLOYEE NAME', 'PAN NUMBER', 'UNIVERSAL ACCOUNT NUMBER (UAN)', 'ESI IDENTIFICATION NO', 'MONTHLY EPF CONTRIBUTION'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 950),
        child: Table(
          children: [
            _buildTableHeaderRow(headers),
            ..._complianceList.map((c) => TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.empName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.panNumber, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.uanNumber, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.esiNumber, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.monthlyEpf, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLoansTable() {
    final headers = ['EMPLOYEE NAME', 'GRANTED LOAN AMOUNT', 'MONTHLY EMI DEDUCTION', 'REMAINING LOAN BALANCE', 'SALARY ADVANCE'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 950),
        child: Table(
          children: [
            _buildTableHeaderRow(headers),
            ..._loans.map((l) => TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(l.empName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(l.grantedLoan, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(l.monthlyEmi, style: const TextStyle(fontSize: 11, color: Color(0xFFC2410C)))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(l.remainingBalance, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(l.salaryAdvance, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
              ],
            )),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeaderRow(List<String> headers) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      children: headers.map((h) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          h,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
        ),
      )).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EXPANDABLE DROPUP FAB FOR MOBILE
// ═══════════════════════════════════════════════════════════════
class _ExpandableFab extends StatefulWidget {
  final VoidCallback onAllocateLoan;
  final VoidCallback onProcessPayroll;

  const _ExpandableFab({
    required this.onAllocateLoan,
    required this.onProcessPayroll,
  });

  @override
  State<_ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<_ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        if (_open) _toggle();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAnimatedChild(
            1,
            _MiniFab(
              icon: LucideIcons.plus,
              label: 'Process Monthly Payroll',
              color: const Color(0xFF166534), // Green
              onPressed: () {
                _toggle();
                widget.onProcessPayroll();
              },
            ),
          ),
          _buildAnimatedChild(
            0,
            _MiniFab(
              icon: LucideIcons.sliders,
              label: 'Allocate Employee Loan',
              color: const Color(0xFFD63384), // Pink / Accent
              onPressed: () {
                _toggle();
                widget.onAllocateLoan();
              },
            ),
          ),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildAnimatedChild(int index, Widget child) {
    final double start = (index * 0.1).clamp(0.0, 1.0);
    final double end = (start + 0.6).clamp(0.0, 1.0);

    final sizeAnim = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
      reverseCurve: Interval(start, end, curve: Curves.easeIn),
    );

    final fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
      reverseCurve: Interval(start, end, curve: Curves.easeIn),
    );

    return SizeTransition(
      sizeFactor: sizeAnim,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: fadeAnim,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = ColorTween(
          begin: const Color(0xFF166534),
          end: const Color(0xFF1E293B),
        ).evaluate(_controller);

        return Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (color ?? Colors.green).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              customBorder: const CircleBorder(),
              child: RotationTransition(
                turns: Tween<double>(begin: 0.0, end: 0.125).animate(_expandAnimation),
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MiniFab({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkText),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 48,
          width: 48,
          child: FloatingActionButton(
            heroTag: null,
            onPressed: onPressed,
            backgroundColor: color,
            elevation: 4,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STICKY TAB NAV DELEGATE
// ═══════════════════════════════════════════════════════════════
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
