import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────

class _SupplierModel {
  String id;
  String name;
  String code;
  String contactPerson;
  String phone;
  String email;
  String gstin;
  String pan;
  double creditLimit;
  String paymentTerms;
  double runningPayable;
  bool isAdvance;
  String status;
  String statusSubtitle;
  bool isRegistered;
  double totalProcured;

  _SupplierModel({
    required this.id,
    required this.name,
    required this.code,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.gstin,
    required this.pan,
    this.creditLimit = 0.0,
    this.paymentTerms = 'Net 30',
    required this.runningPayable,
    this.isAdvance = false,
    this.status = 'CONNECTED',
    this.statusSubtitle = 'Connected on Website',
    this.isRegistered = true,
    this.totalProcured = 0.0,
  });
}

class _LedgerEntry {
  final String date;
  final String description;
  final double? debit;
  final double? credit;
  final double runningBalance;

  _LedgerEntry({
    required this.date,
    required this.description,
    this.debit,
    this.credit,
    required this.runningBalance,
  });
}

// ─── Currency Formatter ──────────────────────────────────────────────────────

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

// ─── Main Suppliers Page ────────────────────────────────────────────────────

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  int _activeTab = 0; // 0: Master Base, 1: Ledger Statements, 2: Aging & Reminders

  // Filter & Search state
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'Sort: Newest First';
  String _selectedStatus = 'Status: All';
  String _selectedType = 'Type: All';

  // Selected supplier in Tab 1 (Ledger)
  _SupplierModel? _selectedLedgerSupplier;

  // Suppliers seed data strictly matching Image 1, 2, 3, 4
  late List<_SupplierModel> _suppliers;

  // Mock ledger data map
  late Map<String, List<_LedgerEntry>> _ledgerEntries;

  @override
  void initState() {
    super.initState();

    _suppliers = [
      _SupplierModel(
        id: 'SUP-180',
        name: 'legal',
        code: 'SUP-180',
        contactPerson: 'legal',
        phone: '6374943436',
        email: 'vincent1182003@bnxmail.com',
        gstin: 'SEXDCRFVGTBHGBH',
        pan: 'N/A',
        creditLimit: 0,
        paymentTerms: 'Net 30',
        runningPayable: 45,
        isAdvance: false,
        status: 'CONNECTED',
        statusSubtitle: 'Connected on Website',
        isRegistered: true,
        totalProcured: 0,
      ),
      _SupplierModel(
        id: 'SUP-163',
        name: 'jeni fancy 5050',
        code: 'SUP-163',
        contactPerson: 'jeni fancy 5050',
        phone: '6374943436',
        email: 'jenifancy5050@bnxmail.com',
        gstin: 'JDHGSRETHY15265',
        pan: 'N/A',
        creditLimit: 0,
        paymentTerms: 'Net 30',
        runningPayable: 1239000,
        isAdvance: false,
        status: 'CONNECTED',
        statusSubtitle: 'Connected on Website',
        isRegistered: true,
        totalProcured: 0,
      ),
      _SupplierModel(
        id: 'SUP-149',
        name: 'santo',
        code: 'SUP-149',
        contactPerson: 'santo',
        phone: '6374943436',
        email: 'santhoshhhhhh@bnxmail.com',
        gstin: 'Unregistered',
        pan: 'N/A',
        creditLimit: 0,
        paymentTerms: 'Net 30',
        runningPayable: 356740,
        isAdvance: true,
        status: 'CONNECTED',
        statusSubtitle: 'Connected on Website',
        isRegistered: false,
        totalProcured: 0,
      ),
      _SupplierModel(
        id: 'SUP-120',
        name: 'Generic Cash Supplier',
        code: 'SUP-120',
        contactPerson: 'Counter Staff',
        phone: '9876543210',
        email: 'cash@bnxmail.com',
        gstin: 'Unregistered',
        pan: 'N/A',
        creditLimit: 0,
        paymentTerms: 'Immediate',
        runningPayable: 100000,
        isAdvance: false,
        status: 'CONNECTED',
        statusSubtitle: 'Connected on Website',
        isRegistered: false,
        totalProcured: 0,
      ),
      _SupplierModel(
        id: 'SUP-105',
        name: 'Techcorp',
        code: 'SUP-105',
        contactPerson: 'Harish Mehta',
        phone: '9988776655',
        email: 'accounts@techcorp.in',
        gstin: '27AABCT1234F1Z5',
        pan: 'AABCT1234F',
        creditLimit: 50000,
        paymentTerms: 'Net 45',
        runningPayable: 0,
        isAdvance: false,
        status: 'CONNECTED',
        statusSubtitle: 'Connected on Website',
        isRegistered: true,
        totalProcured: 0,
      ),
    ];

    // Seed mock ledger statements for suppliers (matching Image 3)
    _ledgerEntries = {
      'SUP-180': [
        _LedgerEntry(
          date: '2026-09-15',
          description: 'Opening Balance',
          debit: 45,
          credit: null,
          runningBalance: 45,
        ),
      ],
      'SUP-163': [
        _LedgerEntry(
          date: '2026-08-29',
          description: 'PO-9348 / Bill Inv',
          debit: 1180000,
          credit: null,
          runningBalance: 1180000,
        ),
        _LedgerEntry(
          date: '2026-08-29',
          description: 'PO-0861 / Bill Inv',
          debit: 59000,
          credit: null,
          runningBalance: 1239000,
        ),
      ],
      'SUP-149': [
        _LedgerEntry(
          date: '2026-08-21',
          description: 'Advance Supplier Payment',
          debit: null,
          credit: 356740,
          runningBalance: -356740,
        ),
      ],
      'SUP-120': [
        _LedgerEntry(
          date: '2026-09-01',
          description: 'Cash Procurement Batch',
          debit: 100000,
          credit: null,
          runningBalance: 100000,
        ),
      ],
      'SUP-105': [
        _LedgerEntry(
          date: '2026-09-10',
          description: 'Payment Settlement',
          debit: 50000,
          credit: 50000,
          runningBalance: 0,
        ),
      ],
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Filtered Suppliers Helper ─────────────────────────────────────────────

  List<_SupplierModel> get _filteredSuppliers {
    final query = _searchController.text.trim().toLowerCase();
    var list = _suppliers.where((s) {
      final matchesQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.code.toLowerCase().contains(query) ||
          s.phone.toLowerCase().contains(query) ||
          s.email.toLowerCase().contains(query);

      final matchesStatus = _selectedStatus == 'Status: All' ||
          (_selectedStatus == 'Status: Connected' && s.status == 'CONNECTED') ||
          (_selectedStatus == 'Status: Offline' && s.status != 'CONNECTED');

      final matchesType = _selectedType == 'Type: All' ||
          (_selectedType == 'Type: Registered' && s.isRegistered) ||
          (_selectedType == 'Type: Unregistered' && !s.isRegistered);

      return matchesQuery && matchesStatus && matchesType;
    }).toList();

    if (_selectedSort == 'Sort: Name A-Z') {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_selectedSort == 'Sort: Highest Payable') {
      list.sort((a, b) => b.runningPayable.compareTo(a.runningPayable));
    }

    return list;
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
              child: FloatingActionButton(
                onPressed: _showRegisterSupplierDialog,
                backgroundColor: const Color(0xFF166534),
                elevation: 4,
                child: const Icon(LucideIcons.plus, color: Colors.white, size: 22),
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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 14 : 24,
            isMobile ? 14 : 20,
            isMobile ? 14 : 24,
            isMobile ? 100 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (Suppliers Master Suite + Action Buttons)
              _buildHeader(isMobile),

              const SizedBox(height: 18),

              // 2. METRIC STAT CARDS (4 cards in responsive row/grid)
              _buildMetricCards(screenWidth),

              const SizedBox(height: 20),

              // 3. SEGMENTED NAVIGATION TABS (Master Base, Ledger, Aging)
              _buildSegmentedTabs(isMobile),

              const SizedBox(height: 16),

              // 4. MAIN ACTIVE TAB CONTENT
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
                      child: const Icon(LucideIcons.users, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SUPPLIERS & VENDORS',
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
                    Icon(LucideIcons.checkCircle2, size: 13, color: Colors.greenAccent.shade100),
                    const SizedBox(width: 4),
                    Text(
                      'ACTIVE',
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
            'Suppliers Master Suite',
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
                  onPressed: _showBulkImportDialog,
                  icon: const Icon(LucideIcons.uploadCloud, size: 12, color: Colors.white),
                  label: const Text(
                    'Bulk Import (CSV)',
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
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showRegisterSupplierDialog,
                  icon: const Icon(LucideIcons.plus, size: 12, color: Colors.white),
                  label: const Text(
                    '+ Register Supplier',
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
                _buildHeroChip('OUTSTANDING PAYABLES', '₹86,23,901', isMobile),
                const SizedBox(width: 8),
                _buildHeroChip('ADVANCE OUTFLOWS', '₹3,58,655', isMobile),
                const SizedBox(width: 8),
                _buildHeroChip('TOTAL PROCURED', '₹0', isMobile),
                const SizedBox(width: 8),
                _buildHeroChip('REGISTERED SUPPLIERS', '${_suppliers.length > 5 ? _suppliers.length : 65}', isMobile),
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
      (label: 'Suppliers Master Base', icon: LucideIcons.users),
      (label: 'Running Ledger Statements', icon: LucideIcons.fileText),
      (label: 'Payables Aging & Reminders', icon: LucideIcons.alertTriangle),
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
  // 1. TOP HEADER (Suppliers Master Suite)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(bool isMobile) {
    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48), // Pink/Magenta header icon badge
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(LucideIcons.users, size: 22, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Suppliers Master Suite',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Manage vendor demographics, credit limits, purchase ledgers, and outward payables aging summaries.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final actionButtons = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // Bulk Import (CSV) Button
        OutlinedButton.icon(
          onPressed: _showBulkImportDialog,
          icon: const Icon(LucideIcons.uploadCloud, size: 14, color: Color(0xFF334155)),
          label: const Text(
            'Bulk Import (CSV)',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        // + Register New Supplier Button
        ElevatedButton.icon(
          onPressed: _showRegisterSupplierDialog,
          icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
          label: const Text(
            'Register New Supplier',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48), // Pink/Magenta primary
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 14),
          actionButtons,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        actionButtons,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. METRIC STAT CARDS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMetricCards(double screenWidth) {
    // 4 metric cards matching Image 1
    final card1 = _buildSingleMetricCard(
      title: 'OUTSTANDING PAYABLES',
      value: '₹86,23,901',
      icon: LucideIcons.trendingUp,
      iconColor: const Color(0xFFE11D48),
      iconBg: const Color(0xFFFFE4E6),
    );

    final card2 = _buildSingleMetricCard(
      title: 'ADVANCE SUPPLIER OUTFLOWS',
      value: '₹3,58,655',
      icon: LucideIcons.checkCircle2,
      iconColor: const Color(0xFF16A34A),
      iconBg: const Color(0xFFDCFCE7),
    );

    final card3 = _buildSingleMetricCard(
      title: 'TOTAL PROCURED VALUE',
      value: '₹0',
      icon: LucideIcons.layers,
      iconColor: const Color(0xFF2563EB),
      iconBg: const Color(0xFFDBEAFE),
    );

    final card4 = _buildSingleMetricCard(
      title: 'REGISTERED SUPPLIERS',
      value: '${_suppliers.length > 5 ? _suppliers.length : 65}',
      icon: LucideIcons.users,
      iconColor: const Color(0xFF7C3AED),
      iconBg: const Color(0xFFF3E8FF),
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

        // Mobile: 2x2 compact grid with FittedBox
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
            color: Colors.black.withValues(alpha: 0.02),
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
            label: 'Suppliers Master Base',
            icon: LucideIcons.users,
            activeColor: const Color(0xFFE11D48), // Pink
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 1,
            label: 'Running Ledger Statements',
            icon: LucideIcons.fileText,
            activeColor: const Color(0xFF2563EB), // Blue
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 2,
            label: 'Payables Aging & Reminders',
            icon: LucideIcons.alertTriangle,
            activeColor: const Color(0xFF7C3AED), // Purple
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
                      color: activeColor.withValues(alpha: 0.25),
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
        return _buildSuppliersMasterBaseTab(screenWidth);
      case 1:
        return _buildRunningLedgerTab(screenWidth);
      case 2:
        return _buildAgingAndRemindersTab(screenWidth);
      default:
        return const SizedBox.shrink();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 0: SUPPLIERS MASTER BASE - Image 1
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildSuppliersMasterBaseTab(double screenWidth) {
    final filtered = _filteredSuppliers;

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
          // Filter & Search Toolbar (Image 1)
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 780;

                final searchBox = SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() {}),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Search suppliers, company or contact pe...',
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

                final sortDropdown = _buildFilterDropdown(
                  value: _selectedSort,
                  items: const ['Sort: Newest First', 'Sort: Name A-Z', 'Sort: Highest Payable'],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSort = val);
                  },
                );

                final statusDropdown = _buildFilterDropdown(
                  value: _selectedStatus,
                  items: const ['Status: All', 'Status: Connected', 'Status: Offline'],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                );

                final typeDropdown = _buildFilterDropdown(
                  value: _selectedType,
                  items: const ['Type: All', 'Type: Registered', 'Type: Unregistered'],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      searchBox,
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [sortDropdown, statusDropdown, typeDropdown],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: searchBox),
                    const SizedBox(width: 12),
                    sortDropdown,
                    const SizedBox(width: 8),
                    statusDropdown,
                    const SizedBox(width: 8),
                    typeDropdown,
                  ],
                );
              },
            ),
          ),

          // Responsive Data Table (Image 1)
          if (screenWidth < 768 && Theme.of(context).platform != TargetPlatform.macOS)
            _buildMobileSuppliersCardList(filtered)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = math.max(constraints.maxWidth, 1100.0);

                return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Table Header (Image 1)
                      _buildSuppliersTableHeader(),

                      // Table Rows
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.users, size: 36, color: Color(0xFF94A3B8)),
                                const SizedBox(height: 12),
                                const Text(
                                  'No matching suppliers found',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Try searching with a different keyword or reset filters.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filtered.map((s) => _buildSupplierTableRow(s)),
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

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          iconSize: 16,
          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
          selectedItemBuilder: (context) {
            return items.map((it) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(it, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              );
            }).toList();
          },
          items: items.map((it) => DropdownMenuItem(value: it, child: Text(it, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSuppliersTableHeader() {
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
          _buildThFlex('SUPPLIER DETAILS', flex: 20, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('CONTACT', flex: 20, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('GST & PAN', flex: 18, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('CREDIT LIMITS', flex: 15, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('RUNNING PAYABLE', flex: 17, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('STATUS', flex: 15, withFilter: true),
          const SizedBox(width: 8),
          _buildThFlex('ACTIONS', flex: 12, alignment: Alignment.centerRight),
        ],
      ),
    );
  }

  Widget _buildSupplierTableRow(_SupplierModel s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // 1. SUPPLIER DETAILS (Avatar, Name, Code)
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.user, size: 18, color: Color(0xFF16A34A)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Code: ${s.code} | Contact: ${s.contactPerson}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 2. CONTACT (Phone, Email)
          Expanded(
            flex: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  s.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. GST & PAN
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.gstin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  s.pan.isEmpty ? 'PAN: N/A' : 'PAN: ${s.pan}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 4. CREDIT LIMITS
          Expanded(
            flex: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limit: ${_formatIndianCurrency(s.creditLimit)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 3),
                Text(
                  'Terms: ${s.paymentTerms}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 5. RUNNING PAYABLE (Red for payable, Green for advance)
          Expanded(
            flex: 17,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.isAdvance
                      ? '${_formatIndianCurrency(s.runningPayable)} (Adv)'
                      : _formatIndianCurrency(s.runningPayable),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: s.isAdvance ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 6. STATUS (Connected badge)
          Expanded(
            flex: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.statusSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 7. ACTIONS (Edit & Delete Icon buttons)
          Expanded(
            flex: 12,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  InkWell(
                    onTap: () => _showEditSupplierDialog(s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(LucideIcons.pencil, size: 14, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Delete Button
                  InkWell(
                    onTap: () => _showDeleteSupplierDialog(s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSuppliersCardList(List<_SupplierModel> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: const [
            Icon(LucideIcons.users, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'No suppliers found',
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
        final s = items[index];

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
              // Top Row: Avatar + Name/Code + Edit/Delete Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.user, size: 18, color: Color(0xFF16A34A)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Code: ${s.code} | Contact: ${s.contactPerson}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _showEditSupplierDialog(s),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(LucideIcons.pencil, size: 13, color: Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _showDeleteSupplierDialog(s),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: const Icon(LucideIcons.trash2, size: 13, color: Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Contact row
              Row(
                children: [
                  const Icon(LucideIcons.phone, size: 11, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(s.phone, style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
                  const SizedBox(width: 12),
                  const Icon(LucideIcons.mail, size: 11, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      s.email,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Taxes & Terms
              Wrap(
                spacing: 10,
                runSpacing: 2,
                children: [
                  Text('GSTIN: ${s.gstin}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text(s.pan.isEmpty ? 'PAN: N/A' : 'PAN: ${s.pan}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text('Terms: ${s.paymentTerms}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 8),

              // Financial stats & Status strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CREDIT LIMIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            _formatIndianCurrency(s.creditLimit),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('RUNNING PAYABLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            s.isAdvance
                                ? '${_formatIndianCurrency(s.runningPayable)} (Adv)'
                                : _formatIndianCurrency(s.runningPayable),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: s.isAdvance ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s.status,
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (s.statusSubtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              s.statusSubtitle,
                              style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Bottom View Ledger Button
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedLedgerSupplier = s;
                      _activeTab = 1;
                    });
                  },
                  icon: const Icon(LucideIcons.fileText, size: 12, color: Color(0xFF16A34A)),
                  label: const Text(
                    'View Ledger',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBBF7D0)),
                    backgroundColor: const Color(0xFFF0FDF4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLedgerEntriesCardList(List<_LedgerEntry> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          children: const [
            Icon(LucideIcons.bookOpen, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'No ledger entries found',
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
        final entry = items[index];

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
              // Top Row: Date & Running Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.date,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                  ),
                  Text(
                    'Bal: ${_formatIndianCurrency(entry.runningBalance)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                entry.description,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),

              // Debit & Credit row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Debit: ${entry.debit != null ? _formatIndianCurrency(entry.debit!) : '-'}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: entry.debit != null ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    'Credit: ${entry.credit != null ? _formatIndianCurrency(entry.credit!) : '-'}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: entry.credit != null ? const Color(0xFF16A34A) : const Color(0xFF64748B),
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: RUNNING LEDGER STATEMENTS - Images 2 & 3
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildRunningLedgerTab(double screenWidth) {
    final isMobile = screenWidth < 900;

    final leftSidebar = Container(
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Supplier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          ..._suppliers.map((s) {
            final isSelected = _selectedLedgerSupplier?.id == s.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedLedgerSupplier = s);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.isAdvance
                            ? 'Payable: -${_formatIndianCurrency(s.runningPayable)}'
                            : 'Payable: ${_formatIndianCurrency(s.runningPayable)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: s.isAdvance ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );

    final rightStatement = Container(
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
      child: _selectedLedgerSupplier == null
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select a supplier from the left sidebar to view their full statement ledger.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Image 3)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 620;

                      final titlePart = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statement of Account: ${_selectedLedgerSupplier!.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'GSTIN: ${_selectedLedgerSupplier!.gstin} | Contact: ${_selectedLedgerSupplier!.phone}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      );

                      final buttonsPart = Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          // WhatsApp Remind
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(LucideIcons.messageSquare, color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('WhatsApp statement reminder sent to ${_selectedLedgerSupplier!.phone}!'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF166534),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.smartphone, size: 14, color: Color(0xFF16A34A)),
                            label: const Text(
                              'WhatsApp Remind',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0FDF4),
                              side: const BorderSide(color: Color(0xFF86EFAC)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),

                          // Export Statement PDF
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(LucideIcons.download, color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('Exporting statement ledger for ${_selectedLedgerSupplier!.name} as PDF...'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF2563EB),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.download, size: 14, color: Color(0xFF475569)),
                            label: const Text(
                              'Export Statement PDF',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titlePart,
                            const SizedBox(height: 12),
                            buttonsPart,
                          ],
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          titlePart,
                          buttonsPart,
                        ],
                      );
                    },
                  ),
                ),

                // Statement Ledger Table (Image 3)
                if (screenWidth < 768 && Theme.of(context).platform != TargetPlatform.macOS)
                  _buildMobileLedgerEntriesCardList(_ledgerEntries[_selectedLedgerSupplier!.id] ?? [])
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final entries = _ledgerEntries[_selectedLedgerSupplier!.id] ?? [];
                      final tableWidth = math.max(constraints.maxWidth, 720.0);

                      return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: tableWidth,
                        child: Column(
                          children: [
                            // Table Headers (Image 3)
                            Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                border: Border(
                                  top: BorderSide(color: Color(0xFFE2E8F0)),
                                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(flex: 18, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                  Expanded(flex: 28, child: Text('Description / Ref No.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                  Expanded(flex: 18, child: Text('Debit (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                  Expanded(flex: 18, child: Text('Credit (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                                  Expanded(flex: 18, child: Align(alignment: Alignment.centerRight, child: Text('Running Balance (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))))),
                                ],
                              ),
                            ),

                            // Table Rows (Image 3)
                            ...entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 18,
                                      child: Text(
                                        entry.date,
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 28,
                                      child: Text(
                                        entry.description,
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 18,
                                      child: Text(
                                        entry.debit != null ? _formatIndianCurrency(entry.debit!) : '-',
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 18,
                                      child: Text(
                                        entry.credit != null ? _formatIndianCurrency(entry.credit!) : '-',
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 18,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _formatIndianCurrency(entry.runningBalance),
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
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
                const SizedBox(height: 12),
              ],
            ),
    );

    if (isMobile) {
      return Column(
        children: [
          leftSidebar,
          const SizedBox(height: 16),
          rightStatement,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 320, child: leftSidebar),
        const SizedBox(width: 16),
        Expanded(child: rightStatement),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: PAYABLES AGING & REMINDERS - Image 4
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildAgingAndRemindersTab(double screenWidth) {
    final isMobile = screenWidth < 900;

    // Left Column: Aging Breakdown & Procurement Shares
    final leftCol = Column(
      children: [
        // Outstanding Payables Aging Breakdown
        Container(
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Outstanding Payables Aging Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 18),

              // Bucket 1: 0–30 Days (Rose card)
              _buildAgingBucketItem(
                label: '0–30 Days Overdue Bucket',
                amount: '₹85,000',
                bgColor: const Color(0xFFFFF1F2),
                borderColor: const Color(0xFFFECDD3),
                textColor: const Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),

              // Bucket 2: 31–60 Days (Amber card)
              _buildAgingBucketItem(
                label: '31–60 Days Overdue Bucket',
                amount: '₹35,000',
                bgColor: const Color(0xFFFFFBEB),
                borderColor: const Color(0xFFFDE68A),
                textColor: const Color(0xFFD97706),
              ),
              const SizedBox(height: 12),

              // Bucket 3: 61–90+ Days (Green card)
              _buildAgingBucketItem(
                label: '61–90+ Days Overdue Bucket',
                amount: '₹0',
                bgColor: const Color(0xFFF0FDF4),
                borderColor: const Color(0xFFBBF7D0),
                textColor: const Color(0xFF16A34A),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Supplier Procurement Shares Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Supplier Procurement Shares',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('legal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text('Total bought: ₹0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.05,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF166534)),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Right Column: Payment Follow-up & Automated Reminders Log
    final rightCol = Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Follow-up & Automated Reminders Log',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 18),

          _buildFollowUpRow(
            name: 'legal',
            balance: '₹45',
            onWhatsApp: () => _sendInstantWhatsApp('legal', '₹45'),
            onSchedule: () => _showScheduleReminderDialog('legal', '₹45'),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          _buildFollowUpRow(
            name: 'jeni fancy 5050',
            balance: '₹12,39,000',
            onWhatsApp: () => _sendInstantWhatsApp('jeni fancy 5050', '₹12,39,000'),
            onSchedule: () => _showScheduleReminderDialog('jeni fancy 5050', '₹12,39,000'),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          _buildFollowUpRow(
            name: 'Generic Cash Supplier',
            balance: '₹1,00,000',
            onWhatsApp: () => _sendInstantWhatsApp('Generic Cash Supplier', '₹1,00,000'),
            onSchedule: () => _showScheduleReminderDialog('Generic Cash Supplier', '₹1,00,000'),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          leftCol,
          const SizedBox(height: 18),
          rightCol,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: leftCol),
        const SizedBox(width: 18),
        Expanded(flex: 5, child: rightCol),
      ],
    );
  }

  Widget _buildAgingBucketItem({
    required String label,
    required String amount,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpRow({
    required String name,
    required String balance,
    required VoidCallback onWhatsApp,
    required VoidCallback onSchedule,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;

        final infoPart = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                children: [
                  const TextSpan(text: 'Balance Due: '),
                  TextSpan(
                    text: balance,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                  ),
                ],
              ),
            ),
          ],
        );

        final btnPart = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Send Instant WhatsApp (Image 4)
            InkWell(
              onTap: onWhatsApp,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.smartphone, size: 13, color: Color(0xFF16A34A)),
                    SizedBox(width: 5),
                    Text(
                      'Send Instant\nWhatsApp',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A), height: 1.1),
                    ),
                  ],
                ),
              ),
            ),

            // Schedule Auto-Reminder (Image 4)
            InkWell(
              onTap: onSchedule,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED), // Purple
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.clock, size: 13, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'Schedule Auto-\nReminder',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoPart,
              const SizedBox(height: 10),
              btnPart,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: infoPart),
            const SizedBox(width: 8),
            btnPart,
          ],
        );
      },
    );
  }

  void _sendInstantWhatsApp(String supplierName, String balance) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.messageSquare, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Instant WhatsApp payment reminder sent for $supplierName ($balance)!'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF166534),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showScheduleReminderDialog(String supplierName, String balance) {
    String frequency = 'Every 3 Days';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Schedule Reminders for $supplierName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outstanding balance: $balance', style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text('Reminder Frequency:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Every 3 Days', child: Text('Every 3 Days')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'On Due Date', child: Text('On Due Date')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => frequency = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Auto-reminder scheduled: $frequency for $supplierName'),
                    backgroundColor: const Color(0xFF7C3AED),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTER VENDOR MASTER PROFILE MODAL (Screenshots 1 & 2)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showRegisterSupplierDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _RegisterVendorMasterProfileModal(
        onSaved: (newSupplier) {
          setState(() {
            _suppliers.insert(0, newSupplier);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Supplier ${newSupplier.name} registered successfully!'),
              backgroundColor: const Color(0xFF059669),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }

  void _showEditSupplierDialog(_SupplierModel s) {
    final nameCtrl = TextEditingController(text: s.name);
    final phoneCtrl = TextEditingController(text: s.phone);
    final emailCtrl = TextEditingController(text: s.email);
    final gstinCtrl = TextEditingController(text: s.gstin);
    final payableCtrl = TextEditingController(text: s.runningPayable.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Supplier: ${s.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Supplier Name')),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: gstinCtrl, decoration: const InputDecoration(labelText: 'GSTIN')),
            const SizedBox(height: 8),
            TextField(controller: payableCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Running Payable (₹)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                s.name = nameCtrl.text.trim();
                s.phone = phoneCtrl.text.trim();
                s.email = emailCtrl.text.trim();
                s.gstin = gstinCtrl.text.trim();
                s.runningPayable = double.tryParse(payableCtrl.text.trim()) ?? s.runningPayable;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Supplier ${s.name} updated successfully!'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSupplierDialog(_SupplierModel s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Supplier?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${s.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _suppliers.removeWhere((item) => item.id == s.id);
                if (_selectedLedgerSupplier?.id == s.id) {
                  _selectedLedgerSupplier = null;
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Supplier "${s.name}" removed successfully.'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBulkImportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.fileSpreadsheet, size: 20, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bulk Import Suppliers (CSV)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload a .csv file containing columns:\nSupplier Name, Contact, Phone, Email, GSTIN, PAN, Credit Limit, Opening Balance.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.uploadCloud, size: 32, color: Color(0xFF2563EB)),
                    SizedBox(height: 8),
                    Text('Click to browse or drop CSV here', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppliers CSV imported successfully!'),
                  backgroundColor: Color(0xFF166534),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            child: const Text('Import Sample Data'),
          ),
        ],
      ),
    );
  }

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
}

// ═════════════════════════════════════════════════════════════════════════════
// REGISTER VENDOR MASTER PROFILE MODAL (EXACTLY MATCHING USER SCREENSHOTS 1 & 2)
// ═════════════════════════════════════════════════════════════════════════════

class _RegisterVendorMasterProfileModal extends StatefulWidget {
  final void Function(_SupplierModel) onSaved;

  const _RegisterVendorMasterProfileModal({required this.onSaved});

  @override
  State<_RegisterVendorMasterProfileModal> createState() => _RegisterVendorMasterProfileModalState();
}

class _RegisterVendorMasterProfileModalState extends State<_RegisterVendorMasterProfileModal> {
  // Card 1: Basic Information
  final TextEditingController _businessNameCtrl = TextEditingController();
  final TextEditingController _contactPersonCtrl = TextEditingController();
  String _supplierType = 'Local Supplier';
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _altPhoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();

  // Card 2: Tax & Registration Details
  final TextEditingController _gstinCtrl = TextEditingController();
  final TextEditingController _panCtrl = TextEditingController();
  String _taxRegistration = 'Registered Business';
  String _stateOfSupply = 'Maharashtra';

  // Card 3: Address Details
  final TextEditingController _billingAddressCtrl = TextEditingController();
  final TextEditingController _shippingAddressCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _pincodeCtrl = TextEditingController();

  // Card 4: Banking & Payment Terms
  final TextEditingController _bankAccountCtrl = TextEditingController();
  final TextEditingController _ifscCtrl = TextEditingController();
  final TextEditingController _upiCtrl = TextEditingController();
  final TextEditingController _openingBalanceCtrl = TextEditingController(text: '0');
  final TextEditingController _creditLimitCtrl = TextEditingController(text: '200000');
  String _paymentTerms = 'Net 30';

  final String _vendorCode = 'SUP-${DateTime.now().millisecondsSinceEpoch % 9000 + 1000}';

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _contactPersonCtrl.dispose();
    _mobileCtrl.dispose();
    _altPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _gstinCtrl.dispose();
    _panCtrl.dispose();
    _billingAddressCtrl.dispose();
    _shippingAddressCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    _bankAccountCtrl.dispose();
    _ifscCtrl.dispose();
    _upiCtrl.dispose();
    _openingBalanceCtrl.dispose();
    _creditLimitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
              // 1. TOP HEADER (Screenshots 1 & 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: LayoutBuilder(
                  builder: (context, headerConstraints) {
                    final isNarrow = headerConstraints.maxWidth < 450;

                    final iconBox = Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.building2, size: 18, color: Color(0xFF16A34A)),
                      ),
                    );

                    final codeBadge = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Code: $_vendorCode',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                    );

                    final closeBtn = InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF475569)),
                      ),
                    );

                    if (isNarrow) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconBox,
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Register Vendor Profile',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    codeBadge,
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Provide business and contact details.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          closeBtn,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        iconBox,
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Register Vendor Master Profile',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Provide your business and contact details to get started.',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            'Code: $_vendorCode',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        closeBtn,
                      ],
                    );
                  },
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 2. SCROLLABLE FORM BODY (Screenshots 1 & 2)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // CARD 1: Basic Information (Screenshot 1)
                      _buildBasicInformationCard(),

                      const SizedBox(height: 16),

                      // CARD 2: Tax & Registration Details (Screenshot 1)
                      _buildTaxRegistrationCard(),

                      const SizedBox(height: 16),

                      // CARD 3: Address Details (Screenshot 2)
                      _buildAddressDetailsCard(),

                      const SizedBox(height: 16),

                      // CARD 4: Banking & Payment Terms (Screenshot 2)
                      _buildBankingAndPaymentCard(),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 3. BOTTOM ACTIONS (Cancel & Initialize buttons)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: LayoutBuilder(
                  builder: (context, actionConstraints) {
                    final cancelBtn = OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                    );

                    final submitBtn = ElevatedButton.icon(
                      onPressed: _saveVendorProfile,
                      icon: const Icon(LucideIcons.check, size: 16, color: Colors.white),
                      label: const Text(
                        'Initialize Supplier Master Profile',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669), // Green
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );

                    if (actionConstraints.maxWidth < 450) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          submitBtn,
                          const SizedBox(height: 8),
                          cancelBtn,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cancelBtn,
                        submitBtn,
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveVendorProfile() {
    final businessName = _businessNameCtrl.text.trim();
    if (businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Supplier / Business Name')),
      );
      return;
    }

    final newSupplier = _SupplierModel(
      id: _vendorCode,
      name: businessName,
      code: _vendorCode,
      contactPerson: _contactPersonCtrl.text.trim().isEmpty ? businessName : _contactPersonCtrl.text.trim(),
      phone: _mobileCtrl.text.trim().isEmpty ? '9876543210' : _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? 'supplier@company.com' : _emailCtrl.text.trim(),
      gstin: _gstinCtrl.text.trim().isEmpty ? 'Unregistered' : _gstinCtrl.text.trim(),
      pan: _panCtrl.text.trim().isEmpty ? 'N/A' : _panCtrl.text.trim(),
      creditLimit: double.tryParse(_creditLimitCtrl.text.trim()) ?? 200000,
      paymentTerms: _paymentTerms,
      runningPayable: double.tryParse(_openingBalanceCtrl.text.trim()) ?? 0,
      isAdvance: (double.tryParse(_openingBalanceCtrl.text.trim()) ?? 0) < 0,
      status: 'CONNECTED',
      statusSubtitle: 'Connected on Website',
      isRegistered: _taxRegistration == 'Registered Business',
    );

    widget.onSaved(newSupplier);
    Navigator.pop(context);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD 1: Basic Information
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildBasicInformationCard() {
    return _buildFormCard(
      icon: LucideIcons.user,
      title: 'Basic Information',
      subtitle: 'Enter your business name and contact details.',
      trailing: const Text('* Required fields', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final f1 = _buildInputField(label: 'Supplier / Business Name *', controller: _businessNameCtrl, hint: 'e.g. TechCorp India Pvt Ltd', icon: LucideIcons.building2);
          final f2 = _buildInputField(label: 'Contact Person', controller: _contactPersonCtrl, hint: 'e.g. Harish Menon', icon: LucideIcons.user);
          final f3 = _buildDropdownField(
            label: 'Supplier Type',
            value: _supplierType,
            icon: LucideIcons.store,
            items: const ['Local Supplier', 'Wholesale Vendor', 'Manufacturer', 'Distributor'],
            onChanged: (v) => setState(() => _supplierType = v!),
          );

          final f4 = _buildInputField(label: 'Mobile Number *', controller: _mobileCtrl, hint: 'e.g. 9876543210', icon: LucideIcons.phone, keyboardType: TextInputType.phone);
          final f5 = _buildInputField(label: 'Alternate Phone', controller: _altPhoneCtrl, hint: 'e.g. 9123456780', icon: LucideIcons.phoneCall, keyboardType: TextInputType.phone);

          final f6 = _buildInputField(label: 'Email Address *', controller: _emailCtrl, hint: 'e.g. supplier@company.com', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress);
          final f7 = _buildInputField(label: 'Website Link', controller: _websiteCtrl, hint: 'e.g. www.company.com', icon: LucideIcons.link2);

          if (isNarrow) {
            return Column(
              children: [
                f1, const SizedBox(height: 10),
                f2, const SizedBox(height: 10),
                f3, const SizedBox(height: 10),
                f4, const SizedBox(height: 10),
                f5, const SizedBox(height: 10),
                f6, const SizedBox(height: 10),
                f7,
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 4, child: f1),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: f2),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: f3),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: f4),
                  const SizedBox(width: 10),
                  Expanded(child: f5),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: f6),
                  const SizedBox(width: 10),
                  Expanded(child: f7),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD 2: Tax & Registration Details
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildTaxRegistrationCard() {
    return _buildFormCard(
      icon: LucideIcons.receipt,
      title: 'Tax & Registration Details',
      subtitle: 'Add your tax and registration information.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final f1 = _buildInputField(label: 'GSTIN ID', controller: _gstinCtrl, hint: 'e.g. 27AABCU9603R1ZN', icon: LucideIcons.creditCard);
          final f2 = _buildInputField(label: 'PAN Number', controller: _panCtrl, hint: 'e.g. ABCDE1234F', icon: LucideIcons.fileText);
          final f3 = _buildDropdownField(
            label: 'Tax Registration',
            value: _taxRegistration,
            icon: LucideIcons.shieldCheck,
            items: const ['Registered Business', 'Composition Dealer', 'Unregistered'],
            onChanged: (v) => setState(() => _taxRegistration = v!),
          );
          final f4 = _buildDropdownField(
            label: 'State of Supply',
            value: _stateOfSupply,
            icon: LucideIcons.mapPin,
            items: const ['Maharashtra', 'Tamil Nadu', 'Karnataka', 'Delhi', 'Gujarat', 'Telangana', 'Kerala', 'West Bengal'],
            onChanged: (v) => setState(() => _stateOfSupply = v!),
          );

          if (isNarrow) {
            return Column(
              children: [
                f1, const SizedBox(height: 10),
                f2, const SizedBox(height: 10),
                f3, const SizedBox(height: 10),
                f4,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: f1),
              const SizedBox(width: 10),
              Expanded(child: f2),
              const SizedBox(width: 10),
              Expanded(child: f3),
              const SizedBox(width: 10),
              Expanded(child: f4),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD 3: Address Details (Screenshot 2)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildAddressDetailsCard() {
    return _buildFormCard(
      icon: LucideIcons.mapPin,
      title: 'Address Details',
      subtitle: 'Provide your business and warehouse addresses.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final f1 = _buildInputField(label: 'Billing Headquarters Address', controller: _billingAddressCtrl, hint: 'e.g. No: 3663, TNHB Color', icon: LucideIcons.building);
          final f2 = _buildInputField(label: 'Shipping Warehouse Address', controller: _shippingAddressCtrl, hint: 'e.g. TNHB Industrial Area', icon: LucideIcons.warehouse);
          final f3 = _buildInputField(label: 'City', controller: _cityCtrl, hint: 'e.g. Chennai', icon: LucideIcons.building);
          final f4 = _buildInputField(label: 'Postal Code (Pincode)', controller: _pincodeCtrl, hint: 'e.g. 602001', icon: LucideIcons.mail, keyboardType: TextInputType.number);

          if (isNarrow) {
            return Column(
              children: [
                f1, const SizedBox(height: 10),
                f2, const SizedBox(height: 10),
                f3, const SizedBox(height: 10),
                f4,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: f1),
              const SizedBox(width: 10),
              Expanded(child: f2),
              const SizedBox(width: 10),
              Expanded(child: f3),
              const SizedBox(width: 10),
              Expanded(child: f4),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD 4: Banking & Payment Terms (Screenshot 2)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildBankingAndPaymentCard() {
    return _buildFormCard(
      icon: LucideIcons.creditCard,
      title: 'Banking & Payment Terms',
      subtitle: 'Add your bank details and payment preferences.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Bank Account, IFSC, UPI ID
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              final f1 = _buildInputField(label: 'Bank Account Number', controller: _bankAccountCtrl, hint: 'e.g. 912345678901', icon: LucideIcons.creditCard, keyboardType: TextInputType.number);
              final f2 = _buildInputField(label: 'IFSC Code', controller: _ifscCtrl, hint: 'e.g. SBIN0001234', icon: LucideIcons.landmark);
              final f3 = _buildInputField(label: 'UPI ID', controller: _upiCtrl, hint: 'e.g. vendor@upi', icon: LucideIcons.smartphone);

              if (isNarrow) {
                return Column(
                  children: [
                    f1, const SizedBox(height: 10),
                    f2, const SizedBox(height: 10),
                    f3,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: f1),
                  const SizedBox(width: 10),
                  Expanded(child: f2),
                  const SizedBox(width: 10),
                  Expanded(child: f3),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Sub-Card: Credit & Payment Details (Screenshot 2)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: Color(0xFF166534)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Credit & Payment Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 620;

                    final f1 = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          label: 'Opening Payable Balance (₹)',
                          controller: _openingBalanceCtrl,
                          hint: '0',
                          prefixText: '₹ ',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Keep positive if you owe them, negative for advance payment',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                    );

                    final f2 = _buildInputField(
                      label: 'Credit Limit Allowance (₹)',
                      controller: _creditLimitCtrl,
                      hint: '200000',
                      prefixText: '₹ ',
                      keyboardType: TextInputType.number,
                    );

                    final f3 = _buildDropdownField(
                      label: 'Payment Terms (Days)',
                      value: _paymentTerms,
                      icon: LucideIcons.calendar,
                      items: const ['Immediate', 'Net 15', 'Net 30', 'Net 45', 'Net 60'],
                      onChanged: (v) => setState(() => _paymentTerms = v!),
                    );

                    if (isNarrow) {
                      return Column(
                        children: [
                          f1, const SizedBox(height: 10),
                          f2, const SizedBox(height: 10),
                          f3,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: f1),
                        const SizedBox(width: 10),
                        Expanded(child: f2),
                        const SizedBox(width: 10),
                        Expanded(child: f3),
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

  // ───────────────────────────────────────────────────────────────────────────
  // CARD & FIELD HELPERS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildFormCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFDFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Strip
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(icon, size: 14, color: const Color(0xFF166534)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFDCFCE7)),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    String? prefixText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              prefixIcon: icon != null
                  ? Icon(icon, size: 14, color: const Color(0xFF94A3B8))
                  : (prefixText != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10, top: 9),
                          child: Text(prefixText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        )
                      : null),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 5),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 13, color: Color(0xFF64748B)),
              items: items.map((it) {
                return DropdownMenuItem(
                  value: it,
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(it, style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
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

