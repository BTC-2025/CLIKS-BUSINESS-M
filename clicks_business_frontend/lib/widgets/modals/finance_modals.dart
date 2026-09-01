import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../features/billing/providers/accounting_provider.dart';
import '../../features/billing/providers/expenses_provider.dart';
import '../app_ui_kit.dart';

class RecordExpenseModal extends ConsumerStatefulWidget {
  const RecordExpenseModal({super.key});

  @override
  ConsumerState<RecordExpenseModal> createState() => _RecordExpenseModalState();
}

class _RecordExpenseModalState extends ConsumerState<RecordExpenseModal> {
  String category = 'Rent';
  String gstRate = '0% Excluded';
  String paymentMode = 'UPI';

  final TextEditingController subcategoryController = TextEditingController();
  final TextEditingController payeeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController refController = TextEditingController();

  @override
  void dispose() {
    subcategoryController.dispose();
    payeeController.dispose();
    amountController.dispose();
    refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ModalWrapper(
      title: 'Record Business Expense',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLabel('Expense Category'),
          _buildDropdown(
            value: category,
            items: ['Rent', 'Utilities', 'Office Supplies', 'Marketing', 'Travel', 'Software / SaaS', 'Others'],
            onChanged: (val) => setState(() => category = val!),
          ),
          const SizedBox(height: 16),
          _buildLabel('Subcategory / Spares description'),
          _buildTextField(controller: subcategoryController, hintText: 'Office space rent'),
          const SizedBox(height: 16),
          _buildLabel('Payee / Merchant Profile'),
          _buildTextField(controller: payeeController, hintText: 'e.g. Landmark Properties Ltd'),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            context,
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Expense Amount (INR)'),
                  _buildTextField(controller: amountController, hintText: 'Enter amount', keyboardType: TextInputType.number),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('GST % Percentage'),
                  _buildDropdown(
                    value: gstRate,
                    items: ['0% Excluded', '5% GST', '12% GST', '18% GST', '28% GST'],
                    onChanged: (val) => setState(() => gstRate = val!),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            context,
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Payment Mode'),
                  _buildDropdown(
                    value: paymentMode,
                    items: ['UPI', 'Cash', 'Bank Transfer', 'Credit Card', 'Debit Card'],
                    onChanged: (val) => setState(() => paymentMode = val!),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Ref / UPI reference'),
                  _buildTextField(controller: refController, hintText: 'e.g. txn_9812401824'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettleButton(
            text: 'Settle & Post Expense',
            onPressed: () {
              final payee = payeeController.text.trim();
              final desc = subcategoryController.text.trim();
              final amtStr = amountController.text.trim();
              final parsedAmt = double.tryParse(amtStr) ?? 0.0;
              final title = payee.isNotEmpty ? payee : (desc.isNotEmpty ? desc : category);

              final newEntry = AccountingEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                category: category,
                entryType: 'Expense',
                amount: parsedAmt,
                paymentMode: paymentMode,
                date: '08-08-2026',
                notes: desc,
              );

              ref.read(accountingEntriesProvider.notifier).addEntry(newEntry);

              AppSnackbar.show(
                context,
                "Expense '$title' (₹${parsedAmt.toStringAsFixed(2)}) posted successfully!",
                type: SnackType.success,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({TextEditingController? controller, required String hintText, TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        ),
      ),
    );
  }
}



class GenerateEWayBillModal extends StatefulWidget {
  final Function(Map<String, String>)? onGenerated;
  const GenerateEWayBillModal({super.key, this.onGenerated});

  @override
  State<GenerateEWayBillModal> createState() => _GenerateEWayBillModalState();
}

class _GenerateEWayBillModalState extends State<GenerateEWayBillModal> {
  String selectedSalesInvoice = '-- Select Sales Invoice --';
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController hsnController = TextEditingController();
  final TextEditingController unitController = TextEditingController(text: 'Pcs');
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController taxableValueController = TextEditingController();
  String gstRate = '18%';

  final TextEditingController invoiceNoController = TextEditingController(text: 'INV-2026-001');
  final TextEditingController invoiceDateController = TextEditingController(text: '08-08-2026');
  String transportMode = 'Road';
  final TextEditingController transportCompanyController = TextEditingController(text: 'Bluedart Cargo');
  final TextEditingController transporterGstinController = TextEditingController(text: '27AAAAA1111A1Z1');
  final TextEditingController vehicleNoController = TextEditingController(text: 'MH-02-EH-9081');
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController dispatchLocationController = TextEditingController();
  final TextEditingController deliveryDestinationController = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        invoiceDateController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 550;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: screenHeight * 0.88,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))
                : BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Create Government e-Way Bill', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6), shape: const CircleBorder(), padding: const EdgeInsets.all(6)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdown('AUTO-FILL FROM SALES INVOICE (OPTIONAL)', selectedSalesInvoice, ['-- Select Sales Invoice --', 'INV-2026-001 (Saravana Stores)', 'INV-2026-002 (Reliances)'], (v) => setState(() => selectedSalesInvoice = v!)),
                      const SizedBox(height: 14),

                      // Section Box for Manual Entry
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('GOODS DETAILS (MANUAL ENTRY)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                            const SizedBox(height: 10),

                            _buildLabel('PRODUCT NAME *'),
                            _buildField(productNameController, hint: 'e.g. Steel Rods'),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('HSN/SAC CODE'), _buildField(hsnController, hint: 'e.g. 7214')])),
                                const SizedBox(width: 10),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('UNIT'), _buildField(unitController, hint: 'Pcs')])),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('QUANTITY *'), _buildField(qtyController, hint: 'e.g. 10', keyboardType: TextInputType.number)])),
                                const SizedBox(width: 10),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('TAXABLE VALUE (₹) *'), _buildField(taxableValueController, hint: 'e.g. 50000', keyboardType: TextInputType.number)])),
                              ],
                            ),
                            const SizedBox(height: 10),

                            _buildDropdown('GST RATE (%)', gstRate, ['18%', '5%', '12%', '28%'], (v) => setState(() => gstRate = v!)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('INVOICE NUMBER *'), _buildField(invoiceNoController, hint: 'INV-2026-001')])),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('INVOICE DATE *'),
                                InkWell(
                                  onTap: _pickDate,
                                  child: SizedBox(
                                    height: 40,
                                    child: TextField(
                                      controller: invoiceDateController,
                                      enabled: false,
                                      style: const TextStyle(fontSize: 12, color: AppColors.darkText),
                                      decoration: InputDecoration(
                                        hintText: '08-08-2026',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        suffixIcon: const Icon(LucideIcons.calendar, size: 15, color: AppColors.darkText),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(child: _buildDropdown('TRANSPORT MODE *', transportMode, ['Road', 'Rail', 'Air', 'Ship'], (v) => setState(() => transportMode = v!))),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('TRANSPORT COMPANY NAME *'), _buildField(transportCompanyController, hint: 'Bluedart Cargo')])),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('TRANSPORTER GSTIN (OPTIONAL)'), _buildField(transporterGstinController, hint: '27AAAAA1111A1Z1')])),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('VEHICLE NUMBER *'), _buildField(vehicleNoController, hint: 'MH-02-EH-9081')])),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('DISTANCE (KMS) *'), _buildField(distanceController, hint: 'e.g. 150', keyboardType: TextInputType.number)])),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('DISPATCH LOCATION *'), _buildField(dispatchLocationController, hint: 'Mumbai warehouse')])),
                        ],
                      ),
                      const SizedBox(height: 10),

                      _buildLabel('DELIVERY DESTINATION *'),
                      _buildField(deliveryDestinationController, hint: 'Client site, Pune'),
                      const SizedBox(height: 20),

                      // Purple Full-width Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            final ewbNo = "3810${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
                            final generatedData = {
                              'ewbNo': ewbNo,
                              'invNo': invoiceNoController.text.isNotEmpty ? invoiceNoController.text : 'INV-2026-001',
                              'transporter': transportCompanyController.text.isNotEmpty ? transportCompanyController.text : 'Bluedart Cargo',
                              'vehicle': vehicleNoController.text.isNotEmpty ? vehicleNoController.text : 'MH-02-EH-9081',
                              'distance': "${distanceController.text.isNotEmpty ? distanceController.text : '150'} Kms",
                              'route': "${dispatchLocationController.text.isNotEmpty ? dispatchLocationController.text : 'Mumbai'} - ${deliveryDestinationController.text.isNotEmpty ? deliveryDestinationController.text : 'Pune'}",
                              'status': 'ACTIVE',
                            };
                            widget.onGenerated?.call(generatedData);
                            AppSnackbar.show(context, "Government e-Way Bill ($ewbNo) generated successfully!", type: SnackType.success);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D28D9), // Purple matching Image 1
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Generate Government e-Way Bill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkText)),
    );
  }

  Widget _buildField(TextEditingController controller, {required String hint, TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != value) _buildLabel(label),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: onChanged,
            icon: const Icon(LucideIcons.chevronDown, size: 15, color: Color(0xFF6B7280)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
        ),
      ],
    );
  }
}

