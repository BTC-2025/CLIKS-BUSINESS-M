import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

// ─── DATA MODELS ──────────────────────────────────────────────

class StaffEmployeeItem {
  final String id;
  String name;
  String joinDate;
  String phone;
  String email;
  String emergencyPerson;
  String emergencyPhone;
  String dob;
  String gender;
  String age;
  String bloodGroup;
  String addressLine1;
  String cityState;
  String pincode;
  String department;
  String designation;
  double basicSalary;
  double annualBonus;
  String shift;
  double monthlyLeaves;
  int leaveBalance;
  String weeklyHoliday;
  double rating;
  int kpiScore;
  String panNumber;
  String pfNumber;
  String bankName;
  String bankAccount;
  String ifsc;

  StaffEmployeeItem({
    required this.id,
    required this.name,
    required this.joinDate,
    required this.phone,
    required this.email,
    required this.emergencyPerson,
    required this.emergencyPhone,
    required this.dob,
    required this.gender,
    required this.age,
    required this.bloodGroup,
    required this.addressLine1,
    required this.cityState,
    required this.pincode,
    this.department = 'Operations',
    this.designation = 'Sales Executive',
    this.basicSalary = 50000.0,
    this.annualBonus = 5000.0,
    this.shift = 'Morning Shift (6 AM - 2 PM)',
    this.monthlyLeaves = 1.5,
    this.leaveBalance = 14,
    this.weeklyHoliday = 'Sunday Off',
    this.rating = 4.5,
    this.kpiScore = 92,
    this.panNumber = 'ABCDE1234F',
    this.pfNumber = 'MH/BAN/0011223/001',
    this.bankName = 'HDFC Bank',
    this.bankAccount = '50100223344551',
    this.ifsc = 'HDFC0000124',
  });
}

class ReimbursementClaimItem {
  final String claimId;
  final String employee;
  final String purpose;
  final String lodgeDate;
  final String receiptDetails;
  final String status;
  final double amount;

  ReimbursementClaimItem({
    required this.claimId,
    required this.employee,
    required this.purpose,
    required this.lodgeDate,
    required this.receiptDetails,
    required this.status,
    required this.amount,
  });
}

class PublicHolidayItem {
  final String date;
  final String name;
  final String type;

  const PublicHolidayItem({
    required this.date,
    required this.name,
    required this.type,
  });
}

// ─── MAIN STAFF PAGE ──────────────────────────────────────────

