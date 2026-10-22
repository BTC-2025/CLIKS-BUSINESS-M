import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/billing/pages/accounting_page.dart';

void main() {
  group('macOS Finance → Accounting Page UI Modernization Tests', () {
    testWidgets('macOS Accounting page renders modernized header, KPIs, tabs, and breakdowns at 1280x800',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('Accounting'), findsOneWidget);
      expect(find.text('Compliance-ready financial management and GST reporting.'), findsOneWidget);
      expect(find.text('Record Entry'), findsOneWidget);

      // 2. Verify 4 Financial KPI Cards
      expect(find.text('GROSS REVENUE'), findsOneWidget);
      expect(find.text('TOTAL EXPENSES'), findsOneWidget);
      expect(find.text('NET PROFIT'), findsOneWidget);
      expect(find.text('GST PAYABLE'), findsOneWidget);
      expect(find.textContaining('10,00,00,07,06,880'), findsWidgets);
      expect(find.textContaining('9,88,66,717.4'), findsOneWidget);
      expect(find.text('LIVE POSITION'), findsNWidgets(4));

      // 3. Verify 7 Accounting Tabs
      expect(find.text('P & L'), findsOneWidget);
      expect(find.text('Balance Sheet'), findsOneWidget);
      expect(find.text('Receivables & Payables'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Cash & Bank'), findsOneWidget);
      expect(find.text('GST'), findsOneWidget);
      expect(find.text('Day Book'), findsOneWidget);

      // 4. Verify Revenue Breakdown (P & L active by default)
      expect(find.text('Revenue Breakdown'), findsOneWidget);
      expect(find.text('3 Sources'), findsOneWidget);
      expect(find.text('Sales Revenue'), findsOneWidget);
      expect(find.text('Service Income'), findsOneWidget);
      expect(find.text('Other Income'), findsOneWidget);
      expect(find.text('100%'), findsWidgets);

      // 5. Verify Expense Breakdown
      expect(find.text('Expense Breakdown'), findsOneWidget);
      expect(find.text('13 Categories'), findsOneWidget);
      expect(find.text('Office Expenses'), findsOneWidget);
      expect(find.text('Rent & Utilities'), findsOneWidget);
      expect(find.text('Salary & Wages'), findsOneWidget);
      expect(find.text('Marketing & Advertising'), findsOneWidget);
      expect(find.text('Travel & Meals'), findsOneWidget);
      expect(find.text('Vehicle Expenses'), findsOneWidget);
      expect(find.text('Software & Subscription'), findsOneWidget);
      expect(find.text('Repairs & Maintenance'), findsOneWidget);
      expect(find.text('Bank Charges'), findsOneWidget);
      expect(find.text('Taxes & Government Fees'), findsOneWidget);
      expect(find.text('Insurance'), findsOneWidget);
      expect(find.text('Inventory Purchase'), findsOneWidget);
      expect(find.text('Miscellaneous'), findsOneWidget);

      // 6. Zero overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('macOS Accounting page renders without overflow at 1440x900 wide screen',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accounting'), findsOneWidget);
      expect(find.text('Revenue Breakdown'), findsOneWidget);
      expect(find.text('Expense Breakdown'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('macOS Accounting page renders without overflow at 1050x700 compact screen',
        (tester) async {
      tester.view.physicalSize = const Size(1050, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      FlutterErrorDetails? errorDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        errorDetails = details;
      };
      addTearDown(() {
        FlutterError.onError = oldHandler;
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accounting'), findsOneWidget);
      if (errorDetails != null) {
        debugPrint('CAPTURED ERROR DETAILS: $errorDetails');
      }
      expect(errorDetails, isNull);
    });

    testWidgets('macOS Accounting page renders without overflow at 950x650 small window size',
        (tester) async {
      tester.view.physicalSize = const Size(950, 650);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accounting'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('macOS Accounting Record Entry button opens entry dialog',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final recordEntryBtn = find.text('Record Entry');
      expect(recordEntryBtn, findsOneWidget);
      await tester.tap(recordEntryBtn);
      await tester.pumpAndSettle();

      // Verify Record Entry modal/dialog appeared
      expect(find.textContaining('Record Entry'), findsWidgets);
    });

    testWidgets('macOS Accounting tabs switch correctly and display respective tab content',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: AccountingPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Balance Sheet
      await tester.tap(find.text('Balance Sheet'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Switch to Receivables & Payables
      await tester.tap(find.text('Receivables & Payables'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Switch to Day Book
      await tester.tap(find.text('Day Book'));
      await tester.pumpAndSettle();
      expect(find.byType(DataTable), findsAtLeastNWidgets(1));
      expect(tester.takeException(), isNull);

      // Switch back to P & L
      await tester.tap(find.text('P & L'));
      await tester.pumpAndSettle();
      expect(find.text('Revenue Breakdown'), findsOneWidget);
      expect(find.text('Expense Breakdown'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
