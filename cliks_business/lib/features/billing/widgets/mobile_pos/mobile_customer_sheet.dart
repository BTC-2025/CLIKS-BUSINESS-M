import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';

class MobileCustomerSheet extends StatefulWidget {
  final MobileCustomer currentCustomer;
  final List<MobileCustomer> customers;
  final ValueChanged<MobileCustomer> onSelectCustomer;
  final ValueChanged<MobileCustomer> onRegisterCustomer;

  const MobileCustomerSheet({
    super.key,
    required this.currentCustomer,
    required this.customers,
    required this.onSelectCustomer,
    required this.onRegisterCustomer,
  });

  @override
  State<MobileCustomerSheet> createState() => _MobileCustomerSheetState();
}

class _MobileCustomerSheetState extends State<MobileCustomerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _isAddingNew = false;

  // New Customer Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _customerType = 'Retail';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _gstinCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  List<MobileCustomer> get _filteredCustomers {
    if (_query.isEmpty) return widget.customers;
    final q = _query.toLowerCase();
    return widget.customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.gstin.toLowerCase().contains(q);
    }).toList();
  }

  void _submitNewCustomer() {
    if (_formKey.currentState?.validate() ?? false) {
      final newCust = MobileCustomer(
        id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        gstin: _gstinCtrl.text.trim().isEmpty
            ? 'Unregistered'
            : _gstinCtrl.text.trim().toUpperCase(),
        businessName: _customerType,
        loyaltyPoints: 0,
        isWalkIn: false,
      );
      widget.onRegisterCustomer(newCust);
      widget.onSelectCustomer(newCust);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: MobilePosColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isAddingNew ? LucideIcons.userPlus : LucideIcons.users,
                      size: 18,
                      color: MobilePosColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isAddingNew ? 'Add New Customer' : 'Select Customer',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: MobilePosColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  size: 20,
                  color: MobilePosColors.textSecondary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (!_isAddingNew) ...[
            // Search field
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: MobilePosColors.surfaceBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MobilePosColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.search,
                    size: 16,
                    color: MobilePosColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _query = val),
                      style: GoogleFonts.inter(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by name, phone or GSTIN...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: MobilePosColors.textMuted,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    InkWell(
                      onTap: () => setState(() {
                        _searchCtrl.clear();
                        _query = '';
                      }),
                      child: const Icon(
                        LucideIcons.xCircle,
                        size: 16,
                        color: MobilePosColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Add new customer trigger & Walk-in reset button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _isAddingNew = true),
                    icon: const Icon(LucideIcons.userPlus, size: 14),
                    label: Text(
                      'Add New Customer',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MobilePosColors.primaryGreen,
                      side: const BorderSide(
                        color: MobilePosColors.accentGreen,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onSelectCustomer(MobileCustomer.walkIn);
                      Navigator.pop(context);
                    },
                    icon: const Icon(LucideIcons.userCheck, size: 14),
                    label: Text(
                      'Walk-in Client',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MobilePosColors.textSecondary,
                      side: const BorderSide(color: MobilePosColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: MobilePosColors.border),
            const SizedBox(height: 6),

            // Customers List
            Flexible(
              child: _filteredCustomers.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.userX,
                            size: 36,
                            color: MobilePosColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No customer found matching "$_query"',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: MobilePosColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {
                              _nameCtrl.text = _query;
                              _isAddingNew = true;
                            }),
                            icon: const Icon(LucideIcons.plus, size: 14),
                            label: const Text('Add This Customer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MobilePosColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredCustomers.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: MobilePosColors.borderLight,
                      ),
                      itemBuilder: (context, idx) {
                        final c = _filteredCustomers[idx];
                        final isSelected = c.id == widget.currentCustomer.id;

                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? MobilePosColors.lightGreen
                                  : const Color(0xFFF3F4F6),
                              child: Text(
                                c.name.isNotEmpty
                                    ? c.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? MobilePosColors.primaryGreen
                                      : MobilePosColors.textPrimary,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: MobilePosColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (c.loyaltyPoints > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${c.loyaltyPoints} pts',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              c.phone.isNotEmpty
                                  ? '${c.phone} • ${c.gstin.isNotEmpty ? c.gstin : "No GST"}'
                                  : (c.email.isNotEmpty
                                        ? c.email
                                        : 'Registered Client'),
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: MobilePosColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    LucideIcons.checkCircle2,
                                    color: MobilePosColors.accentGreen,
                                    size: 20,
                                  )
                                : const Icon(
                                    LucideIcons.chevronRight,
                                    color: MobilePosColors.textMuted,
                                    size: 16,
                                  ),
                            onTap: () {
                              widget.onSelectCustomer(c);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ] else ...[
            // Add New Customer Form
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTOMER DETAILS',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: MobilePosColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Name (Mandatory)
                      TextFormField(
                        controller: _nameCtrl,
                        style: GoogleFonts.inter(fontSize: 13.5),
                        decoration: InputDecoration(
                          labelText: 'Customer Name *',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: MobilePosColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.user,
                            size: 16,
                            color: MobilePosColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Customer name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Phone (Mandatory)
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(fontSize: 13.5),
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: MobilePosColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.phone,
                            size: 16,
                            color: MobilePosColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          if (val.trim().length < 8) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.inter(fontSize: 13.5),
                        decoration: InputDecoration(
                          labelText: 'Email Address (Optional)',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: MobilePosColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.mail,
                            size: 16,
                            color: MobilePosColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // GSTIN
                      TextFormField(
                        controller: _gstinCtrl,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.inter(fontSize: 13.5),
                        decoration: InputDecoration(
                          labelText: 'GSTIN (Optional)',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: MobilePosColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.fileText,
                            size: 16,
                            color: MobilePosColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Billing Address
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        style: GoogleFonts.inter(fontSize: 13.5),
                        decoration: InputDecoration(
                          labelText: 'Billing Address (Optional)',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: MobilePosColors.textSecondary,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: Icon(
                              LucideIcons.mapPin,
                              size: 16,
                              color: MobilePosColors.textSecondary,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Customer Type Selector
                      Row(
                        children: [
                          Text(
                            'Type: ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...['Retail', 'Wholesale', 'Enterprise'].map((type) {
                            final isSel = _customerType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(
                                  type,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSel,
                                selectedColor: MobilePosColors.lightGreen,
                                onSelected: (s) =>
                                    setState(() => _customerType = type),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _isAddingNew = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _submitNewCustomer,
                              icon: const Icon(LucideIcons.check, size: 16),
                              label: Text(
                                'Register & Assign',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MobilePosColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
