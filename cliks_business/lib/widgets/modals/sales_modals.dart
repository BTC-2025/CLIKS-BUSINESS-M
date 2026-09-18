import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';

class InvoiceTemplatesModal extends ConsumerStatefulWidget {
  const InvoiceTemplatesModal({super.key});

  @override
  ConsumerState<InvoiceTemplatesModal> createState() => _InvoiceTemplatesModalState();
}

class _InvoiceTemplatesModalState extends ConsumerState<InvoiceTemplatesModal> {
  int _selectedTemplate = 0;

  final List<Map<String, String>> _templates = [
    {'name': 'Premium Corporate', 'desc': 'Sleek Navy Enterprise', 'color': '0xFF1E3A8A'},
    {'name': 'Bold Amethyst', 'desc': 'Creative Digital Studio', 'color': '0xFF6D28D9'},
    {'name': 'Emerald Eco-Mint', 'desc': 'Organic Minimal Luxe', 'color': '0xFF059669'},
    {'name': 'Executive Standard', 'desc': 'Clean Compliance', 'color': '0xFF374151'},
    {'name': 'Modern Pro', 'desc': 'Minimalist Sans Serif', 'color': '0xFF2563EB'},
    {'name': 'Master Box Grid', 'desc': 'Heavy Accounting', 'color': '0xFF0F172A'},
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    final templatesList = Column(
      children: List.generate(_templates.length, (idx) {
        final t = _templates[idx];
        final isSel = _selectedTemplate == idx;
        return GestureDetector(
          onTap: () => setState(() => _selectedTemplate = idx),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFE5E7EB),
                width: isSel ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(int.parse(t['color']!)).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.fileText,
                    size: 16,
                    color: Color(int.parse(t['color']!)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                      const SizedBox(height: 2),
                      Text(t['desc']!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                    ],
                  ),
                ),
                if (isSel)
                  const Icon(LucideIcons.checkCircle, color: Color(0xFF6B21A8), size: 18),
              ],
            ),
          ),
        );
      }),
    );

    final previewPane = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(int.parse(_templates[_selectedTemplate]['color']!)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('r', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RAVIKUMARLAPTOP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937))),
                    Text('Global Solutions Enterprise', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE5E7EB)),
          const Text('INVOICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF374151), letterSpacing: 1)),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('INVOICE NO.', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
              Text('INV-SAMPLE-001', style: TextStyle(fontSize: 11, color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DATE ISSUED', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
              Text('7/10/2026', style: TextStyle(fontSize: 11, color: Color(0xFF1F2937))),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE5E7EB)),
          const Text('BILL RECIPIENT', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Johnathan Doe Ltd.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const Text('742 Evergreen Terrace, Springfield, US', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const Divider(height: 20, color: Color(0xFFE5E7EB)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PAYMENT MODE', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
              Text('UPI / Credit Card', style: TextStyle(fontSize: 11, color: Color(0xFF1F2937))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.billing),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Set as Active Template', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    return _LargeModalWrapper(
      title: 'Choose Invoice Template',
      subtitle: 'Select the visual design for generated PDF and physical prints. Select one of 11 unique layouts.',
      onClose: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.billing),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: templatesList),
                const SizedBox(width: 24),
                Expanded(flex: 6, child: previewPane),
              ],
            )
          : Column(
              children: [
                templatesList,
                const SizedBox(height: 20),
                previewPane,
              ],
            ),
    );
  }
}