// --- MODAL 2: GENERATE GST E-INVOICE (MATCHING IMAGES 2 & 4) ---
class GenerateEInvoiceModal extends StatefulWidget {
  final Function(Map<String, String>)? onGenerated;
  const GenerateEInvoiceModal({super.key, this.onGenerated});

  @override
  State<GenerateEInvoiceModal> createState() => _GenerateEInvoiceModalState();
}

class _GenerateEInvoiceModalState extends State<GenerateEInvoiceModal> {
  final TextEditingController senderProductNameController = TextEditingController();

  int customerSource = 0; // 0: Existing Customer (Default matching screenshot), 1: Manual Entry
  String selectedCustomer = 'Select Customer';
  final List<String> existingCustomers = [
    'Select Customer',
    'Saravana Stores Pvt Ltd',
    'Reliance Retail Ltd',
    'Tata Digital Ltd',
    'Infosys Limited',
  ];

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerGstinController = TextEditingController();
  String statePlaceOfSupply = '33 - Tamil Nadu';
  bool saveCustomerFuture = false;
  final TextEditingController receiverProductNameController = TextEditingController();

  String invoiceType = 'B2B';
  final TextEditingController taxableValueController = TextEditingController();
  String gstPercentage = '12%';
  String reverseCharge = 'No';

