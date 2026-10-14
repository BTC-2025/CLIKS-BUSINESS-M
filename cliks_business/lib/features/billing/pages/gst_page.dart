import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── DATA MODELS ──────────────────────────────────────────────

class Gstr1InvoiceItem {
  final String invNo;
  final String date;
  final String customer;
  final String gstin;
  final String type;
  final String pos;
  double taxableValue;
  String cgstSgst;
  String igst;
  double totalGst;
  String status;
  String irnStatus;

  Gstr1InvoiceItem({
    required this.invNo,
    required this.date,
    required this.customer,
    required this.gstin,
    required this.type,
    required this.pos,
    required this.taxableValue,
    this.cgstSgst = '—',
    this.igst = '—',
    required this.totalGst,
    this.status = 'READY',
    this.irnStatus = 'IRN Generated',
  });
}

class VendorInvoiceItem {
  String gstin;
  String vendor;
  final String invNo;
  final String date;
  double totalVal;
  double gstAmt;
  String split;
  double eligibleItc;
  String status;

  VendorInvoiceItem({
    required this.gstin,
    required this.vendor,
    required this.invNo,
    required this.date,
    required this.totalVal,
    required this.gstAmt,
    required this.split,
    required this.eligibleItc,
    this.status = 'PENDING',
  });
}

class _GstTabConfig {
  final String label;
  final IconData icon;
  final Color activeColor;

  _GstTabConfig({
    required this.label,
    required this.icon,
    required this.activeColor,
  });
}

// ─── INDIAN CURRENCY FORMATTER ────────────────────────────────

