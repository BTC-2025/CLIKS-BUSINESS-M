import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';

// ─── Shared helpers ──────────────────────────────────────────────────────────

const _kGreen = Color(0xFF1B5E20);
const _kGreenLight = Color(0xFF2E7D32);

Widget _lbl(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 4, left: 1),
  child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF5A7184), letterSpacing: 0.4)),
);

Widget _tf(String hint, {TextInputType kt = TextInputType.text}) => TextFormField(
  keyboardType: kt,
  style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
  decoration: InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFC1C7D0), fontSize: 12),
    isDense: true, filled: true, fillColor: const Color(0xFFF9FAFB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFE5EAF4))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: _kGreenLight, width: 1.5)),
  ),
);

Widget _dd(String value, List<String> items, ValueChanged<String?> onChanged) => Container(
  height: 40,
  padding: const EdgeInsets.symmetric(horizontal: 10),
  decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0xFFE5EAF4))),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: value, isExpanded: true,
      icon: const Icon(LucideIcons.chevronDown, size: 13, color: _kGreenLight),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937))))).toList(),
      onChanged: onChanged,
    ),
  ),
);

Widget _card({required String title, required IconData icon, required List<Widget> children, Widget? trailing}) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(13),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(13),
    border: Border.all(color: const Color(0xFFE5E7EB)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: _kGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 13, color: _kGreen)),
      const SizedBox(width: 8),
      Expanded(child: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), letterSpacing: 0.2))),
      ?trailing,
    ]),
    const SizedBox(height: 10),
    const Divider(height: 1, color: Color(0xFFF3F4F6)),
    const SizedBox(height: 10),
    ...children,
  ]),
);

Widget _summaryRow(String label, String value, {bool bold = false, bool red = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 2.5),
  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(fontSize: 12, color: bold ? const Color(0xFF1F2937) : const Color(0xFF6B7280), fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
    Text(value, style: TextStyle(fontSize: bold ? 14 : 12, fontWeight: FontWeight.bold, color: red ? const Color(0xFFEF4444) : (bold ? _kGreenLight : const Color(0xFF1F2937)))),
  ]),
);

// ─── Shared gradient header ───────────────────────────────────────────────────

Widget _header({required String title, required String subtitle, required VoidCallback onBack}) => Container(
  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
  decoration: const BoxDecoration(
    color: Colors.white,
  ),
  child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      const SizedBox(height: 2),
      Text(subtitle, style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
    ])),
    const SizedBox(width: 12),
    IconButton(
      onPressed: onBack,
      icon: const Icon(LucideIcons.x, size: 18, color: Colors.black54),
      style: IconButton.styleFrom(
        backgroundColor: Color(0xFFF3F4F6),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
      ),
    ),
  ]),
);

// ─── Shared product row ───────────────────────────────────────────────────────

Widget _productRowItem(String productDd, List<String> productItems) => Container(
  margin: const EdgeInsets.only(bottom: 8),
  padding: const EdgeInsets.all(9),
  decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0xFFEEEEEE))),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Product name dropdown
    Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFE5EAF4))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: productDd, isExpanded: true, isDense: true,
          icon: const Icon(LucideIcons.chevronDown, size: 11, color: Color(0xFF9CA3AF)),
          items: [productDd, 'Product A', 'Product B'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 11, color: Color(0xFF1F2937))))).toList(),
          onChanged: (v) {},
        ),
      ),
    ),
    const SizedBox(height: 6),
    Row(children: [
      Expanded(child: _miniBox('SKU', 'IPH-15')),
      const SizedBox(width: 6),
      Expanded(child: _miniBox('Cost (₹)', '0')),
      const SizedBox(width: 6),
      Expanded(child: _miniBox('Qty', '1')),
      const SizedBox(width: 6),
      Expanded(child: _miniBox('Disc%', '0')),
      const SizedBox(width: 6),
      Expanded(child: _miniGstDd()),
    ]),
  ]),
);

Widget _miniBox(String label, String value) => Container(
  height: 32,
  padding: const EdgeInsets.symmetric(horizontal: 7),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFE5EAF4))),
  child: Row(children: [
    Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFF1F2937), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
    Text(label, style: const TextStyle(fontSize: 8.5, color: Color(0xFF9CA3AF))),
  ]),
);

Widget _miniGstDd() => Container(
  height: 32,
  padding: const EdgeInsets.symmetric(horizontal: 6),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFE5EAF4))),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: '18%', isDense: true, isExpanded: true,
      icon: const Icon(LucideIcons.chevronDown, size: 10, color: Color(0xFF9CA3AF)),
      items: ['0%', '5%', '12%', '18%', '28%'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 10)))).toList(),
      onChanged: (v) {},
    ),
  ),
);

Widget _addRowBtn(VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: _kGreen, borderRadius: BorderRadius.circular(7)),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(LucideIcons.plus, size: 11, color: Colors.white),
      SizedBox(width: 4),
      Text('+ Add Row', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
    ]),
  ),
);

