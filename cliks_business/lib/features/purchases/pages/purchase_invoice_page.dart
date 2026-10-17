import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────

class _PurchaseBillItem {
  final String poNumber;
  final String date;
  final String dueDate;
  final String supplier;
  final String gstin;
  final String itemName;
  final int qty;
  final double rate;
  final double totalPayable;
  final double cgst;
  final double sgst;
  final String status;
  final bool isCompleted;

  _PurchaseBillItem({
    required this.poNumber,
    required this.date,
    required this.dueDate,
    required this.supplier,
    required this.gstin,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.totalPayable,
    required this.cgst,
    required this.sgst,
    required this.status,
    this.isCompleted = false,
  });
}

class _PurchaseReturnItem {
  final String refId;
  final String supplier;
  final String itemName;
  final int returnedQty;
  final double refundAmount;
  final String status;

  _PurchaseReturnItem({
    required this.refId,
    required this.supplier,
    required this.itemName,
    required this.returnedQty,
    required this.refundAmount,
    required this.status,
  });
}

String _formatIndianCurrencyAmount(double amount) {
  if (amount == 0) return '₹0';
  final isNegative = amount < 0;
  final absAmount = amount.abs().round();
  final str = absAmount.toString();
  if (str.length <= 3) {
    return '${isNegative ? "-₹" : "₹"}$str';
  }
  final lastThree = str.substring(str.length - 3);
  final rest = str.substring(0, str.length - 3);
  final formattedRest = rest.replaceAllMapped(
    RegExp(r'\B(?=(\d{2})+(?!\d))'),
    (match) => ',',
  );
  return '${isNegative ? "-₹" : "₹"}$formattedRest,$lastThree';
}

class _ProductRowData {
  String productName;
  String sku;
  final TextEditingController costController;
  final TextEditingController qtyController;
  final TextEditingController discountController;
  String gst;

  _ProductRowData({
    this.productName = '-- Select Product --',
    this.sku = 'IPH-15',
    String cost = '0',
    String qty = '1',
    String discount = '0',
    this.gst = '18%',
  })  : costController = TextEditingController(text: cost),
        qtyController = TextEditingController(text: qty),
        discountController = TextEditingController(text: discount);

  String get cost => costController.text;
  set cost(String val) => costController.text = val;

  String get qty => qtyController.text;
  set qty(String val) => qtyController.text = val;

  String get discount => discountController.text;
  set discount(String val) => discountController.text = val;

  double get numericCost => double.tryParse(costController.text) ?? 0.0;
  int get numericQty => int.tryParse(qtyController.text) ?? 1;
  double get numericDiscount => double.tryParse(discountController.text) ?? 0.0;
  double get gstRate {
    final clean = gst.replaceAll('%', '').trim();
    return (double.tryParse(clean) ?? 18.0) / 100.0;
  }

  double get subtotal => numericQty * numericCost;
  double get discountAmount => subtotal * (numericDiscount / 100.0);
  double get taxableAmount => subtotal - discountAmount;
  double get gstAmount => taxableAmount * gstRate;
  double get total => taxableAmount + gstAmount;

  void dispose() {
    costController.dispose();
    qtyController.dispose();
    discountController.dispose();
  }
}

// ─── Main Page ───────────────────────────────────────────────────────────────

class PurchaseInvoicePage extends ConsumerStatefulWidget {
  const PurchaseInvoicePage({super.key});

  @override
  ConsumerState<PurchaseInvoicePage> createState() => _PurchaseInvoicePageState();
}

class _PurchaseInvoicePageState extends ConsumerState<PurchaseInvoicePage> {
  int _activeTab = 0; // 0: PO, 1: Bills & Invoices, 2: Returns (Suppliers)

  // Search & Filter state
  final TextEditingController _poSearchController = TextEditingController();
  final TextEditingController _billSearchController = TextEditingController();
  final TextEditingController _returnSearchController = TextEditingController();

  DateTime? _poFilterDate;
  String _poFilterStatus = 'All Status';

  // Seed Data matching the user's screenshots exactly
  late final List<_PurchaseBillItem> _purchaseBills;
  late final List<_PurchaseReturnItem> _purchaseReturns;
  late final List<_PurchaseBillItem> _purchaseOrders;

  @override
  void initState() {
    super.initState();

    _purchaseBills = [
      _PurchaseBillItem(
        poNumber: 'PO-9348',
        date: '2026-08-29',
        dueDate: '2026-09-28',
        supplier: 'jeni fancy 5050',
        gstin: 'JDHGSRETHY15265',
        itemName: 'VIVO',
        qty: 20,
        rate: 50000,
        totalPayable: 1180000,
        cgst: 90000,
        sgst: 90000,
        status: 'CONFIRMED BY SUPPLIER',
        isCompleted: false,
      ),
      _PurchaseBillItem(
        poNumber: 'PO-0861',
        date: '2026-08-29',
        dueDate: '2026-09-28',
        supplier: 'jeni fancy 5050',
        gstin: 'JDHGSRETHY15265',
        itemName: 'VIVO',
        qty: 1,
        rate: 50000,
        totalPayable: 59000,
        cgst: 4500,
        sgst: 4500,
        status: 'Completed',
        isCompleted: true,
      ),
      _PurchaseBillItem(
        poNumber: 'PO-6193',
        date: '2026-08-21',
        dueDate: '2026-09-20',
        supplier: 'santo',
        gstin: 'Unregistered',
        itemName: 'carrot',
        qty: 1000,
        rate: 45,
        totalPayable: 53100,
        cgst: 4050,
        sgst: 4050,
        status: 'Completed',
        isCompleted: true,
      ),
    ];

    _purchaseReturns = [
      _PurchaseReturnItem(
        refId: 'RET-8943',
        supplier: 'ashwin',
        itemName: 'erferfa',
        returnedQty: 1,
        refundAmount: 0,
        status: 'COMPLETED',
      ),
      _PurchaseReturnItem(
        refId: 'RET-2743',
        supplier: 'scjkhe vj',
        itemName: 'erferfa',
        returnedQty: 1,
        refundAmount: 0,
        status: 'COMPLETED',
      ),
      _PurchaseReturnItem(
        refId: 'RET-3992',
        supplier: 'srgfsg',
        itemName: 'erferfa',
        returnedQty: 1,
        refundAmount: 0,
        status: 'COMPLETED',
      ),
    ];

    // Purchase orders initially empty or seeded
    _purchaseOrders = [];
  }

  @override
  void dispose() {
    _poSearchController.dispose();
    _billSearchController.dispose();
    _returnSearchController.dispose();
    super.dispose();
  }

  // ─── Helpers to format numbers ─────────────────────────────────────────────

  String _formatIndianCurrency(double amount) {
    if (amount == 0) return '₹0';
    final isNegative = amount < 0;
    final absAmount = amount.abs().round();
    final str = absAmount.toString();
    if (str.length <= 3) {
      return '${isNegative ? "-₹" : "₹"}$str';
    }
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
      (match) => ',',
    );
    return '${isNegative ? "-₹" : "₹"}$formattedRest,$lastThree';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    if (isMacOS) {
      return _buildDesktopView(screenWidth, isMobile);
    }

