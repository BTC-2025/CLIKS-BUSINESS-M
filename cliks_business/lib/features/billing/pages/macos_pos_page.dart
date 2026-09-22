import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../widgets/quick_register_item_dialog.dart';

class _PosProductItem {
  final String id;
  String name;
  String sku;
  String category;
  double price;
  int stock;
  final String unit;

  _PosProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    this.unit = 'PCS',
  });
}

class _PosCartLine {
  final _PosProductItem product;
  int quantity;

  _PosCartLine({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}

class MacOsPosPage extends ConsumerStatefulWidget {
  const MacOsPosPage({super.key});

  @override
  ConsumerState<MacOsPosPage> createState() => _MacOsPosPageState();
}

class _MacOsPosPageState extends ConsumerState<MacOsPosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedWarehouse = 'Warehouse';

  // Customer state
  bool _hasCustomer = true;
  final String _customerName = 'Varshini';
  final String _customerContact = 'chandran12...';
  final int _loyaltyPoints = 0;

  // Payment modifiers
  final double _discountPercent = 0.0;
  final double _gstRate = 0.18; // 18%
  final double _ptsRedeemed = 0.0;

  // Product Catalog matching screenshot
  late List<_PosProductItem> _products;

  // Active Cart
  late List<_PosCartLine> _cart;

  @override
  void initState() {
    super.initState();

    _products = [
      _PosProductItem(
        id: '1',
        name: 'a new digit product',
        sku: 'SKU: SKU-3752',
        category: 'General',
        price: 10004399.00,
        stock: 416,
      ),
      _PosProductItem(
        id: '2',
        name: 'apple',
        sku: 'SKU: app',
        category: 'Electronics',
        price: 500.00,
        stock: 8,
      ),
      _PosProductItem(
        id: '3',
        name: 'BMW car',
        sku: 'SKU: BMW-788',
        category: 'vehicles',
        price: 80000.00,
        stock: 35,
      ),
      _PosProductItem(
        id: '4',
        name: 'car',
        sku: 'SKU: 54',
        category: 'Electronics',
        price: 545.00,
        stock: 29,
      ),
      _PosProductItem(
        id: '5',
        name: 'carrot',
        sku: 'SKU: SKU-746095',
        category: 'General',
        price: 526.00,
        stock: 1180,
      ),
      _PosProductItem(
        id: '6',
        name: 'erferfa',
        sku: 'SKU: n rcn',
        category: 'General',
        price: 0.00,
        stock: 0,
      ),
      _PosProductItem(
        id: '7',
        name: 'esrdfg',
        sku: 'SKU: rvs',
        category: 'Electronics',
        price: 5465.00,
        stock: 47,
      ),
      _PosProductItem(
        id: '8',
        name: 'laptop',
        sku: 'SKU: j- rcn',
        category: 'Electronics',
        price: 54000.00,
        stock: 72,
      ),
      _PosProductItem(
        id: '9',
        name: 'macbook',
        sku: 'SKU: MAC-02',
        category: 'Electronics',
        price: 124999.00,
        stock: 15,
      ),
      _PosProductItem(
        id: '10',
        name: 'milk',
        sku: 'SKU: MILK-101',
        category: 'General',
        price: 65.00,
        stock: 140,
      ),
      _PosProductItem(
        id: '11',
        name: 'new bottle',
        sku: 'SKU: BOT-99',
        category: 'Electronics',
        price: 799.00,
        stock: 55,
      ),
      _PosProductItem(
        id: '12',
        name: 'new product',
        sku: 'SKU: FW-11',
        category: 'Footwear',
        price: 1899.00,
        stock: 20,
      ),
    ];

    // Initial Cart items matching reference screenshot:
    // 1. esrdfg (qty: 1, ₹5,465)
    // 2. car (qty: 1, ₹545)
    // 3. BMW car (qty: 2, ₹1,60,000)
    _cart = [
      _PosCartLine(product: _products[6], quantity: 1),
      _PosCartLine(product: _products[3], quantity: 1),
      _PosCartLine(product: _products[2], quantity: 2),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getCartQuantity(String productId) {
    for (final item in _cart) {
      if (item.product.id == productId) {
        return item.quantity;
      }
    }
    return 0;
  }

  int _getAvailableStock(_PosProductItem product) {
    final inCart = _getCartQuantity(product.id);
    final available = product.stock - inCart;
    return available < 0 ? 0 : available;
  }

  void _addToCart(_PosProductItem product) {
    final available = _getAvailableStock(product);
    if (available <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is out of available stock!', style: GoogleFonts.outfit()),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          width: 380,
        ),
      );
      return;
    }

    setState(() {
      final index = _cart.indexWhere((line) => line.product.id == product.id);
      if (index >= 0) {
        _cart[index].quantity++;
      } else {
        _cart.add(_PosCartLine(product: product, quantity: 1));
      }
    });
  }

  void _incrementCartItem(int index) {
    final line = _cart[index];
    if (line.quantity >= line.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot add more. Only ${line.product.stock} ${line.product.unit} available in stock!',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          width: 380,
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
    });
  }

