import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../navigation/widgets/macos_showroom_menu_card.dart';

// ─── DATA MODELS ──────────────────────────────────────────────

class ShowroomBranchItem {
  final String id;
  String name;
  String code;
  String invoicePrefix;
  String address;
  String city;
  String phone;
  String gstin;
  bool isHQ;
  int stockItemsCount;
  double totalUnits;
  List<String> managers;

  ShowroomBranchItem({
    required this.id,
    required this.name,
    required this.code,
    required this.invoicePrefix,
    required this.address,
    required this.city,
    required this.phone,
    this.gstin = '',
    this.isHQ = false,
    this.stockItemsCount = 15,
    this.totalUnits = 5372.75,
    this.managers = const ['Ravi K (Store Admin)'],
  });
}

class BranchStockProduct {
  final String name;
  final String sku;
  final String category;
  int stock;
  int threshold;
  int mainWarehouseStock;
  int suggestedReorder;
  double sellingPrice;
  final String showroom;
  bool isSelectedForIndent;

  BranchStockProduct({
    required this.name,
    required this.sku,
    required this.category,
    required this.stock,
    this.threshold = 5,
    this.mainWarehouseStock = 0,
    this.suggestedReorder = 10,
    required this.sellingPrice,
    required this.showroom,
    this.isSelectedForIndent = false,
  });

  bool get isCritical => stock <= threshold;
}

class BranchTransferItem {
  final String id;
  final String date;
  final String fromBranch;
  final String toBranch;
  final String product;
  final int quantity;
  final String reason;
  final String status;
  final bool isReturn;

  BranchTransferItem({
    required this.id,
    required this.date,
    required this.fromBranch,
    required this.toBranch,
    required this.product,
    required this.quantity,
    required this.reason,
    this.status = 'Dispatched',
    this.isReturn = false,
  });
}

class ShowroomPromotionItem {
  final String id;
  final String showroomId;
  final String showroomName;
  final String showroomCode;
  final String title;
  final String discountType;
  final double discountValue;
  final String scope;
  final double minBillAmount;
  final String startDate;
  final String endDate;
  final String justification;
  String status; // 'Pending Approval', 'Approved / Active', 'Rejected'
  final String createdAt;

  ShowroomPromotionItem({
    required this.id,
    required this.showroomId,
    required this.showroomName,
    required this.showroomCode,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.scope,
    this.minBillAmount = 0.0,
    required this.startDate,
    required this.endDate,
    required this.justification,
    this.status = 'Pending Approval',
    required this.createdAt,
  });
}

// ─── SHOWROOMS & MULTI-BRANCH PAGE ─────────────────────────────

class ShowroomsPage extends ConsumerStatefulWidget {
  const ShowroomsPage({super.key});

  @override
  ConsumerState<ShowroomsPage> createState() => _ShowroomsPageState();
}

class _ShowroomsPageState extends ConsumerState<ShowroomsPage> {
  // Tabs matching reference designs:
  // 0: Showrooms List (1)
  // 1: Branch Stock Matrix
  // 2: Low Stock & Auto-Reorder 8
  // 3: Transfers & Returns Log (0)
  // 4: Showroom Promos & Discounts
  // 5: Cross-Branch Loyalty & Credit
  int _activeTabIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _selectAllReplenishment = false;

  late List<ShowroomBranchItem> _showrooms;
  late List<BranchStockProduct> _products;
  late List<BranchTransferItem> _transfers;
  late List<ShowroomPromotionItem> _promotions;
  String _selectedPromoStatusFilter = 'All';
  String _selectedPromoShowroomFilter = 'All Showrooms';

