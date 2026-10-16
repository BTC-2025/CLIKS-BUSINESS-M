import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';

class MobileCartSheet extends StatefulWidget {
  final List<MobileCartItem> cart;
  final MobileCustomer customer;
  final double discountPercent;
  final double discountFlat;
  final DiscountMode discountMode;
  final double gstRate;
  final double ptsRedeemed;
  final double ptsEarned;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;
  final ValueChanged<int> onRemove;
  final VoidCallback onClearCart;
  final VoidCallback onHoldCart;
  final Function(DiscountMode mode, double value) onUpdateDiscount;
  final ValueChanged<double> onUpdateGstRate;
  final VoidCallback onProceedToPayment;

  const MobileCartSheet({
    super.key,
    required this.cart,
    required this.customer,
    required this.discountPercent,
    required this.discountFlat,
    required this.discountMode,
    required this.gstRate,
    required this.ptsRedeemed,
    required this.ptsEarned,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onClearCart,
    required this.onHoldCart,
    required this.onUpdateDiscount,
    required this.onUpdateGstRate,
    required this.onProceedToPayment,
  });

  @override
  State<MobileCartSheet> createState() => _MobileCartSheetState();
}

class _MobileCartSheetState extends State<MobileCartSheet> {
  late DiscountMode _discountMode;
  late TextEditingController _discountCtrl;
  late double _discountPercent;
  late double _discountFlat;
  late double _gstRate;

