import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionTierData {
  final int tierNumber;
  final String topTag;
  final String name;
  final String headline;
  final String originalMonthlyPrice;
  final String offerMonthlyPrice;
  final String fullAnnualPrice;
  final String discountTag;
  final IconData icon;
  final List<String> features;
  final bool isCurrentPlan;

  const _SubscriptionTierData({
    required this.tierNumber,
    required this.topTag,
    required this.name,
    required this.headline,
    required this.originalMonthlyPrice,
    required this.offerMonthlyPrice,
    required this.fullAnnualPrice,
    required this.discountTag,
    required this.icon,
    required this.features,
    this.isCurrentPlan = false,
  });
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // Dark Forest Green brand color palette matching other macOS sections (#135029)
  static const Color _darkForestGreen = Color(0xFF135029);
  static const Color _lightMintGreen = Color(0xFFEAFAE3);
  static const Color _mintBorder = Color(0xFFD1F2C2);

  // Scroll Controller & GlobalKeys for seamless section navigation
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _topHeaderKey = GlobalKey();
  final GlobalKey _activePlanKey = GlobalKey();
  final GlobalKey _upgradeTiersKey = GlobalKey();
  final GlobalKey _billingHistoryKey = GlobalKey();

  // 90-Day Promotional Discount Live Countdown Timer
  late final DateTime _offerEndTime;
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(days: 90);

  @override
  void initState() {
    super.initState();
    // 90-day promotional discount countdown
    _offerEndTime = DateTime.now().add(const Duration(days: 90));
    _remainingTime = _offerEndTime.difference(DateTime.now());
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final diff = _offerEndTime.difference(DateTime.now());
      if (diff.isNegative) {
        timer.cancel();
        setState(() => _remainingTime = Duration.zero);
      } else {
        setState(() => _remainingTime = diff);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    }
  }

  final List<_SubscriptionTierData> _tiers = const [
    _SubscriptionTierData(
      tierNumber: 1,
      topTag: 'STARTER',
      name: 'Tier 1 (Starter)',
      headline:
          'Essential tools for emerging retail, solopreneurs & small teams.',
      originalMonthlyPrice: '₹549',
      offerMonthlyPrice: '₹99',
      fullAnnualPrice: '₹1,188',
      discountTag: 'Save 82%',
      icon: LucideIcons.rocket,
      features: [
        'Unlimited Accounting & Day Book Logs',
        'Live GST Filings & ITC Auto-Matching',
        'Single-Warehouse Inventory Management',
        'Fast Invoicing, E-Way & Payment Links',
        'Automated Cash Flow & P&L Statements',
        'Standard Email Support (24h SLA)',
      ],
      isCurrentPlan: false,
    ),
    _SubscriptionTierData(
      tierNumber: 2,
      topTag: 'STANDARD',
      name: 'Tier 2 (Standard)',
      headline:
          'Comprehensive operational suite for growing SMBs and expanding stores.',
      originalMonthlyPrice: '₹1,349',
      offerMonthlyPrice: '₹249',
      fullAnnualPrice: '₹2,988',
      discountTag: 'Save 81%',
      icon: LucideIcons.layers,
      features: [
        'Everything included in Tier 1',
        'Multi-Warehouse Routing (up to 3 sites)',
        'Automated Payroll & Staff Attendance',
        'Recurring Invoices & Smart Overdue Alerts',
        'Custom Barcode & QR Label Printing',
        'Priority Live Chat & Email Support',
      ],
      isCurrentPlan: false,
    ),
    _SubscriptionTierData(
      tierNumber: 3,
      topTag: 'MOST POPULAR',
      name: 'Tier 3 (Premium / Growth)',
      headline:
          'High-velocity automation, multi-site sync & advanced business analytics.',
      originalMonthlyPrice: '₹2,499',
      offerMonthlyPrice: '₹549',
      fullAnnualPrice: '₹6,588',
      discountTag: 'Save 78%',
      icon: LucideIcons.trendingUp,
      features: [
        'Everything included in Tier 2',
        'Multi-Site Inventory & Routing (up to 10 sites)',
        'Dedicated Bill of Materials (BOM) & Work Orders',
        'API Webhook Access & Direct ERP Sync',
        'Advanced Tax Deductions & Audit Hub Reports',
        'Granular Multi-User Role Permissions',
        'Fast-Track Phone & VIP Chat Assistance',
      ],
      isCurrentPlan: false,
    ),
    _SubscriptionTierData(
      tierNumber: 4,
      topTag: 'CURRENTLY ACTIVE PLAN',
      name: 'Tier 4 (Elite)',
      headline:
          'Maximum performance, unlimited scale & dedicated 24/7 VIP governance.',
      originalMonthlyPrice: '₹3,499',
      offerMonthlyPrice: '₹999',
      fullAnnualPrice: '₹11,988',
      discountTag: 'Save 71%',
      icon: LucideIcons.crown,
      features: [
        'Everything included in Tier 3',
        'Unlimited Warehouses & Branch Locations',
        'Uncapped Active Staff & User Accounts',
        'Custom White-Label Invoicing & Branding',
        'Unlimited Manufacturing Batches & QC Logs',
        'Guaranteed 99.99% Enterprise Uptime SLA',
        'Dedicated FIN-PRO Manager & 24/7 VIP Support',
      ],
      isCurrentPlan: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 18.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(paddingVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP HEADER (Subscription & Billing with Credit Card Icon & Cycle Pill) ───
            Container(key: _topHeaderKey, child: _buildTopHeader(isMobile)),
            const SizedBox(height: 18),

            // ─── 2. ACTIVE PLAN HERO BANNER (Elite Suite with Next Renewal & Amount) ───
            Container(key: _activePlanKey, child: _buildActivePlanBanner(isMobile)),
            const SizedBox(height: 28),

            // ─── 3. UPGRADE WORKSPACE TIER SECTION TITLE ───
            Container(key: _upgradeTiersKey, child: _buildUpgradeSectionHeader()),
            const SizedBox(height: 18),

            // ─── 4. FOUR SUBSCRIPTION CARDS (SIDE-BY-SIDE WITH DARK FOREST GREEN HIGHLIGHTS) ───
            _buildFourTierCards(),
            const SizedBox(height: 36),

            // ─── 5. BILLING & STATEMENT HISTORY ───
            Container(key: _billingHistoryKey, child: _buildBillingHistorySection()),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP HEADER: Subscription & Billing + Cycle Pill
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopHeader(bool isMobile) {
    final titleSection = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _darkForestGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(LucideIcons.creditCard, color: Colors.white, size: 21),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Subscription & Billing',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _darkForestGreen,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your active workspace tier, features access, and transaction statements.',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    final billingCyclePill = Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(
        color: _lightMintGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _mintBorder, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Annual Billing Cycle',
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _darkForestGreen,
            ),
          ),
          const SizedBox(width: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: _darkForestGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ACTIVE',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [titleSection, const SizedBox(height: 12), billingCyclePill],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleSection),
        const SizedBox(width: 16),
        billingCyclePill,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. ACTIVE PLAN HERO BANNER: Elite Suite (Dark Forest Green)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildActivePlanBanner(bool isMobile) {
    final leftPart = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Icon(LucideIcons.sparkles, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'ACTIVE PLAN: ',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Elite Suite',
                    style: GoogleFonts.outfit(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Your workspace is configured with high-performance ERP pipelines under the Business Elite Suite tier.',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final rightBox = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NEXT RENEWAL',
                style: GoogleFonts.outfit(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '12 Jul 2027',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 28,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RENEWAL AMOUNT',
                style: GoogleFonts.outfit(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '₹8,999 + GST',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: _darkForestGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _darkForestGreen.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leftPart, const SizedBox(height: 16), rightBox],
            )
          : Row(
              children: [
                Expanded(child: leftPart),
                const SizedBox(width: 20),
                rightBox,
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. UPGRADE WORKSPACE TIER SECTION TITLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildUpgradeSectionHeader() {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final mins = _remainingTime.inMinutes % 60;
    final secs = _remainingTime.inSeconds % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _darkForestGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Upgrade Workspace Tier',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            // Small button near "Upgrade Workspace Tier"
            _buildUpgradeOfferTimerButton(days, hours, mins, secs),
            // Quick Jump to Active Plan
            InkWell(
              onTap: () => _scrollToSection(_activePlanKey),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.arrowUp, size: 10.5, color: Color(0xFF475569)),
                    const SizedBox(width: 3.5),
                    Text(
                      'Active Plan',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Quick Jump to Billing History
            InkWell(
              onTap: () => _scrollToSection(_billingHistoryKey),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.arrowDown, size: 10.5, color: Color(0xFF475569)),
                    const SizedBox(width: 3.5),
                    Text(
                      'Billing History',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Choose the ideal tier for your business scale. Special 90-day promotional discount active: save up to 82% before offer expires in $days days.',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeOfferTimerButton(
    int days,
    int hours,
    int mins,
    int secs,
  ) {
    return PopupMenuButton<String>(
      tooltip: '90-Day Promotional Discount Active • Click to Navigate Sections',
      onSelected: (value) {
        if (value == 'active_plan') {
          _scrollToSection(_activePlanKey);
        } else if (value == 'tiers') {
          _scrollToSection(_upgradeTiersKey);
        } else if (value == 'billing') {
          _scrollToSection(_billingHistoryKey);
        } else if (value == 'top') {
          _scrollToSection(_topHeaderKey);
        }
      },
      offset: const Offset(0, 34),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      elevation: 6,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'active_plan',
          child: Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 14, color: _darkForestGreen),
              const SizedBox(width: 8),
              Text(
                'Active Plan (Elite Suite)',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'tiers',
          child: Row(
            children: [
              const Icon(LucideIcons.layers, size: 14, color: _darkForestGreen),
              const SizedBox(width: 8),
              Text(
                'Workspace Pricing Tiers',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'billing',
          child: Row(
            children: [
              const Icon(LucideIcons.history, size: 14, color: _darkForestGreen),
              const SizedBox(width: 8),
              Text(
                'Billing & Statement History',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'top',
          child: Row(
            children: [
              const Icon(LucideIcons.arrowUp, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                'Back to Top',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.timer,
                size: 12.5,
                color: Color(0xFF78350F),
              ),
              const SizedBox(width: 4.5),
              Text(
                '90d Offer: ${days}d ${hours.toString().padLeft(2, '0')}h ${mins.toString().padLeft(2, '0')}m ${secs.toString().padLeft(2, '0')}s left',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF78350F),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 1,
                height: 11,
                color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
              ),
              const SizedBox(width: 5),
              Text(
                'Navigate',
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF92400E),
                ),
              ),
              const SizedBox(width: 2.5),
              const Icon(
                LucideIcons.chevronDown,
                size: 11,
                color: Color(0xFF78350F),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. FOUR SUBSCRIPTION CARDS (Strict Identical Height & Layout Uniformity)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFourTierCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = _tiers
            .map((tier) => _buildSingleSubscriptionCard(tier))
            .toList();

        // Responsive horizontal scroll guard on smaller macOS window sizes to avoid overflow
        if (constraints.maxWidth < 1180) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1200),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cards
                      .map(
                        (c) => SizedBox(
                          width: 290,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: c,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        }

        // Full width desktop: 4 cards side-by-side with strict identical height
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: c,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INDIVIDUAL SUBSCRIPTION CARD (Enterprise SaaS Aesthetic)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSingleSubscriptionCard(_SubscriptionTierData tier) {
    final int tierNum = tier.tierNumber;
    final bool isTier1 = tierNum == 1;
    final bool isTier2 = tierNum == 2;
    final bool isTier3 = tierNum == 3;
    final bool isTier4 = tierNum == 4;

    // Distinct Tier Accents & Color Themes
    final Color accentColor = isTier1
        ? const Color(0xFF475569) // Cool Slate Blue
        : (isTier2
              ? const Color(0xFF0D9488) // Clean Teal / Emerald
              : (isTier3
                    ? const Color(0xFF2563EB) // Vibrant Royal Blue / Indigo
                    : const Color(0xFFB45309))); // Rich Warm Gold / Amber

    final Color cardBorderColor = isTier4
        ? const Color(0xFFD4AF37) // Luxury Champagne Gold border
        : (isTier3
              ? const Color(0xFF2563EB) // Royal Blue border
              : const Color(0xFFE2E8F0));

    final double borderWidth = isTier4 ? 2.4 : (isTier3 ? 2.0 : 1.2);

    final List<BoxShadow> cardShadow = isTier3
        ? [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.14),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : (isTier4
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]);

    return Container(
      decoration: BoxDecoration(
        color: isTier4 ? const Color(0xFFFFFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: borderWidth),
        boxShadow: cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // ─── 1. TOP PILL BADGE (Aligned across all cards) ───
          Container(
            height: 28,
            alignment: Alignment.centerLeft,
            child: _buildTierTopBadge(tier),
          ),
          const SizedBox(height: 14),

          // ─── 2. TIER ICON & TOP-RIGHT DISCOUNT TAG ───
          SizedBox(
            height: 44,
            child: Row(
              children: [
                _buildTierIcon(tier, accentColor),
                const Spacer(),
                _buildDiscountTag(tier),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ─── 3. TIER NAME (Identical height for all cards) ───
          Container(
            height: 28,
            alignment: Alignment.centerLeft,
            child: Text(
              tier.name,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isTier4
                    ? const Color(0xFF78350F)
                    : const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ─── 4. TIER HEADLINE (Strict identical 42px height for all cards) ───
          SizedBox(
            height: 42,
            child: Text(
              tier.headline,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          // ─── 5. PRICING CONTAINER (Identical height & padding across all cards) ───
          _buildPricingBox(tier),
          const SizedBox(height: 16),

          // ─── 6. ACTION CTA BUTTON (Strict 44px height across all cards) ───
          _buildCtaButton(tier, accentColor),
          const SizedBox(height: 20),

          // ─── 7. WHAT'S INCLUDED HEADER (Starts on identical horizontal axis) ───
          Text(
            "WHAT'S INCLUDED",
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isTier4
                  ? const Color(0xFF92400E)
                  : const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // ─── 8. FEATURES LIST (Checklist with clean theme icons & standard line-height) ───
          ...tier.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 9.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 17,
                    height: 17,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isTier4
                          ? const Color(0xFFFEF3C7)
                          : accentColor.withValues(alpha: 0.12),
                      border: isTier4
                          ? Border.all(
                              color: const Color(0xFFFDE68A),
                              width: 1.0,
                            )
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.check,
                        size: 10.5,
                        color: isTier4 ? const Color(0xFFB45309) : accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                        height: 1.35,
                      ),
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

  Widget _buildTierTopBadge(_SubscriptionTierData tier) {
    if (tier.tierNumber == 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sparkles, size: 12, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'MOST POPULAR',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      );
    }

    if (tier.tierNumber == 4) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFB45309)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.crown, size: 12, color: Color(0xFFFEF3C7)),
            const SizedBox(width: 5),
            Text(
              'CURRENTLY ACTIVE PLAN',
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      );
    }

    if (tier.tierNumber == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCCFBF1)),
        ),
        child: Text(
          'STANDARD',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0D9488),
            letterSpacing: 0.6,
          ),
        ),
      );
    }

    // Tier 1 (Starter)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'STARTER',
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF475569),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildTierIcon(_SubscriptionTierData tier, Color accentColor) {
    final bool isTier4 = tier.tierNumber == 4;
    final bool isTier3 = tier.tierNumber == 3;
    final bool isTier2 = tier.tierNumber == 2;

    final Color bgColor = isTier4
        ? const Color(0xFFFEF3C7)
        : (isTier3
              ? const Color(0xFFEFF6FF)
              : (isTier2 ? const Color(0xFFF0FDFA) : const Color(0xFFF1F5F9)));

    final Color borderColor = isTier4
        ? const Color(0xFFD4AF37)
        : (isTier3
              ? const Color(0xFFBFDBFE)
              : (isTier2 ? const Color(0xFF99F6E4) : const Color(0xFFCBD5E1)));

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isTier4 ? 1.5 : 1.2),
        boxShadow: isTier4
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          tier.icon,
          size: 20,
          color: isTier4 ? const Color(0xFFB45309) : accentColor,
        ),
      ),
    );
  }

  Widget _buildDiscountTag(_SubscriptionTierData tier) {
    final bool isTier4 = tier.tierNumber == 4;
    final bool isTier3 = tier.tierNumber == 3;
    final bool isTier2 = tier.tierNumber == 2;

    final Color bgColor = isTier4
        ? const Color(0xFFFEF3C7)
        : (isTier3
              ? const Color(0xFFEFF6FF)
              : (isTier2 ? const Color(0xFFF0FDFA) : const Color(0xFFF1F5F9)));

    final Color textColor = isTier4
        ? const Color(0xFF78350F)
        : (isTier3
              ? const Color(0xFF2563EB)
              : (isTier2 ? const Color(0xFF0D9488) : const Color(0xFF475569)));

    final Color borderColor = isTier4
        ? const Color(0xFFD4AF37)
        : (isTier3
              ? const Color(0xFFBFDBFE)
              : (isTier2 ? const Color(0xFFCCFBF1) : const Color(0xFFE2E8F0)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: isTier4 ? 1.3 : 1.0),
      ),
      child: Text(
        tier.discountTag,
        style: GoogleFonts.outfit(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPricingBox(_SubscriptionTierData tier) {
    final bool isTier4 = tier.tierNumber == 4;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isTier4 ? const Color(0xFFFFFDF0) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTier4 ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
          width: isTier4 ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Strikethrough monthly price
          Text(
            '${tier.originalMonthlyPrice}/mo',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
              decoration: TextDecoration.lineThrough,
              decorationColor: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),

          // Large bold monthly offer price
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                tier.offerMonthlyPrice,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isTier4
                      ? const Color(0xFF78350F)
                      : const Color(0xFF0F172A),
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ mo',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // Billed annually at ₹X / yr
          Text(
            'Billed annually at ${tier.fullAnnualPrice} / yr',
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),

          // Price per organization, billed annually
          Text(
            'Price per organization, billed annually',
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(_SubscriptionTierData tier, Color accentColor) {
    if (tier.isCurrentPlan) {
      return Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.checkCheck,
              size: 16,
              color: Color(0xFF78350F),
            ),
            const SizedBox(width: 7),
            Text(
              'Currently Active Plan',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF78350F),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showUpgradeDialog(tier),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: tier.tierNumber == 3 ? 2 : 0,
          shadowColor: tier.tierNumber == 3
              ? accentColor.withValues(alpha: 0.35)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start free trial',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog(_SubscriptionTierData tier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(tier.icon, size: 20, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Start Trial - ${tier.name}',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get instant 14-day free access to all features under ${tier.name}. No credit card required to start.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Rate:',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${tier.offerMonthlyPrice} / mo',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'After Trial:',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Billed annually at ${tier.fullAnnualPrice} / yr',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '14-day free trial activated for ${tier.name}!',
                    style: GoogleFonts.outfit(),
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                  width: 420,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Start 14-Day Free Trial',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. BILLING & STATEMENT HISTORY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBillingHistorySection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.history,
                color: _darkForestGreen,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Billing & Statement History',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal scroll table fallback to prevent overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(130),
              children: [
                // Header Row
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                    ),
                  ),
                  children: [
                    _buildTh('INVOICE ID'),
                    _buildTh('BILLING DATE'),
                    _buildTh('TIER DETAILS'),
                    _buildTh('PAYMENT MODE'),
                    _buildTh('STATUS'),
                    _buildTh('AMOUNT PAID'),
                  ],
                ),

                // Table Row Data
                TableRow(
                  children: [
                    _buildTd(
                      'INV-2026-0743',
                      isBold: true,
                      color: _darkForestGreen,
                    ),
                    _buildTd('03 Jul 2026'),
                    _buildTd('Tier 4 (Elite)', isBold: true),
                    _buildTd('Cashfree PG'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: _lightMintGreen,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: _mintBorder),
                            ),
                            child: Text(
                              'Paid',
                              style: GoogleFonts.outfit(
                                color: _darkForestGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTd(
                      '₹11,988',
                      isBold: true,
                      color: const Color(0xFF0F172A),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTd(
                      'INV-2025-0682',
                      isBold: true,
                      color: _darkForestGreen,
                    ),
                    _buildTd('03 Jul 2025'),
                    _buildTd('Tier 3 (Growth)', isBold: true),
                    _buildTd('HDFC NetBanking'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: _lightMintGreen,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: _mintBorder),
                            ),
                            child: Text(
                              'Paid',
                              style: GoogleFonts.outfit(
                                color: _darkForestGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTd(
                      '₹6,588',
                      isBold: true,
                      color: const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTh(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTd(String val, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        val,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: color ?? const Color(0xFF334155),
        ),
      ),
    );
  }
}
