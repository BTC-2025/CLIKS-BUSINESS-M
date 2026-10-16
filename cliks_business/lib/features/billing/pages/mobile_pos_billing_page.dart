import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../models/mobile_pos_models.dart';
import '../widgets/mobile_pos/mobile_pos_utils.dart';
import '../widgets/mobile_pos/mobile_pos_header.dart';
import '../widgets/mobile_pos/mobile_customer_bar.dart';
import '../widgets/mobile_pos/mobile_product_card.dart';
import '../widgets/mobile_pos/mobile_cart_sheet.dart';
import '../widgets/mobile_pos/mobile_payment_sheet.dart';
import '../widgets/mobile_pos/mobile_history_sheet.dart';
import '../widgets/mobile_pos/mobile_held_carts_sheet.dart';
import '../widgets/mobile_pos/mobile_stock_adjustment_sheet.dart';
import '../widgets/mobile_pos/mobile_edit_product_sheet.dart';
import '../widgets/quick_register_item_dialog.dart';

class MobilePosBillingPage extends ConsumerStatefulWidget {
  const MobilePosBillingPage({super.key});

  @override
  ConsumerState<MobilePosBillingPage> createState() =>
      _MobilePosBillingPageState();
}

class _MobilePosBillingPageState extends ConsumerState<MobilePosBillingPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedWarehouse = 'Main Store (Wh-01)';

  final List<String> _warehouses = [
    'Main Store (Wh-01)',
    'Central Warehouse',
    'Depot North',
    'Downtown Express',
  ];

  final List<String> _categories = [
    'All',
    'Electronics',
    'General',
    'Vehicles',
    'Footwear',
    'Accessories',
  ];

  // Customers
  late List<MobileCustomer> _customers;
  late MobileCustomer _selectedCustomer;

  // Products Catalogue matching reference
  late List<MobilePosProduct> _products;

  // Active Cart Items
  late List<MobileCartItem> _cart;

  // Financial Modifiers
  double _discountPercent = 0.0;
  double _discountFlat = 0.0;
  DiscountMode _discountMode = DiscountMode.percentage;
  double _gstRate = 0.18; // 18% default
  final double _ptsRedeemed = 0.0;
  final double _ptsEarned = 0.0;

  // Held Carts
  final List<MobileHeldCart> _heldCarts = [];

  // Sales History Register
  late List<MobilePosSale> _salesHistory;

  @override
  void initState() {
    super.initState();

    _customers = [
      const MobileCustomer(
        id: 'cust-1',
        name: 'Varshini',
        phone: 'chandran12...',
        email: 'varshini@bnxmail.com',
        gstin: '33AABCU9603R1ZM',
        businessName: 'Varshini Retail',
        loyaltyPoints: 0,
      ),
      const MobileCustomer(
        id: 'cust-2',
        name: 'vincent1182003',
        phone: '9876543210',
        email: 'vincent1182003@bnxmail.com',
        gstin: 'Unregistered',
        businessName: 'vincent1182003',
        loyaltyPoints: 120,
      ),
      const MobileCustomer(
        id: 'cust-3',
        name: 'NIIT400',
        phone: '9456161498',
        email: 'aruntest@bnxmail.com',
        gstin: 'KLEWDNWKEDNKJWE',
        businessName: 'Personal',
        loyaltyPoints: 45,
      ),
      const MobileCustomer(
        id: 'cust-4',
        name: 'sanjay123',
        phone: '9123456789',
        email: 'sanjay123@bnxmail.com',
        gstin: 'Unregistered',
        businessName: 'sanjay123',
        loyaltyPoints: 0,
      ),
      const MobileCustomer(
        id: 'cust-5',
        name: 'Rahul Sharma',
        phone: '9845012345',
        email: 'rahul.sharma@example.com',
        gstin: '07AAAAA0000A1Z5',
        businessName: 'Sharma Electronics',
        loyaltyPoints: 350,
      ),
      const MobileCustomer(
        id: 'cust-6',
        name: 'Ananya Verma',
        phone: '9988776655',
        email: 'ananya.v@example.com',
        gstin: '29ABCDE1234F1Z5',
        businessName: 'Verma Traders',
        loyaltyPoints: 80,
      ),
      const MobileCustomer(
        id: 'cust-7',
        name: 'Priya Nair',
        phone: '9876123456',
        email: 'priya.nair@example.com',
        gstin: '32AABCP1234G1Z1',
        businessName: 'Nair Studio',
        loyaltyPoints: 210,
      ),
    ];

    // Default to Varshini as in desktop reference
    _selectedCustomer = _customers.first;

    // Standard product items from desktop reference
    _products = [
      MobilePosProduct(
        id: '1',
        name: 'a new digit product',
        sku: 'SKU: SKU-3752',
        category: 'General',
        price: 10004399.00,
        stock: 416,
      ),
      MobilePosProduct(
        id: '2',
        name: 'apple',
        sku: 'SKU: app',
        category: 'Electronics',
        price: 500.00,
        stock: 8,
      ),
      MobilePosProduct(
        id: '3',
        name: 'BMW car',
        sku: 'SKU: BMW-788',
        category: 'Vehicles',
        price: 80000.00,
        stock: 35,
      ),
      MobilePosProduct(
        id: '4',
        name: 'car',
        sku: 'SKU: 54',
        category: 'Electronics',
        price: 545.00,
        stock: 29,
      ),
      MobilePosProduct(
        id: '5',
        name: 'carrot',
        sku: 'SKU: SKU-746095',
        category: 'General',
        price: 526.00,
        stock: 1180,
      ),
      MobilePosProduct(
        id: '6',
        name: 'erferfa',
        sku: 'SKU: n rcn',
        category: 'General',
        price: 0.00,
        stock: 0, // Demonstrates out-of-stock state
      ),
      MobilePosProduct(
        id: '7',
        name: 'esrdfg',
        sku: 'SKU: rvs',
        category: 'Electronics',
        price: 5465.00,
        stock: 47,
      ),
      MobilePosProduct(
        id: '8',
        name: 'laptop',
        sku: 'SKU: j- rcn',
        category: 'Electronics',
        price: 54000.00,
        stock: 72,
      ),
      MobilePosProduct(
        id: '9',
        name: 'macbook',
        sku: 'SKU: MAC-02',
        category: 'Electronics',
        price: 124999.00,
        stock: 15,
      ),
      MobilePosProduct(
        id: '10',
        name: 'milk',
        sku: 'SKU: MILK-101',
        category: 'General',
        price: 65.00,
        stock: 140,
      ),
      MobilePosProduct(
        id: '11',
        name: 'new bottle',
        sku: 'SKU: BOT-99',
        category: 'Electronics',
        price: 799.00,
        stock: 55,
      ),
      MobilePosProduct(
        id: '12',
        name: 'new product',
        sku: 'SKU: FW-11',
        category: 'Footwear',
        price: 1899.00,
        stock: 20,
      ),
      MobilePosProduct(
        id: '13',
        name: 'Wireless Bluetooth Headphones',
        sku: 'SKU: SKU-HD100',
        category: 'Accessories',
        price: 2499.00,
        stock: 45,
      ),
      MobilePosProduct(
        id: '14',
        name: 'USB-C Fast Charging Cable',
        sku: 'SKU: SKU-CB502',
        category: 'Accessories',
        price: 499.00,
        stock: 120,
      ),
    ];

    // Initial Cart items matching reference
    _cart = [
      MobileCartItem(
        product: _products[6],
        quantity: 1,
      ), // esrdfg (qty: 1, ₹5,465)
      MobileCartItem(product: _products[3], quantity: 1), // car (qty: 1, ₹545)
      MobileCartItem(
        product: _products[2],
        quantity: 2,
      ), // BMW car (qty: 2, ₹1,60,000)
    ];

    // Initial Sales History matching reference
    _salesHistory = [
      MobilePosSale(
        billNo: 'POS-BILL-9901',
        customer: 'Walk-in Client',
        itemCount: 3,
        totalAmount: 6497.00,
        paymentMode: 'UPI (F2)',
        time: '11:42 AM',
      ),
      MobilePosSale(
        billNo: 'POS-BILL-9902',
        customer: 'Rahul Sharma',
        itemCount: 1,
        totalAmount: 24999.00,
        paymentMode: 'Card (F3)',
        time: '11:15 AM',
      ),
      MobilePosSale(
        billNo: 'POS-BILL-9903',
        customer: 'Ananya Verma',
        itemCount: 4,
        totalAmount: 1996.00,
        paymentMode: 'Cash (F1)',
        time: '10:30 AM',
      ),
      MobilePosSale(
        billNo: 'POS-BILL-9904',
        customer: 'Priya Nair',
        itemCount: 2,
        totalAmount: 11498.00,
        paymentMode: 'UPI (F2)',
        time: '09:50 AM',
      ),
    ];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════
  // CART & FINANCIAL CALCULATIONS
  // ═════════════════════════════════════════════════════════════════
  int _getCartQuantity(String productId) {
    for (final item in _cart) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  int _getAvailableStock(MobilePosProduct product) {
    final inCart = _getCartQuantity(product.id);
    final available = product.stock - inCart;
    return available < 0 ? 0 : available;
  }

  void _addToCart(MobilePosProduct product) {
    final available = _getAvailableStock(product);
    if (available <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} is out of available stock!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: MobilePosColors.danger,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      final index = _cart.indexWhere((line) => line.product.id == product.id);
      if (index >= 0) {
        _cart[index].quantity++;
      } else {
        _cart.add(MobileCartItem(product: product, quantity: 1));
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${product.name} to cart',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: MobilePosColors.darkGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _incrementCartItem(int index) {
    final line = _cart[index];
    if (line.quantity >= line.product.stock) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot add more. Only ${line.product.stock} ${line.product.unit} available in stock!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: MobilePosColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      line.quantity++;
    });
  }

  void _decrementCartItem(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _removeCartItem(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _discountPercent = 0.0;
      _discountFlat = 0.0;
    });
  }

  void _holdCart() {
    if (_cart.isEmpty) return;

    final held = MobileHeldCart(
      id: 'HELD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      customer: _selectedCustomer,
      items: List.from(
        _cart.map(
          (e) => MobileCartItem(product: e.product, quantity: e.quantity),
        ),
      ),
      heldAt: DateTime.now(),
      totalAmount: _payableAmount,
    );

    setState(() {
      _heldCarts.add(held);
      _cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order marked as ON HOLD (${_heldCarts.length} held orders)',
          style: GoogleFonts.inter(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: MobilePosColors.warning,
      ),
    );
  }

  void _restoreHeldCart(MobileHeldCart held) {
    setState(() {
      _selectedCustomer = held.customer;
      _cart = List.from(held.items);
      _heldCarts.remove(held);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Held cart restored to active checkout.',
          style: GoogleFonts.inter(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: MobilePosColors.darkGreen,
      ),
    );
  }

  double get _subtotal => _cart.fold(0.0, (sum, line) => sum + line.total);
  double get _discountAmount {
    if (_discountMode == DiscountMode.percentage) {
      return _subtotal * (_discountPercent / 100);
    } else {
      return _discountFlat.clamp(0.0, _subtotal);
    }
  }

  double get _taxableAmount =>
      (_subtotal - _discountAmount).clamp(0.0, double.infinity);
  double get _gstAmount => _taxableAmount * _gstRate;
  double get _rawTotal =>
      (_taxableAmount + _gstAmount - _ptsRedeemed).clamp(0.0, double.infinity);
  double get _payableAmount => _rawTotal.roundToDouble();

  int get _cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  List<MobilePosProduct> get _filteredProducts {
    return _products.where((p) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ═════════════════════════════════════════════════════════════════
  // MODAL SHEETS TRIGGERS
  // ═════════════════════════════════════════════════════════════════
  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobileCartSheet(
        cart: _cart,
        customer: _selectedCustomer,
        discountPercent: _discountPercent,
        discountFlat: _discountFlat,
        discountMode: _discountMode,
        gstRate: _gstRate,
        ptsRedeemed: _ptsRedeemed,
        ptsEarned: _ptsEarned,
        onIncrement: _incrementCartItem,
        onDecrement: _decrementCartItem,
        onRemove: _removeCartItem,
        onClearCart: _clearCart,
        onHoldCart: _holdCart,
        onUpdateDiscount: (mode, val) {
          setState(() {
            _discountMode = mode;
            if (mode == DiscountMode.percentage) {
              _discountPercent = val;
            } else {
              _discountFlat = val;
            }
          });
        },
        onUpdateGstRate: (rate) => setState(() => _gstRate = rate),
        onProceedToPayment: _openPaymentSheet,
      ),
    );
  }

  void _openPaymentSheet() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cart is empty. Add products before payment.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: MobilePosColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobilePaymentSheet(
        payableAmount: _payableAmount,
        customer: _selectedCustomer,
        cart: _cart,
        onPaymentCompleted: (sale) {
          setState(() {
            _salesHistory.insert(0, sale);
            _cart.clear();
            _discountPercent = 0.0;
            _discountFlat = 0.0;
          });
        },
      ),
    );
  }

  void _openSalesHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobileHistorySheet(salesHistory: _salesHistory),
    );
  }

  void _openHeldCarts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobileHeldCartsSheet(
        heldCarts: _heldCarts,
        onRestoreCart: _restoreHeldCart,
        onDiscardCart: (held) => setState(() => _heldCarts.remove(held)),
      ),
    );
  }

  void _openQuickAddProduct() {
    showDialog(
      context: context,
      builder: (context) => const QuickRegisterItemDialog(),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  // PRODUCT STOCK MANAGEMENT & ACTIONS (Mobile Android + iOS Only)
  // ═════════════════════════════════════════════════════════════════
  Future<bool> _handleStockAdjustment({
    required MobilePosProduct product,
    required MobileStockAdjustmentType type,
    required int quantity,
    required String reason,
    required String warehouse,
  }) async {
    // Authoritative stock update logic:
    // Simulates network latency with authoritative validation and state refresh
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return false;

    if (type == MobileStockAdjustmentType.increase) {
      setState(() {
        product.stock += quantity;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $quantity ${product.unit} to "${product.name}". Total stock is now ${product.stock} ${product.unit} ($warehouse).',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: MobilePosColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2500),
        ),
      );
    } else {
      if (quantity > product.stock) {
        return false;
      }
      setState(() {
        product.stock -= quantity;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deducted $quantity ${product.unit} from "${product.name}". Total stock is now ${product.stock} ${product.unit} ($warehouse).',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFFEA580C),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2500),
        ),
      );

      // Revalidate active cart: warn if cart quantity exceeds newly available stock
      final inCartIndex =
          _cart.indexWhere((item) => item.product.id == product.id);
      if (inCartIndex >= 0) {
        final cartItem = _cart[inCartIndex];
        if (cartItem.quantity > product.stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notice: Cart has ${cartItem.quantity} of "${product.name}", exceeding updated stock (${product.stock} ${product.unit}). Please review your cart.',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: MobilePosColors.warning,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
    return true;
  }

  void _openIncreaseStockSheet(MobilePosProduct product) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobileStockAdjustmentSheet(
        product: product,
        warehouse: _selectedWarehouse,
        type: MobileStockAdjustmentType.increase,
        onConfirm: ({
          required int quantity,
          required String reason,
          required String warehouse,
        }) =>
            _handleStockAdjustment(
          product: product,
          type: MobileStockAdjustmentType.increase,
          quantity: quantity,
          reason: reason,
          warehouse: warehouse,
        ),
      ),
    );
  }

  void _openDecreaseStockSheet(MobilePosProduct product) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobileStockAdjustmentSheet(
        product: product,
        warehouse: _selectedWarehouse,
        type: MobileStockAdjustmentType.decrease,
        onConfirm: ({
          required int quantity,
          required String reason,
          required String warehouse,
        }) =>
            _handleStockAdjustment(
          product: product,
          type: MobileStockAdjustmentType.decrease,
          quantity: quantity,
          reason: reason,
          warehouse: warehouse,
        ),
      ),
    );
  }

  void _openEditProductSheet(MobilePosProduct product) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobileEditProductSheet(
        product: product,
        categories: _categories,
        onSave: ({
          required String name,
          required double price,
          required int stock,
          required String category,
        }) async {
          await Future.delayed(const Duration(milliseconds: 300));
          if (!mounted) return false;

          setState(() {
            final idx = _products.indexWhere((p) => p.id == product.id);
            if (idx >= 0) {
              _products[idx] = product.copyWith(
                name: name,
                price: price,
                stock: stock,
                category: category,
              );
            }
            // Update item in cart if present
            final cartIdx =
                _cart.indexWhere((c) => c.product.id == product.id);
            if (cartIdx >= 0 && idx >= 0) {
              _cart[cartIdx] = MobileCartItem(
                product: _products[idx],
                quantity: _cart[cartIdx].quantity,
              );
            }
          });

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product "$name" updated successfully'),
              backgroundColor: MobilePosColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return true;
        },
      ),
    );
  }

  void _confirmDeleteProduct(MobilePosProduct product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MobilePosColors.dangerLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.trash2,
                color: MobilePosColors.danger,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Delete Product?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MobilePosColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${product.name}" from the catalogue? It will also be removed from any active cart.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: MobilePosColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: MobilePosColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _products.removeWhere((p) => p.id == product.id);
                _cart.removeWhere((c) => c.product.id == product.id);
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Item "${product.name}" deleted from catalog'),
                  backgroundColor: MobilePosColors.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MobilePosColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: MobilePosColors.surfaceBg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Compact POS Header
                MobilePosHeader(
                  selectedWarehouse: _selectedWarehouse,
                  warehouses: _warehouses,
                  onWarehouseSelected: (wh) =>
                      setState(() => _selectedWarehouse = wh),
                  onOpenHistory: _openSalesHistory,
                  onOpenHeldCarts: _openHeldCarts,
                  heldCartsCount: _heldCarts.length,
                  onQuickAddProduct: _openQuickAddProduct,
                  onBack: () {
                    ref
                        .read(navigationProvider.notifier)
                        .setModuleAndRoute(AppModule.books, AppRoute.dashboard);
                  },
                ),

                // 2. Customer Summary / Selector Bar
                MobileCustomerBar(
                  currentCustomer: _selectedCustomer,
                  customers: _customers,
                  onSelectCustomer: (c) =>
                      setState(() => _selectedCustomer = c),
                  onRegisterCustomer: (newC) {
                    setState(() {
                      _customers.insert(0, newC);
                      _selectedCustomer = newC;
                    });
                  },
                ),

                // 3. Search & Category Filters Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search input
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: MobilePosColors.surfaceBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: MobilePosColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.search,
                              size: 16,
                              color: MobilePosColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (val) =>
                                    setState(() => _searchQuery = val),
                                style: GoogleFonts.inter(fontSize: 12.5),
                                decoration: InputDecoration(
                                  hintText:
                                      'Search product by name, SKU or category...',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: MobilePosColors.textMuted,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              InkWell(
                                onTap: () => setState(() {
                                  _searchCtrl.clear();
                                  _searchQuery = '';
                                }),
                                child: const Icon(
                                  LucideIcons.xCircle,
                                  size: 16,
                                  color: MobilePosColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Horizontal Categories List
                      SizedBox(
                        height: 28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 6),
                          itemBuilder: (context, idx) {
                            final cat = _categories[idx];
                            final isSel = _selectedCategory == cat;

                            return InkWell(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? MobilePosColors.primaryGreen
                                      : MobilePosColors.surfaceBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSel
                                        ? MobilePosColors.primaryGreen
                                        : MobilePosColors.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: isSel
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSel
                                          ? Colors.white
                                          : MobilePosColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Products Catalogue Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      // 1 column on narrow width < 340, 3 columns on tablet >= 600, 2 columns on phones
                      final crossAxisCount = width < 340
                          ? 1
                          : (width >= 600 ? 3 : 2);
                      final childAspectRatio = crossAxisCount == 1
                          ? 1.85
                          : (width < 380 ? 0.77 : 0.82);

                      if (_filteredProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.packageX,
                                size: 44,
                                color: MobilePosColors.textMuted,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No products found',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: MobilePosColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search query or category filter',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: MobilePosColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final bottomBarOffset = bottomInset > 0
                          ? (bottomInset * 0.35).clamp(2.0, 6.0)
                          : 4.0;

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          14,
                          12,
                          14,
                          _cart.isNotEmpty
                              ? (154 + bottomBarOffset)
                              : (80 + bottomBarOffset),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final inCartQty = _getCartQuantity(product.id);
                          final cartIndex = _cart.indexWhere(
                            (l) => l.product.id == product.id,
                          );

                          return MobileProductCard(
                            product: product,
                            cartQuantity: inCartQty,
                            onAddToCart: () => _addToCart(product),
                            onIncrement: cartIndex >= 0
                                ? () => _incrementCartItem(cartIndex)
                                : null,
                            onDecrement: cartIndex >= 0
                                ? () => _decrementCartItem(cartIndex)
                                : null,
                            onIncreaseStock: () =>
                                _openIncreaseStockSheet(product),
                            onDecreaseStock: () =>
                                _openDecreaseStockSheet(product),
                            onEditItem: () => _openEditProductSheet(product),
                            onDeleteItem: () => _confirmDeleteProduct(product),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // 5. Persistent Docked Mobile Cart Bar (Docked gracefully above stylish bottom nav bar)
            if (_cart.isNotEmpty)
              Positioned(
                left: 14,
                right: 14,
                bottom:
                    74 +
                    (bottomInset > 0
                        ? (bottomInset * 0.35).clamp(2.0, 6.0)
                        : 4.0),
                child: Material(
                  elevation: 8,
                  shadowColor: MobilePosColors.primaryGreen.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: MobilePosColors.primaryGreen,
                  child: InkWell(
                    onTap: _openCartSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.shoppingBag,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_cartItemCount ${_cartItemCount == 1 ? "Item" : "Items"} • Tax Incl.',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '₹${formatIndianCurrency(_payableAmount)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Cart',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: MobilePosColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  size: 14,
                                  color: MobilePosColors.primaryGreen,
                                ),
                              ],
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
      ),
    );
  }
}
