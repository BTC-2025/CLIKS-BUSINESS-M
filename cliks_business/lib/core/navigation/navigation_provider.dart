import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppModule {
  books,
  payments,
  social,
  profile,
}

enum AppRoute {
  dashboard,
  profile,
  meetup,
  billing,
  simpleBilling,
  people,
  accounting,
  expenses,
  gst,
  sales,
  customers,
  returns,
  purchase,
  suppliers,
  registerSupplier,
  inventory,
  products,
  stock,
  warehouse,
  hr,
  staff,
  attendance,
  payroll,
  pos,
  reports,
  marketing,
  rewards,
  barcodeGen,
  auditHub,
  subscription,
  settings,
  help,
  tradingDocs,
  betaClub,
  wallet,
  transaction,
  segregation,
  referral,
  splitCollect,
  planner,
  newInvoice,
  recordExpense,
  lodgeStaffClaim,
  generateEWayBill,
  generateEInvoice,
  invoiceTemplates,
  newSalesOrder,
  addCustomer,
  newCustomerReturn,
  newSupplierReturn,
  newPO,
  newPurchaseBill,
  purchaseReturn,
  registerProduct,
  adjustStock,
  warehouseTransfer,
  registerWarehouse,
  goodsInwardReceipt,
  interWarehouseTransfer,
  secureAuditExport,
  recordAccountingEntry,
  manualPunchEntry,
  regularizeMissedPunch,
  allocateEmployeeLoan,
  processMonthlyPayroll,
  scheduleReturnReminder,
}

class NavigationState {
  final AppModule currentModule;
  final AppRoute currentRoute;

  NavigationState({
    this.currentModule = AppModule.books,
    this.currentRoute = AppRoute.dashboard,
  });

  NavigationState copyWith({
    AppModule? currentModule,
    AppRoute? currentRoute,
  }) {
    return NavigationState(
      currentModule: currentModule ?? this.currentModule,
      currentRoute: currentRoute ?? this.currentRoute,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void setModule(AppModule module) {
    state = state.copyWith(currentModule: module);
  }

  void setRoute(AppRoute route) {
    state = state.copyWith(currentRoute: route);
  }

  void setModuleAndRoute(AppModule module, AppRoute route) {
    state = state.copyWith(currentModule: module, currentRoute: route);
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
