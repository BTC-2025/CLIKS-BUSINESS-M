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
  final int _activeWorkplace = 1; // 1: FIN-PRO Firm
  int _activeAdvisoryTab = 6; // 0: Home, 1: Clients, 2: Tasks, 3: Teams, 4: Time Tracking, 5: Workpaper, 6: Auditor Suite, 7: consult, 8: Reports, 9: Senior CA
  int _selectedAuditorIndex = 1; // 0: Statutory, 1: Tax, 2: Internal, 3: Cost, 4: Secretarial, 5: Forensic
  int _activeSubTab = 0; // Sub-tab index
  bool _showTeamRequests = false;
  bool _aruntestRemoved = false;
  final TextEditingController _emailController = TextEditingController();

  final List<String> _auditorRoles = [
    'Statutory Financial Auditor (ICAI CA)',
    'Tax Auditor (ICAI CA)',
    'Internal Auditor (CIA / CA / CMA)',
    'Cost Auditor (ICMAI CMA)',
    'Secretarial Auditor (ICSI CS)',
    'Forensic Auditor (ICAI FAFD / CFE)',
  ];

  late final List<_TabItem> _advisoryTabs = [
    _TabItem('Home', LucideIcons.home),
    _TabItem('Clients', LucideIcons.users),
    _TabItem('Tasks', LucideIcons.checkSquare),
    _TabItem('Teams', LucideIcons.userCheck),
    _TabItem('Time Tracking', LucideIcons.clock),
    _TabItem('Workpaper', LucideIcons.fileText),
    _TabItem('Tax Auditor', LucideIcons.briefcase),
    _TabItem('consult', LucideIcons.wallet),
    _TabItem('Reports', LucideIcons.barChart2),
    _TabItem('Senior CA', LucideIcons.userCheck),
  ];

  void _selectAuditorRole(int index) {
    setState(() {
      _selectedAuditorIndex = index;
      _activeAdvisoryTab = 6;
      _activeSubTab = 0;
      final roleNames = [
        'Statutory Financial Auditor',
        'Tax Auditor',
        'Internal Auditor',
        'Cost Auditor',
        'Secretarial Auditor',
        'Forensic Auditor',
      ];
      _advisoryTabs[6] = _TabItem(roleNames[index], LucideIcons.briefcase);
    });
  }

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
    const isFirmWorkplace = true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── CARD 1: TOP AUDITOR ROLE CARDS & ICAI VERIFICATION ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 14 : 24,
                isMobile ? 12 : 16,
                isMobile ? 14 : 24,
                0,
              ),
              child: _buildTopAuditorCard(isMobile),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 12),
          ),

          // ─── CARD 2: TOP ADVISORY TABS CARD (EXACT TO REFERENCE IMAGES) ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 14 : 24,
                0,
                isMobile ? 14 : 24,
                0,
              ),
              child: _buildAdvisoryTabsBar(isMobile),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // ─── MAIN CONTENT AREA ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 80 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: isMacOS
                  ? _buildMainContent(isMobile, isFirmWorkplace)
                  : _buildMainContent(isMobile, isFirmWorkplace)
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
  Widget _buildHeroSummary(bool isMobile, bool isMacOS) {
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

          // FIN-PRO Firm Advisory Workspace Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.userCheck, color: Colors.white, size: 14),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'FIN-PRO Firm Advisory Workspace',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 11.5 : 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
  // TOP AUDITOR ROLE CARDS & ICAI VERIFICATION (macOS)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopAuditorCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _showVerifyIcaDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF166534), width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.shieldCheck, size: 14, color: Color(0xFF166534)),
                    SizedBox(width: 6),
                    Text(
                      'VERIFY ICAI',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_auditorRoles.length, (index) {
                final isSelected = _selectedAuditorIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => _selectAuditorRole(index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF166534) : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF166534) : const Color(0xFF9CA3AF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _auditorRoles[index],
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF166534) : const Color(0xFF4B5563),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: isMobile ? 11.5 : 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerifyIcaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF15803D), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ICAI Member Verification Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Institute of Chartered Accountants of India', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Practicing CA:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      Text('CA Ravindran K. (FCA)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Membership No:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      Text('084291 (Active COP)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Firm Reg No (FRN):', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      Text('009182S / 2026', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('UDIN Service:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      Text('LIVE & Connected ✓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATUTORY FINANCIAL AUDIT SUITE CARD (EXACT TO IMAGES)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAuditorSuiteTab(bool isMobile) {
    final subTabs = _getSuiteSubTabs();
    final isTaxAudit = _selectedAuditorIndex == 1;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suite Header & Core Deliverable
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isTaxAudit ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isTaxAudit ? const Color(0xFFFDE68A) : const Color(0xFFDBEAFE)),
                ),
                child: Icon(
                  LucideIcons.fileText,
                  color: isTaxAudit ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _getSuiteTitle(),
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isTaxAudit ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isTaxAudit ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            _getSuiteBadge(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isTaxAudit ? const Color(0xFFB45309) : const Color(0xFF1D4ED8),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getSuiteSubtitle(),
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Deliverable Box (full-featured pill on its own line)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📦 ', style: TextStyle(fontSize: 13)),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Core Deliverable: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                            color: Color(0xFF374151),
                          ),
                        ),
                        TextSpan(
                          text: _getCoreDeliverableText(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sub-Tabs Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(subTabs.length, (index) {
                final activeSub = _activeSubTab >= subTabs.length ? 0 : _activeSubTab;
                final isSubSelected = activeSub == index;

                Color activeBorderColor;
                Color activeTextColor;
                if (isTaxAudit) {
                  if (index == 0) {
                    activeBorderColor = const Color(0xFFD97706);
                    activeTextColor = const Color(0xFFD97706);
                  } else if (index == 1 || index == 2) {
                    activeBorderColor = const Color(0xFF2563EB);
                    activeTextColor = const Color(0xFF2563EB);
                  } else if (index == 3) {
                    activeBorderColor = const Color(0xFFD97706);
                    activeTextColor = const Color(0xFFD97706);
                  } else {
                    activeBorderColor = const Color(0xFF2563EB);
                    activeTextColor = const Color(0xFFD97706);
                  }
                } else {
                  activeBorderColor = const Color(0xFF2563EB);
                  activeTextColor = const Color(0xFF2563EB);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => setState(() => _activeSubTab = index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSubSelected ? activeBorderColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        subTabs[index],
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: isSubSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSubSelected ? activeTextColor : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Active Sub-Tab View
          Builder(
            builder: (context) {
              final activeSub = _activeSubTab >= subTabs.length ? 0 : _activeSubTab;
              if (_selectedAuditorIndex == 0) {
                if (activeSub == 0) return _buildRule11gVault(isMobile);
                if (activeSub == 1) return _buildSmartVouching(isMobile);
                if (activeSub == 2) return _buildFixedAssetDepreciation(isMobile);
                if (activeSub == 3) return _buildDirectBankBRS(isMobile);
              } else if (_selectedAuditorIndex == 1) {
                if (activeSub == 0) return _buildTaxCashPaymentWatchdog(isMobile);
                if (activeSub == 1) return _buildTaxTdsTcsHub(isMobile);
                if (activeSub == 2) return _buildTaxClause44ExpenseBreakdown(isMobile);
                if (activeSub == 3) return _buildTaxMsmePaymentTracker(isMobile);
                if (activeSub == 4) return _buildTaxStatutoryDuesClock(isMobile);
              }
              return _buildGeneralAuditorSuiteContent(isMobile);
            },
          ),
        ],
      ),
    );
  }

  // ─── SUB-TAB 0: RULE 11(g) VAULT & CERTIFICATE (IMAGE 1 & 5) ───
  Widget _buildRule11gVault(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('🛡️', style: TextStyle(fontSize: 15)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Immutable Rule 11(g) Audit-Log Vault & Certificate',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Append-only, tamper-evident datastore logging all voucher creations, modifications, and deletions with field-level diffs.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Downloading Rule 11(g) Audit Trail Certificate PDF...'),
                      backgroundColor: Color(0xFF1D4ED8),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.download, size: 14, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        '1-Click Rule 11(g) Report (.PDF)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Monospaced Console Log Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[SYSTEM STATUS] Rule 11(g) Audit Logging: ACTIVE & IMMUTABLE (Zero Downtime / Zero Tampering)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: Color(0xFF15803D),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '• 2026-09-09 14:22:01 | User: accounts@bnxmail.com | Table: vouchers | Action: UPDATE | Field: amount | old: ₹45,000 → new: ₹50,000\n'
                  '• 2026-09-09 11:15:40 | User: admin@bnxmail.com | Table: ledger_entries | Action: CREATE | Record ID: #8912 | Status: Verified\n'
                  '• 2026-09-08 17:04:12 | User: audit_user@bnxmail.com | Table: invoices | Action: DELETE (Soft) | Record ID: #4401 | Reason: Cancelled',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SUB-TAB 1: SMART VOUCHING & SAMPLER (IMAGE 2) ───
  Widget _buildSmartVouching(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.search, size: 16, color: Color(0xFF4B5563)),
                        SizedBox(width: 8),
                        Text(
                          'Smart Vouching & Materiality Sampler',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3-Way Match Verification (PO ↔ GRN ↔ Purchase Invoice) & Statistical Sampling Engine.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Text(
                      'Cutoff: > ₹50,000',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Text(
                      '3-Way Match Rate: 98.4%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text('PO Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                      Expanded(flex: 2, child: Text('GRN Ref', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                      Expanded(flex: 2, child: Text('Invoice Ref', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                      Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                      Expanded(flex: 3, child: Text('3-Way Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)))),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text('PO-8821', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D)))),
                      Expanded(flex: 2, child: Text('GRN-4012', style: TextStyle(fontSize: 12.5, color: Color(0xFF166534)))),
                      Expanded(flex: 2, child: Text('INV-9021', style: TextStyle(fontSize: 12.5, color: Color(0xFF374151)))),
                      Expanded(flex: 2, child: Text('₹1,25,000', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Icon(LucideIcons.check, size: 14, color: Color(0xFF15803D)),
                            SizedBox(width: 4),
                            Text('Matched (Qty & Rate)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text('PO-8840', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D)))),
                      Expanded(flex: 2, child: Text('GRN-4029', style: TextStyle(fontSize: 12.5, color: Color(0xFF166534)))),
                      Expanded(flex: 2, child: Text('INV-9055', style: TextStyle(fontSize: 12.5, color: Color(0xFF374151)))),
                      Expanded(flex: 2, child: Text('₹68,000', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Icon(LucideIcons.triangleAlert, size: 14, color: Color(0xFFDC2626)),
                            SizedBox(width: 4),
                            Text('Rate Discrepancy (2.5% spike)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                          ],
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

  // ─── SUB-TAB 2: FIXED ASSET & DEPRECIATION (IMAGE 3) ───
  Widget _buildFixedAssetDepreciation(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('📓', style: TextStyle(fontSize: 15)),
                  SizedBox(width: 8),
                  Text(
                    'Fixed Asset & Depreciation Engine',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Auto-computes Companies Act 2013 Sched II (Useful life) vs Income Tax Act (Block of assets).',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (isMobile)
            Column(
              children: [
                _buildDepreciationMetricCard(
                  'COMPANIES ACT SCHED II (SLM/WDV)',
                  '₹1,42,000',
                  const Color(0xFF2563EB),
                ),
                const SizedBox(height: 12),
                _buildDepreciationMetricCard(
                  'INCOME TAX ACT (BLOCK OF ASSETS)',
                  '₹1,68,500',
                  const Color(0xFF15803D),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildDepreciationMetricCard(
                    'COMPANIES ACT SCHED II (SLM/WDV)',
                    '₹1,42,000',
                    const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDepreciationMetricCard(
                    'INCOME TAX ACT (BLOCK OF ASSETS)',
                    '₹1,68,500',
                    const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDepreciationMetricCard(String title, String amount, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── SUB-TAB 3: DIRECT BANK BRS ENGINE (IMAGE 4) ───
  Widget _buildDirectBankBRS(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('🏛️', style: TextStyle(fontSize: 15)),
                  SizedBox(width: 8),
                  Text(
                    'Direct Bank Reconciliation (BRS) Engine',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Reconciles bank statement feeds against system ledgers with unpresented cheque tracking.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (isMobile)
            Column(
              children: [
                _buildBRSMetricCard('Unpresented Cheques', '₹1,24,000', const Color(0xFFD97706)),
                const SizedBox(height: 12),
                _buildBRSMetricCard('Uncleared Deposits', '₹85,000', const Color(0xFF2563EB)),
                const SizedBox(height: 12),
                _buildBRSMetricCard('Net BRS Discrepancy', '₹0.00 (Reconciled)', const Color(0xFF15803D)),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildBRSMetricCard('Unpresented Cheques', '₹1,24,000', const Color(0xFFD97706)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildBRSMetricCard('Uncleared Deposits', '₹85,000', const Color(0xFF2563EB)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildBRSMetricCard('Net BRS Discrepancy', '₹0.00 (Reconciled)', const Color(0xFF15803D)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBRSMetricCard(String title, String amount, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }



  // ═══════════════════════════════════════════════════════════════
  // TAX AUDIT & FORM 3CD HUB (5 SUB-TABS EXACT TO IMAGES)
  // ═══════════════════════════════════════════════════════════════

  // ─── TAX SUB-TAB 0: SEC 40A(3) CASH PAYMENT WATCHDOG (IMAGE 1) ───
  Widget _buildTaxCashPaymentWatchdog(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Watchdog Header Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Text('📕', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Text(
                          'Section 40A(3) Cash Payment Watchdog',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Flags aggregate daily cash payments to a single vendor subject to tax disallowance under Sec 40A(3).',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Text(
                  'Threshold: > ₹10,000 / Day / Party',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. Disallowed Alert Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Icon(LucideIcons.alertTriangle, color: Color(0xFFE11D48), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendor: Balaji Heavy Roadways',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: const [
                          TextSpan(
                            text: 'Date: 2026-08-18 | Total Cash: ',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                          ),
                          TextSpan(
                            text: '₹38,200',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFBE123C),
                            ),
                          ),
                          TextSpan(
                            text: ' across 1 vouchers (VCH-8411)',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DISALLOWED u/s 40A(3)',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBE123C),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 3. SEC 40A(3) AUDIT INSPECTION LEDGER Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'SEC 40A(3) AUDIT INSPECTION LEDGER',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF374151),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'FY 2025-2026 | Auto-aggregated by Date & Party',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: double.infinity,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                  dataTextStyle: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                  horizontalMargin: 16,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Payment\nDate')),
                    DataColumn(label: Text('Party / Vendor Name')),
                    DataColumn(label: Text('PAN')),
                    DataColumn(label: Text('Voucher Nos')),
                    DataColumn(label: Text('Total Cash\nPaid (₹)')),
                    DataColumn(label: Text('Statutory\nLimit')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: [
                    // Row 1: Sharma Logistics
                    DataRow(
                      cells: [
                        const DataCell(Text('2026-09-\n02', style: TextStyle(fontSize: 11.5))),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Sharma Logistics (Cash Payment)',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Note: Rule 6DD(g) - Payment made on bank holiday or\noffline rural banking unit',
                                  style: TextStyle(fontSize: 10.5, color: Color(0xFF047857)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const DataCell(Text('AABCS99\n12E', style: TextStyle(fontSize: 11.5))),
                        const DataCell(Text('VCH-9012,\nVCH-9015', style: TextStyle(fontSize: 11.5))),
                        const DataCell(Text('₹18,500', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('₹10,000')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(LucideIcons.check, size: 12, color: Color(0xFF047857)),
                                SizedBox(width: 4),
                                Text(
                                  'EXEMPT u/r\n6DD',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF10B981)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(LucideIcons.check, size: 12, color: Color(0xFF047857)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Exempted',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Remark',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF9CA3AF),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Row 2: Balaji Heavy Roadways
                    DataRow(
                      cells: [
                        const DataCell(Text('2026-08-\n18', style: TextStyle(fontSize: 11.5))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Balaji Heavy Roadways',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFDBEAFE)),
                                ),
                                child: const Text(
                                  'Transporter',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const DataCell(Text('AAHFB77\n14K', style: TextStyle(fontSize: 11.5))),
                        const DataCell(Text('VCH-8411')),
                        const DataCell(Text('₹38,200', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('₹35,000')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'DISALLOWED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFD1D5DB)),
                            ),
                            child: const Text(
                              'Exempt under Rule\n6DD',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Row 3: Shree Sai Packing Materials
                    DataRow(
                      cells: [
                        const DataCell(Text('2026-08-\n25', style: TextStyle(fontSize: 11.5))),
                        const DataCell(
                          Text(
                            'Shree Sai Packing Materials',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                        const DataCell(Text('AACSS44\n12L', style: TextStyle(fontSize: 11.5))),
                        const DataCell(Text('VCH-8650')),
                        const DataCell(Text('₹9,200', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('₹10,000')),
                        const DataCell(
                          Text(
                            'COMPLIANT',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFD1D5DB)),
                            ),
                            child: const Text(
                              'Exempt under Rule\n6DD',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Row 4: National Highway Transport Corp
                    DataRow(
                      cells: [
                        const DataCell(Text('2026-07-\n14', style: TextStyle(fontSize: 11.5))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'National Highway Transport Corp',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFDBEAFE)),
                                ),
                                child: const Text(
                                  'Transporter',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const DataCell(Text('AAACN22\n01P', style: TextStyle(fontSize: 11.5))),
                        const DataCell(Text('VCH-7910')),
                        const DataCell(Text('₹34,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('₹35,000')),
                        const DataCell(
                          Text(
                            'COMPLIANT',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFD1D5DB)),
                            ),
                            child: const Text(
                              'Exempt under Rule\n6DD',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
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
      ],
    );
  }

  // ─── TAX SUB-TAB 1: TDS/TCS HUB (CLAUSE 34) (IMAGE 2) ───
  Widget _buildTaxTdsTcsHub(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Status Chips and Export Button
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(LucideIcons.check, size: 13, color: Color(0xFF047857)),
                            SizedBox(width: 5),
                            Text(
                              'Sec 194C (Contractors) - ✓ Compliant',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(LucideIcons.check, size: 13, color: Color(0xFF047857)),
                            SizedBox(width: 5),
                            Text(
                              'Sec 194J (Professional) - ✓ Compliant',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(LucideIcons.alertTriangle, size: 13, color: Color(0xFFB45309)),
                            SizedBox(width: 5),
                            Text(
                              'Sec 194Q (Goods Purchase) - ⚠️ 1 Delay Deposit',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exporting Form 3CD Clause 34 (.XLSX)...'),
                          backgroundColor: Color(0xFF2563EB),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.fileSpreadsheet, size: 14, color: Colors.white),
                    label: const Text(
                      'Form 3CD Clause 34 - Ready to Export (.XLSX)',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(LucideIcons.check, size: 13, color: Color(0xFF047857)),
                              SizedBox(width: 5),
                              Text(
                                'Sec 194C (Contractors) - ✓ Compliant',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(LucideIcons.check, size: 13, color: Color(0xFF047857)),
                              SizedBox(width: 5),
                              Text(
                                'Sec 194J (Professional) - ✓ Compliant',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(LucideIcons.alertTriangle, size: 13, color: Color(0xFFB45309)),
                              SizedBox(width: 5),
                              Text(
                                'Sec 194Q (Goods Purchase) - ⚠️ 1 Delay Deposit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exporting Form 3CD Clause 34 (.XLSX)...'),
                          backgroundColor: Color(0xFF2563EB),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.fileSpreadsheet, size: 14, color: Colors.white),
                    label: const Text(
                      'Form 3CD Clause 34 - Ready to Export (.XLSX)',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),

        const SizedBox(height: 14),

        // 2. Statutory Disallowance Alert Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.shieldAlert, color: Color(0xFFE11D48), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: const [
                      TextSpan(
                        text: 'Statutory Disallowance Alert: ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFBE123C),
                        ),
                      ),
                      TextSpan(
                        text: 'Total 30% expenditure disallowed under Section 40(a)(ia) due to belated deposit: ',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFFBE123C)),
                      ),
                      TextSpan(
                        text: '₹10,20,000.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFBE123C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Text(
                  'Add back to P&L in 3CD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBE123C),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 3. FORM 3CD CLAUSE 34 MASTER SCHEDULE Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'FORM 3CD CLAUSE 34 MASTER SCHEDULE',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF374151),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Statutory Due Date: Strict 7th of Following Month',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: double.infinity,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                  dataTextStyle: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                  horizontalMargin: 16,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('TDS Section')),
                    DataColumn(label: Text('Total Amount\nPaid/Credited')),
                    DataColumn(label: Text('Total Base\nDeductible')),
                    DataColumn(label: Text('Actual TDS\nDeducted')),
                    DataColumn(label: Text('Challan / Deposit\nDate')),
                    DataColumn(label: Text('Statutory Due\nDate')),
                    DataColumn(label: Text('Delay (Days)')),
                    DataColumn(label: Text('Disallowance Flag (30% u/s\n40(a)(ia))')),
                  ],
                  rows: [
                    // Row 1: Sec 194C
                    DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Sec 194C', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              Text('Payments to Contractors & Sub-\nContractors', style: TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        const DataCell(Text('₹48,50,000')),
                        const DataCell(Text('₹48,50,000')),
                        const DataCell(Text('₹97,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('2026-08-05')),
                        const DataCell(Text('2026-08-07')),
                        const DataCell(Text('0 days (On-\nTime)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF047857), fontSize: 11.5))),
                        const DataCell(Text('₹0.00 (Nil)', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5))),
                      ],
                    ),
                    // Row 2: Sec 194J
                    DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Sec 194J', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              Text('Fees for Professional & Technical\nServices', style: TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        const DataCell(Text('₹16,20,000')),
                        const DataCell(Text('₹16,20,000')),
                        const DataCell(Text('₹1,62,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('2026-08-06')),
                        const DataCell(Text('2026-08-07')),
                        const DataCell(Text('0 days (On-\nTime)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF047857), fontSize: 11.5))),
                        const DataCell(Text('₹0.00 (Nil)', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5))),
                      ],
                    ),
                    // Row 3: Sec 194Q
                    DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Sec 194Q', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              Text('Purchase of Goods exceeding\n₹50 Lakhs', style: TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        const DataCell(Text('₹84,00,000')),
                        const DataCell(Text('₹34,00,000')),
                        const DataCell(Text('₹3,400', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('2026-08-19')),
                        const DataCell(Text('2026-08-07')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '+12 days',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '₹10,20,000 (30%)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBE123C)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Row 4: Sec 194I(a)
                    DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Sec 194I(a)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              Text('Rent of Plant, Machinery &\nEquipment', style: TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        const DataCell(Text('₹7,50,000')),
                        const DataCell(Text('₹7,50,000')),
                        const DataCell(Text('₹15,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('2026-08-07')),
                        const DataCell(Text('2026-08-07')),
                        const DataCell(Text('0 days (On-\nTime)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF047857), fontSize: 11.5))),
                        const DataCell(Text('₹0.00 (Nil)', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5))),
                      ],
                    ),
                    // Row 5: Sec 194H
                    DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Sec 194H', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              Text('Commission or Brokerage', style: TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        const DataCell(Text('₹3,20,000')),
                        const DataCell(Text('₹3,20,000')),
                        const DataCell(Text('₹16,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('2026-08-04')),
                        const DataCell(Text('2026-08-07')),
                        const DataCell(Text('0 days (On-\nTime)', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF047857), fontSize: 11.5))),
                        const DataCell(Text('₹0.00 (Nil)', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5))),
                      ],
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

  // ─── TAX SUB-TAB 2: CLAUSE 44 EXPENSE BREAKDOWN (IMAGE 3) ───
  Widget _buildTaxClause44ExpenseBreakdown(bool isMobile) {
    Widget buildMetricCard({
      required String title,
      required String amount,
      required String subtitle,
      required Color indicatorColor,
      required Color amountColor,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 18,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4B5563),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Metric Cards Row
        Row(
          children: [
            buildMetricCard(
              title: 'GST EXEMPT SUPPLIES',
              amount: '₹4,20,000',
              subtitle: 'Nil-rated / Non-taxable',
              indicatorColor: const Color(0xFF10B981),
              amountColor: const Color(0xFF047857),
            ),
            const SizedBox(width: 12),
            buildMetricCard(
              title: 'COMPOSITION SCHEME',
              amount: '₹1,80,000',
              subtitle: 'Sec 10 Composition dealers',
              indicatorColor: const Color(0xFF3B82F6),
              amountColor: const Color(0xFF2563EB),
            ),
            const SizedBox(width: 12),
            buildMetricCard(
              title: 'REGISTERED ENTITIES',
              amount: '₹45,60,000',
              subtitle: 'Regular GST registered suppliers',
              indicatorColor: const Color(0xFF8B5CF6),
              amountColor: const Color(0xFF7C3AED),
            ),
            const SizedBox(width: 12),
            buildMetricCard(
              title: 'NON-REGISTERED ENTITIES',
              amount: '₹8,10,000',
              subtitle: 'Unregistered entities (URD)',
              indicatorColor: const Color(0xFFF59E0B),
              amountColor: const Color(0xFFD97706),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. FORM 3CD CLAUSE 44 OFFICIAL EXPENDITURE MATRIX Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'FORM 3CD CLAUSE 44 OFFICIAL EXPENDITURE MATRIX',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF374151),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Break-up of total expenditure in respect of entities registered under GST vs unregistered entities.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Exporting Clause 44 Excel for Form 3CD...'),
                            backgroundColor: Color(0xFF059669),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.downloadCloud, size: 14, color: Colors.white),
                      label: const Text(
                        'Export Clause 44 Excel for Form 3CD',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: double.infinity,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                  dataTextStyle: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                  horizontalMargin: 16,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('S\nl')),
                    DataColumn(label: Text('Expenditure Head (Col 1)')),
                    DataColumn(label: Text('Total Expenditure (Col\n2)')),
                    DataColumn(label: Text('Exempt (Col\n3)')),
                    DataColumn(label: Text('Composition (Col\n4)')),
                    DataColumn(label: Text('Other Registered (Col\n5)')),
                    DataColumn(label: Text('Total Registered (Col\n6)')),
                    DataColumn(label: Text('Non-Registered (Col\n7)')),
                  ],
                  rows: [
                    _buildClause44Row('1', 'Raw Materials & Consumables', '₹32,50,000', '₹1,50,000', '₹90,000', '₹26,00,000', '₹28,40,000', '₹4,10,000'),
                    _buildClause44Row('2', 'Freight, Cartage & Logistics', '₹8,40,000', '₹1,20,000', '₹0', '₹5,60,000', '₹6,80,000', '₹1,60,000'),
                    _buildClause44Row('3', 'Rent, Rates & Office Occupancy', '₹7,20,000', '₹0', '₹0', '₹6,40,000', '₹6,40,000', '₹80,000'),
                    _buildClause44Row('4', 'Legal & Professional Retainers', '₹4,60,000', '₹0', '₹45,000', '₹3,85,000', '₹4,30,000', '₹30,000'),
                    _buildClause44Row('5', 'Repairs & Machinery\nMaintenance', '₹3,80,000', '₹50,000', '₹45,000', '₹2,15,000', '₹3,10,000', '₹70,000'),
                    _buildClause44Row('6', 'Power, Fuel & Utilities', '₹3,20,000', '₹1,00,000', '₹0', '₹1,60,000', '₹2,60,000', '₹60,000'),
                    // Total Row
                    DataRow(
                      color: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                      cells: const [
                        DataCell(Text('')),
                        DataCell(
                          Text(
                            'TOTAL (FORM 3CD CLAUSE 44)',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                        DataCell(Text('₹59,70,000', style: TextStyle(fontWeight: FontWeight.w800))),
                        DataCell(Text('₹4,20,000', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF047857)))),
                        DataCell(Text('₹1,80,000', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB)))),
                        DataCell(Text('₹45,60,000', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)))),
                        DataCell(Text('₹51,60,000', style: TextStyle(fontWeight: FontWeight.w800))),
                        DataCell(Text('₹8,10,000', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD97706)))),
                      ],
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

  DataRow _buildClause44Row(
    String sl,
    String head,
    String total,
    String exempt,
    String composition,
    String otherReg,
    String totalReg,
    String nonReg,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(sl, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)))),
        DataCell(Text(head, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        DataCell(Text(total, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(exempt)),
        DataCell(Text(composition)),
        DataCell(Text(otherReg)),
        DataCell(Text(totalReg, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(nonReg)),
      ],
    );
  }

  // ─── TAX SUB-TAB 3: SEC 43B(h) MSME PAYMENT TRACKER (IMAGE 4) ───
  Widget _buildTaxMsmePaymentTracker(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Amber Banner Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.clock, color: Color(0xFFD97706), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Micro Vendor: Precision Tools Pvt Ltd | Invoice Date: 2026-08-01 (40 Days Elapsed) | Limit: 45 Days',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF78350F),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Payment must be settled within the statutory limit to avoid non-deductible tax disallowance under Section 43B(h).',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Text(
                  '[ 5 Days Remaining ]',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Table: MSMED ACT SEC 15 & INCOME TAX SEC 43B(H) AGING LEDGER
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'MSMED ACT SEC 15 & INCOME TAX SEC 43B(H) AGING LEDGER',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF374151),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Statutory Rule: Default 15 days without agreement / Maximum 45 days with written agreement.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Exporting Section 43B(h) Disallowance Schedule...'),
                            backgroundColor: Color(0xFFD97706),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.downloadCloud, size: 14, color: Colors.white),
                      label: const Text(
                        'Export Section 43B(h) Disallowance Schedule',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: double.infinity,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                  dataTextStyle: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                  horizontalMargin: 16,
                  columnSpacing: 22,
                  columns: const [
                    DataColumn(label: Text('Vendor Name')),
                    DataColumn(label: Text('MSME\nCategory')),
                    DataColumn(label: Text('Udyam Reg No')),
                    DataColumn(label: Text('Invoice No &\nDate')),
                    DataColumn(label: Text('Bill Amount\n(₹)')),
                    DataColumn(label: Text('Balance Due\n(₹)')),
                    DataColumn(label: Text('Statutory\nLimit')),
                    DataColumn(label: Text('Days\nElapsed')),
                    DataColumn(label: Text('Days\nRemaining')),
                    DataColumn(label: Text('Risk Status')),
                  ],
                  rows: [
                    // Row 1: Precision Tools Pvt Ltd
                    DataRow(
                      cells: [
                        const DataCell(Text('Precision Tools Pvt Ltd', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataCell(_buildMsmeCategoryBadge('Micro')),
                        const DataCell(Text('UDYAM-MH-03-\n0044912', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('INV-2026-PT-\n881\n2026-08-01', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('₹3,45,000')),
                        const DataCell(Text('₹3,45,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('45 Days')),
                        const DataCell(Text('40', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('5d', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)))),
                        DataCell(_buildMsmeRiskBadge('CRITICAL_DUE')),
                      ],
                    ),
                    // Row 2: Apex Micro Stampings
                    DataRow(
                      cells: [
                        const DataCell(Text('Apex Micro Stampings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataCell(_buildMsmeCategoryBadge('Micro')),
                        const DataCell(Text('UDYAM-TN-02-\n0019283', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('AMS-9022\n2026-07-15', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('₹1,88,000')),
                        const DataCell(Text('₹1,88,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('45 Days')),
                        const DataCell(Text('57', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('-12d\n(Overdue)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontSize: 11))),
                        DataCell(_buildMsmeRiskBadge('DISALLOWED_43BH')),
                      ],
                    ),
                    // Row 3: Kaveri Paper Converters
                    DataRow(
                      cells: [
                        const DataCell(Text('Kaveri Paper Converters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataCell(_buildMsmeCategoryBadge('Small')),
                        const DataCell(Text('UDYAM-KR-08-\n0051142', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('KPC-1140\n2026-08-28', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('₹5,20,000')),
                        const DataCell(Text('₹5,20,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('15 Days')),
                        const DataCell(Text('13', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('2d', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)))),
                        DataCell(_buildMsmeRiskBadge('CRITICAL_DUE')),
                      ],
                    ),
                    // Row 4: Supreme Electro-Tech Controls
                    DataRow(
                      cells: [
                        const DataCell(Text('Supreme Electro-Tech\nControls', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataCell(_buildMsmeCategoryBadge('Small')),
                        const DataCell(Text('UDYAM-GJ-01-\n0078129', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('SETC-4091\n2026-08-20', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('₹2,90,000')),
                        const DataCell(Text('₹0', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('45 Days')),
                        const DataCell(Text('21', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('24d', style: TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(_buildMsmeRiskBadge('COMPLIANT')),
                      ],
                    ),
                    // Row 5: Shilpa Industrial Fasteners
                    DataRow(
                      cells: [
                        const DataCell(Text('Shilpa Industrial\nFasteners', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                        DataCell(_buildMsmeCategoryBadge('Micro')),
                        const DataCell(Text('UDYAM-DL-05-\n0033190', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('SIF-6712\n2026-09-01', style: TextStyle(fontSize: 11))),
                        const DataCell(Text('₹1,42,000')),
                        const DataCell(Text('₹1,42,000', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('45 Days')),
                        const DataCell(Text('9', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('36d', style: TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(_buildMsmeRiskBadge('COMPLIANT')),
                      ],
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

  Widget _buildMsmeCategoryBadge(String cat) {
    final isMicro = cat == 'Micro';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMicro ? const Color(0xFFEFF6FF) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isMicro ? const Color(0xFFBFDBFE) : const Color(0xFFC7D2FE)),
      ),
      child: Text(
        cat,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: isMicro ? const Color(0xFF2563EB) : const Color(0xFF4F46E5),
        ),
      ),
    );
  }

  Widget _buildMsmeRiskBadge(String status) {
    Color bg;
    Color text;
    Color border;

    if (status == 'CRITICAL_DUE') {
      bg = const Color(0xFFFEF3C7);
      border = const Color(0xFFFDE68A);
      text = const Color(0xFFB45309);
    } else if (status == 'DISALLOWED_43BH') {
      bg = const Color(0xFFFEE2E2);
      border = const Color(0xFFFECACA);
      text = const Color(0xFFBE123C);
    } else {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFFA7F3D0);
      text = const Color(0xFF047857);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: text),
      ),
    );
  }

  // ─── TAX SUB-TAB 4: STATUTORY DUES CLOCK (PF/ESI) (IMAGE 5) ───
  Widget _buildTaxStatutoryDuesClock(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Header Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text('⏰', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Text(
                          'Statutory Dues Clock (Clause 20(b) of Form 3CD)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Strict 15th-of-next-month statutory clock for EPF and ESIC contributions under Section 36(1)(va) and Section 43B.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(LucideIcons.alertTriangle, size: 13, color: Color(0xFFE11D48)),
                              SizedBox(width: 5),
                              Text(
                                'Late Deposit Observed',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Exporting Form 3CD Clause 20(b) Format...'),
                                backgroundColor: Color(0xFF0F172A),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.downloadCloud, size: 14, color: Colors.white),
                          label: const Text(
                            'Export Form 3CD Clause 20(b) Format',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Text('⏰', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 8),
                              Text(
                                'Statutory Dues Clock (Clause 20(b) of Form 3CD)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Strict 15th-of-next-month statutory clock for EPF and ESIC contributions under Section 36(1)(va) and Section 43B.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(LucideIcons.alertTriangle, size: 13, color: Color(0xFFE11D48)),
                              SizedBox(width: 5),
                              Text(
                                'Late Deposit Observed',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Exporting Form 3CD Clause 20(b) Format...'),
                                backgroundColor: Color(0xFF0F172A),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.downloadCloud, size: 14, color: Colors.white),
                          label: const Text(
                            'Export Form 3CD Clause 20(b) Format',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 14),

        // 2. Disallowance Alert Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.shieldAlert, color: Color(0xFFE11D48), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: const [
                      TextSpan(
                        text: 'Permanent Disallowance u/s 36(1)(va): ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFBE123C),
                        ),
                      ),
                      TextSpan(
                        text: 'Total employee PF/ESI contributions delayed past the 15th statutory due date cannot be claimed: ',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFFBE123C)),
                      ),
                      TextSpan(
                        text: '₹31,800',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFBE123C),
                        ),
                      ),
                      TextSpan(
                        text: ' (SC Judgment in ',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFFBE123C)),
                      ),
                      TextSpan(
                        text: 'Checkmate Services P. Ltd.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFBE123C),
                        ),
                      ),
                      TextSpan(
                        text: ').',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFFBE123C)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 3. CLAUSE 20(B) MONTHLY STATUTORY DUES GRID Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'CLAUSE 20(B) MONTHLY STATUTORY DUES GRID',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF374151),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'EPF (12% + 12%) | ESIC (0.75% + 3.25%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: double.infinity,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                  headingTextStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                  dataTextStyle: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                  horizontalMargin: 16,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Month /\nPeriod')),
                    DataColumn(label: Text('Fund Nature')),
                    DataColumn(label: Text('Employee\nContribution (₹)')),
                    DataColumn(label: Text('Employer\nShare (₹)')),
                    DataColumn(label: Text('Statutory Due\nDate')),
                    DataColumn(label: Text('Actual Deposit\nDate')),
                    DataColumn(label: Text('Challan / TRRN\nRef')),
                    DataColumn(label: Text('Delay (Days)')),
                    DataColumn(label: Text('Disallowed u/s\n36(1)(va)')),
                  ],
                  rows: [
                    // Row 1: August 2026 EPF
                    _buildStatutoryDuesRow(
                      month: 'August\n2026',
                      fundName: 'EPF (Employees Provident\nFund)',
                      isEpf: true,
                      empContr: '₹1,45,000',
                      emprShare: '₹1,45,000',
                      dueDate: '2026-09-15',
                      actualDate: '2026-09-10',
                      ref: 'TRRN-8821901',
                      delay: '0 days (On-\nTime)',
                      isDelay: false,
                      disallowed: '₹0.00 (Nil)',
                      isDisallowed: false,
                    ),
                    // Row 2: August 2026 ESIC
                    _buildStatutoryDuesRow(
                      month: 'August\n2026',
                      fundName: 'ESIC (Employees State\nInsurance)',
                      isEpf: false,
                      empContr: '₹32,400',
                      emprShare: '₹1,39,800',
                      dueDate: '2026-09-15',
                      actualDate: '2026-09-11',
                      ref: 'ESIC-7740192',
                      delay: '0 days (On-\nTime)',
                      isDelay: false,
                      disallowed: '₹0.00 (Nil)',
                      isDisallowed: false,
                    ),
                    // Row 3: July 2026 EPF
                    _buildStatutoryDuesRow(
                      month: 'July 2026',
                      fundName: 'EPF (Employees Provident\nFund)',
                      isEpf: true,
                      empContr: '₹1,42,000',
                      emprShare: '₹1,42,000',
                      dueDate: '2026-08-15',
                      actualDate: '2026-08-14',
                      ref: 'TRRN-7719402',
                      delay: '0 days (On-\nTime)',
                      isDelay: false,
                      disallowed: '₹0.00 (Nil)',
                      isDisallowed: false,
                    ),
                    // Row 4: July 2026 ESIC (Delayed!)
                    _buildStatutoryDuesRow(
                      month: 'July 2026',
                      fundName: 'ESIC (Employees State\nInsurance)',
                      isEpf: false,
                      empContr: '₹31,800',
                      emprShare: '₹1,37,200',
                      dueDate: '2026-08-15',
                      actualDate: '2026-08-19',
                      ref: 'ESIC-6630129',
                      delay: '+4 days',
                      isDelay: true,
                      disallowed: '₹31,800',
                      isDisallowed: true,
                    ),
                    // Row 5: June 2026 EPF
                    _buildStatutoryDuesRow(
                      month: 'June 2026',
                      fundName: 'EPF (Employees Provident\nFund)',
                      isEpf: true,
                      empContr: '₹1,38,000',
                      emprShare: '₹1,38,000',
                      dueDate: '2026-07-15',
                      actualDate: '2026-07-12',
                      ref: 'TRRN-6629103',
                      delay: '0 days (On-\nTime)',
                      isDelay: false,
                      disallowed: '₹0.00 (Nil)',
                      isDisallowed: false,
                    ),
                    // Row 6: June 2026 ESIC
                    _buildStatutoryDuesRow(
                      month: 'June 2026',
                      fundName: 'ESIC (Employees State\nInsurance)',
                      isEpf: false,
                      empContr: '₹30,500',
                      emprShare: '₹1,31,500',
                      dueDate: '2026-07-15',
                      actualDate: '2026-07-13',
                      ref: 'ESIC-5510291',
                      delay: '0 days (On-\nTime)',
                      isDelay: false,
                      disallowed: '₹0.00 (Nil)',
                      isDisallowed: false,
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

  DataRow _buildStatutoryDuesRow({
    required String month,
    required String fundName,
    required bool isEpf,
    required String empContr,
    required String emprShare,
    required String dueDate,
    required String actualDate,
    required String ref,
    required String delay,
    required bool isDelay,
    required String disallowed,
    required bool isDisallowed,
  }) {
    return DataRow(
      cells: [
        DataCell(Text(month, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEpf ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isEpf ? const Color(0xFFDBEAFE) : const Color(0xFFA7F3D0)),
            ),
            child: Text(
              fundName,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isEpf ? const Color(0xFF2563EB) : const Color(0xFF047857),
              ),
            ),
          ),
        ),
        DataCell(Text(empContr)),
        DataCell(Text(emprShare)),
        DataCell(Text(dueDate, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(actualDate)),
        DataCell(Text(ref, style: const TextStyle(fontSize: 11.5))),
        DataCell(
          isDelay
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    delay,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBE123C)),
                  ),
                )
              : Text(
                  delay,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF047857), fontSize: 11.5),
                ),
        ),
        DataCell(
          isDisallowed
              ? Text(disallowed, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBE123C)))
              : Text(disallowed, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5)),
        ),
      ],
    );
  }

  // ─── GENERAL SUITE CONTENT FOR OTHER AUDITOR ROLES ───
  Widget _buildGeneralAuditorSuiteContent(bool isMobile) {
    final subTabs = _getSuiteSubTabs();
    final currentSubTab = _activeSubTab < subTabs.length ? subTabs[_activeSubTab] : subTabs[0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
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
                    Row(
                      children: [
                        const Icon(LucideIcons.clipboardCheck, size: 16, color: Color(0xFF166534)),
                        const SizedBox(width: 8),
                        Text(
                          currentSubTab,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automated compliance, verification checks and working papers for ${_auditorRoles[_selectedAuditorIndex]}.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generating $currentSubTab Report...'),
                      backgroundColor: const Color(0xFF166534),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF166534),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.download, size: 14, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        '1-Click Export (.PDF)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STATUS: COMPLIANT & READY FOR SIGNING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('UDIN COMPLIANT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Verified data feeds from company trial balance and statutory ledgers.\n'
                  '• Checklists updated to the latest Ministry of Corporate Affairs (MCA) and technical standards.\n'
                  '• Ready for peer review packaging and partner digital certificate attachment.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SUITE METADATA HELPERS ───
  String _getSuiteTitle() {
    switch (_selectedAuditorIndex) {
      case 0:
        return 'Statutory Financial Audit Suite';
      case 1:
        return 'Tax Audit & Form 3CD Hub';
      case 2:
        return 'Internal Audit & Controls Suite';
      case 3:
        return 'Cost Audit & Compliance Suite';
      case 4:
        return 'Secretarial Audit & Governance Suite';
      case 5:
        return 'Forensic Audit & Fraud Investigation Suite';
      default:
        return 'Statutory Financial Audit Suite';
    }
  }

  String _getSuiteBadge() {
    switch (_selectedAuditorIndex) {
      case 0:
        return 'ICAI CA STANDARD';
      case 1:
        return 'SEC 44AB TAX AUDIT';
      case 2:
        return 'CIA / CA / CMA STANDARD';
      case 3:
        return 'ICMAI CMA STANDARD';
      case 4:
        return 'ICSI CS STANDARD';
      case 5:
        return 'ICAI FAFD / CFE STANDARD';
      default:
        return 'ICAI CA STANDARD';
    }
  }

  String _getSuiteSubtitle() {
    switch (_selectedAuditorIndex) {
      case 0:
        return "Prove a 'true and fair view' under Section 143 of the Companies Act and Indian Accounting Standards (Ind AS).";
      case 1:
        return 'Verify compliance under Section 44AB and auto-populate Form 3CD.';
      case 2:
        return 'Operational risk management, IFC (Internal Financial Controls) and COSO framework matrix.';
      case 3:
        return 'Statutory cost compliance under Section 148 of Companies Act 2013 and CRA Rules.';
      case 4:
        return 'Corporate governance audit under Section 204 of the Companies Act 2013 and SEBI LODR Regulations.';
      case 5:
        return "Digital forensics, Benford's Law distribution analysis, and fund diversion tracking under IBC & EOW norms.";
      default:
        return "Prove a 'true and fair view' under Section 143 of the Companies Act and Indian Accounting Standards (Ind AS).";
    }
  }

  String _getCoreDeliverableText() {
    switch (_selectedAuditorIndex) {
      case 0:
        return 'Rule 11(g) Audit Trail Certificate & SA 230 Working Paper Bundle';
      case 1:
        return '1-Click Form 3CD Data Extractor (Clauses 21, 34, 44, Sec 43B(h))';
      case 2:
        return 'Internal Financial Controls (IFC) Report & Risk-Control Matrix (RCM)';
      case 3:
        return 'Form CRA-1 to CRA-4 Cost Audit Report & XBRL Package';
      case 4:
        return 'Form MR-3 Secretarial Audit Report & Annual Secretarial Compliance Report';
      case 5:
        return 'Forensic Audit Investigation Report & Money Trail Evidentiary Pack';
      default:
        return 'Rule 11(g) Audit Trail Certificate & SA 230 Working Paper Bundle';
    }
  }

  List<String> _getSuiteSubTabs() {
    switch (_selectedAuditorIndex) {
      case 0:
        return [
          'Rule 11(g) Vault & Certificate',
          'Smart Vouching & Sampler',
          'Fixed Asset & Depreciation',
          'Direct Bank BRS Engine',
        ];
      case 1:
        return [
          'Sec 40A(3) Cash Payment Watchdog',
          'TDS/TCS Hub (Clause 34)',
          'Clause 44 Expense Breakdown',
          'Sec 43B(h) MSME Payment Tracker',
          'Statutory Dues Clock (PF/ESI)',
        ];
      case 2:
        return [
          'Risk Control Matrix (RCM)',
          'Entity Level Controls (ELC)',
          'Process Walkthroughs',
          'Testing of Operating Effectiveness',
          'Audit Committee Summary',
        ];
      case 3:
        return [
          'CRA-1 Cost Records',
          'CRA-2 Form & Filing',
          'CRA-3 Cost Audit Report',
          'CRA-4 Annexures & Reconciliation',
          'Capacity & Ratio Engine',
        ];
      case 4:
        return [
          'Form MR-3 Compliance',
          'Board & Committee Meetings',
          'MCA Statutory Registers',
          'SEBI LODR Checklists',
          'Secretarial Working Papers',
        ];
      case 5:
        return [
          "Benford's Law Fraud Engine",
          'Red Flag Transaction Scanner',
          'Related Party Fund Siphoning',
          'Journal Entry (JE) Testing',
          'Evidentiary Dossier',
        ];
      default:
        return [
          'Rule 11(g) Vault & Certificate',
          'Smart Vouching & Sampler',
          'Fixed Asset & Depreciation',
          'Direct Bank BRS Engine',
        ];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ADVISORY CHOICE TABS (Accounting Style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAdvisoryTabsBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_advisoryTabs.length, (index) {
            final isSelected = _activeAdvisoryTab == index;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () => setState(() {
                  _activeAdvisoryTab = index;
                  _showTeamRequests = false;
                }),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF166534) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _advisoryTabs[index].icon,
                        size: isMobile ? 13 : 15,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _advisoryTabs[index].label,
                        style: TextStyle(
                          fontSize: isMobile ? 11.5 : 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAIN CONTENT ROUTER WITH ACCOUNTING STYLE CARD CONTAINER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile, bool isFirmWorkplace) {
    if (!isFirmWorkplace) {
      // FIN-PRO Business View (macOS only)
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
    if (_activeAdvisoryTab == 6) {
      return _buildAuditorSuiteTab(isMobile);
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
        return _buildAuditorSuiteTab(isMobile);
      case 7:
        return _buildAdvisoryConsultTab(isMobile);
      case 8:
        return _buildAdvisoryReportsTab(isMobile);
      case 9:
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => showDialog(context: context, builder: (_) => const AssignTaskDialog()),
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Assign Task', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
    if (_showTeamRequests) {
      return _buildTeamRequestsView(isMobile);
    }
    return _buildTeamMembersTableView(isMobile);
  }

  Widget _buildTeamRequestsView(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar with Back to Teams button + Title matching Image 2
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showTeamRequests = false;
                  });
                },
                icon: const Icon(LucideIcons.arrowLeft, size: 13, color: Color(0xFF334155)),
                label: const Text(
                  'Back to Teams',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Text('✉️ ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Team Invitations & Requests',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Approve join requests or track pending invitations.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showTeamRequests = false;
                  });
                },
                icon: const Icon(LucideIcons.arrowLeft, size: 14, color: Color(0xFF334155)),
                label: const Text(
                  'Back to Teams',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('✉️ ', style: TextStyle(fontSize: 16)),
                      Text(
                        'Team Invitations & Requests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Approve join requests or track pending invitations.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),

        const SizedBox(height: 18),

        // Empty state card matching Image 2
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Icon(
                  LucideIcons.userCheck,
                  size: 24,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Pending Requests',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'All team invitations and member requests have been fully processed.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMembersTableView(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row matching Image 1
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('👥 ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Practice Team Members',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
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
                      onPressed: () {
                        setState(() {
                          _showTeamRequests = true;
                        });
                      },
                      icon: const Icon(LucideIcons.userCheck, size: 13, color: Color(0xFF2563EB)),
                      label: const Text('Team Requests', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.white,
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
                    Row(
                      children: [
                        Text('👥 ', style: TextStyle(fontSize: 16)),
                        Text(
                          'Practice Team Members',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                      ],
                    ),
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
                onPressed: () {
                  setState(() {
                    _showTeamRequests = true;
                  });
                },
                icon: const Icon(LucideIcons.userCheck, size: 14, color: Color(0xFF2563EB)),
                label: const Text('Team Requests', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.white,
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

        const SizedBox(height: 18),

        // Table container matching Image 1
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tableContent = Column(
                children: [
                  // Table Header Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildColumnFilterHeader('TEAM MEMBER'),
                        ),
                        Expanded(
                          flex: 4,
                          child: _buildColumnFilterHeader('EMAIL ADDRESS'),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildColumnFilterHeader('DESIGNATION / ROLE'),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildColumnFilterHeader('STATUS'),
                        ),
                        const SizedBox(
                          width: 90,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'ACTIONS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Member row (aruntest)
                  if (!_aruntestRemoved)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          // Team Member
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: const Color(0xFFDCFCE7),
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'aruntest',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Email Address
                          const Expanded(
                            flex: 4,
                            child: Text(
                              'aruntest@bnxmail.com',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                          // Designation / Role
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'CS Specialist',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Status
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Actions
                          SizedBox(
                            width: 90,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _aruntestRemoved = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Team member removed'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFFECACA)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No team members found',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                ],
              );

              if (constraints.maxWidth < 650) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 650,
                    child: tableContent,
                  ),
                );
              }
              return tableContent;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColumnFilterHeader(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.filter, size: 9, color: Color(0xFF94A3B8)),
              SizedBox(width: 2),
              Icon(LucideIcons.chevronDown, size: 8, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
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
