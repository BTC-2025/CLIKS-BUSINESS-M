import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/dashboard/dashboard_page.dart';
import 'package:clicks_business_frontend/features/navigation/widgets/macos_right_utility_rail.dart';
import 'package:clicks_business_frontend/widgets/bento/bento_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('MacOSRightUtilityRail Panel Close Tests', () {
    testWidgets('Clicking Close panel on BETA drawer only closes drawer and preserves rail tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      // Initially set macosBetaAppsVisibleProvider to true
      final container = ProviderContainer(
        overrides: [
          macosBetaAppsVisibleProvider.overrideWith((ref) => true),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  Expanded(child: SizedBox()),
                  MacOSRightUtilityRail(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify vertical rail is present (54px rail contains 'B' squircle)
      expect(find.text('B'), findsOneWidget);

      // Tap 'B' button to open Beta panel
      await tester.tap(find.text('B'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Beta drawer panel is now open
      expect(find.text('BETA'), findsOneWidget);
      expect(find.text('FAVORITES'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);

      // Find the close panel IconButton
      final closeButton = find.byTooltip('Close panel');
      expect(closeButton, findsOneWidget);

      // Tap close button
      await tester.tap(closeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The left drawer panel is now CLOSED
      expect(find.text('FAVORITES'), findsNothing);
      expect(find.text('RECENT'), findsNothing);

      // BUT the right vertical rail with all tabs & 'B' button is STILL THERE!
      expect(find.text('B'), findsOneWidget);
      expect(find.byType(MacOSRightUtilityRail), findsOneWidget);
      expect(container.read(macosBetaAppsVisibleProvider), isTrue);
    });

    testWidgets('Clicking Close panel on Calendar drawer only closes drawer and preserves rail tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      final container = ProviderContainer(
        overrides: [
          macosBetaAppsVisibleProvider.overrideWith((ref) => true),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  Expanded(child: SizedBox()),
                  MacOSRightUtilityRail(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Calendar icon on the rail
      final calBtn = find.byTooltip('Calendar');
      expect(calBtn, findsOneWidget);
      await tester.tap(calBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Calendar panel is open
      expect(find.text('CALENDAR'), findsOneWidget);

      // Close panel
      final closeBtn = find.byTooltip('Close panel');
      await tester.tap(closeBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Drawer is closed
      expect(find.text('CALENDAR'), findsNothing);

      // Rail is still present
      expect(find.text('B'), findsOneWidget);
      expect(find.byTooltip('Calendar'), findsOneWidget);
      expect(container.read(macosBetaAppsVisibleProvider), isTrue);
    });
  });

  group('Dashboard Metric Cards Zero Overflow Tests', () {
    testWidgets('BentoMetricCard with long trend text does not overflow when constrained', (tester) async {
      // Test the exact card that previously overflowed: Estimated Net Profit with Margin: 0.0%
      await tester.binding.setSurfaceSize(const Size(200, 300));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 140, // Narrow width simulates 4 cards crammed when side panel is open
              child: BentoMetricCard(
                label: 'Estimated Net Profit',
                value: '₹0',
                icon: LucideIcons.wallet,
                trendText: 'Margin: 0.0%',
                isTrendPositive: true,
                footerText: 'Gross Operational Yield',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Estimated Net Profit'), findsOneWidget);
    });

    testWidgets('DashboardPage renders cleanly with 0 overflow across desktop, tablet, and narrow widths', (tester) async {
      // Test at typical desktop viewport with side panel open (~1280x800)
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DashboardPage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Test at intermediate width (1000x800)
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Test at narrow width (720x800)
      await tester.binding.setSurfaceSize(const Size(720, 800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
