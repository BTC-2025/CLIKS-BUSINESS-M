import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/navigation/navigation_provider.dart';
import '../../widgets/bento/bento.dart';
import 'widgets/configure_quick_actions_dialog.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;
    final isDesktop = screenWidth >= 1100;
    final isMacOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

    final activeIds = ref.watch(dashboardShortcutsProvider);
    final activeShortcuts = allDashboardShortcuts
        .where((s) => activeIds.contains(s.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9), // Subtle clean tint
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── 1. TOP BENTO HERO BANNER ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 14 : 24,
                isMobile ? 12 : 20,
                isMobile ? 14 : 24,
                0,
              ),
              child: isMacOS
                  ? MacOsSoftUiBentoHero(
                      title: 'Business Overview',
                      mainValue: '₹10,21,25,50,71,294',
                      subtitle: 'Monitor your enterprise performance and operations.',
                      badgeText: 'LIVE',
                      isMobile: isMobile,
                      margin: EdgeInsets.zero,
                      chips: const [
                        MacOsBentoHeroChip(
                          label: 'Revenue',
                          value: '₹10,21,25,50,71,294',
                          icon: LucideIcons.trendingUp,
                          accentColor: Color(0xFF166534),
                        ),
                        MacOsBentoHeroChip(
                          label: 'Purchases',
                          value: '₹13,84,791',
                          icon: LucideIcons.shoppingCart,
                          accentColor: Color(0xFF2563EB),
                        ),
                        MacOsBentoHeroChip(
                          label: 'Operating Expenses',
                          value: '₹3,14,61,64,99,53,93,93...',
                          icon: LucideIcons.banknote,
                          accentColor: Color(0xFFDC2626),
                        ),
                        MacOsBentoHeroChip(
                          label: 'Est. Net Profit',
                          value: '₹0',
                          icon: LucideIcons.wallet,
                          accentColor: Color(0xFF166534),
                        ),
                      ],
                      trailingAction: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const ConfigureQuickActionsDialog(),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.settings2,
                                size: 12,
                                color: Color(0xFF334155),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Customise',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : BentoHeroBanner(
                      title: 'BUSINESS OVERVIEW',
                      netProfitText: 'Est. Net Profit: ₹0',
                      isMobile: isMobile,
                      chips: const [
                        BentoHeroChipData(
                          label: 'Revenue',
                          value: '₹10,21,25,50,71,294',
                          icon: LucideIcons.trendingUp,
                        ),
                        BentoHeroChipData(
                          label: 'Purchases',
                          value: '₹13,84,791',
                          icon: LucideIcons.shoppingCart,
                        ),
                        BentoHeroChipData(
                          label: 'Expenses',
                          value: '₹3,14,61,64,99,53,93,93...',
                          icon: LucideIcons.banknote,
                        ),
                      ],
                      onCustomiseTap: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const ConfigureQuickActionsDialog(),
                        );
                      },
                    )
                      .animate()
                      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                      .slideY(begin: -0.04, end: 0, curve: Curves.easeOut),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          // ─── 2. BENTO METRIC CARDS ───
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
            sliver: SliverToBoxAdapter(
              child: _buildMetricCards(context, ref, isMobile, isTablet, isDesktop),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 28),
          ),

          // ─── 3. QUICK ACTION CENTER (BENTO MODULE) ───
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
            sliver: SliverToBoxAdapter(
              child: BentoCard(
                title: 'Quick Action Center',
                subtitle: 'Rapid navigation to essential business tasks & workflows',
                icon: LucideIcons.zap,
                iconColor: const Color(0xFF166534),
                iconBackgroundColor: const Color(0xFFDCF2E4),
                badge: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCF2E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '1-CLICK ACCESS',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                trailing: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          const ConfigureQuickActionsDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.slidersHorizontal,
                            size: 13, color: Color(0xFF475569)),
                        const SizedBox(width: 5),
                        Text(
                          'Configure',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...activeShortcuts.map(
                      (shortcut) => BentoActionCard(
                        label: shortcut.label,
                        icon: shortcut.icon,
                        color: shortcut.color,
                        onTap: () {
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(shortcut.route);
                        },
                      ),
                    ),
                    _ManageShortcutsDashedButton(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const ConfigureQuickActionsDialog(),
                        );
                      },
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.03, end: 0, curve: Curves.easeOut),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 28),
          ),

          // ─── 4. ANALYTICS & CHARTS SECTION ───
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
            sliver: SliverToBoxAdapter(
              child: isDesktop
                  ? Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildSalesPerformanceCard(context),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: _buildExpenseDistributionCard(context, ref),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTopPerformingProductsCard(context, ref),
                      ],
                    )
                  : Column(
                      children: [
                        _buildSalesPerformanceCard(context),
                        const SizedBox(height: 18),
                        _buildExpenseDistributionCard(context, ref),
                        const SizedBox(height: 18),
                        _buildTopPerformingProductsCard(context, ref),
                      ],
                    ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards(
    BuildContext context,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final revenueCard = BentoMetricCard(
      label: 'Total Sales Revenue',
      value: '₹10,21,25,50,71,294',
      icon: LucideIcons.trendingUp,
      iconColor: const Color(0xFF166534),
      iconBg: const Color(0xFFDCF2E4),
      hasLiveBadge: true,
      footerText: 'Fiscal Year Cumulative Sales',
      onTap: () {
        ref.read(navigationProvider.notifier).setRoute(AppRoute.sales);
      },
      animationDelayMs: 50,
    );

    final purchasesCard = BentoMetricCard(
      label: 'Total Purchases',
      value: '₹13,84,791',
      icon: LucideIcons.shoppingCart,
      iconColor: const Color(0xFF2563EB),
      iconBg: const Color(0xFFEFF6FF),
      trendText: '+4.2%',
      isTrendPositive: true,
      footerText: 'Vendor Orders & Inward Goods',
      onTap: () {
        ref.read(navigationProvider.notifier).setRoute(AppRoute.purchase);
      },
      animationDelayMs: 100,
    );

    final expensesCard = BentoMetricCard(
      label: 'Total Expenses',
      value: '₹3,14,61,64,99,53,93,93,80,00,00,00,00,00,00,00,00,00,00,000',
      icon: LucideIcons.banknote,
      iconColor: const Color(0xFFEA580C),
      iconBg: const Color(0xFFFFF7ED),
      trendText: 'Overhead',
      isTrendPositive: false,
      footerText: 'Operating & Admin Expenses',
      onTap: () {
        ref.read(navigationProvider.notifier).setRoute(AppRoute.expenses);
      },
      animationDelayMs: 150,
    );

    if (isMobile) {
      return Column(
        children: [
          revenueCard,
          const SizedBox(height: 12),
          purchasesCard,
          const SizedBox(height: 12),
          expensesCard,
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          revenueCard,
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: purchasesCard),
              const SizedBox(width: 14),
              Expanded(child: expensesCard),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: revenueCard),
        const SizedBox(width: 16),
        Expanded(child: purchasesCard),
        const SizedBox(width: 16),
        Expanded(child: expensesCard),
      ],
    );
  }

  Widget _buildSalesPerformanceCard(BuildContext context) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const salesValues = [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0
    ];

    return const BentoChartCard(
      title: 'Sales Performance Analytics',
      subtitle: 'Interactive monthly sales aggregation graph & revenue trends',
      metricLabel: 'Aggregated Turnover',
      metricValue: '₹10,21,25,50,71,294',
      changePercentage: '+18.4%',
      xLabels: months,
      values: salesValues,
      maxY: 1000.0,
      lineColor: Color(0xFF166534),
      gradientStartColor: Color(0xFFDCF2E4),
    );
  }

  Widget _buildExpenseDistributionCard(BuildContext context, WidgetRef ref) {
    return BentoCard(
      title: 'Expense Distribution',
      subtitle: 'Categorical allocation grouped by operational expense heads',
      icon: LucideIcons.pieChart,
      iconColor: const Color(0xFFEA580C),
      iconBackgroundColor: const Color(0xFFFFF7ED),
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'BREAKDOWN',
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFEA580C),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(LucideIcons.receipt,
                  size: 24, color: Color(0xFFEA580C)),
            ),
            const SizedBox(height: 14),
            Text(
              'No Expense Data Logged',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Record operational business expenses to view your category distribution matrix and overhead audits.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(navigationProvider.notifier).setRoute(AppRoute.recordExpense);
              },
              icon: const Icon(LucideIcons.plus, size: 14),
              label: Text(
                'Record Expense',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF166534),
                side: const BorderSide(color: Color(0xFF166534)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformingProductsCard(BuildContext context, WidgetRef ref) {
    return BentoCard(
      title: 'Top Performing Products',
      subtitle: 'Highest volume contributors & sales velocity matrix',
      icon: LucideIcons.package,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      badge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF93C5FD), width: 0.5),
        ),
        child: Text(
          'VOLUME MATRIX',
          style: GoogleFonts.inter(
            color: const Color(0xFF1D4ED8),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      trailing: TextButton.icon(
        onPressed: () {
          ref.read(navigationProvider.notifier).setRoute(AppRoute.products);
        },
        icon: const Icon(LucideIcons.arrowRight, size: 13),
        label: Text(
          'View All Products',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF166534),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.boxes,
                  size: 22, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 12),
            Text(
              'No Product Sales Analytics Logged Yet',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'As sales orders and invoice line items are fulfilled, top contributing items will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(navigationProvider.notifier).setRoute(AppRoute.registerProduct);
              },
              icon: const Icon(LucideIcons.plus, size: 14),
              label: Text(
                'Register Product',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageShortcutsDashedButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ManageShortcutsDashedButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFF86EFAC),
            borderRadius: 12,
            dashLength: 4.0,
            spaceLength: 3.5,
            strokeWidth: 1.2,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.plus, color: Color(0xFF166534), size: 14),
                const SizedBox(width: 6),
                Text(
                  '+ Manage Shortcuts',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF166534),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double spaceLength;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashLength = 4.0,
    this.spaceLength = 3.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = distance;
        final end = distance + dashLength;
        final segment = metric.extractPath(
          start,
          end > metric.length ? metric.length : end,
        );
        canvas.drawPath(segment, paint);
        distance += dashLength + spaceLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashLength != oldDelegate.dashLength ||
      spaceLength != oldDelegate.spaceLength ||
      borderRadius != oldDelegate.borderRadius;
}
