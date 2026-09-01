import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../widgets/modals/finance_modals.dart';
import '../../billing/providers/expenses_provider.dart';

class TopNavBar extends ConsumerStatefulWidget {
  const TopNavBar({super.key});

  @override
  ConsumerState<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends ConsumerState<TopNavBar> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final navigation = ref.watch(navigationProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    if (_isSearchExpanded && !isDesktop) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 24),
              onPressed: () => setState(() => _isSearchExpanded = false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.search, color: Colors.white70, size: 16),
                    suffixIcon: IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white70, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _isSearchExpanded = false);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    hintText: 'Search transactions, bills...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      );
    }

    return Container(
      height: 64,
      padding: EdgeInsets.only(
        left: isDesktop ? 16 : 8,
        right: 0, // Shifting icons closer to the right edge
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
      ),
      child: Row(
        children: [
          // Logo and Menu section
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDesktop && navigation.currentModule != AppModule.profile)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(LucideIcons.menu, color: Colors.white, size: 24),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              InkWell(
                onTap: () => ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.books, AppRoute.dashboard),
                child: Row(
                  children: [
                    if (![
                      AppRoute.people,
                      AppRoute.wallet,
                      AppRoute.transaction,
                      AppRoute.segregation,
                      AppRoute.splitCollect,
                      AppRoute.planner,
                      AppRoute.accounting,
                      AppRoute.expenses,
                      AppRoute.gst,
                      AppRoute.billing,
                      AppRoute.sales,
                      AppRoute.customers,
                      AppRoute.returns,
                      AppRoute.purchase,
                      AppRoute.suppliers,
                      AppRoute.products,
                      AppRoute.stock,
                      AppRoute.warehouse,
                      AppRoute.inventory,
                      AppRoute.pos,
                      AppRoute.reports,
                      AppRoute.marketing,
                      AppRoute.barcodeGen,
                      AppRoute.auditHub,
                      AppRoute.payroll,
                      AppRoute.allocateEmployeeLoan,
                      AppRoute.processMonthlyPayroll,
                      AppRoute.attendance,
                      AppRoute.manualPunchEntry,
                      AppRoute.regularizeMissedPunch,
                      AppRoute.staff,
                      AppRoute.hr,
                    ].contains(navigation.currentRoute)) ...[
                      Container(
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      () {
                        switch (navigation.currentRoute) {
                          case AppRoute.people: return 'People';
                          case AppRoute.wallet: return 'Wallet';
                          case AppRoute.transaction: return 'Transaction';
                          case AppRoute.segregation: return 'Segregation';
                          case AppRoute.splitCollect: return 'Split and Collect';
                          case AppRoute.planner: return 'Planner';
                          case AppRoute.accounting: return 'Accounting';
                          case AppRoute.expenses: return 'Expenses';
                          case AppRoute.gst: return 'GST Compliance';
                          case AppRoute.billing: return 'Sales Invoice';
                          case AppRoute.sales: return 'Sales Orders';
                          case AppRoute.customers: return 'Customers';
                          case AppRoute.returns: return 'Returns';
                          case AppRoute.purchase: return 'Purchase Invoice';
                          case AppRoute.suppliers: return 'Suppliers';
                          case AppRoute.products: return 'Products';
                          case AppRoute.stock: return 'Stock & Inventory';
                          case AppRoute.warehouse: return 'Warehouse';
                          case AppRoute.inventory: return 'Inventory';
                          case AppRoute.pos: return 'Point of Sale (POS)';
                          case AppRoute.reports: return 'Reports & Analytics';
                          case AppRoute.marketing: return 'Marketing Hub';
                          case AppRoute.barcodeGen: return 'Barcode Generator';
                          case AppRoute.auditHub: return 'Audit Hub';
                          case AppRoute.payroll:
                          case AppRoute.allocateEmployeeLoan:
                          case AppRoute.processMonthlyPayroll:
                            return 'Payroll';
                          case AppRoute.attendance:
                          case AppRoute.manualPunchEntry:
                          case AppRoute.regularizeMissedPunch:
                            return 'Attendance';
                          case AppRoute.staff: return 'Staff';
                          case AppRoute.hr: return 'Human Resources';
                          default: return 'Cliks Business';
                        }
                      }(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 20 : 17.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Central Animated Section (Search or Module Selector)
          Expanded(
            flex: _isSearchExpanded ? 8 : 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _isSearchExpanded
                  ? Container(
                      key: const ValueKey('expanded_search'),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search analytics, people or documents...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                          prefixIcon: const Icon(LucideIcons.search, color: Colors.white70, size: 18),
                          suffixIcon: IconButton(
                            icon: const Icon(LucideIcons.x, color: Colors.white70, size: 18),
                            onPressed: () => setState(() => _isSearchExpanded = false),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    )
                  : isDesktop
                      ? Container(
                          key: const ValueKey('module_selector'),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ModulePill(
                                label: 'Books',
                                isActive: navigation.currentModule == AppModule.books,
                                onTap: () => ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.books, AppRoute.dashboard),
                              ),
                              _ModulePill(
                                label: 'Payments',
                                isActive: navigation.currentModule == AppModule.payments,
                                onTap: () => ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.payments, AppRoute.people),
                              ),
                              _ModulePill(
                                label: 'Social',
                                isActive: navigation.currentModule == AppModule.social,
                                onTap: () => ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.social, AppRoute.meetup),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),

          const Spacer(),

          // Right-side Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (navigation.currentRoute == AppRoute.expenses) ...[
                _buildExpenseHeaderActionButton(context, ref),
              ] else ...[
                if (!_isSearchExpanded) ...[
                  if (isDesktop) const _PointsChip(),
                  if (isDesktop) const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.search, color: Colors.white, size: 22),
                    onPressed: () => setState(() => _isSearchExpanded = true),
                    tooltip: 'Search',
                  ),
                ],
                const SizedBox(width: 2),
                // Notification Button (Hidden on specific Finance/Sales/Inventory pages)
                if (![
                  AppRoute.people,
                  AppRoute.wallet,
                  AppRoute.transaction,
                  AppRoute.segregation,
                  AppRoute.splitCollect,
                  AppRoute.planner,
                  AppRoute.accounting,
                  AppRoute.expenses,
                  AppRoute.gst,
                  AppRoute.billing,
                  AppRoute.sales,
                  AppRoute.customers,
                  AppRoute.returns,
                  AppRoute.purchase,
                  AppRoute.suppliers,
                  AppRoute.products,
                  AppRoute.stock,
                  AppRoute.warehouse,
                  AppRoute.inventory,
                  AppRoute.pos,
                  AppRoute.reports,
                  AppRoute.marketing,
                  AppRoute.barcodeGen,
                  AppRoute.auditHub,
                  AppRoute.payroll,
                  AppRoute.allocateEmployeeLoan,
                  AppRoute.processMonthlyPayroll,
                  AppRoute.attendance,
                  AppRoute.manualPunchEntry,
                  AppRoute.regularizeMissedPunch,
                  AppRoute.staff,
                  AppRoute.hr,
                ].contains(navigation.currentRoute))
                  PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    icon: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const Icon(LucideIcons.bell, color: Colors.white, size: 22),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                          ),
                        ),
                      ],
                    ),
                    itemBuilder: (context) => [
                      _buildNotificationItem(
                        title: 'New Invoice Created',
                        subtitle: 'INV-158091 was saved successfully.',
                        time: '2 mins ago',
                        icon: LucideIcons.fileCheck,
                        iconColor: AppColors.primaryGreen,
                      ),
                      _buildNotificationItem(
                        title: 'Points Updated',
                        subtitle: 'You collected 500 referral points!',
                        time: '1 hour ago',
                        icon: LucideIcons.sparkles,
                        iconColor: const Color(0xFFF2C94C),
                      ),
                      _buildNotificationItem(
                        title: 'Backup Successful',
                        subtitle: 'Cloud reconciliation database synced.',
                        time: 'Yesterday',
                        icon: LucideIcons.database,
                        iconColor: const Color(0xFF2F80ED),
                      ),
                    ],
                  ),
              ],
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseHeaderActionButton(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(expenseActiveTabProvider);
    String label = 'Record';
    IconData icon = LucideIcons.plus;
    VoidCallback onTap = () => _openExpenseModal(context, const RecordExpenseModal());

    switch (activeTab) {
      case 1:
        label = 'Add Subs';
        icon = LucideIcons.plus;
        onTap = () => _openExpenseModal(context, const AddRecurringSubscriptionModal());
        break;
      case 2:
        label = 'Set Budget';
        icon = LucideIcons.sliders;
        onTap = () => _openExpenseModal(context, const SetTeamBudgetModal());
        break;
      case 3:
        label = 'Lodge Claim';
        icon = LucideIcons.filePlus;
        onTap = () => _openExpenseModal(context, const LodgeStaffClaimModal());
        break;
      default:
        label = 'Record';
        icon = LucideIcons.plus;
        onTap = () => _openExpenseModal(context, const RecordExpenseModal());
        break;
    }

    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 11, color: const Color(0xFF15803D)),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openExpenseModal(BuildContext context, Widget modal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => modal,
    );
  }

  PopupMenuItem<String> _buildNotificationItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    return PopupMenuItem<String>(
      enabled: false,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.darkText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModulePill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModulePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _PointsChip extends ConsumerWidget {
  const _PointsChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    return InkWell(
      onTap: () {
        ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.payments, AppRoute.marketing);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 10 : 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.yellow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.coins, color: AppColors.yellow, size: 16),
            SizedBox(width: 6),
            Text(
              '1,000 Pts',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
