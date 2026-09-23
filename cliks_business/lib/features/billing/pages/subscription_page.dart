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
  final String monthlySavings;
  final String annualSavings;
  final String discountPercentage;
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
    required this.monthlySavings,
    required this.annualSavings,
    required this.discountPercentage,
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

  final List<_SubscriptionTierData> _tiers = const [
    _SubscriptionTierData(
      tierNumber: 1,
      topTag: 'ANNUAL SAVER',
      name: 'Tier 1 (Basic / Starter)',
      headline: 'Essential tools for emerging retail, solopreneurs & small teams.',
      originalMonthlyPrice: '₹549',
      offerMonthlyPrice: '₹99',
      fullAnnualPrice: '₹1,188',
      monthlySavings: '₹450',
      annualSavings: '₹5,400',
      discountPercentage: '82%',
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
      topTag: 'GROWTH READY',
      name: 'Tier 2 (Standard)',
      headline: 'Comprehensive operational suite for growing SMBs and expanding stores.',
      originalMonthlyPrice: '₹1,349',
      offerMonthlyPrice: '₹249',
      fullAnnualPrice: '₹2,988',
      monthlySavings: '₹1,100',
      annualSavings: '₹13,200',
      discountPercentage: '81%',
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
      headline: 'High-velocity automation, multi-site sync & advanced business analytics.',
      originalMonthlyPrice: '₹2,499',
      offerMonthlyPrice: '₹549',
      fullAnnualPrice: '₹6,588',
      monthlySavings: '₹1,950',
      annualSavings: '₹23,400',
      discountPercentage: '78%',
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
      headline: 'Maximum performance, unlimited scale & dedicated 24/7 VIP governance.',
      originalMonthlyPrice: '₹3,499',
      offerMonthlyPrice: '₹999',
      fullAnnualPrice: '₹11,988',
      monthlySavings: '₹2,500',
      annualSavings: '₹30,000',
      discountPercentage: '71%',
      icon: LucideIcons.crown,
      features: [
        'Everything included in Tier 3',
        'Unlimited Warehouses & Branch Locations',
        'Uncapped Active Staff & User Accounts',
        'Custom White-Label Invoicing & Branding',
        'Unlimited Manufacturing Batches & QC Logs',
        'Guaranteed 99.99% Enterprise Uptime SLA',
        'Dedicated FIN-PRO Account Manager',
        '24/7/365 Direct Priority VIP Phone Support',
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
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(paddingVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP HEADER (Subscription & Billing with Credit Card Icon & Cycle Pill) ───
            _buildTopHeader(isMobile),
            const SizedBox(height: 18),

            // ─── 2. ACTIVE PLAN HERO BANNER (Elite Suite with Next Renewal & Amount) ───
            _buildActivePlanBanner(isMobile),
            const SizedBox(height: 28),

            // ─── 3. UPGRADE WORKSPACE TIER SECTION TITLE ───
            _buildUpgradeSectionHeader(),
            const SizedBox(height: 18),

            // ─── 4. FOUR SUBSCRIPTION CARDS (SIDE-BY-SIDE WITH DARK FOREST GREEN HIGHLIGHTS) ───
            _buildFourTierCards(),
            const SizedBox(height: 36),

            // ─── 5. BILLING & STATEMENT HISTORY ───
            _buildBillingHistorySection(),
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
            child: Icon(
              LucideIcons.creditCard,
              color: Colors.white,
              size: 21,
            ),
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
        children: [
          titleSection,
          const SizedBox(height: 12),
          billingCyclePill,
        ],
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
            child: Icon(
              LucideIcons.sparkles,
              color: Colors.white,
              size: 22,
            ),
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
              children: [
                leftPart,
                const SizedBox(height: 16),
                rightBox,
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 4),
        Text(
          'Choose the ideal tier for your business scale. Save up to 82% with annual billed pricing.',
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. FOUR SUBSCRIPTION CARDS (Side-by-side with perfect vertical alignment)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFourTierCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = _tiers.map((tier) => _buildSingleSubscriptionCard(tier)).toList();

        // Responsive horizontal scroll guard on smaller macOS window sizes to avoid overflow
        if (constraints.maxWidth < 1180) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1180),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cards
                    .map(
                      (c) => SizedBox(
                        width: 285,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: c,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        }

        // Full width desktop: 4 cards side-by-side
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INDIVIDUAL SUBSCRIPTION CARD (Dark Forest Green Highlighting)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSingleSubscriptionCard(_SubscriptionTierData tier) {
    final isCurrent = tier.isCurrentPlan;
    final isPopular = tier.tierNumber == 3;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? _darkForestGreen
              : (isPopular ? const Color(0xFF22C55E).withValues(alpha: 0.6) : const Color(0xFFE2E8F0)),
          width: isCurrent ? 2.2 : (isPopular ? 1.5 : 1.2),
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: _darkForestGreen.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── TOP TAG / RIBBON BAR (Aligned 34px height across all 4 cards) ───
          Container(
            width: double.infinity,
            height: 34,
            decoration: BoxDecoration(
              color: isCurrent
                  ? _darkForestGreen
                  : (isPopular ? _lightMintGreen : const Color(0xFFF8FAFC)),
              border: Border(
                bottom: BorderSide(
                  color: isCurrent
                      ? _darkForestGreen
                      : (isPopular ? _mintBorder : const Color(0xFFE2E8F0)),
                  width: 1.0,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCurrent) ...[
                  const Icon(LucideIcons.checkCircle2, size: 13, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    tier.topTag,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ] else if (isPopular) ...[
                  const Icon(LucideIcons.sparkles, size: 12, color: _darkForestGreen),
                  const SizedBox(width: 5),
                  Text(
                    tier.topTag,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: _darkForestGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ] else ...[
                  Text(
                    tier.topTag,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── 1. TIER ICON ───
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCurrent ? _darkForestGreen : _lightMintGreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent ? _darkForestGreen : _mintBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          tier.icon,
                          size: 20,
                          color: isCurrent ? const Color(0xFFF2C94C) : _darkForestGreen,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _lightMintGreen,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _mintBorder),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: _darkForestGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else if (isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Text(
                          'RECOMMENDED',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF15803D),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // ─── 2. TIER NAME ───
                Text(
                  tier.name,
                  style: GoogleFonts.outfit(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),

                // ─── 3. TIER HEADLINE ───
                SizedBox(
                  height: 38,
                  child: Text(
                    tier.headline,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 4, 5, 6, 7. PRICING SECTION (Dark Forest Green Highlights) ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monthly Without Offer (Strikethrough, Neutral)
                      Row(
                        children: [
                          Text(
                            '${tier.originalMonthlyPrice} / month',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: const Color(0xFF94A3B8),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _lightMintGreen,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _mintBorder),
                            ),
                            child: Text(
                              '${tier.discountPercentage} OFF',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: _darkForestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // With Offer Price (Annual Billed Monthly - Prominent Dark Forest Green)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            tier.offerMonthlyPrice,
                            style: GoogleFonts.outfit(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: _darkForestGreen,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ month',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _darkForestGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(Annual)',
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Full Annual Billed Price (with Offer)
                      Row(
                        children: [
                          const Icon(LucideIcons.calendarCheck, size: 12, color: _darkForestGreen),
                          const SizedBox(width: 5),
                          Text(
                            'Full Annual Cost: ${tier.fullAnnualPrice} / year',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _darkForestGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Savings Detail
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: _lightMintGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.tag, size: 11, color: _darkForestGreen),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Save ${tier.monthlySavings}/mo (${tier.annualSavings}/yr)',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: _darkForestGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ─── 8. UPGRADE PLAN BUTTON (Dark Forest Green) ───
                SizedBox(
                  width: double.infinity,
                  child: isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _lightMintGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _darkForestGreen, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.checkCheck, size: 15, color: _darkForestGreen),
                              const SizedBox(width: 7),
                              Text(
                                'Current Active Plan',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: _darkForestGreen,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _showUpgradeDialog(tier),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkForestGreen,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: _darkForestGreen.withValues(alpha: 0.35),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Upgrade to Tier ${tier.tierNumber}',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // ─── 9. WHAT'S INCLUDED SECTION ───
                Text(
                  "WHAT'S INCLUDED",
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                // Checklist of features with dark forest green checkmarks
                ...tier.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 9.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: _lightMintGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.check, size: 10, color: _darkForestGreen),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            f,
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
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
        ],
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
                color: _lightMintGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(tier.icon, size: 20, color: _darkForestGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Upgrade to ${tier.name}',
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm subscription upgrade to ${tier.name}.',
              style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF334155)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Annual Amount Due:',
                    style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  Text(
                    '${tier.fullAnnualPrice} + GST',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _darkForestGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.outfit(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Upgrade order initiated for ${tier.name} (${tier.fullAnnualPrice}/year).',
                    style: GoogleFonts.outfit(),
                  ),
                  backgroundColor: _darkForestGreen,
                  behavior: SnackBarBehavior.floating,
                  width: 420,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkForestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Proceed with Payment',
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
              const Icon(LucideIcons.history, color: _darkForestGreen, size: 18),
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
                    border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
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
                    _buildTd('INV-2026-0743', isBold: true, color: _darkForestGreen),
                    _buildTd('03 Jul 2026'),
                    _buildTd('Tier 4 (Elite)', isBold: true),
                    _buildTd('Cashfree PG'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
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
                    _buildTd('₹11,988', isBold: true, color: const Color(0xFF0F172A)),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTd('INV-2025-0682', isBold: true, color: _darkForestGreen),
                    _buildTd('03 Jul 2025'),
                    _buildTd('Tier 3 (Growth)', isBold: true),
                    _buildTd('HDFC NetBanking'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
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
                    _buildTd('₹6,588', isBold: true, color: const Color(0xFF0F172A)),
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
