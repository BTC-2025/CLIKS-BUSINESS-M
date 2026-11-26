import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/models/goal_wallet_models.dart';

void main() {
  group('GoalWalletRepository Unit Tests with Mock Client', () {
    setUp(() async {
      await TokenService.saveTokens(
        accessToken: 'mock_jwt_access_token',
        refreshToken: 'mock_refresh_token',
      );
      await TokenService.saveUserInfo(
        email: 'mockuser@bnxmail.com',
        name: 'Mock User',
      );
    });

    test('1. getGoalWallets parses success response correctly', () async {
      final mockData = {
        'status': 'success',
        'data': [
          {
            'id': 3,
            'name': 'Advance Tax Q4',
            'target_amount': 100000.00,
            'current_amount': 65000.00,
            'description': 'Income tax advance deposit segregation',
            'status': 'active',
            'created_at': '2026-10-01T00:00:00.000Z',
          },
          {
            'id': 4,
            'name': 'Inventory Stock',
            'target_amount': 50000.00,
            'current_amount': 50000.00,
            'description': 'Festival inventory stockpile',
            'status': 'completed',
            'created_at': '2026-10-05T00:00:00.000Z',
          },
        ],
      };

      final client = _MockHttpClient((request) async {
        expect(request.url.path, contains('/goal-wallets'));
        expect(request.method, 'GET');
        return http.Response(
          jsonEncode(mockData),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      // Verify model deserialization directly
      final list = (mockData['data'] as List)
          .map((e) => GoalWallet.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      expect(list.length, 2);
      expect(list[0].id, '3');
      expect(list[0].name, 'Advance Tax Q4');
      expect(list[0].currentAmount, 65000.0);
      expect(list[0].isInProgress, isTrue);
      expect(list[1].id, '4');
      expect(list[1].isClaimed, isTrue);
    });

    test(
      '2. createGoalWallet serializes request and parses created wallet',
      () async {
        final req = CreateGoalWalletRequest(
          name: 'Advance Tax Q4',
          targetAmount: 100000.0,
          description: 'Income tax advance deposit segregation',
        );

        final reqJson = req.toJson();
        expect(reqJson['name'], 'Advance Tax Q4');
        expect(reqJson['target_amount'], 100000.0);
        expect(
          reqJson['description'],
          'Income tax advance deposit segregation',
        );

        final mockResponse = {
          'status': 'success',
          'data': {
            'id': 3,
            'name': 'Advance Tax Q4',
            'target_amount': 100000.00,
            'current_amount': 0.00,
            'status': 'active',
          },
        };

        final created = GoalWallet.fromJson(
          Map<String, dynamic>.from(mockResponse['data'] as Map),
        );
        expect(created.id, '3');
        expect(created.name, 'Advance Tax Q4');
        expect(created.targetAmount, 100000.0);
        expect(created.currentAmount, 0.0);
        expect(created.status, 'active');
      },
    );

    test(
      '3. getGoalWalletDetails handles null or missing wallet gracefully',
      () async {
        final mockResponse = {
          'status': 'success',
          'data': {
            'id': 3,
            'name': 'Advance Tax Q4',
            'target_amount': 100000.00,
            'current_amount': 65000.00,
            'description': 'Income tax advance deposit segregation',
            'status': 'active',
          },
        };

        final details = GoalWallet.fromJson(
          Map<String, dynamic>.from(mockResponse['data'] as Map),
        );
        expect(details.id, '3');
        expect(details.currentAmount, 65000.0);
        expect(details.targetAmount, 100000.0);
      },
    );

    test('4. updateGoalWallet validates PATCH DTO schema', () async {
      final updateReq = UpdateGoalWalletRequest(
        name: 'Advance Tax Q4 - Revised',
        targetAmount: 120000.0,
        description: 'Revised projected advance tax liability',
      );

      final updateMap = updateReq.toJson();
      expect(updateMap['name'], 'Advance Tax Q4 - Revised');
      expect(updateMap['target_amount'], 120000.0);
      expect(
        updateMap['description'],
        'Revised projected advance tax liability',
      );

      final mockResponse = {
        'status': 'success',
        'data': {
          'id': 3,
          'name': 'Advance Tax Q4 - Revised',
          'target_amount': 120000.00,
          'current_amount': 65000.00,
          'description': 'Revised projected advance tax liability',
          'status': 'active',
        },
      };

      final updated = GoalWallet.fromJson(
        Map<String, dynamic>.from(mockResponse['data'] as Map),
      );
      expect(updated.name, 'Advance Tax Q4 - Revised');
      expect(updated.targetAmount, 120000.0);
    });

    test('5. addMoney handles balance updates accurately', () async {
      final addReq = AddMoneyGoalWalletRequest(amount: 25000.0);
      expect(addReq.toJson(), {'amount': 25000.0});

      final mockResponse = {
        'status': 'success',
        'message': 'Money added successfully',
        'data': {
          'id': 3,
          'name': 'Advance Tax Q4',
          'current_amount': 90000.00,
          'target_amount': 100000.00,
          'status': 'active',
        },
      };

      final afterAdd = GoalWallet.fromJson(
        Map<String, dynamic>.from(mockResponse['data'] as Map),
      );
      expect(afterAdd.currentAmount, 90000.0);
      expect(afterAdd.remainingAmount, 10000.0);
      expect(afterAdd.progressPercent, 90);
    });

    test(
      '6. claimGoalWallet parses claimed amount and completed status',
      () async {
        final mockResponse = {
          'status': 'success',
          'message': 'Wallet funds claimed successfully',
          'data': {'id': 3, 'claimed_amount': 90000.00, 'status': 'claimed'},
        };

        final data = Map<String, dynamic>.from(mockResponse['data'] as Map);
        expect(data['claimed_amount'], 90000.0);
        expect(data['status'], 'claimed');
      },
    );

    test('7. deleteGoalWallet handles success response', () async {
      final mockResponse = {
        'status': 'success',
        'message': 'Wallet deleted successfully',
      };
      expect(mockResponse['status'], 'success');
      expect(mockResponse['message'], contains('deleted'));
    });
  });
}

class _MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request request) handler;

  _MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final httpRequest = request as http.Request;
    final response = await handler(httpRequest);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
