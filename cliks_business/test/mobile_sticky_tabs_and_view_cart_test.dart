import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/billing/pages/staff_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/payroll_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/marketing_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/mobile_pos_billing_page.dart';

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
  group('Mobile Sticky Tabs, Compact Cart Icon, and Marketing FAB Position Tests', () {
    testWidgets('StaffPage on Mobile: subsection tabs are in a pinned SliverPersistentHeader', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp(child: const StaffPage()));
      await tester.pumpAndSettle();

      // Verify CustomScrollView is present on mobile
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Verify SliverPersistentHeader is pinned
      final sliverHeaderFinder = find.byType(SliverPersistentHeader);
      expect(sliverHeaderFinder, findsOneWidget);
      final sliverHeader = tester.widget<SliverPersistentHeader>(sliverHeaderFinder);
      expect(sliverHeader.pinned, isTrue);

      // Verify subsection tabs are present
      expect(find.text('Employee Profiles'), findsOneWidget);
      expect(find.text('Leaves & Shifts Rosters'), findsOneWidget);
      expect(find.text('Performance Appraisals'), findsOneWidget);
      expect(find.text('Staff Reimbursements'), findsOneWidget);
    });

    testWidgets('PayrollPage on Mobile: subsection tabs are in a pinned SliverPersistentHeader', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp(child: const PayrollPage()));
      await tester.pumpAndSettle();

      // Verify CustomScrollView is present on mobile
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Verify SliverPersistentHeader is pinned
      final sliverHeaderFinder = find.byType(SliverPersistentHeader);
      expect(sliverHeaderFinder, findsOneWidget);
      final sliverHeader = tester.widget<SliverPersistentHeader>(sliverHeaderFinder);
      expect(sliverHeader.pinned, isTrue);

      // Verify subsection tabs are present
      expect(find.text('Monthly Payroll Register'), findsOneWidget);
      expect(find.text('Salary Structures (CTC)'), findsOneWidget);
    });

    testWidgets('MarketingPage on Mobile: FAB bottom padding is correctly adjusted (not 130)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp(child: const MarketingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Create Email Campaign'), findsOneWidget);
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Find the Padding wrapping the FAB
      final paddingWidget = tester.widget<Padding>(
        find.ancestor(of: fabFinder, matching: find.byType(Padding)).first,
      );
      final insets = paddingWidget.padding as EdgeInsets;
      expect(insets.bottom, equals(76.0));
      expect(insets.bottom, isNot(equals(130.0)));
    });

    testWidgets('MobilePosBillingPage: View Cart is a small icon on the right side with cost and items count', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp(child: const MobilePosBillingPage()));
      await tester.pumpAndSettle();

      // Verify View Cart is shown with initial items
      expect(find.text('View Cart'), findsOneWidget);

      // Verify Positioned widget is docked on the right side and does NOT stretch across screen (left is null)
      final positionedWidgets = tester.widgetList<Positioned>(find.byType(Positioned));
      final cartPositioned = positionedWidgets.firstWhere(
        (p) => p.right != null && p.left == null,
      );
      expect(cartPositioned.right, equals(16.0));
      expect(cartPositioned.left, isNull);

      // Verify cost and number of products badge are visible
      expect(find.byType(Badge), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsNothing); // Uses Lucide shoppingBag
    });
  });
}
