import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/billing/models/archived_auditor_roles.dart';
import 'package:clicks_business_frontend/features/billing/pages/audit_hub_page.dart';

void main() {
  group('FIN-PRO Auditor Roles Frontend Filtering & Archival Tests', () {
    test('Archived roles model preserves all removed auditor roles safely', () {
      expect(kActiveAuditorRoles.length, equals(2));
      expect(kActiveAuditorRoles, contains('Statutory Financial Auditor (ICAI CA)'));
      expect(kActiveAuditorRoles, contains('Tax Auditor (ICAI CA)'));

      // Check archived roles
      expect(kArchivedAuditorRoles.length, equals(4));

      final internalAuditor = getArchivedAuditorRole(2);
      expect(internalAuditor, isNotNull);
      expect(internalAuditor!.fullName, equals('Internal Auditor (CIA / CA / CMA)'));
      expect(internalAuditor.shortName, equals('Internal Auditor'));
      expect(internalAuditor.suiteTitle, equals('Internal Audit & Controls Suite'));
      expect(internalAuditor.subTabs.length, equals(5));

      final costAuditor = getArchivedAuditorRole(3);
      expect(costAuditor, isNotNull);
      expect(costAuditor!.fullName, equals('Cost Auditor (ICMAI CMA)'));
      expect(costAuditor.suiteTitle, equals('Cost Audit & Compliance Suite'));

      final secretarialAuditor = getArchivedAuditorRole(4);
      expect(secretarialAuditor, isNotNull);
      expect(secretarialAuditor!.fullName, equals('Secretarial Auditor (ICSI CS)'));
      expect(secretarialAuditor.suiteTitle, equals('Secretarial Audit & Governance Suite'));

      final forensicAuditor = getArchivedAuditorRole(5);
      expect(forensicAuditor, isNotNull);
      expect(forensicAuditor!.fullName, equals('Forensic Auditor (ICAI FAFD / CFE)'));
      expect(forensicAuditor.suiteTitle, equals('Forensic Audit & Fraud Investigation Suite'));
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
      final platformName = platform == TargetPlatform.macOS ? 'macOS' : 'Mobile (Android)';

      testWidgets('Frontend displays ONLY statutory and tax auditor on $platformName', (tester) async {
        tester.view.physicalSize = platform == TargetPlatform.macOS ? const Size(1280, 800) : const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          Theme(
            data: ThemeData(platform: platform),
            child: const ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: AuditHubPage(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify "Statutory Financial Auditor (ICAI CA)" is present in the frontend
        expect(find.text('Statutory Financial Auditor (ICAI CA)'), findsOneWidget);

        // 2. Verify "Tax Auditor (ICAI CA)" is present in the frontend
        expect(find.text('Tax Auditor (ICAI CA)'), findsOneWidget);

        // 3. Verify removed auditors are NOT present in the frontend chips
        expect(find.text('Internal Auditor (CIA / CA / CMA)'), findsNothing);
        expect(find.text('Cost Auditor (ICMAI CMA)'), findsNothing);
        expect(find.text('Secretarial Auditor (ICSI CS)'), findsNothing);
        expect(find.text('Forensic Auditor (ICAI FAFD / CFE)'), findsNothing);

        // 4. Test selecting Tax Auditor chip
        final taxAuditorFinder = find.text('Tax Auditor (ICAI CA)');
        await tester.ensureVisible(taxAuditorFinder);
        await tester.pumpAndSettle();
        await tester.tap(taxAuditorFinder);
        await tester.pumpAndSettle();

        // Verify the suite switches to Tax Audit
        expect(find.text('Tax Audit & Form 3CD Hub'), findsOneWidget);
        expect(find.text('SEC 44AB TAX AUDIT'), findsOneWidget);

        // 5. Test selecting Statutory Financial Auditor chip
        final statutoryFinder = find.text('Statutory Financial Auditor (ICAI CA)');
        await tester.ensureVisible(statutoryFinder);
        await tester.pumpAndSettle();
        await tester.tap(statutoryFinder);
        await tester.pumpAndSettle();

        // Verify the suite switches to Statutory Financial Audit
        expect(find.text('Statutory Financial Audit Suite'), findsOneWidget);
        expect(find.text('ICAI CA STANDARD'), findsOneWidget);
      });
    }
  });
}