String _formatCurrency(double amount) {
  if (amount == 0) return '₹0';
  final isNeg = amount < 0;
  final absAmt = amount.abs();
  final integerPart = absAmt.toInt().toString();

  // If there's a decimal component
  final decimalPart = (absAmt - absAmt.toInt()).toStringAsFixed(2).substring(1);
  final hasDecimals = decimalPart != '.00';

  String formattedInt;
  if (integerPart.length <= 3) {
    formattedInt = integerPart;
  } else {
    final last3 = integerPart.substring(integerPart.length - 3);
    final remaining = integerPart.substring(0, integerPart.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    formattedInt = '${buffer.toString()},$last3';
  }

  return '${isNeg ? '-' : ''}₹$formattedInt${hasDecimals ? decimalPart : ''}';
}

// ─── MAIN GST PAGE ────────────────────────────────────────────

class GstPage extends ConsumerStatefulWidget {
  const GstPage({super.key});

  @override
  ConsumerState<GstPage> createState() => _GstPageState();
}

class _GstPageState extends ConsumerState<GstPage> {
  // 0: GSTR-1 (Sales) - (Magenta #BE185D)
  // 1: GSTR-2 (Purchase) - (Royal Blue #2563EB)
  // 2: GSTR-3B (Liability) - Image 1 & 2 (Solid Purple #7C3AED)
  // 3: GSTR-9 (Annual) - Image 3 & 4 (Solid Amber #D97706)
  int _activeTab = 2; // Default to Tab 2: GSTR-3B (Liability) as in reference screenshots

  final TextEditingController _searchCtrl = TextEditingController();

  late List<Gstr1InvoiceItem> _gstr1Invoices;
  late List<VendorInvoiceItem> _vendorInvoices;

  String _selectedGstr9Fy = 'FY 2024–25';
  bool _gstr3bFiled = false;
  String _gstr3bAck = '';
  bool _gstr9Certified = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with exact records from Image 1 & 2
    _gstr1Invoices = [
      Gstr1InvoiceItem(
        invNo: 'CLK-INV-7715',
        date: '2026-10-13',
        customer: 'Sthuthya Consignee',
        gstin: '09AAAPG7885R002',
        type: 'B2B',
        pos: '09-Uttar Pradesh',
        taxableValue: 1000.0,
        cgstSgst: '—',
        igst: '—',
        totalGst: 180.0,
        status: 'READY',
        irnStatus: 'IRN Generated',
      ),
      Gstr1InvoiceItem(
        invNo: 'CLK-INV-9559',
        date: '2026-09-18',
        customer: 'Sthuthya Consignee',
        gstin: '09AAAPG7885R002',
        type: 'B2B',
        pos: '09-Uttar Pradesh',
        taxableValue: 1000.0,
        cgstSgst: '—',
        igst: '—',
        totalGst: 180.0,
        status: 'READY',
        irnStatus: 'IRN Generated',
      ),
      Gstr1InvoiceItem(
        invNo: 'CLK-INV-4412',
        date: '2026-09-01',
        customer: 'Sthuthya Consignee',
        gstin: '09AAAPG7885R002',
        type: 'B2B',
        pos: '09-Uttar Pradesh',
        taxableValue: 1000.0,
        cgstSgst: '—',
        igst: '—',
        totalGst: 180.0,
        status: 'READY',
        irnStatus: 'IRN Generated',
      ),
    ];

    // Pre-populate with exact records from Image 3
    _vendorInvoices = [
      VendorInvoiceItem(
        gstin: 'URD-UNREGISTERED',
        vendor: 'Ravi',
        invNo: 'BILL-228060',
        date: '2026-08-08',
        totalVal: 5000.0,
        gstAmt: 762.71,
        split: 'C: ₹381.36 / S: ₹381.36',
        eligibleItc: 762.71,
        status: 'PENDING',
      ),
      VendorInvoiceItem(
        gstin: 'daafdsaſsſds',
        vendor: 'ashwin',
        invNo: 'PO-1928',
        date: '2026-08-13',
        totalVal: 0.0,
        gstAmt: 0.0,
        split: 'C: ₹0 / S: ₹0',
        eligibleItc: 0.0,
        status: 'VERIFIED',
      ),
      VendorInvoiceItem(
        gstin: 'kqjernf jkefr',
        vendor: 'scjkhe vj',
        invNo: 'RET-2743',
        date: '2026-08-13',
        totalVal: 61.0,
        gstAmt: 9.36,
        split: 'C: ₹4.68 / S: ₹4.68',
        eligibleItc: 7.93,
        status: 'PENDING',
      ),
      VendorInvoiceItem(
        gstin: 'daafdsaſsſds',
        vendor: 'ashwin',
        invNo: 'RET-8943',
        date: '2026-08-13',
        totalVal: 61.0,
        gstAmt: 9.36,
        split: 'C: ₹4.68 / S: ₹4.68',
        eligibleItc: 7.93,
        status: 'PENDING',
      ),
      VendorInvoiceItem(
        gstin: 'tkqjbjkt',
        vendor: 'srqfsq',
        invNo: 'RET-3992',
        date: '2026-08-13',
        totalVal: 61.0,
        gstAmt: 9.36,
        split: 'C: ₹4.68 / S: ₹4.68',
        eligibleItc: 7.93,
        status: 'PENDING',
      ),
    ];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Gstr1InvoiceItem> get _filteredGstr1 {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _gstr1Invoices;
    return _gstr1Invoices.where((i) {
      return i.invNo.toLowerCase().contains(q) ||
          i.customer.toLowerCase().contains(q) ||
          i.gstin.toLowerCase().contains(q) ||
          i.pos.toLowerCase().contains(q) ||
          i.type.toLowerCase().contains(q);
    }).toList();
  }

  // ─── ACTION MODALS ──────────────────────────────────────────

  void _openVerifyVendorInvoiceModal({VendorInvoiceItem? initialItem}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _VerifyVendorInvoiceDialog(
        initialItem: initialItem,
        onSettle: (newItem) {
          setState(() {
            if (initialItem != null) {
              initialItem.gstin = newItem.gstin;
              initialItem.vendor = newItem.vendor;
              initialItem.totalVal = newItem.totalVal;
              initialItem.gstAmt = newItem.gstAmt;
              initialItem.split = newItem.split;
              initialItem.eligibleItc = newItem.eligibleItc;
              initialItem.status = newItem.status;
            } else {
              _vendorInvoices.insert(0, newItem);
            }
            _activeTab = 1; // Stay on GSTR-2 Purchase
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(initialItem != null
                  ? 'Vendor invoice "${newItem.invNo}" status updated to ${newItem.status}.'
                  : 'Vendor invoice "${newItem.invNo}" added for reconciliation.'),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _openQrCodeModal(Gstr1InvoiceItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => _InvoiceQrCodeDialog(item: item),
    );
  }

  void _downloadGstr3bReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.download, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'GSTR-3B monthly return report downloaded successfully.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6D28D9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _exportGstr9Pdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.fileText, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Exporting GSTR-9 Annual Return PDF for $_selectedGstr9Fy...',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _fileGstr3b() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('File GSTR-3B Return', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: const Text(
          'Confirm set-off of Outward Tax Liability (₹2,28,433.69) against Eligible ITC (₹1,68,177.97)?\n\nNet Tax Payable: ₹60,255.72',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _gstr3bFiled = true;
                _gstr3bAck = 'ACK-3B-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('GSTR-3B successfully filed! Ack No: $_gstr3bAck'),
                  backgroundColor: const Color(0xFF7C3AED),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm & File Return', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _certifyGstr9() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('GSTR-9C Annual Audit Certification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: const Text(
          'Reconciliation difference with audited balance sheet: ₹0.00.\n\nProceed to attach Digital Signature Certificate (DSC) and certify GSTR-9C Annual Return?',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _gstr9Certified = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('GSTR-9C Annual Return Certified & DSC attached.'),
                  backgroundColor: const Color(0xFFD97706),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign & Certify GSTR-9C', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ROOT ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          isMobile ? 12 : 24,
          isMobile ? 12 : 20,
          isMobile ? 12 : 24,
          isMobile ? 80 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP HEADER (Image 1, 2, 3, 4) ───
            _buildTopHeader(isMobile),
            const SizedBox(height: 18),

            // ─── 2. GOVERNMENT GSTIN REGISTERED CARD (Image 1, 2, 3, 4) ───
            _buildGstinBanner(isMobile),
            const SizedBox(height: 18),

            // ─── 3. STAT METRIC CARDS (Image 1 & 2 vs Image 3 & 4) ───
            _buildMetricStatCards(isMobile),
            const SizedBox(height: 20),

            // ─── 4. FOUR TAB NAVIGATION PILLS (Image 1, 2, 3, 4) ───
            _buildTabBar(isMobile),
            const SizedBox(height: 18),

            // ─── 5. ACTIVE TAB CONTENT ───
            if (_activeTab == 0) _buildGstr1Content(isMobile),
            if (_activeTab == 1) _buildGstr2Content(isMobile),
            if (_activeTab == 2) _buildGstr3bContent(isMobile),
            if (_activeTab == 3) _buildGstr9Content(isMobile),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP HEADER (Image 1, 2, 3, 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopHeader(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Magenta rounded container with tax/percent icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            LucideIcons.percent,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'GST & Tax Compliance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Prepare returns, authenticate tax records, and reconcile purchase ITC.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. GOVERNMENT GSTIN REGISTERED CARD (Image 1, 2, 3, 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGstinBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;

          final leftContent = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.award,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Government GSTIN Registered',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Legal Name: Welton Consignor | Type: Private Limited',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          );

          final rightContent = Column(
            crossAxisAlignment: isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: const [
              Text(
                '05AAAPG7885R002',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Place of Supply Code: 05 (Uttarakhand)',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftContent,
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                rightContent,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leftContent,
              rightContent,
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. STAT METRIC CARDS (Image 1 & 2 vs Image 3 & 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMetricStatCards(bool isMobile) {
    if (_activeTab != 0) {
      // Tabs 1, 2, 3: Exactly 4 cards (Image 1, 2, 3, 4)
      return LayoutBuilder(
        builder: (context, constraints) {
          final card1 = _buildSingleStatCard(
            label: 'TOTAL OUTPUT GST COLLECTED',
            value: '₹2,28,433.69',
            icon: LucideIcons.arrowUpRight,
            iconColor: const Color(0xFFE11D48),
            iconBgColor: const Color(0xFFFFF1F2),
          );

          final card2 = _buildSingleStatCard(
            label: 'ELIGIBLE ITC (CLAIMED GSTR-2B)',
            value: '₹1,68,177.97',
            icon: LucideIcons.arrowDownLeft,
            iconColor: const Color(0xFF059669),
            iconBgColor: const Color(0xFFECFDF5),
          );

          final card3 = _buildSingleStatCard(
            label: 'NET GST PAYABLE LIABILITY',
            value: '₹60,255.72',
            icon: LucideIcons.ban,
            iconColor: const Color(0xFFDC2626),
            iconBgColor: const Color(0xFFFEF2F2),
          );

          final card4 = _buildSingleStatCard(
            label: 'CUMULATIVE TAXABLE SALES',
            value: '₹12,85,392.17',
            icon: LucideIcons.fileText,
            iconColor: const Color(0xFF2563EB),
            iconBgColor: const Color(0xFFEFF6FF),
          );

          if (constraints.maxWidth < 650) {
            return Column(
              children: [
                card1,
                const SizedBox(height: 10),
                card2,
                const SizedBox(height: 10),
                card3,
                const SizedBox(height: 10),
                card4,
              ],
            );
          }

          if (constraints.maxWidth < 1050) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: card1),
                    const SizedBox(width: 12),
                    Expanded(child: card2),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: card3),
                    const SizedBox(width: 12),
                    Expanded(child: card4),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 12),
              Expanded(child: card2),
              const SizedBox(width: 12),
              Expanded(child: card3),
              const SizedBox(width: 12),
              Expanded(child: card4),
            ],
          );
        },
      );
    }

    // Image 1 & 2: 2 rows of 4 cards (8 cards total) for GSTR-1 (Sales)
    return LayoutBuilder(
      builder: (context, constraints) {
        final card1 = _buildSingleStatCard(
          label: 'TOTAL TAXABLE SALES',
          value: '₹12,85,392.17',
          icon: LucideIcons.fileText,
          iconColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
        );

        final card2 = _buildSingleStatCard(
          label: 'TOTAL OUTPUT GST',
          value: '₹2,28,433.69',
          icon: LucideIcons.arrowUpRight,
          iconColor: const Color(0xFFE11D48),
          iconBgColor: const Color(0xFFFFF1F2),
        );

        final card3 = _buildSingleStatCard(
          label: 'TOTAL IGST',
          value: '₹0',
          icon: LucideIcons.zap,
          iconColor: const Color(0xFF7C3AED),
          iconBgColor: const Color(0xFFF5F3FF),
        );

        final card4 = _buildSingleStatCard(
          label: 'TOTAL CGST + SGST',
          value: '₹0',
          icon: LucideIcons.circleDot,
          iconColor: const Color(0xFF059669),
          iconBgColor: const Color(0xFFECFDF5),
        );

        final card5 = _buildSingleStatCard(
          label: 'B2B INVOICES',
          value: '53',
          icon: LucideIcons.fileText,
          iconColor: const Color(0xFF4F46E5),
          iconBgColor: const Color(0xFFEEF2FF),
        );

        final card6 = _buildSingleStatCard(
          label: 'B2C INVOICES',
          value: '1',
          icon: LucideIcons.user,
          iconColor: const Color(0xFFD97706),
          iconBgColor: const Color(0xFFFFFBEB),
        );

        final card7 = _buildSingleStatCard(
          label: 'EXPORT INVOICES',
          value: '0',
          icon: LucideIcons.truck,
          iconColor: const Color(0xFF0D9488),
          iconBgColor: const Color(0xFFF0FDFA),
        );

        final card8 = _buildSingleStatCard(
          label: 'TOTAL COUNT',
          value: '138',
          icon: LucideIcons.activity,
          iconColor: const Color(0xFF64748B),
          iconBgColor: const Color(0xFFF1F5F9),
        );

        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              card1,
              const SizedBox(height: 10),
              card2,
              const SizedBox(height: 10),
              card3,
              const SizedBox(height: 10),
              card4,
              const SizedBox(height: 10),
              card5,
              const SizedBox(height: 10),
              card6,
              const SizedBox(height: 10),
              card7,
              const SizedBox(height: 10),
              card8,
            ],
          );
        }

        if (constraints.maxWidth < 1050) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 12),
                  Expanded(child: card2),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: card3),
                  const SizedBox(width: 12),
                  Expanded(child: card4),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: card5),
                  const SizedBox(width: 12),
                  Expanded(child: card6),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: card7),
                  const SizedBox(width: 12),
                  Expanded(child: card8),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 12),
                Expanded(child: card2),
                const SizedBox(width: 12),
                Expanded(child: card3),
                const SizedBox(width: 12),
                Expanded(child: card4),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: card5),
                const SizedBox(width: 12),
                Expanded(child: card6),
                const SizedBox(width: 12),
                Expanded(child: card7),
                const SizedBox(width: 12),
                Expanded(child: card8),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSingleStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. FOUR TAB NAVIGATION PILLS (Image 1, 2, 3, 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isMobile) {
    final tabs = [
      _GstTabConfig(
        label: 'GSTR-1 (Sales)',
        icon: LucideIcons.fileText,
        activeColor: const Color(0xFFE11D48), // Magenta (Image 1 & 2)
      ),
      _GstTabConfig(
        label: 'GSTR-2 (Purchase)',
        icon: LucideIcons.refreshCw,
        activeColor: const Color(0xFF2563EB), // Royal Blue (Image 3 & 4)
      ),
      _GstTabConfig(
        label: 'GSTR-3B (Liability)',
        icon: LucideIcons.percent,
        activeColor: const Color(0xFF7C3AED), // Solid Purple
      ),
      _GstTabConfig(
        label: 'GSTR-9 (Annual)',
        icon: LucideIcons.award,
        activeColor: const Color(0xFFD97706), // Solid Amber
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isActive = _activeTab == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _activeTab = index),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? tab.activeColor : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive ? tab.activeColor : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: tab.activeColor.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 14,
                        color: isActive ? Colors.white : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          color: isActive ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. TAB 0: GSTR-1 (Sales) CONTENT (Image 1 & 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGstr1Content(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar (Image 1 & 2)
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Search GST invoices or state...',
                hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 14, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Invoices Table with Sort/Filter badges (Image 1 & 2)
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 1100.0;
              final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 14, child: _buildSortableHeader('INVOICE NO')),
                            Expanded(flex: 16, child: _buildSortableHeader('CUSTOMER')),
                            Expanded(flex: 14, child: _buildSortableHeader('GSTIN')),
                            Expanded(flex: 10, child: _buildSortableHeader('TYPE')),
                            Expanded(flex: 16, child: _buildSortableHeader('PLACE OF SUPPLY')),
                            Expanded(flex: 13, child: _buildSortableHeader('TAXABLE VALUE')),
                            Expanded(flex: 11, child: _buildSortableHeader('CGST/SGST')),
                            Expanded(flex: 10, child: _buildSortableHeader('IGST')),
                            Expanded(flex: 12, child: _buildSortableHeader('TOTAL GST')),
                            Expanded(flex: 14, child: _buildSortableHeader('STATUS')),
                            Expanded(flex: 10, child: _buildSortableHeader('ACTIONS')),
                          ],
                        ),
                      ),

                      // Rows
                      if (_filteredGstr1.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(LucideIcons.fileSpreadsheet, size: 28, color: Color(0xFF94A3B8)),
                                SizedBox(height: 12),
                                Text(
                                  'No GST invoices matching search.',
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._filteredGstr1.map((inv) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                // INVOICE NO
                                Expanded(
                                  flex: 14,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(inv.invNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                      const SizedBox(height: 2),
                                      Text(inv.date, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                // CUSTOMER
                                Expanded(
                                  flex: 16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(inv.customer, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                      const SizedBox(height: 2),
                                      Text(inv.gstin, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                // GSTIN
                                Expanded(
                                  flex: 14,
                                  child: Text(inv.gstin, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                ),
                                // TYPE
                                Expanded(
                                  flex: 10,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        inv.type,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                      ),
                                    ),
                                  ),
                                ),
                                // PLACE OF SUPPLY
                                Expanded(
                                  flex: 16,
                                  child: Text(inv.pos, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155))),
                                ),
                                // TAXABLE VALUE
                                Expanded(
                                  flex: 13,
                                  child: Text(
                                    _formatCurrency(inv.taxableValue),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                ),
                                // CGST/SGST
                                Expanded(
                                  flex: 11,
                                  child: Text(inv.cgstSgst, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                                ),
                                // IGST
                                Expanded(
                                  flex: 10,
                                  child: Text(inv.igst, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                                ),
                                // TOTAL GST
                                Expanded(
                                  flex: 12,
                                  child: Text(
                                    _formatCurrency(inv.totalGst),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                ),
                                // STATUS
                                Expanded(
                                  flex: 14,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(inv.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                                      const SizedBox(height: 2),
                                      Text(inv.irnStatus, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF166534))),
                                    ],
                                  ),
                                ),
                                // ACTIONS (QR code + Delete from Image 2!)
                                Expanded(
                                  flex: 10,
                                  child: Row(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _openQrCodeModal(inv),
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(LucideIcons.qrCode, size: 14, color: Color(0xFF2563EB)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() => _gstr1Invoices.remove(inv));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Invoice "${inv.invNo}" removed.'),
                                                backgroundColor: const Color(0xFFDC2626),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE2E2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFDC2626)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 6. TAB 1: GSTR-2 (Purchase) CONTENT (Image 3 & 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGstr2Content(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and + Verify Vendor Invoice button (Image 3 & 4)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GSTR-2B Purchase ITC Reconciliations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openVerifyVendorInvoiceModal(),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text(
                  'Verify Vendor Invoice',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Reconciliations Table (Image 3 & 4)
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 980.0;
              final width = math.max(constraints.maxWidth, minWidth);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 16, child: _TableHeaderText('Vendor GSTIN')),
                            Expanded(flex: 14, child: _TableHeaderText('Vendor Name')),
                            Expanded(flex: 14, child: _TableHeaderText('Invoice No')),
                            Expanded(flex: 12, child: _TableHeaderText('Date')),
                            Expanded(flex: 12, child: _TableHeaderText('Total Value')),
                            Expanded(flex: 12, child: _TableHeaderText('GST Amt')),
                            Expanded(flex: 18, child: _TableHeaderText('CGST/SGST/IGST')),
                            Expanded(flex: 12, child: _TableHeaderText('Eligible ITC')),
                            Expanded(flex: 12, child: _TableHeaderText('Status')),
                            Expanded(flex: 14, child: _TableHeaderText('Actions')),
                          ],
                        ),
                      ),

                      // Rows
                      if (_vendorInvoices.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(LucideIcons.fileSearch, size: 28, color: Color(0xFF94A3B8)),
                                SizedBox(height: 12),
                                Text(
                                  'No purchase ITC records found.',
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._vendorInvoices.map((v) {
                          final isVerified = v.status.toUpperCase() == 'VERIFIED' || v.status.toUpperCase() == 'MATCHED';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            child: Row(
                              children: [
                                // Vendor GSTIN
                                Expanded(
                                  flex: 16,
                                  child: Text(
                                    v.gstin,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                ),
                                // Vendor Name (Green bold as in Image 3)
                                Expanded(
                                  flex: 14,
                                  child: Text(
                                    v.vendor,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                  ),
                                ),
                                // Invoice No (Green bold as in Image 3)
                                Expanded(
                                  flex: 14,
                                  child: Text(
                                    v.invNo,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                  ),
                                ),
                                // Date
                                Expanded(
                                  flex: 12,
                                  child: Text(
                                    v.date,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ),
                                // Total Value
                                Expanded(
                                  flex: 12,
                                  child: Text(
                                    _formatCurrency(v.totalVal),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                ),
                                // GST Amt
                                Expanded(
                                  flex: 12,
                                  child: Text(
                                    _formatCurrency(v.gstAmt),
                                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                                  ),
                                ),
                                // CGST/SGST/IGST
                                Expanded(
                                  flex: 18,
                                  child: Text(
                                    v.split,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ),
                                // Eligible ITC (Bold Blue as in Image 3)
                                Expanded(
                                  flex: 12,
                                  child: Text(
                                    _formatCurrency(v.eligibleItc),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                ),
                                // Status badge
                                Expanded(
                                  flex: 12,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        v.status,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isVerified ? const Color(0xFF166534) : const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Actions (Verify button + Delete trash button)
                                Expanded(
                                  flex: 14,
                                  child: Row(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _openVerifyVendorInvoiceModal(initialItem: v),
                                          borderRadius: BorderRadius.circular(4),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Verify',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() => _vendorInvoices.remove(v));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Vendor record "${v.invNo}" removed.'),
                                                backgroundColor: const Color(0xFFDC2626),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(4),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE2E2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFDC2626)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 7. TAB 2: GSTR-3B (Liability) CONTENT (Image 1 & 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGstr3bContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top badges + Download Report button
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              final badges = Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'GSTR-3B COMPLIANCE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C3AED),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        LucideIcons.checkCircle2,
                        size: 15,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Status: Verified',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ],
              );

              final downloadBtn = ElevatedButton.icon(
                onPressed: _downloadGstr3bReport,
                icon: const Icon(LucideIcons.download, size: 15),
                label: const Text(
                  'Download Report',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    badges,
                    const SizedBox(height: 12),
                    downloadBtn,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  badges,
                  downloadBtn,
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Title & Subtitle
          const Text(
            'Self-Declared Summary Return (Monthly)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aggregate outward liabilities set off against eligible input tax credits.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Two boxes: Outward supplies & Eligible ITC
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 780;

              final leftBox = Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF3E8FF)),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OUTWARD TAXABLE SUPPLIES (SALES)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7E22CE),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTaxSummaryRow(
                      label: 'Taxable Value:',
                      value: '₹10,22,01,44,47,392.67',
                      labelColor: const Color(0xFF6B21A8),
                      valueColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 12),
                    _buildTaxSummaryRow(
                      label: 'Integrated Tax (IGST):',
                      value: '₹540',
                      labelColor: const Color(0xFF6B21A8),
                      valueColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 12),
                    _buildTaxSummaryRow(
                      label: 'Central Tax (CGST):',
                      value: '₹1,98,13,51,622.9',
                      labelColor: const Color(0xFF6B21A8),
                      valueColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 12),
                    _buildTaxSummaryRow(
                      label: 'State Tax (SGST):',
                      value: '₹1,98,13,51,622.9',
                      labelColor: const Color(0xFF6B21A8),
                      valueColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE9D5FF)),
                    const SizedBox(height: 14),
                    _buildTaxSummaryRow(
                      label: 'Total Liability:',
                      value: '₹3,96,27,03,785.78',
                      labelColor: const Color(0xFF6B21A8),
                      valueColor: const Color(0xFF7C3AED),
                      isBold: true,
                      valueFontSize: 15,
                    ),
                  ],
                ),
              );

              final rightBox = Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ELIGIBLE INPUT TAX CREDIT (ITC)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTaxSummaryRow(
                      label: 'Eligible IGST Available:',
                      value: '₹540',
                      labelColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 12),
                    _buildTaxSummaryRow(
                      label: 'Eligible Central Tax (CGST):',
                      value: '₹1,98,13,51,622.9',
                      labelColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 12),
                    _buildTaxSummaryRow(
                      label: 'Eligible State Tax (SGST):',
                      value: '₹1,98,13,51,622.9',
                      labelColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 12),
                    _buildTaxSummaryRow(
                      label: 'Ineligible/Blocked Credit:',
                      value: '₹0',
                      labelColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFBBF7D0)),
                    const SizedBox(height: 14),
                    _buildTaxSummaryRow(
                      label: 'Total Claimable ITC:',
                      value: '₹0',
                      labelColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF15803D),
                      isBold: true,
                      valueFontSize: 15,
                    ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    leftBox,
                    const SizedBox(height: 16),
                    rightBox,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: leftBox),
                  const SizedBox(width: 16),
                  Expanded(child: rightBox),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Bottom Card: FINAL NET TAX LIABILITY PAYABLE (CASH OUTFLOW) (Image 2)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FINAL NET TAX LIABILITY PAYABLE (CASH OUTFLOW)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFBE123C),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, c) {
                    final isNarrow = c.maxWidth < 620;

                    Widget card(String label, String value) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final c1 = card('Net IGST Payable', '₹0');
                    final c2 = card('Net CGST Payable', '₹0');
                    final c3 = card('Net SGST Payable', '₹0');

                    if (isNarrow) {
                      return Column(
                        children: [
                          c1,
                          const SizedBox(height: 10),
                          c2,
                          const SizedBox(height: 10),
                          c3,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: c1),
                        const SizedBox(width: 12),
                        Expanded(child: c2),
                        const SizedBox(width: 12),
                        Expanded(child: c3),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxSummaryRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
    bool isBold = false,
    double valueFontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: labelColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 8. TAB 3: GSTR-9 (Annual) CONTENT (Image 3 & 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGstr9Content(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Title + Dropdown & Export PDF button
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 650;

              final titleSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'GSTR-9 Annual Return',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Financial Year Summary & Reconciliation',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              );

              final actionsSection = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // FY Dropdown menu button (Image 3 & 4)
                  PopupMenuButton<String>(
                    initialValue: _selectedGstr9Fy,
                    tooltip: 'Select Financial Year',
                    onSelected: (val) {
                      setState(() {
                        _selectedGstr9Fy = val;
                      });
                    },
                    offset: const Offset(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    itemBuilder: (context) => [
                      _buildFyMenuItem('FY 2023–24'),
                      _buildFyMenuItem('FY 2024–25'),
                      _buildFyMenuItem('FY 2025–26'),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedGstr9Fy,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Export Annual PDF button
                  ElevatedButton.icon(
                    onPressed: _exportGstr9Pdf,
                    icon: const Icon(LucideIcons.download, size: 14),
                    label: const Text(
                      'Export Annual PDF',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 14),
                    actionsSection,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  titleSection,
                  actionsSection,
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Large empty state container with ribbon icon (Image 3 & 4)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ribbon / Award badge icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.award,
                      size: 30,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'No annual GST data found for ${_selectedGstr9Fy.replaceAll('FY ', '')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: const Text(
                    'Create sales invoices and purchase bills for the selected financial year to automatically generate your GSTR-9 Annual Return and statutory summaries.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      height: 1.45,
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

  PopupMenuItem<String> _buildFyMenuItem(String fy) {
    final isSelected = _selectedGstr9Fy == fy;
    return PopupMenuItem<String>(
      value: fy,
      height: 38,
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: isSelected
                ? const Icon(LucideIcons.check, size: 14, color: Color(0xFF0F172A))
                : null,
          ),
          const SizedBox(width: 4),
          Text(
            fy,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.filter, size: 8, color: Color(0xFF94A3B8)),
              SizedBox(width: 2),
              Icon(LucideIcons.arrowUpDown, size: 8, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── TABLE HEADER TEXT HELPER ─────────────────────────────────

class _TableHeaderText extends StatelessWidget {
  final String text;
  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.2,
      ),
    );
  }
}

// ─── VERIFY VENDOR INVOICE MODAL (Image 4) ────────────────────

class _VerifyVendorInvoiceDialog extends StatefulWidget {
  final VendorInvoiceItem? initialItem;
  final void Function(VendorInvoiceItem item) onSettle;

  const _VerifyVendorInvoiceDialog({
    this.initialItem,
    required this.onSettle,
  });

  @override
  State<_VerifyVendorInvoiceDialog> createState() => _VerifyVendorInvoiceDialogState();
}

class _VerifyVendorInvoiceDialogState extends State<_VerifyVendorInvoiceDialog> {
  late final TextEditingController _gstinCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;

  String _gstRate = '18% GST';
  String _matchStatus = 'PENDING';

  @override
  void initState() {
    super.initState();
    _gstinCtrl = TextEditingController(text: widget.initialItem?.gstin ?? '27AAAA1111A1Z1');
    _nameCtrl = TextEditingController(text: widget.initialItem?.vendor ?? 'Acme Hardwares');
    _amountCtrl = TextEditingController(
      text: widget.initialItem != null ? widget.initialItem!.totalVal.toInt().toString() : '',
    );
    if (widget.initialItem != null) {
      _matchStatus = widget.initialItem!.status;
    }
  }

  @override
  void dispose() {
    _gstinCtrl.dispose();
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final gstin = _gstinCtrl.text.trim().isNotEmpty ? _gstinCtrl.text.trim() : '27AAAA1111A1Z1';
    final name = _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Acme Hardwares';
    final total = double.tryParse(_amountCtrl.text.trim()) ?? 5000.0;

    double gstPct = 0.18;
    if (_gstRate.contains('5%')) gstPct = 0.05;
    if (_gstRate.contains('12%')) gstPct = 0.12;
    if (_gstRate.contains('28%')) gstPct = 0.28;
    if (_gstRate.contains('0%')) gstPct = 0.00;

    final gstAmt = total * gstPct;
    final halfGst = (gstAmt / 2).toStringAsFixed(2);
    final splitStr = 'C: ₹$halfGst / S: ₹$halfGst';

    final invNo = widget.initialItem?.invNo ?? 'BILL-${100000 + math.Random().nextInt(899999)}';
    final now = DateTime.now();
    final dateStr = widget.initialItem?.date ?? '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final item = VendorInvoiceItem(
      gstin: gstin,
      vendor: name,
      invNo: invNo,
      date: dateStr,
      totalVal: total,
      gstAmt: gstAmt,
      split: splitStr,
      eligibleItc: gstAmt,
      status: _matchStatus,
    );

    widget.onSettle(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 480,
          constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Image 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Verify Vendor Invoice',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'GSTR-2B ITC RECONCILIATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Row 1: VENDOR GSTIN & VENDOR NAME (Image 4)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('VENDOR GSTIN', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.2)),
                          const SizedBox(height: 6),
                          _buildField(_gstinCtrl, '27AAAA1111A1Z1'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('VENDOR NAME', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.2)),
                          const SizedBox(height: 6),
                          _buildField(_nameCtrl, 'Acme Hardwares'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row 2: INVOICE TOTAL AMOUNT (INR) *
                const Text('INVOICE TOTAL AMOUNT (INR) *', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.2)),
                const SizedBox(height: 6),
                _buildField(_amountCtrl, 'e.g. 5000', isNumeric: true),
                const SizedBox(height: 16),

                // Row 3: GST RATE % & MATCH GSTR-2B (Image 4)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GST RATE %', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.2)),
                          const SizedBox(height: 6),
                          _buildDropdownContainer(
                            value: _gstRate,
                            items: ['18% GST', '5% GST', '12% GST', '28% GST', '0% Excluded'],
                            onChanged: (v) => setState(() => _gstRate = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MATCH GSTR-2B', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF475569), letterSpacing: 0.2)),
                          const SizedBox(height: 6),
                          _buildDropdownContainer(
                            value: _matchStatus,
                            items: ['PENDING', 'VERIFIED', 'MATCHED', 'DISPUTED'],
                            onChanged: (v) => setState(() => _matchStatus = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bottom button: Settle Reconciliation Status (Slate-blue in Image 4)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B9CB2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Settle Reconciliation Status',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, {bool isNumeric = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

// ─── INVOICE QR CODE MODAL ────────────────────────────────────

class _InvoiceQrCodeDialog extends StatelessWidget {
  final Gstr1InvoiceItem item;

  const _InvoiceQrCodeDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: 420,
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'e-Invoice QR Code',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.qrCode, size: 90, color: Color(0xFF0F172A)),
                      SizedBox(height: 6),
                      Text('NIC GST Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.invNo,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                'IRN: 89f1a2938471bc890192837492817492019...',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Value', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                    Text(_formatCurrency(item.taxableValue + item.totalGst), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
