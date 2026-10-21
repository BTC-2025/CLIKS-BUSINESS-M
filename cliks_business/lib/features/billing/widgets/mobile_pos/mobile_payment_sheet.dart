import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/mobile_pos_models.dart';
import 'mobile_pos_utils.dart';
import 'mobile_receipt_modal.dart';

class MobilePaymentSheet extends StatefulWidget {
  final double payableAmount;
  final MobileCustomer customer;
  final List<MobileCartItem> cart;
  final ValueChanged<MobilePosSale> onPaymentCompleted;

  const MobilePaymentSheet({
    super.key,
    required this.payableAmount,
    required this.customer,
    required this.cart,
    required this.onPaymentCompleted,
  });

  @override
  State<MobilePaymentSheet> createState() => _MobilePaymentSheetState();
}

class _MobilePaymentSheetState extends State<MobilePaymentSheet> {
  PaymentMode _selectedMode = PaymentMode.cash;
  bool _isProcessing = false;

  // Cash payment state
  late TextEditingController _tenderedCtrl;
  double _tenderedAmount = 0.0;

  // UPI payment state
  String _upiTxnId = '';

  // Card payment state
  String _cardAuthCode = '';

  @override
  void initState() {
    super.initState();
    _tenderedAmount = widget.payableAmount;
    _tenderedCtrl = TextEditingController(
      text: widget.payableAmount.toStringAsFixed(0),
    );
    _upiTxnId =
        'UPI-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    _cardAuthCode =
        'AUTH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  void dispose() {
    _tenderedCtrl.dispose();
    super.dispose();
  }

  double get _changeDue =>
      (_tenderedAmount - widget.payableAmount).clamp(0.0, double.infinity);
  double get _shortAmount =>
      (widget.payableAmount - _tenderedAmount).clamp(0.0, double.infinity);