    // ─── MOBILE OS REDESIGNED VIEW (Matching Reports / Barcode / Marketing) ───
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 76),
              child: _ExpandableFab(
                onNewPO: _showNewPODialog,
                onNewBill: _showNewPurchaseBillDialog,
                onReturn: _showPurchaseReturnDialog,
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting/Reports Style Header) ───
          SliverToBoxAdapter(
            child: _buildHeroSummary(isMobile)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.05, end: 0),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 6),
          ),

          // ─── STICKY TAB NAVIGATION BAR ───
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabNavDelegate(
              height: 46,
              child: Container(
                color: const Color(0xFFF8F9FB),
                child: _buildMobileTabNav(),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // ─── MAIN CONTENT CONTAINER (Tables & Lists) ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              14,
              0,
              14,
              isMobile ? 140 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildActiveTabContent(screenWidth),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP VIEW (Preserved strictly for macOS)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopView(double screenWidth, bool isMobile) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: _ExpandableFab(
                onNewPO: _showNewPODialog,
                onNewBill: _showNewPurchaseBillDialog,
                onReturn: _showPurchaseReturnDialog,
              ),
            )
          : null,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 14 : 24,
            isMobile ? 12 : 20,
            isMobile ? 14 : 24,
            isMobile ? 120 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (Purchases Hub + Action Buttons)
              _buildHeader(isMobile),

              const SizedBox(height: 18),

              // 2. METRIC STAT CARDS (4 cards in responsive grid/row)
              _buildMetricCards(screenWidth),

              const SizedBox(height: 20),

              // 3. SEGMENTED NAVIGATION TABS
              _buildSegmentedTabs(isMobile),

              const SizedBox(height: 14),

              // 4. MAIN CONTENT CONTAINER (Tables & Lists)
              _buildActiveTabContent(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE HERO SUMMARY CARD (Matching Reports / Barcode / Marketing)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 12 : 16, isMobile ? 14 : 24, 0),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header & Status Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.shoppingBag, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'PURCHASES & PROCUREMENT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.activity, size: 13, color: Colors.greenAccent.shade100),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE SYNC',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Purchase Invoices & Orders',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons row inside Hero card
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showNewPODialog,
                  icon: const Icon(LucideIcons.plus, size: 12, color: Colors.white),
                  label: const Text(
                    '+ New PO',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showNewPurchaseBillDialog,
                  icon: const Icon(LucideIcons.plus, size: 12, color: Colors.white),
                  label: const Text(
                    '+ New Bill',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showPurchaseReturnDialog,
                  icon: const Icon(LucideIcons.rotateCcw, size: 12, color: Colors.white),
                  label: const Text(
                    '+ Return',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4 Stat Chips inside hero card
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildHeroChip('OUTWARD PROCUREMENT', '₹13,84,608', isMobile),
                const SizedBox(width: 8),
                _buildHeroChip('ACTIVE PO CYCLES', '${_purchaseOrders.length}', isMobile),
                const SizedBox(width: 8),
                _buildHeroChip('CLAIMABLE ITC', '₹2,03,584.11', isMobile),
                const SizedBox(width: 8),
                _buildHeroChip('REFUND ADJUSTMENTS', '₹0', isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, String value, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 8.5 : 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 13 : 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE STICKY TAB NAVIGATION (Matching Reports / Barcode / Marketing)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileTabNav() {
    final tabs = [
      (label: 'Purchase Orders (PO)', icon: LucideIcons.shoppingCart),
      (label: 'Purchase Bills & Invoices', icon: LucideIcons.fileText),
      (label: 'Purchase Returns (Suppliers)', icon: LucideIcons.rotateCcw),
    ];

    return SizedBox(
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _activeTab == index;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF166534) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF166534) : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF166534).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabs[index].icon,
                        size: 13,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tabs[index].label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. HEADER ROW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildHubIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Purchases Hub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manage vendor procurement cycles, GST input tax credits, multi-warehouse receiving, and purchase returns.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeaderActionBtn(
                label: '+ New PO',
                icon: LucideIcons.plus,
                color: const Color(0xFFE11D48),
                borderColor: const Color(0xFFFECDD3),
                onTap: _showNewPODialog,
              ),
              _buildHeaderActionBtn(
                label: '+ New Purchase Bill',
                icon: LucideIcons.plus,
                color: const Color(0xFF2563EB),
                borderColor: const Color(0xFFBFDBFE),
                onTap: _showNewPurchaseBillDialog,
              ),
              _buildHeaderActionBtn(
                label: '+ Purchase Return',
                icon: LucideIcons.plus,
                color: const Color(0xFF7C3AED),
                borderColor: const Color(0xFFDDD6FE),
                onTap: _showPurchaseReturnDialog,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHubIcon(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Purchases Hub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Manage vendor procurement cycles, GST input tax credits, multi-warehouse receiving, and purchase returns.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildHeaderActionBtn(
              label: '+ New PO',
              icon: LucideIcons.plus,
              color: const Color(0xFFE11D48),
              borderColor: const Color(0xFFFECDD3),
              onTap: _showNewPODialog,
            ),
            _buildHeaderActionBtn(
              label: '+ New Purchase Bill',
              icon: LucideIcons.plus,
              color: const Color(0xFF2563EB),
              borderColor: const Color(0xFFBFDBFE),
              onTap: _showNewPurchaseBillDialog,
            ),
            _buildHeaderActionBtn(
              label: '+ Purchase Return',
              icon: LucideIcons.plus,
              color: const Color(0xFF7C3AED),
              borderColor: const Color(0xFFDDD6FE),
              onTap: _showPurchaseReturnDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHubIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48), // Deep Pink / Raspberry
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          LucideIcons.shoppingBag,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildHeaderActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label.replaceFirst('+ ', ''),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. METRIC STAT CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMetricCards(double screenWidth) {
    // 4 metric cards exactly matching Image 1/2/3
    final card1 = _buildSingleMetricCard(
      title: 'OUTWARD PROCUREMENT (AT COST)',
      value: '₹13,84,608',
      icon: LucideIcons.trendingUp,
      iconColor: const Color(0xFFE11D48),
      iconBg: const Color(0xFFFFE4E6),
    );

    final card2 = _buildSingleMetricCard(
      title: 'ACTIVE PO CYCLES',
      value: '${_purchaseOrders.length}',
      icon: LucideIcons.shoppingCart,
      iconColor: const Color(0xFF2563EB),
      iconBg: const Color(0xFFDBEAFE),
    );

    final card3 = _buildSingleMetricCard(
      title: 'CLAIMABLE INPUT TAX CREDIT (ITC)',
      value: '₹2,03,584.11',
      icon: LucideIcons.percent,
      iconColor: const Color(0xFF7C3AED),
      iconBg: const Color(0xFFF3E8FF),
    );

    final card4 = _buildSingleMetricCard(
      title: 'REFUND ADJUSTMENTS',
      value: '₹0',
      icon: LucideIcons.refreshCw,
      iconColor: const Color(0xFF16A34A),
      iconBg: const Color(0xFFDCFCE7),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Desktop: 4 in a horizontal row
        if (width >= 1050) {
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
        }

        // Tablet: 2x2 grid
        if (width >= 620) {
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

        // Mobile: 2x2 compact grid with FittedBox to prevent any overflow
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 10),
                Expanded(child: card2),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: card3),
                const SizedBox(width: 10),
                Expanded(child: card4),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSingleMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 7),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SEGMENTED NAVIGATION TABS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSegmentedTabs(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTabPill(
            index: 0,
            label: 'Purchase Orders (PO)',
            icon: LucideIcons.shoppingCart,
            activeColor: const Color(0xFFE11D48), // Pink for PO
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 1,
            label: 'Purchase Bills & Invoices',
            icon: LucideIcons.fileText,
            activeColor: const Color(0xFF2563EB), // Blue for Bills
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 2,
            label: 'Purchase Returns (Suppliers)',
            icon: LucideIcons.rotateCcw,
            activeColor: const Color(0xFF059669), // Green for Returns
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isActive = _activeTab == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? activeColor : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. MAIN ACTIVE TAB CONTENT
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildActiveTabContent(double screenWidth) {
    switch (_activeTab) {
      case 0:
        return _buildPurchaseOrdersTab(screenWidth);
      case 1:
        return _buildPurchaseBillsTab(screenWidth);
      case 2:
        return _buildPurchaseReturnsTab(screenWidth);
      default:
        return const SizedBox.shrink();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 0: PURCHASE ORDERS (PO) - Image 1
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildPurchaseOrdersTab(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Bar inside Card (Image 1)
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 750;

                final searchField = SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _poSearchController,
                    onChanged: (v) => setState(() {}),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Search suppliers or order numbers',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                      ),
                    ),
                  ),
                );

                final dateBtn = InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _poFilterDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _poFilterDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _poFilterDate != null
                              ? '${_poFilterDate!.day.toString().padLeft(2, '0')}/${_poFilterDate!.month.toString().padLeft(2, '0')}/${_poFilterDate!.year}'
                              : 'dd/mm/yyyy',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _poFilterDate != null ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.calendar, size: 15, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                );

                final statusDropdown = Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _poFilterStatus,
                      icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      items: const [
                        DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                        DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                        DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _poFilterStatus = v);
                      },
                    ),
                  ),
                );

                final filterBtn = Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _poFilterDate = null;
                        _poFilterStatus = 'All Status';
                        _poSearchController.clear();
                      });
                    },
                    tooltip: 'Reset Filters',
                    icon: const Icon(LucideIcons.filter, size: 15, color: Color(0xFF64748B)),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      searchField,
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [dateBtn, statusDropdown, filterBtn],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    dateBtn,
                    const SizedBox(width: 8),
                    statusDropdown,
                    const SizedBox(width: 8),
                    filterBtn,
                  ],
                );
              },
            ),
          ),

          // Table Structure (guaranteed NO horizontal overflow via SingleChildScrollView)
          if (screenWidth < 768 && Theme.of(context).platform != TargetPlatform.macOS)
            _buildMobilePoCardList(_purchaseOrders)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = math.max(constraints.maxWidth, 1020.0);

                return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Table Header
                      _buildPoTableHeader(),

                      // Table Rows / Empty State
                      if (_purchaseOrders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF1F2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.shoppingBag, size: 32, color: Color(0xFFE11D48)),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'No active purchase orders found',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Create a new purchase order cycle with vendor terms to get started.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _showNewPODialog,
                                  icon: const Icon(LucideIcons.plus, size: 14),
                                  label: const Text('Create Purchase Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE11D48),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._purchaseOrders.map((po) => _buildPoTableRow(po)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPoTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          _buildThFlex('PO DETAILS', flex: 18, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('SUPPLIER & GST', flex: 20, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('ITEMS', flex: 16, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('OUTWARD PAYABLES', flex: 18, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('STATUS', flex: 16, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('ACTIONS', flex: 14, alignment: Alignment.centerRight),
        ],
      ),
    );
  }

  Widget _buildPoTableRow(_PurchaseBillItem po) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  po.poNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  'Date: ${po.date} | Due: ${po.dueDate}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  po.supplier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  'GSTIN: ${po.gstin}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  po.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  'Qty: ${po.qty} @ ${_formatIndianCurrency(po.rate)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatIndianCurrency(po.totalPayable),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  'CGST: ${_formatIndianCurrency(po.cgst)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
                Text(
                  'SGST: ${_formatIndianCurrency(po.sgst)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 16,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  po.status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 14,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(LucideIcons.moreVertical, size: 16, color: Color(0xFF64748B)),
                onPressed: () => _showBillDetailsModal(po),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: PURCHASE BILLS & INVOICES - Image 2
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildPurchaseBillsTab(double screenWidth) {
    final query = _billSearchController.text.trim().toLowerCase();
    final filteredBills = query.isEmpty
        ? _purchaseBills
        : _purchaseBills.where((b) {
            return b.poNumber.toLowerCase().contains(query) ||
                b.supplier.toLowerCase().contains(query) ||
                b.itemName.toLowerCase().contains(query);
          }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header inside Card (Image 2)
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 750;

                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Purchase Bills',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        children: [
                          const TextSpan(text: 'Bills with '),
                          TextSpan(
                            text: 'Pending Goods',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          const TextSpan(text: ' status need warehouse confirmation before GSTR-2B ITC is activated.'),
                        ],
                      ),
                    ),
                  ],
                );

                final searchBox = SizedBox(
                  width: isNarrow ? double.infinity : 280,
                  height: 40,
                  child: TextField(
                    controller: _billSearchController,
                    onChanged: (v) => setState(() {}),
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Search suppliers or bill numbe...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(LucideIcons.search, size: 15, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      ),
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleBlock,
                      const SizedBox(height: 12),
                      searchBox,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 16),
                    searchBox,
                  ],
                );
              },
            ),
          ),

          // Data Table wrapped in horizontal scroll view
          if (screenWidth < 768 && Theme.of(context).platform != TargetPlatform.macOS)
            _buildMobileBillsCardList(filteredBills)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = math.max(constraints.maxWidth, 1020.0);

                return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Table Header (Image 2)
                      _buildPoTableHeader(),

                      // Rows (Image 2 exact items)
                      ...filteredBills.map((bill) => _buildPurchaseBillRow(bill)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPurchaseBillRow(_PurchaseBillItem bill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // PO DETAILS
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.poNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Date: ${bill.date} | Due: ${bill.dueDate}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // SUPPLIER & GST
          Expanded(
            flex: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.supplier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bill.gstin == 'Unregistered' ? 'Unregistered' : 'GSTIN: ${bill.gstin}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: bill.gstin == 'Unregistered' ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ITEMS
          Expanded(
            flex: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Qty: ${bill.qty} @ ${_formatIndianCurrency(bill.rate)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // OUTWARD PAYABLES
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatIndianCurrency(bill.totalPayable),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'CGST (9%): ${_formatIndianCurrency(bill.cgst)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
                Text(
                  'SGST (9%): ${_formatIndianCurrency(bill.sgst)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // STATUS PILL (Image 2)
          Expanded(
            flex: 16,
            child: Align(
              alignment: Alignment.centerLeft,
              child: bill.isCompleted
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.checkCircle2, size: 13, color: Color(0xFF16A34A)),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Completed',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.clock, size: 12, color: Colors.blueGrey.shade600),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              bill.status,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),

          // ACTIONS (Image 2)
          Expanded(
            flex: 14,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showBillDetailsModal(bill);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bill.isCompleted ? 'COMPLETED' : 'CONFIRMED BY SUPPLIER',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: PURCHASE RETURNS (SUPPLIERS) - Image 3
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildPurchaseReturnsTab(double screenWidth) {
    final query = _returnSearchController.text.trim().toLowerCase();
    final filteredReturns = query.isEmpty
        ? _purchaseReturns
        : _purchaseReturns.where((r) {
            return r.refId.toLowerCase().contains(query) ||
                r.supplier.toLowerCase().contains(query) ||
                r.itemName.toLowerCase().contains(query);
          }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header inside Card (Image 3)
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;

                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Purchase Returns (Suppliers)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Manage supplier defective product returns, debit notes, and refund statuses.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                );

                final actionBtn = ElevatedButton.icon(
                  onPressed: _showPurchaseReturnDialog,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text(
                    'New Supplier Return',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669), // Emerald Green
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleBlock,
                      const SizedBox(height: 12),
                      actionBtn,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 16),
                    actionBtn,
                  ],
                );
              },
            ),
          ),

          // Table Structure (Image 3)
          if (screenWidth < 768 && Theme.of(context).platform != TargetPlatform.macOS)
            _buildMobileReturnsCardList(filteredReturns)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = math.max(constraints.maxWidth, 960.0);

                return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Header Strip (Image 3)
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFE2E8F0)),
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildThFlex('REF BILL / PURCHASE ID', flex: 20),
                            const SizedBox(width: 8),
                            _buildThFlex('SUPPLIER', flex: 20),
                            const SizedBox(width: 8),
                            _buildThFlex('ITEMS RETURNED', flex: 26),
                            const SizedBox(width: 8),
                            _buildThFlex('REFUND AMOUNT', flex: 18),
                            const SizedBox(width: 8),
                            _buildThFlex('STATUS', flex: 16, alignment: Alignment.centerRight),
                          ],
                        ),
                      ),

                      // Rows (Image 3)
                      ...filteredReturns.map((ret) => _buildPurchaseReturnRow(ret)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPurchaseReturnRow(_PurchaseReturnItem ret) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // REF BILL / PURCHASE ID
          Expanded(
            flex: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ret.refId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Original Bill Ref',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // SUPPLIER
          Expanded(
            flex: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ret.supplier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Registered Supplier',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ITEMS RETURNED (capsule with itemName & returned units)
          Expanded(
            flex: 26,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ret.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Returned: ${ret.returnedQty} Units',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // REFUND AMOUNT
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatIndianCurrency(ret.refundAmount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Credit Note Applied',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // STATUS
          Expanded(
            flex: 16,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.checkCircle2, size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        ret.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
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

  Widget _buildMobilePoCardList(List<_PurchaseBillItem> items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.shoppingBag, size: 32, color: Color(0xFFE11D48)),
              ),
              const SizedBox(height: 14),
              const Text(
                'No active purchase orders found',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create a new purchase order cycle with vendor terms to get started.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showNewPODialog,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Create Purchase Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final po = items[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: PO Number, Status, More Menu
              Row(
                children: [
                  Flexible(
                    child: Text(
                      po.poNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      po.status,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.moreVertical, size: 16, color: Color(0xFF64748B)),
                    onPressed: () => _showBillDetailsModal(po),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Supplier & GSTIN
              Text(
                po.supplier,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: 10,
                runSpacing: 2,
                children: [
                  Text('GSTIN: ${po.gstin}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text('Date: ${po.date} | Due: ${po.dueDate}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 8),

              // Item details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        po.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Qty: ${po.qty} @ ${_formatIndianCurrency(po.rate)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Total payable & Tax breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CGST: ${_formatIndianCurrency(po.cgst)} | SGST: ${_formatIndianCurrency(po.sgst)}',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatIndianCurrency(po.totalPayable),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileBillsCardList(List<_PurchaseBillItem> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: const [
            Icon(LucideIcons.fileText, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'No purchase bills found',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final bill = items[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: PO Number and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      bill.poNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  bill.isCompleted
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.checkCircle2, size: 12, color: Color(0xFF16A34A)),
                              SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.clock, size: 12, color: Colors.blueGrey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                bill.status,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 6),

              // Supplier & GSTIN
              Text(
                bill.supplier,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: 10,
                runSpacing: 2,
                children: [
                  Text(
                    bill.gstin == 'Unregistered' ? 'Unregistered' : 'GSTIN: ${bill.gstin}',
                    style: TextStyle(fontSize: 11, color: bill.gstin == 'Unregistered' ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                  Text('Date: ${bill.date} | Due: ${bill.dueDate}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 8),

              // Items
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        bill.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Qty: ${bill.qty} @ ${_formatIndianCurrency(bill.rate)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Payables & Tax
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CGST (9%): ${_formatIndianCurrency(bill.cgst)} | SGST (9%): ${_formatIndianCurrency(bill.sgst)}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatIndianCurrency(bill.totalPayable),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _showBillDetailsModal(bill),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: Text(
                    bill.isCompleted ? 'View Details' : 'Supplier Status',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileReturnsCardList(List<_PurchaseReturnItem> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: const [
            Icon(LucideIcons.rotateCcw, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'No purchase returns found',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final ret = items[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Ref ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      ret.refId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.checkCircle2, size: 12, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text(
                          ret.status,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Supplier
              Text(
                ret.supplier,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 8),

              // Item capsule
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        ret.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Returned: ${ret.returnedQty} Units',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Refund Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Credit Note Applied',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  Text(
                    _formatIndianCurrency(ret.refundAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED TABLE HEADER CELL HELPER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildThFlex(
    String label, {
    required int flex,
    bool withFilter = false,
    Alignment alignment = Alignment.centerLeft,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 11 : 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (withFilter) ...[
              const SizedBox(width: 4),
              const Icon(LucideIcons.chevronsUpDown, size: 12, color: Color(0xFF94A3B8)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTh(
    String label, {
    required double width,
    bool withFilter = false,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.4,
              ),
            ),
            if (withFilter) ...[
              const SizedBox(width: 4),
              const Icon(LucideIcons.chevronsUpDown, size: 12, color: Color(0xFF94A3B8)),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOG 1: LOG PURCHASE RETURN (DEBIT NOTE) - Image 4
  // ═══════════════════════════════════════════════════════════════════════════

  void _showPurchaseReturnDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return _PurchaseReturnDialog(
          onReturnSaved: (newReturn) {
            setState(() {
              _purchaseReturns.insert(0, newReturn);
              _activeTab = 2; // Jump to returns tab to show newly logged return
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Purchase return ${newReturn.refId} logged successfully!'),
                  ],
                ),
                backgroundColor: const Color(0xFF166534),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOG 2: NEW PURCHASE ORDER (PO)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showNewPODialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return _NewPODialog(
          onPOSaved: (newPO) {
            setState(() {
              _purchaseOrders.insert(0, newPO);
              _activeTab = 0; // Jump to PO tab
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Purchase Order ${newPO.poNumber} created successfully!'),
                  ],
                ),
                backgroundColor: const Color(0xFFE11D48),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOG 3: REGISTER NEW PURCHASE BILL
  // ═══════════════════════════════════════════════════════════════════════════

  void _showNewPurchaseBillDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return _NewPurchaseBillDialog(
          onBillSaved: (newBill) {
            setState(() {
              _purchaseBills.insert(0, newBill);
              _activeTab = 1; // Jump to bills tab
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Purchase Bill ${newBill.poNumber} registered successfully!'),
                  ],
                ),
                backgroundColor: const Color(0xFF2563EB),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DETAIL SHEET
  // ═══════════════════════════════════════════════════════════════════════════

  void _showBillDetailsModal(_PurchaseBillItem bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 600,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bill.poNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('Supplier: ${bill.supplier}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow('Date', bill.date),
              _buildDetailRow('Due Date', bill.dueDate),
              _buildDetailRow('GSTIN', bill.gstin),
              _buildDetailRow('Item & Qty', '${bill.itemName} (Qty: ${bill.qty} @ ${_formatIndianCurrency(bill.rate)})'),
              _buildDetailRow('CGST (9%)', _formatIndianCurrency(bill.cgst)),
              _buildDetailRow('SGST (9%)', _formatIndianCurrency(bill.sgst)),
              _buildDetailRow('Total Payable', _formatIndianCurrency(bill.totalPayable), isBold: true),
              _buildDetailRow('Status', bill.status),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? const Color(0xFF166534) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// IMAGE 4 DIALOG: LOG PURCHASE RETURN (DEBIT NOTE)
// ═════════════════════════════════════════════════════════════════════════════

class _PurchaseReturnDialog extends StatefulWidget {
  final void Function(_PurchaseReturnItem) onReturnSaved;
  const _PurchaseReturnDialog({required this.onReturnSaved});

  @override
  State<_PurchaseReturnDialog> createState() => _PurchaseReturnDialogState();
}

class _PurchaseReturnDialogState extends State<_PurchaseReturnDialog> {
  String _supplierName = '-- Select Active Supplier --';
  final TextEditingController _gstinController = TextEditingController(text: '27AAAAA1111A1Z1');
  final TextEditingController _addressController = TextEditingController(text: 'Supplier HQ Address');
  final TextEditingController _phoneController = TextEditingController(text: '+91 99881...');
  String _taxMode = 'GST Tax Registered';
  DateTime _purchaseDate = DateTime(2026, 10, 13);
  DateTime _dueDate = DateTime(2026, 11, 12);
  final TextEditingController _targetWarehouseController = TextEditingController(text: 'Main Godown');
  String _warehouseDropdown = '-- Select Product First --';
  final TextEditingController _reasonController = TextEditingController(text: 'Damaged Goods');
  String _paymentMode = 'Cash';

  final List<_ProductRowData> _rows = [
    _ProductRowData(
      productName: '-- Select Supplier First --',
      sku: 'IPH-15',
      cost: '0',
      qty: '1',
      discount: '0',
      gst: '18%',
    ),
  ];

  @override
  void dispose() {
    _gstinController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _targetWarehouseController.dispose();
    _reasonController.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header (Image 4)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Log Purchase Return (Debit Note)',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Doc Reference: CN-${DateTime.now().millisecondsSinceEpoch % 9000 + 4000}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.x, size: 18, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Scrollable Dialog Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. SUPPLIER METADATA CARD (Image 4)
                      _buildSupplierMetadataCard(),

                      const SizedBox(height: 14),

                      // 2. ITEMIZED PRODUCTS CARD (Image 4)
                      _buildItemizedProductsCard(),

                      const SizedBox(height: 14),

                      // 3. WAREHOUSE & REASON (Image 4)
                      _buildWarehouseAndReasonSection(),

                      const SizedBox(height: 16),

                      // 4. PAYMENT MODE & SUMMARY (Image 5)
                      LayoutBuilder(
                        builder: (context, c) => _buildPaymentModeAndSummary(c.maxWidth),
                      ),

                      const SizedBox(height: 18),

                      // Submit Button (Image 5)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final refNum = 'RET-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}';
                            final item = (_rows.isNotEmpty && _rows.first.productName != '-- Select Supplier First --')
                                ? _rows.first.productName
                                : 'erferfa';
                            final count = _rows.isNotEmpty ? int.tryParse(_rows.first.qty) ?? 1 : 1;
                            final supplier = _supplierName == '-- Select Active Supplier --'
                                ? 'ashwin'
                                : _supplierName;

                            final newReturn = _PurchaseReturnItem(
                              refId: refNum,
                              supplier: supplier,
                              itemName: item,
                              returnedQty: count,
                              refundAmount: 0.0,
                              status: 'COMPLETED',
                            );

                            widget.onReturnSaved(newReturn);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534), // Forest Green
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Save & Complete Purchase Document',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(LucideIcons.user, size: 14, color: Color(0xFF334155)),
              SizedBox(width: 8),
              Text(
                'SUPPLIER METADATA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 1: Supplier Name, GSTIN, Billing Address, Contact Phone
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 580;

              final col1 = _buildFormField(
                label: 'Supplier Name',
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _supplierName,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: '-- Select Active Supplier --', child: Text('-- Select Active Supplier --', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'ashwin', child: Text('ashwin', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'scjkhe vj', child: Text('scjkhe vj', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'srgfsg', child: Text('srgfsg', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'jeni fancy 5050', child: Text('jeni fancy 5050', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'santo', child: Text('santo', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _supplierName = v);
                      },
                    ),
                  ),
                ),
              );

              final col2 = _buildFormField(
                label: 'GSTIN Number',
                child: _buildInput(_gstinController, '27AAAAA1111A1Z1'),
              );

              final col3 = _buildFormField(
                label: 'Billing Address',
                child: _buildInput(_addressController, 'Supplier HQ Address'),
              );

              final col4 = _buildFormField(
                label: 'Contact Phone',
                child: _buildInput(_phoneController, '+91 99881...'),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    Row(children: [Expanded(child: col1), const SizedBox(width: 8), Expanded(child: col2)]),
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: col3), const SizedBox(width: 8), Expanded(child: col4)]),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 8),
                  Expanded(child: col2),
                  const SizedBox(width: 8),
                  Expanded(child: col3),
                  const SizedBox(width: 8),
                  Expanded(child: col4),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Row 2: Tax Mode, Purchase Date, Due Date, Target Warehouse
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 580;

              final col1 = _buildFormField(
                label: 'Tax Mode',
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _taxMode,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: 'GST Tax Registered', child: Text('GST Tax Registered', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'GST Composite', child: Text('GST Composite', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Non-GST', child: Text('Non-GST', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _taxMode = v);
                      },
                    ),
                  ),
                ),
              );

              final col2 = _buildFormField(
                label: 'Purchase Date',
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _purchaseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _purchaseDate = picked);
                  },
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_purchaseDate), style: const TextStyle(fontSize: 12))),
                        const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              );

              final col3 = _buildFormField(
                label: 'Due Date',
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_dueDate), style: const TextStyle(fontSize: 12))),
                        const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              );

              final col4 = _buildFormField(
                label: 'Target Warehouse',
                child: _buildInput(_targetWarehouseController, 'Main Godown'),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    Row(children: [Expanded(child: col1), const SizedBox(width: 8), Expanded(child: col2)]),
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: col3), const SizedBox(width: 8), Expanded(child: col4)]),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 8),
                  Expanded(child: col2),
                  const SizedBox(width: 8),
                  Expanded(child: col3),
                  const SizedBox(width: 8),
                  Expanded(child: col4),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemizedProductsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with + Add Row button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.layers, size: 14, color: Color(0xFF166534)),
                  SizedBox(width: 8),
                  Text(
                    'ITEMIZED PRODUCTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _rows.add(_ProductRowData());
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF166534),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('+ Add Row', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dynamic Rows (Image 4)
          ..._rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;

                  final pName = _buildFormField(
                    label: 'Product Name',
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: item.productName,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(value: '-- Select Supplier First --', child: Text('-- Select Supplier First --', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'erferfa', child: Text('erferfa', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'VIVO', child: Text('VIVO', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: 'carrot', child: Text('carrot', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => item.productName = v);
                          },
                        ),
                      ),
                    ),
                  );

                  final sku = _buildFormField(
                    label: 'SKU',
                    child: _buildStaticBox(item.sku),
                  );

                  final cost = _buildFormField(
                    label: 'Purchase Cost (₹)',
                    child: _buildStaticBox(item.cost),
                  );

                  final qty = _buildFormField(
                    label: 'Qty',
                    child: _buildStaticBox(item.qty),
                  );

                  final disc = _buildFormField(
                    label: 'Discount %',
                    child: _buildStaticBox(item.discount),
                  );

                  final gst = _buildFormField(
                    label: 'GST %',
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: item.gst,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 11, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(value: '0%', child: Text('0%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '5%', child: Text('5%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '12%', child: Text('12%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '18%', child: Text('18%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '28%', child: Text('28%', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => item.gst = v);
                          },
                        ),
                      ),
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        Row(children: [Expanded(flex: 3, child: pName), const SizedBox(width: 8), Expanded(flex: 2, child: sku)]),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: cost),
                            const SizedBox(width: 6),
                            Expanded(child: qty),
                            const SizedBox(width: 6),
                            Expanded(child: disc),
                            const SizedBox(width: 6),
                            Expanded(child: gst),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 22, child: pName),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: sku),
                      const SizedBox(width: 6),
                      Expanded(flex: 14, child: cost),
                      const SizedBox(width: 6),
                      Expanded(flex: 10, child: qty),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: disc),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: gst),
                      if (_rows.length > 1) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(LucideIcons.trash2, size: 15, color: Colors.red),
                          onPressed: () => setState(() => _rows.removeAt(idx)),
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWarehouseAndReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warehouse * (Image 4)
        _buildFormField(
          label: 'Warehouse *',
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _warehouseDropdown,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                items: const [
                  DropdownMenuItem(value: '-- Select Product First --', child: Text('-- Select Product First --', style: TextStyle(fontSize: 12.5))),
                  DropdownMenuItem(value: 'Main Godown', child: Text('Main Godown', style: TextStyle(fontSize: 12.5))),
                  DropdownMenuItem(value: 'Secondary Godown', child: Text('Secondary Godown', style: TextStyle(fontSize: 12.5))),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _warehouseDropdown = v);
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Reason for Return (Image 4)
        _buildFormField(
          label: 'Reason for Return',
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: _reasonController,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF166534))),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _buildPaymentModeAndSummary(double maxWidth) {
    final isNarrow = maxWidth < 550;

    final paymentModeSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT MODE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPayModeBtn('Cash'),
            _buildPayModeBtn('UPI'),
            _buildPayModeBtn('Bank'),
            _buildPayModeBtn('Credit'),
          ],
        ),
      ],
    );

    final summarySection = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildSummaryLine('Subtotal:', '₹0'),
          const SizedBox(height: 6),
          _buildSummaryLine('Total Discount:', '- ₹0', isRed: true),
          const SizedBox(height: 6),
          _buildSummaryLine('Input Tax (GST):', '₹0'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          _buildSummaryLine('Grand Total Due:', '₹0', isBold: true),
        ],
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          paymentModeSection,
          const SizedBox(height: 14),
          summarySection,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: paymentModeSection),
        const SizedBox(width: 16),
        Expanded(flex: 5, child: summarySection),
      ],
    );
  }

  Widget _buildPayModeBtn(String mode) {
    final isSelected = _paymentMode == mode;
    return InkWell(
      onTap: () => setState(() => _paymentMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF166534) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isRed = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13 : 11.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14.5 : 12,
            fontWeight: FontWeight.bold,
            color: isRed
                ? const Color(0xFFEF4444)
                : (isBold ? const Color(0xFF0F172A) : const Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(TextEditingController controller, String hint) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
        ),
      ),
    );
  }

  Widget _buildStaticBox(String text) {
    return Container(
      height: 38,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DIALOG 2: NEW PURCHASE ORDER (PO) - Images 3 & 4
// ═════════════════════════════════════════════════════════════════════════════

class _NewPODialog extends StatefulWidget {
  final void Function(_PurchaseBillItem) onPOSaved;
  const _NewPODialog({required this.onPOSaved});

  @override
  State<_NewPODialog> createState() => _NewPODialogState();
}

class _NewPODialogState extends State<_NewPODialog> {
  String _supplierName = '-- Select Active Supplier --';
  final TextEditingController _gstinController = TextEditingController(text: '27AAAAA1111A1Z1');
  final TextEditingController _addressController = TextEditingController(text: 'Supplier HQ Address');
  final TextEditingController _phoneController = TextEditingController(text: '+91 99881...');
  String _taxMode = 'GST Tax Registered';
  DateTime _purchaseDate = DateTime(2026, 10, 13);
  DateTime _dueDate = DateTime(2026, 11, 12);
  String _paymentMode = 'Cash';
  final TextEditingController _advancePaymentController = TextEditingController(text: '0');

  final List<String> _availableProducts = [
    '-- Select Product --',
    'IPH-15',
    'VIVO',
    'carrot',
    'erferfa',
  ];

  late final List<_ProductRowData> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      _ProductRowData(
        productName: '-- Select Product --',
        sku: 'IPH-15',
        cost: '0',
        qty: '1',
        discount: '0',
        gst: '18%',
      ),
    ];
  }

  @override
  void dispose() {
    _gstinController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _advancePaymentController.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  double get _subtotal => _rows.fold(0.0, (sum, r) => sum + r.subtotal);
  double get _totalDiscount => _rows.fold(0.0, (sum, r) => sum + r.discountAmount);
  double get _inputTaxGst => _rows.fold(0.0, (sum, r) => sum + r.gstAmount);
  double get _grandTotal => _rows.fold(0.0, (sum, r) => sum + r.total);

  void _showCreateProductModal() {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final costCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Product Name', hintText: 'e.g. Apple iPad Pro'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: skuCtrl,
              decoration: const InputDecoration(labelText: 'SKU', hintText: 'e.g. IPAD-PRO'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Purchase Cost (₹)', hintText: '0'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              if (newName.isNotEmpty) {
                final newSku = skuCtrl.text.trim().isEmpty ? 'SKU-01' : skuCtrl.text.trim();
                final newCost = costCtrl.text.trim();
                setState(() {
                  if (!_availableProducts.contains(newName)) {
                    _availableProducts.add(newName);
                  }
                  if (_rows.isNotEmpty) {
                    _rows.first.productName = newName;
                    _rows.first.sku = newSku;
                    _rows.first.cost = newCost;
                  }
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (Image 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Purchase Order (PO)',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Doc Reference: PO-3181',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.x, size: 18, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. SUPPLIER METADATA CARD (Image 3)
                      _buildSupplierMetadataCard(),

                      const SizedBox(height: 14),

                      // 2. ITEMIZED PRODUCTS CARD (Image 3)
                      _buildItemizedProductsCard(),

                      const SizedBox(height: 16),

                      // 3. PAYMENT MODE & SUMMARY (Image 4)
                      LayoutBuilder(
                        builder: (context, c) => _buildPaymentModeAndSummary(c.maxWidth),
                      ),

                      const SizedBox(height: 18),

                      // Bottom Button: Save & Complete Purchase Document (Image 4)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final itemDesc = (_rows.isNotEmpty && _rows.first.productName != '-- Select Product --')
                                ? _rows.first.productName
                                : 'IPH-15';
                            final totalQty = _rows.fold<int>(0, (sum, r) => sum + r.numericQty);
                            final avgRate = _rows.isNotEmpty ? _rows.first.numericCost : 0.0;
                            final supplier = _supplierName == '-- Select Active Supplier --'
                                ? 'jeni fancy 5050'
                                : _supplierName;

                            final po = _PurchaseBillItem(
                              poNumber: 'PO-3181',
                              date: '${_purchaseDate.year}-${_purchaseDate.month.toString().padLeft(2, '0')}-${_purchaseDate.day.toString().padLeft(2, '0')}',
                              dueDate: '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                              supplier: supplier,
                              gstin: _gstinController.text.trim().isEmpty ? '27AAAAA1111A1Z1' : _gstinController.text.trim(),
                              itemName: itemDesc,
                              qty: totalQty == 0 ? 1 : totalQty,
                              rate: avgRate,
                              totalPayable: _grandTotal,
                              cgst: _inputTaxGst / 2,
                              sgst: _inputTaxGst / 2,
                              status: 'Active',
                            );

                            widget.onPOSaved(po);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534), // Forest Green
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Save & Complete Purchase Document',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(LucideIcons.user, size: 14, color: Color(0xFF334155)),
              SizedBox(width: 8),
              Text(
                'SUPPLIER METADATA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 1: Supplier Name, GSTIN, Billing Address, Contact Phone
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              final col1 = _buildFormField(
                label: 'Supplier Name',
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _supplierName,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: '-- Select Active Supplier --', child: Text('-- Select Active Supplier --', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'jeni fancy 5050', child: Text('jeni fancy 5050', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'ashwin', child: Text('ashwin', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'santo', child: Text('santo', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'scjkhe vj', child: Text('scjkhe vj', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'srgfsg', child: Text('srgfsg', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _supplierName = v);
                      },
                    ),
                  ),
                ),
              );

              final col2 = _buildFormField(
                label: 'GSTIN Number',
                child: _buildInput(_gstinController, '27AAAAA1111A1Z1'),
              );

              final col3 = _buildFormField(
                label: 'Billing Address',
                child: _buildInput(_addressController, 'Supplier HQ Address'),
              );

              final col4 = _buildFormField(
                label: 'Contact Phone',
                child: _buildInput(_phoneController, '+91 99881...'),
              );

              if (constraints.maxWidth < 420) {
                return Column(
                  children: [
                    col1,
                    const SizedBox(height: 10),
                    col2,
                    const SizedBox(height: 10),
                    col3,
                    const SizedBox(height: 10),
                    col4,
                  ],
                );
              }

              if (isNarrow) {
                return Column(
                  children: [
                    Row(children: [Expanded(child: col1), const SizedBox(width: 8), Expanded(child: col2)]),
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: col3), const SizedBox(width: 8), Expanded(child: col4)]),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 8),
                  Expanded(child: col2),
                  const SizedBox(width: 8),
                  Expanded(child: col3),
                  const SizedBox(width: 8),
                  Expanded(child: col4),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Row 2: Tax Mode, Purchase Date, Due Date (Image 3)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              final col1 = _buildFormField(
                label: 'Tax Mode',
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _taxMode,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: 'GST Tax Registered', child: Text('GST Tax Registered', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Unregistered / Composition', child: Text('Unregistered / Composition', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _taxMode = v);
                      },
                    ),
                  ),
                ),
              );

              final col2 = _buildFormField(
                label: 'Purchase Date',
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _purchaseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _purchaseDate = picked);
                  },
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_purchaseDate), style: const TextStyle(fontSize: 12))),
                        const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              );

              final col3 = _buildFormField(
                label: 'Due Date',
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_dueDate), style: const TextStyle(fontSize: 12))),
                        const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              );

              if (isNarrow) {
                if (constraints.maxWidth < 420) {
                  return Column(
                    children: [
                      col1,
                      const SizedBox(height: 10),
                      col2,
                      const SizedBox(height: 10),
                      col3,
                    ],
                  );
                }
                return Column(
                  children: [
                    col1,
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: col2), const SizedBox(width: 8), Expanded(child: col3)]),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 8),
                  Expanded(child: col2),
                  const SizedBox(width: 8),
                  Expanded(child: col3),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemizedProductsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with + Create Product & + Add Row buttons (Image 3)
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 460;
              final titleWidget = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.layers, size: 14, color: Color(0xFF166534)),
                  SizedBox(width: 8),
                  Text(
                    'ITEMIZED PRODUCTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              );

              final createBtn = InkWell(
                onTap: _showCreateProductModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 12, color: Color(0xFF166534)),
                      SizedBox(width: 4),
                      Text('+ Create Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ],
                  ),
                ),
              );

              final addRowBtn = InkWell(
                onTap: () {
                  setState(() {
                    _rows.add(_ProductRowData());
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF166534),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('+ Add Row', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              );

              if (isVeryNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [createBtn, addRowBtn],
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleWidget,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      createBtn,
                      const SizedBox(width: 8),
                      addRowBtn,
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Dynamic Rows (Image 3)
          ..._rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 620;

                  final pName = _buildFormField(
                    label: 'Product Name',
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _availableProducts.contains(item.productName) ? item.productName : _availableProducts.first,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF64748B)),
                          items: _availableProducts.map((p) {
                            return DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 11)));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                item.productName = v;
                                if (v == 'IPH-15') {
                                  item.sku = 'IPH-15';
                                } else if (v == 'VIVO') {
                                  item.sku = 'VIVO-X100';
                                  item.cost = '50000';
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  );

                  final sku = _buildFormField(
                    label: 'SKU',
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: TextEditingController(text: item.sku),
                        onChanged: (val) => item.sku = val,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
                        ),
                      ),
                    ),
                  );

                  final cost = _buildFormField(
                    label: 'Purchase Cost (₹)',
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: item.costController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
                        ),
                      ),
                    ),
                  );

                  final qty = _buildFormField(
                    label: 'Qty',
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: item.qtyController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
                        ),
                      ),
                    ),
                  );

                  final disc = _buildFormField(
                    label: 'Discount %',
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: item.discountController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
                        ),
                      ),
                    ),
                  );

                  final gst = _buildFormField(
                    label: 'GST %',
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: item.gst,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 11, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(value: '0%', child: Text('0%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '5%', child: Text('5%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '12%', child: Text('12%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '18%', child: Text('18%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '28%', child: Text('28%', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => item.gst = v);
                            }
                          },
                        ),
                      ),
                    ),
                  );

                  if (isNarrow) {
                    final deleteBtn = _rows.length > 1
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(LucideIcons.trash2, size: 15, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                final removed = _rows.removeAt(idx);
                                removed.dispose();
                              });
                            },
                          )
                        : null;

                    if (constraints.maxWidth < 420) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 3, child: pName),
                              const SizedBox(width: 8),
                              Expanded(flex: 2, child: sku),
                              if (deleteBtn != null) ...[
                                const SizedBox(width: 6),
                                deleteBtn,
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: cost),
                              const SizedBox(width: 8),
                              Expanded(child: qty),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: disc),
                              const SizedBox(width: 8),
                              Expanded(child: gst),
                            ],
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 3, child: pName),
                            const SizedBox(width: 8),
                            Expanded(flex: 2, child: sku),
                            if (deleteBtn != null) ...[
                              const SizedBox(width: 6),
                              deleteBtn,
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: cost),
                            const SizedBox(width: 6),
                            Expanded(child: qty),
                            const SizedBox(width: 6),
                            Expanded(child: disc),
                            const SizedBox(width: 6),
                            Expanded(child: gst),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 22, child: pName),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: sku),
                      const SizedBox(width: 6),
                      Expanded(flex: 14, child: cost),
                      const SizedBox(width: 6),
                      Expanded(flex: 10, child: qty),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: disc),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: gst),
                      if (_rows.length > 1) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(LucideIcons.trash2, size: 15, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              final removed = _rows.removeAt(idx);
                              removed.dispose();
                            });
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentModeAndSummary(double maxWidth) {
    final isNarrow = maxWidth < 550;

    final paymentModeSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT MODE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPayModeBtn('Cash'),
            _buildPayModeBtn('UPI'),
            _buildPayModeBtn('Bank'),
            _buildPayModeBtn('Credit'),
          ],
        ),
        const SizedBox(height: 14),
        _buildFormField(
          label: 'Advance Payment Amount (₹)',
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _advancePaymentController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Entering an advance payment logs instant cash outflows dynamically.',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );

    final summarySection = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildSummaryLine('Subtotal:', _formatIndianCurrencyAmount(_subtotal)),
          const SizedBox(height: 6),
          _buildSummaryLine('Total Discount:', '- ${_formatIndianCurrencyAmount(_totalDiscount)}', isRed: true),
          const SizedBox(height: 6),
          _buildSummaryLine('Input Tax (GST):', _formatIndianCurrencyAmount(_inputTaxGst)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          _buildSummaryLine('Grand Total Due:', _formatIndianCurrencyAmount(_grandTotal), isBold: true),
        ],
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          paymentModeSection,
          const SizedBox(height: 14),
          summarySection,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: paymentModeSection),
        const SizedBox(width: 16),
        Expanded(flex: 5, child: summarySection),
      ],
    );
  }

  Widget _buildPayModeBtn(String mode) {
    final isSelected = _paymentMode == mode;
    return InkWell(
      onTap: () => setState(() => _paymentMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF166534) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isRed = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13 : 11.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14.5 : 12,
            fontWeight: FontWeight.bold,
            color: isRed
                ? const Color(0xFFEF4444)
                : (isBold ? const Color(0xFF0F172A) : const Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _buildInput(TextEditingController controller, String hint) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DIALOG 3: REGISTER NEW PURCHASE BILL - Image 5
// ═════════════════════════════════════════════════════════════════════════════

class _NewPurchaseBillDialog extends StatefulWidget {
  final void Function(_PurchaseBillItem) onBillSaved;
  const _NewPurchaseBillDialog({required this.onBillSaved});

  @override
  State<_NewPurchaseBillDialog> createState() => _NewPurchaseBillDialogState();
}

class _NewPurchaseBillDialogState extends State<_NewPurchaseBillDialog> {
  String _supplierName = '-- Select Active Supplier --';
  final TextEditingController _gstinController = TextEditingController(text: '27AAAAA1111A1Z1');
  final TextEditingController _addressController = TextEditingController(text: 'Supplier HQ Address');
  final TextEditingController _phoneController = TextEditingController(text: '+91 99881...');
  String _taxMode = 'GST Tax Registered';
  DateTime _purchaseDate = DateTime(2026, 10, 13);
  DateTime _dueDate = DateTime(2026, 11, 12);
  final TextEditingController _targetWarehouseController = TextEditingController(text: 'Main Godown');
  String _paymentMode = 'Cash';
  final TextEditingController _paidAmountController = TextEditingController(text: '0');

  final List<String> _availableProducts = [
    '-- Select Product --',
    'IPH-15',
    'VIVO',
    'carrot',
    'erferfa',
  ];

  late final List<_ProductRowData> _rows;

  @override
  void initState() {
    super.initState();
    _rows = [
      _ProductRowData(
        productName: '-- Select Product --',
        sku: 'IPH-15',
        cost: '0',
        qty: '1',
        discount: '0',
        gst: '18%',
      ),
    ];
  }

  @override
  void dispose() {
    _gstinController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _targetWarehouseController.dispose();
    _paidAmountController.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  double get _subtotal => _rows.fold(0.0, (sum, r) => sum + r.subtotal);
  double get _totalDiscount => _rows.fold(0.0, (sum, r) => sum + r.discountAmount);
  double get _inputTaxGst => _rows.fold(0.0, (sum, r) => sum + r.gstAmount);
  double get _grandTotal => _rows.fold(0.0, (sum, r) => sum + r.total);

  void _showCreateProductModal() {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final costCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Product Name', hintText: 'e.g. Apple iPad Pro'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: skuCtrl,
              decoration: const InputDecoration(labelText: 'SKU', hintText: 'e.g. IPAD-PRO'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Purchase Cost (₹)', hintText: '0'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              if (newName.isNotEmpty) {
                final newSku = skuCtrl.text.trim().isEmpty ? 'SKU-01' : skuCtrl.text.trim();
                final newCost = costCtrl.text.trim();
                setState(() {
                  if (!_availableProducts.contains(newName)) {
                    _availableProducts.add(newName);
                  }
                  if (_rows.isNotEmpty) {
                    _rows.first.productName = newName;
                    _rows.first.sku = newSku;
                    _rows.first.cost = newCost;
                  }
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (Image 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Register New Purchase Bill',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Doc Reference: BILL-7429',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.x, size: 18, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. SUPPLIER METADATA CARD (Image 5)
                      _buildSupplierMetadataCard(),

                      const SizedBox(height: 14),

                      // 2. ITEMIZED PRODUCTS CARD (Image 5)
                      _buildItemizedProductsCard(),

                      const SizedBox(height: 16),

                      // 3. PAYMENT MODE & SUMMARY
                      LayoutBuilder(
                        builder: (context, c) => _buildPaymentModeAndSummary(c.maxWidth),
                      ),

                      const SizedBox(height: 18),

                      // Bottom Button: Save & Complete Purchase Document
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final itemDesc = (_rows.isNotEmpty && _rows.first.productName != '-- Select Product --')
                                ? _rows.first.productName
                                : 'IPH-15';
                            final totalQty = _rows.fold<int>(0, (sum, r) => sum + r.numericQty);
                            final avgRate = _rows.isNotEmpty ? _rows.first.numericCost : 0.0;
                            final supplier = _supplierName == '-- Select Active Supplier --'
                                ? 'jeni fancy 5050'
                                : _supplierName;

                            final bill = _PurchaseBillItem(
                              poNumber: 'BILL-7429',
                              date: '${_purchaseDate.year}-${_purchaseDate.month.toString().padLeft(2, '0')}-${_purchaseDate.day.toString().padLeft(2, '0')}',
                              dueDate: '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                              supplier: supplier,
                              gstin: _gstinController.text.trim().isEmpty ? '27AAAAA1111A1Z1' : _gstinController.text.trim(),
                              itemName: itemDesc,
                              qty: totalQty == 0 ? 1 : totalQty,
                              rate: avgRate,
                              totalPayable: _grandTotal,
                              cgst: _inputTaxGst / 2,
                              sgst: _inputTaxGst / 2,
                              status: 'Completed',
                              isCompleted: true,
                            );

                            widget.onBillSaved(bill);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF166534), // Forest Green
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Save & Complete Purchase Document',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(LucideIcons.user, size: 14, color: Color(0xFF334155)),
              SizedBox(width: 8),
              Text(
                'SUPPLIER METADATA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 1: Supplier Name, GSTIN, Billing Address, Contact Phone
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              final col1 = _buildFormField(
                label: 'Supplier Name',
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _supplierName,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: '-- Select Active Supplier --', child: Text('-- Select Active Supplier --', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'jeni fancy 5050', child: Text('jeni fancy 5050', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'ashwin', child: Text('ashwin', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'santo', child: Text('santo', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'scjkhe vj', child: Text('scjkhe vj', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'srgfsg', child: Text('srgfsg', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _supplierName = v);
                      },
                    ),
                  ),
                ),
              );

              final col2 = _buildFormField(
                label: 'GSTIN Number',
                child: _buildInput(_gstinController, '27AAAAA1111A1Z1'),
              );

              final col3 = _buildFormField(
                label: 'Billing Address',
                child: _buildInput(_addressController, 'Supplier HQ Address'),
              );

              final col4 = _buildFormField(
                label: 'Contact Phone',
                child: _buildInput(_phoneController, '+91 99881...'),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    Row(children: [Expanded(child: col1), const SizedBox(width: 8), Expanded(child: col2)]),
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: col3), const SizedBox(width: 8), Expanded(child: col4)]),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 8),
                  Expanded(child: col2),
                  const SizedBox(width: 8),
                  Expanded(child: col3),
                  const SizedBox(width: 8),
                  Expanded(child: col4),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Row 2: Tax Mode, Purchase Date, Due Date, Target Warehouse (Image 5)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              final col1 = _buildFormField(
                label: 'Tax Mode',
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _taxMode,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: 'GST Tax Registered', child: Text('GST Tax Registered', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Unregistered / Composition', child: Text('Unregistered / Composition', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _taxMode = v);
                      },
                    ),
                  ),
                ),
              );

              final col2 = _buildFormField(
                label: 'Purchase Date',
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _purchaseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _purchaseDate = picked);
                  },
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_purchaseDate), style: const TextStyle(fontSize: 12))),
                        const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              );

              final col3 = _buildFormField(
                label: 'Due Date',
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDate(_dueDate), style: const TextStyle(fontSize: 12))),
                        const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              );

              final col4 = _buildFormField(
                label: 'Target Warehouse',
                child: _buildInput(_targetWarehouseController, 'Main Godown'),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    Row(children: [Expanded(child: col1), const SizedBox(width: 8), Expanded(child: col2)]),
                    const SizedBox(height: 10),
                    Row(children: [Expanded(child: col3), const SizedBox(width: 8), Expanded(child: col4)]),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 8),
                  Expanded(child: col2),
                  const SizedBox(width: 8),
                  Expanded(child: col3),
                  const SizedBox(width: 8),
                  Expanded(child: col4),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemizedProductsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with + Create Product & + Add Row buttons (Image 5)
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 460;
              final titleWidget = const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.layers, size: 14, color: Color(0xFF166534)),
                  SizedBox(width: 8),
                  Text(
                    'ITEMIZED PRODUCTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              );

              final createBtn = InkWell(
                onTap: _showCreateProductModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 12, color: Color(0xFF166534)),
                      SizedBox(width: 4),
                      Text('Create Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ],
                  ),
                ),
              );

              final addRowBtn = InkWell(
                onTap: () {
                  setState(() {
                    _rows.add(_ProductRowData());
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF166534),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Add Row', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              );

              if (isVeryNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [createBtn, addRowBtn],
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleWidget,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      createBtn,
                      const SizedBox(width: 8),
                      addRowBtn,
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Dynamic Rows (Image 5)
          ..._rows.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 620;

                  final pName = _buildFormField(
                    label: 'Product Name',
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _availableProducts.contains(item.productName) ? item.productName : _availableProducts.first,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF64748B)),
                          items: _availableProducts.map((p) {
                            return DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 11)));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                item.productName = v;
                                if (v == 'IPH-15') {
                                  item.sku = 'IPH-15';
                                } else if (v == 'VIVO') {
                                  item.sku = 'VIVO-X100';
                                  item.cost = '50000';
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  );

                  final sku = _buildFormField(
                    label: 'SKU',
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: TextEditingController(text: item.sku),
                        onChanged: (val) => item.sku = val,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
                        ),
                      ),
                    ),
                  );

                  final cost = _buildFormField(
                    label: 'Purchase Cost (₹)',
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: item.costController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
                        ),
                      ),
                    ),
                  );

                  final qty = _buildFormField(
                    label: 'Qty',
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: item.qtyController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
                        ),
                      ),
                    ),
                  );

                  final disc = _buildFormField(
                    label: 'Discount %',
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: item.discountController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
                        ),
                      ),
                    ),
                  );

                  final gst = _buildFormField(
                    label: 'GST %',
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: item.gst,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 11, color: Color(0xFF64748B)),
                          items: const [
                            DropdownMenuItem(value: '0%', child: Text('0%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '5%', child: Text('5%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '12%', child: Text('12%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '18%', child: Text('18%', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: '28%', child: Text('28%', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => item.gst = v);
                            }
                          },
                        ),
                      ),
                    ),
                  );

                  if (constraints.maxWidth < 420) {
                    return Column(
                      children: [
                        Row(children: [Expanded(flex: 3, child: pName), const SizedBox(width: 8), Expanded(flex: 2, child: sku)]),
                        const SizedBox(height: 8),
                        Row(children: [Expanded(child: cost), const SizedBox(width: 8), Expanded(child: qty)]),
                        const SizedBox(height: 8),
                        Row(children: [Expanded(child: disc), const SizedBox(width: 8), Expanded(child: gst)]),
                      ],
                    );
                  }

                  if (isNarrow) {
                    return Column(
                      children: [
                        Row(children: [Expanded(flex: 3, child: pName), const SizedBox(width: 8), Expanded(flex: 2, child: sku)]),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: cost),
                            const SizedBox(width: 6),
                            Expanded(child: qty),
                            const SizedBox(width: 6),
                            Expanded(child: disc),
                            const SizedBox(width: 6),
                            Expanded(child: gst),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 22, child: pName),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: sku),
                      const SizedBox(width: 6),
                      Expanded(flex: 14, child: cost),
                      const SizedBox(width: 6),
                      Expanded(flex: 10, child: qty),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: disc),
                      const SizedBox(width: 6),
                      Expanded(flex: 12, child: gst),
                      if (_rows.length > 1) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(LucideIcons.trash2, size: 15, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              final removed = _rows.removeAt(idx);
                              removed.dispose();
                            });
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentModeAndSummary(double maxWidth) {
    final isNarrow = maxWidth < 550;

    final paymentModeSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT MODE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPayModeBtn('Cash'),
            _buildPayModeBtn('UPI'),
            _buildPayModeBtn('Bank'),
            _buildPayModeBtn('Credit'),
          ],
        ),
        const SizedBox(height: 14),
        _buildFormField(
          label: 'Paid Amount (₹)',
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _paidAmountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
              ),
            ),
          ),
        ),
      ],
    );

    final summarySection = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildSummaryLine('Subtotal:', _formatIndianCurrencyAmount(_subtotal)),
          const SizedBox(height: 6),
          _buildSummaryLine('Total Discount:', '- ${_formatIndianCurrencyAmount(_totalDiscount)}', isRed: true),
          const SizedBox(height: 6),
          _buildSummaryLine('Input Tax (GST):', _formatIndianCurrencyAmount(_inputTaxGst)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          _buildSummaryLine('Grand Total Due:', _formatIndianCurrencyAmount(_grandTotal), isBold: true),
        ],
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          paymentModeSection,
          const SizedBox(height: 14),
          summarySection,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: paymentModeSection),
        const SizedBox(width: 16),
        Expanded(flex: 5, child: summarySection),
      ],
    );
  }

  Widget _buildPayModeBtn(String mode) {
    final isSelected = _paymentMode == mode;
    return InkWell(
      onTap: () => setState(() => _paymentMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF166534) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isRed = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13 : 11.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14.5 : 12,
            fontWeight: FontWeight.bold,
            color: isRed
                ? const Color(0xFFEF4444)
                : (isBold ? const Color(0xFF0F172A) : const Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _buildInput(TextEditingController controller, String hint) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF166534))),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RESPONSIVE FLOATING ACTION BUTTON (SPEED DIAL FOR MOBILE)
