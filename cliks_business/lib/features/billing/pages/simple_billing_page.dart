import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';

class _SimpleBillItem {
  final TextEditingController nameController;
  final TextEditingController rateController;
  final TextEditingController qtyController;

  _SimpleBillItem({
    String name = '',
    double? rate,
    int qty = 1,
  })  : nameController = TextEditingController(text: name),
        rateController = TextEditingController(
          text: rate != null && rate > 0 ? rate.toStringAsFixed(2) : '',
        ),
        qtyController = TextEditingController(text: qty > 0 ? qty.toString() : '1');

  double get rate {
    final text = rateController.text.trim();
    if (text.isEmpty) return 0.0;
    final val = double.tryParse(text);
    if (val == null || val.isNaN || val.isInfinite || val < 0) return 0.0;
    return val;
  }

  int get quantity {
    final text = qtyController.text.trim();
    if (text.isEmpty) return 0;
    final clean = text.length > 12 ? text.substring(0, 12) : text;
    final val = int.tryParse(clean);
    if (val == null || val < 0) return 0;
    return val;
  }

  double get total {
    final t = rate * quantity;
    if (t.isNaN || t.isInfinite || t < 0) return 0.0;
    return t;
  }

  void dispose() {
    nameController.dispose();
    rateController.dispose();
    qtyController.dispose();
  }
}

class SimpleBillingPage extends ConsumerStatefulWidget {
  const SimpleBillingPage({super.key});

  @override
  ConsumerState<SimpleBillingPage> createState() => _SimpleBillingPageState();
}

class _SimpleBillingPageState extends ConsumerState<SimpleBillingPage> {
  final TextEditingController _customerController = TextEditingController();
  final FocusNode _customerFocusNode = FocusNode();

  late String _orderNumber;
  final List<_SimpleBillItem> _items = [];
  bool _isCustomerFocused = false;

  // Catalog for quick multi-select and dropdown
  final List<Map<String, dynamic>> _catalogProducts = [
    {'name': 'Wireless Optical Mouse', 'rate': 499.00, 'category': 'Electronics'},
    {'name': 'Mechanical RGB Keyboard', 'rate': 2499.00, 'category': 'Electronics'},
    {'name': 'USB-C Fast Charging Cable (1.5m)', 'rate': 299.00, 'category': 'Accessories'},
    {'name': '27" 4K UHD IPS Monitor', 'rate': 18999.00, 'category': 'Electronics'},
    {'name': 'Ergonomic Office Swivel Chair', 'rate': 6499.00, 'category': 'Furniture'},
    {'name': 'Laptop Aluminum Stand', 'rate': 899.00, 'category': 'Accessories'},
    {'name': 'Noise Cancelling Headphones', 'rate': 3999.00, 'category': 'Audio'},
    {'name': 'Thermal Receipt Paper Roll (Pack of 10)', 'rate': 350.00, 'category': 'Supplies'},
    {'name': 'Laser Barcode Scanner USB', 'rate': 1799.00, 'category': 'Supplies'},
    {'name': 'Heavy Duty Cash Drawer', 'rate': 2899.00, 'category': 'Hardware'},
    {'name': 'Bluetooth Thermal Receipt Printer', 'rate': 4200.00, 'category': 'Hardware'},
    {'name': 'Full HD 1080p Webcam', 'rate': 1499.00, 'category': 'Electronics'},
    {'name': 'Adjustable Desk Lamp with Wireless Charger', 'rate': 1299.00, 'category': 'Furniture'},
    {'name': 'High-Speed Wi-Fi 6 Router', 'rate': 3199.00, 'category': 'Electronics'},
    {'name': 'Cat-6 Ethernet Cable (5m)', 'rate': 249.00, 'category': 'Accessories'},
  ];