  void _processPayment() async {
    if (_isProcessing) return;

    if (_selectedMode == PaymentMode.cash &&
        _tenderedAmount < widget.payableAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tendered amount is less than payable amount by ₹${formatIndianCurrency(_shortAmount)}',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: MobilePosColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment transaction network latency
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    final billNo =
        'POS-BILL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final now = DateTime.now();
    final timeStr =
        '${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    final paymentModeStr = _selectedMode == PaymentMode.cash
        ? 'Cash (F1)'
        : (_selectedMode == PaymentMode.upi ? 'UPI (F2)' : 'Card (F3)');

    final sale = MobilePosSale(
      billNo: billNo,
      customer: widget.customer.name,
      itemCount: widget.cart.fold(0, (sum, i) => sum + i.quantity),
      totalAmount: widget.payableAmount,
      paymentMode: paymentModeStr,
      time: timeStr,
      items: List.from(widget.cart),
    );

    setState(() => _isProcessing = false);

    Navigator.pop(context); // close payment sheet
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    widget.onPaymentCompleted(sale);
    MobilePosReceiptModal.show(
      context: context,
      sale: sale,
    );
  }

  void _showReceiptDialog(MobilePosSale sale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: MobilePosColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.checkCircle2,
                  color: MobilePosColors.primaryGreen,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Payment Completed!',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: MobilePosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Amount ₹${formatIndianCurrency(sale.totalAmount)} received via ${sale.paymentMode}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: MobilePosColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // Summary Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MobilePosColors.border),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Bill Number', sale.billNo, isBold: true),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Customer', sale.customer),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Items Count', '${sale.itemCount} Items'),
                    const SizedBox(height: 6),
                    _buildReceiptRow(
                      'Payment Mode',
                      sale.paymentMode,
                      valueColor: MobilePosColors.accentGreen,
                    ),
                    if (_selectedMode == PaymentMode.cash &&
                        _changeDue > 0) ...[
                      const SizedBox(height: 6),
                      _buildReceiptRow(
                        'Cash Tendered',
                        '₹${formatIndianCurrency(_tenderedAmount)}',
                      ),
                      const SizedBox(height: 6),
                      _buildReceiptRow(
                        'Change Returned',
                        '₹${formatIndianCurrency(_changeDue)}',
                        valueColor: MobilePosColors.blue,
                      ),
                    ],
                    const Divider(height: 14, color: MobilePosColors.border),
                    _buildReceiptRow(
                      'Total Paid',
                      '₹${formatIndianCurrency(sale.totalAmount)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actions: Print Receipt & New Sale
              Row(
                children: [
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
                            backgroundColor: MobilePosColors.darkGreen,
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.printer, size: 15),
                      label: Text(
                        'Print',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MobilePosColors.textPrimary,
                        side: const BorderSide(color: MobilePosColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onPaymentCompleted(sale);
                      },
                      icon: const Icon(LucideIcons.plus, size: 15),
                      label: Text(
                        'New Sale',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MobilePosColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 13 : 11.5,
            color: isTotal
                ? MobilePosColors.textPrimary
                : MobilePosColors.textSecondary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal || isBold ? FontWeight.bold : FontWeight.w600,
            color:
                valueColor ??
                (isTotal
                    ? MobilePosColors.primaryGreen
                    : MobilePosColors.textPrimary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: MobilePosColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.creditCard,
                      size: 18,
                      color: MobilePosColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Complete Payment',
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

          // Amount to Pay Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MobilePosColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PAYABLE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: MobilePosColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Customer: ${widget.customer.name}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: MobilePosColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${formatIndianCurrency(widget.payableAmount)}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: MobilePosColors.primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Method Selector Tabs
          Row(
            children: [
              _buildMethodTab(
                mode: PaymentMode.cash,
                label: 'Cash (F1)',
                icon: LucideIcons.banknote,
                color: MobilePosColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              _buildMethodTab(
                mode: PaymentMode.upi,
                label: 'UPI (F2)',
                icon: LucideIcons.qrCode,
                color: MobilePosColors.purple,
              ),
              const SizedBox(width: 8),
              _buildMethodTab(
                mode: PaymentMode.card,
                label: 'Card (F3)',
                icon: LucideIcons.creditCard,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Payment View Body according to selected method
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildSelectedMethodBody(),
            ),
          ),
          const SizedBox(height: 14),

          // Submit Payment Button
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMode == PaymentMode.cash
                      ? MobilePosColors.primaryGreen
                      : (_selectedMode == PaymentMode.upi
                            ? MobilePosColors.purple
                            : const Color(0xFFD97706)),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedMode == PaymentMode.cash
                                ? LucideIcons.check
                                : (_selectedMode == PaymentMode.upi
                                      ? LucideIcons.qrCode
                                      : LucideIcons.creditCard),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedMode == PaymentMode.cash
                                ? 'Confirm Cash Payment'
                                : (_selectedMode == PaymentMode.upi
                                      ? 'Verify & Collect UPI'
                                      : 'Authorize Card Payment'),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTab({
    required PaymentMode mode,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMode = mode),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : MobilePosColors.border,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : MobilePosColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : MobilePosColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMethodBody() {
    switch (_selectedMode) {
      case PaymentMode.cash:
        return _buildCashBody();
      case PaymentMode.upi:
        return _buildUpiBody();
      case PaymentMode.card:
        return _buildCardBody();
    }
  }

  Widget _buildCashBody() {
    final payable = widget.payableAmount;
    final quickAmounts = <double>{
      payable,
      (payable / 100).ceil() * 100.0,
      (payable / 500).ceil() * 500.0,
      (payable / 1000).ceil() * 1000.0,
    }.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CASH TENDERED',
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: MobilePosColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Cash Input Field
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: MobilePosColors.border),
          ),
          child: Row(
            children: [
              Text(
                '₹',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MobilePosColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _tenderedCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _tenderedAmount = double.tryParse(val.trim()) ?? 0.0;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Quick Tender Chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: quickAmounts.map((amt) {
            final isExact = amt == payable;
            return ActionChip(
              label: Text(
                isExact
                    ? 'Exact (₹${formatIndianCurrency(amt)})'
                    : '₹${formatIndianCurrency(amt)}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: MobilePosColors.surfaceBg,
              onPressed: () {
                setState(() {
                  _tenderedAmount = amt;
                  _tenderedCtrl.text = amt.toStringAsFixed(
                    amt.truncateToDouble() == amt ? 0 : 2,
                  );
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Change Due / Shortage Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _shortAmount > 0
                ? MobilePosColors.dangerLight
                : MobilePosColors.lightGreen,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _shortAmount > 0
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFBBF7D0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _shortAmount > 0
                        ? LucideIcons.alertCircle
                        : LucideIcons.arrowRightCircle,
                    size: 16,
                    color: _shortAmount > 0
                        ? MobilePosColors.danger
                        : MobilePosColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _shortAmount > 0
                        ? 'Remaining to collect:'
                        : 'Change to return:',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _shortAmount > 0
                          ? MobilePosColors.danger
                          : MobilePosColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${formatIndianCurrency(_shortAmount > 0 ? _shortAmount : _changeDue)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _shortAmount > 0
                      ? MobilePosColors.danger
                      : MobilePosColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpiBody() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.qrCode,
                color: MobilePosColors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Scan QR with any UPI App',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: MobilePosColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Simulated QR Code Frame
          Container(
            width: 140,
            height: 140,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9D5FF), width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.qrCode,
                    size: 68,
                    color: MobilePosColors.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${formatIndianCurrency(widget.payableAmount)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: MobilePosColors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Merchant VPA & Txn ID
          Text(
            'UPI ID: cliks.business@icici',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MobilePosColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Ref ID: $_upiTxnId',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: MobilePosColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBody() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.creditCard,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Swipe, Tap, or Insert Card',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.wifi,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POS Terminal #01 (Connected)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ready to accept Visa, Mastercard, RuPay',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: MobilePosColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terminal Ref: $_cardAuthCode',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: MobilePosColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