  // ─── INCREASE STOCK MODAL (Matching Screenshot) ───
  void _showIncreaseStockDialog(_PosProductItem product) {
    final qtyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Increase Stock',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(LucideIcons.x, size: 17, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRODUCT',
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Current Stock: ',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${product.stock}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'Quantity to Add',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '*',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF111827)),
                          decoration: InputDecoration(
                            hintText: 'e.g. 20',
                            hintStyle: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      Container(
                        width: 28,
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: Color(0xFFE5E7EB))),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                final cur = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                                qtyCtrl.text = '${cur + 1}';
                              },
                              child: const SizedBox(
                                height: 18,
                                child: Center(
                                  child: Icon(LucideIcons.chevronUp, size: 13, color: Color(0xFF4B5563)),
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                            InkWell(
                              onTap: () {
                                final cur = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                                if (cur > 1) {
                                  qtyCtrl.text = '${cur - 1}';
                                }
                              },
                              child: const SizedBox(
                                height: 18,
                                child: Center(
                                  child: Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF4B5563)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final addQty = int.tryParse(qtyCtrl.text.trim());
                        if (addQty == null || addQty <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please enter a valid quantity greater than 0',
                                style: GoogleFonts.outfit(),
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                              width: 380,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          product.stock += addQty;
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $addQty PCS to "${product.name}". Total stock is now ${product.stock} PCS.',
                              style: GoogleFonts.outfit(),
                            ),
                            backgroundColor: const Color(0xFF16A34A),
                            duration: const Duration(milliseconds: 1800),
                            behavior: SnackBarBehavior.floating,
                            width: 400,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                      ),
                      child: Text(
                        'Add Stock',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── DECREASE STOCK MODAL ───
  void _showDecreaseStockDialog(_PosProductItem product) {
    final qtyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Decrease Stock',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(LucideIcons.x, size: 17, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRODUCT',
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Current Stock: ',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            '${product.stock}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'Quantity to Deduct',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '*',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF111827)),
                          decoration: InputDecoration(
                            hintText: 'e.g. 5',
                            hintStyle: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      Container(
                        width: 28,
                        decoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: Color(0xFFE5E7EB))),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                final cur = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                                qtyCtrl.text = '${cur + 1}';
                              },
                              child: const SizedBox(
                                height: 18,
                                child: Center(
                                  child: Icon(LucideIcons.chevronUp, size: 13, color: Color(0xFF4B5563)),
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                            InkWell(
                              onTap: () {
                                final cur = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                                if (cur > 1) {
                                  qtyCtrl.text = '${cur - 1}';
                                }
                              },
                              child: const SizedBox(
                                height: 18,
                                child: Center(
                                  child: Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF4B5563)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final deductQty = int.tryParse(qtyCtrl.text.trim());
                        if (deductQty == null || deductQty <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a valid quantity greater than 0', style: GoogleFonts.outfit()),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                              width: 380,
                            ),
                          );
                          return;
                        }
                        if (deductQty > product.stock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cannot deduct $deductQty PCS. Current stock is only ${product.stock} PCS.', style: GoogleFonts.outfit()),
                              backgroundColor: const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                              width: 380,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          product.stock -= deductQty;
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deducted $deductQty PCS from "${product.name}". Total stock is now ${product.stock} PCS.', style: GoogleFonts.outfit()),
                            backgroundColor: const Color(0xFFEA580C),
                            duration: const Duration(milliseconds: 1800),
                            behavior: SnackBarBehavior.floating,
                            width: 400,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      ),
                      child: Text(
                        'Deduct Stock',
                        style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteProduct(_PosProductItem product) {
    setState(() {
      _products.removeWhere((p) => p.id == product.id);
      _cart.removeWhere((line) => line.product.id == product.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item "${product.name}" deleted from catalog'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        width: 380,
      ),
    );
  }

  void _showEditProductDialog(_PosProductItem product) {
    final nameCtrl = TextEditingController(text: product.name);
    final priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));
    final stockCtrl = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.penSquare, color: Color(0xFF2563EB), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Edit Product Item',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Product Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stock (PCS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          product.name = nameCtrl.text.trim();
                          product.price = double.tryParse(priceCtrl.text.trim()) ?? product.price;
                          product.stock = int.tryParse(stockCtrl.text.trim()) ?? product.stock;
                        });
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF135029),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _subtotal => _cart.fold(0.0, (sum, line) => sum + line.total);
  double get _discountAmount => _subtotal * (_discountPercent / 100);
  double get _taxableAmount => _subtotal - _discountAmount;
  double get _gstAmount => _taxableAmount * _gstRate;
  double get _rawTotal => _taxableAmount + _gstAmount - _ptsRedeemed;
  double get _roundOff => (_rawTotal.roundToDouble() - _rawTotal);
  double get _payableAmount => _rawTotal.roundToDouble();

  List<_PosProductItem> get _filteredProducts {
    return _products.where((prod) {
      final matchesSearch = _searchQuery.isEmpty ||
          prod.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prod.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prod.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          prod.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  String _formatIndianCurrency(double amount) {
    final isNegative = amount < 0;
    final absVal = amount.abs();
    final parts = absVal.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 1).split('.');
    String whole = parts[0];
    final dec = parts.length > 1 ? '.${parts[1]}' : '';

    if (whole.length > 3) {
      final lastThree = whole.substring(whole.length - 3);
      final rest = whole.substring(0, whole.length - 3);
      final buffer = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) {
          buffer.write(',');
        }
        buffer.write(rest[i]);
      }
      whole = '${buffer.toString()},$lastThree';
    }

    return '${isNegative ? '-' : ''}$whole$dec';
  }

  void _showCheckoutSuccess(String method) {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty. Please add items to checkout.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          width: 380,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAFAE3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.checkCircle2,
                    color: Color(0xFF135029),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Completed!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Amount ₹${_formatIndianCurrency(_payableAmount)} received via $method.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Customer:', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5)),
                          Text(_hasCustomer ? _customerName : 'Walk-in Customer',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827), fontSize: 12.5)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Items Count:', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5)),
                          Text('${_cart.length} Products', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Mode:', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5)),
                          Text(method, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A), fontSize: 12.5)),
                        ],
                      ),
                      const Divider(height: 16, color: Color(0xFFE5E7EB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            '₹${_formatIndianCurrency(_payableAmount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: Color(0xFF135029),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        icon: const Icon(LucideIcons.printer, size: 16),
                        label: const Text('Print Receipt'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF374151),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          _clearCart();
                        },
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('New Sale'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF135029),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSalesHistoryDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 540),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.history, color: Color(0xFF135029), size: 20),
                        SizedBox(width: 10),
                        Text(
                          'POS Sales Register',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _buildHistoryItem('POS-BILL-9901', 'Walk-in Client', '₹6,497', 'UPI', '11:42 AM', 3),
                      _buildHistoryItem('POS-BILL-9902', 'Rahul Sharma', '₹24,999', 'CARD', '11:15 AM', 1),
                      _buildHistoryItem('POS-BILL-9903', 'Ananya Verma', '₹1,996', 'CASH', '10:30 AM', 4),
                      _buildHistoryItem('POS-BILL-9904', 'Priya Nair', '₹11,498', 'UPI', '09:50 AM', 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String billNo, String customer, String amount, String mode, String time, int items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAFAE3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.receipt, color: Color(0xFF135029), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(billNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                Text('$customer • $items items', style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF111827))),
              Text('$mode • $time', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTwoColumn = constraints.maxWidth >= 1080;

          if (isTwoColumn) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── LEFT: MAIN CATALOG & CONTROLS ───
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 12),
                        _buildSearchAndFilters(),
                        const SizedBox(height: 10),
                        _buildWarehouseDropdown(),
                        const SizedBox(height: 12),
                        _buildProductCatalogGrid(constraints.maxWidth - 430),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // ─── RIGHT: CART & PAYMENT PANEL ───
                SizedBox(
                  width: 400,
                  height: constraints.maxHeight,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildRightCheckoutPanel(),
                  ),
                ),
              ],
            );
          } else {
            // Adaptive stacked layout for narrow window widths to guarantee zero overflow
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 12),
                  _buildSearchAndFilters(),
                  const SizedBox(height: 10),
                  _buildWarehouseDropdown(),
                  const SizedBox(height: 12),
                  _buildProductCatalogGrid(constraints.maxWidth),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: _buildRightCheckoutPanel(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. HEADER CARD (Compact & Modern)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Green POS Identity Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.shoppingBag,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Retail POS System',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  height: 1.15,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Speed Checkout Terminal #1',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // + Add Product Emerald Button
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const QuickRegisterItemDialog(),
              );
            },
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text(
              'Add Product',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          const Spacer(),

          // Stats Pill: TODAY ORDERS & TOTAL SALES
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              border: Border.all(color: const Color(0xFFBBF7D0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY ORDERS',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL SALES',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '₹2,36,00,10,382',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // History Button
          OutlinedButton.icon(
            onPressed: _showSalesHistoryDialog,
            icon: const Icon(LucideIcons.history, size: 13, color: Color(0xFF4B5563)),
            label: const Text('History', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. SEARCH & CURVY CATEGORY FILTERS ROW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchAndFilters() {
    final categories = ['All', 'General', 'Electronics', 'vehicles', 'Footwear'];

    return Row(
      children: [
        // Pill-shaped Search bar
        Expanded(
          flex: 4,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(LucideIcons.search, size: 15, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF111827)),
                    decoration: const InputDecoration(
                      hintText: 'Search item name, category or barcode S',
                      hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 11),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(LucideIcons.x, size: 14, color: Color(0xFF9CA3AF)),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Curvy Category Pills
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF166534) : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Pill-shaped Curvy Warehouse Dropdown
  Widget _buildWarehouseDropdown() {
    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() {
          _selectedWarehouse = val;
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Warehouse', child: Text('All Warehouses')),
        const PopupMenuItem(value: 'Main Hub', child: Text('Main Central Hub')),
        const PopupMenuItem(value: 'Retail Store 1', child: Text('Retail Store #1')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedWarehouse,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF1E293B)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. PRODUCT CATALOG GRID (Modern Curvy Cards)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProductCatalogGrid(double availableWidth) {
    final filtered = _filteredProducts;

    if (filtered.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.box, size: 36, color: Color(0xFF9CA3AF)),
            SizedBox(height: 10),
            Text(
              'No matching products found',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: Color(0xFF4B5563)),
            ),
          ],
        ),
      );
    }

    int crossAxisCount = 4;
    if (availableWidth < 700) {
      crossAxisCount = 2;
    } else if (availableWidth < 1000) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.22,
      ),
      itemBuilder: (context, index) {
        final product = filtered[index];
        final cartQty = _getCartQuantity(product.id);
        final isInCart = cartQty > 0;

        return InkWell(
          onTap: () => _addToCart(product),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isInCart ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                width: isInCart ? 1.6 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isInCart
                      ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Category tag + 3-Dots Action Popup
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.5,
                      ),
                    ),

                    // Custom 3-dots popup menu matching reference screenshot
                    Theme(
                      data: Theme.of(context).copyWith(cardColor: Colors.white),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 160),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        elevation: 8,
                        color: Colors.white,
                        icon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Icon(LucideIcons.ellipsisVertical, size: 13, color: Color(0xFF6B7280)),
                        ),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showEditProductDialog(product);
                          } else if (val == 'increase') {
                            _showIncreaseStockDialog(product);
                          } else if (val == 'decrease') {
                            _showDecreaseStockDialog(product);
                          } else if (val == 'delete') {
                            _deleteProduct(product);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            height: 38,
                            child: Row(
                              children: [
                                const Icon(LucideIcons.penSquare, size: 15, color: Color(0xFF2563EB)),
                                const SizedBox(width: 10),
                                Text('Edit Item', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'increase',
                            height: 38,
                            child: Row(
                              children: [
                                const Icon(LucideIcons.trendingUp, size: 15, color: Color(0xFF16A34A)),
                                const SizedBox(width: 10),
                                Text('Increase Stock', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'decrease',
                            height: 38,
                            child: Row(
                              children: [
                                const Icon(LucideIcons.trendingDown, size: 15, color: Color(0xFFEA580C)),
                                const SizedBox(width: 10),
                                Text('Decrease Stock', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(height: 1),
                          PopupMenuItem(
                            value: 'delete',
                            height: 38,
                            child: Row(
                              children: [
                                const Icon(LucideIcons.trash2, size: 15, color: Color(0xFFEF4444)),
                                const SizedBox(width: 10),
                                Text('Delete Item', style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Product Name + In-Cart Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.sku,
                            style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                    if (isInCart)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$cartQty In Cart',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                // Bottom Row: Price + Dynamic Stock Pill (Reduces dynamically with cart additions)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹${_formatIndianCurrency(product.price)} ',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          TextSpan(
                            text: '/ ${product.unit}',
                            style: GoogleFonts.outfit(fontSize: 9, color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),

                    // Dynamic Stock badge: Automatically reflects stock minus cart quantity
                    Builder(
                      builder: (context) {
                        final availableStock = _getAvailableStock(product);

                        if (availableStock == 0) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'OUT',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          );
                        } else if (availableStock < 10) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$availableStock PCS\nleft',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD97706),
                                height: 1.0,
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$availableStock PCS\nleft',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF16A34A),
                                height: 1.0,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. RIGHT CHECKOUT & CART PANEL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRightCheckoutPanel() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── A. CUSTOMER INFORMATION ───
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CUSTOMER INFORMATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(LucideIcons.chevronUp, size: 16, color: Color(0xFF6B7280)),
            ],
          ),

          const SizedBox(height: 10),

          // Customer search / input
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.user, size: 15, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _hasCustomer ? _customerName : 'Select Customer',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  ),
                ),
                if (_hasCustomer)
                  InkWell(
                    onTap: () {
                      setState(() => _hasCustomer = false);
                    },
                    child: const Icon(LucideIcons.x, size: 14, color: Color(0xFF9CA3AF)),
                  ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    ref.read(navigationProvider.notifier).setRoute(AppRoute.addCustomer);
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.userPlus, size: 13, color: Color(0xFF16A34A)),
                      SizedBox(width: 4),
                      Text(
                        'Add Customer',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_hasCustomer) ...[
            const SizedBox(height: 10),
            // Selected Customer card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  Text(
                    'Name: $_customerName',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _customerContact,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LTP: $_loyaltyPoints',
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ),
                  const Spacer(),
                  const Icon(LucideIcons.pencil, size: 13, color: Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => setState(() => _hasCustomer = false),
                    child: const Icon(LucideIcons.trash2, size: 13, color: Color(0xFFEF4444)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.history, size: 10, color: Color(0xFF2563EB)),
                        SizedBox(width: 3),
                        Text(
                          'History',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ─── B. CART ITEMS ───
          Row(
            children: [
              Text(
                'CART (${_cart.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF374151),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cart marked as ON HOLD.'),
                      behavior: SnackBarBehavior.floating,
                      width: 300,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: const Text(
                    'Hold Cart',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _clearCart,
                child: const Text(
                  'Clear Cart',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_cart.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              alignment: Alignment.center,
              child: const Text(
                'Your cart is empty.\nTap products on the left to add items.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cart.length,
              separatorBuilder: (_, _) => const Divider(height: 14, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final line = _cart[index];

                return Row(
                  children: [
                    // Name & Unit Price
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.product.name,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '₹${_formatIndianCurrency(line.product.price)} / ${line.product.unit}',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),

                    // Stepper: [-] X PCS [+]
                    Container(
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => _decrementCartItem(index),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(LucideIcons.minus, size: 11, color: Color(0xFF374151)),
                            ),
                          ),
                          Text(
                            '${line.quantity}  ${line.product.unit}',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                          ),
                          InkWell(
                            onTap: () => _incrementCartItem(index),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(LucideIcons.plus, size: 11, color: Color(0xFF374151)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Line Total
                    Text(
                      '₹${_formatIndianCurrency(line.total)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Trash button
                    InkWell(
                      onTap: () => _removeCartItem(index),
                      child: const Icon(LucideIcons.trash2, size: 13, color: Color(0xFFEF4444)),
                    ),
                  ],
                );
              },
            ),

          const SizedBox(height: 16),

          // ─── C. PAYMENT SUMMARY ───
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAYMENT SUMMARY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(LucideIcons.chevronUp, size: 16, color: Color(0xFF6B7280)),
            ],
          ),

          const SizedBox(height: 10),

          // Four input columns: DISCOUNT, GST TAX, PTS REDEEMED, PTS EARNED
          Row(
            children: [
              // DISCOUNT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('DISCOUNT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                        Spacer(),
                        Text('%', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                        Text(' | ', style: TextStyle(fontSize: 7.5, color: Color(0xFFD1D5DB))),
                        Text('Flat', style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 30,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('0', style: TextStyle(fontSize: 11.5, color: Color(0xFF111827))),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // GST TAX (%)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GST TAX (%)', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
                    const SizedBox(height: 4),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('18%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                          Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF6B7280)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // PTS REDEEMED
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PTS REDEEMED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    const SizedBox(height: 4),
                    Container(
                      height: 30,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        border: Border.all(color: const Color(0xFFFECACA)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('0', style: TextStyle(fontSize: 11.5, color: Color(0xFF111827))),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // PTS EARNED
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PTS EARNED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    const SizedBox(height: 4),
                    Container(
                      height: 30,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('0', style: TextStyle(fontSize: 11.5, color: Color(0xFF111827))),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Subtotal lines
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
              Text('₹${_formatIndianCurrency(_subtotal)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GST (18%)', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
              Text('₹${_formatIndianCurrency(_gstAmount)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Round Off', style: TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF))),
              Text(
                '${_roundOff >= 0 ? '+' : ''}₹${_roundOff.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Payable Amount row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Payable Amount',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
              Text(
                '₹${_formatIndianCurrency(_payableAmount)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 Quick Payment Buttons: Cash (F1), UPI (F2), Card (F3)
          Row(
            children: [
              // $ Cash (F1)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCheckoutSuccess('Cash (F1)'),
                  icon: const Icon(LucideIcons.dollarSign, size: 13),
                  label: const Text('Cash (F1)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // UPI (F2)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCheckoutSuccess('UPI (F2)'),
                  icon: const Icon(LucideIcons.qrCode, size: 13),
                  label: const Text('UPI (F2)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Card (F3)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCheckoutSuccess('Card (F3)'),
                  icon: const Icon(LucideIcons.creditCard, size: 13),
                  label: const Text('Card (F3)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
