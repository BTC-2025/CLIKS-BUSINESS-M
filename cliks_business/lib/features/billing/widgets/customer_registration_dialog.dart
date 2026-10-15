import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomerFormData {
  final String name;
  final String shopName;
  final String customerType;
  final String phone;
  final String alternatePhone;
  final String email;
  final String website;
  final String gstin;
  final String panNumber;
  final String taxType;
  final String placeOfSupply;
  final String shippingAddress;
  final double openingBalance;
  final double creditLimit;
  final int dueDays;
  final String preferredReminder;
  final String accountStatus;

  CustomerFormData({
    required this.name,
    this.shopName = '',
    this.customerType = 'Wholesale',
    required this.phone,
    this.alternatePhone = '',
    this.email = '',
    this.website = '',
    this.gstin = '',
    this.panNumber = '',
    this.taxType = 'Registered Business',
    this.placeOfSupply = 'Delhi',
    this.shippingAddress = '',
    this.openingBalance = 0.0,
    this.creditLimit = 50000.0,
    this.dueDays = 30,
    this.preferredReminder = 'WhatsApp',
    this.accountStatus = 'Active',
  });
}

class CustomerRegistrationDialog extends StatefulWidget {
  final VoidCallback? onClose;
  final ValueChanged<CustomerFormData>? onCustomerRegistered;

  const CustomerRegistrationDialog({
    super.key,
    this.onClose,
    this.onCustomerRegistered,
  });

  @override
  State<CustomerRegistrationDialog> createState() =>
      _CustomerRegistrationDialogState();
}

