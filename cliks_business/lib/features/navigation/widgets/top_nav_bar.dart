import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../widgets/modals/finance_modals.dart';
import '../../billing/providers/expenses_provider.dart';
import '../../billing/providers/mobile_pos_header_provider.dart';
import 'macos_right_utility_rail.dart';
import 'macos_account_menu_card.dart';
import 'macos_showroom_menu_card.dart';
import '../../../data/account_provider.dart';

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
    final isMacOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    final isLinux = !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
    final isDesktopPlatform =
        isMacOS || isWindows || isLinux || (kIsWeb && isDesktop);
    final isProfileModule = navigation.currentModule == AppModule.profile;
    final headerColor = (!isDesktop && isProfileModule)
        ? AppColors.primaryGreen
        : AppColors.headerBackground;

    if (isDesktopPlatform) {
      return _buildMacOSNavBar(context, ref, isDesktop, navigation);
    }

    if (_isSearchExpanded && !isDesktop) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: headerColor),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: Colors.white,
                size: 24,
              ),
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
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      color: Colors.white70,
                      size: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        LucideIcons.x,
                        color: Colors.white70,
                        size: 16,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _isSearchExpanded = false);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    hintText: 'Search transactions, bills...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
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
        right: isDesktop ? 0 : 4,
      ),
      decoration: BoxDecoration(color: headerColor),
      child: Row(
        children: [
          // Logo and Menu section
          Expanded(
            child: Row(
              children: [
                if (!isDesktop && navigation.currentModule != AppModule.profile)
                  Builder(
                    builder: (ctx) => IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(
                        LucideIcons.menu,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    ),
                  ),
                if (!isDesktop) const SizedBox(width: 2),
                Flexible(
                  child: InkWell(
                    onTap: () => ref
                        .read(navigationProvider.notifier)
                        .setModuleAndRoute(AppModule.books, AppRoute.dashboard),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          AppRoute.simpleBilling,
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
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Image.asset(
                              'assets/images/icon.png',
                              width: 22,
                              height: 22,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (!isDesktop && navigation.currentRoute == AppRoute.pos)
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                final posHeader =
                                    ref.read(mobilePosHeaderProvider);
                                posHeader.onOpenWarehousePicker?.call();
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Point of Sale (POS)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            ref
                                                .watch(mobilePosHeaderProvider)
                                                .selectedWarehouse,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          LucideIcons.chevronDown,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: Text(
                              () {
                                switch (navigation.currentRoute) {
                                  case AppRoute.people:
                                    return 'People';
                                  case AppRoute.wallet:
                                    return 'Wallet';
                                  case AppRoute.transaction:
                                    return 'Transaction';
                                  case AppRoute.segregation:
                                    return 'Segregation';
                                  case AppRoute.splitCollect:
                                    return 'Split and Collect';
                                  case AppRoute.planner:
                                    return 'Planner';
                                  case AppRoute.accounting:
                                    return 'Accounting';
                                  case AppRoute.expenses:
                                    return 'Expenses';
                                  case AppRoute.gst:
                                    return 'GST Compliance';
                                  case AppRoute.billing:
                                    return 'Sales Invoice';
                                  case AppRoute.simpleBilling:
                                    return 'Simple Billing';
                                  case AppRoute.sales:
                                    return 'Sales Orders';
                                  case AppRoute.customers:
                                    return 'Customers';
                                  case AppRoute.returns:
                                    return 'Returns';
                                  case AppRoute.purchase:
                                    return 'Purchase Invoice';
                                  case AppRoute.suppliers:
                                    return 'Suppliers';
                                  case AppRoute.products:
                                    return 'Products';
                                  case AppRoute.stock:
                                    return 'Stock & Inventory';
                                  case AppRoute.warehouse:
                                    return 'Warehouse';
                                  case AppRoute.inventory:
                                    return 'Inventory';
                                  case AppRoute.pos:
                                    return 'Point of Sale (POS)';
                                  case AppRoute.reports:
                                    return 'Reports & Analytics';
                                  case AppRoute.marketing:
                                    return 'Marketing Hub';
                                  case AppRoute.barcodeGen:
                                    return 'Barcode Generator';
                                  case AppRoute.auditHub:
                                    return 'Audit Hub';
                                  case AppRoute.fintech:
                                    return 'Fintech';
                                  case AppRoute.payroll:
                                  case AppRoute.allocateEmployeeLoan:
                                  case AppRoute.processMonthlyPayroll:
                                    return 'Payroll';
                                  case AppRoute.attendance:
                                  case AppRoute.manualPunchEntry:
                                  case AppRoute.regularizeMissedPunch:
                                    return 'Attendance';
                                  case AppRoute.staff:
                                    return 'Staff';
                                  case AppRoute.hr:
                                    return 'Human Resources';
                                  case AppRoute.betaClub:
                                    return 'Partner Launch Desk';
                                  case AppRoute.storage:
                                    return 'Storage';
                                  default:
                                    return 'Cliks Business';
                                }
                              }(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 20 : 16.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
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

          if (isDesktop) ...[
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
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search analytics, people or documents...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.search,
                              color: Colors.white70,
                              size: 18,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                LucideIcons.x,
                                color: Colors.white70,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _isSearchExpanded = false),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      )
                    : Container(
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
                              isActive:
                                  navigation.currentModule == AppModule.books,
                              onTap: () => ref
                                  .read(navigationProvider.notifier)
                                  .setModuleAndRoute(
                                    AppModule.books,
                                    AppRoute.dashboard,
                                  ),
                            ),
                            _ModulePill(
                              label: 'Payments',
                              isActive: navigation.currentModule ==
                                  AppModule.payments,
                              onTap: () => ref
                                  .read(navigationProvider.notifier)
                                  .setModuleAndRoute(
                                    AppModule.payments,
                                    AppRoute.people,
                                  ),
                            ),
                            _ModulePill(
                              label: 'Social',
                              isActive:
                                  navigation.currentModule == AppModule.social,
                              onTap: () => ref
                                  .read(navigationProvider.notifier)
                                  .setModuleAndRoute(
                                    AppModule.social,
                                    AppRoute.betaClub,
                                  ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const Spacer(),
          ] else ...[
            const SizedBox(width: 4),
          ],

          // Right-side Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (navigation.currentRoute == AppRoute.expenses) ...[
                _buildExpenseHeaderActionButton(context, ref),
              ] else ...[
                if (!_isSearchExpanded) ...[
                  // FIN PRO capsule tab - small & sleek, only on Dashboard
                  if (navigation.currentRoute == AppRoute.dashboard) ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(navigationProvider.notifier)
                              .setRoute(AppRoute.auditHub);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.landmark,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'FIN PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                  ],
                  if (isDesktop) const _PointsChip(),
                  if (isDesktop) const SizedBox(width: 8),
                  if (!isDesktop && navigation.currentRoute == AppRoute.pos)
                    _buildPosMobileHeaderActions(ref)
                  else
                    IconButton(
                      visualDensity: isDesktop
                          ? VisualDensity.standard
                          : VisualDensity.compact,
                      padding: EdgeInsets.all(isDesktop ? 8 : 4),
                      constraints: isDesktop
                          ? const BoxConstraints()
                          : const BoxConstraints(minWidth: 34, minHeight: 34),
                      icon: Icon(
                        LucideIcons.search,
                        color: Colors.white,
                        size: isDesktop ? 22 : 20,
                      ),
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
                  AppRoute.simpleBilling,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(isDesktop ? 8 : 4),
                    constraints: isDesktop
                        ? const BoxConstraints()
                        : const BoxConstraints(minWidth: 34, minHeight: 34),
                    icon: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          LucideIcons.bell,
                          color: Colors.white,
                          size: isDesktop ? 22 : 20,
                        ),
                        Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 7,
                              minHeight: 7,
                            ),
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

  Widget _buildMacOSNavBar(
    BuildContext context,
    WidgetRef ref,
    bool isDesktop,
    NavigationState navigation,
  ) {
    final activeAccount = ref.watch(activeAccountProvider);
    final userEmail = activeAccount.email.trim().isNotEmpty
        ? activeAccount.email.trim()
        : '';
    final userDisplayName = userEmail.contains('@')
        ? userEmail.split('@').first
        : (activeAccount.name.isNotEmpty ? activeAccount.name : 'User');

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: AppColors.headerBackground),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left and Right content row
          Row(
            children: [
              // Left: Logo + Brand Name (strictly 'Cliks Business', no section titles)
              InkWell(
                onTap: () => ref
                    .read(navigationProvider.notifier)
                    .setModuleAndRoute(AppModule.books, AppRoute.dashboard),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAFAE3),
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
                    const Text(
                      'Cliks Business',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Showroom selector dropdown pill matching reference screenshot
              const SizedBox(width: 14),
              Consumer(
                builder: (context, ref, _) {
                  final isShowroomMenuOpen =
                      ref.watch(macosShowroomMenuVisibleProvider);
                  final selectedScope =
                      ref.watch(selectedShowroomScopeProvider);
                  final label = selectedScope == 'All Showrooms'
                      ? 'All Showrooms (Consoli...'
                      : '$selectedScope (MAIN-01)';

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(macosBetaAppsVisibleProvider.notifier).state =
                            false;
                        ref.read(macosAccountMenuVisibleProvider.notifier).state =
                            false;
                        ref
                            .read(macosShowroomMenuVisibleProvider.notifier)
                            .update((v) => !v);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        constraints: const BoxConstraints(maxWidth: 195),
                        decoration: BoxDecoration(
                          color: isShowroomMenuOpen
                              ? Colors.white.withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isShowroomMenuOpen
                                ? Colors.white.withValues(alpha: 0.35)
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF34D399),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isShowroomMenuOpen
                                  ? LucideIcons.chevronUp
                                  : LucideIcons.chevronDown,
                              color: Colors.white70,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Right: Action items matching reference image
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Search button
                  _buildMacOSCircleButton(
                    icon: LucideIcons.search,
                    tooltip: 'Search',
                    onTap: () =>
                        setState(() => _isSearchExpanded = !_isSearchExpanded),
                  ),
                  const SizedBox(width: 8),

                  // 2. Notifications Bell button
                  PopupMenuButton<String>(
                    offset: const Offset(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      _buildNotificationItem(
                        title: 'New Invoice Created',
                        subtitle: 'INV-158091 was saved successfully.',
                        time: '2 mins ago',
                        icon: LucideIcons.fileCheck,
                        iconColor: const Color(0xFF166534),
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
                    child: _buildMacOSCircleButton(
                      icon: LucideIcons.bell,
                      tooltip: 'Notifications',
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 3. FIN PRO Capsule button (visible on top right in macOS header)
                  _buildMacOSCapsuleButton(
                    onTap: () {
                      ref
                          .read(navigationProvider.notifier)
                          .setModuleAndRoute(
                            AppModule.books,
                            AppRoute.auditHub,
                          );
                    },
                    tooltip: 'FIN-PRO Audit Hub',
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.landmark,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'FIN PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 4. User Profile Capsule button (ravinew2004 ▾ / ▴)
                  _buildMacOSCapsuleButton(
                    tooltip: 'Account Settings',
                    onTap: () {
                      ref.read(macosBetaAppsVisibleProvider.notifier).state =
                          false;
                      ref.read(macosShowroomMenuVisibleProvider.notifier).state =
                          false;
                      ref
                          .read(macosAccountMenuVisibleProvider.notifier)
                          .update((v) => !v);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.circleUser,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          userDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          ref.watch(macosAccountMenuVisibleProvider)
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 5. Beta Apps View Button
                  _buildMacOSCircleButton(
                    icon: LucideIcons.slidersHorizontal,
                    tooltip: ref.watch(macosBetaAppsVisibleProvider)
                        ? 'Close Toolbar'
                        : 'Open Toolbar',
                    isActive: ref.watch(macosBetaAppsVisibleProvider),
                    onTap: () {
                      ref.read(macosAccountMenuVisibleProvider.notifier).state =
                          false;
                      ref.read(macosShowroomMenuVisibleProvider.notifier).state =
                          false;
                      ref
                          .read(macosBetaAppsVisibleProvider.notifier)
                          .update((v) => !v);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Center: Module Selector (or expanded search input)
          Align(
            alignment: Alignment.center,
            child: _isSearchExpanded
                ? Container(
                    width: 380,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Search analytics, people, documents...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          color: Colors.white70,
                          size: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            color: Colors.white70,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _isSearchExpanded = false);
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMacOSModulePill(
                          label: 'Books',
                          isActive: navigation.currentModule == AppModule.books,
                          onTap: () => ref
                              .read(navigationProvider.notifier)
                              .setModuleAndRoute(
                                AppModule.books,
                                AppRoute.dashboard,
                              ),
                        ),
                        _buildMacOSModulePill(
                          label: 'Payments',
                          isActive:
                              navigation.currentModule == AppModule.payments,
                          onTap: () => ref
                              .read(navigationProvider.notifier)
                              .setModuleAndRoute(
                                AppModule.payments,
                                AppRoute.people,
                              ),
                        ),
                        _buildMacOSModulePill(
                          label: 'Social',
                          isActive:
                              navigation.currentModule == AppModule.social,
                          onTap: () => ref
                              .read(navigationProvider.notifier)
                              .setModuleAndRoute(
                                AppModule.social,
                                AppRoute.betaClub,
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

  Widget _buildMacOSCircleButton({
    required IconData icon,
    String? tooltip,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    final button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.white
                : Colors.black.withValues(alpha: 0.2),
            border: Border.all(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF166534) : Colors.white,
            size: 18,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  Widget _buildMacOSCapsuleButton({
    required Widget child,
    String? tooltip,
    VoidCallback? onTap,
  }) {
    final button = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  Widget _buildMacOSModulePill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F4622) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isActive
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.2,
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseHeaderActionButton(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(expenseActiveTabProvider);
    String label = 'Record';
    IconData icon = LucideIcons.plus;
    VoidCallback onTap = () =>
        _openExpenseModal(context, const RecordExpenseModal());

    switch (activeTab) {
      case 1:
        label = 'Add Subs';
        icon = LucideIcons.plus;
        onTap = () =>
            _openExpenseModal(context, const AddRecurringSubscriptionModal());
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondaryText,
                    ),
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

  Widget _buildPosMobileHeaderActions(WidgetRef ref) {
    final posHeader = ref.watch(mobilePosHeaderProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Settings Button
        InkWell(
          onTap: () => posHeader.onOpenSettings?.call(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.settings,
                  size: 13,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 5),

        // 2. 3-Dot Icon with the 4 POS Actions
        PopupMenuButton<String>(
          tooltip: 'POS Menu',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          elevation: 8,
          position: PopupMenuPosition.under,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  LucideIcons.ellipsisVertical,
                  size: 16,
                  color: Colors.white,
                ),
                if (posHeader.heldCartsCount > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          onSelected: (val) {
            switch (val) {
              case 'warehouse':
                posHeader.onOpenWarehousePicker?.call();
                break;
              case 'hold_carts':
                posHeader.onOpenHeldCarts?.call();
                break;
              case 'history':
                posHeader.onOpenHistory?.call();
                break;
              case 'quick_add':
                posHeader.onQuickAddProduct?.call();
                break;
            }
          },
          itemBuilder: (ctx) => [
            // 1. Select POS Warehouse
            const PopupMenuItem<String>(
              value: 'warehouse',
              height: 40,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.warehouse,
                    size: 15,
                    color: Color(0xFF166534),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Select POS Warehouse',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            // 2. Hold Carts
            PopupMenuItem<String>(
              value: 'hold_carts',
              height: 40,
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.pauseCircle,
                    size: 15,
                    color: Color(0xFFEA580C),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Hold Carts',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  if (posHeader.heldCartsCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${posHeader.heldCartsCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 3. Sales History
            const PopupMenuItem<String>(
              value: 'history',
              height: 40,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.history,
                    size: 15,
                    color: Color(0xFF2563EB),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Sales History',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            // 4. Quick Add Product
            const PopupMenuItem<String>(
              value: 'quick_add',
              height: 40,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.plusCircle,
                    size: 15,
                    color: Color(0xFF166534),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Quick Add Product',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
            letterSpacing: 0.2,
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
        ref
            .read(navigationProvider.notifier)
            .setModuleAndRoute(AppModule.payments, AppRoute.marketing);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 10 : 6,
          vertical: 6,
        ),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
