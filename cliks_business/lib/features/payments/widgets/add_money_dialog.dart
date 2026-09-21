import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';



class AddMoneyDialog extends StatefulWidget {
  const AddMoneyDialog({super.key});

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final _amountController = TextEditingController(text: '500.00');
  final _noteController = TextEditingController();
  String _selectedPaymentMethod = 'UPI / NetBanking';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 24 : 16)),
      insetPadding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Load Liquid Capital',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('SOURCE / PAYMENT METHOD'),
                    _buildDropdown(
                      value: _selectedPaymentMethod,
                      items: ['UPI / NetBanking', 'HDFC Primary Current A/c', 'ICICI Reserve A/c', 'Corporate Credit Card'],
                      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                    ),
                    const SizedBox(height: 12),
                    
                    // Quick info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF1E6F3F)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Instant node activation upon gateway handshake.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('LOAD AMOUNT (INR)'),
                    _buildAmountField(),
                    const SizedBox(height: 16),
                    
                    _buildLabel('BRIEF NOTE / DESCRIPTION'),
                    _buildTextField(
                      controller: _noteController,
                      hint: 'e.g. UPI Top-up, Bank Load',
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
                          if (amt <= 0) {
                            AppSnackbar.show(
                              context,
                              'Please enter a valid amount greater than ₹0',
                              type: SnackType.warning,
                            );
                            return;
                          }
                          if (amt > kMaxAllowedAmount) {
                            AppSnackbar.show(
                              context,
                              'Amount cannot exceed $kMaxAllowedAmountText',
                              type: SnackType.warning,
                            );
                            return;
                          }
                          AppSnackbar.show(
                            context,
                            '₹${amt.toStringAsFixed(2)} load initiated successfully',
                            type: SnackType.success,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E6F3F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Confirm & Authorize Load',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5A7184),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5EAF4)),
      ),
      child: Row(
        children: [
          const Text('₹', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                LengthLimitingTextInputFormatter(15),
              ],
              style: const TextStyle(fontSize: 14, color: AppColors.darkText, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.chevronUp, size: 10, color: Color(0xFF5A7184)),
              Icon(LucideIcons.chevronDown, size: 10, color: Color(0xFF5A7184)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 13, color: AppColors.darkText, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC1C7D0), fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5EAF4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5EAF4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E6F3F), width: 1.5),
        ),
      ),
    );
  }
}
