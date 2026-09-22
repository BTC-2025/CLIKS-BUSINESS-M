import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/onboard_staff_employee_dialog.dart';
import '../widgets/file_performance_review_dialog.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

// ═══════════════════════════════════════════════════════════════
// HR DUMMY DATA MODEL
// ═══════════════════════════════════════════════════════════════
class _StaffEmployee {
  final String id;
  final String name;
  final String role;
  final String department;
  final String phone;
  final String email;
  final String emergencyContact;
  final String personalInfo;
  final String address;
  final String salaryType;
  final double monthlySalary;
  final String bankAccount;
  final String ifsc;
  final String pfNumber;
  final String panNumber;
  final String shift;
  final int leaveBalance;
  final String weeklyHoliday;
  final double rating;
  final String kpiScore;
  final String appraisalDate;
  final String reportingManager;
  final String employmentType;

  _StaffEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.phone,
    required this.email,
    required this.emergencyContact,
    required this.personalInfo,
    required this.address,
    required this.salaryType,
    required this.monthlySalary,
    required this.bankAccount,
    required this.ifsc,
    required this.pfNumber,
    required this.panNumber,
    required this.shift,
    required this.leaveBalance,
    required this.weeklyHoliday,
    required this.rating,
    required this.kpiScore,
    required this.appraisalDate,
    required this.reportingManager,
    required this.employmentType,
  });
}

class StaffPage extends ConsumerStatefulWidget {
  const StaffPage({super.key});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Employee Profiles, 1: Hierarchy, 2: Payroll & Bank, 3: Leaves & Shifts, 4: Appraisals
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<_TabItem> _tabs = [
    _TabItem('Employee Profiles', LucideIcons.user),
    _TabItem('Hierarchy & Employment', LucideIcons.network),
    _TabItem('Payroll & Bank Details', LucideIcons.creditCard),
    _TabItem('Leaves & Shifts Rosters', LucideIcons.calendarDays),
    _TabItem('Performance Appraisals', LucideIcons.award),
  ];

