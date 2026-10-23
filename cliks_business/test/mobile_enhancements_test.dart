import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/core/widgets/avatar_widget.dart';
import 'package:clicks_business_frontend/features/auth/notifiers/auth_notifier.dart';
import 'package:clicks_business_frontend/features/profile/pages/profile_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/accounting_page.dart';
import 'package:clicks_business_frontend/features/billing/pages/expenses_page.dart';
import 'package:clicks_business_frontend/features/navigation/shell_layout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mobile OS specific enhancements vs macOS untouched', () {
    setUp(() async {
      await TokenService.clearTokens();
      await TokenService.setExplicitlyLoggedOut(false);
    });

    test('TokenService explicit logout flag persistence', () async {
      expect(await TokenService.isExplicitlyLoggedOut(), isFalse);

      await TokenService.setExplicitlyLoggedOut(true);
      expect(await TokenService.isExplicitlyLoggedOut(), isTrue);

      await TokenService.setExplicitlyLoggedOut(false);
      expect(await TokenService.isExplicitlyLoggedOut(), isFalse);
    });

    test('Mobile AuthNotifier auto-logs in unless explicitly logged out', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      try {
        await TokenService.clearTokens();
        await TokenService.setExplicitlyLoggedOut(false);

        final notifier = AuthNotifier();
        // Give async initial check a moment
        await Future.delayed(const Duration(milliseconds: 100));

        // On mobile, first open should automatically go into account
        expect(notifier.state.isLoggedIn, isTrue);

        // Explicit logout on mobile should set state to false and save flag
        await notifier.logout();
        expect(notifier.state.isLoggedIn, isFalse);
        expect(await TokenService.isExplicitlyLoggedOut(), isTrue);

        // When explicitly logged out, re-initializing notifier stays logged out
        final loggedOutNotifier = AuthNotifier();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(loggedOutNotifier.state.isLoggedIn, isFalse);

        // Logging back in clears explicit logout flag
        loggedOutNotifier.login();
        expect(loggedOutNotifier.state.isLoggedIn, isTrue);
        expect(await TokenService.isExplicitlyLoggedOut(), isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('macOS AuthNotifier preserves standard desktop behavior', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      try {
        await TokenService.clearTokens();
        await TokenService.setExplicitlyLoggedOut(false);

        final notifier = AuthNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        // When no tokens exist on macOS desktop, it does NOT auto-login
        expect(notifier.state.isLoggedIn, isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('ProfilePage fetches and displays AvatarWidget on mobile', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
        await TokenService.saveUserInfo(
          email: 'ravinew2004@bnxmail.com',
          name: 'Ravi Kumar',
        );
        await TokenService.saveUserAvatar('ravinew2004@bnxmail.com', 'https://example.com/avatar.png');

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProfilePage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check AvatarWidget presence
        expect(find.byType(AvatarWidget), findsWidgets);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('AccountingPage and ExpensesPage FABs are elevated with bottom padding', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
        // AccountingPage Record Entry FAB
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: AccountingPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final accountingFab = find.byType(FloatingActionButton);
        expect(accountingFab, findsOneWidget);

        // Verify the AccountingPage FAB is wrapped in a Padding widget with bottom padding >= 24
        final paddingFinder = find.ancestor(of: accountingFab, matching: find.byType(Padding));
        expect(paddingFinder, findsWidgets);
        final paddingWidget = tester.widget<Padding>(paddingFinder.first);
        final insets = paddingWidget.padding as EdgeInsets;
        expect(insets.bottom, greaterThanOrEqualTo(24.0));

        // ExpensesPage Record Expense FAB
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ExpensesPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final expensesFab = find.byType(FloatingActionButton);
        expect(expensesFab, findsOneWidget);
        final expPaddingFinder = find.ancestor(of: expensesFab, matching: find.byType(Padding));
        expect(expPaddingFinder, findsWidgets);
        final expPaddingWidget = tester.widget<Padding>(expPaddingFinder.first);
        final expInsets = expPaddingWidget.padding as EdgeInsets;
        expect(expInsets.bottom, greaterThanOrEqualTo(24.0));
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('ShellLayout renders renderedPage cleanly without opaque bottom padding for transparent bar', (tester) async {
      // 1. Mobile test (390x844)
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShellLayout(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // On mobile, ensure there is NO artificial bottom: 84.0 padding cutting off the page
        final paddings = tester.widgetList<Padding>(find.byType(Padding));
        final mobileBasePadding = paddings.where((p) {
          if (p.padding is EdgeInsets) {
            return (p.padding as EdgeInsets).bottom == 84.0;
          }
          return false;
        });
        expect(mobileBasePadding, isEmpty);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }

      // 2. Desktop test (1280x800, macOS)
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ShellLayout(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // On desktop (width >= 1100, macOS), bottom 84.0 padding should NOT exist
        final paddings = tester.widgetList<Padding>(find.byType(Padding));
        final mobileBasePadding = paddings.where((p) {
          if (p.padding is EdgeInsets) {
            return (p.padding as EdgeInsets).bottom == 84.0;
          }
          return false;
        });
        expect(mobileBasePadding, isEmpty);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });
  });
}
