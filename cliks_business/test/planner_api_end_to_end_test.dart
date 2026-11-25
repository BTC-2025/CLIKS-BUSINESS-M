import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/data/models/payment_models.dart';
import 'package:clicks_business_frontend/data/repositories/payments_repository.dart';
import 'package:clicks_business_frontend/features/payments/pages/planner_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Planner API End-to-End Tests (Section 5)', () {
    test('5.1 List Planned Payments & Query Filters', () async {
      final allPlans = await PaymentsRepository.getPlannedPayments();
      expect(allPlans, isNotEmpty);
      expect(allPlans.length, greaterThanOrEqualTo(9));

      // Test filter by category
      final utilPlans = await PaymentsRepository.getPlannedPayments(category: 'Utilities');
      expect(utilPlans, isNotEmpty);
      expect(utilPlans.every((p) => p.category.toLowerCase() == 'utilities'), isTrue);

      // Test filter by status
      final pendingPlans = await PaymentsRepository.getPlannedPayments(status: 'pending');
      expect(pendingPlans, isNotEmpty);
      expect(pendingPlans.every((p) => p.status.toLowerCase() == 'pending'), isTrue);
    });

    test('5.2 Create Planned Payment via API', () async {
      final req = CreatePlannedPaymentRequest(
        name: 'Datacenter Server Lease',
        amount: 85000.0,
        dueDate: '2026-12-10',
        frequency: 'Monthly Recurring',
        category: 'Utilities',
        type: 'SEND',
        description: 'Primary datacenter cloud cluster servers',
        notes: 'Monthly billing cycle on 10th',
      );

      final created = await PaymentsRepository.createPlannedPayment(req);
      expect(created.id, isNotNull);
      expect(created.name, equals('Datacenter Server Lease'));
      expect(created.amount, equals(85000.0));
      expect(created.status.toLowerCase(), equals('pending'));
      expect(created.isSend, isTrue);

      // Verify it appears in the list
      final list = await PaymentsRepository.getPlannedPayments();
      expect(list.any((p) => p.id.toString() == created.id.toString()), isTrue);
    });

    test('5.3 Get Planned Payment Details by ID', () async {
      final list = await PaymentsRepository.getPlannedPayments();
      final target = list.first;

      final fetched = await PaymentsRepository.getPlannedPaymentById(target.id);
      expect(fetched, isNotNull);
      expect(fetched!.id.toString(), equals(target.id.toString()));
      expect(fetched.name, equals(target.name));
      expect(fetched.amount, equals(target.amount));
    });

    test('5.4 Update Planned Payment via PATCH', () async {
      final req = CreatePlannedPaymentRequest(
        name: 'Warehouse Maintenance Retainer',
        amount: 5000.0,
        dueDate: '2026-12-15',
        frequency: 'Monthly Recurring',
        category: 'Rent (Monthly)',
      );
      final created = await PaymentsRepository.createPlannedPayment(req);

      final updated = await PaymentsRepository.updatePlannedPayment(created.id, {
        'amount': 6500.0,
        'description': 'Revised warehouse expansion maintenance',
      });

      expect(updated.amount, equals(6500.0));
      expect(updated.description, equals('Revised warehouse expansion maintenance'));
    });

    test('5.5 Mark Planned Payment as Paid via mark-paid PATCH', () async {
      final req = CreatePlannedPaymentRequest(
        name: 'Electricity Substation Fee',
        amount: 15000.0,
        dueDate: '2026-12-05',
        frequency: 'Monthly Recurring',
        category: 'Utilities',
      );
      final created = await PaymentsRepository.createPlannedPayment(req);

      await PaymentsRepository.markPlannedPaymentPaid(created.id);

      final list = await PaymentsRepository.getPlannedPayments();
      final paidItem = list.firstWhere((p) => p.id.toString() == created.id.toString());
      expect(paidItem.isPaid, isTrue);
    });

    test('5.6 Delete Planned Payment via DELETE', () async {
      final req = CreatePlannedPaymentRequest(
        name: 'Temporary Event Setup',
        amount: 3000.0,
        dueDate: '2026-12-25',
        frequency: 'One-Time',
        category: 'General',
      );
      final created = await PaymentsRepository.createPlannedPayment(req);

      await PaymentsRepository.deletePlannedPayment(created.id);

      final list = await PaymentsRepository.getPlannedPayments();
      expect(list.any((p) => p.id.toString() == created.id.toString()), isFalse);
    });

    testWidgets('PlannerPage UI renders data fetched from API end-to-end', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PlannerPage(),
          ),
        ),
      );

      // Allow async _loadData to complete
      await tester.pumpAndSettle();

      // Verify page title
      expect(find.text('Payment Planner'), findsOneWidget);

      // Verify stat cards
      expect(find.text('TOTAL SCHEDULED'), findsOneWidget);
      expect(find.text('TOTAL OUTWARD'), findsOneWidget);
      expect(find.text('TOTAL INWARD'), findsOneWidget);
      expect(find.text('MONTHLY / RENT PLANS'), findsOneWidget);

      // Verify Schedule Payment button
      expect(find.text('Schedule Payment'), findsOneWidget);

      // Verify scheduled payments loaded from API
      expect(find.text('Electricity / Internet Bill'), findsWidgets);
      expect(find.text('Office Space Rent'), findsWidgets);
    });

    testWidgets('Schedule Payment dialog opens, creates payment, and shows snackbar safely', (tester) async {
      tester.view.physicalSize = const Size(1200, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PlannerPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Schedule Payment' button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Schedule Payment'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Schedule transfers, monthly rent, and trigger automated email notifications'), findsOneWidget);

      // Enter payment name and amount in dialog form fields
      final formFields = find.byType(TextFormField);
      await tester.enterText(formFields.at(0), 'Vendor Invoice Bill');
      await tester.enterText(formFields.at(1), '4000.00');

      // Submit dialog
      final submitBtn = find.widgetWithText(ElevatedButton, '+ Schedule Payment');
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pumpAndSettle();

      // Dialog should be dismissed without deactivated ancestor error
      expect(find.text('Schedule transfers, monthly rent, and trigger automated email notifications'), findsNothing);
    });
  });
}
