import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';
import 'mobile_receipt_modal.dart';

class MobileHistorySheet extends StatefulWidget {
  final List<MobilePosSale> salesHistory;

  const MobileHistorySheet({super.key, required this.salesHistory});

  @override
  State<MobileHistorySheet> createState() => _MobileHistorySheetState();
}

class _MobileHistorySheetState extends State<MobileHistorySheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedMode = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MobilePosSale> get _filteredSales {
    return widget.salesHistory.where((sale) {
      final matchesQuery =
          _query.isEmpty ||
          sale.billNo.toLowerCase().contains(_query.toLowerCase()) ||
          sale.customer.toLowerCase().contains(_query.toLowerCase());

      final matchesMode =
          _selectedMode == 'All' ||
          sale.paymentMode.toLowerCase().contains(_selectedMode.toLowerCase());

      return matchesQuery && matchesMode;
    }).toList();
  }

  double get _totalCollections =>
      widget.salesHistory.fold(0.0, (sum, s) => sum + s.totalAmount);

  void _showSaleDetail(MobilePosSale sale) {
    MobilePosReceiptModal.show(context: context, sale: sale);
  }


  Color _getModeColor(String mode) {
    if (mode.toLowerCase().contains('upi')) return MobilePosColors.purple;
    if (mode.toLowerCase().contains('cash')) return MobilePosColors.accentGreen;
    return const Color(0xFFD97706);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
                      color: MobilePosColors.blueLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.history,
                      size: 18,
                      color: MobilePosColors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sales Register',
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

          // Today's Collection Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MobilePosColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY\'S TOTAL POS SALES',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: MobilePosColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.salesHistory.length} Bills Completed',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: MobilePosColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '₹${formatIndianCurrency(_totalCollections)}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: MobilePosColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Search Bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: MobilePosColors.surfaceBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MobilePosColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.search,
                  size: 14,
                  color: MobilePosColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _query = val),
                    style: GoogleFonts.inter(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Filter by bill number or customer...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: MobilePosColors.textMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Filter Mode Chips
          Row(
            children: ['All', 'Cash', 'UPI', 'Card'].map((mode) {
              final isSel = _selectedMode == mode;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    mode,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: MobilePosColors.lightGreen,
                  onSelected: (val) => setState(() => _selectedMode = mode),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: MobilePosColors.border),

          // Sales List
          Expanded(
            child: _filteredSales.isEmpty
                ? Center(
                    child: Text(
                      'No sales found',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: MobilePosColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredSales.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 8, color: Colors.transparent),
                    itemBuilder: (context, idx) {
                      final s = _filteredSales[idx];
                      final modeColor = _getModeColor(s.paymentMode);

                      return InkWell(
                        onTap: () => _showSaleDetail(s),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: MobilePosColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: modeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  LucideIcons.receipt,
                                  color: modeColor,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.billNo,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: MobilePosColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      '${s.customer} • ${s.itemCount} Items',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: MobilePosColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${formatIndianCurrency(s.totalAmount)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: MobilePosColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${s.paymentMode} • ${s.time}',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: MobilePosColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                LucideIcons.chevronRight,
                                size: 14,
                                color: MobilePosColors.textMuted,
                              ),
                            ],
                          ),
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