  // Dummy HR Staff Roster Data
  final List<_StaffEmployee> _allEmployees = [
    _StaffEmployee(
      id: 'EMP-001',
      name: 'Ravi Kumar',
      role: 'Senior Operations Manager',
      department: 'Operations',
      phone: '+91 98765 43210',
      email: 'ravi@cliks.io',
      emergencyContact: 'Sunita (Wife)',
      personalInfo: 'Male • DOB: 14 Aug 1990',
      address: '123 MG Road, Bangalore, KA',
      salaryType: 'Monthly Fixed',
      monthlySalary: 85000.0,
      bankAccount: 'HDFC Bank (•••• 4321)',
      ifsc: 'HDFC0000128',
      pfNumber: 'PF-BLR-8849201',
      panNumber: 'ABCDE1234F',
      shift: 'General (09:00 AM - 06:00 PM)',
      leaveBalance: 18,
      weeklyHoliday: 'Sunday',
      rating: 4.9,
      kpiScore: '98%',
      appraisalDate: '15 Dec 2026',
      reportingManager: 'Executive Director',
      employmentType: 'Full-Time Permanent',
    ),
    _StaffEmployee(
      id: 'EMP-002',
      name: 'Ananya Sharma',
      role: 'Lead Accountant',
      department: 'Finance & Billing',
      phone: '+91 98230 11223',
      email: 'ananya@cliks.io',
      emergencyContact: 'Vikram (Father)',
      personalInfo: 'Female • DOB: 02 Mar 1995',
      address: '45 Indiranagar 100ft Rd, Bangalore',
      salaryType: 'Monthly Fixed',
      monthlySalary: 65000.0,
      bankAccount: 'ICICI Bank (•••• 9876)',
      ifsc: 'ICIC0000456',
      pfNumber: 'PF-BLR-8849202',
      panNumber: 'FGHIJ5678K',
      shift: 'General (09:00 AM - 06:00 PM)',
      leaveBalance: 14,
      weeklyHoliday: 'Sunday',
      rating: 4.8,
      kpiScore: '95%',
      appraisalDate: '20 Dec 2026',
      reportingManager: 'Ravi Kumar',
      employmentType: 'Full-Time Permanent',
    ),
    _StaffEmployee(
      id: 'EMP-003',
      name: 'Rajesh Patel',
      role: 'Warehouse Supervisor',
      department: 'Logistics & Warehouse',
      phone: '+91 97112 88990',
      email: 'rajesh@cliks.io',
      emergencyContact: 'Priya (Wife)',
      personalInfo: 'Male • DOB: 22 Nov 1988',
      address: '88 Koramangala 5th Block, Bangalore',
      salaryType: 'Monthly Fixed',
      monthlySalary: 48000.0,
      bankAccount: 'SBI (•••• 5544)',
      ifsc: 'SBIN0001122',
      pfNumber: 'PF-BLR-8849203',
      panNumber: 'LMNOP9012Q',
      shift: 'Morning (07:00 AM - 04:00 PM)',
      leaveBalance: 21,
      weeklyHoliday: 'Sunday',
      rating: 4.5,
      kpiScore: '91%',
      appraisalDate: '10 Jan 2027',
      reportingManager: 'Ravi Kumar',
      employmentType: 'Full-Time Permanent',
    ),
    _StaffEmployee(
      id: 'EMP-004',
      name: 'Sneha Reddy',
      role: 'HR Operations Specialist',
      department: 'Human Resources',
      phone: '+91 99450 66778',
      email: 'sneha@cliks.io',
      emergencyContact: 'Kiran (Brother)',
      personalInfo: 'Female • DOB: 19 Jun 1997',
      address: '12 HSR Layout Sector 3, Bangalore',
      salaryType: 'Monthly Fixed',
      monthlySalary: 52000.0,
      bankAccount: 'Axis Bank (•••• 3322)',
      ifsc: 'UTIB0000889',
      pfNumber: 'PF-BLR-8849204',
      panNumber: 'RSTUV3456W',
      shift: 'General (09:00 AM - 06:00 PM)',
      leaveBalance: 16,
      weeklyHoliday: 'Sunday',
      rating: 4.7,
      kpiScore: '94%',
      appraisalDate: '15 Jan 2027',
      reportingManager: 'Ravi Kumar',
      employmentType: 'Full-Time Permanent',
    ),
    _StaffEmployee(
      id: 'EMP-005',
      name: 'Vikram Singh',
      role: 'Senior Billing Associate',
      department: 'Sales & Retail',
      phone: '+91 96500 44332',
      email: 'vikram@cliks.io',
      emergencyContact: 'Meena (Mother)',
      personalInfo: 'Male • DOB: 05 Dec 1992',
      address: '90 Whitefield Main Rd, Bangalore',
      salaryType: 'Hourly / Stipend',
      monthlySalary: 35000.0,
      bankAccount: 'Kotak Bank (•••• 7711)',
      ifsc: 'KKBK0000991',
      pfNumber: 'PF-BLR-8849205',
      panNumber: 'XYZAB7890C',
      shift: 'Evening (01:00 PM - 10:00 PM)',
      leaveBalance: 12,
      weeklyHoliday: 'Saturday & Sunday',
      rating: 4.2,
      kpiScore: '88%',
      appraisalDate: '28 Feb 2027',
      reportingManager: 'Ananya Sharma',
      employmentType: 'Full-Time Contract',
    ),
  ];

  List<_StaffEmployee> get _filteredEmployees {
    if (_searchQuery.isEmpty) return _allEmployees;
    final q = _searchQuery.toLowerCase();
    return _allEmployees.where((emp) {
      return emp.name.toLowerCase().contains(q) ||
          emp.id.toLowerCase().contains(q) ||
          emp.department.toLowerCase().contains(q) ||
          emp.role.toLowerCase().contains(q);
    }).toList();
  }

  void _triggerFileAppraisal() {
    showDialog(
      context: context,
      builder: (context) => const FilePerformanceReviewDialog(),
    );
  }

