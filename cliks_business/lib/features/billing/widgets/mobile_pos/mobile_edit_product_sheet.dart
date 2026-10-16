import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';

class MobileEditProductSheet extends StatefulWidget {
  final MobilePosProduct product;
  final List<String> categories;
  final Future<bool> Function({
    required String name,
    required double price,
    required int stock,
    required String category,
  }) onSave;

  const MobileEditProductSheet({
    super.key,
    required this.product,
    required this.categories,
    required this.onSave,
  });

  @override
  State<MobileEditProductSheet> createState() => _MobileEditProductSheetState();
}

class _MobileEditProductSheetState extends State<MobileEditProductSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late String _selectedCategory;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _priceCtrl = TextEditingController(
      text: widget.product.price.toStringAsFixed(
        widget.product.price.truncateToDouble() == widget.product.price ? 0 : 2,
      ),
    );
    _stockCtrl = TextEditingController(text: '${widget.product.stock}');

    final validCats = widget.categories.where((c) => c != 'All').toList();
    if (validCats.contains(widget.product.category)) {
      _selectedCategory = widget.product.category;
    } else {
      _selectedCategory = validCats.isNotEmpty ? validCats.first : 'General';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) {
      return 'Product name is required';
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price < 0) {
      return 'Please enter a valid price (>= 0)';
    }
    final stock = int.tryParse(_stockCtrl.text.trim());
    if (stock == null || stock < 0) {
      return 'Please enter a valid stock quantity (>= 0)';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    final error = _validate();
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final price = double.parse(_priceCtrl.text.trim());
      final stock = int.parse(_stockCtrl.text.trim());
      final success = await widget.onSave(
        name: _nameCtrl.text.trim(),
        price: price,
        stock: stock,
        category: _selectedCategory,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Failed to update product details. Please retry.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final validCats = widget.categories.where((c) => c != 'All').toList();

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
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.penSquare,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Product Item',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MobilePosColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SKU: ${widget.product.sku}',
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
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(false),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: MobilePosColors.border),

          // Scrollable Form
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 14 + bottomInset),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  _buildLabel('Product Name *'),
                  TextField(
                    controller: _nameCtrl,
                    enabled: !_isSaving,
                    style: GoogleFonts.inter(fontSize: 13),
                    decoration: _inputDecoration('Enter product name'),
                  ),
                  const SizedBox(height: 14),

                  // Category
                  _buildLabel('Category'),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: MobilePosColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(
                          LucideIcons.chevronDown,
                          size: 16,
                          color: MobilePosColors.textSecondary,
                        ),
                        items: validCats.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: _isSaving
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Price & Stock Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Price (₹) *'),
                            TextField(
                              controller: _priceCtrl,
                              enabled: !_isSaving,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: GoogleFonts.inter(fontSize: 13),
                              decoration: _inputDecoration('0.00'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Stock (${widget.product.unit}) *'),
                            TextField(
                              controller: _stockCtrl,
                              enabled: !_isSaving,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13),
                              decoration: _inputDecoration('0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
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
                    onPressed: _isSaving
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
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: MobilePosColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 12,
        color: MobilePosColors.textMuted,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MobilePosColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MobilePosColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
