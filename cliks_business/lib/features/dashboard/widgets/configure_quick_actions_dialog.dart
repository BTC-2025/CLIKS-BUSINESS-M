import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';

class QuickActionItem {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final AppRoute route;

  const QuickActionItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

const List<QuickActionItem> allDashboardShortcuts = [
  QuickActionItem(
    id: 'new_invoice',
    label: 'New Invoice',
    icon: LucideIcons.plus,
    color: Color(0xFF10B981),
    route: AppRoute.newInvoice,
  ),
  QuickActionItem(
    id: 'sales_orders',
    label: 'Sales Orders',
    icon: LucideIcons.shoppingBag,
    color: Color(0xFF3B82F6),
    route: AppRoute.sales,
  ),
  QuickActionItem(
    id: 'add_product',
    label: 'Add Product',
    icon: LucideIcons.box,
    color: Color(0xFF059669),
    route: AppRoute.products,
  ),
  QuickActionItem(
    id: 'pos_billing',
    label: 'POS Billing',
    icon: LucideIcons.shoppingCart,
    color: Color(0xFFD97706),
    route: AppRoute.pos,
  ),
  QuickActionItem(
    id: 'add_expense',
    label: 'Add Expense',
    icon: LucideIcons.receipt,
    color: Color(0xFFEF4444),
    route: AppRoute.recordExpense,
  ),
  QuickActionItem(
    id: 'attendance',
    label: 'Attendance',
    icon: LucideIcons.clock,
    color: Color(0xFF2563EB),
    route: AppRoute.attendance,
  ),
  QuickActionItem(
    id: 'suppliers',
    label: 'Suppliers',
    icon: LucideIcons.users,
    color: Color(0xFFA855F7),
    route: AppRoute.suppliers,
  ),
  QuickActionItem(
    id: 'add_customer',
    label: 'Add Customer',
    icon: LucideIcons.userPlus,
    color: Color(0xFFEC4899),
    route: AppRoute.addCustomer,
  ),
  QuickActionItem(
    id: 'new_purchase_po',
    label: 'New Purchase PO',
    icon: LucideIcons.fileText,
    color: Color(0xFF6366F1),
    route: AppRoute.newPO,
  ),
  QuickActionItem(
    id: 'staff_claim',
    label: 'Staff Claim',
    icon: LucideIcons.dollarSign,
    color: Color(0xFF16A34A),
    route: AppRoute.lodgeStaffClaim,
  ),
  QuickActionItem(
    id: 'onboard_staff',
    label: 'Onboard Staff',
    icon: LucideIcons.userCheck,
    color: Color(0xFF84CC16),
    route: AppRoute.staff,
  ),
  QuickActionItem(
    id: 'gst_records',
    label: 'GST Records',
    icon: LucideIcons.layers,
    color: Color(0xFFF59E0B),
    route: AppRoute.gst,
  ),
  QuickActionItem(
    id: 'marketing_hub',
    label: 'Marketing Hub',
    icon: LucideIcons.megaphone,
    color: Color(0xFFEA580C),
    route: AppRoute.marketing,
  ),
  QuickActionItem(
    id: 'audit_hub',
    label: 'FIN-PRO Audit Hub',
    icon: LucideIcons.activity,
    color: Color(0xFFF43F5E),
    route: AppRoute.auditHub,
  ),
  QuickActionItem(
    id: 'purchase_bills',
    label: 'Purchase Bills',
    icon: LucideIcons.receipt,
    color: Color(0xFF2563EB),
    route: AppRoute.purchase,
  ),
  QuickActionItem(
    id: 'new_purchase_bill',
    label: 'New Purchase Bill',
    icon: LucideIcons.fileSpreadsheet,
    color: Color(0xFF06B6D4),
    route: AppRoute.newPurchaseBill,
  ),
  QuickActionItem(
    id: 'purchase_returns',
    label: 'Purchase Returns',
    icon: LucideIcons.arrowLeftRight,
    color: Color(0xFF8B5CF6),
    route: AppRoute.returns,
  ),
  QuickActionItem(
    id: 'new_purchase_return',
    label: 'New Purchase Return',
    icon: LucideIcons.undo,
    color: Color(0xFFF472B6),
    route: AppRoute.purchaseReturn,
  ),
  QuickActionItem(
    id: 'sales_returns',
    label: 'Sales Returns',
    icon: LucideIcons.refreshCw,
    color: Color(0xFFF97316),
    route: AppRoute.returns,
  ),
  QuickActionItem(
    id: 'stock_management',
    label: 'Stock Management',
    icon: LucideIcons.database,
    color: Color(0xFF3B82F6),
    route: AppRoute.stock,
  ),
  QuickActionItem(
    id: 'godown_warehouse',
    label: 'Godown/Warehouse',
    icon: LucideIcons.home,
    color: Color(0xFF8D6E63),
    route: AppRoute.warehouse,
  ),
  QuickActionItem(
    id: 'barcode_generator',
    label: 'Barcode Generator',
    icon: LucideIcons.barcode,
    color: Color(0xFF334155),
    route: AppRoute.barcodeGen,
  ),
  QuickActionItem(
    id: 'split_collect',
    label: 'Split & Collect',
    icon: LucideIcons.split,
    color: Color(0xFF7C3AED),
    route: AppRoute.splitCollect,
  ),
  QuickActionItem(
    id: 'payments_ledger',
    label: 'Payments Ledger',
    icon: LucideIcons.bookOpen,
    color: Color(0xFF166534),
    route: AppRoute.transaction,
  ),
  QuickActionItem(
    id: 'company_wallet',
    label: 'Company Wallet',
    icon: LucideIcons.wallet,
    color: Color(0xFF2563EB),
    route: AppRoute.wallet,
  ),
  QuickActionItem(
    id: 'loyalty_rewards',
    label: 'Loyalty Rewards',
    icon: LucideIcons.gift,
    color: Color(0xFFE11D48),
    route: AppRoute.rewards,
  ),
  QuickActionItem(
    id: 'staff_payroll',
    label: 'Staff Payroll',
    icon: LucideIcons.creditCard,
    color: Color(0xFF4F46E5),
    route: AppRoute.payroll,
  ),
  QuickActionItem(
    id: 'double_entry_accounting',
    label: 'Double Entry Accounting',
    icon: LucideIcons.calculator,
    color: Color(0xFF0D9488),
    route: AppRoute.accounting,
  ),
  QuickActionItem(
    id: 'delivery_challan',
    label: 'Delivery Challan',
    icon: LucideIcons.truck,
    color: Color(0xFF0891B2),
    route: AppRoute.sales,
  ),
  QuickActionItem(
    id: 'theme_customization',
    label: 'Theme Customization',
    icon: LucideIcons.wrench,
    color: Color(0xFF64748B),
    route: AppRoute.settings,
  ),
];

final dashboardShortcutsProvider = StateProvider<List<String>>((ref) {
  return allDashboardShortcuts.map((s) => s.id).toList();
});

class ConfigureQuickActionsDialog extends ConsumerStatefulWidget {
  const ConfigureQuickActionsDialog({super.key});

