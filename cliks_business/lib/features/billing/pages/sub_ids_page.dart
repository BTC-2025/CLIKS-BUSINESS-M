import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── DATA MODELS ──────────────────────────────────────────────

class SubIdItem {
  final String id;
  String name;
  String email;
  String username;
  String assignedShowroom;
  bool isInvoiceOnlyStrict;
  Set<String> permissions;

  SubIdItem({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.assignedShowroom = 'All Showrooms / Global',
    this.isInvoiceOnlyStrict = false,
    Set<String>? permissions,
  }) : permissions = permissions ?? <String>{};
}

class PermissionTreeNode {
  final String id;
  final String title;
  final List<PermissionTreeNode> children;

  const PermissionTreeNode({
    required this.id,
    required this.title,
    this.children = const [],
  });

  bool get isLeaf => children.isEmpty;

  List<String> get allLeafIds {
    if (isLeaf) return [id];
    final list = <String>[];
    for (final child in children) {
      list.addAll(child.allLeafIds);
    }
    return list;
  }
}

// ─── ACCESS CONTROL HIERARCHY TREE DEFINITION ─────────────────
// Matching Images 2, 4, 5, 6 exactly

final List<PermissionTreeNode> kAccessControlHierarchy = [
  // 1. FINANCE
  PermissionTreeNode(
    id: 'finance',
    title: 'Finance',
    children: [
      PermissionTreeNode(
        id: 'finance_accounting',
        title: 'Accounting',
        children: [
          PermissionTreeNode(id: 'finance_accounting_all', title: 'Finance Accounting All'),
          PermissionTreeNode(id: 'finance_pl', title: 'Finance P&L'),
          PermissionTreeNode(id: 'finance_balance_sheet', title: 'Finance Balance Sheet'),
          PermissionTreeNode(id: 'finance_receivables_payables', title: 'Finance Receivables & Payables'),
          PermissionTreeNode(id: 'finance_expenses', title: 'Finance Expenses'),
          PermissionTreeNode(id: 'finance_cash_bank', title: 'Finance Cash & Bank'),
        ],
      ),
      PermissionTreeNode(
        id: 'finance_expenses_group',
        title: 'Expenses',
        children: [
          PermissionTreeNode(id: 'finance_expenses_all', title: 'Finance Expenses All'),
          PermissionTreeNode(id: 'finance_exp_registry_itc', title: 'Finance Exp Registry ITC'),
          PermissionTreeNode(id: 'finance_exp_recurring', title: 'Finance Exp Recurring'),
          PermissionTreeNode(id: 'finance_exp_dept_budgets', title: 'Finance Exp Dept Budgets'),
          PermissionTreeNode(id: 'finance_exp_staff_reimburse', title: 'Finance Exp Staff Reimburse'),
        ],
      ),
      PermissionTreeNode(
        id: 'finance_tax',
        title: 'Tax',
        children: [
          PermissionTreeNode(id: 'finance_tax_all', title: 'Finance Tax All'),
          PermissionTreeNode(id: 'finance_tax_gstr1', title: 'Finance Tax GSTR1'),
          PermissionTreeNode(id: 'finance_tax_gstr2', title: 'Finance Tax GSTR2'),
          PermissionTreeNode(id: 'finance_tax_gstr3b', title: 'Finance Tax GSTR3B'),
          PermissionTreeNode(id: 'finance_tax_gstr9', title: 'Finance Tax GSTR9'),
          PermissionTreeNode(id: 'finance_tax_einvoice', title: 'Finance Tax E-Invoice'),
          PermissionTreeNode(id: 'finance_tax_eway', title: 'Finance Tax E-Way'),
        ],
      ),
      PermissionTreeNode(
        id: 'finance_audit',
        title: 'Audit Center',
        children: [
          PermissionTreeNode(id: 'finance_audit_access', title: 'Finance Audit Center Access'),
        ],
      ),
    ],
  ),

  // 2. SALES
  PermissionTreeNode(
    id: 'sales',
    title: 'Sales',
    children: [
      PermissionTreeNode(
        id: 'sales_invoice_group',
        title: 'Sales Invoice',
        children: [
          PermissionTreeNode(id: 'sales_section_all', title: 'Sales Section All'),
          PermissionTreeNode(id: 'sales_invoice', title: 'Sales Invoice'),
          PermissionTreeNode(id: 'sales_orders_list', title: 'Sales Orders List'),
          PermissionTreeNode(id: 'sales_returns', title: 'Sales Returns'),
          PermissionTreeNode(id: 'sales_warranty_claims', title: 'Sales Warranty Claims'),
          PermissionTreeNode(id: 'sales_cust_aging_reports', title: 'Sales Cust Aging Reports'),
          PermissionTreeNode(id: 'sales_cust_points_rules', title: 'Sales Cust Points Rules'),
        ],
      ),
    ],
  ),

  // 3. PURCHASES
  PermissionTreeNode(
    id: 'purchases',
    title: 'Purchases',
    children: [
      PermissionTreeNode(
        id: 'purchases_invoice_group',
        title: 'Purchase Invoice',
        children: [
          PermissionTreeNode(id: 'purchases_section_all', title: 'Purchases Section All'),
          PermissionTreeNode(id: 'purchases_invoice', title: 'Purchases Invoice'),
          PermissionTreeNode(id: 'purchases_orders_po', title: 'Purchases Orders PO'),
          PermissionTreeNode(id: 'purchases_bills_invoices', title: 'Purchases Bills Invoices'),
          PermissionTreeNode(id: 'purchases_returns', title: 'Purchases Returns'),
        ],
      ),
      PermissionTreeNode(
        id: 'purchases_suppliers_group',
        title: 'Suppliers',
        children: [
          PermissionTreeNode(id: 'purchases_supp_all', title: 'Purchases Supp All'),
          PermissionTreeNode(id: 'purchases_supp_list', title: 'Purchases Supp List'),
          PermissionTreeNode(id: 'purchases_supp_ledger', title: 'Purchases Supp Ledger'),
          PermissionTreeNode(id: 'purchases_supp_aging_reminders', title: 'Purchases Supp Aging Reminders'),
        ],
      ),
    ],
  ),

  // 4. INVENTORY
  PermissionTreeNode(
    id: 'inventory',
    title: 'Inventory',
    children: [
      PermissionTreeNode(
        id: 'inventory_products_group',
        title: 'Products',
        children: [
          PermissionTreeNode(id: 'inventory_products', title: 'Inventory Products'),
        ],
      ),
      PermissionTreeNode(
        id: 'inventory_stock_group',
        title: 'Stock',
        children: [
          PermissionTreeNode(id: 'inventory_section_all', title: 'Inventory Section All'),
          PermissionTreeNode(id: 'inventory_stock', title: 'Inventory Stock'),
          PermissionTreeNode(id: 'inventory_stock_registry', title: 'Inventory Stock Registry'),
          PermissionTreeNode(id: 'inventory_inward_outward', title: 'Inventory Inward Outward'),
          PermissionTreeNode(id: 'inventory_transfers', title: 'Inventory Transfers'),
          PermissionTreeNode(id: 'inventory_batches_expiry', title: 'Inventory Batches Expiry'),
        ],
      ),
      PermissionTreeNode(
        id: 'inventory_warehouse_group',
        title: 'Warehouse',
        children: [
          PermissionTreeNode(id: 'inventory_wh_all', title: 'Inventory WH All'),
          PermissionTreeNode(id: 'inventory_wh_godowns', title: 'Inventory WH Godowns'),
          PermissionTreeNode(id: 'inventory_wh_stock_registry', title: 'Inventory WH Stock Registry'),
          PermissionTreeNode(id: 'inventory_wh_goods_logs', title: 'Inventory WH Goods Logs'),
          PermissionTreeNode(id: 'inventory_wh_inter_transfers', title: 'Inventory WH Inter Transfers'),
        ],
      ),
    ],
  ),

  // 5. HR
  PermissionTreeNode(
    id: 'hr',
    title: 'HR',
    children: [
      PermissionTreeNode(
        id: 'hr_staff_group',
        title: 'Staff',
        children: [
          PermissionTreeNode(id: 'hr_staff_all', title: 'HR Staff All'),
          PermissionTreeNode(id: 'hr_staff_profiles', title: 'HR Staff Profiles'),
          PermissionTreeNode(id: 'hr_staff_leave_rosters', title: 'HR Staff Leave Rosters'),
          PermissionTreeNode(id: 'hr_staff_appraisals', title: 'HR Staff Appraisals'),
          PermissionTreeNode(id: 'hr_staff_reimbursements', title: 'HR Staff Reimbursements'),
        ],
      ),
      PermissionTreeNode(
        id: 'hr_attendance_group',
        title: 'Attendance',
        children: [
          PermissionTreeNode(id: 'hr_att_all', title: 'HR Att All'),
          PermissionTreeNode(id: 'hr_att_today_logs', title: 'HR Att Today Logs'),
          PermissionTreeNode(id: 'hr_att_history_ledgers', title: 'HR Att History Ledgers'),
          PermissionTreeNode(id: 'hr_att_shift_configs', title: 'HR Att Shift Configs'),
          PermissionTreeNode(id: 'hr_att_gps_fencing', title: 'HR Att GPS Fencing'),
          PermissionTreeNode(id: 'hr_att_correction_verify', title: 'HR Att Correction Verify'),
          PermissionTreeNode(id: 'hr_att_calendar', title: 'HR Att Calendar'),
        ],
      ),
      PermissionTreeNode(
        id: 'hr_payroll_group',
        title: 'Payroll',
        children: [
          PermissionTreeNode(id: 'hr_pay_all', title: 'HR Pay All'),
          PermissionTreeNode(id: 'hr_pay_monthly_register', title: 'HR Pay Monthly Register'),
          PermissionTreeNode(id: 'hr_pay_salary_structures', title: 'HR Pay Salary Structures'),
          PermissionTreeNode(id: 'hr_pay_compliance', title: 'HR Pay Compliance'),
          PermissionTreeNode(id: 'hr_pay_loans_advances', title: 'HR Pay Loans Advances'),
        ],
      ),
    ],
  ),

  // 6. POS Billing
  PermissionTreeNode(
    id: 'pos_billing_root',
    title: 'POS Billing',
    children: [
      PermissionTreeNode(id: 'pos_billing', title: 'POS Billing'),
    ],
  ),

  // 7. Simple Billing
  PermissionTreeNode(
    id: 'simple_billing_root',
    title: 'Simple Billing',
    children: [
      PermissionTreeNode(id: 'simple_billing', title: 'Simple Billing'),
    ],
  ),

  // 8. Reports
  PermissionTreeNode(
    id: 'reports_root',
    title: 'Reports',
    children: [
      PermissionTreeNode(id: 'reports', title: 'Reports'),
    ],
  ),

  // 9. Barcode Gen
  PermissionTreeNode(
    id: 'barcode_gen_root',
    title: 'Barcode Gen',
    children: [
      PermissionTreeNode(id: 'barcode_gen', title: 'Barcode Gen'),
    ],
  ),

  // 10. Marketing
  PermissionTreeNode(
    id: 'marketing_root',
    title: 'Marketing',
    children: [
      PermissionTreeNode(id: 'marketing', title: 'Marketing'),
    ],
  ),
];