Widget _paymentToggle(String selected, ValueChanged<String> onChanged) {
  final modes = ['Cash', 'UPI', 'Bank', 'Credit'];
  return Row(children: modes.map((m) {
    final sel = m == selected;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => onChanged(m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: sel ? _kGreen : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: sel ? _kGreen : const Color(0xFFE5E7EB)),
          ),
          child: Text(m, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: sel ? Colors.white : const Color(0xFF374151))),
        ),
      ),
    );
  }).toList());
}

Widget _saveBtn(String label, VoidCallback onTap) => SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: _kGreen, foregroundColor: Colors.white, elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
  ),
);

// ═══════════════════════════════════════════════════════════════════════════
// 1. NEW PURCHASE ORDER (PO)
// ═══════════════════════════════════════════════════════════════════════════

class NewPOModal extends ConsumerStatefulWidget {
  const NewPOModal({super.key});
  @override
  ConsumerState<NewPOModal> createState() => _NewPOModalState();
}

class _NewPOModalState extends ConsumerState<NewPOModal> {
  String _taxMode = 'GST Tax Registered';
  String _payMode = 'Cash';
  int _rows = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final nav = ref.read(navigationProvider.notifier);
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
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Column(children: [
                // Drag Handle
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                _header(title: 'New Purchase Order (PO)', subtitle: 'Doc Reference: PO-${DateTime.now().millisecondsSinceEpoch % 90000 + 9000}', onBack: () => nav.setRoute(AppRoute.purchase)),
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(13),
                  physics: const BouncingScrollPhysics(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Supplier Metadata
                    _card(title: 'SUPPLIER METADATA', icon: LucideIcons.user, children: [
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Supplier Name'), _tf('-- Select Active Supplier --')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('GSTIN Number'), _tf('27AAAAA1111A1Z1')])),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Billing Address'), _tf('Supplier HQ Address')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Contact Phone'), _tf('+91 99881...', kt: TextInputType.phone)])),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    // Order Info
                    _card(title: 'ORDER INFO', icon: LucideIcons.calendar, children: [
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Tax Mode'), _dd(_taxMode, ['GST Tax Registered', 'GST Composite', 'Non-GST'], (v) => setState(() => _taxMode = v!))])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Purchase Date'), _tf('11-07-2026')])),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Due Date'), _tf('10-08-2026')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Target Warehouse'), _tf('Main Godown')])),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    // Products
                    _card(title: 'ITEMIZED PRODUCTS', icon: LucideIcons.layers, trailing: _addRowBtn(() => setState(() => _rows++)), children: [
                      ...List.generate(_rows, (_) => _productRowItem('-- Select Product --', [])),
                    ]),
                    const SizedBox(height: 10),
                    // Payment + Summary
                    _card(title: 'PAYMENT MODE', icon: LucideIcons.creditCard, children: [
                      _paymentToggle(_payMode, (v) => setState(() => _payMode = v)),
                      const SizedBox(height: 10),
                      _lbl('Advance Payment Amount (₹)'),
                      _tf('0', kt: TextInputType.number),
                      const SizedBox(height: 4),
                      Text('Entering an advance payment logs instant cash outflows dynamically.', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 10),
                      _summaryRow('Subtotal:', '₹0'),
                      _summaryRow('Total Discount:', '- ₹0', red: true),
                      _summaryRow('Input Tax (GST):', '₹0'),
                      const SizedBox(height: 6),
                      _summaryRow('Grand Total Due:', '₹0', bold: true),
                    ]),
                    const SizedBox(height: 14),
                    _saveBtn('Save & Complete Purchase Document', () => nav.setRoute(AppRoute.purchase)),
                    const SizedBox(height: 8),
                  ]),
                )),
              ]),
            ),
          ),
        ),
      );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. NEW PURCHASE BILL
// ═══════════════════════════════════════════════════════════════════════════

class NewPurchaseBillModal extends ConsumerStatefulWidget {
  const NewPurchaseBillModal({super.key});
  @override
  ConsumerState<NewPurchaseBillModal> createState() => _NewPurchaseBillModalState();
}

