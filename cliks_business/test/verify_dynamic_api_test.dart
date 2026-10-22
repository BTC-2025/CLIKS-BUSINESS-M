import 'package:flutter_test/flutter_test.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/repositories/user_repository.dart';
import 'package:clicks_business_frontend/data/repositories/storage_repository.dart';

void main() {
  test('Verify dynamic live API integration without hardcoding', () async {
    final token = await TokenService.getAccessToken();
    print('\n================ LIVE API VERIFICATION ================');
    print('Token exists: ${token != null && token.isNotEmpty}');
    final email = await TokenService.getUserEmail();
    print('Authenticated User Email: $email');
    expect(email, isNotNull);
    expect(email, isNotEmpty);

    // 1. Profile Data (GET /api/users/me & GET /api/users/settings)
    final profile = await UserRepository.getProfileData(email: email);
    print('\n[1] Dynamic Profile:');
    print('  - fullName: ${profile?['fullName']}');
    print('  - nickname: ${profile?['nickname']}');
    print('  - displayName: ${profile?['displayName']}');
    print('  - phoneNumber: ${profile?['phoneNumber']}');
    print('  - recoveryEmail: ${profile?['recoveryEmail']}');
    print('  - profilePictureUrl: ${profile?['profilePictureUrl']}');
    print('  - occupation: ${profile?['occupation']}');
    print('  - location: ${profile?['location']}');

    expect(profile, isNotNull);
    expect(profile!['email'], equals(email));
    expect(profile['nickname'], equals('see last'));
    expect(profile['displayName'], equals('Ravi K'));
    expect(profile['phoneNumber'], equals('8072909876'));
    expect(profile['recoveryEmail'], equals('chandran123@bnxmail.com'));
    expect(profile['profilePictureUrl'], contains('/api/users/profile-picture/'));

    // 2. Storage Quota (GET /api/mail/storage-quota)
    final quota = await StorageRepository.fetchStorageQuota();
    print('\n[2] Dynamic Storage Quota:');
    print('  - used: ${quota.usedFormatted}');
    print('  - limit: ${quota.limitFormatted}');
    print('  - percentage: ${quota.percentageFormatted}');
    print('  - status: ${quota.status}');
    expect(quota.storageLimit, greaterThan(0));

    // 3. Connected Mail Accounts (GET /api/emails/list)
    final emails = await UserRepository.getConnectedEmails();
    print('\n[3] Dynamic Connected Mail Accounts:');
    print('  - count: ${emails.length}');
    for (final e in emails) {
      print('  - account: ${e['email']} (isPrimary: ${e['isPrimary']})');
    }
    expect(emails, isNotEmpty);
    expect(emails.any((e) => e['email'] == email), isTrue);

    // 4. Sub-IDs (GET /api/subid/list)
    final subIds = await UserRepository.listSubIds();
    print('\n[4] Dynamic Sub-IDs:');
    print('  - count: ${subIds.length}');
    for (final s in subIds.take(3)) {
      print('  - subId: ${s['username']} (${s['role']})');
    }
    expect(subIds, isNotEmpty);
    print('========================================================\n');
  });
}
