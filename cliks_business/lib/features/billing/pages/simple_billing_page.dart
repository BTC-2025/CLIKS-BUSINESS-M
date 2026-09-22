import 'package:flutter/material.dart';
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
        qtyController = TextEditingController(text: qty.toString());

  double get rate => double.tryParse(rateController.text.trim()) ?? 0.0;
  int get quantity => int.tryParse(qtyController.text.trim()) ?? 0;
  double get total => rate * quantity;

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
  bool _showCustomerError = false;
  bool _isCustomerFocused = false;

  // Catalog for quick multi-select
  final List<Map<String, dynamic>> _catalogProducts = [
    {'name': 'Wireless Optical Mouse', 'rate': 499.00, 'category': 'Electronics'},
    {'name': 'Mechanical RGB Keyboard', 'rate': 2499.00, 'category': 'Electronics'},
    {'name': 'USB-C Fast Charging Cable (1.5m)', 'rate': 299.00, 'category': 'Accessories'},
    {'name': '27" 4K UHD IPS Monitor', 'rate': 18999.00, 'category': 'Electronics'},
    {'name': 'Ergonomic Office Swivel Chair', 'rate': 6499.00, 'category': 'Furniture'},
    {'name': 'Laptop Aluminum Stand', 'rate': 899.00, 'category': 'Accessories'},
    {'name': 'Noise Cancelling Headphones', 'rate': 3999.00, 'category': 'Audio'},
    {'name': 'Thermal Receipt Paper Roll (Pack of 10)', 'rate': 350.00, 'category': 'Supplies'},
  ];

  @override
  void initState() {
    super.initState();
    _orderNumber = 'ORD-547426';

    // Start with 1 empty item matching reference UI
    _items.add(_SimpleBillItem());

    _customerController.addListener(() {
      if (_showCustomerError && _customerController.text.trim().isNotEmpty) {
        setState(() {
          _showCustomerError = false;
        });
      }
    });

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

  void _openMultiProductDialog() {
    final selectedIndices = <int>{};

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580, maxHeight: 600),
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
                                  'Add Multiple Products',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Select products from inventory to quickly populate your bill.',
                                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
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
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _catalogProducts.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, idx) {
                            final prod = _catalogProducts[idx];
                            final isChecked = selectedIndices.contains(idx);
                            final double rate = prod['rate'] as double;

                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  if (isChecked) {
                                    selectedIndices.remove(idx);
                                  } else {
                                    selectedIndices.add(idx);
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
                                            selectedIndices.add(idx);
                                          } else {
                                            selectedIndices.remove(idx);
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
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          Text(
                                            prod['category'] as String,
                                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₹${rate.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Color(0xFF475569))),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: selectedIndices.isEmpty
                                ? null
                                : () {
                                    Navigator.of(dialogCtx).pop();
                                    setState(() {
                                      // If initial row is untouched, overwrite it
                                      bool usedFirst = false;
                                      if (_items.length == 1 &&
                                          _items[0].nameController.text.trim().isEmpty &&
                                          _items[0].rateController.text.trim().isEmpty) {
                                        usedFirst = true;
                                      }

                                      int count = 0;
                                      for (final idx in selectedIndices) {
                                        final itemData = _catalogProducts[idx];
                                        if (count == 0 && usedFirst) {
                                          _items[0].nameController.text = itemData['name'] as String;
                                          _items[0].rateController.text =
                                              (itemData['rate'] as double).toStringAsFixed(2);
                                          _items[0].qtyController.text = '1';
                                        } else {
                                          _addNewRow(
                                            name: itemData['name'] as String,
                                            rate: itemData['rate'] as double,
                                            qty: 1,
                                          );
                                        }
                                        count++;
                                      }
                                    });
                                  },
                            icon: const Icon(LucideIcons.check, size: 16),
                            label: Text(
                              selectedIndices.isEmpty
                                  ? 'Add Selected'
                                  : 'Add Selected (${selectedIndices.length})',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF135029),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  void _submitBill() {
    final customerName = _customerController.text.trim();

    if (customerName.isEmpty) {
      setState(() {
        _showCustomerError = true;
      });
      _customerFocusNode.requestFocus();
      return;
    }

    setState(() {
      _showCustomerError = false;
    });

    // Check if at least one item has content
    final validItems = _items.where((i) => i.nameController.text.trim().isNotEmpty || i.rate > 0).toList();
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
                            Text('${validItems.length} items (${_totalQuantity} pcs)', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                            Text(
                              '₹${_grandTotal.toStringAsFixed(2)}',
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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 800;

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 16 : 36,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── 1. EYEBROW & HEADER ───
                _buildHeader(isCompact),

                const SizedBox(height: 24),

                // ─── 2. ORDER # & CUSTOMER NAME FIELDS ───
                _buildOrderAndCustomerFields(isCompact),

                const SizedBox(height: 28),

                // ─── 3. PRODUCT ITEMS SECTION ───
                _buildProductItemsSection(isCompact),

                const SizedBox(height: 32),

                // ─── 4. SUMMARY BAR & SUBMIT ACTION ───
                _buildSummaryBar(isCompact),

                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag / Eyebrow
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: const Color(0xFFEAFAE3),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFFD4EED1)),
              ),
              child: const Icon(
                LucideIcons.receiptText,
                color: Color(0xFF135029),
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'BILLING MODULE',
              style: TextStyle(
                color: Color(0xFF135029),
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Main Title Row
        if (isCompact) ...[
          const Text(
            'Simple Billing',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Generate quick bills, add multiple items, and keep track of your customer sales.',
            style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          _buildViewRecordsButton(),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simple Billing',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Generate quick bills, add multiple items, and keep track of your customer sales.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildViewRecordsButton(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildViewRecordsButton() {
    return InkWell(
      onTap: () {
        ref.read(navigationProvider.notifier).setRoute(AppRoute.billing);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View Billing Records',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(LucideIcons.arrowRight, size: 15, color: Color(0xFF64748B)),
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
            Icon(LucideIcons.receiptText, size: 14, color: Color(0xFF135029)),
            SizedBox(width: 6),
            Text(
              'BILLING ORDER # ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              '*',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAFAE3).withValues(alpha: 0.6),
            border: Border.all(color: const Color(0xFFBBF7D0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _orderNumber,
            style: const TextStyle(
              color: Color(0xFF166534),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
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
              'CUSTOMER NAME ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              '*',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _showCustomerError
                      ? const Color(0xFFDC2626)
                      : (_isCustomerFocused
                          ? const Color(0xFF166534)
                          : const Color(0xFFCBD5E1)),
                  width: (_showCustomerError || _isCustomerFocused) ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _customerController,
                focusNode: _customerFocusNode,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  hintText: 'Enter Customer Name (e.g. John Doe / Sharma Enterprises)',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),

            // Popover validation tooltip matching screenshot exactly with arrow pointer
            if (_showCustomerError)
              Positioned(
                top: 50,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: CustomPaint(
                        size: const Size(12, 6),
                        painter: _TrianglePainter(),
                      ),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(6),
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                LucideIcons.alertTriangle,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Please fill in this field.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
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
      ],
    );

    if (isCompact) {
      return Column(
        children: [
          orderField,
          const SizedBox(height: 16),
          customerField,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: orderField),
        const SizedBox(width: 24),
        Expanded(child: customerField),
      ],
    );
  }

  Widget _buildProductItemsSection(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.package, size: 18, color: Color(0xFF166534)),
                SizedBox(width: 8),
                Text(
                  'Product Items',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: _openMultiProductDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, size: 14, color: Color(0xFF166534)),
                    SizedBox(width: 4),
                    Text(
                      'Add Multiple Products',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Product Items Table with horizontal overflow protection
        LayoutBuilder(
          builder: (context, constraints) {
            const double minTableWidth = 680.0;
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

        const SizedBox(height: 16),

        // Add Multiple Products Dotted/Dashed Row matching screenshot
        InkWell(
          onTap: () => _addNewRow(),
          borderRadius: BorderRadius.circular(8),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: const Color(0xFF86EFAC),
              strokeWidth: 1.2,
              dashWidth: 5.0,
              dashSpace: 4.0,
              borderRadius: 8.0,
            ),
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FDF9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.plus, size: 16, color: Color(0xFF166534)),
                  SizedBox(width: 6),
                  Text(
                    'Add Multiple Products',
                    style: TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Column(
      children: [
        // Column Headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              const Expanded(
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
              const SizedBox(width: 12),
              const Expanded(
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
              const SizedBox(width: 12),
              const Expanded(
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
              const SizedBox(width: 12),
              const Expanded(
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
              const SizedBox(width: 12),
              const SizedBox(
                width: 44,
                child: Center(
                  child: Text(
                    'ACTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Item Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = _items[index];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Name Field
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: item.nameController,
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
                ),

                const SizedBox(width: 12),

                // Selling Rate Field
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
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Quantity Field
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

                // Automatic Total Text
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 44,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '₹${item.total.toStringAsFixed(2)}',
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
                  width: 44,
                  height: 44,
                  child: IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 17, color: Color(0xFF94A3B8)),
                    hoverColor: const Color(0xFFFEE2E2),
                    splashRadius: 18,
                    tooltip: 'Remove Item',
                    onPressed: () => _removeItem(index),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBar(bool isCompact) {
    final qtySection = Column(
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
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$_totalQuantity ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const TextSpan(
                text: 'items',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final grandTotalSection = Column(
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
        const SizedBox(height: 4),
        Text(
          '₹${_grandTotal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF135029),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );

    final submitButton = InkWell(
      onTap: _submitBill,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF135029),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF135029).withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Submit Bill',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: submitButton,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          qtySection,
          const SizedBox(width: 48),
          grandTotalSection,
          const Spacer(),
          submitButton,
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  _DashedBorderPainter({
    this.color = const Color(0xFF86EFAC),
    this.strokeWidth = 1.2,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.borderRadius != borderRadius;
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
