import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/quick_register_item_dialog.dart';
import '../../../widgets/app_ui_kit.dart';

class _TabItem {
  final String label;
  final IconData icon;
  _TabItem(this.label, this.icon);
}

// ═══════════════════════════════════════════════════════════════
// DUMMY POS MODELS
// ═══════════════════════════════════════════════════════════════
class _PosProduct {
  final String sku;
  final String name;
  final String category;
  final double price;
  final int stock;

  _PosProduct({
    required this.sku,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });
}

class _PosCartItem {
  final _PosProduct product;
  int quantity;

  _PosCartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class _PosSale {
  final String billNo;
  final String customer;
  final int itemCount;
  final double totalAmount;
  final String paymentMode;
  final String time;

  _PosSale({
    required this.billNo,
    required this.customer,
    required this.itemCount,
    required this.totalAmount,
    required this.paymentMode,
    required this.time,
  });
}

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Billing Terminal, 1: Product Catalog, 2: Sales History, 3: Cash Drawer
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<_TabItem> _tabs = [
    _TabItem('Billing Terminal', LucideIcons.monitor),
    _TabItem('Product Catalog', LucideIcons.shoppingBag),
    _TabItem('Sales History Register', LucideIcons.history),
    _TabItem('Daily Cash Drawer', LucideIcons.wallet),
  ];

  // Dummy Catalog
  final List<_PosProduct> _catalog = [
    _PosProduct(sku: 'SKU-HD100', name: 'Wireless Bluetooth Headphones', category: 'Electronics', price: 2499.00, stock: 45),
    _PosProduct(sku: 'SKU-CH201', name: 'Ergonomic Office Chair', category: 'Furniture', price: 8999.00, stock: 12),
    _PosProduct(sku: 'SKU-KB305', name: 'Mechanical RGB Keyboard', category: 'Electronics', price: 3499.00, stock: 28),
    _PosProduct(sku: 'SKU-MN404', name: '4K Ultra HD Monitor 27"', category: 'Electronics', price: 24999.00, stock: 8),
    _PosProduct(sku: 'SKU-CB502', name: 'USB-C Fast Charging Cable', category: 'Accessories', price: 499.00, stock: 120),
  ];

  // Active Cart Items
  late List<_PosCartItem> _cart;

  // Dummy Sales History
  final List<_PosSale> _salesHistory = [
    _PosSale(billNo: 'POS-BILL-9901', customer: 'Walk-in Client', itemCount: 3, totalAmount: 6497.00, paymentMode: 'UPI', time: '11:42 AM'),
    _PosSale(billNo: 'POS-BILL-9902', customer: 'Rahul Sharma', itemCount: 1, totalAmount: 24999.00, paymentMode: 'CARD', time: '11:15 AM'),
    _PosSale(billNo: 'POS-BILL-9903', customer: 'Ananya Verma', itemCount: 4, totalAmount: 1996.00, paymentMode: 'CASH', time: '10:30 AM'),
    _PosSale(billNo: 'POS-BILL-9904', customer: 'Priya Nair', itemCount: 2, totalAmount: 11498.00, paymentMode: 'UPI', time: '09:50 AM'),
  ];

