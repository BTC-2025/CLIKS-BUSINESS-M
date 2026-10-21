import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';

class MobileProductCard extends StatelessWidget {
  final MobilePosProduct product;
  final int cartQuantity;
  final VoidCallback onAddToCart;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncreaseStock;
  final VoidCallback? onDecreaseStock;
  final VoidCallback? onEditItem;
  final VoidCallback? onDeleteItem;

  const MobileProductCard({
    super.key,
    required this.product,
    required this.cartQuantity,
    required this.onAddToCart,
    this.onIncrement,
    this.onDecrement,
    this.onIncreaseStock,
    this.onDecreaseStock,
    this.onEditItem,
    this.onDeleteItem,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return const Color(0xFF2563EB); // Blue
      case 'furniture':
        return const Color(0xFFD97706); // Amber
      case 'vehicles':
        return const Color(0xFF7C3AED); // Purple
      case 'footwear':
        return const Color(0xFF0D9488); // Teal
      case 'accessories':
        return const Color(0xFFDB2777); // Pink
      default:
        return MobilePosColors.primaryGreen;
    }
  }

  Color _getCategoryBg(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return const Color(0xFFEFF6FF);
      case 'furniture':
        return const Color(0xFFFFFBEB);
      case 'vehicles':
        return const Color(0xFFF5F3FF);
      case 'footwear':
        return const Color(0xFFF0FDFA);
      case 'accessories':
        return const Color(0xFFFDF2F8);
      default:
        return MobilePosColors.lightGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableStock = product.stock - cartQuantity;
    final isOutOfStock = availableStock <= 0;
    final catColor = _getCategoryColor(product.category);
    final catBg = _getCategoryBg(product.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddToCart,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isOutOfStock ? const Color(0xFFF9FAFB) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: cartQuantity > 0
                  ? MobilePosColors.accentGreen
                  : const Color(0xFFE5E7EB),
              width: cartQuantity > 0 ? 1.5 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: cartQuantity > 0
                    ? MobilePosColors.accentGreen.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Section: Category & Actions, Name, SKU, Stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Category pill + 3-Dot Overflow Menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: catBg,
                            borderRadius: BorderRadius.circular(3.5),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: catColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      _buildOverflowMenu(context),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Row 2: Product Name (compact 2 lines)
                  SizedBox(
                    height: 27,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isOutOfStock
                            ? MobilePosColors.textMuted
                            : MobilePosColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Row 3: SKU & Cart badge (if any)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.sku,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            color: MobilePosColors.textMuted,
                          ),
                        ),
                      ),
                      if (cartQuantity > 0) ...[
                        const SizedBox(width: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3.5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$cartQuantity',
                            style: GoogleFonts.inter(
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2.5),

                  // Row 4: Stock Status Pill
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? MobilePosColors.dangerLight
                            : (availableStock <= 5
                                ? const Color(0xFFFFFBEB)
                                : const Color(0xFFF0FDF4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOutOfStock
                            ? 'Out of Stock'
                            : (cartQuantity > 0
                                ? '$availableStock left'
                                : '$availableStock in stock'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock
                              ? MobilePosColors.danger
                              : (availableStock <= 5
                                  ? const Color(0xFFD97706)
                                  : MobilePosColors.darkGreen),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Section: Price & Stepper / Add button
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '₹${formatIndianCurrency(product.price)}',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: isOutOfStock
                                    ? MobilePosColors.textMuted
                                    : MobilePosColors.primaryGreen,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Text(
                            'per ${product.unit}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: MobilePosColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 2),

                    // Actions: If in cart, show mini stepper; otherwise show "+" button
                    if (cartQuantity > 0 &&
                        onIncrement != null &&
                        onDecrement != null)
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: MobilePosColors.lightGreen,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: MobilePosColors.accentGreen.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: onDecrement,
                              borderRadius: BorderRadius.circular(5),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.5,
                                  vertical: 2,
                                ),
                                child: Icon(
                                  LucideIcons.minus,
                                  size: 11,
                                  color: MobilePosColors.primaryGreen,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              child: Text(
                                '$cartQuantity',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: MobilePosColors.primaryGreen,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: isOutOfStock
                                  ? () => onIncrement?.call()
                                  : onIncrement,
                              borderRadius: BorderRadius.circular(5),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3.5,
                                  vertical: 2,
                                ),
                                child: Icon(
                                  LucideIcons.plus,
                                  size: 11,
                                  color: isOutOfStock
                                      ? MobilePosColors.textMuted
                                      : MobilePosColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: onAddToCart,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? const Color(0xFFE5E7EB)
                                : MobilePosColors.primaryGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            LucideIcons.plus,
                            size: 13,
                            color: isOutOfStock
                                ? MobilePosColors.textMuted
                                : Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverflowMenu(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      tooltip: 'Product Actions',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      elevation: 6,
      position: PopupMenuPosition.under,
      child: Container(
        width: 19,
        height: 19,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          LucideIcons.ellipsisVertical,
          size: 11,
          color: Color(0xFF475569),
        ),
      ),
      onSelected: (val) {
        switch (val) {
          case 'increase':
            onIncreaseStock?.call();
            break;
          case 'decrease':
            onDecreaseStock?.call();
            break;
          case 'edit':
            onEditItem?.call();
            break;
          case 'delete':
            onDeleteItem?.call();
            break;
        }
      },
      itemBuilder: (ctx) => [
        _buildPopupMenuItem(
          value: 'increase',
          icon: LucideIcons.trendingUp,
          iconColor: const Color(0xFF16A34A),
          label: 'Increase Stock',
        ),
        _buildPopupMenuItem(
          value: 'decrease',
          icon: LucideIcons.trendingDown,
          iconColor: const Color(0xFFEA580C),
          label: 'Decrease Stock',
        ),
        _buildPopupMenuItem(
          value: 'edit',
          icon: LucideIcons.penSquare,
          iconColor: const Color(0xFF2563EB),
          label: 'Edit Item',
        ),
        const PopupMenuDivider(height: 1),
        _buildPopupMenuItem(
          value: 'delete',
          icon: LucideIcons.trash2,
          iconColor: const Color(0xFFEF4444),
          label: 'Delete Item',
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String label,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDestructive
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
