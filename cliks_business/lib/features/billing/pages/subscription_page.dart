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
  final bool isTopTier;
  final Widget? extraWidget;
  final String? billingCycleText;
  final String? billingSubtext;

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
    this.isTopTier = false,
    this.extraWidget,
    this.billingCycleText,
    this.billingSubtext,
  });
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  // Dark Forest Green brand color palette matching other macOS sections (#135029)
  static const Color _darkForestGreen = Color(0xFF135029);
  static const Color _lightMintGreen = Color(0xFFEAFAE3);
  static const Color _mintBorder = Color(0xFFD1F2C2);

  // Section Navigation Tabs (BUSINESS, FIN-PRO, PARTNER LAUNCH DESK)
  int _selectedMainTab = 0; // 0: BUSINESS, 1: FIN-PRO, 2: PARTNER LAUNCH DESK
  int _selectedPartnerTab = 0; // 0: Investor Club, 1: Products & Ideas

  // Tier tracking for Upgrade logic:
  // "A person can go from starter plan to elite plan , like upgrading ,
  // but if he puts the elite or any other plan , the plan which is before it button should not work , the button above it can work"
  int _currentBusinessTier = 1; // 1: Starter, 2: Standard, 3: Premium, 4: Elite
  int _currentFinProTier = 1; // 1: Solo (Active), 2: Firm (Top tier with Gold UI)
  int _finProTeamMembers = 3; // Stepper counter in Fin-Pro Firm
  int _currentInvestorTier = 1; // 1: Basic Investor, 2: Pro Investor (Top tier with Gold UI)
  int _currentProductsTier = 1; // 1: Monthly Innovator, 2: Yearly Founder (Top tier with Gold UI)

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

  // Animated Blinking Offer Controller for macOS Tier Tabs
  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;

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

    // Blinking pulsing animation for tier tabs
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _blinkAnimation = CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _blinkController.dispose();
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
      topTag: 'ELITE ENTERPRISE',
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
      isCurrentPlan: false,
      isTopTier: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 18.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.white,
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

            // ─── 2. ACTIVE PLAN HERO BANNER (Dark green color long tab) ───
            Container(key: _activePlanKey, child: _buildActivePlanBanner(isMobile)),
            const SizedBox(height: 20),

            // ─── 3. 3-SECTION PILL SELECTOR (Directly below "Active plan" dark green long tab) ───
            _buildMainTabSelector(),
            const SizedBox(height: 28),

            if (_selectedMainTab == 0) ...[
              // ─── 4. UPGRADE WORKSPACE TIER SECTION TITLE ───
              Container(key: _upgradeTiersKey, child: _buildUpgradeSectionHeader()),
              const SizedBox(height: 18),

              // ─── 5. FOUR SUBSCRIPTION CARDS (SIDE-BY-SIDE WITH UPGRADE PLAN LOGIC) ───
              _buildFourTierCards(),
            ] else if (_selectedMainTab == 1) ...[
              // ─── FIN-PRO SECTION ───
              _buildFinProSection(isMobile),
            ] else ...[
              // ─── PARTNER LAUNCH DESK SECTION ───
              _buildPartnerLaunchDeskSection(isMobile),
            ],
            const SizedBox(height: 36),

            // ─── BILLING & STATEMENT HISTORY ───
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
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _darkForestGreen,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your active workspace tier, features access, and transaction statements.',
                style: GoogleFonts.inter(
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
            style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
    String activePlanName;
    String activePlanDesc;
    String activeRenewalAmount;

    if (_selectedMainTab == 0) {
      final activeTierData = _tiers.firstWhere(
        (t) => t.tierNumber == _currentBusinessTier,
        orElse: () => _tiers.first,
      );
      activePlanName = activeTierData.name;
      activePlanDesc =
          'Your workspace is configured with high-performance ERP pipelines under the ${activeTierData.name} tier.';
      activeRenewalAmount = '${activeTierData.fullAnnualPrice} + GST';
    } else if (_selectedMainTab == 1) {
      final isFirm = _currentFinProTier == 2;
      activePlanName = isFirm ? 'Fin-Pro Firm' : 'Fin-Pro Solo';
      activePlanDesc = isFirm
          ? 'Your practice is equipped with multi-client auditing, collaborative team management, and direct API sandbox access.'
          : 'Your practice is equipped with solo practitioner client ledgers and direct audit verification logs.';
      activeRenewalAmount = isFirm ? '₹17,988 + GST' : '₹9,588 + GST';
    } else {
      if (_selectedPartnerTab == 0) {
        final isPro = _currentInvestorTier == 2;
        activePlanName = isPro ? 'Pro Investor' : 'Basic Investor';
        activePlanDesc = isPro
            ? 'Your desk has full access to 50 curated pitches, interactive deal rooms, and 1-on-1 consultations.'
            : 'Your desk has access to 20 curated startup pitches and direct founder contact channels.';
        activeRenewalAmount = isPro ? '₹23,988 + GST' : '₹11,988 + GST';
      } else {
        final isYearly = _currentProductsTier == 2;
        activePlanName = isYearly ? 'Yearly Founder' : 'Monthly Innovator';
        activePlanDesc = isYearly
            ? 'Annual sovereign tier with lifetime fee freeze, unlimited pitches, and VIP gala entry.'
            : 'Monthly access for founders seeking foundational product testing.';
        activeRenewalAmount = isYearly ? '₹4,999 + GST' : '₹499 + GST';
      }
    }

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
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activePlanName,
                    style: GoogleFonts.inter(
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
                activePlanDesc,
                style: GoogleFonts.inter(
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
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: isMobile ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NEXT RENEWAL',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '12 Jul 2027',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 14.5 : 16,
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
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RENEWAL AMOUNT',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                activeRenewalAmount,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 14.5 : 16,
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
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 22, vertical: 18),
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
  Widget _buildUpgradeSectionHeader([String title = 'Upgrade Workspace Tier']) {
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
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
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
                      style: GoogleFonts.inter(
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
                      style: GoogleFonts.inter(
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
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. FOUR SUBSCRIPTION CARDS (Strict Identical Height & Layout Uniformity)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFourTierCards() {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final mins = _remainingTime.inMinutes % 60;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = _tiers
            .map(
              (tier) => _buildSingleSubscriptionCard(
                tier: tier,
                activeTierNumber: _currentBusinessTier,
                onUpgrade: (newTier) {
                  setState(() => _currentBusinessTier = newTier);
                },
                days: days,
                hours: hours,
                mins: mins,
              ),
            )
            .toList();

        // Responsive horizontal scroll guard on smaller window sizes to avoid overflow
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
  Widget _buildSingleSubscriptionCard({
    required _SubscriptionTierData tier,
    required int activeTierNumber,
    required ValueChanged<int> onUpgrade,
    required int days,
    required int hours,
    required int mins,
  }) {
    final int tierNum = tier.tierNumber;
    final bool isTier1 = tierNum == 1;
    final bool isTier2 = tierNum == 2;
    final bool isTier3 = tierNum == 3;
    final bool isCurrent = tierNum == activeTierNumber;
    final bool isGold = tier.isTopTier;

    // Distinct Tier Accents & Color Themes
    final Color accentColor = isGold
        ? const Color(0xFFB45309) // Rich Warm Gold / Amber for top tiers
        : (isTier1
              ? const Color(0xFF475569) // Cool Slate Blue
              : (isTier2
                    ? const Color(0xFF0D9488) // Clean Teal / Emerald
                    : (isTier3
                          ? const Color(0xFF2563EB) // Vibrant Royal Blue / Indigo
                          : const Color(0xFFB45309))));

    // Gold UI ONLY for higher plan (All Top Tiers)!
    // Currently active plan is normally highlighted (Clean Brand Green, ZERO gold)
    final Color cardBorderColor = isGold
        ? const Color(0xFFD4AF37) // Luxury Gold border ONLY for top tiers
        : (isCurrent
              ? _darkForestGreen // Normally highlighted for active plan
              : (isTier3
                    ? const Color(0xFF2563EB) // Royal Blue border
                    : const Color(0xFFE2E8F0)));

    final double borderWidth = isGold ? 2.4 : (isCurrent ? 2.0 : (isTier3 ? 1.8 : 1.2));

    final List<BoxShadow> cardShadow = isGold
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
        : (isCurrent
            ? [
                BoxShadow(
                  color: _darkForestGreen.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : (isTier3
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
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]));

    return Container(
      decoration: BoxDecoration(
        color: isGold
            ? const Color(0xFFFFFDF5) // Luxury Gold background ONLY for top tiers
            : (isCurrent ? const Color(0xFFF9FDF9) : Colors.white),
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
              child: _buildTierTopBadge(tier, isCurrent),
            ),
            const SizedBox(height: 14),

            // ─── 2. TIER ICON & TOP-RIGHT DISCOUNT TAG ───
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  _buildTierIcon(tier, accentColor, isCurrent),
                  const Spacer(),
                  _buildDiscountTag(tier, isCurrent),
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
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isGold
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
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 32,
              alignment: Alignment.centerLeft,
              child: _buildBlinkingOfferButton(tier, days, hours, mins, isCurrent),
            ),
            const SizedBox(height: 8),

            // ─── 5. PRICING CONTAINER (Identical height & padding across all cards) ───
            _buildPricingBox(tier, isCurrent),
            const SizedBox(height: 14),

            // ─── OPTIONAL EXTRA WIDGET (e.g. Stepper in Fin-Pro Firm) ───
            if (tier.extraWidget != null) ...[
              tier.extraWidget!,
              const SizedBox(height: 14),
            ],

            // ─── 6. ACTION CTA BUTTON (Strict 44px height across all cards) ───
            _buildCtaButton(
              tier: tier,
              accentColor: accentColor,
              activeTierNumber: activeTierNumber,
              onUpgrade: onUpgrade,
            ),
            const SizedBox(height: 20),

            // ─── 7. WHAT'S INCLUDED HEADER (Starts on identical horizontal axis) ───
            Text(
              "WHAT'S INCLUDED",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isGold
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
                        color: isGold
                            ? const Color(0xFFFEF3C7)
                            : (isCurrent
                                  ? const Color(0xFFECFDF5)
                                  : accentColor.withValues(alpha: 0.12)),
                        border: isGold
                            ? Border.all(
                                color: const Color(0xFFFDE68A),
                                width: 1.0,
                              )
                            : (isCurrent
                                  ? Border.all(
                                      color: const Color(0xFFA7F3D0),
                                      width: 1.0,
                                    )
                                  : null),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          LucideIcons.check,
                          size: 10.5,
                          color: isGold
                              ? const Color(0xFFB45309)
                              : (isCurrent ? _darkForestGreen : accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.inter(
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

  // ═══════════════════════════════════════════════════════════════
  // ANIMATED BLINKING OFFER BUTTON FOR macOS TIER TABS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBlinkingOfferButton(
    _SubscriptionTierData tier,
    int days,
    int hours,
    int mins,
    bool isCurrent,
  ) {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        final double t = _blinkAnimation.value;
        // Gold UI for all Top Tiers (always gold)!
        final bool isGold = tier.isTopTier;
        final bool isTier3 = tier.tierNumber == 3;
        final bool isTier2 = tier.tierNumber == 2;

        final Color baseColor = isGold
            ? const Color(0xFFB45309)
            : (isCurrent
                  ? _darkForestGreen
                  : (isTier3
                        ? const Color(0xFF1D4ED8)
                        : (isTier2 ? const Color(0xFF0F766E) : const Color(0xFF334155))));

        final Color glowColor = isGold
            ? const Color(0xFFF59E0B)
            : (isCurrent
                  ? const Color(0xFF10B981)
                  : (isTier3
                        ? const Color(0xFF3B82F6)
                        : (isTier2 ? const Color(0xFF14B8A6) : const Color(0xFF64748B))));

        final Color dotColor = isGold
            ? const Color(0xFFEA580C)
            : (isCurrent
                  ? const Color(0xFF059669)
                  : (isTier3 ? const Color(0xFF2563EB) : const Color(0xFFEF4444)));

        return Tooltip(
          message: 'Special Promotional Discount Active • ${tier.discountTag}',
          child: Transform.scale(
            scale: 1.0 + 0.025 * t,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isGold
                      ? [
                          Color.lerp(const Color(0xFFFFFBEB), const Color(0xFFFEF3C7), t)!,
                          Color.lerp(const Color(0xFFFDE68A), const Color(0xFFFCD34D), t)!,
                        ]
                      : (isTier3
                            ? [
                                Color.lerp(const Color(0xFFEFF6FF), const Color(0xFFDBEAFE), t)!,
                                Color.lerp(const Color(0xFFBFDBFE), const Color(0xFF93C5FD), t)!,
                              ]
                            : [
                                Color.lerp(const Color(0xFFF0FDF4), const Color(0xFFDCFCE7), t)!,
                                Color.lerp(const Color(0xFFBBF7D0), const Color(0xFF86EFAC), t)!,
                              ]),
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color.lerp(
                    baseColor.withValues(alpha: 0.45),
                    baseColor,
                    t,
                  )!,
                  width: 1.1 + 0.3 * t,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.22 + 0.38 * t),
                    blurRadius: 4 + 7 * t,
                    spreadRadius: 0.6 * t,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Blinking live pulse dot
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dotColor.withValues(alpha: 0.3 + 0.7 * t),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.5 * t),
                          blurRadius: 3 * t,
                          spreadRadius: 0.8 * t,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    LucideIcons.flame,
                    size: 11.5,
                    color: baseColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Offer • ${days}d left',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: baseColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.sparkles,
                    size: 9.5,
                    color: baseColor.withValues(alpha: 0.4 + 0.6 * t),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTierTopBadge(_SubscriptionTierData tier, bool isCurrent) {
    if (isCurrent) {
      if (tier.isTopTier) {
        // Gold badge for active top tier (Elite always stays gold!)
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
                style: GoogleFonts.inter(
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

      // Normally highlighted badge for active non-top plan (Clean green checkmark, NO gold)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
        decoration: BoxDecoration(
          color: _darkForestGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _darkForestGreen.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.checkCheck, size: 12, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'CURRENTLY ACTIVE PLAN',
              style: GoogleFonts.inter(
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

    // Gold UI for all top tiers (Tier 4 Elite, Fin-Pro Firm, Pro Investor, Yearly Founder)
    if (tier.isTopTier) {
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
              tier.topTag.isNotEmpty && tier.topTag != 'CURRENTLY ACTIVE PLAN'
                  ? tier.topTag
                  : 'ELITE ENTERPRISE',
              style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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

    if (tier.tierNumber == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCCFBF1)),
        ),
        child: Text(
          tier.topTag,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0D9488),
            letterSpacing: 0.6,
          ),
        ),
      );
    }

    // Tier 1 (Starter / Solo / Basic)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        tier.topTag,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF475569),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildTierIcon(_SubscriptionTierData tier, Color accentColor, bool isCurrent) {
    final bool isGold = tier.isTopTier;
    final bool isTier3 = tier.tierNumber == 3;
    final bool isTier2 = tier.tierNumber == 2;

    // Gold UI for all top tiers!
    final Color bgColor = isGold
        ? const Color(0xFFFEF3C7) // Luxury Gold background for top tiers
        : (isCurrent
              ? const Color(0xFFECFDF5) // Clean mint for active plan
              : (isTier3
                    ? const Color(0xFFEFF6FF)
                    : (isTier2 ? const Color(0xFFF0FDFA) : const Color(0xFFF1F5F9))));

    final Color borderColor = isGold
        ? const Color(0xFFD4AF37) // Gold border for top tiers
        : (isCurrent
              ? const Color(0xFFA7F3D0) // Emerald border for active plan
              : (isTier3
                    ? const Color(0xFFBFDBFE)
                    : (isTier2 ? const Color(0xFF99F6E4) : const Color(0xFFCBD5E1))));

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isGold || isCurrent ? 1.5 : 1.2),
        boxShadow: isGold
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : (isCurrent
                ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null),
      ),
      child: Center(
        child: Icon(
          tier.icon,
          size: 20,
          color: isGold
              ? const Color(0xFFB45309) // Gold icon for top tiers
              : (isCurrent ? _darkForestGreen : accentColor),
        ),
      ),
    );
  }

  Widget _buildDiscountTag(_SubscriptionTierData tier, bool isCurrent) {
    final bool isGold = tier.isTopTier;
    final bool isTier3 = tier.tierNumber == 3;
    final bool isTier2 = tier.tierNumber == 2;

    // Gold tag for top tiers
    final Color bgColor = isGold
        ? const Color(0xFFFEF3C7)
        : (isCurrent
              ? const Color(0xFFECFDF5)
              : (isTier3
                    ? const Color(0xFFEFF6FF)
                    : (isTier2 ? const Color(0xFFF0FDFA) : const Color(0xFFF1F5F9))));

    final Color textColor = isGold
        ? const Color(0xFF78350F)
        : (isCurrent
              ? const Color(0xFF065F46)
              : (isTier3
                    ? const Color(0xFF2563EB)
                    : (isTier2 ? const Color(0xFF0D9488) : const Color(0xFF475569))));

    final Color borderColor = isGold
        ? const Color(0xFFD4AF37)
        : (isCurrent
              ? const Color(0xFFA7F3D0)
              : (isTier3
                    ? const Color(0xFFBFDBFE)
                    : (isTier2 ? const Color(0xFFCCFBF1) : const Color(0xFFE2E8F0))));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: isGold ? 1.3 : 1.0),
      ),
      child: Text(
        tier.discountTag,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPricingBox(_SubscriptionTierData tier, bool isCurrent) {
    // Gold pricing box for top tiers (always gold)! Active non-top plan is clean neutral (ZERO gold)
    final bool isGold = tier.isTopTier;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isGold ? const Color(0xFFFFFDF0) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGold ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
          width: isGold ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Strikethrough monthly price
          Text(
            '${tier.originalMonthlyPrice}/mo',
            style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isGold
                      ? const Color(0xFF78350F)
                      : const Color(0xFF0F172A),
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ mo',
                style: GoogleFonts.inter(
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
            tier.billingCycleText ?? 'Billed annually at ${tier.fullAnnualPrice} / yr',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),

          // Price per organization, billed annually
          Text(
            tier.billingSubtext ?? 'Price per organization, billed annually',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton({
    required _SubscriptionTierData tier,
    required Color accentColor,
    required int activeTierNumber,
    required ValueChanged<int> onUpgrade,
  }) {
    final int tierNum = tier.tierNumber;
    final bool isCurrent = tierNum == activeTierNumber;
    final bool isBelow = tierNum < activeTierNumber;
    final bool isAbove = tierNum > activeTierNumber;

    if (isCurrent) {
      if (tier.isTopTier) {
        // Elite plan active CTA button - Gold themed!
        return Container(
          height: 44,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
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
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF78350F),
                ),
              ),
            ],
          ),
        );
      }

      // Normally highlighted button for currently active non-top plan (Clean green checkmark, NO gold)
      return Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
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
              color: Color(0xFF065F46),
            ),
            const SizedBox(width: 7),
            Text(
              'Currently Active Plan',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF065F46),
              ),
            ),
          ],
        ),
      );
    }

    if (isBelow) {
      // "the plan which is before it button should not work"
      return SizedBox(
        height: 44,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: null, // Disabled - button does not work
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            backgroundColor: const Color(0xFFF8FAFC),
            disabledForegroundColor: const Color(0xFF94A3B8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.ban, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                'Downgrade Unavailable',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // isAbove: "the button above it can work" - Gold for all top tiers!
    final bool isGold = tier.isTopTier;
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showPlanUpgradeDialog(tier, onUpgrade),
        style: ElevatedButton.styleFrom(
          backgroundColor: isGold ? const Color(0xFFB45309) : accentColor,
          foregroundColor: Colors.white,
          elevation: isGold || tier.tierNumber == 3 ? 2 : 0,
          shadowColor: isGold
              ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
              : (tier.tierNumber == 3 ? accentColor.withValues(alpha: 0.35) : null),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Upgrade Plan',
              style: GoogleFonts.inter(
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

  void _showPlanUpgradeDialog(
    _SubscriptionTierData tier,
    ValueChanged<int> onUpgrade,
  ) {
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
                'Upgrade Plan - ${tier.name}',
                style: GoogleFonts.inter(
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
              'Upgrade your workspace to access all capabilities under ${tier.name}. Instant activation with prorated billing.',
              style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${tier.offerMonthlyPrice} / mo',
                        style: GoogleFonts.inter(
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
                        'Billing Cycle:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        tier.billingCycleText ?? '${tier.fullAnnualPrice} / yr',
                        style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onUpgrade(tier.tierNumber);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully upgraded to ${tier.name}!',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: const Color(0xFF135029),
                  behavior: SnackBarBehavior.floating,
                  width: 420,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF135029),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirm Upgrade to ${tier.name}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP 3-SECTION PILL SELECTOR (BUSINESS | FIN-PRO | PARTNER LAUNCH DESK)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainTabSelector() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFEAFAE3), // Soft mint green background
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFD1F2C2), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMainTabItem(
              index: 0,
              label: 'BUSINESS',
              icon: LucideIcons.shieldCheck,
              activeColor: _darkForestGreen,
            ),
            const SizedBox(width: 4),
            _buildMainTabItem(
              index: 1,
              label: 'FIN-PRO',
              icon: LucideIcons.award,
              activeColor: _darkForestGreen,
            ),
            const SizedBox(width: 4),
            _buildMainTabItem(
              index: 2,
              label: 'PARTNER LAUNCH DESK',
              icon: LucideIcons.crown,
              activeColor: const Color(0xFF312E81),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTabItem({
    required int index,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final bool isSelected = _selectedMainTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMainTab = index;
        });
      },
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF1E3A2B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1E3A2B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FIN-PRO SECTION (Completely matching Business section SaaS UI)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFinProSection(bool isMobile) {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final mins = _remainingTime.inMinutes % 60;

    final finProTiers = [
      _SubscriptionTierData(
        tierNumber: 1,
        topTag: 'SOLO PRACTITIONER',
        name: 'Fin-Pro Solo',
        headline:
            'Perfect for solo practitioners and independent chartered accountants.',
        originalMonthlyPrice: '₹1,199',
        offerMonthlyPrice: '₹799',
        fullAnnualPrice: '₹9,588',
        discountTag: 'Save ₹400',
        icon: LucideIcons.shieldCheck,
        billingCycleText: 'Billed annually at ₹9,588 / yr',
        billingSubtext: 'Price per practitioner, billed annually',
        extraWidget: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.user, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                'Solo Practitioner License',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
              const Spacer(),
              Text(
                '1 Seat',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        features: const [
          'Manage up to 25 Active Client Ledgers',
          'Standard Multi-Client GST/ITR Reporting',
          'Direct Auditing & Daybook Verification Logs',
          'Automated Exporting to CSV/Excel formats',
          'Priority Email & Live Chat Support',
          'Standard CA Digital Stamp & Verification',
        ],
      ),
      _SubscriptionTierData(
        tierNumber: 2,
        topTag: 'FIRM ENTERPRISE',
        name: 'Fin-Pro Firm',
        headline:
            'Designed for scaling accounting firms and collaborative auditing teams.',
        originalMonthlyPrice: '₹2,499',
        offerMonthlyPrice: '₹1,499',
        fullAnnualPrice: '₹17,988',
        discountTag: 'Save ₹1,000',
        icon: LucideIcons.crown,
        billingCycleText: 'Billed annually at ₹17,988 / yr',
        billingSubtext: 'Price per firm, billed annually',
        isTopTier: true,
        extraWidget: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(
                'Total Team Members:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (_finProTeamMembers > 1) {
                    setState(() => _finProTeamMembers--);
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.minus, size: 12, color: Color(0xFF334155)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '$_finProTeamMembers',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() => _finProTeamMembers++);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.plus, size: 12, color: Color(0xFF334155)),
                  ),
                ),
              ),
            ],
          ),
        ),
        features: [
          'Manage Unlimited Active Client Ledgers',
          'Custom White-Labeled Client Report Generation',
          '$_finProTeamMembers Team Members included by default',
          'Additional members at just ₹299/month each',
          'Live Chat Support & Direct API Sandbox Access',
          'Automated Audit Trail & Role Permissions',
        ],
      ),
    ];

    final cards = finProTiers
        .map(
          (tier) => _buildSingleSubscriptionCard(
            tier: tier,
            activeTierNumber: _currentFinProTier,
            onUpgrade: (newTier) {
              setState(() => _currentFinProTier = newTier);
            },
            days: days,
            hours: hours,
            mins: mins,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUpgradeSectionHeader('Upgrade Fin-Pro Practice Tier'),
        const SizedBox(height: 18),
        if (isMobile)
          Column(
            children: [
              cards[0],
              const SizedBox(height: 18),
              cards[1],
            ],
          )
        else
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 20),
                    Expanded(child: cards[1]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PARTNER LAUNCH DESK SECTION (Completely matching Business section SaaS UI)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPartnerLaunchDeskSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-selector tabs: [ Investor Club ] [ Products & Ideas ]
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPartnerSubTab(
                index: 0,
                label: 'Investor Club',
                icon: LucideIcons.crown,
              ),
              const SizedBox(width: 14),
              _buildPartnerSubTab(
                index: 1,
                label: 'Products & Ideas',
                icon: LucideIcons.zap,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (_selectedPartnerTab == 0)
          _buildInvestorClubTab(isMobile)
        else
          _buildProductsAndIdeasTab(isMobile),
      ],
    );
  }

  Widget _buildPartnerSubTab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedPartnerTab == index;
    final Color activeColor =
        index == 1 ? const Color(0xFFE11D48) : _darkForestGreen;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPartnerTab = index;
        });
      },
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF1E293B),
            ),
            const SizedBox(width: 9),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestorClubTab(bool isMobile) {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final mins = _remainingTime.inMinutes % 60;

    final investorTiers = const [
      _SubscriptionTierData(
        tierNumber: 1,
        topTag: 'BASIC INVESTOR',
        name: 'Basic Investor',
        headline:
            'Access curated startup directories with a limit of 20 pitches.',
        originalMonthlyPrice: '₹1,499',
        offerMonthlyPrice: '₹999',
        fullAnnualPrice: '₹11,988',
        discountTag: 'Save ₹500',
        icon: LucideIcons.shieldCheck,
        billingCycleText: 'Billed annually at ₹11,988 / yr',
        billingSubtext: 'Price per investor desk, billed annually',
        features: [
          'Access up to 20 startup pitches',
          'Filter pitches by industry and funding goal',
          'Direct contact channels with verified founders',
          'Real-time notifications for newly listed ventures',
          'Standard Deal Room Document Viewer',
          'Weekly Curated Angel Syndicate Digest',
        ],
      ),
      _SubscriptionTierData(
        tierNumber: 2,
        topTag: 'PRO INVESTOR',
        name: 'Pro Investor',
        headline:
            'Expanded access for active investors with a limit of 50 pitches.',
        originalMonthlyPrice: '₹2,999',
        offerMonthlyPrice: '₹1,999',
        fullAnnualPrice: '₹23,988',
        discountTag: 'Save ₹1,000',
        icon: LucideIcons.crown,
        billingCycleText: 'Billed annually at ₹23,988 / yr',
        billingSubtext: 'Price per investor desk, billed annually',
        isTopTier: true,
        features: [
          'Access up to 50 startup pitches',
          'Direct contact details for startup listings',
          'Interactive deal rooms & shared pitch folders',
          '1-on-1 deal flow consultations with steering team',
          'VIP Access to Private Founder Demo Days',
          'Priority Direct Syndicate Co-Investment Rights',
        ],
      ),
    ];

    final cards = investorTiers
        .map(
          (tier) => _buildSingleSubscriptionCard(
            tier: tier,
            activeTierNumber: _currentInvestorTier,
            onUpgrade: (newTier) {
              setState(() => _currentInvestorTier = newTier);
            },
            days: days,
            hours: hours,
            mins: mins,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUpgradeSectionHeader('Upgrade Investor Club Tier'),
        const SizedBox(height: 18),
        if (isMobile)
          Column(
            children: [
              cards[0],
              const SizedBox(height: 18),
              cards[1],
            ],
          )
        else
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 20),
                    Expanded(child: cards[1]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PRODUCTS & IDEAS TAB (Completely matching our SaaS cards UI)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProductsAndIdeasTab(bool isMobile) {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final mins = _remainingTime.inMinutes % 60;

    final productsTiers = const [
      _SubscriptionTierData(
        tierNumber: 1,
        topTag: 'FOUNDATIONAL INNOVATOR',
        name: 'Monthly Innovator',
        headline:
            'Monthly access for founders seeking foundational product testing.',
        originalMonthlyPrice: '₹699',
        offerMonthlyPrice: '₹499',
        fullAnnualPrice: '₹5,988',
        discountTag: 'Save ₹200',
        icon: LucideIcons.shieldCheck,
        billingCycleText: 'Billed monthly at ₹499 / mo',
        billingSubtext: 'Price per founder desk, billed monthly',
        isTopTier: false,
        features: [
          'Early access to new platform updates',
          'Standard community mastermind forum access',
          'List active roadmaps/pitches in the Deal Marketplace',
          'Standard investor-ready pitch templates',
        ],
      ),
      _SubscriptionTierData(
        tierNumber: 2,
        topTag: 'YEARLY SOVEREIGN',
        name: 'Yearly Founder',
        headline:
            'Annual sovereign tier with lifetime fee freeze and VIP gala entry.',
        originalMonthlyPrice: '₹5,988',
        offerMonthlyPrice: '₹4,999',
        fullAnnualPrice: '₹4,999',
        discountTag: 'Save ₹989',
        icon: LucideIcons.crown,
        billingCycleText: 'Billed annually at ₹4,999 / yr',
        billingSubtext: 'Equivalent to ₹417 per month • Lifetime Freeze',
        isTopTier: true,
        features: [
          'All features of Monthly Innovator tier',
          'Unlimited active roadmaps/pitches in the Marketplace',
          'Featured homepage and dashboard spotlight placement',
          'VIP reserved seat at the Annual Founder\'s Gala',
          'Lifetime subscription fee freeze guarantee',
        ],
      ),
    ];

    final cards = productsTiers
        .map(
          (tier) => _buildSingleSubscriptionCard(
            tier: tier,
            activeTierNumber: _currentProductsTier,
            onUpgrade: (newTier) {
              setState(() => _currentProductsTier = newTier);
            },
            days: days,
            hours: hours,
            mins: mins,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUpgradeSectionHeader('Upgrade Workspace Tier'),
        const SizedBox(height: 18),
        if (isMobile)
          Column(
            children: [
              cards[0],
              const SizedBox(height: 18),
              cards[1],
            ],
          )
        else
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 20),
                    Expanded(child: cards[1]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. BILLING & STATEMENT HISTORY (Matching uploaded Image 2 exactly)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBillingHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & History Icon OUTSIDE on top of container
        Row(
          children: [
            const Icon(
              LucideIcons.history,
              color: _darkForestGreen,
              size: 19,
            ),
            const SizedBox(width: 9),
            Text(
              'Billing & Statement History',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _darkForestGreen,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // White card container with table
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
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double minWidth = 840;
              final bool shouldScroll = constraints.maxWidth < minWidth;

              final tableWidget = SizedBox(
                width: shouldScroll ? minWidth : constraints.maxWidth,
                child: Column(
                  children: [
                    // Table Header Bar (#F8FAFC)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: _buildTableHeaderText('INVOICE ID')),
                          Expanded(flex: 3, child: _buildTableHeaderText('BILLING DATE')),
                          Expanded(flex: 3, child: _buildTableHeaderText('TIER DETAILS')),
                          Expanded(flex: 3, child: _buildTableHeaderText('PAYMENT MODE')),
                          Expanded(flex: 2, child: _buildTableHeaderText('STATUS')),
                          Expanded(flex: 2, child: _buildTableHeaderText('AMOUNT PAID', alignRight: true)),
                        ],
                      ),
                    ),

                    // Table Row 1 (From Image 2)
                    _buildTableRow(
                      invoiceId: 'INV-2026-0996',
                      billingDate: '2026-09-10',
                      tierDetails: 'Elite Suite',
                      paymentMode: 'Cashfree PG',
                      status: 'Paid',
                      amountPaid: '₹8,999',
                      isLast: false,
                    ),

                    // Table Row 2
                    _buildTableRow(
                      invoiceId: 'INV-2025-0682',
                      billingDate: '2025-09-10',
                      tierDetails: 'Tier 3 (Growth)',
                      paymentMode: 'HDFC NetBanking',
                      status: 'Paid',
                      amountPaid: '₹7,188',
                      isLast: false,
                    ),

                    // Table Row 3
                    _buildTableRow(
                      invoiceId: 'INV-2024-0321',
                      billingDate: '2024-09-10',
                      tierDetails: 'Tier 2 (Standard)',
                      paymentMode: 'UPI AutoPay',
                      status: 'Paid',
                      amountPaid: '₹4,788',
                      isLast: true,
                    ),
                  ],
                ),
              );

              if (shouldScroll) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: tableWidget,
                );
              }
              return tableWidget;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaderText(String label, {bool alignRight = false}) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTableRow({
    required String invoiceId,
    required String billingDate,
    required String tierDetails,
    required String paymentMode,
    required String status,
    required String amountPaid,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              invoiceId,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              billingDate,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              tierDetails,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              paymentMode,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF15803D),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                amountPaid,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
