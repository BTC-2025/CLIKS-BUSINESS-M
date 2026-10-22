import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account_model.dart';
import 'repositories/user_repository.dart';
import 'repositories/auth_repository.dart';
import '../core/network/token_service.dart';
import '../features/auth/notifiers/auth_notifier.dart';
import '../features/auth/pages/login_screen.dart';
import 'app_state_provider.dart';
import 'settings_provider.dart';

class AccountsNotifier extends StateNotifier<List<AccountModel>> {
  AccountsNotifier()
    : super([
        const AccountModel(
          id: 'loading',
          name: 'User',
          email: '',
          avatarColor: Color(0xFF195BAC),
          isActive: true,
        ),
      ]) {
    loadMailboxes();
  }

  Future<void> loadMailboxes() async {
    final loggedInEmail = (await TokenService.getUserEmail() ?? '')
        .trim()
        .toLowerCase();
    final savedRegistry = await TokenService.getSavedAccountsFromRegistry();
    final userProfile = await UserRepository.getProfile();

    List<AccountModel> mergedList = [];

    // 1. Build accounts from saved local registry
    for (final reg in savedRegistry) {
      final regEmail = (reg['email']?.toString() ?? '').trim().toLowerCase();
      if (regEmail.isEmpty) continue;
      final regName = reg['name']?.toString() ?? regEmail.split('@').first;
      final savedAvatar = await TokenService.getUserAvatar(regEmail);
      final cachedSettings = await TokenService.getUserSettings(regEmail) ?? {};

      final isCurrentActive =
          (loggedInEmail.isNotEmpty && regEmail == loggedInEmail);

      final avatar = (savedAvatar != null && savedAvatar.isNotEmpty)
          ? savedAvatar
          : ((isCurrentActive &&
                    userProfile != null &&
                    userProfile.avatarUrl != null &&
                    userProfile.avatarUrl!.isNotEmpty)
                ? userProfile.avatarUrl
                : null);

      final phone = cachedSettings['phoneNumber']?.toString() ??
          cachedSettings['phone']?.toString() ??
          (isCurrentActive ? userProfile?.phone : null);
      final recovery = cachedSettings['recoveryEmail']?.toString() ??
          (isCurrentActive ? userProfile?.recoveryEmail : null);
      final dobStr = cachedSettings['dob']?.toString();
      final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;

      mergedList.add(
        AccountModel(
          id: regEmail,
          name:
              (isCurrentActive &&
                  userProfile != null &&
                  userProfile.name.isNotEmpty)
              ? userProfile.name
              : regName,
          email: regEmail,
          avatarColor: const Color(0xFF195BAC),
          isActive:
              isCurrentActive || (mergedList.isEmpty && loggedInEmail.isEmpty),
          avatarUrl: avatar,
          phone: phone,
          recoveryEmail: recovery,
          dob: dob,
        ),
      );
    }

    // 2. Fetch backend mailboxes if available and merge
    try {
      final list = await UserRepository.getMailboxes();
      if (list.isNotEmpty) {
        for (final acc in list) {
          final accEmail = acc.email.trim().toLowerCase();
          if (accEmail.isNotEmpty &&
              !mergedList.any(
                (a) => a.email.trim().toLowerCase() == accEmail,
              )) {
            final savedAvatar = await TokenService.getUserAvatar(accEmail);
            final cachedSettings = await TokenService.getUserSettings(accEmail) ?? {};
            final avatar = (savedAvatar != null && savedAvatar.isNotEmpty)
                ? savedAvatar
                : acc.avatarUrl;
            final phone = cachedSettings['phoneNumber']?.toString() ??
                cachedSettings['phone']?.toString() ??
                acc.phone;
            final recovery = cachedSettings['recoveryEmail']?.toString() ??
                acc.recoveryEmail;
            final dobStr = cachedSettings['dob']?.toString();
            final dob = dobStr != null ? DateTime.tryParse(dobStr) : acc.dob;

            mergedList.add(
              acc.copyWith(
                id: accEmail,
                isActive: accEmail == loggedInEmail,
                avatarUrl: avatar,
                phone: phone,
                recoveryEmail: recovery,
                dob: dob,
              ),
            );
          }
        }
      }
    } catch (_) {}

    // 3. Fallback to active loggedInEmail if registry was empty
    if (mergedList.isEmpty && loggedInEmail.isNotEmpty) {
      final name = await TokenService.getUserName() ?? 'User';
      final savedAvatar = await TokenService.getUserAvatar(loggedInEmail);
      final cachedSettings = await TokenService.getUserSettings(loggedInEmail) ?? {};
      final avatar = (savedAvatar != null && savedAvatar.isNotEmpty)
          ? savedAvatar
          : userProfile?.avatarUrl;
      final phone = cachedSettings['phoneNumber']?.toString() ??
          cachedSettings['phone']?.toString() ??
          userProfile?.phone;
      final recovery = cachedSettings['recoveryEmail']?.toString() ??
          userProfile?.recoveryEmail;
      final dobStr = cachedSettings['dob']?.toString();
      final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;

      mergedList.add(
        AccountModel(
          id: loggedInEmail,
          name: (userProfile != null && userProfile.name.isNotEmpty)
              ? userProfile.name
              : name,
          email: loggedInEmail,
          avatarColor: const Color(0xFF195BAC),
          isActive: true,
          avatarUrl: avatar,
          phone: phone,
          recoveryEmail: recovery,
          dob: dob,
        ),
      );
    }

    if (mergedList.isNotEmpty) {
      bool hasActive = mergedList.any((a) => a.isActive);
      if (!hasActive) {
        mergedList[0] = mergedList[0].copyWith(isActive: true);
      }
      state = mergedList;
    }
  }

