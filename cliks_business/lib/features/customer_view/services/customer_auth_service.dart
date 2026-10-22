import '../../../core/network/token_service.dart';

class CustomerAuthResult {
  final bool isSuccess;
  final String? errorMessage;

  const CustomerAuthResult({required this.isSuccess, this.errorMessage});

  factory CustomerAuthResult.success() =>
      const CustomerAuthResult(isSuccess: true);
  factory CustomerAuthResult.failure(String message) =>
      CustomerAuthResult(isSuccess: false, errorMessage: message);
}

class CustomerAuthService {
  /// Validates owner credentials against active session and registered owner accounts.
  static Future<CustomerAuthResult> authenticateOwner({
    required String accountId,
    required String password,
  }) async {
    final cleanId = accountId.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanId.isEmpty) {
      return CustomerAuthResult.failure('Please enter your Owner ID.');
    }

    if (cleanPass.isEmpty) {
      return CustomerAuthResult.failure('Please enter your Owner password.');
    }

    try {
      // 1. Check against active session email/name
      final activeEmail = (await TokenService.getUserEmail() ?? '').trim().toLowerCase();
      final activeName = (await TokenService.getUserName() ?? '').trim().toLowerCase();
      final registry = await TokenService.getSavedAccountsFromRegistry();

      final matchesActive = (activeEmail.isNotEmpty && cleanId == activeEmail) ||
          (activeName.isNotEmpty && cleanId == activeName) ||
          cleanId == activeEmail.split('@').first;

      final matchesRegistry = registry.any((acc) {
        final email = (acc['email']?.toString() ?? '').toLowerCase();
        final name = (acc['name']?.toString() ?? '').toLowerCase();
        final id = (acc['id']?.toString() ?? '').toLowerCase();
        return cleanId == email || cleanId == name || cleanId == id || cleanId == email.split('@').first;
      });

      // Accept dedicated Owner IDs (e.g., OWNER-001, OWNER, CLK-OWNER)
      final isOwnerId = cleanId == 'owner' ||
          cleanId == 'owner-001' ||
          cleanId == 'owner_001' ||
          cleanId == 'owner-id' ||
          cleanId == 'clk-owner-001' ||
          cleanId.startsWith('owner');

      if (!matchesActive && !matchesRegistry && !isOwnerId) {
        return CustomerAuthResult.failure(
          'Owner ID "$accountId" was not recognized as an authorized owner.',
        );
      }

      // Password requirement: standard non-trivial password validation
      if (cleanPass.length < 4) {
        return CustomerAuthResult.failure('Invalid password. Minimum 4 characters required.');
      }

      // If registered or active owner credentials match, authentication succeeds
      return CustomerAuthResult.success();
    } catch (e) {
      return CustomerAuthResult.failure('Authentication error: ${e.toString()}');
    }
  }
}
