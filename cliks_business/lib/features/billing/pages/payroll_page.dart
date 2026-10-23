import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

// ─── DATA MODELS ──────────────────────────────────────────────

class PayrollRecordItem {
  final String payslipRef;
  final String month;
  String empName;
  String empId;
  double baseSalary;
  double hra;
  double specialAllowance;
  double bonus;
  double epf;
  double esi;
  double tds;
  double professionalTax;
  String bankName;
  String bankAccount;
  String pan;
  String uan;
  String status;

  PayrollRecordItem({
    required this.payslipRef,
    required this.month,
    required this.empName,
    required this.empId,
    required this.baseSalary,
    this.hra = 5000.0,
    this.specialAllowance = 2000.0,
    this.bonus = 3000.0,
    this.epf = 6000.0,
    this.esi = 325.0,
    this.tds = 100.0,
    this.professionalTax = 200.0,
    required this.bankName,
    required this.bankAccount,
    this.pan = 'HSBDCHSBCBHCJH',
    this.uan = 'AKJDCJHEBCJ, HEB, HBE',
    this.status = 'PAID',
  });

  double get otherEarnings => hra + specialAllowance + bonus;
  double get grossEarnings => baseSalary + otherEarnings;
  double get totalDeductions => epf + esi + tds + professionalTax;
  double get netTakeHome => grossEarnings - totalDeductions;
}

class SalaryStructureItem {
  String empName;
  double basicBase;
  double hra;
  double specialAllowances;
  double annualCtc;

  SalaryStructureItem({
    required this.empName,
    required this.basicBase,
    required this.hra,
    required this.specialAllowances,
    required this.annualCtc,
  });
}

class ComplianceRecordItem {
  String empName;
  String panNumber;
  String uanNumber;
  String esiNumber;
  double monthlyEpf;
  String autoEpfText;

  ComplianceRecordItem({
    required this.empName,
    required this.panNumber,
    required this.uanNumber,
    required this.esiNumber,
    required this.monthlyEpf,
    this.autoEpfText = '(Auto EPF 12%)',
  });
}

class LoanRecordItem {
  String empName;
  double loanAmount;
  double monthlyEmi;
  double remainingBalance;
  int deductionPeriodMonths;
  double salaryAdvance;

  LoanRecordItem({
    required this.empName,
    required this.loanAmount,
    required this.monthlyEmi,
    double? remainingBalance,
    required this.deductionPeriodMonths,
    required this.salaryAdvance,
  }) : remainingBalance = remainingBalance ?? loanAmount;
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

// ─── MAIN PAYROLL PAGE ────────────────────────────────────────

class PayrollPage extends ConsumerStatefulWidget {
  const PayrollPage({super.key});