  void clear() {
    state = [
      const AccountModel(
        id: 'loading',
        name: 'User',
        email: '',
        avatarColor: Color(0xFF195BAC),
        isActive: true,
      ),
    ];
  }

  String get activeAccountId =>
      state.firstWhere((a) => a.isActive, orElse: () => state.first).id;

  AccountModel get activeAccount =>
      state.firstWhere((a) => a.isActive, orElse: () => state.first);

  Future<void> switchAccount(String id, [WidgetRef? ref]) async {
    final cleanId = id.trim().toLowerCase();
    print('[ACCOUNT SWITCH FAST] Switching active account to: $cleanId');

    // 1. Instantly update tokens locally
    await TokenService.switchActiveAccountSession(cleanId);

    final cached = await TokenService.getUserSettings(cleanId);
    final phone = (cached?['phoneNumber'] ?? cached?['phone'])?.toString();
    final recEmail = cached?['recoveryEmail']?.toString();
    DateTime? dob;
    if (cached?['dob'] != null || cached?['birthday'] != null) {
      dob = DateTime.tryParse((cached!['dob'] ?? cached['birthday']).toString());
    }
    final name = (cached?['fullName'] ?? cached?['name'])?.toString();

    // 2. Update account list state immediately so activeAccount is up to date
    state = state.map((acc) {
      final accEmail = acc.email.trim().toLowerCase();
      final accId = acc.id.trim().toLowerCase();
      final isTarget = (accEmail == cleanId || accId == cleanId);
      if (isTarget && cached != null) {
        return acc.copyWith(
          isActive: true,
          phone: (phone != null && phone.isNotEmpty) ? phone : acc.phone,
          recoveryEmail: (recEmail != null && recEmail.isNotEmpty)
              ? recEmail
              : acc.recoveryEmail,
          dob: dob ?? acc.dob,
          name: (name != null && name.isNotEmpty) ? name : acc.name,
        );
      }
      return acc.copyWith(isActive: isTarget);
    }).toList();

    // 3. Invalidate settings so it updates for new account
    if (ref != null) {
      ref.invalidate(settingsProvider);
      ref.read(appUiProvider.notifier).loadUserSettings(cleanId);
    }

    // 4. Non-blocking background call to update primary mailbox on backend
    UserRepository.setPrimaryMailbox(id).catchError((_) {});
  }

