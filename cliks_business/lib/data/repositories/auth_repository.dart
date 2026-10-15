import '../../core/network/token_service.dart';

class AuthRepository {
  static Future<void> logout() async {
    TokenService.cachedAccessToken = null;
  }

  static Future<void> logoutSpecificAccount(String email) async {
    final clean = email.trim().toLowerCase();
    final active = (await TokenService.getUserEmail())?.trim().toLowerCase();
    if (active == clean) {
      final registry = await TokenService.getSavedAccountsFromRegistry();
      final remaining = registry.where((a) => (a['email']?.toString() ?? '').toLowerCase() != clean).toList();
      if (remaining.isNotEmpty) {
        await TokenService.switchActiveAccountSession(remaining.first['email']?.toString() ?? '');
      } else {
        await logout();
      }
    }
  }
}
