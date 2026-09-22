import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/request_document_dialog.dart';
import '../widgets/assign_task_dialog.dart';
import '../widgets/register_client_dialog.dart';
import '../widgets/invite_team_dialog.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

class AuditHubPage extends StatefulWidget {
  const AuditHubPage({super.key});

  @override
  State<AuditHubPage> createState() => _AuditHubPageState();
}

class _AuditHubPageState extends State<AuditHubPage> with SingleTickerProviderStateMixin {
  int _activeWorkplace = 0; // 0: FIN-PRO Business, 1: FIN-PRO Firm
  int _activeAdvisoryTab = 0; // 0: Home, 1: Clients, 2: Tasks, 3: Teams, 4: Time Tracking, 5: Workpaper, 6: consult, 7: Reports, 8: Senior CA
  final TextEditingController _emailController = TextEditingController();

  final List<_TabItem> _advisoryTabs = [
    _TabItem('Home', LucideIcons.home),
    _TabItem('Clients', LucideIcons.users),
    _TabItem('Tasks', LucideIcons.checkSquare),
    _TabItem('Teams', LucideIcons.userCheck),
    _TabItem('Time Tracking', LucideIcons.clock),
    _TabItem('Workpaper', LucideIcons.fileText),
    _TabItem('consult', LucideIcons.wallet),
    _TabItem('Reports', LucideIcons.barChart2),
    _TabItem('Senior CA', LucideIcons.userCheck),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD WITH INTEGRATED WORKPLACE BUTTONS ───
          SliverToBoxAdapter(
            child: isMacOS
                ? _buildHeroSummary(isMobile)
                : _buildHeroSummary(isMobile)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.05, end: 0),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 12),
          ),

          // ─── STICKY ADVISORY TAB NAVIGATION (When in Firm Mode) ───
          if (_activeWorkplace == 1)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabNavDelegate(
                height: isMobile ? 50 : 56,
                child: Container(
                  color: const Color(0xFFF8F9FB),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: _buildAdvisoryTabsBar(isMobile),
                ),
              ),
            ),

          if (_activeWorkplace == 1)
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),

          // ─── MAIN CONTENT AREA ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 40 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: isMacOS
                  ? _buildMainContent(isMobile)
                  : _buildMainContent(isMobile)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 150.ms),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY CARD WITH INTEGRATED 2 BUTTONS & ESSENTIAL STATS
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
          // Title Header & Status Badge Row
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
                      child: const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'FIN-PRO AUDIT & COMPLIANCE',
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
                    Icon(LucideIcons.checkCircle2, size: 13, color: Colors.greenAccent.shade100),
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

          // 2 Workplace Buttons Placed Inside Statistics Header Card
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeWorkplace = 0),
                  child: AnimatedContainer(
                    duration: Theme.of(context).platform == TargetPlatform.macOS ? Duration.zero : const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _activeWorkplace == 0 ? Colors.white : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _activeWorkplace == 0 ? Colors.white : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.monitor,
                          color: _activeWorkplace == 0 ? AppColors.stylishDarkGreen : Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'FIN-PRO Business',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _activeWorkplace == 0 ? AppColors.stylishDarkGreen : Colors.white,
                              fontSize: isMobile ? 11 : 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeWorkplace = 1),
                  child: AnimatedContainer(
                    duration: Theme.of(context).platform == TargetPlatform.macOS ? Duration.zero : const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _activeWorkplace == 1 ? Colors.white : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _activeWorkplace == 1 ? Colors.white : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.userCheck,
                          color: _activeWorkplace == 1 ? AppColors.stylishDarkGreen : Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'FIN-PRO Firm',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _activeWorkplace == 1 ? AppColors.stylishDarkGreen : Colors.white,
                              fontSize: isMobile ? 11 : 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Essential Necessary Stat Chips Only
          Row(
            children: [
              _buildHeroChip('Active Compliance Audits', '12 Active', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Compliance Score', '98.5%', isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, String value, bool isMobile) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 8 : 10),
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
                fontSize: isMobile ? 8.5 : 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
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
  // ADVISORY CHOICE TABS (Accounting Style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAdvisoryTabsBar(bool isMobile) {
    return Container(
      height: isMobile ? 46 : 52,
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 6),
        itemCount: _advisoryTabs.length,
        itemBuilder: (context, index) {
          final isSelected = _activeAdvisoryTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _activeAdvisoryTab = index),
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
                      _advisoryTabs[index].icon,
                      size: isMobile ? 13 : 15,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _advisoryTabs[index].label,
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
  // MAIN CONTENT ROUTER WITH ACCOUNTING STYLE CARD CONTAINER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile) {
    if (_activeWorkplace == 0) {
      // FIN-PRO Business View
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
                    'FIN-PRO Business Command Centre',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildMainBannerCard(),
            const SizedBox(height: 20),
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildComplianceChecklistCard(),
                  const SizedBox(height: 20),
                  _buildAccountantConnectionCard(isMobile),
                  const SizedBox(height: 20),
                  _buildPaymentHistoryCard(),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildComplianceChecklistCard(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: _buildAccountantConnectionCard(isMobile),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPaymentHistoryCard(),
                ],
              ),
          ],
        ),
      );
    }

    // FIN-PRO Firm View
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
                  'FIN-PRO Advisory: ${_advisoryTabs[_activeAdvisoryTab].label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAdvisoryContent(isMobile),
        ],
      ),
    );
  }

  Widget _buildMainBannerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.briefcase, color: Color(0xFF15803D), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'FIN-PRO Command Centre',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PROFESSIONAL LAYER',
                        style: TextStyle(
                          color: Color(0xFF15803D),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage audits, taxes, compliance, and client reports in one place.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceChecklistCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle, color: Color(0xFF166534), size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'FIN-PRO-Assigned Compliance Checklist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.check, size: 9, color: Color(0xFF15803D)),
                    SizedBox(width: 4),
                    Text(
                      'All Caught Up!',
                      style: TextStyle(color: Color(0xFF15803D), fontSize: 8.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "These are the live compliance and audit actions assigned to your account by your connected FIN-PRO. Mark them as 'Completed' or 'In Progress' to sync status in real time.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Inner Empty State Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.check, color: Color(0xFF15803D), size: 24),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No Active Tasks',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your FIN-PRO Advisor hasn't assigned any compliance checklists to your email yet.",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountantConnectionCard(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(LucideIcons.users, color: Color(0xFF166534), size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Accountant Connection',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Not Connected',
                  style: TextStyle(color: Colors.black54, fontSize: 8.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Invite your FIN-PRO Advisory Partner to securely manage your taxes, scan transactions for compliance, and compile operational financial audits in real time.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _emailController,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Advisor's Email Address",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_emailController.text.trim().isNotEmpty) {
                  AppSnackbar.show(context, "Invitation sent to ${_emailController.text.trim()}", type: SnackType.success);
                  _emailController.clear();
                } else {
                  AppSnackbar.show(context, "Please enter an advisor's email address.", type: SnackType.error);
                }
              },
              icon: const Icon(LucideIcons.userPlus, size: 14),
              label: const Text('Connect Advisor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'What you will share with your FIN-PRO:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 12),

          // 2x2 Feature Share Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureChip(
                      'Check GST & Tax',
                      'Validates input credit & status',
                      LucideIcons.checkCheck,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFeatureChip(
                      'Analyze Invoices',
                      'Flags suspicious payments',
                      LucideIcons.fileSearch,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureChip(
                      'Map Accounts',
                      'IFRS / US GAAP layout mapping',
                      LucideIcons.layoutGrid,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFeatureChip(
                      'Reconcile Feeds',
                      'Matches inbound ledger payments',
                      LucideIcons.refreshCw,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF166534), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: AppColors.secondaryText, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.creditCard, color: Color(0xFF166534), size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Professional Service Payment History',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No payment history recorded yet.',
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ADVISORY FIRM CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAdvisoryContent(bool isMobile) {
    switch (_activeAdvisoryTab) {
      case 0:
        return _buildAdvisoryHomeTab(isMobile);
      case 1:
        return _buildAdvisoryClientsTab(isMobile);
      case 2:
        return _buildAdvisoryTasksTab(isMobile);
      case 3:
        return _buildAdvisoryTeamsTab(isMobile);
      case 4:
        return _buildAdvisoryTimeTrackingTab(isMobile);
      case 5:
        return _buildAdvisoryWorkpaperTab(isMobile);
      case 6:
        return _buildAdvisoryConsultTab(isMobile);
      case 7:
        return _buildAdvisoryReportsTab(isMobile);
      case 8:
        return _buildAdvisorySeniorCATab(isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAdvisoryHomeTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 Practice Stat Cards Grid
        if (isMobile)
          Column(
            children: [
              Row(
                children: [
                  _buildPracticeStatCard('Total Practice Clients', '0', 'Active Taxpayers Portal', const Color(0xFF15803D)),
                  const SizedBox(width: 10),
                  _buildPracticeStatCard('Awaiting Client Uploads', '0', 'Outbound requests pending', const Color(0xFFD97706)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildPracticeStatCard('Open Compliance Tasks', '0', 'Filing checklist items', const Color(0xFFDC2626)),
                  const SizedBox(width: 10),
                  _buildPracticeStatCard('Timesheet Records', '0', 'Logged consulting blocks', const Color(0xFF2563EB)),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              _buildPracticeStatCard('Total Practice Clients', '0', 'Active Taxpayers Portal', const Color(0xFF15803D)),
              const SizedBox(width: 12),
              _buildPracticeStatCard('Awaiting Client Uploads', '0', 'Outbound requests pending', const Color(0xFFD97706)),
              const SizedBox(width: 12),
              _buildPracticeStatCard('Open Compliance Tasks', '0', 'Filing checklist items', const Color(0xFFDC2626)),
              const SizedBox(width: 12),
              _buildPracticeStatCard('Timesheet Records', '0', 'Logged consulting blocks', const Color(0xFF2563EB)),
            ],
          ),

        const SizedBox(height: 20),

        // Activity Stream & Quick Actions Grid
        if (isMobile)
          Column(
            children: [
              _buildActivityStreamCard(),
              const SizedBox(height: 16),
              _buildQuickPracticeActionsCard(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildActivityStreamCard()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildQuickPracticeActionsCard()),
            ],
          ),
      ],
    );
  }

  Widget _buildAdvisoryClientsTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Action & Search Bar
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(LucideIcons.search, size: 14, color: Colors.black45),
                    hintText: 'Search taxpayers by name or email...',
                    hintStyle: TextStyle(fontSize: 11, color: Colors.black45),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const RequestDocumentDialog()),
                      icon: const Icon(LucideIcons.helpCircle, size: 13, color: Color(0xFF2563EB)),
                      label: const Text('Client Requests', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF93C5FD)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const RegisterClientDialog()),
                      icon: const Icon(LucideIcons.plus, size: 13),
                      label: const Text('Add Taxpayer Client', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(LucideIcons.search, size: 14, color: Colors.black45),
                      hintText: 'Search taxpayers by name or email...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.black45),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => const RequestDocumentDialog()),
                icon: const Icon(LucideIcons.helpCircle, size: 14, color: Color(0xFF2563EB)),
                label: const Text('Client Requests', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => const RegisterClientDialog()),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Taxpayer Client', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),
        _buildClientCard('Acme Technologies', 'INV-2026-041', 'Active', '9876543210'),
        const SizedBox(height: 10),
        _buildClientCard('Ravi Traders', 'INV-2026-038', 'Pending Audit', '9812345678'),
      ],
    );
  }

  Widget _buildPracticeStatCard(String label, String value, String subtitle, Color subColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkText),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: subColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStreamCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.fileText, color: Color(0xFF166534), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Practice Activity Stream',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No practice activities recorded yet. Add clients or create tasks to see live updates.',
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPracticeActionsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.zap, color: Color(0xFFD97706), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quick Practice Actions',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: 'Add New Practice Client',
            icon: LucideIcons.userPlus,
            onPressed: () => showDialog(context: context, builder: (_) => const RegisterClientDialog()),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            label: 'Request Client Document',
            icon: LucideIcons.helpCircle,
            onPressed: () => showDialog(context: context, builder: (_) => const RequestDocumentDialog()),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            label: 'Create Operations Task',
            icon: LucideIcons.checkSquare,
            onPressed: () => showDialog(context: context, builder: (_) => const AssignTaskDialog()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14, color: const Color(0xFF166534)),
        label: Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF0FDF4),
          side: const BorderSide(color: Color(0xFFBBF7D0)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildAdvisoryTasksTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Audit & Tax Tasks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => showDialog(context: context, builder: (_) => const AssignTaskDialog()),
              icon: const Icon(LucideIcons.plusCircle, size: 14),
              label: const Text('Assign Task', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTaskCard('Verify GSTR-3B Input Tax Credit', 'Due: 15-08-2026', 'In Progress'),
        const SizedBox(height: 10),
        _buildTaskCard('Perform Stock Count Reconciliation', 'Due: 20-08-2026', 'Pending'),
      ],
    );
  }

  Widget _buildAdvisoryTeamsTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Practice Team Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 4),
              const Text(
                'Manage roles, access control, and staff associations inside your advisory firm.',
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const InviteTeamDialog()),
                      icon: const Icon(LucideIcons.userCheck, size: 13, color: Color(0xFF2563EB)),
                      label: const Text('Team Requests', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF93C5FD)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const InviteTeamDialog()),
                      icon: const Icon(LucideIcons.plus, size: 13),
                      label: const Text('Add Team Member', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Practice Team Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    SizedBox(height: 4),
                    Text(
                      'Manage roles, access control, and staff associations inside your advisory firm.',
                      style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => const InviteTeamDialog()),
                icon: const Icon(LucideIcons.userCheck, size: 14, color: Color(0xFF2563EB)),
                label: const Text('Team Requests', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => const InviteTeamDialog()),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add Team Member', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),
        _buildTeamCard('Rajesh Sharma', 'Senior Auditor', 'rajesh@finpro.com'),
        const SizedBox(height: 10),
        _buildTeamCard('Priya Nair', 'Tax Specialist', 'priya@finpro.com'),
      ],
    );
  }

  Widget _buildAdvisoryTimeTrackingTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            children: [
              _buildBusinessOwnerDetailsCard(),
              const SizedBox(height: 16),
              _buildAuditSessionTimerCard(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildBusinessOwnerDetailsCard()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildAuditSessionTimerCard()),
            ],
          ),
      ],
    );
  }

  Widget _buildBusinessOwnerDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.user, color: Color(0xFF166534), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Business Owner Details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Profile Header Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFDCFCE7),
                  child: const Text('U', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('uhgk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                      Text('uhgk@gmail.com', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Active Client', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                ),
                const SizedBox(width: 6),
                const Icon(LucideIcons.messageSquare, size: 14, color: Color(0xFF166534)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _buildDetailRow(LucideIcons.building, 'Business Name', 'uhgk'),
          _buildDetailRow(LucideIcons.fileText, 'GSTIN', '07ABCDE1234F1Z5'),
          _buildDetailRow(LucideIcons.briefcase, 'Business Type', 'Proprietorship'),
          _buildDetailRow(LucideIcons.mail, 'Email', 'uhgk@gmail.com'),
          _buildDetailRow(LucideIcons.phone, 'Mobile', '9876543210'),
          _buildDetailRow(LucideIcons.mapPin, 'Address', '123 Business Street, New Delhi, Delhi - 110001, India'),
          _buildDetailRow(LucideIcons.creditCard, 'PAN', 'ABCDE1234F'),
          _buildDetailRow(LucideIcons.calendar, 'Date of Onboarding', '01/08/2026'),
          _buildDetailRow(LucideIcons.checkCircle, 'Status', 'Active', isStatus: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
            ),
          ),
          Expanded(
            flex: 3,
            child: isStatus
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Active', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditSessionTimerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.timer, color: Color(0xFF166534), size: 22),
          const SizedBox(height: 6),
          const Text('Audit Session Timer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 2),
          const Text('Track your professional audit hours for billing.', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
          const SizedBox(height: 16),

          // Fields
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: 'uhgk',
                      isExpanded: true,
                      style: const TextStyle(fontSize: 11, color: AppColors.darkText),
                      items: const [DropdownMenuItem(value: 'uhgk', child: Text('uhgk'))],
                      onChanged: null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: const Text('8/11/2026', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 64,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const TextField(
              maxLines: 2,
              style: TextStyle(fontSize: 11),
              decoration: InputDecoration(
                hintText: 'Example:\nGST Return Filing (GSTR-1)\nReview Purchase Bills',
                hintStyle: TextStyle(fontSize: 10, color: Colors.black38),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Clock Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Text(
                  '00:00:00',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.stylishDarkGreen, letterSpacing: 2),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('READY TO START', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.play, size: 14),
              label: const Text('Start Audit Session', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryWorkpaperTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📑 Workpaper — Select a Client',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 4),
        const Text(
          'Click on a client to view and manage their audit checklist.',
          style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 3, child: Text('Client Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                  Expanded(flex: 3, child: Text('Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                  Expanded(flex: 3, child: Text('Checklist Progress', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                  Expanded(flex: 2, child: Text('Action', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Text(
                    'No clients found. Add clients first in the Clients tab.',
                    style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvisoryConsultTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 6 Summary Stat Cards (Earnings & Revenue)
        if (isMobile)
          Column(
            children: [
              Row(
                children: [
                  _buildConsultStatCard("Today's Earnings", '₹0', const Color(0xFF15803D)),
                  const SizedBox(width: 8),
                  _buildConsultStatCard('This Week', '₹0', const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  _buildConsultStatCard('This Month', '₹0', const Color(0xFF2563EB)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildConsultStatCard('Pending Payments', '₹0', const Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  _buildConsultStatCard('Paid Payments', '₹0', const Color(0xFF15803D)),
                  const SizedBox(width: 8),
                  _buildConsultStatCard('Total Revenue', '₹0', const Color(0xFF2563EB)),
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  _buildConsultStatCard("Today's Earnings", '₹0', const Color(0xFF15803D)),
                  const SizedBox(width: 12),
                  _buildConsultStatCard('This Week', '₹0', const Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  _buildConsultStatCard('This Month', '₹0', const Color(0xFF2563EB)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildConsultStatCard('Pending Payments', '₹0', const Color(0xFFD97706)),
                  const SizedBox(width: 12),
                  _buildConsultStatCard('Paid Payments', '₹0', const Color(0xFF15803D)),
                  const SizedBox(width: 12),
                  _buildConsultStatCard('Total Revenue', '₹0', const Color(0xFF2563EB)),
                ],
              ),
            ],
          ),

        const SizedBox(height: 20),

        // Billing History & Latest Unbilled Audit Session Cards Row
        if (isMobile)
          Column(
            children: [
              _buildProfessionalBillingHistoryCard(),
              const SizedBox(height: 16),
              _buildUnbilledAuditSessionCard(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildProfessionalBillingHistoryCard()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildUnbilledAuditSessionCard()),
            ],
          ),
      ],
    );
  }

  Widget _buildConsultStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalBillingHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.scrollText, color: Color(0xFF166534), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Professional Billing History',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTH('Invoice #'),
                      _buildTH('Client'),
                      _buildTH('Audit Description'),
                      _buildTH('Duration'),
                      _buildTH('Amount'),
                      _buildTH('Status'),
                      _buildTH('Action'),
                    ],
                  ),
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No billing records found',
                      style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTH(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
    );
  }

  Widget _buildUnbilledAuditSessionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF93C5FD).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(LucideIcons.timer, color: Color(0xFF2563EB), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Latest Unbilled Audit Session',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Awaiting Invoice', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(LucideIcons.clock, size: 32, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text(
                  'All sessions have been billed.',
                  style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAdvisoryReportsTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📊 Filing Compliance & Master Sheets', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.fileSpreadsheet, size: 14),
                label: const Text('Compile Master Audit Sheet', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('📊 Filing Compliance & Master Sheets', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.fileSpreadsheet, size: 14),
                label: const Text('Compile Master Audit Sheet', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),

        // Table Container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTH('CLIENT TAXPAYER ⚙'),
                    _buildTH('FILING FORM TYPE ⚙'),
                    _buildTH('ASSESSMENT YEAR ⚙'),
                    _buildTH('FILING SEASON STATUS ⚙'),
                    _buildTH('EXEMPTION STATUS ⚙'),
                  ],
                ),
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Text(
                    'No practice clients registered in workspace database.',
                    style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvisorySeniorCATab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Senior CA Executive Desk Header Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.userCheck, color: Color(0xFF15803D), size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🛡️ Senior CA Executive Advisory Desk',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Senior Audit Leadership, Quality Review & Executive Compliance Sign-off',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.checkCircle2, size: 12, color: Color(0xFF15803D)),
                        SizedBox(width: 4),
                        Text(
                          'Senior CA Active Clearance',
                          style: TextStyle(color: Color(0xFF15803D), fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3 Stat Cards Row
              if (isMobile)
                Column(
                  children: [
                    _buildSeniorCACard('HIGH RISK AUDITS', '0 Active', 'All clear & verified', const Color(0xFF15803D)),
                    const SizedBox(height: 10),
                    _buildSeniorCACard('QUALITY SIGN-OFFS', '100% Passed', 'Compliance standard met', const Color(0xFF15803D)),
                    const SizedBox(height: 10),
                    _buildSeniorCACard('SENIOR CONSULTANT DESK', 'Ready', 'Live advisory session active', const Color(0xFF2563EB)),
                  ],
                )
              else
                Row(
                  children: [
                    _buildSeniorCACard('HIGH RISK AUDITS', '0 Active', 'All clear & verified', const Color(0xFF15803D)),
                    const SizedBox(width: 12),
                    _buildSeniorCACard('QUALITY SIGN-OFFS', '100% Passed', 'Compliance standard met', const Color(0xFF15803D)),
                    const SizedBox(width: 12),
                    _buildSeniorCACard('SENIOR CONSULTANT DESK', 'Ready', 'Live advisory session active', const Color(0xFF2563EB)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeniorCACard(String label, String value, String subtitle, Color subColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: subColor),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: subColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(String name, String ref, String status, String phone) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
            child: const Icon(LucideIcons.building, color: Color(0xFF15803D), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Ref: $ref • Ph: $phone', style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String task, String due, String status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.checkSquare, color: Color(0xFF166534), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(due, style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(String name, String role, String email) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFDCFCE7),
            child: Text(name.substring(0, 1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('$role • $email', style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
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
