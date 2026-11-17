import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:clicks_business_frontend/features/billing/pages/sub_ids_page.dart';

void main() {
  group('Sub-IDs Management Page - Multi-OS Layout, Trees & Modals Tests', () {
    testWidgets('Renders all Sub-IDs, permissions header, strict mode, and access hierarchy tree on macOS Desktop (1280x800)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Left Panel (Sub-IDs)
        expect(find.text('Sub-IDs'), findsOneWidget);
        expect(find.text('ravi kumar'), findsOneWidget);
        expect(find.text('sales.ravinew2004@bnxmail.com'), findsOneWidget);
        expect(find.text('ID: sales.ravinew2004'), findsOneWidget);
        expect(find.text('Customer Support'), findsWidgets);
        expect(find.text('Test Check'), findsOneWidget);
        expect(find.text('Test Managed'), findsOneWidget);

        // 2. Right Panel (Header Card)
        expect(find.text('Manage Permissions'), findsOneWidget);
        expect(find.text('Configuring access for ravi kumar (sales.ravinew2004)'), findsOneWidget);
        expect(find.text('Assigned Showroom:'), findsOneWidget);
        expect(find.text('All Showrooms / Global'), findsWidgets);
        expect(find.text('Save Changes'), findsOneWidget);

        // 3. Strict Mode Banner (Inactive by default)
        expect(find.text('Only Generate Invoice Control (Strict Mode)'), findsOneWidget);
        expect(find.text('INACTIVE'), findsOneWidget);
        expect(find.text('Enable Invoice Only'), findsOneWidget);

        // 4. Access Control Hierarchy Tree
        expect(find.text('ACCESS CONTROL HIERARCHY'), findsOneWidget);
        expect(find.text('Finance'), findsOneWidget);
        expect(find.text('Accounting'), findsOneWidget);
        expect(find.text('Finance Accounting All'), findsOneWidget);
        expect(find.text('Finance P&L'), findsOneWidget);
        expect(find.text('Finance Balance Sheet'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Renders cleanly on Windows Desktop (1024x577)', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      tester.view.physicalSize = const Size(1024, 577);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sub-IDs'), findsOneWidget);
        expect(find.text('Manage Permissions'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);
        expect(find.text('ACCESS CONTROL HIERARCHY'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Renders cleanly on Android Mobile (360x780) without overflow',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sub-IDs'), findsOneWidget);
        expect(find.text('Manage Permissions'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Renders cleanly on iOS Mobile (390x844) without overflow',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sub-IDs'), findsOneWidget);
        expect(find.text('Manage Permissions'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Sub-ID card selection updates header title and context', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially ravi kumar is selected
        expect(find.text('Configuring access for ravi kumar (sales.ravinew2004)'), findsOneWidget);

        // Select 'Test Check'
        await tester.tap(find.text('Test Check'));
        await tester.pumpAndSettle();

        // Header updates
        expect(find.text('Configuring access for Test Check (testcheck1.ravinew2004)'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Strict mode toggle switches between inactive and active (Images 2 & 3)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially inactive
        expect(find.text('INACTIVE'), findsOneWidget);
        expect(find.text('Enable Invoice Only'), findsOneWidget);

        // Tap Enable Invoice Only
        await tester.tap(find.text('Enable Invoice Only'));
        await tester.pumpAndSettle();

        // Active state (Image 3)
        expect(find.text('ACTIVE'), findsOneWidget);
        expect(find.text('Disable Strict Mode'), findsOneWidget);

        // Tap Disable Strict Mode
        await tester.tap(find.text('Disable Strict Mode'));
        await tester.pumpAndSettle();

        // Back to inactive (Image 2)
        expect(find.text('INACTIVE'), findsOneWidget);
        expect(find.text('Enable Invoice Only'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Save Changes button displays feedback snackbar', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Permissions saved for ravi kumar'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Add Sub-ID dialog opens, submits, and selects new Sub-ID', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Add User icon button
        final addBtn = find.byIcon(LucideIcons.userPlus);
        expect(addBtn, findsOneWidget);
        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        // Dialog opens
        expect(find.text('Add New Sub-ID Account'), findsOneWidget);
        expect(find.text('Staff Member Name *'), findsOneWidget);
        expect(find.text('Sub-ID Prefix (Username) *'), findsOneWidget);

        // Fill form
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Anand Kumar');
        await tester.enterText(textFields.at(1), 'billing2');
        await tester.enterText(textFields.at(2), 'Pass1234');
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.text('Create Sub-ID'));
        await tester.pumpAndSettle();

        // Dialog closes, new Sub-ID appears and is selected
        expect(find.text('Add New Sub-ID Account'), findsNothing);
        expect(find.text('Anand Kumar'), findsWidgets);
        expect(find.text('Configuring access for Anand Kumar (billing2)'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets(
        'Verifies complete hierarchy matching Image 7 (Payroll, POS Billing, Simple Billing, Reports, Barcode Gen, Marketing) and Customer Support selection',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: SubIdsPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify HR Attendance nodes exist
        expect(find.text('HR Att Today Logs'), findsOneWidget);
        expect(find.text('HR Att History Ledgers'), findsOneWidget);
        expect(find.text('HR Att Shift Configs'), findsOneWidget);
        expect(find.text('HR Att GPS Fencing'), findsOneWidget);
        expect(find.text('HR Att Correction Verify'), findsOneWidget);
        expect(find.text('HR Att Calendar'), findsOneWidget);

        // Verify HR Payroll nodes matching Image 7
        expect(find.text('Payroll'), findsOneWidget);
        expect(find.text('HR Pay All'), findsOneWidget);
        expect(find.text('HR Pay Monthly Register'), findsOneWidget);
        expect(find.text('HR Pay Salary Structures'), findsOneWidget);
        expect(find.text('HR Pay Compliance'), findsOneWidget);
        expect(find.text('HR Pay Loans Advances'), findsOneWidget);

        // Verify trailing module root sections matching Image 7
        expect(find.text('POS Billing'), findsWidgets);
        expect(find.text('Simple Billing'), findsWidgets);
        expect(find.text('Reports'), findsWidgets);
        expect(find.text('Barcode Gen'), findsWidgets);
        expect(find.text('Marketing'), findsWidgets);

        // Select Customer Support card (sub_2)
        final customerSupportCard = find.text('testsupport.ravinew2004@bnxmail.com');
        expect(customerSupportCard, findsOneWidget);
        await tester.tap(customerSupportCard);
        await tester.pumpAndSettle();

        // Header shows Customer Support
        expect(find.text('Configuring access for Customer Support (testsupport.ravinew2004)'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });
  });
}