  @override
  void initState() {
    super.initState();
    _orderNumber = 'ORD-547426';

    // Start with 1 empty item matching reference UI
    _items.add(_SimpleBillItem());

    _customerFocusNode.addListener(() {
      setState(() {
        _isCustomerFocused = _customerFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _customerController.dispose();
    _customerFocusNode.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addNewRow({String name = '', double? rate, int qty = 1}) {
    setState(() {
      final item = _SimpleBillItem(name: name, rate: rate, qty: qty);
      _items.add(item);
    });
  }

  void _removeItem(int index) {
    setState(() {
      if (_items.length > 1) {
        final removed = _items.removeAt(index);
        removed.dispose();
      } else {
        // Reset the single remaining row
        _items[0].nameController.clear();
        _items[0].rateController.clear();
        _items[0].qtyController.text = '1';
      }
    });
  }

  int get _totalQuantity {
    int sum = 0;
    for (final item in _items) {
      sum += item.quantity;
    }
    return sum;
  }

  double get _grandTotal {
    double sum = 0.0;
    for (final item in _items) {
      sum += item.total;
    }
    return sum;
  }

  String _formatCurrency(double amount) {
    if (amount.isNaN || amount.isInfinite || amount < 0) return '0.00';
    final parts = amount.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final regex = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    final formattedWhole = whole.replaceAllMapped(regex, (match) => '${match[1]},');
    return '$formattedWhole.$decimal';
  }

  String _formatNumber(int number) {
    if (number < 0) return '0';
    final str = number.toString();
    final regex = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]},');
  }

  void _openProductDropdown([int? targetRowIndex]) {
    final int rowIndex = targetRowIndex ?? (_items.isNotEmpty ? _items.length - 1 : 0);
    final selectedIndices = <int>{};
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = _catalogProducts.where((p) {
              if (searchQuery.trim().isEmpty) return true;
              final q = searchQuery.toLowerCase();
              final name = (p['name'] as String).toLowerCase();
              final cat = (p['category'] as String).toLowerCase();
              return name.contains(q) || cat.contains(q);
            }).toList();

            final allFilteredSelected = filtered.isNotEmpty &&
                filtered.every((p) => selectedIndices.contains(_catalogProducts.indexOf(p)));

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAFAE3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.boxes,
                              color: Color(0xFF135029),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Products from Records',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Search, select specified products or select all to add to billing records.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search bar
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          autofocus: true,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF94A3B8)),
                                    onPressed: () {
                                      setDialogState(() {
                                        searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            hintText: 'Search products by name or category...',
                            hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              searchQuery = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // "Select All" & Counter Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                setDialogState(() {
                                  if (allFilteredSelected) {
                                    for (final p in filtered) {
                                      selectedIndices.remove(_catalogProducts.indexOf(p));
                                    }
                                  } else {
                                    for (final p in filtered) {
                                      selectedIndices.add(_catalogProducts.indexOf(p));
                                    }
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: allFilteredSelected,
                                    activeColor: const Color(0xFF135029),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          for (final p in filtered) {
                                            selectedIndices.add(_catalogProducts.indexOf(p));
                                          }
                                        } else {
                                          for (final p in filtered) {
                                            selectedIndices.remove(_catalogProducts.indexOf(p));
                                          }
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    'Select All (${filtered.length} products)',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedIndices.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAFAE3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Text(
                                  '${selectedIndices.length} selected',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Product List
                      Flexible(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'No products match your search.',
                                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                itemBuilder: (context, idx) {
                                  final prod = filtered[idx];
                                  final originalIdx = _catalogProducts.indexOf(prod);
                                  final isChecked = selectedIndices.contains(originalIdx);
                                  final double rate = prod['rate'] as double;

                                  return InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        if (isChecked) {
                                          selectedIndices.remove(originalIdx);
                                        } else {
                                          selectedIndices.add(originalIdx);
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isChecked,
                                            activeColor: const Color(0xFF135029),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            onChanged: (val) {
                                              setDialogState(() {
                                                if (val == true) {
                                                  selectedIndices.add(originalIdx);
                                                } else {
                                                  selectedIndices.remove(originalIdx);
                                                }
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  prod['name'] as String,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                                Text(
                                                  prod['category'] as String,
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '₹${_formatCurrency(rate)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13.5,
                                              color: Color(0xFF135029),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 14),

                      // Footer Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569))),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: selectedIndices.isEmpty
                                ? null
                                : () {
                                    Navigator.of(dialogCtx).pop();
                                    final chosen = selectedIndices
                                        .map((i) => _catalogProducts[i])
                                        .toList();
                                    _applySelectedProductsToRecords(
                                      rowIndex: rowIndex,
                                      selectedProducts: chosen,
                                    );
                                  },
                            icon: const Icon(LucideIcons.check, size: 16),
                            label: Text(
                              selectedIndices.isEmpty
                                  ? 'Add to Records'
                                  : 'Add to Records (${selectedIndices.length})',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF135029),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _applySelectedProductsToRecords({
    required int rowIndex,
    required List<Map<String, dynamic>> selectedProducts,
  }) {
    if (selectedProducts.isEmpty) return;

    setState(() {
      // Check if current row is blank
      final bool isCurrentRowBlank = rowIndex >= 0 &&
          rowIndex < _items.length &&
          _items[rowIndex].nameController.text.trim().isEmpty &&
          _items[rowIndex].rateController.text.trim().isEmpty;

      int startIdx = 0;
      if (isCurrentRowBlank) {
        final firstProd = selectedProducts[0];
        _items[rowIndex].nameController.text = firstProd['name'] as String;
        _items[rowIndex].rateController.text =
            (firstProd['rate'] as double).toStringAsFixed(2);
        _items[rowIndex].qtyController.text = '1';
        startIdx = 1;
      }

      // Remaining products are populated into separate records
      // e.g. If 5 products are selected, all 5 appear in separate records!
      for (int i = startIdx; i < selectedProducts.length; i++) {
        final prod = selectedProducts[i];
        final newItem = _SimpleBillItem(
          name: prod['name'] as String,
          rate: prod['rate'] as double,
          qty: 1,
        );
        final int targetPos = rowIndex + (isCurrentRowBlank ? i : i + 1);
        if (targetPos < _items.length) {
          _items.insert(targetPos, newItem);
        } else {
          _items.add(newItem);
        }
      }
    });
  }

  void _submitBill() {
    final rawCustomerName = _customerController.text.trim();
    final customerName =
        rawCustomerName.isNotEmpty ? rawCustomerName : 'Walk-in Customer';

    // Check if at least one item has content
    final validItems = _items
        .where((i) => i.nameController.text.trim().isNotEmpty || i.rate > 0)
        .toList();
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Please add at least one product item with a name or rate.'),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          width: 450,
        ),
      );
      return;
    }

    // Show Bill Generated Confirmation Dialog
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
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
                    'Bill Generated Successfully!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order $_orderNumber for "$customerName" has been registered.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Billing Order #:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            Text(_orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF135029))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Customer Name:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            Text(customerName, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Items / Qty:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            Text('${validItems.length} items (${_formatNumber(_totalQuantity)} pcs)', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                            Text(
                              '₹${_formatCurrency(_grandTotal)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
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
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            ref.read(navigationProvider.notifier).setRoute(AppRoute.billing);
                          },
                          icon: const Icon(LucideIcons.receipt, size: 16),
                          label: const Text('View All Bills'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF334155),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            setState(() {
                              _customerController.clear();
                              for (final item in _items) {
                                item.dispose();
                              }
                              _items.clear();
                              _items.add(_SimpleBillItem());
                              // Generate new order number
                              final nextNum = int.parse(_orderNumber.replaceAll('ORD-', '')) + 1;
                              _orderNumber = 'ORD-$nextNum';
                            });
                          },
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('New Bill'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF135029),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 860;

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              left: isCompact ? 16 : 32,
              right: isCompact ? 16 : 32,
              top: 32,
              bottom: 48,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // ─── 1. EYEBROW & HEADER ───
                    _buildHeader(isCompact),

                    const SizedBox(height: 24),

                    // ─── 2. ORDER # & CUSTOMER NAME FIELDS ───
                    _buildOrderAndCustomerFields(isCompact),

                    const SizedBox(height: 24),

                    // ─── 3. PRODUCT ITEMS SECTION ───
                    _buildProductItemsSection(isCompact),

                    const SizedBox(height: 24),

                    // ─── 4. SUMMARY BAR & SUBMIT ACTION ───
                    _buildSummaryBar(isCompact),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag / Eyebrow Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            border: Border.all(color: const Color(0xFFBBF7D0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.receiptText,
                color: Color(0xFF166534),
                size: 13,
              ),
              SizedBox(width: 6),
              Text(
                'SIMPLE BILLING SYSTEM',
                style: TextStyle(
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Simple Billing',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Create instant point-of-sale customer bills with line-item accuracy.',
          style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 14),
          _buildViewRecordsButton(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titleSection),
        const SizedBox(width: 16),
        _buildViewRecordsButton(),
      ],
    );
  }

  Widget _buildViewRecordsButton() {
    return InkWell(
      onTap: () {
        ref.read(navigationProvider.notifier).setRoute(AppRoute.billing);
      },
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.history, size: 15, color: Color(0xFF166534)),
            SizedBox(width: 8),
            Text(
              'View All Bills',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(LucideIcons.arrowUpRight, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderAndCustomerFields(bool isCompact) {
    final orderField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(LucideIcons.receipt, size: 14, color: Color(0xFF166534)),
            SizedBox(width: 6),
            Text(
              'BILLING ORDER #',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 46,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            border: Border.all(color: const Color(0xFFBBF7D0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _orderNumber,
                style: const TextStyle(
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 11, color: Color(0xFF166534)),
                    SizedBox(width: 4),
                    Text(
                      'Auto-generated',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final customerField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(LucideIcons.user, size: 14, color: Color(0xFF64748B)),
            SizedBox(width: 6),
            Text(
              'CUSTOMER NAME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF475569),
              ),
            ),
            SizedBox(width: 6),
            Text(
              '(Optional)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _isCustomerFocused
                  ? const Color(0xFF166534)
                  : const Color(0xFFCBD5E1),
              width: _isCustomerFocused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _customerController,
            focusNode: _customerFocusNode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(80),
            ],
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.user, size: 15, color: Color(0xFF94A3B8)),
              suffixIcon: _customerController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF94A3B8)),
                      splashRadius: 14,
                      onPressed: () {
                        setState(() {
                          _customerController.clear();
                        });
                      },
                    )
                  : null,
              hintText: 'Enter Customer Name (or leave blank for Walk-in)',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );

    final content = isCompact
        ? Column(
            children: [
              orderField,
              const SizedBox(height: 16),
              customerField,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: orderField),
              const SizedBox(width: 20),
              Expanded(child: customerField),
            ],
          );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildProductItemsSection(bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFAE3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.package, size: 16, color: Color(0xFF166534)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Product Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_items.length} ${_items.length == 1 ? 'record' : 'records'}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Product Items Table with horizontal overflow protection
          LayoutBuilder(
            builder: (context, constraints) {
              const double minTableWidth = 750.0;
              if (constraints.maxWidth < minTableWidth) {
                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: minTableWidth,
                      child: _buildItemsTable(),
                    ),
                  ),
                );
              }
              return _buildItemsTable();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Column(
      children: [
        // Column Headers Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'PRODUCT NAME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  'SELLING RATE (₹)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  'QUANTITY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // ADD Column Header
              SizedBox(
                width: 44,
                child: Center(
                  child: Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'AUTOMATIC TOTAL (₹)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // ACTION Column Header (56px width so it NEVER wraps)
              SizedBox(
                width: 56,
                child: Center(
                  child: Text(
                    'ACTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Item Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = _items[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                // Product Name Field with Dropdown
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: item.nameController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                            decoration: const InputDecoration(
                              hintText: 'Product Name (e.g. Wireless Mouse)',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Tooltip(
                          message: 'Choose from product records',
                          child: InkWell(
                            onTap: () => _openProductDropdown(index),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              child: const Icon(
                                LucideIcons.chevronDown,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Selling Rate Field (constrained to 12 digits + 2 decimals)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: item.rateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,12}(\.\d{0,2})?')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 10, right: 6),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 0),
                        hintText: '0.00',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Quantity Field (constrained to 12 digits, digits only)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: item.qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: const InputDecoration(
                        hintText: '1',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Add Record Icon Button between Quantity and Automatic Total
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Tooltip(
                      message: 'Add New Record',
                      child: InkWell(
                        onTap: _addNewRow,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAFAE3),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF166534).withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.plus,
                            size: 17,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Automatic Total Text
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 44,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '₹${_formatCurrency(item.total)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF135029),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Trash Action Button
                SizedBox(
                  width: 56,
                  height: 44,
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 17, color: Color(0xFF94A3B8)),
                        hoverColor: const Color(0xFFFEE2E2),
                        splashRadius: 18,
                        tooltip: 'Remove Item',
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ],
    );
  }

  Widget _buildSummaryBar(bool isCompact) {
    final qtySection = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.layers, size: 18, color: Color(0xFF475569)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL QUANTITY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_formatNumber(_totalQuantity)} ',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const TextSpan(
                    text: 'items',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    final grandTotalSection = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEAFAE3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.receipt, size: 18, color: Color(0xFF166534)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GRAND TOTAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '₹${_formatCurrency(_grandTotal)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF135029),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );

    final submitButton = InkWell(
      onTap: _submitBill,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF135029),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF135029).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Submit Bill',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                qtySection,
                grandTotalSection,
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: submitButton,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          qtySection,
          const SizedBox(width: 44),
          grandTotalSection,
          const Spacer(),
          submitButton,
        ],
      ),
    );
  }
}
