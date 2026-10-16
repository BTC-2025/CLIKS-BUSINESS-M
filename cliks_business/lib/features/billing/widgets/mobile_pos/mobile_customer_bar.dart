import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_customer_sheet.dart';
import 'mobile_pos_utils.dart';

class MobileCustomerBar extends StatelessWidget {
  final MobileCustomer currentCustomer;
  final List<MobileCustomer> customers;
  final ValueChanged<MobileCustomer> onSelectCustomer;
  final ValueChanged<MobileCustomer> onRegisterCustomer;

  const MobileCustomerBar({
    super.key,
    required this.currentCustomer,
    required this.customers,
    required this.onSelectCustomer,
    required this.onRegisterCustomer,
  });

  void _openCustomerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobileCustomerSheet(
        currentCustomer: currentCustomer,
        customers: customers,
        onSelectCustomer: onSelectCustomer,
        onRegisterCustomer: onRegisterCustomer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWalkIn = currentCustomer.isWalkIn;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: Row(
        children: [
          // Icon Avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isWalkIn
                  ? const Color(0xFFF3F4F6)
                  : MobilePosColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWalkIn ? LucideIcons.user : LucideIcons.userCheck,
              size: 16,
              color: isWalkIn
                  ? MobilePosColors.textSecondary
                  : MobilePosColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 10),

          // Customer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        currentCustomer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: MobilePosColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!isWalkIn && currentCustomer.loyaltyPoints > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${currentCustomer.loyaltyPoints} pts',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  isWalkIn
                      ? 'Tap to assign customer or loyalty'
                      : (currentCustomer.phone.isNotEmpty
                            ? currentCustomer.phone
                            : (currentCustomer.email.isNotEmpty
                                  ? currentCustomer.email
                                  : currentCustomer.gstin)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: MobilePosColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Change / Select Button
          InkWell(
            onTap: () => _openCustomerSheet(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isWalkIn
                    ? MobilePosColors.lightGreen
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isWalkIn ? 'Add / Select' : 'Change',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isWalkIn
                          ? MobilePosColors.primaryGreen
                          : MobilePosColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 12,
                    color: isWalkIn
                        ? MobilePosColors.primaryGreen
                        : MobilePosColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Reset to walk-in if registered customer selected
          if (!isWalkIn) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: () => onSelectCustomer(MobileCustomer.walkIn),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  LucideIcons.x,
                  size: 14,
                  color: MobilePosColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
