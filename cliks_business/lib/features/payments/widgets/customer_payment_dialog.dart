import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/payment_models.dart';
import '../../../data/repositories/payments_repository.dart';
import '../../../widgets/app_ui_kit.dart';

class RecordCustomerPaymentDialog extends StatefulWidget {
  final PaymentTransaction? transaction;
  final List<PaymentAccount> accounts;
  final List<String>? customerOptions;
  final VoidCallback onPaymentSuccess;

  const RecordCustomerPaymentDialog({
    super.key,
    this.transaction,
    this.accounts = const [],
    this.customerOptions,
    required this.onPaymentSuccess,
  });

  @override
  State<RecordCustomerPaymentDialog> createState() => _RecordCustomerPaymentDialogState();
}

class _RecordCustomerPaymentDialogState extends State<RecordCustomerPaymentDialog> {
  late final TextEditingController _customerController;
  late final TextEditingController _invoiceIdController;
  late final TextEditingController _originalAmountController;
  late final TextEditingController _paidAmountController;
  late final TextEditingController _refIdController;
  late final TextEditingController _notesController;

  String _paymentMode = 'UPI';
  PaymentAccount? _selectedAccount;
  bool _isSubmitting = false;
  bool _isGeneratingGatewayOrder = false;
  String? _activeGatewaySession;

  final List<String> _paymentModes = const [
    'UPI',
    'Cash',
    'Bank Transfer',
    'Cheque',
    'Card',
    'Other',
  ];

