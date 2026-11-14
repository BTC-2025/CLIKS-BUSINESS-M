import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/features/navigation/widgets/macos_right_utility_rail.dart';
import 'package:clicks_business_frontend/features/navigation/providers/bit_tool_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bit Tool API Module & Provider Integration Tests', () {
    test(
      'bitToolApiModuleProvider initializes with decoupled token provider',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final module = container.read(bitToolApiModuleProvider);
        expect(module, isA<BitToolApiModule>());
        expect(module.contacts, isNotNull);
        expect(module.notes, isNotNull);
        expect(module.calendar, isNotNull);
        expect(module.calculator, isNotNull);
        expect(module.notifications, isNotNull);
        expect(module.weather, isNotNull);
        expect(module.currency, isNotNull);
        expect(module.userProfile, isNotNull);
      },
    );

    test(
      'BitToolContactsNotifier manages contacts and search filtering',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final state = container.read(bitToolContactsProvider);
        expect(state.contacts, isA<List<ContactModel>>());

        // Add contact
        final added = await container
            .read(bitToolContactsProvider.notifier)
            .addContact(
              firstName: 'Vikram',
              lastName: 'Sharma',
              email: 'vikram@cliks.com',
              phone: '+91 9876543210',
              company: 'Cliks Tech',
              role: 'DevOps Lead',
            );
        expect(added, isTrue);

        final updatedState = container.read(bitToolContactsProvider);
        expect(
          updatedState.contacts.any((c) => c.firstName == 'Vikram'),
          isTrue,
        );

        // Filter
        container
            .read(bitToolContactsProvider.notifier)
            .setSearchQuery('Vikram');
        expect(
          container.read(bitToolContactsProvider).filteredContacts.length,
          1,
        );

        container
            .read(bitToolContactsProvider.notifier)
            .setSearchQuery('NonExistentContact');
        expect(
          container.read(bitToolContactsProvider).filteredContacts.isEmpty,
          isTrue,
        );
      },
    );

    test('BitToolNotesNotifier creates, pins, and deletes notes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialNotes = container.read(bitToolNotesProvider);
      expect(initialNotes.notes, isA<List<NoteModel>>());

      // Create new note
      final created = await container
          .read(bitToolNotesProvider.notifier)
          .createNote(
            title: 'Q4 Tax Audit',
            content: 'Review GSTR-9 annual filing',
            color: '#FEF3C7',
            isPinned: true,
          );
      expect(created, isTrue);

      final updatedState = container.read(bitToolNotesProvider);
      final newNote = updatedState.notes.firstWhere(
        (n) => n.title == 'Q4 Tax Audit',
      );
      expect(newNote.isPinned, isTrue);

      // Delete note
      final deleted = await container
          .read(bitToolNotesProvider.notifier)
          .deleteNote(newNote.id);
      expect(deleted, isTrue);
      expect(
        container
            .read(bitToolNotesProvider)
            .notes
            .any((n) => n.id == newNote.id),
        isFalse,
      );
    });

    test(
      'BitToolNotificationsNotifier tracks unread count and marks read',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifs = container.read(bitToolNotificationsProvider);
        expect(notifs.notifications, isNotEmpty);

        final firstNotif = notifs.notifications.first;
        await container
            .read(bitToolNotificationsProvider.notifier)
            .markAsRead(firstNotif.id);

        final updated = container.read(bitToolNotificationsProvider);
        expect(
          updated.notifications.firstWhere((n) => n.id == firstNotif.id).isRead,
          isTrue,
        );

        await container
            .read(bitToolNotificationsProvider.notifier)
            .markAllAsRead();
        expect(container.read(bitToolNotificationsProvider).unreadCount, 0);
      },
    );
  });

  group('MacOSRightUtilityRail UI Rendering Tests', () {
    testWidgets(
      'Renders vertical rail with exact 6 Bit Tool tools and toggles panels',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1280, 800));

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Align(
                  alignment: Alignment.centerRight,
                  child: MacOSRightUtilityRail(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify the rail and exact 6 tools + Beta Apps are present
        expect(find.byType(MacOSRightUtilityRail), findsOneWidget);
        expect(find.byTooltip('Beta Apps'), findsOneWidget);
        expect(find.byTooltip('Calculator'), findsOneWidget);
        expect(find.byTooltip('Calendar'), findsOneWidget);
        expect(find.byTooltip('Notes'), findsOneWidget);
        expect(find.byTooltip('Contacts'), findsOneWidget);
        expect(find.byTooltip('Weather'), findsOneWidget);
        expect(find.byTooltip('Keyboard'), findsOneWidget);
        expect(find.byTooltip('Toggle Drawer'), findsOneWidget);

        // Verify obsolete tools are NOT on the rail
        expect(find.byTooltip('Bit Tool Notifications'), findsNothing);
        expect(find.byTooltip('B2Auth & Account Profile'), findsNothing);
        expect(find.byTooltip('More Utilities & API Hub'), findsNothing);

        // 1. Tap Calculator button on the rail
        await tester.tap(find.byTooltip('Calculator'));
        await tester.pumpAndSettle();
        expect(find.text('CALCULATOR'), findsOneWidget);

        // 2. Tap Calendar button on the rail
        await tester.tap(find.byTooltip('Calendar'));
        await tester.pumpAndSettle();
        expect(find.text('CALENDAR'), findsOneWidget);

        // 3. Tap Notes button on the rail
        await tester.tap(find.byTooltip('Notes'));
        await tester.pumpAndSettle();
        expect(find.text('NOTES'), findsOneWidget);

        // 4. Tap Contacts button on the rail
        await tester.tap(find.byTooltip('Contacts'));
        await tester.pumpAndSettle();
        expect(find.text('GLOBAL CONTACTS'), findsOneWidget);

        // 5. Tap Weather button on the rail
        await tester.tap(find.byTooltip('Weather'));
        await tester.pumpAndSettle();
        expect(find.text('WEATHER'), findsOneWidget);

        // 6. Tap Keyboard button on the rail
        await tester.tap(find.byTooltip('Keyboard'));
        await tester.pumpAndSettle();
        expect(find.text('KEYBOARD'), findsOneWidget);
        expect(find.text('ABC'), findsOneWidget);
        expect(find.text('123 & Symbols'), findsOneWidget);
        expect(find.text('😊 Emojis'), findsOneWidget);

        // Test typing on virtual keyboard
        await tester.tap(find.text('h'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('i'));
        await tester.pumpAndSettle();
        expect(find.text('hi'), findsOneWidget);

        // Test Clear action
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        expect(find.text('hi'), findsNothing);
      },
    );
  });
}
