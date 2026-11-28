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
      nameErr = 'Full identity name is required';
      isValid = false;
    } else if (rawName.length < 2) {
      nameErr = 'Name must be at least 2 characters';
      isValid = false;
    }

    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      phoneErr = '10-digit phone contact is required';
      isValid = false;
    } else if (rawPhone.length != 10) {
      phoneErr = 'Enter a valid 10-digit phone number';
      isValid = false;
    }

    final rawEmail = _emailController.text.trim().toLowerCase();
    if (rawEmail.isEmpty) {
      emailErr = 'E-mail address is required';
      isValid = false;
    } else if (!rawEmail.endsWith('@bnxmail.com')) {
      emailErr = 'Only @bnxmail.com accepted';
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
      relationship: _networkRole,
      phone: rawPhone,
      email: rawEmail,
      company: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : null,
    );

    if (widget.onSubmit != null) {
      setState(() => _isSubmitting = true);
      try {
        await widget.onSubmit!(req);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _generalError = e
                .toString()
                .replaceAll('ApiException: ', '')
                .replaceAll('Exception: ', '');
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
        'company': _companyController.text.trim().isEmpty
            ? '-'
            : _companyController.text.trim(),
        'phone': formattedPhone,
        'email': rawEmail,
        'ledgerStand': 0.0,
        'transactions': <Map<String, dynamic>>[],
        'repaymentAlerts': <Map<String, dynamic>>[],
      };
      widget.onContactCreated!(newContact);
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, true);
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
                        'Enroll New Contact',
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
                      key: const Key('close_enroll_contact_dialog'),
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

                // General Error Banner
                if (_generalError != null) ...[
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
                            _generalError!,
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

                // 1. Full Identity Name *
                _buildLabel('Full Identity Name *'),
                _buildTextField(
                  key: const Key('input_enroll_name'),
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
                const SizedBox(height: 16),

                // 2. Network Role & Company Label
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Network Role'),
                          _buildRoleDropdown(),
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
                            key: const Key('input_enroll_company'),
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
                const SizedBox(height: 16),

                // 3. Phone Contact * & E-Mail Address (bnxmail) *
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Phone Contact *'),
                          _buildTextField(
                            key: const Key('input_enroll_phone'),
                            controller: _phoneController,
                            hint: '10 digits (e.g. 987654321',
                            keyboardType: TextInputType.phone,
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
                          _buildLabel('E-Mail Address (bnxmail) *'),
                          _buildTextField(
                            key: const Key('input_enroll_email'),
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
                const SizedBox(height: 6),

                // Footnote caveat for email
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '* ',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Only @bnxmail.com accepted.\nRequest will be sent for approval.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Create Contact Node Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    key: const Key('btn_create_contact_node'),
                    onPressed: _isSubmitting ? null : _validateAndSubmit,
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
                            'Create Contact Node',
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

  Widget _buildRoleDropdown() {
    final roles = [
      'Friend',
      'Partner',
      'Investor',
      'Colleague',
      'Business',
      'Other',
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
          key: const Key('dropdown_network_role'),
          value: _networkRole,
          isExpanded: true,
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: Color(0xFF64748B),
          ),
          items: roles.map((r) {
            return DropdownMenuItem<String>(
              value: r,
              child: Text(
                r,
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
              setState(() => _networkRole = val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: key,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
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
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF0F4A2A),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
