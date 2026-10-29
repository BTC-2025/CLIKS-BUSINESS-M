import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Data class representing one feature row in the 4-tier plan comparison table.
class PlanComparisonFeatureItem {
  final int id;
  final String module;
  final String featureName;
  final String description;
  final String starter;
  final String standard;
  final String growth;
  final String elite;
  final IconData icon;

  const PlanComparisonFeatureItem({
    required this.id,
    required this.module,
    required this.featureName,
    required this.description,
    required this.starter,
    required this.standard,
    required this.growth,
    required this.elite,
    required this.icon,
  });
}

/// A comprehensive, responsive 4-tier comparison table widget matching the design of Cliks Business.
class PlanFeaturesComparisonTable extends StatefulWidget {
  final bool isMobile;
  final int activeTierNumber; // 1: Starter, 2: Standard, 3: Growth/Premium, 4: Elite
  final ValueChanged<int>? onUpgrade;

  const PlanFeaturesComparisonTable({
    super.key,
    this.isMobile = false,
    this.activeTierNumber = 1,
    this.onUpgrade,
  });

  @override
  State<PlanFeaturesComparisonTable> createState() =>
      _PlanFeaturesComparisonTableState();
}

class _PlanFeaturesComparisonTableState
    extends State<PlanFeaturesComparisonTable> {
  // Brand colors
  static const Color _darkForestGreen = Color(0xFF135029);
  static const Color _starterGreen = Color(0xFF16A34A);
  static const Color _standardBlue = Color(0xFF0284C7);
  static const Color _growthIndigo = Color(0xFF4F46E5);
  static const Color _elitePurple = Color(0xFF7C3AED);

  // Search and Module Filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Horizontal scroll controller for the table
  final ScrollController _horizontalScrollController = ScrollController();

  // Hover state tracking for rows
  int? _hoveredRowIndex;

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // All 30 features across 15 Modules strictly reflecting the prompt specifications
  static const List<PlanComparisonFeatureItem> _allFeatures = [
    // ─── 1. Workspace & Users ───
    PlanComparisonFeatureItem(
      id: 1,
      module: 'Workspace & Users',
      featureName: 'Organization User Seats',
      description:
          'Controls how many staff members or accountants can log into the organization workspace.',
      starter: '0 Users',
      standard: '2 Users',
      growth: '7 Users',
      elite: '15 Users',
      icon: LucideIcons.users,
    ),
    PlanComparisonFeatureItem(
      id: 2,
      module: 'Workspace & Users',
      featureName: 'Role-Based Access & Permissions',
      description:
          'Restricts what each user can view, create, edit, or delete across modules.',
      starter: 'Predefined Basic Roles',
      standard: 'Standard Module-Level Roles',
      growth: 'Granular Multi-User Role Permissions',
      elite: 'Custom Field-Level & Branch Locks',
      icon: LucideIcons.shieldCheck,
    ),

    // ─── 2. Sales & Billing ───
    PlanComparisonFeatureItem(
      id: 3,
      module: 'Sales & Billing',
      featureName: 'Annual Sales Invoices Cap',
      description:
          'Sets the maximum number of standard B2B/B2C tax invoices generated per year.',
      starter: '5,000 Invoices / yr (~415/mo)',
      standard: '15,000 Invoices / yr (~1,250/mo)',
      growth: '50,000 Invoices / yr (~4,160/mo)',
      elite: '150,000 Invoices / yr (Strict Cap)',
      icon: LucideIcons.fileText,
    ),
    PlanComparisonFeatureItem(
      id: 4,
      module: 'Sales & Billing',
      featureName: 'Quotes, Proforma & Delivery Challans',
      description:
          'Creates estimates, proforma bills, and delivery challans that convert into invoices in 1 click.',
      starter: '1,000 Quotes/Challans / yr',
      standard: '5,000 Quotes/Challans / yr',
      growth: '20,000 Quotes/Challans / yr',
      elite: '50,000 Quotes/Challans / yr',
      icon: LucideIcons.fileCheck,
    ),
    PlanComparisonFeatureItem(
      id: 5,
      module: 'Sales & Billing',
      featureName: 'Credit Notes & Sales Returns',
      description:
          'Processes customer returns, damaged goods adjustments, and tax credit notes.',
      starter: 'Up to 500 Credit Notes / yr',
      standard: 'Up to 2,000 Credit Notes / yr',
      growth: 'Up to 10,000 Credit Notes / yr',
      elite: '25,000 Credit Notes / yr',
      icon: LucideIcons.receipt,
    ),
    PlanComparisonFeatureItem(
      id: 6,
      module: 'Sales & Billing',
      featureName: 'Customer Directory (CRM)',
      description:
          'Stores customer profiles, billing/shipping addresses, credit limits, and receivable ledgers.',
      starter: '2,000 Customer Records',
      standard: '7,500 Customer Records',
      growth: '25,000 Customer Records',
      elite: '75,000 Customer Records Max',
      icon: LucideIcons.contact,
    ),
    PlanComparisonFeatureItem(
      id: 7,
      module: 'Sales & Billing',
      featureName: 'Recurring Invoices & Overdue Alerts',
      description:
          'Auto-generates repeat subscription bills and flags overdue customer receivables.',
      starter: '❌ (Manual Billing Only)',
      standard: 'Recurring Invoices & Smart Overdue Alerts',
      growth: 'Automated Dunning & Late-Fee Rules',
      elite: 'Custom Multi-Schedule Billing Pipelines',
      icon: LucideIcons.refreshCw,
    ),

    // ─── 3. Purchases ───
    PlanComparisonFeatureItem(
      id: 8,
      module: 'Purchases',
      featureName: 'Annual Purchase Bills & Expenses Cap',
      description:
          'Tracks supplier purchase invoices, raw material inward bills, and operational vouchers.',
      starter: '5,000 Bills / yr',
      standard: '15,000 Bills / yr',
      growth: '50,000 Bills / yr',
      elite: '150,000 Bills / yr (Strict Cap)',
      icon: LucideIcons.shoppingBag,
    ),
    PlanComparisonFeatureItem(
      id: 9,
      module: 'Purchases',
      featureName: 'Purchase Orders (PO) & Debit Notes',
      description:
          'Issues formal purchase orders to suppliers and generates debit notes for purchase returns.',
      starter: 'Basic Debit Note Entry',
      standard: '2,500 Purchase Orders / yr',
      growth: '10,000 POs / yr + GRN Matching',
      elite: '30,000 POs / yr + Auto-Reorder POs',
      icon: LucideIcons.clipboardList,
    ),
    PlanComparisonFeatureItem(
      id: 10,
      module: 'Purchases',
      featureName: 'Supplier / Vendor Directory',
      description:
          'Maintains vendor contact records, payment terms, and supplier payable ledgers.',
      starter: '500 Vendor Records',
      standard: '2,000 Vendor Records',
      growth: '10,000 Vendor Records',
      elite: '25,000 Vendor Records Max',
      icon: LucideIcons.truck,
    ),

    // ─── 4. External Tax APIs (Master India @ ₹0.70/call) ───
    PlanComparisonFeatureItem(
      id: 11,
      module: 'External Tax APIs (Master India @ ₹0.70/call)',
      featureName:
          'Combined Daily Tax API Quota (E-Invoice + E-Way Bill + GSTIN Lookup)',
      description:
          'Total daily external Master India API calls allowed across E-Invoicing, E-Way Bills, and GSTIN verification.',
      starter: '❌ 0 API Calls / day (No E-Invoice / No E-Way Bill)',
      standard: '5 API Calls / day (150 / mo | 1,825 / yr)',
      growth: '10 API Calls / day (300 / mo | 3,650 / yr)',
      elite: '30 API Calls / day (900 / mo | 10,950 / yr)',
      icon: LucideIcons.zap,
    ),
    PlanComparisonFeatureItem(
      id: 12,
      module: 'External Tax APIs (Master India)',
      featureName: 'Live E-Invoice (IRN & QR) & E-Way Bill Generation',
      description:
          'Generates official Government IRN, Signed QR Code, and Part-A/B E-Way Bills within the daily API cap.',
      starter: '❌ Not Included in Starter',
      standard: 'Included (Up to 5 combined calls/day)',
      growth: 'Included (Up to 10 combined calls/day)',
      elite: 'Included (Up to 30 combined calls/day)',
      icon: LucideIcons.qrCode,
    ),

    // ─── 5. Tax (Zero-Cost Local Software) ───
    PlanComparisonFeatureItem(
      id: 13,
      module: 'Tax (Zero-Cost Local Software)',
      featureName: 'GSTR-1, 2B, 3B & Tax Report Downloads',
      description:
          'Lists and downloads local GSTR-1, GSTR-2, GSTR-3B, and GSTR-9 CSV/PDF reports (₹0 API cost).',
      starter: 'List & Download GSTR-1 & 3B (CSV/PDF)',
      standard: 'GSTR-1, 2B Purchase View & 3B Downloads',
      growth: 'GSTR-1, 2, 3B, GSTR-9 & Audit Hub Exports',
      elite: 'Multi-GSTIN Consolidated Tax Repository',
      icon: LucideIcons.download,
    ),
    PlanComparisonFeatureItem(
      id: 14,
      module: 'Tax (Zero-Cost Local Software)',
      featureName: 'TDS / TCS Deduction Schedules',
      description:
          'Calculates and tracks Tax Deducted/Collected at Source on vendor bills and sales invoices.',
      starter: '❌',
      standard: 'Basic TDS Deducted Ledger View',
      growth: 'Advanced Tax Deductions (TDS/TCS) Reports',
      elite: 'Full Quarterly TDS/TCS Statement Export',
      icon: LucideIcons.percent,
    ),

    // ─── 6. Inventory ───
    PlanComparisonFeatureItem(
      id: 15,
      module: 'Inventory',
      featureName: 'Products & Stock SKU Catalog',
      description:
          'Defines how many unique products, services, and variants can be stored in inventory.',
      starter: '5,000 Active SKUs',
      standard: '15,000 Active SKUs',
      growth: '50,000 Active SKUs',
      elite: '150,000 Active SKUs Max',
      icon: LucideIcons.package,
    ),
    PlanComparisonFeatureItem(
      id: 16,
      module: 'Inventory',
      featureName: 'Warehouses, Godowns & Showrooms',
      description:
          'Tracks stock quantities across multiple physical store locations, godowns, and branches.',
      starter: '1 Warehouse (Single Site)',
      standard: 'Up to 3 Sites (Multi-Warehouse Routing)',
      growth: 'Up to 10 Sites (Multi-Site Inventory Sync)',
      elite: '25 Sites Max (Consolidated Multi-Branch)',
      icon: LucideIcons.warehouse,
    ),
    PlanComparisonFeatureItem(
      id: 17,
      module: 'Inventory',
      featureName: 'Batch, Serial Number & Expiry Tracking',
      description:
          'Tracks medicine/FMCG batches with expiry dates or electronics IMEI/serial numbers.',
      starter: 'Basic Stock In/Out',
      standard: 'Batch & Expiry Date Alerts',
      growth: 'Serial Number / IMEI Tracking + Batches',
      elite: 'FIFO/LIFO Batch Costing & QC Logs',
      icon: LucideIcons.calendarClock,
    ),

    // ─── 7. POS & Simple Billing ───
    PlanComparisonFeatureItem(
      id: 18,
      module: 'POS & Simple Billing',
      featureName: 'POS Billing Counters & Kiosk Mode',
      description:
          'Runs touch-friendly retail checkout counters with cart hold, barcode scan, and split tender.',
      starter: '1 Basic POS Counter',
      standard: '2 POS Counters + Hold Cart & Offline Sync',
      growth: '5 POS Counters + Kiosk Mode',
      elite: '15 POS Counters Max (Multi-Outlet Retail)',
      icon: LucideIcons.monitor,
    ),
    PlanComparisonFeatureItem(
      id: 19,
      module: 'POS & Simple Billing',
      featureName: 'Thermal & A4 Invoice Print Formats',
      description:
          'Formats bills for 2-inch/3-inch thermal receipt printers and standard A4/A5 laser printers.',
      starter: 'Standard A4 / A5 PDF Templates',
      standard: 'Thermal Receipt (2" & 3") + A4 Layouts',
      growth: 'Custom Logo, Header & Terms on Thermal/A4',
      elite: 'Custom White-Label Invoicing & Branding',
      icon: LucideIcons.printer,
    ),

    // ─── 8. Barcode Gen ───
    PlanComparisonFeatureItem(
      id: 20,
      module: 'Barcode Gen',
      featureName: 'Barcode & Thermal QR Label Engine',
      description:
          'Generates and prints scannable SKU barcodes and QR stickers using local software rendering.',
      starter: 'Standard A4 Barcode Sticker Sheets',
      standard: 'Custom Barcode & QR Label Printing (1,500/mo)',
      growth: 'Bulk Roll Label Designer (10,000 labels/mo)',
      elite: '50,000 Labels/mo + Weigh-Scale Barcode Support',
      icon: LucideIcons.scanLine,
    ),

    // ─── 9. Finance ───
    PlanComparisonFeatureItem(
      id: 21,
      module: 'Finance',
      featureName: 'Core Accounting & Financial Statements',
      description:
          'Automates double-entry bookkeeping, Day Book logs, Cash & Bank registers, P&L, and Balance Sheets.',
      starter: 'Day Book, Cash Flow & P&L Statements',
      standard: 'Full Balance Sheet, Trial Balance & BRS',
      growth: 'Cost Centre Tagging & Branch-Wise P&L',
      elite: 'Consolidated Multi-Showroom Financial Statements',
      icon: LucideIcons.bookOpen,
    ),
    PlanComparisonFeatureItem(
      id: 22,
      module: 'Finance',
      featureName: 'Expense Tracking & Voucher Approvals',
      description:
          'Records operational expenses with receipt attachments and manager approval workflows.',
      starter: 'Basic Expense Category Logging',
      standard: 'Expense Receipts + Vendor Tagging',
      growth: 'Single-Level Manager Expense Approval',
      elite: 'Multi-Stage Maker-Checker Voucher Approvals',
      icon: LucideIcons.checkSquare,
    ),

    // ─── 10. HR & Payroll ───
    PlanComparisonFeatureItem(
      id: 23,
      module: 'HR & Payroll',
      featureName: 'Active Staff Roster & Attendance',
      description:
          'Manages employee profiles, daily attendance logs, leave balances, and shift rosters.',
      starter: 'Up to 5 Staff (Manual Attendance)',
      standard: 'Up to 15 Staff (Automated Attendance)',
      growth: 'Up to 50 Staff (Shifts & Leave Tracking)',
      elite: '100 Active Staff Max (Multi-Branch Roster)',
      icon: LucideIcons.userCheck,
    ),
    PlanComparisonFeatureItem(
      id: 24,
      module: 'HR & Payroll',
      featureName: 'Automated Salary & Payslip Engine',
      description:
          'Calculates monthly staff salaries, PF/ESI/TDS deductions, advances, and PDF payslips.',
      starter: 'Basic Salary Expense Entry',
      standard: 'Automated Payroll & Payslip PDF Generation',
      growth: 'Bulk Salary Register + Connected CLIKS Staff Sync',
      elite: 'Full Statutory Payroll Vault & Department Costing',
      icon: LucideIcons.banknote,
    ),

    // ─── 11. Marketing ───
    PlanComparisonFeatureItem(
      id: 25,
      module: 'Marketing',
      featureName: 'Email Campaigns & ROI Automation',
      description:
          'Sends promotional newsletters, discount codes, and abandoned cart emails with ROI tracking.',
      starter: '500 Campaign Emails / mo (2 Templates)',
      standard: '2,500 Campaign Emails / mo + Trigger Automations',
      growth: '10,000 Campaign Emails / mo + Advanced ROI Reports',
      elite: '25,000 Campaign Emails / mo (Strict Cap)',
      icon: LucideIcons.mail,
    ),
    PlanComparisonFeatureItem(
      id: 26,
      module: 'Marketing',
      featureName: 'WhatsApp Bill Share & Payment Links',
      description:
          'Shares PDF invoices and overdue reminders via free WhatsApp deep-links (wa.me).',
      starter: 'Manual 1-Click WhatsApp Bill Share',
      standard: 'Automated Overdue Reminder Templates',
      growth: 'Bulk Festival Broadcast Lists',
      elite: 'Custom Webhook Notification Pipelines',
      icon: LucideIcons.messageSquare,
    ),

    // ─── 12. Reports ───
    PlanComparisonFeatureItem(
      id: 27,
      module: 'Reports',
      featureName: 'Business Analytics & Custom Reports',
      description:
          'Generates party-wise, item-wise, tax, ageing, and profitability reports with CSV/PDF export.',
      starter: '15+ Core Financial & Sales Reports',
      standard: '40+ Inventory, Party & Ageing Reports',
      growth: 'Advanced Margin, Cohort & Audit Reports + 10 Saved Views',
      elite:
          'Custom Report Builder (50 Saved Views) + Scheduled Digests',
      icon: LucideIcons.barChart3,
    ),

    // ─── 13. Storage & Backup ───
    PlanComparisonFeatureItem(
      id: 28,
      module: 'Storage & Backup',
      featureName: 'Cloud Document Vault & Attachments',
      description:
          'Stores uploaded supplier bills, expense receipts, product images, and backups in the cloud.',
      starter: '1 GB Cloud Storage (1 file/entry)',
      standard: '5 GB Cloud Storage (Up to 3 files/entry)',
      growth: '25 GB Cloud Storage (Up to 5 files/entry)',
      elite: '100 GB Enterprise Vault + Scheduled Backups',
      icon: LucideIcons.cloud,
    ),

    // ─── 14. Integrations ───
    PlanComparisonFeatureItem(
      id: 29,
      module: 'Integrations',
      featureName: 'Inbound REST API & Webhook ERP Sync',
      description:
          'Connects Cliks Business with Shopify, WooCommerce, or custom ERPs (Your own server API).',
      starter: '❌',
      standard: '❌',
      growth: 'REST API & Webhooks (1,000 calls / day)',
      elite: 'Enterprise API Access (10,000 calls / day cap)',
      icon: LucideIcons.webhook,
    ),

    // ─── 15. Support & SLA ───
    PlanComparisonFeatureItem(
      id: 30,
      module: 'Support & SLA',
      featureName: 'Customer Support & Uptime SLA',
      description:
          'Defines guaranteed response time for technical tickets, onboarding, and server availability.',
      starter: 'Standard Email Support (24h SLA)',
      standard: 'Priority Live Chat & Email Support (12h SLA)',
      growth: 'Fast-Track Phone & VIP Chat (6h SLA)',
      elite: 'Dedicated Account Manager (2h SLA) & 99.9% Uptime.',
      icon: LucideIcons.headphones,
    ),
  ];

  // Category filter options
  static const List<String> _categories = [
    'All',
    'Workspace & Users',
    'Sales & Billing',
    'Purchases',
    'Tax & Compliance',
    'Inventory & Barcode',
    'POS & Billing',
    'Finance',
    'HR & Payroll',
    'Marketing',
    'Reports & Storage',
    'Integrations & Support',
  ];

  List<PlanComparisonFeatureItem> get _filteredFeatures {
    return _allFeatures.where((item) {
      // Category filter
      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Tax & Compliance') {
          if (!item.module.toLowerCase().contains('tax')) return false;
        } else if (_selectedCategory == 'Inventory & Barcode') {
          if (!item.module.toLowerCase().contains('inventory') &&
              !item.module.toLowerCase().contains('barcode')) {
            return false;
          }
        } else if (_selectedCategory == 'Reports & Storage') {
          if (!item.module.toLowerCase().contains('reports') &&
              !item.module.toLowerCase().contains('storage')) {
            return false;
          }
        } else if (_selectedCategory == 'Integrations & Support') {
          if (!item.module.toLowerCase().contains('integrations') &&
              !item.module.toLowerCase().contains('support')) {
            return false;
          }
        } else {
          if (!item.module
              .toLowerCase()
              .contains(_selectedCategory.toLowerCase())) {
            return false;
          }
        }
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = item.featureName.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        final matchModule = item.module.toLowerCase().contains(q);
        final matchStarter = item.starter.toLowerCase().contains(q);
        final matchStandard = item.standard.toLowerCase().contains(q);
        final matchGrowth = item.growth.toLowerCase().contains(q);
        final matchElite = item.elite.toLowerCase().contains(q);
        return matchName ||
            matchDesc ||
            matchModule ||
            matchStarter ||
            matchStandard ||
            matchGrowth ||
            matchElite;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFeatures;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. TOP CARD HEADER: Shield Icon, Title & Subtitle ───
          _buildCardHeader(),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // ─── 2. CONTROLS: Search Bar & Module Filter Chips ───
          _buildFilterBar(),

          // ─── 3. COMPARISON TABLE ───
          _buildTableContent(filtered),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD HEADER (Shield Check + Title + Subtitle)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCardHeader() {
    return Padding(
      padding: EdgeInsets.all(widget.isMobile ? 18.0 : 26.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Green Shield Icon Container
          Container(
            width: widget.isMobile ? 38 : 44,
            height: widget.isMobile ? 38 : 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAFAE3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1F2C2), width: 1.2),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.shieldCheck,
                color: _darkForestGreen,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: widget.isMobile ? 12 : 16),
          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Plan Features Comparison',
                      style: GoogleFonts.inter(
                        fontSize: widget.isMobile ? 16 : 21,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '${_allFeatures.length} Features Matrix',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Compare exact features, usage quotas, and capabilities across all subscription tiers.',
                  style: GoogleFonts.inter(
                    fontSize: widget.isMobile ? 12 : 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
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
  // FILTER BAR (Search + Category Filter Chips)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 16 : 24,
        vertical: 14,
      ),
      color: const Color(0xFFFBFDFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isMobile) ...[
            // Mobile Search
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Search features (e.g. invoice, e-way)...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    size: 15,
                    color: Color(0xFF94A3B8),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 14),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                '${_filteredFeatures.length} of ${_allFeatures.length} Features',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                // Search Input
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Search features (e.g. invoice, e-way, warehouse, gst, payroll)...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 14),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Results counter pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '${_filteredFeatures.length} of ${_allFeatures.length} Features',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Scrollable category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _darkForestGreen
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _darkForestGreen
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABLE CONTENT WITH HORIZONTAL SCROLL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTableContent(List<PlanComparisonFeatureItem> features) {
    if (features.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(LucideIcons.search, size: 36, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'No features match "$_searchQuery"',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search terms or filter selection.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    // Column widths:
    // Feature Column: 310px
    // 4 Tier Columns: equal flex width (~215px each)
    // Total table width = 310 + 860 = 1170px
    const double featureColWidth = 310.0;
    const double totalTableWidth = 1170.0;

    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(widget.isMobile ? 12 : 20),
        child: SizedBox(
          width: totalTableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── TABLE HEADER ROW ───
              _buildTableHeader(featureColWidth),

              // ─── TABLE BODY ROWS (Grouped by module) ───
              ..._buildGroupedFeatureRows(features, featureColWidth),

              // ─── BOTTOM CTA ACTIONS ROW ───
              _buildTableFooterActions(featureColWidth),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABLE HEADER ROW (Platform/Feature + 4 Tiers)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTableHeader(double featureColWidth) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. PLATFORM / FEATURE HEADER ──
          Container(
            width: featureColWidth,
            height: 122,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Platform / Feature',
                  style: GoogleFonts.inter(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_allFeatures.length} modules & operational quotas',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. TIER 1: STARTER (Green) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 1,
              title: 'Starter',
              annualPrice: '₹1,188 / year',
              monthlySubtext: '(~₹99/month)',
              badgeText: 'BEST FOR SMALL BUSINESS',
              backgroundColor: _starterGreen,
              isCurrent: widget.activeTierNumber == 1,
            ),
          ),

          // ── 3. TIER 2: STANDARD (Blue) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 2,
              title: 'Standard',
              annualPrice: '₹2,988 / year',
              monthlySubtext: '(~₹249/month)',
              badgeText: 'BEST FOR GROWING BUSINESS',
              backgroundColor: _standardBlue,
              isCurrent: widget.activeTierNumber == 2,
            ),
          ),

          // ── 4. TIER 3: GROWTH / PREMIUM (Indigo) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 3,
              title: 'Growth',
              annualPrice: '₹6,588 / year',
              monthlySubtext: '(~₹549/month)',
              badgeText: 'HIGH-VELOCITY AUTOMATION',
              backgroundColor: _growthIndigo,
              isCurrent: widget.activeTierNumber == 3,
            ),
          ),

          // ── 5. TIER 4: ELITE (Purple) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 4,
              title: 'Elite',
              annualPrice: '₹11,988 / year',
              monthlySubtext: '(~₹999/month)',
              badgeText: 'BEST FOR LARGE / ADVANCED BUSINESS',
              backgroundColor: _elitePurple,
              isCurrent: widget.activeTierNumber == 4,
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SINGLE TIER HEADER COLUMN
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTierHeaderColumn({
    required int tierNumber,
    required String title,
    required String annualPrice,
    required String monthlySubtext,
    required String badgeText,
    required Color backgroundColor,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Container(
      height: 122,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: backgroundColor, width: 1),
          bottom: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          right: isLast
              ? BorderSide(color: backgroundColor, width: 1)
              : BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tier Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),

          // Annual Price
          Text(
            annualPrice,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          // Monthly subtext
          Text(
            monthlySubtext,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),

          // Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.inter(
                fontSize: 8.8,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // GROUPED FEATURE ROWS WITH MODULE SECTION HEADERS
  // ═══════════════════════════════════════════════════════════════
  List<Widget> _buildGroupedFeatureRows(
    List<PlanComparisonFeatureItem> features,
    double featureColWidth,
  ) {
    final List<Widget> rows = [];
    String? currentModule;

    for (int i = 0; i < features.length; i++) {
      final item = features[i];

      // Add Module category separator bar whenever module changes
      if (_selectedCategory == 'All' && item.module != currentModule) {
        currentModule = item.module;
        rows.add(_buildModuleSectionDivider(currentModule));
      }

      // Add feature comparison row
      rows.add(
        _buildFeatureComparisonRow(
          item: item,
          rowIndex: i,
          featureColWidth: featureColWidth,
        ),
      );
    }

    return rows;
  }

  // ═══════════════════════════════════════════════════════════════
  // MODULE SECTION DIVIDER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildModuleSectionDivider(String moduleName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _darkForestGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            moduleName.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF334155),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SINGLE FEATURE COMPARISON ROW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFeatureComparisonRow({
    required PlanComparisonFeatureItem item,
    required int rowIndex,
    required double featureColWidth,
  }) {
    final isEven = rowIndex % 2 == 0;
    final isHovered = _hoveredRowIndex == rowIndex;
    final baseColor = isHovered
        ? const Color(0xFFF1F5F9)
        : (isEven ? Colors.white : const Color(0xFFFAFCFF));

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRowIndex = rowIndex),
      onExit: (_) => setState(() => _hoveredRowIndex = null),
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
            left: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. FEATURE NAME & DESCRIPTION COLUMN ──
              Container(
                width: featureColWidth,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feature Icon
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          item.icon,
                          size: 15,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name and What This Does
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.featureName,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.description,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. TIER 1 (STARTER) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.starter,
                  tierNumber: 1,
                  isCurrent: widget.activeTierNumber == 1,
                ),
              ),

              // ── 3. TIER 2 (STANDARD) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.standard,
                  tierNumber: 2,
                  isCurrent: widget.activeTierNumber == 2,
                ),
              ),

              // ── 4. TIER 3 (GROWTH) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.growth,
                  tierNumber: 3,
                  isCurrent: widget.activeTierNumber == 3,
                ),
              ),

              // ── 5. TIER 4 (ELITE) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.elite,
                  tierNumber: 4,
                  isCurrent: widget.activeTierNumber == 4,
                  isLast: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PARSED TIER VALUE CELL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTierValueCell({
    required String rawText,
    required int tierNumber,
    required bool isCurrent,
    bool isLast = false,
  }) {
    final textTrim = rawText.trim();

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFF0FDF4).withValues(alpha: 0.35) : null,
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
      ),
      child: Center(
        child: _formatCellValue(textTrim),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CELL VALUE FORMATTER (Red Crosses, Green Checks, Bold Metrics)
  // ═══════════════════════════════════════════════════════════════
  Widget _formatCellValue(String text) {
    // 1. Exact Red Cross: "❌"
    if (text == '❌') {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
        ),
        child: const Center(
          child: Icon(
            LucideIcons.x,
            color: Color(0xFFEF4444),
            size: 15,
          ),
        ),
      );
    }

    // 2. Starts with "❌" (e.g., "❌ (Manual Billing Only)", "❌ Not Included in Starter")
    if (text.startsWith('❌')) {
      final detail = text.replaceFirst('❌', '').trim();
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.x,
                    color: Color(0xFFEF4444),
                    size: 11,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Not Available',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      );
    }

    // 3. Included with details (e.g. "Included (Up to 5 combined calls/day)")
    if (text.toLowerCase().startsWith('included')) {
      final sub =
          text.replaceFirst(RegExp(r'included', caseSensitive: false), '').trim();
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.check,
                    color: Color(0xFF16A34A),
                    size: 12,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Included',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ],
      );
    }

    // 4. Highlighted Unlimited or Strict Cap
    final isUnlimited = text.toLowerCase().contains('unlimited');
    final hasParenthesis = text.contains('(') && text.contains(')');

    if (hasParenthesis) {
      final parenIdx = text.indexOf('(');
      final mainPart = text.substring(0, parenIdx).trim();
      final subPart = text.substring(parenIdx).trim();

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            mainPart,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isUnlimited
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subPart,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      );
    }

    // 5. Default single text line
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: isUnlimited ? FontWeight.w800 : FontWeight.w600,
        color: isUnlimited
            ? const Color(0xFF16A34A)
            : const Color(0xFF1E293B),
        height: 1.3,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABLE FOOTER ACTIONS ROW (Upgrade buttons for each tier)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTableFooterActions(double featureColWidth) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          left: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Empty placeholder column matching feature column
          Container(
            width: featureColWidth,
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  color: _darkForestGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select Workspace Plan',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Action button for Tier 1: Starter
          Expanded(
            child: _buildTierActionCell(
              tierNumber: 1,
              tierName: 'Starter',
              color: _starterGreen,
            ),
          ),

          // Action button for Tier 2: Standard
          Expanded(
            child: _buildTierActionCell(
              tierNumber: 2,
              tierName: 'Standard',
              color: _standardBlue,
            ),
          ),

          // Action button for Tier 3: Growth
          Expanded(
            child: _buildTierActionCell(
              tierNumber: 3,
              tierName: 'Growth',
              color: _growthIndigo,
            ),
          ),

          // Action button for Tier 4: Elite
          Expanded(
            child: _buildTierActionCell(
              tierNumber: 4,
              tierName: 'Elite',
              color: _elitePurple,
              isLast: true,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SINGLE TIER ACTION BUTTON CELL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTierActionCell({
    required int tierNumber,
    required String tierName,
    required Color color,
    bool isLast = false,
  }) {
    final bool isCurrent = tierNumber == widget.activeTierNumber;
    final bool isBelow = tierNumber < widget.activeTierNumber;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: isCurrent
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.checkCheck,
                    size: 15,
                    color: Color(0xFF065F46),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Active Plan',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            )
          : isBelow
              ? SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Included in Tier',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onUpgrade != null) {
                        widget.onUpgrade!(tierNumber);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Upgrade to $tierName',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
    );
  }
}
