import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../widgets/app_ui_kit.dart';

class BillingPage extends ConsumerStatefulWidget {
  const BillingPage({super.key});

  @override
  ConsumerState<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends ConsumerState<BillingPage> {
  // Main Tabs: 0: Orders List, 1: Sales Returns, 2: Warranty & Replacement Claims, 3: DELIVERY CHALLAN
  int _activeMainTab = 0;

  // Delivery Challan Sub-Tabs: 0: Shipments & Real-Time Status, 1: Delivery Challans, 2: Driver Performance, 3: Reverse Logistics
  int _activeDeliverySubTab = 0;

  // Filters
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedStatus = 'All Status';

  // ─── STATE DATA ───
  // 1. Orders / Sales Invoices (Image 1)
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'POS-239759',
      'shortId': 'POS-239759',
      'tag': 'Billed in POS',
      'client': 'Walk-in Customer',
      'subClient': 'Billed by: Admin',
      'email': '',
      'dueDate': '2026-10-12',
      'amount': '₹2,00,00,08,798',
      'status': 'POS BILLED PRODUCT',
      'hasEInvoice': false,
    },
    {
      'id': 'POS-239758',
      'shortId': 'POS-239758',
      'tag': 'Billed in POS',
      'client': 'sanjay123',
      'subClient': 'Billed by: Admin',
      'email': 'sanjay123@bnxmail.com',
      'dueDate': '2026-09-29',
      'amount': '₹2,00,01,68,798',
      'status': 'POS BILLED PRODUCT',
      'hasEInvoice': false,
    },
    {
      'id': 'POS-239757',
      'shortId': 'POS-239757',
      'tag': 'Billed in POS',
      'client': 'Walk-in Customer',
      'subClient': 'Billed by: Admin',
      'email': '',
      'dueDate': '2026-09-28',
      'amount': '₹1,090',
      'status': 'POS BILLED PRODUCT',
      'hasEInvoice': false,
    },
    {
      'id': 'POS-239756',
      'shortId': 'POS-239756',
      'tag': 'Billed in POS',
      'client': 'Walk-in Customer',
      'subClient': 'Billed by: Admin',
      'email': '',
      'dueDate': '2026-09-28',
      'amount': '₹14',
      'status': 'POS BILLED PRODUCT',
      'hasEInvoice': false,
    },
    {
      'id': 'POS-239755',
      'shortId': 'POS-239755',
      'tag': 'Billed in POS',
      'client': 'Walk-in Customer',
      'subClient': 'Billed by: Admin',
      'email': '',
      'dueDate': '2026-09-25',
      'amount': '₹357',
      'status': 'POS BILLED PRODUCT',
      'hasEInvoice': false,
    },
  ];

  // 2. Sales Returns (Image 2)
  final List<Map<String, dynamic>> _salesReturns = [
    {
      'ref': 'RET-307902',
      'client': 'Varshini',
      'origInvoice': 'POS-239759',
      'date': '24/08/2026',
      'amount': '₹45,32,800',
      'status': 'PENDING',
      'godown': 'Assigned: Chennai godown',
    },
    {
      'ref': 'RET-301403',
      'client': 'Customer',
      'origInvoice': 'POS / Direct',
      'date': '21/08/2026',
      'amount': '₹0',
      'status': 'COMPLETED',
      'godown': 'Assigned: Chennai godown',
    },
    {
      'ref': 'RET-360441',
      'client': 'Customer',
      'origInvoice': 'POS / Direct',
      'date': '21/08/2026',
      'amount': '₹0',
      'status': 'COMPLETED',
      'godown': 'Assigned: Chennai godown',
    },
    {
      'ref': 'RET-980992',
      'client': 'Customer',
      'origInvoice': 'POS / Direct',
      'date': '21/08/2026',
      'amount': '₹0',
      'status': 'COMPLETED',
      'godown': 'Assigned: Damaged products godown',
    },
  ];

  // 3. Warranty & Replacement Claims (Image 3)
  final List<Map<String, dynamic>> _warrantyClaims = [
    {
      'ref': 'CLM-256942',
      'product': 'VIVO',
      'client': 'Walk-in Customer',
      'serial': 'N/A',
      'claimType': 'Warranty Tracking',
      'status': 'ACTIVE',
      'godown': '',
      'period': '3 Years',
      'isGreenRef': true,
    },
    {
      'ref': 'RET-490845',
      'product': 'VIVO',
      'client': 'sanjay123',
      'serial': 'N/A',
      'claimType': 'Warranty Tracking',
      'status': 'PENDING',
      'godown': '',
      'period': '3 Years',
      'isGreenRef': false,
    },
    {
      'ref': 'CLM-141578',
      'product': 'VIVO',
      'client': 'sanjay123',
      'serial': 'N/A',
      'claimType': 'Warranty Tracking',
      'status': 'ACTIVE',
      'godown': '',
      'period': '3 Years',
      'isGreenRef': true,
    },
    {
      'ref': 'RET-307902',
      'product': 'PEN',
      'client': 'Varshini',
      'serial': 'N/A',
      'claimType': 'Warranty Tracking',
      'status': 'PENDING',
      'godown': 'Assigned: Chennai godown',
      'period': '3 Years',
      'isGreenRef': false,
    },
    {
      'ref': 'RET-301403',
      'product': 'Product',
      'client': 'Customer',
      'serial': 'N/A',
      'claimType': 'Warranty Tracking',
      'status': 'DONE',
      'godown': 'Assigned: Chennai godown',
      'period': '3 Years',
      'isGreenRef': false,
    },
  ];

  // 4. Delivery Shipments (Image 4)
  final List<Map<String, dynamic>> _deliveries = [
    {
      'recipient': 'Aman Deep',
      'status': 'Out For Delivery',
      'ref': 'CLIKS/DEL/26/101',
      'city': 'Pune',
      'courier': 'CLIKS Logistics',
      'tracking': 'TRK998248102',
      'driver': 'Satish Yadav',
      'vehicle': 'MH-12-QB-8821',
      'isDelivered': false,
    },
    {
      'recipient': 'Megha Sharma',
      'status': 'Delivered',
      'ref': 'CLIKS/DEL/26/102',
      'city': 'Pune',
      'courier': 'Delhivery',
      'tracking': 'TRK998248091',
      'driver': 'Rajesh Patil',
      'vehicle': 'MH-14-EU-4592',
      'isDelivered': true,
    },
  ];

  // 5. Generated Delivery Challans (Image 5)
  final List<Map<String, dynamic>> _generatedChallans = [
    {
      'challanNo': 'CHL-2026-4402',
      'client': 'Aman Deep',
      'invoice': 'INV-40292',
      'type': 'GST',
      'date': '2026-05-06',
      'status': 'OUT FOR DELIVERY',
      'statusColor': 'amber',
    },
    {
      'challanNo': 'CHL-2026-4403',
      'client': 'Megha Sharma',
      'invoice': 'INV-40280',
      'type': 'GST',
      'date': '2026-05-05',
      'status': 'DELIVERED',
      'statusColor': 'green',
    },
    {
      'challanNo': 'CHL-2026-4390',
      'client': 'Rahul Varma',
      'invoice': 'INV-40250',
      'type': 'GST',
      'date': '2026-05-04',
      'status': 'FAILED ATTEMPT',
      'statusColor': 'red',
    },
    {
      'challanNo': 'CHL-2026-4420',
      'client': 'Snehal Deshmukh',
      'invoice': 'INV-40301',
      'type': 'Non-GST',
      'date': '2026-05-06',
      'status': 'PACKED',
      'statusColor': 'amber',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 14.0 : 28.0;

    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    if (isMacOS) {
      return _buildDesktopView(isMobile, paddingVal);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      floatingActionButton: (isMobile && _activeMainTab == 0)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 76),
              child: FloatingActionButton.extended(
                onPressed: () {
                  ref.read(navigationProvider.notifier).setRoute(AppRoute.newInvoice);
                },
                backgroundColor: const Color(0xFF166534),
                elevation: 4,
                icon: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                label: const Text(
                  'Generate Invoice',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting Style Header) ───
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
              height: isMobile ? 50 : 56,
              child: Container(
                color: const Color(0xFFF8F9FB),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _buildTabNav(isMobile),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // ─── MAIN CONTENT AREA ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 140 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_activeMainTab == 0) ...[
                    _buildOrdersListTab(isMobile),
                  ] else if (_activeMainTab == 1) ...[
                    _buildWarrantyClaimsTab(isMobile),
                  ] else ...[
                    _buildDeliveryChallanTab(isMobile),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MACOS / DESKTOP VIEW (UNTOUCHED ORIGINAL LAYOUT)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopView(bool isMobile, double paddingVal) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(paddingVal, isMobile ? 12 : 24, paddingVal, isMobile ? 90 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. TOP HEADER ───
            _buildTopHeader(isMobile),
            const SizedBox(height: 20),

            // ─── 2. 4 TOP METRIC CARDS ───
            _buildTopMetricCards(isMobile),
            const SizedBox(height: 22),

            // ─── 3. 4 MAIN SECTION TABS ───
            _buildMainTabs(isMobile),
            const SizedBox(height: 18),

            // ─── 4. TAB SPECIFIC CONTENT ───
            if (_activeMainTab == 0) ...[
              _buildOrdersListTab(isMobile),
            ] else if (_activeMainTab == 1) ...[
              _buildWarrantyClaimsTab(isMobile),
            ] else ...[
              _buildDeliveryChallanTab(isMobile),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE HERO SUMMARY CARD (Reports / Marketing / Barcode Gen Style)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 12 : 16, isMobile ? 14 : 24, 0),
      padding: EdgeInsets.all(isMobile ? 16 : 22),
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
                      child: const Icon(LucideIcons.receipt, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'SALES & BILLING HUB',
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
                    Icon(LucideIcons.trendingUp, size: 13, color: Colors.greenAccent.shade100),
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
          const SizedBox(height: 14),
          Row(
            children: [
              _buildHeroChip('TOTAL INVOICED', '₹10,259.7 Cr', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('PAID REVENUE', '₹10,258.7 Cr', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('UNPAID DUES', '₹10.21 Cr', isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, String value, bool isMobile) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 8 : 10),
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
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE STICKY TAB NAVIGATION (Choice Chips matching Reports & Marketing)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabNav(bool isMobile) {
    final tabs = [
      {'label': 'Invoices List', 'icon': LucideIcons.receipt},
      {'label': 'Warranty & Replacement Claims', 'icon': LucideIcons.shieldCheck},
      {'label': 'DELIVERY CHALLAN', 'icon': LucideIcons.truck},
    ];

    return Container(
      color: const Color(0xFFF8F9FB),
      height: isMobile ? 46 : 52,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 4),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _activeMainTab == index;
            final isLast = index == tabs.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 6),
              child: Builder(
                builder: (tabContext) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeMainTab = index);
                      Scrollable.ensureVisible(
                        tabContext,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: 0.5,
                      );
                    },
                    child: AnimatedContainer(
                      duration: Theme.of(context).platform == TargetPlatform.macOS ? Duration.zero : const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
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
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[index]['icon'] as IconData,
                            size: isMobile ? 13 : 15,
                            color: isSelected ? Colors.white : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tabs[index]['label'] as String,
                            style: TextStyle(
                              fontSize: isMobile ? 11.5 : 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP HEADER: Title, Subtitle, and Top Action Buttons
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopHeader(bool isMobile) {
    final titleSection = Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(LucideIcons.receipt, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Billing Center',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3),
              Text(
                'Manage client invoices and accounts receivable.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (_activeMainTab == 2)
          ElevatedButton.icon(
            onPressed: () => _openDispatchShipmentModal(),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text(
              'Dispatch Shipment',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () {
            ref.read(navigationProvider.notifier).setRoute(AppRoute.invoiceTemplates);
          },
          icon: const Icon(LucideIcons.layoutGrid, size: 14, color: Color(0xFF334155)),
          label: const Text(
            'Templates',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(navigationProvider.notifier).setRoute(AppRoute.newInvoice);
          },
          icon: const Icon(LucideIcons.plus, size: 14),
          label: const Text(
            'Generate Invoice',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile || constraints.maxWidth < 680) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleSection,
              const SizedBox(height: 14),
              actions,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: titleSection),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. 4 TOP METRIC CARDS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopMetricCards(bool isMobile) {
    final card1 = _buildKpiCard(
      label: 'TOTAL INVOICED',
      value: '₹10,25,97,52,82,582',
      icon: LucideIcons.trendingUp,
      iconColor: const Color(0xFFE11D48),
      iconBg: const Color(0xFFFFF1F2),
    );

    final card2 = _buildKpiCard(
      label: 'PAID REVENUE',
      value: '₹10,23,61,43,53,378',
      icon: LucideIcons.checkCircle2,
      iconColor: const Color(0xFF10B981),
      iconBg: const Color(0xFFDCFCE7),
    );

    final card3 = _buildKpiCard(
      label: 'OUTSTANDING BALANCE',
      value: '₹2,36,09,29,204',
      icon: LucideIcons.alertTriangle,
      iconColor: const Color(0xFFF59E0B),
      iconBg: const Color(0xFFFEF3C7),
    );

    final card4 = _buildKpiCard(
      label: 'ACTIVE CLIENTS',
      value: '9',
      icon: LucideIcons.user,
      iconColor: const Color(0xFF3B82F6),
      iconBg: const Color(0xFFEFF6FF),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1050) {
          return Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 14),
              Expanded(child: card2),
              const SizedBox(width: 14),
              Expanded(child: card3),
              const SizedBox(width: 14),
              Expanded(child: card4),
            ],
          );
        } else if (constraints.maxWidth >= 600) {
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
        } else {
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
      },
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. MAIN SECTION TABS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainTabs(bool isMobile) {
    final tabs = [
      {'title': 'Invoices List', 'icon': LucideIcons.receipt, 'color': const Color(0xFF166534)},
      {'title': 'Warranty & Replacement Claims', 'icon': LucideIcons.shieldCheck, 'color': const Color(0xFF059669)},
      {'title': 'DELIVERY CHALLAN', 'icon': LucideIcons.truck, 'color': const Color(0xFF0284C7)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _activeMainTab == index;
          final tabData = tabs[index];
          final activeColor = tabData['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _activeMainTab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabData['icon'] as IconData,
                      size: 15,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabData['title'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {Alignment alignment = Alignment.centerLeft, bool isMobile = false}) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 14, vertical: isMobile ? 8 : 14),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 11.0 : 12.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget child, {Alignment alignment = Alignment.centerLeft, bool isMobile = false}) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 14, vertical: isMobile ? 7 : 14),
      child: ClipRect(child: child),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. TAB 0: ORDERS LIST (Image 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOrdersListTab(bool isMobile) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _invoices.where((inv) {
      return query.isEmpty ||
          inv['id'].toString().toLowerCase().contains(query) ||
          inv['client'].toString().toLowerCase().contains(query);
    }).toList();

    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    if (isMobile && !isMacOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(
            hintText: 'Search client or invoice #...',
            isMobile: isMobile,
            extraAction: null,
          ),
          const SizedBox(height: 16),
          _buildMobileOrdersCardList(filtered),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(
          hintText: 'Search client or invoice #...',
          isMobile: isMobile,
          extraAction: null,
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
            boxShadow: const [],
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = isMobile
                    ? math.max(constraints.maxWidth, 680.0)
                    : math.max(constraints.maxWidth, 1060.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: isMobile
                          ? const {
                              0: FlexColumnWidth(2.2), // INVOICE
                              1: FlexColumnWidth(2.4), // CLIENT
                              2: FlexColumnWidth(1.4), // DUE DATE
                              3: FlexColumnWidth(1.4), // AMOUNT
                              4: FlexColumnWidth(2.0), // STATUS
                              5: FixedColumnWidth(140), // ACTIONS
                            }
                          : const {
                              0: FlexColumnWidth(2.6), // INVOICE
                              1: FlexColumnWidth(2.6), // CLIENT
                              2: FlexColumnWidth(1.6), // DUE DATE
                              3: FlexColumnWidth(1.6), // AMOUNT
                              4: FlexColumnWidth(2.2), // STATUS
                              5: FixedColumnWidth(185), // ACTIONS
                            },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0)),
                          ),
                          children: [
                            _buildTableHeaderCell('INVOICE ▽', isMobile: isMobile),
                            _buildTableHeaderCell('CLIENT ▽', isMobile: isMobile),
                            _buildTableHeaderCell('DUE DATE ▽', isMobile: isMobile),
                            _buildTableHeaderCell('AMOUNT ▽', isMobile: isMobile),
                            _buildTableHeaderCell('STATUS ▽', isMobile: isMobile),
                            _buildTableHeaderCell('ACTIONS', alignment: Alignment.centerRight, isMobile: isMobile),
                          ],
                        ),
                        ...filtered.map((inv) {
                          final isEInv = inv['hasEInvoice'] == true;
                          return TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            children: [
                              _buildTableCell(
                                Row(
                                  children: [
                                    Container(
                                      width: isMobile ? 24 : 28,
                                      height: isMobile ? 24 : 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1F2),
                                        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                                      ),
                                      child: Center(
                                        child: Icon(LucideIcons.fileText, color: const Color(0xFFE11D48), size: isMobile ? 12 : 14),
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 6 : 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            inv['id'] ?? 'POS-239759',
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12 : 13, color: const Color(0xFF0F172A)),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 6, vertical: isMobile ? 1.5 : 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              inv['tag'] ?? 'Billed in POS',
                                              style: TextStyle(fontSize: isMobile ? 8 : 9, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5)),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      inv['client'] ?? '',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12 : 13, color: const Color(0xFF0F172A)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    if (inv['email'] != null && (inv['email'] as String).isNotEmpty)
                                      Text(
                                        inv['email'] as String,
                                        style: TextStyle(fontSize: isMobile ? 10 : 11, color: const Color(0xFF64748B)),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    Text(
                                      inv['subClient'] ?? '',
                                      style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.calendar, size: isMobile ? 11 : 13, color: const Color(0xFF94A3B8)),
                                      SizedBox(width: isMobile ? 4 : 6),
                                      Text(
                                        inv['dueDate'] ?? '',
                                        style: TextStyle(fontSize: isMobile ? 11 : 12.5, color: const Color(0xFF334155), fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    inv['amount'] ?? '',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12 : 13.5, color: const Color(0xFF0F172A)),
                                  ),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0E7FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        inv['status'] ?? 'POS BILLED PRODUCT',
                                        style: TextStyle(fontSize: isMobile ? 8.5 : 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF3730A3)),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          inv['hasEInvoice'] = true;
                                        });
                                        AppSnackbar.show(
                                          context,
                                          "Government e-Invoice generated for ${inv['id']}! IRN acknowledged.",
                                          type: SnackType.success,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 3),
                                        decoration: BoxDecoration(
                                          color: isEInv ? const Color(0xFFDCFCE7) : const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isEInv ? const Color(0xFF16A34A) : const Color(0xFFA7F3D0),
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isEInv ? LucideIcons.check : LucideIcons.sparkles,
                                                size: isMobile ? 10 : 11,
                                                color: const Color(0xFF059669),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isEInv ? 'IRN Verified' : '+ Generate E-Invoice',
                                                style: TextStyle(
                                                  fontSize: isMobile ? 8.5 : 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF059669),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildActionIconButton(
                                        icon: LucideIcons.history,
                                        tooltip: 'Audit Log',
                                        isCompact: isMobile,
                                        onTap: () => _showAuditLogDialog(inv['id']),
                                      ),
                                      SizedBox(width: isMobile ? 2 : 3),
                                      _buildActionIconButton(
                                        icon: LucideIcons.share2,
                                        tooltip: 'Share',
                                        isCompact: isMobile,
                                        onTap: () => AppSnackbar.show(context, 'Public billing share link copied to clipboard.', type: SnackType.info),
                                      ),
                                      SizedBox(width: isMobile ? 2 : 3),
                                      _buildActionIconButton(
                                        icon: LucideIcons.printer,
                                        tooltip: 'Print Invoice',
                                        isCompact: isMobile,
                                        onTap: () => AppSnackbar.show(context, 'Sent ${inv['id']} to thermal printer queue.', type: SnackType.success),
                                      ),
                                      SizedBox(width: isMobile ? 2 : 3),
                                      _buildActionIconButton(
                                        icon: LucideIcons.edit3,
                                        tooltip: 'Edit',
                                        isCompact: isMobile,
                                        onTap: () => _showEditInvoiceDialog(inv),
                                      ),
                                      SizedBox(width: isMobile ? 2 : 3),
                                      _buildActionIconButton(
                                        icon: LucideIcons.trash2,
                                        tooltip: 'Delete',
                                        color: const Color(0xFFEF4444),
                                        isCompact: isMobile,
                                        onTap: () => _confirmDeleteInvoice(inv),
                                      ),
                                    ],
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                                isMobile: isMobile,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileOrdersCardList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Icon(LucideIcons.fileText, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text('No invoices match the search filter', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final inv = items[index];
        final isEInv = inv['hasEInvoice'] == true;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Invoice ID + Tag badge + Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.fileText, color: Color(0xFFE11D48), size: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              inv['id'] ?? 'POS-239759',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                inv['tag'] ?? 'Billed in POS',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                              ),
                            ),
                          ],
                        ),
                        if (inv['subClient'] != null && (inv['subClient'] as String).isNotEmpty)
                          Text(
                            inv['subClient'] as String,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    inv['amount'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Row 2: Client info + Due Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.user, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      inv['client'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF334155)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.calendar, size: 11, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    inv['dueDate'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (inv['email'] != null && (inv['email'] as String).isNotEmpty) ...[
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Text(
                    inv['email'] as String,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 8),

              // Row 3: Status badge & E-Invoice trigger
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      inv['status'] ?? 'POS BILLED PRODUCT',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF3730A3)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        inv['hasEInvoice'] = true;
                      });
                      AppSnackbar.show(
                        context,
                        "Government e-Invoice generated for ${inv['id']}! IRN acknowledged.",
                        type: SnackType.success,
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isEInv ? const Color(0xFFDCFCE7) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isEInv ? const Color(0xFF16A34A) : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEInv ? LucideIcons.check : LucideIcons.sparkles,
                            size: 11,
                            color: const Color(0xFF059669),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isEInv ? 'IRN Verified' : '+ Generate E-Invoice',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 6),

              // Row 4: Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionIconButton(
                    icon: LucideIcons.history,
                    tooltip: 'Audit Log',
                    isCompact: true,
                    onTap: () => _showAuditLogDialog(inv['id']),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIconButton(
                    icon: LucideIcons.share2,
                    tooltip: 'Share',
                    isCompact: true,
                    onTap: () => AppSnackbar.show(context, 'Public billing share link copied to clipboard.', type: SnackType.info),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIconButton(
                    icon: LucideIcons.printer,
                    tooltip: 'Print Invoice',
                    isCompact: true,
                    onTap: () => AppSnackbar.show(context, 'Sent ${inv['id']} to thermal printer queue.', type: SnackType.success),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIconButton(
                    icon: LucideIcons.edit3,
                    tooltip: 'Edit',
                    isCompact: true,
                    onTap: () => _showEditInvoiceDialog(inv),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIconButton(
                    icon: LucideIcons.trash2,
                    tooltip: 'Delete',
                    color: const Color(0xFFEF4444),
                    isCompact: true,
                    onTap: () => _confirmDeleteInvoice(inv),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. TAB 1: SALES RETURNS (CUSTOMERS) (Image 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSalesReturnsTab(bool isMobile) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _salesReturns.where((ret) {
      return query.isEmpty ||
          ret['ref'].toString().toLowerCase().contains(query) ||
          ret['client'].toString().toLowerCase().contains(query);
    }).toList();

    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    if (isMobile && !isMacOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(
            hintText: 'Search client or return ref #...',
            isMobile: isMobile,
            leftExtraAction: ElevatedButton.icon(
              onPressed: () => _openCreateSalesReturnModal(),
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text(
                'Create Sales Return',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileSalesReturnsCardList(filtered),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(
          hintText: 'Search client or invoice #...',
          isMobile: isMobile,
          leftExtraAction: ElevatedButton.icon(
            onPressed: () => _openCreateSalesReturnModal(),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text(
              'Create Sales Return',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
            boxShadow: const [],
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = isMobile
                    ? math.max(constraints.maxWidth, 660.0)
                    : math.max(constraints.maxWidth, 1060.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: isMobile
                          ? const {
                              0: FlexColumnWidth(1.8), // RETURN REF #
                              1: FlexColumnWidth(2.0), // CUSTOMER / CLIENT
                              2: FlexColumnWidth(1.8), // ORIGINAL INVOICE
                              3: FlexColumnWidth(1.4), // RETURN DATE
                              4: FlexColumnWidth(1.4), // AMOUNT
                              5: FlexColumnWidth(2.0), // STATUS
                              6: FixedColumnWidth(100), // ACTIONS
                            }
                          : const {
                              0: FlexColumnWidth(2.0), // RETURN REF #
                              1: FlexColumnWidth(2.4), // CUSTOMER / CLIENT
                              2: FlexColumnWidth(2.0), // ORIGINAL INVOICE
                              3: FlexColumnWidth(1.6), // RETURN DATE
                              4: FlexColumnWidth(1.6), // AMOUNT
                              5: FlexColumnWidth(2.6), // STATUS
                              6: FixedColumnWidth(155), // ACTIONS
                            },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0)),
                          ),
                          children: [
                            _buildTableHeaderCell('RETURN REF # ▽', isMobile: isMobile),
                            _buildTableHeaderCell('CUSTOMER / CLIENT ▽', isMobile: isMobile),
                            _buildTableHeaderCell('ORIGINAL INVOICE ▽', isMobile: isMobile),
                            _buildTableHeaderCell('RETURN DATE ▽', isMobile: isMobile),
                            _buildTableHeaderCell('AMOUNT ▽', isMobile: isMobile),
                            _buildTableHeaderCell('STATUS ▽', isMobile: isMobile),
                            _buildTableHeaderCell('ACTIONS', alignment: Alignment.centerRight, isMobile: isMobile),
                          ],
                        ),
                        ...filtered.map((ret) {
                          final isPending = ret['status'] == 'PENDING';
                          return TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            children: [
                              _buildTableCell(
                                Text(
                                  ret['ref'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: isMobile ? 12 : 13.5,
                                    color: const Color(0xFFBE123C),
                                  ),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  ret['client'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 12 : 13, color: const Color(0xFF0F172A)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  ret['origInvoice'] ?? '',
                                  style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF475569), fontWeight: FontWeight.w500),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  ret['date'] ?? '',
                                  style: TextStyle(fontSize: isMobile ? 11 : 12.5, color: const Color(0xFF475569)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  ret['amount'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12 : 13.5, color: const Color(0xFF0F172A)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 3),
                                      decoration: BoxDecoration(
                                        color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ret['status'] ?? '',
                                        style: TextStyle(
                                          fontSize: isMobile ? 8.5 : 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: isPending ? const Color(0xFFB45309) : const Color(0xFF15803D),
                                        ),
                                      ),
                                    ),
                                    if (ret['godown'] != null && (ret['godown'] as String).isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 7, vertical: isMobile ? 1.5 : 2.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: const Color(0xFFA7F3D0)),
                                        ),
                                        child: ClipRect(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(LucideIcons.warehouse, size: isMobile ? 9 : 10, color: const Color(0xFF15803D)),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  ret['godown'] as String,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 8 : 9,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF15803D),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                    onPressed: () => _showReturnDetailsDialog(ret),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 14, vertical: isMobile ? 4 : 8),
                                    ),
                                    child: Text(
                                      'View Details',
                                      style: TextStyle(fontSize: isMobile ? 10 : 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                                    ),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                                isMobile: isMobile,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSalesReturnsCardList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Icon(LucideIcons.cornerDownLeft, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text('No sales returns found', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final ret = items[index];
        final isPending = ret['status'] == 'PENDING';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Ref # + Status + Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ret['ref'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Color(0xFFBE123C),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Orig: ${ret['origInvoice'] ?? ''}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ret['amount'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          ret['status'] ?? '',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isPending ? const Color(0xFFB45309) : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Middle Row: Customer + Date
              Row(
                children: [
                  const Icon(LucideIcons.user, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ret['client'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF0F172A)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.calendar, size: 11, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    ret['date'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              if (ret['godown'] != null && (ret['godown'] as String).isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.warehouse, size: 10, color: Color(0xFF15803D)),
                      const SizedBox(width: 4),
                      Text(
                        ret['godown'] as String,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _showReturnDetailsDialog(ret),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 6. TAB 2: WARRANTY & REPLACEMENT CLAIMS (Image 3)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWarrantyClaimsTab(bool isMobile) {
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _warrantyClaims.where((clm) {
      return query.isEmpty ||
          clm['ref'].toString().toLowerCase().contains(query) ||
          clm['product'].toString().toLowerCase().contains(query) ||
          clm['client'].toString().toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(
          hintText: 'Search client or invoice #...',
          isMobile: isMobile,
          leftExtraAction: ElevatedButton.icon(
            onPressed: () => _openLogWarrantyClaimModal(),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text(
              'Log Warranty Claim',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (isMobile && !isMacOS)
          _buildMobileWarrantyClaimsCardList(filtered)
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
              boxShadow: const [],
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = isMobile
                      ? math.max(constraints.maxWidth, 720.0)
                      : math.max(constraints.maxWidth, 1100.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: isMobile
                          ? const {
                              0: FlexColumnWidth(1.6), // CLAIM REF #
                              1: FlexColumnWidth(1.6), // PRODUCT / ITEM
                              2: FlexColumnWidth(1.8), // CUSTOMER / SUPPLIER
                              3: FlexColumnWidth(1.2), // SERIAL / IMEI
                              4: FlexColumnWidth(1.6), // CLAIM TYPE
                              5: FlexColumnWidth(2.0), // STATUS
                              6: FlexColumnWidth(1.2), // PERIOD
                              7: FixedColumnWidth(105), // ACTIONS
                            }
                          : const {
                              0: FlexColumnWidth(1.8), // CLAIM REF #
                              1: FlexColumnWidth(1.8), // PRODUCT / ITEM
                              2: FlexColumnWidth(2.2), // CUSTOMER / SUPPLIER
                              3: FlexColumnWidth(1.3), // SERIAL / IMEI
                              4: FlexColumnWidth(1.8), // CLAIM TYPE
                              5: FlexColumnWidth(2.6), // STATUS
                              6: FlexColumnWidth(1.4), // PERIOD
                              7: FixedColumnWidth(155), // ACTIONS
                            },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          children: [
                            _buildTableHeaderCell('CLAIM REF # ▽', isMobile: isMobile),
                            _buildTableHeaderCell('PRODUCT / ITEM ▽', isMobile: isMobile),
                            _buildTableHeaderCell('CUSTOMER / SUPPLIER ▽', isMobile: isMobile),
                            _buildTableHeaderCell('SERIAL / IMEI ▽', isMobile: isMobile),
                            _buildTableHeaderCell('CLAIM TYPE ▽', isMobile: isMobile),
                            _buildTableHeaderCell('STATUS ▽', isMobile: isMobile),
                            _buildTableHeaderCell('PERIOD ▽', isMobile: isMobile),
                            _buildTableHeaderCell('ACTIONS', alignment: Alignment.centerRight, isMobile: isMobile),
                          ],
                        ),
                        ...filtered.map((clm) {
                          final isGreenRef = clm['isGreenRef'] == true;
                          final status = clm['status'] as String;

                          Color statusBg = const Color(0xFFDCFCE7);
                          Color statusFg = const Color(0xFF15803D);
                          if (status == 'PENDING') {
                            statusBg = const Color(0xFFFEF3C7);
                            statusFg = const Color(0xFFB45309);
                          } else if (status == 'DONE') {
                            statusBg = const Color(0xFFCCFBF1);
                            statusFg = const Color(0xFF0F766E);
                          }

                          return TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            children: [
                              _buildTableCell(
                                Text(
                                  clm['ref'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: isMobile ? 12 : 13.5,
                                    color: isGreenRef ? const Color(0xFF059669) : const Color(0xFFBE123C),
                                  ),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  clm['product'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12 : 13, color: const Color(0xFF0F172A)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  clm['client'] ?? '',
                                  style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF334155), fontWeight: FontWeight.w600),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  clm['serial'] ?? 'N/A',
                                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFF64748B)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  clm['claimType'] ?? 'Warranty Tracking',
                                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFF475569)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 3),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(fontSize: isMobile ? 8.5 : 9.5, fontWeight: FontWeight.w800, color: statusFg),
                                      ),
                                    ),
                                    if (clm['godown'] != null && (clm['godown'] as String).isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 7, vertical: isMobile ? 1.5 : 2.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: const Color(0xFFA7F3D0)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(LucideIcons.warehouse, size: isMobile ? 9 : 10, color: const Color(0xFF15803D)),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                clm['godown'] as String,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: isMobile ? 8 : 9,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF15803D),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  clm['period'] ?? '3 Years',
                                  style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF475569)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      if (status == 'ACTIVE') {
                                        _showWarrantyDetailDialog(clm);
                                      } else {
                                        _showMoveReturnedProductsDialog(clm);
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 14, vertical: isMobile ? 4 : 8),
                                    ),
                                    child: Text(
                                      status == 'ACTIVE' ? 'View Detail' : 'Manage Claim',
                                      style: TextStyle(fontSize: isMobile ? 10 : 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                                    ),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                                isMobile: isMobile,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileWarrantyClaimsCardList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: const [
            Icon(LucideIcons.shieldAlert, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'No warranty claims found',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final clm = items[index];
        final isGreenRef = clm['isGreenRef'] == true;
        final status = (clm['status'] as String?) ?? 'PENDING';

        Color statusBg = const Color(0xFFDCFCE7);
        Color statusFg = const Color(0xFF15803D);
        if (status == 'PENDING') {
          statusBg = const Color(0xFFFEF3C7);
          statusFg = const Color(0xFFB45309);
        } else if (status == 'DONE') {
          statusBg = const Color(0xFFCCFBF1);
          statusFg = const Color(0xFF0F766E);
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Claim Ref # and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      clm['ref'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isGreenRef ? const Color(0xFF059669) : const Color(0xFFBE123C),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: statusFg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Product / Item name
              Text(
                clm['product'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),

              // Customer / Client
              Row(
                children: [
                  const Icon(LucideIcons.user, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      clm['client'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Metadata wrap
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (clm['serial'] != null && clm['serial'].toString().isNotEmpty)
                    Text(
                      'S/N: ${clm['serial']}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  Text(
                    'Type: ${clm['claimType'] ?? 'Warranty Tracking'}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  Text(
                    'Period: ${clm['period'] ?? '3 Years'}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),

              // Godown tag if present
              if (clm['godown'] != null && (clm['godown'] as String).isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.warehouse, size: 10, color: Color(0xFF15803D)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          clm['godown'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () {
                    if (status == 'ACTIVE') {
                      _showWarrantyDetailDialog(clm);
                    } else {
                      _showMoveReturnedProductsDialog(clm);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  ),
                  child: Text(
                    status == 'ACTIVE' ? 'View Detail' : 'Manage Claim',
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

  // ═══════════════════════════════════════════════════════════════
  // 7. TAB 3: DELIVERY CHALLAN (Images 4 & 5)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDeliveryChallanTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 Delivery Metric Cards
        _buildDeliveryMetricCards(isMobile),
        const SizedBox(height: 20),

        // Sub Navigation Tabs
        _buildDeliverySubTabs(isMobile),
        const SizedBox(height: 18),

        // SUB-TAB CONTENT
        if (_activeDeliverySubTab == 0) ...[
          // Sub-Tab 0: Shipments & Real-Time Status (Image 4)
          _buildDeliverySearchBar(isMobile),
          const SizedBox(height: 16),
          ...List.generate(_deliveries.length, (idx) {
            final del = _deliveries[idx];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildShipmentCard(del, isMobile),
            );
          }),
        ] else if (_activeDeliverySubTab == 1) ...[
          // Sub-Tab 1: Delivery Challans Table (Image 5)
          _buildDeliveryChallansTable(isMobile),
        ] else if (_activeDeliverySubTab == 2) ...[
          // Sub-Tab 2: Driver Performance
          _buildDriverPerformanceView(isMobile),
        ] else ...[
          // Sub-Tab 3: Reverse Logistics
          _buildReverseLogisticsView(isMobile),
        ],
      ],
    );
  }

  Widget _buildDeliveryMetricCards(bool isMobile) {
    final c1 = _buildDeliveryStatCard(
      label: 'DELIVERY SUCCESS RATE',
      value: '25%',
      icon: LucideIcons.award,
      iconColor: const Color(0xFF166534),
      iconBg: const Color(0xFFDCFCE7),
      isMobile: isMobile,
    );

    final c2 = _buildDeliveryStatCard(
      label: 'AVG DELIVERY SPEED',
      value: '52 mins',
      icon: LucideIcons.clock,
      iconColor: const Color(0xFF0D9488),
      iconBg: const Color(0xFFCCFBF1),
      isMobile: isMobile,
    );

    final c3 = _buildDeliveryStatCard(
      label: 'FAILED ATTEMPTS',
      value: '1',
      icon: LucideIcons.alertCircle,
      iconColor: const Color(0xFFDC2626),
      iconBg: const Color(0xFFFEE2E2),
      isMobile: isMobile,
    );

    final c4 = _buildDeliveryStatCard(
      label: 'ONGOING SHIPMENTS',
      value: '2',
      icon: LucideIcons.activity,
      iconColor: const Color(0xFF2563EB),
      iconBg: const Color(0xFFDBEAFE),
      isMobile: isMobile,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1050) {
          return Row(
            children: [
              Expanded(child: c1),
              const SizedBox(width: 14),
              Expanded(child: c2),
              const SizedBox(width: 14),
              Expanded(child: c3),
              const SizedBox(width: 14),
              Expanded(child: c4),
            ],
          );
        } else if (constraints.maxWidth >= 600) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: c1),
                  const SizedBox(width: 12),
                  Expanded(child: c2),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: c3),
                  const SizedBox(width: 12),
                  Expanded(child: c4),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: c1),
                  const SizedBox(width: 10),
                  Expanded(child: c2),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: c3),
                  const SizedBox(width: 10),
                  Expanded(child: c4),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDeliveryStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool isMobile = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 30 : 34,
            height: isMobile ? 30 : 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: isMobile ? 16 : 18),
            ),
          ),
          SizedBox(height: isMobile ? 10 : 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySubTabs(bool isMobile) {
    final subTabs = [
      {'title': 'Shipments & Real-Time Status', 'icon': '📦'},
      {'title': 'Delivery Challans', 'icon': '📄'},
      {'title': 'Delivery Staff & Driver Performance', 'icon': '👨‍💼'},
      {'title': 'Reverse Logistics (Returns)', 'icon': '🔄'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(subTabs.length, (idx) {
          final isSel = _activeDeliverySubTab == idx;
          final item = subTabs[idx];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _activeDeliverySubTab = idx),
              child: AnimatedContainer(
                duration: Theme.of(context).platform == TargetPlatform.macOS ? Duration.zero : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 10,
                  vertical: isMobile ? 6 : 6,
                ),
                decoration: BoxDecoration(
                  color: isMobile
                      ? (isSel ? const Color(0xFF166534) : Colors.white)
                      : Colors.transparent,
                  border: isMobile
                      ? Border.all(
                          color: isSel ? const Color(0xFF166534) : const Color(0xFFE5E7EB),
                        )
                      : (isSel
                          ? Border.all(color: const Color(0xFF0284C7), width: 1.5)
                          : Border.all(color: Colors.transparent, width: 1.5)),
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 6),
                  boxShadow: (isMobile && isSel)
                      ? [
                          BoxShadow(
                            color: const Color(0xFF166534).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      item['title']!,
                      style: TextStyle(
                        fontSize: isMobile ? 11.5 : 13,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        color: isMobile
                            ? (isSel ? Colors.white : const Color(0xFF374151))
                            : (isSel ? const Color(0xFF0284C7) : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Sub-Tab 1: Delivery Challans Table (Image 5) ───
  Widget _buildDeliveryChallansTable(bool isMobile) {
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    final titleWidget = Row(
      children: const [
        Text('📄', style: TextStyle(fontSize: 16)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Generated Delivery Challans (Product Dispatches)',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final newChallanBtn = ElevatedButton.icon(
      onPressed: () => _openDispatchShipmentModal(),
      icon: const Icon(LucideIcons.plus, size: 13),
      label: const Text('New Challan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleWidget,
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: newChallanBtn,
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('📄', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Generated Delivery Challans (Product Dispatches)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              newChallanBtn,
            ],
          ),
        const SizedBox(height: 14),

        if (isMobile && !isMacOS)
          _buildMobileDeliveryChallansCardList(_generatedChallans)
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
              boxShadow: const [],
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = isMobile
                      ? math.max(constraints.maxWidth, 680.0)
                      : math.max(constraints.maxWidth, 1060.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: isMobile
                          ? const {
                              0: FlexColumnWidth(1.8), // CHALLAN NO #
                              1: FlexColumnWidth(2.0), // CUSTOMER / CLIENT
                              2: FlexColumnWidth(1.6), // LINKED INVOICE
                              3: FlexColumnWidth(1.3), // CHALLAN TYPE
                              4: FlexColumnWidth(1.4), // CHALLAN DATE
                              5: FlexColumnWidth(1.6), // STATUS
                              6: FixedColumnWidth(100), // ACTIONS
                            }
                          : const {
                              0: FlexColumnWidth(2.0), // CHALLAN NO #
                              1: FlexColumnWidth(2.4), // CUSTOMER / CLIENT
                              2: FlexColumnWidth(1.8), // LINKED INVOICE
                              3: FlexColumnWidth(1.5), // CHALLAN TYPE
                              4: FlexColumnWidth(1.6), // CHALLAN DATE
                              5: FlexColumnWidth(1.8), // STATUS
                              6: FixedColumnWidth(155), // ACTIONS
                            },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          children: [
                            _buildTableHeaderCell('CHALLAN NO # ▽', isMobile: isMobile),
                            _buildTableHeaderCell('CUSTOMER / CLIENT ▽', isMobile: isMobile),
                            _buildTableHeaderCell('LINKED INVOICE ▽', isMobile: isMobile),
                            _buildTableHeaderCell('CHALLAN TYPE ▽', isMobile: isMobile),
                            _buildTableHeaderCell('CHALLAN DATE ▽', isMobile: isMobile),
                            _buildTableHeaderCell('STATUS ▽', isMobile: isMobile),
                            _buildTableHeaderCell('ACTIONS', alignment: Alignment.centerRight, isMobile: isMobile),
                          ],
                        ),
                        ..._generatedChallans.map((ch) {
                          final status = ch['status'] as String;
                          Color statusBg = const Color(0xFFFEF3C7);
                          Color statusFg = const Color(0xFFB45309);

                          if (status == 'DELIVERED') {
                            statusBg = const Color(0xFFDCFCE7);
                            statusFg = const Color(0xFF15803D);
                          } else if (status == 'FAILED ATTEMPT') {
                            statusBg = const Color(0xFFFEE2E2);
                            statusFg = const Color(0xFFDC2626);
                          }

                          final isGst = ch['type'] == 'GST';

                          return TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            children: [
                              _buildTableCell(
                                Text(
                                  ch['challanNo'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12 : 13, color: const Color(0xFF0284C7)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  ch['client'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12 : 13, color: const Color(0xFF0F172A)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  ch['invoice'] ?? '',
                                  style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF475569)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 3),
                                  decoration: BoxDecoration(
                                    color: isGst ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ch['type'] ?? '',
                                    style: TextStyle(
                                      fontSize: isMobile ? 8.5 : 10,
                                      fontWeight: FontWeight.w800,
                                      color: isGst ? const Color(0xFF0284C7) : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Text(
                                  ch['date'] ?? '',
                                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFF64748B)),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 3),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(fontSize: isMobile ? 8.5 : 9.5, fontWeight: FontWeight.w800, color: statusFg),
                                  ),
                                ),
                                isMobile: isMobile,
                              ),
                              _buildTableCell(
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: Text('Challan Details: ${ch['challanNo']}'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Customer: ${ch['client']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text('Linked Invoice: ${ch['invoice']}'),
                                              Text('Challan Type: ${ch['type']}'),
                                              Text('Challan Date: ${ch['date']}'),
                                              Text('Current Status: ${ch['status']}'),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                                          ],
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 14, vertical: isMobile ? 4 : 8),
                                    ),
                                    child: Text('View Details', style: TextStyle(fontSize: isMobile ? 10 : 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                                isMobile: isMobile,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDeliveryChallansCardList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: const [
            Icon(LucideIcons.fileText, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'No delivery challans found',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final ch = items[index];
        final status = (ch['status'] as String?) ?? 'IN TRANSIT';
        Color statusBg = const Color(0xFFFEF3C7);
        Color statusFg = const Color(0xFFB45309);

        if (status == 'DELIVERED') {
          statusBg = const Color(0xFFDCFCE7);
          statusFg = const Color(0xFF15803D);
        } else if (status == 'FAILED ATTEMPT') {
          statusBg = const Color(0xFFFEE2E2);
          statusFg = const Color(0xFFDC2626);
        }

        final isGst = ch['type'] == 'GST';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Challan No, Type, Status
              Row(
                children: [
                  Flexible(
                    child: Text(
                      ch['challanNo'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF0284C7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isGst ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      ch['type'] ?? '',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isGst ? const Color(0xFF0284C7) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: statusFg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Customer / Client name
              Text(
                ch['client'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),

              // Linked Invoice & Date
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (ch['invoice'] != null && ch['invoice'].toString().isNotEmpty)
                    Text(
                      'Invoice: ${ch['invoice']}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                    ),
                  if (ch['date'] != null && ch['date'].toString().isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendar, size: 11, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          ch['date'] ?? '',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Challan Details: ${ch['challanNo']}'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: ${ch['client']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Linked Invoice: ${ch['invoice']}'),
                            Text('Challan Type: ${ch['type']}'),
                            Text('Challan Date: ${ch['date']}'),
                            Text('Current Status: ${ch['status']}'),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Sub-Tab 2: Driver Performance (Image 1) ───
  Widget _buildDriverPerformanceView(bool isMobile) {
    final card1 = _buildDriverCard(
      name: 'Satish Yadav',
      id: 'ID: STF-05',
      status: 'On Delivery',
      statusBg: const Color(0xFFE0F2FE),
      statusFg: const Color(0xFF0284C7),
      vehicle: 'MH-12-QB-8821',
      mobile: '+91 98234 56789',
      speed: '48 mins',
      rate: 96,
      isMobile: isMobile,
    );

    final card2 = _buildDriverCard(
      name: 'Rajesh Patil',
      id: 'ID: STF-02',
      status: 'Available',
      statusBg: const Color(0xFFDCFCE7),
      statusFg: const Color(0xFF16A34A),
      vehicle: 'MH-14-EU-4592',
      mobile: '+91 91234 56711',
      speed: '42 mins',
      rate: 98,
      isMobile: isMobile,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('👨‍💼', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delivery Staff Performance & Fleet Assignments',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF166534),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 720) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: card1),
                    const SizedBox(width: 16),
                    Expanded(child: card2),
                  ],
                );
              }
              return Column(
                children: [
                  card1,
                  const SizedBox(height: 14),
                  card2,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard({
    required String name,
    required String id,
    required String status,
    required Color statusBg,
    required Color statusFg,
    required String vehicle,
    required String mobile,
    required String speed,
    required int rate,
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      id,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusFg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _driverDetailRow('Vehicle: ', vehicle),
          const SizedBox(height: 5),
          _driverDetailRow('Mobile: ', mobile),
          const SizedBox(height: 5),
          _driverDetailRow('Avg Delivery Speed: ', speed),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Delivery Success Rate',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF166534),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$rate%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate / 100.0,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF166534)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _driverDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  // ─── Sub-Tab 3: Reverse Logistics (Image 2) ───
  Widget _buildReverseLogisticsView(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🔄', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reverse Logistics (Return pick-ups & Failures)',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF166534),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFEE2E8)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 650;

                final leftInfo = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        const Text(
                          'Rahul Varma',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Failed Attempt',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
                        children: [
                          TextSpan(text: 'Ref: CLIKS/DEL/26/103 • Destination: Pune • Reason: '),
                          TextSpan(
                            text: 'Customer out of town / Premises locked',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final actionBtn = OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Reschedule Pickup: CLIKS/DEL/26/103'),
                        content: const Text('Confirm new pickup date for Rahul Varma? Driver will be notified.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              AppSnackbar.show(context, 'Pickup rescheduled for tomorrow 10:00 AM.', type: SnackType.success);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
                            child: const Text('Confirm Reschedule'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE11D48)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'Reschedule Pickup',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leftInfo,
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: actionBtn,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: leftInfo),
                    const SizedBox(width: 16),
                    actionBtn,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySearchBar(bool isMobile) {
    final searchField = SizedBox(
      height: 42,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 12.5),
        decoration: InputDecoration(
          hintText: 'Search deliveries by customer name, order number, city, or driver...',
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
          ),
        ),
      ),
    );

    Widget buildStatusDropdown({bool expanded = false}) {
      return Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: expanded,
            value: _selectedStatus == 'All Status' ? 'All Statuses' : _selectedStatus,
            icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            items: const [
              DropdownMenuItem(value: 'All Statuses', child: Text('Status: All Statuses')),
              DropdownMenuItem(value: 'Out For Delivery', child: Text('Status: Out For Delivery')),
              DropdownMenuItem(value: 'Delivered', child: Text('Status: Delivered')),
            ],
            onChanged: (v) {
              setState(() {
                _selectedStatus = v == 'All Statuses' ? 'All Status' : (v ?? 'All Status');
              });
            },
          ),
        ),
      );
    }

    final dispatchBtn = ElevatedButton.icon(
      onPressed: () => _openDispatchShipmentModal(),
      icon: const Icon(LucideIcons.plus, size: 14),
      label: const Text(
        'Dispatch Shipment',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 8),
          buildStatusDropdown(expanded: true),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: dispatchBtn,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 12),
        buildStatusDropdown(expanded: false),
        const SizedBox(width: 12),
        dispatchBtn,
      ],
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> del, bool isMobile) {
    final isDelivered = del['isDelivered'] == true;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;

          final mainInfo = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDelivered ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.truck,
                    color: isDelivered ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            del['recipient'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDelivered ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            del['status'] ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDelivered ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
                        children: [
                          TextSpan(text: 'Ref: ${del['ref']} • City: ${del['city']} • Courier: ${del['courier']} • Tracking: '),
                          TextSpan(
                            text: del['tracking'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final driverInfo = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Assigned Driver',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    del['driver'] ?? '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    del['vehicle'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              OutlinedButton(
                onPressed: () => _openChallanConfirmModal(del),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF166534), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: const Text(
                  'Challan & Confirm',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                ),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mainInfo,
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assigned Driver', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text(del['driver'] ?? '', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        Text(del['vehicle'] ?? '', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () => _openChallanConfirmModal(del),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF166534)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Challan & Confirm', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: mainInfo),
              const SizedBox(width: 20),
              driverInfo,
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SHARED FILTER BAR WIDGET
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFilterBar({
    required String hintText,
    required bool isMobile,
    Widget? extraAction,
    Widget? leftExtraAction,
  }) {
    final searchInput = SizedBox(
      height: isMobile ? 36 : 40,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(fontSize: isMobile ? 12 : 12.5),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: isMobile ? 11 : 12, color: const Color(0xFF94A3B8)),
          prefixIcon: Icon(LucideIcons.search, size: isMobile ? 14 : 16, color: const Color(0xFF94A3B8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 6 : 10),
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

    final dateWidget = InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (d != null) {
          setState(() => _selectedDate = d);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: isMobile ? 36 : 40,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedDate != null
                  ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
                  : 'dd/mm/yyyy',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: _selectedDate != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Icon(LucideIcons.calendar, size: isMobile ? 13 : 14, color: const Color(0xFF64748B)),
          ],
        ),
      ),
    );

    final statusDropdown = Container(
      height: isMobile ? 36 : 40,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          icon: Icon(LucideIcons.chevronDown, size: isMobile ? 13 : 14, color: const Color(0xFF64748B)),
          style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
          items: const [
            DropdownMenuItem(value: 'All Status', child: Text('All Status')),
            DropdownMenuItem(value: 'Paid', child: Text('Paid')),
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            DropdownMenuItem(value: 'POS Billed', child: Text('POS Billed')),
          ],
          onChanged: (v) {
            setState(() {
              _selectedStatus = v ?? 'All Status';
            });
          },
        ),
      ),
    );

    final funnelBtn = Container(
      height: isMobile ? 36 : 40,
      width: isMobile ? 36 : 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(LucideIcons.filter, size: isMobile ? 14 : 15, color: const Color(0xFF64748B)),
        onPressed: () {
          setState(() {
            _searchController.clear();
            _selectedDate = null;
            _selectedStatus = 'All Status';
          });
          AppSnackbar.show(context, 'Filters reset to default.', type: SnackType.info);
        },
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final needsWrap = isMobile || constraints.maxWidth < (leftExtraAction != null ? 820 : 660);
        if (needsWrap) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: searchInput),
                  if (leftExtraAction != null) ...[
                    const SizedBox(width: 8),
                    leftExtraAction,
                  ],
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    dateWidget,
                    const SizedBox(width: 8),
                    statusDropdown,
                    const SizedBox(width: 8),
                    funnelBtn,
                    if (extraAction != null) ...[
                      const SizedBox(width: 8),
                      extraAction,
                    ],
                  ],
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchInput),
            if (leftExtraAction != null) ...[
              const SizedBox(width: 12),
              leftExtraAction,
            ],
            const SizedBox(width: 12),
            dateWidget,
            const SizedBox(width: 10),
            statusDropdown,
            const SizedBox(width: 10),
            funnelBtn,
            if (extraAction != null) ...[
              const SizedBox(width: 12),
              extraAction,
            ],
          ],
        );
      },
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = const Color(0xFF64748B),
    bool isCompact = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isCompact ? 5 : 6),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 3.5 : 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(isCompact ? 5 : 6),
          ),
          child: Icon(icon, size: isCompact ? 11.5 : 13.5, color: color),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EXACT MODALS (Images 1, 2, 3, 4)
  // ═══════════════════════════════════════════════════════════════

  // ─── Modal 1: Log Warranty Claim (Image 1) ───
  void _openLogWarrantyClaimModal() {
    String selectedCustomer = '-- Select Customer --';
    String selectedProduct = '-- Select Warranty-Covered Product --';
    final serialController = TextEditingController();
    final returnAmountController = TextEditingController(text: '0.00');
    final reasonController = TextEditingController(text: 'Defective / Customer Return');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isMobile = MediaQuery.of(context).size.width < 600;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.shieldCheck, color: Color(0xFF059669), size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Log Warranty Claim',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Enter return or claim transaction details',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Customer Name *
                    _modalLabel('CUSTOMER NAME *'),
                    const SizedBox(height: 6),
                    _modalDropdown(
                      value: selectedCustomer,
                      items: const [
                        '-- Select Customer --',
                        'Walk-in Customer',
                        'sanjay123',
                        'Varshini',
                        'Customer',
                      ],
                      onChanged: (v) => setModalState(() => selectedCustomer = v!),
                    ),
                    const SizedBox(height: 14),

                    // Select Covered Product *
                    _modalLabel('SELECT COVERED PRODUCT *'),
                    const SizedBox(height: 6),
                    _modalDropdown(
                      value: selectedProduct,
                      items: const [
                        '-- Select Warranty-Covered Product --',
                        'VIVO V29 Pro 5G',
                        'VIVO Y200',
                        'PEN',
                        'Product',
                      ],
                      onChanged: (v) => setModalState(() => selectedProduct = v!),
                    ),
                    const SizedBox(height: 14),

                    // Serial / IMEI Number
                    _modalLabel('SERIAL / IMEI NUMBER'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: serialController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _modalInputDecoration(hint: 'e.g. POS-123456 / BILL-001'),
                    ),
                    const SizedBox(height: 14),

                    // Return Amount (₹) *
                    _modalLabel('RETURN AMOUNT (₹) *'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: returnAmountController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _modalInputDecoration(),
                    ),
                    const SizedBox(height: 14),

                    // Reason / Notes
                    _modalLabel('REASON / NOTES'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: _modalInputDecoration(),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedCustomer == '-- Select Customer --') {
                            AppSnackbar.show(context, 'Please select a customer.', type: SnackType.error);
                            return;
                          }
                          setState(() {
                            _warrantyClaims.insert(0, {
                              'ref': 'CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                              'product': selectedProduct == '-- Select Warranty-Covered Product --' ? 'Product' : selectedProduct,
                              'client': selectedCustomer,
                              'serial': serialController.text.trim().isEmpty ? 'N/A' : serialController.text.trim(),
                              'claimType': 'Warranty Tracking',
                              'status': 'ACTIVE',
                              'godown': '',
                              'period': '3 Years',
                              'isGreenRef': true,
                            });
                          });
                          Navigator.pop(ctx);
                          AppSnackbar.show(context, 'Warranty record submitted and saved successfully!', type: SnackType.success);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Submit & Save Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Modal 2: Create Sales Return (Image 2) ───
  void _openCreateSalesReturnModal() {
    String selectedCustomer = '-- Select Customer --';
    String selectedInvoice = '-- Select Customer First --';
    final returnAmountController = TextEditingController(text: '0.00');
    final reasonController = TextEditingController(text: 'Defective / Customer Return');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isMobile = MediaQuery.of(context).size.width < 600;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.rotateCcw, color: Color(0xFFE11D48), size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Create Sales Return',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Enter return or claim transaction details',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Customer Name *
                    _modalLabel('CUSTOMER NAME *'),
                    const SizedBox(height: 6),
                    _modalDropdown(
                      value: selectedCustomer,
                      items: const [
                        '-- Select Customer --',
                        'Varshini',
                        'Customer',
                        'Walk-in Customer',
                        'sanjay123',
                      ],
                      onChanged: (v) {
                        setModalState(() {
                          selectedCustomer = v!;
                          selectedInvoice = selectedCustomer == 'Varshini'
                              ? 'POS-239759'
                              : (selectedCustomer == '-- Select Customer --' ? '-- Select Customer First --' : 'POS / Direct');
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Invoice / Bill Number
                    _modalLabel('INVOICE / BILL NUMBER'),
                    const SizedBox(height: 6),
                    _modalDropdown(
                      value: selectedInvoice,
                      items: const [
                        '-- Select Customer First --',
                        'POS-239759',
                        'POS-239758',
                        'POS / Direct',
                      ],
                      onChanged: (v) => setModalState(() => selectedInvoice = v!),
                    ),
                    const SizedBox(height: 14),

                    // Return Amount (₹) *
                    _modalLabel('RETURN AMOUNT (₹) *'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: returnAmountController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _modalInputDecoration(),
                    ),
                    const SizedBox(height: 14),

                    // Reason / Notes
                    _modalLabel('REASON / NOTES'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: _modalInputDecoration(),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedCustomer == '-- Select Customer --') {
                            AppSnackbar.show(context, 'Please select a customer.', type: SnackType.error);
                            return;
                          }
                          final refId = 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                          setState(() {
                            _salesReturns.insert(0, {
                              'ref': refId,
                              'client': selectedCustomer,
                              'origInvoice': selectedInvoice == '-- Select Customer First --' ? 'POS / Direct' : selectedInvoice,
                              'date': '13/10/2026',
                              'amount': '₹${returnAmountController.text.trim()}',
                              'status': 'PENDING',
                              'godown': 'Assigned: Chennai godown',
                            });
                          });
                          Navigator.pop(ctx);
                          AppSnackbar.show(context, 'Sales return record $refId saved successfully!', type: SnackType.success);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Submit & Save Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Modal 3: Dispatch Shipment & Issue Challan (Images 3 & 4) ───
  void _openDispatchShipmentModal() {
    String selectedInvoice = '-- Choose Sales Invoice to Auto-populate Consignee & Items --';
    final refController = TextEditingController(text: 'CLIKS/DEL/26/105');
    final dateController = TextEditingController(text: '13/10/2026');
    String initialStatus = 'Packed';

    final receiverController = TextEditingController(text: 'Aman Deep');
    final cityController = TextEditingController(text: 'Pune');
    final pincodeController = TextEditingController(text: '411016');
    final addressController = TextEditingController();

    String selectedWarehouse = 'WH-MAIN-01 (Pune)';
    final packageCountController = TextEditingController(text: '1');
    final weightController = TextEditingController(text: '1');
    String challanType = 'GST Challan';
    final remarksController = TextEditingController();

    String selectedDriver = 'Select Internal Driver';
    final courierController = TextEditingController(text: 'CLIKS Logistics');
    final trackingController = TextEditingController(text: 'TRK972854173');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isMobile = MediaQuery.of(context).size.width < 700;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 36, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 740,
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Top Title Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 18, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.truck, color: Color(0xFF166534), size: 20),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Dispatch Shipment & Issue Challan',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Assign courier/driver, attach sales order, and initiate logistics transit',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Scrollable Form Cards
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── CARD 1: LINK SALES INVOICE & BASIC DETAILS ───
                            _buildModalSectionCard(
                              title: '📌 1. LINK SALES INVOICE & BASIC DETAILS',
                              trailingText: 'Quick auto-fill from current orders',
                              children: [
                                _modalLabel('Select Existing Invoice / Order (Optional)'),
                                const SizedBox(height: 6),
                                _modalDropdown(
                                  value: selectedInvoice,
                                  items: const [
                                    '-- Choose Sales Invoice to Auto-populate Consignee & Items --',
                                    'POS-239759 (Walk-in Customer)',
                                    'POS-239758 (sanjay123)',
                                  ],
                                  onChanged: (v) {
                                    setModalState(() {
                                      selectedInvoice = v!;
                                      if (selectedInvoice.contains('sanjay123')) {
                                        receiverController.text = 'sanjay123';
                                      } else if (selectedInvoice.contains('Walk-in')) {
                                        receiverController.text = 'Walk-in Customer';
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 14),
                                if (isMobile) ...[
                                  _modalLabel('Delivery Reference No *'),
                                  const SizedBox(height: 6),
                                  TextField(controller: refController, decoration: _modalInputDecoration()),
                                  const SizedBox(height: 12),
                                  _modalLabel('Dispatch Date *'),
                                  const SizedBox(height: 6),
                                  TextField(controller: dateController, decoration: _modalInputDecoration(suffixIcon: LucideIcons.calendar)),
                                  const SizedBox(height: 12),
                                  _modalLabel('Initial Status'),
                                  const SizedBox(height: 6),
                                  _modalDropdown(
                                    value: initialStatus,
                                    items: const ['Packed', 'Out For Delivery', 'In Transit'],
                                    onChanged: (v) => setModalState(() => initialStatus = v!),
                                  ),
                                ] else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Delivery Reference No *'),
                                            const SizedBox(height: 6),
                                            TextField(controller: refController, decoration: _modalInputDecoration()),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Dispatch Date *'),
                                            const SizedBox(height: 6),
                                            TextField(controller: dateController, decoration: _modalInputDecoration(suffixIcon: LucideIcons.calendar)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Initial Status'),
                                            const SizedBox(height: 6),
                                            _modalDropdown(
                                              value: initialStatus,
                                              items: const ['Packed', 'Out For Delivery', 'In Transit'],
                                              onChanged: (v) => setModalState(() => initialStatus = v!),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 18),

                            // ─── CARD 2: SHIPPING ADDRESS & RECEIVER ───
                            _buildModalSectionCard(
                              title: '📍 2. SHIPPING ADDRESS & RECEIVER',
                              children: [
                                if (isMobile) ...[
                                  _modalLabel('Receiver / Customer Name *'),
                                  const SizedBox(height: 6),
                                  TextField(controller: receiverController, decoration: _modalInputDecoration(hint: 'e.g. Aman Deep')),
                                  const SizedBox(height: 12),
                                  _modalLabel('City / Pincode *'),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(child: TextField(controller: cityController, decoration: _modalInputDecoration())),
                                      const SizedBox(width: 8),
                                      SizedBox(width: 100, child: TextField(controller: pincodeController, decoration: _modalInputDecoration())),
                                    ],
                                  ),
                                ] else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Receiver / Customer Name *'),
                                            const SizedBox(height: 6),
                                            TextField(controller: receiverController, decoration: _modalInputDecoration(hint: 'e.g. Aman Deep')),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('City / Pincode *'),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Expanded(child: TextField(controller: cityController, decoration: _modalInputDecoration())),
                                                const SizedBox(width: 8),
                                                SizedBox(width: 90, child: TextField(controller: pincodeController, decoration: _modalInputDecoration())),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 14),
                                _modalLabel('Full Shipping Address *'),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: addressController,
                                  decoration: _modalInputDecoration(hint: 'Flat / Office / Street address...'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // ─── CARD 3: PACKING & CHALLAN SPECS ───
                            _buildModalSectionCard(
                              title: '📦 3. PACKING & CHALLAN SPECS',
                              children: [
                                if (isMobile) ...[
                                  _modalLabel('Warehouse'),
                                  const SizedBox(height: 6),
                                  _modalDropdown(
                                    value: selectedWarehouse,
                                    items: const ['WH-MAIN-01 (Pune)', 'WH-CENTRAL-02', 'WH-CHENNAI-03'],
                                    onChanged: (v) => setModalState(() => selectedWarehouse = v!),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Package Count'),
                                            const SizedBox(height: 6),
                                            TextField(controller: packageCountController, decoration: _modalInputDecoration()),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Total Weight (Kg)'),
                                            const SizedBox(height: 6),
                                            TextField(controller: weightController, decoration: _modalInputDecoration()),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _modalLabel('Challan Type'),
                                  const SizedBox(height: 6),
                                  _modalDropdown(
                                    value: challanType,
                                    items: const ['GST Challan', 'Non-GST Challan'],
                                    onChanged: (v) => setModalState(() => challanType = v!),
                                  ),
                                ] else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Warehouse'),
                                            const SizedBox(height: 6),
                                            _modalDropdown(
                                              value: selectedWarehouse,
                                              items: const ['WH-MAIN-01 (Pune)', 'WH-CENTRAL-02', 'WH-CHENNAI-03'],
                                              onChanged: (v) => setModalState(() => selectedWarehouse = v!),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Package Count'),
                                            const SizedBox(height: 6),
                                            TextField(controller: packageCountController, decoration: _modalInputDecoration()),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Total Weight (Kg)'),
                                            const SizedBox(height: 6),
                                            TextField(controller: weightController, decoration: _modalInputDecoration()),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Challan Type'),
                                            const SizedBox(height: 6),
                                            _modalDropdown(
                                              value: challanType,
                                              items: const ['GST Challan', 'Non-GST Challan'],
                                              onChanged: (v) => setModalState(() => challanType = v!),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 14),
                                _modalLabel('Packaging Remarks'),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: remarksController,
                                  decoration: _modalInputDecoration(hint: 'Fragile items, urgent priority, delivery notes...'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // ─── CARD 4: FLEET & COURIER ASSIGNMENT ───
                            _buildModalSectionCard(
                              title: '🤠 4. FLEET & COURIER ASSIGNMENT',
                              children: [
                                if (isMobile) ...[
                                  _modalLabel('Internal Delivery Driver'),
                                  const SizedBox(height: 6),
                                  _modalDropdown(
                                    value: selectedDriver,
                                    items: const [
                                      'Select Internal Driver',
                                      'Satish Yadav (MH-12-QB-8821)',
                                      'Rajesh Patil (MH-14-EU-4592)',
                                      'Vikram Shinde (MH-01-AX-3211)',
                                    ],
                                    onChanged: (v) => setModalState(() => selectedDriver = v!),
                                  ),
                                  const SizedBox(height: 12),
                                  _modalLabel('Courier Company'),
                                  const SizedBox(height: 6),
                                  TextField(controller: courierController, decoration: _modalInputDecoration()),
                                  const SizedBox(height: 12),
                                  _modalLabel('Tracking Reference ID'),
                                  const SizedBox(height: 6),
                                  TextField(controller: trackingController, decoration: _modalInputDecoration()),
                                ] else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Internal Delivery Driver'),
                                            const SizedBox(height: 6),
                                            _modalDropdown(
                                              value: selectedDriver,
                                              items: const [
                                                'Select Internal Driver',
                                                'Satish Yadav (MH-12-QB-8821)',
                                                'Rajesh Patil (MH-14-EU-4592)',
                                                'Vikram Shinde (MH-01-AX-3211)',
                                              ],
                                              onChanged: (v) => setModalState(() => selectedDriver = v!),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Courier Company'),
                                            const SizedBox(height: 6),
                                            TextField(controller: courierController, decoration: _modalInputDecoration()),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _modalLabel('Tracking Reference ID'),
                                            const SizedBox(height: 6),
                                            TextField(controller: trackingController, decoration: _modalInputDecoration()),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (receiverController.text.trim().isEmpty) {
                                    AppSnackbar.show(context, 'Please enter recipient name.', type: SnackType.error);
                                    return;
                                  }
                                  final newRef = refController.text.trim();
                                  setState(() {
                                    _deliveries.insert(0, {
                                      'recipient': receiverController.text.trim(),
                                      'status': initialStatus,
                                      'ref': newRef,
                                      'city': cityController.text.trim(),
                                      'courier': courierController.text.trim(),
                                      'tracking': trackingController.text.trim(),
                                      'driver': selectedDriver == 'Select Internal Driver' ? 'Satish Yadav' : selectedDriver.split('(').first.trim(),
                                      'vehicle': 'MH-12-QB-8821',
                                      'isDelivered': initialStatus == 'Delivered',
                                    });

                                    _generatedChallans.insert(0, {
                                      'challanNo': 'CHL-2026-${4430 + _generatedChallans.length}',
                                      'client': receiverController.text.trim(),
                                      'invoice': selectedInvoice.contains('POS') ? selectedInvoice.split('(').first.trim() : 'INV-40310',
                                      'type': challanType.contains('Non-GST') ? 'Non-GST' : 'GST',
                                      'date': '2026-10-13',
                                      'status': initialStatus.toUpperCase(),
                                      'statusColor': initialStatus == 'Delivered' ? 'green' : 'amber',
                                    });
                                  });
                                  Navigator.pop(ctx);
                                  AppSnackbar.show(context, 'Delivery challan $newRef issued & dispatched successfully!', type: SnackType.success);
                                },
                                icon: const Icon(LucideIcons.truck, size: 16),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Generate Challan & Dispatch Shipment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF166534),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalSectionCard({
    required String title,
    String? trailingText,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: 0.3),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _modalLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF334155),
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _modalInputDecoration({String? hint, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 14, color: const Color(0xFF64748B)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
      ),
    );
  }

  Widget _modalDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : items.first,
          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // OTHER ROW ACTIONS
  // ═══════════════════════════════════════════════════════════════
  void _openChallanConfirmModal(Map<String, dynamic> del) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.truck, color: Color(0xFF166534), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Challan: ${del['ref']}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipient: ${del['recipient']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Destination: ${del['city']} (${del['courier']})'),
            Text('Driver: ${del['driver']} (${del['vehicle']})'),
            Text('Tracking: ${del['tracking']}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Verify recipient signature or digital OTP upon physical handover. Settle Challan status below.',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                del['status'] = 'Delivered';
                del['isDelivered'] = true;
              });
              Navigator.pop(ctx);
              AppSnackbar.show(context, 'Shipment ${del['ref']} confirmed as Delivered!', type: SnackType.success);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Delivered'),
          ),
        ],
      ),
    );
  }

  void _showReturnDetailsDialog(Map<String, dynamic> ret) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Return Manifest: ${ret['ref']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${ret['client']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Original Invoice: ${ret['origInvoice']}'),
            Text('Return Date: ${ret['date']}'),
            Text('Amount: ${ret['amount']}'),
            Text('Facility: ${ret['godown']}'),
            Text('Status: ${ret['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ─── Modal: Warranty Claim Details (Image 1) ───
  void _showWarrantyDetailDialog(Map<String, dynamic> clm) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.shieldCheck, color: Color(0xFF059669), size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Warranty Claim Details',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 3),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                children: [
                                  const TextSpan(text: 'Claim Ref: '),
                                  TextSpan(
                                    text: clm['ref'] ?? 'CLM-256942',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Purchase Date:', '09/09/2026', const Color(0xFF0F172A)),
                        const SizedBox(height: 12),
                        _buildDetailRow('Warranty Period:', clm['period'] ?? '3 Years', const Color(0xFF15803D)),
                        const SizedBox(height: 12),
                        _buildDetailRow('Warranty Progress:', '34 / 1095 days', const Color(0xFF0284C7)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor),
        ),
      ],
    );
  }

  // ─── Modal: Move Returned Products (Image 2) ───
  void _showMoveReturnedProductsDialog(Map<String, dynamic> clm) {
    String selectedWarehouse = '-- Select Registered Warehouse --';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isMobile = MediaQuery.of(context).size.width < 600;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.warehouse, color: Color(0xFF0284C7), size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Move Returned Products',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 3),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  children: [
                                    const TextSpan(text: 'Return Ref: '),
                                    TextSpan(
                                      text: clm['ref'] ?? 'RET-490845',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Product:', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              Text(clm['product'] ?? 'VIVO', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Returned Quantity:', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              Text('1', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _modalLabel('SELECT WAREHOUSE *'),
                    const SizedBox(height: 6),
                    _modalDropdown(
                      value: selectedWarehouse,
                      items: const [
                        '-- Select Registered Warehouse --',
                        'Chennai godown',
                        'Damaged products godown',
                        'Central godown',
                        'WH-MAIN-01 (Pune)',
                      ],
                      onChanged: (v) => setModalState(() => selectedWarehouse = v!),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedWarehouse == '-- Select Registered Warehouse --') {
                              AppSnackbar.show(context, 'Please select a warehouse facility.', type: SnackType.error);
                              return;
                            }
                            setState(() {
                              clm['godown'] = 'Assigned: $selectedWarehouse';
                              clm['status'] = 'DONE';
                            });
                            Navigator.pop(ctx);
                            AppSnackbar.show(context, 'Product moved to $selectedWarehouse successfully!', type: SnackType.success);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Move to Warehouse', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAuditLogDialog(String? id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Audit History ($id)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• 2026-10-12 14:22: POS Terminal Checkout by Cashier Admin'),
            SizedBox(height: 4),
            Text('• 2026-10-12 14:22: Inventory auto-decremented in Chennai godown'),
            SizedBox(height: 4),
            Text('• 2026-10-12 14:23: Cash Receipt logged into books ledger'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showEditInvoiceDialog(Map<String, dynamic> inv) {
    final clientCtrl = TextEditingController(text: inv['client']);
    final amountCtrl = TextEditingController(text: inv['amount']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Invoice ${inv['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _modalLabel('Client Name'),
                const SizedBox(height: 6),
                TextField(controller: clientCtrl, decoration: _modalInputDecoration()),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _modalLabel('Amount'),
                const SizedBox(height: 6),
                TextField(controller: amountCtrl, decoration: _modalInputDecoration()),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                inv['client'] = clientCtrl.text.trim();
                inv['amount'] = amountCtrl.text.trim();
              });
              Navigator.pop(ctx);
              AppSnackbar.show(context, 'Invoice updated.', type: SnackType.success);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteInvoice(Map<String, dynamic> inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Invoice?'),
        content: Text('Are you sure you want to delete invoice ${inv['id']}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _invoices.remove(inv);
              });
              Navigator.pop(ctx);
              AppSnackbar.show(context, 'Invoice ${inv['id']} deleted.', type: SnackType.info);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STICKY TAB NAV DELEGATE
// ═══════════════════════════════════════════════════════════════
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