// ─── SUB-IDS MANAGEMENT PAGE ───────────────────────────────────

class SubIdsPage extends ConsumerStatefulWidget {
  const SubIdsPage({super.key});

  @override
  ConsumerState<SubIdsPage> createState() => _SubIdsPageState();
}

class _SubIdsPageState extends ConsumerState<SubIdsPage> {
  late List<SubIdItem> _subIds;
  late String _selectedSubId;

  // Track expanded state for tree nodes
  final Set<String> _expandedNodeIds = {
    'finance',
    'finance_accounting',
    'finance_expenses_group',
    'finance_tax',
    'finance_audit',
    'sales',
    'sales_invoice_group',
    'purchases',
    'purchases_invoice_group',
    'purchases_suppliers_group',
    'inventory',
    'inventory_products_group',
    'inventory_stock_group',
    'inventory_warehouse_group',
    'hr',
    'hr_staff_group',
    'hr_attendance_group',
    'hr_payroll_group',
    'pos_billing_root',
    'simple_billing_root',
    'reports_root',
    'barcode_gen_root',
    'marketing_root',
  };

  @override
  void initState() {
    super.initState();
    _subIds = [
      SubIdItem(
        id: 'sub_1',
        name: 'ravi kumar',
        email: 'sales.ravinew2004@bnxmail.com',
        username: 'sales.ravinew2004',
        assignedShowroom: 'All Showrooms / Global',
        isInvoiceOnlyStrict: false,
        permissions: {'sales_section_all', 'sales_invoice'},
      ),
      SubIdItem(
        id: 'sub_2',
        name: 'Customer Support',
        email: 'testsupport.ravinew2004@bnxmail.com',
        username: 'testsupport.ravinew2004',
        assignedShowroom: 'All Showrooms / Global',
        isInvoiceOnlyStrict: false,
        permissions: {'simple_billing'},
      ),
      SubIdItem(
        id: 'sub_3',
        name: 'Customer Support',
        email: 'testsupport2.ravinew2004@bnxmail.com',
        username: 'testsupport2.ravinew2004',
        assignedShowroom: 'All Showrooms / Global',
        isInvoiceOnlyStrict: false,
      ),
      SubIdItem(
        id: 'sub_4',
        name: 'Customer Support',
        email: 'testsupport3.ravinew2004@bnxmail.com',
        username: 'testsupport3.ravinew2004',
        assignedShowroom: 'All Showrooms / Global',
        isInvoiceOnlyStrict: false,
      ),
      SubIdItem(
        id: 'sub_5',
        name: 'Test Check',
        email: 'testcheck1.ravinew2004@bnxmail.com',
        username: 'testcheck1.ravinew2004',
        assignedShowroom: 'All Showrooms / Global',
        isInvoiceOnlyStrict: false,
      ),
      SubIdItem(
        id: 'sub_6',
        name: 'Test Managed',
        email: 'testmanaged1.ravinew2004@bnxmail.com',
        username: 'testmanaged1.ravinew2004',
        assignedShowroom: 'All Showrooms / Global',
        isInvoiceOnlyStrict: false,
      ),
    ];
    _selectedSubId = _subIds.first.id;
  }