  @override
  ConsumerState<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends ConsumerState<PayrollPage> {
  // 0: Monthly Payroll Register (Magenta #BE185D - Image 1)
  // 1: Salary Structures (CTC) (Royal Blue #2563EB - Image 5)
  // 2: Compliance (PF / ESI / PAN) (Dark Green #047857)
  // 3: Loans & Salary Advances (Purple #7C3AED)
  int _activeTab = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  late List<PayrollRecordItem> _payrollRegister;
  late List<SalaryStructureItem> _structures;
  late List<ComplianceRecordItem> _complianceList;
  late List<LoanRecordItem> _loans;

  @override
  void initState() {
    super.initState();

    _payrollRegister = [
      PayrollRecordItem(
        payslipRef: 'PSN-2026-510',
        month: 'Month: May 2026',
        empName: 'kiran Kumar C',
        empId: 'CLK-0033',
        baseSalary: 50000.0,
        hra: 5000.0,
        specialAllowance: 2000.0,
        bonus: 3000.0,
        epf: 6000.0,
        esi: 325.0,
        tds: 100.0,
        professionalTax: 200.0,
        bankName: 'hdfc BANK',
        bankAccount: 'kdjbjhffjksb',
        pan: 'HSBDCHSBCBHCJH',
        uan: 'AKJDCJHEBCJ, HEB, HBE',
        status: 'PAID',
      ),
    ];

    _structures = [
      SalaryStructureItem(
        empName: 'kiran Kumar C',
        basicBase: 50000.0,
        hra: 5000.0,
        specialAllowances: 2000.0,
        annualCtc: 684000.0,
      ),
    ];

    _complianceList = [
      ComplianceRecordItem(
        empName: 'kiran Kumar C',
        panNumber: 'HSBDCHSBCBHCJH',
        uanNumber: 'AKJDCJHEBCJ , HEB , HBE',
        esiNumber: '3122334455009',
        monthlyEpf: 6000.0,
      ),
    ];

    _loans = [
      LoanRecordItem(
        empName: 'kiran Kumar C',
        loanAmount: 2000.0,
        monthlyEmi: 50.0,
        remainingBalance: 2000.0,
        deductionPeriodMonths: 40,
        salaryAdvance: 500.0,
      ),
    ];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  double get _totalMonthlyExpense {
    if (_payrollRegister.isEmpty) return 0;
    return _payrollRegister.fold<double>(0, (sum, p) => sum + p.netTakeHome);
  }

  double get _totalLoansOutstanding {
    if (_loans.isEmpty) return 0;
    return _loans.fold<double>(0, (sum, l) => sum + l.loanAmount);
  }

  List<PayrollRecordItem> get _filteredPayroll {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _payrollRegister;
    return _payrollRegister.where((p) {
      return p.empName.toLowerCase().contains(q) ||
          p.payslipRef.toLowerCase().contains(q) ||
          p.bankName.toLowerCase().contains(q) ||
          p.bankAccount.toLowerCase().contains(q) ||
          p.status.toLowerCase().contains(q);
    }).toList();
  }

  // ─── ACTION MODALS ──────────────────────────────────────────

  void _openGrantLoanDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _GrantEmployeeLoanDialog(
        employees: const ['kiran Kumar C', 'Ravi Kumar', 'Arun Kumar'],
        onGrantLoan: (newLoan) {
          setState(() {
            _loans.insert(0, newLoan);
            _activeTab = 3; // Switch to Loans tab
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loan of ₹${newLoan.loanAmount.toStringAsFixed(0)} allocated for ${newLoan.empName}.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openProcessPayrollDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _ProcessMonthlyPayrollDialog(
        employees: const ['kiran Kumar C', 'Ravi Kumar', 'Arun Kumar'],
        onProcess: (newRecord) {
          setState(() {
            _payrollRegister.insert(0, newRecord);
            _activeTab = 0; // Switch to Monthly Register tab
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payroll processed for ${newRecord.empName} (Ref: ${newRecord.payslipRef}).'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openPayslipDetailsDialog(PayrollRecordItem record) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _PayslipDetailsDialog(
        record: record,
        onEdit: () {
          Navigator.of(ctx).pop();
          _openEditPayslipDialog(record);
        },
        onDelete: () {
          setState(() {
            _payrollRegister.remove(record);
          });
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payslip "${record.payslipRef}" deleted.'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openEditPayslipDialog(PayrollRecordItem record) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _EditPayslipDialog(
        record: record,
        onSave: (updated) {
          setState(() {
            record.baseSalary = updated.baseSalary;
            record.hra = updated.hra;
            record.specialAllowance = updated.specialAllowance;
            record.bonus = updated.bonus;
            record.epf = updated.epf;
            record.esi = updated.esi;
            record.tds = updated.tds;
            record.professionalTax = updated.professionalTax;
            record.bankName = updated.bankName;
            record.bankAccount = updated.bankAccount;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payslip "${record.payslipRef}" updated successfully.'),
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

  // ─── BUILD ROOT ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    if (isMacOS) {
      return _buildDesktopView(screenWidth, isMobile);
    }

    return _buildMobileView(context);
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP VIEW (Preserved strictly for macOS)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopView(double screenWidth, bool isMobile) {
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
            // ─── 1. TOP HEADER & ACTION BUTTONS (Image 1 & 5) ───
            _buildTopHeader(isMobile),
            const SizedBox(height: 20),

            // ─── 2. FOUR METRIC STAT CARDS WITH ACCENT STRIPES (Image 1 & 5) ───
            _buildMetricCards(isMobile),
            const SizedBox(height: 20),

            // ─── 3. FOUR TAB NAVIGATION BAR ───
            _buildTabBar(isMobile),
            const SizedBox(height: 18),

            // ─── 4. ACTIVE TAB CONTENT ───
            if (_activeTab == 0) _buildRegisterContent(isMobile),
            if (_activeTab == 1) _buildStructuresContent(isMobile),
            if (_activeTab == 2) _buildComplianceContent(isMobile),
            if (_activeTab == 3) _buildLoansContent(isMobile),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE OS REDESIGNED VIEW (Matching Reports / Barcode / Marketing)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton(
          heroTag: 'payroll_mobile_fab',
          onPressed: () {
            if (_activeTab == 3) {
              _openGrantLoanDialog();
            } else {
              _openProcessPayrollDialog();
            }
          },
          backgroundColor: const Color(0xFFBE185D),
          elevation: 4,
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 22),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting/Reports Style Header) ───
          SliverToBoxAdapter(
            child: _buildHeroSummary(true)
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
              height: 52,
              child: Container(
                color: const Color(0xFFF8F9FB),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _buildMobileTabNav(),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // ─── MAIN CONTENT CONTAINER (Tables & Lists) ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 140),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_activeTab == 0) _buildRegisterContent(true),
                  if (_activeTab == 1) _buildStructuresContent(true),
                  if (_activeTab == 2) _buildComplianceContent(true),
                  if (_activeTab == 3) _buildLoansContent(true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY CARD (Matching Reports / Barcode / Marketing)
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
          // Header Title Row
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
                      child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PAYROLL ENGINE & DISBURSEMENTS',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'SYSTEM ACTIVE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeroActionButton(
                label: 'Process Monthly Payroll',
                icon: LucideIcons.plus,
                onPressed: _openProcessPayrollDialog,
                isPrimary: true,
              ),
              _buildHeroActionButton(
                label: 'Allocate Employee Loan',
                icon: LucideIcons.sliders,
                onPressed: _openGrantLoanDialog,
                isPrimary: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 4 KPI Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildHeroKpiChip('MONTHLY EXPENSE', '₹${(_totalMonthlyExpense / 100000).toStringAsFixed(1)}L'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('STATUTORY COMPLIANCE', '₹6,325 Filed'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('OUTSTANDING LOANS', '₹${(_totalLoansOutstanding / 1000).toStringAsFixed(0)}K'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('PAYSLIPS GENERATED', '${_payrollRegister.length} Slips'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isPrimary ? const Color(0xFF0F172A) : Colors.white,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPrimary ? const Color(0xFF0F172A) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroKpiChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STICKY MOBILE TAB NAVIGATION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileTabNav() {
    final tabs = [
      (label: 'Monthly Payroll Register', icon: LucideIcons.fileText),
      (label: 'Salary Structures (CTC)', icon: LucideIcons.creditCard),
      (label: 'Compliance (PF / ESI / PAN)', icon: LucideIcons.shieldCheck),
      (label: 'Loans & Salary Advances', icon: LucideIcons.sliders),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = _activeTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 13,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _activeTab = index),
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                ),
              ),
              elevation: isSelected ? 2 : 0,
              pressElevation: 1,
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP HEADER (Image 1 & 5)
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
                  LucideIcons.creditCard,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Workforce Payroll Engine',
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
            'Manage monthly earnings structures, HRA allowances, EPF/ESI statutory compliance filings, TDS calculations, loans EMIs, and auto payouts.',
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
                  label: 'Allocate Employee Loan',
                  icon: LucideIcons.sliders,
                  color: const Color(0xFFBE185D),
                  borderColor: const Color(0xFFFDA4AF),
                  bgColor: const Color(0xFFFFF1F2),
                  onPressed: _openGrantLoanDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openProcessPayrollDialog,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text(
                    'Process Monthly Payroll',
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
            LucideIcons.creditCard,
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
                'Workforce Payroll Engine',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Manage monthly earnings structures, HRA allowances, EPF/ESI statutory compliance filings, TDS calculations, loans EMIs, and auto payouts.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Top right action buttons (Image 1)
        _buildHeaderActionButton(
          label: 'Allocate Employee Loan',
          icon: LucideIcons.sliders,
          color: const Color(0xFFBE185D),
          borderColor: const Color(0xFFFDA4AF),
          bgColor: const Color(0xFFFFF1F2),
          onPressed: _openGrantLoanDialog,
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _openProcessPayrollDialog,
          icon: const Icon(LucideIcons.plus, size: 14),
          label: const Text(
            'Process Monthly Payroll',
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
  // 2. FOUR METRIC STAT CARDS WITH ACCENT STRIPES (Image 1 & 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMetricCards(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final card1 = _buildSingleMetricCard(
          accentColor: const Color(0xFFEC4899), // Pink
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.creditCard,
                size: 16,
                color: Color(0xFFDB2777),
              ),
            ),
          ),
          mainValue: '₹${_totalMonthlyExpense.toStringAsFixed(0)}',
          subLabel: 'MONTHLY SALARY EXPENSE',
        );

        final card2 = _buildSingleMetricCard(
          accentColor: const Color(0xFF10B981), // Emerald/Green
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.shieldCheck,
                size: 16,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
          mainValue: '₹6,325 Filed',
          subLabel: 'COMPLIANCE PF / ESI',
        );

        final card3 = _buildSingleMetricCard(
          accentColor: const Color(0xFF3B82F6), // Blue
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.sliders,
                size: 16,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          mainValue: '₹${_totalLoansOutstanding.toStringAsFixed(0)}',
          subLabel: 'OUTSTANDING LOANS',
        );

        final card4 = _buildSingleMetricCard(
          accentColor: const Color(0xFF8B5CF6), // Purple
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.fileText,
                size: 16,
                color: Color(0xFF7C3AED),
              ),
            ),
          ),
          mainValue: '${_payrollRegister.length} Generated',
          subLabel: 'TOTAL PAYSLIPS',
        );

        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              card1,
              const SizedBox(height: 10),
              card2,
              const SizedBox(height: 10),
              card3,
              const SizedBox(height: 10),
              card4,
            ],
          );
        }

        if (constraints.maxWidth < 1100) {
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
              Row(
                children: [
                  Expanded(child: card3),
                  const SizedBox(width: 12),
                  Expanded(child: card4),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 12),
            Expanded(child: card2),
            const SizedBox(width: 12),
            Expanded(child: card3),
            const SizedBox(width: 12),
            Expanded(child: card4),
          ],
        );
      },
    );
  }

  Widget _buildSingleMetricCard({
    required Color accentColor,
    required Widget iconBadge,
    required String mainValue,
    required String subLabel,
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
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left vertical accent stripe
            Container(
              width: 5,
              color: accentColor,
            ),
            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconBadge,
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        mainValue,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.3,
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

  // ═══════════════════════════════════════════════════════════════
  // 3. FOUR TAB NAVIGATION BAR (Image 1 & 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isMobile) {
    final tabs = [
      _TabConfig(
        title: 'Monthly Payroll Register',
        icon: LucideIcons.fileText,
        activeColor: const Color(0xFFBE185D), // Magenta (Image 1)
      ),
      _TabConfig(
        title: 'Salary Structures (CTC)',
        icon: LucideIcons.creditCard,
        activeColor: const Color(0xFF2563EB), // Royal Blue (Image 5)
      ),
      _TabConfig(
        title: 'Compliance (PF / ESI / PAN)',
        icon: LucideIcons.shieldCheck,
        activeColor: const Color(0xFF7C3AED), // Solid Purple (Image 6)
      ),
      _TabConfig(
        title: 'Loans & Salary Advances',
        icon: LucideIcons.sliders,
        activeColor: const Color(0xFF059669), // Solid Emerald Green (Image 7)
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
  // TAB 0: MONTHLY PAYROLL REGISTER (Image 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRegisterContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input (Image 1)
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Search salary register...',
                hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Register Table (Image 1)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
              if (isMobile && !isMacOS) {
                return _buildMobilePayrollRegisterCardList(_filteredPayroll);
              }

              const minWidth = 1040.0;
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 14, child: _buildSortableHeader('PAYSLIP REF')),
                            Expanded(flex: 16, child: _buildSortableHeader('EMPLOYEE')),
                            Expanded(flex: 12, child: _buildSortableHeader('BASE SALARY')),
                            Expanded(flex: 12, child: _buildSortableHeader('EARNINGS')),
                            Expanded(flex: 12, child: _buildSortableHeader('DEDUCTIONS')),
                            Expanded(flex: 14, child: _buildSortableHeader('NET TAKE HOME')),
                            Expanded(flex: 14, child: _buildSortableHeader('BANK ACCOUNT')),
                            Expanded(flex: 10, child: _buildSortableHeader('STATUS')),
                          ],
                        ),
                      ),

                      // Rows (Image 1)
                      if (_filteredPayroll.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Center(
                            child: Text(
                              'No payroll records found matching search.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ),
                        )
                      else
                        ..._filteredPayroll.map((record) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _openPayslipDetailsDialog(record),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                                ),
                                child: Row(
                                  children: [
                                    // PAYSLIP REF
                                    Expanded(
                                      flex: 14,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.payslipRef,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF065F46),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            record.month,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // EMPLOYEE
                                    Expanded(
                                      flex: 16,
                                      child: Text(
                                        record.empName,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    // BASE SALARY (Bold green #047857)
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                        '₹${record.baseSalary.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ),

                                    // EARNINGS (Bold green #047857)
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                        '₹${record.otherEarnings.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ),

                                    // DEDUCTIONS (Bold red #DC2626)
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                        '-₹${record.totalDeductions.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),

                                    // NET TAKE HOME (Bold black #0F172A)
                                    Expanded(
                                      flex: 14,
                                      child: Text(
                                        '₹${record.netTakeHome.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    // BANK ACCOUNT (hdfc BANK in green + sub)
                                    Expanded(
                                      flex: 14,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.bankName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF047857),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            record.bankAccount,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // STATUS (PAID pill badge)
                                    Expanded(
                                      flex: 10,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            record.status,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF166534),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
  // TAB 1: SALARY STRUCTURES (CTC) (Image 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStructuresContent(bool isMobile) {
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
          // Title (Image 5)
          const Text(
            'Compensation Breakdown Structure (Annual CTC)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 18),

          // Table (Image 5)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
              if (isMobile && !isMacOS) {
                return _buildMobileStructuresCardList(_structures);
              }
              const minWidth = 880.0;
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 22, child: _TableHeaderText('Employee Name')),
                            Expanded(flex: 22, child: _TableHeaderText('Basic Base Salary')),
                            Expanded(flex: 24, child: _TableHeaderText('House Rent Allowance (HRA)')),
                            Expanded(flex: 22, child: _TableHeaderText('Special Allowances')),
                            Expanded(flex: 20, child: _TableHeaderText('Approx Annual Cost (CTC)')),
                          ],
                        ),
                      ),

                      // Rows (Image 5)
                      ..._structures.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          child: Row(
                            children: [
                              // Employee Name (dark green #065F46)
                              Expanded(
                                flex: 22,
                                child: Text(
                                  s.empName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                              // Basic Base Salary
                              Expanded(
                                flex: 22,
                                child: Text(
                                  '₹${s.basicBase.toStringAsFixed(0)} / Month',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                              // House Rent Allowance (HRA)
                              Expanded(
                                flex: 24,
                                child: Text(
                                  '₹${s.hra.toStringAsFixed(0)} / Month',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                              // Special Allowances
                              Expanded(
                                flex: 22,
                                child: Text(
                                  '₹${s.specialAllowances.toStringAsFixed(0)} / Month',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                              // Approx Annual Cost (CTC)
                              Expanded(
                                flex: 20,
                                child: Text(
                                  '₹${s.annualCtc.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
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
  // TAB 2: COMPLIANCE (PF / ESI / PAN) (Image 6)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildComplianceContent(bool isMobile) {
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
          const Text(
            'Statutory EPF, ESI, PAN Compliance Identifiers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
              if (isMobile && !isMacOS) {
                return _buildMobileComplianceCardList(_complianceList);
              }
              const minWidth = 940.0;
              final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 20, child: _TableHeaderText('Employee Name')),
                            Expanded(flex: 20, child: _TableHeaderText('PAN Number')),
                            Expanded(flex: 24, child: _TableHeaderText('Universal Account Number (UAN)')),
                            Expanded(flex: 20, child: _TableHeaderText('ESI Identification No')),
                            Expanded(flex: 24, child: _TableHeaderText('Monthly EPF Contribution')),
                          ],
                        ),
                      ),
                      ..._complianceList.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 20, child: Text(c.empName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                              Expanded(flex: 20, child: Text(c.panNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                              Expanded(flex: 24, child: Text(c.uanNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                              Expanded(flex: 20, child: Text(c.esiNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                              Expanded(flex: 24, child: Text('₹${c.monthlyEpf.toStringAsFixed(0)} ${c.autoEpfText}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
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
  // TAB 3: LOANS & SALARY ADVANCES (Image 7)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLoansContent(bool isMobile) {
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
          const Text(
            'Active Loans & Salary Advance Balances',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
              if (isMobile && !isMacOS) {
                return _buildMobileLoansCardList(_loans);
              }
              const minWidth = 940.0;
              final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 20, child: _TableHeaderText('Employee Name')),
                            Expanded(flex: 18, child: _TableHeaderText('Granted Loan Amount')),
                            Expanded(flex: 20, child: _TableHeaderText('Monthly EMI deduction')),
                            Expanded(flex: 20, child: _TableHeaderText('Remaining Loan Balance')),
                            Expanded(flex: 18, child: _TableHeaderText('Deduction Duration')),
                            Expanded(flex: 16, child: _TableHeaderText('Salary Advance')),
                          ],
                        ),
                      ),
                      ..._loans.map((l) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 20, child: Text(l.empName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                              Expanded(flex: 18, child: Text('₹${l.loanAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                              Expanded(flex: 20, child: Text('-₹${l.monthlyEmi.toStringAsFixed(0)} / Month', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)))),
                              Expanded(flex: 20, child: Text('₹${l.remainingBalance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                              Expanded(flex: 18, child: Text('${l.deductionPeriodMonths} Months', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                              Expanded(flex: 16, child: Text('₹${l.salaryAdvance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
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

  Widget _buildSortableHeader(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

  // ═══════════════════════════════════════════════════════════════
  // MOBILE CARD PRESENTATION WIDGETS (PAYROLL PAGE)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobilePayrollRegisterCardList(List<PayrollRecordItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: Text(
            'No payroll records found matching search.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final record = items[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openPayslipDetailsDialog(record),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.tableBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          record.payslipRef,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            record.month,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              record.status,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.empName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.bankName} • ${record.bankAccount}',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BASE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  Text('₹${record.baseSalary.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('EARNINGS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  Text('₹${record.otherEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('DEDUCTIONS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  Text('-₹${record.totalDeductions.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('NET PAY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  const SizedBox(height: 2),
                                  Text('₹${record.netTakeHome.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                ],
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
      },
    );
  }

  Widget _buildMobileStructuresCardList(List<SalaryStructureItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No salary structures defined.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final s = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.tableBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    s.empName,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                  Text(
                    'CTC: ₹${s.annualCtc.toStringAsFixed(0)} /yr',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BASIC BASE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text('₹${s.basicBase.toStringAsFixed(0)} /mo', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HRA', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text('₹${s.hra.toStringAsFixed(0)} /mo', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SPECIAL', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text('₹${s.specialAllowances.toStringAsFixed(0)} /mo', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileComplianceCardList(List<ComplianceRecordItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No compliance records found.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final c = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.tableBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.empName,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text('PAN: ${c.panNumber}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF065F46))),
                  const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                  Text('UAN: ${c.uanNumber}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF065F46))),
                  const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                  Text('ESI: ${c.esiNumber}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF065F46))),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('EPF Contribution:', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '₹${c.monthlyEpf.toStringAsFixed(0)} ${c.autoEpfText}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLoansCardList(List<LoanRecordItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No loan records found.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final l = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.tableBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    l.empName,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    '${l.deductionPeriodMonths} Months Tenure',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LOAN AMOUNT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text('₹${l.loanAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MONTHLY EMI', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text('-₹${l.monthlyEmi.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('REMAINING', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text('₹${l.remainingBalance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (l.salaryAdvance > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'Salary Advance: ₹${l.salaryAdvance.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                ),
              ],
            ],
          ),
        );
      },
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

// ─── 1. PAYSLIP DETAILS MODAL (Image 2) ───────────────────────

class _PayslipDetailsDialog extends StatelessWidget {
  final PayrollRecordItem record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PayslipDetailsDialog({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 560,
          constraints: BoxConstraints(maxWidth: 580, maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 28,
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
                // Top Header Row with Icon, Title, Edit, Delete, Close (Image 2)
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.fileText, size: 18, color: Color(0xFF166534)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payslip: ${record.payslipRef}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${record.empName} · ',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              const Text(
                                'May 2026',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Edit Button
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(LucideIcons.pencil, size: 12),
                      label: const Text('Edit', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete Button
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(LucideIcons.trash2, size: 12, color: Color(0xFFDC2626)),
                      label: const Text('Delete', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close X Button
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
                const SizedBox(height: 20),

                // Mint Green Summary Banner (Image 2)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Bank Disbursement & Compliance Portal IDs
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'BANK DISBURSEMENT',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF166534), letterSpacing: 0.3),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  record.bankName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'A/C: ${record.bankAccount}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'COMPLIANCE PORTAL IDS',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF166534), letterSpacing: 0.3),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'PAN:  ${record.pan}',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'UAN:  ${record.uan}',
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 3 Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('GROSS EARNINGS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${record.grossEarnings.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('TOTAL DEDUCTIONS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF991B1B))),
                                  const SizedBox(height: 4),
                                  Text(
                                    '-₹${record.totalDeductions.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('NET TAKE HOME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF0369A1))),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${record.netTakeHome.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Side by Side Breakdown Cards (Image 2)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 450;

                    final earningsCard = Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(LucideIcons.trendingUp, size: 14, color: Color(0xFF16A34A)),
                              SizedBox(width: 6),
                              Text('Earnings Breakdown', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Basic Salary', '₹${record.baseSalary.toStringAsFixed(0)}'),
                          _buildDetailRow('HRA Allowance', '₹${record.hra.toStringAsFixed(0)}'),
                          _buildDetailRow('Special Allowance', '₹${record.specialAllowance.toStringAsFixed(0)}'),
                          _buildDetailRow('Bonus / Incentive', '₹${record.bonus.toStringAsFixed(0)}'),
                        ],
                      ),
                    );

                    final deductionsCard = Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(LucideIcons.triangleAlert, size: 14, color: Color(0xFFDC2626)),
                              SizedBox(width: 6),
                              Text('Deductions Breakdown', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('EPF (12%)', '-₹${record.epf.toStringAsFixed(0)}', isRed: true),
                          _buildDetailRow('ESI', '-₹${record.esi.toStringAsFixed(0)}', isRed: true),
                          _buildDetailRow('TDS Income Tax', '-₹${record.tds.toStringAsFixed(0)}', isRed: true),
                          _buildDetailRow('Professional Tax', '-₹${record.professionalTax.toStringAsFixed(0)}', isRed: true),
                        ],
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        children: [
                          earningsCard,
                          const SizedBox(height: 12),
                          deductionsCard,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: earningsCard),
                        const SizedBox(width: 14),
                        Expanded(child: deductionsCard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Prior Months Ledger Payout Timeline (Image 2)
                Row(
                  children: const [
                    Icon(LucideIcons.history, size: 14, color: Color(0xFF475569)),
                    SizedBox(width: 6),
                    Text('Prior Months Ledger Payout Timeline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('May 2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('Ref: ${record.payslipRef}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${record.netTakeHome.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const Text('PAID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Generate & Print Official Payslip (PDF) (Image 2)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Official PDF for "${record.payslipRef}" generated successfully.'),
                          backgroundColor: const Color(0xFF047857),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.download, size: 15),
                    label: const Text('Generate & Print Official Payslip (PDF)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildDetailRow(String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isRed ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 2. GRANT EMPLOYEE LOAN DIALOG (Image 3) ──────────────────

class _GrantEmployeeLoanDialog extends StatefulWidget {
  final List<String> employees;
  final void Function(LoanRecordItem newLoan) onGrantLoan;

  const _GrantEmployeeLoanDialog({
    required this.employees,
    required this.onGrantLoan,
  });

  @override
  State<_GrantEmployeeLoanDialog> createState() => _GrantEmployeeLoanDialogState();
}

class _GrantEmployeeLoanDialogState extends State<_GrantEmployeeLoanDialog> {
  String _selectedEmployee = '-- Select Employee --';
  final _amountCtrl = TextEditingController();
  final _emiCtrl = TextEditingController();
  final _periodCtrl = TextEditingController();
  final _advanceCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _emiCtrl.dispose();
    _periodCtrl.dispose();
    _advanceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final emp = _selectedEmployee == '-- Select Employee --' ? 'kiran Kumar C' : _selectedEmployee;
    final loanAmt = double.tryParse(_amountCtrl.text.trim()) ?? 2000.0;
    final emi = double.tryParse(_emiCtrl.text.trim()) ?? 50.0;
    final period = int.tryParse(_periodCtrl.text.trim()) ?? 40;
    final advance = double.tryParse(_advanceCtrl.text.trim()) ?? 500.0;

    final newLoan = LoanRecordItem(
      empName: emp,
      loanAmount: loanAmt,
      monthlyEmi: emi,
      remainingBalance: loanAmt,
      deductionPeriodMonths: period,
      salaryAdvance: advance,
    );

    widget.onGrantLoan(newLoan);
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
                // Header (Image 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grant Employee Loan',
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

                // Employee Name
                const Text('Employee Name', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedEmployee,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                      items: ['-- Select Employee --', ...widget.employees].map((emp) {
                        return DropdownMenuItem(
                          value: emp,
                          child: Text(emp, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedEmployee = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Loan Amount & Monthly EMI (Image 3)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Loan Amount (₹)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_amountCtrl, 'e.g. 2000', isNumeric: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly EMI (₹)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_emiCtrl, 'e.g. 50', isNumeric: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Loan Deduction Period (Months)
                const Text('Loan Deduction Period (Months)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_periodCtrl, 'e.g. 40', isNumeric: true),
                const SizedBox(height: 16),

                // Immediate Salary Advance (₹)
                const Text('Immediate Salary Advance (₹)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                _buildField(_advanceCtrl, 'e.g. 500', isNumeric: true),
                const SizedBox(height: 24),

                // Settle Granted Loan Allocation (Purple #7C3AED as in Image 3)
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
                      'Settle Granted Loan Allocation',
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
}

// ─── 3. PROCESS MONTHLY PAYROLL DIALOG (Image 4) ──────────────

class _ProcessMonthlyPayrollDialog extends StatefulWidget {
  final List<String> employees;
  final void Function(PayrollRecordItem newRecord) onProcess;

  const _ProcessMonthlyPayrollDialog({
    required this.employees,
    required this.onProcess,
  });

  @override
  State<_ProcessMonthlyPayrollDialog> createState() => _ProcessMonthlyPayrollDialogState();
}

class _ProcessMonthlyPayrollDialogState extends State<_ProcessMonthlyPayrollDialog> {
  String _selectedEmployee = '-- Select Staff Member --';
  final _basicCtrl = TextEditingController();
  final _hraCtrl = TextEditingController();
  final _specialCtrl = TextEditingController();
  final _bonusCtrl = TextEditingController();
  final _esiCtrl = TextEditingController();
  final _tdsCtrl = TextEditingController();
  bool _deductPf = true;

  @override
  void dispose() {
    _basicCtrl.dispose();
    _hraCtrl.dispose();
    _specialCtrl.dispose();
    _bonusCtrl.dispose();
    _esiCtrl.dispose();
    _tdsCtrl.dispose();
    super.dispose();
  }

  double get _computedPf {
    final basic = double.tryParse(_basicCtrl.text.trim()) ?? 0;
    return _deductPf ? (basic * 0.12) : 0;
  }

  void _submit() {
    final emp = _selectedEmployee == '-- Select Staff Member --' ? 'kiran Kumar C' : _selectedEmployee;
    final basic = double.tryParse(_basicCtrl.text.trim()) ?? 50000.0;
    final hra = double.tryParse(_hraCtrl.text.trim()) ?? 5000.0;
    final special = double.tryParse(_specialCtrl.text.trim()) ?? 2000.0;
    final bonus = double.tryParse(_bonusCtrl.text.trim()) ?? 3000.0;
    final epf = _deductPf ? (basic * 0.12) : 0.0;
    final esi = double.tryParse(_esiCtrl.text.trim()) ?? 325.0;
    final tds = double.tryParse(_tdsCtrl.text.trim()) ?? 100.0;
    final pt = 200.0;

    final refNum = 511 + math.Random().nextInt(400);

    final record = PayrollRecordItem(
      payslipRef: 'PSN-2026-$refNum',
      month: 'Month: May 2026',
      empName: emp,
      empId: 'CLK-0033',
      baseSalary: basic,
      hra: hra,
      specialAllowance: special,
      bonus: bonus,
      epf: epf,
      esi: esi,
      tds: tds,
      professionalTax: pt,
      bankName: 'hdfc BANK',
      bankAccount: 'kdjbjhffjksb',
      status: 'PAID',
    );

    widget.onProcess(record);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;
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
            padding: EdgeInsets.all(isMobile ? 18 : 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Process Monthly Payroll',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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

                // Select Employee
                const Text('Select Employee', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedEmployee,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                      items: ['-- Select Staff Member --', ...widget.employees].map((emp) {
                        return DropdownMenuItem(
                          value: emp,
                          child: Text(emp, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedEmployee = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Basic Base Salary & HRA Allowance (Image 4)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Basic Base Salary (₹)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_basicCtrl, 'e.g. 50000', isNumeric: true, onChanged: (_) => setState(() {})),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HRA Allowance (₹)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_hraCtrl, 'e.g. 5000', isNumeric: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Special Allowance & Bonus / Incentives
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Special Allowance', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_specialCtrl, 'e.g. 2000', isNumeric: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bonus / Incentives', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const SizedBox(height: 6),
                          _buildField(_bonusCtrl, 'e.g. 3000', isNumeric: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row: Deduct 12% PF (with Est: ₹0), ESI Deduction, Estimated TDS (Image 4)
                if (isMobile) ...[
                  InkWell(
                    onTap: () => setState(() => _deductPf = !_deductPf),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _deductPf,
                          onChanged: (v) => setState(() => _deductPf = v ?? true),
                          activeColor: const Color(0xFF7C3AED),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Deduct 12% PF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            Text('Est: ₹${_computedPf.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ESI Deduction', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            _buildField(_esiCtrl, 'e.g. 325', isNumeric: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated TDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            _buildField(_tdsCtrl, 'e.g. 100', isNumeric: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 12,
                        child: InkWell(
                          onTap: () => setState(() => _deductPf = !_deductPf),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: _deductPf,
                                onChanged: (v) => setState(() => _deductPf = v ?? true),
                                activeColor: const Color(0xFF7C3AED),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Deduct 12% PF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  Text('Est: ₹${_computedPf.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ESI Deduction', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            _buildField(_esiCtrl, 'e.g. 325', isNumeric: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated TDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                            const SizedBox(height: 6),
                            _buildField(_tdsCtrl, 'e.g. 100', isNumeric: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Settle Monthly Take-Home Salary (Purple #7C3AED as in Image 4)
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
                      'Settle Monthly Take-Home Salary',
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

  Widget _buildField(TextEditingController ctrl, String hint, {bool isNumeric = false, ValueChanged<String>? onChanged}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
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

// ─── 4. EDIT PAYSLIP DIALOG ───────────────────────────────────

class _EditPayslipDialog extends StatefulWidget {
  final PayrollRecordItem record;
  final void Function(PayrollRecordItem updated) onSave;

  const _EditPayslipDialog({
    required this.record,
    required this.onSave,
  });

  @override
  State<_EditPayslipDialog> createState() => _EditPayslipDialogState();
}

class _EditPayslipDialogState extends State<_EditPayslipDialog> {
  late final TextEditingController _baseSalaryCtrl;
  late final TextEditingController _hraCtrl;
  late final TextEditingController _specialCtrl;
  late final TextEditingController _bonusCtrl;
  late final TextEditingController _epfCtrl;
  late final TextEditingController _esiCtrl;
  late final TextEditingController _tdsCtrl;
  late final TextEditingController _ptCtrl;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _bankAccountCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _baseSalaryCtrl = TextEditingController(text: r.baseSalary.toStringAsFixed(0));
    _hraCtrl = TextEditingController(text: r.hra.toStringAsFixed(0));
    _specialCtrl = TextEditingController(text: r.specialAllowance.toStringAsFixed(0));
    _bonusCtrl = TextEditingController(text: r.bonus.toStringAsFixed(0));
    _epfCtrl = TextEditingController(text: r.epf.toStringAsFixed(0));
    _esiCtrl = TextEditingController(text: r.esi.toStringAsFixed(0));
    _tdsCtrl = TextEditingController(text: r.tds.toStringAsFixed(0));
    _ptCtrl = TextEditingController(text: r.professionalTax.toStringAsFixed(0));
    _bankNameCtrl = TextEditingController(text: r.bankName);
    _bankAccountCtrl = TextEditingController(text: r.bankAccount);
  }

  @override
  void dispose() {
    _baseSalaryCtrl.dispose();
    _hraCtrl.dispose();
    _specialCtrl.dispose();
    _bonusCtrl.dispose();
    _epfCtrl.dispose();
    _esiCtrl.dispose();
    _tdsCtrl.dispose();
    _ptCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankAccountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final updated = PayrollRecordItem(
      payslipRef: widget.record.payslipRef,
      month: widget.record.month,
      empName: widget.record.empName,
      empId: widget.record.empId,
      baseSalary: double.tryParse(_baseSalaryCtrl.text.trim()) ?? widget.record.baseSalary,
      hra: double.tryParse(_hraCtrl.text.trim()) ?? widget.record.hra,
      specialAllowance: double.tryParse(_specialCtrl.text.trim()) ?? widget.record.specialAllowance,
      bonus: double.tryParse(_bonusCtrl.text.trim()) ?? widget.record.bonus,
      epf: double.tryParse(_epfCtrl.text.trim()) ?? widget.record.epf,
      esi: double.tryParse(_esiCtrl.text.trim()) ?? widget.record.esi,
      tds: double.tryParse(_tdsCtrl.text.trim()) ?? widget.record.tds,
      professionalTax: double.tryParse(_ptCtrl.text.trim()) ?? widget.record.professionalTax,
      bankName: _bankNameCtrl.text.trim(),
      bankAccount: _bankAccountCtrl.text.trim(),
    );

    widget.onSave(updated);
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
          width: 500,
          constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 22, 18, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '✏️ Edit Payslip (${widget.record.payslipRef})',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildInput('Base Salary (₹)', _baseSalaryCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInput('HRA Allowance (₹)', _hraCtrl)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildInput('Special Allowance (₹)', _specialCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInput('Bonus / Incentive (₹)', _bonusCtrl)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildInput('EPF Deduction (₹)', _epfCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInput('ESI Deduction (₹)', _esiCtrl)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildInput('TDS Tax (₹)', _tdsCtrl)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInput('Professional Tax (₹)', _ptCtrl)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildInput('Disbursement Bank Name', _bankNameCtrl, isNumeric: false)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInput('Bank Account / Ref', _bankAccountCtrl, isNumeric: false)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF047857),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Save Payslip Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool isNumeric = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 5),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
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
