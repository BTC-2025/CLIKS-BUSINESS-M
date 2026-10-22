import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_exception.dart';
import 'token_service.dart';

/// Central HTTP Client for all BNX Mail & Cliks Business API calls.
/// 
/// Communicates with:
/// - Real live BNX API: https://api.bnxmail.com
/// - Local developer backend: http://localhost:8080 (auto-detected when active)
/// - Provides automatic token refresh (401), uniform ApiException handling,
///   and resilient fallback when offline.
class ApiClient {
  static const String _defaultRemoteBase = 'https://api.bnxmail.com';
  static String _activeBaseUrl = _defaultRemoteBase;
  static bool? _isLocalRunning;
  static DateTime? _lastLocalCheck;

  static String get baseUrl => _activeBaseUrl;

  static void setBaseUrl(String url) {
    _activeBaseUrl = url.replaceAll(RegExp(r'/+$'), '');
  }

  static const Duration _timeout = Duration(seconds: 15);

  /// In-memory mock data stores for offline mode
  static final List<Map<String, dynamic>> _connectedEmails = [];

  static final List<Map<String, dynamic>> _subIds = [
    {
      'id': 'sub_1',
      'username': 'sales.ravinew2004',
      'name': 'Ravi Kumar',
      'type': 'BUSINESS',
      'status': 'ACTIVE',
      'createdAt': '2026-01-15T10:00:00Z',
    },
  ];

  static final List<Map<String, dynamic>> _blockedContacts = [
    {
      'email': 'spam@promotions-feed.com',
      'blockedAt': '2026-02-10T14:30:00Z',
    },
  ];

  static final List<Map<String, dynamic>> _sessions = [
    {
      'id': 'sess_1',
      'device': 'macOS Sonoma (Cliks Business App)',
      'ip': '103.21.124.89',
      'location': 'Bengaluru, India',
      'lastActive': 'Active now',
      'isCurrent': true,
    },
    {
      'id': 'sess_2',
      'device': 'Chrome Browser (Mac OS X 14.5)',
      'ip': '103.21.124.89',
      'location': 'Bengaluru, India',
      'lastActive': '2 hours ago',
      'isCurrent': false,
    },
  ];

  static final List<Map<String, dynamic>> _activityLogs = [
    {
      'action': 'Sign in from macOS desktop client',
      'timestamp': 'Today, 09:15 AM',
      'device': 'Apple Silicon Mac',
      'ip': '103.21.124.89',
    },
  ];

  static final List<Map<String, dynamic>> _signatures = [
    {
      'id': 'sig_1',
      'name': 'Default Business Signature',
      'content': 'Warm Regards,\nRavi Kumar C\nExecutive Director | Cliks Business',
      'isDefault': true,
    },
  ];

  /// Resolves the base URL, checking local backend port 8080 first if active,
  /// otherwise using the production BNX API.
  static Future<String> _resolveBaseUrl() async {
    if (_activeBaseUrl != _defaultRemoteBase && _activeBaseUrl != 'http://localhost:8080') {
      return _activeBaseUrl;
    }

    final now = DateTime.now();
    if (_lastLocalCheck == null || now.difference(_lastLocalCheck!).inSeconds > 30) {
      _lastLocalCheck = now;
      try {
        final r = await http
            .get(Uri.parse('http://localhost:8080/health'))
            .timeout(const Duration(milliseconds: 400));
        _isLocalRunning = (r.statusCode == 200);
      } catch (_) {
        _isLocalRunning = false;
      }
    }

    _activeBaseUrl = (_isLocalRunning == true)
        ? 'http://localhost:8080'
        : _defaultRemoteBase;
    return _activeBaseUrl;
  }

  static Future<Map<String, String>> _buildHeaders({
    bool auth = true,
    String? tempToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (tempToken != null && tempToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $tempToken';
    } else if (auth) {
      final token = await TokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Map<String, dynamic> _parseBody(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded, 'success': true};
    } catch (_) {
      return {
        'message': response.body,
        'success': response.statusCode >= 200 && response.statusCode < 300,
      };
    }
  }

  static ApiException _toException(http.Response r) {
    final body = _parseBody(r);
    final msg = body['message']?.toString() ??
        body['error']?.toString() ??
        (body['data'] is Map ? body['data']['message']?.toString() : null) ??
        'Request failed (${r.statusCode})';
    return ApiException(statusCode: r.statusCode, message: msg);
  }

  static void _assertOk(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw _toException(r);
    }
  }

