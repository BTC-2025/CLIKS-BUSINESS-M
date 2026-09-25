import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../payments/widgets/add_money_dialog.dart';
import 'sidebar_utility_rail.dart';
import '../pages/macos_storage_page.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigation = ref.watch(navigationProvider);
    final isMacOS =
        Theme.of(context).platform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (isMacOS) {
      return _buildMacOSSidebar(context, ref, navigation);
    }

    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = (screenWidth * 0.85).clamp(295.0, 315.0);

    return Container(
      width: drawerWidth,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Top section - stays fixed curvy green gradient card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16, 24 + topPadding, 16, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryGreen, Color(0xFF0F5B2E)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE8F5E9,
                              ), // Light green covering the curvy square
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/images/icon.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Cliks Business',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 12),
                      const SidebarUtilityRail(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Scrollable rest of the list (now inline in main ListView)
                if (navigation.currentModule == AppModule.books) ...[
                  // Dashboard Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.dashboard);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: (navigation.currentRoute == AppRoute.dashboard)
                              ? AppColors.primaryGreen.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (navigation.currentRoute == AppRoute.dashboard)
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.layoutDashboard,
                              size: 20,
                              color:
                                  (navigation.currentRoute ==
                                      AppRoute.dashboard)
                                  ? AppColors.primaryGreen
                                  : AppColors.secondaryText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Dashboard',
                                style: TextStyle(
                                  color:
                                      (navigation.currentRoute ==
                                          AppRoute.dashboard)
                                      ? AppColors.primaryGreen
                                      : AppColors.darkText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final scaffold = Scaffold.maybeOf(context);
                        if (scaffold != null && scaffold.isDrawerOpen) {
                          Navigator.pop(context);
                        }
                        ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.newInvoice);
                      },
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text(
                        'Generate Invoice',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  _SidebarExpandable(
                    icon: LucideIcons.wallet,
                    label: 'Finance',
                    isInitiallyExpanded:
                        navigation.currentRoute == AppRoute.accounting ||
                        navigation.currentRoute == AppRoute.expenses ||
                        navigation.currentRoute == AppRoute.gst ||
                        navigation.currentRoute == AppRoute.fintech ||
                        navigation.currentRoute == AppRoute.recordExpense ||
                        navigation.currentRoute == AppRoute.lodgeStaffClaim ||
                        navigation.currentRoute == AppRoute.generateEWayBill ||
                        navigation.currentRoute == AppRoute.generateEInvoice,
                    children: [
                      _SidebarSubItem(
                        icon: LucideIcons.calculator,
                        label: 'Accounting',
                        isSelected:
                            navigation.currentRoute == AppRoute.accounting,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.accounting);
                        },
                      ),
                      _SidebarSubItem(
                        icon: LucideIcons.trendingUp,
                        label: 'Expenses',
                        isSelected:
                            navigation.currentRoute == AppRoute.expenses ||
                            navigation.currentRoute == AppRoute.recordExpense ||
                            navigation.currentRoute == AppRoute.lodgeStaffClaim,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.expenses);
                        },
                      ),
                      _SidebarSubItem(
                        icon: LucideIcons.percent,
                        label: 'Tax',
                        isSelected:
                            navigation.currentRoute == AppRoute.gst ||
                            navigation.currentRoute ==
                                AppRoute.generateEWayBill ||
                            navigation.currentRoute ==
                                AppRoute.generateEInvoice,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.gst);
                        },
                      ),
                      _SidebarSubItem(
                        icon: LucideIcons.cpu,
                        label: 'Fintech',
                        isSelected:
                            navigation.currentRoute == AppRoute.fintech,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.fintech);
                        },
                      ),
                    ],
                  ),
                  _SidebarExpandable(
                    icon: LucideIcons.shoppingCart,
                    label: 'Sales',
                    isInitiallyExpanded:
                        navigation.currentRoute == AppRoute.billing ||
                        navigation.currentRoute == AppRoute.sales ||
                        navigation.currentRoute == AppRoute.customers ||
                        navigation.currentRoute == AppRoute.returns ||
                        navigation.currentRoute == AppRoute.invoiceTemplates ||
                        navigation.currentRoute == AppRoute.newSalesOrder ||
                        navigation.currentRoute == AppRoute.addCustomer ||
                        navigation.currentRoute == AppRoute.newCustomerReturn ||
                        navigation.currentRoute == AppRoute.newSupplierReturn,
                    children: [
                      _SidebarSubItem(
                        label: 'Sales Invoice',
                        isSelected:
                            navigation.currentRoute == AppRoute.billing ||
                            navigation.currentRoute ==
                                AppRoute.invoiceTemplates,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.billing);
                        },
                      ),
                      _SidebarSubItem(
                        label: 'Orders',
                        isSelected:
                            navigation.currentRoute == AppRoute.sales ||
                            navigation.currentRoute == AppRoute.newSalesOrder,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.sales);
                        },
                      ),
                      _SidebarSubItem(
                        label: 'Customers',
                        isSelected:
                            navigation.currentRoute == AppRoute.customers ||
                            navigation.currentRoute == AppRoute.addCustomer,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.customers);
                        },
                      ),
                      _SidebarSubItem(
                        label: 'Returns',
                        isSelected:
                            navigation.currentRoute == AppRoute.returns ||
                            navigation.currentRoute ==
                                AppRoute.newCustomerReturn ||
                            navigation.currentRoute ==
                                AppRoute.newSupplierReturn,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.returns);
                        },
                      ),
                    ],
                  ),
                  _SidebarExpandable(
                    icon: LucideIcons.shoppingBag,
                    label: 'Purchases',
                    isInitiallyExpanded:
                        navigation.currentRoute == AppRoute.purchase,
                    children: [
                      _SidebarSubItem(
                        label: 'Purchase Invoice',
                        isSelected:
                            navigation.currentRoute == AppRoute.purchase,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.purchase);
                        },
                      ),
                      _SidebarSubItem(
                        label: 'Suppliers',
                        isSelected:
                            navigation.currentRoute == AppRoute.suppliers,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.suppliers);
                        },
                      ),
                    ],
                  ),
                  _SidebarExpandable(
                    icon: LucideIcons.box,
                    label: 'Inventory',
                    isInitiallyExpanded:
                        navigation.currentRoute == AppRoute.products ||
                        navigation.currentRoute == AppRoute.stock ||
                        navigation.currentRoute == AppRoute.warehouse,
                    children: [
                      _SidebarSubItem(
                        label: 'Products',
                        isSelected:
                            navigation.currentRoute == AppRoute.products,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.products);
                        },
                      ),
                      _SidebarSubItem(
                        label: 'Stock',
                        isSelected: navigation.currentRoute == AppRoute.stock,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.stock);
                        },
                      ),
                      _SidebarSubItem(
                        label: 'Warehouse',
                        isSelected:
                            navigation.currentRoute == AppRoute.warehouse,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.warehouse);
                        },
                      ),
                    ],
                  ),
                  _SidebarExpandable(
                    icon: LucideIcons.users,
                    label: 'HR',
                    isInitiallyExpanded:
                        navigation.currentRoute == AppRoute.staff ||
                        navigation.currentRoute == AppRoute.attendance ||
                        navigation.currentRoute == AppRoute.payroll ||
                        navigation.currentRoute == AppRoute.hr,
                    children: [
                      _SidebarSubItem(
                        label: 'Staff',
                        isSelected:
                            navigation.currentRoute == AppRoute.staff ||
                            navigation.currentRoute == AppRoute.hr,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.staff);
                        },
                      ),
                      _SidebarSubItem(
                        label: 'Attendance',
                        isSelected:
                            navigation.currentRoute == AppRoute.attendance,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.attendance);
                        },
                      ),
                      _SidebarSubItem(
                        label: 'Payroll',
                        isSelected: navigation.currentRoute == AppRoute.payroll,
                        onTap: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.payroll);
                        },
                      ),
                    ],
                  ),
                  _SidebarItem(
                    icon: LucideIcons.monitor,
                    label: 'POS Billing',
                    isSelected: navigation.currentRoute == AppRoute.pos,
                    onTap: () {
                      final scaffold = Scaffold.maybeOf(context);
                      if (scaffold != null && scaffold.isDrawerOpen) {
                        Navigator.pop(context);
                      }
                      ref
                          .read(navigationProvider.notifier)
                          .setRoute(AppRoute.pos);
                    },
                  ),
                  _SidebarItem(
                    icon: LucideIcons.receiptText,
                    label: 'Simple Billing',
                    isSelected:
                        navigation.currentRoute == AppRoute.simpleBilling,
                    onTap: () {
                      final scaffold = Scaffold.maybeOf(context);
                      if (scaffold != null && scaffold.isDrawerOpen) {
                        Navigator.pop(context);
                      }
                      ref
                          .read(navigationProvider.notifier)
                          .setRoute(AppRoute.simpleBilling);
                    },
                  ),
                  _SidebarItem(
                    icon: LucideIcons.lineChart,
                    label: 'Reports',
                    isSelected: navigation.currentRoute == AppRoute.reports,
                    onTap: () {
                      final scaffold = Scaffold.maybeOf(context);
                      if (scaffold != null && scaffold.isDrawerOpen) {
                        Navigator.pop(context);
                      }
                      ref
                          .read(navigationProvider.notifier)
                          .setRoute(AppRoute.reports);
                    },
                  ),
                  _SidebarItem(
                    icon: LucideIcons.barcode,
                    label: 'Barcode Gen',
                    isSelected: navigation.currentRoute == AppRoute.barcodeGen,
                    onTap: () {
                      final scaffold = Scaffold.maybeOf(context);
                      if (scaffold != null && scaffold.isDrawerOpen) {
                        Navigator.pop(context);
                      }
                      ref
                          .read(navigationProvider.notifier)
                          .setRoute(AppRoute.barcodeGen);
                    },
                  ),
                  _SidebarItem(
                    icon: LucideIcons.megaphone,
                    label: 'Marketing',
                    isSelected: navigation.currentRoute == AppRoute.marketing,
                    onTap: () {
                      final scaffold = Scaffold.maybeOf(context);
                      if (scaffold != null && scaffold.isDrawerOpen) {
                        Navigator.pop(context);
                      }
                      ref
                          .read(navigationProvider.notifier)
                          .setRoute(AppRoute.marketing);
                    },
                  ),
                  _SidebarItem(
                    icon: LucideIcons.sparkles,
                    label: 'Refer & Earn',
                    isSelected: navigation.currentRoute == AppRoute.referral,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.referral),
                  ),
                ] else if (navigation.currentModule == AppModule.payments) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AddMoneyDialog(),
                        );
                      },
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text(
                        'Add Money',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  _SidebarItem(
                    icon: LucideIcons.users,
                    label: 'People',
                    isSelected: navigation.currentRoute == AppRoute.people,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.people),
                  ),
                  _SidebarItem(
                    icon: LucideIcons.history,
                    label: 'Transaction',
                    isSelected: navigation.currentRoute == AppRoute.transaction,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.transaction),
                  ),
                  _SidebarItem(
                    icon: LucideIcons.split,
                    label: 'Segregation',
                    isSelected: navigation.currentRoute == AppRoute.segregation,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.segregation),
                  ),
                  _SidebarItem(
                    icon: LucideIcons.activity,
                    label: 'Split & Collect',
                    isSelected:
                        navigation.currentRoute == AppRoute.splitCollect,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.splitCollect),
                  ),
                  _SidebarItem(
                    icon: LucideIcons.calendarDays,
                    label: 'Planner',
                    isSelected: navigation.currentRoute == AppRoute.planner,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.planner),
                  ),
                  _SidebarItem(
                    icon: LucideIcons.sparkles,
                    label: 'Refer & Earn',
                    isSelected: navigation.currentRoute == AppRoute.referral,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.referral),
                  ),
                ] else if (navigation.currentModule == AppModule.social) ...[
                  _SidebarItem(
                    icon: LucideIcons.userCheck,
                    label: 'PARTNER LAUNCH DESK',
                    isSelected: navigation.currentRoute == AppRoute.betaClub,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.betaClub),
                  ),
                  _SidebarItem(
                    icon: LucideIcons.trendingUp,
                    label: 'Trading Docs',
                    isSelected: navigation.currentRoute == AppRoute.tradingDocs,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.tradingDocs),
                  ),
                  _SidebarItem(
                    icon: LucideIcons.sparkles,
                    label: 'Refer & Earn',
                    isSelected: navigation.currentRoute == AppRoute.referral,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.referral),
                  ),
                ] else if (navigation.currentModule == AppModule.profile) ...[
                  _SidebarItem(
                    icon: LucideIcons.user,
                    label: 'Account Profile',
                    isSelected: navigation.currentRoute == AppRoute.profile,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.profile),
                  ),
                ],
              ],
            ),
          ),
          const _MobileSidebarBottomFixed(),
        ],
      ),
    );
  }

  Widget _buildMacOSSidebar(
    BuildContext context,
    WidgetRef ref,
    NavigationState navigation,
  ) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFFF0FDF4),
        border: Border(right: BorderSide(color: Color(0xFFDCF2E4))),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                if (navigation.currentModule == AppModule.books) ...[
                  // 1. Dashboard Pill
                  _buildMacOSItem(
                    icon: LucideIcons.layoutGrid,
                    label: 'Dashboard',
                    isSelected: navigation.currentRoute == AppRoute.dashboard,
                    onTap: () {
                      ref
                          .read(navigationProvider.notifier)
                          .setRoute(AppRoute.dashboard);
                    },
                  ),

                  const SizedBox(height: 6),

                  // 2. + Generate Invoice Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.newInvoice);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF166534),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.plus,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Generate Invoice',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 3. Expandable Groups
                  _buildMacOSExpandable(
                    icon: LucideIcons.banknote,
                    label: 'Finance',
                    isInitiallyExpanded: [
                      AppRoute.accounting,
                      AppRoute.expenses,
                      AppRoute.gst,
                      AppRoute.recordExpense,
                      AppRoute.lodgeStaffClaim,
                      AppRoute.generateEWayBill,
                      AppRoute.generateEInvoice,
                    ].contains(navigation.currentRoute),
                    children: [
                      _buildMacOSSubItem(
                        icon: LucideIcons.calculator,
                        label: 'Accounting',
                        isSelected:
                            navigation.currentRoute == AppRoute.accounting,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.accounting),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.trendingUp,
                        label: 'Expenses',
                        isSelected:
                            navigation.currentRoute == AppRoute.expenses ||
                            navigation.currentRoute == AppRoute.recordExpense ||
                            navigation.currentRoute == AppRoute.lodgeStaffClaim,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.expenses),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.percent,
                        label: 'Tax',
                        isSelected:
                            navigation.currentRoute == AppRoute.gst ||
                            navigation.currentRoute ==
                                AppRoute.generateEWayBill ||
                            navigation.currentRoute ==
                                AppRoute.generateEInvoice,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.gst),
                      ),
                    ],
                  ),

                  _buildMacOSExpandable(
                    icon: LucideIcons.shoppingCart,
                    label: 'Sales',
                    isInitiallyExpanded: [
                      AppRoute.billing,
                      AppRoute.sales,
                      AppRoute.customers,
                      AppRoute.returns,
                      AppRoute.newSalesOrder,
                      AppRoute.addCustomer,
                      AppRoute.invoiceTemplates,
                      AppRoute.newCustomerReturn,
                      AppRoute.newSupplierReturn,
                    ].contains(navigation.currentRoute),
                    children: [
                      _buildMacOSSubItem(
                        icon: LucideIcons.receipt,
                        label: 'Sales Invoices',
                        isSelected:
                            navigation.currentRoute == AppRoute.billing ||
                            navigation.currentRoute ==
                                AppRoute.invoiceTemplates,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.billing),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.fileSpreadsheet,
                        label: 'Sales Orders',
                        isSelected:
                            navigation.currentRoute == AppRoute.sales ||
                            navigation.currentRoute == AppRoute.newSalesOrder,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.sales),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.users,
                        label: 'Customers',
                        isSelected:
                            navigation.currentRoute == AppRoute.customers ||
                            navigation.currentRoute == AppRoute.addCustomer,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.customers),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.rotateCcw,
                        label: 'Returns',
                        isSelected:
                            navigation.currentRoute == AppRoute.returns ||
                            navigation.currentRoute ==
                                AppRoute.newCustomerReturn,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.returns),
                      ),
                    ],
                  ),

                  _buildMacOSExpandable(
                    icon: LucideIcons.shoppingBag,
                    label: 'Purchases',
                    isInitiallyExpanded: [
                      AppRoute.purchase,
                      AppRoute.suppliers,
                      AppRoute.newPO,
                      AppRoute.newPurchaseBill,
                      AppRoute.purchaseReturn,
                      AppRoute.registerSupplier,
                    ].contains(navigation.currentRoute),
                    children: [
                      _buildMacOSSubItem(
                        icon: LucideIcons.receiptText,
                        label: 'Purchase Invoices',
                        isSelected:
                            navigation.currentRoute == AppRoute.purchase ||
                            navigation.currentRoute == AppRoute.newPurchaseBill,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.purchase),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.truck,
                        label: 'Suppliers',
                        isSelected:
                            navigation.currentRoute == AppRoute.suppliers ||
                            navigation.currentRoute ==
                                AppRoute.registerSupplier,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.suppliers),
                      ),
                    ],
                  ),

                  _buildMacOSExpandable(
                    icon: LucideIcons.store,
                    label: 'Inventory',
                    isInitiallyExpanded: [
                      AppRoute.products,
                      AppRoute.stock,
                      AppRoute.warehouse,
                      AppRoute.inventory,
                      AppRoute.registerProduct,
                      AppRoute.adjustStock,
                      AppRoute.warehouseTransfer,
                      AppRoute.registerWarehouse,
                      AppRoute.goodsInwardReceipt,
                      AppRoute.interWarehouseTransfer,
                      AppRoute.secureAuditExport,
                      AppRoute.recordAccountingEntry,
                    ].contains(navigation.currentRoute),
                    children: [
                      _buildMacOSSubItem(
                        icon: LucideIcons.package,
                        label: 'Products',
                        isSelected:
                            navigation.currentRoute == AppRoute.products ||
                            navigation.currentRoute == AppRoute.registerProduct,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.products),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.boxes,
                        label: 'Stock & Inventory',
                        isSelected:
                            navigation.currentRoute == AppRoute.stock ||
                            navigation.currentRoute == AppRoute.adjustStock,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.stock),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.warehouse,
                        label: 'Warehouse',
                        isSelected:
                            navigation.currentRoute == AppRoute.warehouse ||
                            navigation.currentRoute ==
                                AppRoute.registerWarehouse,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.warehouse),
                      ),
                    ],
                  ),

                  _buildMacOSExpandable(
                    icon: LucideIcons.userCheck,
                    label: 'HR',
                    isInitiallyExpanded: [
                      AppRoute.staff,
                      AppRoute.attendance,
                      AppRoute.payroll,
                      AppRoute.hr,
                      AppRoute.allocateEmployeeLoan,
                      AppRoute.processMonthlyPayroll,
                    ].contains(navigation.currentRoute),
                    children: [
                      _buildMacOSSubItem(
                        icon: LucideIcons.user,
                        label: 'Staff',
                        isSelected:
                            navigation.currentRoute == AppRoute.staff ||
                            navigation.currentRoute == AppRoute.hr,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.staff),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.calendarCheck,
                        label: 'Attendance',
                        isSelected:
                            navigation.currentRoute == AppRoute.attendance,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.attendance),
                      ),
                      _buildMacOSSubItem(
                        icon: LucideIcons.fileText,
                        label: 'Payroll',
                        isSelected:
                            navigation.currentRoute == AppRoute.payroll ||
                            navigation.currentRoute ==
                                AppRoute.allocateEmployeeLoan ||
                            navigation.currentRoute ==
                                AppRoute.processMonthlyPayroll,
                        onTap: () => ref
                            .read(navigationProvider.notifier)
                            .setRoute(AppRoute.payroll),
                      ),
                    ],
                  ),

                  _buildMacOSItem(
                    icon: LucideIcons.monitor,
                    label: 'POS Billing',
                    isSelected: navigation.currentRoute == AppRoute.pos,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.pos),
                  ),

                  _buildMacOSItem(
                    icon: LucideIcons.receiptText,
                    label: 'Simple Billing',
                    isSelected:
                        navigation.currentRoute == AppRoute.simpleBilling,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.simpleBilling),
                  ),

                  _buildMacOSItem(
                    icon: LucideIcons.lineChart,
                    label: 'Reports',
                    isSelected: navigation.currentRoute == AppRoute.reports,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.reports),
                  ),

                  _buildMacOSItem(
                    icon: LucideIcons.barcode,
                    label: 'Barcode Gen',
                    isSelected: navigation.currentRoute == AppRoute.barcodeGen,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.barcodeGen),
                  ),

                  _buildMacOSItem(
                    icon: LucideIcons.megaphone,
                    label: 'Marketing',
                    isSelected: navigation.currentRoute == AppRoute.marketing,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.marketing),
                  ),

                  _buildMacOSItem(
                    icon: LucideIcons.briefcase,
                    label: 'FIN-PRO Audit Hub',
                    isSelected: navigation.currentRoute == AppRoute.auditHub,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.auditHub),
                  ),

                  _buildMacOSItem(
                    icon: LucideIcons.sparkles,
                    label: 'Refer & Earn',
                    isSelected: navigation.currentRoute == AppRoute.referral,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.referral),
                  ),
                ] else if (navigation.currentModule == AppModule.payments) ...[
                  // + Add Money Button (for Payments module)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => const AddMoneyDialog(),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF166534),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.plus,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Money',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  _buildMacOSItem(
                    icon: LucideIcons.users,
                    label: 'People',
                    isSelected: navigation.currentRoute == AppRoute.people,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.people),
                  ),
                  _buildMacOSItem(
                    icon: LucideIcons.history,
                    label: 'Transaction',
                    isSelected: navigation.currentRoute == AppRoute.transaction,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.transaction),
                  ),
                  _buildMacOSItem(
                    icon: LucideIcons.split,
                    label: 'Segregation',
                    isSelected: navigation.currentRoute == AppRoute.segregation,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.segregation),
                  ),
                  _buildMacOSItem(
                    icon: LucideIcons.activity,
                    label: 'Split & Collect',
                    isSelected:
                        navigation.currentRoute == AppRoute.splitCollect,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.splitCollect),
                  ),
                  _buildMacOSItem(
                    icon: LucideIcons.calendarDays,
                    label: 'Planner',
                    isSelected: navigation.currentRoute == AppRoute.planner,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.planner),
                  ),
                  _buildMacOSItem(
                    icon: LucideIcons.sparkles,
                    label: 'Refer & Earn',
                    isSelected: navigation.currentRoute == AppRoute.referral,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.referral),
                  ),
                ] else if (navigation.currentModule == AppModule.social) ...[
                  _buildMacOSItem(
                    icon: LucideIcons.userCheck,
                    label: 'Partner Launch Desk',
                    isSelected: navigation.currentRoute == AppRoute.betaClub,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.betaClub),
                  ),
                  _buildMacOSItem(
                    icon: LucideIcons.fileText,
                    label: 'Trading Docs',
                    isSelected: navigation.currentRoute == AppRoute.tradingDocs,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.tradingDocs),
                  ),
                  _buildMacOSItem(
                    icon: LucideIcons.sparkles,
                    label: 'Refer & Earn',
                    isSelected: navigation.currentRoute == AppRoute.referral,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.referral),
                  ),
                ] else if (navigation.currentModule == AppModule.profile) ...[
                  _buildMacOSItem(
                    icon: LucideIcons.user,
                    label: 'Account Profile',
                    isSelected: navigation.currentRoute == AppRoute.profile,
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setRoute(AppRoute.profile),
                  ),
                ],
              ],
            ),
          ),

          // Bottom Area (Storage, Badges, Settings, Help)
          _buildMacOSBottomSection(context, ref, navigation),
        ],
      ),
    );
  }

  Widget _buildMacOSBottomSection(
    BuildContext context,
    WidgetRef ref,
    NavigationState navigation,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Storage Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MacOsStoragePage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.cloud,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Storage',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '921.00 MB of 1.00 GB used',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFC7D2FE),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '90%',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. Dual Badges Capsule (Subscription Button)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1938),
            borderRadius: BorderRadius.circular(12),
            border: navigation.currentRoute == AppRoute.subscription
                ? Border.all(color: const Color(0xFFF2C94C), width: 1.5)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Tooltip(
              message: 'Subscription Plans',
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ref
                      .read(navigationProvider.notifier)
                      .setRoute(AppRoute.subscription);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Badge 1: 293 DAYS BOOK ELITE
                      _buildMacOSDaysBadge(
                        '293',
                        'DAYS',
                        'BOOK',
                        'ELITE',
                        const Color(0xFFF2C94C),
                      ),
                      Container(width: 1, height: 26, color: Colors.white24),
                      // Badge 2: 354 DAYS FIN-PRO FIRM
                      _buildMacOSDaysBadge(
                        '354',
                        'DAYS',
                        'FIN-PRO',
                        'FIRM',
                        const Color(0xFFF2C94C),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // 3. Settings Item
        _buildMacOSItem(
          icon: LucideIcons.settings,
          label: 'Settings',
          isSelected: navigation.currentRoute == AppRoute.settings,
          onTap: () {
            ref
                .read(navigationProvider.notifier)
                .setModuleAndRoute(AppModule.books, AppRoute.settings);
          },
          trailing: const Icon(
            LucideIcons.chevronRight,
            size: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),

        // 4. Help & Support Item
        _buildMacOSItem(
          icon: LucideIcons.helpCircle,
          label: 'Help & Support',
          isSelected: navigation.currentRoute == AppRoute.help,
          onTap: () {
            ref
                .read(navigationProvider.notifier)
                .setModuleAndRoute(AppModule.books, AppRoute.help);
          },
          trailing: const Icon(
            LucideIcons.chevronRight,
            size: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMacOSDaysBadge(
    String days,
    String daysLabel,
    String line1,
    String line2,
    Color accentColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF111C38),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                days,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  height: 1,
                ),
              ),
              Text(
                daysLabel,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 6,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              line1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 9.5,
                height: 1.1,
              ),
            ),
            Text(
              line2,
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 9.5,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacOSItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return _MacOSSidebarTile(
      icon: icon,
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      trailing: trailing,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
    );
  }

  Widget _buildMacOSExpandable({
    required IconData icon,
    required String label,
    required List<Widget> children,
    bool isInitiallyExpanded = false,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final expandedStates = ref.watch(sidebarExpandedProvider);
        final isExpanded = expandedStates[label] ?? isInitiallyExpanded;
        return _MacOSExpandableGroup(
          icon: icon,
          label: label,
          isExpanded: isExpanded,
          onToggle: () {
            ref
                .read(sidebarExpandedProvider.notifier)
                .update((state) => {...state, label: !isExpanded});
          },
          children: children,
        );
      },
    );
  }

  Widget _buildMacOSSubItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return _MacOSSidebarTile(
      icon: icon,
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class _MacOSSidebarTile extends StatefulWidget {
  final IconData? icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const _MacOSSidebarTile({
    this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.trailing,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
  });

  @override
  State<_MacOSSidebarTile> createState() => _MacOSSidebarTileState();
}

class _MacOSSidebarTileState extends State<_MacOSSidebarTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isSelected || _isHovered || _isPressed;

    final Color bgColor;
    if (widget.isSelected) {
      bgColor = const Color(0xFFDCF2E4);
    } else if (_isHovered || _isPressed) {
      bgColor = const Color(0xFFDCF2E4).withValues(alpha: 0.65);
    } else {
      bgColor = Colors.transparent;
    }

    final Color contentColor = isHighlighted
        ? const Color(0xFF166534)
        : const Color(0xFF111827);
    final Color iconColor = isHighlighted
        ? const Color(0xFF166534)
        : const Color(0xFF374151);

    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // Curved indicator bar on the left edge when touched or selected
                if (isHighlighted)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? const Color(0xFF166534)
                            : const Color(0xFF166534).withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: widget.padding,
                  child: Row(
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: iconColor),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            color: contentColor,
                            fontWeight: isHighlighted
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (widget.trailing != null) widget.trailing!,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MacOSExpandableGroup extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _MacOSExpandableGroup({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  State<_MacOSExpandableGroup> createState() => _MacOSExpandableGroupState();
}

class _MacOSExpandableGroupState extends State<_MacOSExpandableGroup> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isExpanded || _isHovered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onToggle,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? const Color(0xFFDCF2E4).withValues(alpha: 0.35)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 18,
                      color: isHighlighted
                          ? const Color(0xFF166534)
                          : const Color(0xFF4B5563),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: isHighlighted
                              ? const Color(0xFF166534)
                              : const Color(0xFF111827),
                          fontWeight: isHighlighted
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    Icon(
                      widget.isExpanded
                          ? LucideIcons.chevronDown
                          : LucideIcons.chevronRight,
                      size: 16,
                      color: isHighlighted
                          ? const Color(0xFF166534)
                          : const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 14),
            child: Column(children: widget.children),
          ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isHeader;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.trailing,
    this.isHeader = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = widget.trailing;
    final isHighlighted = widget.isSelected || _isHovered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: () {
            widget.onTap();
            if (!widget.isHeader && Scaffold.of(context).isDrawerOpen) {
              Navigator.of(context).pop();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFFDCF2E4)
                  : (_isHovered
                        ? const Color(0xFFDCF2E4).withValues(alpha: 0.5)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 19,
                  color: isHighlighted
                      ? const Color(0xFF166534)
                      : AppColors.secondaryText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: isHighlighted
                          ? const Color(0xFF166534)
                          : AppColors.darkText,
                      fontWeight: widget.isSelected
                          ? FontWeight.w700
                          : (_isHovered ? FontWeight.w600 : FontWeight.w500),
                      fontSize: 13.5,
                    ),
                  ),
                ),
                ?trailingWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final sidebarExpandedProvider = StateProvider<Map<String, bool>>((ref) => {});

class _SidebarExpandable extends ConsumerWidget {
  final IconData icon;
  final String label;
  final List<Widget> children;
  final bool isInitiallyExpanded;

  const _SidebarExpandable({
    required this.icon,
    required this.label,
    required this.children,
    this.isInitiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedStates = ref.watch(sidebarExpandedProvider);
    final isExpanded = expandedStates[label] ?? isInitiallyExpanded;

    return Column(
      children: [
        _SidebarItem(
          icon: icon,
          label: label,
          isSelected: false,
          isHeader: true,
          onTap: () {
            ref
                .read(sidebarExpandedProvider.notifier)
                .update((state) => {...state, label: !isExpanded});
          },
          trailing: Icon(
            isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
            size: 16,
            color: AppColors.secondaryText,
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(children: children),
          ),
      ],
    );
  }
}

class _SidebarSubItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _SidebarSubItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  State<_SidebarSubItem> createState() => _SidebarSubItemState();
}

class _SidebarSubItemState extends State<_SidebarSubItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isSelected || _isHovered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: () {
            widget.onTap();
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.of(context).pop();
            }
          },
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFFDCF2E4)
                  : (_isHovered
                        ? const Color(0xFFDCF2E4).withValues(alpha: 0.5)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 15,
                    color: isHighlighted
                        ? const Color(0xFF166534)
                        : AppColors.secondaryText,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: isHighlighted
                          ? const Color(0xFF166534)
                          : AppColors.secondaryText,
                      fontSize: 13,
                      fontWeight: widget.isSelected
                          ? FontWeight.w700
                          : (_isHovered ? FontWeight.w600 : FontWeight.w500),
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
}

class _MobileSidebarBottomFixed extends ConsumerWidget {
  const _MobileSidebarBottomFixed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigation = ref.watch(navigationProvider);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 10 + bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(top: BorderSide(color: Color(0xFFDCF2E4), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Storage Card
          _buildStorageCard(context, ref),
          const SizedBox(height: 8),

          // 2. Dual Badges Capsule (Subscription Button)
          _buildSubscriptionBadgesCard(context, ref, navigation),
          const SizedBox(height: 8),

          // 3. Settings Card
          _buildActionCard(
            context: context,
            icon: LucideIcons.settings,
            label: 'Settings',
            onTap: () {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold != null && scaffold.isDrawerOpen) {
                Navigator.pop(context);
              }
              ref.read(navigationProvider.notifier).setRoute(AppRoute.settings);
            },
          ),
          const SizedBox(height: 8),

          // 4. Help & Support Card
          _buildActionCard(
            context: context,
            icon: LucideIcons.helpCircle,
            label: 'Help & Support',
            onTap: () {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold != null && scaffold.isDrawerOpen) {
                Navigator.pop(context);
              }
              ref.read(navigationProvider.notifier).setRoute(AppRoute.help);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          final scaffold = Scaffold.maybeOf(context);
          if (scaffold != null && scaffold.isDrawerOpen) Navigator.pop(context);
          ref.read(navigationProvider.notifier).setRoute(AppRoute.storage);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.cloud, color: Color(0xFF2563EB), size: 17),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Storage',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      '0 KB of 1.00 GB used',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '0%',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionBadgesCard(
    BuildContext context,
    WidgetRef ref,
    NavigationState navigation,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final scaffold = Scaffold.maybeOf(context);
          if (scaffold != null && scaffold.isDrawerOpen) Navigator.pop(context);
          ref.read(navigationProvider.notifier).setRoute(AppRoute.subscription);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1329), // Dark navy
            borderRadius: BorderRadius.circular(16),
            border: navigation.currentRoute == AppRoute.subscription
                ? Border.all(color: const Color(0xFFF59E0B), width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              // Badge 1: 290 DAYS BOOK ELITE
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132247),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 2.2,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '290',
                              style: TextStyle(
                                color: Color(0xFF0B1329),
                                fontWeight: FontWeight.w900,
                                fontSize: 10.5,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'DAYS',
                              style: TextStyle(
                                color: Color(0xFF0B1329),
                                fontWeight: FontWeight.w800,
                                fontSize: 6.5,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'BOOK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              height: 1.1,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'ELITE',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              height: 1.1,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge 2: 351 DAYS FIN-PRO FIRM
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132247),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 2.2,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '351',
                              style: TextStyle(
                                color: Color(0xFF0B1329),
                                fontWeight: FontWeight.w900,
                                fontSize: 10.5,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'DAYS',
                              style: TextStyle(
                                color: Color(0xFF0B1329),
                                fontWeight: FontWeight.w800,
                                fontSize: 6.5,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'FIN-PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              height: 1.1,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'FIRM',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              height: 1.1,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
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
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF334155)),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              const Spacer(),
              const Icon(
                LucideIcons.chevronRight,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
