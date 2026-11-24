import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clicks_business_frontend/core/network/token_service.dart';
import 'package:clicks_business_frontend/data/repositories/storage_repository.dart';
import 'package:clicks_business_frontend/data/account_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    StorageRepository.resetInFlight();
    await TokenService.saveUserSettings('ravinew2004@bnxmail.com', {
      'storageLimit': 5368709120, // 5 GB
      'storageUsed': 10276044, // 9.80 MB
    });
    await TokenService.saveUserSettings('ramaniteam123@bnxmail.com', {
      'storageLimit': 16106127360, // 15 GB
      'storageUsed': 0, // 0 B
    });
  });

  test('StorageRepository scopes quota per account email without leaking across users', () async {
    // 1. Fetch quota for ravinew2004
    final raviQuota = await StorageRepository.fetchStorageQuota('ravinew2004@bnxmail.com');
    expect(raviQuota.email, equals('ravinew2004@bnxmail.com'));
    expect(raviQuota.limitFormatted, equals('5 GB'));

    // 2. Fetch quota for ramaniteam123
    final ramaniQuota = await StorageRepository.fetchStorageQuota('ramaniteam123@bnxmail.com');
    expect(ramaniQuota.email, equals('ramaniteam123@bnxmail.com'));
    expect(ramaniQuota.storageUsed, equals(0));
    expect(ramaniQuota.usedFormatted, equals('0 B'));
    expect(ramaniQuota.limitFormatted, equals('15 GB'));
    expect(ramaniQuota.percentageFormatted, equals('0%'));

    // 3. Verify getCachedQuota returns account-specific data
    final cachedRavi = StorageRepository.getCachedQuota('ravinew2004@bnxmail.com');
    final cachedRamani = StorageRepository.getCachedQuota('ramaniteam123@bnxmail.com');

    expect(cachedRavi, isNotNull);
    expect(cachedRavi!.email, equals('ravinew2004@bnxmail.com'));
    expect(cachedRavi.limitFormatted, equals('5 GB'));

    expect(cachedRamani, isNotNull);
    expect(cachedRamani!.email, equals('ramaniteam123@bnxmail.com'));
    expect(cachedRamani.usedFormatted, equals('0 B'));
    expect(cachedRamani.limitFormatted, equals('15 GB'));
  });

  test('storageQuotaProvider reacts dynamically when switching accounts', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial account switch to ravinew2004
    await container.read(accountsProvider.notifier).switchAccount('ravinew2004@bnxmail.com');
    var quota = await container.read(storageQuotaProvider.future);
    expect(quota.email, equals('ravinew2004@bnxmail.com'));

    // Switch account to ramaniteam123
    await container.read(accountsProvider.notifier).switchAccount('ramaniteam123@bnxmail.com');
    quota = await container.read(storageQuotaProvider.future);
    expect(quota.email, equals('ramaniteam123@bnxmail.com'));
    expect(quota.usedFormatted, equals('0 B'));
    expect(quota.limitFormatted, equals('15 GB'));
  });
}
