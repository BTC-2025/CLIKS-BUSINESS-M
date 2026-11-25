import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/api_client.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/repositories/payments_repository.dart';

void main() {
  test('Multi-Account Payments Isolation - dynamic fetching without hardcoded leaks', () async {
    const raviEmail = 'ravinew2004@bnxmail.com';
    const raviBnxToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhcHBfbmFtZSI6IkJOWCBNYWlsIiwic3ViIjoicmF2aW5ldzIwMDRAYm54bWFpbC5jb20iLCJpYXQiOjE3OTMwODM2MTEsImV4cCI6MTc5NTY3NTYxMX0.neyvYkB7aY5zXgI-ehOp36vlaAeuI5BPR0Ho_X1OlV4';
    const raviCliksToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NzMsInVzZXJuYW1lIjoicmF2aW5ldzIwMDQiLCJlbWFpbCI6InJhdmluZXcyMDA0QGJueG1haWwuY29tIiwicm9sZSI6ImJ1c2luZXNzIiwiYWNjb3VudF90eXBlIjoiYnVzaW5lc3MiLCJhY2NvdW50VHlwZSI6IkJVU0lORVNTIiwiYnVzaW5lc3MiOnRydWUsImlhdCI6MTc5NTYwMjQyNywiZXhwIjoxNzk4MTk0NDI3fQ.-MQoI2i7SUsXPlt5BUJnZ6YNuX0KY6vpZCMyiNacBXM';

    await TokenService.saveAccountToRegistry({
      'email': raviEmail,
      'name': 'Ravi K',
      'accessToken': raviBnxToken,
      'refreshToken': '',
    });
    await TokenService.saveCliksAccessToken(raviCliksToken, raviEmail);

    const ramaniEmail = 'ramaniteam123@bnxmail.com';
    await TokenService.saveAccountToRegistry({
      'email': ramaniEmail,
      'name': 'Ramani Team',
      'accessToken': '',
      'refreshToken': '',
    });

    // ── STEP A: Fetch for ravinew2004 ─────────────────────────────────────────
    await TokenService.switchActiveAccountSession(raviEmail);
    ApiClient.clearCliksToken();

    final raviPayments = await PaymentsRepository.getPlannedPayments(email: raviEmail);
    print('[TEST] ravinew2004 planned payments count: ${raviPayments.length}');
    expect(raviPayments, isNotEmpty, reason: 'ravinew2004 must fetch its live planned payments from backend');
    expect(raviPayments.length, greaterThanOrEqualTo(1));

    // ── STEP B: Switch to ramaniteam123 ───────────────────────────────────────
    await TokenService.switchActiveAccountSession(ramaniEmail);
    ApiClient.clearCliksToken();

    final ramaniPayments = await PaymentsRepository.getPlannedPayments(email: ramaniEmail);
    print('[TEST] ramaniteam123 planned payments count: ${ramaniPayments.length}');

    // MUST NOT leak ravinew2004 data!
    expect(
      ramaniPayments.length,
      equals(0),
      reason: 'ramaniteam123 must NOT inherit ravinew2004 data or hardcoded mock fallback items',
    );

    // Verify token isolation
    final activeToken = await TokenService.getAccessToken();
    expect(activeToken, isNull, reason: 'ramaniteam123 must not leak ravinew2004 access token');

    final targetToken = await TokenService.getTokenForAccount(ramaniEmail);
    expect(targetToken, isNull, reason: 'Target token for ramaniteam123 must be null');

    // ── STEP C: Switch back to ravinew2004 ─────────────────────────────────────
    await TokenService.switchActiveAccountSession(raviEmail);
    ApiClient.clearCliksToken();

    final raviReloaded = await PaymentsRepository.getPlannedPayments(email: raviEmail);
    print('[TEST] ravinew2004 reloaded count: ${raviReloaded.length}');
    expect(raviReloaded, isNotEmpty);
    expect(raviReloaded.length, greaterThanOrEqualTo(1));
  });
}
