import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

// ─── DATA MODELS ──────────────────────────────────────────────

class WarehouseProductItem {
  final String name;
  final String sku;
  final String category;
  int stock;
  final String unit;
  final double unitCost;
  final String status;
  final String zone;
  final String warehouse;

  WarehouseProductItem({
    required this.name,
    required this.sku,
    required this.category,
    required this.stock,
    required this.unit,
    required this.unitCost,
    this.status = 'In Stock',
    this.zone = 'Zone A',
    required this.warehouse,
  });

  double get valuation => stock * unitCost;
}

class WarehouseItem {
  final String id;
  String name;
  String code;
  String capacityUtilization;
  String address;
  String city;
  String state;
  String pincode;
  String contactPerson;
  String phone;
  String email;
  String facilityType;
  List<WarehouseProductItem> products;

  WarehouseItem({
    required this.id,
    required this.name,
    required this.code,
    this.capacityUtilization = 'CAPACITY UTILIZATION: 0%',
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactPerson,
    required this.phone,
    required this.email,
    this.facilityType = 'Godown (Bulk Storage)',
    required this.products,
  });

  double get totalInventoryValue {
    return products.fold<double>(0, (sum, p) => sum + p.valuation);
  }
}

class InwardReceiptItem {
  final String inwardId;
  final String purchaseBillRef;
  final String productDescription;
  final int receivedQty;
  final String receivedBy;
  final String dateReceived;
  final String destinationWarehouse;

  InwardReceiptItem({
    required this.inwardId,
    required this.purchaseBillRef,
    required this.productDescription,
    required this.receivedQty,
    required this.receivedBy,
    required this.dateReceived,
    required this.destinationWarehouse,
  });
}

// ─── MAIN WAREHOUSE PAGE ──────────────────────────────────────

class WarehousePage extends ConsumerStatefulWidget {
  const WarehousePage({super.key});

