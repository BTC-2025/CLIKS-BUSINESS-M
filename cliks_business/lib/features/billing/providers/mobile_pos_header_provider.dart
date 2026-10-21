import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobilePosHeaderState {
  final String selectedWarehouse;
  final List<String> warehouses;
  final int heldCartsCount;
  final VoidCallback? onOpenWarehousePicker;
  final VoidCallback? onOpenHeldCarts;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onQuickAddProduct;
  final VoidCallback? onOpenSettings;

  const MobilePosHeaderState({
    this.selectedWarehouse = 'Main Store (Wh-01)',
    this.warehouses = const [
      'Main Store (Wh-01)',
      'Central Warehouse',
      'Depot North',
      'Downtown Express',
    ],
    this.heldCartsCount = 0,
    this.onOpenWarehousePicker,
    this.onOpenHeldCarts,
    this.onOpenHistory,
    this.onQuickAddProduct,
    this.onOpenSettings,
  });

  MobilePosHeaderState copyWith({
    String? selectedWarehouse,
    List<String>? warehouses,
    int? heldCartsCount,
    VoidCallback? onOpenWarehousePicker,
    VoidCallback? onOpenHeldCarts,
    VoidCallback? onOpenHistory,
    VoidCallback? onQuickAddProduct,
    VoidCallback? onOpenSettings,
  }) {
    return MobilePosHeaderState(
      selectedWarehouse: selectedWarehouse ?? this.selectedWarehouse,
      warehouses: warehouses ?? this.warehouses,
      heldCartsCount: heldCartsCount ?? this.heldCartsCount,
      onOpenWarehousePicker:
          onOpenWarehousePicker ?? this.onOpenWarehousePicker,
      onOpenHeldCarts: onOpenHeldCarts ?? this.onOpenHeldCarts,
      onOpenHistory: onOpenHistory ?? this.onOpenHistory,
      onQuickAddProduct: onQuickAddProduct ?? this.onQuickAddProduct,
      onOpenSettings: onOpenSettings ?? this.onOpenSettings,
    );
  }
}

class MobilePosHeaderNotifier extends StateNotifier<MobilePosHeaderState> {
  MobilePosHeaderNotifier() : super(const MobilePosHeaderState());

  void setWarehouse(String wh) {
    state = state.copyWith(selectedWarehouse: wh);
  }

  void setHeldCartsCount(int count) {
    state = state.copyWith(heldCartsCount: count);
  }

  void registerCallbacks({
    required VoidCallback onOpenWarehousePicker,
    required VoidCallback onOpenHeldCarts,
    required VoidCallback onOpenHistory,
    required VoidCallback onQuickAddProduct,
    VoidCallback? onOpenSettings,
    required String selectedWarehouse,
    required List<String> warehouses,
    required int heldCartsCount,
  }) {
    state = MobilePosHeaderState(
      selectedWarehouse: selectedWarehouse,
      warehouses: warehouses,
      heldCartsCount: heldCartsCount,
      onOpenWarehousePicker: onOpenWarehousePicker,
      onOpenHeldCarts: onOpenHeldCarts,
      onOpenHistory: onOpenHistory,
      onQuickAddProduct: onQuickAddProduct,
      onOpenSettings: onOpenSettings,
    );
  }
}

final mobilePosHeaderProvider =
    StateNotifierProvider<MobilePosHeaderNotifier, MobilePosHeaderState>(
      (ref) => MobilePosHeaderNotifier(),
    );
