import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../widgets/app_ui_kit.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  int _activeTab = 0; // 0: Customers List, 1: Aging & Collection Reports

  final List<_TabItem> _tabs = [
    _TabItem('Customers List', LucideIcons.users),
    _TabItem('Collection Reports', LucideIcons.pieChart),
  ];

  void _triggerPrimaryAction() {
    ref.read(navigationProvider.notifier).setRoute(AppRoute.addCustomer);
  }

  void _triggerSecondaryAction() {
    AppSnackbar.show(
      context,
      "Opening CSV bulk import sheet. Please select a customer spreadsheet file.",
      type: SnackType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: FloatingActionButton.extended(
                onPressed: _triggerPrimaryAction,
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Add Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── FINANCIAL SUMMARY HERO CARD ───
          SliverToBoxAdapter(
            child: isMacOS
                ? _buildHeroSummary(isMobile)
                : _buildHeroSummary(isMobile)
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

          // ─── TAB CONTENT ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 90 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDesktopActions(isMobile),
                  if (!isMobile) const SizedBox(height: 12),
                  isMacOS
                      ? _buildMainContent(isMobile)
                      : _buildMainContent(isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopActions(bool isMobile) {
    if (isMobile) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _triggerSecondaryAction,
            icon: const Icon(LucideIcons.uploadCloud, size: 14),
            label: const Text('Bulk Import (CSV)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _triggerPrimaryAction,
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Add Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY (replaces action strip + stat cards)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 8 : 16, isMobile ? 14 : 24, 0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL OUTSTANDING',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹0',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.alertCircle, size: 13, color: Colors.greenAccent.shade100),
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
          Row(
            children: [
              _buildHeroChip('Active', '0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Advance', '₹0', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Efficiency', '100%', isMobile),
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
              style: TextStyle(
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 2),
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

  Widget _buildMainContent(bool isMobile) {
    if (_activeTab == 1) {
      return _buildAgingCollectionTab(isMobile);
    }
    return _buildCustomersListTab(isMobile);
  }

  Widget _buildCustomersListTab(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterRow(isMobile),
          const SizedBox(height: 20),
          _buildTableOrList(isMobile),
        ],
      ),
    );
  }

  Widget _buildAgingCollectionTab(bool isMobile) {
    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Outstanding Receivables Ledger
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(LucideIcons.alertCircle, color: Color(0xFFDC3545), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Outstanding Receivables Ledger',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'No outstanding receivables logged.',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),

        // Card 2: Outstanding Aging Reports
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(LucideIcons.clock, color: Colors.blueGrey, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Outstanding Aging Reports',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isMobile
                  ? Column(
                      children: [
                        _buildAgingBox('0-15 Days', '₹0', Colors.blue.shade600, const Color(0xFFE0F7FA)),
                        const SizedBox(height: 12),
                        _buildAgingBox('16 - 30 Days', '₹0', Colors.orange.shade700, const Color(0xFFFFF3E0)),
                        const SizedBox(height: 12),
                        _buildAgingBox('31+ Days', '₹0', Colors.red.shade700, const Color(0xFFFFEBEE)),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildAgingBox('0-15 Days', '₹0', Colors.blue.shade600, const Color(0xFFE0F7FA))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAgingBox('16 - 30 Days Overdue', '₹0', Colors.orange.shade700, const Color(0xFFFFF3E0))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAgingBox('31+ Days Critical', '₹0', Colors.red.shade700, const Color(0xFFFFEBEE))),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );

    final rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Collection Efficiency Rate
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Text(
                'Collection Efficiency Rate',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const SizedBox(height: 32),
              // Circular Graph / Efficiency Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ),
                  const Text(
                    '100%',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Collection efficiency indicates recovered payments out of overall credit sales.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),

        // Card 2: Top Customer Sales Contribution
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(LucideIcons.trendingUp, color: Colors.purple, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Top Customer Sales Contribution',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'No customer sales contribution logged yet.',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          leftColumn,
          const SizedBox(height: 20),
          rightColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 11, child: leftColumn),
        const SizedBox(width: 24),
        Expanded(flex: 9, child: rightColumn),
      ],
    );
  }

  Widget _buildAgingBox(String label, String value, Color textColor, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5A7184))),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildFilterRow(bool isMobile) {
    final searchField = Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SizedBox(width: 12),
          Icon(LucideIcons.search, size: 16, color: Color(0xFF9CA3AF)),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name, business or phone...',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );

    final filters = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDropdown('All Types'),
          const SizedBox(width: 8),
          _buildDropdown('All Balances'),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchField,
          const SizedBox(height: 12),
          filters,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 4, child: searchField),
        const SizedBox(width: 16),
        filters,
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }

  Widget _buildTableOrList(bool isMobile) {
    final headers = [
      'CUSTOMER NAME',
      'BUSINESS / CONTACT',
      'GSTIN',
      'CREDIT LIMIT',
      'OUTSTANDING',
      'CREDIT STATUS',
      'LOYALTY PTS',
      'ACTIONS',
    ];

    if (isMobile) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.users, size: 40, color: AppColors.secondaryText.withValues(alpha: 0.4)),
            const SizedBox(height: 10),
            const Text(
              'No active customers matched.',
              style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 900),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.8),
            1: FlexColumnWidth(1.8),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.2),
            4: FlexColumnWidth(1.2),
            5: FlexColumnWidth(1.2),
            6: FlexColumnWidth(1.0),
            7: FlexColumnWidth(1.2),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1.5)),
              ),
              children: headers.map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(
                  h,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                ),
              )).toList(),
            ),
            TableRow(
              children: List.generate(headers.length, (idx) {
                if (idx == 1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No active customers found.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  );
                }
                return const SizedBox();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyTabNavDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyTabNavDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyTabNavDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
