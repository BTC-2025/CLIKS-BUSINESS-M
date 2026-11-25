import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/models/payment_models.dart';
import 'package:clicks_business_frontend/data/repositories/payments_repository.dart';

void main() {
  test('Live Payments Planner API - Full End-to-End CRUD Lifecycle', () async {
    // 1. Authenticate with active BNX Token (exchanges via SSO for Cliks token)
    const bnxToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhcHBfbmFtZSI6IkJOWCBNYWlsIiwic3ViIjoicmF2aW5ldzIwMDRAYm54bWFpbC5jb20iLCJpYXQiOjE3OTMwODM2MTEsImV4cCI6MTc5NTY3NTYxMX0.neyvYkB7aY5zXgI-ehOp36vlaAeuI5BPR0Ho_X1OlV4';
    await TokenService.saveTokens(accessToken: bnxToken, refreshToken: '');

    // 2. CREATE planned payment (POST /v1/planned-payments)
    final req = CreatePlannedPaymentRequest(
      name: 'Server Infrastructure Host',
      amount: 4500,
      dueDate: '2026-12-30',
      frequency: 'Monthly',
      category: 'Utilities',
      type: 'SEND',
      notes: 'End-to-end verified schedule',
    );
    final created = await PaymentsRepository.createPlannedPayment(req);
    print('[TEST RESULT] Created: ID=${created.id}, Name=${created.name}, Amount=${created.amount}');
    expect(created.id, isNotNull);
    expect(created.name, 'Server Infrastructure Host');
    expect(created.amount, 4500.0);

    // 3. GET BY ID (GET /v1/planned-payments/:id)
    final fetched = await PaymentsRepository.getPlannedPaymentById(created.id);
    print('[TEST RESULT] Fetched by ID: ${fetched?.id}, Name=${fetched?.name}');
    expect(fetched, isNotNull);
    expect(fetched!.name, 'Server Infrastructure Host');

    // 4. LIST (GET /v1/planned-payments)
    final list = await PaymentsRepository.getPlannedPayments();
    print('[TEST RESULT] Total items in list: ${list.length}');
    expect(list.any((p) => p.id.toString() == created.id.toString()), isTrue);

    // 5. UPDATE (PATCH /v1/planned-payments/:id)
    final updated = await PaymentsRepository.updatePlannedPayment(created.id, {
      'amount': 4800,
      'notes': 'Revised bandwidth tier',
    });
    print('[TEST RESULT] Updated Amount: ${updated.amount}');
    expect(updated.amount, 4800.0);

    // 6. DELETE (DELETE /v1/planned-payments/:id)
    await PaymentsRepository.deletePlannedPayment(created.id);
    print('[TEST RESULT] Deleted ID: ${created.id}');

    // 7. VERIFY DELETED
    final afterDelete = await PaymentsRepository.getPlannedPaymentById(created.id);
    expect(afterDelete, isNull);
    print('[TEST RESULT] Successfully verified item is removed from database.');
  });
}
