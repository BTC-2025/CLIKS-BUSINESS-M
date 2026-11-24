import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Data class representing one feature row in the 5-tier limit allocation matrix table.
class PlanComparisonFeatureItem {
  final int id;
  final String category;
  final String featureName;
  final String micro;
  final String starter;
  final String standard;
  final String growth;
  final String elite;

  const PlanComparisonFeatureItem({
    required this.id,
    required this.category,
    required this.featureName,
    required this.micro,
    required this.starter,
    required this.standard,
    required this.growth,
    required this.elite,
  });
}

/// Comprehensive 5-tier limit allocation matrix table matching Cliks Business.
class PlanFeaturesComparisonTable extends StatefulWidget {
  final bool isMobile;
  final int activeTierNumber; // 1: Micro, 2: Starter, 3: Standard, 4: Growth, 5: Elite Suite
  final ValueChanged<int>? onUpgrade;

  const PlanFeaturesComparisonTable({
    super.key,
    this.isMobile = false,
    this.activeTierNumber = 5,
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

  // Search and Module Filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All Categories (94)';

  // Collapsed categories state (empty means all are expanded by default)
  final Set<String> _collapsedCategories = {};

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

  static const List<String> _categories = [
    'All Categories (94)',
    'Core Subscription & Limits 8',
    'GST API & Compliance 5',
    'Dashboard & Accounting 17',
    'Purchases & Suppliers 9',
    'Sales & Billing Center 10',
    'Products & Inventory 9',
    'POS (Point of Sale) 7',
    'HR, Staff & Payroll 5',
    'Payments & Escrow 24',
  ];

  static const List<PlanComparisonFeatureItem> _allFeatures = [
    // ═══════════════════════════════════════════════════════════════
    // 1. Core Subscription & Limits (8 Features)
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 1,
      category: '1. Core Subscription & Limits',
      featureName: "Sub ID's Roles",
      micro: '🔒 Locked',
      starter: "2 ID's",
      standard: "5 ID's",
      growth: "10 ID's",
      elite: "20 ID's",
    ),
    PlanComparisonFeatureItem(
      id: 2,
      category: '1. Core Subscription & Limits',
      featureName: 'Internal Showrooms / Godowns (Owned)',
      micro: '1 branch',
      starter: '1 branch',
      standard: '2 branch',
      growth: '5 branch',
      elite: '15 branch',
    ),
    PlanComparisonFeatureItem(
      id: 3,
      category: '1. Core Subscription & Limits',
      featureName: 'External Franchise / Partner Branches',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '🔒 Locked',
      growth: 'Upto 2 External',
      elite: 'Upto 10 External',
    ),
    PlanComparisonFeatureItem(
      id: 4,
      category: '1. Core Subscription & Limits',
      featureName: 'Sales Invoice Limit',
      micro: '1,000',
      starter: '5,000',
      standard: '10,000',
      growth: '25,000',
      elite: '100,000',
    ),
    PlanComparisonFeatureItem(
      id: 5,
      category: '1. Core Subscription & Limits',
      featureName: 'Bill Limit',
      micro: '1,000',
      starter: '5,000',
      standard: '10,000',
      growth: '25,000',
      elite: '100,000',
    ),
    PlanComparisonFeatureItem(
      id: 6,
      category: '1. Core Subscription & Limits',
      featureName: 'Active Stock SKUs',
      micro: '1,000',
      starter: '5,000',
      standard: '10,000',
      growth: '50,000',
      elite: '✨ Unlimited',
    ),
    PlanComparisonFeatureItem(
      id: 7,
      category: '1. Core Subscription & Limits',
      featureName: 'Cloud Storage Tracker',
      micro: '1 GB',
      starter: '5 GB',
      standard: '10 GB',
      growth: '20 GB',
      elite: '50 GB',
    ),
    PlanComparisonFeatureItem(
      id: 8,
      category: '1. Core Subscription & Limits',
      featureName: 'Auto-Backup',
      micro: '🔒 Locked',
      starter: 'Monthly',
      standard: 'Weekly',
      growth: 'Daily',
      elite: 'Daily',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 2. GST API & Compliance (5 Features)
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 9,
      category: '2. GST API & Compliance',
      featureName: 'Live E-Invoicing (IRN/QR)',
      micro: '🔒 (0/day)',
      starter: 'Up to 5/day\n(150/mo)',
      standard: 'Up to 10/day\n(300/mo)',
      growth: 'Up to 20/day\n(600/mo)',
      elite: 'Up to 30/day\n(900/mo)',
    ),
    PlanComparisonFeatureItem(
      id: 10,
      category: '2. GST API & Compliance',
      featureName: 'Live E-Way Bills',
      micro: '🔒 (0/day)',
      starter: 'Up to 2/day\n(60/mo)',
      standard: 'Up to 3/day (90/mo)',
      growth: 'Up to 5/day\n(150/mo)',
      elite: 'Up to 10/day\n(300/mo)',
    ),
    PlanComparisonFeatureItem(
      id: 11,
      category: '2. GST API & Compliance',
      featureName: 'GSTIN Validation API',
      micro: '🔒 Locked',
      starter: '1/day',
      standard: '2/day',
      growth: '3/day',
      elite: '5/day',
    ),
    PlanComparisonFeatureItem(
      id: 12,
      category: '2. GST API & Compliance',
      featureName: 'GST Tax Summary & Day Book',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 13,
      category: '2. GST API & Compliance',
      featureName: 'GSTR Reports (1, 2B, 3B)',
      micro: '🔒 Locked',
      starter: 'Offline CSV/PDF',
      standard: 'GSTR-1 & 3B\nReports',
      growth: 'GSTR-1, 2B, 3B +\nIMS',
      elite: 'Full GSTR + JSON\nExport',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 3. Dashboard & Accounting (17 Features)
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 14,
      category: '3. Dashboard & Accounting',
      featureName: 'Business Overview Dashboard',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 15,
      category: '3. Dashboard & Accounting',
      featureName: 'Quick Action Center',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 16,
      category: '3. Dashboard & Accounting',
      featureName: 'Multi-Showroom Toggle',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: 'Yes (2 Branches)',
      growth: 'Yes (5 Branches)',
      elite: 'Yes (10 Branches)',
    ),
    PlanComparisonFeatureItem(
      id: 17,
      category: '3. Dashboard & Accounting',
      featureName: 'P&L & Balance Sheet',
      micro: '🔒 Locked',
      starter: 'P&L Only',
      standard: 'Full Statements',
      growth: 'Full Statements',
      elite: 'Full + Branch Level',
    ),
    PlanComparisonFeatureItem(
      id: 18,
      category: '3. Dashboard & Accounting',
      featureName: 'Receivables & Payables',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 19,
      category: '3. Dashboard & Accounting',
      featureName: 'Expense Breakdown',
      micro: '🔒 Locked',
      starter: 'Basic Groups',
      standard: 'Full Breakdown',
      growth: 'Full Breakdown',
      elite: 'Sub-accounts &\nCost Centers',
    ),
    PlanComparisonFeatureItem(
      id: 20,
      category: '3. Dashboard & Accounting',
      featureName: 'Cash & Bank Ledger',
      micro: '🔒 Locked',
      starter: 'Bank Statement\nCSV',
      standard: 'Bank Rec (BRS)',
      growth: 'BRS Rules',
      elite: 'Multi-Bank + Auto-\nRules',
    ),
    PlanComparisonFeatureItem(
      id: 21,
      category: '3. Dashboard & Accounting',
      featureName: 'Audit Center',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: 'Basic Auditor Role',
      growth: 'Transaction\nLocking',
      elite: 'Full Activity Audit\nLog',
    ),
    PlanComparisonFeatureItem(
      id: 22,
      category: '3. Dashboard & Accounting',
      featureName: 'Custom Chart of Accounts',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 23,
      category: '3. Dashboard & Accounting',
      featureName: 'Item-wise Expenses',
      micro: 'Basic',
      starter: 'Basic',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 24,
      category: '3. Dashboard & Accounting',
      featureName: 'Dashboard Customization',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '🔒 Locked',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 25,
      category: '3. Dashboard & Accounting',
      featureName: 'Advanced Voucher Audit & Voucher Modification History',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '🔒 Locked',
      growth: '5 limit/day',
      elite: '15 limit/day',
    ),
    PlanComparisonFeatureItem(
      id: 26,
      category: '3. Dashboard & Accounting',
      featureName: 'Sales & Revenue Reports Download (8)',
      micro: '3 Reports',
      starter: '5 Reports',
      standard: '6 Reports',
      growth: '8 Reports',
      elite: '8 Reports',
    ),
    PlanComparisonFeatureItem(
      id: 27,
      category: '3. Dashboard & Accounting',
      featureName: 'Purchase Reports Download (6)',
      micro: '2 Reports',
      starter: '3 Reports',
      standard: '4 Reports',
      growth: '6 Reports',
      elite: '6 Reports',
    ),
    PlanComparisonFeatureItem(
      id: 28,
      category: '3. Dashboard & Accounting',
      featureName: 'Stock & Inventory Reports Download (6)',
      micro: '2 Reports',
      starter: '3 Reports',
      standard: '4 Reports',
      growth: '5 Reports',
      elite: '6 Reports',
    ),
    PlanComparisonFeatureItem(
      id: 29,
      category: '3. Dashboard & Accounting',
      featureName: 'CRM & Parties Reports Download (5)',
      micro: '2 Reports',
      starter: '3 Reports',
      standard: '4 Reports',
      growth: '5 Reports',
      elite: '5 Reports',
    ),
    PlanComparisonFeatureItem(
      id: 30,
      category: '3. Dashboard & Accounting',
      featureName: 'Finance & Tax Reports Download (17)',
      micro: '3 Reports',
      starter: '5 Reports',
      standard: '8 Reports',
      growth: '13 Reports',
      elite: '17 Reports',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 4. Purchases & Suppliers (9 Features) - [Screenshot 1]
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 31,
      category: '4. Purchases & Suppliers',
      featureName: 'Purchases Hub Dashboard',
      micro: 'Full Dashboard',
      starter: 'Full Dashboard',
      standard: 'Full Dashboard',
      growth: 'Full Dashboard',
      elite: 'Full Dashboard',
    ),
    PlanComparisonFeatureItem(
      id: 32,
      category: '4. Purchases & Suppliers',
      featureName: 'Request Stock',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 33,
      category: '4. Purchases & Suppliers',
      featureName: 'Purchase Orders (PO)',
      micro: 'Basic POs',
      starter: 'Basic POs',
      standard: 'Full POs',
      growth: 'POs + Landed\nCost',
      elite: 'POs + Custom\nWorkflows',
    ),
    PlanComparisonFeatureItem(
      id: 34,
      category: '4. Purchases & Suppliers',
      featureName: 'Purchase Bills & Invoices',
      micro: 'Basic',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: 'Yes + Vendor Portal',
    ),
    PlanComparisonFeatureItem(
      id: 35,
      category: '4. Purchases & Suppliers',
      featureName: 'Purchase Returns',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 36,
      category: '4. Purchases & Suppliers',
      featureName: 'Supplier Directory',
      micro: 'Basic',
      starter: 'Basic',
      standard: 'Advance + Credit\nterms',
      growth: 'Advance',
      elite: 'Advance + Multi-\nCurrency',
    ),
    PlanComparisonFeatureItem(
      id: 37,
      category: '4. Purchases & Suppliers',
      featureName: 'Advance Payments Tracker',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 38,
      category: '4. Purchases & Suppliers',
      featureName: 'Landed Cost Allocation',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: 'Basic',
      growth: 'Advanced',
      elite: 'Multi-Currency\nLanded Cost',
    ),
    PlanComparisonFeatureItem(
      id: 39,
      category: '4. Purchases & Suppliers',
      featureName: 'Voucher Scan',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '10 scans',
      growth: '50 scans',
      elite: '200 scans',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 5. Sales & Billing Center (10 Features) - [Screenshot 2]
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 40,
      category: '5. Sales & Billing Center',
      featureName: 'Billing Center Dashboard',
      micro: 'Full Dashboard',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 41,
      category: '5. Sales & Billing Center',
      featureName: 'Generate Invoice',
      micro: 'Fixed Basic\nTemplates',
      starter: 'Cust. Templates',
      standard: 'Advanced\nTemplates',
      growth: 'Advanced\nTemplates',
      elite: '✨ Unlimited White-label',
    ),
    PlanComparisonFeatureItem(
      id: 42,
      category: '5. Sales & Billing Center',
      featureName: 'Sales Orders List',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 43,
      category: '5. Sales & Billing Center',
      featureName: 'Sales Returns',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 44,
      category: '5. Sales & Billing Center',
      featureName: 'Delivery Challan',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 45,
      category: '5. Sales & Billing Center',
      featureName: 'Loyalty Points Tracker',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: 'Basic Tracking',
      growth: 'Auto-Redemption',
      elite: 'Advanced Loyalty\nRules',
    ),
    PlanComparisonFeatureItem(
      id: 46,
      category: '5. Sales & Billing Center',
      featureName: 'Customer CRM Directory',
      micro: '100 Customers',
      starter: '1,000 Customers',
      standard: '5,000 Customers',
      growth: '15,000 Customers',
      elite: '25,000 Customers',
    ),
    PlanComparisonFeatureItem(
      id: 47,
      category: '5. Sales & Billing Center',
      featureName: 'Multi-Series Invoice Numbering',
      micro: '🔒 Locked',
      starter: 'Single Prefix',
      standard: '2 Prefixes',
      growth: '5 Prefixes',
      elite: '✨ Unlimited Custom Series',
    ),
    PlanComparisonFeatureItem(
      id: 48,
      category: '5. Sales & Billing Center',
      featureName: 'Remove Branding / White-Label',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '🔒 Locked',
      growth: '✓ Available',
      elite: 'Full White-Label',
    ),
    PlanComparisonFeatureItem(
      id: 49,
      category: '5. Sales & Billing Center',
      featureName: 'Marketing Campaigns',
      micro: '5 limit/day',
      starter: '10 limit/day',
      standard: '15 limit/day',
      growth: '20 limit/day',
      elite: '40 limit/day',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 6. Products & Inventory (9 Features) - [Screenshot 3]
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 50,
      category: '6. Products & Inventory',
      featureName: 'Stock Valuation Dashboard',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 51,
      category: '6. Products & Inventory',
      featureName: 'Low Stock SKU Alerts',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 52,
      category: '6. Products & Inventory',
      featureName: 'Categories & Subcategories',
      micro: 'Basic',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 53,
      category: '6. Products & Inventory',
      featureName: 'Bulk Import (CSV)',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 54,
      category: '6. Products & Inventory',
      featureName: 'Product Master Management',
      micro: 'Basic Profiles',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 55,
      category: '6. Products & Inventory',
      featureName: 'Godown / Warehouse Mapping',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '1 Godowns',
      growth: '5 Godowns',
      elite: '10 Godowns',
    ),
    PlanComparisonFeatureItem(
      id: 56,
      category: '6. Products & Inventory',
      featureName: 'Price Lists',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 57,
      category: '6. Products & Inventory',
      featureName: 'Batch, Expiry & Serial Tracking',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '🔒 Locked',
      growth: 'Basic Batching',
      elite: 'Full\nBatch/Expiry/Serial',
    ),
    PlanComparisonFeatureItem(
      id: 58,
      category: '6. Products & Inventory',
      featureName: 'FMCG Distribution',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 7. POS (Point of Sale) (7 Features) - [Screenshot 4]
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 59,
      category: '7. POS (Point of Sale)',
      featureName: 'POS Checkout Interface',
      micro: 'Basic PDF Only',
      starter: '1 Counter\n(Thermal)',
      standard: '2 Counters',
      growth: '5 Counters +\nBasic Kiosk Mode',
      elite: '15 Counters +\nCustomizable Kiosk\nMode',
    ),
    PlanComparisonFeatureItem(
      id: 60,
      category: '7. POS (Point of Sale)',
      featureName: 'Batch, Expiry & Serial Tracking in POS',
      micro: '🔒 Locked',
      starter: 'Basic Support',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: 'Yes + Mobile App\nScanning',
    ),
    PlanComparisonFeatureItem(
      id: 61,
      category: '7. POS (Point of Sale)',
      featureName: 'Sold by Weight Toggle',
      micro: 'Basic',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: 'Yes + Weigh Scale\nSync',
    ),
    PlanComparisonFeatureItem(
      id: 62,
      category: '7. POS (Point of Sale)',
      featureName: 'Hold / Clear Cart',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 63,
      category: '7. POS (Point of Sale)',
      featureName: 'Payment Split',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 64,
      category: '7. POS (Point of Sale)',
      featureName: 'Thermal Receipt Printing',
      micro: '🔒 PDF Only',
      starter: '1 Format',
      standard: '2 Formats',
      growth: 'Custom Layouts',
      elite: 'Custom Layouts +\nLogo',
    ),
    PlanComparisonFeatureItem(
      id: 65,
      category: '7. POS (Point of Sale)',
      featureName: 'Simple Billing',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 8. HR, Staff & Payroll (5 Features) - [Screenshot 5]
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 66,
      category: '8. HR, Staff & Payroll',
      featureName: 'HR & Employees Database',
      micro: '🔒 Locked',
      starter: 'Basic (2 Staff)',
      standard: 'Basic (5 Staff)',
      growth: 'Advanced (25\nStaff)',
      elite: 'Elite (100 Staff)',
    ),
    PlanComparisonFeatureItem(
      id: 67,
      category: '8. HR, Staff & Payroll',
      featureName: 'Active Headcount & Payroll',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 68,
      category: '8. HR, Staff & Payroll',
      featureName: 'Leaves & Shifts Rosters',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 69,
      category: '8. HR, Staff & Payroll',
      featureName: 'Staff Reimbursements',
      micro: '🔒 Locked',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 70,
      category: '8. HR, Staff & Payroll',
      featureName: 'Automated Payroll Processing',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: 'Full Sync to\nAccounts',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 9. Payments & Escrow (24 Features) - [Screenshot 5]
    // ═══════════════════════════════════════════════════════════════
    PlanComparisonFeatureItem(
      id: 71,
      category: '9. Payments & Escrow',
      featureName: 'People Network & Escrow',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 72,
      category: '9. Payments & Escrow',
      featureName: 'To Receive / To Pay Dashboard',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 73,
      category: '9. Payments & Escrow',
      featureName: 'Financial Groups',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 74,
      category: '9. Payments & Escrow',
      featureName: 'Global Ledger',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 75,
      category: '9. Payments & Escrow',
      featureName: 'Repayment Alerts',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: 'Basic Alerts',
      growth: 'Custom Alerts',
      elite: 'Custom SMS/Email',
    ),
    PlanComparisonFeatureItem(
      id: 76,
      category: '9. Payments & Escrow',
      featureName: 'Contact Classification',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 77,
      category: '9. Payments & Escrow',
      featureName: 'Net Exposure Tracking',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 78,
      category: '9. Payments & Escrow',
      featureName: 'Payments & Cash Flow Engine',
      micro: 'Manual',
      starter: 'Basic',
      standard: 'Full',
      growth: 'Full',
      elite: 'Full',
    ),
    PlanComparisonFeatureItem(
      id: 79,
      category: '9. Payments & Escrow',
      featureName: 'Outstanding Receivables Tracker',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 80,
      category: '9. Payments & Escrow',
      featureName: 'Combined Balances View',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 81,
      category: '9. Payments & Escrow',
      featureName: 'Efficiency Rate Metric',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 82,
      category: '9. Payments & Escrow',
      featureName: 'Total Inward & Outward Flow',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 83,
      category: '9. Payments & Escrow',
      featureName: 'Log Transaction (Inward/Outward)',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 84,
      category: '9. Payments & Escrow',
      featureName: 'Segregation Goals',
      micro: 'Upto 5 Goals',
      starter: 'Upto 10 Goals',
      standard: 'Upto 20 Goals',
      growth: 'Upto 30 Goals',
      elite: '✨ Yes (Unlimited)',
    ),
    PlanComparisonFeatureItem(
      id: 85,
      category: '9. Payments & Escrow',
      featureName: 'Total Isolated Funds Tracker',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 86,
      category: '9. Payments & Escrow',
      featureName: 'Splitwise & Collect',
      micro: 'Upto 5 splits',
      starter: 'Upto 10 splits',
      standard: 'Upto 20 splits',
      growth: 'Upto 30 splits',
      elite: '✨ Yes (Unlimited)',
    ),
    PlanComparisonFeatureItem(
      id: 87,
      category: '9. Payments & Escrow',
      featureName: 'Group Expense Tickets',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 88,
      category: '9. Payments & Escrow',
      featureName: 'Members & Balances Tracking',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 89,
      category: '9. Payments & Escrow',
      featureName: 'Invite Member & Admin Rights',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 90,
      category: '9. Payments & Escrow',
      featureName: 'Payment Planner',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 91,
      category: '9. Payments & Escrow',
      featureName: 'Automated Reminders',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '10 limit',
      growth: '20 limit/day',
      elite: '40 limit/day',
    ),
    PlanComparisonFeatureItem(
      id: 92,
      category: '9. Payments & Escrow',
      featureName: 'Payment Reminders',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 93,
      category: '9. Payments & Escrow',
      featureName: 'Import Bank and Credit Card Statements',
      micro: '✓ Available',
      starter: '✓ Available',
      standard: '✓ Available',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
    PlanComparisonFeatureItem(
      id: 94,
      category: '9. Payments & Escrow',
      featureName: 'Late Fees',
      micro: '🔒 Locked',
      starter: '🔒 Locked',
      standard: '🔒 Locked',
      growth: '✓ Available',
      elite: '✓ Available',
    ),
  ];

  static IconData _getCategoryIcon(String category) {
    if (category.contains('Core')) return LucideIcons.layers;
    if (category.contains('GST')) return LucideIcons.fileCheck;
    if (category.contains('Dashboard')) return LucideIcons.barChart2;
    if (category.contains('Purchases')) return LucideIcons.shoppingBag;
    if (category.contains('Sales') || category.contains('Billing')) return LucideIcons.receipt;
    if (category.contains('Products') || category.contains('Inventory')) return LucideIcons.box;
    if (category.contains('POS')) return LucideIcons.store;
    if (category.contains('HR')) return LucideIcons.users;
    if (category.contains('Payments') || category.contains('Escrow')) return LucideIcons.wallet;
    return LucideIcons.shieldAlert;
  }

  List<PlanComparisonFeatureItem> get _filteredFeatures {
    return _allFeatures.where((item) {
      // Category filter
      if (_selectedCategory != 'All Categories (94)') {
        final cleanCategory = _selectedCategory.replaceAll(RegExp(r'\s+\d+$'), '').trim().toLowerCase();
        final itemClean = item.category.replaceAll(RegExp(r'^\d+\.\s*'), '').trim().toLowerCase();
        if (!itemClean.contains(cleanCategory) && !cleanCategory.contains(itemClean)) {
          return false;
        }
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = item.featureName.toLowerCase().contains(q);
        final matchesCat = item.category.toLowerCase().contains(q);
        final matchesMicro = item.micro.toLowerCase().contains(q);
        final matchesStarter = item.starter.toLowerCase().contains(q);
        final matchesStandard = item.standard.toLowerCase().contains(q);
        final matchesGrowth = item.growth.toLowerCase().contains(q);
        final matchesElite = item.elite.toLowerCase().contains(q);

        return matchesName ||
            matchesCat ||
            matchesMicro ||
            matchesStarter ||
            matchesStandard ||
            matchesGrowth ||
            matchesElite;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final features = _filteredFeatures;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 1. TOP CARD HEADER ───
          _buildCardHeader(),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ─── 2. SEARCH & CATEGORY FILTER BAR ───
          _buildFilterBar(),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ─── 3. RESPONSIVE TABLE WITH HORIZONTAL SCROLL ───
          _buildTableContent(features),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. TOP CARD HEADER (Icon + Matrix Title + Subtitle)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCardHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 16 : 24,
        vertical: 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCEEAD6)),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.shieldCheck,
                color: Color(0xFF135029),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Full Subscription Features & Limit Allocation Matrix',
                  style: GoogleFonts.inter(
                    fontSize: widget.isMobile ? 16 : 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Comprehensive breakdown across 9 categories (94+ platform features) based on the official Cliks Business Feature Allocation Document.',
                  style: GoogleFonts.inter(
                    fontSize: widget.isMobile ? 11.5 : 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.35,
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
  // 2. FILTER BAR (Search + Expand/Collapse All + Category Filter Chips)
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
                  hintText: 'Search features (e.g. E-Invoicing, BRS, C...',
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
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _collapsedCategories.clear();
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.chevronDown,
                                size: 13,
                                color: Color(0xFF475569),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Expand All',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _collapsedCategories.addAll(
                          _allFeatures.map((f) => f.category).toSet(),
                        );
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.chevronUp,
                                size: 13,
                                color: Color(0xFF475569),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Collapse All',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                        hintText: 'Search features (e.g. E-Invoicing, BRS, C...',
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
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Expand All Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _collapsedCategories.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.chevronDown,
                          size: 13,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expand All',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Collapse All Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _collapsedCategories.addAll(
                        _allFeatures.map((f) => f.category).toSet(),
                      );
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.chevronUp,
                          size: 13,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Collapse All',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
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
                        horizontal: 12,
                        vertical: 6,
                      ),
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
  // 3. TABLE CONTENT WITH HORIZONTAL SCROLL
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

    const double featureColWidth = 280.0;
    const double totalTableWidth = 1260.0;

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

              // ─── TABLE BODY ROWS (Grouped by category with collapse/expand) ───
              ..._buildGroupedFeatureRows(features, featureColWidth),

              // ─── BOTTOM ACTIONS ROW ───
              _buildTableFooterActions(featureColWidth),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABLE HEADER ROW (Platform/Feature + 5 Tiers)
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
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                  'Platform Features',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Compare exact quotas & parameters',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. MICRO (Teal #0F766E) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 1,
              title: 'Micro',
              annualPrice: '₹3,000 / yr',
              monthlySubtext: '₹250 / mo',
              buttonText: 'Select Micro',
              backgroundColor: const Color(0xFF0F766E),
              isCurrent: widget.activeTierNumber == 1,
            ),
          ),

          // ── 3. STARTER (Green #16A34A) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 2,
              title: 'Starter',
              annualPrice: '₹6,996 / yr',
              monthlySubtext: '₹583 / mo',
              buttonText: 'Select Starter',
              backgroundColor: const Color(0xFF16A34A),
              isCurrent: widget.activeTierNumber == 2,
            ),
          ),

          // ── 4. STANDARD (Royal Blue #2563EB with RECOMMENDED badge) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 3,
              title: 'Standard',
              annualPrice: '₹10,788 / yr',
              monthlySubtext: '₹899 / mo',
              buttonText: 'Select Standard',
              topBadgeText: 'RECOMMENDED',
              backgroundColor: const Color(0xFF2563EB),
              isCurrent: widget.activeTierNumber == 3,
            ),
          ),

          // ── 5. GROWTH (Sky Blue #0284C7) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 4,
              title: 'Growth',
              annualPrice: '₹17,988 / yr',
              monthlySubtext: '₹1,499 / mo',
              buttonText: 'Select Growth',
              backgroundColor: const Color(0xFF0284C7),
              isCurrent: widget.activeTierNumber == 4,
            ),
          ),

          // ── 6. ELITE (Purple #7C3AED) ──
          Expanded(
            child: _buildTierHeaderColumn(
              tierNumber: 5,
              title: 'Elite',
              annualPrice: '₹29,988 / yr',
              monthlySubtext: '₹2,499 / mo',
              buttonText: 'CURRENT PLAN',
              backgroundColor: const Color(0xFF7C3AED),
              isCurrent: widget.activeTierNumber == 5,
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
    required String buttonText,
    String? topBadgeText,
    required Color backgroundColor,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Container(
      height: 140,
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
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (topBadgeText != null)
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
                ),
                child: Text(
                  topBadgeText,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: topBadgeText != null ? 18 : 12,
              bottom: 10,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      annualPrice,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      monthlySubtext,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        if (!isCurrent && widget.onUpgrade != null) {
                          widget.onUpgrade!(tierNumber);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5.5,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isCurrent
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isCurrent ? Colors.white : backgroundColor,
                            letterSpacing: 0.2,
                          ),
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

  // ═══════════════════════════════════════════════════════════════
  // GROUPED FEATURE ROWS WITH COLLAPSIBLE CATEGORY HEADERS
  // ═══════════════════════════════════════════════════════════════
  List<Widget> _buildGroupedFeatureRows(
    List<PlanComparisonFeatureItem> features,
    double featureColWidth,
  ) {
    final List<Widget> rows = [];
    final Map<String, List<PlanComparisonFeatureItem>> grouped = {};

    for (final item in features) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    int rowIndex = 0;
    grouped.forEach((category, items) {
      final isCollapsed = _collapsedCategories.contains(category);
      // Category header
      rows.add(_buildCategoryHeader(category, items.length));

      // Category rows (if not collapsed)
      if (!isCollapsed) {
        for (final item in items) {
          rows.add(
            _buildFeatureComparisonRow(
              item: item,
              rowIndex: rowIndex++,
              featureColWidth: featureColWidth,
            ),
          );
        }
      }
    });

    return rows;
  }

  // ═══════════════════════════════════════════════════════════════
  // CATEGORY HEADER BAR WITH COLLAPSE / EXPAND TOGGLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCategoryHeader(String category, int count) {
    final isCollapsed = _collapsedCategories.contains(category);

    return InkWell(
      onTap: () {
        setState(() {
          if (isCollapsed) {
            _collapsedCategories.remove(category);
          } else {
            _collapsedCategories.add(category);
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF0FDF4),
          border: Border(
            top: BorderSide(color: Color(0xFFDCFCE7), width: 1.0),
            bottom: BorderSide(color: Color(0xFFDCFCE7), width: 1.0),
            left: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF166534),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(category),
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count Features',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF166534),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCollapsed ? 'Expand' : 'Collapse',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isCollapsed ? LucideIcons.chevronDown : LucideIcons.chevronUp,
                  size: 13,
                  color: const Color(0xFF475569),
                ),
              ],
            ),
          ],
        ),
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
        ? const Color(0xFFF8FAFC)
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
              // ── 1. FEATURE NAME COLUMN ──
              Container(
                width: featureColWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.featureName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. TIER 1 (MICRO) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.micro,
                  tierNumber: 1,
                  isCurrent: widget.activeTierNumber == 1,
                ),
              ),

              // ── 3. TIER 2 (STARTER) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.starter,
                  tierNumber: 2,
                  isCurrent: widget.activeTierNumber == 2,
                ),
              ),

              // ── 4. TIER 3 (STANDARD) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.standard,
                  tierNumber: 3,
                  isCurrent: widget.activeTierNumber == 3,
                ),
              ),

              // ── 5. TIER 4 (GROWTH) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.growth,
                  tierNumber: 4,
                  isCurrent: widget.activeTierNumber == 4,
                ),
              ),

              // ── 6. TIER 5 (ELITE) VALUE CELL ──
              Expanded(
                child: _buildTierValueCell(
                  rawText: item.elite,
                  tierNumber: 5,
                  isCurrent: widget.activeTierNumber == 5,
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
  // CELL VALUE RENDERER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTierValueCell({
    required String rawText,
    required int tierNumber,
    required bool isCurrent,
    bool isLast = false,
  }) {
    final textTrim = rawText.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFF0FDF4).withValues(alpha: 0.3) : null,
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
  // CELL VALUE FORMATTER (Locked Badges, Available Badges, Text)
  // ═══════════════════════════════════════════════════════════════
  Widget _formatCellValue(String text) {
    // 1. Red locked badge: "🔒 Locked"
    if (text == '🔒 Locked') {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.lock, size: 11, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Text(
                'Locked',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Red locked with quota: starts with "🔒" (e.g. "🔒 (0/day)")
    if (text.startsWith('🔒')) {
      final quota = text.replaceFirst('🔒', '').trim();
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.lock, size: 11, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Text(
                quota.isNotEmpty ? quota : 'Locked',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Green Available badge: "✓ Available"
    if (text == '✓ Available') {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.check, size: 11, color: Color(0xFF16A34A)),
              const SizedBox(width: 4),
              Text(
                'Available',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Emerald Unlimited badge: "✨ Unlimited" / "✨ Unlimited White-label" / "✨ Unlimited Custom Series"
    if (text.contains('Unlimited')) {
      final label = text.replaceAll('✨', '').trim();
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF059669),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.sparkles, size: 11, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 5. Standard text representation
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
          height: 1.25,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM ACTIONS ROW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTableFooterActions(double featureColWidth) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: featureColWidth,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Text(
              'Upgrade or change workspace plan:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          Expanded(child: _buildFooterActionButton(1, 'Select Micro', const Color(0xFF0F766E))),
          Expanded(child: _buildFooterActionButton(2, 'Select Starter', const Color(0xFF16A34A))),
          Expanded(child: _buildFooterActionButton(3, 'Select Standard', const Color(0xFF2563EB))),
          Expanded(child: _buildFooterActionButton(4, 'Select Growth', const Color(0xFF0284C7))),
          Expanded(child: _buildFooterActionButton(5, 'CURRENT PLAN', const Color(0xFF7C3AED))),
        ],
      ),
    );
  }

  Widget _buildFooterActionButton(int tierNumber, String label, Color color) {
    final isCurrent = widget.activeTierNumber == tierNumber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: ElevatedButton(
        onPressed: isCurrent
            ? null
            : () {
                if (widget.onUpgrade != null) {
                  widget.onUpgrade!(tierNumber);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrent ? const Color(0xFFE2E8F0) : color,
          foregroundColor: isCurrent ? const Color(0xFF94A3B8) : Colors.white,
          elevation: isCurrent ? 0 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        child: Text(
          isCurrent ? 'Active Plan' : label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
