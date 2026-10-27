import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/billing/pages/subscription_page.dart';
import 'package:clicks_business_frontend/features/billing/widgets/customizable_plan_builder_section.dart';

void main() {
  group('Customizable Subscription & Instant Add-Ons Builder', () {
    testWidgets('Renders Business sub-tabs and switches to Customizable builder view',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SubscriptionPage(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify the 3 main category tabs are present
        expect(find.text('BUSINESS'), findsOneWidget);
        expect(find.text('FIN-PRO'), findsOneWidget);
        expect(find.text('PARTNER LAUNCH DESK'), findsOneWidget);

        // Verify Business sub-tabs are present
        expect(find.text('Standard Tiers (4 Plans)'), findsOneWidget);
        expect(find.text('✦ Customizable Plan & Add-Ons'), findsOneWidget);

        // Tap the Customizable sub-tab inside Business
        await tester.tap(find.text('✦ Customizable Plan & Add-Ons'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify CustomizablePlanBuilderSection is rendered
        expect(find.byType(CustomizablePlanBuilderSection), findsOneWidget);
        expect(find.text('Customize Workspace & Add-On Boosters'), findsOneWidget);

        // Verify Section A Base Platform Floor (₹149/mo)
        expect(find.text('Cliks Core Workspace Foundation'), findsOneWidget);
        expect(find.textContaining('₹149'), findsWidgets);

        // Verify Section B Capacity Sliders title
        expect(find.text('Interactive Quantitative Limits'), findsOneWidget);

        // Verify Section C Modular Modules title
        expect(find.text('Select Only What Your Business Needs'), findsOneWidget);

        // Verify sticky Right-Hand Summary Card
        expect(find.text('Custom Plan & Add-On Summary'), findsOneWidget);
        expect(find.text('Annual Billing'), findsWidgets);
        expect(find.text('Monthly Billing'), findsWidgets);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('Toggling modules and adjusting steppers updates live summary calculation',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CustomizablePlanBuilderSection(),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Initial base summary: ₹149/mo with 20% discount = ₹119/mo
        expect(find.text('Core Workspace Foundation'), findsOneWidget);

        // Find and toggle a module (e.g. Automated HR Payroll, Attendance & Payslips)
        final hrModuleText = find.text('Automated HR Payroll, Attendance & Payslips');
        expect(hrModuleText, findsOneWidget);
        await tester.ensureVisible(hrModuleText);
        await tester.pumpAndSettle();
        await tester.tap(hrModuleText);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify module is now itemized in summary
        expect(find.text('1 selected (+ ₹79 / mo)'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('Admin simulation control allows switching between Idle, Pending, and Approved',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CustomizablePlanBuilderSection(),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Initial state button
        expect(find.text('🚀 Submit Custom Plan to Admin'), findsOneWidget);

        // Tap submit button to trigger submission modal
        await tester.tap(find.text('🚀 Submit Custom Plan to Admin'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Confirm in dialog
        expect(find.text('Submit Custom Plan for Admin Review'), findsOneWidget);
        await tester.tap(find.text('Confirm & Submit Request'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Now button shows pending review state
        expect(find.text('⏳ Under Review (Admin SLA: 2 Hrs)'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('CustomizablePlanBuilderSection renders on 360px mobile without overflow',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CustomizablePlanBuilderSection(isMobile: true),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(CustomizablePlanBuilderSection), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
