import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';

enum MobileStockAdjustmentType { increase, decrease }

class MobileStockAdjustmentSheet extends StatefulWidget {
  final MobilePosProduct product;
  final String warehouse;
  final MobileStockAdjustmentType type;
  final Future<bool> Function({
    required int quantity,
    required String reason,
    required String warehouse,
  }) onConfirm;

  const MobileStockAdjustmentSheet({
    super.key,
    required this.product,
    required this.warehouse,
    required this.type,
    required this.onConfirm,
  });

  @override
  State<MobileStockAdjustmentSheet> createState() =>
      _MobileStockAdjustmentSheetState();
}

class _MobileStockAdjustmentSheetState
    extends State<MobileStockAdjustmentSheet> {
  late TextEditingController _qtyCtrl;
  late TextEditingController _reasonCtrl;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isIncrease => widget.type == MobileStockAdjustmentType.increase;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '1');
    _reasonCtrl = TextEditingController(
      text: _isIncrease
          ? 'Stock replenishment'
          : 'Stock reconciliation / damage write-off',
    );
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  int get _parsedQty => int.tryParse(_qtyCtrl.text.trim()) ?? 0;

  int get _resultingStock {
    if (_isIncrease) {
      return widget.product.stock + _parsedQty;
    } else {
      return widget.product.stock - _parsedQty;
    }
  }

  void _incrementQty() {
    if (_isSubmitting) return;
    final current = _parsedQty;
    setState(() {
      _qtyCtrl.text = '${current + 1}';
      _errorMessage = null;
    });
  }

  void _decrementQty() {
    if (_isSubmitting) return;
    final current = _parsedQty;
    if (current > 1) {
      setState(() {
        _qtyCtrl.text = '${current - 1}';
        _errorMessage = null;
      });
    }
  }

  void _applyPresetQty(int delta) {
    if (_isSubmitting) return;
    setState(() {
      final newQty = (_parsedQty + delta).clamp(1, 999999);
      _qtyCtrl.text = '$newQty';
      _errorMessage = null;
    });
  }

  void _applyDirectQty(int val) {
    if (_isSubmitting) return;
    setState(() {
      _qtyCtrl.text = '$val';
      _errorMessage = null;
    });
  }

  String? _validate() {
    final qty = _parsedQty;
    if (qty <= 0) {
      return 'Please enter a valid quantity greater than 0';
    }
    if (!_isIncrease && qty > widget.product.stock) {
      return 'Cannot deduct $qty ${widget.product.unit}. Current stock is only ${widget.product.stock} ${widget.product.unit}.';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final error = _validate();
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onConfirm(
        quantity: _parsedQty,
        reason: _reasonCtrl.text.trim(),
        warehouse: widget.warehouse,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage =
              'Stock adjustment failed on the server. Please check your connection and retry.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeColor = _isIncrease
        ? MobilePosColors.primaryGreen
        : const Color(0xFFEA580C);
    final themeBg = _isIncrease
        ? MobilePosColors.lightGreen
        : const Color(0xFFFFF7ED);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isIncrease
                        ? LucideIcons.trendingUp
                        : LucideIcons.trendingDown,
                    size: 18,
                    color: themeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isIncrease ? 'Increase Stock' : 'Decrease Stock',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MobilePosColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isIncrease
                            ? 'Add inventory to warehouse'
                            : 'Deduct inventory from warehouse',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: MobilePosColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    size: 18,
                    color: MobilePosColors.textSecondary,
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: MobilePosColors.border),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 14 + bottomInset),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Target Warehouse
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.warehouse,
                          size: 15,
                          color: MobilePosColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Warehouse: ',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: MobilePosColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.warehouse,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: MobilePosColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Product Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MobilePosColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PRODUCT DETAILS',
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: MobilePosColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.product.category,
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: MobilePosColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.product.name,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: MobilePosColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.product.sku,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: MobilePosColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: MobilePosColors.border),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Stock:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: MobilePosColors.textSecondary,
                              ),
                            ),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${widget.product.stock} ${widget.product.unit}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: widget.product.stock > 0
                                        ? MobilePosColors.primaryGreen
                                        : MobilePosColors.danger,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity input section
                  Row(
                    children: [
                      Text(
                        _isIncrease ? 'Quantity to Add' : 'Quantity to Deduct',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: MobilePosColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        '*',
                        style: TextStyle(
                          color: MobilePosColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Stepper & Direct TextField
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _errorMessage != null
                            ? MobilePosColors.danger
                            : MobilePosColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Minus button
                        InkWell(
                          onTap: _isSubmitting ? null : _decrementQty,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(10),
                          ),
                          child: Container(
                            width: 44,
                            alignment: Alignment.center,
                            child: const Icon(
                              LucideIcons.minus,
                              size: 16,
                              color: MobilePosColors.textPrimary,
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          color: MobilePosColors.border,
                        ),

                        // Text Field
                        Expanded(
                          child: TextField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            enabled: !_isSubmitting,
                            onChanged: (_) {
                              setState(() => _errorMessage = null);
                            },
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MobilePosColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: GoogleFonts.inter(
                                color: MobilePosColors.textMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),

                        const VerticalDivider(
                          width: 1,
                          color: MobilePosColors.border,
                        ),
                        // Plus button
                        InkWell(
                          onTap: _isSubmitting ? null : _incrementQty,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(10),
                          ),
                          child: Container(
                            width: 44,
                            alignment: Alignment.center,
                            child: const Icon(
                              LucideIcons.plus,
                              size: 16,
                              color: MobilePosColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Preset chips row
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _isIncrease
                          ? [
                              _buildPresetChip('+5', () => _applyPresetQty(5)),
                              _buildPresetChip(
                                '+10',
                                () => _applyPresetQty(10),
                              ),
                              _buildPresetChip(
                                '+25',
                                () => _applyPresetQty(25),
                              ),
                              _buildPresetChip(
                                '+50',
                                () => _applyPresetQty(50),
                              ),
                              _buildPresetChip(
                                '+100',
                                () => _applyPresetQty(100),
                              ),
                            ]
                          : [
                              _buildPresetChip('-1', () => _applyPresetQty(-1)),
                              _buildPresetChip('-5', () => _applyPresetQty(-5)),
                              _buildPresetChip(
                                '-10',
                                () => _applyPresetQty(-10),
                              ),
                              if (widget.product.stock > 0)
                                _buildPresetChip(
                                  'All (${widget.product.stock})',
                                  () => _applyDirectQty(widget.product.stock),
                                ),
                            ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Resulting Stock Preview Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _isIncrease
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isIncrease
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFED7AA),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Resulting Stock:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: MobilePosColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${widget.product.stock}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: MobilePosColors.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  LucideIcons.arrowRight,
                                  size: 13,
                                  color: MobilePosColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$_resultingStock ${widget.product.unit}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: _resultingStock < 0
                                        ? MobilePosColors.danger
                                        : themeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Reason / Reference Field
                  Text(
                    'Reason / Notes (Optional)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MobilePosColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _reasonCtrl,
                    enabled: !_isSubmitting,
                    style: GoogleFonts.inter(fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. Physical count reconciliation, delivery',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 12,
                        color: MobilePosColors.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: MobilePosColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: MobilePosColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),

                  // Error Message Display
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: MobilePosColors.dangerLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: MobilePosColors.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.alertCircle,
                            size: 15,
                            color: MobilePosColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: MobilePosColors.danger,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 14 + bottomPadding),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: MobilePosColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: MobilePosColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MobilePosColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isIncrease ? LucideIcons.plus : LucideIcons.minus,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isIncrease ? 'Add Stock' : 'Deduct Stock',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label),
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: MobilePosColors.textPrimary,
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: _isSubmitting ? null : onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
