import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../widgets/app_ui_kit.dart';

class SchedulePaymentDialog extends StatefulWidget {
  final Function(Map<String, dynamic>)? onScheduled;
  final Map<String, dynamic>? initialData;

  const SchedulePaymentDialog({super.key, this.onScheduled, this.initialData});

  @override
  State<SchedulePaymentDialog> createState() => _SchedulePaymentDialogState();
}

class _SchedulePaymentDialogState extends State<SchedulePaymentDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late bool _isSending;
  late String _selectedFrequency;
  late String _selectedCategory;
  late String _selectedPerson;
  late DateTime _selectedDate;

  final List<String> _frequencies = [
    'Monthly (e.g. Rent, EMI)',
    'One-Time',
    'Weekly',
    'Quarterly',
    'Yearly',
  ];

  final List<String> _categories = [
    'Rent (Monthly)',
    'Utilities',
    'Vendor Bill',
    'Client Retainer',
    'Loan / EMI',
    'Salary / Stipend',
    'General',
  ];

  final List<String> _people = [
    'Select Person / Payee...',
    'kamesh (itsokletssee123@bnxmail.com)',
    'Rahul tewatiya (rahul.t@example.com)',
    'sridharan (sridharan@bnxmail.com)',
    'Walk-in Customer',
    'Admin (admin@bnxmail.com)',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialData;
    _nameController = TextEditingController(text: init?['name'] ?? '');
    _amountController = TextEditingController(
      text: init != null && init['amount'] != null
          ? ((init['amount'] as num).toDouble() == 0
                ? '0.00'
                : (init['amount'] as num).toDouble().toStringAsFixed(2))
          : '0.00',
    );
    _descriptionController = TextEditingController(
      text: init?['description'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: init?['description'] ?? init?['notes'] ?? '',
    );
    _isSending = init?['isSend'] ?? true;
    _selectedFrequency = init?['frequency'] ?? 'Monthly (e.g. Rent, EMI)';
    _selectedCategory = init?['category'] ?? 'Rent (Monthly)';
    _selectedPerson = init?['person'] ?? 'Select Person / Payee...';
    _selectedDate = DateTime.now();

    DateTime initialDate = DateTime.now();
    if (init != null) {
      final rawDate =
          init['rawDate'] ??
          init['due_date'] ??
          init['dueDate'] ??
          init['date'];
      if (rawDate != null) {
        final str = rawDate.toString().split('T').first;
        if (str.contains('-')) {
          initialDate = DateTime.tryParse(str) ?? DateTime.now();
        } else if (str.contains('/')) {
          final parts = str.split('/');
          if (parts.length == 3) {
            final d = int.tryParse(parts[0]) ?? 1;
            final m = int.tryParse(parts[1]) ?? 1;
            final y = int.tryParse(parts[2]) ?? DateTime.now().year;
            initialDate = DateTime(y, m, d);
          }
        }
      }
    }
    _selectedDate = initialDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyPreset({
    required String name,
    required String category,
    required String frequency,
    required bool isSend,
  }) {
    setState(() {
      _nameController.text = name;
      _selectedCategory = category;
      _selectedFrequency = frequency;
      _isSending = isSend;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF166534),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 580 ? screenWidth - 32 : 520.0;
    final amountVal =
        double.tryParse(_amountController.text.trim().replaceAll(',', '')) ??
        0.0;
    final isSubmitDisabled =
        amountVal <= 0 || _nameController.text.trim().isEmpty;

    final dateFormatted =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Close X
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.initialData != null
                              ? 'Edit Scheduled Payment'
                              : 'Schedule Payment',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Schedule transfers, monthly rent, and trigger automated email notifications',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.x,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Type Selector (I am Sending vs I am Receiving)
              Row(
                children: [
                  Expanded(
                    child: _buildTypeToggle(
                      label: 'I am Sending',
                      icon: LucideIcons.arrowUpRight,
                      isSelected: _isSending,
                      selectedColor: const Color(0xFFDC2626),
                      selectedBgColor: const Color(0xFFFEF2F2),
                      selectedBorderColor: const Color(0xFFEF4444),
                      onTap: () => setState(() => _isSending = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeToggle(
                      label: 'I am Receiving',
                      icon: LucideIcons.arrowDownLeft,
                      isSelected: !_isSending,
                      selectedColor: const Color(0xFF059669),
                      selectedBgColor: const Color(0xFFECFDF5),
                      selectedBorderColor: const Color(0xFF10B981),
                      onTap: () => setState(() => _isSending = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Quick Template Presets Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.zap,
                          size: 12,
                          color: Color(0xFFD97706),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'QUICK TEMPLATE PRESETS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD97706),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip(
                          label: 'Monthly Rent',
                          icon: '🏠',
                          onTap: () => _applyPreset(
                            name: 'Monthly Rent',
                            category: 'Rent (Monthly)',
                            frequency: 'Monthly (e.g. Rent, EMI)',
                            isSend: true,
                          ),
                        ),
                        _buildPresetChip(
                          label: 'Vendor Bill',
                          icon: '💼',
                          onTap: () => _applyPreset(
                            name: 'Vendor Invoice Bill',
                            category: 'Vendor Bill',
                            frequency: 'One-Time',
                            isSend: true,
                          ),
                        ),
                        _buildPresetChip(
                          label: 'Client Retainer',
                          icon: '🏢',
                          onTap: () => _applyPreset(
                            name: 'Client Retainer Monthly',
                            category: 'Client Retainer',
                            frequency: 'Monthly (e.g. Rent, EMI)',
                            isSend: false,
                          ),
                        ),
                        _buildPresetChip(
                          label: 'Utilities',
                          icon: '⚡',
                          onTap: () => _applyPreset(
                            name: 'Electricity / Internet Bill',
                            category: 'Utilities',
                            frequency: 'Monthly (e.g. Rent, EMI)',
                            isSend: true,
                          ),
                        ),
                        _buildPresetChip(
                          label: 'Loan / EMI',
                          icon: '📋',
                          onTap: () => _applyPreset(
                            name: 'Commercial Loan EMI',
                            category: 'Loan / EMI',
                            frequency: 'Monthly (e.g. Rent, EMI)',
                            isSend: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. REFERENCE NAME *
              _buildInputLabel('REFERENCE NAME *'),
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  'e.g. Monthly Rent, Client Retainer, Vendor Bill',
                ),
              ),
              const SizedBox(height: 16),

              // 5. Two-column: PAYMENT FREQUENCY & CATEGORY
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('PAYMENT FREQUENCY'),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _frequencies.contains(_selectedFrequency)
                                  ? _selectedFrequency
                                  : _frequencies.first,
                              isExpanded: true,
                              icon: const Icon(
                                LucideIcons.chevronDown,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              items: _frequencies.map((freq) {
                                return DropdownMenuItem(
                                  value: freq,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.repeat,
                                        size: 12,
                                        color: Color(0xFF7E22CE),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          freq,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedFrequency = v);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('CATEGORY'),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _categories.contains(_selectedCategory)
                                  ? _selectedCategory
                                  : _categories.first,
                              isExpanded: true,
                              icon: const Icon(
                                LucideIcons.chevronDown,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              items: _categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.tag,
                                        size: 12,
                                        color: Color(0xFFD97706),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          cat,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedCategory = v);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. LINK TO PERSON (OPTIONAL)
              _buildInputLabel('LINK TO PERSON (OPTIONAL)'),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _people.contains(_selectedPerson)
                        ? _selectedPerson
                        : _people.first,
                    isExpanded: true,
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    items: _people.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          p,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedPerson = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Two-column: AMOUNT (₹) * & SCHEDULED DATE *
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('AMOUNT (₹) *'),
                        TextFormField(
                          controller: _amountController,
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
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: _inputDecoration('0.00'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('SCHEDULED DATE *'),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateFormatted,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.calendar,
                                  size: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 8. Info Notification Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.mail, size: 15, color: Color(0xFF15803D)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Automated Email Notification Active: Instant confirmation email is dispatched via BNX Mail API upon scheduling. Monthly recurring payments (like rent) will automatically roll forward to next month when marked as paid.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF166534),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 9. Full Width Button (+ Schedule Payment)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: isSubmitDisabled
                      ? null
                      : () {
                          final name = _nameController.text.trim();
                          final amount =
                              double.tryParse(
                                _amountController.text.trim().replaceAll(
                                  ',',
                                  '',
                                ),
                              ) ??
                              0.0;

                          if (amount <= 0) {
                            AppSnackbar.show(
                              context,
                              'Please enter an amount greater than ₹0',
                              type: SnackType.warning,
                            );
                            return;
                          }
                          if (amount > kMaxAllowedAmount) {
                            AppSnackbar.show(
                              context,
                              'Amount cannot exceed $kMaxAllowedAmountText',
                              type: SnackType.warning,
                            );
                            return;
                          }

                          final isMonthly =
                              _selectedFrequency.toLowerCase().contains(
                                'monthly',
                              ) ||
                              _selectedCategory.toLowerCase().contains('rent');

                          final isoDate =
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

                          final newSchedule = {
                            'id':
                                widget.initialData?['id'] ??
                                'sch_${DateTime.now().millisecondsSinceEpoch}',
                            'name': name,
                            'amount': amount,
                            'isSend': _isSending,
                            'date': dateFormatted,
                            'rawDate': isoDate,
                            'frequency': isMonthly
                                ? 'Monthly Recurring'
                                : _selectedFrequency,
                            'category': _selectedCategory,
                            'status':
                                widget.initialData?['status'] ?? 'PENDING',
                            'autoNotified': true,
                            'person':
                                _selectedPerson != 'Select Person / Payee...'
                                ? _selectedPerson
                                : null,
                            'description': _descriptionController.text.trim(),
                            'notes': _descriptionController.text.trim(),
                          };

                          if (widget.onScheduled != null) {
                            widget.onScheduled!(newSchedule);
                          }
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.initialData != null
                        ? 'Update Payment'
                        : '+ Schedule Payment',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required Color selectedBgColor,
    required Color selectedBorderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? selectedBorderColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? selectedColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? selectedColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF166534), width: 1.5),
      ),
    );
  }
}
