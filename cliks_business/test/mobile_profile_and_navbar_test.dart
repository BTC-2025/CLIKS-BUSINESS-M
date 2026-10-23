import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:clicks_business_frontend/core/widgets/avatar_widget.dart';
import 'package:clicks_business_frontend/features/profile/pages/profile_page.dart';
import 'package:clicks_business_frontend/features/profile/presentation/manage_account_screen.dart';
import 'package:clicks_business_frontend/features/navigation/shell_layout.dart';

void main() {
  group('Mobile Profile & Bottom Bar Responsiveness & Auth Integration', () {
    testWidgets('ProfilePage renders on 390x844 mobile resolution without RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
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

        // Check for ProfilePage presence
        expect(find.byType(ProfilePage), findsOneWidget);

        // Verify profile avatar widget is present in header
        expect(find.byType(AvatarWidget), findsWidgets);

        // Scroll and verify "Sign Out" tile exists on mobile
        final signOutTile = find.text('Sign Out');
        await tester.scrollUntilVisible(signOutTile, 200);
        await tester.pumpAndSettle();
        expect(signOutTile, findsOneWidget);

        // Verify "Terminate Secure Session" button exists
        final terminateBtn = find.text('Terminate Secure Session');
        await tester.scrollUntilVisible(terminateBtn, 200);
        await tester.pumpAndSettle();
        expect(terminateBtn, findsOneWidget);

        // No Flutter errors (e.g. RenderFlex overflow) occurred
        expect(tester.takeException(), isNull);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('ProfilePage renders on 360x640 compact mobile resolution without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      try {
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

        expect(find.byType(ProfilePage), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Tapping Sign Out on mobile triggers confirmation dialog',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
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

        // Scroll to make Sign Out visible
        final signOutTile = find.text('Sign Out');
        await tester.scrollUntilVisible(signOutTile, 200);
        await tester.pumpAndSettle();

        expect(signOutTile, findsOneWidget);
        await tester.tap(signOutTile);
        await tester.pumpAndSettle();

        // Confirm dialog shows up with title & options
        expect(find.text('Are you sure you want to sign out of this account?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Sign Out'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Tapping Terminate Secure Session on mobile triggers confirmation dialog',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
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

        final terminateBtn = find.text('Terminate Secure Session');
        await tester.scrollUntilVisible(terminateBtn, 200);
        await tester.pumpAndSettle();

        expect(terminateBtn, findsOneWidget);
        await tester.tap(terminateBtn);
        await tester.pumpAndSettle();

        expect(find.text('Terminate Session?'), findsOneWidget);
        expect(find.text('Terminate'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('Expanding account switcher reveals Manage Account and Add another account bottom sheet',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
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

        // Tap on chevron / username row in header to expand accounts
        final chevron = find.byIcon(LucideIcons.chevronDown);
        expect(chevron, findsOneWidget);
        await tester.tap(chevron);
        await tester.pumpAndSettle();

        // Verify "Manage Account" and "Add another account" are now visible
        expect(find.text('Manage Account'), findsOneWidget);
        final addAccountBtn = find.text('Add another account');
        expect(addAccountBtn, findsOneWidget);

        // Tap "Add another account"
        await tester.tap(addAccountBtn);
        await tester.pumpAndSettle();

        // Verify bottom sheet modal opened with both options
        expect(find.text('Add or Switch Account'), findsOneWidget);
        expect(find.text('Sign in with existing account'), findsOneWidget);
        expect(find.text('Create a new account'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('ManageAccountScreen renders on mobile and contains Sign Out button',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      try {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: ManageAccountScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ManageAccountScreen), findsOneWidget);

        // Verify mobile sign out button exists
        final signOutBtn = find.text('Sign out of account');
        await tester.scrollUntilVisible(
          signOutBtn,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        expect(signOutBtn, findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });

    testWidgets('ShellLayout bottom navigation bar renders on mobile with reduced horizontal length & increased breadth',
        (tester) async {
      FlutterErrorDetails? overflowDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          overflowDetails = details;
        }
        originalOnError?.call(details);
      };

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
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
        expect(tester.takeException(), isNull, reason: 'Initial load failed');

        // Active tab is Books by default, so text 'Books' is shown
        expect(find.text('Books'), findsWidgets);

        // Other tabs show their icons
        expect(find.byIcon(LucideIcons.wallet), findsWidgets);
        expect(find.byIcon(LucideIcons.messageCircle), findsWidgets);
        expect(find.byIcon(LucideIcons.user), findsWidgets);

        // Tap Profile tab in bottom bar
        final profileTab = find.byIcon(LucideIcons.user).last;
        await tester.tap(profileTab);
        await tester.pumpAndSettle();

        // Now Profile is active and its text is shown
        expect(find.text('Profile'), findsWidgets);

        final err = tester.takeException();
        expect(err, isNull);
      } finally {
        FlutterError.onError = originalOnError;
        debugDefaultTargetPlatformOverride = null;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });
  });
}