  void _onCustomerSelected(String? customer) {
    if (customer == null) return;
    setState(() {
      selectedCustomer = customer;
      if (customer == 'Saravana Stores Pvt Ltd') {
        customerGstinController.text = '33ABCDE1234F1Z5';
        statePlaceOfSupply = '33 - Tamil Nadu';
      } else if (customer == 'Reliance Retail Ltd') {
        customerGstinController.text = '27AAACR1234F1Z1';
        statePlaceOfSupply = '27 - Maharashtra';
      } else if (customer == 'Tata Digital Ltd') {
        customerGstinController.text = '29AAACT5678G1Z2';
        statePlaceOfSupply = '29 - Karnataka';
      } else if (customer == 'Infosys Limited') {
        customerGstinController.text = '29AAACI9876H1Z9';
        statePlaceOfSupply = '29 - Karnataka';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 550;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: screenHeight * 0.88,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))
                : BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Generate GST e-Invoice', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6), shape: const CircleBorder(), padding: const EdgeInsets.all(6)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SENDER FROM CARD
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('SENDER (FROM)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                            SizedBox(height: 4),
                            Text('Company Name: Saravana Stores Pvt Ltd', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                            Text('GSTIN: 33ABCDE1234F1Z5', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                            Text('State: Tamil Nadu', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // RECEIVER TO SECTION
                      const Text('RECEIVER (TO)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Text('Customer Source: ', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => setState(() => customerSource = 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Radio<int>(
                                    value: 0,
                                    groupValue: customerSource,
                                    onChanged: (v) => setState(() => customerSource = v!),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('Existing Customer', style: TextStyle(fontSize: 10.5, fontWeight: customerSource == 0 ? FontWeight.bold : FontWeight.normal)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () => setState(() => customerSource = 1),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Radio<int>(
                                    value: 1,
                                    groupValue: customerSource,
                                    onChanged: (v) => setState(() => customerSource = v!),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('Manual Entry', style: TextStyle(fontSize: 10.5, fontWeight: customerSource == 1 ? FontWeight.bold : FontWeight.normal)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (customerSource == 0)
                        _buildDropdown('Customer Name *', selectedCustomer, existingCustomers, _onCustomerSelected)
                      else ...[
                        _buildLabel('Customer Name *'),
                        _buildField(customerNameController, hint: 'Enter Customer Name'),
                      ],
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Customer GSTIN'), _buildField(customerGstinController, hint: 'Enter GSTIN')])),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDropdown('State / Place of Supply', statePlaceOfSupply, ['33 - Tamil Nadu', '27 - Maharashtra', '07 - Delhi', '29 - Karnataka'], (v) => setState(() => statePlaceOfSupply = v!))),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (customerSource == 1) ...[
                        Row(
                          children: [
                            Checkbox(
                              value: saveCustomerFuture,
                              onChanged: (v) => setState(() => saveCustomerFuture = v!),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const Text('Save this customer for future use', style: TextStyle(fontSize: 10.5, color: AppColors.secondaryText)),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      _buildLabel('Product Name *'),
                      _buildField(receiverProductNameController, hint: 'Select or enter Product Name'),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(child: _buildDropdown('Invoice Type', invoiceType, ['B2B', 'B2C', 'Export', 'SEZ'], (v) => setState(() => invoiceType = v!))),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Taxable Value (Before GST)'), _buildField(taxableValueController, hint: 'Enter amount', keyboardType: TextInputType.number)])),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(child: _buildDropdown('GST %', gstPercentage, ['12%', '18%', '5%', '28%'], (v) => setState(() => gstPercentage = v!))),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDropdown('Reverse Charge', reverseCharge, ['No', 'Yes'], (v) => setState(() => reverseCharge = v!))),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // TAX TYPE DETERMINED CARD (MATCHING IMAGE 4)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TAX TYPE DETERMINED:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                                Text('INTRA-STATE (CGST + SGST)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('CGST (6%)', style: TextStyle(fontSize: 10, color: Color(0xFF6B21A8))), Text('₹0', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B21A8)))]),
                            SizedBox(height: 2),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('SGST (6%)', style: TextStyle(fontSize: 10, color: Color(0xFF6B21A8))), Text('₹0', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B21A8)))]),
                            SizedBox(height: 4),
                            Divider(height: 1, color: Color(0xFFD8B4FE)),
                            SizedBox(height: 4),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total Invoice Amount', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF6B21A8))), Text('₹0', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF6B21A8)))]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Purple Full-width Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            final custName = customerSource == 0
                                ? (selectedCustomer != 'Select Customer' ? selectedCustomer : 'Saravana Stores Pvt Ltd')
                                : (customerNameController.text.isNotEmpty ? customerNameController.text : 'Custom Client');
                            final rawTaxable = taxableValueController.text.replaceAll('₹', '').replaceAll(',', '').trim();
                            final taxableVal = double.tryParse(rawTaxable) ?? 5000.0;
                            final gstRate = double.tryParse(gstPercentage.replaceAll('%', '')) ?? 12.0;
                            final gstAmt = taxableVal * (gstRate / 100.0);
                            final totalVal = taxableVal + gstAmt;
                            final irnNo = "89f1a293${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}8901";
                            final invNo = "BILL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

                            final generatedData = {
                              'irn': irnNo,
                              'invNo': invNo,
                              'ackNo': "1220${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
                              'ackDate': '2026-08-08',
                              'customer': custName,
                              'amount': "₹${totalVal.toStringAsFixed(2)}",
                              'taxable': taxableVal.toStringAsFixed(2),
                              'gstAmt': gstAmt.toStringAsFixed(2),
                              'status': 'AUTHENTICATED',
                              'gstin': customerGstinController.text.isNotEmpty ? customerGstinController.text : '33ABCDE1234F1Z5',
                              'type': invoiceType,
                            };

                            widget.onGenerated?.call(generatedData);
                            AppSnackbar.show(context, "GST e-Invoice ($invNo) generated & authenticated successfully!", type: SnackType.success);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED), // Purple matching Image 4
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Generate / Authenticate e-Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkText)),
    );
  }

