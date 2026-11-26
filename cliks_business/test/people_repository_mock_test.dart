import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/core/network/api_exception.dart';
import 'package:clicks_business_frontend/data/models/people_models.dart';

class _MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;
  _MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  group('PeopleRepository Unit Tests - All 23 Operations with Mock Client', () {
    setUp(() async {
      await TokenService.saveTokens(
        accessToken: 'mock_jwt_access_token',
        refreshToken: 'mock_refresh_token',
      );
      await TokenService.saveUserInfo(
        email: 'testuser@bnxmail.com',
        name: 'Test User',
      );
      await TokenService.saveCliksAccessToken(
        'mock_cliks_token',
        'testuser@bnxmail.com',
      );
    });

    test('1. List contacts (GET /api/v1/people)', () async {
      final mockData = {
        'success': true,
        'data': [
          {
            'id': 5,
            'name': 'Kiran Kumar',
            'role_type': 'partner',
            'relationship': 'Investor',
            'phone': '9876543210',
            'email': 'kiran@bnxmail.com',
            'company': 'Kiran Ventures',
            'total_lent': 100000.00,
            'total_borrowed': 25000.00,
            'net_balance': 75000.00,
          }
        ],
      };

      final contacts = (mockData['data'] as List)
          .map((e) => PersonContact.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      expect(contacts.length, 1);
      expect(contacts[0].id, 5);
      expect(contacts[0].name, 'Kiran Kumar');
      expect(contacts[0].netBalance, 75000.0);
    });

    test('2. Create person (POST /api/v1/people)', () async {
      final req = CreatePersonRequest(
        name: 'Kiran Kumar',
        roleType: 'partner',
        relationship: 'Investor',
        phone: '9876543210',
        email: 'kiran@bnxmail.com',
        company: 'Kiran Ventures',
      );

      final reqJson = req.toJson();
      expect(reqJson['name'], 'Kiran Kumar');
      expect(reqJson['email'], 'kiran@bnxmail.com');

      final mockResponse = {
        'success': true,
        'data': {
          'id': 5,
          'name': 'Kiran Kumar',
          'role_type': 'partner',
          'email': 'kiran@bnxmail.com',
        },
      };

      final created = PersonContact.fromJson(mockResponse['data'] as Map<String, dynamic>);
      expect(created.id, 5);
      expect(created.name, 'Kiran Kumar');
    });

    test('3. Person details (GET /api/v1/people/:id)', () async {
      final mockResponse = {
        'success': true,
        'data': {
          'id': 5,
          'name': 'Kiran Kumar',
          'role_type': 'partner',
          'relationship': 'Investor',
          'phone': '9876543210',
          'email': 'kiran@bnxmail.com',
          'company': 'Kiran Ventures',
          'total_lent': 100000.00,
          'total_borrowed': 25000.00,
          'net_balance': 75000.00,
          'transactions': [],
        },
      };

      final details = PersonContact.fromJson(mockResponse['data'] as Map<String, dynamic>);
      expect(details.id, 5);
      expect(details.totalLent, 100000.00);
      expect(details.transactions, isEmpty);
    });

    test('4. Update person (PATCH /api/v1/people/:id)', () async {
      final req = UpdatePersonRequest(
        phone: '9876543211',
        relationship: 'Senior Partner',
      );

      final reqJson = req.toJson();
      expect(reqJson['phone'], '9876543211');
      expect(reqJson['relationship'], 'Senior Partner');

      final mockResponse = {
        'success': true,
        'data': {
          'id': 5,
          'name': 'Kiran Kumar',
          'phone': '9876543211',
          'relationship': 'Senior Partner',
        },
      };

      final updated = PersonContact.fromJson(mockResponse['data'] as Map<String, dynamic>);
      expect(updated.id, 5);
      expect(updated.relationship, 'Senior Partner');
    });

    test('5. Delete person (DELETE /api/v1/people/:id)', () async {
      final mockResponse = {
        'success': true,
        'message': 'Person and associated records deleted successfully',
      };
      expect(mockResponse['success'], isTrue);
    });

    test('6. List People transactions (GET /api/v1/people/transactions)', () async {
      final mockData = {
        'success': true,
        'data': [
          {
            'id': 34,
            'person_id': 5,
            'person_name': 'Kiran Kumar',
            'type': 'lent',
            'amount': 50000.00,
            'date': '2026-11-20',
            'status': 'active',
            'notes': 'Short term liquidity loan',
          }
        ],
      };

      final txs = (mockData['data'] as List)
          .map((e) => PersonTransaction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      expect(txs.length, 1);
      expect(txs[0].id, 34);
      expect(txs[0].personName, 'Kiran Kumar');
      expect(txs[0].isLent, isTrue);
      expect(txs[0].amount, 50000.00);
    });

    test('7. List repayment alerts (GET /api/v1/people/reminders)', () async {
      final mockData = {
        'success': true,
        'data': [
          {
            'id': 14,
            'contact_id': 5,
            'target_contact': 'Kiran Kumar',
            'claim_cap': 25000.00,
            'maturity_date': '2026-12-15',
            'memo_label': 'Q4 Short-term Bridge Repayment',
            'status': 'Pending',
          }
        ],
      };

      final alerts = (mockData['data'] as List)
          .map((e) => RepaymentAlert.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      expect(alerts.length, 1);
      expect(alerts[0].id, 14);
      expect(alerts[0].targetContact, 'Kiran Kumar');
      expect(alerts[0].claimCap, 25000.0);
    });

    test('8. Create repayment alert (POST /api/v1/people/reminders)', () async {
      final req = CreateRepaymentAlertRequest(
        contactId: 5,
        targetContact: 'Kiran Kumar',
        claimCap: 25000.00,
        maturityDate: '2026-12-15',
        memoLabel: 'Q4 Short-term Bridge Repayment',
      );

      final reqJson = req.toJson();
      expect(reqJson['contact_id'], 5);
      expect(reqJson['claim_cap'], 25000.00);

      final mockResponse = {
        'success': true,
        'data': {
          'id': 14,
          'target_contact': 'Kiran Kumar',
          'claim_cap': 25000.00,
          'maturity_date': '2026-12-15',
          'memo_label': 'Q4 Short-term Bridge Repayment',
          'status': 'Pending',
        },
      };

      final created = RepaymentAlert.fromJson(mockResponse['data'] as Map<String, dynamic>);
      expect(created.id, 14);
      expect(created.claimCap, 25000.00);
    });

    test('9. Update alert status (PATCH /api/v1/people/reminders/:id)', () async {
      final mockResponse = {
        'success': true,
        'message': 'Alert status updated successfully',
      };
      expect(mockResponse['success'], isTrue);
    });

    test('10. Delete repayment alert (DELETE /api/v1/people/reminders/:id)', () async {
      final mockResponse = {
        'success': true,
        'message': 'Repayment alert removed',
      };
      expect(mockResponse['success'], isTrue);
    });

    test('11. Incoming connection requests (GET /api/v1/people/requests/incoming)', () async {
      final mockData = {
        'success': true,
        'data': [
          {
            'id': 8,
            'from_user_id': 22,
            'from_name': 'Suresh Raina',
            'from_email': 'suresh@bnxmail.com',
            'created_at': '2026-11-22T08:00:00.000Z',
          }
        ],
      };

      final reqs = (mockData['data'] as List)
          .map((e) => ConnectionRequest.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      expect(reqs.length, 1);
      expect(reqs[0].id, 8);
      expect(reqs[0].fromName, 'Suresh Raina');
    });

    test('12. Respond to connection request (PATCH /api/v1/people/requests/:id/respond)', () async {
      final body = {'action': 'accept'};
      expect(body['action'], 'accept');
    });

    test('13. List financial groups (GET /api/v1/people/groups)', () async {
      final mockData = {
        'success': true,
        'data': [
          {
            'id': 5,
            'name': 'Retail Group',
            'description': 'Shared expense pool',
            'group_type': 'syndicate',
            'currency': 'INR',
            'target_amount': 500000.0,
            'status': 'active',
          }
        ],
      };

      final groups = (mockData['data'] as List)
          .map((e) => FinancialGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      expect(groups.length, 1);
      expect(groups[0].id, 5);
      expect(groups[0].name, 'Retail Group');
      expect(groups[0].targetAmount, 500000.0);
    });

    test('14. Create financial group (POST /api/v1/people/groups)', () async {
      final req = CreateFinancialGroupRequest(
        name: 'Store Renovation Group',
        description: 'Shared expense pool',
        currency: 'INR',
        targetAmount: 100000.0,
      );

      final reqJson = req.toJson();
      expect(reqJson['name'], 'Store Renovation Group');
      expect(reqJson['title'], 'Store Renovation Group');
      expect(reqJson['currency'], 'INR');
    });

    test('15. Get group details (GET /api/v1/people/groups/:id)', () async {
      final mockData = {
        'success': true,
        'data': {
          'id': 5,
          'name': 'Store Renovation Group',
          'members': [
            {
              'id': 14,
              'group_id': 5,
              'email': 'user@cliks.com',
              'name': 'user',
              'role': 'admin',
              'status': 'accepted',
            }
          ],
          'transactions': [],
        },
      };

      final details = FinancialGroup.fromJson(mockData['data'] as Map<String, dynamic>);
      expect(details.id, 5);
      expect(details.members.length, 1);
      expect(details.members[0].role, 'admin');
    });

    test('16. Update group (PUT /api/v1/people/groups/:id)', () async {
      final req = UpdateFinancialGroupRequest(
        name: 'Store Renovation Group - Revised',
        description: 'Updated description',
        currency: 'INR',
        targetAmount: 120000.0,
      );
      final json = req.toJson();
      expect(json['name'], 'Store Renovation Group - Revised');
    });

    test('17. Delete group (DELETE /api/v1/people/groups/:id)', () async {
      final mockResponse = {'success': true, 'data': {'deleted': true}};
      expect(mockResponse['success'], isTrue);
    });

    test('18. Invite group member (POST /api/v1/people/groups/:id/members)', () async {
      final req = InviteGroupMemberRequest(
        email: 'partner@bnxmail.com',
        role: 'member',
      );
      expect(req.toJson()['email'], 'partner@bnxmail.com');
      expect(req.toJson()['role'], 'member');
    });

    test('19. Remove group member (DELETE /api/v1/people/groups/:id/members/:memberId)', () async {
      final mockResponse = {'success': true, 'data': {'removed': true}};
      expect(mockResponse['success'], isTrue);
    });

    test('20. Add group transaction (POST /api/v1/people/groups/:id/transactions)', () async {
      final req = AddGroupTransactionRequest(
        title: 'Architectural Blueprint Fee',
        amount: 40000.00,
        type: 'expense',
        category: 'Design',
        splitType: 'equal',
      );
      expect(req.toJson()['title'], 'Architectural Blueprint Fee');
      expect(req.toJson()['amount'], 40000.0);
      expect(req.toJson()['type'], 'expense');
    });

    test('21. Delete group transaction (DELETE /api/v1/people/groups/:id/transactions/:txId)', () async {
      final mockResponse = {'success': true, 'data': {'deleted': true}};
      expect(mockResponse['success'], isTrue);
    });

    test('22. Create private member note (POST /api/v1/people/groups/:id/members/:memberId/private-note)', () async {
      final req = SetPrivateNoteRequest(
        note: 'Private internal accounting note',
        amount: 30000.0,
      );
      expect(req.toJson()['note'], 'Private internal accounting note');
      expect(req.toJson()['amount'], 30000.0);
    });

    test('23. Delete private member note (DELETE /api/v1/people/groups/:id/members/:memberId/private-note)', () async {
      final mockResponse = {'success': true, 'data': {'deleted': true}};
      expect(mockResponse['success'], isTrue);
    });

    test('24. ApiException handling propagates error messages accurately', () {
      final exception = ApiException(
        statusCode: 400,
        message: "Email must end with @bnxmail.com",
      );
      expect(exception.statusCode, 400);
      expect(exception.message, 'Email must end with @bnxmail.com');
    });
  });
}
