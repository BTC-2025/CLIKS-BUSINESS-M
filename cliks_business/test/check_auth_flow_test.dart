import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/core/network/api_client.dart';
import 'package:clicks_business_frontend/data/repositories/user_repository.dart';

void main() {
  test('Check auth flow when switched to ramaniteam123', () async {
    // 1. ravinew2004
    await TokenService.switchActiveAccountSession('ravinew2004@bnxmail.com');
    final raviEmail = await TokenService.getUserEmail();
    final raviToken = await TokenService.getAccessToken();
    print('[TEST] Active ravinew2004 token: $raviToken');

    // 2. switch to ramaniteam123
    await TokenService.switchActiveAccountSession('ramaniteam123@bnxmail.com');
    final ramaniEmail = await TokenService.getUserEmail();
    final ramaniToken = await TokenService.getAccessToken();
    print('[TEST] Active ramaniteam123 email: $ramaniEmail, token: $ramaniToken');

    // 3. call /api/users/me while ramaniteam123 is active
    try {
      final res = await ApiClient.get('/api/users/me');
      print('[TEST] ramaniteam123 /api/users/me res: $res');
    } catch (e) {
      print('[TEST] ramaniteam123 /api/users/me error: $e');
    }
  });
}
