import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

class PurchaseInvoicePage extends ConsumerStatefulWidget {
  const PurchaseInvoicePage({super.key});

  @override
  ConsumerState<PurchaseInvoicePage> createState() => _PurchaseInvoicePageState();
}

class _PurchaseInvoicePageState extends ConsumerState<PurchaseInvoicePage>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0;

  final List<_TabItem> _tabs = [
    _TabItem('Purchase Orders (PO)', LucideIcons.shoppingCart),
    _TabItem('Purchase Bills & Invoices', LucideIcons.fileText),
    _TabItem('Returns (Debit Notes)', LucideIcons.undo2),
  ];

  void _onActionSelected(AppRoute route) {
    ref.read(navigationProvider.notifier).setRoute(route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: _ExpandableFab(onActionSelected: _onActionSelected),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── FINANCIAL SUMMARY HERO CARD ───
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

          // ─── TAB CONTENT ───
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
                  _buildMainContent(isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms),
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
            onPressed: () => _onActionSelected(AppRoute.newPO),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('New PO', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD63384),
              side: const BorderSide(color: Color(0xFFF8D7DA)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _onActionSelected(AppRoute.newPurchaseBill),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('New Purchase Bill', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D6EFD),
              side: const BorderSide(color: Color(0xFFD6E4FF)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _onActionSelected(AppRoute.purchaseReturn),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Purchase Return', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7C3AED),
              side: const BorderSide(color: Color(0xFFE5D4FF)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OUTWARD PROCUREMENT (AT COST)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981), // Green indicator
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  title: 'ACTIVE PO CYCLES',
                  value: '0',
                  icon: LucideIcons.shoppingCart,
                  isMobile: isMobile,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _buildMiniStat(
                  title: 'CLAIMABLE ITC',
                  value: '₹0',
                  icon: LucideIcons.percent,
                  isMobile: isMobile,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _buildMiniStat(
                  title: 'REFUND ADJ.',
                  value: '₹0',
                  icon: LucideIcons.refreshCcw,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String title,
    required String value,
    required IconData icon,
    required bool isMobile,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB NAVIGATION
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
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
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
  // MAIN CONTENT (TABLE OR LIST)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile) {
    String title = "";
    String emptyMessage = "";
    List<String> filters = ['All', 'Active', 'Completed', 'Cancelled'];

    switch (_activeTab) {
      case 0:
        title = "Purchase Orders (PO)";
        emptyMessage = "No active purchase orders found.";
        break;
      case 1:
        title = "Purchase Bills Register";
        emptyMessage = "No purchase bills recorded.";
        break;
      case 2:
        title = "Purchase Returns & Debit Notes";
        emptyMessage = "No active replacement claims found in system database.";
        filters = ['All', 'Pending', 'Processed', 'Rejected'];
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    _buildSmallActionBtn('All', LucideIcons.list, () {}),
                    const SizedBox(width: 6),
                    _buildSmallActionBtn('Excel', LucideIcons.download, () {}),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 38,
              child: TextField(
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search $title...',
                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                  prefixIcon: const Icon(LucideIcons.search, size: 14, color: AppColors.secondaryText),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                ),
              ),
            ),
          ),

          // Status filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: filters.map((s) {
                  final isActive = s == 'All';
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? _getTabColor(_activeTab) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Empty state
          Padding(
            padding: const EdgeInsets.all(30),
            child: Center(child: Text(emptyMessage, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText))),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Color _getTabColor(int index) {
    return const Color(0xFF2563EB); // Match the Purchases solid blue theme color
  }

  Widget _buildSmallActionBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: const Color(0xFF6B7280)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SLIVER DELEGATE FOR STICKY TABS
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
  bool shouldRebuild(covariant _StickyTabNavDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM EXPANDABLE FLOATING ACTION BUTTON (SPEED DIAL)
// ═══════════════════════════════════════════════════════════════
class _ExpandableFab extends StatefulWidget {
  final void Function(AppRoute) onActionSelected;
  const _ExpandableFab({required this.onActionSelected});

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<_ExpandableFab> with SingleTickerProviderStateMixin {
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
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
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

  void _handleAction(AppRoute route) {
    _toggle();
    widget.onActionSelected(route);
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
            2,
            _MiniFab(
              icon: LucideIcons.undo2,
              label: 'Purchase Return',
              color: const Color(0xFF7C3AED), // Purple
              onPressed: () => _handleAction(AppRoute.purchaseReturn),
            ),
          ),
          _buildAnimatedChild(
            1,
            _MiniFab(
              icon: LucideIcons.fileText,
              label: 'New Purchase Bill',
              color: const Color(0xFF0D6EFD), // Blue
              onPressed: () => _handleAction(AppRoute.newPurchaseBill),
            ),
          ),
          _buildAnimatedChild(
            0,
            _MiniFab(
              icon: LucideIcons.shoppingCart,
              label: 'New PO',
              color: const Color(0xFFD63384), // Pink
              onPressed: () => _handleAction(AppRoute.newPO),
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
    
    // For size, use a smooth curve without overshoot to prevent layout jitter in Scaffold
    final sizeAnim = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
      reverseCurve: Interval(start, end, curve: Curves.easeIn),
    );

    // Fade animation
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
        // Color transition
        final color = ColorTween(
          begin: const Color(0xFF3B82F6),
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
                color: (color ?? Colors.blue).withValues(alpha: 0.4),
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
      }
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
            heroTag: null, // Avoid hero tag conflicts if page routes happen
            onPressed: onPressed,
            backgroundColor: color,
            elevation: 4,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 4), // offset perfectly over the center of the 56px main button
      ],
    );
  }
}
