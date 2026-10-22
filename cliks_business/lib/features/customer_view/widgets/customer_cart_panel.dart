import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/customer_cart_item.dart';
import '../models/customer_view_settings_model.dart';
import '../utils/customer_theme_helper.dart';

class CustomerCartPanel extends StatelessWidget {
  final List<CustomerCartItem> cart;
  final double subtotal;
  final double gst;
  final double total;
  final CustomerViewSettings settings;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;
  final ValueChanged<int> onRemove;
  final VoidCallback onClear;
  final VoidCallback onCheckout;
  final Color primaryColor;

  const CustomerCartPanel({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.gst,
    required this.total,
    required this.settings,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onClear,
    required this.onCheckout,
    required this.primaryColor,
  });

  Widget _buildItemThumbnail(CustomerCartItem item) {
    if (item.product.customImagePath != null &&
        item.product.customImagePath!.isNotEmpty &&
        File(item.product.customImagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(item.product.customImagePath!),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildFallbackThumbnail(item),
        ),
      );
    }
    return _buildFallbackThumbnail(item);
  }

  Widget _buildFallbackThumbnail(CustomerCartItem item) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          LucideIcons.shoppingBag,
          size: 20,
          color: primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = cart.fold(0, (sum, i) => sum + i.quantity);
    final isDark = settings.isDarkMode;
    final panelBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final radius = Radius.circular(settings.borderRadius);

    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.all(radius),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. HEADER ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.shoppingBag,
                        size: 18,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'My Tray',
                      style: CustomerThemeHelper.font(
                        settings,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalItems items',
                        style: CustomerThemeHelper.font(
                          settings,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
                if (cart.isNotEmpty)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                    label: Text(
                      'Clear',
                      style: CustomerThemeHelper.font(
                        settings,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6)),

          // ─── 2. ITEMS LIST OR EMPTY STATE ───
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.utensilsCrossed,
                              size: 32,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your tray is empty',
                            style: CustomerThemeHelper.font(
                              settings,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select delicious items from the catalog to build your order.',
                            textAlign: TextAlign.center,
                            style: CustomerThemeHelper.font(
                              settings,
                              fontSize: 12,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: cart.length,
                    separatorBuilder: (ctx, i) => Divider(
                      height: 16,
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                    ),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Item Thumbnail
                          _buildItemThumbnail(item),
                          const SizedBox(width: 12),

                          // Title, Variant, Unit Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: CustomerThemeHelper.font(
                                    settings,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                if (item.selectedVariant != null)
                                  Text(
                                    item.selectedVariant!,
                                    style: CustomerThemeHelper.font(
                                      settings,
                                      fontSize: 11,
                                      color: subtextColor,
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  CustomerThemeHelper.formatPrice(settings, item.lineTotal),
                                  style: CustomerThemeHelper.font(
                                    settings,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quantity Controls (- QTY +)
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF475569) : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => onDecrement(index),
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(LucideIcons.minus, size: 13, color: subtextColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '${item.quantity}',
                                    style: CustomerThemeHelper.font(
                                      settings,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => onIncrement(index),
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(LucideIcons.plus, size: 13, color: primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // ─── 3. PAYMENT BREAKDOWN & CHECKOUT BUTTON ───
          if (cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.vertical(bottom: radius),
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: CustomerThemeHelper.font(settings, fontSize: 12.5, color: subtextColor),
                      ),
                      Text(
                        CustomerThemeHelper.formatPrice(settings, subtotal),
                        style: CustomerThemeHelper.font(
                          settings,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  if (settings.taxDisplayMode == 'breakdown') ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated GST (18%)',
                          style: CustomerThemeHelper.font(settings, fontSize: 12.5, color: subtextColor),
                        ),
                        Text(
                          CustomerThemeHelper.formatPrice(settings, gst),
                          style: CustomerThemeHelper.font(
                            settings,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: textColor,
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
                          'Taxes & Duties',
                          style: CustomerThemeHelper.font(settings, fontSize: 12.5, color: subtextColor),
                        ),
                        Text(
                          'Inclusive in Price',
                          style: CustomerThemeHelper.font(
                            settings,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: CustomerThemeHelper.font(
                          settings,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      Text(
                        CustomerThemeHelper.formatPrice(
                          settings,
                          settings.taxDisplayMode == 'inclusive' ? subtotal : total,
                        ),
                        style: CustomerThemeHelper.font(
                          settings,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Big Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(radius),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.arrowRight, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Proceed to Checkout',
                            style: CustomerThemeHelper.font(
                              settings,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
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
}
