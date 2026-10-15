import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';

class RegisterSupplierPage extends ConsumerStatefulWidget {
  const RegisterSupplierPage({super.key});

  @override
  ConsumerState<RegisterSupplierPage> createState() => _RegisterSupplierPageState();
}

class _RegisterSupplierPageState extends ConsumerState<RegisterSupplierPage> {
  // Card 1: Basic Information
  final TextEditingController _businessNameCtrl = TextEditingController();
  final TextEditingController _contactPersonCtrl = TextEditingController();
  String _supplierType = 'Local Supplier';
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _altPhoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();

  // Card 2: Tax & Registration Details
  final TextEditingController _gstinCtrl = TextEditingController();
  final TextEditingController _panCtrl = TextEditingController();
  String _taxRegistration = 'Registered Business';
  String _stateOfSupply = 'Maharashtra';

  // Card 3: Address Details
  final TextEditingController _billingAddressCtrl = TextEditingController();
  final TextEditingController _shippingAddressCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _pincodeCtrl = TextEditingController();

  // Card 4: Banking & Payment Terms
  final TextEditingController _bankAccountCtrl = TextEditingController();
  final TextEditingController _ifscCtrl = TextEditingController();
  final TextEditingController _upiCtrl = TextEditingController();
  final TextEditingController _openingBalanceCtrl = TextEditingController(text: '0');
  final TextEditingController _creditLimitCtrl = TextEditingController(text: '200000');
  String _paymentTerms = 'Net 30';

