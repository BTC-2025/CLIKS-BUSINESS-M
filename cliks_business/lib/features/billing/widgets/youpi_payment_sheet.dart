import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/youpi_payment_models.dart';
import '../services/youpi_payment_service.dart';

enum _PaymentUiState {
  initializing,
  checkoutOpened,
  pendingVerification,
  verifiedSuccess,
  failed,
  cancelled,
  expired,
}

/// Authentic YOUPI PG Checkout Sheet matching the gateway's signature
/// blue theme (`#0B63E5`), direct UPI QR code generation, and live observer.
class YoupiPaymentSheet extends StatefulWidget {
  final int tierNumber;
  final String planName;
  final String fullAnnualPrice;
  final double payableAmount;
  final String customerEmail;
  final String? customerName;
  final String? customerPhone;
  final ValueChanged<int>? onPaymentVerified;

  const YoupiPaymentSheet({
    super.key,
    required this.tierNumber,
    required this.planName,
    required this.fullAnnualPrice,
    required this.payableAmount,
    required this.customerEmail,
    this.customerName,
    this.customerPhone,
    this.onPaymentVerified,
  });

  static Future<void> show({
    required BuildContext context,
    required int tierNumber,
    required String planName,
    required String fullAnnualPrice,
    required double payableAmount,
    required String customerEmail,
    String? customerName,
    String? customerPhone,
    ValueChanged<int>? onPaymentVerified,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: YoupiPaymentSheet(
            tierNumber: tierNumber,
            planName: planName,
            fullAnnualPrice: fullAnnualPrice,
            payableAmount: payableAmount,
            customerEmail: customerEmail,
            customerName: customerName,
            customerPhone: customerPhone,
            onPaymentVerified: onPaymentVerified,
          ),
        ),
      ),
    );
  }

  @override
  State<YoupiPaymentSheet> createState() => _YoupiPaymentSheetState();
}

