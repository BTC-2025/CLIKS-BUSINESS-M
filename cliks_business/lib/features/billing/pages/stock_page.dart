import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/warehouse_transfer_dialog.dart';

// ─── DATA MODELS ──────────────────────────────────────────────

class StockItem {
  final String name;
  final String sku;
  final String warehouse;
  final bool isDamagedWarehouse;
  int currentStock;
  int availableStock;
  final int dmgCount;
  final int expCount;
  final double avgCost;
  double totalValuation;
  final int startQty;
  int dailySold;
  double dailySoldVal;
  int weeklySold;
  double weeklySoldVal;
  final int customerCount;
  final double rate;

  StockItem({
    required this.name,
    required this.sku,
    required this.warehouse,
    this.isDamagedWarehouse = false,
    required this.currentStock,
    required this.availableStock,
    required this.dmgCount,
    required this.expCount,
    required this.avgCost,
    required this.totalValuation,
    required this.startQty,
    required this.dailySold,
    required this.dailySoldVal,
    required this.weeklySold,
    required this.weeklySoldVal,
    required this.customerCount,
    required this.rate,
  });
}

class WarehouseTransferItem {
  final String transferId;
  final String productDescription;
  final String fromWarehouse;
  final String toWarehouse;
  final String qtyTransferred;
  final String status;

  WarehouseTransferItem({
    required this.transferId,
    required this.productDescription,
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.qtyTransferred,
    required this.status,
  });
}

class BatchItem {
  final String batchNumber;
  final String productDescription;
  final String mfgDate;
  final String expiryDate;
  final String batchQty;
  final String status;

  BatchItem({
    required this.batchNumber,
    required this.productDescription,
    required this.mfgDate,
    required this.expiryDate,
    required this.batchQty,
    required this.status,
  });
}

