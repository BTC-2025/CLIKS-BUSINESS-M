import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/customer_product_model.dart';
import '../models/customer_view_settings_model.dart';
import '../utils/customer_theme_helper.dart';

class CustomerProductCard extends StatelessWidget {
  final CustomerProduct product;
  final CustomerViewSettings settings;
  final int cartQuantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CustomerProductCard({
    super.key,
    required this.product,
    required this.settings,
    required this.cartQuantity,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('dining') || cat.contains('burger')) {
      return LucideIcons.utensils;
    }
    if (cat.contains('bever') || cat.contains('coffee') || cat.contains('drink')) {
      return LucideIcons.coffee;
    }
    if (cat.contains('elec')) {
      return LucideIcons.laptop;
    }
    if (cat.contains('vehic') || cat.contains('car')) {
      return LucideIcons.car;
    }
    if (cat.contains('foot') || cat.contains('shoe')) {
      return LucideIcons.footprints;
    }
    return LucideIcons.shoppingBag;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food')) return const Color(0xFFF97316); // Orange
    if (cat.contains('bever')) return const Color(0xFF06B6D4); // Cyan
    if (cat.contains('elec')) return const Color(0xFF6366F1); // Indigo
    if (cat.contains('vehic')) return const Color(0xFFEF4444); // Red
    if (cat.contains('foot')) return const Color(0xFF8B5CF6); // Purple
    return const Color(0xFF10B981); // Emerald
  }

  Widget _buildDietaryBadge() {
    final isVeg = product.isVeg;
    final color = isVeg ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: isVeg ? BoxShape.circle : BoxShape.rectangle,
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.customImagePath != null &&
        product.customImagePath!.isNotEmpty &&
        File(product.customImagePath!).existsSync()) {
      return Image.file(
        File(product.customImagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, stack) => _buildFallbackImage(),
      );
    }
    if (product.networkImageUrl != null && product.networkImageUrl!.isNotEmpty) {
      return Image.network(
        product.networkImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, stack) => _buildFallbackImage(),
      );
    }
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    final catColor = _getCategoryColor(product.category);
    return Container(
      color: catColor.withValues(alpha: 0.12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getCategoryIcon(product.category),
            size: 32,
            color: catColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.isAvailable;
    final primaryColor = Color(settings.primaryColorValue);
    final accentColor = Color(settings.accentColorValue);
    final isDark = settings.isDarkMode;
    final radius = Radius.circular(settings.borderRadius);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    // Card decoration according to productCardStyle
    final isBorderedOnly = settings.productCardStyle == 'bordered';
    final isMinimal = settings.productCardStyle == 'minimal';

    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.all(radius),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.all(radius),
          border: Border.all(
            color: cartQuantity > 0
                ? primaryColor.withValues(alpha: 0.75)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
            width: cartQuantity > 0 ? 2.0 : 1.0,
          ),
          boxShadow: (isBorderedOnly || isMinimal)
              ? null
              : [
                  BoxShadow(
                    color: cartQuantity > 0
                        ? primaryColor.withValues(alpha: 0.14)
                        : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP IMAGE AREA ───
            if (settings.showProductImages)
              Expanded(
                flex: 11,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(settings.borderRadius - 1)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _buildProductImage(),
                      ),
                    ),

                    // Top Left: Veg/Non-Veg & Category Pill Tag
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (settings.enableDietaryFilters) ...[
                            _buildDietaryBadge(),
                            const SizedBox(width: 5),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B).withValues(alpha: 0.94)
                                  : Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(product.category),
                                  size: 11,
                                  color: _getCategoryColor(product.category),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.category,
                                  style: CustomerThemeHelper.font(
                                    settings,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Right: Rating Pill or Best Seller Badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (product.isFeatured)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accentColor, accentColor.withValues(alpha: 0.85)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.sparkles, size: 9, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    'POPULAR',
                                    style: CustomerThemeHelper.font(
                                      settings,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFBBF24)),
                                const SizedBox(width: 2),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: CustomerThemeHelper.font(
                                    settings,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Left inside image: Calories Chip
                    if (settings.showCalories && product.calories != null && product.calories!.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.flame, size: 9, color: Color(0xFFF97316)),
                              const SizedBox(width: 3),
                              Text(
                                product.calories!,
                                style: CustomerThemeHelper.font(
                                  settings,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Out of stock overlay
                    if (!isAvailable)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(settings.borderRadius - 1)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'SOLD OUT',
                              style: CustomerThemeHelper.font(
                                settings,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // ─── 2. INFO & ACTION AREA ───
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CustomerThemeHelper.font(
                            settings,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Short Description if enabled
                        if (settings.showProductDescriptions && product.description.isNotEmpty)
                          Text(
                            product.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomerThemeHelper.font(
                              settings,
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),

                    // Price & Add to Cart row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CustomerThemeHelper.formatPrice(settings, product.price),
                              style: CustomerThemeHelper.font(
                                settings,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                            if (settings.showProductAvailability && isAvailable)
                              Text(
                                'In Stock',
                                style: CustomerThemeHelper.font(
                                  settings,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                          ],
                        ),

                        // Action Button
                        if (!isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Unavailable',
                              style: CustomerThemeHelper.font(
                                settings,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        else if (cartQuantity == 0)
                          ElevatedButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(LucideIcons.plus, size: 14),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: CustomerThemeHelper.font(
                                settings,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          // Active Stepper (- QTY +)
                          Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: onDecrement,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(LucideIcons.minus, size: 14, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '$cartQuantity',
                                    style: CustomerThemeHelper.font(
                                      settings,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: onIncrement,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(LucideIcons.plus, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
