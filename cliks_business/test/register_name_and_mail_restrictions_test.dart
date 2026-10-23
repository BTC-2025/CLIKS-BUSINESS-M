import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/features/auth/pages/register_account_type_screen.dart';

void main() {
  group('RegisterAccountTypeScreen Name & Mail Creation Restrictions (6-15 chars)', () {
    Widget buildTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RegisterAccountTypeScreen(initialStep: 'personal'),
          ),
        ),
      );
    }

    testWidgets('First Name and Last Name must be between 6 and 15 characters', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Navigate to personal profile step
      final forMyselfCard = find.text('For myself');
      if (forMyselfCard.evaluate().isNotEmpty) {
        await tester.tap(forMyselfCard);
        await tester.pumpAndSettle();
      }

      // Verify Personal Details step is visible
      expect(find.text('Personal Details'), findsOneWidget);

      final nextStepBtn = find.text('Next Step');
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // 1. Empty submission
      await tester.tap(nextStepBtn);
      await tester.pumpAndSettle();

      expect(find.text('First Name is required'), findsOneWidget);
      expect(find.text('Last Name is required'), findsOneWidget);

      // 2. Too short (< 6 chars)
      await tester.enterText(textFields.at(0), 'Alex'); // 4 chars
      await tester.pumpAndSettle();

      await tester.tap(nextStepBtn);
      await tester.pumpAndSettle();

      expect(find.text('First Name must be between 6 and 15 characters'), findsOneWidget);

      // 3. Valid name between 6 and 15 chars
      await tester.enterText(textFields.at(0), 'Alexander'); // 9 chars
      await tester.pumpAndSettle();

      // Last name too short (< 6 chars)
      final lastNameField = textFields.at(1);
      await tester.enterText(lastNameField, 'Lee'); // 3 chars
      await tester.pumpAndSettle();

      await tester.tap(nextStepBtn);
      await tester.pumpAndSettle();

      expect(find.text('First Name must be between 6 and 15 characters'), findsNothing);
      expect(find.text('Last Name must be between 6 and 15 characters'), findsOneWidget);

      // Enter valid last name (6 to 15 chars)
      await tester.enterText(lastNameField, 'Franklin'); // 8 chars
      await tester.pumpAndSettle();

      // Valid DOB
      final dobField = textFields.at(2);
      await tester.enterText(dobField, '15/08/1995');
      await tester.pumpAndSettle();

      // Tap Next Step -> should proceed to choose email address
      await tester.tap(nextStepBtn);
      await tester.pumpAndSettle();

      expect(find.text('Choose your email address'), findsOneWidget);
    });

    testWidgets('Mail creation custom handle must be between 6 and 15 characters', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Step 1: selection
      final forMyselfCard = find.text('For myself');
      if (forMyselfCard.evaluate().isNotEmpty) {
        await tester.tap(forMyselfCard);
        await tester.pumpAndSettle();
      }

      // Step 2: enter valid names & DOB
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Alexander');
      await tester.enterText(textFields.at(1), 'Hamilton');
      await tester.enterText(textFields.at(2), '11/01/1990');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your email address'), findsOneWidget);

      // Custom handle field
      final usernameField = find.byType(TextField).first;

      // 1. Test empty handle
      await tester.enterText(usernameField, '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      expect(find.text('Username is required'), findsOneWidget);

      // 2. Test handle too short (< 6 chars)
      await tester.enterText(usernameField, 'alex');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      expect(find.text('Username must be between 6 and 15 characters'), findsOneWidget);

      // 3. Test handle with invalid characters
      await tester.enterText(usernameField, 'alex_hamilton');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      expect(find.text('Only lowercase letters and numbers are allowed'), findsOneWidget);

      // 4. Test valid handle within 6-15 chars
      await tester.enterText(usernameField, 'alexander99'); // 11 chars
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      // Should advance past mail step to Mobile Verification
      expect(find.text('Mobile Verification'), findsOneWidget);
    });
  });
}