class AddCustomerModal extends ConsumerWidget {
  const AddCustomerModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _LargeModalWrapper(
      title: 'New Customer Registration',
      subtitle: 'Code: CUST-8245',
      onClose: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.customers),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResponsiveRow(
            context,
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CUSTOMER NAME'),
                  _buildTextField(hintText: 'Rajesh Gupta'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('SHOP / BUSINESS NAME'),
                  _buildTextField(hintText: 'Gupta Groceries Wholesale'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResponsiveFourRow(
            context,
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('PHONE NUMBER'),
                  _buildTextField(hintText: '9876543210', keyboardType: TextInputType.phone),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('ALTERNATE PHONE'),
                  _buildTextField(hintText: 'Alternate Phone', keyboardType: TextInputType.phone),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('EMAIL ADDRESS'),
                  _buildTextField(hintText: 'name@domain.com', keyboardType: TextInputType.emailAddress),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('WEBSITE'),
                  _buildTextField(hintText: 'www.website.com'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResponsiveFourRow(
            context,
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('GSTIN'),
                  _buildTextField(hintText: '07AAAAA1111A1Z1'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('PAN NUMBER'),
                  _buildTextField(hintText: 'ABCDE1234F'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('TAX TYPE'),
                  _buildDropdown(
                    value: 'Registered Business',
                    items: ['Registered Business', 'Unregistered Business', 'Consumer'],
                    onChanged: (val) {},
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('PLACE OF SUPPLY'),
                  _buildDropdown(
                    value: 'Delhi',
                    items: ['Delhi', 'Maharashtra', 'Karnataka', 'Tamil Nadu', 'Uttar Pradesh'],
                    onChanged: (val) {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            context,
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('BILLING ADDRESS'),
                  _buildTextField(hintText: 'Enter billing address...'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('SHIPPING ADDRESS'),
                  _buildTextField(hintText: 'Enter shipping address...'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResponsiveFourRow(
            context,
            [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Opening Balance (₹)'),
                  _buildTextField(hintText: '0', keyboardType: TextInputType.number),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Credit Limit (₹)'),
                  _buildTextField(hintText: '50000', keyboardType: TextInputType.number),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Due Days (Terms)'),
                  _buildTextField(hintText: '30', keyboardType: TextInputType.number),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Preferred Reminder'),
                  _buildDropdown(
                    value: 'WhatsApp',
                    items: ['WhatsApp', 'SMS', 'Email', 'Call'],
                    onChanged: (val) {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('Opening Loyalty Points'),
          _buildTextField(hintText: '0', keyboardType: TextInputType.number),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.customers),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Register Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeModalWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final Widget child;

  const _LargeModalWrapper({
    required this.title,
    required this.subtitle,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 680,
            maxHeight: screenHeight * 0.65,
          ),
          margin: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onClose,
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
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
  final isSmall = MediaQuery.of(context).size.width < 550;
  if (isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        children[0],
        const SizedBox(height: 16),
        children[1],
      ],
    );
  }
  return Row(
    children: [
      Expanded(child: children[0]),
      const SizedBox(width: 12),
      Expanded(child: children[1]),
    ],
  );
}

Widget _buildResponsiveThreeRow(BuildContext context, List<Widget> children) {
  final isSmall = MediaQuery.of(context).size.width < 550;
  if (isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        children[0],
        const SizedBox(height: 16),
        children[1],
        const SizedBox(height: 16),
        children[2],
      ],
    );
  }
  return Row(
    children: [
      Expanded(child: children[0]),
      const SizedBox(width: 8),
      Expanded(child: children[1]),
      const SizedBox(width: 8),
      Expanded(child: children[2]),
    ],
  );
}

Widget _buildResponsiveFourRow(BuildContext context, List<Widget> children) {
  final isSmall = MediaQuery.of(context).size.width < 600;
  if (isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        children[0],
        const SizedBox(height: 16),
        children[1],
        const SizedBox(height: 16),
        children[2],
        const SizedBox(height: 16),
        children[3],
      ],
    );
  }
  return Row(
    children: [
      Expanded(child: children[0]),
      const SizedBox(width: 8),
      Expanded(child: children[1]),
      const SizedBox(width: 8),
      Expanded(child: children[2]),
      const SizedBox(width: 8),
      Expanded(child: children[3]),
    ],
  );
}

Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF374151),
      ),
    ),
  );
}

Widget _buildTextField({required String hintText, TextInputType keyboardType = TextInputType.text}) {
  return SizedBox(
    height: 38,
    child: TextField(
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12.5, color: Color(0xFF1F2937)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
      ),
    ),
  );
}

Widget _buildDropdown({
  required String value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return SizedBox(
    height: 38,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937))),
        );
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF6B7280)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
      ),
    ),
  );
}

Widget _buildCompactInput(String hint, {required double width}) {
  return SizedBox(
    width: width,
    height: 36,
    child: TextField(
      style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
      ),
    ),
  );
}

Widget _buildCompactDropdown(String value, List<String> items) {
  return SizedBox(
    height: 36,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 11.5, color: Color(0xFF1F2937))),
        );
      }).toList(),
      onChanged: (val) {},
      icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF6B7280)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
      ),
    ),
  );
}

class NewCustomerReturnModal extends ConsumerStatefulWidget {
  const NewCustomerReturnModal({super.key});

  @override
  ConsumerState<NewCustomerReturnModal> createState() => _NewCustomerReturnModalState();
}

