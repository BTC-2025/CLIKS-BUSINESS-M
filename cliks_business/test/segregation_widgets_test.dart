import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/models/goal_wallet_models.dart';
import 'package:clicks_business_frontend/features/payments/pages/segregation_page.dart';
import 'package:clicks_business_frontend/features/payments/widgets/setup_target_wallet_dialog.dart';

void main() {
  setUp(() async {
    Animate.restartOnHotReload = false;
    await TokenService.saveTokens(
      accessToken: 'test_token',
      refreshToken: 'test_refresh',
    );
    await TokenService.saveUserInfo(
      email: 'ravinew2004@bnxmail.com',
      name: 'Ravi Kumar',
    );
  });

  group('Segregation Widget & UI Component Tests', () {
    testWidgets(
      'SegregationPage renders page header, subtitle, search icon, and setup button',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1000));

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: SegregationPage())),
        );

        // Allow initial frame to settle
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify Page Title & Subtitle
        expect(find.text('Segregation Wallets'), findsOneWidget);
        expect(
          find.text(
            'Create target-based wallets to isolate and secure funds for specific business needs.',
          ),
          findsOneWidget,
        );

        // Verify Setup Purpose Wallet button exists
        expect(find.text('Setup Purpose Wallet'), findsWidgets);

        // Tap search icon to toggle search bar
        await tester.tap(find.byTooltip('Search wallets'));
        await tester.pump();

        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'AllocationLedgerDialog renders wallet info and transaction history',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1000));

        final mockTransactions = [
          GoalWalletTransaction(
            id: '109',
            walletId: '71',
            amount: 4000.0,
            type: 'credit',
            createdAt: DateTime(2026, 11, 26, 14, 23),
          ),
          GoalWalletTransaction(
            id: '110',
            walletId: '71',
            amount: 1000.0,
            type: 'credit',
            createdAt: DateTime(2026, 11, 26, 14, 22),
          ),
          GoalWalletTransaction(
            id: '111',
            walletId: '71',
            amount: 5000.0,
            type: 'credit',
            createdAt: DateTime(2026, 11, 26, 14, 21),
          ),
        ];

        final mockWallet = GoalWallet(
          id: '71',
          name: 'Tax Reserve',
          targetAmount: 10000.0,
          currentAmount: 10000.0,
          status: 'active',
          transactions: mockTransactions,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: AllocationLedgerDialog(wallet: mockWallet)),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify Dialog Title
        expect(find.text('Allocation Ledger'), findsOneWidget);
        expect(find.text('SELECTED WALLET'), findsOneWidget);
        expect(find.text('Tax Reserve'), findsOneWidget);
        expect(find.text('Total Isolated'), findsOneWidget);
        expect(find.text('₹10,000'), findsOneWidget);

        // Verify Allocation History Items
        expect(find.text('ALLOCATION HISTORY'), findsOneWidget);
        expect(find.text('✦ IN / CREDIT'), findsWidgets);
        expect(find.text('+ ₹4,000'), findsOneWidget);
        expect(find.text('+ ₹1,000'), findsOneWidget);
        expect(find.text('+ ₹5,000'), findsOneWidget);
      },
    );

    testWidgets(
      'SetupTargetWalletDialog renders fields and validates empty inputs',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1000));

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SetupTargetWalletDialog())),
        );
        await tester.pump();

        // Verify Dialog Title & Subtitle
        expect(find.text('Setup Target Wallet'), findsOneWidget);
        expect(
          find.text('Isolate and lock funds toward a dedicated business goal'),
          findsOneWidget,
        );

        // Verify Input Labels
        expect(find.text('PURPOSE / ITEM NAME'), findsOneWidget);
        expect(find.text('TARGET CAP AMOUNT (INR)'), findsOneWidget);
        expect(find.text('DESCRIPTIVE NOTES'), findsOneWidget);

        // Verify Quick Chips
        expect(find.text('+ Tax Reserve'), findsOneWidget);
        expect(find.text('+ Inventory Stock'), findsOneWidget);
        expect(find.text('₹5,000'), findsOneWidget);
        expect(find.text('₹10,000'), findsOneWidget);

        // Verify Action Button
        expect(find.text('Activate Isolated Container'), findsOneWidget);

        // Scroll into view and tap Activate without entering required fields
        await tester.ensureVisible(find.text('Activate Isolated Container'));
        await tester.pump();
        await tester.tap(
          find.text('Activate Isolated Container'),
          warnIfMissed: false,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Warning snackbar should appear
        expect(
          find.text('Please enter a purpose or name for this wallet'),
          findsOneWidget,
        );
      },
    );

    testWidgets('SetupTargetWalletDialog validates zero amount', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SetupTargetWalletDialog())),
      );
      await tester.pump();

      // Enter purpose name
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Tax Reserve 2027',
      );

      // Enter 0 as amount
      await tester.enterText(find.byType(TextFormField).at(1), '0');

      await tester.ensureVisible(find.text('Activate Isolated Container'));
      await tester.pump();
      await tester.tap(
        find.text('Activate Isolated Container'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Please enter a target amount greater than ₹0'),
        findsOneWidget,
      );
    });

    testWidgets('SetupTargetWalletDialog preset chips update inputs', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SetupTargetWalletDialog())),
      );
      await tester.pump();

      // Tap Tax Reserve chip
      await tester.tap(find.text('+ Tax Reserve'));
      await tester.pump();

      // Tap 10,000 chip
      await tester.tap(find.text('₹10,000'));
      await tester.pump();

      // Purpose input should now have Tax Reserve
      expect(find.text('Tax Reserve'), findsOneWidget);
      // Amount input should now have 10000
      expect(find.text('10000'), findsOneWidget);
    });
  });
}
