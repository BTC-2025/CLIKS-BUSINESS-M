import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

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

class SalaryAdvanceItem {
  final String id;
  String empName;
  double amount;
  String recoveryMonth;
  String reason;
  DateTime disbursalDate;
  String status;

  SalaryAdvanceItem({
    required this.id,
    required this.empName,
    required this.amount,
    required this.recoveryMonth,
    this.reason = '',
    required this.disbursalDate,
    this.status = 'DISBURSED',
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

// ─── MAIN PAYROLL PAGE ────────────────────────────────────────

class PayrollPage extends ConsumerStatefulWidget {
  const PayrollPage({super.key});

  @override
  ConsumerState<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends ConsumerState<PayrollPage> {
  // 0: Monthly Payroll Register (#E11D48)
  // 1: Salary Structures (CTC) (#2563EB)
  // 2: Compliance (PF / ESI / PAN) (#059669)
  // 3: Employee Loans (#4F46E5)
  // 4: Salary Advances (#D97706)
  int _activeTab = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedMonth = 'All Months (Show All)';
  final List<String> _payrollMonths = const [
    'All Months (Show All)',
    'Immediate (Next Payroll)',
    'January 2026',
    'February 2026',
    'March 2026',
    'April 2026',
    'May 2026',
    'June 2026',
    'July 2026',
    'August 2026',
    'September 2026',
    'October 2026',
    'November 2026',
    'December 2026',
    'January 2027',
    'February 2027',
    'March 2027',
    'April 2027',
  ];

  late List<PayrollRecordItem> _payrollRegister;
  late List<SalaryStructureItem> _structures;
  late List<ComplianceRecordItem> _complianceList;
  late List<LoanRecordItem> _loans;
  late List<SalaryAdvanceItem> _salaryAdvances;

  @override
  void initState() {
    super.initState();

    // Matching Image 1 initial display with 0 values
    _payrollRegister = [];

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

    _loans = [];
    _salaryAdvances = [];
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

  double get _totalSalaryAdvances {
    if (_salaryAdvances.isEmpty) return 0;
    return _salaryAdvances.fold<double>(0, (sum, a) => sum + a.amount);
  }

  List<PayrollRecordItem> get _filteredPayroll {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _payrollRegister.where((p) {
      final matchesSearch = q.isEmpty ||
          p.empName.toLowerCase().contains(q) ||
          p.payslipRef.toLowerCase().contains(q) ||
          p.bankName.toLowerCase().contains(q) ||
          p.bankAccount.toLowerCase().contains(q) ||
          p.status.toLowerCase().contains(q);

      final matchesMonth = _selectedMonth == 'All Months (Show All)' ||
          p.month.toLowerCase().contains(_selectedMonth.toLowerCase());

      return matchesSearch && matchesMonth;
    }).toList();
  }

  // ─── ACTION MODALS ──────────────────────────────────────────

  void _openGrantLoanDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _GrantEmployeeLoanDialog(
        employees: const ['kiran Kumar C', 'Ravi Kumar', 'Arun Kumar', 'Priya Sharma'],
        onGrantLoan: (newLoan) {
          setState(() {
            _loans.insert(0, newLoan);
            _activeTab = 3; // Switch to Employee Loans tab
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loan of ₹${newLoan.loanAmount.toStringAsFixed(0)} allocated for ${newLoan.empName}.'),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openDisburseSalaryAdvanceDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _DisburseSalaryAdvanceDialog(
        employees: const ['kiran Kumar C', 'Ravi Kumar', 'Arun Kumar', 'Priya Sharma'],
        onDisburse: (newAdvance) {
          setState(() {
            _salaryAdvances.insert(0, newAdvance);
            _activeTab = 4; // Switch to Salary Advances tab
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Salary advance of ₹${newAdvance.amount.toStringAsFixed(0)} disbursed to ${newAdvance.empName}.'),
              backgroundColor: const Color(0xFFD97706),
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
        employees: const ['kiran Kumar C', 'Ravi Kumar', 'Arun Kumar', 'Priya Sharma'],
        onProcess: (newRecord) {
          setState(() {
            _payrollRegister.insert(0, newRecord);
            _activeTab = 0; // Switch to Monthly Register tab
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payroll processed for ${newRecord.empName} (Ref: ${newRecord.payslipRef}).'),
              backgroundColor: const Color(0xFF059669),
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
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  // ─── BUILD ROOT (Universal for all OS's) ──────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isMobile ? 14 : 24,
          isMobile ? 14 : 20,
          isMobile ? 14 : 24,
          isMobile ? 80 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP HEADER & ACTION BUTTONS (Image 1) ───
            _buildTopHeader(isMobile),
            const SizedBox(height: 20),

            // ─── 2. FIVE METRIC STAT CARDS WITH TOP ACCENT STRIPES (Image 1) ───
            _buildMetricCards(isMobile),
            const SizedBox(height: 20),

            // ─── 3. FIVE TAB NAVIGATION BAR (Image 1) ───
            _buildTabBar(isMobile),
            const SizedBox(height: 18),

            // ─── 4. ACTIVE TAB CONTENT ───
            if (_activeTab == 0) _buildRegisterContent(isMobile),
            if (_activeTab == 1) _buildStructuresContent(isMobile),
            if (_activeTab == 2) _buildComplianceContent(isMobile),
            if (_activeTab == 3) _buildLoansContent(isMobile),
            if (_activeTab == 4) _buildSalaryAdvancesContent(isMobile),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP HEADER (Image 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopHeader(bool isMobile) {
    final titleSection = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(10),
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
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actionButtons = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Button 1: Allocate Employee Loan (Green Outline)
        _buildHeaderActionButton(
          label: 'Allocate Employee Loan',
          icon: LucideIcons.slidersHorizontal,
          color: const Color(0xFF059669),
          borderColor: const Color(0xFF10B981),
          bgColor: Colors.white,
          onPressed: _openGrantLoanDialog,
        ),
        // Button 2: Disburse Salary Advance (Amber Outline - Image 1)
        _buildHeaderActionButton(
          label: 'Disburse Salary Advance',
          icon: LucideIcons.zap,
          color: const Color(0xFFD97706),
          borderColor: const Color(0xFFF59E0B),
          bgColor: Colors.white,
          onPressed: _openDisburseSalaryAdvanceDialog,
        ),
        // Button 3: + Process Monthly Payroll (Pink Solid - Image 1)
        ElevatedButton.icon(
          onPressed: _openProcessPayrollDialog,
          icon: const Icon(LucideIcons.plus, size: 15),
          label: const Text(
            'Process Monthly Payroll',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 14),
          actionButtons,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleSection),
        const SizedBox(width: 16),
        actionButtons,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. FIVE METRIC STAT CARDS WITH TOP ACCENT STRIPES (Image 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMetricCards(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Card 1: Monthly Salary Expense (Pink)
        final card1 = _buildSingleMetricCard(
          accentColor: const Color(0xFFF43F5E),
          iconBadge: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.creditCard,
                size: 18,
                color: Color(0xFFE11D48),
              ),
            ),
          ),
          mainValue: '₹${_totalMonthlyExpense.toStringAsFixed(0)}',
          subLabel: 'MONTHLY SALARY EXPENSE',
        );

        // Card 2: Compliance PF / ESI (Emerald)
        final card2 = _buildSingleMetricCard(
          accentColor: const Color(0xFF10B981),
          iconBadge: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.shieldCheck,
                size: 18,
                color: Color(0xFF059669),
              ),
            ),
          ),
          mainValue: '₹0 Filed',
          subLabel: 'COMPLIANCE PF / ESI',
        );

        // Card 3: Outstanding Loans (Blue)
        final card3 = _buildSingleMetricCard(
          accentColor: const Color(0xFF3B82F6),
          iconBadge: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.slidersHorizontal,
                size: 18,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          mainValue: '₹${_totalLoansOutstanding.toStringAsFixed(0)}',
          subLabel: 'OUTSTANDING LOANS',
        );

        // Card 4: Salary Advances (Amber - Image 1)
        final card4 = _buildSingleMetricCard(
          accentColor: const Color(0xFFF59E0B),
          iconBadge: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.zap,
                size: 18,
                color: Color(0xFFD97706),
              ),
            ),
          ),
          mainValue: '₹${_totalSalaryAdvances.toStringAsFixed(0)}',
          subValue: 'Disbursed',
          subLabel: 'SALARY ADVANCES',
        );

        // Card 5: Total Payslips (Purple - Image 1)
        final card5 = _buildSingleMetricCard(
          accentColor: const Color(0xFF8B5CF6),
          iconBadge: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.fileText,
                size: 18,
                color: Color(0xFF7C3AED),
              ),
            ),
          ),
          mainValue: '${_payrollRegister.length}',
          subValue: 'Generated',
          subLabel: 'TOTAL PAYSLIPS',
        );

        if (constraints.maxWidth >= 1050) {
          return Row(
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
        } else if (constraints.maxWidth >= 650) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 12),
                  Expanded(child: card2),
                  const SizedBox(width: 12),
                  Expanded(child: card3),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: card4),
                  const SizedBox(width: 12),
                  Expanded(child: card5),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              card1,
              const SizedBox(height: 10),
              card2,
              const SizedBox(height: 10),
              card3,
              const SizedBox(height: 10),
              card4,
              const SizedBox(height: 10),
              card5,
            ],
          );
        }
      },
    );
  }