class _YoupiPaymentSheetState extends State<YoupiPaymentSheet>
    with SingleTickerProviderStateMixin {
  // Authentic YOUPI PG Palette from checkout.html
  static const Color _ypgBlue = Color(0xFF0B63E5);
  static const Color _ypgBlueDark = Color(0xFF0957CB);
  static const Color _ypgNavy = Color(0xFF0B1526);
  static const Color _ypgBg = Color(0xFFF8FAFC);
  static const Color _ypgCard = Color(0xFFFFFFFF);
  static const Color _ypgTextDark = Color(0xFF0F172A);
  static const Color _ypgTextMuted = Color(0xFF64748B);
  static const Color _ypgBorder = Color(0xFFE2E8F0);
  static const Color _ypgBorderLight = Color(0xFFEEF2F6);
  static const Color _ypgGreen = Color(0xFF0D9F67);
  static const Color _ypgGreenBg = Color(0xFFE6F9F0);
  static const Color _ypgOfferBg = Color(0xFFEFF6FF);

  _PaymentUiState _uiState = _PaymentUiState.initializing;
  String? _orderId;
  YoupiPaymentSession? _session;
  YoupiPaymentVerification? _verification;
  String? _errorMessage;

  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _secondsRemaining = 300; // 5 minutes countdown
  int _pollCount = 0;
  static const int _maxPollCount = 100;

  bool _isCopied = false;
  bool _showUtrInput = false;
  final TextEditingController _utrController = TextEditingController();

  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startPaymentFlow();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _radarController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _uiState = _PaymentUiState.expired);
      }
    });
  }

  Future<void> _startPaymentFlow() async {
    setState(() {
      _uiState = _PaymentUiState.initializing;
      _errorMessage = null;
    });

    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      _orderId = 'CLIKS-SUB-T${widget.tierNumber}-$nowMs';

      final session = await YoupiPaymentService.instance.createPaymentSession(
        orderId: _orderId!,
        amount: widget.payableAmount,
        planName: widget.planName,
        tierNumber: widget.tierNumber,
        customerEmail: widget.customerEmail,
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
        returnUrl: 'cliks://payment-return?orderId=$_orderId',
      );

      if (!mounted) return;

      setState(() {
        _session = session;
        _uiState = _PaymentUiState.checkoutOpened;
      });

      _startCountdown();

      // Launch hosted checkout if remote url_launcher configured
      await YoupiPaymentService.instance.launchCheckout(session.checkoutUrl);

      // Begin polling verification
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uiState = _PaymentUiState.failed;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollCount = 0;
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      if (_pollCount > _maxPollCount) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _uiState = _PaymentUiState.expired;
          });
        }
        return;
      }

      await _checkStatus();
    });
  }

  Future<void> _checkStatus({bool isManual = false}) async {
    if (_session == null || _orderId == null) return;

    try {
      final verification = await YoupiPaymentService.instance.getPaymentStatus(
        _session!.paymentId,
      );

      if (!mounted) return;

      setState(() {
        _verification = verification;
      });

      if (verification.isAuthoritativelyVerified) {
        _pollingTimer?.cancel();
        _countdownTimer?.cancel();

        final activated = await YoupiPaymentService.instance
            .verifyAndActivateSubscription(
              paymentId: _session!.paymentId,
              expectedOrderId: _orderId!,
              expectedAmount: widget.payableAmount,
              tierNumber: widget.tierNumber,
              planName: widget.planName,
              customerEmail: widget.customerEmail,
            );

        if (!mounted) return;

        if (activated) {
          setState(() {
            _uiState = _PaymentUiState.verifiedSuccess;
          });
          widget.onPaymentVerified?.call(widget.tierNumber);
        }
      } else if (isManual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Awaiting bank confirmation. If you just paid via GPay, the observer will detect it in a few moments, or submit your 12-digit UTR below.',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            backgroundColor: const Color(0xFF0B63E5),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      // Keep listening gracefully on next poll
    }
  }

  Future<void> _submitUtrManualVerification() async {
    final utr = _utrController.text.trim();
    if (_session == null || _orderId == null) return;

    if (utr.isEmpty || utr.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 12-digit UPI reference number (UTR).'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _uiState = _PaymentUiState.pendingVerification;
    });

    final success = await YoupiPaymentService.instance.submitUtrForVerification(
      paymentId: _session!.paymentId,
      orderId: _orderId!,
      expectedAmount: widget.payableAmount,
      tierNumber: widget.tierNumber,
      planName: widget.planName,
      customerEmail: widget.customerEmail,
      utr: utr,
    );

    if (!mounted) return;

    if (success) {
      _pollingTimer?.cancel();
      _countdownTimer?.cancel();
      setState(() {
        _uiState = _PaymentUiState.verifiedSuccess;
      });
      widget.onPaymentVerified?.call(widget.tierNumber);
    } else {
      // Revert to checkoutOpened and show awaiting observation feedback
      setState(() {
        _uiState = _PaymentUiState.checkoutOpened;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'UTR $utr submitted. Waiting for banking observer to detect credit to ${YoupiPaymentService.configuredPayeeVpa}...',
          ),
          backgroundColor: const Color(0xFF0B63E5),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _simulateBankCreditAlert() {
    if (_session == null || _orderId == null) return;
    final testUtr = '4289${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    YoupiPaymentService.instance.simulateObserverCredit(
      paymentId: _session!.paymentId,
      orderId: _orderId!,
      amount: widget.payableAmount,
      utr: testUtr,
    );
    _checkStatus();
  }

  void _copyVpa(String vpa) {
    Clipboard.setData(ClipboardData(text: vpa));
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _ypgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAuthenticYoupiHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildBodyContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. AUTHENTIC YOUPI PG BLUE HEADER (checkout.html signature)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAuthenticYoupiHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_ypgBlue, _ypgBlueDark],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Teal Merchant Avatar with 'C' for Cliks Business
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.85),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliks Business',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.shieldCheck,
                            size: 13,
                            color: Color(0xFF4ADE80),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'YOUPI PG Verified Business',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Close button
                InkWell(
                  onTap: () {
                    _pollingTimer?.cancel();
                    _countdownTimer?.cancel();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sub-banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.black.withOpacity(0.15),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.lock,
                  size: 12,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Fast & Secure 256-Bit Encrypted · Direct-To-Bank Settlement',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. BODY CONTENT ROUTER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBodyContent() {
    switch (_uiState) {
      case _PaymentUiState.initializing:
        return _buildInitializingView();
      case _PaymentUiState.checkoutOpened:
      case _PaymentUiState.pendingVerification:
        return _buildActiveCheckoutView();
      case _PaymentUiState.verifiedSuccess:
        return _buildSuccessView();
      case _PaymentUiState.failed:
        return _buildFailedView();
      case _PaymentUiState.expired:
        return _buildExpiredView();
      case _PaymentUiState.cancelled:
        return _buildCancelledView();
    }
  }

  Widget _buildInitializingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30),
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(_ypgBlue),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connecting to YOUPI PG...',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _ypgTextDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Initializing secure UPI payment session for ${widget.planName}',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _ypgTextMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildActiveCheckoutView() {
    final vpa = _session?.payeeVpa ?? YoupiPaymentService.configuredPayeeVpa;
    final upiUrl = _session?.upiUri ??
        YoupiPaymentService.instance.buildUpiPaymentUri(
          amount: widget.payableAmount,
          orderId: _orderId ?? 'CLIKS-ORD',
          planName: widget.planName,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Order Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _ypgOfferBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPGRADING TO',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _ypgBlueDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.planName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _ypgNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _orderId ?? 'Order Pending',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _ypgTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PAYABLE AMOUNT',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _ypgBlueDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${widget.payableAmount.toStringAsFixed(widget.payableAmount.truncateToDouble() == widget.payableAmount ? 0 : 2)}',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _ypgBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section Heading & Countdown Timer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UPI Payment (Direct Bank)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.clock, size: 12, color: Color(0xFF475569)),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Authentic Core UPI QR Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: _ypgBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _ypgBorderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Scan QR to Pay with any UPI App',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _ypgTextDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // UPI brand pills
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 4,
                children: ['GPay', 'PhonePe', 'Paytm', 'BHIM', 'CRED']
                    .map(
                      (app) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          app,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              // White QR Box
              Container(
                width: 170,
                height: 170,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _ypgBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: QrImageView(
                    data: upiUrl,
                    version: QrVersions.auto,
                    size: 154,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0F172A),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _ypgGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.zap, size: 12, color: _ypgGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Instant 0% Fee Settlement',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _ypgGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Live Observer Radar Strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF16A34A),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16A34A)
                              .withOpacity(0.4 + 0.4 * _radarController.value),
                          blurRadius: 6 * _radarController.value,
                          spreadRadius: 2 * _radarController.value,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Live Observer Active · Listening for UPI payment in real-time...',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Primary "Pay via UPI App" Button
        ElevatedButton.icon(
          onPressed: () {
            YoupiPaymentService.instance.launchUpiIntent(upiUrl);
          },
          icon: const Icon(LucideIcons.arrowUpRight, size: 16, color: Colors.white),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Pay via UPI App (GPay / PhonePe / Paytm)',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _ypgBlue,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),

        const SizedBox(height: 10),

        // Manual Verify / UTR Toggle
        if (!_showUtrInput)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _checkStatus(isManual: true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    side: const BorderSide(color: _ypgBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Check Status',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _ypgTextDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showUtrInput = true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    side: const BorderSide(color: _ypgBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'I Have Paid (Enter UTR)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _ypgBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _ypgBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter 12-Digit UPI Reference / UTR Number:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _ypgTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _utrController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'e.g. 428912345678',
                          hintStyle: GoogleFonts.inter(fontSize: 12, color: _ypgTextMuted),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: _ypgBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: _ypgBlue, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitUtrManualVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _ypgGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Submit UTR',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        if (widget.payableAmount == 1.0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.flaskConical, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 6),
                    Text(
                      'Developer Test Mode (₹1 Plan)',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'In real production, the Android Observer APK or Gmail Observer detects the credit SMS. For local testing without an active Android observer daemon, click below to simulate an incoming bank credit alert:',
                  style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF78350F)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _simulateBankCreditAlert,
                  icon: const Icon(LucideIcons.zap, size: 13, color: Color(0xFFB45309)),
                  label: Text(
                    'Simulate Bank SMS Credit Receipt (Test Only)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. SUCCESS VIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _ypgGreenBg,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
          ),
          child: const Center(
            child: Icon(
              LucideIcons.checkCheck,
              color: _ypgGreen,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Payment Authoritatively Verified!',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ypgTextDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Your ${widget.planName} subscription has been activated successfully.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _ypgTextMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _ypgBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _ypgBorderLight),
          ),
          child: Column(
            children: [
              _buildDetailRow('Plan', widget.planName),
              const Divider(height: 14),
              _buildDetailRow(
                'Amount',
                '₹${widget.payableAmount.toStringAsFixed(2)} (Direct-To-Bank)',
              ),
              const Divider(height: 14),
              _buildDetailRow(
                'Beneficiary VPA',
                YoupiPaymentService.configuredPayeeVpa,
              ),
              const Divider(height: 14),
              _buildDetailRow('Verification', 'Level 2 · Banking Dual Observer'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _ypgBlue,
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Continue to Workspace',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              LucideIcons.alertTriangle,
              color: Color(0xFFDC2626),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Payment Verification Failed',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _ypgTextDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ??
              'Payment could not be verified by the banking observer.',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: _ypgTextMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _startPaymentFlow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ypgBlue,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpiredView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        const Icon(LucideIcons.clockAlert, size: 48, color: Color(0xFFF59E0B)),
        const SizedBox(height: 14),
        Text(
          'Checkout Session Expired',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _ypgTextDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'The 5-minute active window for this UPI payment has expired.',
          style: GoogleFonts.inter(fontSize: 13, color: _ypgTextMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _startPaymentFlow,
          style: ElevatedButton.styleFrom(
            backgroundColor: _ypgBlue,
            minimumSize: const Size.fromHeight(42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Start New Session',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        const Icon(LucideIcons.xCircle, size: 48, color: Color(0xFF64748B)),
        const SizedBox(height: 14),
        Text(
          'Checkout Cancelled',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _ypgTextDark,
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Plans'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _ypgTextMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _ypgTextDark,
          ),
        ),
      ],
    );
  }
}
