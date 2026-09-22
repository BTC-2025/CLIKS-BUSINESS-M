import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/roster_shift_dialog.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

// ═══════════════════════════════════════════════════════════════
// DUMMY ATTENDANCE MODELS
// ═══════════════════════════════════════════════════════════════
class _AttendanceLog {
  final String logId;
  final String empName;
  final String empId;
  final String checkIn;
  final String checkOut;
  final String productiveHours;
  final String location;
  final String status; // PRESENT (ON-TIME), LATE ENTRY, ABSENT
  final Color statusColor;

  _AttendanceLog({
    required this.logId,
    required this.empName,
    required this.empId,
    required this.checkIn,
    required this.checkOut,
    required this.productiveHours,
    required this.location,
    required this.status,
    required this.statusColor,
  });
}

class _ShiftConfig {
  final String shiftId;
  final String shiftName;
  final String timing;
  final String shiftType;
  final String graceTime;

  _ShiftConfig({
    required this.shiftId,
    required this.shiftName,
    required this.timing,
    required this.shiftType,
    required this.graceTime,
  });
}

class _CorrectionClaim {
  final String claimId;
  final String empName;
  final String reason;
  final String date;
  final String status;
  final Color statusColor;

  _CorrectionClaim({
    required this.claimId,
    required this.empName,
    required this.reason,
    required this.date,
    required this.status,
    required this.statusColor,
  });
}

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Today's Logs, 1: History Ledger, 2: Date-wise Lookup, 3: Shift Configs, 4: GPS Fencing, 5: Corrections, 6: Calendar
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<_TabItem> _tabs = [
    _TabItem('Today\'s Logs', LucideIcons.clock),
    _TabItem('History Ledger', LucideIcons.users),
    _TabItem('Date-wise Lookup', LucideIcons.calendarSearch),
    _TabItem('Shift Configurations', LucideIcons.layoutPanelTop),
    _TabItem('GPS Location Fencing', LucideIcons.mapPin),
    _TabItem('Correction Verifications', LucideIcons.refreshCw),
    _TabItem('Calendar View', LucideIcons.calendarRange),
  ];

  // Dummy Attendance Logs
  final List<_AttendanceLog> _logs = [
    _AttendanceLog(
      logId: 'LOG-8801',
      empName: 'Ravi Kumar',
      empId: 'EMP-001',
      checkIn: '09:05 AM',
      checkOut: '06:12 PM',
      productiveHours: '9h 07m',
      location: 'Bangalore HQ',
      status: 'PRESENT (ON-TIME)',
      statusColor: const Color(0xFF166534),
    ),
    _AttendanceLog(
      logId: 'LOG-8802',
      empName: 'Ananya Sharma',
      empId: 'EMP-002',
      checkIn: '09:18 AM',
      checkOut: '06:05 PM',
      productiveHours: '8h 47m',
      location: 'Bangalore HQ',
      status: 'LATE ENTRY (18m)',
      statusColor: const Color(0xFFC2410C),
    ),
    _AttendanceLog(
      logId: 'LOG-8803',
      empName: 'Rajesh Patel',
      empId: 'EMP-003',
      checkIn: '07:02 AM',
      checkOut: '04:08 PM',
      productiveHours: '9h 06m',
      location: 'Main Warehouse',
      status: 'PRESENT (ON-TIME)',
      statusColor: const Color(0xFF166534),
    ),
    _AttendanceLog(
      logId: 'LOG-8804',
      empName: 'Sneha Reddy',
      empId: 'EMP-004',
      checkIn: '08:58 AM',
      checkOut: '06:00 PM',
      productiveHours: '9h 02m',
      location: 'Bangalore HQ',
      status: 'PRESENT (ON-TIME)',
      statusColor: const Color(0xFF166534),
    ),
    _AttendanceLog(
      logId: 'LOG-8805',
      empName: 'Vikram Singh',
      empId: 'EMP-005',
      checkIn: '01:00 PM',
      checkOut: '10:00 PM',
      productiveHours: '9h 00m',
      location: 'Retail Outlet',
      status: 'PRESENT (ON-TIME)',
      statusColor: const Color(0xFF166534),
    ),
  ];

  // Dummy Shift Configs
  final List<_ShiftConfig> _shifts = [
    _ShiftConfig(shiftId: 'SHIFT-01', shiftName: 'General Corporate Shift', timing: '09:00 AM - 06:00 PM', shiftType: 'Regular Day', graceTime: '15 Mins'),
    _ShiftConfig(shiftId: 'SHIFT-02', shiftName: 'Morning Warehouse Shift', timing: '07:00 AM - 04:00 PM', shiftType: 'Early Morning', graceTime: '10 Mins'),
    _ShiftConfig(shiftId: 'SHIFT-03', shiftName: 'Evening Retail Shift', timing: '01:00 PM - 10:00 PM', shiftType: 'Second Shift', graceTime: '15 Mins'),
  ];

  // Dummy Correction Claims
  final List<_CorrectionClaim> _claims = [
    _CorrectionClaim(claimId: 'CLM-101', empName: 'Ananya Sharma', reason: 'Missed Punch Out (Biometric Error)', date: '10-Aug-2026', status: 'APPROVED', statusColor: const Color(0xFF166534)),
    _CorrectionClaim(claimId: 'CLM-102', empName: 'Vikram Singh', reason: 'GPS Sync Timeout at Client Location', date: '08-Aug-2026', status: 'PENDING APPROVAL', statusColor: const Color(0xFFC2410C)),
  ];

  List<_AttendanceLog> get _filteredLogs {
    if (_searchQuery.isEmpty) return _logs;
    final q = _searchQuery.toLowerCase();
    return _logs.where((l) => l.empName.toLowerCase().contains(q) || l.empId.toLowerCase().contains(q) || l.logId.toLowerCase().contains(q)).toList();
  }

  void _triggerRegularizeMissedPunch() {
    ref.read(navigationProvider.notifier).setRoute(AppRoute.regularizeMissedPunch);
  }

  void _triggerManualPunchEntry() {
    ref.read(navigationProvider.notifier).setRoute(AppRoute.manualPunchEntry);
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
                onRegularize: _triggerRegularizeMissedPunch,
                onManualPunch: _triggerManualPunchEntry,
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
            onPressed: _triggerRegularizeMissedPunch,
            icon: const Icon(LucideIcons.refreshCw, size: 14),
            label: const Text('Regularize Missed Punch', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD63384),
              side: const BorderSide(color: Color(0xFFF8D7DA)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _triggerManualPunchEntry,
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Manual Punch Entry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                      child: const Icon(LucideIcons.clock, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'TIME & ATTENDANCE TRACKING',
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
            'TODAY\'S ATTENDANCE RATE',
            style: TextStyle(
              fontSize: isMobile ? 9.5 : 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '94.2% Present',
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
              _buildHeroChip('Late Punch Marks', '1 Late', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Active Shifts', '3 Roster', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Pending Claims', '0 Claims', isMobile),
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
        sectionTitle = "Today's Attendance Logs";
        searchRow = _buildSearchRow(isMobile);
        break;
      case 1:
        sectionTitle = "Monthly Staff Attendance History Ledger";
        break;
      case 2:
        sectionTitle = "Date-wise Timesheet Lookup";
        break;
      case 3:
        sectionTitle = "Roster Shifts & Work Timings";
        break;
      case 4:
        sectionTitle = "GPS Geofencing Geo-Tracking Setup";
        break;
      case 5:
        sectionTitle = "Missed Punch Correction Approvals";
        break;
      case 6:
        sectionTitle = "Workforce Attendance Calendar View";
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
                  onPressed: () {
                    showDialog(context: context, builder: (context) => const RosterShiftDialog());
                  },
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text('Add Roster Shift', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                  hintText: 'Search today\'s logs by employee...',
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
      return _buildMobileAttendanceCards();
    }

    switch (_activeTab) {
      case 0:
        return _buildDesktopLogsTable(_filteredLogs);
      case 1:
        return _buildDesktopHistoryTable();
      case 2:
        return _buildDesktopDateLookupTable();
      case 3:
        return _buildDesktopShiftsTable();
      case 4:
        return _buildDesktopGpsTable();
      case 5:
        return _buildDesktopCorrectionsTable();
      case 6:
        return _buildDesktopCalendarView();
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE ATTENDANCE CARDS (Zero Scroll, Native Mobile Fit)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileAttendanceCards() {
    if (_activeTab == 0 || _activeTab == 2) {
      return Column(
        children: _filteredLogs.map((log) {
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
                        log.empName.substring(0, 2).toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.empName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                          Text(log.empId, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: log.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: log.statusColor.withValues(alpha: 0.25)),
                      ),
                      child: Text(log.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: log.statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildMobileBadge('CHECK-IN / OUT', '${log.checkIn} - ${log.checkOut}', const Color(0xFFEFF6FF), const Color(0xFF1D4ED8))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMobileBadge('PRODUCTIVE HOURS', log.productiveHours, const Color(0xFFECFDF5), const Color(0xFF047857))),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.mapPin, 'Location', log.location),
              ],
            ),
          );
        }).toList(),
      );
    } else if (_activeTab == 3) {
      return Column(
        children: _shifts.map((shift) {
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
                    Text(shift.shiftName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Text(shift.shiftId, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.clock, 'Timing', shift.timing),
                _buildMobileField(LucideIcons.shieldCheck, 'Grace Period', shift.graceTime),
              ],
            ),
          );
        }).toList(),
      );
    } else if (_activeTab == 5) {
      return Column(
        children: _claims.map((claim) {
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
                    Text(claim.empName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: claim.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(claim.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: claim.statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMobileField(LucideIcons.fileText, 'Reason', claim.reason),
                _buildMobileField(LucideIcons.calendar, 'Date', claim.date),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Default fallback for history / calendar
    return Column(
      children: _logs.map((log) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.empName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(log.location, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ],
              ),
              Text(log.productiveHours, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
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
  Widget _buildDesktopLogsTable(List<_AttendanceLog> list) {
    final headers = ['LOG ID', 'EMPLOYEE PROFILE', 'CHECK-IN / OUT', 'PRODUCTIVE HOURS', 'LOCATION', 'STATUS'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 950),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(110),
            1: FixedColumnWidth(210),
            2: FixedColumnWidth(200),
            3: FixedColumnWidth(160),
            4: FixedColumnWidth(160),
            5: FixedColumnWidth(160),
          },
          children: [
            _buildTableHeaderRow(headers),
            ...list.map((log) => TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(log.logId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.empName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                      Text(log.empId, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('${log.checkIn} - ${log.checkOut}', style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(log.productiveHours, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(log.location, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: log.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(log.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: log.statusColor)),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHistoryTable() {
    final headers = ['EMPLOYEE ID', 'STAFF MEMBER', 'PRESENT DAYS', 'ABSENT DAYS', 'LATE MARKS', 'ACTION LEDGER'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 900),
        child: Table(
          columnWidths: const {0: FixedColumnWidth(120), 1: FixedColumnWidth(210), 2: FixedColumnWidth(140), 3: FixedColumnWidth(140), 4: FixedColumnWidth(140), 5: FixedColumnWidth(150)},
          children: [
            _buildTableHeaderRow(headers),
            ..._logs.map((log) => TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(log.empId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(log.empName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: const Text('24 Days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: const Text('1 Day', style: TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: const Text('1 Late', style: TextStyle(fontSize: 11, color: Color(0xFFC2410C)))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: const Text('View Timesheet', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)))),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopDateLookupTable() {
    return _buildDesktopLogsTable(_filteredLogs);
  }

  Widget _buildDesktopShiftsTable() {
    final headers = ['SHIFT ID', 'SHIFT NAME', 'SHIFT TIMING', 'SHIFT TYPE', 'ALLOWED GRACE TIME'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 900),
        child: Table(
          children: [
            _buildTableHeaderRow(headers),
            ..._shifts.map((s) => TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.shiftId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.shiftName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.timing, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.shiftType, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(s.graceTime, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopGpsTable() {
    final headers = ['LOCATION CODE', 'FACILITY NAME', 'GPS COORDINATES', 'ALLOWED GEOFENCE RADIUS', 'STATUS'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 900),
        child: Table(
          children: [
            _buildTableHeaderRow(headers),
            TableRow(
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('LOC-01', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('Bangalore HQ Office', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('12.9716° N, 77.5946° E', style: TextStyle(fontSize: 11))),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('100 Meters Radius', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)), child: const Text('ACTIVE FENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCorrectionsTable() {
    final headers = ['CLAIM ID', 'EMPLOYEE', 'REASON FOR CORRECTION', 'DATE OF LOG', 'STATUS'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 900),
        child: Table(
          children: [
            _buildTableHeaderRow(headers),
            ..._claims.map((c) => TableRow(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.claimId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.empName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.reason, style: const TextStyle(fontSize: 11, color: AppColors.darkText))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(c.date, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: c.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(c.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c.statusColor)),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCalendarView() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.calendarRange, size: 40, color: Color(0xFF166534)),
          SizedBox(height: 12),
          Text('Workforce Attendance Monthly Roster Grid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          SizedBox(height: 4),
          Text('All 5 staff members fully logged for current month.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
        ],
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
  final VoidCallback onRegularize;
  final VoidCallback onManualPunch;

  const _ExpandableFab({
    required this.onRegularize,
    required this.onManualPunch,
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
              label: 'Manual Punch Entry',
              color: const Color(0xFF166534), // Green
              onPressed: () {
                _toggle();
                widget.onManualPunch();
              },
            ),
          ),
          _buildAnimatedChild(
            0,
            _MiniFab(
              icon: LucideIcons.refreshCw,
              label: 'Regularize Missed Punch',
              color: const Color(0xFFD63384), // Pink / Accent
              onPressed: () {
                _toggle();
                widget.onRegularize();
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