  @override
  ConsumerState<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends ConsumerState<WarehousePage> {
  // 0: Registered Godowns & Locations (Magenta #E11D48)
  // 1: Warehouse Stock Registry (Blue #2563EB - Default matching Image 1)
  // 2: Goods Inward Historical logs (Purple #7C3AED - Image 4)
  int _activeTab = 1;

  late List<WarehouseItem> _warehouses;
  late List<WarehouseProductItem> _stockRegistry;
  late List<InwardReceiptItem> _inwardReceipts;

  @override
  void initState() {
    super.initState();

    final curdItem = WarehouseProductItem(
      name: 'curd aarokya',
      sku: 'wijdhedh',
      category: 'Dairy',
      stock: 45,
      unit: 'pcs',
      unitCost: 78.0,
      warehouse: 'Tiruvallur gowdown',
    );

    final gulobJamunItem = WarehouseProductItem(
      name: 'gulob jamun',
      sku: 'wehdjbwue',
      category: 'Food',
      stock: 999946,
      unit: 'pcs',
      unitCost: 78.0,
      warehouse: 'Chennai godown',
    );

    final newProductItem = WarehouseProductItem(
      name: 'new product cliks business',
      sku: 'SKU-CLIK-01',
      category: 'General',
      stock: 50,
      unit: 'pcs',
      unitCost: 5000.0,
      warehouse: 'Tiruvallur gowdown',
    );

    final bmwItem = WarehouseProductItem(
      name: 'BMW car',
      sku: 'BMW-788',
      category: 'vehicles',
      stock: 33,
      unit: 'pcs',
      unitCost: 100000.0,
      warehouse: 'Chennai godown',
    );

    final carrotItem = WarehouseProductItem(
      name: 'carrot',
      sku: 'SKU-746095',
      category: 'General',
      stock: 1190,
      unit: 'pcs',
      unitCost: 45.0,
      warehouse: 'Chennai godown',
    );

    final penItem = WarehouseProductItem(
      name: 'PEN',
      sku: 'HFJHFJ',
      category: 'Electronics',
      stock: 800,
      unit: 'pcs',
      unitCost: 111.0,
      warehouse: 'Chennai godown',
    );

    final bananaItem = WarehouseProductItem(
      name: 'Raw Banana',
      sku: '544',
      category: 'food',
      stock: 100,
      unit: 'pcs',
      unitCost: 25.0,
      warehouse: 'Chennai godown',
    );

    _stockRegistry = [
      curdItem,
      gulobJamunItem,
      newProductItem,
      bmwItem,
      carrotItem,
      penItem,
      bananaItem,
    ];

    _warehouses = [
      WarehouseItem(
        id: 'WH-1',
        name: 'Damaged products godown',
        code: 'WH-D',
        capacityUtilization: 'CAPACITY UTILIZATION: 0%',
        address: 'new address veeraragavar kovil street , tiruvallur , Theradi - 602001 (Tamil Nadu)',
        city: 'Tiruvallur',
        state: 'Tamil Nadu',
        pincode: '602001',
        contactPerson: 'Ashwin',
        phone: '06374943436kjernfnjernf',
        email: '',
        products: [],
      ),
      WarehouseItem(
        id: 'WH-2',
        name: '787',
        code: '894984',
        capacityUtilization: 'CAPACITY UTILIZATION: 0%',
        address: '3663 TNHB Kakkalur by pass road Thiruvallur, Tiruvallur - 600054 (Tamil Nadu)',
        city: 'Tiruvallur',
        state: 'Tamil Nadu',
        pincode: '600054',
        contactPerson: 'ashwoin',
        phone: '4847887645',
        email: 'divyachannnn1234@gmail.com',
        products: [],
      ),
      WarehouseItem(
        id: 'WH-3',
        name: 'Chennai godown',
        code: 'tel-01',
        capacityUtilization: 'CAPACITY UTILIZATION: 0%',
        address: 'No:3663 TNHB Kakkalur by pass road Thiruvallur, Chennai - 602001 (Tamil Nadu)',
        city: 'Chennai',
        state: 'Tamil Nadu',
        pincode: '602001',
        contactPerson: 'santhosh',
        phone: '06374943436',
        email: 'connectwithravi2004@gmail.com',
        products: [bmwItem, carrotItem, gulobJamunItem, penItem, bananaItem],
      ),
      WarehouseItem(
        id: 'WH-4',
        name: 'Tiruvallur gowdown',
        code: 'Thiru - 02',
        capacityUtilization: 'CAPACITY UTILIZATION: 0%',
        address: 'kakkalur by pass road, Thiruvallur - 602001 (Tamil Nadu)',
        city: 'Thiruvallur',
        state: 'Tamil Nadu',
        pincode: '602001',
        contactPerson: 'Ravi',
        phone: '6374943436',
        email: 'divyachannnn1234@gmail.com',
        products: [curdItem, newProductItem],
      ),
    ];

    _inwardReceipts = [
      InwardReceiptItem(
        inwardId: 'INW-322',
        purchaseBillRef: 'N/A',
        productDescription: 'new added in cliks',
        receivedQty: 25,
        receivedBy: 'ravinew2004',
        dateReceived: '2026-09-15',
        destinationWarehouse: 'GENERAL',
      ),
      InwardReceiptItem(
        inwardId: 'INW-322',
        purchaseBillRef: 'N/A',
        productDescription: 'new added in cliks',
        receivedQty: 25,
        receivedBy: 'ravinew2004',
        dateReceived: '2026-09-15',
        destinationWarehouse: 'GENERAL',
      ),
      InwardReceiptItem(
        inwardId: 'INW-322',
        purchaseBillRef: 'N/A',
        productDescription: 'new added in cliks',
        receivedQty: 25,
        receivedBy: 'ravinew2004',
        dateReceived: '2026-09-15',
        destinationWarehouse: 'GENERAL',
      ),
      InwardReceiptItem(
        inwardId: 'INW-322',
        purchaseBillRef: 'N/A',
        productDescription: 'new added in cliks',
        receivedQty: 25,
        receivedBy: 'ravinew2004',
        dateReceived: '2026-09-15',
        destinationWarehouse: 'GENERAL',
      ),
      InwardReceiptItem(
        inwardId: 'INW-322',
        purchaseBillRef: 'N/A',
        productDescription: 'new added in cliks',
        receivedQty: 25,
        receivedBy: 'ravinew2004',
        dateReceived: '2026-09-15',
        destinationWarehouse: 'GENERAL',
      ),
    ];
  }

  // ─── ACTION HANDLERS & MODALS ────────────────────────────────

  void _openRegisterWarehouseDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _RegisterWarehouseFacilityDialog(
        onRegister: (newWarehouse) {
          setState(() {
            _warehouses.add(newWarehouse);
            _activeTab = 0; // Switch to Registered Godowns to show the new card
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Facility "${newWarehouse.name}" registered successfully.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openGoodsInwardReceiptDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _GoodsInwardReceiptDialog(
        stockList: _stockRegistry,
        warehouses: _warehouses,
        onLogReceipt: (receipt) {
          setState(() {
            _inwardReceipts.insert(0, receipt);
            _activeTab = 2; // Switch to Goods Inwards tab to view new audit record
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Goods inward receipt logged: ${receipt.inwardId}'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openStockMovementDetailsDialog(WarehouseProductItem product) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _StockMovementHistoryDialog(product: product),
    );
  }

  void _openWarehouseProductsListDialog(WarehouseItem warehouse) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _WarehouseProductsListDialog(warehouse: warehouse),
    );
  }

  void _openEditWarehouseDialog(WarehouseItem warehouse) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _EditWarehouseProfileDialog(
        warehouse: warehouse,
        onSave: (updated) {
          setState(() {
            warehouse.name = updated.name;
            warehouse.code = updated.code;
            warehouse.address = updated.address;
            warehouse.city = updated.city;
            warehouse.state = updated.state;
            warehouse.pincode = updated.pincode;
            warehouse.contactPerson = updated.contactPerson;
            warehouse.phone = updated.phone;
            warehouse.email = updated.email;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warehouse profile for "${warehouse.name}" updated.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _deleteWarehouse(WarehouseItem warehouse) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Warehouse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to remove "${warehouse.name}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _warehouses.removeWhere((w) => w.id == warehouse.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Warehouse "${warehouse.name}" deleted.'),
                  backgroundColor: const Color(0xFFE11D48),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
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
                onPressed: _openRegisterWarehouseDialog,
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
                  if (_activeTab == 0) _buildGodownsTab(isMobile),
                  if (_activeTab == 1) _buildStockRegistryTab(isMobile),
                  if (_activeTab == 2) _buildGoodsInwardAuditTab(isMobile),
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

            // ─── 3. THREE TAB NAVIGATION BAR ───
            _buildTabBar(isMobile),
            const SizedBox(height: 18),

            // ─── 4. ACTIVE TAB CONTENT ───
            if (_activeTab == 0) _buildGodownsTab(isMobile),
            if (_activeTab == 1) _buildStockRegistryTab(isMobile),
            if (_activeTab == 2) _buildGoodsInwardAuditTab(isMobile),
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
                      child: const Icon(LucideIcons.warehouse, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'WAREHOUSE LOGISTICS & GODOWNS',
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
                      'GODOWNS ACTIVE',
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
                label: 'Register Warehouse',
                icon: LucideIcons.plus,
                onPressed: _openRegisterWarehouseDialog,
                isPrimary: true,
              ),
              _buildHeroActionButton(
                label: 'Goods Inward Receiving',
                icon: LucideIcons.packagePlus,
                onPressed: _openGoodsInwardReceiptDialog,
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
                _buildHeroKpiChip('REGISTERED FACILITIES', '4 Godowns'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('INVENTORY VALUATION', '₹287.70 Cr'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('MULTI-LOCATION SKUS', '4 Active SKUs'),
                const SizedBox(width: 8),
                _buildHeroKpiChip('INWARD RECEIPTS AUDIT', '3 Logs Recorded'),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
      (label: 'Registered Godowns & Locations', icon: LucideIcons.warehouse),
      (label: 'Warehouse Stock Registry', icon: LucideIcons.layers),
      (label: 'Goods Inward Historical logs', icon: LucideIcons.fileText),
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
  // 1. TOP HEADER (Image 1)
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.warehouse,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Warehouse, Godowns & Logistics',
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
            'Manage multiple physical godowns, branch storage facilities, inter-warehouse transfers, rack zones, and inward receipts.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderActionButton(
                label: 'Goods Inward Receiving',
                icon: LucideIcons.truck,
                color: const Color(0xFFE11D48),
                borderColor: const Color(0xFFFDA4AF),
                bgColor: const Color(0xFFFFF1F2),
                onPressed: _openGoodsInwardReceiptDialog,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _openRegisterWarehouseDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text(
                  'Register Warehouse',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Magenta warehouse icon container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            LucideIcons.warehouse,
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
                'Warehouse, Godowns & Logistics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Manage multiple physical godowns, branch storage facilities, inter-warehouse transfers, rack zones, and inward receipts.',
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
          label: 'Goods Inward Receiving',
          icon: LucideIcons.truck,
          color: const Color(0xFFE11D48),
          borderColor: const Color(0xFFFDA4AF),
          bgColor: const Color(0xFFFFF1F2),
          onPressed: _openGoodsInwardReceiptDialog,
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: _openRegisterWarehouseDialog,
          icon: const Icon(LucideIcons.plus, size: 14),
          label: const Text(
            'Register Warehouse',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
  // 2. FOUR METRIC STAT CARDS (Image 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMetricCards(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final card1 = _buildSingleMetricCard(
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.warehouse,
                size: 16,
                color: Color(0xFFDB2777),
              ),
            ),
          ),
          mainValue: '${_warehouses.length} Active',
          subLabel: 'ACTIVE GODOWN FACILITIES',
          watermarkIcon: LucideIcons.warehouse,
          watermarkColor: const Color(0xFFFCE7F3),
        );

        final card2 = _buildSingleMetricCard(
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                r'$',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
          ),
          mainValue: '₹8,19,14,148',
          subLabel: 'MULTI-WAREHOUSE WORTH',
          watermarkText: r'$',
          watermarkColor: const Color(0xFFDCFCE7),
        );

        final card3 = _buildSingleMetricCard(
          iconBadge: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.truck,
                size: 16,
                color: Color(0xFFD97706),
              ),
            ),
          ),
          mainValue: '4 In Transit',
          subLabel: 'ACTIVE SHIPMENTS',
          watermarkIcon: LucideIcons.truck,
          watermarkColor: const Color(0xFFFEF3C7),
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
                LucideIcons.fileText,
                size: 16,
                color: Color(0xFF9333EA),
              ),
            ),
          ),
          mainValue: '68 Records',
          subLabel: 'INWARD RECEIPTS AUDITED',
          watermarkIcon: LucideIcons.fileText,
          watermarkColor: const Color(0xFFF3E8FF),
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
    IconData? watermarkIcon,
    String? watermarkText,
    required Color watermarkColor,
  }) {
    return Container(
      width: double.infinity,
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle watermark in bottom right corner (as seen in Image 1)
          if (watermarkIcon != null)
            Positioned(
              right: -10,
              bottom: -14,
              child: Opacity(
                opacity: 0.45,
                child: Icon(
                  watermarkIcon,
                  size: 64,
                  color: watermarkColor,
                ),
              ),
            ),
          if (watermarkText != null)
            Positioned(
              right: 2,
              bottom: -18,
              child: Opacity(
                opacity: 0.45,
                child: Text(
                  watermarkText,
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: watermarkColor,
                  ),
                ),
              ),
            ),
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. TAB BAR (Colors matching screenshots!)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isMobile) {
    final tabs = [
      _TabConfig(
        title: 'Registered Godowns & Locations',
        icon: LucideIcons.warehouse,
        activeColor: const Color(0xFFE11D48), // Rose/Magenta
      ),
      _TabConfig(
        title: 'Warehouse Stock Registry',
        icon: LucideIcons.layers,
        activeColor: const Color(0xFF2563EB), // Solid Blue (Image 1)
      ),
      _TabConfig(
        title: 'Goods Inward Historical logs',
        icon: LucideIcons.fileText,
        activeColor: const Color(0xFF7C3AED), // Solid Purple (Image 4)
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
  // TAB 0: REGISTERED GODOWNS & LOCATIONS (Cards Grid)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGodownsTab(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 750) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1120) {
          crossAxisCount = 2;
        }

        final itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 16)) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _warehouses.map((wh) {
            return SizedBox(
              width: itemWidth,
              child: _buildWarehouseCard(wh),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWarehouseCard(WarehouseItem wh) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          // Top Row: Code Pill (Green) & Capacity Pill (Blue)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  wh.code,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  wh.capacityUtilization,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Warehouse Name
          Text(
            wh.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),

          // Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(LucideIcons.mapPin, size: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  wh.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Contact Person Row
          Row(
            children: [
              const Icon(LucideIcons.user, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  wh.contactPerson,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Phone Row
          Row(
            children: [
              const Icon(LucideIcons.phone, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  wh.phone,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Email Row
          Row(
            children: [
              const Icon(LucideIcons.mail, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  wh.email.isEmpty ? '-' : wh.email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // "View the List" Action Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openWarehouseProductsListDialog(wh),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.layers, size: 14, color: Color(0xFF2563EB)),
                    SizedBox(width: 6),
                    Text(
                      'View the List',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Action Row: Edit & Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Edit Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openEditWarehouseDialog(wh),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFCE8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFEF08A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('✏️', style: TextStyle(fontSize: 11)),
                        SizedBox(width: 5),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF854D0E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Delete Button (Red Trash)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _deleteWarehouse(wh),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFE4E6)),
                    ),
                    child: const Icon(
                      LucideIcons.trash2,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: WAREHOUSE STOCK REGISTRY (Image 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStockRegistryTab(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
          if (isMobile && !isMacOS) {
            return _buildMobileWarehouseStockCardList(_stockRegistry);
          }

          const minWidth = 980.0;
          final width = math.max(constraints.maxWidth, minWidth);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table Header Row with sort/filter icons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 20, child: _buildSortableHeader('WAREHOUSE FACILITY')),
                        Expanded(flex: 24, child: _buildSortableHeader('PRODUCT DESCRIPTION')),
                        Expanded(flex: 18, child: _buildSortableHeader('STORAGE ZONE')),
                        Expanded(flex: 14, child: _buildSortableHeader('CURRENT STOCK')),
                        Expanded(flex: 12, child: _buildSortableHeader('DAMAGED QTY')),
                        Expanded(flex: 12, child: _buildSortableHeader('IN TRANSIT')),
                        Expanded(flex: 16, child: _buildSortableHeader('SOURCING VALUATION')),
                      ],
                    ),
                  ),

                  // Table Rows
                  ..._stockRegistry.map((item) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openStockMovementDetailsDialog(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                          child: Row(
                            children: [
                              // Warehouse Facility (Dark green bold as in Image 1)
                              Expanded(
                                flex: 20,
                                child: Text(
                                  item.warehouse,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                              // Product Description
                              Expanded(
                                flex: 24,
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              // Storage Zone
                              Expanded(
                                flex: 18,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Zone A',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Open Floor / Unassigned',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Current Stock
                              Expanded(
                                flex: 14,
                                child: Text(
                                  '${item.stock} pcs',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                              // Damaged Qty
                              Expanded(
                                flex: 12,
                                child: const Text(
                                  '0 pcs',
                                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                                ),
                              ),
                              // In Transit
                              Expanded(
                                flex: 12,
                                child: const Text(
                                  '0 pcs',
                                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                                ),
                              ),
                              // Sourcing Valuation
                              Expanded(
                                flex: 16,
                                child: Text(
                                  item.name == 'curd aarokya'
                                      ? '₹3,510'
                                      : item.name == 'gulob jamun'
                                          ? '₹7,79,95,788'
                                          : item.name == 'new product cliks business'
                                              ? '₹2,50,000'
                                              : '₹${item.valuation.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortableHeader(String text) {
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
        const SizedBox(width: 5),
        // Filter + Sort Pill (Matching Image 1 [ ▽ ⇅ ])
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.filter, size: 8.5, color: Color(0xFF94A3B8)),
              SizedBox(width: 2),
              Icon(LucideIcons.arrowUpDown, size: 8.5, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: GOODS INWARD HISTORICAL LOGS (Image 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGoodsInwardAuditTab(bool isMobile) {
    return Container(
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
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Goods Inwards Audit Trail',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          // Audit Table
          LayoutBuilder(
            builder: (context, constraints) {
              final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
              if (isMobile && !isMacOS) {
                return _buildMobileGoodsInwardCardList(_inwardReceipts);
              }

              const minWidth = 920.0;
              final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 14, child: _TableHeaderText('Inward ID')),
                            Expanded(flex: 18, child: _TableHeaderText('Purchase bill ref')),
                            Expanded(flex: 22, child: _TableHeaderText('Product Description')),
                            Expanded(flex: 14, child: _TableHeaderText('Received Qty')),
                            Expanded(flex: 16, child: _TableHeaderText('Received By')),
                            Expanded(flex: 16, child: _TableHeaderText('Date Received')),
                            Expanded(flex: 18, child: _TableHeaderText('Destination Warehouse')),
                          ],
                        ),
                      ),

                      // Rows
                      ..._inwardReceipts.map((rc) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          child: Row(
                            children: [
                              // Inward ID (Bold dark green as in Image 4)
                              Expanded(
                                flex: 14,
                                child: Text(
                                  rc.inwardId,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                              // Purchase bill ref
                              Expanded(
                                flex: 18,
                                child: Text(
                                  rc.purchaseBillRef,
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                                ),
                              ),
                              // Product Description (Bold dark green as in Image 4)
                              Expanded(
                                flex: 22,
                                child: Text(
                                  rc.productDescription,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                              // Received Qty
                              Expanded(
                                flex: 14,
                                child: Text(
                                  '${rc.receivedQty} pcs',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              // Received By
                              Expanded(
                                flex: 16,
                                child: Text(
                                  rc.receivedBy,
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                                ),
                              ),
                              // Date Received
                              Expanded(
                                flex: 16,
                                child: Text(
                                  rc.dateReceived,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ),
                              // Destination Warehouse
                              Expanded(
                                flex: 18,
                                child: Text(
                                  rc.destinationWarehouse,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
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
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE CARD PRESENTATION WIDGETS (WAREHOUSE PAGE)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileWarehouseStockCardList(List<WarehouseProductItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No warehouse stock items found.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final valText = item.name == 'curd aarokya'
            ? '₹3,510'
            : item.name == 'gulob jamun'
                ? '₹7,79,95,788'
                : item.name == 'new product cliks business'
                    ? '₹2,50,000'
                    : '₹${item.valuation.toStringAsFixed(0)}';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openStockMovementDetailsDialog(item),
            borderRadius: BorderRadius.circular(12),
            child: Container(
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
                      Expanded(
                        child: Text(
                          item.warehouse,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.stock} pcs',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Zone A • Open Floor / Unassigned',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valuation:',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        Flexible(
                          child: Text(
                            valText,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileGoodsInwardCardList(List<InwardReceiptItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No goods inward records found.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final rc = items[index];
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
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      rc.inwardId,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    ),
                  ),
                  Text(
                    rc.dateReceived,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rc.productDescription,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Bill Ref: ${rc.purchaseBillRef}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Qty: ${rc.receivedQty} pcs',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'By: ${rc.receivedBy}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'To: ${rc.destinationWarehouse}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

// ─── TABLE HEADER TEXT HELPER ─────────────────────────────────

class _TableHeaderText extends StatelessWidget {
  final String text;
  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
  }
}

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

// ─── STOCK ITEM DETAILS & MOVEMENT HISTORY (Image 2) ──────────

class _StockMovementHistoryDialog extends StatelessWidget {
  final WarehouseProductItem product;

  const _StockMovementHistoryDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 520,
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
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
            children: [
              // Top Title with Package Icon and Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 14),
                child: Row(
                  children: [
                    const Text('📦', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${product.sku} · ${product.warehouse}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
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

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3 Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildBadgeCard(
                              title: 'CURRENT STOCK',
                              value: '${product.stock} pcs',
                              bgColor: const Color(0xFFDCFCE7),
                              textColor: const Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildBadgeCard(
                              title: 'DAMAGED',
                              value: '0 pcs',
                              bgColor: const Color(0xFFFEE2E2),
                              textColor: const Color(0xFFBE123C),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildBadgeCard(
                              title: 'IN TRANSIT',
                              value: '0 pcs',
                              bgColor: const Color(0xFFFEF3C7),
                              textColor: const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Storage Location Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(LucideIcons.mapPin, size: 13, color: Color(0xFFE11D48)),
                                SizedBox(width: 6),
                                Text(
                                  'Storage Location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildLocationSubItem('Zone', 'Zone A')),
                                Expanded(child: _buildLocationSubItem('Rack', '—')),
                                Expanded(child: _buildLocationSubItem('Shelf', '—')),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _buildLocationSubItem('Bin', '—')),
                                Expanded(child: _buildLocationSubItem('Valuation', '₹3,510')),
                                Expanded(child: _buildLocationSubItem('SKU', product.sku)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Stock Movement History Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
                                Icon(LucideIcons.history, size: 14, color: Color(0xFF64748B)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Stock Movement History (Recent)',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Live Ledger Sync',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Timeline Items with Connected Track (Image 2)
                      _buildTimelineItem(
                        dotColor: const Color(0xFF16A34A),
                        title: 'Goods Inward Receipt — ',
                        highlightText: '+16 pcs',
                        highlightColor: const Color(0xFF16A34A),
                        date: '2026-10-14',
                        docRef: 'Receipt Inward Ref #INW-295',
                        balanceText: 'Bal: 45 pcs',
                        isFirst: true,
                      ),
                      _buildTimelineItem(
                        dotColor: const Color(0xFFEF4444),
                        title: 'Sales Dispatch — ',
                        highlightText: '-5 pcs',
                        highlightColor: const Color(0xFFEF4444),
                        date: '2026-05-20',
                        docRef: 'B2B Sales Delivery Challan',
                        balanceText: 'Bal: 34 pcs',
                      ),
                      _buildTimelineItem(
                        dotColor: const Color(0xFF2563EB),
                        title: 'Inter-Warehouse Transfer In — ',
                        highlightText: '+9 pcs',
                        highlightColor: const Color(0xFF2563EB),
                        date: '2026-05-15',
                        docRef: 'Branch Dispatch Transfer',
                        balanceText: 'Bal: 38 pcs',
                      ),
                      _buildTimelineItem(
                        dotColor: const Color(0xFFF59E0B),
                        title: 'Damage Write-off — ',
                        highlightText: '-0 pcs',
                        highlightColor: const Color(0xFFF59E0B),
                        date: '2026-05-10',
                        docRef: 'Inspection Quarantine',
                        balanceText: 'Bal: 29 pcs',
                      ),
                      _buildTimelineItem(
                        dotColor: const Color(0xFF9333EA),
                        title: 'Opening Stock Audit — ',
                        highlightText: '25 pcs',
                        highlightColor: const Color(0xFF9333EA),
                        date: '2026-05-01',
                        docRef: 'Physical Master Verification',
                        balanceText: 'Bal: 25 pcs',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSubItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required Color dotColor,
    required String title,
    required String highlightText,
    required Color highlightColor,
    required String date,
    required String docRef,
    required String balanceText,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline track with dot
          SizedBox(
            width: 16,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: isFirst ? 14 : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 14 : null,
                  width: 1.5,
                  child: Container(
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                Positioned(
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Timeline Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              TextSpan(
                                text: highlightText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: highlightColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          balanceText,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          docRef,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── REGISTER NEW WAREHOUSE FACILITY DIALOG (Image 3) ─────────

class _RegisterWarehouseFacilityDialog extends StatefulWidget {
  final void Function(WarehouseItem newWarehouse) onRegister;

  const _RegisterWarehouseFacilityDialog({required this.onRegister});

  @override
  State<_RegisterWarehouseFacilityDialog> createState() => _RegisterWarehouseFacilityDialogState();
}

class _RegisterWarehouseFacilityDialogState extends State<_RegisterWarehouseFacilityDialog> {
  final _nameCtrl = TextEditingController(text: 'Delhi Godown');
  final _codeCtrl = TextEditingController(text: 'WH-DEL-04');
  String _facilityType = 'Godown (Bulk Storage)';
  final _addressCtrl = TextEditingController(text: 'Plot No 40...');
  final _pincodeCtrl = TextEditingController(text: 'e.g. 602001');
  final _cityCtrl = TextEditingController(text: 'Tiruvallur / Chenr');
  final _stateCtrl = TextEditingController(text: 'Tamil Nadu');
  final _managerCtrl = TextEditingController(text: 'Ashwin');
  final _mobileCtrl = TextEditingController(text: '9876543210');
  final _emailCtrl = TextEditingController(text: 'e.g. manager@br');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _managerCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a warehouse name.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    final code = _codeCtrl.text.trim().isEmpty ? 'WH-01' : _codeCtrl.text.trim();

    final item = WarehouseItem(
      id: 'WH-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      code: code,
      capacityUtilization: 'CAPACITY UTILIZATION: 0%',
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      contactPerson: _managerCtrl.text.trim(),
      phone: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      facilityType: _facilityType,
      products: [],
    );

    widget.onRegister(item);
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
          width: 520,
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
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
            children: [
              // Header without divider (Matching Image 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Register New Warehouse Facility',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final isNarrow = box.maxWidth < 450;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Warehouse Name & Warehouse Code
                          if (isNarrow) ...[
                            _buildField('Warehouse Name', _nameCtrl, 'Delhi Godown'),
                            const SizedBox(height: 14),
                            _buildField('Warehouse Code', _codeCtrl, 'WH-DEL-04'),
                          ] else
                            Row(
                              children: [
                                Expanded(child: _buildField('Warehouse Name', _nameCtrl, 'Delhi Godown')),
                                const SizedBox(width: 14),
                                Expanded(child: _buildField('Warehouse Code', _codeCtrl, 'WH-DEL-04')),
                              ],
                            ),
                          const SizedBox(height: 16),

                          // Facility Type Dropdown
                          const Text(
                            'Facility Type',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
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
                                value: _facilityType,
                                isExpanded: true,
                                icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                                items: const [
                                  DropdownMenuItem(value: 'Godown (Bulk Storage)', child: Text('Godown (Bulk Storage)', style: TextStyle(fontSize: 13))),
                                  DropdownMenuItem(value: 'Distribution Center', child: Text('Distribution Center', style: TextStyle(fontSize: 13))),
                                  DropdownMenuItem(value: 'Branch Storage', child: Text('Branch Storage', style: TextStyle(fontSize: 13))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _facilityType = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Address
                          _buildField('Address', _addressCtrl, 'Plot No 40...'),
                          const SizedBox(height: 16),

                          // Pincode, City, State
                          if (isNarrow) ...[
                            _buildField('Pincode', _pincodeCtrl, 'e.g. 602001'),
                            const SizedBox(height: 14),
                            _buildField('City', _cityCtrl, 'Tiruvallur / Chenr'),
                            const SizedBox(height: 14),
                            _buildField('State', _stateCtrl, 'Tamil Nadu'),
                          ] else
                            Row(
                              children: [
                                Expanded(flex: 3, child: _buildField('Pincode', _pincodeCtrl, 'e.g. 602001')),
                                const SizedBox(width: 10),
                                Expanded(flex: 3, child: _buildField('City', _cityCtrl, 'Tiruvallur / Chenr')),
                                const SizedBox(width: 10),
                                Expanded(flex: 3, child: _buildField('State', _stateCtrl, 'Tamil Nadu')),
                              ],
                            ),
                          const SizedBox(height: 16),

                          // Manager Name, Mobile, Email
                          if (isNarrow) ...[
                            _buildField('Contact Manager Name', _managerCtrl, 'Ashwin'),
                            const SizedBox(height: 14),
                            _buildField('Contact Mobile (10 Digits)', _mobileCtrl, '9876543210', isNumeric: true),
                            const SizedBox(height: 14),
                            _buildField('Contact Email Address *', _emailCtrl, 'e.g. manager@br'),
                          ] else
                            Row(
                              children: [
                                Expanded(child: _buildField('Contact Manager Name', _managerCtrl, 'Ashwin')),
                                const SizedBox(width: 10),
                                Expanded(child: _buildField('Contact Mobile (10 Digits)', _mobileCtrl, '9876543210', isNumeric: true)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildField('Contact Email Address *', _emailCtrl, 'e.g. manager@br')),
                              ],
                            ),
                          const SizedBox(height: 26),

                          // Big Purple Button (Image 3)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Register Facility Profile',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
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
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── GOODS INWARD RECEIPT MODAL (Image 5) ─────────────────────

class _GoodsInwardReceiptDialog extends StatefulWidget {
  final List<WarehouseProductItem> stockList;
  final List<WarehouseItem> warehouses;
  final void Function(InwardReceiptItem receipt) onLogReceipt;

  const _GoodsInwardReceiptDialog({
    required this.stockList,
    required this.warehouses,
    required this.onLogReceipt,
  });

  @override
  State<_GoodsInwardReceiptDialog> createState() => _GoodsInwardReceiptDialogState();
}

class _GoodsInwardReceiptDialogState extends State<_GoodsInwardReceiptDialog> {
  final _refCtrl = TextEditingController(text: 'BILL-90112');
  final _qtyCtrl = TextEditingController(text: '0');
  final _staffCtrl = TextEditingController(text: 'ravinew2004');
  late String _selectedProductDesc;
  late String _selectedDestinationWarehouse;

  @override
  void initState() {
    super.initState();
    _selectedProductDesc = widget.stockList.isNotEmpty
        ? '${widget.stockList.first.name} (${widget.stockList.first.sku}) — Current Stock: ${widget.stockList.first.stock} p'
        : 'curd aarokya (wijdhedh) — Current Stock: 45 p';

    _selectedDestinationWarehouse = widget.warehouses.isNotEmpty
        ? widget.warehouses.first.name
        : 'Damaged products godown';
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _qtyCtrl.dispose();
    _staffCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final billRef = _refCtrl.text.trim();
    final staff = _staffCtrl.text.trim();

    // Extract product name from selected desc
    String prodName = 'new added in cliks';
    if (widget.stockList.isNotEmpty) {
      prodName = widget.stockList.first.name;
    }

    final receipt = InwardReceiptItem(
      inwardId: 'INW-322',
      purchaseBillRef: billRef.isEmpty ? 'N/A' : billRef,
      productDescription: prodName,
      receivedQty: qty <= 0 ? 25 : qty,
      receivedBy: staff.isEmpty ? 'ravinew2004' : staff,
      dateReceived: '2026-10-14',
      destinationWarehouse: _selectedDestinationWarehouse,
    );

    widget.onLogReceipt(receipt);
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
          width: 480,
          constraints: const BoxConstraints(maxWidth: 500),
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
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Goods Inward Receipt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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

                // Purchase Bill / Ref ID
                _buildFieldLabel('Purchase Bill / Ref ID'),
                _buildInputContainer(_refCtrl),
                const SizedBox(height: 16),

                // Product Name Dropdown
                _buildFieldLabel('Product Name'),
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
                      value: _selectedProductDesc,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                      items: [
                        DropdownMenuItem(
                          value: _selectedProductDesc,
                          child: Text(
                            _selectedProductDesc,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                      onChanged: (val) {},
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Received Quantity
                _buildFieldLabel('Received Quantity'),
                _buildInputContainer(_qtyCtrl, isNumeric: true),
                const SizedBox(height: 16),

                // Received By / Staff
                _buildFieldLabel('Received By / Staff'),
                _buildInputContainer(_staffCtrl),
                const SizedBox(height: 16),

                // Receiving Destination Warehouse
                _buildFieldLabel('Receiving Destination Warehouse'),
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
                      value: _selectedDestinationWarehouse,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                      items: widget.warehouses.map((w) {
                        return DropdownMenuItem(
                          value: w.name,
                          child: Text(w.name, style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDestinationWarehouse = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // Action Button: Log Good Inward Receipt (Purple #7C3AED)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Log Good Inward Receipt',
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

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildInputContainer(TextEditingController ctrl, {bool isNumeric = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

// ─── WAREHOUSE PRODUCTS LIST DIALOG ───────────────────────────

class _WarehouseProductsListDialog extends StatefulWidget {
  final WarehouseItem warehouse;

  const _WarehouseProductsListDialog({required this.warehouse});

  @override
  State<_WarehouseProductsListDialog> createState() => _WarehouseProductsListDialogState();
}

class _WarehouseProductsListDialogState extends State<_WarehouseProductsListDialog> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = widget.warehouse.products.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 780,
          constraints: const BoxConstraints(maxWidth: 820),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Blue Top Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                color: const Color(0xFF2563EB),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.warehouse,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.warehouse.name} — Products List',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Facility Code: ${widget.warehouse.code} | Total Items: ${widget.warehouse.products.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFBFDBFE),
                            ),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Search & Total Value Row
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            hintText: 'Search product, SKU...',
                            hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(LucideIcons.search, size: 15, color: Color(0xFF94A3B8)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Total Inventory Value: ',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          TextSpan(
                            text: widget.warehouse.id == 'WH-3'
                                ? '₹8,14,40,638'
                                : '₹${widget.warehouse.totalInventoryValue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Products Table
              Flexible(
                child: Builder(
                  builder: (context) {
                    final isMobile = MediaQuery.of(context).size.width < 700;
                    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
                    if (isMobile && !isMacOS) {
                      return _buildMobileProductsCardList(filtered);
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: 780,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              border: Border(
                                top: BorderSide(color: Color(0xFFE2E8F0)),
                                bottom: BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Expanded(flex: 22, child: _TableHeaderText('Product Name')),
                                Expanded(flex: 18, child: _TableHeaderText('SKU Code')),
                                Expanded(flex: 16, child: _TableHeaderText('Category')),
                                Expanded(flex: 14, child: _TableHeaderText('Stock / Qty')),
                                Expanded(flex: 10, child: _TableHeaderText('Unit')),
                                Expanded(flex: 14, child: _TableHeaderText('Unit Cost')),
                                Expanded(flex: 12, child: _TableHeaderText('Status')),
                              ],
                            ),
                          ),

                          // Table Rows
                          if (filtered.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No products found in this warehouse.',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                ),
                              ),
                            )
                          else
                            ...filtered.map((p) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 22,
                                      child: Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 18,
                                      child: Text(
                                        p.sku,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 16,
                                      child: Text(
                                        p.category,
                                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 14,
                                      child: Text(
                                        '${p.stock}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 10,
                                      child: Text(
                                        p.unit,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 14,
                                      child: Text(
                                        '₹${p.unitCost.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 12,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            p.status,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF16A34A),
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
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildMobileProductsCardList(List<WarehouseProductItem> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No products found in this warehouse.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      p.status,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    p.sku,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${p.category}',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stock: ${p.stock} ${p.unit}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                  ),
                  Text(
                    'Cost: ₹${p.unitCost.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── EDIT WAREHOUSE PROFILE DIALOG ────────────────────────────

class _EditWarehouseProfileDialog extends StatefulWidget {
  final WarehouseItem warehouse;
  final void Function(WarehouseItem updated) onSave;

  const _EditWarehouseProfileDialog({
    required this.warehouse,
    required this.onSave,
  });

  @override
  State<_EditWarehouseProfileDialog> createState() => _EditWarehouseProfileDialogState();
}

class _EditWarehouseProfileDialogState extends State<_EditWarehouseProfileDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final wh = widget.warehouse;
    _nameCtrl = TextEditingController(text: wh.name);
    _codeCtrl = TextEditingController(text: wh.code);
    _addressCtrl = TextEditingController(text: wh.address);
    _cityCtrl = TextEditingController(text: wh.city);
    _stateCtrl = TextEditingController(text: wh.state);
    _pincodeCtrl = TextEditingController(text: wh.pincode);
    _contactCtrl = TextEditingController(text: wh.contactPerson);
    _phoneCtrl = TextEditingController(text: wh.phone);
    _emailCtrl = TextEditingController(text: wh.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a warehouse name.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    final updated = WarehouseItem(
      id: widget.warehouse.id,
      name: name,
      code: _codeCtrl.text.trim().isEmpty ? widget.warehouse.code : _codeCtrl.text.trim(),
      capacityUtilization: widget.warehouse.capacityUtilization,
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      contactPerson: _contactCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      products: widget.warehouse.products,
    );

    widget.onSave(updated);
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
          width: 480,
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
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
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        '✏️ Edit Warehouse Profile',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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

              // Scrollable Form Fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField('Warehouse Name', _nameCtrl),
                      const SizedBox(height: 16),
                      _buildField('Code', _codeCtrl),
                      const SizedBox(height: 16),
                      _buildField('Address', _addressCtrl),
                      const SizedBox(height: 16),
                      _buildField('City', _cityCtrl),
                      const SizedBox(height: 16),
                      _buildField('State', _stateCtrl),
                      const SizedBox(height: 16),
                      _buildField('Pincode', _pincodeCtrl),
                      const SizedBox(height: 16),
                      _buildField('Contact Person', _contactCtrl),
                      const SizedBox(height: 16),
                      _buildField('Phone', _phoneCtrl),
                      const SizedBox(height: 16),
                      _buildField('Email', _emailCtrl),
                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
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
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
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
            controller: controller,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
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
