import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/navigation_provider.dart';
import '../../widgets/calculator/beta_calculator.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_nav_bar.dart';
import 'widgets/macos_right_utility_rail.dart';
import 'widgets/macos_account_menu_card.dart';
import '../billing/pages/billing_page.dart';
import '../billing/pages/simple_billing_page.dart';
import '../people/pages/people_page.dart';
import '../dashboard/dashboard_page.dart';
import '../help/pages/help_page.dart';
import '../payments/pages/rewards_page.dart';
import '../social/pages/trading_docs_page.dart';
import '../social/pages/beta_club_page.dart';
import '../payments/pages/wallet_page.dart';
import '../payments/pages/transaction_page.dart';
import '../payments/pages/segregation_page.dart';
import '../payments/pages/split_collect_page.dart';
import '../payments/pages/planner_page.dart';
import '../payments/pages/referral_page.dart';
import '../profile/pages/profile_page.dart';
import '../settings/pages/settings_page.dart';
import 'pages/macos_storage_page.dart';
import 'pages/mobile_storage_page.dart';
import '../billing/pages/new_invoice_page.dart';
import '../billing/pages/accounting_page.dart';
import '../billing/pages/expenses_page.dart';
import '../billing/pages/gst_page.dart';
import '../billing/pages/orders_page.dart';
import '../billing/pages/customers_page.dart';
import '../billing/pages/returns_page.dart';
import '../billing/pages/products_page.dart';
import '../billing/pages/stock_page.dart';
import '../billing/pages/warehouse_page.dart';
import '../billing/pages/staff_page.dart';
import '../billing/pages/attendance_page.dart';
import '../billing/widgets/attendance_panels.dart';
import '../billing/pages/payroll_page.dart';
import '../billing/widgets/payroll_panels.dart';
import '../billing/pages/pos_page.dart';
import '../billing/pages/reports_page.dart';
import '../billing/pages/marketing_page.dart';
import '../../widgets/modals/finance_modals.dart';
import '../../widgets/modals/sales_modals.dart';
import '../billing/pages/barcode_gen_page.dart';
import '../billing/pages/audit_hub_page.dart';
import '../billing/pages/fintech_page.dart';
import '../billing/pages/subscription_page.dart';
import '../purchases/pages/purchase_invoice_page.dart';
import '../purchases/pages/suppliers_page.dart';
import '../purchases/pages/register_supplier_page.dart';
import '../billing/pages/new_sales_order_page.dart';
import '../../widgets/modals/purchase_modals.dart';
import '../../widgets/modals/inventory_modals.dart';
import '../people/widgets/schedule_reminder_panel.dart';

class ShellLayout extends ConsumerStatefulWidget {
  const ShellLayout({super.key});