class _CustomerRegistrationDialogState
    extends State<CustomerRegistrationDialog> {
  final _nameCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  final _gstinCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _placeCtrl = TextEditingController(text: 'Delhi');
  final _addressCtrl = TextEditingController();

  final _openingBalanceCtrl = TextEditingController(text: '0');
  final _creditLimitCtrl = TextEditingController(text: '50000');
  final _dueDaysCtrl = TextEditingController(text: '30');

  String _customerType = 'Wholesale';
  String _taxType = 'Registered Business';
  String _preferredReminder = 'WhatsApp';
  String _accountStatus = 'Active';

  int _addressCharCount = 0;

  @override
  void initState() {
    super.initState();
    _addressCtrl.addListener(() {
      if (mounted) {
        setState(() {
          _addressCharCount = _addressCtrl.text.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shopCtrl.dispose();
    _phoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _gstinCtrl.dispose();
    _panCtrl.dispose();
    _placeCtrl.dispose();
    _addressCtrl.dispose();
    _openingBalanceCtrl.dispose();
    _creditLimitCtrl.dispose();
    _dueDaysCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter customer name'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final data = CustomerFormData(
      name: _nameCtrl.text.trim(),
      shopName: _shopCtrl.text.trim(),
      customerType: _customerType,
      phone: _phoneCtrl.text.trim(),
      alternatePhone: _altPhoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      gstin: _gstinCtrl.text.trim(),
      panNumber: _panCtrl.text.trim(),
      taxType: _taxType,
      placeOfSupply: _placeCtrl.text.trim(),
      shippingAddress: _addressCtrl.text.trim(),
      openingBalance: double.tryParse(_openingBalanceCtrl.text.trim()) ?? 0.0,
      creditLimit: double.tryParse(_creditLimitCtrl.text.trim()) ?? 50000.0,
      dueDays: int.tryParse(_dueDaysCtrl.text.trim()) ?? 30,
      preferredReminder: _preferredReminder,
      accountStatus: _accountStatus,
    );

    widget.onCustomerRegistered?.call(data);

    if (widget.onClose != null) {
      widget.onClose!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 700;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 820,
          maxHeight: screenHeight * 0.94,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── DIALOG HEADER ───
            _buildHeader(isMobile),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // ─── SCROLLABLE CONTENT BODY ───
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Basic Information
                    _buildSectionCard(
                      icon: LucideIcons.store,
                      title: 'Basic Information',
                      subtitle: 'Enter customer and contact details.',
                      trailingText: '* Required fields',
                      trailingTextColor: const Color(0xFFEF4444),
                      child: _buildBasicInfoFields(isMobile),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Tax & Address Details
                    _buildSectionCard(
                      icon: LucideIcons.fileText,
                      title: 'Tax & Address Details',
                      subtitle: 'Add tax information and place of supply.',
                      child: _buildTaxAndAddressFields(isMobile),
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Financial & Preference Details
                    _buildSectionCard(
                      icon: LucideIcons.creditCard,
                      title: 'Financial & Preference Details',
                      subtitle:
                          'Set credit, payment terms and communication preferences.',
                      child: _buildFinancialFields(isMobile),
                    ),
                  ],
                ),
              ),
            ),

            // ─── DIALOG FOOTER ───
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 22,
        vertical: isMobile ? 14 : 16,
      ),
      child: Row(
        children: [
          // Purple User Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.user,
                color: Color(0xFF7C3AED),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'New Customer Registration',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  'Add customer details to start doing business with them.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Code Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Code: CUST-2406',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Close Button
          InkWell(
            onTap: () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                LucideIcons.x,
                size: 15,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION CARD WRAPPER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    Color? trailingTextColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE9FE), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(icon, color: const Color(0xFF7C3AED), size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: trailingTextColor ?? const Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION 1: BASIC INFORMATION
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBasicInfoFields(bool isMobile) {
    final customerNameField = _buildInputField(
      label: 'Customer Name',
      isRequired: true,
      hintText: 'e.g. Rajesh Gupta',
      controller: _nameCtrl,
      prefixIcon: LucideIcons.user,
    );

    final shopNameField = _buildInputField(
      label: 'Shop / Business Name',
      hintText: 'e.g. Gupta Groceries World',
      controller: _shopCtrl,
      prefixIcon: LucideIcons.store,
    );

    final customerTypeField = _buildDropdownField(
      label: 'Customer Type / Group',
      value: _customerType,
      items: const ['Wholesale', 'Retail', 'Distributor', 'Corporate'],
      prefixIcon: LucideIcons.store,
      onChanged: (val) {
        if (val != null) setState(() => _customerType = val);
      },
    );

    final phoneField = _buildPhoneInputField(
      label: 'Phone Number',
      isRequired: true,
      hintText: 'e.g. 9876543210',
      controller: _phoneCtrl,
    );

    final altPhoneField = _buildPhoneInputField(
      label: 'Alternate Phone',
      hintText: 'e.g. 9123456780',
      controller: _altPhoneCtrl,
    );

    final emailField = _buildInputField(
      label: 'Email Address',
      importantTag: '(important)',
      hintText: 'e.g. customer@bnxmail.com',
      controller: _emailCtrl,
      prefixIcon: LucideIcons.mail,
      helperText: 'Please use a @bnxmail.com email address.',
      keyboardType: TextInputType.emailAddress,
    );

    final websiteField = _buildInputField(
      label: 'Website',
      hintText: 'e.g. www.business.com',
      controller: _websiteCtrl,
      prefixIcon: LucideIcons.globe,
      keyboardType: TextInputType.url,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customerNameField,
          const SizedBox(height: 12),
          shopNameField,
          const SizedBox(height: 12),
          customerTypeField,
          const SizedBox(height: 12),
          phoneField,
          const SizedBox(height: 12),
          altPhoneField,
          const SizedBox(height: 12),
          emailField,
          const SizedBox(height: 12),
          websiteField,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Customer Name, Shop Name, Type
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: customerNameField),
            const SizedBox(width: 12),
            Expanded(child: shopNameField),
            const SizedBox(width: 12),
            Expanded(child: customerTypeField),
          ],
        ),
        const SizedBox(height: 14),

        // Row 2: Phone, Alternate Phone
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: phoneField),
            const SizedBox(width: 12),
            Expanded(child: altPhoneField),
          ],
        ),
        const SizedBox(height: 14),

        // Row 3: Email, Website
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: emailField),
            const SizedBox(width: 12),
            Expanded(child: websiteField),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION 2: TAX & ADDRESS DETAILS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTaxAndAddressFields(bool isMobile) {
    final gstinField = _buildInputField(
      label: 'GSTIN',
      hintText: 'e.g. 27AABCU9603R1ZN',
      controller: _gstinCtrl,
      prefixIcon: LucideIcons.creditCard,
    );

    final panField = _buildInputField(
      label: 'PAN Number',
      hintText: 'e.g. ABCDE1234F',
      controller: _panCtrl,
      prefixIcon: LucideIcons.idCard,
    );

    final taxTypeField = _buildDropdownField(
      label: 'Tax Type',
      value: _taxType,
      items: const [
        'Registered Business',
        'Unregistered Business',
        'Composition Scheme',
        'Consumer'
      ],
      onChanged: (val) {
        if (val != null) setState(() => _taxType = val);
      },
    );

    final placeField = _buildInputField(
      label: 'Place of Supply',
      hintText: 'Delhi',
      controller: _placeCtrl,
      prefixIcon: LucideIcons.mapPin,
    );

    final addressField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Address',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2, right: 8),
                    child: Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _addressCtrl,
                      minLines: 2,
                      maxLines: 3,
                      maxLength: 300,
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) =>
                          null,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Plot 45, Godown Hub, Industrial Area',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '$_addressCharCount/300',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gstinField,
          const SizedBox(height: 12),
          panField,
          const SizedBox(height: 12),
          taxTypeField,
          const SizedBox(height: 12),
          placeField,
          const SizedBox(height: 12),
          addressField,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: GSTIN, PAN Number, Tax Type, Place of Supply
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: gstinField),
            const SizedBox(width: 12),
            Expanded(child: panField),
            const SizedBox(width: 12),
            Expanded(child: taxTypeField),
            const SizedBox(width: 12),
            Expanded(child: placeField),
          ],
        ),
        const SizedBox(height: 14),
        addressField,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION 3: FINANCIAL & PREFERENCE DETAILS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildFinancialFields(bool isMobile) {
    final openingBalanceField = _buildInputField(
      label: 'Opening Balance (₹)',
      hintText: '0',
      controller: _openingBalanceCtrl,
      prefixText: '₹ ',
      helperText: 'Use negative for advance payment',
      keyboardType: TextInputType.number,
    );

    final creditLimitField = _buildInputField(
      label: 'Credit Limit (₹)',
      hintText: '50000',
      controller: _creditLimitCtrl,
      prefixText: '₹ ',
      keyboardType: TextInputType.number,
    );

    final dueDaysField = _buildInputField(
      label: 'Due Days (Terms)',
      hintText: '30',
      controller: _dueDaysCtrl,
      prefixIcon: LucideIcons.calendar,
      keyboardType: TextInputType.number,
    );

    final reminderField = _buildDropdownField(
      label: 'Preferred Reminder',
      value: _preferredReminder,
      items: const ['WhatsApp', 'SMS', 'Email', 'Phone Call'],
      prefixIcon: LucideIcons.bell,
      onChanged: (val) {
        if (val != null) setState(() => _preferredReminder = val);
      },
    );

    final accountStatusField = _buildDropdownField(
      label: 'Account Status',
      value: _accountStatus,
      items: const ['Active', 'Inactive', 'Suspended'],
      onChanged: (val) {
        if (val != null) setState(() => _accountStatus = val);
      },
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          openingBalanceField,
          const SizedBox(height: 12),
          creditLimitField,
          const SizedBox(height: 12),
          dueDaysField,
          const SizedBox(height: 12),
          reminderField,
          const SizedBox(height: 12),
          accountStatusField,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Opening Balance, Credit Limit, Due Days, Preferred Reminder
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: openingBalanceField),
            const SizedBox(width: 12),
            Expanded(child: creditLimitField),
            const SizedBox(width: 12),
            Expanded(child: dueDaysField),
            const SizedBox(width: 12),
            Expanded(child: reminderField),
          ],
        ),
        const SizedBox(height: 14),
        // Row 2: Account Status
        SizedBox(
          width: 200,
          child: accountStatusField,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FOOTER ACTIONS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildFooter(bool isMobile) {
    final cancelBtn = OutlinedButton(
      onPressed: () {
        if (widget.onClose != null) {
          widget.onClose!();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Cancel',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );

    final registerBtn = ElevatedButton.icon(
      onPressed: _handleSubmit,
      icon: const Icon(LucideIcons.check, size: 16, color: Colors.white),
      label: const Text(
        'Register Customer',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 22,
        vertical: 14,
      ),
      child: isMobile
          ? Row(
              children: [
                Expanded(child: cancelBtn),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: registerBtn),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cancelBtn,
                registerBtn,
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // REUSABLE INPUT BUILDERS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildInputField({
    required String label,
    bool isRequired = false,
    String? importantTag,
    required String hintText,
    required TextEditingController controller,
    IconData? prefixIcon,
    String? prefixText,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              if (importantTag != null)
                TextSpan(
                  text: ' $importantTag',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 16, color: const Color(0xFF94A3B8))
                  : (prefixText != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 12, right: 4, top: 11),
                          child: Text(
                            prefixText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        )
                      : null),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneInputField({
    required String label,
    bool isRequired = false,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              // +91 Country Selector Prefix
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🇮🇳', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 22,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.phone,
                size: 15,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    IconData? prefixIcon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 16, color: const Color(0xFF94A3B8)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: items.contains(value) ? value : items.first,
                    isExpanded: true,
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A),
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
