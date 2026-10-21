import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';

class MobileHeldCartsSheet extends StatelessWidget {
  final List<MobileHeldCart> heldCarts;
  final ValueChanged<MobileHeldCart> onRestoreCart;
  final ValueChanged<MobileHeldCart> onDiscardCart;

  const MobileHeldCartsSheet({
    super.key,
    required this.heldCarts,
    required this.onRestoreCart,
    required this.onDiscardCart,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: MobilePosColors.warningLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.pauseCircle,
                      size: 18,
                      color: MobilePosColors.warning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hold Carts (${heldCarts.length})',
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
          const Divider(height: 1, color: MobilePosColors.border),
          const SizedBox(height: 8),

          Flexible(
            child: heldCarts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.pauseCircle,
                          size: 40,
                          color: MobilePosColors.textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No hold carts found',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MobilePosColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Active carts marked on hold will appear here.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: MobilePosColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: heldCarts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final held = heldCarts[idx];
                      final itemCount = held.items.fold(
                        0,
                        (sum, i) => sum + i.quantity,
                      );

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: MobilePosColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.user,
                                      size: 14,
                                      color: MobilePosColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      held.customer.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: MobilePosColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${formatIndianCurrency(held.totalAmount)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: MobilePosColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$itemCount Items: ${held.items.map((i) => "${i.quantity}x ${i.product.name}").take(2).join(", ")}${held.items.length > 2 ? "..." : ""}',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: MobilePosColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    onDiscardCart(held);
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    LucideIcons.trash2,
                                    size: 12,
                                  ),
                                  label: Text(
                                    'Discard',
                                    style: GoogleFonts.inter(fontSize: 11),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: MobilePosColors.danger,
                                    side: const BorderSide(
                                      color: Color(0xFFFECACA),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    onRestoreCart(held);
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(LucideIcons.play, size: 12),
                                  label: Text(
                                    'Restore Cart',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        MobilePosColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
