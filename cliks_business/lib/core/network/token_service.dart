import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Secure token and session persistence service.
/// Uses resilient local persistent storage on desktop/web platforms (.bnx_local_store.json)
/// without hardcoded values, reflecting active authenticated user credentials.
class TokenService {
  static const _kAccess = 'bnx_access_token';
  static const _kRefresh = 'bnx_refresh_token';
  static const _kCliksAccess = 'cliks_business_access_token';
  static const _kEmail = 'bnx_user_email';
  static const _kName = 'bnx_user_name';
  static const _kGlobalAvatar = 'bnx_user_avatar_global';
  static const _kSavedAccountsRegistry = 'bnx_saved_accounts_registry';
  static const _kExplicitlyLoggedOut = 'bnx_user_explicitly_logged_out';

  static String? _cachedAccessToken;
  static String? get cachedAccessToken {
    _ensureFallbackLoaded();
    return _cachedAccessToken;
  }
  static set cachedAccessToken(String? val) {
    _cachedAccessToken = val;
  }
  static final Map<String, String> _memoryFallback = {};
  static bool _fallbackLoaded = false;

  static String _kSettingsKey(String email) =>
      'bnx_user_settings_${email.trim().toLowerCase()}';

  static String _kAvatarKey(String email) =>
      'bnx_user_avatar_${email.trim().toLowerCase()}';

  static String _kBizOnboardedKey(String email) =>
      'bnx_biz_onboarded_${email.trim().toLowerCase()}';

  static File? _testStorageFile;

  /// Returns true if [token] appears to be a valid, structurally-sound JWT.
  /// Rejects dummy offline tokens (e.g. 'offline_token_...', 'token_...').
  static bool isValidJwt(String? token) {
    if (token == null) return false;
    final t = token.trim();
    if (t.isEmpty ||
        t.startsWith('offline_token_') ||
        t.startsWith('token_') ||
        t.startsWith('mock_')) {
      return false;
    }
    final parts = t.split('.');
    return parts.length == 3 && t.startsWith('ey');
  }

