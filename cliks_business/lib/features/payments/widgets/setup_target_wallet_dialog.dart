import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../core/theme/app_colors.dart';

class SetupTargetWalletDialog extends StatefulWidget {
  final Function(Map<String, dynamic>)? onWalletCreated;

  const SetupTargetWalletDialog({super.key, this.onWalletCreated});

  @override
  State<SetupTargetWalletDialog> createState() => _SetupTargetWalletDialogState();
}

class _SetupTargetWalletDialogState extends State<SetupTargetWalletDialog> {
  final _purposeController = TextEditingController();
  // Field starts completely empty - no default 5000 prefilled
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  static const List<String> _purposePresets = [
    'Tax Reserve',
    'Inventory Stock',
    'Equipment Purchase',
    'Emergency Buffer',
    'Office Upgrade',
  ];

  static const List<Map<String, dynamic>> _amountPresets = [
    {'label': '₹5,000', 'value': '5000'},
    {'label': '₹10,000', 'value': '10000'},
    {'label': '₹25,000', 'value': '25000'},
    {'label': '₹50,000', 'value': '50000'},
    {'label': '₹1,00,000', 'value': '100000'},
  ];

  @override
  void dispose() {
    _purposeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final purpose = _purposeController.text.trim();
    if (purpose.isEmpty) {
      AppSnackbar.show(
        context,
        'Please enter a purpose or name for this wallet',
        type: SnackType.warning,
      );
      return;
    }
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      AppSnackbar.show(
        context,
        'Please enter a target amount greater than ₹0',
        type: SnackType.warning,
      );
      return;
    }
    if (amount > kMaxAllowedAmount) {
      AppSnackbar.show(
        context,
        'Target cap cannot exceed $kMaxAllowedAmountText',
        type: SnackType.warning,
      );
      return;
    }
    final newWallet = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': purpose,
      'status': 'GROWING',
      'statusColor': const Color(0xFF10B981),
      'saved': 0.0,
      'target': amount,
      'notes': _notesController.text.trim().isEmpty
          ? 'Purpose-driven isolated container'
          : _notesController.text.trim(),
      'isClaimed': false,
    };
    if (widget.onWalletCreated != null) {
      widget.onWalletCreated!(newWallet);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.white,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 480,
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Icon(
                      LucideIcons.walletCards,
                      size: 20,
                      color: Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Setup Purpose Wallet',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Isolate and lock funds toward a dedicated business goal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Purpose / Item Name
                    _buildLabel('PURPOSE / CONTAINER NAME'),
                    _buildTextField(
                      controller: _purposeController,
                      hint: 'e.g. Tax Reserve, Equipment, Inventory',
                      prefixIcon: LucideIcons.tag,
                    ),
                    const SizedBox(height: 8),

                    // Purpose Quick Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _purposePresets.map((preset) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _purposeController.text = preset;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              '+ $preset',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Target Cap Amount (INR)
                    _buildLabel('TARGET CAP AMOUNT (INR)'),
                    _buildAmountField(),
                    const SizedBox(height: 8),

                    // Quick Amount Suggestions
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _amountPresets.map((preset) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _amountController.text = preset['value'] as String;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              preset['label'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Descriptive Notes
                    _buildLabel('DESCRIPTIVE NOTES & MEMO'),
                    _buildTextField(
                      controller: _notesController,
                      hint: 'Rationale or milestone conditions for this isolated reserve...',
                      maxLines: 2,
                      prefixIcon: LucideIcons.fileText,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF475569),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(LucideIcons.checkCircle2, size: 16),
                            label: const Text(
                              'Activate Purpose Wallet',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.stylishDarkGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '₹ INR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.stylishDarkGreen,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _amountController,
              autofocus: false,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                LengthLimitingTextInputFormatter(15),
              ],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 16, color: const Color(0xFF94A3B8))
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.stylishDarkGreen, width: 1.5),
        ),
      ),
    );
  }
}
