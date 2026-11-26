import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/models/goal_wallet_models.dart';
import '../../../data/repositories/goal_wallet_repository.dart';

class SetupTargetWalletDialog extends StatefulWidget {
  final String? activeEmail;
  final Function(GoalWallet)? onWalletCreated;

  const SetupTargetWalletDialog({
    super.key,
    this.activeEmail,
    this.onWalletCreated,
  });

  @override
  State<SetupTargetWalletDialog> createState() =>
      _SetupTargetWalletDialogState();
}

class _SetupTargetWalletDialogState extends State<SetupTargetWalletDialog> {
  final _purposeController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

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

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final purpose = _purposeController.text.trim();
    if (purpose.isEmpty) {
      AppSnackbar.show(
        context,
        'Please enter a purpose or name for this wallet',
        type: SnackType.warning,
      );
      return;
    }

    final amountStr = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(amountStr) ?? 0.0;
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

    final notes = _notesController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final req = CreateGoalWalletRequest(
        name: purpose,
        targetAmount: amount,
        description: notes.isNotEmpty ? notes : null,
      );

      final createdWallet = await GoalWalletRepository.createGoalWallet(
        req,
        email: widget.activeEmail,
      );

      if (!mounted) return;

      AppSnackbar.show(
        context,
        "Purpose wallet '${createdWallet.name}' activated successfully!",
        type: SnackType.success,
      );

      if (widget.onWalletCreated != null) {
        widget.onWalletCreated!(createdWallet);
      }

      Navigator.pop(context, createdWallet);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final errorMsg = e is ApiException ? e.message : e.toString();
      AppSnackbar.show(
        context,
        'Failed to activate purpose wallet: $errorMsg',
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.white,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 480,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                          'Setup Target Wallet',
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
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(
                      LucideIcons.x,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
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
                    _buildLabel('PURPOSE / ITEM NAME'),
                    _buildTextField(
                      controller: _purposeController,
                      hint: 'e.g. Tax Reserve, Equipment, Inventory',
                      prefixIcon: LucideIcons.tag,
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: 8),

                    // Purpose Quick Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _purposePresets.map((preset) {
                        return InkWell(
                          onTap: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _purposeController.text = preset;
                                  });
                                },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
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
                          onTap: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _amountController.text =
                                        preset['value'] as String;
                                  });
                                },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                              ),
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
                    _buildLabel('DESCRIPTIVE NOTES'),
                    _buildTextField(
                      controller: _notesController,
                      hint:
                          'Rationale or milestone conditions for this isolated reserve...',
                      maxLines: 2,
                      prefixIcon: LucideIcons.fileText,
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.pop(context),
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submit,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    LucideIcons.checkCircle2,
                                    size: 16,
                                  ),
                            label: Text(
                              _isSubmitting
                                  ? 'Activating...'
                                  : 'Activate Isolated Container',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
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
            child: const Text(
              '₹ INR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F5B2E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _amountController,
              enabled: !_isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                const CurrencyInputFormatter(
                  integerDigits: 12,
                  decimalDigits: 2,
                ),
                LengthLimitingTextInputFormatter(15),
              ],
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter target amount',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
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
    bool enabled = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: maxLines > 1 ? 10 : 0,
      ),
      height: maxLines > 1 ? 72 : 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
              child: Icon(prefixIcon, size: 16, color: const Color(0xFF64748B)),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              maxLines: maxLines,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
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
}