  final String _vendorCode = 'SUP-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}';

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _contactPersonCtrl.dispose();
    _mobileCtrl.dispose();
    _altPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _gstinCtrl.dispose();
    _panCtrl.dispose();
    _billingAddressCtrl.dispose();
    _shippingAddressCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    _bankAccountCtrl.dispose();
    _ifscCtrl.dispose();
    _upiCtrl.dispose();
    _openingBalanceCtrl.dispose();
    _creditLimitCtrl.dispose();
    super.dispose();
  }

  void _navigateBack() {
    ref.read(navigationProvider.notifier).setRoute(AppRoute.suppliers);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: isMobile ? Colors.white : Colors.black45,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 820,
              maxHeight: isMobile ? double.infinity : MediaQuery.of(context).size.height * 0.94,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : 24,
              vertical: isMobile ? 0 : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 0 : 24),
              boxShadow: isMobile
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 0 : 24),
              child: Column(
                children: [
                  // 1. TOP HEADER (Screenshots 1 & 2)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.building2, size: 20, color: Color(0xFF16A34A)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Register Vendor Master Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Provide your business and contact details to get started.',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            'Code: $_vendorCode',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _navigateBack,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // 2. SCROLLABLE FORM BODY (Screenshots 1 & 2)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          // CARD 1: Basic Information
                          _buildBasicInformationCard(),

                          const SizedBox(height: 16),

                          // CARD 2: Tax & Registration Details
                          _buildTaxRegistrationCard(),

                          const SizedBox(height: 16),

                          // CARD 3: Address Details
                          _buildAddressDetailsCard(),

                          const SizedBox(height: 16),

                          // CARD 4: Banking & Payment Terms
                          _buildBankingAndPaymentCard(),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // 3. BOTTOM ACTIONS (Cancel & Initialize buttons)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: _navigateBack,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_businessNameCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter Supplier / Business Name')),
                              );
                              return;
                            }
                            _navigateBack();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Supplier ${_businessNameCtrl.text} registered successfully!'),
                                backgroundColor: const Color(0xFF059669),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.check, size: 16, color: Colors.white),
                          label: const Text(
                            'Initialize Supplier Master Profile',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD 1: Basic Information
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildBasicInformationCard() {
    return _buildFormCard(
      icon: LucideIcons.user,
      title: 'Basic Information',
      subtitle: 'Enter your business name and contact details.',
      trailing: const Text('* Required fields', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final f1 = _buildInputField(label: 'Supplier / Business Name *', controller: _businessNameCtrl, hint: 'e.g. TechCorp India Pvt Ltd', icon: LucideIcons.building2);
          final f2 = _buildInputField(label: 'Contact Person', controller: _contactPersonCtrl, hint: 'e.g. Harish Menon', icon: LucideIcons.user);
          final f3 = _buildDropdownField(
            label: 'Supplier Type',
            value: _supplierType,
            icon: LucideIcons.store,
            items: const ['Local Supplier', 'Wholesale Vendor', 'Manufacturer', 'Distributor'],
            onChanged: (v) => setState(() => _supplierType = v!),
          );

          final f4 = _buildInputField(label: 'Mobile Number *', controller: _mobileCtrl, hint: 'e.g. 9876543210', icon: LucideIcons.phone, keyboardType: TextInputType.phone);
          final f5 = _buildInputField(label: 'Alternate Phone', controller: _altPhoneCtrl, hint: 'e.g. 9123456780', icon: LucideIcons.phoneCall, keyboardType: TextInputType.phone);

          final f6 = _buildInputField(label: 'Email Address *', controller: _emailCtrl, hint: 'e.g. supplier@company.com', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress);
          final f7 = _buildInputField(label: 'Website Link', controller: _websiteCtrl, hint: 'e.g. www.company.com', icon: LucideIcons.link2);

          if (isNarrow) {
            return Column(
              children: [
                f1, const SizedBox(height: 10),
                f2, const SizedBox(height: 10),
                f3, const SizedBox(height: 10),
                f4, const SizedBox(height: 10),
                f5, const SizedBox(height: 10),
                f6, const SizedBox(height: 10),
                f7,
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 4, child: f1),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: f2),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: f3),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: f4),
                  const SizedBox(width: 10),
                  Expanded(child: f5),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: f6),
                  const SizedBox(width: 10),
                  Expanded(child: f7),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD 2: Tax & Registration Details
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildTaxRegistrationCard() {
    return _buildFormCard(
      icon: LucideIcons.receipt,
      title: 'Tax & Registration Details',
      subtitle: 'Add your tax and registration information.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final f1 = _buildInputField(label: 'GSTIN ID', controller: _gstinCtrl, hint: 'e.g. 27AABCU9603R1ZN', icon: LucideIcons.creditCard);
          final f2 = _buildInputField(label: 'PAN Number', controller: _panCtrl, hint: 'e.g. ABCDE1234F', icon: LucideIcons.fileText);
          final f3 = _buildDropdownField(
            label: 'Tax Registration',
            value: _taxRegistration,
            icon: LucideIcons.shieldCheck,
            items: const ['Registered Business', 'Composition Dealer', 'Unregistered'],
            onChanged: (v) => setState(() => _taxRegistration = v!),
          );
          final f4 = _buildDropdownField(
            label: 'State of Supply',
            value: _stateOfSupply,
            icon: LucideIcons.mapPin,
            items: const ['Maharashtra', 'Tamil Nadu', 'Karnataka', 'Delhi', 'Gujarat', 'Telangana', 'Kerala', 'West Bengal'],
            onChanged: (v) => setState(() => _stateOfSupply = v!),
          );

          if (isNarrow) {
            return Column(
              children: [
                f1, const SizedBox(height: 10),
                f2, const SizedBox(height: 10),
                f3, const SizedBox(height: 10),
                f4,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: f1),
              const SizedBox(width: 10),
              Expanded(child: f2),
              const SizedBox(width: 10),
              Expanded(child: f3),
              const SizedBox(width: 10),
              Expanded(child: f4),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD 3: Address Details
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildAddressDetailsCard() {
    return _buildFormCard(
      icon: LucideIcons.mapPin,
      title: 'Address Details',
      subtitle: 'Provide your business and warehouse addresses.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final f1 = _buildInputField(label: 'Billing Headquarters Address', controller: _billingAddressCtrl, hint: 'e.g. No: 3663, TNHB Color', icon: LucideIcons.building);
          final f2 = _buildInputField(label: 'Shipping Warehouse Address', controller: _shippingAddressCtrl, hint: 'e.g. TNHB Industrial Area', icon: LucideIcons.warehouse);
          final f3 = _buildInputField(label: 'City', controller: _cityCtrl, hint: 'e.g. Chennai', icon: LucideIcons.building);
          final f4 = _buildInputField(label: 'Postal Code (Pincode)', controller: _pincodeCtrl, hint: 'e.g. 602001', icon: LucideIcons.mail, keyboardType: TextInputType.number);

          if (isNarrow) {
            return Column(
              children: [
                f1, const SizedBox(height: 10),
                f2, const SizedBox(height: 10),
                f3, const SizedBox(height: 10),
                f4,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: f1),
              const SizedBox(width: 10),
              Expanded(child: f2),
              const SizedBox(width: 10),
              Expanded(child: f3),
              const SizedBox(width: 10),
              Expanded(child: f4),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD 4: Banking & Payment Terms
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildBankingAndPaymentCard() {
    return _buildFormCard(
      icon: LucideIcons.creditCard,
      title: 'Banking & Payment Terms',
      subtitle: 'Add your bank details and payment preferences.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              final f1 = _buildInputField(label: 'Bank Account Number', controller: _bankAccountCtrl, hint: 'e.g. 912345678901', icon: LucideIcons.creditCard, keyboardType: TextInputType.number);
              final f2 = _buildInputField(label: 'IFSC Code', controller: _ifscCtrl, hint: 'e.g. SBIN0001234', icon: LucideIcons.landmark);
              final f3 = _buildInputField(label: 'UPI ID', controller: _upiCtrl, hint: 'e.g. vendor@upi', icon: LucideIcons.smartphone);

              if (isNarrow) {
                return Column(
                  children: [
                    f1, const SizedBox(height: 10),
                    f2, const SizedBox(height: 10),
                    f3,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: f1),
                  const SizedBox(width: 10),
                  Expanded(child: f2),
                  const SizedBox(width: 10),
                  Expanded(child: f3),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: Color(0xFF166534)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Credit & Payment Details',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 620;

                    final f1 = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          label: 'Opening Payable Balance (₹)',
                          controller: _openingBalanceCtrl,
                          hint: '0',
                          prefixText: '₹ ',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Keep positive if you owe them, negative for advance payment',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                    );

                    final f2 = _buildInputField(
                      label: 'Credit Limit Allowance (₹)',
                      controller: _creditLimitCtrl,
                      hint: '200000',
                      prefixText: '₹ ',
                      keyboardType: TextInputType.number,
                    );

                    final f3 = _buildDropdownField(
                      label: 'Payment Terms (Days)',
                      value: _paymentTerms,
                      icon: LucideIcons.calendar,
                      items: const ['Immediate', 'Net 15', 'Net 30', 'Net 45', 'Net 60'],
                      onChanged: (v) => setState(() => _paymentTerms = v!),
                    );

                    if (isNarrow) {
                      return Column(
                        children: [
                          f1, const SizedBox(height: 10),
                          f2, const SizedBox(height: 10),
                          f3,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: f1),
                        const SizedBox(width: 10),
                        Expanded(child: f2),
                        const SizedBox(width: 10),
                        Expanded(child: f3),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD & FIELD HELPERS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildFormCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFDFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(icon, size: 14, color: const Color(0xFF166534)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFDCFCE7)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    String? prefixText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              prefixIcon: icon != null
                  ? Icon(icon, size: 14, color: const Color(0xFF94A3B8))
                  : (prefixText != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10, top: 9),
                          child: Text(prefixText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        )
                      : null),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 5),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
              items: items.map((it) {
                return DropdownMenuItem(
                  value: it,
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(it, style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