  Future<void> _createOnlineGatewayOrder() async {
    final paidText = _paidAmountController.text.trim();
    final paidAmount = double.tryParse(paidText);

    if (paidAmount == null || paidAmount <= 0) {
      AppSnackbar.show(
        context,
        'Please enter a valid payment amount first to generate a gateway order',
        type: SnackType.warning,
      );
      return;
    }

    setState(() => _isGeneratingGatewayOrder = true);
    try {
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
      final req = CreatePaymentOrderRequest(
        amount: paidAmount,
        orderId: orderId,
        currency: 'INR',
      );
      final res = await PaymentsRepository.createPaymentOrder(req);
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final sessionId = data['payment_session_id']?.toString() ??
          data['order_id']?.toString() ??
          orderId;

      setState(() {
        _activeGatewaySession = sessionId;
        _refIdController.text = sessionId;
      });

      if (mounted) {
        AppSnackbar.show(
          context,
          'Online payment session initialized ($sessionId)',
          type: SnackType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Gateway setup failed: $e', type: SnackType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingGatewayOrder = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;

    _customerController = TextEditingController(
      text: tx?.partyName ?? '',
    );
    _invoiceIdController = TextEditingController(
      text: tx?.invoiceId ?? '',
    );
    _originalAmountController = TextEditingController(
      text: tx != null && tx.totalOriginal > 0 ? tx.totalOriginal.toStringAsFixed(2) : '',
    );
    _paidAmountController = TextEditingController(
      text: tx != null && tx.paidAmount > 0 ? tx.paidAmount.toStringAsFixed(2) : '',
    );
    _refIdController = TextEditingController(
      text: tx?.referenceNumber ?? '',
    );
    _notesController = TextEditingController();

    if (tx != null && _paymentModes.contains(tx.paymentMode)) {
      _paymentMode = tx.paymentMode;
    }

    // Default to first active account
    if (widget.accounts.isNotEmpty) {
      _selectedAccount = widget.accounts.firstWhere(
        (acc) => acc.isActive,
        orElse: () => widget.accounts.first,
      );
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _invoiceIdController.dispose();
    _originalAmountController.dispose();
    _paidAmountController.dispose();
    _refIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final paidText = _paidAmountController.text.trim();
    final paidAmount = double.tryParse(paidText);

    if (paidAmount == null || paidAmount <= 0) {
      AppSnackbar.show(
        context,
        'Please enter a valid payment amount greater than zero',
        type: SnackType.warning,
      );
      return;
    }

    if (paidAmount > kMaxAllowedAmount) {
      AppSnackbar.show(
        context,
        'Amount cannot exceed $kMaxAllowedAmountText',
        type: SnackType.warning,
      );
      return;
    }

    final origText = _originalAmountController.text.trim();
    final origAmount = double.tryParse(origText);

    setState(() => _isSubmitting = true);

    try {
      final req = ReceivePaymentRequest(
        amount: paidAmount,
        customerName: _customerController.text.trim().isNotEmpty ? _customerController.text.trim() : null,
        invoiceId: _invoiceIdController.text.trim().isNotEmpty ? _invoiceIdController.text.trim() : null,
        paymentMode: _paymentMode,
        referenceNumber: _refIdController.text.trim().isNotEmpty ? _refIdController.text.trim() : null,
        accountId: _selectedAccount?.id,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        totalOriginalAmount: origAmount != null && origAmount > 0 ? origAmount : paidAmount,
        paidAmount: paidAmount,
      );

      final res = await PaymentsRepository.receivePayment(req);
      final msg = res['message']?.toString() ?? 'Payment received successfully';

      if (!mounted) return;
      AppSnackbar.show(context, msg, type: SnackType.success);
      widget.onPaymentSuccess();
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, e.message, type: SnackType.error);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, 'Transaction failed: $e', type: SnackType.error);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          maxWidth: isMobile ? double.infinity : 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
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
                    // Receiving Account Selector
                    _buildLabel('Receiving Bank / Cash Account'),
                    _buildAccountDropdown(),
                    const SizedBox(height: 18),

                    // Customer Name
                    _buildLabel('Customer / Client Name'),
                    _buildCustomerField(),
                    const SizedBox(height: 18),

                    // Invoice and Original Amount
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Invoice Linked ID (Optional)'),
                              _buildTextField(
                                controller: _invoiceIdController,
                                hint: 'e.g. INV-2026-0042',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Original Bill Total (₹)'),
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
                    const SizedBox(height: 18),

                    // Amount Received
                    _buildLabel('Amount Received (Receipt worth, ₹) *'),
                    _buildTextField(
                      controller: _paidAmountController,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                        LengthLimitingTextInputFormatter(15),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Payment Mode & Reference Number
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Payment Mode'),
                              _buildDropdown(
                                value: _paymentMode,
                                items: _paymentModes,
                                onChanged: (v) {
                                  if (v != null) setState(() => _paymentMode = v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('UTR / Ref / Cheque No.'),
                              _buildTextField(
                                controller: _refIdController,
                                hint: 'e.g., UPI/9876543210/PAY',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_paymentMode == 'UPI' || _paymentMode == 'Card') ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _isGeneratingGatewayOrder ? null : _createOnlineGatewayOrder,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.zap, size: 16, color: Color(0xFF2563EB)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _activeGatewaySession != null
                                      ? 'Gateway Active: $_activeGatewaySession'
                                      : 'Generate UPI / Online Gateway Session (Cashfree)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_isGeneratingGatewayOrder)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF2563EB)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Notes (Optional)
                    _buildLabel('Notes / Remarks (Optional)'),
                    _buildTextField(
                      controller: _notesController,
                      hint: 'Payment memo or notes',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF084421),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor: const Color(0xFF084421).withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
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

  Widget _buildCustomerField() {
    final options = widget.customerOptions;
    if (options != null && options.isNotEmpty) {
      return Autocomplete<String>(
        initialValue: TextEditingValue(text: _customerController.text),
        optionsBuilder: (textEditingValue) {
          if (textEditingValue.text.isEmpty) return options;
          return options.where(
            (c) => c.toLowerCase().contains(textEditingValue.text.toLowerCase()),
          );
        },
        onSelected: (selection) {
          _customerController.text = selection;
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          // Keep controllers in sync
          controller.addListener(() {
            _customerController.text = controller.text;
          });
          return _buildTextField(
            controller: controller,
            hint: 'Search or enter customer name',
          );
        },
      );
    }

    return _buildTextField(
      controller: _customerController,
      hint: 'Enter customer name',
    );
  }

  Widget _buildAccountDropdown() {
    if (widget.accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5EAF4)),
        ),
        child: const Text(
          'Default Cash Account',
          style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EAF4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PaymentAccount>(
          value: _selectedAccount,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF5A7184)),
          items: widget.accounts.map((acc) {
            final balanceFmt = acc.currentBalance
                .toInt()
                .toString()
                .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

            return DropdownMenuItem<PaymentAccount>(
              value: acc,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: acc.isCash
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      acc.isCash ? 'CASH' : 'BANK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: acc.isCash ? const Color(0xFF047857) : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      acc.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₹ $balanceFmt',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (acc) {
            if (acc != null) {
              setState(() => _selectedAccount = acc);
            }
          },
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
          fontWeight: FontWeight.bold,
          color: Color(0xFF5A7184),
          letterSpacing: 0.3,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
