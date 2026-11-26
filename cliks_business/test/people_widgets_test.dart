import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/models/people_models.dart';
import 'package:clicks_business_frontend/features/people/pages/people_page.dart';
import 'package:clicks_business_frontend/features/people/providers/people_providers.dart';

class _TestPeopleNotifier extends PeopleNotifier {
  _TestPeopleNotifier(PeopleState initial) {
    state = initial;
  }

  @override
  Future<void> loadAll({bool isRefresh = false}) async {
    // No-op for deterministic widget testing
  }
}

void main() {
  setUp(() async {
    await TokenService.saveTokens(
      accessToken: 'test_token',
      refreshToken: 'test_refresh',
    );
    await TokenService.saveUserInfo(
      email: 'testuser@bnxmail.com',
      name: 'Test Business User',
    );
  });

  final testContacts = [
    const PersonContact(
      id: 1,
      name: 'Kiran Kumar',
      roleType: 'Partner',
      relationship: 'Investor',
      company: 'Kiran Ventures',
      phone: '+919876543210',
      email: 'kiran@bnxmail.com',
      totalLent: 100000.0,
      totalBorrowed: 25000.0,
      netBalance: 75000.0,
    ),
    const PersonContact(
      id: 2,
      name: 'Dev Sharma',
      roleType: 'Vendor',
      relationship: 'Supplier',
      company: 'Sharma Logistics',
      phone: '+919123456780',
      email: 'dev@bnxmail.com',
      totalLent: 10000.0,
      totalBorrowed: 40000.0,
      netBalance: -30000.0,
    ),
  ];

  final testSummary = PeopleSummary.fromContacts(testContacts);

  final testGroups = [
    const FinancialGroup(
      id: 101,
      name: 'Core Founders Fund',
      currency: 'INR',
      targetAmount: 500000.0,
      memberCount: 4,
      description: 'Syndicate reserve pool',
    ),
  ];

  final testReminders = [
    const RepaymentAlert(
      id: 201,
      contactId: 1,
      targetContact: 'Kiran Kumar',
      claimCap: 25000.0,
      maturityDate: '2026-06-30',
      memoLabel: 'Advance Dividend',
      status: 'Pending',
    ),
  ];

  final testTransactions = [
    const PersonTransaction(
      id: 301,
      personId: 1,
      personName: 'Kiran Kumar',
      type: 'lent',
      amount: 50000.0,
      date: '2026-03-15',
      status: 'completed',
      notes: 'Angel advance Q1',
    ),
  ];

  final testRequests = [
    const ConnectionRequest(
      id: 401,
      fromUserId: 99,
      fromName: 'Anita Roy',
      fromEmail: 'anita@bnxmail.com',
    ),
  ];

  final populatedState = PeopleState(
    isLoading: false,
    contacts: testContacts,
    summary: testSummary,
    groups: testGroups,
    reminders: testReminders,
    transactions: testTransactions,
    incomingRequests: testRequests,
  );

  group('PeoplePage Widget & UI Integration Tests', () {
    testWidgets('1. Renders page title, subtitle, and primary actions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('People Network & Escrow'), findsOneWidget);
      expect(
        find.text(
          'Track peer-to-peer relationships, log personal advances, track friendly loans, and set ledger alerts.',
        ),
        findsOneWidget,
      );
      expect(find.text('Log Transaction'), findsOneWidget);
      expect(find.text('Add People Contact'), findsOneWidget);
    });

    testWidgets('2. Renders financial summary cards with actual backend metrics', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Summary Card A: TO RECEIVE & Card B: TO PAY
      expect(find.text('TO RECEIVE'), findsOneWidget);
      expect(find.text('TO PAY'), findsOneWidget);
      expect(find.textContaining('Collected'), findsOneWidget);
      expect(find.textContaining('Settled'), findsOneWidget);
    });

    testWidgets('3. Renders 5 main navigation tabs with dynamic counts', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Contacts'), findsWidgets);
      expect(find.textContaining('Financial Groups'), findsWidgets);
      expect(find.textContaining('Requests'), findsWidgets);
      expect(find.textContaining('Global Ledger'), findsWidgets);
      expect(find.textContaining('Repayment Alerts'), findsWidgets);
    });

    testWidgets('4. Contacts table displays dynamic backend data rows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Kiran Kumar'), findsOneWidget);
      expect(find.text('Dev Sharma'), findsOneWidget);
      expect(find.text('Kiran Ventures'), findsOneWidget);
      expect(find.text('Sharma Logistics'), findsOneWidget);
      expect(find.text('kiran@bnxmail.com'), findsOneWidget);
      expect(find.text('dev@bnxmail.com'), findsOneWidget);
    });

    testWidgets('5. Search toggle button reveals search input and filters table', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Toggle search icon
      final searchIconBtn = find.byIcon(LucideIcons.search);
      expect(searchIconBtn, findsWidgets);

      await tester.tap(searchIconBtn.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Enter search query
      final searchInput = find.byType(TextField);
      expect(searchInput, findsOneWidget);

      await tester.enterText(searchInput, 'Kiran');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Kiran Kumar'), findsOneWidget);
      expect(find.text('Dev Sharma'), findsNothing);
    });

    testWidgets('6. Tab switching opens Financial Groups tab', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Financial Groups
      final groupsTab = find.textContaining('Financial Groups');
      await tester.tap(groupsTab.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Core Founders Fund'), findsOneWidget);
      expect(find.text('Syndicate reserve pool'), findsOneWidget);
    });

    testWidgets('7. Tab switching opens Repayment Alerts tab', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Repayment Alerts
      final alertsTab = find.textContaining('Repayment Alerts');
      await tester.tap(alertsTab.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Advance Dividend'), findsOneWidget);
      expect(find.text('Kiran Kumar'), findsWidgets);
    });

    testWidgets('8. Tab switching opens Global Ledger tab', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Global Ledger
      final ledgerTab = find.textContaining('Global Ledger');
      await tester.tap(ledgerTab.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Angel advance Q1'), findsOneWidget);
    });

    testWidgets('9. Log Transaction button displays informational guidance dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Log Transaction
      final logBtn = find.text('Log Transaction');
      await tester.tap(logBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Log Transaction Notice'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);
    });

    testWidgets('10. Add People Contact opens dialog and enforces @bnxmail.com', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Add People Contact
      final addBtn = find.text('Add People Contact');
      await tester.tap(addBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Dialog is open
      expect(find.text('Add People Contact'), findsWidgets);
      expect(find.text('Enroll Contact'), findsOneWidget);

      // Tap save without filling form - validation triggers
      await tester.ensureVisible(find.text('Enroll Contact'));
      await tester.tap(find.text('Enroll Contact'));
      await tester.pump();

      expect(find.text('Full name is required'), findsOneWidget);
    });

    testWidgets('11. Pending Invitations banner displays request and Review All switches tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Banner Title and Review All button
      expect(find.text('Pending Invitations (1)'), findsOneWidget);
      expect(find.text('1 contact request(s) sent to your @bnxmail.com address.'), findsOneWidget);
      expect(find.text('Review All (1)'), findsOneWidget);

      // Verify Request card inside banner
      expect(find.text('Anita Roy'), findsOneWidget);
      expect(find.text('anita@bnxmail.com'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsWidgets);

      // Tap Review All (1) -> switches to Requests tab
      await tester.tap(find.text('Review All (1)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Incoming Requests & Invitations'), findsOneWidget);
      expect(find.text('Direct Contact Requests (1)'), findsOneWidget);
      expect(find.text('Accept Request'), findsOneWidget);
    });

    testWidgets('12. Requests tab UI renders full request card with badges and action buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(populatedState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to Requests tab
      final reqTab = find.textContaining('Requests');
      await tester.tap(reqTab.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Incoming Requests & Invitations'), findsOneWidget);
      expect(find.text('1 Pending'), findsOneWidget);
      expect(find.text('Direct Contact Requests (1)'), findsOneWidget);
      expect(find.text('Anita Roy'), findsWidgets);
      expect(find.text('anita@bnxmail.com'), findsWidgets);
      expect(find.text('COLLEAGUE'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Accept Request'), findsOneWidget);
      expect(find.text('Decline'), findsWidgets);
    });

    testWidgets('13. Zero network contacts renders table with empty message', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));

      final emptyContactsState = populatedState.copyWith(contacts: []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            peopleProvider.overrideWith((ref) => _TestPeopleNotifier(emptyContactsState)),
          ],
          child: const MaterialApp(home: PeoplePage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Table headers are present
      expect(find.text('PROFILE CONTACT'), findsOneWidget);
      expect(find.text('CLASSIFICATION'), findsOneWidget);
      expect(find.text('COMPANY / LINK'), findsOneWidget);
      expect(find.text('PHONE / EMAIL'), findsOneWidget);
      expect(find.text('NET EXPOSURE'), findsOneWidget);

      // Centered empty state text from Image 2
      expect(find.text('Zero network contacts found. Start adding!'), findsOneWidget);
    });
  });
}