  @override
  void initState() {
    super.initState();
    _discountMode = widget.discountMode;
    _discountPercent = widget.discountPercent;
    _discountFlat = widget.discountFlat;
    _gstRate = widget.gstRate;
    final val = _discountMode == DiscountMode.percentage
        ? _discountPercent
        : _discountFlat;
    _discountCtrl = TextEditingController(
      text: val > 0
          ? val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 2)
          : '',
    );
  }

  @override
  void didUpdateWidget(MobileCartSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gstRate != widget.gstRate) {
      _gstRate = widget.gstRate;
    }
    if (oldWidget.discountPercent != widget.discountPercent) {
      _discountPercent = widget.discountPercent;
    }
    if (oldWidget.discountFlat != widget.discountFlat) {
      _discountFlat = widget.discountFlat;
    }
    if (oldWidget.discountMode != widget.discountMode) {
      _discountMode = widget.discountMode;
    }
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => widget.cart.fold(0.0, (sum, i) => sum + i.total);

  double get _discountAmount {
    if (_discountMode == DiscountMode.percentage) {
      return _subtotal * (_discountPercent / 100);
    } else {
      return _discountFlat.clamp(0.0, _subtotal);
    }
  }

  double get _taxableAmount =>
      (_subtotal - _discountAmount).clamp(0.0, double.infinity);
  double get _gstAmount => _taxableAmount * _gstRate;
  double get _rawTotal => (_taxableAmount + _gstAmount - widget.ptsRedeemed)
      .clamp(0.0, double.infinity);
  double get _roundOff => (_rawTotal.roundToDouble() - _rawTotal);
  double get _payableAmount => _rawTotal.roundToDouble();

  void _handleIncrement(int index) {
    if (index < 0 || index >= widget.cart.length) return;
    final line = widget.cart[index];
    if (line.quantity >= line.product.stock) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot add more. Only ${line.product.stock} ${line.product.unit} available in stock!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: MobilePosColors.danger,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }
    setState(() {
      widget.onIncrement(index);
    });
  }

  void _handleDecrement(int index) {
    if (index < 0 || index >= widget.cart.length) return;
    setState(() {
      widget.onDecrement(index);
    });
  }

  void _handleRemove(int index) {
    if (index < 0 || index >= widget.cart.length) return;
    setState(() {
      widget.onRemove(index);
    });
  }

  void _onDiscountChanged(String text) {
    final parsed = double.tryParse(text.trim()) ?? 0.0;
    setState(() {
      if (_discountMode == DiscountMode.percentage) {
        _discountPercent = parsed.clamp(0.0, 100.0);
        widget.onUpdateDiscount(_discountMode, _discountPercent);
      } else {
        _discountFlat = parsed.clamp(0.0, _subtotal);
        widget.onUpdateDiscount(_discountMode, _discountFlat);
      }
    });
  }

  void _confirmClearCart() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Cart?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: MobilePosColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all ${_cartItemsCount()} items from this checkout?',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: MobilePosColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: MobilePosColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onClearCart();
              Navigator.pop(context); // Close cart sheet
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MobilePosColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear Cart',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  int _cartItemsCount() => widget.cart.fold(0, (sum, i) => sum + i.quantity);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: MobilePosColors.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.shoppingCart,
                    size: 16,
                    color: MobilePosColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Cart (${_cartItemsCount()})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: MobilePosColors.textPrimary,
                    ),
                  ),
                ),
                // Hold Cart
                OutlinedButton.icon(
                  onPressed: () {
                    widget.onHoldCart();
                    Navigator.pop(context);
                  },
                  icon: const Icon(LucideIcons.pauseCircle, size: 12),
                  label: Text(
                    'Hold',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MobilePosColors.warning,
                    side: const BorderSide(color: Color(0xFFFDE68A)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Clear Cart
                InkWell(
                  onTap: _confirmClearCart,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: MobilePosColors.danger,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    size: 18,
                    color: MobilePosColors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 26,
                    minHeight: 26,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: MobilePosColors.border),

          // Scrollable Items list + Financial Summary
          Expanded(
            child: widget.cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.shoppingBag,
                          size: 48,
                          color: MobilePosColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your cart is empty',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: MobilePosColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap products in the catalogue to add them',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: MobilePosColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 20 + bottomInset),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Cart Line Items
                      ...widget.cart.asMap().entries.map((entry) {
                        final index = entry.key;
                        final line = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: MobilePosColors.border),
                          ),
                          child: Row(
                            children: [
                              // Product Details
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: MobilePosColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${formatIndianCurrency(line.product.price)} / ${line.product.unit}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: MobilePosColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Stepper: [-] Qty [+]
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: MobilePosColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _handleDecrement(index),
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                              left: Radius.circular(7),
                                            ),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            LucideIcons.minus,
                                            size: 13,
                                            color: MobilePosColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 26,
                                      ),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Text(
                                        '${line.quantity}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: MobilePosColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _handleIncrement(index),
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                              right: Radius.circular(7),
                                            ),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            LucideIcons.plus,
                                            size: 13,
                                            color:
                                                line.quantity >=
                                                        line.product.stock
                                                    ? MobilePosColors.textMuted
                                                    : MobilePosColors
                                                        .textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Line Total
                              SizedBox(
                                width: 72,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '₹${formatIndianCurrency(line.total)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: MobilePosColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ),

                              // Trash Icon
                              const SizedBox(width: 4),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _handleRemove(index),
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      LucideIcons.trash2,
                                      size: 15,
                                      color: MobilePosColors.danger,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // ─── Financial Modifiers & Summary ───
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: MobilePosColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PAYMENT & TAX SUMMARY',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: MobilePosColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Inputs row: Discount & GST Tax
                            Row(
                              children: [
                                // Discount Box
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'DISCOUNT',
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  MobilePosColors.textSecondary,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(
                                                    () => _discountMode =
                                                        DiscountMode.percentage,
                                                  );
                                                  _onDiscountChanged(
                                                    _discountCtrl.text,
                                                  );
                                                },
                                                child: Text(
                                                  '%',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        _discountMode ==
                                                            DiscountMode
                                                                .percentage
                                                        ? MobilePosColors
                                                              .primaryGreen
                                                        : MobilePosColors
                                                              .textMuted,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                ' | ',
                                                style: GoogleFonts.inter(
                                                  fontSize: 8,
                                                  color: MobilePosColors.border,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(
                                                    () => _discountMode =
                                                        DiscountMode.flat,
                                                  );
                                                  _onDiscountChanged(
                                                    _discountCtrl.text,
                                                  );
                                                },
                                                child: Text(
                                                  'Flat',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        _discountMode ==
                                                            DiscountMode.flat
                                                        ? MobilePosColors
                                                              .primaryGreen
                                                        : MobilePosColors
                                                              .textMuted,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 36,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: MobilePosColors.border,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _discountCtrl,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          onChanged: _onDiscountChanged,
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: InputDecoration(
                                            hintText:
                                                _discountMode ==
                                                    DiscountMode.percentage
                                                ? '0%'
                                                : '₹0',
                                            hintStyle: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: MobilePosColors.textMuted,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // GST Tax Dropdown
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GST TAX',
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: MobilePosColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 36,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: MobilePosColors.border,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<double>(
                                            value: _gstRate,
                                            isExpanded: true,
                                            icon: const Icon(
                                              LucideIcons.chevronDown,
                                              size: 14,
                                              color:
                                                  MobilePosColors.textSecondary,
                                            ),
                                            style: GoogleFonts.inter(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  MobilePosColors.textPrimary,
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 0.0,
                                                child: Text('0%'),
                                              ),
                                              DropdownMenuItem(
                                                value: 0.05,
                                                child: Text('5%'),
                                              ),
                                              DropdownMenuItem(
                                                value: 0.12,
                                                child: Text('12%'),
                                              ),
                                              DropdownMenuItem(
                                                value: 0.18,
                                                child: Text('18%'),
                                              ),
                                              DropdownMenuItem(
                                                value: 0.28,
                                                child: Text('28%'),
                                              ),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() {
                                                  _gstRate = val;
                                                });
                                                widget.onUpdateGstRate(val);
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
                            const SizedBox(height: 12),
                            const Divider(
                              height: 1,
                              color: MobilePosColors.borderLight,
                            ),
                            const SizedBox(height: 10),

                            // Subtotal row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: MobilePosColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '₹${formatIndianCurrency(_subtotal)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: MobilePosColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (_discountAmount > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Discount (${_discountMode == DiscountMode.percentage ? "$_discountPercent%" : "Flat"})',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: MobilePosColors.danger,
                                    ),
                                  ),
                                  Text(
                                    '-₹${formatIndianCurrency(_discountAmount)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: MobilePosColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'GST (${(_gstRate * 100).toInt()}%)',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: MobilePosColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '₹${formatIndianCurrency(_gstAmount)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: MobilePosColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (_roundOff != 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Round Off',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: MobilePosColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    '${_roundOff >= 0 ? "+" : ""}₹${_roundOff.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: MobilePosColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            const Divider(
                              height: 1,
                              color: MobilePosColors.border,
                            ),
                            const SizedBox(height: 8),

                            // Payable Amount
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payable Amount',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: MobilePosColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '₹${formatIndianCurrency(_payableAmount)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: MobilePosColors.primaryGreen,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          // Bottom Proceed to Checkout Bar
          if (widget.cart.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 14 + bottomPadding),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: MobilePosColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close cart sheet
                    widget.onProceedToPayment();
                  },
                  icon: const Icon(LucideIcons.arrowRight, size: 16),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Proceed to Payment (₹${formatIndianCurrency(_payableAmount)})',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MobilePosColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
