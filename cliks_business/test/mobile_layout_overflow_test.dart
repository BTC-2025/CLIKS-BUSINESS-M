import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/people/pages/people_page.dart';
import 'package:clicks_business_frontend/features/payments/pages/split_collect_page.dart';
import 'package:clicks_business_frontend/features/payments/pages/planner_page.dart';
import 'package:clicks_business_frontend/features/payments/pages/transaction_page.dart';
import 'package:clicks_business_frontend/features/payments/pages/segregation_page.dart';

void main() {
  const testWidths = [320.0, 360.0, 390.0];

  for (final width in testWidths) {
    group('Viewport width: ${width}px', () {
      testWidgets('PeoplePage renders without overflow', (tester) async {
        tester.view.physicalSize = Size(width, 740);
        tester.view.devicePixelRatio = 1.0;
        await tester.binding.setSurfaceSize(Size(width, 740));
        addTearDown(() async {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          await tester.binding.setSurfaceSize(null);
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: PeoplePage()),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('SplitCollectPage renders without overflow', (tester) async {
        tester.view.physicalSize = Size(width, 740);
        tester.view.devicePixelRatio = 1.0;
        await tester.binding.setSurfaceSize(Size(width, 740));
        addTearDown(() async {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          await tester.binding.setSurfaceSize(null);
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: SplitCollectPage()),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('PlannerPage renders without overflow', (tester) async {
        tester.view.physicalSize = Size(width, 740);
        tester.view.devicePixelRatio = 1.0;
        await tester.binding.setSurfaceSize(Size(width, 740));
        addTearDown(() async {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          await tester.binding.setSurfaceSize(null);
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: PlannerPage()),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('TransactionPage renders without overflow', (tester) async {
        tester.view.physicalSize = Size(width, 740);
        tester.view.devicePixelRatio = 1.0;
        await tester.binding.setSurfaceSize(Size(width, 740));
        addTearDown(() async {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          await tester.binding.setSurfaceSize(null);
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TransactionPage()),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('SegregationPage renders without overflow', (tester) async {
        tester.view.physicalSize = Size(width, 740);
        tester.view.devicePixelRatio = 1.0;
        await tester.binding.setSurfaceSize(Size(width, 740));
        addTearDown(() async {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          await tester.binding.setSurfaceSize(null);
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: SegregationPage()),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    });
  }
}