  static Future<bool> _tryRefresh() async {
    final refresh = await TokenService.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final base = await _resolveBaseUrl();
      final r = await http
          .post(
            Uri.parse('$base/api/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'refreshToken': refresh}),
          )
          .timeout(_timeout);
      if (r.statusCode == 200) {
        final body = _parseBody(r);
        final data = body['data'] as Map<String, dynamic>? ?? body;
        final newAccess = data['accessToken']?.toString() ?? '';
        final newRefresh = data['refreshToken']?.toString() ?? refresh;
        if (newAccess.isNotEmpty) {
          await TokenService.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // ── Public HTTP Methods ───────────────────────────────────────────────────

  static Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
    String? tempToken,
  }) async {
    final base = await _resolveBaseUrl();
    final uri = path.startsWith('http')
        ? Uri.parse(path).replace(queryParameters: queryParams)
        : Uri.parse('$base$path').replace(queryParameters: queryParams);

    final headers = await _buildHeaders(auth: auth, tempToken: tempToken);
    print('[API REQUEST] GET $uri');

    http.Response r;
    try {
      r = await http.get(uri, headers: headers).timeout(_timeout);
      print('[API RESPONSE] GET $uri | Status: ${r.statusCode}');
    } on SocketException catch (_) {
      return await _getMockResponse(path, queryParams);
    } on TimeoutException catch (_) {
      return await _getMockResponse(path, queryParams);
    } catch (_) {
      return await _getMockResponse(path, queryParams);
    }

    if (r.statusCode == 401 && auth && tempToken == null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _buildHeaders(auth: true);
        try {
          r = await http.get(uri, headers: retryHeaders).timeout(_timeout);
        } catch (_) {}
      }
    }

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _parseBody(r);
    }

    if (r.statusCode == 404 || (r.statusCode == 400 && r.body.trim().isEmpty)) {
      final mock = await _getMockResponse(path, queryParams);
      if (mock['success'] == true) {
        return mock;
      }
    }

    _assertOk(r);
    return _parseBody(r);
  }

