import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'mobile_pos_utils.dart';

class MobilePosHeader extends StatelessWidget {
  final String selectedWarehouse;
  final List<String> warehouses;
  final ValueChanged<String> onWarehouseSelected;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenHeldCarts;
  final int heldCartsCount;
  final VoidCallback onQuickAddProduct;
  final VoidCallback? onBack;

  const MobilePosHeader({
    super.key,
    required this.selectedWarehouse,
    required this.warehouses,
    required this.onWarehouseSelected,
    required this.onOpenHistory,
    required this.onOpenHeldCarts,
    required this.heldCartsCount,
    required this.onQuickAddProduct,
    this.onBack,
  });

  void _showWarehousePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.of(ctx).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(
                  LucideIcons.warehouse,
                  size: 18,
                  color: MobilePosColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select POS Warehouse',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MobilePosColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: MobilePosColors.border),
            const SizedBox(height: 8),
            ...warehouses.map((wh) {
              final isSelected = wh == selectedWarehouse;
              return InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onWarehouseSelected(wh);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MobilePosColors.lightGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? MobilePosColors.accentGreen.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.store,
                            size: 16,
                            color: isSelected
                                ? MobilePosColors.primaryGreen
                                : MobilePosColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            wh,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? MobilePosColors.primaryGreen
                                  : MobilePosColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        const Icon(
                          LucideIcons.check,
                          size: 18,
                          color: MobilePosColors.accentGreen,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Row(
        children: [
          // Branding Icon / Back Button
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: MobilePosColors.lightGreen,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                onBack != null
                    ? LucideIcons.arrowLeft
                    : LucideIcons.shoppingCart,
                size: 17,
                color: MobilePosColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Title & Warehouse subtitle (Flexible)
          Expanded(
            child: InkWell(
              onTap: () => _showWarehousePicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'POS Billing',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: MobilePosColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'LIVE',
                                style: GoogleFonts.inter(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            selectedWarehouse,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: MobilePosColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          LucideIcons.chevronDown,
                          size: 11,
                          color: MobilePosColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Action 1: Warehouse Switch Icon
          InkWell(
            onTap: () => _showWarehousePicker(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: MobilePosColors.surfaceBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MobilePosColors.border),
              ),
              child: const Icon(
                LucideIcons.warehouse,
                size: 15,
                color: MobilePosColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Action 2: Held Carts Button
          if (heldCartsCount > 0) ...[
            InkWell(
              onTap: onOpenHeldCarts,
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: MobilePosColors.warningLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Icon(
                      LucideIcons.pauseCircle,
                      size: 15,
                      color: MobilePosColors.warning,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: MobilePosColors.warning,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        '$heldCartsCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
          ],

          // Action 3: Sales History Button
          InkWell(
            onTap: onOpenHistory,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: MobilePosColors.blueLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Icon(
                LucideIcons.history,
                size: 15,
                color: MobilePosColors.blue,
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Action 4: Quick Add Product Button
          InkWell(
            onTap: onQuickAddProduct,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: MobilePosColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.plus,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
