import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';

class RecordCustomerPaymentDialog extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  final Function(Map<String, dynamic>) onSave;

  const RecordCustomerPaymentDialog({super.key, this.transaction, required this.onSave});

  @override
  State<RecordCustomerPaymentDialog> createState() => _RecordCustomerPaymentDialogState();
}

class _RecordCustomerPaymentDialogState extends State<RecordCustomerPaymentDialog> {
  final _invoiceIdController = TextEditingController(text: 'INV-2026-104');
  final _originalAmountController = TextEditingController(text: '10000');
  final _paidAmountController = TextEditingController(text: '4000');
  final _refIdController = TextEditingController(text: 'UPI-9092210A');
  
  String _customerProfile = 'Acme Corporates (Rahul Dev)';
  String _paymentMode = 'UPI';

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _invoiceIdController.text = widget.transaction!['invoice'] ?? '';
      _originalAmountController.text = widget.transaction!['total']?.toString() ?? '10000';
      _paidAmountController.text = widget.transaction!['paid']?.toString() ?? '4000';
      // Ensure the value exists in the dropdown list or use default
      final customers = ['Acme Corporates (Rahul Dev)', 'Dunder Mifflin', 'Stark Industries', 'Wayne Ent.'];
      _customerProfile = customers.contains(widget.transaction!['customer']) ? widget.transaction!['customer'] : 'Acme Corporates (Rahul Dev)';
      final modes = ['UPI', 'Cash', 'Bank Transfer', 'Cheque', 'Other'];
      _paymentMode = modes.contains(widget.transaction!['mode']) ? widget.transaction!['mode'] : 'UPI';
    }
  }

  @override
  void dispose() {
    _invoiceIdController.dispose();
    _originalAmountController.dispose();
    _paidAmountController.dispose();
    _refIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.65,
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
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Record Customer Payment',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
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
            const Divider(height: 1, color: AppColors.border),
            
            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Select Customer Profile'),
                    _buildDropdown(
                      value: _customerProfile,
                      items: ['Acme Corporates (Rahul Dev)', 'Dunder Mifflin', 'Stark Industries', 'Wayne Ent.'],
                      onChanged: (v) => setState(() => _customerProfile = v!),
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Invoice Linked ID'),
                              _buildTextField(
                                controller: _invoiceIdController,
                                hint: 'INV-...',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Original Amount (₹)'),
                              _buildTextField(
                                controller: _originalAmountController,
                                hint: '0.00',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                                  LengthLimitingTextInputFormatter(15),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildLabel('Paid amount (Receipt worth, ₹)'),
                    _buildTextField(
                      controller: _paidAmountController,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                        LengthLimitingTextInputFormatter(15),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Payment Mode'),
                              _buildDropdown(
                                value: _paymentMode,
                                items: ['UPI', 'Cash', 'Bank Transfer', 'Cheque', 'Other'],
                                onChanged: (v) => setState(() => _paymentMode = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Ref ID / UPI reference'),
                              _buildTextField(
                                controller: _refIdController,
                                hint: 'e.g., TXN123456',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final newTotal = double.tryParse(_originalAmountController.text) ?? 0.0;
                          final newPaid = double.tryParse(_paidAmountController.text) ?? 0.0;
                          
                          if (newTotal > kMaxAllowedAmount || newPaid > kMaxAllowedAmount) {
                            AppSnackbar.show(
                              context,
                              'Amount cannot exceed $kMaxAllowedAmountText',
                              type: SnackType.warning,
                            );
                            return;
                          }

                          widget.onSave({
                            'id': widget.transaction?['id'] ?? 'TXN-NEW',
                            'date': widget.transaction?['date'] ?? '12-08-2026',
                            'customer': _customerProfile,
                            'invoice': _invoiceIdController.text,
                            'total': newTotal,
                            'paid': newPaid,
                            'mode': _paymentMode,
                            'status': newPaid >= newTotal ? 'Reconciled' : 'Pending',
                            'type': 'Inward',
                            'overdue': widget.transaction?['overdue'] ?? false,
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF084421),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Finalize Payment Collection',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5A7184),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14, color: AppColors.darkText, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC1C7D0), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5EAF4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5EAF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF084421), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EAF4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF5A7184)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13, color: AppColors.darkText, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