  SubIdItem get _currentSubId {
    return _subIds.firstWhere(
      (s) => s.id == _selectedSubId,
      orElse: () => _subIds.first,
    );
  }

  void _openAddSubIdDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => _AddSubIdDialog(
        onCreated: (newSubId) {
          setState(() {
            _subIds.insert(0, newSubId);
            _selectedSubId = newSubId.id;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sub-ID "${newSubId.name}" created successfully.'),
              backgroundColor: const Color(0xFF0E4D34),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  void _toggleStrictInvoiceMode() {
    setState(() {
      final current = _currentSubId;
      current.isInvoiceOnlyStrict = !current.isInvoiceOnlyStrict;
      if (current.isInvoiceOnlyStrict) {
        current.permissions = {'sales_section_all', 'sales_invoice'};
      }
    });

    final current = _currentSubId;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          current.isInvoiceOnlyStrict
              ? 'Invoice-Only Strict Mode enabled for ${current.name}.'
              : 'Strict Mode disabled for ${current.name}. Granular permissions restored.',
        ),
        backgroundColor: current.isInvoiceOnlyStrict
            ? const Color(0xFFD97706)
            : const Color(0xFF0E4D34),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _toggleNodePermission(PermissionTreeNode node) {
    setState(() {
      final current = _currentSubId;
      if (node.isLeaf) {
        if (current.permissions.contains(node.id)) {
          current.permissions.remove(node.id);
        } else {
          current.permissions.add(node.id);
        }
      } else {
        final leafIds = node.allLeafIds;
        final isCurrentlyChecked = _isNodeChecked(node);
        if (isCurrentlyChecked) {
          current.permissions.removeAll(leafIds);
          current.permissions.remove(node.id);
        } else {
          current.permissions.addAll(leafIds);
          current.permissions.add(node.id);
        }
      }
    });
  }

  bool _isNodeChecked(PermissionTreeNode node) {
    final current = _currentSubId;
    if (node.isLeaf) {
      return current.permissions.contains(node.id);
    }
    // For single-child roots like Simple Billing, POS Billing, Reports, Barcode Gen, Marketing:
    // in reference design (media_1794921766796_b5c64f09.jpg), parent checkbox is unchecked
    // while the child is checked.
    if (node.children.length == 1 && node.children.first.isLeaf) {
      return current.permissions.contains(node.id);
    }
    final leafIds = node.allLeafIds;
    return leafIds.isNotEmpty && leafIds.every((id) => current.permissions.contains(id));
  }

  bool _isNodeIndeterminate(PermissionTreeNode node) {
    if (node.isLeaf) return false;
    if (_isNodeChecked(node)) return false;
    if (node.children.length == 1 && node.children.first.isLeaf) return false;
    final current = _currentSubId;
    final leafIds = node.allLeafIds;
    final checkedCount = leafIds.where((id) => current.permissions.contains(id)).length;
    return checkedCount > 0 && checkedCount < leafIds.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          if (isMobile) {
            return _buildMobileLayout();
          }

          return _buildDesktopLayout(constraints);
        },
      ),
    );
  }

  // ─── DESKTOP 2-COLUMN MASTER-DETAIL LAYOUT ───────────────────

  Widget _buildDesktopLayout(BoxConstraints constraints) {
    final double? availableHeight =
        constraints.maxHeight.isFinite ? constraints.maxHeight - 48 : null;

    if (availableHeight != null && availableHeight > 300) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Sub-IDs List (300px width, scrollable within viewport)
            SizedBox(
              width: 300,
              height: availableHeight,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildSubIdsListCard(),
              ),
            ),

            const SizedBox(width: 20),

            // Right Column: Manage Permissions Workspace (Expanded, scrollable)
            Expanded(
              child: SizedBox(
                height: availableHeight,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPermissionsHeaderCard(),
                      const SizedBox(height: 16),
                      _buildStrictModeBanner(),
                      const SizedBox(height: 16),
                      _buildAccessControlTreeCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: _buildSubIdsListCard(),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPermissionsHeaderCard(),
                const SizedBox(height: 16),
                _buildStrictModeBanner(),
                const SizedBox(height: 16),
                _buildAccessControlTreeCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── MOBILE RESPONSIVE LAYOUT ────────────────────────────────

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-IDs Selector on top (horizontally scrollable cards on mobile)
          _buildMobileSubIdsSelector(),
          const SizedBox(height: 16),
          _buildPermissionsHeaderCard(),
          const SizedBox(height: 14),
          _buildStrictModeBanner(),
          const SizedBox(height: 14),
          _buildAccessControlTreeCard(),
        ],
      ),
    );
  }

  // ─── 1. LEFT COLUMN: SUB-IDS LIST CARD ────────────────────────

  Widget _buildSubIdsListCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: 👥 Sub-IDs + Add User Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.users, size: 16, color: Color(0xFF0F172A)),
                    SizedBox(width: 8),
                    Text(
                      'Sub-IDs',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _openAddSubIdDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.userPlus, size: 14, color: Color(0xFF059669)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // List of Sub-ID Cards
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: _subIds.map((sub) {
                final isSelected = sub.id == _selectedSubId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildSubIdCardItem(sub, isSelected),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubIdCardItem(SubIdItem sub, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedSubId = sub.id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sub.name,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub.email,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Showroom Tag Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.store, size: 10.5, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      sub.assignedShowroom.contains('/')
                          ? sub.assignedShowroom.split('/').first.trim()
                          : sub.assignedShowroom,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Sub-ID code
            Text(
              'ID: ${sub.username}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSubIdsSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.users, size: 16, color: Color(0xFF0F172A)),
                  SizedBox(width: 8),
                  Text(
                    'Sub-IDs',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              InkWell(
                onTap: _openAddSubIdDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.userPlus, size: 13, color: Color(0xFF059669)),
                      SizedBox(width: 4),
                      Text('Add Sub-ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _subIds.map((sub) {
                final isSelected = sub.id == _selectedSubId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 220,
                    child: _buildSubIdCardItem(sub, isSelected),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. RIGHT PANEL: MANAGE PERMISSIONS HEADER ────────────────

  Widget _buildPermissionsHeaderCard() {
    final sub = _currentSubId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          final headerText = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Permissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Configuring access for ${sub.name} (${sub.username})',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),

              // Assigned Showroom Dropdown Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(LucideIcons.store, size: 13, color: Color(0xFF15803D)),
                  ),
                  const Text(
                    'Assigned Showroom:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth < 240 ? constraints.maxWidth : 240,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: sub.assignedShowroom,
                          isDense: true,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF64748B)),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'All Showrooms / Global',
                              child: Text('All Showrooms / Global', overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'Main Showroom (MAIN-01)',
                              child: Text('Main Showroom (MAIN-01)', overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'Tambaram Showroom (TMB-02)',
                              child: Text('Tambaram Showroom (TMB-02)', overflow: TextOverflow.ellipsis),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => sub.assignedShowroom = val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          final saveBtn = ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Permissions saved for ${sub.name} (${sub.username}).'),
                  backgroundColor: const Color(0xFF0E4D34),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            icon: const Icon(LucideIcons.save, size: 14),
            label: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerText,
                const SizedBox(height: 14),
                saveBtn,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headerText),
              const SizedBox(width: 16),
              saveBtn,
            ],
          );
        },
      ),
    );
  }

  // ─── 3. STRICT MODE BANNER (Image 2 & 3) ──────────────────────

  Widget _buildStrictModeBanner() {
    final sub = _currentSubId;
    final isActive = sub.isInvoiceOnlyStrict;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          final iconWidget = Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                LucideIcons.receipt,
                size: 18,
                color: isActive ? const Color(0xFFD97706) : const Color(0xFF64748B),
              ),
            ),
          );

          final textWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Only Generate Invoice Control (Strict Mode)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isActive ? const Color(0xFFD97706) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Restricts this Sub-ID to only generating invoices. All other access (Dashboard, customer databases, purchase lists, stock, financial reports, simple billing, and business settings) is completely blocked.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isActive ? const Color(0xFF92400E) : const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          );

          final buttonWidget = isActive
              ? ElevatedButton(
                  onPressed: _toggleStrictInvoiceMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Disable Strict Mode',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _toggleStrictInvoiceMode,
                  icon: const Icon(LucideIcons.zap, size: 13, color: Color(0xFFF59E0B)),
                  label: const Text(
                    'Enable Invoice Only',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconWidget,
                    const SizedBox(width: 12),
                    Expanded(child: textWidget),
                  ],
                ),
                const SizedBox(height: 12),
                buttonWidget,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconWidget,
              const SizedBox(width: 12),
              Expanded(child: textWidget),
              const SizedBox(width: 16),
              buttonWidget,
            ],
          );
        },
      ),
    );
  }

  // ─── 4. ACCESS CONTROL HIERARCHY TREE VIEW CARD ───────────────

  Widget _buildAccessControlTreeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACCESS CONTROL HIERARCHY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 16),

          // Build tree nodes
          ...kAccessControlHierarchy.map((rootNode) => _buildTreeNode(rootNode, 0)),
        ],
      ),
    );
  }

  Widget _buildTreeNode(PermissionTreeNode node, int level) {
    final isExpanded = _expandedNodeIds.contains(node.id);
    final isChecked = _isNodeChecked(node);
    final isIndeterminate = _isNodeIndeterminate(node);

    final row = InkWell(
      onTap: () {
        if (!node.isLeaf) {
          setState(() {
            if (isExpanded) {
              _expandedNodeIds.remove(node.id);
            } else {
              _expandedNodeIds.add(node.id);
            }
          });
        } else {
          _toggleNodePermission(node);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: Row(
          children: [
            // Indentation
            SizedBox(width: (level * 22).toDouble()),

            // Expand/Collapse Chevron (for non-leaf)
            if (!node.isLeaf)
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedNodeIds.remove(node.id);
                    } else {
                      _expandedNodeIds.add(node.id);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                    size: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              )
            else
              const SizedBox(width: 17),

            const SizedBox(width: 4),

            // Checkbox Container
            InkWell(
              onTap: () => _toggleNodePermission(node),
              borderRadius: BorderRadius.circular(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isChecked || isIndeterminate
                        ? const Color(0xFF10B981)
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isChecked
                      ? const Icon(LucideIcons.check, size: 12, color: Color(0xFF10B981))
                      : (isIndeterminate
                          ? Container(
                              width: 8,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            )
                          : null),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Node Title
            Flexible(
              child: Text(
                node.title,
                style: TextStyle(
                  fontSize: level == 0 ? 13.5 : (level == 1 ? 12.5 : 12),
                  fontWeight: level == 0
                      ? FontWeight.w700
                      : (level == 1 ? FontWeight.w600 : FontWeight.w400),
                  color: const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    if (node.isLeaf || !isExpanded) {
      return row;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        ...node.children.map((child) => _buildTreeNode(child, level + 1)),
      ],
    );
  }
}

// ─── ADD NEW SUB-ID MODAL DIALOG ───────────────────────────────

class _AddSubIdDialog extends StatefulWidget {
  final Function(SubIdItem) onCreated;

  const _AddSubIdDialog({required this.onCreated});

  @override
  State<_AddSubIdDialog> createState() => _AddSubIdDialogState();
}

class _AddSubIdDialogState extends State<_AddSubIdDialog> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _assignedShowroom = 'All Showrooms / Global';
  bool _invoiceOnlyStrict = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final newSubId = SubIdItem(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      name: name,
      username: username.toLowerCase(),
      email: '${username.toLowerCase()}.ravinew2004@bnxmail.com',
      assignedShowroom: _assignedShowroom,
      isInvoiceOnlyStrict: _invoiceOnlyStrict,
      permissions: _invoiceOnlyStrict ? {'sales_section_all', 'sales_invoice'} : {},
    );

    widget.onCreated(newSubId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.userPlus, size: 18, color: Color(0xFF059669)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Sub-ID Account',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Create a restricted credentials sub-account for staff member',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Staff Member Name *
              const Text('Staff Member Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _dialogInputDeco('e.g. Anand Kumar'),
              ),

              const SizedBox(height: 16),

              // Sub-ID Username / Prefix *
              const Text('Sub-ID Prefix (Username) *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _usernameCtrl,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _dialogInputDeco('e.g. sales2 (creates sales2.ravinew2004@bnxmail.com)'),
              ),

              const SizedBox(height: 16),

              // Assigned Showroom
              const Text('Showroom Assignment *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _assignedShowroom,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    items: const [
                      DropdownMenuItem(value: 'All Showrooms / Global', child: Text('All Showrooms / Global')),
                      DropdownMenuItem(value: 'Main Showroom (MAIN-01)', child: Text('Main Showroom (MAIN-01)')),
                      DropdownMenuItem(value: 'Tambaram Showroom (TMB-02)', child: Text('Tambaram Showroom (TMB-02)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _assignedShowroom = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password *
              const Text('Password *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                decoration: _dialogInputDeco('Enter staff login password'),
              ),

              const SizedBox(height: 16),

              // Strict Mode Switch
              SwitchListTile(
                value: _invoiceOnlyStrict,
                onChanged: (val) => setState(() => _invoiceOnlyStrict = val),
                title: const Text('Strict Invoice-Only Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: const Text('Restricts staff to invoice generation only', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                activeColor: const Color(0xFF059669),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Create Sub-ID',
                        style: TextStyle(fontWeight: FontWeight.w700),
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

  InputDecoration _dialogInputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
      ),
    );
  }
}
