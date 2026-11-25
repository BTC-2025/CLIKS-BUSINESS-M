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

  static File? _resolveFallbackFile() {
    try {
      if (kIsWeb) return null;
      Directory? baseDir;
      if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null && home.isNotEmpty) {
          baseDir = Directory('$home/Library/Application Support/com.bnxmail.app');
        }
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null && home.isNotEmpty) {
          baseDir = Directory('$home/.config/com.bnxmail.app');
        }
      } else if (Platform.isWindows) {
        final appData = Platform.environment['APPDATA'];
        if (appData != null && appData.isNotEmpty) {
          baseDir = Directory('$appData/com.bnxmail.app');
        }
      }
      baseDir ??= Directory('${Directory.systemTemp.path}/com.bnxmail.app');
      if (!baseDir.existsSync()) {
        baseDir.createSync(recursive: true);
      }
      return File('${baseDir.path}/.bnx_local_store.json');
    } catch (_) {
      return null;
    }
  }

  static void _ensureFallbackLoaded() {
    if (_fallbackLoaded) return;
    _fallbackLoaded = true;
    try {
      final file = _resolveFallbackFile();
      if (file != null && file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map) {
            decoded.forEach((k, v) {
              if (k != null && v != null) {
                _memoryFallback[k.toString()] = v.toString();
              }
            });
          }
        }
      }
      if (_memoryFallback.containsKey(_kAccess)) {
        cachedAccessToken = _memoryFallback[_kAccess];
      }
    } catch (e) {
      debugPrint('[TOKEN SERVICE] Fallback storage read error: $e');
    }
  }

  static void _persistFallback() {
    try {
      final file = _resolveFallbackFile();
      if (file != null) {
        file.writeAsStringSync(jsonEncode(_memoryFallback));
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
      if (activeTok != null && activeTok.isNotEmpty) {
        cachedAccessToken = activeTok;
        return activeTok;
      }

      final settings = await getUserSettings(activeEmail);
      final settingsTok = settings?['accessToken']?.toString();
      if (settingsTok != null && settingsTok.isNotEmpty && settingsTok.startsWith('ey')) {
        cachedAccessToken = settingsTok;
        return settingsTok;
      }
    }

    if (cachedAccessToken != null && cachedAccessToken!.isNotEmpty) {
      return cachedAccessToken;
    }

    final stored = await _safeRead(key: _kAccess);
    if (stored != null && stored.isNotEmpty) {
      cachedAccessToken = stored;
      return stored;
    }

    // Fallback: look in saved accounts registry for any available primary token
    final registry = await getSavedAccountsFromRegistry();
    if (registry.isNotEmpty) {
      for (final a in registry) {
        final tok = a['accessToken']?.toString();
        if (tok != null && tok.isNotEmpty) {
          cachedAccessToken = tok;
          await _safeWrite(key: _kAccess, value: tok);
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
    if (tok != null && tok.isNotEmpty) return tok;
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
    final activeEmail = (await getUserEmail() ?? '').trim().toLowerCase();
    if (activeEmail == clean) {
      final token = await getAccessToken();
      if (token != null && token.isNotEmpty) return token;
    }
    final registry = await getSavedAccountsFromRegistry();
    final found = registry.firstWhere(
      (a) =>
          (a['email']?.toString() ?? '').trim().toLowerCase() == clean ||
          (a['id']?.toString() ?? '').trim().toLowerCase() == clean,
      orElse: () => {},
    );
    final tok = found['accessToken']?.toString();
    if (tok != null && tok.isNotEmpty) return tok;
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
        final jwtEmail = _getEmailFromJwt(currentToken);
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