  List<_PosProduct> get _filteredCatalog {
    if (_searchQuery.isEmpty) return _catalog;
    final q = _searchQuery.toLowerCase();
    return _catalog.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q) || p.category.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    // Pre-populate 2 items in cart for demonstration
    _cart = [
      _PosCartItem(product: _catalog[0], quantity: 1),
      _PosCartItem(product: _catalog[4], quantity: 2),
    ];
  }

  void _addToCart(_PosProduct product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.sku == product.sku);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(_PosCartItem(product: product));
      }
    });
  }

  double get _cartSubtotal => _cart.fold(0, (sum, item) => sum + item.total);
  double get _cartGst => _cartSubtotal * 0.18;
  double get _cartTotal => _cartSubtotal + _cartGst;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                onAddProduct: () {
                  showDialog(
                    context: context,
                    builder: (context) => const QuickRegisterItemDialog(),
                  );
                },
                onViewHistory: () {
                  setState(() => _activeTab = 2);
                },
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
                      ? _buildMainContent(isMobile, screenWidth)
                      : _buildMainContent(isMobile, screenWidth)
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
            onPressed: () => setState(() => _activeTab = 2),
            icon: const Icon(LucideIcons.history, size: 14),
            label: const Text('View Sales History', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD63384),
              side: const BorderSide(color: Color(0xFFF8D7DA)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const QuickRegisterItemDialog(),
              );
            },
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Add Quick Product', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
  // HERO SUMMARY CARD (Accounting Style Header)
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
                      child: const Icon(LucideIcons.monitor, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'RETAIL POS & SPEED CHECKOUT',
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
            'TODAY\'S TOTAL POS COLLECTIONS',
            style: TextStyle(
              fontSize: isMobile ? 9.5 : 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹1,84,520.00',
            style: TextStyle(
              fontSize: isMobile ? 26 : 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 16),

          // 3 Stat Chips in a row inside hero card
          Row(
            children: [
              _buildHeroChip('Today\'s Orders', '42 Orders', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Avg Bill Value', '₹4,393.00', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Active Terminal', 'Terminal #01', isMobile),
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
  Widget _buildMainContent(bool isMobile, double screenWidth) {
    String sectionTitle = "";

    switch (_activeTab) {
      case 0:
        sectionTitle = "Point of Sale Speed Billing Terminal";
        break;
      case 1:
        sectionTitle = "Store Inventory Product Catalog";
        break;
      case 2:
        sectionTitle = "Completed POS Billing Sales Register";
        break;
      case 3:
        sectionTitle = "Daily Cash Till & Register Reconciliation";
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
          _buildActiveTabContent(isMobile),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(bool isMobile) {
    switch (_activeTab) {
      case 0:
        return _buildTerminalView(isMobile);
      case 1:
        return _buildCatalogTab(isMobile);
      case 2:
        return _buildSalesHistoryTab(isMobile);
      case 3:
        return _buildCashDrawerTab(isMobile);
      default:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 0: BILLING TERMINAL VIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTerminalView(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildCatalogGrid(isMobile),
          const SizedBox(height: 24),
          _buildCartPanel(isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildCatalogGrid(isMobile),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: _buildCartPanel(isMobile),
        ),
      ],
    );
  }

  Widget _buildCatalogGrid(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(LucideIcons.search, size: 16, color: AppColors.secondaryText),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Search products by name, SKU or barcode...',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Product Cards Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: _filteredCatalog.length,
          itemBuilder: (context, index) {
            final p = _filteredCatalog[index];
            return InkWell(
              onTap: () => _addToCart(p),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                          child: Text(p.category, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                        ),
                        Text('Stock: ${p.stock}', style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                      ],
                    ),
                    Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFF166534), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.plus, size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCartPanel(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.shoppingCart, size: 16, color: Color(0xFF166534)),
                  SizedBox(width: 8),
                  Text('Current Checkout Cart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                ],
              ),
              if (_cart.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _cart.clear()),
                  child: const Text('Clear Cart', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          if (_cart.isEmpty)
            Container(
              height: 140,
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shoppingBag, size: 36, color: AppColors.secondaryText),
                  SizedBox(height: 8),
                  Text('Cart is empty. Tap products to add.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ],
              ),
            )
          else
            Column(
              children: _cart.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('₹${item.product.price} × ${item.quantity}', style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.minusCircle, size: 16, color: AppColors.secondaryText),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  item.quantity--;
                                } else {
                                  _cart.remove(item);
                                }
                              });
                            },
                          ),
                          Text('${item.quantity}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(LucideIcons.plusCircle, size: 16, color: Color(0xFF166534)),
                            onPressed: () => setState(() => item.quantity++),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text('₹${item.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // Total Calculation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              Text('₹${_cartSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GST Tax (18%)', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              Text('₹${_cartGst.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payable Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              Text('₹${_cartTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Checkout Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppSnackbar.show(context, "Cash payment of ₹${_cartTotal.toStringAsFixed(2)} received! Receipt printed.", type: SnackType.success);
                    setState(() => _cart.clear());
                  },
                  icon: const Icon(LucideIcons.banknote, size: 13),
                  label: const Text('Cash (F1)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppSnackbar.show(context, "UPI QR Code generated for ₹${_cartTotal.toStringAsFixed(2)}.", type: SnackType.info);
                  },
                  icon: const Icon(LucideIcons.qrCode, size: 13),
                  label: const Text('UPI (F2)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppSnackbar.show(context, "Card Terminal initiated for ₹${_cartTotal.toStringAsFixed(2)}.", type: SnackType.info);
                  },
                  icon: const Icon(LucideIcons.creditCard, size: 13),
                  label: const Text('Card (F3)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2410C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
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
  // OTHER TABS (Catalog, History, Cash Drawer)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCatalogTab(bool isMobile) {
    if (isMobile) {
      return Column(
        children: _catalog.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('${p.sku} • ${p.category}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ],
              ),
              Text('₹${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
            ],
          ),
        )).toList(),
      );
    }

    final headers = ['SKU CODE', 'PRODUCT NAME', 'CATEGORY', 'SELLING PRICE', 'STOCK LEVEL'];
    return Table(
      children: [
        _buildTableHeaderRow(headers),
        ..._catalog.map((p) => TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
          children: [
            Padding(padding: const EdgeInsets.all(12), child: Text(p.sku, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            Padding(padding: const EdgeInsets.all(12), child: Text(p.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            Padding(padding: const EdgeInsets.all(12), child: Text(p.category, style: const TextStyle(fontSize: 11))),
            Padding(padding: const EdgeInsets.all(12), child: Text('₹${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
            Padding(padding: const EdgeInsets.all(12), child: Text('${p.stock} Pcs', style: const TextStyle(fontSize: 11))),
          ],
        )),
      ],
    );
  }

  Widget _buildSalesHistoryTab(bool isMobile) {
    if (isMobile) {
      return Column(
        children: _salesHistory.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.billNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('${s.customer} • ${s.time}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ],
              ),
              Text('₹${s.totalAmount.toStringAsFixed(2)} (${s.paymentMode})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
            ],
          ),
        )).toList(),
      );
    }

    final headers = ['BILL NO', 'CUSTOMER NAME', 'ITEM COUNT', 'PAYMENT MODE', 'TOTAL AMOUNT', 'TIME'];
    return Table(
      children: [
        _buildTableHeaderRow(headers),
        ..._salesHistory.map((s) => TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
          children: [
            Padding(padding: const EdgeInsets.all(12), child: Text(s.billNo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            Padding(padding: const EdgeInsets.all(12), child: Text(s.customer, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            Padding(padding: const EdgeInsets.all(12), child: Text('${s.itemCount} Items', style: const TextStyle(fontSize: 11))),
            Padding(padding: const EdgeInsets.all(12), child: Text(s.paymentMode, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)))),
            Padding(padding: const EdgeInsets.all(12), child: Text('₹${s.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)))),
            Padding(padding: const EdgeInsets.all(12), child: Text(s.time, style: const TextStyle(fontSize: 11))),
          ],
        )),
      ],
    );
  }

  Widget _buildCashDrawerTab(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Opening Cash Balance', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              Text('₹10,000.00', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today Cash Collections', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              Text('₹45,200.00', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
            ],
          ),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expected Till Cash Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('₹55,200.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeaderRow(List<String> headers) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      children: headers.map((h) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          h,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
        ),
      )).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EXPANDABLE DROPUP FAB FOR MOBILE
// ═══════════════════════════════════════════════════════════════
class _ExpandableFab extends StatefulWidget {
  final VoidCallback onAddProduct;
  final VoidCallback onViewHistory;

  const _ExpandableFab({
    required this.onAddProduct,
    required this.onViewHistory,
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
              icon: LucideIcons.plus,
              label: 'Add Quick Product',
              color: const Color(0xFF166534), // Green
              onPressed: () {
                _toggle();
                widget.onAddProduct();
              },
            ),
          ),
          _buildAnimatedChild(
            0,
            _MiniFab(
              icon: LucideIcons.history,
              label: 'View Sales History',
              color: const Color(0xFFD63384), // Pink / Accent
              onPressed: () {
                _toggle();
                widget.onViewHistory();
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
