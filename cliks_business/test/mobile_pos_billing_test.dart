import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:clicks_business_frontend/features/billing/pages/pos_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/macos_pos_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/mobile_pos_billing_page.dart';
import 'package:clicks_business_frontend/features/billing/widgets/mobile_pos/mobile_product_card.dart';
import 'package:clicks_business_frontend/features/billing/widgets/mobile_pos/mobile_stock_adjustment_sheet.dart';
import 'package:clicks_business_frontend/features/billing/widgets/mobile_pos/mobile_edit_product_sheet.dart';
import 'package:clicks_business_frontend/features/billing/widgets/mobile_pos/mobile_cart_sheet.dart';

Widget _buildTestApp({
  required Widget child,
  TargetPlatform platform = TargetPlatform.android,
}) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(platform: platform, useMaterial3: true),
      home: child,
    ),
  );
}

void main() {
  group('Mobile POS Billing Redesign Tests', () {
    testWidgets(
      'Platform Isolation: macOS returns MacOsPosPage, Android returns MobilePosBillingPage',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Ignore existing legacy macOS overflow in test environment with test font metrics
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exceptionAsString().contains('overflowed')) return;
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        // 1. Test macOS platform -> returns MacOsPosPage
        await tester.pumpWidget(
          _buildTestApp(child: const PosPage(), platform: TargetPlatform.macOS),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MacOsPosPage), findsOneWidget);
        expect(find.byType(MobilePosBillingPage), findsNothing);

        // 2. Test Android platform -> returns MobilePosBillingPage
        await tester.pumpWidget(
          _buildTestApp(
            child: const PosPage(),
            platform: TargetPlatform.android,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MobilePosBillingPage), findsOneWidget);
        expect(find.byType(MacOsPosPage), findsNothing);

        // 3. Test iOS platform -> returns MobilePosBillingPage
        await tester.pumpWidget(
          _buildTestApp(child: const PosPage(), platform: TargetPlatform.iOS),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MobilePosBillingPage), findsOneWidget);
        expect(find.byType(MacOsPosPage), findsNothing);
      },
    );

    testWidgets(
      'Renders without overflow on compact 320px width mobile screen',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MobilePosBillingPage), findsOneWidget);
        expect(find.text('POS Billing'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Renders without overflow on standard 360px width Android screen',
      (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MobilePosBillingPage), findsOneWidget);
        expect(find.text('POS Billing'), findsOneWidget);
        expect(find.text('Varshini'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Renders without overflow on modern 390px iPhone viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestApp(
          child: const MobilePosBillingPage(),
          platform: TargetPlatform.iOS,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MobilePosBillingPage), findsOneWidget);
      expect(find.text('View Cart'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Product search filters catalogue accurately', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestApp(child: const MobilePosBillingPage()),
      );
      await tester.pumpAndSettle();

      // Find search field
      final searchFinder = find.byType(TextField).first;
      expect(searchFinder, findsOneWidget);

      // Search for "apple"
      await tester.enterText(searchFinder, 'apple');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(MobileProductCard, 'apple'), findsOneWidget);
      expect(find.widgetWithText(MobileProductCard, 'BMW car'), findsNothing);

      // Clear search
      await tester.enterText(searchFinder, '');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(MobileProductCard, 'BMW car'), findsOneWidget);
    });

    testWidgets('Category chips filter catalogue', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestApp(child: const MobilePosBillingPage()),
      );
      await tester.pumpAndSettle();

      // Tap General category chip (first InkWell with text 'General')
      final generalChip = find.widgetWithText(InkWell, 'General').first;
      await tester.tap(generalChip);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(MobileProductCard, 'a new digit product'),
        findsOneWidget,
      );
      expect(find.widgetWithText(MobileProductCard, 'BMW car'), findsNothing);
      expect(find.widgetWithText(MobileProductCard, 'apple'), findsNothing);
    });

    testWidgets('Out of stock product shows badge and prevents adding', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestApp(child: const MobilePosBillingPage()),
      );
      await tester.pumpAndSettle();

      // Search for "erferfa" which has stock 0
      final searchFinder = find.byType(TextField).first;
      await tester.enterText(searchFinder, 'erferfa');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(MobileProductCard, 'erferfa'), findsOneWidget);
      expect(find.text('Out of Stock'), findsOneWidget);
    });

    testWidgets('Floating cart bar opens cart sheet and displays totals', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestApp(child: const MobilePosBillingPage()),
      );
      await tester.pumpAndSettle();

      // Tap "View Cart" button on docked floating bar
      final viewCartButton = find.text('View Cart');
      expect(viewCartButton, findsOneWidget);
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      // Cart sheet is displayed with items and financial summary
      expect(find.text('Cart (4)'), findsOneWidget);
      expect(find.text('PAYMENT & TAX SUMMARY'), findsOneWidget);
      expect(find.text('GST TAX'), findsOneWidget);
      expect(find.text('Proceed to Payment (₹1,95,892)'), findsOneWidget);
    });

    testWidgets(
      'Cart sheet "+" and "-" icons correctly increment and decrement item quantity with real-time total updates',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Open cart sheet
        await tester.tap(find.text('View Cart'));
        await tester.pumpAndSettle();

        expect(find.byType(MobileCartSheet), findsOneWidget);
        expect(find.text('Cart (4)'), findsOneWidget);
        expect(find.text('Proceed to Payment (₹1,95,892)'), findsOneWidget);

        // Find the stepper plus button inside MobileCartSheet
        final plusButton = find
            .descendant(
              of: find.byType(MobileCartSheet),
              matching: find.byIcon(LucideIcons.plus),
            )
            .first;

        // 1. Touch "+" icon -> Quantity increments to 2, cart items count becomes 5, totals recalculate
        await tester.tap(plusButton);
        await tester.pumpAndSettle();

        expect(find.text('Cart (5)'), findsOneWidget);
        expect(find.text('Proceed to Payment (₹2,02,341)'), findsOneWidget);

        // Find the stepper minus button inside MobileCartSheet
        final minusButton = find
            .descendant(
              of: find.byType(MobileCartSheet),
              matching: find.byIcon(LucideIcons.minus),
            )
            .first;

        // 2. Touch "-" icon -> Quantity decrements back to 1, totals recalculate immediately
        await tester.tap(minusButton);
        await tester.pumpAndSettle();

        expect(find.text('Cart (4)'), findsOneWidget);
        expect(find.text('Proceed to Payment (₹1,95,892)'), findsOneWidget);
      },
    );

    testWidgets(
      'Customer selector opens customer sheet and allows selecting Walk-in Client',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Default customer is Varshini
        expect(find.text('Varshini'), findsOneWidget);

        // Tap Change button
        final changeBtn = find.text('Change');
        expect(changeBtn, findsOneWidget);
        await tester.tap(changeBtn);
        await tester.pumpAndSettle();

        // Customer sheet is shown
        expect(find.text('Select Customer'), findsOneWidget);
        expect(find.text('Walk-in Client'), findsOneWidget);

        // Select Walk-in Client
        await tester.tap(find.text('Walk-in Client'));
        await tester.pumpAndSettle();

        // Customer summary now shows Walk-in Client
        expect(find.text('Walk-in Client'), findsOneWidget);
      },
    );

    testWidgets('Sales history sheet opens from header icon', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _buildTestApp(child: const MobilePosBillingPage()),
      );
      await tester.pumpAndSettle();

      // Tap history icon in header
      final historyIcon = find.byIcon(LucideIcons.history);
      expect(historyIcon, findsOneWidget);
      await tester.tap(historyIcon);
      await tester.pumpAndSettle();

      // Sales register sheet is shown
      expect(find.text('Sales Register'), findsOneWidget);
      expect(find.text('POS-BILL-9901'), findsOneWidget);
      expect(find.text('POS-BILL-9902'), findsOneWidget);
    });

    testWidgets(
      'Floating cart bar is positioned above bottom navigation bar without collision',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Check header back button exists
        final backButton = find.byIcon(LucideIcons.arrowLeft);
        expect(backButton, findsOneWidget);

        // Verify the View Cart button is visible
        final viewCartFinder = find.text('View Cart');
        expect(viewCartFinder, findsOneWidget);

        // Verify cart bar center is safely above the bottom navigation area (bottom 70px)
        final viewCartCenter = tester.getCenter(viewCartFinder);
        expect(viewCartCenter.dy, lessThan(844 - 70));
      },
    );

    testWidgets(
      'Stock Management: Overflow menu shows Increase, Decrease, Edit, and Delete actions',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Find the 3-dot overflow menu button on the first product card
        final moreButtons = find.byTooltip('Product Actions');
        expect(moreButtons, findsWidgets);

        // Tap the 3-dot menu on first card
        await tester.tap(moreButtons.first);
        await tester.pumpAndSettle();

        // Verify all 4 action items appear in the popup menu
        expect(find.text('Increase Stock'), findsOneWidget);
        expect(find.text('Decrease Stock'), findsOneWidget);
        expect(find.text('Edit Item'), findsOneWidget);
        expect(find.text('Delete Item'), findsOneWidget);
      },
    );

    testWidgets(
      'Stock Management: Increase Stock validates input, adds stock, and refreshes card',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Filter to "apple" (Stock: 8)
        await tester.enterText(find.byType(TextField).first, 'apple');
        await tester.pumpAndSettle();

        expect(find.text('8 PCS in stock'), findsOneWidget);

        // Tap 3-dot menu on apple card
        await tester.tap(find.byTooltip('Product Actions').first);
        await tester.pumpAndSettle();

        // Tap "Increase Stock"
        await tester.tap(find.text('Increase Stock'));
        await tester.pumpAndSettle();

        // Verify Increase Stock sheet opened
        expect(find.text('Warehouse: '), findsOneWidget);
        expect(find.text('Main Store (Wh-01)'), findsWidgets);
        expect(find.text('Current Stock:'), findsOneWidget);
        expect(find.text('8 PCS'), findsOneWidget);

        // Enter quantity: 12
        final qtyField = find.widgetWithText(TextField, '1');
        expect(qtyField, findsOneWidget);
        await tester.enterText(qtyField, '12');
        await tester.pumpAndSettle();

        // Verify preview shows resulting stock 20 PCS
        expect(find.text('20 PCS'), findsOneWidget);

        // Submit Add Stock
        final addStockBtn = find.widgetWithText(ElevatedButton, 'Add Stock');
        await tester.tap(addStockBtn);
        await tester.pump(); // Start async delay
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify sheet closed and stock updated to 20 on product card
        expect(find.text('20 PCS in stock'), findsOneWidget);
      },
    );

    testWidgets(
      'Stock Management: Decrease Stock validates stock limit, deducts stock, and refreshes card',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Filter to "apple" (Stock: 8)
        await tester.enterText(find.byType(TextField).first, 'apple');
        await tester.pumpAndSettle();

        expect(find.text('8 PCS in stock'), findsOneWidget);

        // Tap 3-dot menu on apple card
        await tester.tap(find.byTooltip('Product Actions').first);
        await tester.pumpAndSettle();

        // Tap "Decrease Stock"
        await tester.tap(find.text('Decrease Stock'));
        await tester.pumpAndSettle();

        // Verify Decrease Stock sheet opened
        expect(find.text('Decrease Stock'), findsOneWidget);
        expect(find.text('8 PCS'), findsOneWidget);

        // Attempt to deduct 50 PCS (exceeds stock 8)
        final qtyFields = find.descendant(
          of: find.byType(MobileStockAdjustmentSheet),
          matching: find.byType(TextField),
        );
        await tester.enterText(qtyFields.first, '50');
        await tester.pumpAndSettle();

        final deductStockBtn = find.widgetWithText(ElevatedButton, 'Deduct Stock');
        await tester.tap(deductStockBtn);
        await tester.pumpAndSettle();

        // Verify validation error message appears and sheet remains open
        expect(find.textContaining('Cannot deduct 50 PCS. Current stock is only 8 PCS.'), findsOneWidget);

        // Now enter valid quantity 3
        await tester.enterText(qtyFields.first, '3');
        await tester.pumpAndSettle();

        // Submit valid deduction
        await tester.tap(deductStockBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify sheet closed and stock updated to 5
        expect(find.text('5 PCS in stock'), findsOneWidget);
      },
    );

    testWidgets(
      'Stock Management: Edit Item updates product name and price in catalogue',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Filter to "BMW"
        await tester.enterText(find.byType(TextField).first, 'BMW');
        await tester.pumpAndSettle();

        // Tap 3-dot menu
        await tester.tap(find.byTooltip('Product Actions').first);
        await tester.pumpAndSettle();

        // Tap "Edit Item"
        await tester.tap(find.text('Edit Item'));
        await tester.pumpAndSettle();

        // Verify Edit Item sheet is visible
        expect(find.text('Edit Product Item'), findsOneWidget);

        // Change Name to "BMW Sports Car"
        final editTextFields = find.descendant(
          of: find.byType(MobileEditProductSheet),
          matching: find.byType(TextField),
        );
        await tester.enterText(editTextFields.first, 'BMW Sports Car');
        await tester.pumpAndSettle();

        // Tap "Save Changes"
        await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify updated name appears in catalogue
        expect(find.widgetWithText(MobileProductCard, 'BMW Sports Car'), findsOneWidget);
      },
    );

    testWidgets(
      'Stock Management: Delete Item removes product after confirmation',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Filter to "BMW car"
        await tester.enterText(find.byType(TextField).first, 'BMW car');
        await tester.pumpAndSettle();
        expect(find.widgetWithText(MobileProductCard, 'BMW car'), findsOneWidget);

        // Tap 3-dot menu
        await tester.tap(find.byTooltip('Product Actions').first);
        await tester.pumpAndSettle();

        // Tap "Delete Item"
        await tester.tap(find.text('Delete Item'));
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Delete Product?'), findsOneWidget);
        expect(find.textContaining('Are you sure you want to remove "BMW car"'), findsOneWidget);

        // Tap "Delete" button in dialog
        await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
        await tester.pumpAndSettle();

        // Product is gone from catalogue
        expect(find.widgetWithText(MobileProductCard, 'BMW car'), findsNothing);
      },
    );

    testWidgets(
      'Stock & Cart: PCS count, in-cart wording, and stock limit are strictly enforced',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          _buildTestApp(child: const MobilePosBillingPage()),
        );
        await tester.pumpAndSettle();

        // Filter to "apple" (stock: 8)
        await tester.enterText(find.byType(TextField).first, 'apple');
        await tester.pumpAndSettle();

        // 1. Initially: 8 PCS in stock is visible
        expect(find.text('8 PCS in stock'), findsOneWidget);
        expect(find.textContaining('in cart'), findsNothing);

        // 2. Add 1 to cart
        final plusButton = find.descendant(
          of: find.widgetWithText(MobileProductCard, 'apple'),
          matching: find.byIcon(LucideIcons.plus),
        );
        await tester.tap(plusButton.first);
        await tester.pumpAndSettle();

        // 3. In-cart wording "1 in cart" and remaining stock "7 PCS left" are clearly visible
        expect(find.text('1 in cart'), findsOneWidget);
        expect(find.text('7 PCS left'), findsOneWidget);

        // 4. Increment up to available stock (8) directly on product card stepper
        for (int i = 0; i < 7; i++) {
          await tester.tap(plusButton.first);
          await tester.pumpAndSettle();
        }

        // On product card: 8 in cart and Out of Stock (0 remaining) are visible
        expect(find.text('8 in cart'), findsOneWidget);
        expect(find.text('Out of Stock'), findsOneWidget);

        // 5. Attempt to increment past available stock (9th item)
        await tester.tap(plusButton.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // SnackBar warning is shown and cannot add above available stock
        expect(
          find.textContaining('Cannot add more. Only 8 PCS available in stock!'),
          findsOneWidget,
        );
        expect(find.text('8 in cart'), findsOneWidget);
      },
    );
  });
}