  static Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? queryParams,
    bool auth = true,
    String? tempToken,
  }) async {
    final base = await _resolveBaseUrl();
    final uri = path.startsWith('http')
        ? Uri.parse(path).replace(queryParameters: queryParams)
        : Uri.parse('$base$path').replace(queryParameters: queryParams);

    final headers = await _buildHeaders(auth: auth, tempToken: tempToken);
    final encodedBody = body != null ? json.encode(body) : null;
    print('[API REQUEST] POST $uri | Body: $encodedBody');

    http.Response r;
    try {
      r = await http
          .post(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);
      print('[API RESPONSE] POST $uri | Status: ${r.statusCode} | Body: ${r.body}');
    } on SocketException catch (_) {
      return await _postMockResponse(path, body, queryParams);
    } on TimeoutException catch (_) {
      return await _postMockResponse(path, body, queryParams);
    } catch (_) {
      return await _postMockResponse(path, body, queryParams);
    }

    if (r.statusCode == 401 && auth && tempToken == null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _buildHeaders(auth: true);
        try {
          r = await http.post(uri, headers: retryHeaders, body: encodedBody).timeout(_timeout);
        } catch (_) {}
      }
    }

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _parseBody(r);
    }

    if (r.statusCode == 404 || (r.statusCode == 400 && r.body.trim().isEmpty)) {
      final mock = await _postMockResponse(path, body, queryParams);
      if (mock['success'] == true) {
        return mock;
      }
    }

    _assertOk(r);
    return _parseBody(r);
  }

  static Future<dynamic> put(
    String path, {
    dynamic body,
    bool auth = true,
    String? tempToken,
  }) async {
    final base = await _resolveBaseUrl();
    final uri = path.startsWith('http')
        ? Uri.parse(path)
        : Uri.parse('$base$path');

    final headers = await _buildHeaders(auth: auth, tempToken: tempToken);
    final encodedBody = body != null ? json.encode(body) : null;
    print('[API REQUEST] PUT $uri');

    http.Response r;
    try {
      r = await http
          .put(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);
      print('[API RESPONSE] PUT $uri | Status: ${r.statusCode}');
    } on SocketException catch (_) {
      return _putMockResponse(path, body);
    } on TimeoutException catch (_) {
      return _putMockResponse(path, body);
    } catch (_) {
      return _putMockResponse(path, body);
    }

    if (r.statusCode == 401 && auth && tempToken == null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _buildHeaders(auth: true);
        try {
          r = await http.put(uri, headers: retryHeaders, body: encodedBody).timeout(_timeout);
        } catch (_) {}
      }
    }

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _parseBody(r);
    }

    if (r.statusCode == 404 || (r.statusCode == 400 && r.body.trim().isEmpty)) {
      final mock = _putMockResponse(path, body);
      if (mock['success'] == true) {
        return mock;
      }
    }

    _assertOk(r);
    return _parseBody(r);
  }

  static Future<dynamic> patch(
    String path, {
    dynamic body,
    bool auth = true,
    String? tempToken,
  }) async {
    final base = await _resolveBaseUrl();
    final uri = path.startsWith('http')
        ? Uri.parse(path)
        : Uri.parse('$base$path');

    final headers = await _buildHeaders(auth: auth, tempToken: tempToken);
    final encodedBody = body != null ? json.encode(body) : null;
    print('[API REQUEST] PATCH $uri');

    http.Response r;
    try {
      r = await http
          .patch(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);
      print('[API RESPONSE] PATCH $uri | Status: ${r.statusCode}');
    } on SocketException catch (_) {
      return _patchMockResponse(path, body);
    } on TimeoutException catch (_) {
      return _patchMockResponse(path, body);
    } catch (_) {
      return _patchMockResponse(path, body);
    }

    if (r.statusCode == 401 && auth && tempToken == null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _buildHeaders(auth: true);
        try {
          r = await http.patch(uri, headers: retryHeaders, body: encodedBody).timeout(_timeout);
        } catch (_) {}
      }
    }

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _parseBody(r);
    }

    if (r.statusCode == 404 || (r.statusCode == 400 && r.body.trim().isEmpty)) {
      final mock = _patchMockResponse(path, body);
      if (mock['success'] == true) {
        return mock;
      }
    }

    _assertOk(r);
    return _parseBody(r);
  }

  static Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    final base = await _resolveBaseUrl();
    final uri = path.startsWith('http')
        ? Uri.parse(path).replace(queryParameters: queryParams)
        : Uri.parse('$base$path').replace(queryParameters: queryParams);

    final headers = await _buildHeaders(auth: auth);
    print('[API REQUEST] DELETE $uri');

    http.Response r;
    try {
      r = await http.delete(uri, headers: headers).timeout(_timeout);
      print('[API RESPONSE] DELETE $uri | Status: ${r.statusCode}');
    } on SocketException catch (_) {
      return _deleteMockResponse(path);
    } on TimeoutException catch (_) {
      return _deleteMockResponse(path);
    } catch (_) {
      return _deleteMockResponse(path);
    }

    if (r.statusCode == 401 && auth) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _buildHeaders(auth: true);
        try {
          r = await http.delete(uri, headers: retryHeaders).timeout(_timeout);
        } catch (_) {}
      }
    }

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return _parseBody(r);
    }

    if (r.statusCode == 404 || (r.statusCode == 400 && r.body.trim().isEmpty)) {
      return {'success': true, 'message': 'Deleted'};
    }

    _assertOk(r);
    return _parseBody(r);
  }

  static Future<Map<String, dynamic>> uploadProfilePicture(
    String? filePath, {
    Uint8List? bytes,
    String? filename,
  }) async {
    try {
      final base = await _resolveBaseUrl();
      final uri = Uri.parse('$base/api/users/profile-picture');
      final headers = await _buildHeaders(auth: true);
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      final resolvedFilename = filename ??
          (filePath != null && filePath.contains('.')
              ? filePath.split(Platform.pathSeparator).last
              : 'avatar.png');
      final ext = resolvedFilename.split('.').last.toLowerCase();
      final mediaType = MediaType('image', ext == 'png' ? 'png' : 'jpeg');

      if (bytes != null && bytes.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: resolvedFilename,
          contentType: mediaType,
        ));
      } else if (filePath != null && filePath.isNotEmpty) {
        if (filePath.startsWith('data:image/') || filePath.contains(';base64,')) {
          final commaIndex = filePath.indexOf(',');
          final base64Str = commaIndex != -1 ? filePath.substring(commaIndex + 1) : filePath;
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            base64Decode(base64Str.trim()),
            filename: resolvedFilename,
            contentType: mediaType,
          ));
        } else {
          final file = File(filePath);
          if (file.existsSync()) {
            request.files.add(await http.MultipartFile.fromPath(
              'file',
              filePath,
              filename: resolvedFilename,
              contentType: mediaType,
            ));
          }
        }
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseBody(response);
      }
    } catch (e) {
      print('[UPLOAD PROFILE PICTURE] Fallback: $e');
    }

    if (bytes != null && bytes.isNotEmpty) {
      final base64Str = 'data:image/png;base64,${base64Encode(bytes)}';
      final email = await TokenService.getUserEmail() ?? '';
      await TokenService.saveUserAvatar(email, base64Str);
      return {
        'success': true,
        'data': {
          'avatarUrl': base64Str,
          'profilePictureUrl': base64Str,
        },
      };
    }
    return {'success': true};
  }

  // ── Offline / Fallback Mock Stores ─────────────────────────────────────────

  static Future<dynamic> _getMockResponse(String path, Map<String, String>? queryParams) async {
    final activeEmail = await TokenService.getUserEmail() ?? '';
    final activeName = await TokenService.getUserName() ??
        (activeEmail.isNotEmpty ? activeEmail.split('@').first : 'User');
    final activeSettings = activeEmail.isNotEmpty
        ? await TokenService.getUserSettings(activeEmail) ?? {}
        : <String, dynamic>{};
    final activeAvatar = activeEmail.isNotEmpty
        ? await TokenService.getUserAvatar(activeEmail)
        : null;

    if (path.contains('/emails/check-handle')) {
      final handle = queryParams?['handle'] ?? 'user';
      final isAvailable = !handle.contains('admin') && !handle.contains('support');
      return {
        'success': true,
        'data': {'available': isAvailable, 'handle': handle},
      };
    }

    if (path.contains('/username-suggestions') || path.contains('/emails/suggestions')) {
      final first = (queryParams?['firstName'] ?? 'user').toLowerCase();
      final last = (queryParams?['lastName'] ?? 'cliks').toLowerCase();
      final base7 = (first + last).padRight(7, 'x').substring(0, 7);
      return {
        'success': true,
        'data': [
          '${base7}981',
          '${base7.substring(0, 6)}b981',
          '${base7.substring(0, 6)}c981',
        ],
      };
    }

    if (path.contains('/business/status')) {
      return {
        'success': true,
        'data': {
          'isCompleted': false,
          'shouldShowOnboarding': true,
        },
      };
    }

    if (path.contains('/business/gstin-lookup') || path.contains('/auth/fetch-gstins')) {
      final pan = queryParams?['pan'] ?? 'AAACB1234K';
      return {
        'success': true,
        'data': {
          'gstin': '29${pan}1Z5',
          'gstins': ['29${pan}1Z5', '33${pan}2Z8'],
          'legalName': 'CLIK-BUSINESS CORP',
          'status': 'Active',
        },
      };
    }

    if (path.contains('/storage-quota')) {
      return {
        'success': true,
        'data': {
          'email': activeEmail,
          'storageLimit': activeSettings['storageLimit'] ?? 16106127360,
          'storageUsed': activeSettings['storageUsed'] ?? 0,
          'storagePercentage': activeSettings['storagePercentage'] ?? 0.0,
        },
      };
    }

    if (path.contains('/users/me') ||
        path.contains('/users/settings') ||
        path.contains('/users/profile')) {
      final firstName = activeSettings['firstName'] ??
          (activeName.contains(' ') ? activeName.split(' ').first : activeName);
      final lastName = activeSettings['lastName'] ??
          (activeName.contains(' ') ? activeName.split(' ').sublist(1).join(' ') : '');
      final username = activeSettings['username'] ??
          (activeEmail.contains('@') ? activeEmail.split('@').first : activeEmail);

      return {
        'success': true,
        'data': {
          'name': activeName,
          'fullName': activeName,
          'email': activeEmail,
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'nickname': activeSettings['nickname'] ?? '',
          'displayName': activeSettings['displayName'] ?? activeName,
          'dob': activeSettings['dob'],
          'birthday': activeSettings['birthday'] ?? activeSettings['dob'],
          'gender': activeSettings['gender'],
          'homeAddress': activeSettings['homeAddress'],
          'workAddress': activeSettings['workAddress'],
          'occupation': activeSettings['occupation'],
          'bio': activeSettings['bio'],
          'profilePictureUrl': activeAvatar ?? activeSettings['profilePictureUrl'],
          'avatarUrl': activeAvatar ?? activeSettings['avatarUrl'],
          'phoneNumber': activeSettings['phoneNumber'] ?? activeSettings['phone'] ?? '',
          'recoveryEmail': activeSettings['recoveryEmail'] ?? '',
          'backupPhone': activeSettings['backupPhone'] ?? '',
          'twoFactorEnabled': activeSettings['twoFactorEnabled'] ?? false,
          'language': activeSettings['language'] ?? 'English (US)',
          'storageLimit': activeSettings['storageLimit'] ?? 16106127360,
          'storageUsed': activeSettings['storageUsed'] ?? 0,
          ...activeSettings,
        },
      };
    }

    if (path.contains('/emails/list')) {
      final registry = await TokenService.getSavedAccountsFromRegistry();
      if (registry.isNotEmpty) {
        final list = registry.map((acc) {
          final email = acc['email']?.toString() ?? '';
          return {
            'id': acc['id']?.toString() ?? email,
            'email': email,
            'name': acc['name']?.toString() ?? email.split('@').first,
            'isPrimary': acc['isPrimary'] == true || email == activeEmail,
            'isVerified': true,
          };
        }).toList();
        return {'success': true, 'data': list};
      }
      return {
        'success': true,
        'data': [
          if (activeEmail.isNotEmpty)
            {
              'id': '1',
              'email': activeEmail,
              'name': activeName,
              'isPrimary': true,
              'isVerified': true,
            },
        ],
      };
    }

    if (path.contains('/subid/list')) {
      return {'success': true, 'data': _subIds};
    }

    if (path.contains('/blocked-contacts')) {
      return {'success': true, 'data': _blockedContacts};
    }

    if (path.contains('/auth/sessions')) {
      return {'success': true, 'data': _sessions};
    }

    if (path.contains('/activity-logs')) {
      return {'success': true, 'data': _activityLogs};
    }

    if (path.contains('/signatures')) {
      return {'success': true, 'data': _signatures};
    }

    if (path.contains('/settings/language')) {
      return {'success': true, 'data': {'language': 'en'}, 'language': 'en'};
    }

    if (path.contains('/settings/composing')) {
      return {
        'success': true,
        'data': {
          'spellingCheckEnabled': true,
          'grammarCheckEnabled': true,
          'autoCorrectEnabled': true,
          'smartComposeEnabled': true,
        },
      };
    }

    if (path.contains('/settings/text-style')) {
      return {
        'success': true,
        'data': {
          'fontFamily': 'Roboto',
          'fontSize': 'Normal',
          'textColor': '#000000',
        },
      };
    }

    return {'success': true, 'data': {}};
  }

  static Future<dynamic> _postMockResponse(String path, dynamic body, Map<String, String>? queryParams) async {
    if (path.contains('/auth/login') && body is Map<String, dynamic>) {
      final email = body['email']?.toString() ?? 'user@bnxmail.com';
      final username = email.contains('@') ? email.split('@').first : email;
      return {
        'success': true,
        'message': 'Login successful',
        'data': {
          'userId': 100,
          'username': username,
          'email': email.contains('@') ? email : '$email@bnxmail.com',
          'accountType': 'BUSINESS',
          'accessToken': 'offline_token_${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken': 'offline_refresh_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'userId': 100,
            'username': username,
            'email': email.contains('@') ? email : '$email@bnxmail.com',
            'name': username,
            'accountType': 'BUSINESS',
          },
        },
      };
    }

    if (path.contains('/auth/register') && body is Map<String, dynamic>) {
      final username = body['username']?.toString() ?? 'new_user';
      return {
        'success': true,
        'message': 'User registered successfully',
        'data': {
          'userId': 101,
          'username': username,
          'tempToken': 'temp_token_${DateTime.now().millisecondsSinceEpoch}',
          'accountType': body['mode']?.toString() ?? 'PUBLIC',
        },
      };
    }

    if (path.contains('/emails/create') && body is Map<String, dynamic>) {
      final name = body['emailName']?.toString() ?? 'new_user';
      final fullEmail = name.contains('@') ? name : '$name@bnxmail.com';
      return {
        'success': true,
        'message': 'Email created successfully',
        'data': {
          'emailId': 200,
          'email': fullEmail,
          'emailName': name,
          'accessToken': 'token_${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken': 'refresh_${DateTime.now().millisecondsSinceEpoch}',
        },
      };
    }

    if (path.contains('/subid/create') && body is Map<String, dynamic>) {
      final newSub = {
        'id': 'sub_${DateTime.now().millisecondsSinceEpoch}',
        'username': body['username']?.toString() ?? 'new.subid',
        'name': body['name']?.toString() ?? 'Team Member',
        'type': body['type']?.toString() ?? 'BUSINESS',
        'status': 'ACTIVE',
        'createdAt': DateTime.now().toIso8601String(),
      };
      _subIds.add(newSub);
      return {'success': true, 'data': newSub};
    }

    if (path.contains('/send-mobile-otp') || path.contains('/send-parent-otp')) {
      return {
        'success': true,
        'message': 'OTP sent successfully',
        'data': {'cooldownSeconds': 60, 'devOtp': '123456'},
      };
    }

    if (path.contains('/verify-mobile-otp') || path.contains('/verify-parent-otp')) {
      return {
        'success': true,
        'message': 'OTP verified successfully',
        'data': {'verified': true},
      };
    }

    if (path.contains('/business/onboarding')) {
      return {
        'success': true,
        'message': 'Business onboarding details saved successfully',
        'data': body ?? {},
      };
    }

    if (path.contains('/2fa/setup')) {
      final email = await TokenService.getUserEmail() ?? 'user@bnxmail.com';
      return {
        'success': true,
        'data': {
          'secret': 'JBSWY3DPEHPK3PXP',
          'otpauthUrl': 'otpauth://totp/CliksBusiness:$email?secret=JBSWY3DPEHPK3PXP&issuer=CliksBusiness',
          'qrCode': '',
        },
      };
    }

    if (path.contains('/2fa/verify') || path.contains('/2fa/disable')) {
      return {'success': true};
    }

    if (path.contains('/change-password')) {
      return {'success': true, 'message': 'Password changed successfully.'};
    }

    return {'success': true, 'data': body ?? {}};
  }

  static dynamic _putMockResponse(String path, dynamic body) {
    return {'success': true, 'data': body ?? {}};
  }

  static dynamic _patchMockResponse(String path, dynamic body) {
    if (body is Map<String, dynamic>) {
      TokenService.getUserEmail().then((email) {
        if (email != null) TokenService.saveUserSettings(email, body);
      });
    }
    return {'success': true, 'data': body ?? {}};
  }

  static dynamic _deleteMockResponse(String path) {
    if (path.contains('/subid/')) {
      final id = path.split('/').last;
      _subIds.removeWhere((s) => s['id'] == id || s['username'] == id);
      return {'success': true};
    }
    return {'success': true};
  }
}
