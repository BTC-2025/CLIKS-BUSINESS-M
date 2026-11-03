import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/navigation/widgets/top_nav_bar.dart';
import 'package:clicks_business_frontend/core/navigation/navigation_provider.dart';

void main() {
  group('TopNavBar Responsive & Overflow Prevention Tests', () {
    testWidgets(
        'TopNavBar renders without overflow at minimized width (740px - user screenshot size)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(740, 700);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TopNavBar(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Brand logo and showroom are visible without crashing or overflowing
        expect(find.text('Cliks Business'), findsOneWidget);
        expect(find.byType(TopNavBar), findsOneWidget);

        // On minimized screen (740px), center module pills (Books, Payments, Social)
        // must NOT be in the top bar to prevent overlapping the showroom & action items
        // (as they are already in the bottom bar on ShellLayout)
        expect(find.text('Payments'), findsNothing);
        expect(find.text('Social'), findsNothing);

        // No overflow errors
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('TopNavBar renders without overflow at compact width (600px)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(600, 700);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TopNavBar(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(TopNavBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets(
        'TopNavBar renders full desktop layout at medium desktop width (1120px) without Social / Search collision',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1120, 750);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TopNavBar(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // On 1120px desktop width, both center modules and right actions exist cleanly
        expect(find.text('Cliks Business'), findsOneWidget);
        expect(find.text('Books'), findsOneWidget);
        expect(find.text('Payments'), findsOneWidget);
        expect(find.text('Social'), findsOneWidget);

        // Check positions: Social right edge must be strictly to the left of Search button
        final socialRect = tester.getRect(find.text('Social'));
        final searchFinder = find.byTooltip('Search');
        expect(searchFinder, findsOneWidget);
        final searchRect = tester.getRect(searchFinder);

        // Assert Social does NOT intersect or collide with Search
        expect(socialRect.right < searchRect.left, isTrue,
            reason: 'Social right edge (${socialRect.right}) must be strictly less than Search left edge (${searchRect.left})');

        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets(
        'TopNavBar renders full desktop layout at large width (1280px)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TopNavBar(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // On full desktop (1280px), module pills are present in top bar
        expect(find.text('Cliks Business'), findsOneWidget);
        expect(find.text('Books'), findsOneWidget);
        expect(find.text('Payments'), findsOneWidget);
        expect(find.text('Social'), findsOneWidget);

        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets(
        'TopNavBar ensures positive clearance between Social and Search across all desktop widths (>= 1100px)',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        for (final w in [1100.0, 1120.0, 1150.0, 1200.0, 1250.0, 1280.0, 1440.0]) {
          tester.view.physicalSize = Size(w, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: TopNavBar(),
                ),
              ),
            ),
          );
          await tester.pump();

          final socialFinder = find.text('Social');
          final searchFinder = find.byTooltip('Search');
          final slidersFinder = find.byTooltip('Open Toolbar');

          expect(socialFinder, findsOneWidget);
          expect(searchFinder, findsOneWidget);

          final socialRect = tester.getRect(socialFinder);
          final searchRect = tester.getRect(searchFinder);
          final slidersRect = tester.getRect(slidersFinder);

          // 1. Social right edge must have at least 30px clearance before Search left edge
          final gap = searchRect.left - socialRect.right;
          expect(gap >= 30.0, isTrue,
              reason: 'Width $w: Gap ($gap) must be >= 30.0px (Social right: ${socialRect.right}, Search left: ${searchRect.left})');

          // 2. Right action toolbar button must be docked at right edge (w - 16)
          expect((slidersRect.right - (w - 16.0)).abs() < 1.0, isTrue,
              reason: 'Width $w: Sliders button right edge (${slidersRect.right}) must be docked at ${w - 16.0}');
        }
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets(
        'TopNavBar dynamically toggles FIN PRO visibility via finProTopButtonVisibleProvider',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: TopNavBar(),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Default state: FIN PRO is visible
        expect(find.text('FIN PRO'), findsOneWidget);
        expect(find.byTooltip('FIN-PRO Audit Hub'), findsOneWidget);

        // Turn OFF the FIN PRO visibility button (as done in Settings switch)
        container.read(finProTopButtonVisibleProvider.notifier).state = false;
        await tester.pump();

        // FIN PRO button must be immediately hidden from the navbar
        expect(find.text('FIN PRO'), findsNothing);
        expect(find.byTooltip('FIN-PRO Audit Hub'), findsNothing);

        // Turn it back ON
        container.read(finProTopButtonVisibleProvider.notifier).state = true;
        await tester.pump();

        // FIN PRO button is visible again
        expect(find.text('FIN PRO'), findsOneWidget);
        expect(find.byTooltip('FIN-PRO Audit Hub'), findsOneWidget);

        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });
  });
}