  /// Lists candidate locations for `.bnx_local_store.json`.
  /// Handles macOS sandbox container paths vs real host Library paths.
  static List<File> _candidateFiles() {
    final list = <File>[];
    if (kIsWeb) return list;
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _testStorageFile ??= File('${Directory.systemTemp.path}/bnx_test_local_store.json');
      return [_testStorageFile!];
    }
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      // 1. If running inside a sandbox container, check the real host home
      if (home.contains('/Library/Containers/')) {
        final realHome = home.split('/Library/Containers/').first;
        if (realHome.isNotEmpty) {
          list.add(File('$realHome/Library/Application Support/com.bnxmail.app/.bnx_local_store.json'));
        }
      }
      // 2. Direct home path
      if (home.isNotEmpty) {
        list.add(File('$home/Library/Application Support/com.bnxmail.app/.bnx_local_store.json'));
      }
      // 3. User environment fallback
      final user = Platform.environment['USER'];
      if (user != null && user.isNotEmpty) {
        list.add(File('/Users/$user/Library/Application Support/com.bnxmail.app/.bnx_local_store.json'));
      }
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        list.add(File('$home/.config/com.bnxmail.app/.bnx_local_store.json'));
      }
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        list.add(File('$appData/com.bnxmail.app/.bnx_local_store.json'));
      }
    }
    list.add(File('${Directory.systemTemp.path}/com.bnxmail.app/.bnx_local_store.json'));
    return list;
  }

  static File? _resolveFallbackFile() {
    final candidates = _candidateFiles();
    return candidates.isNotEmpty ? candidates.first : null;
  }

  static void _ensureFallbackLoaded() {
    if (_fallbackLoaded) return;
    _fallbackLoaded = true;
    try {
      final candidates = _candidateFiles();
      Map<String, String>? bestData;

      // Scan candidate files, prioritizing ones with valid JWT tokens
      for (final f in candidates) {
        if (!f.existsSync()) continue;
        try {
          final content = f.readAsStringSync();
          if (content.isEmpty) continue;
          final decoded = jsonDecode(content);
          if (decoded is! Map) continue;

          final candidateMap = <String, String>{};
          decoded.forEach((k, v) {
            if (k != null && v != null) {
              candidateMap[k.toString()] = v.toString();
            }
          });

          final token = candidateMap[_kAccess];
          final hasValidJwt = isValidJwt(token);

          if (hasValidJwt) {
            bestData = candidateMap;
            break; // Found file with authenticated session JWT
          } else {
            bestData ??= candidateMap;
          }
        } catch (_) {}
      }

      if (bestData != null) {
        _memoryFallback.addAll(bestData);
      }

      // Ensure mock/offline tokens are never used as active access tokens
      if (_memoryFallback.containsKey(_kAccess)) {
        final tok = _memoryFallback[_kAccess];
        if (isValidJwt(tok)) {
          cachedAccessToken = tok;
        } else {
          _memoryFallback.remove(_kAccess);
          cachedAccessToken = null;
        }
      }
    } catch (e) {
      debugPrint('[TOKEN SERVICE] Fallback storage read error: $e');
    }
  }

  static void _persistFallback() {
    try {
      final jsonStr = jsonEncode(_memoryFallback);
      for (final f in _candidateFiles()) {
        try {
          final dir = f.parent;
          if (!dir.existsSync()) {
            dir.createSync(recursive: true);
          }
          f.writeAsStringSync(jsonStr);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[TOKEN SERVICE] Fallback storage persist error: $e');
    }
  }

  static Future<void> _safeWrite({required String key, required String value}) async {
    _ensureFallbackLoaded();
    _memoryFallback[key] = value;
    _persistFallback();
  }

  static Future<String?> _safeRead({required String key}) async {
    _ensureFallbackLoaded();
    return _memoryFallback[key];
  }

  static Future<void> _safeDelete({required String key}) async {
    _ensureFallbackLoaded();
    _memoryFallback.remove(key);
    _persistFallback();
  }

  static Future<void> _safeDeleteAll() async {
    _ensureFallbackLoaded();
    final preserved = <String, String>{};
    _memoryFallback.forEach((k, v) {
      if (k.startsWith('bnx_biz_onboarded_') ||
          k.startsWith('bnx_user_settings_') ||
          k.startsWith('bnx_user_avatar_') ||
          k == _kExplicitlyLoggedOut ||
          k == _kSavedAccountsRegistry) {
        preserved[k] = v;
      }
    });
    _memoryFallback.clear();
    _memoryFallback.addAll(preserved);
    _persistFallback();
  }

  // ── Tokens ─────────────────────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    cachedAccessToken = accessToken;
    await _safeWrite(key: _kAccess, value: accessToken);
    await _safeWrite(key: _kRefresh, value: refreshToken);
  }

  static String? getEmailFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
        if (payload is Map) {
          final sub = payload['sub']?.toString().trim().toLowerCase();
          final email = payload['email']?.toString().trim().toLowerCase();
          return email ?? sub;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<String?> getAccessToken() async {
    _ensureFallbackLoaded();
    final activeEmail = (await getUserEmail() ?? '').trim().toLowerCase();

    // 1. If active account has a token in registry or user settings, use it
    if (activeEmail.isNotEmpty) {
      final registry = await getSavedAccountsFromRegistry();
      final found = registry.firstWhere(
        (a) {
          final email = (a['email']?.toString() ?? '').trim().toLowerCase();
          final id = (a['id']?.toString() ?? '').trim().toLowerCase();
          return email == activeEmail || id == activeEmail;
        },
        orElse: () => {},
      );
      final activeTok = found['accessToken']?.toString();
      if (isValidJwt(activeTok)) {
        cachedAccessToken = activeTok;
        return activeTok;
      }

      final settings = await getUserSettings(activeEmail);
      final settingsTok = settings?['accessToken']?.toString();
      if (isValidJwt(settingsTok)) {
        cachedAccessToken = settingsTok;
        return settingsTok;
      }
    }

    if (isValidJwt(cachedAccessToken)) {
      return cachedAccessToken;
    }

    final stored = await _safeRead(key: _kAccess);
    if (isValidJwt(stored)) {
      cachedAccessToken = stored;
      return stored;
    }

    // Fallback: look in saved accounts registry for any available primary token
    final registry = await getSavedAccountsFromRegistry();
    if (registry.isNotEmpty) {
      for (final a in registry) {
        final tok = a['accessToken']?.toString();
        if (isValidJwt(tok)) {
          cachedAccessToken = tok;
          await _safeWrite(key: _kAccess, value: tok!);
          return cachedAccessToken;
        }
      }
    }

    return null;
  }

  static Future<String?> getRefreshToken() async =>
      _safeRead(key: _kRefresh);

  static Future<void> clearTokens() async {
    cachedAccessToken = null;
    await _safeDelete(key: _kAccess);
    await _safeDelete(key: _kRefresh);
  }

  static Future<void> clearAll() async {
    cachedAccessToken = null;
    await _safeDeleteAll();
  }

  static String _kCliksAccessKey(String email) =>
      'cliks_business_access_token_${email.trim().toLowerCase()}';

  static Future<String?> getCliksAccessToken([String? email]) async {
    _ensureFallbackLoaded();
    final target = (email ?? await getUserEmail() ?? '').trim().toLowerCase();
    if (target.isEmpty) return null;
    final tok = await _safeRead(key: _kCliksAccessKey(target));
    if (isValidJwt(tok)) {
      final jwtEmail = getEmailFromJwt(tok!);
      if (jwtEmail == null || !jwtEmail.contains('user@cliks.com')) {
        return tok;
      }
    }
    return null;
  }

  static Future<void> saveCliksAccessToken(String token, [String? email]) async {
    _ensureFallbackLoaded();
    final target = (email ?? await getUserEmail() ?? '').trim().toLowerCase();
    if (target.isNotEmpty) {
      await _safeWrite(key: _kCliksAccessKey(target), value: token);
    }
  }

  static Future<void> clearCliksAccessToken([String? email]) async {
    _ensureFallbackLoaded();
    final target = (email ?? await getUserEmail() ?? '').trim().toLowerCase();
    if (target.isNotEmpty) {
      await _safeDelete(key: _kCliksAccessKey(target));
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isExplicitlyLoggedOut() async {
    _ensureFallbackLoaded();
    final val = await _safeRead(key: _kExplicitlyLoggedOut);
    return val == 'true';
  }

  static Future<void> setExplicitlyLoggedOut(bool value) async {
    _ensureFallbackLoaded();
    if (value) {
      await _safeWrite(key: _kExplicitlyLoggedOut, value: 'true');
    } else {
      await _safeDelete(key: _kExplicitlyLoggedOut);
    }
  }

  // ── User Info & Active Session ─────────────────────────────────────────────

  static Future<String?> getUserEmail() async {
    final email = await _safeRead(key: _kEmail);
    if (email != null && email.isNotEmpty) return email;
    final registry = await getSavedAccountsFromRegistry();
    if (registry.isNotEmpty) {
      final regEmail = registry.first['email']?.toString();
      if (regEmail != null && regEmail.isNotEmpty) return regEmail;
    }
    return null;
  }

  static Future<String?> getUserName() async {
    final name = await _safeRead(key: _kName);
    if (name != null && name.isNotEmpty) return name;
    final email = await getUserEmail();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return null;
  }

  static Future<void> saveUserInfo({String? email, String? name}) async {
    if (email != null && email.isNotEmpty) {
      final cleanEmail = email.trim().toLowerCase();
      await _safeWrite(key: _kEmail, value: cleanEmail);
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) {
        await saveAccountToRegistry({
          'id': cleanEmail,
          'email': cleanEmail,
          'name': name ?? cleanEmail.split('@').first,
          'accessToken': token,
          'isPrimary': true,
        });
      }
    }
    if (name != null && name.isNotEmpty) {
      await _safeWrite(key: _kName, value: name);
    }
  }

  // ── User Avatar ────────────────────────────────────────────────────────────

  static Future<String?> getUserAvatar(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isNotEmpty) {
      final val = await _safeRead(key: _kAvatarKey(cleanEmail));
      if (val != null && val.isNotEmpty) return val;
    }
    final globalVal = await _safeRead(key: _kGlobalAvatar);
    return (globalVal != null && globalVal.isNotEmpty) ? globalVal : null;
  }

  static Future<void> saveUserAvatar(String email, String avatar) async {
    final cleanEmail = email.trim().toLowerCase();
    if (avatar.isNotEmpty) {
      await _safeWrite(key: _kGlobalAvatar, value: avatar);
      if (cleanEmail.isNotEmpty) {
        await _safeWrite(key: _kAvatarKey(cleanEmail), value: avatar);
      }
    } else {
      await _safeDelete(key: _kGlobalAvatar);
      if (cleanEmail.isNotEmpty) {
        await _safeDelete(key: _kAvatarKey(cleanEmail));
      }
    }
  }

  // ── User Settings ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUserSettings(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return null;
    final str = await _safeRead(key: _kSettingsKey(cleanEmail));
    if (str != null && str.isNotEmpty) {
      try {
        final decoded = jsonDecode(str);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  static Future<void> saveUserSettings(String email, Map<String, dynamic> data) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isNotEmpty) {
      final existing = await getUserSettings(cleanEmail) ?? {};
      final merged = {...existing, ...data};
      await _safeWrite(key: _kSettingsKey(cleanEmail), value: jsonEncode(merged));
    }
  }

  /// Synchronous retrieval of user settings from preloaded fallback memory
  static Map<String, dynamic>? getUserSettingsSync(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return null;
    _ensureFallbackLoaded();
    final str = _memoryFallback[_kSettingsKey(cleanEmail)];
    if (str != null && str.isNotEmpty) {
      try {
        final decoded = jsonDecode(str);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  /// Returns the specific access token for a given account email,
  /// falling back to the active session token.
  static Future<String?> getTokenForAccount(String email) async {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return getAccessToken();
    final registry = await getSavedAccountsFromRegistry();
    final found = registry.firstWhere(
      (a) =>
          (a['email']?.toString() ?? '').trim().toLowerCase() == clean ||
          (a['id']?.toString() ?? '').trim().toLowerCase() == clean,
      orElse: () => {},
    );
    if (found.isNotEmpty) {
      final tok = found['accessToken']?.toString();
      if (isValidJwt(tok)) return tok;
      return null;
    }
    final activeEmail = (await getUserEmail() ?? '').trim().toLowerCase();
    if (activeEmail == clean) {
      final token = await getAccessToken();
      if (isValidJwt(token)) return token;
    }
    return null;
  }

  // ── Multi-Account Registry ─────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getSavedAccountsFromRegistry() async {
    final raw = await _safeRead(key: _kSavedAccountsRegistry);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> saveAccountToRegistry(Map<String, dynamic> account) async {
    final email = (account['email']?.toString() ?? '').trim().toLowerCase();
    if (email.isEmpty) return;
    final existing = await getSavedAccountsFromRegistry();
    final targetExisting = existing.firstWhere(
      (a) => (a['email']?.toString() ?? '').toLowerCase() == email,
      orElse: () => {},
    );
    final updated = existing.where((a) => (a['email']?.toString() ?? '').toLowerCase() != email).toList();
    String? token = account['accessToken']?.toString() ?? targetExisting['accessToken']?.toString();
    String? refresh = account['refreshToken']?.toString() ?? targetExisting['refreshToken']?.toString();

    if (token == null || token.isEmpty) {
      final currentToken = await getAccessToken();
      if (currentToken != null && currentToken.isNotEmpty) {
        final jwtEmail = getEmailFromJwt(currentToken);
        if (jwtEmail == email) {
          token = currentToken;
        }
      }
    }

    updated.add({
      ...targetExisting,
      ...account,
      if (token != null && token.isNotEmpty) 'accessToken': token,
      if (refresh != null && refresh.isNotEmpty) 'refreshToken': refresh,
      'email': email,
      'id': email,
    });
    await _safeWrite(key: _kSavedAccountsRegistry, value: jsonEncode(updated));
  }

  static Future<void> removeAccountFromRegistry(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    final existing = await getSavedAccountsFromRegistry();
    final updated = existing.where((a) => (a['email']?.toString() ?? '').toLowerCase() != cleanEmail).toList();
    await _safeWrite(key: _kSavedAccountsRegistry, value: jsonEncode(updated));
  }

  static Future<void> switchActiveAccountSession(String id) async {
    final clean = id.trim().toLowerCase();
    cachedAccessToken = null;
    final accounts = await getSavedAccountsFromRegistry();
    final target = accounts.firstWhere(
      (a) {
        final email = (a['email']?.toString() ?? '').trim().toLowerCase();
        final accId = (a['id']?.toString() ?? '').trim().toLowerCase();
        final username = email.contains('@') ? email.split('@').first : email;
        return email == clean || accId == clean || username == clean;
      },
      orElse: () => {},
    );
    if (target.isNotEmpty) {
      String accessToken = target['accessToken']?.toString() ?? '';
      String refreshToken = target['refreshToken']?.toString() ?? '';
      final name = target['name']?.toString() ?? clean.split('@').first;

      if (accessToken.isEmpty) {
        for (final acc in accounts) {
          final tok = acc['accessToken']?.toString() ?? '';
          if (tok.isNotEmpty) {
            final jwtEmail = getEmailFromJwt(tok);
            if (jwtEmail == clean) {
              accessToken = tok;
              refreshToken = acc['refreshToken']?.toString() ?? '';
              target['accessToken'] = tok;
              break;
            }
          }
        }
      }

      // If target mailbox does not have its own separate token, retain current/primary session token
      if (accessToken.isEmpty) {
        final currentSessionToken = await _safeRead(key: _kAccess);
        if (currentSessionToken != null && currentSessionToken.isNotEmpty) {
          accessToken = currentSessionToken;
          refreshToken = (await _safeRead(key: _kRefresh)) ?? '';
        } else {
          for (final acc in accounts) {
            final tok = acc['accessToken']?.toString() ?? '';
            if (tok.isNotEmpty) {
              accessToken = tok;
              refreshToken = acc['refreshToken']?.toString() ?? '';
              break;
            }
          }
        }
      }

      if (accessToken.isNotEmpty) {
        await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
      await _safeWrite(key: _kEmail, value: clean);
      await _safeWrite(key: _kName, value: name);
    } else {
      await _safeWrite(key: _kEmail, value: clean);
    }

    final updated = accounts.map((acc) {
      final accEmail = (acc['email']?.toString() ?? '').toLowerCase();
      final accId = (acc['id']?.toString() ?? '').toLowerCase();
      final username = accEmail.contains('@') ? accEmail.split('@').first : accEmail;
      return {
        ...acc,
        'isPrimary': (accEmail == clean || accId == clean || username == clean),
      };
    }).toList();
    await _safeWrite(key: _kSavedAccountsRegistry, value: jsonEncode(updated));
  }

  // ── Business Onboarding ────────────────────────────────────────────────────

  static Future<void> setBusinessOnboardingCompleted(
    String email, {
    bool completed = true,
  }) async {
    final clean = email.trim().toLowerCase();
    if (clean.isNotEmpty) {
      await _safeWrite(key: _kBizOnboardedKey(clean), value: completed ? 'true' : 'false');
    }
  }

  static Future<bool> isBusinessOnboardingCompleted(String email) async {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return false;
    final val = await _safeRead(key: _kBizOnboardedKey(clean));
    return val == 'true';
  }
}