class _NewCustomerReturnModalState extends ConsumerState<NewCustomerReturnModal> {
  String _invoiceId = 'Select Invoice';
  String _refundMode = 'Cash';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 680,
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Log Sales Return',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Customer Credit Note  •  SRN-4752',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.returns),
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
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  // ── Body ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Return Details card
                    _returnCard(
                      title: 'Return Details',
                      icon: LucideIcons.fileText,
                      color: const Color(0xFF059669),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Original Invoice ID'),
                                  _dd(_invoiceId, ['Select Invoice', 'INV-8890', 'INV-8891'],
                                      (v) => setState(() => _invoiceId = v!)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Return Date'),
                                  _tf('10-07-2026'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Customer Name'),
                                  _tf('Select invoice to populate'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Refund Mode'),
                                  _dd(_refundMode, ['Cash', 'Store Credit', 'Bank Transfer'],
                                      (v) => setState(() => _refundMode = v!)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Reason for Return'),
                                  _tf('Damaged Item'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Return Warehouse'),
                                  _tf('Main Godown'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Products card
                    _returnCard(
                      title: 'Return Products',
                      icon: LucideIcons.package,
                      color: const Color(0xFF059669),
                      trailing: _addBtn(() {}),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _miniDd('Select Product', ['Select Product', 'Product A', 'Product B']),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(width: 60, child: _miniTf('Qty', '1')),
                              const SizedBox(width: 6),
                              SizedBox(width: 70, child: _miniTf('Rate', '0.00')),
                              const SizedBox(width: 6),
                              const Text('₹ 0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Total summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Grand Total Refund / Credit:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46))),
                          Text('₹ 0.00', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF059669))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.returns),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              foregroundColor: const Color(0xFF6B7280),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.returns),
                            icon: const Icon(LucideIcons.checkCircle, size: 15),
                            label: const Text('Complete Return', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
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

  Widget _returnCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(7)),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _lbl(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5, left: 2),
    child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.4)),
  );

  Widget _tf(String hint) => TextFormField(
    style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC1C7D0), fontSize: 12),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
    ),
  );

  Widget _dd(String value, List<String> items, ValueChanged<String?> onChanged) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE5EAF4)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF059669)),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w500)))).toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _miniDd(String value, List<String> items) => Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFE5EAF4))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        isDense: true,
        icon: const Icon(LucideIcons.chevronDown, size: 10, color: Color(0xFF9CA3AF)),
        items: items.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFF1F2937))))).toList(),
        onChanged: (v) {},
      ),
    ),
  );

  Widget _miniTf(String hint, String value) => Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFE5EAF4))),
    child: Row(
      children: [
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFF1F2937), fontWeight: FontWeight.w500))),
        Text(hint, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
      ],
    ),
  );

  Widget _addBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF059669),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.plus, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text('Add', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// New Supplier Return Modal
// ─────────────────────────────────────────────────────────────
class NewSupplierReturnModal extends ConsumerStatefulWidget {
  const NewSupplierReturnModal({super.key});

  @override
  ConsumerState<NewSupplierReturnModal> createState() => _NewSupplierReturnModalState();
}

class _NewSupplierReturnModalState extends ConsumerState<NewSupplierReturnModal> {
  String _billId = 'Select Purchase Bill';
  String _refundMode = 'Cash';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 680,
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Log Purchase Return',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Supplier Debit Note  •  PRN-4805',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.returns),
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
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  // ── Body ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Return Details
                    _returnCard(
                      title: 'Return Details',
                      icon: LucideIcons.fileText,
                      color: const Color(0xFFD97706),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Purchase Bill ID'),
                                  _dd(_billId, ['Select Purchase Bill', 'BIL-7761', 'BIL-7762'],
                                      (v) => setState(() => _billId = v!)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Return Date'),
                                  _tf('10-07-2026'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Supplier Name'),
                                  _tf('Select purchase bill to populate'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Refund Mode'),
                                  _dd(_refundMode, ['Cash', 'Store Credit', 'Bank Transfer'],
                                      (v) => setState(() => _refundMode = v!)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Reason for Return'),
                                  _tf('Damaged / Wrong Item'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _lbl('Return Warehouse'),
                                  _tf('Main Godown'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Products card
                    _returnCard(
                      title: 'Return Products',
                      icon: LucideIcons.package,
                      color: const Color(0xFFD97706),
                      trailing: _addBtn(() {}),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _miniDd('Select Product', ['Select Product', 'Product A', 'Product B']),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(width: 60, child: _miniTf('Qty', '1')),
                              const SizedBox(width: 6),
                              SizedBox(width: 70, child: _miniTf('Rate', '0.00')),
                              const SizedBox(width: 6),
                              const Text('₹ 0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Total
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Grand Total Debit Note:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E))),
                          Text('₹ 0.00', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFD97706))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.returns),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              foregroundColor: const Color(0xFF6B7280),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.returns),
                            icon: const Icon(LucideIcons.checkCircle, size: 15),
                            label: const Text('Complete Return', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97706),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
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

  Widget _returnCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(7)),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _lbl(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5, left: 2),
    child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.4)),
  );

  Widget _tf(String hint) => TextFormField(
    style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC1C7D0), fontSize: 12),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5)),
    ),
  );

  Widget _dd(String value, List<String> items, ValueChanged<String?> onChanged) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFE5EAF4)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFFD97706)),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w500)))).toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _miniDd(String value, List<String> items) => Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFE5EAF4))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        isDense: true,
        icon: const Icon(LucideIcons.chevronDown, size: 10, color: Color(0xFF9CA3AF)),
        items: items.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFF1F2937))))).toList(),
        onChanged: (v) {},
      ),
    ),
  );

  Widget _miniTf(String hint, String value) => Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFE5EAF4))),
    child: Row(
      children: [
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFF1F2937), fontWeight: FontWeight.w500))),
        Text(hint, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
      ],
    ),
  );

  Widget _addBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(7)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.plus, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text('Add', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}