  Widget _buildField(TextEditingController controller, {required String hint, TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != value) _buildLabel(label),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: onChanged,
            icon: const Icon(LucideIcons.chevronDown, size: 15, color: Color(0xFF6B7280)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModalWrapper extends ConsumerWidget {
  final String title;
  final Widget child;

  const _ModalWrapper({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 550,
          maxHeight: screenHeight * 0.88,
        ),
        margin: EdgeInsets.zero,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        ref.read(navigationProvider.notifier).setRoute(AppRoute.expenses);
                      }
                    },
                    icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
  final isSmall = MediaQuery.of(context).size.width < 450;
  if (isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        children[0],
        const SizedBox(height: 16),
        children[1],
      ],
    );
  }
  return Row(
    children: [
      Expanded(child: children[0]),
      const SizedBox(width: 12),
      Expanded(child: children[1]),
    ],
  );
}

Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF374151),
      ),
    ),
  );
}

class SecureAuditExportModal extends ConsumerStatefulWidget {
  const SecureAuditExportModal({super.key});

  @override
  ConsumerState<SecureAuditExportModal> createState() => _SecureAuditExportModalState();
}

class _SecureAuditExportModalState extends ConsumerState<SecureAuditExportModal> {
  int selectedFormat = 0; // 0: Tally/Excel, 1: Raw CSV

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 800,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Secure FIN-PRO Audit Export',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.accounting),
                      icon: const Icon(LucideIcons.x, size: 18, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: AppColors.border),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0, isMobile ? 16 : 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFFDE8E8), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(LucideIcons.downloadCloud, color: Color(0xFFDC3545), size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Select your timeline and format options.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('SET DATE LIMITS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildDateField('FROM', '11-06-2026')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDateField('TO', '11-07-2026')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('SELECT FILE FORMAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildFormatCard('Tally/Excel Doc', '.xlsx Spreadsheet', selectedFormat == 0, () => setState(() => selectedFormat = 0))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFormatCard('Raw Flat Data', '.csv File', selectedFormat == 1, () => setState(() => selectedFormat = 1))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF198754).withValues(alpha: 0.12))),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.shieldCheck, color: Color(0xFF198754), size: 16),
                            SizedBox(width: 10),
                            Expanded(child: Text('Audit ready structures generated according to accounting principles.', style: TextStyle(fontSize: 11, color: Color(0xFF198754), fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.accounting),
                          icon: const Icon(LucideIcons.download, size: 16),
                          label: const Text('EXPORT LEDGER NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD63384), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
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

  Widget _buildDateField(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.calendar, size: 10, color: Color(0xFFD63384)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const Icon(LucideIcons.calendar, size: 14, color: AppColors.secondaryText),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatCard(String title, String subtitle, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                if (isSelected) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }
}

class RecordAccountingEntryModal extends ConsumerStatefulWidget {
  const RecordAccountingEntryModal({super.key});

  @override
  ConsumerState<RecordAccountingEntryModal> createState() => _RecordAccountingEntryModalState();
}

class _RecordAccountingEntryModalState extends ConsumerState<RecordAccountingEntryModal> {
  String entryType = 'Expense';
  String category = 'Office Expenses';
  String paymentMode = 'Cash in Hand';
  DateTime selectedDate = DateTime(2026, 8, 8);

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController(text: '0.00');
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    customerNameController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day-$month-${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 550;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: screenHeight * 0.85,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))
                : BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Financial Entry',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    IconButton(
                      onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.accounting),
                      icon: const Icon(LucideIcons.x, size: 18, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Entry Type & Date Row
                      if (isMobile) ...[
                        _buildDropdownField(
                          'Entry Type',
                          entryType,
                          ['Income / Sales', 'Expense', 'Journal Entry', 'Transfer', 'Asset Purchase'],
                          (val) => setState(() => entryType = val!),
                        ),
                        const SizedBox(height: 14),
                        _buildDateField(context, 'Date', _formatDate(selectedDate)),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                'Entry Type',
                                entryType,
                                ['Income / Sales', 'Expense', 'Journal Entry', 'Transfer', 'Asset Purchase'],
                                (val) => setState(() => entryType = val!),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: _buildDateField(context, 'Date', _formatDate(selectedDate))),
                          ],
                        ),
                      const SizedBox(height: 14),
                      
                      // Customer Name Field
                      _buildInputField('Customer Name', 'Customer Name', customerNameController),
                      const SizedBox(height: 14),

                      // Category & Payment Mode Row
                      if (isMobile) ...[
                        _buildDropdownField(
                          'Category',
                          category,
                          ['Sales Revenue', 'Service Income', 'Other Income', 'Office Expenses', 'Rent & Utilities', 'Salary & Wages', 'Marketing & Advertising'],
                          (val) => setState(() => category = val!),
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownField(
                          'Payment Mode',
                          paymentMode,
                          ['Cash in Hand', 'Bank Transfer', 'UPI', 'Cheque', 'Credit Card'],
                          (val) => setState(() => paymentMode = val!),
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                'Category',
                                category,
                                ['Sales Revenue', 'Service Income', 'Other Income', 'Office Expenses', 'Rent & Utilities', 'Salary & Wages', 'Marketing & Advertising'],
                                (val) => setState(() => category = val!),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildDropdownField(
                                'Payment Mode',
                                paymentMode,
                                ['Cash in Hand', 'Bank Transfer', 'UPI', 'Cheque', 'Credit Card'],
                                (val) => setState(() => paymentMode = val!),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Amount Input
                      _buildLabel('Amount (₹)'),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            hintText: '0.00',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes / Reference
                      _buildInputField('Notes / Reference', 'e.g. Inv #123 or Bill Reference', notesController),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = customerNameController.text.trim();
                            final amtStr = amountController.text.trim();
                            final parsedAmt = double.tryParse(amtStr) ?? 0.0;
                            final title = name.isNotEmpty ? name : (category.isNotEmpty ? category : 'Financial Entry');

                            final newEntry = AccountingEntry(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              category: category,
                              entryType: entryType,
                              amount: parsedAmt,
                              paymentMode: paymentMode,
                              date: _formatDate(selectedDate),
                              notes: notesController.text.trim(),
                            );

                            ref.read(accountingEntriesProvider.notifier).addEntry(newEntry);

                            AppSnackbar.show(
                              context,
                              "Financial entry '$title' (₹${parsedAmt.toStringAsFixed(2)}) saved successfully!",
                              type: SnackType.success,
                            );
                            ref.read(navigationProvider.notifier).setRoute(AppRoute.accounting);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B61FF), // Purple brand button
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Save Financial Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildDateField(BuildContext context, String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(fontSize: 13, color: AppColors.darkText, fontWeight: FontWeight.w500)),
                const Icon(LucideIcons.calendar, size: 16, color: AppColors.secondaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 42,
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF7B61FF), width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 42,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged,
            icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.secondaryText),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF7B61FF), width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }
}
Widget _buildDropdown({
  required String value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return SizedBox(
    height: 42,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF6B7280)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const Color(0xFF7C3AED) == Colors.white ? const BorderSide(color: Color(0xFFE5E7EB)) : const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
      ),
    ),
  );
}

