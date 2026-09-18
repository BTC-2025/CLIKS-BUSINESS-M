import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../widgets/compose_email_campaign_dialog.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> with SingleTickerProviderStateMixin {
  int _activeTab = 2; // Default to Trigger Automations (Tab 2)

  final List<_TabItem> _tabs = [
    _TabItem('All Campaigns', LucideIcons.megaphone),
    _TabItem('Message Templates', LucideIcons.fileText),
    _TabItem('Trigger Automations', LucideIcons.zap),
    _TabItem('Audience & Loyalty', LucideIcons.users),
    _TabItem('Advanced ROI Reports', LucideIcons.barChart),
  ];

  final List<Map<String, dynamic>> _automations = [
    {
      'title': 'Birthday Wish',
      'subtitle': 'Trigger: customer_birthday • Channel: Email • Timing: Instant (09:00 AM)',
      'sent': 45,
      'conv': 12,
      'active': true,
    },
    {
      'title': 'Anniversary Wish',
      'subtitle': 'Trigger: customer_anniversary • Channel: Email • Timing: Instant (10:00 AM)',
      'sent': 12,
      'conv': 3,
      'active': true,
    },
    {
      'title': 'Payment Follow-up',
      'subtitle': 'Trigger: invoice_due • Channel: Email • Timing: 2 Days after due date',
      'sent': 340,
      'conv': 288,
      'active': true,
    },
    {
      'title': 'Abandoned Cart',
      'subtitle': 'Trigger: cart_abandoned • Channel: Email • Timing: 4 Hours after abandonment',
      'sent': 0,
      'conv': 0,
      'active': false,
    },
  ];

  final List<Map<String, dynamic>> _segments = [
    {
      'title': 'VIP Customers',
      'subtitle': 'Customers with life-time purchase value > ₹25,000',
      'lcv': 'Avg Lifecycle Value: ₹34,500',
      'buyers': 124,
    },
    {
      'title': 'Active Retail Buyers',
      'subtitle': 'Purchased in the last 30 days',
      'lcv': 'Avg Lifecycle Value: ₹4,200',
      'buyers': 840,
    },
    {
      'title': 'Inactive Lapsed Buyers',
      'subtitle': 'No purchases in the last 90+ days',
      'lcv': 'Avg Lifecycle Value: ₹1,800',
      'buyers': 180,
    },
    {
      'title': 'Wholesale Partners',
      'subtitle': 'Subscribed as verified business purchasers',
      'lcv': 'Avg Lifecycle Value: ₹1,12,000',
      'buyers': 56,
    },
  ];

  void _openComposeDialog() {
    showDialog(
      context: context,
      builder: (context) => const ComposeEmailCampaignDialog(),
    );
  }

  void _configureNewTrigger() {
    AppSnackbar.show(context, "Opening Trigger Automation Builder...", type: SnackType.info);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // Single Floating Action Button for Mobile
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.extended(
                onPressed: _openComposeDialog,
                backgroundColor: const Color(0xFF166534),
                elevation: 4,
                icon: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                label: const Text(
                  'Create Email Campaign',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
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
                  _buildMainContent(isMobile)
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
  // DESKTOP ACTIONS (Top-Right Action Buttons like Accounting)
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
            onPressed: _configureNewTrigger,
            icon: const Icon(LucideIcons.zap, size: 14),
            label: const Text('Configure New Trigger', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF166534),
              side: const BorderSide(color: Color(0xFFBBF7D0)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openComposeDialog,
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Create Email Campaign', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
  // HERO SUMMARY CARD (Accounting Style Header Card)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 12 : 16, isMobile ? 14 : 24, 0),
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F5B2E), Color(0xFF1A7A42), Color(0xFF22905A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5B2E).withValues(alpha: 0.25),
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
                      child: const Icon(LucideIcons.megaphone, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'MARKETING & ENGAGEMENT ENGINE',
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

          const SizedBox(height: 16),

          // 3 Stat Chips (Accounting Style)
          Row(
            children: [
              _buildHeroChip('TOTAL REACH', '1,180', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('AVG. ROI', '12.4%', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('ACTIVE AUTOMATIONS', '4 Triggers', isMobile),
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
  // TAB NAVIGATION (Accounting Style Choice Chips)
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
  // MAIN CONTENT ROUTER WITH ACCOUNTING STYLE CARD CONTAINER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile) {
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
                  _tabs[_activeTab].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F5B2E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActiveTabSection(isMobile),
        ],
      ),
    );
  }

  Widget _buildActiveTabSection(bool isMobile) {
    switch (_activeTab) {
      case 0:
        return _buildCampaignsTab(isMobile);
      case 1:
        return _buildTemplatesTab(isMobile);
      case 2:
        return _buildAutomationsTab(isMobile);
      case 3:
        return _buildAudienceTab(isMobile);
      case 4:
        return _buildRoiTab(isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- TAB 0: ALL CAMPAIGNS ---
  Widget _buildCampaignsTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.megaphone, size: 48, color: AppColors.secondaryText.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                const Text(
                  'No Campaigns Found',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create a new Email campaign to get started with bulk customer promotions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.secondaryText, height: 1.4),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _openComposeDialog,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text('Create Email Campaign', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 1: MESSAGE TEMPLATES ---
  Widget _buildTemplatesTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.fileText, size: 48, color: AppColors.secondaryText.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                const Text(
                  'No Templates Saved',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Save template structures during campaign creation to reuse them later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.secondaryText, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 2: TRIGGER AUTOMATIONS ---
  Widget _buildAutomationsTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _automations.length,
          itemBuilder: (context, index) {
            final aut = _automations[index];
            final isActive = aut['active'] as bool;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.zap,
                          color: isActive ? const Color(0xFF15803D) : const Color(0xFF64748B),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          aut['title'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Paused',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    aut['subtitle'],
                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sent: ${aut['sent']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                      Text('Conversions: ${aut['conv']}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --- TAB 3: AUDIENCE & LOYALTY ---
  Widget _buildAudienceTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _segments.length,
          itemBuilder: (context, index) {
            final seg = _segments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seg['title'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          seg['subtitle'],
                          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          seg['lcv'],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${seg['buyers']} Buyers',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --- TAB 4: ADVANCED ROI REPORTS ---
  Widget _buildRoiTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(LucideIcons.barChart2, color: Color(0xFF15803D), size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Campaign Performance Summary',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildRoiStatCard('Total Revenue Generated', '₹1,45,800', isMobile),
                  const SizedBox(width: 12),
                  _buildRoiStatCard('Average Campaign ROI', '340%', isMobile),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoiStatCard(String label, String value, bool isMobile) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
              style: const TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
            ),
          ],
        ),
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
