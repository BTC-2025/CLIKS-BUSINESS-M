import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/repositories/auth_repository.dart';
import 'package:clicks_business_frontend/data/repositories/user_repository.dart';
import 'package:clicks_business_frontend/features/auth/pages/login_screen.dart';
import 'package:clicks_business_frontend/features/auth/pages/register_account_type_screen.dart';
import 'package:clicks_business_frontend/features/navigation/widgets/macos_account_menu_card.dart';

void main() {
  testWidgets('LoginScreen renders UI correctly on macOS with inputs and links', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand / Header text
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Securely access your Bnx mail account.'), findsOneWidget);
    expect(find.text('Stay signed in'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create one for free'), findsOneWidget);

    // Verify TextFields for email and password
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets(
    'Clicking "Create one for free" navigates to RegisterAccountTypeScreen',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Create one for free"
      final createBtn = find.text('Create one for free');
      expect(createBtn, findsOneWidget);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      // Verify RegisterAccountTypeScreen opened
      expect(find.byType(RegisterAccountTypeScreen), findsOneWidget);
      expect(find.text('For myself'), findsOneWidget);
      expect(find.text('For my child'), findsOneWidget);
      expect(find.text('For business'), findsOneWidget);
    },
  );

  testWidgets(
    'MacOSAccountMenuCard sign out button exists and navigates to LoginScreen',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: Stack(
                children: [
                  MacOSAccountMenuCard(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Sign out button is present
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Sign out of all accounts'), findsOneWidget);

      // Tap Sign out
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      // Verify navigation pushed LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  group('BNX API & Repository Integration Tests', () {
    test('AuthRepository username suggestions returns handles conforming to spec', () async {
      final suggestions = await AuthRepository.getUsernameSuggestions(
        firstName: 'Ravi',
        lastName: 'Kumar',
        dob: '1998-05-15',
      );
      expect(suggestions, isNotEmpty);
      expect(suggestions.length, greaterThanOrEqualTo(2));
      for (final s in suggestions) {
        expect(s.length, greaterThanOrEqualTo(6));
      }
    });

    test('AuthRepository sendMobileOtp & verifyMobileOtp handles live & dev verification', () async {
      await expectLater(
        AuthRepository.sendMobileOtp('9876543210'),
        completes,
      );

      // Master dev OTP 123456 verification
      await expectLater(
        AuthRepository.verifyMobileOtp('9876543210', '123456'),
        completes,
      );
    });

    test('AuthRepository sendParentOtp & verifyParentOtp handles child flow', () async {
      await expectLater(
        AuthRepository.sendParentOtp('parent@bnxmail.com'),
        completes,
      );

      await expectLater(
        AuthRepository.verifyParentOtp('parent@bnxmail.com', '123456'),
        completes,
      );
    });

    test('AuthRepository fetchGstins returns valid list for PAN', () async {
      final gstins = await AuthRepository.fetchGstins('ABCDE1234F');
      expect(gstins, isNotEmpty);
      expect(gstins.first.contains('ABCDE1234F'), isTrue);
    });

    test('UserRepository saveBusinessOnboarding & isBusinessAccountOnboarded', () async {
      final testEmail = 'business_test_user@bnxmail.com';
      await TokenService.setBusinessOnboardingCompleted(testEmail, completed: false);

      await UserRepository.saveBusinessOnboarding({
        'businessName': 'Test Corp',
        'businessType': 'Private Limited Company',
        'industry': 'Software',
        'companySize': '11-50',
      }, email: testEmail);

      final onboarded = await UserRepository.isBusinessAccountOnboarded(testEmail);
      expect(onboarded, isTrue);
    });

    test('AuthRepository.logout() clears session tokens cleanly', () async {
      await TokenService.saveTokens(
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
      );
      expect(await TokenService.isLoggedIn(), isTrue);
      expect(await TokenService.getRefreshToken(), 'test_refresh_token');

      await AuthRepository.logout();

      expect(await TokenService.isLoggedIn(), isFalse);
      expect(await TokenService.getAccessToken(), isNull);
      expect(await TokenService.getRefreshToken(), isNull);
    });
  });
}
