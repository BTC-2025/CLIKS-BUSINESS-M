import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../widgets/warehouse_transfer_dialog.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Stock Registry & Valuation, 1: Inward & Outward, 2: Warehouse Transfers, 3: Batches & Expiries

  final List<_TabItem> _tabs = [
    _TabItem('Stock Registry & Valuation', LucideIcons.box),
    _TabItem('Inward & Outward Logs', LucideIcons.arrowLeftRight),
    _TabItem('Warehouse Transfers', LucideIcons.truck),
    _TabItem('Batches & Expiries', LucideIcons.shieldAlert),
  ];

  void _triggerAdjustStock() {
    ref.read(navigationProvider.notifier).setRoute(AppRoute.adjustStock);
  }

  void _triggerWarehouseTransfer() {
    ref.read(navigationProvider.notifier).setRoute(AppRoute.warehouseTransfer);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      // Dropup Expandable FAB for Mobile
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 130),
              child: _ExpandableFab(
                onAdjustStock: _triggerAdjustStock,
                onWarehouseTransfer: _triggerWarehouseTransfer,
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting Style Header) ───
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
                  isMacOS
                      ? _buildMainContent(isMobile)
                      : _buildMainContent(isMobile)
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
  // DESKTOP ACTIONS
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
            onPressed: _triggerAdjustStock,
            icon: const Icon(LucideIcons.sliders, size: 14),
            label: const Text('Adjust Stock Counts', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD63384),
              side: const BorderSide(color: Color(0xFFF8D7DA)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _triggerWarehouseTransfer,
            icon: const Icon(LucideIcons.arrowLeftRight, size: 14),
            label: const Text('Warehouse Transfer', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D6EFD),
              side: const BorderSide(color: Color(0xFFD6E4FF)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY CARD (Accounting Style)
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
          // Header Title & Live Badge Row
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
                      child: const Icon(LucideIcons.box, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'STOCK & INVENTORY VALUATION',
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

          const SizedBox(height: 14),

          // Main Hero Number
          Text(
            'TOTAL INVENTORY VALUATION (COST)',
            style: TextStyle(
              fontSize: isMobile ? 9.5 : 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹0.00',
            style: TextStyle(
              fontSize: isMobile ? 28 : 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 16),

          // 3 Stat Chips in a row inside hero card
          Row(
            children: [
              _buildHeroChip('Low Stock Alerts', '0 Items', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Godowns Registered', '0 Units', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('In-Transit Stock', '0 Shifts', isMobile),
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

  // ═══════════════════════════════════════════════════════════════
  // TAB NAVIGATION (Accounting Style)
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

  // ═══════════════════════════════════════════════════════════════
  // MAIN CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_activeTab == 0) _buildRegistryView(isMobile),
          if (_activeTab == 1) _buildInwardOutwardView(isMobile),
          if (_activeTab == 2) _buildTransferView(isMobile),
          if (_activeTab == 3) _buildBatchView(isMobile),
        ],
      ),
    );
  }

  Widget _buildRegistryView(bool isMobile) {
    final headers = [
      'PRODUCT DESCRIPTION',
      'WAREHOUSE LOCATION',
      'CURRENT STOCK',
      'AVAILABLE STOCK',
      'DAMAGED / EXPIRED',
      'AVG COST',
      'TOTAL VALUATION',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Registry & Valuation Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen)),
        const SizedBox(height: 24),
        _buildTable(headers, isMobile, 'No recorded inventory items.'),
      ],
    );
  }

  Widget _buildInwardOutwardView(bool isMobile) {
    final headers = [
      'MOVEMENT ID',
      'DATE',
      'PRODUCT DESCRIPTION',
      'TYPE',
      'QTY MOVED',
      'REASON / DOC REF',
      'PERFORMED BY',
    ];

    final headerAction = _buildCompactDropdown('Select Product:', ['All Products']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stock Inward / Outward running ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen)),
              const SizedBox(height: 12),
              headerAction,
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stock Inward / Outward running ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen)),
              headerAction,
            ],
          ),
        const SizedBox(height: 24),
        _buildTable(headers, isMobile, 'No stock movement logs found.'),
      ],
    );
  }

  Widget _buildTransferView(bool isMobile) {
    final headers = [
      'TRANSFER ID',
      'PRODUCT DESCRIPTION',
      'FROM WAREHOUSE',
      'TO WAREHOUSE',
      'QTY TRANSFERRED',
      'STATUS',
    ];

    final headerAction = ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const WarehouseTransferDialog(),
        );
      },
      icon: const Icon(LucideIcons.plus, size: 14),
      label: const Text('Transfer Stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.stylishDarkGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Warehouse Branch transfers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen)),
              const SizedBox(height: 12),
              headerAction,
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Warehouse Branch transfers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen)),
              headerAction,
            ],
          ),
        const SizedBox(height: 24),
        _buildTable(headers, isMobile, 'No warehouse transfers recorded.'),
      ],
    );
  }

  Widget _buildBatchView(bool isMobile) {
    final headers = [
      'BATCH NUMBER',
      'PRODUCT DESCRIPTION',
      'MFG DATE',
      'EXPIRY DATE',
      'BATCH QTY',
      'DAYS TO EXPIRY',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Batch-Wise & Expiry Tracking (FIFO Engine)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen)),
        const SizedBox(height: 24),
        _buildTable(headers, isMobile, 'No batched stock items found.'),
      ],
    );
  }

  Widget _buildTable(List<String> headers, bool isMobile, String emptyMsg) {
    if (isMobile) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.box, size: 40, color: AppColors.secondaryText.withValues(alpha: 0.4)),
            const SizedBox(height: 10),
            Text(emptyMsg, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 900),
        child: Table(
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              children: headers.map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(
                  h,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                ),
              )).toList(),
            ),
            TableRow(
              children: List.generate(headers.length, (idx) {
                if (idx == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Text(emptyMsg, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
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

  Widget _buildCompactDropdown(String label, List<String> items) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Text(items.first, style: const TextStyle(fontSize: 11, color: AppColors.darkText)),
              const SizedBox(width: 6),
              const Icon(LucideIcons.chevronDown, size: 12, color: AppColors.secondaryText),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EXPANDABLE DROPUP FAB FOR MOBILE
// ═══════════════════════════════════════════════════════════════
class _ExpandableFab extends StatefulWidget {
  final VoidCallback onAdjustStock;
  final VoidCallback onWarehouseTransfer;

  const _ExpandableFab({
    required this.onAdjustStock,
    required this.onWarehouseTransfer,
  });

  @override
  State<_ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<_ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) {
        if (_open) _toggle();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAnimatedChild(
            1,
            _MiniFab(
              icon: LucideIcons.arrowLeftRight,
              label: 'Warehouse Transfer',
              color: const Color(0xFF0D6EFD), // Blue
              onPressed: () {
                _toggle();
                widget.onWarehouseTransfer();
              },
            ),
          ),
          _buildAnimatedChild(
            0,
            _MiniFab(
              icon: LucideIcons.sliders,
              label: 'Adjust Stock Counts',
              color: const Color(0xFFD63384), // Pink / Accent
              onPressed: () {
                _toggle();
                widget.onAdjustStock();
              },
            ),
          ),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildAnimatedChild(int index, Widget child) {
    final double start = (index * 0.1).clamp(0.0, 1.0);
    final double end = (start + 0.6).clamp(0.0, 1.0);

    final sizeAnim = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
      reverseCurve: Interval(start, end, curve: Curves.easeIn),
    );

    final fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
      reverseCurve: Interval(start, end, curve: Curves.easeIn),
    );

    return SizeTransition(
      sizeFactor: sizeAnim,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: fadeAnim,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildTapToOpenFab() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = ColorTween(
          begin: const Color(0xFF166534),
          end: const Color(0xFF1E293B),
        ).evaluate(_controller);

        return Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (color ?? Colors.green).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              customBorder: const CircleBorder(),
              child: RotationTransition(
                turns: Tween<double>(begin: 0.0, end: 0.125).animate(_expandAnimation),
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniFab extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MiniFab({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkText),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 48,
          width: 48,
          child: FloatingActionButton(
            heroTag: null,
            onPressed: onPressed,
            backgroundColor: color,
            elevation: 4,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 4),
      ],
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
