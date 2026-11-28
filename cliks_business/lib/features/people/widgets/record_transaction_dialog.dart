import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/people_models.dart';
import '../../../widgets/app_ui_kit.dart';

class RecordTransactionDialog extends StatefulWidget {
  final List<PersonContact> contacts;
  final Future<void> Function(
    dynamic personId,
    String type,
    double amount,
    String date,
    String? description,
  )? onSubmit;
  final Function(Map<String, dynamic>)? onTransactionCreated;

  const RecordTransactionDialog({
    super.key,
    this.contacts = const [],
    this.onSubmit,
    this.onTransactionCreated,
  });

  @override
  State<RecordTransactionDialog> createState() => _RecordTransactionDialogState();
}

class _RecordTransactionDialogState extends State<RecordTransactionDialog> {
  final _amountController = TextEditingController(text: '0.00');
  final _memoController = TextEditingController();

  PersonContact? _selectedContact;
  String _entryDirection = 'I Lent Assets / Money';
  DateTime _selectedDate = DateTime.now();
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.contacts.isNotEmpty) {
      _selectedContact = widget.contacts.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F4A2A),
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (_selectedContact == null && widget.contacts.isNotEmpty) {
      setState(() {
        _errorMessage = 'Please select a contact from the registry';
      });
      return;
    }

    final amtStr = _amountController.text.trim().replaceAll(',', '');
    final amt = double.tryParse(amtStr) ?? 0.0;
    if (amt <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount greater than ₹0';
      });
      return;
    }
    if (amt > kMaxAllowedAmount) {
      setState(() {
        _errorMessage = 'Amount cannot exceed $kMaxAllowedAmountText';
      });
      return;
    }

    final type = _entryDirection.contains('Lent') ? 'lent' : 'borrowed';
    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final memo = _memoController.text.trim();

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      if (widget.onSubmit != null && _selectedContact != null) {
        await widget.onSubmit!(
          _selectedContact!.id,
          type,
          amt,
          formattedDate,
          memo.isNotEmpty ? memo : null,
        );
      } else if (widget.onTransactionCreated != null) {
        widget.onTransactionCreated!({
          'contact': _selectedContact?.name ?? 'Unknown',
          'type': type,
          'amount': amt,
          'date': formattedDate,
          'description': memo,
        });
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e
              .toString()
              .replaceAll('ApiException: ', '')
              .replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.white,
      alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: isMobile
            ? const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              )
            : BorderRadius.circular(24),
      ),
      insetPadding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title and Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Record Peer Transaction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F4A2A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      key: const Key('close_record_peer_tx_dialog'),
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Error Message if any
                if (_errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertTriangle,
                            size: 16, color: Color(0xFFDC2626)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 1. Target Network User
                _buildLabel('Target Network User'),
                _buildContactDropdown(),
                const SizedBox(height: 16),

                // 2. Entry Direction & Ledger Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Entry Direction'),
                          _buildDirectionDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Ledger Date'),
                          _buildDatePicker(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Value Cap Amount (₹)
                _buildLabel('Value Cap Amount (₹)'),
                _buildTextField(
                  key: const Key('input_peer_tx_amount'),
                  controller: _amountController,
                  hint: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    const CurrencyInputFormatter(
                        integerDigits: 12, decimalDigits: 2),
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Asset narrative / Memo
                _buildLabel('Asset narrative / Memo'),
                _buildTextField(
                  key: const Key('input_peer_tx_memo'),
                  controller: _memoController,
                  hint: 'e.g., Advance for marketing services',
                  maxLines: 1,
                ),
                const SizedBox(height: 24),

                // 5. Authorize Entry Log Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    key: const Key('btn_authorize_entry_log'),
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4A2A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Authorize Entry Log',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildContactDropdown() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PersonContact?>(
          key: const Key('dropdown_target_network_user'),
          value: _selectedContact,
          isExpanded: true,
          hint: const Text(
            'Select contact from registry...',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: Color(0xFF64748B),
          ),
          items: widget.contacts.map((c) {
            final companyText =
                (c.company != null && c.company!.isNotEmpty) ? ' • ${c.company}' : '';
            return DropdownMenuItem<PersonContact?>(
              value: c,
              child: Text(
                '${c.name}$companyText',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedContact = val;
              if (_errorMessage != null) _errorMessage = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDirectionDropdown() {
    final options = [
      'I Lent Assets / Money',
      'I Borrowed Assets / Money',
    ];

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: const Key('dropdown_entry_direction'),
          value: _entryDirection,
          isExpanded: true,
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: Color(0xFF64748B),
          ),
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(
                opt,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _entryDirection = val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final formatted =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return InkWell(
      key: const Key('picker_ledger_date'),
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatted,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              LucideIcons.calendar,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.darkText,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0F4A2A), width: 1.5),
        ),
      ),
    );
  }
}
