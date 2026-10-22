import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/customer_view/pages/customer_view_settings_page.dart';
import 'package:clicks_business_frontend/features/customer_view/models/customer_product_model.dart';
import 'package:clicks_business_frontend/features/customer_view/models/customer_cart_item.dart';
import 'package:clicks_business_frontend/features/customer_view/models/customer_order_model.dart';
import 'package:clicks_business_frontend/features/customer_view/models/customer_view_settings_model.dart';
import 'package:clicks_business_frontend/features/customer_view/services/customer_auth_service.dart';
import 'package:clicks_business_frontend/features/customer_view/providers/customer_view_provider.dart';
import 'package:clicks_business_frontend/features/customer_view/widgets/customer_owner_auth_dialog.dart';
import 'package:clicks_business_frontend/features/customer_view/utils/customer_theme_helper.dart';

void main() {
  group('Customer View Models & Pricing Calculation Tests', () {
    test('CustomerCartItem correctly calculates unit price, line total, and GST', () {
      const product = CustomerProduct(
        id: 'test-1',
        name: 'Gourmet Burger',
        category: 'Food & Dining',
        price: 200.0,
        stock: 20,
        gstRate: 0.18,
      );

      final item = CustomerCartItem(
        product: product,
        quantity: 3,
        selectedVariant: 'Large (+₹50)',
        extraPrice: 50.0,
      );

      expect(item.unitPrice, 250.0);
      expect(item.lineTotal, 750.0);
      expect(item.lineGst, 135.0); // 750 * 0.18
    });

    test('CustomerOrder aggregates total amount correctly', () {
      const product = CustomerProduct(
        id: 'test-2',
        name: 'Iced Coffee',
        category: 'Beverages',
        price: 100.0,
        stock: 50,
      );

      final cartItem = CustomerCartItem(product: product, quantity: 2);
      final order = CustomerOrder(
        orderId: 'K-9901',
        items: [cartItem],
        subtotal: 200.0,
        gst: 36.0,
        totalAmount: 236.0,
        paymentMode: 'UPI QR Code',
        createdAt: DateTime.now(),
        estimatedPrepMinutes: 10,
      );

      expect(order.orderId, 'K-9901');
      expect(order.totalItemCount, 2);
      expect(order.totalAmount, 236.0);
      expect(order.paymentMode, 'UPI QR Code');
    });

    test('CustomerViewSettings default values are secure and kiosk-appropriate', () {
      const settings = CustomerViewSettings();

      expect(settings.showBusinessName, true);
      expect(settings.showProductSku, false); // Internal SKU hidden from customer by default
      expect(settings.showPreparationTimer, true);
      expect(settings.enableSelfOrdering, true);
      expect(settings.defaultPreparationMinutes, 12);
    });
  });

  group('CustomerAuthService Owner Exit Verification Tests', () {
    test('Rejects empty credentials with clear error messages', () async {
      final emptyResult = await CustomerAuthService.authenticateOwner(
        accountId: '',
        password: '',
      );
      expect(emptyResult.isSuccess, false);
      expect(emptyResult.errorMessage, contains('Please enter'));

      final emptyPass = await CustomerAuthService.authenticateOwner(
        accountId: 'ravinew2004@bnxmail.com',
        password: '',
      );
      expect(emptyPass.isSuccess, false);
      expect(emptyPass.errorMessage, contains('password'));
    });

    test('Rejects unrecognized account IDs', () async {
      final fakeResult = await CustomerAuthService.authenticateOwner(
        accountId: 'intruder@unknown.com',
        password: 'securePassword123',
      );
      expect(fakeResult.isSuccess, false);
      expect(fakeResult.errorMessage, contains('not recognized'));
    });

    test('Authenticates registered owner with valid credentials', () async {
      final successResult = await CustomerAuthService.authenticateOwner(
        accountId: 'ravinew2004@bnxmail.com',
        password: 'adminPassword123',
      );
      expect(successResult.isSuccess, true);
      expect(successResult.errorMessage, isNull);
    });

    test('Authenticates with Owner ID format (e.g. OWNER-001)', () async {
      final successResult = await CustomerAuthService.authenticateOwner(
        accountId: 'OWNER-001',
        password: 'ownerPassword123',
      );
      expect(successResult.isSuccess, true);
      expect(successResult.errorMessage, isNull);
    });

    testWidgets('CustomerOwnerAuthDialog displays Owner ID and does not show ravinew2004@bnxmail.com', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerOwnerAuthDialog(
              onExitToOwnerPos: () {},
              onOpenSettings: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Owner ID'), findsOneWidget);
      expect(find.text('OWNER-001'), findsOneWidget);
      expect(find.text('ravinew2004@bnxmail.com'), findsNothing);
      expect(find.text('Owner Account ID or Email'), findsNothing);
    });
  });

  group('CustomerViewNotifier State Management Tests', () {
    test('Adding item updates cart and computes subtotal and GST', () {
      final notifier = CustomerViewNotifier();
      const product = CustomerProduct(
        id: 'test-p',
        name: 'Fresh Salad',
        category: 'Food',
        price: 150.0,
        stock: 10,
      );

      notifier.addToCart(product, quantity: 2);
      final state = notifier.state;

      expect(state.cart.length, 1);
      expect(state.cartFirstQuantity('test-p'), 2);
      expect(state.cartSubtotal, 300.0);
      expect(state.cartGst, 54.0);
      expect(state.cartTotal, 354.0);
    });

    test('Dietary filter correctly segments Veg, Non-Veg and Specials', () async {
      final notifier = CustomerViewNotifier();
      await pumpEventQueue();

      // Default filter is 'All'
      notifier.setDietaryFilter('All');
      expect(notifier.state.visibleProducts.isNotEmpty, true);

      // Filter by 'Veg'
      notifier.setDietaryFilter('Veg');
      expect(notifier.state.visibleProducts.isNotEmpty, true);
      for (final p in notifier.state.visibleProducts) {
        expect(p.isVeg, true);
      }

      // Filter by 'Non-Veg'
      notifier.setDietaryFilter('Non-Veg');
      expect(notifier.state.visibleProducts.isNotEmpty, true);
      for (final p in notifier.state.visibleProducts) {
        expect(p.isVeg, false);
      }

      // Filter by 'Specials'
      notifier.setDietaryFilter('Specials');
      expect(notifier.state.visibleProducts.isNotEmpty, true);
      for (final p in notifier.state.visibleProducts) {
        expect(p.isFeatured || notifier.state.featuredProductIds.contains(p.id), true);
      }
    });

    test('Theme presets and promo banner update settings correctly', () async {
      final notifier = CustomerViewNotifier();
      await pumpEventQueue();

      await notifier.applyVisualThemePreset('tokyo_amber');
      expect(notifier.state.settings.themePreset, 'tokyo_amber');
      expect(notifier.state.settings.primaryColorValue, 0xFFEA580C);
      expect(notifier.state.settings.accentColorValue, 0xFFFBBF24);

      await notifier.applyVisualThemePreset('midnight_luxury');
      expect(notifier.state.settings.isDarkMode, true);

      await notifier.applyGourmetFoodPresets();
      final burger = notifier.state.products.firstWhere((p) => p.id == 'burger-01');
      expect(burger.networkImageUrl, isNotNull);
      expect(burger.networkImageUrl, contains('images.unsplash.com'));
    });

    test('CustomerViewSettings serializes and restores all customizable features', () {
      const original = CustomerViewSettings(
        fontFamily: 'Poppins',
        fontSizeScale: 1.15,
        fontWeightPreset: 'Bold',
        borderRadius: 20.0,
        headerStyle: 'pill',
        surfaceTint: 'warm',
        promoBannerStyle: 'gold',
        attractSubtitle: 'Freshly Baked Artisanal Pastries',
        currencySymbol: '\$',
        taxDisplayMode: 'inclusive',
        showCalories: true,
        showPrepTimeBadge: true,
        showTableNumberInput: true,
        requireTableNumber: true,
      );

      final json = original.toJson();
      final restored = CustomerViewSettings.fromJson(json);

      expect(restored.fontFamily, 'Poppins');
      expect(restored.fontSizeScale, 1.15);
      expect(restored.fontWeightPreset, 'Bold');
      expect(restored.borderRadius, 20.0);
      expect(restored.headerStyle, 'pill');
      expect(restored.surfaceTint, 'warm');
      expect(restored.promoBannerStyle, 'gold');
      expect(restored.attractSubtitle, 'Freshly Baked Artisanal Pastries');
      expect(restored.currencySymbol, '\$');
      expect(restored.taxDisplayMode, 'inclusive');
      expect(restored.showCalories, true);
      expect(restored.showPrepTimeBadge, true);
      expect(restored.showTableNumberInput, true);
      expect(restored.requireTableNumber, true);
    });

    test('CustomerThemeHelper correctly formats prices and resolves background tints', () {
      const settings = CustomerViewSettings(
        currencySymbol: '€',
        borderRadius: 22.0,
        surfaceTint: 'frost',
        isDarkMode: false,
      );

      expect(CustomerThemeHelper.formatPrice(settings, 120.0), '€120');
      expect(CustomerThemeHelper.formatPrice(settings, 120.50), '€120.50');
      expect(CustomerThemeHelper.borderRadius(settings), 22.0);
      expect(CustomerThemeHelper.surfaceBackground(settings), const Color(0xFFF1F5F9));
    });

    testWidgets('CustomerViewSettingsPage renders with default settings (borderRadius: 16.0) without assertion errors', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CustomerViewSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Themes & Colors'), findsOneWidget);
      expect(find.text('Promotions & Attract'), findsOneWidget);
      expect(find.text('Menu & Ordering'), findsOneWidget);
      expect(find.text('Food Photography'), findsOneWidget);
      expect(find.text('Catalog Visibility'), findsOneWidget);

      // Verify each tab can be switched to without throwing dropdown assertion errors
      await tester.tap(find.text('Promotions & Attract'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu & Ordering'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Food Photography'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Catalog Visibility'));
      await tester.pumpAndSettle();
    });

    testWidgets('CustomerViewSettingsPage renders with custom legacy settings without assertion errors', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set custom/legacy values that previously could cause assertion mismatch
      container.read(customerViewProvider.notifier).updateSettings(
        const CustomerViewSettings(
          borderRadius: 20.0,
          fontSizeScale: 1.15,
          fontWeightPreset: 'UltraThinCustom',
          productCardStyle: 'vintage',
          headerStyle: 'floating',
          surfaceTint: 'warm',
          promoBannerStyle: 'sunset',
          idleTimeoutSeconds: 45,
          currencySymbol: 'CAD',
          taxDisplayMode: 'simplified',
          kitchenSlipMode: 'Digital QR',
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CustomerViewSettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Themes & Colors'), findsOneWidget);

      await tester.tap(find.text('Promotions & Attract'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu & Ordering'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Food Photography'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Catalog Visibility'));
      await tester.pumpAndSettle();
    });
  });
}

extension on CustomerViewState {
  int cartFirstQuantity(String id) {
    return cart.firstWhere((i) => i.product.id == id).quantity;
  }
}

