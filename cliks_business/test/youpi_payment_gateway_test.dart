import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:clicks_business_frontend/features/billing/models/youpi_payment_models.dart';
import 'package:clicks_business_frontend/features/billing/services/youpi_payment_service.dart';
import 'package:clicks_business_frontend/features/billing/widgets/youpi_payment_sheet.dart';
import 'package:clicks_business_frontend/features/billing/pages/subscription_page.dart';
import 'package:clicks_business_frontend/data/repositories/subscription_repository.dart';

void main() {
  group('YOUPI PG Data Models & OpenAPI Contract Conformance', () {
    test('YoupiPaymentRequest serializes correctly to JSON', () {
      final req = YoupiPaymentRequest(
        orderId: 'ORDER-1001',
        amount: '1188.00',
        currency: 'INR',
        description: 'Tier 1 Annual Subscription',
        returnUrl: 'cliks://payment-return?orderId=ORDER-1001',
        customer: const YoupiCustomer(
          name: 'Ravi Kumar',
          email: 'ravi@example.com',
          phoneNumber: '9876543210',
        ),
        metadata: {
          'tierNumber': 1,
          'planName': 'Tier 1 (Starter)',
        },
      );

      final json = req.toJson();
      expect(json['orderId'], 'ORDER-1001');
      expect(json['amount'], '1188.00');
      expect(json['currency'], 'INR');
      expect(json['customer']['email'], 'ravi@example.com');
      expect(json['customer']['phoneNumber'], '9876543210');
      expect(json['metadata']['tierNumber'], 1);
    });

    test('YoupiPaymentSession parses CreatePaymentResponse JSON', () {
      final raw = {
        'paymentId': 'c7942127-14e3-469a-9e4a-9359a16f903a',
        'orderId': 'ORDER-1001',
        'amount': '2988.00',
        'amountPaise': '298800',
        'currency': 'INR',
        'status': 'INITIATED',
        'queuePosition': 0,
        'checkoutUrl':
            'http://localhost:7000/checkout/c7942127-14e3-469a-9e4a-9359a16f903a',
      };

      final session = YoupiPaymentSession.fromJson(raw);
      expect(session.paymentId, 'c7942127-14e3-469a-9e4a-9359a16f903a');
      expect(session.orderId, 'ORDER-1001');
      expect(session.amount, '2988.00');
      expect(session.amountPaise, '298800');
      expect(session.status, 'INITIATED');
      expect(session.queuePosition, 0);
      expect(session.checkoutUrl,
          'http://localhost:7000/checkout/c7942127-14e3-469a-9e4a-9359a16f903a');
    });

    test('YoupiPaymentVerification parses PaymentDetailsResponse JSON', () {
      final raw = {
        'paymentId': 'c7942127-14e3-469a-9e4a-9359a16f903a',
        'orderId': 'ORDER-1001',
        'amount': '2988.00',
        'amountPaise': '298800',
        'currency': 'INR',
        'status': 'SUCCESS',
        'internalStatus': 'SUCCESS',
        'method': 'UPI',
        'verificationLevel': 2,
        'verificationSources': ['SMS', 'GMAIL'],
        'verificationTag': 'VERIFIED_DUAL',
        'completedAt': '2026-10-18T10:00:00.000Z',
        'utr': '123456789012',
      };

      final ver = YoupiPaymentVerification.fromJson(raw);
      expect(ver.paymentId, 'c7942127-14e3-469a-9e4a-9359a16f903a');
      expect(ver.status, 'SUCCESS');
      expect(ver.isSuccess, true);
      expect(ver.verificationLevel, 2);
      expect(ver.isAuthoritativelyVerified, true);
      expect(ver.utr, '123456789012');
      expect(ver.verificationSources, contains('SMS'));
      expect(ver.verificationSources, contains('GMAIL'));
    });
  });

  group('YOUPI PG All 4 Subscription Plans Initiation & Pricing', () {
    late YoupiPaymentService service;

    setUp(() {
      service = YoupiPaymentService.instance;
      SubscriptionRepository.clearVerifiedSubscriptions();
    });

    test('Starter (Tier 1) creates payment session for ₹1,188 (1188.00)', () async {
      service.testClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/payments');
        expect(request.headers['X-Merchant-Id'], YoupiPaymentService.defaultMerchantId);
        final body = jsonDecode(request.body);
        expect(body['amount'], '1188.00');
        expect(body['metadata']['tierNumber'], 1);

        return http.Response(
          jsonEncode({
            'paymentId': 'pay-tier-1',
            'orderId': body['orderId'],
            'amount': '1188.00',
            'amountPaise': '118800',
            'currency': 'INR',
            'status': 'INITIATED',
            'checkoutUrl': 'http://localhost:7000/checkout/pay-tier-1',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final session = await service.createPaymentSession(
        orderId: 'ORD-TIER1-TEST',
        amount: 1188.0,
        planName: 'Tier 1 (Starter)',
        tierNumber: 1,
        customerEmail: 'user@example.com',
      );

      expect(session.paymentId, 'pay-tier-1');
      expect(session.amount, '1188.00');
      expect(session.checkoutUrl, contains('pay-tier-1'));
    });

    test('Standard (Tier 2) creates payment session for ₹2,988 (2988.00)', () async {
      service.testClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['amount'], '2988.00');
        expect(body['metadata']['tierNumber'], 2);

        return http.Response(
          jsonEncode({
            'paymentId': 'pay-tier-2',
            'orderId': body['orderId'],
            'amount': '2988.00',
            'amountPaise': '298800',
            'currency': 'INR',
            'status': 'INITIATED',
            'checkoutUrl': 'http://localhost:7000/checkout/pay-tier-2',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final session = await service.createPaymentSession(
        orderId: 'ORD-TIER2-TEST',
        amount: 2988.0,
        planName: 'Tier 2 (Standard)',
        tierNumber: 2,
        customerEmail: 'user@example.com',
      );

      expect(session.paymentId, 'pay-tier-2');
      expect(session.amount, '2988.00');
    });

    test('Premium / Growth (Tier 3) creates payment session for ₹6,588 (6588.00)', () async {
      service.testClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['amount'], '6588.00');
        expect(body['metadata']['tierNumber'], 3);

        return http.Response(
          jsonEncode({
            'paymentId': 'pay-tier-3',
            'orderId': body['orderId'],
            'amount': '6588.00',
            'amountPaise': '658800',
            'currency': 'INR',
            'status': 'INITIATED',
            'checkoutUrl': 'http://localhost:7000/checkout/pay-tier-3',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final session = await service.createPaymentSession(
        orderId: 'ORD-TIER3-TEST',
        amount: 6588.0,
        planName: 'Tier 3 (Premium / Growth)',
        tierNumber: 3,
        customerEmail: 'user@example.com',
      );

      expect(session.paymentId, 'pay-tier-3');
      expect(session.amount, '6588.00');
    });

    test('Elite (Tier 4) creates payment session for ₹11,988 (11988.00)', () async {
      service.testClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['amount'], '11988.00');
        expect(body['metadata']['tierNumber'], 4);

        return http.Response(
          jsonEncode({
            'paymentId': 'pay-tier-4',
            'orderId': body['orderId'],
            'amount': '11988.00',
            'amountPaise': '1198800',
            'currency': 'INR',
            'status': 'INITIATED',
            'checkoutUrl': 'http://localhost:7000/checkout/pay-tier-4',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final session = await service.createPaymentSession(
        orderId: 'ORD-TIER4-TEST',
        amount: 11988.0,
        planName: 'Tier 4 (Elite)',
        tierNumber: 4,
        customerEmail: 'user@example.com',
      );

      expect(session.paymentId, 'pay-tier-4');
      expect(session.amount, '11988.00');
    });

    test('1 Rupee Test Plan creates payment session for ₹1.00 with configured payee VPA', () async {
      final uri = service.buildUpiPaymentUri(
        amount: 1.0,
        orderId: 'CLIKS-TEST-1INR',
        planName: 'Test Plan (₹1 Verification)',
      );

      expect(uri, contains('pa=merchant@upi'));
      expect(uri, contains('pn=Cliks%20Business'));
      expect(uri, contains('am=1.00'));

      service.testClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['amount'], '1.00');
        expect(body['metadata']['payeeVpa'], 'merchant@upi');

        return http.Response(
          jsonEncode({
            'paymentId': 'pay-test-1inr',
            'orderId': body['orderId'],
            'amount': '1.00',
            'amountPaise': '100',
            'currency': 'INR',
            'status': 'INITIATED',
            'checkoutUrl': 'http://localhost:7000/checkout/pay-test-1inr',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final session = await service.createPaymentSession(
        orderId: 'CLIKS-TEST-1INR',
        amount: 1.0,
        planName: 'Test Plan (₹1 Verification)',
        tierNumber: 1,
        customerEmail: 'tester@example.com',
      );

      expect(session.amount, '1.00');
      expect(session.payeeVpa, 'merchant@upi');
      expect(session.upiUri, contains('pa=merchant@upi'));
    });
  });

  group('Authoritative Verification & Integrity Protection', () {
    late YoupiPaymentService service;

    setUp(() {
      service = YoupiPaymentService.instance;
      SubscriptionRepository.clearVerifiedSubscriptions();
    });

    test('Rejects payment if status is not SUCCESS (e.g. PENDING)', () async {
      service.testClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'paymentId': 'pay-pending',
            'orderId': 'ORD-P-1',
            'amount': '2988.00',
            'status': 'ACTIVE',
            'verificationLevel': 0,
            'verificationTag': 'UNVERIFIED',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final verified = await service.verifyAndActivateSubscription(
        paymentId: 'pay-pending',
        expectedOrderId: 'ORD-P-1',
        expectedAmount: 2988.0,
        tierNumber: 2,
        planName: 'Tier 2 (Standard)',
        customerEmail: 'ravi@example.com',
      );

      expect(verified, false);
      final sub = await SubscriptionRepository.getBusinessSubscription('ravi@example.com');
      expect(sub?['is_verified'], isNot(true));
    });

    test('Rejects payment if verificationLevel is 0 (Unobserved payment)', () async {
      service.testClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'paymentId': 'pay-unobserved',
            'orderId': 'ORD-U-1',
            'amount': '2988.00',
            'status': 'SUCCESS',
            'verificationLevel': 0,
            'verificationTag': 'UNVERIFIED',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final verified = await service.verifyAndActivateSubscription(
        paymentId: 'pay-unobserved',
        expectedOrderId: 'ORD-U-1',
        expectedAmount: 2988.0,
        tierNumber: 2,
        planName: 'Tier 2 (Standard)',
        customerEmail: 'ravi@example.com',
      );

      expect(verified, false);
    });

    test('Rejects payment if amount does not match expected plan amount (Tampering protection)', () async {
      service.testClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'paymentId': 'pay-tampered',
            'orderId': 'ORD-T-1',
            'amount': '99.00', // Cheaper amount paid!
            'status': 'SUCCESS',
            'verificationLevel': 1,
            'verificationTag': 'VERIFIED_SMS',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final verified = await service.verifyAndActivateSubscription(
        paymentId: 'pay-tampered',
        expectedOrderId: 'ORD-T-1',
        expectedAmount: 2988.0, // Expected Standard plan ₹2,988
        tierNumber: 2,
        planName: 'Tier 2 (Standard)',
        customerEmail: 'ravi@example.com',
      );

      expect(verified, false);
    });

    test('Accepts payment when observer verified and activates subscription with start/expiry rules', () async {
      service.testClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'paymentId': 'pay-verified-success',
            'orderId': 'ORD-S-1',
            'amount': '2988.00',
            'status': 'SUCCESS',
            'verificationLevel': 2,
            'verificationTag': 'VERIFIED_DUAL',
            'utr': '987654321098',
            'completedAt': '2026-10-18T12:00:00Z',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final verified = await service.verifyAndActivateSubscription(
        paymentId: 'pay-verified-success',
        expectedOrderId: 'ORD-S-1',
        expectedAmount: 2988.0,
        tierNumber: 2,
        planName: 'Tier 2 (Standard)',
        customerEmail: 'ravi@example.com',
      );

      expect(verified, true);

      // Verify authoritative subscription record in Cliks Business
      final sub = await SubscriptionRepository.getBusinessSubscription('ravi@example.com');
      expect(sub, isNotNull);
      expect(sub!['plan_name'], 'Tier 2 (Standard)');
      expect(sub['tier_number'], 2);
      expect(sub['subscription_days_remaining'], 365);
      expect(sub['utr'], '987654321098');
      expect(sub['is_verified'], true);
    });

    test('Submitting an unobserved fake UTR rejects payment and does NOT activate subscription', () async {
      service.testClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'paymentId': 'pay-fake-utr',
            'orderId': 'ORD-FAKE-1',
            'amount': '2988.00',
            'status': 'ACTIVE',
            'verificationLevel': 0,
            'verificationTag': 'UNVERIFIED',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final verified = await service.submitUtrForVerification(
        paymentId: 'pay-fake-utr',
        orderId: 'ORD-FAKE-1',
        expectedAmount: 2988.0,
        tierNumber: 2,
        planName: 'Tier 2 (Standard)',
        customerEmail: 'fraud@example.com',
        utr: '123456789012',
      );

      expect(verified, false);
      final sub = await SubscriptionRepository.getBusinessSubscription('fraud@example.com');
      expect(sub?['is_verified'], isNot(true));
    });

    test('Prevents duplicate subscription activation for the same payment ID (Idempotency)', () async {
      service.testClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'paymentId': 'pay-idempotent',
            'orderId': 'ORD-IDEM-1',
            'amount': '6588.00',
            'status': 'SUCCESS',
            'verificationLevel': 1,
            'verificationTag': 'VERIFIED_SMS',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      // First activation
      final firstResult = await service.verifyAndActivateSubscription(
        paymentId: 'pay-idempotent',
        expectedOrderId: 'ORD-IDEM-1',
        expectedAmount: 6588.0,
        tierNumber: 3,
        planName: 'Tier 3 (Premium / Growth)',
        customerEmail: 'ravi@example.com',
      );
      expect(firstResult, true);

      // Duplicate second activation
      final secondResult = await service.verifyAndActivateSubscription(
        paymentId: 'pay-idempotent',
        expectedOrderId: 'ORD-IDEM-1',
        expectedAmount: 6588.0,
        tierNumber: 3,
        planName: 'Tier 3 (Premium / Growth)',
        customerEmail: 'ravi@example.com',
      );
      expect(secondResult, true);
    });
  });

  group('Subscription Page Integration & UI Constraints', () {
    testWidgets('SubscriptionPage renders all 4 tier cards with prices and upgrade buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SubscriptionPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify all 4 tiers render
      expect(find.text('Tier 1 (Starter)'), findsWidgets);
      expect(find.text('Tier 2 (Standard)'), findsWidgets);
      expect(find.text('Tier 3 (Premium / Growth)'), findsWidgets);
      expect(find.text('Tier 4 (Elite)'), findsWidgets);

      // Verify annual prices and monthly offer prices
      expect(find.textContaining('₹1,188'), findsWidgets);
      expect(find.textContaining('₹2,988'), findsWidgets);
      expect(find.textContaining('₹6,588'), findsWidgets);
      expect(find.textContaining('₹11,988'), findsWidgets);

      expect(find.text('₹99'), findsWidgets);
      expect(find.text('₹249'), findsWidgets);
      expect(find.text('₹549'), findsWidgets);
      expect(find.text('₹999'), findsWidgets);

      // Current active tier is Tier 1
      expect(find.text('Currently Active Plan'), findsWidgets);

      // Upgrade Plan button is present for higher tiers
      expect(find.text('Upgrade Plan'), findsWidgets);
    });

    testWidgets('YoupiPaymentSheet displays pending and verified success state', (tester) async {
      final service = YoupiPaymentService.instance;
      String currentOrderId = '';
      service.testClient = MockClient((request) async {
        if (request.url.path == '/api/v1/payments') {
          final body = jsonDecode(request.body);
          currentOrderId = body['orderId'];
          return http.Response(
            jsonEncode({
              'paymentId': 'pay-flow-test',
              'orderId': currentOrderId,
              'amount': '2988.00',
              'status': 'INITIATED',
              'checkoutUrl': 'http://localhost:7000/checkout/pay-flow-test',
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/api/v1/payments/pay-flow-test') {
          return http.Response(
            jsonEncode({
              'paymentId': 'pay-flow-test',
              'orderId': currentOrderId,
              'amount': '2988.00',
              'status': 'SUCCESS',
              'verificationLevel': 2,
              'verificationTag': 'VERIFIED_DUAL',
              'utr': '112233445566',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      int verifiedTier = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YoupiPaymentSheet(
              tierNumber: 2,
              planName: 'Tier 2 (Standard)',
              fullAnnualPrice: '₹2,988',
              payableAmount: 2988.0,
              customerEmail: 'test@example.com',
              onPaymentVerified: (t) => verifiedTier = t,
            ),
          ),
        ),
      );

      // Initializing state with authentic header
      expect(find.text('Cliks Business'), findsWidgets);
      expect(find.text('YOUPI PG Verified Business'), findsOneWidget);
      expect(find.textContaining('Tier 2 (Standard)'), findsOneWidget);

      // Pump to process creation and launch
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // After status check poll returns SUCCESS with level 2
      expect(verifiedTier, 2);
      expect(find.text('Payment Authoritatively Verified!'), findsOneWidget);
      expect(find.text('Continue to Workspace'), findsOneWidget);
    });

    testWidgets('YoupiPaymentSheet displays failed state when gateway errors', (tester) async {
      final service = YoupiPaymentService.instance;
      service.testClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': 'Gateway unreachable or invalid merchant configuration',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YoupiPaymentSheet(
              tierNumber: 3,
              planName: 'Tier 3 (Premium / Growth)',
              fullAnnualPrice: '₹6,588',
              payableAmount: 6588.0,
              customerEmail: 'test@example.com',
              onPaymentVerified: (_) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Payment Verification Failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