  @override
  ConsumerState<ConfigureQuickActionsDialog> createState() =>
      _ConfigureQuickActionsDialogState();
}

class _ConfigureQuickActionsDialogState
    extends ConsumerState<ConfigureQuickActionsDialog> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    final active = ref.read(dashboardShortcutsProvider);
    _selectedIds = Set<String>.from(active);
  }

  void _toggleShortcut(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.isNotEmpty) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(allDashboardShortcuts.map((s) => s.id));
      }
    });
  }

  void _saveConfiguration() {
    ref.read(dashboardShortcutsProvider.notifier).state = _selectedIds.toList();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final total = allDashboardShortcuts.length;
    final activeCount = _selectedIds.length;
    final hasSelection = _selectedIds.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with title & circular close button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Configure Quick Actions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Pin your most frequent workflows straight to the Dashboard overview.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 2. Active count and Deselect/Select All button row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text(
                      '$activeCount of $total shortcuts active',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _toggleSelectAll,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: hasSelection
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasSelection
                                ? const Color(0xFFFECACA)
                                : const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasSelection
                                  ? LucideIcons.check
                                  : LucideIcons.plus,
                              size: 13,
                              color: hasSelection
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasSelection ? 'Deselect All' : 'Select All',
                              style: TextStyle(
                                color: hasSelection
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF2563EB),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Scrollable List of shortcuts
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: allDashboardShortcuts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = allDashboardShortcuts[index];
                    final isSelected = _selectedIds.contains(item.id);

                    return InkWell(
                      onTap: () => _toggleShortcut(item.id),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? item.color
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon Box
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? item.color.withValues(alpha: 0.12)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? item.color
                                    : const Color(0xFF94A3B8),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Label
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),

                            // Action Button (Colored circle with 'X' or plus)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? item.color
                                    : const Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected
                                    ? LucideIcons.x
                                    : LucideIcons.plus,
                                size: 12,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // 4. Save Configuration Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveConfiguration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14532D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Configuration',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
