import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _livePreview = true;
  String _invoiceNo = 'INV-158091';
  String _invoiceType = 'GST';
  String _invoiceStatus = 'Unpaid';
  String _paymentMode = 'Bank';
  String _selectedBank = '-- Select Bank Account --';
  String _terms = 'Due on Receipt';
  DateTime _dueDate = DateTime.now();

  // Client Details
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _clientGstinController = TextEditingController();
  final TextEditingController _billingAddressController = TextEditingController();
  final TextEditingController _shippingAddressController = TextEditingController();

  final List<Map<String, dynamic>> _items = [
    {
      'desc': 'Development Services',
      'hsn': '8471.30.10',
      'qty': 1,
      'unit': 'Pcs',
      'price': 12000.0,
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
      double gstRate = double.tryParse(item['gst'].replaceAll('%', '')) ?? 0;
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
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;

    final formColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Invoice Info Fields
        _buildInvoiceDetailsForm(isMobile),
        const SizedBox(height: 24),

        // Client details
        _buildClientDetailsForm(isMobile),
        const SizedBox(height: 24),

        // Addresses details
        _buildAddressesForm(isMobile),
        const SizedBox(height: 32),

        // Invoice Items section
        _buildInvoiceItemsSection(isMobile),
        const SizedBox(height: 32),

        // Payment, loyalty & totals
        _buildPaymentAndTotalsSection(isMobile),
        const SizedBox(height: 32),

        // Bottom action
        _buildBottomActionButton(isMobile),
      ],
    );

    final previewColumn = _buildLivePreviewCard(isMobile);

    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : (_livePreview && !isMobile ? 1200 : 800),
            maxHeight: screenHeight * 0.65,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildHeader(context, isMobile),
              ),
              const Divider(height: 16, color: AppColors.border),
              
              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0, isMobile ? 16 : 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Responsive side-by-side or stacked layout
                      if (isMobile) ...[
                        formColumn,
                      ] else if (_livePreview) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 11, child: formColumn),
                            const SizedBox(width: 32),
                            Expanded(flex: 9, child: previewColumn),
                          ],
                        ),
                      ] else ...[
                        formColumn,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'New Invoice',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
        ),
        // Live Preview Switch Button (Pink styling to match image)
        GestureDetector(
          onTap: () => setState(() => _livePreview = !_livePreview),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _livePreview ? LucideIcons.eye : LucideIcons.eyeOff,
                size: 16,
                color: const Color(0xFFDB2777),
              ),
              const SizedBox(width: 6),
              const Text(
                'Preview Live',
                style: TextStyle(
                  color: Color(0xFFDB2777),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Settings Icon Button
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.black45,
              builder: (ctx) => const InvoiceSettingsModal(),
            );
          },
          icon: const Icon(LucideIcons.settings, size: 18, color: AppColors.darkText),
          tooltip: 'Invoice Settings',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            ref.read(navigationProvider.notifier).setRoute(AppRoute.billing);
          },
          icon: const Icon(LucideIcons.x, size: 18, color: AppColors.secondaryText),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceDetailsForm(bool isMobile) {
    final settings = ref.watch(invoiceSettingsProvider);
    final typeOptions = settings.invoiceTypes.contains(_invoiceType) ? settings.invoiceTypes : [...settings.invoiceTypes, _invoiceType];
    final statusOptions = settings.invoiceStatuses.contains(_invoiceStatus) ? settings.invoiceStatuses : [...settings.invoiceStatuses, _invoiceStatus];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildInputField(
          width: isMobile ? double.infinity : 220,
          label: 'INVOICE #',
          child: TextFormField(
            initialValue: _invoiceNo,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            decoration: _inputDecoration(),
            onChanged: (val) => setState(() => _invoiceNo = val),
          ),
        ),
        _buildInputField(
          width: isMobile ? double.infinity : 220,
          label: 'TYPE',
          child: DropdownButtonFormField<String>(
            initialValue: typeOptions.contains(_invoiceType) ? _invoiceType : typeOptions.first,
            style: const TextStyle(color: AppColors.darkText, fontSize: 13),
            decoration: _inputDecoration(),
            items: typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) => setState(() => _invoiceType = val!),
          ),
        ),
        _buildInputField(
          width: isMobile ? double.infinity : 220,
          label: 'STATUS',
          child: DropdownButtonFormField<String>(
            initialValue: statusOptions.contains(_invoiceStatus) ? _invoiceStatus : statusOptions.first,
            style: const TextStyle(color: AppColors.darkText, fontSize: 13),
            decoration: _inputDecoration(),
            items: statusOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) => setState(() => _invoiceStatus = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildClientDetailsForm(bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildInputField(
          width: isMobile ? double.infinity : 220,
          label: 'CLIENT NAME',
          child: TextFormField(
            controller: _clientNameController,
            decoration: _inputDecoration(hint: 'Enter client name'),
            style: const TextStyle(fontSize: 13),
            onChanged: (val) => setState(() {}),
          ),
        ),
        _buildInputField(
          width: isMobile ? double.infinity : 220,
          label: 'CLIENT EMAIL',
          child: TextFormField(
            controller: _clientEmailController,
            decoration: _inputDecoration(hint: 'Enter client email'),
            style: const TextStyle(fontSize: 13),
            onChanged: (val) => setState(() {}),
          ),
        ),
        _buildInputField(
          width: isMobile ? double.infinity : 220,
          label: 'CLIENT GSTIN',
          child: TextFormField(
            controller: _clientGstinController,
            decoration: _inputDecoration(hint: 'Optional'),
            style: const TextStyle(fontSize: 13),
            onChanged: (val) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressesForm(bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildInputField(
          width: isMobile ? double.infinity : 340,
          label: 'BILLING ADDRESS',
          child: TextFormField(
            controller: _billingAddressController,
            maxLines: 2,
            decoration: _inputDecoration(hint: 'Enter billing details'),
            style: const TextStyle(fontSize: 13),
            onChanged: (val) => setState(() {}),
          ),
        ),
        _buildInputField(
          width: isMobile ? double.infinity : 340,
          label: 'SHIPPING ADDRESS',
          child: TextFormField(
            controller: _shippingAddressController,
            maxLines: 2,
            decoration: _inputDecoration(hint: 'Enter shipping details'),
            style: const TextStyle(fontSize: 13),
            onChanged: (val) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceItemsSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Invoice Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF472B6),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Search barcode
        Container(
          width: isMobile ? double.infinity : 320,
          height: 38,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.search, size: 14, color: AppColors.secondaryText),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Quick Scan / Barcode',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // Items table (scrollable horizontally)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(100),
            columnWidths: const {
              0: FixedColumnWidth(180), // Description
              1: FixedColumnWidth(90),  // HSN
              2: FixedColumnWidth(60),  // Qty
              3: FixedColumnWidth(80),  // Unit
              4: FixedColumnWidth(80),  // Price
              5: FixedColumnWidth(60),  // Disc %
              6: FixedColumnWidth(80),  // GST %
              7: FixedColumnWidth(40),  // Delete
            },
            children: [
              TableRow(
                children: [
                  _buildTableHeader('DESCRIPTION'),
                  _buildTableHeader('HSN'),
                  _buildTableHeader('QTY'),
                  _buildTableHeader('UNIT'),
                  _buildTableHeader('PRICE (₹)'),
                  _buildTableHeader('DISC %'),
                  _buildTableHeader('GST %'),
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
                        style: const TextStyle(fontSize: 12),
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
                        style: const TextStyle(fontSize: 12),
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
                        style: const TextStyle(fontSize: 12),
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
                          final unitOpts = settings.unitsList.contains(unitVal) ? settings.unitsList : [...settings.unitsList, unitVal];
                          return DropdownButtonFormField<String>(
                            initialValue: unitOpts.contains(unitVal) ? unitVal : unitOpts.first,
                            decoration: _tableInputDecoration(),
                            style: const TextStyle(fontSize: 12, color: AppColors.darkText),
                            items: unitOpts.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
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
                        initialValue: item['price'].toString(),
                        decoration: _tableInputDecoration(),
                        style: const TextStyle(fontSize: 12),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            item['price'] = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: TextFormField(
                        initialValue: item['disc'].toString(),
                        decoration: _tableInputDecoration(),
                        style: const TextStyle(fontSize: 12),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            item['disc'] = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: Builder(
                        builder: (context) {
                          final settings = ref.watch(invoiceSettingsProvider);
                          final gstVal = item['gst'].toString();
                          final gstOpts = settings.gstRates.contains(gstVal) ? settings.gstRates : [...settings.gstRates, gstVal];
                          return DropdownButtonFormField<String>(
                            initialValue: gstOpts.contains(gstVal) ? gstVal : gstOpts.first,
                            decoration: _tableInputDecoration(),
                            style: const TextStyle(fontSize: 12, color: AppColors.darkText),
                            items: gstOpts.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) {
                              setState(() {
                                item['gst'] = val;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 16),
                      onPressed: () => _removeItem(index),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentAndTotalsSection(bool isMobile) {
    final settings = ref.watch(invoiceSettingsProvider);
    final paymentModes = settings.paymentModes.contains(_paymentMode) ? settings.paymentModes : [...settings.paymentModes, _paymentMode];

    final paymentPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT MODE',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: paymentModes.map((mode) {
            final isSelected = _paymentMode == mode;
            return ChoiceChip(
              label: Text(
                mode,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _paymentMode = mode);
              },
              selectedColor: const Color(0xFF7C3AED),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? const Color(0xFF7C3AED) : AppColors.border),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
        if (_paymentMode == 'Bank') ...[
          const SizedBox(height: 16),
          _buildInputField(
            width: double.infinity,
            label: 'SELECT BANK ACCOUNT',
            child: DropdownButtonFormField<String>(
              initialValue: _selectedBank,
              style: const TextStyle(color: AppColors.darkText, fontSize: 13),
              decoration: _inputDecoration(),
              items: ['-- Select Bank Account --', 'HDFC Bank - 501002...', 'SBI - 302919...']
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedBank = val!),
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Responsive Stack for Paid & Due Amounts on mobile to prevent overflow
        isMobile
            ? Column(
                children: [
                  _buildInputField(
                    label: 'PAID AMOUNT (₹)',
                    child: TextFormField(
                      initialValue: '0',
                      decoration: _inputDecoration(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'DUE AMOUNT (₹)',
                    child: TextFormField(
                      initialValue: '0',
                      decoration: _inputDecoration(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'PAID AMOUNT (₹)',
                      child: TextFormField(
                        initialValue: '0',
                        decoration: _inputDecoration(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      label: 'DUE AMOUNT (₹)',
                      child: TextFormField(
                        initialValue: '0',
                        decoration: _inputDecoration(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 16),
        // Loyalty points
        const Text(
          'LOYALTY POINTS',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Points to redeem',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                AppSnackbar.show(
                  context,
                  "Applied maximum balance deduction to invoice.",
                  type: SnackType.info,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Use Max', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Responsive stack for Terms & Due date on mobile to prevent horizontal layout overflow
        isMobile
            ? Column(
                children: [
                  _buildInputField(
                    label: 'TERMS',
                    child: DropdownButtonFormField<String>(
                      initialValue: _terms,
                      style: const TextStyle(color: AppColors.darkText, fontSize: 13),
                      decoration: _inputDecoration(),
                      items: ['Due on Receipt', 'Net 15', 'Net 30', 'Net 60']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) => setState(() => _terms = val!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'DUE DATE',
                    child: _buildDatePickerSelector(),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'TERMS',
                      child: DropdownButtonFormField<String>(
                        initialValue: _terms,
                        style: const TextStyle(color: AppColors.darkText, fontSize: 13),
                        decoration: _inputDecoration(),
                        items: ['Due on Receipt', 'Net 15', 'Net 30', 'Net 60']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _terms = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      label: 'DUE DATE',
                      child: _buildDatePickerSelector(),
                    ),
                  ),
                ],
              ),
      ],
    );

    final totalsPanel = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalRow('Subtotal:', '₹ ${_subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildTotalRow('Total Discount:', '- ₹ ${_discount.toStringAsFixed(0)}', isDiscount: true),
          const SizedBox(height: 8),
          _buildTotalRow('GST Amount:', '₹ ${_gstAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildTotalRow('Round Off:', '₹ 0.00'),
          const Divider(height: 24, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              Text(
                '₹ ${_total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Points to earn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.sparkles, size: 14, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Points to earn this bill: 0 pts',
                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
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
        Expanded(flex: 5, child: paymentPanel),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: totalsPanel),
      ],
    );
  }

  Widget _buildDatePickerSelector() {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selected != null) {
          setState(() {
            _dueDate = selected;
          });
        }
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_dueDate.day.toString().padLeft(2, '0')}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.year}',
              style: const TextStyle(fontSize: 12),
            ),
            const Icon(LucideIcons.calendar, size: 14, color: AppColors.secondaryText),
          ],
        ),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue Accent bar at top
          Container(
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Details
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
                      child: const Text('r', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RAVIKUMARLAPTOP',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A)),
                          ),
                          const SizedBox(height: 2),
                          const Text('Global Solutions Enterprise', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text('GSTIN: ${_clientGstinController.text.isNotEmpty ? _clientGstinController.text : "N/A"}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          const Text('EMAIL: ravikumarlaptop@bnxmail.com', style: TextStyle(fontSize: 10, color: Color(0xFF1E3A8A))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Large Invoice Title & Stats
                const Text(
                  'INVOICE',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1),
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
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'DATE ISSUED  2026-07-08',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE2E8F0)),

                // Bill Recipient
                const Text(
                  'BILL RECIPIENT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  _clientNameController.text.isNotEmpty ? _clientNameController.text : '[Client Name]',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                if (_clientEmailController.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(_clientEmailController.text, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                ],
                if (_billingAddressController.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(_billingAddressController.text, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                ],
                const SizedBox(height: 20),

                // Payment Mode Panel
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PAYMENT MODE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(_paymentMode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                            Text('Terms: $_terms', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CURRENCY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 4),
                            const Text('INR (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                            const Text('Indian Rupee', style: TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Items list header
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('DESCRIPTION', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text('QTY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Items mapped
                ..._items.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['desc'].toString().isNotEmpty ? item['desc'] : 'Item detail',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText),
                            ),
                            Text(
                              item['qty'].toString(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (item['hsn'].toString().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('HSN CODE: ${item['hsn']}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Bank details
                if (_paymentMode == 'Bank') ...[
                  const Text(
                    'BANK SETTLEMENT DETAILS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text('BANK NAME: Standard Chartered', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                  const Text('IFSC CODE: SCBL0001234', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                  const Text('ACCOUNT NUMBER: 5544 9900 1122 3344', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  const SizedBox(height: 20),
                ],

                // Notes & instructions
                const Text(
                  'NOTES & INSTRUCTIONS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                const Text('1. Please quote invoice number in all communications.', style: TextStyle(fontSize: 9, color: Colors.grey)),
                const Text('2. Payment is due within 30 days of invoice date.', style: TextStyle(fontSize: 9, color: Colors.grey)),
                const SizedBox(height: 24),

                // Subtotal totals calculation
                _buildPreviewTotalRow('Amount (Tax Excl.)', '₹${_subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 6),
                _buildPreviewTotalRow('Calculated GST', '₹${_gstAmount.toStringAsFixed(2)}'),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('₹${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  ],
                ),
                const SizedBox(height: 16),

                // Blue word banner
                Container(
                  width: double.infinity,
                  color: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  alignment: Alignment.center,
                  child: Text(
                    'AMOUNT IN WORDS: ${_total > 0 ? "RUPEES ${_total.toInt().toString().toUpperCase()} ONLY." : "RUPEES ZERO ONLY."}',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // Signature footer
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text('Digital Signature', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'AUTHORIZED SIGNATORY FOR CLIKS ENTERPRISE',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
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

  Widget _buildTotalRow(String label, String val, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 12)),
        Text(
          val,
          style: TextStyle(
            color: isDiscount ? Colors.red : AppColors.darkText,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          AppSnackbar.show(
            context,
            "Invoice $_invoiceNo saved & generated successfully! Ready for download.",
            type: SnackType.success,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C3AED), // Violet color matching the mockup
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Generate & Save Invoice',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildInputField({double? width, required String label, required Widget child}) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 9, fontWeight: FontWeight.bold),
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
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryGreen),
      ),
    );
  }

  InputDecoration _tableInputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primaryGreen),
      ),
    );
  }
}