  /// Signs out of a single specific account.
  Future<void> signOutSingleAccount({
    required String targetEmail,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    final cleanTarget = targetEmail.trim().toLowerCase();
    print('[ACCOUNT SIGN OUT] Signing out of single account: $cleanTarget');

    // 1. Identify remaining accounts in state (excluding targetEmail)
    final remainingAccounts = state.where((acc) {
      final accEmail = acc.email.trim().toLowerCase();
      final accId = acc.id.trim().toLowerCase();
      return accEmail != cleanTarget &&
          accId != cleanTarget &&
          acc.id != 'loading';
    }).toList();

    // 2. Perform backend/local logout for the target account
    await AuthRepository.logoutSpecificAccount(cleanTarget);

    if (remainingAccounts.isNotEmpty) {
      final nextAccount = remainingAccounts.first;
      state = remainingAccounts;
      await switchAccount(nextAccount.id, ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Signed out of $cleanTarget. Switched to ${nextAccount.email}',
            ),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      clear();
      ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed out of $cleanTarget'),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void markAccountRead(String id) {
    state = state
        .map((acc) => acc.id == id ? acc.copyWith(unreadCount: 0) : acc)
        .toList();
  }

  Future<void> updateAccountFields(
    String id, {
    String? name,
    String? recoveryEmail,
    String? phone,
    String? accountType,
    String? language,
    String? accessibility,
    String? designation,
    DateTime? dob,
    String? avatarUrl,
  }) async {
    final cleanId = id.trim().toLowerCase();
    state = state.map((acc) {
      final accId = acc.id.trim().toLowerCase();
      final accEmail = acc.email.trim().toLowerCase();
      if (accId == cleanId || accEmail == cleanId) {
        return acc.copyWith(
          name: name ?? acc.name,
          recoveryEmail: recoveryEmail ?? acc.recoveryEmail,
          phone: phone ?? acc.phone,
          accountType: accountType ?? acc.accountType,
          language: language ?? acc.language,
          accessibility: accessibility ?? acc.accessibility,
          designation: designation ?? acc.designation,
          dob: dob ?? acc.dob,
          avatarUrl: avatarUrl ?? acc.avatarUrl,
        );
      }
      return acc;
    }).toList();

    final active = state.firstWhere(
      (a) =>
          a.id.trim().toLowerCase() == cleanId ||
          a.email.trim().toLowerCase() == cleanId,
      orElse: () => activeAccount,
    );
    if (name != null && active.email.isNotEmpty) {
      await TokenService.saveUserInfo(email: active.email, name: name);
    }
    if (phone != null && active.email.isNotEmpty) {
      await TokenService.saveUserSettings(active.email, {'phoneNumber': phone});
    }
    if (recoveryEmail != null && active.email.isNotEmpty) {
      await TokenService.saveUserSettings(active.email, {'recoveryEmail': recoveryEmail});
    }
    if (dob != null && active.email.isNotEmpty) {
      await TokenService.saveUserSettings(active.email, {'dob': dob.toIso8601String()});
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty && active.email.isNotEmpty) {
      await TokenService.saveUserAvatar(active.email, avatarUrl);
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    }
  }

  Future<void> updateAvatar(
    String id,
    String avatarUrl, {
    Uint8List? bytes,
    String? filePath,
    String? filename,
  }) async {
    final cleanId = id.trim().toLowerCase();

    state = state.map((acc) {
      final accEmail = acc.email.trim().toLowerCase();
      final accId = acc.id.trim().toLowerCase();
      if (accId == cleanId || accEmail == cleanId) {
        return acc.copyWith(avatarUrl: avatarUrl);
      }
      return acc;
    }).toList();

    // Clear Flutter's in-memory image cache so old photos do not linger
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    final active = state.firstWhere(
      (a) =>
          a.id.trim().toLowerCase() == cleanId ||
          a.email.trim().toLowerCase() == cleanId,
      orElse: () => activeAccount,
    );
    final targetEmail = active.email.isNotEmpty
        ? active.email
        : (await TokenService.getUserEmail() ?? '');

    try {
      final remoteUrl = await UserRepository.uploadAvatar(
        targetEmail,
        avatarUrl,
        bytes: bytes,
        filePath: filePath,
        filename: filename,
      );
      if (remoteUrl != null && remoteUrl.isNotEmpty) {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        state = state.map((acc) {
          final accEmail = acc.email.trim().toLowerCase();
          final accId = acc.id.trim().toLowerCase();
          if (accId == cleanId || accEmail == cleanId) {
            return acc.copyWith(avatarUrl: remoteUrl);
          }
          return acc;
        }).toList();
        await TokenService.saveUserAvatar(targetEmail, remoteUrl);
      }
    } catch (e) {
      print('[AVATAR SYNC ERROR] Failed to upload avatar to backend: $e');
    }
  }

  Future<void> removeAvatar(String id) async {
    final cleanId = id.trim().toLowerCase();

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    state = state.map((acc) {
      final accEmail = acc.email.trim().toLowerCase();
      final accId = acc.id.trim().toLowerCase();
      if (accId == cleanId || accEmail == cleanId) {
        return acc.copyWith(avatarUrl: null);
      }
      return acc;
    }).toList();

    final active = state.firstWhere(
      (a) =>
          a.id.trim().toLowerCase() == cleanId ||
          a.email.trim().toLowerCase() == cleanId,
      orElse: () => activeAccount,
    );
    final targetEmail = active.email.isNotEmpty
        ? active.email
        : (await TokenService.getUserEmail() ?? '');

    if (targetEmail.isNotEmpty) {
      await TokenService.saveUserAvatar(targetEmail, '');
    }
    final loggedInEmail = await TokenService.getUserEmail();
    if (loggedInEmail != null && loggedInEmail.isNotEmpty) {
      await TokenService.saveUserAvatar(loggedInEmail, '');
    }

    try {
      await UserRepository.deleteAvatar(targetEmail);
    } catch (e) {
      print('[AVATAR REMOVE ERROR] Failed to remove avatar: $e');
    }
  }
}

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, List<AccountModel>>((ref) {
      return AccountsNotifier();
    });

/// Convenience provider: returns just the active account
final activeAccountProvider = Provider<AccountModel>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.firstWhere((a) => a.isActive, orElse: () => accounts.first);
});