  @override
  void initState() {
    super.initState();
    _promotions = [];

    _showrooms = [
      ShowroomBranchItem(
        id: 'SHW-01',
        name: 'Main Showroom',
        code: 'MAIN-01',
        invoicePrefix: 'MS-',
        address: 'Central Commercial Hub, Chennai',
        city: 'Chennai',
        phone: '+91 98765 43210',
        gstin: '33AAAAA0000A1Z5',
        isHQ: true,
        stockItemsCount: 15,
        totalUnits: 5372.75,
        managers: ['Ravi K (Store Admin)', 'Admin (General Manager)'],
      ),
    ];

    // 15 products with exactly 8 shortages (stock <= threshold), perfectly matching images 1, 2, 3, 4!
    _products = [
      BranchStockProduct(
        name: 'a new digit product',
        sku: 'SKU-3752',
        category: 'General',
        stock: 182,
        threshold: 20,
        mainWarehouseStock: 500,
        suggestedReorder: 50,
        sellingPrice: 1000004399.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'apple',
        sku: 'app',
        category: 'Electronics',
        stock: 0,
        threshold: 5,
        mainWarehouseStock: 0,
        suggestedReorder: 10,
        sellingPrice: 500.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'car',
        sku: '54',
        category: 'Electronics',
        stock: 0,
        threshold: 5,
        mainWarehouseStock: 0,
        suggestedReorder: 10,
        sellingPrice: 100000.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'Thermal Receipt Rolls 80mm',
        sku: 'POS-ROLL-80',
        category: 'Supplies',
        stock: 0,
        threshold: 50,
        mainWarehouseStock: 0,
        suggestedReorder: 50,
        sellingPrice: 45.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'A4 Billing Stationary',
        sku: 'STAT-A4-01',
        category: 'Supplies',
        stock: 0,
        threshold: 40,
        mainWarehouseStock: 0,
        suggestedReorder: 40,
        sellingPrice: 350.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'Barcode Label Sticker Rolls',
        sku: 'BAR-LBL-100',
        category: 'Supplies',
        stock: 0,
        threshold: 30,
        mainWarehouseStock: 0,
        suggestedReorder: 30,
        sellingPrice: 180.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'Retail Carry Bags (Medium)',
        sku: 'BAG-MED-05',
        category: 'Packaging',
        stock: 0,
        threshold: 200,
        mainWarehouseStock: 0,
        suggestedReorder: 200,
        sellingPrice: 15.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'Hand Sanitizer Disinfection Pack',
        sku: 'SAN-500ML',
        category: 'Hygiene',
        stock: 0,
        threshold: 25,
        mainWarehouseStock: 0,
        suggestedReorder: 25,
        sellingPrice: 120.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'Branded Price Tags (Heavy)',
        sku: 'TAG-BRND-50',
        category: 'Merchandising',
        stock: 0,
        threshold: 150,
        mainWarehouseStock: 0,
        suggestedReorder: 150,
        sellingPrice: 5.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'BMW car',
        sku: 'BMW-788',
        category: 'Vehicles',
        stock: 33,
        threshold: 10,
        mainWarehouseStock: 25,
        suggestedReorder: 10,
        sellingPrice: 100000.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'curd aarokya',
        sku: 'wijdhedh',
        category: 'Dairy',
        stock: 45,
        threshold: 20,
        mainWarehouseStock: 200,
        suggestedReorder: 50,
        sellingPrice: 78.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'gulob jamun',
        sku: 'wehdjbwue',
        category: 'Food',
        stock: 999946,
        threshold: 100,
        mainWarehouseStock: 1000000,
        suggestedReorder: 1000,
        sellingPrice: 78.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'carrot',
        sku: 'SKU-746095',
        category: 'General',
        stock: 1190,
        threshold: 100,
        mainWarehouseStock: 5000,
        suggestedReorder: 500,
        sellingPrice: 45.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'PEN',
        sku: 'HFJHFJ',
        category: 'Electronics',
        stock: 800,
        threshold: 50,
        mainWarehouseStock: 2000,
        suggestedReorder: 500,
        sellingPrice: 111.0,
        showroom: 'Main Showroom',
      ),
      BranchStockProduct(
        name: 'Raw Banana',
        sku: '544',
        category: 'Food',
        stock: 100,
        threshold: 50,
        mainWarehouseStock: 500,
        suggestedReorder: 100,
        sellingPrice: 25.0,
        showroom: 'Main Showroom',
      ),
    ];

    _transfers = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _criticalStockCount => _products.where((p) => p.isCritical).length;

  void _recalculateShowroomStats() {
    if (_showrooms.isEmpty) return;
    final totalUnits = _products.fold<double>(0.0, (sum, p) => sum + p.stock);
    _showrooms.first.totalUnits = totalUnits;
    _showrooms.first.stockItemsCount = _products.length;
  }

  // ─── ACTION DIALOGS ──────────────────────────────────────────

  void _openTransferStockDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _TransferGoodsAcrossShowroomsDialog(
        showrooms: _showrooms,
        products: _products,
        onConfirmTransfer: (item) {
          setState(() {
            _transfers.insert(0, item);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dispatched transfer of ${item.quantity} units to ${item.toBranch}.'),
              backgroundColor: const Color(0xFF0E4D34),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openReturnGoodsDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _ReturnGoodsToMainWarehouseDialog(
        showrooms: _showrooms,
        products: _products,
        onConfirmReturn: (item) {
          setState(() {
            _transfers.insert(0, item);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dispatched return of ${item.quantity} units to Central Warehouse.'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openRegisterShowroomDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _RegisterNewShowroomDialog(
        onRegister: (newShowroom) {
          setState(() {
            if (newShowroom.isHQ) {
              for (var s in _showrooms) {
                s.isHQ = false;
              }
            }
            _showrooms.add(newShowroom);
            _activeTabIndex = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Showroom "${newShowroom.name}" registered successfully.'),
              backgroundColor: const Color(0xFF0E4D34),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openShowroomManagersDialog(ShowroomBranchItem showroom) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _ShowroomManagersDialog(
        showroom: showroom,
        onUpdate: () => setState(() {}),
      ),
    );
  }

  void _openAdjustStockDialog(BranchStockProduct product) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _AdjustStockForShowroomDialog(
        product: product,
        showroomName: _showrooms.isNotEmpty ? _showrooms.first.name : 'Main Showroom',
        onSave: (newStock) {
          setState(() {
            product.stock = newStock;
            _recalculateShowroomStats();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stock updated for "${product.name}" to $newStock PCS.'),
              backgroundColor: const Color(0xFF0E4D34),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openRequestPromotionDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _RequestShowroomPromotionDialog(
        showrooms: _showrooms,
        onCreated: (newPromo) {
          setState(() {
            _promotions.insert(0, newPromo);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Promotion request submitted for "${newPromo.showroomName}".'),
              backgroundColor: const Color(0xFF0E4D34),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openEditShowroomDialog(ShowroomBranchItem showroom) {
    final nameCtrl = TextEditingController(text: showroom.name);
    final codeCtrl = TextEditingController(text: showroom.code);
    final prefixCtrl = TextEditingController(text: showroom.invoicePrefix);
    final addrCtrl = TextEditingController(text: showroom.address);
    final cityCtrl = TextEditingController(text: showroom.city);
    final phoneCtrl = TextEditingController(text: showroom.phone);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.pencil, size: 18, color: Color(0xFF0E4D34)),
            SizedBox(width: 8),
            Text('Edit Showroom Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Showroom Name')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Branch Code'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: prefixCtrl, decoration: const InputDecoration(labelText: 'Invoice Prefix'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E4D34), foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                showroom.name = nameCtrl.text.trim();
                showroom.code = codeCtrl.text.trim();
                showroom.invoicePrefix = prefixCtrl.text.trim();
                showroom.address = addrCtrl.text.trim();
                showroom.city = cityCtrl.text.trim();
                showroom.phone = phoneCtrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save Changes'),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isMobile ? 14 : 28,
          isMobile ? 16 : 24,
          isMobile ? 14 : 28,
          isMobile ? 90 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP HEADER BANNER & ACTION BUTTONS ───
            _buildTopBanner(isMobile),
            const SizedBox(height: 20),

            // ─── 2. 5 SUMMARY METRIC CARDS ───
            _buildSummaryMetricCards(isMobile),
            const SizedBox(height: 22),

            // ─── 3. SEGMENTED TABS BAR ───
            _buildSegmentedTabBar(isMobile),
            const SizedBox(height: 18),

            // ─── 4. SEARCH INPUT BAR ───
            _buildSearchBar(),
            const SizedBox(height: 18),

            // ─── 5. ACTIVE TAB CONTENT VIEW ───
            _buildActiveTabContent(isMobile),
          ],
        ),
      ),
    );
  }

  // ─── 1. TOP BANNER & ACTION BUTTONS (Image 1 & 2) ─────────────

  Widget _buildTopBanner(bool isMobile) {
    final headerLeft = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0E4D34),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E4D34).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              LucideIcons.store,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showrooms & Multi-Branch',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Multi-outlet inventory control, showroom billing separation, and inter-branch stock transfers.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actionButtons = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 1. Showroom Managers
        _buildHeaderButton(
          icon: LucideIcons.users,
          label: 'Showroom Managers',
          isOutlined: true,
          textColor: const Color(0xFF334155),
          borderColor: const Color(0xFFE2E8F0),
          onTap: () {
            if (_showrooms.isNotEmpty) {
              _openShowroomManagersDialog(_showrooms.first);
            }
          },
        ),

        // 2. Transfer Stock
        _buildHeaderButton(
          icon: LucideIcons.arrowRightLeft,
          label: 'Transfer Stock',
          isOutlined: true,
          textColor: const Color(0xFF334155),
          borderColor: const Color(0xFFE2E8F0),
          onTap: _openTransferStockDialog,
        ),

        // 3. Return Goods to Main
        _buildHeaderButton(
          icon: LucideIcons.rotateCcw,
          label: 'Return Goods to Main',
          isOutlined: true,
          textColor: const Color(0xFFDC2626),
          borderColor: const Color(0xFFFECDD3),
          onTap: _openReturnGoodsDialog,
        ),

        // 4. + Add Showroom (Solid Green)
        _buildHeaderButton(
          icon: LucideIcons.plus,
          label: '+ Add Showroom',
          isOutlined: false,
          backgroundColor: const Color(0xFF0E4D34),
          textColor: Colors.white,
          onTap: _openRegisterShowroomDialog,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1050) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerLeft,
              const SizedBox(height: 16),
              actionButtons,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: headerLeft),
            const SizedBox(width: 16),
            actionButtons,
          ],
        );
      },
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required bool isOutlined,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : (backgroundColor ?? const Color(0xFF0E4D34)),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isOutlined ? (borderColor ?? const Color(0xFFCBD5E1)) : Colors.transparent,
              width: 1,
            ),
            boxShadow: isOutlined
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF0E4D34).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.5, color: textColor ?? const Color(0xFF334155)),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? const Color(0xFF334155),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 2. 5 SUMMARY METRIC CARDS (Image 1 & 2) ──────────────────

  Widget _buildSummaryMetricCards(bool isMobile) {
    final selectedScope = ref.watch(selectedShowroomScopeProvider);
    final activeBranchName = selectedScope == 'All Showrooms'
        ? (_showrooms.isNotEmpty ? _showrooms.first.name : 'Main Showroom')
        : selectedScope;

    final card1 = _buildSingleMetricCard(
      title: 'TOTAL SHOWROOMS',
      value: _showrooms.length.toString(),
      subtext: 'Active retail branches',
      subtextColor: const Color(0xFF16A34A),
    );

    final card2 = _buildSingleMetricCard(
      title: 'SELECTED BRANCH',
      value: activeBranchName,
      valueColor: const Color(0xFF0E4D34),
      subtext: 'Code: MAIN-01',
      subtextColor: const Color(0xFF64748B),
    );

    final card3 = _buildSingleMetricCard(
      title: 'ITEMS IN BRANCH',
      value: '${_products.length} / 23',
      subtext: 'Products stocked',
      subtextColor: const Color(0xFF64748B),
    );

    final card4 = _buildAlertMetricCard(
      title: 'LOW STOCK ALERTS',
      badge: '$_criticalStockCount critical',
      value: _criticalStockCount.toString(),
      subtext: 'Click to auto-replenish →',
      onTap: () {
        setState(() {
          _activeTabIndex = 2; // Switch to Low Stock & Auto-Reorder
        });
      },
    );

    final card5 = _buildSingleMetricCard(
      title: 'TRANSFERS & RETURNS',
      value: _transfers.length.toString(),
      subtext: 'Log movements',
      subtextColor: const Color(0xFF16A34A),
    );

    final cards = [card1, card2, card3, card4, card5];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: cards
              .map((c) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(width: 210, child: c),
                  ))
              .toList(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: cards
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SizedBox(width: 215, child: c),
                      ))
                  .toList(),
            ),
          );
        }

        return Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 14),
            Expanded(child: card2),
            const SizedBox(width: 14),
            Expanded(child: card3),
            const SizedBox(width: 14),
            Expanded(child: card4),
            const SizedBox(width: 14),
            Expanded(child: card5),
          ],
        );
      },
    );
  }

  Widget _buildSingleMetricCard({
    required String title,
    required String value,
    Color? valueColor,
    required String subtext,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: valueColor ?? const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertMetricCard({
    required String title,
    required String badge,
    required String value,
    required String subtext,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB45309),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFD97706),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 3. SEGMENTED TABS BAR (Image 1, 3, 5) ────────────────────

  Widget _buildSegmentedTabBar(bool isMobile) {
    final tabs = [
      (label: 'Showrooms List (${_showrooms.length})', icon: null, badge: null),
      (label: 'Branch Stock Matrix', icon: null, badge: null),
      (label: 'Low Stock & Auto-Reorder', icon: LucideIcons.zap, badge: '$_criticalStockCount'),
      (label: 'Transfers & Returns Log (${_transfers.length})', icon: null, badge: null),
      (label: 'Showroom Promos & Discounts', icon: LucideIcons.tag, badge: null),
      (label: 'Cross-Branch Loyalty & Credit', icon: LucideIcons.users, badge: null),
    ];

    Widget buildTabItem(
      ({String label, IconData? icon, String? badge}) t,
      int index,
    ) {
      final isSelected = _activeTabIndex == index;

      Color activeColor = const Color(0xFF0F172A);
      if (index == 2) {
        activeColor = const Color(0xFF7C3AED);
      } else if (index == 4) {
        activeColor = const Color(0xFF059669);
      }

      return InkWell(
        onTap: () => setState(() => _activeTabIndex = index),
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: isSelected ? Border.all(color: const Color(0xFFE2E8F0)) : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (t.icon != null) ...[
                Icon(
                  t.icon,
                  size: 13,
                  color: isSelected ? activeColor : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                t.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : const Color(0xFF64748B),
                ),
              ),
              if (t.badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t.badge!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(tabs.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: buildTabItem(tabs[index], index),
              );
            }),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 6,
        children: List.generate(tabs.length, (index) {
          return buildTabItem(tabs[index], index);
        }),
      ),
    );
  }

  // ─── 4. SEARCH INPUT BAR (Image 1, 3, 5) ──────────────────────

  Widget _buildSearchBar() {
    final hint = _activeTabIndex == 1
        ? 'Search products in this branch...'
        : 'Search showroom by name, code, city...';

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(LucideIcons.x, size: 15, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }

  // ─── 5. ACTIVE TAB CONTENT ───────────────────────────────────

  Widget _buildActiveTabContent(bool isMobile) {
    switch (_activeTabIndex) {
      case 0:
        return _buildShowroomsListTab(isMobile);
      case 1:
        return _buildBranchStockMatrixTab(isMobile);
      case 2:
        return _buildLowStockReorderTab(isMobile);
      case 3:
        return _buildTransfersReturnsLogTab(isMobile);
      case 4:
        return _buildPromosDiscountsTab(isMobile);
      case 5:
        return _buildCrossBranchLoyaltyTab(isMobile);
      default:
        return _buildShowroomsListTab(isMobile);
    }
  }

  // ─── TAB 0: SHOWROOMS LIST ───────────────────────────────────

  Widget _buildShowroomsListTab(bool isMobile) {
    final filtered = _showrooms.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.toLowerCase().contains(_searchQuery) ||
          s.code.toLowerCase().contains(_searchQuery) ||
          s.city.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.store, size: 40, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text(
              'No Showrooms Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different search query or register a new retail showroom.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openRegisterShowroomDialog,
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Add Showroom'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E4D34),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 800
            ? constraints.maxWidth
            : (constraints.maxWidth < 1200 ? (constraints.maxWidth - 16) / 2 : 460.0);

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: filtered.map((showroom) {
            return SizedBox(
              width: cardWidth,
              child: _buildShowroomCard(showroom),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildShowroomCard(ShowroomBranchItem showroom) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon + Title/Badge + Edit
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.building2,
                    color: Color(0xFF0D9488),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            showroom.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (showroom.isHQ) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'HQ / MAIN',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        InkWell(
                          onTap: () => _openEditShowroomDialog(showroom),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(LucideIcons.pencil, size: 12.5, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Code: ${showroom.code} | Prefix: ${showroom.invoicePrefix}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Address Line
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  showroom.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // Bottom Stats & Action Buttons (Responsive with Wrap to prevent overflow on mobile)
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STOCK ITEMS',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${showroom.stockItemsCount}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL UNITS',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        showroom.totalUnits.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  // + Add Manager button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openShowroomManagersDialog(showroom),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.userPlus, size: 12.5, color: Color(0xFF065F46)),
                            SizedBox(width: 5),
                            Text(
                              'Add Manager',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // View Stock > button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _activeTabIndex = 1; // Go to Branch Stock Matrix
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Stock',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(LucideIcons.chevronRight, size: 13, color: Color(0xFF334155)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: BRANCH STOCK MATRIX (Image 1 & 2) ─────────────────

  Widget _buildBranchStockMatrixTab(bool isMobile) {
    final filtered = _products.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery) ||
          p.sku.toLowerCase().contains(_searchQuery) ||
          p.category.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-header Bar: Current Showroom Dropdown + Refresh Button
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Current Showroom:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showrooms.isNotEmpty ? '${_showrooms.first.name} (${_showrooms.first.code})' : 'Main Showroom (MAIN-01)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Branch stock refreshed from Central Hub.'),
                      backgroundColor: Color(0xFF0E4D34),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.refreshCw, size: 12.5, color: Color(0xFF334155)),
                      SizedBox(width: 6),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Data Table Container matching Image 1
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 18,
              columnSpacing: 28,
              columns: const [
                DataColumn(label: Text('PRODUCT NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('SKU / BARCODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('SELLING PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('SHOWROOM STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('ACTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
              ],
              rows: filtered.map((p) {
                final isOutOfStock = p.stock == 0;

                return DataRow(
                  cells: [
                    // Product Name
                    DataCell(
                      Text(
                        p.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ),
                    // SKU / Barcode
                    DataCell(
                      Text(
                        p.sku,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    // Category
                    DataCell(
                      Text(
                        p.category,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    // Selling Price
                    DataCell(
                      Text(
                        _formatPrice(p.sellingPrice),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ),
                    // Showroom Stock
                    DataCell(
                      Text(
                        '${p.stock} PCS',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isOutOfStock ? const Color(0xFFDC2626) : const Color(0xFF059669),
                        ),
                      ),
                    ),
                    // Status Badge
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOutOfStock ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOutOfStock ? 'Out of Stock' : 'Available',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ),
                    // Action: Adjust Stock Button
                    DataCell(
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openAdjustStockDialog(p),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Text(
                              'Adjust Stock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '₹1,00,00,04,399';
    } else if (price >= 100000) {
      return '₹1,00,000';
    } else if (price >= 1000) {
      return '₹${price.toStringAsFixed(0)}';
    }
    return '₹${price.toStringAsFixed(0)}';
  }

  // ─── TAB 2: LOW STOCK & AUTO-REORDER (Images 3 & 4) ───────────

  Widget _buildLowStockReorderTab(bool isMobile) {
    final shortages = _products.where((p) => p.isCritical).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Card: Showroom Stock Depletion & Automated Replenishment
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with amber zap icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.zap, size: 18, color: Color(0xFFD97706)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Showroom Stock Depletion & Automated Replenishment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Identifies branch inventory at or below threshold and calculates suggested indent requisitions from Main Showroom.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Controls Row: Showroom Dropdown, Refresh, 1-Click Auto-Indent
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Showroom:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Main Showroom ⭐ (Main Central)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            SizedBox(width: 6),
                            Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Refresh Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() {}),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.refreshCw, size: 12, color: Color(0xFF334155)),
                            SizedBox(width: 5),
                            Text(
                              'Refresh',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 1-Click Auto-Indent (${shortages.length} Items) button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          for (var p in shortages) {
                            p.stock += p.suggestedReorder;
                          }
                          _recalculateShowroomStats();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Auto-indent requisition dispatched for ${shortages.length} items to Main Showroom.'),
                            backgroundColor: const Color(0xFF0E4D34),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.zap, size: 12, color: Color(0xFFD97706)),
                            const SizedBox(width: 6),
                            Text(
                              '1-Click Auto-Indent (${shortages.length} Items)',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Blue Notice Banner matching Image 3 & 4
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.info, size: 15, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Note: Main Showroom ',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E40AF), fontSize: 12),
                            ),
                            TextSpan(
                              text: 'is designated as the Main Central Warehouse. It fulfills stock requests sent by retail showrooms. Switch to a retail branch above to view its low-stock alerts and draft replenishment requisitions.',
                              style: TextStyle(color: Color(0xFF1E40AF), fontSize: 12),
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
        ),

        const SizedBox(height: 16),

        // 3 KPI Cards Row matching Image 4
        LayoutBuilder(
          builder: (context, constraints) {
            final card1 = _buildReplenishKpiCard(
              title: 'TOTAL SHORTAGES',
              value: '8',
              valueColor: const Color(0xFFD97706),
              subtext: 'Products at or below threshold',
              subtextColor: const Color(0xFF64748B),
              icon: LucideIcons.triangleAlert,
              iconColor: const Color(0xFFD97706),
              iconBgColor: const Color(0xFFFEF3C7),
            );

            final card2 = _buildReplenishKpiCard(
              title: 'CRITICAL OUT-OF-STOCK',
              value: '8',
              valueColor: const Color(0xFFDC2626),
              subtext: 'Zero items remaining on shelf',
              subtextColor: const Color(0xFFDC2626),
              icon: LucideIcons.circleAlert,
              iconColor: const Color(0xFFDC2626),
              iconBgColor: const Color(0xFFFEE2E2),
            );

            final card3 = _buildReplenishKpiCard(
              title: 'MAIN SHOWROOM READY',
              value: '0 / 8',
              valueColor: const Color(0xFF059669),
              subtext: 'Available for immediate dispatch',
              subtextColor: const Color(0xFF16A34A),
              icon: LucideIcons.circleCheck,
              iconColor: const Color(0xFF059669),
              iconBgColor: const Color(0xFFDCFCE7),
            );

            if (constraints.maxWidth < 800) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    SizedBox(width: 240, child: card1),
                    const SizedBox(width: 12),
                    SizedBox(width: 240, child: card2),
                    const SizedBox(width: 12),
                    SizedBox(width: 240, child: card3),
                  ],
                ),
              );
            }

            return Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 14),
                Expanded(child: card2),
                const SizedBox(width: 14),
                Expanded(child: card3),
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        // Items Requiring Replenishment Table Container matching Image 4
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Top Title Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Checkbox(
                      value: _selectAllReplenishment,
                      activeColor: const Color(0xFF059669),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          _selectAllReplenishment = val ?? false;
                          for (var p in shortages) {
                            p.isSelectedForIndent = _selectAllReplenishment;
                          }
                        });
                      },
                    ),
                    const Text(
                      'Items Requiring Replenishment',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    const Text(
                      'Central Warehouse: Main Showroom',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Horizontal scrollable DataTable
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  horizontalMargin: 18,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('PRODUCT DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('CURRENT SHOWROOM STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('THRESHOLD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('MAIN WAREHOUSE STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('SUGGESTED REORDER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                    DataColumn(label: Text('REPLENISH ACTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                  ],
                  rows: shortages.map((p) {
                    return DataRow(
                      cells: [
                        // Checkbox + Product Details
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: p.isSelectedForIndent,
                                activeColor: const Color(0xFF059669),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  setState(() => p.isSelectedForIndent = val ?? false);
                                },
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SKU: ${p.sku}  •  Category: ${p.category}',
                                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Current Showroom Stock
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${p.stock} PCS',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'OUT OF STOCK',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Threshold
                        DataCell(
                          Text(
                            '${p.threshold} PCS',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                        ),

                        // Main Warehouse Stock
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${p.mainWarehouseStock} PCS',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Shortage at Main',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Suggested Reorder
                        DataCell(
                          Text(
                            '+${p.suggestedReorder} PCS',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
                          ),
                        ),

                        // Replenish Action: Indent Now
                        DataCell(
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  p.stock += p.suggestedReorder;
                                  _recalculateShowroomStats();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Indent requisition created for "${p.name}". Stock increased by +${p.suggestedReorder} PCS.'),
                                    backgroundColor: const Color(0xFF0E4D34),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFDDD6FE)),
                                ),
                                child: const Text(
                                  'Indent Now',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplenishKpiCard({
    required String title,
    required String value,
    required Color valueColor,
    required String subtext,
    required Color subtextColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
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
                  title,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Icon(icon, size: 14, color: iconColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: subtextColor),
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: TRANSFERS & RETURNS LOG (Image 5) ─────────────────

  Widget _buildTransfersReturnsLogTab(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title + Return & Transfer Buttons (Image 5)
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final titleCol = const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Showroom Stock Movements & Return Logistics',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Audit trail of forward branch transfers and damaged/dead stock returned to Main Warehouse.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                );

                final actionBtns = Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    // Return Damaged / Dead Stock button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openReturnGoodsDialog,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.rotateCcw, size: 13, color: Color(0xFFDC2626)),
                              SizedBox(width: 6),
                              Text(
                                'Return Damaged / Dead Stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // + New Transfer button (Solid green)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openTransferStockDialog,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E4D34),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.plus, size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                '+ New Transfer',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                if (constraints.maxWidth < 850) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleCol,
                      const SizedBox(height: 14),
                      actionBtns,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleCol),
                    const SizedBox(width: 14),
                    actionBtns,
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Table Headers row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 18,
              columnSpacing: 32,
              columns: const [
                DataColumn(label: Text('TRANSFER # & TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('SOURCE BRANCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('DESTINATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('ITEMS MOVED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
              ],
              rows: _transfers.map((t) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: t.isReturn ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t.isReturn ? 'Return' : 'Transfer',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: t.isReturn ? const Color(0xFFDC2626) : const Color(0xFF0E4D34),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(t.fromBranch, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                    DataCell(Text(t.toBranch, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                    DataCell(Text('${t.quantity}x ${t.product}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
                    DataCell(Text(t.date, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.status,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          // Empty state matching Image 5 exactly
          if (_transfers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              alignment: Alignment.center,
              child: const Text(
                'No inter-branch transfers recorded yet. Click "New Transfer" to move stock between showrooms.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── TAB 4: SHOWROOM PROMOS & DISCOUNTS (Images 1, 2, 3) ──────────────

  Widget _buildPromosDiscountsTab(bool isMobile) {
    // Filter promotions
    final filtered = _promotions.where((p) {
      if (_selectedPromoStatusFilter != 'All' && p.status != _selectedPromoStatusFilter) {
        return false;
      }
      if (_selectedPromoShowroomFilter != 'All Showrooms' && p.showroomId != _selectedPromoShowroomFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matches = p.title.toLowerCase().contains(query) ||
            p.showroomName.toLowerCase().contains(query) ||
            p.showroomCode.toLowerCase().contains(query);
        if (!matches) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. BANNER CARD (Showroom-Specific Pricing & Festive Discounts)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 800;

              final infoColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'LOCAL PRICING & PROMOTIONS',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        'Showroom-Specific Pricing & Festive Discounts',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Standard products sell at base price, but specific showrooms can offer custom pricing, festive cuts, or regional tier discounts. Requested discounts require Main Branch / Owner approval and apply strictly in that showroom only.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              );

              final actionBtn = ElevatedButton.icon(
                onPressed: _openRequestPromotionDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text(
                  'Request Local Discount',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoColumn,
                    const SizedBox(height: 14),
                    actionBtn,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: infoColumn),
                  const SizedBox(width: 20),
                  actionBtn,
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 2. DATA TABLE & FILTERS CONTAINER
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Sub-header Filter Bar (Showroom dropdown, Status pills, promotions count)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 850;

                    final leftFilters = Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Showroom Dropdown
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.store, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            const Text(
                              'Showroom:',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPromoShowroomFilter,
                                  isDense: true,
                                  icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF64748B)),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'All Showrooms',
                                      child: Text('All Showrooms'),
                                    ),
                                    ..._showrooms.map(
                                      (s) => DropdownMenuItem(
                                        value: s.id,
                                        child: Text('${s.name} (${s.code})'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedPromoShowroomFilter = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Status Filter Pills
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Status:',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ...['All', 'Pending Approval', 'Approved / Active', 'Rejected'].map((status) {
                              final isSelected = _selectedPromoStatusFilter == status;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedPromoStatusFilter = status),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: isSelected ? Border.all(color: const Color(0xFFCBD5E1)) : null,
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    );

                    final rightCount = Text(
                      '${filtered.length} promotions recorded',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          leftFilters,
                          const SizedBox(height: 10),
                          rightCount,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: leftFilters),
                        const SizedBox(width: 12),
                        rightCount,
                      ],
                    );
                  },
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // Content Area: Empty State or Data Table
              if (filtered.isEmpty)
                _buildPromosEmptyState()
              else
                _buildPromosTable(filtered),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromosEmptyState() {
    return Column(
      children: [
        // Table Header Row matching Screenshot 1 & 3
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(
              children: [
                SizedBox(width: 140, child: Text('SHOWROOM', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5))),
                SizedBox(width: 180, child: Text('PROMOTION DETAILS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5))),
                SizedBox(width: 160, child: Text('DISCOUNT / PRICE OVERRIDE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5))),
                SizedBox(width: 160, child: Text('APPLICABLE SCOPE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5))),
                SizedBox(width: 150, child: Text('VALIDITY & LIMITS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5))),
                SizedBox(width: 130, child: Text('STATUS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5))),
                SizedBox(width: 130, child: Text('OWNER ACTIONS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5))),
              ],
            ),
          ),
        ),

        const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

        // Empty state illustration & button (matching Screenshot 3)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(LucideIcons.tag, size: 22, color: Color(0xFF059669)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Showroom Promotions Found',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Showroom managers can request festive discounts or local showroom\npricing overrides tailored for regional competition.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openRequestPromotionDialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text(
                  'Request First Promotion',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromosTable(List<ShowroomPromotionItem> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        headingTextStyle: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
        dataRowMinHeight: 64,
        dataRowMaxHeight: 64,
        horizontalMargin: 20,
        columnSpacing: 28,
        columns: const [
          DataColumn(label: Text('SHOWROOM')),
          DataColumn(label: Text('PROMOTION DETAILS')),
          DataColumn(label: Text('DISCOUNT / PRICE OVERRIDE')),
          DataColumn(label: Text('APPLICABLE SCOPE')),
          DataColumn(label: Text('VALIDITY & LIMITS')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('OWNER ACTIONS')),
        ],
        rows: items.map((p) {
          Color statusBg;
          Color statusText;
          if (p.status == 'Approved / Active') {
            statusBg = const Color(0xFFDCFCE7);
            statusText = const Color(0xFF15803D);
          } else if (p.status == 'Rejected') {
            statusBg = const Color(0xFFFEE2E2);
            statusText = const Color(0xFFDC2626);
          } else {
            statusBg = const Color(0xFFFEF3C7);
            statusText = const Color(0xFFD97706);
          }

          String discountText;
          if (p.discountType.contains('Percentage')) {
            discountText = '${p.discountValue.toStringAsFixed(p.discountValue.truncateToDouble() == p.discountValue ? 0 : 1)}% OFF';
          } else if (p.discountType.contains('Flat')) {
            discountText = '₹${p.discountValue.toStringAsFixed(0)} OFF';
          } else {
            discountText = 'Fixed: ₹${p.discountValue.toStringAsFixed(0)}';
          }

          return DataRow(
            cells: [
              // Showroom
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p.showroomName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.showroomCode,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),

              // Promotion Details
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.justification,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Discount / Price Override
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    discountText,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                  ),
                ),
              ),

              // Applicable Scope
              DataCell(
                Text(
                  p.scope,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                ),
              ),

              // Validity & Limits
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${p.startDate} - ${p.endDate}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.minBillAmount > 0 ? 'Min Bill: ₹${p.minBillAmount.toStringAsFixed(0)}' : 'No Min Bill',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),

              // Status
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusText),
                  ),
                ),
              ),

              // Owner Actions
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (p.status == 'Pending Approval') ...[
                      InkWell(
                        onTap: () {
                          setState(() => p.status = 'Approved / Active');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Promotion '${p.title}' approved for ${p.showroomName}!"),
                              backgroundColor: const Color(0xFF0E4D34),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          setState(() => p.status = 'Rejected');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Promotion '${p.title}' rejected."),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: const Text('Reject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                        ),
                      ),
                    ] else ...[
                      InkWell(
                        onTap: () {
                          setState(() => p.status = p.status == 'Approved / Active' ? 'Rejected' : 'Approved / Active');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            p.status == 'Approved / Active' ? 'Deactivate' : 'Reactivate',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        setState(() => _promotions.remove(p));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Promotion deleted.'),
                            backgroundColor: Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─── TAB 5: CROSS-BRANCH LOYALTY ─────────────────────────────

  Widget _buildCrossBranchLoyaltyTab(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.users, size: 18, color: Color(0xFF0E4D34)),
              SizedBox(width: 8),
              Text(
                'Cross-Branch Customer Loyalty & Shared Credit Ledger',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Centralized customer balances allow walk-in patrons to redeem credit notes and reward points across all showrooms.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.checkCircle2, size: 20, color: Color(0xFF065F46)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Multi-Branch Sync Active: 1,420 registered customers can redeem store credit across all company outlets seamlessly.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MODAL: ADJUST STOCK FOR SHOWROOM (Image 2)
// ═══════════════════════════════════════════════════════════════

class _AdjustStockForShowroomDialog extends StatefulWidget {
  final BranchStockProduct product;
  final String showroomName;
  final Function(int) onSave;

  const _AdjustStockForShowroomDialog({
    required this.product,
    required this.showroomName,
    required this.onSave,
  });

  @override
  State<_AdjustStockForShowroomDialog> createState() =>
      _AdjustStockForShowroomDialogState();
}

class _AdjustStockForShowroomDialogState
    extends State<_AdjustStockForShowroomDialog> {
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title + Close X Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Adjust Stock for Showroom',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Subtitle matching Image 2
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Updating stock for '),
                    TextSpan(
                      text: widget.product.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const TextSpan(text: ' at '),
                    TextSpan(
                      text: widget.showroomName,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 18),

              // Form Field Label & Input
              _buildFieldLabel('Quantity Available'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                decoration: _buildInputDecoration(hint: 'Enter quantity...'),
              ),

              const SizedBox(height: 22),

              // Action Buttons: Cancel and Save Stock
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          final qty = int.tryParse(_qtyCtrl.text.trim()) ?? widget.product.stock;
                          widget.onSave(qty);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Save Stock', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MODAL: TRANSFER GOODS ACROSS SHOWROOMS (Image 3)
// ═══════════════════════════════════════════════════════════════

class _TransferGoodsAcrossShowroomsDialog extends StatefulWidget {
  final List<ShowroomBranchItem> showrooms;
  final List<BranchStockProduct> products;
  final Function(BranchTransferItem) onConfirmTransfer;

  const _TransferGoodsAcrossShowroomsDialog({
    required this.showrooms,
    required this.products,
    required this.onConfirmTransfer,
  });

  @override
  State<_TransferGoodsAcrossShowroomsDialog> createState() =>
      _TransferGoodsAcrossShowroomsDialogState();
}

class _TransferGoodsAcrossShowroomsDialogState
    extends State<_TransferGoodsAcrossShowroomsDialog> {
  String _sourceShowroom = 'Main Showroom';
  String? _destinationShowroom;
  String? _selectedProduct;
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _notesController = TextEditingController();

  final List<String> _destOptions = [
    'Tambaram Showroom',
    'Tiruvallur Showroom',
    'Chennai Central Hub',
    'Coimbatore Branch',
  ];

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Icon + Title + Close Button
              Row(
                children: [
                  const Icon(LucideIcons.arrowRightLeft, size: 20, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Transfer Goods Across Showrooms',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Row 1: Source & Destination
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 420;
                  final fromCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Source Showroom (From)'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _sourceShowroom,
                        isExpanded: true,
                        decoration: _buildInputDecoration(),
                        items: ['Main Showroom', 'Tambaram Showroom', 'Tiruvallur Showroom']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _sourceShowroom = val);
                        },
                      ),
                    ],
                  );

                  final toCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Destination (To)'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _destinationShowroom,
                        isExpanded: true,
                        hint: const Text('Select Destination', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                        decoration: _buildInputDecoration(),
                        items: _destOptions
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _destinationShowroom = val);
                        },
                      ),
                    ],
                  );

                  if (isTight) {
                    return Column(children: [fromCol, const SizedBox(height: 14), toCol]);
                  }
                  return Row(
                    children: [
                      Expanded(child: fromCol),
                      const SizedBox(width: 14),
                      Expanded(child: toCol),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Field 2: Select Product
              _buildFieldLabel('Select Product'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedProduct,
                isExpanded: true,
                hint: const Text('Choose item to transfer...', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                decoration: _buildInputDecoration(),
                items: widget.products
                    .map((p) => DropdownMenuItem(
                          value: p.name,
                          child: Text('${p.name} (Stock: ${p.stock})', style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedProduct = val);
                },
              ),

              const SizedBox(height: 16),

              // Field 3: Transfer Quantity
              _buildFieldLabel('Transfer Quantity'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _buildInputDecoration(hint: '1'),
              ),

              const SizedBox(height: 16),

              // Field 4: Transfer Notes / Reason
              _buildFieldLabel('Transfer Notes / Reason'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _buildInputDecoration(hint: 'e.g. Stock balancing for weekend sale'),
              ),

              const SizedBox(height: 24),

              // Submit Button: Confirm & Dispatch Transfer
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(_qtyController.text.trim()) ?? 1;
                    final item = BranchTransferItem(
                      id: 'TRF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      date: DateTime.now().toString().split(' ')[0],
                      fromBranch: _sourceShowroom,
                      toBranch: _destinationShowroom ?? 'Tambaram Showroom',
                      product: _selectedProduct ?? 'a new digit product',
                      quantity: qty,
                      reason: _notesController.text.trim().isEmpty
                          ? 'Stock balancing for retail sale'
                          : _notesController.text.trim(),
                    );
                    widget.onConfirmTransfer(item);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm & Dispatch Transfer',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
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

// ═══════════════════════════════════════════════════════════════
// MODAL: RETURN GOODS TO MAIN WAREHOUSE (Image 4 & 5)
// ═══════════════════════════════════════════════════════════════

class _ReturnGoodsToMainWarehouseDialog extends StatefulWidget {
  final List<ShowroomBranchItem> showrooms;
  final List<BranchStockProduct> products;
  final Function(BranchTransferItem) onConfirmReturn;

  const _ReturnGoodsToMainWarehouseDialog({
    required this.showrooms,
    required this.products,
    required this.onConfirmReturn,
  });

  @override
  State<_ReturnGoodsToMainWarehouseDialog> createState() =>
      _ReturnGoodsToMainWarehouseDialogState();
}

class _ReturnGoodsToMainWarehouseDialogState
    extends State<_ReturnGoodsToMainWarehouseDialog> {
  String _originShowroom = 'Main Showroom (MAIN-01)';
  String _returnReason = '⚠️ Damaged Goods / Packaging Defect';
  String? _selectedProduct;
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _notesController = TextEditingController();

  final List<String> _reasonOptions = [
    '⚠️ Damaged Goods / Packaging Defect',
    '📦 Slow Moving / Dead Stock',
    '🔄 Consolidation to Central Hub',
    '📅 Seasonal Recall / Expiry Buffer',
  ];

  @override
  void dispose() {
    _qtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Red icon box + Title/Subtitle + Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.rotateCcw,
                        size: 18,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Return Goods to Main Warehouse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Reverse inventory transfer for damaged, dead, or consolidated showroom stock.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Row 1: Origin Showroom & Destination
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 420;
                  final originCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Origin Showroom (Returning From) *'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _originShowroom,
                        isExpanded: true,
                        decoration: _buildInputDecoration(),
                        items: ['Main Showroom (MAIN-01)', 'Tambaram Showroom (SHW-TMB)']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _originShowroom = val);
                        },
                      ),
                    ],
                  );

                  final destCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Destination (Central Hub)'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Main Showroom',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  );

                  if (isTight) {
                    return Column(children: [originCol, const SizedBox(height: 14), destCol]);
                  }
                  return Row(
                    children: [
                      Expanded(child: originCol),
                      const SizedBox(width: 14),
                      Expanded(child: destCol),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Field 2: Return Classification / Reason *
              _buildFieldLabel('Return Classification / Reason *'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _returnReason,
                isExpanded: true,
                decoration: _buildInputDecoration(),
                items: _reasonOptions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _returnReason = val);
                },
              ),

              const SizedBox(height: 16),

              // Field 3: Product to Return *
              _buildFieldLabel('Product to Return *'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedProduct,
                isExpanded: true,
                hint: const Text('Select item from branch...', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                decoration: _buildInputDecoration(),
                items: widget.products
                    .map((p) => DropdownMenuItem(
                          value: p.name,
                          child: Text('${p.name} (Qty: ${p.stock})', style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedProduct = val);
                },
              ),

              const SizedBox(height: 16),

              // Field 4: Return Quantity *
              _buildFieldLabel('Return Quantity *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _buildInputDecoration(hint: '1'),
              ),

              const SizedBox(height: 16),

              // Field 5: Inspection Notes / Reason Details
              _buildFieldLabel('Inspection Notes / Reason Details'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _buildInputDecoration(hint: 'e.g. Scratched screen during transit, unbox defect'),
              ),

              const SizedBox(height: 24),

              // Submit Button: Confirm & Dispatch Return to Main Showroom (Solid Crimson)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(_qtyController.text.trim()) ?? 1;
                    final item = BranchTransferItem(
                      id: 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      date: DateTime.now().toString().split(' ')[0],
                      fromBranch: _originShowroom,
                      toBranch: 'Main Central Hub',
                      product: _selectedProduct ?? 'apple',
                      quantity: qty,
                      reason: _notesController.text.trim().isEmpty ? _returnReason : _notesController.text.trim(),
                      isReturn: true,
                      status: 'Returned to Hub',
                    );
                    widget.onConfirmReturn(item);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm & Dispatch Return to Main Showroom',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
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

// ═══════════════════════════════════════════════════════════════
// MODAL: REGISTER NEW SHOWROOM
// ═══════════════════════════════════════════════════════════════

class _RegisterNewShowroomDialog extends StatefulWidget {
  final Function(ShowroomBranchItem) onRegister;

  const _RegisterNewShowroomDialog({
    required this.onRegister,
  });

  @override
  State<_RegisterNewShowroomDialog> createState() =>
      _RegisterNewShowroomDialogState();
}

class _RegisterNewShowroomDialogState
    extends State<_RegisterNewShowroomDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  bool _isPrimaryHQ = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _prefixController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Green storefront icon + Title + Close Button
              Row(
                children: [
                  const Icon(LucideIcons.store, size: 20, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Register New Showroom',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Field 1: Showroom Name *
              _buildFieldLabel('Showroom Name *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _buildInputDecoration(hint: 'e.g. Tambaram Showroom'),
              ),

              const SizedBox(height: 16),

              // Row 2: Branch Code * & Invoice Prefix
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 420;
                  final codeCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Branch Code *'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _codeController,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: _buildInputDecoration(hint: 'e.g. SHW-TMB'),
                      ),
                    ],
                  );

                  final prefixCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Invoice Prefix'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _prefixController,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: _buildInputDecoration(hint: 'e.g. TMB-'),
                      ),
                    ],
                  );

                  if (isTight) {
                    return Column(children: [codeCol, const SizedBox(height: 14), prefixCol]);
                  }
                  return Row(
                    children: [
                      Expanded(child: codeCol),
                      const SizedBox(width: 14),
                      Expanded(child: prefixCol),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Field 3: Address
              _buildFieldLabel('Address'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _buildInputDecoration(hint: 'Street / Commercial Complex'),
              ),

              const SizedBox(height: 16),

              // Row 4: City & Phone Number
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 420;
                  final cityCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('City'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _cityController,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: _buildInputDecoration(hint: 'e.g. Chennai'),
                      ),
                    ],
                  );

                  final phoneCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Phone Number'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: _buildInputDecoration(hint: '+91 98765 43210'),
                      ),
                    ],
                  );

                  if (isTight) {
                    return Column(children: [cityCol, const SizedBox(height: 14), phoneCol]);
                  }
                  return Row(
                    children: [
                      Expanded(child: cityCol),
                      const SizedBox(width: 14),
                      Expanded(child: phoneCol),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Field 5: Branch GSTIN (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: _buildFieldLabel('Branch GSTIN (Optional)')),
                  const SizedBox(width: 8),
                  const Text('15-digit alphanumeric', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _gstinController,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _buildInputDecoration(hint: 'e.g. 33AAAAA0000A1Z5'),
              ),

              const SizedBox(height: 16),

              // Checkbox: Set as Primary / Main Showroom (HQ)
              Row(
                children: [
                  Checkbox(
                    value: _isPrimaryHQ,
                    activeColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _isPrimaryHQ = val ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Set as Primary / Main Showroom (HQ)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Button: Register Showroom
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim().isEmpty
                        ? 'Tambaram Showroom'
                        : _nameController.text.trim();
                    final code = _codeController.text.trim().isEmpty
                        ? 'SHW-TMB'
                        : _codeController.text.trim();
                    final prefix = _prefixController.text.trim().isEmpty
                        ? 'TMB-'
                        : _prefixController.text.trim();
                    final address = _addressController.text.trim().isEmpty
                        ? 'GST Road, Tambaram Sanatorium'
                        : _addressController.text.trim();
                    final city = _cityController.text.trim().isEmpty
                        ? 'Chennai'
                        : _cityController.text.trim();
                    final phone = _phoneController.text.trim().isEmpty
                        ? '+91 98765 43210'
                        : _phoneController.text.trim();

                    final newShowroom = ShowroomBranchItem(
                      id: 'SHW-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      name: name,
                      code: code,
                      invoicePrefix: prefix,
                      address: '$address, $city',
                      city: city,
                      phone: phone,
                      gstin: _gstinController.text.trim(),
                      isHQ: _isPrimaryHQ,
                      stockItemsCount: 0,
                      totalUnits: 0.0,
                    );

                    widget.onRegister(newShowroom);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Register Showroom',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
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

// ═══════════════════════════════════════════════════════════════
// MODAL: SHOWROOM MANAGERS DIALOG
// ═══════════════════════════════════════════════════════════════

class _ShowroomManagersDialog extends StatefulWidget {
  final ShowroomBranchItem showroom;
  final VoidCallback onUpdate;

  const _ShowroomManagersDialog({
    required this.showroom,
    required this.onUpdate,
  });

  @override
  State<_ShowroomManagersDialog> createState() => _ShowroomManagersDialogState();
}

class _ShowroomManagersDialogState extends State<_ShowroomManagersDialog> {
  final TextEditingController _managerNameCtrl = TextEditingController();

  @override
  void dispose() {
    _managerNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.users, size: 20, color: Color(0xFF0E4D34)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Managers for ${widget.showroom.name}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Assigned Branch Managers:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
              const SizedBox(height: 8),
              ...widget.showroom.managers.map((mgr) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.circleUser, size: 16, color: Color(0xFF0E4D34)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(mgr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      ),
                      if (widget.showroom.managers.length > 1)
                        InkWell(
                          onTap: () {
                            setState(() {
                              widget.showroom.managers.remove(mgr);
                            });
                            widget.onUpdate();
                          },
                          child: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFDC2626)),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _managerNameCtrl,
                      decoration: _buildInputDecoration(hint: 'Add new manager name...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final name = _managerNameCtrl.text.trim();
                      if (name.isNotEmpty) {
                        setState(() {
                          widget.showroom.managers.add('$name (Store Admin)');
                          _managerNameCtrl.clear();
                        });
                        widget.onUpdate();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E4D34),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── MODAL: REQUEST SHOWROOM PROMOTION (Image 2) ───────────────

class _RequestShowroomPromotionDialog extends StatefulWidget {
  final List<ShowroomBranchItem> showrooms;
  final Function(ShowroomPromotionItem) onCreated;

  const _RequestShowroomPromotionDialog({
    required this.showrooms,
    required this.onCreated,
  });

  @override
  State<_RequestShowroomPromotionDialog> createState() => _RequestShowroomPromotionDialogState();
}

class _RequestShowroomPromotionDialogState extends State<_RequestShowroomPromotionDialog> {
  late String _selectedShowroomId;
  final TextEditingController _campaignTitleCtrl = TextEditingController();
  String _discountType = 'Percentage (% Off)';
  final TextEditingController _discountValueCtrl = TextEditingController(text: '15');
  String _applicableScope = 'Entire Showroom Catalog';
  final TextEditingController _minBillCtrl = TextEditingController(text: '0');
  final TextEditingController _startDateCtrl = TextEditingController(text: '17/11/2026');
  final TextEditingController _endDateCtrl = TextEditingController(text: '01/12/2026');
  final TextEditingController _justificationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedShowroomId = widget.showrooms.isNotEmpty ? widget.showrooms.first.id : '';
  }

  @override
  void dispose() {
    _campaignTitleCtrl.dispose();
    _discountValueCtrl.dispose();
    _minBillCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _justificationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF059669),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      setState(() {
        ctrl.text = '$day/$month/$year';
      });
    }
  }

  void _submit() {
    final title = _campaignTitleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a promotion campaign title')),
      );
      return;
    }

    final targetShowroom = widget.showrooms.firstWhere(
      (s) => s.id == _selectedShowroomId,
      orElse: () => widget.showrooms.first,
    );

    final discountVal = double.tryParse(_discountValueCtrl.text.trim()) ?? 15.0;
    final minBill = double.tryParse(_minBillCtrl.text.trim()) ?? 0.0;

    final newPromo = ShowroomPromotionItem(
      id: 'PRM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      showroomId: targetShowroom.id,
      showroomName: targetShowroom.name,
      showroomCode: targetShowroom.code,
      title: title,
      discountType: _discountType,
      discountValue: discountVal,
      scope: _applicableScope,
      minBillAmount: minBill,
      startDate: _startDateCtrl.text.trim(),
      endDate: _endDateCtrl.text.trim(),
      justification: _justificationCtrl.text.trim().isNotEmpty
          ? _justificationCtrl.text.trim()
          : 'Local festive and regional tier discount promotion.',
      status: 'Pending Approval',
      createdAt: '17/11/2026',
    );

    widget.onCreated(newPromo);
    Navigator.pop(context);
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Icon + Title + Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.tag, size: 18, color: Color(0xFF059669)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Showroom Promotion',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Local showroom discounts require Main Branch approval',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Field 1: Target Showroom *
              _buildFieldLabel('Target Showroom *'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedShowroomId,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    items: widget.showrooms.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.name} (${s.code})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedShowroomId = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Field 2: Promotion Campaign Title *
              _buildFieldLabel('Promotion Campaign Title *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _campaignTitleCtrl,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _inputDeco('e.g. Diwali Festive Rush 10%, Metro Tier-1 Markdown'),
              ),

              const SizedBox(height: 16),

              // Field 3 & 4: Discount Type * & Discount Percentage (%) *
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 440;
                  final typeField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Discount Type *'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _discountType,
                            isExpanded: true,
                            icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                            items: const [
                              DropdownMenuItem(value: 'Percentage (% Off)', child: Text('Percentage (% Off)')),
                              DropdownMenuItem(value: 'Flat Amount (₹ Off)', child: Text('Flat Amount (₹ Off)')),
                              DropdownMenuItem(value: 'Fixed Special Price', child: Text('Fixed Special Price')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _discountType = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  );

                  final valueField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(
                        _discountType.contains('Percentage')
                            ? 'Discount Percentage (%) *'
                            : 'Discount Amount (₹) *',
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _discountValueCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: _inputDeco('e.g. 15'),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        typeField,
                        const SizedBox(height: 16),
                        valueField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: typeField),
                      const SizedBox(width: 14),
                      Expanded(child: valueField),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Field 5 & 6: Applicable Scope * & Minimum Bill Amount
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 440;
                  final scopeField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Applicable Scope *'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _applicableScope,
                            isExpanded: true,
                            icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                            items: const [
                              DropdownMenuItem(value: 'Entire Showroom Catalog', child: Text('Entire Showroom Catalog')),
                              DropdownMenuItem(value: 'Specific Category', child: Text('Specific Category')),
                              DropdownMenuItem(value: 'Selected Products', child: Text('Selected Products')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _applicableScope = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  );

                  final minBillField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Minimum Bill Amount'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _minBillCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: _inputDeco('0'),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        scopeField,
                        const SizedBox(height: 16),
                        minBillField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: scopeField),
                      const SizedBox(width: 14),
                      Expanded(child: minBillField),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Field 7 & 8: Start Date * & End Date *
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 440;

                  Widget buildDateField(String label, TextEditingController ctrl) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(label),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _pickDate(ctrl),
                          borderRadius: BorderRadius.circular(10),
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: ctrl,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                              decoration: _inputDeco('').copyWith(
                                suffixIcon: const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (isNarrow) {
                    return Column(
                      children: [
                        buildDateField('Start Date *', _startDateCtrl),
                        const SizedBox(height: 16),
                        buildDateField('End Date *', _endDateCtrl),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: buildDateField('Start Date *', _startDateCtrl)),
                      const SizedBox(width: 14),
                      Expanded(child: buildDateField('End Date *', _endDateCtrl)),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Field 9: Business Justification & Local Market Reason *
              _buildFieldLabel('Business Justification & Local Market Reason *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _justificationCtrl,
                minLines: 3,
                maxLines: 4,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _inputDeco('Explain why this showroom requires this discount (e.g. Higher rent tier metro clearance, nearby competitor discount match, regional festival rush)'),
              ),

              const SizedBox(height: 16),

              // Information Notice Banner (matching Screenshot 2)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFEF3C7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        const TextSpan(
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), height: 1.4),
                          children: [
                            TextSpan(
                              text: 'Strict Showroom Isolation: ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: 'Once approved by the Main Branch, this discount will automatically be active and strictly applied only at the selected showroom\'s POS counter.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Submit Promotion Request',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HELPER WIDGETS & DECORATIONS ─────────────────────────────

Widget _buildFieldLabel(String label) {
  return Text(
    label,
    style: const TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: Color(0xFF334155),
    ),
  );
}

InputDecoration _buildInputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
    ),
  );
}