// ═════════════════════════════════════════════════════════════════════════════

class _ExpandableFab extends StatefulWidget {
  final VoidCallback onNewPO;
  final VoidCallback onNewBill;
  final VoidCallback onReturn;

  const _ExpandableFab({
    required this.onNewPO,
    required this.onNewBill,
    required this.onReturn,
  });

  @override
  State<_ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<_ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _buildFabOption('Purchase Return', LucideIcons.rotateCcw, const Color(0xFF7C3AED), () {
            _toggle();
            widget.onReturn();
          }),
          const SizedBox(height: 10),
          _buildFabOption('New Purchase Bill', LucideIcons.fileText, const Color(0xFF2563EB), () {
            _toggle();
            widget.onNewBill();
          }),
          const SizedBox(height: 10),
          _buildFabOption('New PO', LucideIcons.shoppingCart, const Color(0xFFE11D48), () {
            _toggle();
            widget.onNewPO();
          }),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: const Color(0xFF166534),
          foregroundColor: Colors.white,
          elevation: 4,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(LucideIcons.plus, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption(String label, IconData icon, Color color, VoidCallback onTap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          height: 44,
          child: FloatingActionButton(
            heroTag: null,
            onPressed: onTap,
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 3,
            child: Icon(icon, size: 18),
          ),
        ),
      ],
    );
  }
}

class _StickyTabNavDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _StickyTabNavDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyTabNavDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
