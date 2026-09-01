import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';

class NewSalesOrderPage extends ConsumerStatefulWidget {
  const NewSalesOrderPage({super.key});

  @override
  ConsumerState<NewSalesOrderPage> createState() => _NewSalesOrderPageState();
}

class _NewSalesOrderPageState extends ConsumerState<NewSalesOrderPage> {
  final _customerController = TextEditingController();
  final _phoneController = TextEditingController(text: '9876543210');
  final _gstinController = TextEditingController(text: '07AAAAA1111A1Z1');
  final _billingController = TextEditingController();
  final _shippingController = TextEditingController();
  final _advanceController = TextEditingController();
  final _shippingChargeController = TextEditingController();

  String _status = 'Draft';
  DateTime _orderDate = DateTime.now();
  DateTime? _dueDate;

  final List<Map<String, dynamic>> _items = [
    {'product': '', 'qty': '1', 'rate': '0', 'tax': '18% GST'},
  ];

  @override
  void dispose() {
    _customerController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _billingController.dispose();
    _shippingController.dispose();
    _advanceController.dispose();
    _shippingChargeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isOrder) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isOrder ? _orderDate : (_dueDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF7C3AED),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isOrder) {
          _orderDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'dd - mm - yyyy';
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 800,
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── HEADER ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'New Sales Order',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Order No: SO-${DateTime.now().millisecondsSinceEpoch % 900000 + 100000}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _statusChip(),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.sales),
                          icon: const Icon(LucideIcons.x, size: 18, color: Colors.black54),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── BODY (scrollable) ─────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer info card
                          _card(
                            title: 'Customer Details',
                            icon: LucideIcons.user,
                            children: [
                              _lbl('Customer Name'),
                              _tf(_customerController, 'Search or select customer...'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _lbl('Phone'),
                                        _tf(_phoneController, '9876543210'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _lbl('GSTIN (Optional)'),
                                        _tf(_gstinController, '07AAAAA...'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _lbl('Billing Address'),
                              _tf(_billingController, 'Street, City, State...', maxLines: 2),
                              const SizedBox(height: 10),
                              _lbl('Shipping Address'),
                              _tf(_shippingController, 'Same as billing or different...', maxLines: 2),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Order date card
                          _card(
                            title: 'Order Info',
                            icon: LucideIcons.calendar,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _lbl('Order Date'),
                                        _datePicker(
                                          value: _fmtDate(_orderDate),
                                          onTap: () => _pickDate(true),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _lbl('Delivery Due Date'),
                                        _datePicker(
                                          value: _fmtDate(_dueDate),
                                          onTap: () => _pickDate(false),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _lbl('Order Status'),
                              _dropdown(
                                value: _status,
                                items: ['Draft', 'Confirmed', 'Processing', 'Shipped', 'Delivered'],
                                onChanged: (v) => setState(() => _status = v!),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Items card
                          _card(
                            title: 'Order Items',
                            icon: LucideIcons.shoppingCart,
                            children: [
                              // Items header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F0FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(flex: 3, child: Text('Product', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9)))),
                                    Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9)), textAlign: TextAlign.center)),
                                    Expanded(flex: 2, child: Text('Tax', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9)), textAlign: TextAlign.center)),
                                    Expanded(flex: 2, child: Text('Total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9)), textAlign: TextAlign.right)),
                                    SizedBox(width: 24),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              ..._items.asMap().entries.map((e) => _itemRow(e.key)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _items.add({'product': '', 'qty': '1', 'rate': '0', 'tax': '18% GST'});
                                }),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF7C3AED), width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xFFF5F3FF),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.plus, size: 13, color: Color(0xFF7C3AED)),
                                      SizedBox(width: 4),
                                      Text('Add Product', style: TextStyle(fontSize: 12, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Payment & totals card
                          _card(
                            title: 'Payment & Summary',
                            icon: LucideIcons.indianRupee,
                            children: [
                              _lbl('Advance Amount Received (₹)'),
                              _tf(_advanceController, '0.00'),
                              const SizedBox(height: 10),
                              _lbl('Shipping / Delivery Charge (₹)'),
                              _tf(_shippingChargeController, '0.00'),
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              const SizedBox(height: 12),
                              _summaryRow('Subtotal', '₹ 0.00'),
                              _summaryRow('Total Discount', '- ₹ 0.00', red: true),
                              _summaryRow('Total Tax (GST)', '₹ 0.00'),
                              _summaryRow('Shipping Charge', '₹ 0.00'),
                              const SizedBox(height: 8),
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Grand Total',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                  ),
                                  Text(
                                    '₹ 0.00',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.sales),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                                    foregroundColor: const Color(0xFF6B7280),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.sales),
                                  icon: const Icon(LucideIcons.checkCircle, size: 15),
                                  label: const Text('Create Sales Order', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C3AED),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
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

  Widget _statusChip() {
    final colors = {
      'Draft': const Color(0xFF6B7280),
      'Confirmed': const Color(0xFF059669),
      'Processing': const Color(0xFFF59E0B),
      'Shipped': const Color(0xFF3B82F6),
      'Delivered': const Color(0xFF10B981),
    };
    return GestureDetector(
      onTap: () {
        final list = ['Draft', 'Confirmed', 'Processing', 'Shipped', 'Delivered'];
        final next = list[(list.indexOf(_status) + 1) % list.length];
        setState(() => _status = next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: (colors[_status] ?? Colors.grey).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors[_status] ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              _status,
              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 13, color: const Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _lbl(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 2),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.4),
      ),
    );
  }

  Widget _tf(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC1C7D0), fontSize: 12),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFE5EAF4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFE5EAF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
      ),
    );
  }

  Widget _datePicker({required String value, required VoidCallback onTap}) {
    final isPlaceholder = value.contains('dd');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE5EAF4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isPlaceholder ? const Color(0xFFC1C7D0) : const Color(0xFF1F2937),
              ),
            ),
            const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE5EAF4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF7C3AED)),
          items: items.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w500)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _itemRow(int index) {
    final item = _items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFFE5EAF4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.search, size: 12, color: Color(0xFF9CA3AF)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '-- Select Product --',
                          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(LucideIcons.chevronDown, size: 10, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _items.removeAt(index)),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(LucideIcons.x, size: 13, color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _miniField('Qty', item['qty'] as String),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _miniField('Rate (₹)', item['rate'] as String),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFFE5EAF4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: item['tax'] as String,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 10, color: Color(0xFF9CA3AF)),
                      items: ['0% GST', '5% GST', '12% GST', '18% GST', '28% GST'].map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFF1F2937))),
                      )).toList(),
                      onChanged: (v) => setState(() => _items[index]['tax'] = v!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text('₹ 0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniField(String hint, String value) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE5EAF4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(hint, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool red = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: red ? const Color(0xFFEF4444) : const Color(0xFF1F2937)),
          ),
        ],
      ),
    );
  }
}