Widget _buildSettleButton({required String text, required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 44,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

class AddNewBankAccountModal extends StatefulWidget {
  const AddNewBankAccountModal({super.key});

  @override
  State<AddNewBankAccountModal> createState() => _AddNewBankAccountModalState();
}

class _AddNewBankAccountModalState extends State<AddNewBankAccountModal> {
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController openingBalanceController = TextEditingController(text: '0.00');

  String accountType = 'Savings';
  String status = 'Active';

  @override
  void dispose() {
    bankNameController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    branchNameController.dispose();
    openingBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 550;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: screenHeight * 0.88,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))
                : BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle Indicator
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Bank Account',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bank Name & Account Name
                      if (isMobile) ...[
                        _buildField('Bank Name *', 'e.g. HDFC Bank', bankNameController),
                        const SizedBox(height: 14),
                        _buildField('Account Name *', 'e.g. Main Business Savings', accountNameController),
                      ] else
                        Row(
                          children: [
                            Expanded(child: _buildField('Bank Name *', 'e.g. HDFC Bank', bankNameController)),
                            const SizedBox(width: 14),
                            Expanded(child: _buildField('Account Name *', 'e.g. Main Business Savings', accountNameController)),
                          ],
                        ),
                      const SizedBox(height: 14),

                      // Account Number & IFSC Code
                      if (isMobile) ...[
                        _buildField('Account Number *', 'e.g. 501002938128', accountNumberController),
                        const SizedBox(height: 14),
                        _buildField('IFSC Code *', 'e.g. HDFC0000001', ifscCodeController),
                      ] else
                        Row(
                          children: [
                            Expanded(child: _buildField('Account Number *', 'e.g. 501002938128', accountNumberController)),
                            const SizedBox(width: 14),
                            Expanded(child: _buildField('IFSC Code *', 'e.g. HDFC0000001', ifscCodeController)),
                          ],
                        ),
                      const SizedBox(height: 14),

                      // Branch Name & Opening Balance
                      if (isMobile) ...[
                        _buildField('Branch Name (Optional)', 'e.g. Bandra East', branchNameController),
                        const SizedBox(height: 14),
                        _buildField('Opening Balance (₹) *', '0.00', openingBalanceController),
                      ] else
                        Row(
                          children: [
                            Expanded(child: _buildField('Branch Name (Optional)', 'e.g. Bandra East', branchNameController)),
                            const SizedBox(width: 14),
                            Expanded(child: _buildField('Opening Balance (₹) *', '0.00', openingBalanceController)),
                          ],
                        ),
                      const SizedBox(height: 14),

                      // Account Type & Status Dropdowns
                      if (isMobile) ...[
                        _buildModalDropdown('Account Type', accountType, ['Savings', 'Current', 'Credit / Overdraft'], (val) => setState(() => accountType = val!)),
                        const SizedBox(height: 14),
                        _buildModalDropdown('Status', status, ['Active', 'Inactive'], (val) => setState(() => status = val!)),
                      ] else
                        Row(
                          children: [
                            Expanded(child: _buildModalDropdown('Account Type', accountType, ['Savings', 'Current', 'Credit / Overdraft'], (val) => setState(() => accountType = val!))),
                            const SizedBox(width: 14),
                            Expanded(child: _buildModalDropdown('Status', status, ['Active', 'Inactive'], (val) => setState(() => status = val!))),
                          ],
                        ),
                      const SizedBox(height: 24),

                      // Orange Save Bank Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final bName = bankNameController.text.trim();
                            AppSnackbar.show(
                              context,
                              "Bank account ${bName.isNotEmpty ? '\'$bName\' ' : ''}added successfully!",
                              type: SnackType.success,
                            );
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Save Bank Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: onChanged,
            icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF6B7280)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }
}