  void _triggerOnboardStaff() {
    showDialog(
      context: context,
      builder: (context) => const OnboardStaffEmployeeDialog(),
    );
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // Dropup Expandable FAB for Mobile
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: _ExpandableFab(
                onFileAppraisal: _triggerFileAppraisal,
                onOnboardStaff: _triggerOnboardStaff,
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting Style Header) ───
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
                  _buildMainContent(isMobile, screenWidth)
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
            onPressed: _triggerFileAppraisal,
            icon: const Icon(LucideIcons.fileEdit, size: 14),
            label: const Text('File Appraisal Review', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD63384),
              side: const BorderSide(color: Color(0xFFF8D7DA)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _triggerOnboardStaff,
            icon: const Icon(LucideIcons.userPlus, size: 14),
            label: const Text('Onboard Staff Employee', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY CARD (Accounting Style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    double totalPayroll = 0;
    double totalRating = 0;
    for (var emp in _allEmployees) {
      totalPayroll += emp.monthlySalary;
      totalRating += emp.rating;
    }
    final avgRating = (totalRating / _allEmployees.length).toStringAsFixed(2);

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
                      child: const Icon(LucideIcons.users, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'HR STAFF & EMPLOYEES DATABASE',
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
            'TOTAL ACTIVE HEADCOUNT',
            style: TextStyle(
              fontSize: isMobile ? 9.5 : 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_allEmployees.length} Active Staff',
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
              _buildHeroChip('Monthly Payroll', '₹${totalPayroll.toStringAsFixed(0)}', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Avg Performance', '$avgRating / 5.0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Shift Roster', '3 Active Shifts', isMobile),
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
  // MAIN CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile, double screenWidth) {
    String sectionTitle = "";
    Widget? searchRow;

    switch (_activeTab) {
      case 0:
        sectionTitle = "Employee Workforce Profiles";
        searchRow = _buildSearchRow(isMobile);
        break;
      case 1:
        sectionTitle = "Organizational Structure & Hierarchy";
        break;
      case 2:
        sectionTitle = "Workforce Payroll Structure & Bank Details";
        break;
      case 3:
        sectionTitle = "Leaves Balance & Assigned Roster Shifts";
        break;
      case 4:
        sectionTitle = "Personnel Appraisal & Rating Scorecard";
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
          Text(
            sectionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen),
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
                  hintText: 'Search staff by name, role, ID...',
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
    final list = _filteredEmployees;
    if (list.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.users, size: 40, color: AppColors.secondaryText),
            SizedBox(height: 12),
            Text('No staff records matched your filter.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
          ],
        ),
      );
    }

    if (isMobile) {
      return _buildMobileStaffCards(list);
    }

    switch (_activeTab) {
      case 0:
        return _buildProfilesTable(list, isMobile);
      case 1:
        return _buildHierarchyTable(list, isMobile);
      case 2:
        return _buildPayrollTable(list, isMobile);
      case 3:
        return _buildLeavesTable(list, isMobile);
      case 4:
        return _buildAppraisalsTable(list, isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE STAFF CARDS (Zero Scroll, Native Mobile Fit)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileStaffCards(List<_StaffEmployee> list) {
    return Column(
      children: list.map((emp) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF166534).withValues(alpha: 0.12),
                    child: Text(
                      emp.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          emp.role,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: Text(
                      emp.id,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Tab-Specific Info Fields
              if (_activeTab == 0) ...[
                _buildMobileField(LucideIcons.phone, 'Contact Phone', emp.phone),
                _buildMobileField(LucideIcons.mail, 'Email Address', emp.email),
                _buildMobileField(LucideIcons.heartHandshake, 'Emergency Contact', emp.emergencyContact),
                _buildMobileField(LucideIcons.user, 'Personal Info', emp.personalInfo),
                _buildMobileField(LucideIcons.mapPin, 'Address', emp.address),
              ] else if (_activeTab == 1) ...[
                Row(
                  children: [
                    Expanded(child: _buildMobileBadge('DEPARTMENT', emp.department, const Color(0xFFF1F5F9), const Color(0xFF334155))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMobileBadge('EMPLOYMENT TYPE', emp.employmentType, const Color(0xFFECFDF5), const Color(0xFF047857))),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.briefcase, 'Designation Role', emp.role),
                _buildMobileField(LucideIcons.userCheck, 'Reporting Manager', emp.reportingManager),
              ] else if (_activeTab == 2) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BASIC MONTHLY SALARY', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                          const SizedBox(height: 2),
                          Text('₹${emp.monthlySalary.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Text(emp.salaryType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.landmark, 'Bank Account', '${emp.bankAccount} (${emp.ifsc})'),
                _buildMobileField(LucideIcons.fileText, 'PF / PAN Registration', 'PF: ${emp.pfNumber} | PAN: ${emp.panNumber}'),
              ] else if (_activeTab == 3) ...[
                Row(
                  children: [
                    Expanded(child: _buildMobileBadge('LEAVE BALANCE', '${emp.leaveBalance} Days Available', const Color(0xFFECFDF5), const Color(0xFF047857))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMobileBadge('WEEKLY HOLIDAY', emp.weeklyHoliday, const Color(0xFFF1F5F9), const Color(0xFF475569))),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.clock, 'Assigned Work Shift', emp.shift),
              ] else if (_activeTab == 4) ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEFCE8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFEF08A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.star, size: 14, color: Color(0xFFEAB308)),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('RATING', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFA16207))),
                                Text('${emp.rating} / 5.0', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF854D0E))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('KPI SCORE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                            Text('${emp.kpiScore} Achieved', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.calendar, 'Appraisal Target Date', emp.appraisalDate),
              ],
            ],
          ),
        );
      }).toList(),
    );
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
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

  // ─── TAB 0: DESKTOP PROFILES TABLE ───
  Widget _buildProfilesTable(List<_StaffEmployee> list, bool isMobile) {
    final headers = ['EMPLOYEE PROFILE', 'ID / CODE', 'CONTACT INFO', 'EMERGENCY PERSON', 'PERSONAL INFO', 'RESIDENTIAL ADDRESS'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 1000),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(210),
            1: FixedColumnWidth(110),
            2: FixedColumnWidth(200),
            3: FixedColumnWidth(160),
            4: FixedColumnWidth(180),
            5: FixedColumnWidth(240),
          },
          children: [
            _buildTableHeaderRow(headers),
            ...list.map((emp) => TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF166534).withValues(alpha: 0.12),
                        child: Text(
                          emp.name.substring(0, 2).toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emp.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                            Text(emp.role, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: Text(emp.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emp.phone, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                      Text(emp.email, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.emergencyContact, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.personalInfo, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.address, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: DESKTOP HIERARCHY TABLE ───
  Widget _buildHierarchyTable(List<_StaffEmployee> list, bool isMobile) {
    final headers = ['EMPLOYEE NAME', 'DEPARTMENT', 'DESIGNATION ROLES', 'REPORTING MANAGER', 'EMPLOYMENT TYPE'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 900),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(210),
            1: FixedColumnWidth(170),
            2: FixedColumnWidth(210),
            3: FixedColumnWidth(180),
            4: FixedColumnWidth(160),
          },
          children: [
            _buildTableHeaderRow(headers),
            ...list.map((emp) => TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        child: Text(
                          emp.name.substring(0, 2).toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(emp.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(emp.department, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.role, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.reportingManager, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(emp.employmentType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  // ─── TAB 2: DESKTOP PAYROLL TABLE ───
  Widget _buildPayrollTable(List<_StaffEmployee> list, bool isMobile) {
    final headers = ['EMPLOYEE', 'SALARY TYPE', 'BASIC MONTHLY SALARY', 'BANK NAME & ACCOUNT', 'IFSC CODE', 'PF NUMBER', 'PAN NUMBER'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 1050),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(180),
            1: FixedColumnWidth(130),
            2: FixedColumnWidth(170),
            3: FixedColumnWidth(190),
            4: FixedColumnWidth(120),
            5: FixedColumnWidth(130),
            6: FixedColumnWidth(120),
          },
          children: [
            _buildTableHeaderRow(headers),
            ...list.map((emp) => TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.salaryType, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text('₹${emp.monthlySalary.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.bankAccount, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.ifsc, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.pfNumber, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.panNumber, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  // ─── TAB 3: DESKTOP LEAVES TABLE ───
  Widget _buildLeavesTable(List<_StaffEmployee> list, bool isMobile) {
    final headers = ['EMPLOYEE NAME', 'ASSIGNED WORK SHIFT', 'ANNUAL LEAVE BALANCE', 'WEEKLY HOLIDAY'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 800),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(200),
            1: FixedColumnWidth(250),
            2: FixedColumnWidth(180),
            3: FixedColumnWidth(170),
          },
          children: [
            _buildTableHeaderRow(headers),
            ...list.map((emp) => TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Text(emp.shift, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC2410C))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('${emp.leaveBalance} Days Available', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.weeklyHoliday, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  // ─── TAB 4: DESKTOP APPRAISALS TABLE ───
  Widget _buildAppraisalsTable(List<_StaffEmployee> list, bool isMobile) {
    final headers = ['EMPLOYEE', 'PERFORMANCE RATING', 'KPI TARGETS SCORE', 'APPRAISAL TARGET DATE'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 800),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(200),
            1: FixedColumnWidth(220),
            2: FixedColumnWidth(180),
            3: FixedColumnWidth(180),
          },
          children: [
            _buildTableHeaderRow(headers),
            ...list.map((emp) => TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.star, size: 14, color: Color(0xFFEAB308)),
                      const SizedBox(width: 6),
                      Text('${emp.rating} / 5.0', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(emp.kpiScore, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(emp.appraisalDate, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
                ),
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
  final VoidCallback onFileAppraisal;
  final VoidCallback onOnboardStaff;

  const _ExpandableFab({
    required this.onFileAppraisal,
    required this.onOnboardStaff,
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
              icon: LucideIcons.userPlus,
              label: 'Onboard Staff Employee',
              color: const Color(0xFF166534), // Green
              onPressed: () {
                _toggle();
                widget.onOnboardStaff();
              },
            ),
          ),
          _buildAnimatedChild(
            0,
            _MiniFab(
              icon: LucideIcons.fileEdit,
              label: 'File Appraisal Review',
              color: const Color(0xFFD63384), // Pink / Accent
              onPressed: () {
                _toggle();
                widget.onFileAppraisal();
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
