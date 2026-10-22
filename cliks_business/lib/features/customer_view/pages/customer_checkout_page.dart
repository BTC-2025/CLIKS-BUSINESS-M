import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/customer_view_provider.dart';
import '../utils/customer_theme_helper.dart';
import 'customer_order_confirmation_page.dart';

class CustomerCheckoutPage extends ConsumerStatefulWidget {
  const CustomerCheckoutPage({super.key});

  @override
  ConsumerState<CustomerCheckoutPage> createState() =>
      _CustomerCheckoutPageState();
}

class _CustomerCheckoutPageState extends ConsumerState<CustomerCheckoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _tableController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(customerViewProvider);
    _nameController.text = state.customerName;
    _phoneController.text = state.customerPhone;
    _tableController.text = state.tableNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  void _handlePlaceOrder() {
    final notifier = ref.read(customerViewProvider.notifier);
    final state = ref.read(customerViewProvider);

    if (state.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your tray is empty!')),
      );
      return;
    }

    if (state.settings.requireCustomerPhone && _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your contact phone number.')),
      );
      return;
    }

    if (state.selectedOrderType == 'Dine In' &&
        state.settings.showTableNumberInput &&
        state.settings.requireTableNumber &&
        _tableController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your table number to proceed.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    notifier.setCustomerInfo(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      table: _tableController.text.trim(),
    );

    final order = notifier.placeOrder();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => CustomerOrderConfirmationPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerViewProvider);
    final notifier = ref.read(customerViewProvider.notifier);
    final settings = state.settings;
    final primaryColor = Color(settings.primaryColorValue);
    final isDark = settings.isDarkMode;
    final cardRadius = CustomerThemeHelper.borderRadius(settings, defaultRadius: 16);
    final buttonRadius = CustomerThemeHelper.borderRadius(settings, defaultRadius: 14);
    final inputRadius = CustomerThemeHelper.borderRadius(settings, defaultRadius: 10);

    return Scaffold(
      backgroundColor: CustomerThemeHelper.surfaceBackground(settings),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : const Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout & Confirm Order',
          style: CustomerThemeHelper.font(
            settings,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── LEFT: DETAILS & PAYMENT ───
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Type Selection
                      if (settings.allowOrderTypeSelection) ...[
                        Text(
                          '1. Dining Preference',
                          style: CustomerThemeHelper.font(
                            settings,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: ['Dine In', 'Takeaway'].map((type) {
                            final isSelected = state.selectedOrderType == type;
                            return Expanded(
                              child: InkWell(
                                onTap: () => notifier.setOrderType(type),
                                borderRadius: BorderRadius.circular(buttonRadius),
                                child: Container(
                                  margin: EdgeInsets.only(right: type == 'Dine In' ? 12 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.08)
                                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                    borderRadius: BorderRadius.circular(buttonRadius),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        type == 'Dine In' ? LucideIcons.utensils : LucideIcons.packageOpen,
                                        size: 18,
                                        color: isSelected ? primaryColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        type,
                                        style: CustomerThemeHelper.font(
                                          settings,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? primaryColor : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Customer Details
                      if (settings.collectCustomerDetails) ...[
                        Text(
                          '2. Customer Details',
                          style: CustomerThemeHelper.font(
                            settings,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(cardRadius),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _nameController,
                                style: CustomerThemeHelper.font(
                                  settings,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Customer Name (Optional)',
                                  hintText: 'e.g. John Doe',
                                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                                  prefixIcon: const Icon(LucideIcons.user, size: 16),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(inputRadius),
                                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(inputRadius),
                                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: CustomerThemeHelper.font(
                                  settings,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  labelText: settings.requireCustomerPhone ? 'Phone Number (Required)' : 'Phone Number (For SMS updates)',
                                  hintText: 'e.g. +91 98765 43210',
                                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                                  prefixIcon: const Icon(LucideIcons.phone, size: 16),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(inputRadius),
                                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(inputRadius),
                                    borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                  ),
                                ),
                              ),
                              if (state.selectedOrderType == 'Dine In' && settings.showTableNumberInput) ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _tableController,
                                  style: CustomerThemeHelper.font(
                                    settings,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: settings.requireTableNumber ? 'Table Number (Required)' : 'Table Number (Optional)',
                                    hintText: 'e.g. Table 4',
                                    labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                                    prefixIcon: const Icon(LucideIcons.mapPin, size: 16),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(inputRadius),
                                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(inputRadius),
                                      borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Payment Method
                      Text(
                        '3. Payment Method',
                        style: CustomerThemeHelper.font(
                          settings,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: settings.enabledPaymentModes.map((mode) {
                            final isSelected = state.selectedPaymentMode == mode;
                            IconData icon = LucideIcons.banknote;
                            if (mode.contains('UPI')) icon = LucideIcons.qrCode;
                            if (mode.contains('Card')) icon = LucideIcons.creditCard;

                            return InkWell(
                              onTap: () => notifier.setPaymentMode(mode),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.08)
                                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      icon,
                                      size: 20,
                                      color: isSelected ? primaryColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mode,
                                            style: CustomerThemeHelper.font(
                                              settings,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : const Color(0xFF111827),
                                            ),
                                          ),
                                          Text(
                                            mode == 'UPI QR Code'
                                                ? 'Instant UPI confirmation directly on kiosk'
                                                : (mode == 'Pay at Counter'
                                                    ? 'Pay cash or card directly to the cashier when collecting'
                                                    : 'Tap your contactless credit or debit card at the counter terminal'),
                                            style: CustomerThemeHelper.font(
                                              settings,
                                              fontSize: 11,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Radio<String>(
                                      value: mode,
                                      groupValue: state.selectedPaymentMode,
                                      activeColor: primaryColor,
                                      onChanged: (val) {
                                        if (val != null) notifier.setPaymentMode(val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // If UPI is selected, display instant checkout info
                      if (state.selectedPaymentMode == 'UPI QR Code') ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(cardRadius),
                            border: Border.all(color: const Color(0xFF818CF8)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFC7D2FE)),
                                ),
                                child: const Center(
                                  child: Icon(LucideIcons.smartphone, size: 26, color: Color(0xFF4F46E5)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.sparkles, size: 15, color: Color(0xFF6366F1)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'UPI Payment Selected',
                                          style: CustomerThemeHelper.font(
                                            settings,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Click "Place Order Now" below to confirm and generate your order token.',
                                      style: CustomerThemeHelper.font(
                                        settings,
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563),
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Amount: ${CustomerThemeHelper.formatPrice(settings, state.cartTotal)}',
                                        style: CustomerThemeHelper.font(
                                          settings,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // ─── RIGHT: ORDER SUMMARY CARD ───
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.receipt, size: 18, color: isDark ? Colors.white : const Color(0xFF111827)),
                            const SizedBox(width: 8),
                            Text(
                              'Order Summary',
                              style: CustomerThemeHelper.font(
                                settings,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6)),
                        const SizedBox(height: 14),

                        // Itemized list
                        ...state.cart.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}×',
                                  style: CustomerThemeHelper.font(
                                    settings,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: CustomerThemeHelper.font(
                                          settings,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                                        ),
                                      ),
                                      if (item.selectedVariant != null)
                                        Text(
                                          item.selectedVariant!,
                                          style: CustomerThemeHelper.font(
                                            settings,
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CustomerThemeHelper.formatPrice(settings, item.lineTotal),
                                  style: CustomerThemeHelper.font(
                                    settings,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),
                        Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                        const SizedBox(height: 12),

                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: CustomerThemeHelper.font(
                                settings,
                                fontSize: 12.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              CustomerThemeHelper.formatPrice(settings, state.cartSubtotal),
                              style: CustomerThemeHelper.font(
                                settings,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),

                        // Taxes
                        if (settings.taxDisplayMode == 'breakdown' || (settings.taxDisplayMode == 'default' && settings.showGstBreakdown)) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tax / GST (18%)',
                                style: CustomerThemeHelper.font(
                                  settings,
                                  fontSize: 12.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                CustomerThemeHelper.formatPrice(settings, state.cartGst),
                                style: CustomerThemeHelper.font(
                                  settings,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ] else if (settings.taxDisplayMode == 'inclusive') ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tax',
                                style: CustomerThemeHelper.font(
                                  settings,
                                  fontSize: 12.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Taxes Included',
                                style: CustomerThemeHelper.font(
                                  settings,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),
                        Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                        const SizedBox(height: 12),

                        // Total Payable
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: CustomerThemeHelper.font(
                                settings,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              CustomerThemeHelper.formatPrice(settings, state.cartTotal),
                              style: CustomerThemeHelper.font(
                                settings,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Confirm & Place Order Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handlePlaceOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(buttonRadius),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LucideIcons.check, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Place Order Now',
                                        style: CustomerThemeHelper.font(
                                          settings,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
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
        ),
      ),
    );
  }
}
