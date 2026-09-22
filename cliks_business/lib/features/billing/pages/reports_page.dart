import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

class _ReportCardData {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  _ReportCardData({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: All Reports, 1: Sales & Revenue, 2: Purchases, 3: Stock & Inventory, 4: CRM & Parties, 5: Finance & Tax

  final List<_TabItem> _tabs = [
    _TabItem('All Reports', LucideIcons.barChart2),
    _TabItem('Sales & Revenue', LucideIcons.trendingUp),
    _TabItem('Purchases', LucideIcons.shoppingBag),
    _TabItem('Stock & Inventory', LucideIcons.package),
    _TabItem('CRM & Parties', LucideIcons.users),
    _TabItem('Finance & Tax', LucideIcons.fileText),
  ];

  // ═══════════════════════════════════════════════════════════════
  // EXACT REPORT CONTENTS & WORDINGS
  // ═══════════════════════════════════════════════════════════════

  final List<_ReportCardData> _salesReports = [
    _ReportCardData(title: 'Sales Summary', icon: LucideIcons.trendingUp, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Item-wise Sales', icon: LucideIcons.box, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Party-wise Sales', icon: LucideIcons.users, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Bill-wise Profit', icon: LucideIcons.arrowUpRight, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Discount Report', icon: LucideIcons.indianRupee, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Item-wise Discount', icon: LucideIcons.clock, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Sales Agent Commissions', icon: LucideIcons.arrowUpRight, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Sales Returns Analysis', icon: LucideIcons.arrowDownRight, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
  ];

  final List<_ReportCardData> _purchasesReports = [
    _ReportCardData(title: 'Purchases Register', icon: LucideIcons.shoppingBag, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Vendor-wise Procurement', icon: LucideIcons.store, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Sales/Purchase Orders', icon: LucideIcons.fileText, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Sales/Purchases by Category', icon: LucideIcons.pieChart, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Procurement Payout Registry', icon: LucideIcons.creditCard, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Pending Vendor Dues', icon: LucideIcons.calendar, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
  ];

  final List<_ReportCardData> _stockReports = [
    _ReportCardData(title: 'Stock Summary', icon: LucideIcons.box, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Low Stock Report', icon: LucideIcons.arrowDownRight, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Stock by Item Category', icon: LucideIcons.pieChart, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Stock Movement', icon: LucideIcons.history, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Warehouse Capacity', icon: LucideIcons.store, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Dead Stock Register', icon: LucideIcons.xCircle, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
  ];

  final List<_ReportCardData> _crmReports = [
    _ReportCardData(title: 'Customer Statements', icon: LucideIcons.users, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Supplier Statements', icon: LucideIcons.store, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Aging Report', icon: LucideIcons.calendar, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Top Supplier Scorecard', icon: LucideIcons.barChart2, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Party Ledgers (All)', icon: LucideIcons.fileText, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
  ];

  final List<_ReportCardData> _financeReports = [
    _ReportCardData(title: 'GSTR-1 (Outward)', icon: LucideIcons.fileCheck, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'GSTR-3B Summary', icon: LucideIcons.calculator, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Daybook', icon: LucideIcons.bookOpen, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Profit and Loss', icon: LucideIcons.lineChart, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
    _ReportCardData(title: 'Balance Sheet', icon: LucideIcons.scale, iconColor: const Color(0xFFD63384), bgColor: const Color(0xFFFDE8E8)),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
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
            onPressed: () {
              AppSnackbar.show(context, "Automated email alert scheduled.", type: SnackType.info);
            },
            icon: const Icon(LucideIcons.mail, size: 14),
            label: const Text('Schedule Email Alert', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD63384),
              side: const BorderSide(color: Color(0xFFF8D7DA)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              AppSnackbar.show(context, "Exporting all reports...", type: SnackType.success);
            },
            icon: const Icon(LucideIcons.download, size: 14),
            label: const Text('Export All Reports', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                      child: const Icon(LucideIcons.lineChart, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'BUSINESS REPORTS',
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
              _buildHeroChip('TOTAL SALES REVENUE', '₹0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('TOTAL PURCHASING COST', '₹0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('TOTAL OPERATING EXPENSES', '₹0', isMobile),
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
    String sectionTitle = "";
    List<_ReportCardData> currentReports = [];

    switch (_activeTab) {
      case 0:
        sectionTitle = "All Business Reports";
        currentReports = [
          ..._salesReports,
          ..._purchasesReports,
          ..._stockReports,
          ..._crmReports,
          ..._financeReports,
        ];
        break;
      case 1:
        sectionTitle = "Sales & Revenue";
        currentReports = _salesReports;
        break;
      case 2:
        sectionTitle = "Purchases";
        currentReports = _purchasesReports;
        break;
      case 3:
        sectionTitle = "Stock & Inventory";
        currentReports = _stockReports;
        break;
      case 4:
        sectionTitle = "CRM & Parties";
        currentReports = _crmReports;
        break;
      case 5:
        sectionTitle = "Finance & Tax";
        currentReports = _financeReports;
        break;
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
                  sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildReportsGrid(currentReports, isMobile),
        ],
      ),
    );
  }

  Widget _buildReportsGrid(List<_ReportCardData> reportCards, bool isMobile) {
    if (isMobile) {
      return Column(
        children: reportCards.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: _buildReportGridCard(c),
        )).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: reportCards.map((c) => SizedBox(
            width: (constraints.maxWidth - 32) / 3,
            child: _buildReportGridCard(c),
          )).toList(),
        );
      },
    );
  }

  Widget _buildReportGridCard(_ReportCardData card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: card.bgColor, shape: BoxShape.circle),
                child: Icon(card.icon, color: card.iconColor, size: 18),
              ),
              IconButton(
                onPressed: () {
                  AppSnackbar.show(context, "Downloading ${card.title}...", type: SnackType.info);
                },
                icon: const Icon(LucideIcons.download, size: 16, color: AppColors.secondaryText),
                tooltip: 'Download Report',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              AppSnackbar.show(context, "Opening ${card.title}...", type: SnackType.info);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VIEW REPORT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: card.iconColor),
                ),
                const SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, size: 12, color: card.iconColor),
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
