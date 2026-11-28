import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/data/models/people_models.dart';
import 'package:clicks_business_frontend/features/people/widgets/enroll_contact_dialog.dart';
import 'package:clicks_business_frontend/features/people/widgets/record_transaction_dialog.dart';

void main() {
  final List<PersonContact> sampleContacts = [
    const PersonContact(
      id: 70,
      name: 'kamesh',
      phone: '9876543210',
      email: 'itsokletssee123@bnxmail.com',
      company: 'Kamesh Logistics',
      roleType: 'partner',
    ),
    const PersonContact(
      id: 71,
      name: 'sridharan',
      phone: '9876543211',
      email: 'sridharan@bnxmail.com',
      roleType: 'friend',
    ),
  ];

  group('RecordTransactionDialog UI & Interaction Tests', () {
    testWidgets('Renders all fields accurately matching reference screenshot', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordTransactionDialog(
              contacts: sampleContacts,
            ),
          ),
        ),
      );

      expect(find.text('Record Peer Transaction'), findsOneWidget);
      expect(find.text('Target Network User'), findsOneWidget);
      expect(find.text('Entry Direction'), findsOneWidget);
      expect(find.text('Ledger Date'), findsOneWidget);
      expect(find.text('Value Cap Amount (₹)'), findsOneWidget);
      expect(find.text('Asset narrative / Memo'), findsOneWidget);
      expect(find.text('Authorize Entry Log'), findsOneWidget);
      expect(find.byKey(const Key('close_record_peer_tx_dialog')), findsOneWidget);
    });

    testWidgets('Validates zero amount on submission', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordTransactionDialog(
              contacts: sampleContacts,
            ),
          ),
        ),
      );

      // Amount is 0.00 by default. Tap Authorize Entry Log
      await tester.tap(find.byKey(const Key('btn_authorize_entry_log')));
      await tester.pump();

      expect(find.text('Please enter a valid amount greater than ₹0'), findsOneWidget);
    });

    testWidgets('Submits valid transaction successfully', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      dynamic submittedPersonId;
      String? submittedType;
      double? submittedAmount;
      String? submittedDate;
      String? submittedDesc;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordTransactionDialog(
              contacts: sampleContacts,
              onSubmit: (personId, type, amount, date, description) async {
                submittedPersonId = personId;
                submittedType = type;
                submittedAmount = amount;
                submittedDate = date;
                submittedDesc = description;
              },
            ),
          ),
        ),
      );

      // Enter amount
      await tester.enterText(find.byKey(const Key('input_peer_tx_amount')), '5000');
      // Enter memo
      await tester.enterText(
        find.byKey(const Key('input_peer_tx_memo')),
        'Advance for marketing services',
      );
      await tester.pump();

      // Tap Authorize Entry Log
      await tester.tap(find.byKey(const Key('btn_authorize_entry_log')));
      await tester.pump();

      expect(submittedPersonId, 70);
      expect(submittedType, 'lent');
      expect(submittedAmount, 5000.0);
      expect(submittedDesc, 'Advance for marketing services');
      expect(submittedDate, isNotNull);
    });
  });

  group('EnrollContactDialog UI & Interaction Tests', () {
    testWidgets('Renders all fields accurately matching reference screenshot', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnrollContactDialog(),
          ),
        ),
      );

      expect(find.text('Enroll New Contact'), findsOneWidget);
      expect(find.text('Full Identity Name *'), findsOneWidget);
      expect(find.text('Network Role'), findsOneWidget);
      expect(find.text('Company Label'), findsOneWidget);
      expect(find.text('Phone Contact *'), findsOneWidget);
      expect(find.text('E-Mail Address (bnxmail) *'), findsOneWidget);
      expect(find.textContaining('Only @bnxmail.com accepted'), findsOneWidget);
      expect(find.text('Create Contact Node'), findsOneWidget);
      expect(find.byKey(const Key('close_enroll_contact_dialog')), findsOneWidget);
    });

    testWidgets('Validates required fields and email domain', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnrollContactDialog(),
          ),
        ),
      );

      // Tap without filling
      await tester.tap(find.byKey(const Key('btn_create_contact_node')));
      await tester.pump();

      expect(find.text('Full identity name is required'), findsOneWidget);

      // Fill name but invalid phone & non-bnx email
      await tester.enterText(find.byKey(const Key('input_enroll_name')), 'Rahul Dev');
      await tester.enterText(find.byKey(const Key('input_enroll_phone')), '123');
      await tester.enterText(find.byKey(const Key('input_enroll_email')), 'rahul@gmail.com');
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_create_contact_node')));
      await tester.pump();

      expect(find.text('Enter a valid 10-digit phone number'), findsOneWidget);
      expect(find.text('Only @bnxmail.com accepted'), findsOneWidget);
    });

    testWidgets('Submits valid contact successfully', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      CreatePersonRequest? submittedReq;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnrollContactDialog(
              onSubmit: (req) async {
                submittedReq = req;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('input_enroll_name')), 'Rahul Dev');
      await tester.enterText(find.byKey(const Key('input_enroll_company')), 'Dunder Mifflin');
      await tester.enterText(find.byKey(const Key('input_enroll_phone')), '9876543210');
      await tester.enterText(find.byKey(const Key('input_enroll_email')), 'rahuldev@bnxmail.com');
      await tester.pump();

      await tester.tap(find.byKey(const Key('btn_create_contact_node')));
      await tester.pump();

      expect(submittedReq, isNotNull);
      expect(submittedReq!.name, 'Rahul Dev');
      expect(submittedReq!.company, 'Dunder Mifflin');
      expect(submittedReq!.phone, '9876543210');
      expect(submittedReq!.email, 'rahuldev@bnxmail.com');
      expect(submittedReq!.roleType, 'friend');
    });
  });
}