class LodgeStaffClaimModal extends ConsumerStatefulWidget {
  const LodgeStaffClaimModal({super.key});

  @override
  ConsumerState<LodgeStaffClaimModal> createState() => _LodgeStaffClaimModalState();
}

class _LodgeStaffClaimModalState extends ConsumerState<LodgeStaffClaimModal> {
  final TextEditingController employeeController = TextEditingController(text: 'Karan Mehra (Inventory)');
  final TextEditingController descriptionController = TextEditingController(text: 'Client Sample Box Dispatches');
  final TextEditingController dateController = TextEditingController(text: '08-08-2026');
  final TextEditingController timeController = TextEditingController(text: '10:39');
  final TextEditingController amountController = TextEditingController();
  final TextEditingController receiptController = TextEditingController();

  @override
  void dispose() {
    employeeController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    amountController.dispose();
    receiptController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 550;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: screenHeight * 0.88,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))
                : BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lodge Staff Claim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6), shape: const CircleBorder(), padding: const EdgeInsets.all(6)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Employee Profile Name'),
                      _buildTextField(employeeController, hint: 'Karan Mehra (Inventory)'),
                      const SizedBox(height: 14),

                      _buildLabel('Out-of-pocket Description'),
                      _buildTextField(descriptionController, hint: 'Client Sample Box Dispatches'),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Date'),
                                InkWell(
                                  onTap: _pickDate,
                                  child: _buildIconTextField(dateController, hint: '08-08-2026', icon: LucideIcons.calendar),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Time'),
                                InkWell(
                                  onTap: _pickTime,
                                  child: _buildIconTextField(timeController, hint: '10:39', icon: LucideIcons.clock),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildLabel('Claim Amount (INR)'),
                      _buildTextField(amountController, hint: 'Enter amount', keyboardType: TextInputType.number),
                      const SizedBox(height: 14),

                      _buildLabel('Receipt File / URL / Reference'),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(receiptController, hint: 'e.g. claim_receipt_77.pdf or scan link')),
                          const SizedBox(width: 8),
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                            child: IconButton(
                              onPressed: () {
                                AppSnackbar.show(context, "Attachment uploaded successfully!", type: SnackType.success);
                              },
                              icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.darkText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Purple Full-width Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final emp = employeeController.text.trim();
                            final purp = descriptionController.text.trim();
                            final amt = amountController.text.trim();
                            final date = dateController.text.trim();

                            ref.read(expensesReimbursementsProvider.notifier).addReimbursement({
                              'id': 'CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              'employee': emp.isNotEmpty ? emp : 'Staff Member',
                              'purpose': purp.isNotEmpty ? purp : 'Out-of-pocket Claim',
                              'date': date.isNotEmpty ? date : '08-08-2026',
                              'amount': '₹${amt.isNotEmpty ? amt : '2,450'}',
                              'receipt': receiptController.text.trim().isNotEmpty ? receiptController.text.trim() : 'receipt.pdf',
                              'status': 'Under Review',
                            });

                            AppSnackbar.show(context, "Staff reimbursement claim lodged successfully!", type: SnackType.success);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Lodge Reimbursement Claim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
    );
  }

  Widget _buildTextField(TextEditingController controller, {required String hint, TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildIconTextField(TextEditingController controller, {required String hint, required IconData icon}) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        enabled: false,
        style: const TextStyle(fontSize: 13, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: Icon(icon, size: 16, color: AppColors.darkText),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        ),
      ),
    );
  }
}

// --- MODAL 2: SET TEAM BUDGET (MATCHING SCREENSHOT 3) ---
class SetTeamBudgetModal extends ConsumerStatefulWidget {
  const SetTeamBudgetModal({super.key});

