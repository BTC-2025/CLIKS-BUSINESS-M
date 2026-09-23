import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';

enum _StorageTab {
  home,
  bnxMail,
  cliks,
  cliksBusiness,
  storageUsage,
  recycleBin,
  manageApps,
  settings,
}

class MacOsStoragePage extends ConsumerStatefulWidget {
  const MacOsStoragePage({super.key});

  @override
  ConsumerState<MacOsStoragePage> createState() => _MacOsStoragePageState();
}

class _MacOsStoragePageState extends ConsumerState<MacOsStoragePage> {
  _StorageTab _activeTab = _StorageTab.cliksBusiness;
  bool _isAccountMenuOpen = false;
  String _lastUpdatedText = 'Just now';
  bool _isRefreshing = false;

  void _triggerRefresh() {
    setState(() {
      _isRefreshing = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          final now = DateTime.now();
          final minutes = now.minute.toString().padLeft(2, '0');
          _lastUpdatedText = '${now.hour}:$minutes';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Column(
            children: [
              // ─── 1. TOP GLOBAL HEADER BAR ───
              _buildTopBar(),

              // ─── 2. MAIN LAYOUT: SIDEBAR + CONTENT ───
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Sidebar
                    _buildSidebar(),

                    // Right Main Scrollable View
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF8FAFC),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                          child: _buildActiveTabView(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── 3. ACCOUNT DROPDOWN OVERLAY (When Open) ───
          if (_isAccountMenuOpen) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _isAccountMenuOpen = false),
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 58,
              right: 28,
              child: _buildAccountDropdownCard(),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP BAR (Beta Logo, Return Button, Account Button)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Return to Cliks Business Button
          Tooltip(
            message: 'Back to Cliks Business',
            child: InkWell(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  ref.read(navigationProvider.notifier).setRoute(AppRoute.dashboard);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(LucideIcons.arrowLeft, size: 16, color: Color(0xFF334155)),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Beta Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'B',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 19,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Beta',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),

          const Spacer(),

          // Account Button (Blue Pill Button)
          InkWell(
            onTap: () => setState(() => _isAccountMenuOpen = !_isAccountMenuOpen),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.user, size: 15, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Account',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACCOUNT DROPDOWN CARD (Matching Reference Image 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAccountDropdownCard() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar with initial R + camera badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'R',
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.camera, size: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Username & Email
              Text(
                'ravinew2004',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ravinew2004@bnxmail.com',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),

              // Manage your account button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _isAccountMenuOpen = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening account profile management...', style: GoogleFonts.outfit()),
                      backgroundColor: const Color(0xFF2563EB),
                      behavior: SnackBarBehavior.floating,
                      width: 380,
                    ),
                  );
                },
                icon: const Icon(LucideIcons.user, size: 14),
                label: Text(
                  'Manage your account',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 10),

              // Menu Options
              _buildAccountMenuItem(
                icon: LucideIcons.userPlus,
                title: 'Add another account',
                color: const Color(0xFF334155),
                onTap: () {
                  setState(() => _isAccountMenuOpen = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Add account dialog initiated.', style: GoogleFonts.outfit()),
                      backgroundColor: const Color(0xFF334155),
                      behavior: SnackBarBehavior.floating,
                      width: 340,
                    ),
                  );
                },
              ),
              _buildAccountMenuItem(
                icon: LucideIcons.logOut,
                title: 'Sign out of this account',
                color: const Color(0xFF334155),
                onTap: () {
                  setState(() => _isAccountMenuOpen = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Signed out of ravinew2004.', style: GoogleFonts.outfit()),
                      backgroundColor: const Color(0xFF334155),
                      behavior: SnackBarBehavior.floating,
                      width: 340,
                    ),
                  );
                },
              ),
              _buildAccountMenuItem(
                icon: LucideIcons.logOut,
                title: 'Sign out of all accounts',
                color: const Color(0xFFEF4444),
                onTap: () {
                  setState(() => _isAccountMenuOpen = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All accounts signed out.', style: GoogleFonts.outfit()),
                      backgroundColor: const Color(0xFFDC2626),
                      behavior: SnackBarBehavior.floating,
                      width: 340,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LEFT SIDEBAR NAVIGATION (Matching Reference Images)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        children: [
          // Home
          _buildSidebarItem(
            tab: _StorageTab.home,
            icon: LucideIcons.home,
            title: 'Home',
          ),

          const SizedBox(height: 18),
          _buildSidebarSectionHeader('APPLICATION STORAGE'),
          const SizedBox(height: 6),

          _buildSidebarItem(
            tab: _StorageTab.bnxMail,
            icon: LucideIcons.send,
            title: 'BNX Mail',
          ),
          _buildSidebarItem(
            tab: _StorageTab.cliks,
            icon: LucideIcons.checkCircle2,
            title: 'Cliks',
          ),
          _buildSidebarItem(
            tab: _StorageTab.cliksBusiness,
            icon: LucideIcons.checkCircle2,
            title: 'Cliks Business',
          ),

          const SizedBox(height: 18),
          _buildSidebarSectionHeader('STORAGE MANAGEMENT'),
          const SizedBox(height: 6),

          _buildSidebarItem(
            tab: _StorageTab.storageUsage,
            icon: LucideIcons.barChart2,
            title: 'Storage Usage',
          ),
          _buildSidebarItem(
            tab: _StorageTab.recycleBin,
            icon: LucideIcons.trash2,
            title: 'Recycle Bin',
          ),
          _buildSidebarItem(
            tab: _StorageTab.manageApps,
            icon: LucideIcons.layoutGrid,
            title: 'Manage Apps',
          ),

          const SizedBox(height: 18),
          _buildSidebarSectionHeader('SYSTEM'),
          const SizedBox(height: 6),

          _buildSidebarItem(
            tab: _StorageTab.settings,
            icon: LucideIcons.settings,
            title: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF94A3B8),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required _StorageTab tab,
    required IconData icon,
    required String title,
  }) {
    final isSelected = _activeTab == tab;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () => setState(() => _activeTab = tab),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAIN CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildActiveTabView() {
    switch (_activeTab) {
      case _StorageTab.cliksBusiness:
        return _buildCliksBusinessView();
      case _StorageTab.storageUsage:
        return _buildStorageUsageView();
      case _StorageTab.home:
        return _buildHomeOverviewView();
      case _StorageTab.bnxMail:
        return _buildBnxMailView();
      case _StorageTab.cliks:
        return _buildCliksAppView();
      case _StorageTab.recycleBin:
        return _buildRecycleBinView();
      case _StorageTab.manageApps:
        return _buildManageAppsView();
      case _StorageTab.settings:
        return _buildSettingsView();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // VIEW 1: CLIKS BUSINESS STORAGE (Image 1 & 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCliksBusinessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumbs & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _activeTab = _StorageTab.storageUsage),
                      child: Text(
                        'Storage Management',
                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ),
                    Text(
                      '  ›  ',
                      style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8)),
                    ),
                    Text(
                      'Cliks Business',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Cliks Business Storage',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Track how your 1.00 GB storage is used in Cliks Business.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            // Last Updated Pill with Refresh Action
            InkWell(
              onTap: _triggerRefresh,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Last Updated: $_lastUpdatedText',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _isRefreshing ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: const Icon(LucideIcons.refreshCw, size: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ─── SUMMARY STATS CARD ───
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final statsRow = Row(
                children: [
                  // Circular Donut Progress Meter (90% USED)
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CustomPaint(
                      painter: _DonutRingPainter(progress: 0.90, color: const Color(0xFF6366F1)),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '90%',
                              style: GoogleFonts.outfit(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'USED',
                              style: GoogleFonts.outfit(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),

                  // Stat 1: 921.00 MB USED
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '921.00 MB',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF7C3AED),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'USED',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '90% Used',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stat 2: 103.00 MB AVAILABLE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '103.00 MB',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF10B981),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'AVAILABLE',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stat 3: 1.00 GB TOTAL CAPACITY
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1.00 GB',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'TOTAL CAPACITY',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stat 4: Critical
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Critical',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFEF4444),
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'STORAGE CRITICALLY FULL.\nACTION REQUIRED.',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                            height: 1.25,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (constraints.maxWidth < 650) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 650),
                    child: statsRow,
                  ),
                );
              }
              return statsRow;
            },
          ),
        ),

        const SizedBox(height: 24),

        // ─── STORAGE BY CATEGORY TABLE CARD ───
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Storage by Category',
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'USED',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'TYPE',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Category Rows
              _buildCategoryRow(
                dotColor: const Color(0xFF2563EB),
                name: 'Audit & Tax (FIN-PRO)',
                percent: '9%',
                badgeBg: const Color(0xFFEFF6FF),
                badgeBorder: const Color(0xFFBFDBFE),
                badgeText: const Color(0xFF2563EB),
                typeDesc: 'PDFs, XLS, Signed Certificates',
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              _buildCategoryRow(
                dotColor: const Color(0xFF10B981),
                name: 'Sales & Purchases',
                percent: '25%',
                badgeBg: const Color(0xFFECFDF5),
                badgeBorder: const Color(0xFFA7F3D0),
                badgeText: const Color(0xFF059669),
                typeDesc: 'PDF Invoices, Vendor Bills',
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              _buildCategoryRow(
                dotColor: const Color(0xFF7C3AED),
                name: 'Expenses',
                percent: '14%',
                badgeBg: const Color(0xFFF5F3FF),
                badgeBorder: const Color(0xFFDDD6FE),
                badgeText: const Color(0xFF7C3AED),
                typeDesc: 'Receipt Scans, Images',
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              _buildCategoryRow(
                dotColor: const Color(0xFFF59E0B),
                name: 'HR & Payroll',
                percent: '0%',
                badgeBg: const Color(0xFFFFFBEB),
                badgeBorder: const Color(0xFFFDE68A),
                badgeText: const Color(0xFFD97706),
                typeDesc: 'ID Documents, Payslip PDFs',
              ),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),

              _buildCategoryRow(
                dotColor: const Color(0xFF0284C7),
                name: 'Inventory & Media',
                percent: '42%',
                badgeBg: const Color(0xFFF0FDFA),
                badgeBorder: const Color(0xFF99F6E4),
                badgeText: const Color(0xFF0D9488),
                typeDesc: 'Product Photos, Barcodes',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ─── BOTTOM INFO BANNER (Image 4) ───
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.info, size: 16, color: Color(0xFF0284C7)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Keep your storage light! Review cache logs, large attachments, or database backups inside Cliks Business.',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow({
    required Color dotColor,
    required String name,
    required String percent,
    required Color badgeBg,
    required Color badgeBorder,
    required Color badgeText,
    required String typeDesc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          // Category with colored dot
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Used Pill
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeBorder),
                  ),
                  child: Text(
                    percent,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Type Description
          Expanded(
            flex: 4,
            child: Text(
              typeDesc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // VIEW 2: STORAGE USAGE TRACKING (Image 3 & 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStorageUsageView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumbs & Header
        Row(
          children: [
            InkWell(
              onTap: () => setState(() => _activeTab = _StorageTab.cliksBusiness),
              child: Text(
                'Storage Management',
                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ),
            Text(
              '  ›  ',
              style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8)),
            ),
            Text(
              'Storage Usage',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Storage Usage Tracking',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Real-time analytics and detailed storage allocation breakdown across all Beta applications.',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 24),

        // ─── TWO COLUMN CHART & BREAKDOWN ───
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 680;
            final chartCard = Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.barChart2, size: 16, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Text(
                        'Breakdown Chart',
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Multi-Segmented Donut Chart
                  Center(
                    child: SizedBox(
                      width: 190,
                      height: 190,
                      child: CustomPaint(
                        painter: _EcosystemDonutChartPainter(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '2.77 GB',
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'USED',
                                style: GoogleFonts.outfit(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );

            final breakdownCard = Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ecosystem App Breakdown',
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildEcosystemRow(
                    dotColor: const Color(0xFF2563EB),
                    name: 'BNX Mail',
                    sizeText: '1.32 GB',
                    pctText: '26% of total pool',
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  _buildEcosystemRow(
                    dotColor: const Color(0xFF7C3AED),
                    name: 'Cliks Business',
                    sizeText: '921.00 MB',
                    pctText: '18% of total pool',
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  _buildEcosystemRow(
                    dotColor: const Color(0xFF0D9488),
                    name: 'Cliks',
                    sizeText: '570.00 MB',
                    pctText: '11% of total pool',
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),

                  _buildEcosystemRow(
                    dotColor: const Color(0xFF10B981),
                    name: 'Available',
                    sizeText: '2.23 GB',
                    pctText: '45% of total pool',
                  ),
                ],
              ),
            );

            if (isNarrow) {
              return Column(
                children: [
                  chartCard,
                  const SizedBox(height: 20),
                  breakdownCard,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: chartCard),
                const SizedBox(width: 20),
                Expanded(flex: 6, child: breakdownCard),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // ─── BOTTOM STAT CARDS (TOTAL CAPACITY & AVAILABLE) ───
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL CAPACITY',
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '5.00 GB',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABLE',
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2.23 GB',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ─── BOTTOM RECLAIM SPACE BANNER ───
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need to reclaim space?',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Run cleanups inside individual app details to clear temporary files and logs.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEcosystemRow({
    required Color dotColor,
    required String name,
    required String sizeText,
    required String pctText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              sizeText,
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              pctText,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // AUXILIARY VIEWS: HOME, BNX MAIL, CLIKS, RECYCLE BIN, APPS, SETTINGS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHomeOverviewView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beta Cloud Storage Portal',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 4),
        Text('Centralized workspace storage control across all connected Beta services.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B))),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildAppShortcutCard(
              title: 'BNX Mail',
              icon: LucideIcons.send,
              used: '1.32 GB',
              total: '5.00 GB Pool',
              color: const Color(0xFF2563EB),
              onTap: () => setState(() => _activeTab = _StorageTab.bnxMail),
            ),
            const SizedBox(width: 16),
            _buildAppShortcutCard(
              title: 'Cliks Business',
              icon: LucideIcons.checkCircle2,
              used: '921.00 MB',
              total: '1.00 GB Dedicated',
              color: const Color(0xFF7C3AED),
              onTap: () => setState(() => _activeTab = _StorageTab.cliksBusiness),
            ),
            const SizedBox(width: 16),
            _buildAppShortcutCard(
              title: 'Cliks',
              icon: LucideIcons.checkCircle2,
              used: '570.00 MB',
              total: '5.00 GB Pool',
              color: const Color(0xFF0D9488),
              onTap: () => setState(() => _activeTab = _StorageTab.cliks),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppShortcutCard({
    required String title,
    required IconData icon,
    required String used,
    required String total,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 14),
              Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Text(used, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 2),
              Text(total, style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBnxMailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BNX Mail Storage', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text('Storage allocation and message attachments for BNX Mail.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              _buildCategoryRow(dotColor: const Color(0xFF2563EB), name: 'Inbox & Threads', percent: '48%', badgeBg: const Color(0xFFEFF6FF), badgeBorder: const Color(0xFFBFDBFE), badgeText: const Color(0xFF2563EB), typeDesc: 'Email bodies and conversation text'),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),
              _buildCategoryRow(dotColor: const Color(0xFF7C3AED), name: 'Attachments & Files', percent: '36%', badgeBg: const Color(0xFFF5F3FF), badgeBorder: const Color(0xFFDDD6FE), badgeText: const Color(0xFF7C3AED), typeDesc: 'PDFs, images, ZIP files'),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),
              _buildCategoryRow(dotColor: const Color(0xFF10B981), name: 'Sent & Drafts', percent: '16%', badgeBg: const Color(0xFFECFDF5), badgeBorder: const Color(0xFFA7F3D0), badgeText: const Color(0xFF059669), typeDesc: 'Outbox transmissions and temporary drafts'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCliksAppView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cliks Chat & Channel Storage', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text('Shared media, voice notes, and group history for Cliks Messenger.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              _buildCategoryRow(dotColor: const Color(0xFF0D9488), name: 'Media & Videos', percent: '62%', badgeBg: const Color(0xFFF0FDFA), badgeBorder: const Color(0xFF99F6E4), badgeText: const Color(0xFF0D9488), typeDesc: 'Photos, videos, shared links'),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),
              _buildCategoryRow(dotColor: const Color(0xFF6366F1), name: 'Voice Notes', percent: '22%', badgeBg: const Color(0xFFEEF2FF), badgeBorder: const Color(0xFFC7D2FE), badgeText: const Color(0xFF4F46E5), typeDesc: 'Recorded audio clips'),
              const Divider(height: 1, color: Color(0xFFF8FAFC)),
              _buildCategoryRow(dotColor: const Color(0xFFF59E0B), name: 'Channel History', percent: '16%', badgeBg: const Color(0xFFFFFBEB), badgeBorder: const Color(0xFFFDE68A), badgeText: const Color(0xFFD97706), typeDesc: 'Archived team discussions'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecycleBinView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recycle Bin', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text('Items in trash are automatically purged after 30 days.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B))),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Recycle bin emptied.', style: GoogleFonts.outfit()),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    width: 320,
                  ),
                );
              },
              icon: const Icon(LucideIcons.trash2, size: 14),
              label: Text('Empty Bin', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              _buildTrashItem('invoice_backup_july2026.zip', '12.4 MB', 'Deleted 4 days ago'),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildTrashItem('product_catalog_export_v1.xlsx', '3.8 MB', 'Deleted 11 days ago'),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildTrashItem('temp_audit_session_cache.log', '820 KB', 'Deleted 18 days ago'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrashItem(String name, String size, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.file, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 10),
            Text(name, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
          ],
        ),
        Row(
          children: [
            Text(size, style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B))),
            const SizedBox(width: 14),
            Text(date, style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF94A3B8))),
            const SizedBox(width: 14),
            TextButton(
              onPressed: () {},
              child: Text('Restore', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManageAppsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Manage Connected Apps', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text('Control storage access and quota caps for ecosystem applications.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              _buildAppManagerTile('Cliks Business', 'Dedicated: 1.00 GB cap', true),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildAppManagerTile('BNX Mail', 'Pooled: Dynamic allocation', true),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildAppManagerTile('Cliks Messenger', 'Pooled: Dynamic allocation', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppManagerTile(String name, String desc, bool isEnabled) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            Text(desc, style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B))),
          ],
        ),
        Switch(
          value: isEnabled,
          activeColor: const Color(0xFF2563EB),
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _buildSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Storage Settings & Preferences', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text('Configure automated warning thresholds and cache management.', style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF64748B))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alert Thresholds', style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text('Notify when Cliks Business crosses 90% capacity (Active: Critical Alert).', style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF64748B))),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFECACA))),
                    child: Text('Critical Trigger: 90%', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                  ),
                  const SizedBox(width: 10),
                  Text('Active on macOS Notification Center', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTER: SINGLE DONUT RING (Used in Cliks Business View)
// ═══════════════════════════════════════════════════════════════
class _DonutRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DonutRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFFEDE9FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTER: MULTI-SEGMENT DONUT (Used in Storage Usage View)
// ═══════════════════════════════════════════════════════════════
class _EcosystemDonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    final segments = [
      {'color': const Color(0xFF2563EB), 'pct': 0.26}, // BNX Mail: 26%
      {'color': const Color(0xFF7C3AED), 'pct': 0.18}, // Cliks Business: 18%
      {'color': const Color(0xFF0D9488), 'pct': 0.11}, // Cliks: 11%
      {'color': const Color(0xFF10B981), 'pct': 0.45}, // Available: 45%
    ];

    double startAngle = -math.pi / 2;
    const gap = 0.05; // gap in radians between segments

    for (final seg in segments) {
      final color = seg['color'] as Color;
      final pct = seg['pct'] as double;
      final sweep = (2 * math.pi * pct) - gap;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gap / 2),
        sweep,
        false,
        paint,
      );

      startAngle += (2 * math.pi * pct);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