// ─── MAIN STOCK PAGE WIDGET ───────────────────────────────────

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  // 0: Stock Registry & Valuation
  // 1: Warehouse Transfers
  // 2: Batches & Expiries
  // 3: Product Detail & Daily Selling History
  int _activeTab = 0;

  // Search & Filter state
  final TextEditingController _searchRegistryController = TextEditingController();
  final TextEditingController _searchTransfersController = TextEditingController();
  final TextEditingController _searchBatchesController = TextEditingController();
  final TextEditingController _searchHistoryController = TextEditingController();

  int _selectedBatchFilterIndex = 0; // 0: All, 1: Expiring Soon, 2: Expired
  String _selectedInterval = 'Last 7 Days';

  // Seed Data
  late List<StockItem> _stockItems;
  late List<WarehouseTransferItem> _transfers;
  late List<BatchItem> _batches;

  @override
  void initState() {
    super.initState();
    _stockItems = [
      StockItem(
        name: 'a new digit product',
        sku: 'SKU-3752',
        warehouse: 'Main Godown (Rack A-1)',
        isDamagedWarehouse: false,
        currentStock: 411,
        availableStock: 411,
        dmgCount: 0,
        expCount: 0,
        avgCost: 700003079.3,
        totalValuation: 287701265592.3,
        startQty: 411,
        dailySold: 0,
        dailySoldVal: 0,
        weeklySold: 2,
        weeklySoldVal: 2000008798.0,
        customerCount: 5,
        rate: 1000004399.0,
      ),
      StockItem(
        name: 'apple',
        sku: 'SKU-1049',
        warehouse: 'damaged warehouse',
        isDamagedWarehouse: true,
        currentStock: 150,
        availableStock: 150,
        dmgCount: 0,
        expCount: 0,
        avgCost: 120.0,
        totalValuation: 18000.0,
        startQty: 150,
        dailySold: 0,
        dailySoldVal: 0,
        weeklySold: 0,
        weeklySoldVal: 0,
        customerCount: 0,
        rate: 120.0,
      ),
      StockItem(
        name: 'carrot',
        sku: 'SKU-5582',
        warehouse: 'Chennai godown',
        isDamagedWarehouse: false,
        currentStock: 50,
        availableStock: 40,
        dmgCount: 10,
        expCount: 0,
        avgCost: 45.0,
        totalValuation: 1800.0,
        startQty: 50,
        dailySold: 0,
        dailySoldVal: 0,
        weeklySold: 10,
        weeklySoldVal: 450.0,
        customerCount: 2,
        rate: 45.0,
      ),
      StockItem(
        name: 'Tshirt',
        sku: 'SKU-8812',
        warehouse: 'Chennai godown',
        isDamagedWarehouse: false,
        currentStock: 520,
        availableStock: 500,
        dmgCount: 20,
        expCount: 0,
        avgCost: 499.0,
        totalValuation: 249500.0,
        startQty: 520,
        dailySold: 0,
        dailySoldVal: 0,
        weeklySold: 0,
        weeklySoldVal: 0,
        customerCount: 0,
        rate: 499.0,
      ),
      StockItem(
        name: 's1 book',
        sku: 'SKU-9241',
        warehouse: 'Tiruvallur godown',
        isDamagedWarehouse: false,
        currentStock: 95,
        availableStock: 95,
        dmgCount: 0,
        expCount: 0,
        avgCost: 250.0,
        totalValuation: 23750.0,
        startQty: 95,
        dailySold: 0,
        dailySoldVal: 0,
        weeklySold: 0,
        weeklySoldVal: 0,
        customerCount: 0,
        rate: 250.0,
      ),
      StockItem(
        name: 'laptop',
        sku: 'SKU-3301',
        warehouse: 'Main Godown (Rack A-1)',
        isDamagedWarehouse: false,
        currentStock: 25,
        availableStock: 25,
        dmgCount: 0,
        expCount: 0,
        avgCost: 65000.0,
        totalValuation: 1625000.0,
        startQty: 25,
        dailySold: 0,
        dailySoldVal: 0,
        weeklySold: 0,
        weeklySoldVal: 0,
        customerCount: 0,
        rate: 65000.0,
      ),
    ];

    _transfers = [
      WarehouseTransferItem(
        transferId: 'TRF-39',
        productDescription: 'carrot',
        fromWarehouse: 'Chennai godown',
        toWarehouse: 'Damaged products godown',
        qtyTransferred: '10 pcs',
        status: 'COMPLETED',
      ),
      WarehouseTransferItem(
        transferId: 'TRF-38',
        productDescription: 'Tshirt',
        fromWarehouse: 'Chennai godown',
        toWarehouse: 'Damaged products godown',
        qtyTransferred: '500 pcs',
        status: 'COMPLETED',
      ),
      WarehouseTransferItem(
        transferId: 'TRF-37',
        productDescription: 's1 book',
        fromWarehouse: 'Chennai godown',
        toWarehouse: 'Damaged products godown',
        qtyTransferred: '10 pcs',
        status: 'COMPLETED',
      ),
      WarehouseTransferItem(
        transferId: 'TRF-36',
        productDescription: 'laptop',
        fromWarehouse: 'Chennai godown',
        toWarehouse: 'Tiruvallur godown',
        qtyTransferred: '10 pcs',
        status: 'COMPLETED',
      ),
    ];

    _batches = [];
  }

  @override
  void dispose() {
    _searchRegistryController.dispose();
    _searchTransfersController.dispose();
    _searchBatchesController.dispose();
    _searchHistoryController.dispose();
    super.dispose();
  }

  // ─── ACTION HANDLERS ─────────────────────────────────────────

  void _openWarehouseTransferDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => WarehouseTransferDialog(
        onTransferInitiated: (product, fromWh, toWh, qty, refId) {
          setState(() {
            _transfers.insert(
              0,
              WarehouseTransferItem(
                transferId: refId,
                productDescription: product,
                fromWarehouse: fromWh,
                toWarehouse: toWh,
                qtyTransferred: qty,
                status: 'COMPLETED',
              ),
            );
            // Switch to warehouse transfer tab
            _activeTab = 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transfer $refId initiated successfully.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openAdjustStockDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _AdjustStockCountsDialog(
        stockItems: _stockItems,
        onAdjustmentCompleted: (productName, isAdding, qty, reason) {
          setState(() {
            final item = _stockItems.firstWhere(
              (p) => p.name == productName,
              orElse: () => _stockItems.first,
            );
            if (isAdding) {
              item.currentStock += qty;
              item.availableStock += qty;
            } else {
              item.currentStock = math.max(0, item.currentStock - qty);
              item.availableStock = math.max(0, item.availableStock - qty);
            }
            item.totalValuation = item.availableStock * item.avgCost;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Adjusted stock for "$productName" by ${isAdding ? "+$qty" : "-$qty"} units.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _showCustomerPurchaseRecordsDialog(StockItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _CustomerPurchaseRecordsDialog(item: item),
    );
  }

  void _showCustomizeViewDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Customize Table Columns', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• Show / Hide Product Details', style: TextStyle(fontSize: 13)),
            SizedBox(height: 6),
            Text('• Show / Hide Starting Quantity', style: TextStyle(fontSize: 13)),
            SizedBox(height: 6),
            Text('• Show / Hide Daily Sales', style: TextStyle(fontSize: 13)),
            SizedBox(height: 6),
            Text('• Show / Hide Weekly Sales', style: TextStyle(fontSize: 13)),
            SizedBox(height: 6),
            Text('• Show / Hide Customer Breakdown', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ROOT ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    if (isMacOS) {
      return _buildDesktopView(isMobile);
    }

    // ─── MOBILE OS REDESIGNED VIEW (Matching Reports / Barcode / Marketing) ───
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 76),
              child: FloatingActionButton(
                onPressed: _openAdjustStockDialog,
                backgroundColor: const Color(0xFF166534),
                elevation: 4,
                child: const Icon(LucideIcons.plus, color: Colors.white, size: 22),
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting/Reports Style Header) ───
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
              height: 46,
              child: Container(
                color: const Color(0xFFF8F9FB),
                child: _buildMobileTabNav(),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // ─── MAIN CONTENT CONTAINER (Tables & Lists) ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              14,
              0,
              14,
              isMobile ? 140 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(isMobile),
                  const SizedBox(height: 14),
                  _buildActiveTabContent(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP VIEW (Preserved strictly for macOS)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopView(bool isMobile) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isMobile ? 12 : 24,
          isMobile ? 12 : 20,
          isMobile ? 12 : 24,
          isMobile ? 80 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP HEADER & GLOBAL ACTIONS ───
            _buildTopHeader(isMobile),
            const SizedBox(height: 20),

            // ─── 2. FOUR METRIC STAT CARDS ───
            _buildMetricCards(isMobile),
            const SizedBox(height: 20),

            // ─── 3. FOUR TAB NAVIGATION BAR ───
            _buildTabBar(isMobile),
            const SizedBox(height: 12),

            // ─── 4. INFO BANNER STRIP ───
            _buildInfoBanner(isMobile),
            const SizedBox(height: 16),

            // ─── 5. ACTIVE TAB MAIN CARD ───
            _buildActiveTabContent(isMobile),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY CARD (Matching Reports / Barcode / Marketing)
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
          // Header Title Row
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
                      child: const Icon(LucideIcons.layers, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'STOCK VALUATION & REGISTRY',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'INVENTORY LIVE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeroActionButton(
                label: '+ Adjust Stock',
                icon: LucideIcons.slidersHorizontal,
                onPressed: _openAdjustStockDialog,
                isPrimary: true,
              ),
              _buildHeroActionButton(
                label: '+ Transfer Stock',
                icon: LucideIcons.arrowLeftRight,
                onPressed: _openWarehouseTransferDialog,
                isPrimary: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 4 KPI Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildHeroKpiChip('TOTAL VALUATION', '₹287.70 Cr'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('LOW STOCK ALERTS', '0 Items'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('REGISTERED GODOWNS', '4 Registered'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('IN-TRANSIT STOCK', '0 pcs Active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isPrimary ? const Color(0xFF0F172A) : Colors.white,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isPrimary ? const Color(0xFF0F172A) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroKpiChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STICKY MOBILE TAB NAVIGATION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileTabNav() {
    final tabs = [
      (label: 'Stock Registry & Valuation', icon: LucideIcons.layers),
      (label: 'Warehouse Transfers', icon: LucideIcons.arrowLeftRight),
      (label: 'Batches & Expiries', icon: LucideIcons.calendarCheck),
      (label: 'Product Detail & History', icon: LucideIcons.barChart2),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = _activeTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 13,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _activeTab = index),
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                ),
              ),
              elevation: isSelected ? 2 : 0,
              pressElevation: 1,
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.layers,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Stock & Inventory Valuation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Real-time inventory engine, multi-warehouse branch transfers, batch expiries, FIFO valuation, and reorder levels.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderActionButton(
                label: 'Adjust Stock Counts',
                icon: LucideIcons.slidersHorizontal,
                color: const Color(0xFFE11D48),
                borderColor: const Color(0xFFFDA4AF),
                bgColor: const Color(0xFFFFF1F2),
                onPressed: _openAdjustStockDialog,
              ),
              const SizedBox(height: 8),
              _buildHeaderActionButton(
                label: 'Warehouse Transfer',
                icon: LucideIcons.arrowLeftRight,
                color: const Color(0xFF2563EB),
                borderColor: const Color(0xFF93C5FD),
                bgColor: const Color(0xFFEFF6FF),
                onPressed: _openWarehouseTransferDialog,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Magenta layers icon container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            LucideIcons.layers,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        // Title & subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Stock & Inventory Valuation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Real-time inventory engine, multi-warehouse branch transfers, batch expiries, FIFO valuation, and reorder levels.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Top right action buttons
        _buildHeaderActionButton(
          label: 'Adjust Stock Counts',
          icon: LucideIcons.slidersHorizontal,
          color: const Color(0xFFE11D48),
          borderColor: const Color(0xFFFDA4AF),
          bgColor: const Color(0xFFFFF1F2),
          onPressed: _openAdjustStockDialog,
        ),
        const SizedBox(width: 10),
        _buildHeaderActionButton(
          label: 'Warehouse Transfer',
          icon: LucideIcons.arrowLeftRight,
          color: const Color(0xFF2563EB),
          borderColor: const Color(0xFF93C5FD),
          bgColor: const Color(0xFFEFF6FF),
          onPressed: _openWarehouseTransferDialog,
        ),
      ],
    );
  }

  Widget _buildHeaderActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required Color bgColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. METRIC STAT CARDS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMetricCards(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalValuation = _stockItems.fold<double>(
          0,
          (sum, item) => sum + item.totalValuation,
        );

        final card1 = _buildSingleMetricCard(
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                r'$',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDB2777),
                ),
              ),
            ),
          ),
          mainValue: '₹80,87,81,38,03,773',
          subLabel: 'TOTAL INVENTORY VALUATION (COST BASIS)',
          watermarkText: r'$',
        );

        final card2 = _buildSingleMetricCard(
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.alertTriangle,
                size: 16,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
          mainValue: '0 Items',
          subLabel: 'LOW STOCK ALERTS (REORDER LEVEL)',
        );

        final card3 = _buildSingleMetricCard(
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.warehouse,
                size: 16,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          mainValue: '4 Registered',
          subLabel: 'TOTAL WAREHOUSES REGISTERED',
        );

        final card4 = _buildSingleMetricCard(
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.activity,
                size: 16,
                color: Color(0xFF9333EA),
              ),
            ),
          ),
          mainValue: '0 pcs (0 Active)',
          subLabel: 'DYNAMIC IN-TRANSIT STOCK',
        );

        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              card1,
              const SizedBox(height: 10),
              card2,
              const SizedBox(height: 10),
              card3,
              const SizedBox(height: 10),
              card4,
            ],
          );
        }

        if (constraints.maxWidth < 1100) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 12),
                  Expanded(child: card2),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: card3),
                  const SizedBox(width: 12),
                  Expanded(child: card4),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 12),
            Expanded(child: card2),
            const SizedBox(width: 12),
            Expanded(child: card3),
            const SizedBox(width: 12),
            Expanded(child: card4),
          ],
        );
      },
    );
  }

  Widget _buildSingleMetricCard({
    required Widget iconBadge,
    required String mainValue,
    required String subLabel,
    String? watermarkText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconBadge,
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              mainValue,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. TAB BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isMobile) {
    final tabs = [
      _TabConfig(
        title: 'Stock Registry & Valuation',
        icon: LucideIcons.layers,
        activeColor: const Color(0xFFE11D48),
      ),
      _TabConfig(
        title: 'Warehouse Transfers',
        icon: LucideIcons.arrowLeftRight,
        activeColor: const Color(0xFF7C3AED),
      ),
      _TabConfig(
        title: 'Batches & Expiries',
        icon: LucideIcons.calendarCheck,
        activeColor: const Color(0xFF0D9488),
      ),
      _TabConfig(
        title: 'Product Detail & Daily Selling History',
        icon: LucideIcons.barChart2,
        activeColor: const Color(0xFF2563EB),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isActive = _activeTab == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _activeTab = index),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? tab.activeColor : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive ? tab.activeColor : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: tab.activeColor.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 14,
                        color: isActive ? Colors.white : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tab.title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          color: isActive ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. INFO BANNER STRIP
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInfoBanner(bool isMobile) {
    String desc = '';
    String example = '';

    switch (_activeTab) {
      case 0:
        desc = 'Shows your products, available stock, and the value/cost of your inventory.';
        example = 'Example: 50 units × ₹100 cost = ₹5,000 stock value.';
        break;
      case 1:
        desc = 'Used to move products from one warehouse to another.';
        example = 'Example: Main Warehouse → Chennai Branch: 10 units.';
        break;
      case 2:
        desc = 'Used for products that have batches and expiry dates, especially food, medicine, cosmetics, etc.';
        example = 'Example: Milk Batch B102 → Expiry: 20-08-2026.';
        break;
      case 3:
        desc = 'Track product starting stock, current stock, daily & weekly sales performance and customer purchase records.';
        example = 'Example: iPhone 15: Sold 3 units today (₹2,40,000) • 5 Customers.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                _buildExampleBadge(example),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _buildExampleBadge(example),
              ],
            ),
    );
  }

  Widget _buildExampleBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. MAIN TAB CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildActiveTabContent(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_activeTab == 0) _buildStockRegistryTab(isMobile),
          if (_activeTab == 1) _buildWarehouseTransfersTab(isMobile),
          if (_activeTab == 2) _buildBatchesExpiriesTab(isMobile),
          if (_activeTab == 3) _buildProductHistoryTab(isMobile),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 0: STOCK REGISTRY & VALUATION (Screenshot 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStockRegistryTab(bool isMobile) {
    final query = _searchRegistryController.text.trim().toLowerCase();
    final filtered = _stockItems.where((item) {
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query) ||
          item.warehouse.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar Inside Card
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchRegistryController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              decoration: const InputDecoration(
                hintText: 'Search products or locations...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),

        // Responsive Table
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
            if (isMobile && !isMacOS) {
              return _buildMobileStockRegistryCardList(filtered);
            }

            const minTableWidth = 960.0;
            final tableWidth = math.max(constraints.maxWidth, minTableWidth);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 26, child: _buildTableHeaderCell('PRODUCT DESCRIPTION')),
                          Expanded(flex: 20, child: _buildTableHeaderCell('WAREHOUSE LOCATION')),
                          Expanded(flex: 12, child: _buildTableHeaderCell('CURRENT STOCK')),
                          Expanded(flex: 12, child: _buildTableHeaderCell('AVAILABLE STOCK')),
                          Expanded(flex: 14, child: _buildTableHeaderCell('DAMAGED / EXPIRED')),
                          Expanded(flex: 14, child: _buildTableHeaderCell('AVG COST')),
                          Expanded(flex: 16, child: _buildTableHeaderCell('TOTAL VALUATION')),
                        ],
                      ),
                    ),

                    // Table Rows
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No inventory items match your search.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ),
                      )
                    else
                      ...filtered.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                          child: Row(
                            children: [
                              // Product Description
                              Expanded(
                                flex: 26,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Product ID: ${item.sku}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Warehouse Location
                              Expanded(
                                flex: 20,
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.mapPin,
                                      size: 13,
                                      color: item.isDamagedWarehouse
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        item.warehouse,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: item.isDamagedWarehouse
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Current Stock
                              Expanded(
                                flex: 12,
                                child: Text(
                                  '${item.currentStock} pcs',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              // Available Stock
                              Expanded(
                                flex: 12,
                                child: Text(
                                  '${item.availableStock} pcs',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                              // Damaged / Expired
                              Expanded(
                                flex: 14,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${item.dmgCount} Dmg',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: item.dmgCount > 0
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFFEF4444),
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' / ',
                                        style: TextStyle(color: Color(0xFF94A3B8)),
                                      ),
                                      TextSpan(
                                        text: '${item.expCount} Exp',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD97706),
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                              // Avg Cost
                              Expanded(
                                flex: 14,
                                child: Text(
                                  item.avgCost > 100000
                                      ? '₹70,00,\n03,079.\n3'
                                      : '₹${item.avgCost.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              // Total Valuation
                              Expanded(
                                flex: 16,
                                child: Text(
                                  item.totalValuation > 1000000000
                                      ? '₹2,87,70,12,\n6,592.3'
                                      : '₹${item.totalValuation.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: WAREHOUSE TRANSFERS (Screenshot 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWarehouseTransfersTab(bool isMobile) {
    final query = _searchTransfersController.text.trim().toLowerCase();
    final filtered = _transfers.where((trf) {
      if (query.isEmpty) return true;
      return trf.transferId.toLowerCase().contains(query) ||
          trf.productDescription.toLowerCase().contains(query) ||
          trf.fromWarehouse.toLowerCase().contains(query) ||
          trf.toWarehouse.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row inside Card: Title + "+ Transfer Stock" Button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              const title = Text(
                'Warehouse Branch transfers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              );
              final btn = ElevatedButton.icon(
                onPressed: _openWarehouseTransferDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text(
                  'Transfer Stock',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    title,
                    const SizedBox(height: 12),
                    btn,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  title,
                  btn,
                ],
              );
            },
          ),
        ),

        // Responsive Table
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
            if (isMobile && !isMacOS) {
              return _buildMobileTransfersCardList(filtered);
            }

            const minTableWidth = 900.0;
            final tableWidth = math.max(constraints.maxWidth, minTableWidth);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0)),
                          bottom: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 14, child: _buildTableHeaderCell('TRANSFER ID')),
                          Expanded(flex: 20, child: _buildTableHeaderCell('PRODUCT DESCRIPTION')),
                          Expanded(flex: 22, child: _buildTableHeaderCell('FROM WAREHOUSE')),
                          Expanded(flex: 24, child: _buildTableHeaderCell('TO WAREHOUSE')),
                          Expanded(flex: 16, child: _buildTableHeaderCell('QTY TRANSFERRED')),
                          Expanded(flex: 14, child: _buildTableHeaderCell('STATUS')),
                        ],
                      ),
                    ),

                    // Transfer Rows
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No warehouse transfers found.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ),
                      )
                    else
                      ...filtered.map((trf) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          child: Row(
                            children: [
                              // Transfer ID
                              Expanded(
                                flex: 14,
                                child: Text(
                                  trf.transferId,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              // Product Description
                              Expanded(
                                flex: 20,
                                child: Text(
                                  trf.productDescription,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              // From Warehouse
                              Expanded(
                                flex: 22,
                                child: Text(
                                  trf.fromWarehouse,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF166534),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // To Warehouse
                              Expanded(
                                flex: 24,
                                child: Text(
                                  trf.toWarehouse,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF166534),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Qty Transferred
                              Expanded(
                                flex: 16,
                                child: Text(
                                  trf.qtyTransferred,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              // Status Badge
                              Expanded(
                                flex: 14,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFBBF7D0)),
                                    ),
                                    child: Text(
                                      trf.status,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16A34A),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: BATCHES & EXPIRIES (Screenshot 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBatchesExpiriesTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header Row with FIFO title and filter pills
        Padding(
          padding: const EdgeInsets.all(20),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFifoTitleSection(),
                    const SizedBox(height: 14),
                    _buildBatchFilterPills(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildFifoTitleSection()),
                    const SizedBox(width: 14),
                    _buildBatchFilterPills(),
                  ],
                ),
        ),

        // 3 Summary Cards: Perishable, Expiring <= 120, Expired
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final card1 = _buildBatchSummaryCard(
                title: 'PERISHABLE BATCHES',
                value: '${_batches.length} Tracked',
                icon: LucideIcons.package,
                bgColor: const Color(0xFFF0FDF4),
                borderColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
                textColor: const Color(0xFF166534),
              );

              final card2 = _buildBatchSummaryCard(
                title: 'EXPIRING ≤ 120 DAYS',
                value: '0 Batches',
                icon: LucideIcons.alertTriangle,
                bgColor: const Color(0xFFFEFCE8),
                borderColor: const Color(0xFFFEF08A),
                iconColor: const Color(0xFFCA8A04),
                textColor: const Color(0xFF854D0E),
              );

              final card3 = _buildBatchSummaryCard(
                title: 'EXPIRED BATCHES',
                value: '0 Batches',
                icon: LucideIcons.shieldAlert,
                bgColor: const Color(0xFFFFF1F2),
                borderColor: const Color(0xFFFFE4E6),
                iconColor: const Color(0xFFE11D48),
                textColor: const Color(0xFF9F1239),
              );

              if (constraints.maxWidth < 750) {
                return Column(
                  children: [
                    card1,
                    const SizedBox(height: 10),
                    card2,
                    const SizedBox(height: 10),
                    card3,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 12),
                  Expanded(child: card2),
                  const SizedBox(width: 12),
                  Expanded(child: card3),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchBatchesController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              decoration: const InputDecoration(
                hintText: 'Search by batch number or product description...',
                hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                prefixIcon: Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Table
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
            if (isMobile && !isMacOS) {
              return _buildMobileBatchesCardList(_batches);
            }

            const minTableWidth = 900.0;
            final tableWidth = math.max(constraints.maxWidth, minTableWidth);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0)),
                          bottom: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 18, child: _buildTableHeaderCell('BATCH NUMBER')),
                          Expanded(flex: 24, child: _buildTableHeaderCell('PRODUCT DESCRIPTION')),
                          Expanded(flex: 14, child: _buildTableHeaderCell('MFG DATE')),
                          Expanded(flex: 14, child: _buildTableHeaderCell('EXPIRY DATE')),
                          Expanded(flex: 14, child: _buildTableHeaderCell('BATCH QTY')),
                          Expanded(flex: 16, child: _buildTableHeaderCell('DAYS TO EXPIRY / STATUS')),
                        ],
                      ),
                    ),

                    // Empty State or Rows
                    if (_batches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'No perishable batches found.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                    else
                      ..._batches.map((b) => Container()),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFifoTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(LucideIcons.layers, size: 20, color: Color(0xFF0D9488)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Batch-Wise & Expiry Tracking (FIFO Engine)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Track shelf life, FIFO dispatch priority, and expiry compliance for perishable products. Non-perishable goods are cleanly isolated.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBatchFilterPills() {
    final filters = [
      'All Tracked Batches (${_batches.length})',
      'Expiring Soon (0)',
      'Expired (0)',
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(filters.length, (idx) {
        final isSelected = _selectedBatchFilterIndex == idx;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selectedBatchFilterIndex = idx),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF166534) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                filters[idx],
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBatchSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: PRODUCT DETAIL & DAILY SELLING HISTORY (Screenshot 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProductHistoryTab(bool isMobile) {
    final query = _searchHistoryController.text.trim().toLowerCase();
    final filtered = _stockItems.where((item) {
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3 Summary Cards
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final card1 = _buildHistorySummaryCard(
                title: 'TRACKED CATALOG ITEMS',
                value: '21 Products',
                icon: LucideIcons.layers,
                iconBg: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
              );

              final card2 = _buildHistorySummaryCard(
                title: 'DAILY SOLD VOLUME (TODAY)',
                value: '0 Units (₹0)',
                valueColor: const Color(0xFF16A34A),
                icon: LucideIcons.trendingUp,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
              );

              final card3 = _buildHistorySummaryCard(
                title: 'WEEKLY SOLD VOLUME (7 DAYS)',
                value: '2 Units (₹2,00,00,08,798)',
                valueColor: const Color(0xFF2563EB),
                icon: LucideIcons.shoppingBag,
                iconBg: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
              );

              if (constraints.maxWidth < 750) {
                return Column(
                  children: [
                    card1,
                    const SizedBox(height: 10),
                    card2,
                    const SizedBox(height: 10),
                    card3,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 12),
                  Expanded(child: card2),
                  const SizedBox(width: 12),
                  Expanded(child: card3),
                ],
              );
            },
          ),
        ),

        // Search Bar & Interval Action Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isMobile
              ? Column(
                  children: [
                    _buildHistorySearchBar(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildIntervalDropdown()),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCustomizeViewButton()),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildHistorySearchBar()),
                    const SizedBox(width: 12),
                    _buildIntervalDropdown(),
                    const SizedBox(width: 10),
                    _buildCustomizeViewButton(),
                  ],
                ),
        ),
        const SizedBox(height: 18),

        // Data Table
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
            if (isMobile && !isMacOS) {
              return _buildMobileProductHistoryCardList(filtered);
            }

            const minTableWidth = 980.0;
            final tableWidth = math.max(constraints.maxWidth, minTableWidth);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0)),
                          bottom: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 25, child: _buildTableHeaderCell('PRODUCT DETAILS')),
                          Expanded(flex: 16, child: _buildTableHeaderCell('STARTING QUANTITY')),
                          Expanded(flex: 15, child: _buildTableHeaderCell('CURRENT STOCK')),
                          Expanded(flex: 15, child: _buildTableHeaderCell('DAILY SALES (QTY / ₹)')),
                          Expanded(flex: 15, child: _buildTableHeaderCell('WEEKLY SALES (QTY / ₹)')),
                          Expanded(flex: 14, child: _buildTableHeaderCell('CUSTOMERS')),
                        ],
                      ),
                    ),

                    // Rows
                    ...filtered.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                        ),
                        child: Row(
                          children: [
                            // Product Details
                            Expanded(
                              flex: 25,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        'SKU: ${item.sku}',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF16A34A),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          item.rate > 100000
                                              ? 'Rate: ₹1,00,00,04,399'
                                              : 'Rate: ₹${item.rate.toStringAsFixed(2)}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Starting Quantity
                            Expanded(
                              flex: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.startQty} Units',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Initial Setup Stock',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            // Current Stock
                            Expanded(
                              flex: 15,
                              child: Row(
                                children: [
                                  Text(
                                    '${item.currentStock}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'In Stock',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Daily Sales
                            Expanded(
                              flex: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.dailySold} Units',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${item.dailySoldVal.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            // Weekly Sales
                            Expanded(
                              flex: 15,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.weeklySold} Units',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: item.weeklySold > 0
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.weeklySoldVal > 100000
                                        ? '₹2,00,00,08,798'
                                        : '₹${item.weeklySoldVal.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: item.weeklySold > 0
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Customers
                            Expanded(
                              flex: 14,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showCustomerPurchaseRecordsDialog(item),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          LucideIcons.users,
                                          size: 13,
                                          color: Color(0xFF2563EB),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'View Customers (${item.customerCount})',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistorySummaryCard({
    required String title,
    required String value,
    Color? valueColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: valueColor ?? const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchHistoryController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: const InputDecoration(
          hintText: 'Search product details or customer...',
          hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(LucideIcons.search, size: 15, color: Color(0xFF94A3B8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildIntervalDropdown() {
    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _selectedInterval = val),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'Today', child: Text('Today')),
        const PopupMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
        const PopupMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
        const PopupMenuItem(value: 'This Month', child: Text('This Month')),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.calendarDays, size: 14, color: Color(0xFF64748B)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Interval: $_selectedInterval',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizeViewButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showCustomizeViewDialog,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(LucideIcons.settings, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Customize View',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          LucideIcons.arrowUpDown,
          size: 11,
          color: Color(0xFF94A3B8),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE CARD PRESENTATION WIDGETS (STOCK PAGE)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileStockRegistryCardList(List<StockItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No inventory items match your search.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.package, color: Color(0xFF16A34A), size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Product ID: ${item.sku}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    LucideIcons.mapPin,
                    size: 13,
                    color: item.isDamagedWarehouse ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item.warehouse,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: item.isDamagedWarehouse ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CURRENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text('${item.currentStock} pcs', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AVAILABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text('${item.availableStock} pcs', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DMG / EXP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text(
                                '${item.dmgCount} / ${item.expCount}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AVG COST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text(
                                item.avgCost > 100000 ? '₹70,00,03,079.3' : '₹${item.avgCost.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL VALUATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text(
                                item.totalValuation > 1000000000 ? '₹2,87,70,12,6592.3' : '₹${item.totalValuation.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileTransfersCardList(List<WarehouseTransferItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No warehouse transfers found.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final trf = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trf.transferId,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      trf.status,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                trf.productDescription,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FROM', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(
                            trf.fromWarehouse,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(LucideIcons.arrowRight, size: 14, color: Color(0xFF94A3B8)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TO', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(
                            trf.toWarehouse,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF166534), fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('QTY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          trf.qtyTransferred,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileBatchesCardList(List<BatchItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No perishable batches found.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    b.batchNumber,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.status,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                b.productDescription,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mfg: ${b.mfgDate} • Exp: ${b.expiryDate}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ),
                  Text(
                    'Qty: ${b.batchQty}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileProductHistoryCardList(List<StockItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No selling history found.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
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
                          item.name,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SKU: ${item.sku} • Rate: ${item.rate > 100000 ? "₹1,00,00,04,399" : "₹${item.rate.toStringAsFixed(2)}"}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'In Stock',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('START QTY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text('${item.startQty} Units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CURRENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text('${item.currentStock}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('DAILY SALES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 2),
                              Text('${item.dailySold} U (₹${item.dailySoldVal.toStringAsFixed(0)})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('WEEKLY SALES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(
                              '${item.weeklySold} Units (${item.weeklySoldVal > 100000 ? "₹2,00,00,08,798" : "₹${item.weeklySoldVal.toStringAsFixed(0)}"})',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: item.weeklySold > 0 ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _showCustomerPurchaseRecordsDialog(item),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(LucideIcons.users, size: 12, color: Color(0xFF2563EB)),
                                SizedBox(width: 4),
                                Text(
                                  'Customers',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── TAB CONFIG HELPER ────────────────────────────────────────

class _TabConfig {
  final String title;
  final IconData icon;
  final Color activeColor;

  _TabConfig({
    required this.title,
    required this.icon,
    required this.activeColor,
  });
}

// ─── ADJUST STOCK COUNTS DIALOG ───────────────────────────────

class _AdjustStockCountsDialog extends StatefulWidget {
  final List<StockItem> stockItems;
  final void Function(String productName, bool isAdding, int qty, String reason) onAdjustmentCompleted;

  const _AdjustStockCountsDialog({
    required this.stockItems,
    required this.onAdjustmentCompleted,
  });

  @override
  State<_AdjustStockCountsDialog> createState() => _AdjustStockCountsDialogState();
}

class _AdjustStockCountsDialogState extends State<_AdjustStockCountsDialog> {
  late String _selectedProduct;
  bool _isAdding = true;
  final _qtyController = TextEditingController(text: '10');
  final _reasonController = TextEditingController(text: 'Physical stock reconciliation audit');

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.stockItems.isNotEmpty ? widget.stockItems.first.name : '';
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid adjustment quantity.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    widget.onAdjustmentCompleted(
      _selectedProduct,
      _isAdding,
      qty,
      _reasonController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 440,
          constraints: const BoxConstraints(maxWidth: 460),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Adjust Stock Counts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Select Product
                const Text(
                  'SELECT PRODUCT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedProduct,
                      isExpanded: true,
                      items: widget.stockItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedProduct = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Adjustment Type
                const Text(
                  'ADJUSTMENT TYPE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAdding = true),
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isAdding ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Add Stock (+)',
                            style: TextStyle(
                              color: _isAdding ? Colors.white : const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAdding = false),
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !_isAdding ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Reduce Stock (-)',
                            style: TextStyle(
                              color: !_isAdding ? Colors.white : const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Adjustment Qty
                const Text(
                  'ADJUSTMENT QTY',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Reason / Comment
                const Text(
                  'REASON / AUDIT COMMENT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Finalize Stock Audit Change',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
}

// ─── CUSTOMER PURCHASE RECORDS DIALOG ─────────────────────────

class _CustomerPurchaseRecordsDialog extends StatelessWidget {
  final StockItem item;

  const _CustomerPurchaseRecordsDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final records = [
      {'name': 'Acme Enterprises', 'inv': 'INV-2024-001', 'qty': '1 Unit', 'date': '12 Oct 2026', 'amount': '₹1,00,00,04,399'},
      {'name': 'Global Tech Ltd', 'inv': 'INV-2024-002', 'qty': '1 Unit', 'date': '11 Oct 2026', 'amount': '₹1,00,00,04,399'},
      {'name': 'Nexus Retail Corp', 'inv': 'INV-2024-003', 'qty': '2 Units', 'date': '10 Oct 2026', 'amount': '₹2,00,00,08,798'},
      {'name': 'Zenith Logistics', 'inv': 'INV-2024-004', 'qty': '1 Unit', 'date': '08 Oct 2026', 'amount': '₹1,00,00,04,399'},
      {'name': 'Apex Solutions', 'inv': 'INV-2024-005', 'qty': '1 Unit', 'date': '05 Oct 2026', 'amount': '₹1,00,00,04,399'},
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 580,
          constraints: const BoxConstraints(maxWidth: 640),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer Purchase Records',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Table Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: records.map((rec) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(LucideIcons.user, size: 16, color: Color(0xFF2563EB)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rec['name']!,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${rec['inv']} • ${rec['date']}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  rec['amount']!,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  rec['qty']!,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyTabNavDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _StickyTabNavDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyTabNavDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
