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
    final isTablet = screenWidth >= 700 && screenWidth < 1000;
    final isDesktop = screenWidth >= 1000;
    final isCompactMobile = isMobile && screenWidth < 400;

    final activeIds = ref.watch(dashboardShortcutsProvider);
    final activeShortcuts = allDashboardShortcuts
        .where((s) => activeIds.contains(s.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9), // Subtle clean tint
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── 1. TOP BUSINESS OVERVIEW HEADER (Reference 1) ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isCompactMobile ? 12 : (isMobile ? 14 : 24),
                isCompactMobile ? 8 : (isMobile ? 12 : 20),
                isCompactMobile ? 12 : (isMobile ? 14 : 24),
                0,
              ),
              child: _buildBusinessOverviewHeader(context, isMobile),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: isCompactMobile ? 10 : 18),
          ),

          // ─── 2. 4 TOP KPI METRIC CARDS ROW (Reference 1) ───
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompactMobile ? 12 : (isMobile ? 14 : 24),
            ),
            sliver: SliverToBoxAdapter(
              child: _buildMetricCards(
                context,
                ref,
                isMobile,
                isTablet,
                isDesktop,
                isCompactMobile,
              ),
            ),
          ),

          // ─── SALES TIMEFRAME INFORMATION BAR (Reference 1) ───
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isCompactMobile ? 12 : (isMobile ? 14 : 24),
                16,
                isCompactMobile ? 12 : (isMobile ? 14 : 24),
                0,
              ),
              child: _buildSalesTimeframeInfoBar(isMobile),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: isCompactMobile ? 10 : 20),
          ),

          // ─── 3. QUICK ACTION CENTER (BENTO MODULE) ───
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompactMobile ? 12 : (isMobile ? 14 : 24),
            ),
            sliver: SliverToBoxAdapter(
              child: BentoCard(
                title: 'Quick Action Center',
                subtitle: isCompactMobile
                    ? null
                    : 'Rapid navigation to essential business tasks & workflows',
                icon: LucideIcons.zap,
                iconColor: const Color(0xFF166534),
                iconBackgroundColor: const Color(0xFFDCF2E4),
                padding: EdgeInsets.all(isCompactMobile ? 12 : 24),
                badge: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompactMobile ? 6 : 7,
                    vertical: isCompactMobile ? 2 : 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCF2E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '1-CLICK ACCESS',
                    style: GoogleFonts.inter(
                      fontSize: isCompactMobile ? 8.5 : 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF166534),
                      letterSpacing: 0.4,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompactMobile ? 8 : 10,
                      vertical: isCompactMobile ? 4 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.slidersHorizontal,
                          size: isCompactMobile ? 11 : 13,
                          color: const Color(0xFF475569),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Configure',
                          style: GoogleFonts.inter(
                            fontSize: isCompactMobile ? 10.5 : 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                child: isCompactMobile
                    ? _buildCompactMobileShortcutsGrid(
                        context,
                        ref,
                        activeShortcuts,
                      )
                    : Wrap(
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

          SliverToBoxAdapter(
            child: SizedBox(height: isCompactMobile ? 10 : 28),
          ),

          // ─── 4. ANALYTICS & CHARTS SECTION ───
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompactMobile ? 12 : (isMobile ? 14 : 24),
            ),
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
                              child: _buildExpenseDistributionCard(
                                context,
                                ref,
                                isCompactMobile,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTopPerformingProductsCard(
                          context,
                          ref,
                          isCompactMobile,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildSalesPerformanceCard(context),
                        SizedBox(height: isCompactMobile ? 10 : 18),
                        _buildExpenseDistributionCard(
                          context,
                          ref,
                          isCompactMobile,
                        ),
                        SizedBox(height: isCompactMobile ? 10 : 18),
                        _buildTopPerformingProductsCard(
                          context,
                          ref,
                          isCompactMobile,
                        ),
                      ],
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: isCompactMobile ? 60 : 36),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessOverviewHeader(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 22,
        vertical: isMobile ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Mint/light green background (Reference 1)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCF2E4), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06166534),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderTitleSection(),
                const SizedBox(height: 14),
                _buildHeaderControlsSection(context),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildHeaderTitleSection()),
                const SizedBox(width: 16),
                _buildHeaderControlsSection(context),
              ],
            ),
    );
  }

  Widget _buildHeaderTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF166534),
            borderRadius: BorderRadius.circular(11),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26166534),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              LucideIcons.layoutDashboard,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Business Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF2E4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF166534),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF166534),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'Monitor your enterprise performance, revenues, procurement and operational workflows.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderControlsSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FY and Date Selector Pill (Reference 1)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.calendar, size: 14, color: Color(0xFF166534)),
              SizedBox(width: 6),
              Text(
                'FY 2026-27',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Customize Dashboard Button (Reference 1)
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ConfigureQuickActionsDialog(),
            );
          },
          icon: const Icon(LucideIcons.slidersHorizontal, size: 14, color: Color(0xFF166534)),
          label: const Text(
            'Customize Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: Color(0xFF166534),
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF166534)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesTimeframeInfoBar(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: const [
          Icon(LucideIcons.info, size: 14, color: Color(0xFF475569)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Consolidated Enterprise Analytics • Financial Period 2026-2027 • Real-time cloud sync active',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
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
    bool isCompactMobile,
  ) {
    if (isCompactMobile) {
      return _buildCompactMobileMetricCards(context, ref);
    }

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

    final netProfitCard = BentoMetricCard(
      label: 'Estimated Net Profit',
      value: '₹0',
      icon: LucideIcons.wallet,
      iconColor: const Color(0xFF166534),
      iconBg: const Color(0xFFDCF2E4),
      trendText: 'Margin: 0.0%',
      isTrendPositive: true,
      footerText: 'Gross Operational Yield',
      onTap: () {
        ref.read(navigationProvider.notifier).setRoute(AppRoute.accounting);
      },
      animationDelayMs: 200,
    );

    if (isMobile) {
      return Column(
        children: [
          revenueCard,
          const SizedBox(height: 12),
          purchasesCard,
          const SizedBox(height: 12),
          expensesCard,
          const SizedBox(height: 12),
          netProfitCard,
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: revenueCard),
              const SizedBox(width: 14),
              Expanded(child: purchasesCard),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: expensesCard),
              const SizedBox(width: 14),
              Expanded(child: netProfitCard),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: revenueCard),
        const SizedBox(width: 14),
        Expanded(child: purchasesCard),
        const SizedBox(width: 14),
        Expanded(child: expensesCard),
        const SizedBox(width: 14),
        Expanded(child: netProfitCard),
      ],
    );
  }

  Widget _buildCompactMobileMetricCards(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        // Primary Revenue Card (Full Width Compact)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                ref.read(navigationProvider.notifier).setRoute(AppRoute.sales);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCF2E4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.trendingUp,
                        color: Color(0xFF166534),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Sales Revenue',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 1),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '₹10,21,25,50,71,294',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111827),
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCF2E4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF166534),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Live',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF166534),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.arrowUpRight,
                      size: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Left and Right Compact Metrics: Purchases & Expenses
        Row(
          children: [
            Expanded(
              child: _buildCompactMiniMetric(
                label: 'Total Purchases',
                value: '₹13,84,791',
                icon: LucideIcons.shoppingCart,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
                trendText: '+4.2%',
                isTrendPositive: true,
                onTap: () {
                  ref.read(navigationProvider.notifier).setRoute(AppRoute.purchase);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactMiniMetric(
                label: 'Total Expenses',
                value: '₹3,14,61,64,...',
                icon: LucideIcons.banknote,
                iconColor: const Color(0xFFEA580C),
                iconBg: const Color(0xFFFFF7ED),
                trendText: 'Overhead',
                isTrendPositive: false,
                onTap: () {
                  ref.read(navigationProvider.notifier).setRoute(AppRoute.expenses);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactMiniMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String trendText,
    required bool isTrendPositive,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, color: iconColor, size: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isTrendPositive
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trendText,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isTrendPositive
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFEA580C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMobileShortcutsGrid(
    BuildContext context,
    WidgetRef ref,
    List<QuickActionItem> activeShortcuts,
  ) {
    final items = <Widget>[];
    for (final shortcut in activeShortcuts) {
      items.add(
        _CompactMobileShortcutButton(
          label: shortcut.label,
          icon: shortcut.icon,
          color: shortcut.color,
          onTap: () {
            ref.read(navigationProvider.notifier).setRoute(shortcut.route);
          },
        ),
      );
    }

    items.add(
      _CompactMobileManageShortcutsButton(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const ConfigureQuickActionsDialog(),
          );
        },
      ),
    );

    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = (i + 1 < items.length) ? items[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 8),
            Expanded(
              child: right ?? const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < items.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
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

  Widget _buildExpenseDistributionCard(
    BuildContext context,
    WidgetRef ref, [
    bool isCompactMobile = false,
  ]) {
    return BentoCard(
      title: 'Expense Distribution',
      subtitle: isCompactMobile
          ? null
          : 'Categorical allocation grouped by operational expense heads',
      icon: LucideIcons.pieChart,
      iconColor: const Color(0xFFEA580C),
      iconBackgroundColor: const Color(0xFFFFF7ED),
      padding: EdgeInsets.all(isCompactMobile ? 12 : 24),
      badge: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompactMobile ? 6 : 7,
          vertical: isCompactMobile ? 2 : 2.5,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'BREAKDOWN',
          style: GoogleFonts.inter(
            fontSize: isCompactMobile ? 8.5 : 9.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFEA580C),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isCompactMobile ? 12 : 20,
          vertical: isCompactMobile ? 16 : 28,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isCompactMobile ? 36 : 50,
              height: isCompactMobile ? 36 : 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.receipt,
                size: isCompactMobile ? 18 : 24,
                color: const Color(0xFFEA580C),
              ),
            ),
            SizedBox(height: isCompactMobile ? 10 : 14),
            Text(
              'No Expense Data Logged',
              style: GoogleFonts.inter(
                fontSize: isCompactMobile ? 13 : 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Record operational business expenses to view your category distribution matrix and overhead audits.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isCompactMobile ? 11 : 12,
                color: const Color(0xFF6B7280),
                height: 1.35,
              ),
            ),
            SizedBox(height: isCompactMobile ? 12 : 16),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(navigationProvider.notifier).setRoute(AppRoute.recordExpense);
              },
              icon: Icon(LucideIcons.plus, size: isCompactMobile ? 12 : 14),
              label: Text(
                'Record Expense',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: isCompactMobile ? 11 : 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF166534),
                side: const BorderSide(color: Color(0xFF166534)),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompactMobile ? 12 : 16,
                  vertical: isCompactMobile ? 6 : 9,
                ),
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

  Widget _buildTopPerformingProductsCard(
    BuildContext context,
    WidgetRef ref, [
    bool isCompactMobile = false,
  ]) {
    return BentoCard(
      title: 'Top Performing Products',
      subtitle: isCompactMobile
          ? null
          : 'Highest volume contributors & sales velocity matrix',
      icon: LucideIcons.package,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      padding: EdgeInsets.all(isCompactMobile ? 12 : 24),
      badge: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompactMobile ? 6 : 8,
          vertical: isCompactMobile ? 2 : 3,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF93C5FD), width: 0.5),
        ),
        child: Text(
          'VOLUME MATRIX',
          style: GoogleFonts.inter(
            color: const Color(0xFF1D4ED8),
            fontSize: isCompactMobile ? 8.5 : 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      trailing: TextButton.icon(
        onPressed: () {
          ref.read(navigationProvider.notifier).setRoute(AppRoute.products);
        },
        icon: Icon(LucideIcons.arrowRight, size: isCompactMobile ? 11 : 13),
        label: Text(
          'View All Products',
          style: GoogleFonts.inter(
            fontSize: isCompactMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF166534),
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isCompactMobile ? 18 : 36,
          horizontal: isCompactMobile ? 12 : 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: isCompactMobile ? 36 : 46,
              height: isCompactMobile ? 36 : 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.boxes,
                size: isCompactMobile ? 18 : 22,
                color: const Color(0xFF2563EB),
              ),
            ),
            SizedBox(height: isCompactMobile ? 10 : 12),
            Text(
              'No Product Sales Analytics Logged Yet',
              style: GoogleFonts.inter(
                fontSize: isCompactMobile ? 12.5 : 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'As sales orders and invoice line items are fulfilled, top contributing items will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isCompactMobile ? 11 : 12,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: isCompactMobile ? 12 : 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(navigationProvider.notifier).setRoute(AppRoute.registerProduct);
              },
              icon: Icon(LucideIcons.plus, size: isCompactMobile ? 12 : 14),
              label: Text(
                'Register Product',
                style: GoogleFonts.inter(
                  fontSize: isCompactMobile ? 11 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isCompactMobile ? 12 : 16,
                  vertical: isCompactMobile ? 6 : 9,
                ),
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

class _CompactMobileShortcutButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactMobileShortcutButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  LucideIcons.arrowUpRight,
                  size: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactMobileManageShortcutsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CompactMobileManageShortcutsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFF86EFAC),
            borderRadius: 10,
            dashLength: 3.5,
            spaceLength: 3.0,
            strokeWidth: 1.0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCF2E4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    LucideIcons.plus,
                    color: Color(0xFF166534),
                    size: 12,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '+ Manage',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF166534),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
