import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/people_models.dart';

class EnrollContactDialog extends StatefulWidget {
  final Future<void> Function(CreatePersonRequest)? onSubmit;
  final Function(Map<String, dynamic>)? onContactCreated;

  const EnrollContactDialog({
    super.key,
    this.onSubmit,
    this.onContactCreated,
  });

  @override
  State<EnrollContactDialog> createState() => _EnrollContactDialogState();
}

class _EnrollContactDialogState extends State<EnrollContactDialog> {
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _notesController = TextEditingController();

  String _networkRole = 'Friend';
  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _generalError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationshipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    if (_isSubmitting) return;

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
    if (rawPhone.isNotEmpty && rawPhone.length != 10) {
      phoneErr = 'Enter a valid 10-digit mobile number';
      isValid = false;
    }

    final rawEmail = _emailController.text.trim().toLowerCase();
    if (rawEmail.isEmpty) {
      emailErr = 'E-mail address is required';
      isValid = false;
    } else if (!rawEmail.endsWith('@bnxmail.com')) {
      emailErr = 'Email must end with @bnxmail.com as required by documentation';
      isValid = false;
    } else {
      final emailRegex = RegExp(r'^[\w\.-]+@bnxmail\.com$');
      if (!emailRegex.hasMatch(rawEmail)) {
        emailErr = 'Enter a valid username before @bnxmail.com';
        isValid = false;
      }
    }

    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
      _emailError = emailErr;
      _generalError = null;
    });

    if (!isValid) return;

    final req = CreatePersonRequest(
      name: rawName,
      roleType: _networkRole.toLowerCase(),
      relationship: _relationshipController.text.trim().isNotEmpty
          ? _relationshipController.text.trim()
          : _networkRole,
      phone: rawPhone,
      email: rawEmail,
      company: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (widget.onSubmit != null) {
      setState(() => _isSubmitting = true);
      try {
        await widget.onSubmit!(req);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _generalError = e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', '');
          });
        }
      }
    } else if (widget.onContactCreated != null) {
      final formattedPhone = rawPhone.length == 10
          ? '+91 ${rawPhone.substring(0, 5)} ${rawPhone.substring(5)}'
          : rawPhone;

      final newContact = {
        'id': 'c_${DateTime.now().millisecondsSinceEpoch}',
        'name': rawName,
        'classification': _networkRole.toUpperCase(),
        'company': _companyController.text.trim().isEmpty ? '-' : _companyController.text.trim(),
        'phone': formattedPhone,
        'email': rawEmail,
        'ledgerStand': 0.0,
        'transactions': <Map<String, dynamic>>[],
        'repaymentAlerts': <Map<String, dynamic>>[],
      };
      widget.onContactCreated!(newContact);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
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
        borderRadius: isMobile
            ? const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              )
            : BorderRadius.circular(24),
      ),
      insetPadding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: isMobile ? screenHeight * 0.85 : double.infinity,
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
                      'Add People Contact',
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

            if (_generalError != null)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _generalError!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Full Name', isRequired: true),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'e.g., Kiran Kumar',
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
                              _buildLabel('Role Type'),
                              _buildDropdown(
                                value: _networkRole,
                                items: [
                                  'Friend',
                                  'Partner',
                                  'Investor',
                                  'Colleague',
                                  'Business',
                                  'Other',
                                ],
                                onChanged: (v) => setState(() => _networkRole = v!),
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
                                hint: 'e.g. Kiran Ventures',
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
                              _buildLabel('Mobile Number', isRequired: false),
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
                              _buildLabel('E-Mail Address', isRequired: true),
                              _buildTextField(
                                controller: _emailController,
                                hint: 'username@bnxmail.com',
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

                    _buildLabel('Relationship Note / Specific Role'),
                    _buildTextField(
                      controller: _relationshipController,
                      hint: 'e.g. Investor, Senior Partner',
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('General Notes'),
                    _buildTextField(
                      controller: _notesController,
                      hint: 'Optional notes regarding peer relationship',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Enroll Contact',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
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
    TextInputType? keyboardType,
    String? prefixText,
    TextStyle? prefixStyle,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    ValueChanged<String>? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
            prefixText: prefixText,
            prefixStyle: prefixStyle,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFF166534),
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
              style: const TextStyle(fontSize: 11, color: Colors.red),
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
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: AppColors.secondaryText,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
