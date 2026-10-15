import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../widgets/modals/invoice_settings_modal.dart';
import '../providers/invoice_settings_provider.dart';

class NewInvoicePage extends ConsumerStatefulWidget {
  const NewInvoicePage({super.key});

  @override
  ConsumerState<NewInvoicePage> createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends ConsumerState<NewInvoicePage> {
  bool _livePreview = false;
  String _invoiceNo = 'INV-918366';
  String _invoiceType = 'GST';
  String _invoiceStatus = 'Unpaid';
  String _paymentMode = 'Cash';
  String _selectedBank = '-- Select Bank Account --';
  final String _terms = 'Due on Receipt';
  final DateTime _dueDate = DateTime.now();

  // Client Details
  final TextEditingController _clientNameController =
      TextEditingController(text: 'Cash Customer');
  final TextEditingController _clientEmailController =
      TextEditingController(text: 'cash@customer.local');
  final TextEditingController _clientGstinController = TextEditingController();
  final TextEditingController _customerPoController =
      TextEditingController(text: 'PO-12345');
  final TextEditingController _billingAddressController =
      TextEditingController();
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final TextEditingController _paidAmountController =
      TextEditingController(text: '0');
  final TextEditingController _dueAmountController =
      TextEditingController(text: '0');

  final List<Map<String, dynamic>> _items = [
    {
      'desc': '',
      'hsn': '',
      'qty': 1,
      'unit': 'Pcs',
      'price': 0.0,
      'disc': 0.0,
      'gst': '18%',
    }
  ];

  void _addItem() {
    setState(() {
      _items.add({
        'desc': '',
        'hsn': '',
        'qty': 1,
        'unit': 'Pcs',
        'price': 0.0,
        'disc': 0.0,
        'gst': '18%',
      });
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
      });
    }
  }

  double get _subtotal {
    double total = 0;
    for (var item in _items) {
      double qty = double.tryParse(item['qty'].toString()) ?? 0;
      double price = double.tryParse(item['price'].toString()) ?? 0;
      total += qty * price;
    }
    return total;
  }

  double get _discount {
    double total = 0;
    for (var item in _items) {
      double qty = double.tryParse(item['qty'].toString()) ?? 0;
      double price = double.tryParse(item['price'].toString()) ?? 0;
      double disc = double.tryParse(item['disc'].toString()) ?? 0;
      total += (qty * price) * (disc / 100);
    }
    return total;
  }

  double get _gstAmount {
    double total = 0;
    for (var item in _items) {
      double qty = double.tryParse(item['qty'].toString()) ?? 0;
      double price = double.tryParse(item['price'].toString()) ?? 0;
      double disc = double.tryParse(item['disc'].toString()) ?? 0;
      double itemSub = (qty * price) - ((qty * price) * (disc / 100));
      double gstRate = double.tryParse(item['gst'].toString().replaceAll('%', '')) ?? 0;
      total += itemSub * (gstRate / 100);
    }
    return total;
  }

  double get _total => _subtotal - _discount + _gstAmount;

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientGstinController.dispose();
    _customerPoController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _paidAmountController.dispose();
    _dueAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Invoice Info Fields (Row 1)
        _buildInvoiceDetailsForm(screenWidth),
        const SizedBox(height: 20),

        // Client details (Row 2)
        _buildClientDetailsForm(screenWidth),
        const SizedBox(height: 20),

        // Shipping Address (Row 3)
        _buildShippingAddressForm(),
        const SizedBox(height: 28),

        // Invoice Items section
        _buildInvoiceItemsSection(screenWidth),
        const SizedBox(height: 28),

        // Payment & Totals
        _buildPaymentAndTotalsSection(screenWidth),
        const SizedBox(height: 28),

