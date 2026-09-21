import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class EnrollContactDialog extends StatefulWidget {
  final Function(Map<String, dynamic>)? onContactCreated;
  const EnrollContactDialog({super.key, this.onContactCreated});

  @override
  State<EnrollContactDialog> createState() => _EnrollContactDialogState();
}

class _EnrollContactDialogState extends State<EnrollContactDialog> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _pointsController = TextEditingController(text: '0');

  String _networkRole = 'Friend';
  String? _nameError;
  String? _phoneError;
  String? _emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    bool isValid = true;
    String? nameErr;
    String? phoneErr;
    String? emailErr;

    final rawName = _nameController.text.trim();
    if (rawName.isEmpty) {
      nameErr = 'Full name is required';
      isValid = false;
    } else if (rawName.length < 2) {
      nameErr = 'Name must be at least 2 characters';
      isValid = false;
    }

    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      phoneErr = 'Mobile number is required';
      isValid = false;
    } else if (rawPhone.length != 10) {
      phoneErr = 'Enter a valid 10-digit mobile number';
      isValid = false;
    }

    final rawEmail = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (rawEmail.isNotEmpty && !emailRegex.hasMatch(rawEmail)) {
      emailErr = 'Enter a valid email address';
      isValid = false;
    }

    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
      _emailError = emailErr;
    });

    if (!isValid) return;

    final formattedPhone =
        rawPhone.length == 10
            ? '+91 ${rawPhone.substring(0, 5)} ${rawPhone.substring(5)}'
            : rawPhone;

    final newContact = {
      'id': 'c_${DateTime.now().millisecondsSinceEpoch}',
      'name': rawName,
      'classification': _networkRole.toUpperCase(),
      'company':
          _companyController.text.trim().isEmpty
              ? '-'
              : _companyController.text.trim(),
      'phone': formattedPhone,
      'email': rawEmail.isEmpty ? '-' : rawEmail,
      'ledgerStand': 0.0,
      'transactions': <Map<String, dynamic>>[],
      'repaymentAlerts': <Map<String, dynamic>>[],
    };

    if (widget.onContactCreated != null) {
      widget.onContactCreated!(newContact);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.white,
      alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius:
            isMobile
                ? const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                )
                : BorderRadius.circular(24),
      ),
      insetPadding:
          isMobile
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: isMobile ? screenHeight * 0.75 : double.infinity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMobile) ...[
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
            ],
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20, isMobile ? 8 : 16, 12, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Enroll New Contact',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF084421),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.secondaryText,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                    _buildLabel('Full Identity Name', isRequired: true),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'e.g., Rahul Dev',
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      textCapitalization: TextCapitalization.words,
                      errorText: _nameError,
                      onChanged: (v) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Network Role'),
                              _buildDropdown(
                                value: _networkRole,
                                items: [
                                  'Friend',
                                  'Family',
                                  'Colleague',
                                  'Business',
                                  'Other',
                                ],
                                onChanged:
                                    (v) => setState(() => _networkRole = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Company Label'),
                              _buildTextField(
                                controller: _companyController,
                                hint: 'Dunder Mifflin',
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(40),
                                ],
                                textCapitalization: TextCapitalization.words,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Phone Contact', isRequired: true),
                              _buildTextField(
                                controller: _phoneController,
                                hint: '9876543210',
                                keyboardType: TextInputType.phone,
                                prefixText: '+91 ',
                                prefixStyle: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w600,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                errorText: _phoneError,
                                onChanged: (v) {
                                  if (_phoneError != null) {
                                    setState(() => _phoneError = null);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('E-Mail Address'),
                              _buildTextField(
                                controller: _emailController,
                                hint: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(60),
                                ],
                                errorText: _emailError,
                                onChanged: (v) {
                                  if (_emailError != null) {
                                    setState(() => _emailError = null);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Initial Loyalty Points'),
                    _buildTextField(
                      controller: _pointsController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF084421),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Create Contact Node',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A7184),
            letterSpacing: 0.5,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
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
    String? errorText,
    String? prefixText,
    TextStyle? prefixStyle,
    ValueChanged<String>? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.darkText,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFC1C7D0),
              fontSize: 12,
            ),
            prefixText: prefixText,
            prefixStyle: prefixStyle,
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    errorText != null
                        ? Colors.red
                        : const Color(0xFFE5EAF4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    errorText != null
                        ? Colors.red
                        : const Color(0xFFE5EAF4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    errorText != null
                        ? Colors.red
                        : const Color(0xFF084421),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
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
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 14,
            color: Color(0xFF5A7184),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
