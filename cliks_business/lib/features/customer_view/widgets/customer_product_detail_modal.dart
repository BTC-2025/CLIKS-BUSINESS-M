import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/customer_product_model.dart';
import '../models/customer_view_settings_model.dart';

class CustomerProductDetailModal extends StatefulWidget {
  final CustomerProduct product;
  final CustomerViewSettings settings;
  final Function({
    required int quantity,
    String? variant,
    List<String> addOns,
    String instructions,
    double extraPrice,
  }) onAddToCart;

  const CustomerProductDetailModal({
    super.key,
    required this.product,
    required this.settings,
    required this.onAddToCart,
  });

  @override
  State<CustomerProductDetailModal> createState() =>
      _CustomerProductDetailModalState();
}

class _CustomerProductDetailModalState
    extends State<CustomerProductDetailModal> {
  int _quantity = 1;
  String? _selectedVariant;
  final List<String> _selectedAddOns = [];
  final TextEditingController _instructionsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product.availableVariants.isNotEmpty) {
      _selectedVariant = widget.product.availableVariants.first;
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double _getVariantExtraPrice(String? variant) {
    if (variant == null) return 0.0;
    if (variant.contains('+₹')) {
      final parts = variant.split('+₹');
      if (parts.length > 1) {
        final amountPart = parts[1].replaceAll(')', '').trim();
        return double.tryParse(amountPart) ?? 0.0;
      }
    }
    return 0.0;
  }

  double get _computedUnitPrice {
    double extra = _getVariantExtraPrice(_selectedVariant);
    extra += _selectedAddOns.length * 25.0; // ₹25 per extra addon
    return widget.product.price + extra;
  }

  double get _computedTotalPrice => _computedUnitPrice * _quantity;

  Widget _buildImageHeader(Color primaryColor) {
    if (widget.product.customImagePath != null &&
        widget.product.customImagePath!.isNotEmpty &&
        File(widget.product.customImagePath!).existsSync()) {
      return Image.file(
        File(widget.product.customImagePath!),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    if (widget.product.networkImageUrl != null &&
        widget.product.networkImageUrl!.isNotEmpty) {
      return Image.network(
        widget.product.networkImageUrl!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildFallbackHeader(primaryColor),
      );
    }
    return _buildFallbackHeader(primaryColor);
  }

  Widget _buildFallbackHeader(Color primaryColor) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.2),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.utensils,
            size: 34,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(widget.settings.primaryColorValue);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 580,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ─── 1. IMAGE & CLOSE BUTTON ───
            Stack(
              children: [
                _buildImageHeader(primaryColor),
                Positioned(
                  top: 14,
                  right: 14,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.x, size: 18, color: Color(0xFF374151)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.product.category,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ─── 2. CONTENT SCROLLABLE BODY ───
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '₹${_computedUnitPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),

                    if (widget.product.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Variant Options
                    if (widget.product.availableVariants.isNotEmpty) ...[
                      Text(
                        'Select Size / Option',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.product.availableVariants.map((v) {
                          final isSelected = _selectedVariant == v;
                          return ChoiceChip(
                            label: Text(v),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedVariant = v);
                              }
                            },
                            selectedColor: primaryColor.withValues(alpha: 0.15),
                            backgroundColor: const Color(0xFFF9FAFB),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? primaryColor : const Color(0xFF4B5563),
                            ),
                            side: BorderSide(
                              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Add-ons
                    if (widget.product.availableAddOns.isNotEmpty) ...[
                      Text(
                        'Add-ons & Extras (+₹25 each)',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.product.availableAddOns.map((addon) {
                          final isSelected = _selectedAddOns.contains(addon);
                          return FilterChip(
                            label: Text(addon),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAddOns.add(addon);
                                } else {
                                  _selectedAddOns.remove(addon);
                                }
                              });
                            },
                            selectedColor: primaryColor.withValues(alpha: 0.15),
                            backgroundColor: const Color(0xFFF9FAFB),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? primaryColor : const Color(0xFF4B5563),
                            ),
                            side: BorderSide(
                              color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Special instructions text field
                    Text(
                      'Special Request / Custom Note',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _instructionsController,
                      style: GoogleFonts.inter(fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: 'e.g., Less spicy, no mayo, extra ice, gift pack...',
                        hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── 3. BOTTOM FOOTER WITH QUANTITY & ADD BUTTON ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  // Quantity Stepper
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(LucideIcons.minus, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '$_quantity',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(LucideIcons.plus, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Add to Tray Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onAddToCart(
                            quantity: _quantity,
                            variant: _selectedVariant,
                            addOns: _selectedAddOns,
                            instructions: _instructionsController.text.trim(),
                            extraPrice: _computedUnitPrice - widget.product.price,
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.shoppingBag, size: 17),
                            const SizedBox(width: 8),
                            Text(
                              'Add to Tray • ₹${_computedTotalPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