  @override
  ConsumerState<SetTeamBudgetModal> createState() => _SetTeamBudgetModalState();
}

class _SetTeamBudgetModalState extends ConsumerState<SetTeamBudgetModal> {
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController monthlyBudgetController = TextEditingController();
  final TextEditingController spentController = TextEditingController();

  int selectedTab = 0; // 0: Select from HR Database, 1: Manual Entry
  String selectedEmployee = '-- Choose Employee --';

  final List<String> employeeOptions = ['-- Choose Employee --', 'Karan Mehra', 'Ravi Kumar', 'Ananya Sharma', 'Vikram Patel'];

  @override
  void dispose() {
    teamNameController.dispose();
    monthlyBudgetController.dispose();
    spentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 550;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: screenHeight * 0.88,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))
                : BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Set Team Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6), shape: const CircleBorder(), padding: const EdgeInsets.all(6)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Team / Department Name'),
                      _buildField(teamNameController, hint: 'e.g. HR Team'),
                      const SizedBox(height: 14),

                      _buildLabel('Monthly Budget (INR)'),
                      _buildField(monthlyBudgetController, hint: 'e.g. 100000', keyboardType: TextInputType.number),
                      const SizedBox(height: 14),

                      // Section Header for Team Members
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Team Members (0)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Cancel', style: TextStyle(fontSize: 12, color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Sub-Segmented Toggle
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => selectedTab = 0),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedTab == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: selectedTab == 0 ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : [],
                                  ),
                                  child: const Center(
                                    child: Text('Select from HR Database', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => selectedTab = 1),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedTab == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: selectedTab == 1 ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : [],
                                  ),
                                  child: const Center(
                                    child: Text('Manual Entry', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Select Employee'),
                      SizedBox(
                        height: 42,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedEmployee,
                          items: employeeOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (val) => setState(() => selectedEmployee = val!),
                          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF6B7280)),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildLabel('Spent (Optional)'),
                      _buildField(spentController, hint: 'e.g. 25000', keyboardType: TextInputType.number),
                      const SizedBox(height: 12),

                      // Small Add to List Button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            AppSnackbar.show(context, "Employee added to team budget list!", type: SnackType.info);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text('Add to List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text('No team members assigned yet.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.secondaryText)),
                      ),
                      const SizedBox(height: 24),

                      // Purple Settle Budget Target Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final team = teamNameController.text.trim();
                            final limit = monthlyBudgetController.text.trim();
                            final spent = spentController.text.trim();

                            ref.read(expensesBudgetsProvider.notifier).addBudget({
                              'team': team.isNotEmpty ? team : 'Department Team',
                              'limit': '₹${limit.isNotEmpty ? limit : '1,00,000'}',
                              'spent': '₹${spent.isNotEmpty ? spent : '0'}',
                              'index': '0.0%',
                              'status': 'Within Limit',
                            });

                            AppSnackbar.show(context, "Team budget settled successfully!", type: SnackType.success);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Settle Budget Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
    );
  }

  Widget _buildField(TextEditingController controller, {required String hint, TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        ),
      ),
    );
  }
}

// --- MODAL 3: ADD RECURRING SUBSCRIPTION (MATCHING SCREENSHOT 4) ---
class AddRecurringSubscriptionModal extends ConsumerStatefulWidget {
  const AddRecurringSubscriptionModal({super.key});

  @override
  ConsumerState<AddRecurringSubscriptionModal> createState() => _AddRecurringSubscriptionModalState();
}

class _AddRecurringSubscriptionModalState extends ConsumerState<AddRecurringSubscriptionModal> {
  final TextEditingController subNameController = TextEditingController();
  final TextEditingController vendorController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nextDueDateController = TextEditingController(text: '08-08-2026');

  String category = 'Rent';
  String frequency = 'Monthly';
  String autoPost = 'Active (Auto-Create)';
  String status = 'Active';