class _NewPurchaseBillModalState extends ConsumerState<NewPurchaseBillModal> {
  String _taxMode = 'GST Tax Registered';
  String _payMode = 'Cash';
  int _rows = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final nav = ref.read(navigationProvider.notifier);
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
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Column(children: [
                // Drag Handle
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                _header(title: 'Register New Purchase Bill', subtitle: 'Doc Reference: BILL-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}', onBack: () => nav.setRoute(AppRoute.purchase)),
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(13),
                  physics: const BouncingScrollPhysics(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _card(title: 'SUPPLIER METADATA', icon: LucideIcons.user, children: [
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Supplier Name'), _tf('-- Select Active Supplier --')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('GSTIN Number'), _tf('27AAAAA1111A1Z1')])),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Billing Address'), _tf('Supplier HQ Address')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Contact Phone'), _tf('+91 99881...', kt: TextInputType.phone)])),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    _card(title: 'BILL INFO', icon: LucideIcons.fileText, children: [
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Tax Mode'), _dd(_taxMode, ['GST Tax Registered', 'GST Composite', 'Non-GST'], (v) => setState(() => _taxMode = v!))])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Purchase Date'), _tf('11-07-2026')])),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Due Date'), _tf('10-08-2026')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Target Warehouse'), _tf('Main Godown')])),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    _card(title: 'ITEMIZED PRODUCTS', icon: LucideIcons.layers, trailing: _addRowBtn(() => setState(() => _rows++)), children: [
                      ...List.generate(_rows, (_) => _productRowItem('-- Select Product --', [])),
                    ]),
                    const SizedBox(height: 10),
                    _card(title: 'PAYMENT MODE', icon: LucideIcons.creditCard, children: [
                      _paymentToggle(_payMode, (v) => setState(() => _payMode = v)),
                      const SizedBox(height: 10),
                      _lbl('Paid Amount (₹)'),
                      _tf('0', kt: TextInputType.number),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 10),
                      _summaryRow('Subtotal:', '₹0'),
                      _summaryRow('Total Discount:', '- ₹0', red: true),
                      _summaryRow('Input Tax (GST):', '₹0'),
                      const SizedBox(height: 6),
                      _summaryRow('Grand Total Due:', '₹0', bold: true),
                    ]),
                    const SizedBox(height: 14),
                    _saveBtn('Save & Complete Purchase Document', () => nav.setRoute(AppRoute.purchase)),
                    const SizedBox(height: 8),
                  ]),
                )),
              ]),
            ),
          ),
        ),
      );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. PURCHASE RETURN (Debit Note)
// ═══════════════════════════════════════════════════════════════════════════

class PurchaseReturnModal extends ConsumerStatefulWidget {
  const PurchaseReturnModal({super.key});
  @override
  ConsumerState<PurchaseReturnModal> createState() => _PurchaseReturnModalState();
}

class _PurchaseReturnModalState extends ConsumerState<PurchaseReturnModal> {
  String _taxMode = 'GST Tax Registered';
  String _payMode = 'Cash';
  int _rows = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final nav = ref.read(navigationProvider.notifier);
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
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: Column(children: [
                // Drag Handle
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                _header(title: 'Log Purchase Return (Debit Note)', subtitle: 'Doc Reference: CN-${DateTime.now().millisecondsSinceEpoch % 9000 + 4000}', onBack: () => nav.setRoute(AppRoute.purchase)),
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(13),
                  physics: const BouncingScrollPhysics(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _card(title: 'SUPPLIER METADATA', icon: LucideIcons.user, children: [
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Supplier Name'), _tf('-- Select Active Supplier --')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('GSTIN Number'), _tf('27AAAAA1111A1Z1')])),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Billing Address'), _tf('Supplier HQ Address')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Contact Phone'), _tf('+91 99881...', kt: TextInputType.phone)])),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    _card(title: 'RETURN INFO', icon: LucideIcons.rotateCcw, children: [
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Tax Mode'), _dd(_taxMode, ['GST Tax Registered', 'GST Composite', 'Non-GST'], (v) => setState(() => _taxMode = v!))])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Purchase Date'), _tf('11-07-2026')])),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Due Date'), _tf('10-08-2026')])),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl('Target Warehouse'), _tf('Main Godown')])),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    _card(title: 'ITEMIZED PRODUCTS', icon: LucideIcons.layers, trailing: _addRowBtn(() => setState(() => _rows++)), children: [
                      ...List.generate(_rows, (_) => _productRowItem('-- Select Product --', [])),
                    ]),
                    const SizedBox(height: 10),
                    // Reason for return
                    _card(title: 'REASON FOR RETURN', icon: LucideIcons.alertCircle, children: [
                      _tf('Damaged Goods'),
                    ]),
                    const SizedBox(height: 10),
                    _card(title: 'PAYMENT MODE', icon: LucideIcons.creditCard, children: [
                      _paymentToggle(_payMode, (v) => setState(() => _payMode = v)),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 10),
                      _summaryRow('Subtotal:', '₹0'),
                      _summaryRow('Total Discount:', '- ₹0', red: true),
                      _summaryRow('Input Tax (GST):', '₹0'),
                      const SizedBox(height: 6),
                      _summaryRow('Grand Total Due:', '₹0', bold: true),
                    ]),
                    const SizedBox(height: 14),
                    _saveBtn('Save & Complete Purchase Document', () => nav.setRoute(AppRoute.purchase)),
                    const SizedBox(height: 8),
                  ]),
                )),
              ]),
            ),
          ),
        ),
      );
  }
}