class StaffPage extends ConsumerStatefulWidget {
  const StaffPage({super.key});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage> {
  // 0: Employee Profiles (Magenta #BE185D)
  // 1: Leaves & Shifts Rosters (Teal/Dark Green #047857 - Default matching Image 1)
  // 2: Performance Appraisals (Amber/Orange #D97706 - Image 3)
  // 3: Staff Reimbursements (Green #047857 - Image 4)
  int _activeTab = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _reimbursementSearchCtrl = TextEditingController();
  String _selectedClaimStatusFilter = 'All Claims';

  late List<StaffEmployeeItem> _employees;
  late List<ReimbursementClaimItem> _reimbursements;

  static const List<PublicHolidayItem> _publicHolidays = [
    PublicHolidayItem(date: '26 Jan 2026', name: 'Republic Day', type: 'National Holiday'),
    PublicHolidayItem(date: '01 May 2026', name: 'May Day / Labor Day', type: 'State Holiday'),
    PublicHolidayItem(date: '15 Aug 2026', name: 'Independence Day', type: 'National Holiday'),
    PublicHolidayItem(date: '02 Oct 2026', name: 'Gandhi Jayanti', type: 'National Holiday'),
    PublicHolidayItem(date: '20 Oct 2026', name: 'Ayudha Pooja / Diwali', type: 'Festival'),
    PublicHolidayItem(date: '25 Dec 2026', name: 'Christmas', type: 'Festival'),
    PublicHolidayItem(date: '01 Jan 2027', name: 'New Year Day', type: 'General Holiday'),
  ];

  @override
  void initState() {
    super.initState();

    _employees = [
      StaffEmployeeItem(
        id: 'CLK-0033',
        name: 'kiran Kumar',
        joinDate: '2026-08-14',
        phone: '+916374943436',
        email: 'ravikumarrama123@gmail.com',
        emergencyPerson: 'Ravi Kumar',
        emergencyPhone: '+916374943436',
        dob: '2004-12-27',
        gender: 'Male',
        age: 'Age: 21 yrs',
        bloodGroup: 'Blood group: O+',
        addressLine1: '3663 TNHB',
        cityState: 'Thiruvallur, Tamil Nadu',
        pincode: '602001',
        department: 'Finance',
        designation: 'Finance Associate',
        basicSalary: 50000.0,
        annualBonus: 5000.0,
        shift: 'Morning Shift (6 AM - 2 PM)',
        monthlyLeaves: 1.5,
        leaveBalance: 14,
        weeklyHoliday: 'Sunday Off',
        rating: 4.5,
        kpiScore: 92,
      ),
      StaffEmployeeItem(
        id: 'CLK-0032',
        name: 'Ravi Kumar',
        joinDate: '2026-08-14',
        phone: '+916374943436',
        email: 'divyachannnn1234@gmail.com',
        emergencyPerson: 'Ravi Kumar',
        emergencyPhone: '+916374943436',
        dob: '2004-12-27',
        gender: 'Male',
        age: 'Age: 21 yrs',
        bloodGroup: 'Blood group: O+',
        addressLine1: '3663 TNHB',
        cityState: 'Chennai, Tamil Nadu',
        pincode: '602001',
        department: 'Operations',
        designation: 'Sales Executive',
        basicSalary: 50000.0,
        annualBonus: 5000.0,
        shift: 'Morning Shift (6 AM - 2 PM)',
        monthlyLeaves: 1.5,
        leaveBalance: 14,
        weeklyHoliday: 'Sunday Off',
        rating: 4.5,
        kpiScore: 92,
      ),
    ];

    _reimbursements = [];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _reimbursementSearchCtrl.dispose();
    super.dispose();
  }

  double get _totalPayroll {
    return _employees.fold<double>(0, (sum, emp) => sum + emp.basicSalary);
  }

  double get _averageRating {
    if (_employees.isEmpty) return 0.0;
    final sum = _employees.fold<double>(0, (s, emp) => s + emp.rating);
    return sum / _employees.length;
  }

  List<StaffEmployeeItem> get _filteredEmployees {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return _employees;
    return _employees.where((emp) {
      return emp.name.toLowerCase().contains(query) ||
          emp.id.toLowerCase().contains(query) ||
          emp.phone.toLowerCase().contains(query) ||
          emp.email.toLowerCase().contains(query) ||
          emp.department.toLowerCase().contains(query) ||
          emp.cityState.toLowerCase().contains(query);
    }).toList();
  }

  List<ReimbursementClaimItem> get _filteredReimbursements {
    final query = _reimbursementSearchCtrl.text.trim().toLowerCase();
    return _reimbursements.where((claim) {
      final matchesQuery = query.isEmpty ||
          claim.claimId.toLowerCase().contains(query) ||
          claim.employee.toLowerCase().contains(query) ||
          claim.purpose.toLowerCase().contains(query) ||
          claim.amount.toString().contains(query);

      final matchesStatus = _selectedClaimStatusFilter == 'All Claims' ||
          claim.status.toLowerCase() == _selectedClaimStatusFilter.toLowerCase();

      return matchesQuery && matchesStatus;
    }).toList();
  }

  // ─── ACTION HANDLERS & MODALS ────────────────────────────────

  void _openFileAppraisalDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _FilePerformanceReviewDialog(
        employees: _employees,
        onSave: (empId, rating, kpiScore) {
          setState(() {
            final emp = _employees.firstWhere((e) => e.id == empId, orElse: () => _employees.first);
            emp.rating = rating;
            emp.kpiScore = kpiScore;
            _activeTab = 2; // Switch to Appraisals tab to see updated score
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Performance appraisal score settled.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openOnboardStaffDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _OnboardStaffEmployeeDialog(
        onOnboard: (newEmployee) {
          setState(() {
            _employees.add(newEmployee);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Employee "${newEmployee.name}" onboarded successfully.'),
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
        employees: _employees,
        onLodgeClaim: (newClaim) {
          setState(() {
            _reimbursements.insert(0, newClaim);
            _activeTab = 3; // Switch to Staff Reimbursements tab
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reimbursement claim "${newClaim.claimId}" lodged successfully.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openEditEmployeeDialog(StaffEmployeeItem emp) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _EditStaffEmployeeDialog(
        employee: emp,
        onSave: (updated) {
          setState(() {
            emp.name = updated.name;
            emp.phone = updated.phone;
            emp.email = updated.email;
            emp.emergencyPerson = updated.emergencyPerson;
            emp.emergencyPhone = updated.emergencyPhone;
            emp.addressLine1 = updated.addressLine1;
            emp.cityState = updated.cityState;
            emp.pincode = updated.pincode;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Employee profile for "${emp.name}" updated.'),
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
          isMobile ? 120 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP HEADER & ACTIONS (Image 1) ───
            _buildTopHeader(isMobile),
            const SizedBox(height: 20),

            // ─── 2. FOUR METRIC STAT CARDS WITH ACCENT STRIPES (Image 1) ───
            _buildMetricCards(isMobile),
            const SizedBox(height: 20),

            // ─── 3. FOUR TAB NAVIGATION BAR ───
            _buildTabBar(isMobile),
            const SizedBox(height: 18),

            // ─── 4. ACTIVE TAB CONTENT ───
            if (_activeTab == 0) ...[
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildEmployeeProfilesTable(isMobile),
            ],
            if (_activeTab == 1) _buildLeavesAndShiftsContent(isMobile),
            if (_activeTab == 2) _buildAppraisalsContent(isMobile),
            if (_activeTab == 3) _buildReimbursementsContent(isMobile),
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
          heroTag: 'staff_mobile_fab',
          onPressed: () {
            if (_activeTab == 2) {
              _openFileAppraisalDialog();
            } else if (_activeTab == 3) {
              _openLodgeStaffClaimDialog();
            } else {
              _openOnboardStaffDialog();
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
                  if (_activeTab == 0) ...[
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildEmployeeProfilesTable(true),
                  ],
                  if (_activeTab == 1) _buildLeavesAndShiftsContent(true),
                  if (_activeTab == 2) _buildAppraisalsContent(true),
                  if (_activeTab == 3) _buildReimbursementsContent(true),
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
                      child: const Icon(LucideIcons.users, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'HR WORKFORCE & PAYROLL',
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
                      'WORKFORCE ACTIVE',
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
                label: 'Onboard Staff Employee',
                icon: LucideIcons.userPlus,
                onPressed: _openOnboardStaffDialog,
                isPrimary: true,
              ),
              _buildHeroActionButton(
                label: 'File Appraisal Review',
                icon: LucideIcons.award,
                onPressed: _openFileAppraisalDialog,
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
                _buildHeroKpiChip('ACTIVE HEADCOUNT', '${_employees.length} Staff'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('MONTHLY PAYROLL', '₹${(_totalPayroll / 100000).toStringAsFixed(1)}L'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('WORKFORCE RATING', '${_averageRating.toStringAsFixed(1)} / 5.0'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('PENDING CLAIMS', '${_reimbursements.where((r) => r.status.toLowerCase().contains("pending")).length} Claims'),
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
      (label: 'Employee Profiles', icon: LucideIcons.user),
      (label: 'Leaves & Shifts Rosters', icon: LucideIcons.calendarDays),
      (label: 'Performance Appraisals', icon: LucideIcons.award),
      (label: 'Staff Reimbursements', icon: LucideIcons.receipt),
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
  // 1. TOP HEADER (Image 1)
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
                  LucideIcons.users,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'HR Staff & Employees Database',
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
            'Manage whole workforce life cycle: Central Profiles database, Employment designations, Payroll PF/ESI bank accounts, Leaves, Shifts, and Performance ratings.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderActionButton(
                      label: 'File Appraisal Review',
                      icon: LucideIcons.award,
                      color: const Color(0xFFBE185D),
                      borderColor: const Color(0xFFFDA4AF),
                      bgColor: const Color(0xFFFFF1F2),
                      onPressed: _openFileAppraisalDialog,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _openOnboardStaffDialog,
                      icon: const Icon(LucideIcons.userPlus, size: 14),
                      label: const Text(
                        'Onboard Staff Employee',
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
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildHeaderActionButton(
                      label: 'File Appraisal Review',
                      icon: LucideIcons.award,
                      color: const Color(0xFFBE185D),
                      borderColor: const Color(0xFFFDA4AF),
                      bgColor: const Color(0xFFFFF1F2),
                      onPressed: _openFileAppraisalDialog,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openOnboardStaffDialog,
                      icon: const Icon(LucideIcons.userPlus, size: 14),
                      label: const Text(
                        'Onboard Staff Employee',
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
              );
            },
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Magenta group icon container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            LucideIcons.users,
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
                'HR Staff & Employees Database',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Manage whole workforce life cycle: Central Profiles database, Employment designations, Payroll PF/ESI bank accounts, Leaves, Shifts, and Performance ratings.',
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
          label: 'File Appraisal Review',
          icon: LucideIcons.award,
          color: const Color(0xFFBE185D),
          borderColor: const Color(0xFFFDA4AF),
          bgColor: const Color(0xFFFFF1F2),
          onPressed: _openFileAppraisalDialog,
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _openOnboardStaffDialog,
          icon: const Icon(LucideIcons.userPlus, size: 14),
          label: const Text(
            'Onboard Staff Employee',
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
  // 2. FOUR METRIC STAT CARDS WITH ACCENT STRIPES (Image 1)
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
                LucideIcons.users,
                size: 16,
                color: Color(0xFFDB2777),
              ),
            ),
          ),
          mainValue: '${_employees.length} Employees',
          subLabel: 'TOTAL ACTIVE HEADCOUNT',
        );

        final card2 = _buildSingleMetricCard(
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
                LucideIcons.creditCard,
                size: 16,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          mainValue: '₹${_totalPayroll.toStringAsFixed(0)}',
          subLabel: 'MONTHLY BASIC PAYROLL',
        );

        final card3 = _buildSingleMetricCard(
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
                LucideIcons.award,
                size: 16,
                color: Color(0xFF7C3AED),
              ),
            ),
          ),
          mainValue: '${_averageRating.toStringAsFixed(1)} / 5.0 Rating',
          subLabel: 'WORKFORCE PERFORMANCE',
        );

        final card4 = _buildSingleMetricCard(
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
                LucideIcons.clock,
                size: 16,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
          mainValue: 'General (9AM - 6PM)',
          subLabel: 'ASSIGNED SHIFTS',
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
            // Left vertical accent stripe (Image 1)
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
  // 3. FOUR TAB NAVIGATION BAR (Image 1, 2, 3, 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isMobile) {
    final tabs = [
      _TabConfig(
        title: 'Employee Profiles',
        icon: LucideIcons.user,
        activeColor: const Color(0xFFBE185D), // Magenta (Image 1 from first prompt)
      ),
      _TabConfig(
        title: 'Leaves & Shifts Rosters',
        icon: LucideIcons.calendarDays,
        activeColor: const Color(0xFF047857), // Dark Teal/Green (Image 1 & 2)
      ),
      _TabConfig(
        title: 'Performance Appraisals',
        icon: LucideIcons.award,
        activeColor: const Color(0xFFD97706), // Solid Amber/Golden (Image 3)
      ),
      _TabConfig(
        title: 'Staff Reimbursements',
        icon: LucideIcons.receipt,
        activeColor: const Color(0xFF047857), // Solid Emerald/Green (Image 4)
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
  // 4. SEARCH BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: 'Search employees by name...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 0: EMPLOYEE PROFILES TABLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmployeeProfilesTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
          if (isMobile && !isMacOS) {
            return _buildMobileStaffDirectoryCardList(_filteredEmployees);
          }

          final minWidth = isMobile ? 1160.0 : 1040.0;
          final width = math.max(constraints.maxWidth, minWidth);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table Header Row with Sort/Filter Pills
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 20, child: _buildSortableHeader('EMPLOYEE PROFILE')),
                        Expanded(flex: 12, child: _buildSortableHeader('ID / CODE')),
                        Expanded(flex: 18, child: _buildSortableHeader('CONTACT INFO')),
                        Expanded(flex: 16, child: _buildSortableHeader('EMERGENCY PERSON')),
                        Expanded(flex: 22, child: _buildSortableHeader('PERSONAL INFO')),
                        Expanded(flex: 18, child: _buildSortableHeader('RESIDENTIAL ADDRESS')),
                        const SizedBox(
                          width: 60,
                          child: Text(
                            'ACTION',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Rows
                  if (_filteredEmployees.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No employees found matching the search query.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    ..._filteredEmployees.map((emp) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // EMPLOYEE PROFILE
                            Expanded(
                              flex: 20,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF064E3B),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        emp.name.isNotEmpty ? emp.name[0] : 'U',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emp.name,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Joined:\n${emp.joinDate}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ID / CODE
                            Expanded(
                              flex: 12,
                              child: Text(
                                emp.id,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ),

                            // CONTACT INFO
                            Expanded(
                              flex: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emp.phone,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    emp.email,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // EMERGENCY PERSON
                            Expanded(
                              flex: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emp.emergencyPerson,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    emp.emergencyPhone,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // PERSONAL INFO
                            Expanded(
                              flex: 22,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 3,
                                    children: [
                                      Text(
                                        '${emp.dob} (${emp.gender})',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF065F46),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          emp.age,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF166534),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    emp.bloodGroup,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // RESIDENTIAL ADDRESS
                            Expanded(
                              flex: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emp.addressLine1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    emp.cityState,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    '(${emp.pincode})',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ACTION
                            SizedBox(
                              width: 60,
                              child: Center(
                                child: InkWell(
                                  onTap: () => _openEditEmployeeDialog(emp),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      LucideIcons.pencil,
                                      size: 15,
                                      color: Color(0xFF94A3B8),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: LEAVES & SHIFTS ROSTERS (Images 1 & 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLeavesAndShiftsContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Leaves Balance, Pays & Assigned Roster Shifts Table
        Container(
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
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row with Quota Pill (Image 1)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 700;

                  final titleCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Leaves Balance, Pays & Assigned Roster Shifts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Comprehensive view of employee salaries, bonus eligibility, monthly leave quota, and shift rosters.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  );

                  final quotaBadge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('🌴', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Monthly Quota: 1.5 Leaves / Month (18 Days / Year)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleCol,
                        const SizedBox(height: 10),
                        quotaBadge,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: titleCol),
                      const SizedBox(width: 14),
                      quotaBadge,
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),

              // Roster Table (Image 1 & 2)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
                  if (isMobile && !isMacOS) {
                    return _buildMobileLeavesCardList(_employees);
                  }

                  final minWidth = isMobile ? 1060.0 : 980.0;
                  final width = math.max(constraints.maxWidth, minWidth);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: width,
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              border: Border(
                                top: BorderSide(color: Color(0xFFE5E7EB)),
                                bottom: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Expanded(flex: 18, child: _TableHeaderText('Employee Name')),
                                Expanded(flex: 24, child: _TableHeaderText('Assigned Work Shift')),
                                Expanded(flex: 20, child: _TableHeaderText('Basic Salary & Pays')),
                                Expanded(flex: 18, child: _TableHeaderText('Annual Bonus Est.')),
                                Expanded(flex: 22, child: _TableHeaderText('Monthly Allocated Leaves')),
                                Expanded(flex: 20, child: _TableHeaderText('Annual Leave Balance')),
                                Expanded(flex: 16, child: _TableHeaderText('Weekly Holiday')),
                              ],
                            ),
                          ),

                          // Table Rows (Image 1 & 2)
                          ..._employees.map((emp) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                              ),
                              child: Row(
                                children: [
                                  // Employee Name
                                  Expanded(
                                    flex: 18,
                                    child: Text(
                                      emp.name,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                  ),
                                  // Assigned Work Shift (Bold dark green as in Image 1)
                                  Expanded(
                                    flex: 24,
                                    child: Text(
                                      emp.shift,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                  ),
                                  // Basic Salary & Pays (₹50,000 /mo)
                                  Expanded(
                                    flex: 20,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '₹${emp.basicSalary.toStringAsFixed(0)} ',
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '/mo',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Annual Bonus Est. (Amber/Orange bold #D97706)
                                  Expanded(
                                    flex: 18,
                                    child: Text(
                                      '₹${emp.annualBonus.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                  // Monthly Allocated Leaves (Bold royal blue #2563EB)
                                  Expanded(
                                    flex: 22,
                                    child: Text(
                                      '${emp.monthlyLeaves} Days / mo',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                  // Annual Leave Balance (Bold red #DC2626)
                                  Expanded(
                                    flex: 20,
                                    child: Text(
                                      '${emp.leaveBalance} Days Left',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                  // Weekly Holiday (Sunday Off pill)
                                  Expanded(
                                    flex: 16,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Text(
                                          emp.weeklyHoliday,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF475569),
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
        ),
        const SizedBox(height: 20),

        // Section 2: Official Public Holidays Roster (2026) (Image 1 & 2)
        Container(
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(LucideIcons.calendar, size: 17, color: Color(0xFF059669)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Official Public Holidays Roster (2026)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Wrap of Public Holiday Cards (Image 1 & 2)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth < 420
                      ? double.infinity
                      : (constraints.maxWidth < 600
                          ? (constraints.maxWidth - 14) / 2
                          : 176.0);
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: _publicHolidays.map((holiday) {
                      return Container(
                        width: cardWidth,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              holiday.date,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              holiday.name,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              holiday.type,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: PERFORMANCE APPRAISALS (Image 3)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAppraisalsContent(bool isMobile) {
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title (Image 3)
          const Text(
            'Personnel Appraisal & Rating scorecard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 18),

          // Scorecard Table (Image 3)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
              if (isMobile && !isMacOS) {
                return _buildMobileAppraisalsCardList(_employees);
              }

              final minWidth = isMobile ? 900.0 : 840.0;
              final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      // Table Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE5E7EB)),
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 22, child: _TableHeaderText('Employee')),
                            Expanded(flex: 24, child: _TableHeaderText('Performance Rating')),
                            Expanded(flex: 30, child: _TableHeaderText('KPI Targets Score')),
                            Expanded(flex: 24, child: _TableHeaderText('Appraisal Target Date')),
                          ],
                        ),
                      ),

                      // Rows (Image 3)
                      ..._employees.map((emp) {
                        final progressRatio = (emp.kpiScore / 100.0).clamp(0.0, 1.0);

                        return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                          child: Row(
                            children: [
                              // Employee
                              Expanded(
                                flex: 22,
                                child: Text(
                                  emp.name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),

                              // Performance Rating (⭐ 4.5 / 5.0)
                              Expanded(
                                flex: 24,
                                child: Row(
                                  children: [
                                    const Text('⭐ ', style: TextStyle(fontSize: 12)),
                                    Text(
                                      '${emp.rating.toStringAsFixed(1)} / 5.0',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // KPI Targets Score (Progress bar + 92% Achieve)
                              Expanded(
                                flex: 30,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE2E8F0),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: progressRatio,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF047857), // Solid green bar
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${emp.kpiScore}% Achieve',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Appraisal Target Date (Image 3)
                              Expanded(
                                flex: 24,
                                child: const Text(
                                  '1st October 2026',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
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
  // TAB 3: STAFF REIMBURSEMENTS (Images 4 & 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReimbursementsContent(bool isMobile) {
    final claims = _filteredReimbursements;

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
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "+ Lodge Staff Claim" Button (Image 4)
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Employee Reimbursements & Travel claims',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Manage, approve, reject and settle workforce expense reimbursement claims.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _openLodgeStaffClaimDialog,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text(
                    'Lodge Staff Claim',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857), // Solid green (Image 4)
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Employee Reimbursements & Travel claims',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF064E3B),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Manage, approve, reject and settle workforce expense reimbursement claims.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: _openLodgeStaffClaimDialog,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text(
                    'Lodge Staff Claim',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857), // Solid green (Image 4)
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Search & Filter Status Row (Image 4)
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 650;

              final searchBox = Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _reimbursementSearchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(
                    hintText: 'Search by claim ID, employee, amount or purp',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(LucideIcons.search, size: 15, color: Color(0xFF94A3B8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              );

              final filterDropdown = isCompact
                  ? Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedClaimStatusFilter,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(value: 'All Claims', child: Text('Filter: All Claims', style: TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'Pending Approval', child: Text('Filter: Pending Approval', style: TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'Approved', child: Text('Filter: Approved', style: TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'Rejected', child: Text('Filter: Rejected', style: TextStyle(fontSize: 12.5))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedClaimStatusFilter = val);
                          },
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Filter Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        const SizedBox(width: 8),
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
                              value: _selectedClaimStatusFilter,
                              icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                              items: const [
                                DropdownMenuItem(value: 'All Claims', child: Text('All Claims', style: TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: 'Pending Approval', child: Text('Pending Approval', style: TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: 'Approved', child: Text('Approved', style: TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: 'Rejected', child: Text('Rejected', style: TextStyle(fontSize: 12.5))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedClaimStatusFilter = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchBox,
                    const SizedBox(height: 10),
                    filterDropdown,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: searchBox),
                  const SizedBox(width: 20),
                  filterDropdown,
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Table Header & Rows (Image 4)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
              if (isMobile && !isMacOS) {
                return _buildMobileReimbursementsCardList(claims);
              }

              final minWidth = isMobile ? 1060.0 : 960.0;
              final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      // Header Row (Image 4)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE5E7EB)),
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 12, child: _TableHeaderText('CLAIM ID')),
                            Expanded(flex: 18, child: _TableHeaderText('EMPLOYEE PROFILE')),
                            Expanded(flex: 24, child: _TableHeaderText('CLAIM PURPOSE DESCRIPTION')),
                            Expanded(flex: 14, child: _TableHeaderText('LODGE DATE')),
                            Expanded(flex: 16, child: _TableHeaderText('RECEIPT DETAILS')),
                            Expanded(flex: 14, child: _TableHeaderText('STATUS')),
                            Expanded(flex: 14, child: _TableHeaderText('CLAIM AMOUNT')),
                            Expanded(flex: 12, child: _TableHeaderText('ACTIONS')),
                          ],
                        ),
                      ),

                      // Rows or Empty Placeholder (Image 4)
                      if (claims.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Text(
                              'No staff reimbursement claims matching search/filters.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ),
                        )
                      else
                        ...claims.map((claim) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 12, child: Text(claim.claimId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                Expanded(flex: 18, child: Text(claim.employee, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46)))),
                                Expanded(flex: 24, child: Text(claim.purpose, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)))),
                                Expanded(flex: 14, child: Text(claim.lodgeDate, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                                Expanded(flex: 16, child: Text(claim.receiptDetails, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                                Expanded(
                                  flex: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                                    child: Text(claim.status, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                  ),
                                ),
                                Expanded(flex: 14, child: Text('₹${claim.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)))),
                                const Expanded(flex: 12, child: Icon(LucideIcons.moreHorizontal, size: 16, color: Color(0xFF94A3B8))),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
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
            border: Border.all(color: AppColors.tableBorder),
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
  // MOBILE CARD PRESENTATION WIDGETS (STAFF PAGE)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileStaffDirectoryCardList(List<StaffEmployeeItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No employees found matching the search query.',
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
        final emp = items[index];
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        emp.name.isNotEmpty ? emp.name[0] : 'U',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emp.name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${emp.id} • Joined: ${emp.joinDate}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _openEditEmployeeDialog(emp),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        LucideIcons.pencil,
                        size: 15,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(
                    emp.phone,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                  Text(
                    emp.email,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${emp.dob} (${emp.gender})',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      emp.age,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                  Text(
                    emp.bloodGroup,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency: ${emp.emergencyPerson} (${emp.emergencyPhone})',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${emp.addressLine1}, ${emp.cityState} (${emp.pincode})',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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

  Widget _buildMobileLeavesCardList(List<StaffEmployeeItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No staff members found.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final emp = items[index];
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
                    emp.name,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      emp.shift,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    ),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BASIC SALARY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text('₹${emp.basicSalary.toStringAsFixed(0)} /mo', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BONUS EST.', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text('₹${emp.annualBonus.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
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
                              const Text('MONTHLY LEAVES', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text('${emp.monthlyLeaves} Days/mo', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('WEEKLY HOLIDAY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text(emp.weeklyHoliday, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.calendarX, size: 12, color: Color(0xFFDC2626)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${emp.leaveBalance} Days Leave Left',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildMobileAppraisalsCardList(List<StaffEmployeeItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No appraisal records found.',
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
        final emp = items[index];
        final progressRatio = (emp.kpiScore / 100.0).clamp(0.0, 1.0);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      emp.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      const Text('⭐ ', style: TextStyle(fontSize: 11)),
                      Text(
                        '${emp.rating.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('KPI Targets Score', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text(
                    '${emp.kpiScore}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Target Date: 1st October 2026',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileReimbursementsCardList(List<ReimbursementClaimItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Text(
            'No staff reimbursement claims matching search/filters.',
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
        final claim = items[index];
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      claim.claimId,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      claim.status,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                claim.employee,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
              ),
              const SizedBox(height: 2),
              Text(
                claim.purpose,
                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${claim.lodgeDate} • ${claim.receiptDetails}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${claim.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
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
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
        letterSpacing: 0.3,
      ),
    );
  }
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

// ─── LODGE STAFF CLAIM MODAL (Image 5) ────────────────────────

class _LodgeStaffClaimDialog extends StatefulWidget {
  final List<StaffEmployeeItem> employees;
  final void Function(ReimbursementClaimItem newClaim) onLodgeClaim;

  const _LodgeStaffClaimDialog({
    required this.employees,
    required this.onLodgeClaim,
  });

  @override
  State<_LodgeStaffClaimDialog> createState() => _LodgeStaffClaimDialogState();
}

class _LodgeStaffClaimDialogState extends State<_LodgeStaffClaimDialog> {
  late String _selectedEmployeeDesc;
  final _descriptionCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: '14/10/2026');
  final _timeCtrl = TextEditingController(text: '12:00 PM');
  final _amountCtrl = TextEditingController(text: '0');
  final _receiptCtrl = TextEditingController();
  final List<TextEditingController> _extraReceiptCtrls = [];

  @override
  void initState() {
    super.initState();
    _selectedEmployeeDesc = widget.employees.isNotEmpty
        ? '${widget.employees.first.name} (${widget.employees.first.department})'
        : 'kiran Kumar (Finance)';
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _amountCtrl.dispose();
    _receiptCtrl.dispose();
    for (final ctrl in _extraReceiptCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 10, 14),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      setState(() {
        _dateCtrl.text = '$day/$month/${picked.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      setState(() {
        _timeCtrl.text = '${hour.toString().padLeft(2, '0')}:$minute $period';
      });
    }
  }

  void _addExtraReceiptField() {
    setState(() {
      _extraReceiptCtrls.add(TextEditingController());
    });
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final desc = _descriptionCtrl.text.trim();

    final allReceipts = [
      if (_receiptCtrl.text.trim().isNotEmpty) _receiptCtrl.text.trim(),
      ..._extraReceiptCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty),
    ];

    final receiptString = allReceipts.isEmpty ? 'Ref #Proof-Attached' : allReceipts.join(', ');

    final claim = ReimbursementClaimItem(
      claimId: 'CLM-${math.Random().nextInt(9000) + 1000}',
      employee: _selectedEmployeeDesc.split('(').first.trim(),
      purpose: desc.isEmpty ? 'Travel & Local Conveyance' : desc,
      lodgeDate: '2026-10-14',
      receiptDetails: receiptString,
      status: 'Pending Approval',
      amount: amount <= 0 ? 1250 : amount,
    );

    widget.onLodgeClaim(claim);
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
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 5)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Lodge Staff Claim',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
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

                // EMPLOYEE PROFILE NAME
                const Text('EMPLOYEE PROFILE NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.3)),
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
                      value: _selectedEmployeeDesc,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                      items: widget.employees.map((emp) {
                        final label = '${emp.name} (${emp.department})';
                        return DropdownMenuItem(
                          value: label,
                          child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedEmployeeDesc = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // OUT-OF-POCKET DESCRIPTION
                const Text('OUT-OF-POCKET DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.3)),
                const SizedBox(height: 6),
                _buildInputContainer(_descriptionCtrl, hint: 'e.g. Travel, meals, team stationery...'),
                const SizedBox(height: 16),

                // DATE & TIME (Image 5)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.3)),
                          const SizedBox(height: 6),
                          _buildInputContainer(
                            _dateCtrl,
                            suffixIcon: LucideIcons.calendar,
                            readOnly: true,
                            onTap: _pickDate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.3)),
                          const SizedBox(height: 6),
                          _buildInputContainer(
                            _timeCtrl,
                            suffixIcon: LucideIcons.clock,
                            readOnly: true,
                            onTap: _pickTime,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // CLAIM AMOUNT (INR) *
                const Text('CLAIM AMOUNT (INR) *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.3)),
                const SizedBox(height: 6),
                _buildInputContainer(_amountCtrl, isNumeric: true),
                const SizedBox(height: 16),

                // RECEIPT / REFERENCE #1 (OPTIONAL)
                const Text('RECEIPT / REFERENCE #1 (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.3)),
                const SizedBox(height: 6),
                _buildInputContainer(_receiptCtrl, hint: 'e.g. UPI Ref No, Bank Txn ID, Receipt No.', suffixIcon: LucideIcons.paperclip),

                // Extra dynamic receipt reference fields
                ..._extraReceiptCtrls.asMap().entries.map((entry) {
                  final idx = entry.key + 2;
                  final ctrl = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RECEIPT / REFERENCE #$idx (OPTIONAL)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.3)),
                        const SizedBox(height: 6),
                        _buildInputContainer(ctrl, hint: 'e.g. UPI Ref No, Bank Txn ID, Receipt No.', suffixIcon: LucideIcons.paperclip),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // + Add Another Receipt / Proof (Outlined button)
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addExtraReceiptField,
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          '+ Add Another Receipt / Proof',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lodge Reimbursement Claim button (Image 5)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF718E7E), // Sage/forest green as in Image 5
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

  Widget _buildInputContainer(
    TextEditingController ctrl, {
    bool isNumeric = false,
    String? hint,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          controller: ctrl,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: InputBorder.none,
            isDense: true,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, size: 16, color: const Color(0xFF64748B)),
                    onPressed: onTap,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

// ─── FILE PERFORMANCE REVIEW DIALOG (Image 2) ─────────────────

class _FilePerformanceReviewDialog extends StatefulWidget {
  final List<StaffEmployeeItem> employees;
  final void Function(String empId, double rating, int kpiScore) onSave;

  const _FilePerformanceReviewDialog({
    required this.employees,
    required this.onSave,
  });

  @override
  State<_FilePerformanceReviewDialog> createState() => _FilePerformanceReviewDialogState();
}

class _FilePerformanceReviewDialogState extends State<_FilePerformanceReviewDialog> {
  String? _selectedEmpId;
  final _ratingCtrl = TextEditingController(text: '4.8');
  final _kpiCtrl = TextEditingController(text: '94');

  @override
  void initState() {
    super.initState();
    if (widget.employees.isNotEmpty) {
      _selectedEmpId = widget.employees.first.id;
    }
  }

  @override
  void dispose() {
    _ratingCtrl.dispose();
    _kpiCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedEmpId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employee.'), backgroundColor: Color(0xFFE11D48)),
      );
      return;
    }

    final rating = double.tryParse(_ratingCtrl.text.trim()) ?? 4.8;
    final kpi = int.tryParse(_kpiCtrl.text.trim()) ?? 94;

    widget.onSave(_selectedEmpId!, rating, kpi);
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
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'File Performance Review',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
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

                // Select Employee
                const Text(
                  'Select Employee',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
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
                      value: _selectedEmpId,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                      hint: const Text('-- Select Employee --', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                      items: widget.employees.map((emp) {
                        return DropdownMenuItem(
                          value: emp.id,
                          child: Text(
                            '${emp.name} (${emp.id})',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedEmpId = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Row with Rating and KPI Target Score (Image 2)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appraisal Rating (1.0 - 5.0)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 6),
                          _buildInputContainer(_ratingCtrl, isNumeric: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KPI Target Score %',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 6),
                          _buildInputContainer(_kpiCtrl, isNumeric: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // Action Button: Settle Appraisal Score (Purple #7C3AED as in Image 2)
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
                      'Settle Appraisal Score',
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

  Widget _buildInputContainer(TextEditingController ctrl, {bool isNumeric = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

// ─── ONBOARD STAFF EMPLOYEE DIALOG ─────────────────────────────

class _OnboardStaffEmployeeDialog extends StatefulWidget {
  final void Function(StaffEmployeeItem newEmployee) onOnboard;

  const _OnboardStaffEmployeeDialog({required this.onOnboard});

  @override
  State<_OnboardStaffEmployeeDialog> createState() => _OnboardStaffEmployeeDialogState();
}

class _OnboardStaffEmployeeDialogState extends State<_OnboardStaffEmployeeDialog> {
  // Personal Details
  final _firstNameCtrl = TextEditingController(text: 'Arun');
  final _lastNameCtrl = TextEditingController(text: 'Kumar');
  final _dobCtrl = TextEditingController(text: 'dd/mm/yyyy');
  String _gender = 'Male';
  String _bloodGroup = 'O+';
  final _phoneCtrl = TextEditingController(text: '9876543210');
  final _emailCtrl = TextEditingController(text: 'arun.kumar@bnxmail.com');

  // Job & Designation
  String _department = 'Operations';
  final _designationCtrl = TextEditingController(text: 'Sales Executive (Default)');
  String _employmentType = 'Full-time';
  final _joiningDateCtrl = TextEditingController(text: '14/10/2026');
  final _managerCtrl = TextEditingController(text: 'Ankit Sharma (Sales Lead)');
  final _leavesBalCtrl = TextEditingController(text: '14');
  String _assignedShift = 'General Shift (9 AM - 6 PM)';

  // Payroll & Financial
  final _salaryCtrl = TextEditingController(text: '35000 (Default)');
  final _panCtrl = TextEditingController(text: 'ABCDE1234F (Default)');
  final _pfCtrl = TextEditingController(text: 'MH/BAN/0011223/001 (Default)');
  final _bankNameCtrl = TextEditingController(text: 'HDFC Bank (Default)');
  final _accountCtrl = TextEditingController(text: '50100223344551 (Default)');
  final _ifscCtrl = TextEditingController(text: 'HDFC0000124 (Default)');

  // Address & Emergency
  final _addressCtrl = TextEditingController(text: 'Plot No. 12, Anna Nagar (Default)');
  final _cityCtrl = TextEditingController(text: 'Chennai');
  final _stateCtrl = TextEditingController(text: 'Tamil Nadu');
  final _pincodeCtrl = TextEditingController(text: '600040');
  final _emergencyNameCtrl = TextEditingController(text: 'Vijay Kumar (Father) (Default)');
  final _emergencyPhoneCtrl = TextEditingController(text: '+91 98765 99911 (Default)');

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _designationCtrl.dispose();
    _joiningDateCtrl.dispose();
    _managerCtrl.dispose();
    _leavesBalCtrl.dispose();
    _salaryCtrl.dispose();
    _panCtrl.dispose();
    _pfCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountCtrl.dispose();
    _ifscCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    final fullName = '$first $last'.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter employee name.'), backgroundColor: Color(0xFFE11D48)),
      );
      return;
    }

    final idNumber = 34 + math.Random().nextInt(50);
    final newItem = StaffEmployeeItem(
      id: 'CLK-00$idNumber',
      name: fullName,
      joinDate: '2026-10-14',
      phone: _phoneCtrl.text.trim().isEmpty ? '+919876543210' : '+91${_phoneCtrl.text.trim()}',
      email: _emailCtrl.text.trim().isEmpty ? 'arun.kumar@bnxmail.com' : _emailCtrl.text.trim(),
      emergencyPerson: _emergencyNameCtrl.text.trim().replaceAll(' (Default)', ''),
      emergencyPhone: _emergencyPhoneCtrl.text.trim().replaceAll(' (Default)', ''),
      dob: _dobCtrl.text.trim() == 'dd/mm/yyyy' ? '2002-05-18' : _dobCtrl.text.trim(),
      gender: _gender,
      age: 'Age: 24 yrs',
      bloodGroup: 'Blood group: $_bloodGroup',
      addressLine1: _addressCtrl.text.trim().replaceAll(' (Default)', ''),
      cityState: '${_cityCtrl.text.trim()}, ${_stateCtrl.text.trim()}',
      pincode: _pincodeCtrl.text.trim(),
      department: _department,
      designation: _designationCtrl.text.trim().replaceAll(' (Default)', ''),
      basicSalary: 35000.0,
      shift: _assignedShift,
      leaveBalance: int.tryParse(_leavesBalCtrl.text.trim()) ?? 14,
    );

    widget.onOnboard(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 860,
          constraints: BoxConstraints(maxWidth: 900, maxHeight: math.min(780, MediaQuery.of(context).size.height * 0.9)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Header with UserPlus Icon
              Padding(
                padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, isMobile ? 16 : 20, isMobile ? 16 : 20, isMobile ? 12 : 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.userPlus, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Onboard Staff Employee',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
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
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Scrollable Form Cards
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 14 : 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 720;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildPersonalDetailsCard(false)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildJobDesignationCard(false)),
                              ],
                            )
                          else ...[
                            _buildPersonalDetailsCard(constraints.maxWidth < 500),
                            const SizedBox(height: 16),
                            _buildJobDesignationCard(constraints.maxWidth < 500),
                          ],
                          const SizedBox(height: 16),
                          _buildPayrollCard(!isDesktop && constraints.maxWidth < 500),
                          const SizedBox(height: 16),
                          _buildAddressCard(!isDesktop && constraints.maxWidth < 500),
                          const SizedBox(height: 24),
                          if (constraints.maxWidth < 460)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF065F46),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Onboard Staff Employee', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    foregroundColor: const Color(0xFF334155),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    foregroundColor: const Color(0xFF334155),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF065F46),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Onboard Staff Employee', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget header, required List<Widget> children, bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsCard([bool isMobile = false]) {
    return _buildSectionCard(
      isMobile: isMobile,
      header: Row(
        children: const [
          Icon(LucideIcons.user, size: 15, color: Color(0xFF0F172A)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Personal Details',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: [
        Row(
          children: [
            Expanded(child: _buildFormField('First Name', _firstNameCtrl)),
            const SizedBox(width: 10),
            Expanded(child: _buildFormField('Last Name', _lastNameCtrl)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildFormField('Date of Birth', _dobCtrl, trailingIcon: LucideIcons.calendar)),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDropdownField('Gender', _gender, ['Male', 'Female', 'Other'], (val) {
                if (val != null) setState(() => _gender = val);
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField('Blood Group', _bloodGroup, ['O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-'], (val) {
                if (val != null) setState(() => _bloodGroup = val);
              }),
            ),
            const SizedBox(width: 10),
            Expanded(child: _buildFormField('Phone', _phoneCtrl, isNumeric: true)),
          ],
        ),
        const SizedBox(height: 12),
        _buildFormField('Corporate Email (BNX / Company Mail)', _emailCtrl),
      ],
    );
  }

  Widget _buildJobDesignationCard([bool isMobile = false]) {
    return _buildSectionCard(
      isMobile: isMobile,
      header: Row(
        children: const [
          Icon(LucideIcons.briefcase, size: 15, color: Color(0xFF0F172A)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Job & Designation',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdownField('Department', _department, ['Operations', 'Finance & Billing', 'Logistics & Warehouse', 'Human Resources', 'Sales & Retail'], (val) {
                if (val != null) setState(() => _department = val);
              }),
            ),
            const SizedBox(width: 10),
            Expanded(child: _buildFormField('Designation Title', _designationCtrl)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField('Employment Type', _employmentType, ['Full-time', 'Part-time', 'Contract'], (val) {
                if (val != null) setState(() => _employmentType = val);
              }),
            ),
            const SizedBox(width: 10),
            Expanded(child: _buildFormField('Joining Date', _joiningDateCtrl, trailingIcon: LucideIcons.calendar)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildFormField('Reporting Manager', _managerCtrl)),
            const SizedBox(width: 10),
            Expanded(child: _buildFormField('Leaves Bal', _leavesBalCtrl, isNumeric: true)),
          ],
        ),
        const SizedBox(height: 12),
        _buildDropdownField('Assigned Shift', _assignedShift, ['General Shift (9 AM - 6 PM)', 'Morning Shift (6 AM - 2 PM)', 'Evening Shift (2 PM - 10 PM)'], (val) {
          if (val != null) setState(() => _assignedShift = val);
        }),
      ],
    );
  }

  Widget _buildPayrollCard([bool isMobile = false]) {
    return _buildSectionCard(
      isMobile: isMobile,
      header: Row(
        children: const [
          Icon(LucideIcons.creditCard, size: 15, color: Color(0xFF0F172A)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Payroll & Financial Structure',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: [
        if (isMobile) ...[
          _buildFormField('Basic Monthly Salary (INR)', _salaryCtrl),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildFormField('PAN Number', _panCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _buildFormField('PF Number', _pfCtrl)),
            ],
          ),
          const SizedBox(height: 12),
          _buildFormField('Bank Name', _bankNameCtrl),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(flex: 3, child: _buildFormField('Bank Account Number', _accountCtrl)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildFormField('IFSC Code', _ifscCtrl)),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(child: _buildFormField('Basic Monthly Salary (INR)', _salaryCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormField('PAN Number', _panCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormField('PF Number', _pfCtrl)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildFormField('Bank Name', _bankNameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormField('Bank Account Number', _accountCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormField('IFSC Code', _ifscCtrl)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAddressCard([bool isMobile = false]) {
    return _buildSectionCard(
      isMobile: isMobile,
      header: Row(
        children: const [
          Icon(LucideIcons.mapPin, size: 15, color: Color(0xFF0F172A)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Address & Emergency Details',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      children: [
        _buildFormField('Residential Address Line 1', _addressCtrl),
        const SizedBox(height: 12),
        if (isMobile) ...[
          Row(
            children: [
              Expanded(child: _buildFormField('City', _cityCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _buildFormField('State', _stateCtrl)),
            ],
          ),
          const SizedBox(height: 12),
          _buildFormField('Pincode', _pincodeCtrl, isNumeric: true),
        ] else ...[
          Row(
            children: [
              Expanded(child: _buildFormField('City', _cityCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormField('State', _stateCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildFormField('Pincode', _pincodeCtrl, isNumeric: true)),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildFormField('Emergency Contact Name', _emergencyNameCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildFormField('Emergency Phone', _emergencyPhoneCtrl)),
          ],
        ),
      ],
    );
  }

  Widget _buildFormField(String label, TextEditingController ctrl, {bool isNumeric = false, IconData? trailingIcon}) {
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
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
              isDense: true,
              suffixIcon: trailingIcon != null ? Icon(trailingIcon, size: 15, color: const Color(0xFF64748B)) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 5),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 15, color: Color(0xFF64748B)),
              items: options.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A))),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── EDIT STAFF EMPLOYEE DIALOG ───────────────────────────────

class _EditStaffEmployeeDialog extends StatefulWidget {
  final StaffEmployeeItem employee;
  final void Function(StaffEmployeeItem updated) onSave;

  const _EditStaffEmployeeDialog({
    required this.employee,
    required this.onSave,
  });

  @override
  State<_EditStaffEmployeeDialog> createState() => _EditStaffEmployeeDialogState();
}

class _EditStaffEmployeeDialogState extends State<_EditStaffEmployeeDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _emergencyPersonCtrl;
  late final TextEditingController _emergencyPhoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityStateCtrl;
  late final TextEditingController _pincodeCtrl;

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;
    _nameCtrl = TextEditingController(text: emp.name);
    _phoneCtrl = TextEditingController(text: emp.phone);
    _emailCtrl = TextEditingController(text: emp.email);
    _emergencyPersonCtrl = TextEditingController(text: emp.emergencyPerson);
    _emergencyPhoneCtrl = TextEditingController(text: emp.emergencyPhone);
    _addressCtrl = TextEditingController(text: emp.addressLine1);
    _cityStateCtrl = TextEditingController(text: emp.cityState);
    _pincodeCtrl = TextEditingController(text: emp.pincode);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _emergencyPersonCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityStateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final updated = StaffEmployeeItem(
      id: widget.employee.id,
      name: _nameCtrl.text.trim(),
      joinDate: widget.employee.joinDate,
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      emergencyPerson: _emergencyPersonCtrl.text.trim(),
      emergencyPhone: _emergencyPhoneCtrl.text.trim(),
      dob: widget.employee.dob,
      gender: widget.employee.gender,
      age: widget.employee.age,
      bloodGroup: widget.employee.bloodGroup,
      addressLine1: _addressCtrl.text.trim(),
      cityState: _cityStateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      department: widget.employee.department,
      designation: widget.employee.designation,
      basicSalary: widget.employee.basicSalary,
      shift: widget.employee.shift,
      leaveBalance: widget.employee.leaveBalance,
      rating: widget.employee.rating,
      kpiScore: widget.employee.kpiScore,
    );

    widget.onSave(updated);
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
          width: 500,
          constraints: BoxConstraints(maxWidth: 540, maxHeight: math.min(720, MediaQuery.of(context).size.height * 0.9)),
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 22, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '✏️ Edit Employee (${widget.employee.id})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Scrollable Form Fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField('Full Name', _nameCtrl),
                      const SizedBox(height: 14),
                      _buildField('Phone Number', _phoneCtrl),
                      const SizedBox(height: 14),
                      _buildField('Email Address', _emailCtrl),
                      const SizedBox(height: 14),
                      _buildField('Emergency Contact Name', _emergencyPersonCtrl),
                      const SizedBox(height: 14),
                      _buildField('Emergency Phone Number', _emergencyPhoneCtrl),
                      const SizedBox(height: 14),
                      _buildField('Address Line 1', _addressCtrl),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(flex: 3, child: _buildField('City / State', _cityStateCtrl)),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: _buildField('Pincode', _pincodeCtrl)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF065F46),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Save Profile Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