  @override
  void dispose() {
    subNameController.dispose();
    vendorController.dispose();
    amountController.dispose();
    nextDueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        nextDueDateController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 550;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: screenHeight * 0.88,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))
                : BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Recurring Subscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF3F4F6), shape: const CircleBorder(), padding: const EdgeInsets.all(6)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Subscription Name'),
                      _buildField(subNameController, hint: 'e.g. AWS Cloud Server'),
                      const SizedBox(height: 14),

                      _buildLabel('Vendor Name'),
                      _buildField(vendorController, hint: 'e.g. Amazon Web Services'),
                      const SizedBox(height: 14),

                      _buildResponsiveRow(
                        context,
                        [
                          _buildDropdown('Category', category, ['Rent', 'Software / SaaS', 'Utilities', 'Marketing', 'Others'], (v) => setState(() => category = v!)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Amount (INR)'),
                              _buildField(amountController, hint: 'Enter amount', keyboardType: TextInputType.number),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildResponsiveRow(
                        context,
                        [
                          _buildDropdown('Frequency', frequency, ['Monthly', 'Yearly', 'Weekly'], (v) => setState(() => frequency = v!)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Next Due Date'),
                              InkWell(
                                onTap: _pickDate,
                                child: SizedBox(
                                  height: 42,
                                  child: TextField(
                                    controller: nextDueDateController,
                                    enabled: false,
                                    style: const TextStyle(fontSize: 13, color: AppColors.darkText),
                                    decoration: InputDecoration(
                                      hintText: '08-08-2026',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      suffixIcon: const Icon(LucideIcons.calendar, size: 16, color: AppColors.darkText),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildResponsiveRow(
                        context,
                        [
                          _buildDropdown('Auto-Post', autoPost, ['Active (Auto-Create)', 'Manual Review'], (v) => setState(() => autoPost = v!)),
                          _buildDropdown('Status', status, ['Active', 'Inactive'], (v) => setState(() => status = v!)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Blue Create Subscription Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = subNameController.text.trim();
                            final vendor = vendorController.text.trim();
                            final amt = amountController.text.trim();

                            ref.read(expensesSubscriptionsProvider.notifier).addSubscription({
                              'id': 'SUB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              'name': name.isNotEmpty ? name : 'Software Subscription',
                              'vendor': vendor.isNotEmpty ? vendor : 'Vendor',
                              'category': category,
                              'freq': frequency,
                              'nextDue': nextDueDateController.text,
                              'status': status,
                              'autoPost': autoPost.contains('Auto') ? 'Auto-Create' : 'Manual Review',
                              'cost': '₹${amt.isNotEmpty ? amt : '5,000'}',
                            });

                            AppSnackbar.show(context, "Recurring subscription created successfully!", type: SnackType.success);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Create Subscription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
    );
  }

  Widget _buildField(TextEditingController controller, {required String hint, TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 42,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: onChanged,
            icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF6B7280)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
        ),
      ],
    );
  }
}

// --- VERIFY VENDOR INVOICE MODAL (GSTR-2B ITC RECONCILIATION MATCHING IMAGE 2) ---
class VerifyVendorInvoiceModal extends ConsumerStatefulWidget {
  final Map<String, String>? initialData;
  final Function(Map<String, String>)? onSettle;

  const VerifyVendorInvoiceModal({super.key, this.initialData, this.onSettle});

  @override
  ConsumerState<VerifyVendorInvoiceModal> createState() => _VerifyVendorInvoiceModalState();
}

class _VerifyVendorInvoiceModalState extends ConsumerState<VerifyVendorInvoiceModal> {
  late TextEditingController gstinController;
  late TextEditingController vendorNameController;
  late TextEditingController amountController;
  String gstRate = '18% GST';
  String matchStatus = 'PENDING';

  @override
  void initState() {
    super.initState();
    gstinController = TextEditingController(text: widget.initialData?['gstin'] ?? '27AAAAA1111A1Z1');
    vendorNameController = TextEditingController(text: widget.initialData?['vendor'] ?? 'Acme Hardwares');
    amountController = TextEditingController(text: widget.initialData?['amount'] ?? '5,000');
    gstRate = widget.initialData?['gstRate'] ?? '18% GST';
    matchStatus = widget.initialData?['status'] ?? 'PENDING';
  }

  @override
  void dispose() {
    gstinController.dispose();
    vendorNameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: isMobile ? double.infinity : 520,
          constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24, top: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))
                : BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle Bar for Bottom Sheet
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),

              // Header with Close X Button matching Image 2
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Verify Vendor Invoice',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'GSTR-2B ITC Reconciliation',
                          style: TextStyle(fontSize: 11.5, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF4B5563)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vendor GSTIN & Vendor Name side-by-side row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Vendor GSTIN'),
                                _buildTextField(gstinController, hint: '27AAAAA1111A1Z1'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Vendor Name'),
                                _buildTextField(vendorNameController, hint: 'Acme Hardwares'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Invoice Total Amount (INR)
                      _buildLabel('Invoice Total Amount (INR)'),
                      _buildTextField(amountController, hint: '5,000', keyboardType: TextInputType.number),
                      const SizedBox(height: 14),

                      // GST Rate % & Match GSTR-2B side-by-side row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('GST Rate %'),
                                _buildDropdownSelect(
                                  value: gstRate,
                                  items: ['18% GST', '12% GST', '5% GST', '28% GST', '0% GST'],
                                  onChanged: (v) => setState(() => gstRate = v!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Match GSTR-2B'),
                                _buildDropdownSelect(
                                  value: matchStatus,
                                  items: ['PENDING', 'VERIFIED', 'MATCHED', 'MISMATCHED'],
                                  onChanged: (v) => setState(() => matchStatus = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Settle Reconciliation Status Primary Blue Button (Matching Image 2)
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            final data = {
                              'gstin': gstinController.text.trim(),
                              'vendor': vendorNameController.text.trim(),
                              'amount': amountController.text.trim(),
                              'gstRate': gstRate,
                              'status': matchStatus,
                            };
                            widget.onSettle?.call(data);
                            AppSnackbar.show(context, "Vendor invoice reconciled & status updated to $matchStatus!", type: SnackType.success);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8), // Royal Blue matching Image 2
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Settle Reconciliation Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
    );
  }

  Widget _buildTextField(TextEditingController controller, {required String hint, TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        ),
      ),
    );
  }

  Widget _buildDropdownSelect({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return SizedBox(
      height: 42,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
        )).toList(),
        onChanged: onChanged,
        icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF6B7280)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        ),
      ),
    );
  }
}

