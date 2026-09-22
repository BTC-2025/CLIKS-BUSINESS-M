import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int _activeCategory = 0; // 0: BUSINESS, 1: FIN-PRO, 2: BETA CLUB

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Billing Cycle Header
            isMacOS
                ? _buildHeader(isMobile)
                : _buildHeader(isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
            const SizedBox(height: 24),

            // Active Plan Summary Card
            isMacOS
                ? _buildActivePlanSummaryCard(isMobile)
                : _buildActivePlanSummaryCard(isMobile)
                    .animate()
                    .fadeIn(duration: 450.ms, delay: 80.ms),
            const SizedBox(height: 24),

            // Tabs Selector Center Row
            isMacOS
                ? _buildTabsSelector(isMobile)
                : _buildTabsSelector(isMobile)
                    .animate()
                    .fadeIn(duration: 450.ms, delay: 120.ms),
            const SizedBox(height: 32),

            // Section: Upgrade Workspace Tier
            isMacOS
                ? const Text(
                    'Upgrade Workspace Tier',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  )
                : const Text(
                    'Upgrade Workspace Tier',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ).animate().fadeIn(duration: 400.ms, delay: 160.ms),
            const SizedBox(height: 20),

            // Plan Upgrade Cards Grid (desktop layout side-by-side, mobile stacked)
            isMacOS
                ? _buildPlanUpgradeGrid(isMobile)
                : _buildPlanUpgradeGrid(isMobile)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms),
            const SizedBox(height: 40),

            // Section: Billing & Statement History
            isMacOS
                ? _buildBillingHistorySection(isMobile)
                : _buildBillingHistorySection(isMobile)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 240.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final titleWidget = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF137333),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subscription & Billing',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              SizedBox(height: 4),
              Text(
                'Manage your active workspace tier, features access, and transaction statements.',
                style: TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );

    final billingBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Annual Billing Cycle',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          SizedBox(width: 6),
          Text(
            'ACTIVE',
            style: TextStyle(color: Color(0xFF137333), fontSize: 9.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 16),
          billingBadge,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: titleWidget),
        const SizedBox(width: 20),
        billingBadge,
      ],
    );
  }

  Widget _buildActivePlanSummaryCard(bool isMobile) {
    final leftPart = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVE PLAN: Elite Suite',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Your workspace is configured with high-performance ERP pipelines under the Business Elite Suite tier.',
                style: TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );

    final renewalDetails = Row(
      children: [
        _buildRenewalMeta('NEXT RENEWAL', '03 Jul 2027'),
        Container(width: 1, height: 32, color: Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 16)),
        _buildRenewalMeta('RENEWAL AMOUNT', '₹8,999 + GST'),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C4A2C), // Deep premium active green
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0C4A2C).withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                leftPart,
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                renewalDetails,
              ],
            )
          : Row(
              children: [
                Expanded(child: leftPart),
                const SizedBox(width: 24),
                renewalDetails,
              ],
            ),
    );
  }

  Widget _buildRenewalMeta(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 3),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTabsSelector(bool isMobile) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabPill('BUSINESS', LucideIcons.shieldAlert, 0),
              _buildTabPill('FIN-PRO', LucideIcons.briefcase, 1),
              _buildTabPill('BETA CLUB', LucideIcons.crown, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPill(String label, IconData icon, int index) {
    final active = _activeCategory == index;
    return GestureDetector(
      onTap: () => setState(() => _activeCategory = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0C4A2C) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.black54, size: 13),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanUpgradeGrid(bool isMobile) {
    final plans = [
      _buildPlanCard(
        title: 'Starter Plan',
        desc: 'Ideal for small retail & emerging SMBs.',
        originalPrice: '₹4,599',
        savedPrice: 'Save ₹1,600',
        currentPrice: '₹2,999',
        priceSubtext: 'Equivalent to ₹250 per month',
        btnText: 'Upgrade Plan',
        icon: LucideIcons.shieldCheck,
        iconBg: const Color(0xFFE6F4EA),
        iconColor: const Color(0xFF137333),
        features: [
          'Unlimited Accounting & Day Book Logs',
          'Live GST Filings & ITC Auto-Matching',
          'Basic Warehousing (1 site)',
          'Automated Payroll & Attendance Systems',
          'Email Support',
        ],
        isActive: false,
      ),
      _buildPlanCard(
        title: 'Growth Plan',
        desc: 'Built for scaling businesses and multi-site operations.',
        originalPrice: '₹9,999',
        savedPrice: 'Save ₹3,000',
        currentPrice: '₹6,999',
        priceSubtext: 'Equivalent to ₹583 per month',
        btnText: 'Upgrade Plan',
        icon: LucideIcons.zap,
        iconBg: const Color(0xFFE8F0FE),
        iconColor: Colors.blue,
        features: [
          'All features in Starter Plan',
          'Multi-warehouse Routing (up to 3 sites)',
          'Dedicated Bill of Materials (BOM)',
          'API Webhook Access & ERP Syncing',
          'Daily FIN-PRO Data Exporting (CSV/Excel)',
          'Priority Email & Live Chat Support',
        ],
        isActive: false,
      ),
      _buildPlanCard(
        title: 'Elite Suite',
        desc: 'Absolute control for national distribution networks.',
        originalPrice: '₹15,999',
        savedPrice: 'Save ₹7,000',
        currentPrice: '₹8,999',
        priceSubtext: 'Equivalent to ₹750 per month',
        btnText: 'Currently Active Plan',
        icon: LucideIcons.crown,
        iconBg: const Color(0xFFE0F2F1),
        iconColor: Colors.teal,
        features: [
          'All features in Growth Plan',
          'Uncapped active staff profiles',
          'Custom White-Label Invoicing Layouts',
          'Unlimited manufacturing batches & QC logs',
          'Guaranteed 99.99% uptime SLA service',
          'Dedicated FIN-PRO Account Manager assistance',
          'Priority 24/7/365 Direct VIP Phone Support',
        ],
        isActive: true,
      ),
    ];

    if (isMobile) {
      return Column(
        children: plans.map((p) => Padding(padding: const EdgeInsets.only(bottom: 20), child: p)).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: plans.map((p) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: p))).toList(),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String desc,
    required String originalPrice,
    required String savedPrice,
    required String currentPrice,
    required String priceSubtext,
    required String btnText,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required List<String> features,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isActive ? const Color(0xFF0C4A2C) : AppColors.border, width: isActive ? 1.8 : 1.0),
        boxShadow: isActive
            ? [BoxShadow(color: const Color(0xFF0C4A2C).withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const Spacer(),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ULTIMATE VALUE',
                    style: TextStyle(color: Colors.teal, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, height: 1.4)),
          const SizedBox(height: 16),

          // Pricing
          Row(
            children: [
              Text(originalPrice, style: const TextStyle(fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(4)),
                child: Text(savedPrice, style: const TextStyle(color: Color(0xFF137333), fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(currentPrice, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(width: 4),
              const Text('/ year', style: TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(priceSubtext, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500)),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isActive ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? const Color(0xFF0C4A2C) : Colors.transparent,
                foregroundColor: isActive ? Colors.white : const Color(0xFF137333),
                disabledBackgroundColor: const Color(0xFF0C4A2C),
                disabledForegroundColor: Colors.white,
                side: isActive ? BorderSide.none : const BorderSide(color: Color(0xFF137333)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(btnText, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),

          const Text("WHAT'S INCLUDED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),

          // Feature list
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.check, color: Color(0xFF137333), size: 13),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f, style: const TextStyle(fontSize: 11.5, color: Colors.black87, height: 1.3)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBillingHistorySection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.history, color: Color(0xFF137333), size: 16),
              SizedBox(width: 8),
              Text(
                'Billing & Statement History',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // SingleChildScrollView table with horizontal scroll fallback to prevent overflow on mobile!
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(110),
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('INVOICE ID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('BILLING DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('TIER DETAILS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('PAYMENT MODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('STATUS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('AMOUNT PAID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))),
                  ],
                ),
                // Table Row Data
                TableRow(
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('INV-2026-0743', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF137333)))),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('2026-07-08', style: TextStyle(fontSize: 11, color: Colors.black87))),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Elite Suite', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText))),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Cashfree PG', style: TextStyle(fontSize: 11, color: Colors.black87))),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Paid', style: TextStyle(color: Color(0xFF137333), fontSize: 9.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('₹8,999', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