  Widget _buildSingleMetricCard({
    required Color accentColor,
    required Widget iconBadge,
    required String mainValue,
    String? subValue,
    required String subLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top accent colored line
          Container(
            height: 3.5,
            color: accentColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconBadge,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (subValue != null && subValue.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              mainValue,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              subValue,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          mainValue,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      const SizedBox(height: 3),
                      Text(
                        subLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
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
  // 3. FIVE TAB NAVIGATION BAR (Image 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isMobile) {
    final tabs = [
      _TabConfig(
        title: 'Monthly Payroll Register',
        icon: LucideIcons.fileText,
        activeColor: const Color(0xFFE11D48), // Rose/Pink (Image 1)
      ),
      _TabConfig(
        title: 'Salary Structures (CTC)',
        icon: LucideIcons.creditCard,
        activeColor: const Color(0xFF2563EB), // Blue
      ),
      _TabConfig(
        title: 'Compliance (PF / ESI / PAN)',
        icon: LucideIcons.shieldCheck,
        activeColor: const Color(0xFF059669), // Emerald Green
      ),
      _TabConfig(
        title: 'Employee Loans',
        icon: LucideIcons.slidersHorizontal,
        activeColor: const Color(0xFF4F46E5), // Indigo
      ),
      _TabConfig(
        title: 'Salary Advances',
        icon: LucideIcons.zap,
        activeColor: const Color(0xFFD97706), // Amber (Image 1)
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
                              color: tab.activeColor.withValues(alpha: 0.22),
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
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Month Filter Bar (Image 1)
          LayoutBuilder(
            builder: (context, constraints) {
              final searchField = Container(
                height: 42,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              );

              final monthDropdown = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Payroll Month: ',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMonth,
                        icon: const Icon(LucideIcons.chevronDown, size: 15, color: Color(0xFF64748B)),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        items: _payrollMonths.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMonth = val);
                        },
                      ),
                    ),
                  ),
                ],
              );

              if (constraints.maxWidth < 650) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchField,
                    const SizedBox(height: 12),
                    monthDropdown,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 16),
                  monthDropdown,
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Register Table (Image 1 with exact columns)
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 1100.0;
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
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 14, child: _buildSortableHeader('PAYSLIP REF')),
                            Expanded(flex: 16, child: _buildSortableHeader('EMPLOYEE')),
                            Expanded(flex: 12, child: _buildSortableHeader('BASE SALARY')),
                            Expanded(flex: 12, child: _buildSortableHeader('EARNINGS')),
                            Expanded(flex: 12, child: _buildSortableHeader('DEDUCTIONS')),
                            Expanded(flex: 12, child: _buildSortableHeader('PROF. TAX (PT)')),
                            Expanded(flex: 14, child: _buildSortableHeader('NET TAKE HOME')),
                            Expanded(flex: 14, child: _buildSortableHeader('BANK ACCOUNT')),
                            Expanded(flex: 10, child: _buildSortableHeader('STATUS')),
                          ],
                        ),
                      ),

                      // Rows
                      if (_filteredPayroll.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          alignment: Alignment.center,
                          child: const Text(
                            'No payroll records found for the selected period.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                          ),
                        )
                      else
                        ..._filteredPayroll.map((record) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _openPayslipDetailsDialog(record),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
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
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF047857),
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    // BASE SALARY
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                        '₹${record.baseSalary.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ),

                                    // EARNINGS
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                        '₹${record.otherEarnings.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ),

                                    // DEDUCTIONS
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                        '-₹${record.totalDeductions.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),

                                    // PROF. TAX (PT) - Image 1
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                        '-₹${record.professionalTax.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),

                                    // NET TAKE HOME
                                    Expanded(
                                      flex: 14,
                                      child: Text(
                                        '₹${record.netTakeHome.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    // BANK ACCOUNT
                                    Expanded(
                                      flex: 14,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.bankName,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                          ),
                                          Text(
                                            record.bankAccount,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // STATUS
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
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF16A34A),
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
  // TAB 1: SALARY STRUCTURES (CTC)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStructuresContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Salary Structures (CTC Master)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Salary Structure form ready.')),
                  );
                },
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Structure', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 850.0;
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
                            Expanded(flex: 22, child: _TableHeaderText('Employee Name')),
                            Expanded(flex: 18, child: _TableHeaderText('Basic Base Salary')),
                            Expanded(flex: 18, child: _TableHeaderText('HRA Allowance')),
                            Expanded(flex: 20, child: _TableHeaderText('Special Allowances')),
                            Expanded(flex: 22, child: _TableHeaderText('Annual CTC (₹)')),
                          ],
                        ),
                      ),
                      if (_structures.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: const Text('No salary structures defined.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                        )
                      else
                        ..._structures.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 22, child: Text(s.empName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                Expanded(flex: 18, child: Text('₹${s.basicBase.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                                Expanded(flex: 18, child: Text('₹${s.hra.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                                Expanded(flex: 20, child: Text('₹${s.specialAllowances.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                                Expanded(flex: 22, child: Text('₹${s.annualCtc.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)))),
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
  // TAB 2: COMPLIANCE (PF / ESI / PAN)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildComplianceContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statutory Compliance Registry (EPF / ESI / TDS)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Statutory compliance audit verified.')),
                  );
                },
                icon: const Icon(LucideIcons.checkCheck, size: 14),
                label: const Text('Verify Compliance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 900.0;
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
                            Expanded(flex: 22, child: _TableHeaderText('Employee Name')),
                            Expanded(flex: 20, child: _TableHeaderText('PAN Number')),
                            Expanded(flex: 22, child: _TableHeaderText('UAN Number')),
                            Expanded(flex: 18, child: _TableHeaderText('ESI Code')),
                            Expanded(flex: 18, child: _TableHeaderText('Monthly EPF (12%)')),
                          ],
                        ),
                      ),
                      if (_complianceList.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: const Text('No compliance records configured.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                        )
                      else
                        ..._complianceList.map((c) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 22, child: Text(c.empName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                Expanded(flex: 20, child: Text(c.panNumber, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                                Expanded(flex: 22, child: Text(c.uanNumber, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                                Expanded(flex: 18, child: Text(c.esiNumber, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                                Expanded(flex: 18, child: Text('₹${c.monthlyEpf.toStringAsFixed(0)} (Auto 12%)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
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
  // TAB 3: EMPLOYEE LOANS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLoansContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Employee Loans & Repayments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              ElevatedButton.icon(
                onPressed: _openGrantLoanDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Allocate Loan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
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
                      if (_loans.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: const Text('No employee loans active.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                        )
                      else
                        ..._loans.map((l) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 20, child: Text(l.empName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                Expanded(flex: 18, child: Text('₹${l.loanAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                                Expanded(flex: 20, child: Text('-₹${l.monthlyEmi.toStringAsFixed(0)} / Month', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)))),
                                Expanded(flex: 20, child: Text('₹${l.remainingBalance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                                Expanded(flex: 18, child: Text('${l.deductionPeriodMonths} Months', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                                Expanded(flex: 16, child: Text('₹${l.salaryAdvance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
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
  // TAB 4: SALARY ADVANCES (Image 1, 2 & 3)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSalaryAdvancesContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Salary Advances & Instant Disbursals',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              ElevatedButton.icon(
                onPressed: _openDisburseSalaryAdvanceDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Disburse Advance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
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
                            Expanded(flex: 22, child: _TableHeaderText('Employee Name')),
                            Expanded(flex: 18, child: _TableHeaderText('Advance Amount (₹)')),
                            Expanded(flex: 22, child: _TableHeaderText('Recovery Payroll Month')),
                            Expanded(flex: 24, child: _TableHeaderText('Reason / Purpose')),
                            Expanded(flex: 16, child: _TableHeaderText('Status')),
                          ],
                        ),
                      ),
                      if (_salaryAdvances.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: const Text('No salary advances recorded.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                        )
                      else
                        ..._salaryAdvances.map((adv) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 22, child: Text(adv.empName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                Expanded(flex: 18, child: Text('₹${adv.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD97706)))),
                                Expanded(flex: 22, child: Text(adv.recoveryMonth, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                                Expanded(flex: 24, child: Text(adv.reason.isEmpty ? '-' : adv.reason, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                                Expanded(
                                  flex: 16,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        adv.status,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.filter, size: 8, color: Color(0xFF94A3B8)),
              SizedBox(width: 1),
              Icon(LucideIcons.arrowUpDown, size: 8, color: Color(0xFF94A3B8)),
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
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.2,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIALOG: DISBURSE SALARY ADVANCE (Exact Match: Image 2 & 3)
// ═══════════════════════════════════════════════════════════════

class _DisburseSalaryAdvanceDialog extends StatefulWidget {
  final List<String> employees;
  final void Function(SalaryAdvanceItem newAdvance) onDisburse;

  const _DisburseSalaryAdvanceDialog({
    required this.employees,
    required this.onDisburse,
  });

  @override
  State<_DisburseSalaryAdvanceDialog> createState() => _DisburseSalaryAdvanceDialogState();
}

class _DisburseSalaryAdvanceDialogState extends State<_DisburseSalaryAdvanceDialog> {
  String _selectedEmployee = '-- Select Employee --';
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();

  String _recoveryMonth = 'Immediate (Next Payroll)';
  final List<String> _monthOptions = const [
    'Immediate (Next Payroll)',
    'January 2026',
    'February 2026',
    'March 2026',
    'April 2026',
    'May 2026',
    'June 2026',
    'July 2026',
    'August 2026',
    'September 2026',
    'October 2026',
    'November 2026',
    'December 2026',
    'January 2027',
    'February 2027',
    'March 2027',
    'April 2027',
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final emp = _selectedEmployee == '-- Select Employee --' ? 'kiran Kumar C' : _selectedEmployee;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 5000.0;
    final reason = _reasonCtrl.text.trim();

    final newAdv = SalaryAdvanceItem(
      id: 'ADV-${DateTime.now().millisecondsSinceEpoch % 10000}',
      empName: emp,
      amount: amount,
      recoveryMonth: _recoveryMonth,
      reason: reason.isEmpty ? 'Salary advance' : reason,
      disbursalDate: DateTime.now(),
      status: 'DISBURSED',
    );

    widget.onDisburse(newAdv);
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
          width: 440,
          constraints: BoxConstraints(maxWidth: 460, maxHeight: maxHeight),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.zap,
                              size: 18,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Disburse Salary Advance',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(LucideIcons.x, size: 15, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Field 1: Employee Name (Image 2)
                const Text(
                  'Employee Name',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
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

                // Field 2: Advance Amount (₹) (Image 2)
                const Text(
                  'Advance Amount (₹)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
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
                      hintText: 'e.g. 5000',
                      hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Field 3: Recovery Payroll Month (Image 2 & 3)
                const Text(
                  'Recovery Payroll Month',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
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
                      value: _recoveryMonth,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                      items: _monthOptions.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(
                            m == _recoveryMonth ? '✓ $m' : m,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: m == _recoveryMonth ? FontWeight.bold : FontWeight.normal,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _recoveryMonth = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Field 4: Reason / Purpose (Optional) (Image 2)
                const Text(
                  'Reason / Purpose (Optional)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _reasonCtrl,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Medical emergency, festival advance, urgent',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button: Confirm Salary Advance Disbursal (Image 2)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Confirm Salary Advance Disbursal',
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
}

// ═══════════════════════════════════════════════════════════════
// DIALOG: ALLOCATE EMPLOYEE LOAN
// ═══════════════════════════════════════════════════════════════

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

    final loan = LoanRecordItem(
      empName: emp,
      loanAmount: loanAmt,
      monthlyEmi: emi,
      remainingBalance: loanAmt,
      deductionPeriodMonths: period,
      salaryAdvance: advance,
    );

    widget.onGrantLoan(loan);
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
          width: 440,
          constraints: BoxConstraints(maxWidth: 460, maxHeight: maxHeight),
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
            padding: const EdgeInsets.all(24),
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
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.slidersHorizontal,
                              size: 18,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Allocate Employee Loan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(LucideIcons.x, size: 15, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                const Text('Employee Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Loan Amount (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
                          const Text('Monthly EMI (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildField(_emiCtrl, 'e.g. 50', isNumeric: true),
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
                          const Text('Duration (Months)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildField(_periodCtrl, 'e.g. 40', isNumeric: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Immediate Advance (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildField(_advanceCtrl, 'e.g. 500', isNumeric: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Confirm Employee Loan Allocation',
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

// ═══════════════════════════════════════════════════════════════
// DIALOG: PROCESS MONTHLY PAYROLL
// ═══════════════════════════════════════════════════════════════

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
  final _basicCtrl = TextEditingController(text: '50000');
  final _hraCtrl = TextEditingController(text: '5000');
  final _specialCtrl = TextEditingController(text: '2000');
  final _bonusCtrl = TextEditingController(text: '3000');
  final _esiCtrl = TextEditingController(text: '325');
  final _tdsCtrl = TextEditingController(text: '100');
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

    final refNum = 510 + (math.Random().nextInt(400));

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
      bankName: 'HDFC BANK',
      bankAccount: 'kdjbjhffjksb',
      status: 'PAID',
    );

    widget.onProcess(record);
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
            padding: const EdgeInsets.all(24),
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
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.creditCard,
                              size: 18,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Process Monthly Payroll',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF881337),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(LucideIcons.x, size: 15, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                const Text('Select Employee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Basic Base Salary (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
                          const Text('HRA Allowance (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildField(_hraCtrl, 'e.g. 5000', isNumeric: true),
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
                          const Text('Special Allowance (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
                          const Text('Bonus / Incentives (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildField(_bonusCtrl, 'e.g. 3000', isNumeric: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

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
                              activeColor: const Color(0xFFE11D48),
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
                          const Text('ESI Deduction', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
                          const Text('Estimated TDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          _buildField(_tdsCtrl, 'e.g. 100', isNumeric: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Process & Generate Payslip',
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

// ═══════════════════════════════════════════════════════════════
// DIALOG: PAYSLIP DETAILS
// ═══════════════════════════════════════════════════════════════

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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.fileText, size: 18, color: Color(0xFF166534)),
                      ),
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
                              Text(
                                record.month,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

                // Summary Banner
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
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('NET TAKE HOME', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${record.netTakeHome.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
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
                const SizedBox(height: 20),

                // Earnings & Deductions Breakdown
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('EARNINGS BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                          const SizedBox(height: 8),
                          _buildDetailRow('Basic Salary', '₹${record.baseSalary.toStringAsFixed(0)}'),
                          _buildDetailRow('HRA Allowance', '₹${record.hra.toStringAsFixed(0)}'),
                          _buildDetailRow('Special Allowance', '₹${record.specialAllowance.toStringAsFixed(0)}'),
                          _buildDetailRow('Bonus / Incentive', '₹${record.bonus.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STATUTORY DEDUCTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                          const SizedBox(height: 8),
                          _buildDetailRow('EPF (12%)', '-₹${record.epf.toStringAsFixed(0)}', isRed: true),
                          _buildDetailRow('ESI Contribution', '-₹${record.esi.toStringAsFixed(0)}', isRed: true),
                          _buildDetailRow('TDS (Income Tax)', '-₹${record.tds.toStringAsFixed(0)}', isRed: true),
                          _buildDetailRow('Professional Tax', '-₹${record.professionalTax.toStringAsFixed(0)}', isRed: true),
                        ],
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.only(bottom: 6),
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

// ═══════════════════════════════════════════════════════════════
// DIALOG: EDIT PAYSLIP
// ═══════════════════════════════════════════════════════════════

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
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Payslip (${widget.record.payslipRef})',
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
