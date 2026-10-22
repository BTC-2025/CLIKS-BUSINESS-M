import 'dart:async';

class TokenService {
  static String? cachedAccessToken = 'mock_cliks_business_session_token_12345';
  static String _activeEmail = 'ravinew2004@bnxmail.com';
  static String _activeName = 'Ravi Kumar C';

  static final Map<String, String> _avatars = {};
  static final Map<String, Map<String, dynamic>> _userSettings = {
    'ravinew2004@bnxmail.com': {
      'name': 'Ravi Kumar C',
      'email': 'ravinew2004@bnxmail.com',
      'firstName': 'Ravi Kumar',
      'lastName': 'C',
      'username': 'ravinew2004',
      'jobTitle': 'Executive Director',
      'location': 'Bengaluru, India',
      'phoneNumber': '+91 98765 43210',
      'recoveryEmail': 'ravi.backup@gmail.com',
      'backupPhone': '+91 98765 01234',
      'storageLimit': 16106127360, // 15 GB
      'storageUsed': 2362232012,  // 2.2 GB
      'language': 'English (US)',
      'spellingCheckEnabled': true,
      'grammarCheckEnabled': true,
      'autoCorrectEnabled': true,
      'smartComposeEnabled': true,
      'twoFactorEnabled': false,
    },
    'sales.ravinew2004@bnxmail.com': {
      'name': 'Sales Desk',
      'email': 'sales.ravinew2004@bnxmail.com',
      'username': 'sales.ravinew2004',
      'jobTitle': 'Sales Operations',
      'location': 'Bengaluru, India',
      'phoneNumber': '+91 98765 43210',
      'storageLimit': 16106127360,
      'storageUsed': 1048576000,
    },
    'admin@cliks.business': {
      'name': 'Cliks Admin',
      'email': 'admin@cliks.business',
      'username': 'cliks_admin',
      'jobTitle': 'Enterprise Administrator',
      'location': 'Bengaluru, India',
      'storageLimit': 53687091200, // 50 GB
      'storageUsed': 8589934592,
    },
  };

  static final List<Map<String, dynamic>> _registry = [
    {
      'id': 'ravinew2004@bnxmail.com',
      'name': 'Ravi Kumar C',
      'email': 'ravinew2004@bnxmail.com',
      'isPrimary': true,
      'accountType': 'BUSINESS',
      'role': 'Owner / Executive',
    },
    {
      'id': 'sales.ravinew2004@bnxmail.com',
      'name': 'Sales Desk',
      'email': 'sales.ravinew2004@bnxmail.com',
      'isPrimary': false,
      'accountType': 'BUSINESS',
      'role': 'Sub-Account',
    },
    {
      'id': 'admin@cliks.business',
      'name': 'Cliks Admin',
      'email': 'admin@cliks.business',
      'isPrimary': false,
      'accountType': 'ENTERPRISE',
      'role': 'Administrator',
    },
  ];

  static String? _refreshToken;
  static final Set<String> _onboardedBusinessEmails = {'ravinew2004@bnxmail.com'};

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    cachedAccessToken = accessToken;
    _refreshToken = refreshToken;
  }

  static Future<String?> getAccessToken() async {
    return cachedAccessToken;
  }

  static Future<String?> getRefreshToken() async {
    return _refreshToken;
  }

  static Future<void> clearTokens() async {
    cachedAccessToken = null;
    _refreshToken = null;
  }

  static Future<void> clearAll() async {
    cachedAccessToken = null;
    _refreshToken = null;
    _activeEmail = '';
    _activeName = '';
  }

  static Future<bool> isLoggedIn() async {
    return cachedAccessToken != null && cachedAccessToken!.isNotEmpty;
  }

  static Future<void> setBusinessOnboardingCompleted(
    String email, {
    bool completed = true,
  }) async {
    final clean = email.trim().toLowerCase();
    if (completed) {
      _onboardedBusinessEmails.add(clean);
    } else {
      _onboardedBusinessEmails.remove(clean);
    }
  }

  static Future<bool> isBusinessOnboardingCompleted(String email) async {
    final clean = email.trim().toLowerCase();
    return _onboardedBusinessEmails.contains(clean);
  }

  static Future<void> removeAccountFromRegistry(String email) async {
    final clean = email.trim().toLowerCase();
    _registry.removeWhere(
      (a) => (a['email']?.toString() ?? '').toLowerCase() == clean,
    );
  }

  static Future<void> saveAccountToRegistry(Map<String, dynamic> account) async {
    final email = (account['email']?.toString() ?? '').trim().toLowerCase();
    if (email.isEmpty) return;
    final idx = _registry.indexWhere(
      (a) => (a['email']?.toString() ?? '').toLowerCase() == email,
    );
    if (idx >= 0) {
      _registry[idx] = {..._registry[idx], ...account};
    } else {
      _registry.add(account);
    }
  }

  static Future<String?> getUserEmail() async {
    return _activeEmail;
  }

  static Future<String?> getUserName() async {
    return _activeName;
  }

  static Future<void> saveUserInfo({String? email, String? name}) async {
    if (email != null && email.isNotEmpty) _activeEmail = email;
    if (name != null && name.isNotEmpty) _activeName = name;
  }

  static Future<String?> getUserAvatar(String email) async {
    final key = email.trim().toLowerCase();
    return _avatars[key];
  }

  static Future<void> saveUserAvatar(String email, String avatar) async {
    final key = email.trim().toLowerCase();
    if (avatar.isEmpty) {
      _avatars.remove(key);
    } else {
      _avatars[key] = avatar;
    }
  }

  static Future<Map<String, dynamic>?> getUserSettings(String email) async {
    final key = email.trim().toLowerCase();
    return _userSettings[key] != null ? Map<String, dynamic>.from(_userSettings[key]!) : null;
  }

  static Future<void> saveUserSettings(String email, Map<String, dynamic> data) async {
    final key = email.trim().toLowerCase();
    final current = _userSettings[key] ?? {};
    _userSettings[key] = {...current, ...data};
  }

  static Future<List<Map<String, dynamic>>> getSavedAccountsFromRegistry() async {
    return List<Map<String, dynamic>>.from(_registry);
  }

  static Future<void> switchActiveAccountSession(String id) async {
    final clean = id.trim().toLowerCase();
    _activeEmail = clean;
    final found = _registry.firstWhere(
      (acc) => (acc['email']?.toString() ?? '').toLowerCase() == clean,
      orElse: () => {'name': clean.split('@').first},
    );
    _activeName = found['name']?.toString() ?? clean.split('@').first;
    for (var reg in _registry) {
      reg['isPrimary'] = (reg['email']?.toString() ?? '').toLowerCase() == clean;
    }
  }
}