  @override
  ConsumerState<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends ConsumerState<ShellLayout> {
  AppModule? _lastModule;
  bool _slideForward = true;
  int _refreshKey = 0;
  double? _splitCalculatorHeight;

  @override
  Widget build(BuildContext context) {
    final navigation = ref.watch(navigationProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isMacOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final isSplitCalculator = !isMacOS && !isDesktop && ref.watch(mobileCalculatorSplitScreenProvider);

    ref.listen(navigationProvider, (prev, next) {
      if (prev != next && ref.read(macosAccountMenuVisibleProvider)) {
        ref.read(macosAccountMenuVisibleProvider.notifier).state = false;
      }
    });

    // Track directional animations
    if (_lastModule != navigation.currentModule) {
      final modules = [
        AppModule.books,
        AppModule.payments,
        AppModule.social,
        AppModule.profile,
      ];
      final prevIndex = _lastModule != null ? modules.indexOf(_lastModule!) : 0;
      final newIndex = modules.indexOf(navigation.currentModule);
      if (prevIndex != -1 && newIndex != -1) {
        _slideForward = newIndex >= prevIndex;
      }
      _lastModule = navigation.currentModule;
    }

    final isOverlay = navigation.currentRoute == AppRoute.newInvoice ||
        navigation.currentRoute == AppRoute.recordExpense ||
        navigation.currentRoute == AppRoute.lodgeStaffClaim ||
        navigation.currentRoute == AppRoute.generateEWayBill ||
        navigation.currentRoute == AppRoute.generateEInvoice ||
        navigation.currentRoute == AppRoute.invoiceTemplates ||
        navigation.currentRoute == AppRoute.newSalesOrder ||
        navigation.currentRoute == AppRoute.addCustomer ||
        navigation.currentRoute == AppRoute.newCustomerReturn ||
        navigation.currentRoute == AppRoute.newSupplierReturn ||
        navigation.currentRoute == AppRoute.newPO ||
        navigation.currentRoute == AppRoute.newPurchaseBill ||
        navigation.currentRoute == AppRoute.purchaseReturn ||
        navigation.currentRoute == AppRoute.registerProduct ||
        navigation.currentRoute == AppRoute.adjustStock ||
        navigation.currentRoute == AppRoute.warehouseTransfer ||
        navigation.currentRoute == AppRoute.registerWarehouse ||
        navigation.currentRoute == AppRoute.goodsInwardReceipt ||
        navigation.currentRoute == AppRoute.interWarehouseTransfer ||
        navigation.currentRoute == AppRoute.secureAuditExport ||
        navigation.currentRoute == AppRoute.recordAccountingEntry ||
        navigation.currentRoute == AppRoute.registerSupplier ||
        navigation.currentRoute == AppRoute.scheduleReturnReminder ||
        navigation.currentRoute == AppRoute.allocateEmployeeLoan ||
        navigation.currentRoute == AppRoute.processMonthlyPayroll ||
        navigation.currentRoute == AppRoute.manualPunchEntry ||
        navigation.currentRoute == AppRoute.regularizeMissedPunch;

    return PopScope(
      canPop: (navigation.currentModule == AppModule.books && navigation.currentRoute == AppRoute.dashboard) && !isOverlay && !isSplitCalculator,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        if (isSplitCalculator) {
          setState(() {
            _splitCalculatorHeight = null;
          });
          ref.read(mobileCalculatorSplitScreenProvider.notifier).state = false;
          return;
        }

        if (isOverlay) {
          final baseRoute = () {
            if (navigation.currentRoute == AppRoute.recordExpense ||
                navigation.currentRoute == AppRoute.lodgeStaffClaim) {
              return AppRoute.expenses;
            }
            if (navigation.currentRoute == AppRoute.generateEWayBill ||
                navigation.currentRoute == AppRoute.generateEInvoice) {
              return AppRoute.gst;
            }
            if (navigation.currentRoute == AppRoute.invoiceTemplates) {
              return AppRoute.billing;
            }
            if (navigation.currentRoute == AppRoute.newSalesOrder) {
              return AppRoute.sales;
            }
            if (navigation.currentRoute == AppRoute.addCustomer) {
              return AppRoute.customers;
            }
            if (navigation.currentRoute == AppRoute.newCustomerReturn ||
                navigation.currentRoute == AppRoute.newSupplierReturn) {
              return AppRoute.returns;
            }
            if (navigation.currentRoute == AppRoute.newPO ||
                navigation.currentRoute == AppRoute.newPurchaseBill ||
                navigation.currentRoute == AppRoute.purchaseReturn) {
              return AppRoute.purchase;
            }
            if (navigation.currentRoute == AppRoute.registerProduct) {
              return AppRoute.products;
            }
            if (navigation.currentRoute == AppRoute.registerSupplier) {
              return AppRoute.suppliers;
            }
            if (navigation.currentRoute == AppRoute.manualPunchEntry ||
                navigation.currentRoute == AppRoute.regularizeMissedPunch) {
              return AppRoute.attendance;
            }
            if (navigation.currentRoute == AppRoute.allocateEmployeeLoan ||
                navigation.currentRoute == AppRoute.processMonthlyPayroll) {
              return AppRoute.payroll;
            }
            if (navigation.currentRoute == AppRoute.adjustStock ||
                navigation.currentRoute == AppRoute.warehouseTransfer ||
                navigation.currentRoute == AppRoute.registerWarehouse ||
                navigation.currentRoute == AppRoute.goodsInwardReceipt ||
                navigation.currentRoute == AppRoute.interWarehouseTransfer ||
                navigation.currentRoute == AppRoute.secureAuditExport ||
                navigation.currentRoute == AppRoute.recordAccountingEntry) {
              return AppRoute.stock;
            }
            if (navigation.currentRoute == AppRoute.newInvoice) {
              return AppRoute.billing;
            }
            return navigation.currentModule == AppModule.payments
                ? AppRoute.people
                : (navigation.currentModule == AppModule.social ? AppRoute.betaClub : AppRoute.dashboard);
          }();
          ref.read(navigationProvider.notifier).setRoute(baseRoute);
          return;
        }

        final mainRoute = () {
          switch (navigation.currentModule) {
            case AppModule.books:
              return AppRoute.dashboard;
            case AppModule.payments:
              return AppRoute.people;
            case AppModule.social:
              return AppRoute.betaClub;
            case AppModule.profile:
              return AppRoute.profile;
          }
        }();

        if (navigation.currentRoute != mainRoute) {
          ref.read(navigationProvider.notifier).setModuleAndRoute(navigation.currentModule, mainRoute);
        } else {
          ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.books, AppRoute.dashboard);
        }
      },
      child: Scaffold(
          body: Stack(
            children: [
              // Main Body Content
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const TopNavBar(),
                    if (isSplitCalculator)
                      _buildTopSectionBar(context, ref, navigation),
                    Expanded(
                      child: Row(
                        children: [
                          if (isDesktop && navigation.currentModule != AppModule.profile) const Sidebar(),
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.primaryGreen,
                              backgroundColor: Colors.white,
                              strokeWidth: 2.5,
                              displacement: 20,
                              onRefresh: () async {
                                setState(() {
                                  _refreshKey++;
                                });
                                await Future.delayed(const Duration(milliseconds: 600));
                              },
                              child: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                },
                                child: () {
                                  final content = () {
                                    final baseRoute = () {
                                      if (navigation.currentRoute == AppRoute.recordExpense ||
                                          navigation.currentRoute == AppRoute.lodgeStaffClaim) {
                                        return AppRoute.expenses;
                                      }
                                      if (navigation.currentRoute == AppRoute.generateEWayBill ||
                                          navigation.currentRoute == AppRoute.generateEInvoice) {
                                        return AppRoute.gst;
                                      }
                                      if (navigation.currentRoute == AppRoute.invoiceTemplates) {
                                        return AppRoute.billing;
                                      }
                                      if (navigation.currentRoute == AppRoute.newSalesOrder) {
                                        return AppRoute.sales;
                                      }
                                      if (navigation.currentRoute == AppRoute.addCustomer) {
                                        return AppRoute.customers;
                                      }
                                      if (navigation.currentRoute == AppRoute.newCustomerReturn ||
                                          navigation.currentRoute == AppRoute.newSupplierReturn) {
                                        return AppRoute.returns;
                                      }
                                      if (navigation.currentRoute == AppRoute.newPO ||
                                          navigation.currentRoute == AppRoute.newPurchaseBill ||
                                          navigation.currentRoute == AppRoute.purchaseReturn) {
                                        return AppRoute.purchase;
                                      }
                                      if (navigation.currentRoute == AppRoute.registerProduct) {
                                        return AppRoute.products;
                                      }
                                      if (navigation.currentRoute == AppRoute.registerSupplier) {
                                        return AppRoute.suppliers;
                                      }
                                      if (navigation.currentRoute == AppRoute.manualPunchEntry ||
                                          navigation.currentRoute == AppRoute.regularizeMissedPunch) {
                                        return AppRoute.attendance;
                                      }
                                      if (navigation.currentRoute == AppRoute.allocateEmployeeLoan ||
                                          navigation.currentRoute == AppRoute.processMonthlyPayroll) {
                                        return AppRoute.payroll;
                                      }
                                      if (navigation.currentRoute == AppRoute.adjustStock ||
                                          navigation.currentRoute == AppRoute.warehouseTransfer ||
                                          navigation.currentRoute == AppRoute.registerWarehouse ||
                                          navigation.currentRoute == AppRoute.goodsInwardReceipt ||
                                          navigation.currentRoute == AppRoute.interWarehouseTransfer ||
                                          navigation.currentRoute == AppRoute.secureAuditExport ||
                                          navigation.currentRoute == AppRoute.recordAccountingEntry) {
                                        return AppRoute.stock;
                                      }
                                      if (navigation.currentRoute == AppRoute.newInvoice) {
                                        return AppRoute.billing;
                                      }
                                      return navigation.currentModule == AppModule.payments
                                          ? AppRoute.people
                                          : (navigation.currentModule == AppModule.social ? AppRoute.betaClub : AppRoute.dashboard);
                                    }();

                                    if (isOverlay) {
                                      return Stack(
                                        key: ValueKey('${navigation.currentRoute}_$_refreshKey'),
                                        children: [
                                          _getPage(baseRoute),
                                          Positioned.fill(
                                            child: ClipRect(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                                child: Container(
                                                  color: Colors.black.withValues(alpha: 0.3),
                                                  child: Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: _getPage(navigation.currentRoute),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return _getPage(navigation.currentRoute);
                                  }();

                                  final renderedPage = isMacOS
                                      ? KeyedSubtree(
                                          key: ValueKey('${navigation.currentRoute}_$_refreshKey'),
                                          child: content,
                                        )
                                      : AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          transitionBuilder: (child, animation) {
                                            final slideAnimation = Tween<Offset>(
                                              begin: _slideForward ? const Offset(0.08, 0) : const Offset(-0.08, 0),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ));
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: slideAnimation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: content,
                                        );

                                  if (isSplitCalculator) {
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final totalHeight = constraints.maxHeight;
                                        final minHeight = 160.0;
                                        final maxHeight = (totalHeight - 100.0).clamp(minHeight, totalHeight);
                                        final calcHeight = (_splitCalculatorHeight ?? (totalHeight * 0.52))
                                            .clamp(minHeight, maxHeight);

                                        return Column(
                                          children: [
                                            Expanded(
                                              child: ClipRect(
                                                child: renderedPage,
                                              ),
                                            ),
                                            SizedBox(
                                              height: calcHeight,
                                              child: _buildMobileSplitCalculator(
                                                context,
                                                ref,
                                                onDragUpdate: (deltaY) {
                                                  setState(() {
                                                    final current = _splitCalculatorHeight ?? calcHeight;
                                                    _splitCalculatorHeight = (current - deltaY).clamp(minHeight, maxHeight);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }

                                  return renderedPage;
                                }(),
                              ),
                            ),
                          ),
                          if (isMacOS && isDesktop && navigation.currentModule != AppModule.profile && ref.watch(macosBetaAppsVisibleProvider))
                            const MacOSRightUtilityRail(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed Bottom Navigation Bar
              if (!isDesktop && !isOverlay && !isSplitCalculator)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildStylishBottomBar(context, ref, navigation),
                ),

              // macOS Top-Right Account Dropdown Menu Overlay
              if (isMacOS && ref.watch(macosAccountMenuVisibleProvider)) ...[
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref.read(macosAccountMenuVisibleProvider.notifier).state = false;
                    },
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  top: 68 + MediaQuery.of(context).padding.top,
                  right: 50,
                  child: const MacOSAccountMenuCard(),
                ),
              ],
            ],
          ),
          drawer: (isDesktop || navigation.currentModule == AppModule.profile) ? null : const Drawer(child: Sidebar()),
        ),
      );
  }

  Widget _buildMobileSplitCalculator(
    BuildContext context,
    WidgetRef ref, {
    void Function(double deltaY)? onDragUpdate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle and header bar
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              onDragUpdate?.call(details.delta.dy);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Center drag pill handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              LucideIcons.calculator,
                              size: 14,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Calculator',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SPLIT VIEW',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // "X" Close Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _splitCalculatorHeight = null;
                          });
                          ref.read(mobileCalculatorSplitScreenProvider.notifier).state = false;
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.x,
                            size: 15,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Calculator Content
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: BetaCalculator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSectionBar(BuildContext context, WidgetRef ref, NavigationState navigation) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTopTab(ref, navigation, AppModule.books, LucideIcons.bookOpen, 'Books'),
            _buildTopTab(ref, navigation, AppModule.payments, LucideIcons.wallet, 'Payments'),
            _buildTopTab(ref, navigation, AppModule.social, LucideIcons.messageCircle, 'Social'),
            _buildTopTab(ref, navigation, AppModule.profile, LucideIcons.user, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTab(WidgetRef ref, NavigationState navigation, AppModule module, IconData icon, String label) {
    final isActive = navigation.currentModule == module;
    return GestureDetector(
      onTap: () => _switchToModule(ref, module),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.secondaryText,
              size: 15,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: isActive
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylishBottomBar(BuildContext context, WidgetRef ref, NavigationState navigation) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? (bottomInset * 0.35).clamp(2.0, 6.0) : 4.0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomTab(ref, navigation, AppModule.books, LucideIcons.bookOpen, 'Books'),
            _buildBottomTab(ref, navigation, AppModule.payments, LucideIcons.wallet, 'Payments'),
            _buildBottomTab(ref, navigation, AppModule.social, LucideIcons.messageCircle, 'Social'),
            _buildBottomTab(ref, navigation, AppModule.profile, LucideIcons.user, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTab(WidgetRef ref, NavigationState navigation, AppModule module, IconData icon, String label) {
    final isActive = navigation.currentModule == module;
    return GestureDetector(
      onTap: () => _switchToModule(ref, module),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.secondaryText,
              size: 20,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(AppRoute route) {
    switch (route) {
      case AppRoute.dashboard:
        return DashboardPage(key: ValueKey(route));
      case AppRoute.meetup:
        return BetaClubPage(key: ValueKey(route));
      case AppRoute.billing:
        return BillingPage(key: ValueKey(route));
      case AppRoute.simpleBilling:
        return SimpleBillingPage(key: ValueKey(route));
      case AppRoute.people:
        return PeoplePage(key: ValueKey(route));
      case AppRoute.help:
        return HelpPage(key: ValueKey(route));
      case AppRoute.rewards:
        return RewardsPage(key: ValueKey(route));
      case AppRoute.tradingDocs:
        return TradingDocsPage(key: ValueKey(route));
      case AppRoute.betaClub:
        return BetaClubPage(key: ValueKey(route));
      case AppRoute.wallet:
        return WalletPage(key: ValueKey(route));
      case AppRoute.transaction:
        return TransactionPage(key: ValueKey(route));
      case AppRoute.segregation:
        return SegregationPage(key: ValueKey(route));
      case AppRoute.splitCollect:
        return SplitCollectPage(key: ValueKey(route));
      case AppRoute.planner:
        return PlannerPage(key: ValueKey(route));
      case AppRoute.referral:
        return ReferralPage(key: ValueKey(route));
      case AppRoute.profile:
        return ProfilePage(key: ValueKey(route));
      case AppRoute.settings:
        return SettingsPage(key: ValueKey(route));
      case AppRoute.storage:
        final isMacOSStorage = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
        return isMacOSStorage
            ? const MacOsStoragePage(key: ValueKey(AppRoute.storage))
            : const MobileStoragePage(key: ValueKey(AppRoute.storage));
      case AppRoute.newInvoice:
        return NewInvoicePage(key: ValueKey(route));
      case AppRoute.accounting:
        return AccountingPage(key: ValueKey(route));
      case AppRoute.expenses:
        return ExpensesPage(key: ValueKey(route));
      case AppRoute.gst:
        return GstPage(key: ValueKey(route));
      case AppRoute.sales:
        return OrdersPage(key: ValueKey(route));
      case AppRoute.customers:
        return CustomersPage(key: ValueKey(route));
      case AppRoute.returns:
        return ReturnsPage(key: ValueKey(route));
      case AppRoute.purchase:
        return PurchaseInvoicePage(key: ValueKey(route));
      case AppRoute.suppliers:
        return SuppliersPage(key: ValueKey(route));
      case AppRoute.registerSupplier:
        return RegisterSupplierPage(key: ValueKey(route));
      case AppRoute.products:
        return ProductsPage(key: ValueKey(route));
      case AppRoute.stock:
        return StockPage(key: ValueKey(route));
      case AppRoute.warehouse:
        return WarehousePage(key: ValueKey(route));
      case AppRoute.hr:
      case AppRoute.staff:
        return StaffPage(key: ValueKey(route));
      case AppRoute.attendance:
        return AttendancePage(key: ValueKey(route));
      case AppRoute.manualPunchEntry:
        return ManualPunchPanel(key: ValueKey(route));
      case AppRoute.regularizeMissedPunch:
        return RegularizePunchPanel(key: ValueKey(route));
      case AppRoute.payroll:
        return PayrollPage(key: ValueKey(route));
      case AppRoute.allocateEmployeeLoan:
        return EmployeeLoanPanel(key: ValueKey(route));
      case AppRoute.processMonthlyPayroll:
        return ProcessPayrollPanel(key: ValueKey(route));
      case AppRoute.pos:
        return PosPage(key: ValueKey(route));
      case AppRoute.reports:
        return ReportsPage(key: ValueKey(route));
      case AppRoute.marketing:
        return MarketingPage(key: ValueKey(route));
      case AppRoute.barcodeGen:
        return BarcodeGenPage(key: ValueKey(route));
      case AppRoute.auditHub:
        return AuditHubPage(key: ValueKey(route));
      case AppRoute.fintech:
        return FintechPage(key: ValueKey(route));
      case AppRoute.subscription:
        return SubscriptionPage(key: ValueKey(route));
      case AppRoute.recordExpense:
        return RecordExpenseModal(key: ValueKey(route));
      case AppRoute.lodgeStaffClaim:
        return LodgeStaffClaimModal(key: ValueKey(route));
      case AppRoute.generateEWayBill:
        return GenerateEWayBillModal(key: ValueKey(route));
      case AppRoute.generateEInvoice:
        return GenerateEInvoiceModal(key: ValueKey(route));
      case AppRoute.invoiceTemplates:
        return InvoiceTemplatesModal(key: ValueKey(route));
      case AppRoute.newSalesOrder:
        return NewSalesOrderPage(key: ValueKey(AppRoute.newSalesOrder));
      case AppRoute.addCustomer:
        return AddCustomerModal(key: ValueKey(route));
      case AppRoute.newCustomerReturn:
        return NewCustomerReturnModal(key: ValueKey(route));
      case AppRoute.newSupplierReturn:
        return NewSupplierReturnModal(key: ValueKey(route));
      case AppRoute.newPO:
        return NewPOModal(key: ValueKey(route));
      case AppRoute.newPurchaseBill:
        return NewPurchaseBillModal(key: ValueKey(route));
      case AppRoute.purchaseReturn:
        return PurchaseReturnModal(key: ValueKey(route));
      case AppRoute.registerProduct:
        return RegisterProductModal(key: ValueKey(route));
      case AppRoute.adjustStock:
        return AdjustStockModal(key: ValueKey(route));
      case AppRoute.warehouseTransfer:
        return WarehouseTransferModal(key: ValueKey(route));
      case AppRoute.registerWarehouse:
        return RegisterWarehouseModal(key: ValueKey(route));
      case AppRoute.goodsInwardReceipt:
        return GoodsInwardReceiptModal(key: ValueKey(route));
      case AppRoute.interWarehouseTransfer:
        return InterWarehouseTransferModal(key: ValueKey(route));
      case AppRoute.secureAuditExport:
        return SecureAuditExportModal(key: ValueKey(route));
      case AppRoute.recordAccountingEntry:
        return RecordAccountingEntryModal(key: ValueKey(route));
      case AppRoute.scheduleReturnReminder:
        return ScheduleReturnReminderPanel(key: ValueKey(route));
      default:
        return Center(
          key: ValueKey(route),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.construction, size: 64, color: AppColors.border),
              const SizedBox(height: 16),
              Text('Page ${route.name} is under construction', style: const TextStyle(color: AppColors.secondaryText)),
            ],
          ),
        );
    }
  }

  void _switchToModule(WidgetRef ref, AppModule module) {
    if (module == AppModule.books) {
      ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.books, AppRoute.dashboard);
    } else if (module == AppModule.payments) {
      ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.payments, AppRoute.people);
    } else if (module == AppModule.social) {
      ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.social, AppRoute.betaClub);
    } else if (module == AppModule.profile) {
      ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.profile, AppRoute.profile);
    }
  }
}
