import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';

class MobilePosReceiptModal extends StatelessWidget {
  final MobilePosSale sale;
  final VoidCallback? onNewOrder;

  const MobilePosReceiptModal({
    super.key,
    required this.sale,
    this.onNewOrder,
  });

  static Future<void> show({
    required BuildContext context,
    required MobilePosSale sale,
    VoidCallback? onNewOrder,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobilePosReceiptModal(
        sale: sale,
        onNewOrder: onNewOrder,
      ),
    );
  }

  Widget _buildThermalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final items = sale.items.isNotEmpty
        ? sale.items
        : [
            MobileCartItem(
              product: MobilePosProduct(
                id: 'item-1',
                name: 'General Item',
                sku: 'SKU: GEN',
                category: 'General',
                price:
                    sale.totalAmount / (sale.itemCount > 0 ? sale.itemCount : 1),
                stock: 100,
              ),
              quantity: sale.itemCount > 0 ? sale.itemCount : 1,
            ),
          ];

    final rawSubtotal = items.fold(0.0, (sum, i) => sum + i.total);
    final cgst = (rawSubtotal * 0.09);
    final sgst = (rawSubtotal * 0.09);
    final calculatedTotal = rawSubtotal + cgst + sgst;
    final grandTotal = sale.totalAmount > 0 ? sale.totalAmount : calculatedTotal;
    final roundOff = grandTotal - calculatedTotal;

    final modeClean = sale.paymentMode
        .replaceAll(RegExp(r'\(.*\)'), '')
        .trim()
        .toUpperCase();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ══════════════════════════════════════════════════════════════
            // TOP GREEN HEADER (Matching flutter_07.png)
            // ══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: const BoxDecoration(
                color: Color(0xFF00B074),
              ),
              child: Stack(
                children: [
                  // Centered Success Badge & Titles
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF48BB78).withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.check,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Payment Successful!',
                          style: GoogleFonts.inter(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order ${sale.billNo} generated',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close (X) button in white circle on top right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onNewOrder?.call();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          size: 17,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════════════════════════════════
            // THERMAL RECEIPT BODY (Matching flutter_07.png)
            // ══════════════════════════════════════════════════════════════
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Store Branding
                    Center(
                      child: Text(
                        'MAIN SHOWROOM',
                        style: GoogleFonts.inter(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Center(
                      child: Text(
                        'Central Commercial Hub',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Center(
                      child: Text(
                        'Ph: 637494343 | ravinew2004@bnxmail.com',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Receipt No: ${sale.billNo}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Dashed separator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '--------------------------------------------------------------------------------',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black54,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Date & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: $dateStr',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Time: $timeStr',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Customer & Mode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Customer: ${sale.customer}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          'Mode: $modeClean',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    // Dashed separator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '--------------------------------------------------------------------------------',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black54,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Table Header
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'ITEM',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'QTY',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'RATE',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'AMOUNT',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Items List
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${item.quantity} PCS',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '₹${formatIndianCurrency(item.product.price)}',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '₹${formatIndianCurrency(item.total)}',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Dashed separator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '--------------------------------------------------------------------------------',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black54,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Financial Calculations Breakdown
                    _buildThermalRow('SUBTOTAL:', '₹${formatIndianCurrency(rawSubtotal)}'),
                    const SizedBox(height: 5),
                    _buildThermalRow('CGST:', '₹${formatIndianCurrency(cgst)}'),
                    const SizedBox(height: 5),
                    _buildThermalRow('SGST:', '₹${formatIndianCurrency(sgst)}'),
                    const SizedBox(height: 5),
                    _buildThermalRow('IGST:', '₹0'),
                    const SizedBox(height: 5),
                    _buildThermalRow(
                      'ROUND OFF:',
                      '₹${roundOff >= 0 ? '' : ''}${roundOff.toStringAsFixed(1)}',
                    ),

                    // Solid separator line
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '________________________________________________________________________________',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Grand Total Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GRAND TOTAL:',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '₹${formatIndianCurrency(grandTotal)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    // Dashed separator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '--------------------------------------------------------------------------------',
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black54,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ══════════════════════════════════════════════════════════════
            // BOTTOM ACTION BUTTONS (Print & New Order)
            // ══════════════════════════════════════════════════════════════
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  // Print button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Receipt #${sale.billNo} sent to thermal printer.',
                              style: GoogleFonts.inter(),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF166534),
                          ),
                        );
                      },
                      icon: const Icon(
                        LucideIcons.printer,
                        size: 16,
                        color: Color(0xFF0F172A),
                      ),
                      label: Text(
                        'Print',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // New Order button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onNewOrder?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'New Order',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