        // Bottom Action buttons (Cancel & Generate & Save Invoice)
        _buildBottomActionRow(),
      ],
    );

    final previewColumn = _buildLivePreviewCard(isMobile);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12.0 : 24.0,
            vertical: isMobile ? 12.0 : 20.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isMobile),
                    const SizedBox(height: 24),
                    if (_livePreview && !isMobile)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 11, child: formColumn),
                          const SizedBox(width: 28),
                          Expanded(flex: 9, child: previewColumn),
                        ],
                      )
                    else ...[
                      formColumn,
                      if (_livePreview) ...[
                        const SizedBox(height: 32),
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 24),
                        previewColumn,
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBackButton(),
              const Spacer(),
              _buildCloseButton(),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              const Text(
                'New Invoice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              _buildInvoiceBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSettingsButton(),
              _buildLivePreviewButton(),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        _buildBackButton(),
        const SizedBox(width: 14),
        const Text(
          'New Invoice',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 10),
        _buildInvoiceBadge(),
        const Spacer(),
        _buildSettingsButton(),
        const SizedBox(width: 10),
        _buildLivePreviewButton(),
        const SizedBox(width: 10),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () {
        ref.read(navigationProvider.notifier).setRoute(AppRoute.billing);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.arrowLeft, size: 14, color: Color(0xFF475569)),
            SizedBox(width: 6),
            Text(
              'Back to Invoices',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE7F3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _invoiceNo,
        style: const TextStyle(
          color: Color(0xFFBE123C),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black45,
          builder: (ctx) => const InvoiceSettingsModal(),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.settings, size: 14, color: Color(0xFF475569)),
            SizedBox(width: 6),
            Text(
              'Settings',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewButton() {
    return InkWell(
      onTap: () => setState(() => _livePreview = !_livePreview),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _livePreview ? const Color(0xFFEDE9FE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _livePreview ? const Color(0xFFC4B5FD) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _livePreview ? LucideIcons.eye : LucideIcons.eyeOff,
              size: 14,
              color: _livePreview ? const Color(0xFF6D28D9) : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              'Live Preview Mode',
              style: TextStyle(
                color: _livePreview ? const Color(0xFF6D28D9) : const Color(0xFF334155),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return InkWell(
      onTap: () {
        ref.read(navigationProvider.notifier).setRoute(AppRoute.billing);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Icon(
          LucideIcons.x,
          size: 15,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailsForm(double screenWidth) {
    final settings = ref.watch(invoiceSettingsProvider);
    final typeOptions = settings.invoiceTypes.contains(_invoiceType)
        ? settings.invoiceTypes
        : [...settings.invoiceTypes, _invoiceType];
    final statusOptions = settings.invoiceStatuses.contains(_invoiceStatus)
        ? settings.invoiceStatuses
        : [...settings.invoiceStatuses, _invoiceStatus];

    final invoiceNoField = _buildInputField(
      label: 'INVOICE #',
      child: TextFormField(
        initialValue: _invoiceNo,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        decoration: _inputDecoration().copyWith(
          fillColor: const Color(0xFFF8FAFC),
        ),
        onChanged: (val) => setState(() => _invoiceNo = val),
      ),
    );

    final typeField = _buildInputField(
      label: 'TYPE',
      child: DropdownButtonFormField<String>(
        initialValue: typeOptions.contains(_invoiceType) ? _invoiceType : typeOptions.first,
        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w500),
        icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
        decoration: _inputDecoration(),
        items: typeOptions
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (val) => setState(() => _invoiceType = val!),
      ),
    );

    final statusField = _buildInputField(
      label: 'STATUS',
      child: DropdownButtonFormField<String>(
        initialValue: statusOptions.contains(_invoiceStatus)
            ? _invoiceStatus
            : statusOptions.first,
        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w500),
        icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
        decoration: _inputDecoration(),
        items: statusOptions
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (val) => setState(() => _invoiceStatus = val!),
      ),
    );

    if (screenWidth < 750) {
      return Column(
        children: [
          invoiceNoField,
          const SizedBox(height: 12),
          typeField,
          const SizedBox(height: 12),
          statusField,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: invoiceNoField),
        const SizedBox(width: 16),
        Expanded(child: typeField),
        const SizedBox(width: 16),
        Expanded(child: statusField),
      ],
    );
  }

  Widget _buildClientDetailsForm(double screenWidth) {
    final nameField = _buildInputField(
      label: 'CLIENT NAME',
      child: TextFormField(
        controller: _clientNameController,
        decoration: _inputDecoration(hint: 'Cash Customer'),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        onChanged: (val) => setState(() {}),
      ),
    );

    final emailField = _buildInputField(
      label: 'CLIENT EMAIL',
      child: TextFormField(
        controller: _clientEmailController,
        decoration: _inputDecoration(hint: 'cash@customer.local'),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        onChanged: (val) => setState(() {}),
      ),
    );

    final gstinField = _buildInputField(
      label: 'CLIENT GSTIN',
      child: TextFormField(
        controller: _clientGstinController,
        decoration: _inputDecoration(hint: 'Optional'),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        onChanged: (val) => setState(() {}),
      ),
    );

    final poField = _buildInputField(
      label: 'CUSTOMER P.O. NO.',
      child: TextFormField(
        controller: _customerPoController,
        decoration: _inputDecoration(hint: 'PO-12345'),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        onChanged: (val) => setState(() {}),
      ),
    );

    if (screenWidth < 650) {
      return Column(
        children: [
          nameField,
          const SizedBox(height: 12),
          emailField,
          const SizedBox(height: 12),
          gstinField,
          const SizedBox(height: 12),
          poField,
        ],
      );
    }

    if (screenWidth < 1050) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: nameField),
              const SizedBox(width: 16),
              Expanded(child: emailField),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: gstinField),
              const SizedBox(width: 16),
              Expanded(child: poField),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: nameField),
        const SizedBox(width: 16),
        Expanded(child: emailField),
        const SizedBox(width: 16),
        Expanded(child: gstinField),
        const SizedBox(width: 16),
        Expanded(child: poField),
      ],
    );
  }

  Widget _buildShippingAddressForm() {
    return _buildInputField(
      label: 'SHIPPING ADDRESS',
      child: TextFormField(
        controller: _shippingAddressController,
        minLines: 2,
        maxLines: 3,
        decoration: _inputDecoration(hint: 'Enter shipping address...'),
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        onChanged: (val) => setState(() {}),
      ),
    );
  }

  Widget _buildInvoiceItemsSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                const Text(
                  'Invoice Items',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Container(
                  width: screenWidth < 450 ? 150 : 200,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.search, size: 14, color: Color(0xFF94A3B8)),
                      SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Quick Scan / Barcode',
                            hintStyle: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // + Add Item Button (Pink outline as in screenshot)
            InkWell(
              onTap: _addItem,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFBCFE8)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, size: 14, color: Color(0xFFBE185D)),
                    SizedBox(width: 4),
                    Text(
                      'Add Item',
                      style: TextStyle(
                        color: Color(0xFFBE185D),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Items table with horizontal scroll protection to avoid any overflow
        LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double descWidth = (availableWidth - 360).clamp(240.0, 700.0);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: availableWidth),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {
                    0: FixedColumnWidth(descWidth), // Description
                    1: const FixedColumnWidth(85),  // HSN
                    2: const FixedColumnWidth(65),  // QTY
                    3: const FixedColumnWidth(85),  // UNIT
                    4: const FixedColumnWidth(85),  // PRICE (₹)
                    5: const FixedColumnWidth(40),  // Delete
                  },
                  children: [
                    TableRow(
                      children: [
                        _buildTableHeader('DESCRIPTION'),
                        _buildTableHeader('HSN'),
                        _buildTableHeader('QTY'),
                        _buildTableHeader('UNIT'),
                        _buildTableHeader('PRICE (₹)'),
                        const SizedBox.shrink(),
                      ],
                    ),
                    ...List.generate(_items.length, (index) {
                      final item = _items[index];
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: TextFormField(
                              initialValue: item['desc'],
                              decoration: _tableInputDecoration(),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                              onChanged: (val) {
                                item['desc'] = val;
                                setState(() {});
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: TextFormField(
                              initialValue: item['hsn'],
                              decoration: _tableInputDecoration(),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                              onChanged: (val) {
                                item['hsn'] = val;
                                setState(() {});
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: TextFormField(
                              initialValue: item['qty'].toString(),
                              decoration: _tableInputDecoration(),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                setState(() {
                                  item['qty'] = int.tryParse(val) ?? 1;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: Builder(
                              builder: (context) {
                                final settings = ref.watch(invoiceSettingsProvider);
                                final unitVal = item['unit'].toString();
                                final unitOpts = settings.unitsList.contains(unitVal)
                                    ? settings.unitsList
                                    : [...settings.unitsList, unitVal];
                                return DropdownButtonFormField<String>(
                                  initialValue: unitOpts.contains(unitVal)
                                      ? unitVal
                                      : unitOpts.first,
                                  isExpanded: true,
                                  icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                                  decoration: _tableInputDecoration(),
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                                  items: unitOpts
                                      .map((u) => DropdownMenuItem(
                                            value: u,
                                            child: Text(
                                              u,
                                              style: const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      item['unit'] = val;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: TextFormField(
                              initialValue: item['price'].toString().replaceAll('.0', ''),
                              decoration: _tableInputDecoration(),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                setState(() {
                                  item['price'] = double.tryParse(val) ?? 0.0;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444), size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
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

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPaymentAndTotalsSection(double screenWidth) {
    final paymentModes = ['Cash', 'UPI', 'Bank', 'Credit'];

    final paymentPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT MODE',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: paymentModes.map((mode) {
            final isSelected = _paymentMode == mode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => setState(() => _paymentMode = mode),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      mode,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_paymentMode == 'Bank') ...[
          const SizedBox(height: 14),
          _buildInputField(
            label: 'SELECT BANK ACCOUNT',
            child: DropdownButtonFormField<String>(
              initialValue: _selectedBank,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
              decoration: _inputDecoration(),
              items: ['-- Select Bank Account --', 'HDFC Bank - 501002...', 'SBI - 302919...']
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedBank = val!),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                label: 'PAID AMOUNT (₹)',
                child: TextFormField(
                  controller: _paidAmountController,
                  decoration: _inputDecoration(),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildInputField(
                label: 'DUE AMOUNT (₹)',
                child: TextFormField(
                  controller: _dueAmountController,
                  decoration: _inputDecoration(),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final totalsPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalRow('Subtotal:', '₹ ${_subtotal.toStringAsFixed(0)}'),
        const SizedBox(height: 6),
        _buildTotalRow('Total Discount:', '- ₹ ${_discount.toStringAsFixed(0)}', isDiscount: true),
        const SizedBox(height: 6),
        _buildTotalRow('GST Amount:', '₹ ${_gstAmount.toStringAsFixed(0)}'),
        const SizedBox(height: 6),
        _buildTotalRow('Round Off:', '₹ 0.00'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '₹ ${_total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Green Loyalty / Points banner matching screenshot
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  '🎉 Points to earn this bill: 0 pts',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (screenWidth < 900) {
      return Column(
        children: [
          paymentPanel,
          const SizedBox(height: 24),
          totalsPanel,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 11, child: paymentPanel),
        const SizedBox(width: 40),
        Expanded(flex: 9, child: totalsPanel),
      ],
    );
  }

  Widget _buildTotalRow(String label, String val, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        Text(
          val,
          style: TextStyle(
            color: isDiscount ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionRow() {
    return Row(
      children: [
        // Cancel Button
        InkWell(
          onTap: () {
            ref.read(navigationProvider.notifier).setRoute(AppRoute.billing);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Generate & Save Invoice Button (Purple)
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                AppSnackbar.show(
                  context,
                  "Invoice $_invoiceNo saved & generated successfully!",
                  type: SnackType.success,
                );
                ref.read(navigationProvider.notifier).setRoute(AppRoute.billing);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Generate & Save Invoice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({double? width, required String label, required Widget child}) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: col,
      );
    }
    return col;
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
    );
  }

  InputDecoration _tableInputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.2),
      ),
    );
  }

  Widget _buildLivePreviewCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
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
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'r',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RAVIKUMARLAPTOP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Global Solutions Enterprise',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'GSTIN: ${_clientGstinController.text.isNotEmpty ? _clientGstinController.text : "N/A"}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const Text(
                            'EMAIL: ravikumarlaptop@bnxmail.com',
                            style: TextStyle(fontSize: 10, color: Color(0xFF1E3A8A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'INVOICE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'INVOICE NO.  $_invoiceNo',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'DATE ISSUED  ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0)),
                const Text(
                  'BILL RECIPIENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _clientNameController.text.isNotEmpty
                      ? _clientNameController.text
                      : 'Cash Customer',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                if (_clientEmailController.text.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _clientEmailController.text,
                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                  ),
                ],
                const SizedBox(height: 16),
                _buildPreviewTotalRow('Amount (Tax Excl.)', '₹${_subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 6),
                _buildPreviewTotalRow('Calculated GST', '₹${_gstAmount.toStringAsFixed(2)}'),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(
                      '₹${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
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
  }

  Widget _buildPreviewTotalRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }
}
