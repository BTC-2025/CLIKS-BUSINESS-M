import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/billing/pages/audit_hub_page.dart';
import 'package:clicks_business_frontend/features/billing/widgets/verify_icai_dialog.dart';
import 'package:clicks_business_frontend/features/billing/widgets/assign_task_dialog.dart';

void main() {
  setUp(() {
    FlutterError.onError = (details) {
      debugPrint('>>> OVERFLOW ERROR CAUGHT:');
      debugPrint(details.toString());
      throw details.exception;
    };
  });

  Widget buildTestApp() {
    return Theme(
      data: ThemeData(platform: TargetPlatform.android),
      child: const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AuditHubPage(),
          ),
        ),
      ),
    );
  }

  Widget buildDialogTestApp(Widget dialog) {
    return Theme(
      data: ThemeData(platform: TargetPlatform.android),
      child: ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: dialog,
          ),
        ),
      ),
    );
  }

  testWidgets('AuditHubPage exhaustive end-to-end mobile overflow test at 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final state = tester.state<AuditHubPageState>(find.byType(AuditHubPage));

    // 1. Test all 10 Advisory Tabs
    for (int tab = 0; tab < 10; tab++) {
      state.setTestState(
        activeAdvisoryTab: tab,
        showClientRequests: false,
        showTeamRequests: false,
      );
      await tester.pumpAndSettle();

      // If Clients tab (tab 1), also test ledger sub-view
      if (tab == 1) {
        state.setTestState(showClientRequests: true);
        await tester.pumpAndSettle();
      }

      // If Teams tab (tab 3), also test requests sub-view
      if (tab == 3) {
        state.setTestState(showTeamRequests: true);
        await tester.pumpAndSettle();
      }
    }

    // 2. Test Auditor Suite (tab 6) across all 6 roles and all sub-tabs
    state.setTestState(
      activeAdvisoryTab: 6,
      showClientRequests: false,
      showTeamRequests: false,
    );
    await tester.pumpAndSettle();

    final roleSubTabCounts = [9, 10, 5, 5, 5, 5]; // number of sub-tabs per role

    for (int role = 0; role < 6; role++) {
      for (int sub = 0; sub < roleSubTabCounts[role]; sub++) {
        state.setTestState(
          selectedAuditorIndex: role,
          activeSubTab: sub,
        );
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('AuditHubPage exhaustive end-to-end mobile overflow test at 375x812', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final state = tester.state<AuditHubPageState>(find.byType(AuditHubPage));

    for (int tab = 0; tab < 10; tab++) {
      state.setTestState(
        activeAdvisoryTab: tab,
        showClientRequests: false,
        showTeamRequests: false,
      );
      await tester.pumpAndSettle();
    }

    state.setTestState(activeAdvisoryTab: 6);
    await tester.pumpAndSettle();

    final roleSubTabCounts = [9, 10, 5, 5, 5, 5];
    for (int role = 0; role < 6; role++) {
      for (int sub = 0; sub < roleSubTabCounts[role]; sub++) {
        state.setTestState(
          selectedAuditorIndex: role,
          activeSubTab: sub,
        );
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('VerifyIcaiDialog & AssignTaskDialog overflow test at 320x640 and 375x812', (tester) async {
    for (final size in [const Size(320, 640), const Size(375, 812)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      // Test VerifyIcaiDialog
      await tester.pumpWidget(buildDialogTestApp(const VerifyIcaiDialog()));
      await tester.pumpAndSettle();

      // Test AssignTaskDialog
      await tester.pumpWidget(buildDialogTestApp(const AssignTaskDialog()));
      await tester.pumpAndSettle();
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

