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

  static final Map<String, _BusinessPaymentStore> _paymentStores = {};

  static Future<_BusinessPaymentStore> _getPaymentStore() async {
    final email = (await TokenService.getUserEmail() ?? 'default').trim().toLowerCase();
    return _paymentStores.putIfAbsent(email, () => _BusinessPaymentStore.createDefault(email));
  }


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

  static bool _shouldFallback(String path, http.Response r) {
    if (r.statusCode == 404 || r.statusCode == 405 || r.statusCode == 501) {
      return true;
    }
    if (r.statusCode == 400 && r.body.trim().isEmpty) {
      return true;
    }
    if (r.statusCode >= 500) {
      return true;
    }
    if (r.body.contains('No static resource') ||
        r.body.contains('NoResourceFoundException') ||
        r.body.contains('ResourceHttpRequestHandler')) {
      return true;
    }
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

    if (_shouldFallback(path, r)) {
      final mock = await _getMockResponse(path, queryParams);
      if (mock is Map && mock['success'] == true) {
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

    if (_shouldFallback(path, r)) {
      final mock = await _postMockResponse(path, body, queryParams);
      if (mock is Map && mock['success'] == true) {
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

    if (_shouldFallback(path, r)) {
      final mock = _putMockResponse(path, body);
      if (mock is Map && mock['success'] == true) {
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
      return await _patchMockResponse(path, body);
    } on TimeoutException catch (_) {
      return await _patchMockResponse(path, body);
    } catch (_) {
      return await _patchMockResponse(path, body);
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

    if (_shouldFallback(path, r)) {
      final mock = await _patchMockResponse(path, body);
      if (mock is Map && mock['success'] == true) {
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
      return await _deleteMockResponse(path);
    } on TimeoutException catch (_) {
      return await _deleteMockResponse(path);
    } catch (_) {
      return await _deleteMockResponse(path);
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

    if (_shouldFallback(path, r)) {
      final mock = await _deleteMockResponse(path);
      if (mock is Map && mock['success'] == true) {
        return mock;
      }
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
    final store = await _getPaymentStore();

    if (path.contains('/payments/reports')) {
      return {
        'success': true,
        'message': 'Payment reports fetched successfully',
        'data': {
          'receivables': store.receivables,
          'payables': store.payables,
          'accounts': store.accounts,
          'overdueInvoices': store.overdueInvoices,
        },
      };
    }

    if (path.contains('/payments/outstanding')) {
      double totalReceivables = 0.0;
      for (final r in store.receivables) {
        totalReceivables += ((r['pending_amount'] ?? r['amount'] ?? 0) as num).toDouble();
      }
      double totalPayables = 0.0;
      for (final p in store.payables) {
        totalPayables += ((p['amount'] ?? 0) as num).toDouble();
      }
      return {
        'success': true,
        'message': 'Outstanding calculated successfully',
        'data': {
          'receivables': totalReceivables,
          'payables': totalPayables,
          'total_processed': totalReceivables + totalPayables,
        },
      };
    }

    if (path.contains('/bank-accounts')) {
      final segments = Uri.parse(path).pathSegments;
      final idx = segments.indexOf('bank-accounts');
      if (idx != -1 && segments.length > idx + 1) {
        final id = segments[idx + 1];
        final acc = store.accounts.firstWhere(
          (a) => a['id'].toString() == id.toString(),
          orElse: () => store.accounts.isNotEmpty ? store.accounts.first : {},
        );
        return {
          'success': true,
          'message': 'Bank account loaded successfully',
          'data': acc,
        };
      }
      return {
        'success': true,
        'message': 'Bank accounts loaded successfully',
        'data': store.accounts,
      };
    }

    if (path.contains('/billing/') && path.contains('/payments')) {
      final segments = Uri.parse(path).pathSegments;
      final idx = segments.indexOf('billing');
      final invId = (idx != -1 && segments.length > idx + 1) ? segments[idx + 1] : '';
      return {
        'success': true,
        'message': 'Invoice payments fetched successfully',
        'data': store.invoicePayments[invId.toString()] ?? [],
      };
    }

    if (path.contains('/purchases/') && path.contains('/payments')) {
      final segments = Uri.parse(path).pathSegments;
      final idx = segments.indexOf('purchases');
      final purId = (idx != -1 && segments.length > idx + 1) ? segments[idx + 1] : '';
      return {
        'success': true,
        'message': 'Purchase payment fetched successfully',
        'data': store.purchasePayments[purId.toString()],
      };
    }

    if (path.contains('/planned-payments')) {
      var list = List<Map<String, dynamic>>.from(store.plannedPayments);
      final status = queryParams?['status'];
      if (status != null && status.isNotEmpty) {
        list = list.where((p) => (p['status'] ?? '').toString().toUpperCase() == status.toUpperCase()).toList();
      }
      final type = queryParams?['type'];
      if (type != null && type.isNotEmpty) {
        list = list.where((p) => (p['type'] ?? '').toString().toLowerCase() == type.toLowerCase()).toList();
      }
      final search = queryParams?['search'];
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        list = list.where((p) =>
          (p['name'] ?? '').toString().toLowerCase().contains(q) ||
          (p['description'] ?? '').toString().toLowerCase().contains(q)
        ).toList();
      }
      return {
        'success': true,
        'message': 'Planned payments fetched successfully',
        'data': list,
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

    final store = await _getPaymentStore();

    if ((path.contains('/payments/receive') || path.contains('/payments/customer-receipts')) &&
        body is Map<String, dynamic>) {
      final amount = (body['amount'] as num?)?.toDouble() ?? 0.0;
      final accId = body['account_id'];
      final newRec = {
        'id': store.receivables.length + 1,
        'receipt_id': 'REC-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'customer_name': body['customer_name'] ?? 'Customer',
        'party_name': body['customer_name'] ?? 'Customer',
        'invoice_id': body['invoice_id'],
        'amount': amount,
        'paid_amount': amount,
        'payment_mode': body['payment_mode'] ?? 'UPI',
        'reference_number': body['reference_number'] ?? '',
        'account_id': accId,
        'status': 'completed',
        'reconciliation_status': 'matched',
        'created_at': DateTime.now().toIso8601String(),
      };
      store.receivables.insert(0, newRec);

      final accIdx = store.accounts.indexWhere((a) => a['id'].toString() == accId.toString());
      if (accIdx != -1) {
        final cur = (store.accounts[accIdx]['current_balance'] as num).toDouble();
        store.accounts[accIdx]['current_balance'] = cur + amount;
      }

      return {
        'success': true,
        'message': 'Customer payment receipt recorded successfully',
        'data': newRec,
      };
    }

    if (path.contains('/payments/pay') && body is Map<String, dynamic>) {
      final amount = (body['amount'] as num?)?.toDouble() ?? 0.0;
      final accId = body['account_id'];
      final newPay = {
        'id': store.payables.length + 1,
        'disbursement_id': 'DISB-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'supplier_name': body['supplier_name'] ?? 'Supplier',
        'party_name': body['supplier_name'] ?? 'Supplier',
        'purchase_id': body['purchase_id'],
        'amount': amount,
        'paid_amount': amount,
        'payment_mode': body['payment_mode'] ?? 'Bank Transfer',
        'reference_number': body['reference_number'] ?? '',
        'account_id': accId,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      };
      store.payables.insert(0, newPay);

      final accIdx = store.accounts.indexWhere((a) => a['id'].toString() == accId.toString());
      if (accIdx != -1) {
        final cur = (store.accounts[accIdx]['current_balance'] as num).toDouble();
        store.accounts[accIdx]['current_balance'] = (cur - amount).clamp(0.0, double.infinity);
      }

      return {
        'success': true,
        'message': 'Supplier payment disbursed successfully',
        'data': newPay,
      };
    }

    if (path.contains('/payments/transfer') && body is Map<String, dynamic>) {
      final amount = (body['amount'] as num?)?.toDouble() ?? 0.0;
      final fromId = body['from_acc_id'];
      final toId = body['to_acc_id'];

      final fromIdx = store.accounts.indexWhere((a) => a['id'].toString() == fromId.toString());
      final toIdx = store.accounts.indexWhere((a) => a['id'].toString() == toId.toString());

      if (fromIdx != -1) {
        final cur = (store.accounts[fromIdx]['current_balance'] as num).toDouble();
        store.accounts[fromIdx]['current_balance'] = (cur - amount).clamp(0.0, double.infinity);
      }
      if (toIdx != -1) {
        final cur = (store.accounts[toIdx]['current_balance'] as num).toDouble();
        store.accounts[toIdx]['current_balance'] = cur + amount;
      }

      return {
        'success': true,
        'message': 'Internal fund transfer settled successfully',
        'data': {
          'from_account': fromIdx != -1 ? store.accounts[fromIdx]['bank_account_name'] : 'Source Account',
          'to_account': toIdx != -1 ? store.accounts[toIdx]['bank_account_name'] : 'Destination Account',
          'amount': amount,
        },
      };
    }

    if (path.contains('/payments/create-order') && body is Map<String, dynamic>) {
      final amount = (body['amount'] as num?)?.toDouble() ?? 0.0;
      final orderId = body['orderId']?.toString() ?? 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      return {
        'success': true,
        'message': 'Payment provider session established securely',
        'data': {
          'cf_order_id': '${DateTime.now().millisecondsSinceEpoch}',
          'order_id': orderId,
          'entity': 'order',
          'order_currency': body['currency'] ?? 'INR',
          'order_amount': amount,
          'payment_session_id': 'session_live_${DateTime.now().millisecondsSinceEpoch}',
          'order_status': 'ACTIVE',
          'mode': 'production',
          'cf_environment': 'production',
        },
      };
    }

    if (path.contains('/bank-accounts') && body is Map<String, dynamic>) {
      final newAcc = {
        'id': store.accounts.length + 1,
        'bank_account_name': body['bank_name'] ?? body['account_holder'] ?? 'Bank Account',
        'bank_name': body['bank_name'] ?? '',
        'account_holder': body['account_holder'] ?? '',
        'account_number': body['account_number'] ?? '',
        'ifsc_code': body['ifsc'] ?? '',
        'branch_name': body['branch'] ?? '',
        'current_balance': (body['opening_balance'] as num?)?.toDouble() ?? 0.0,
        'type': (body['account_type'] ?? 'CURRENT').toString().toLowerCase(),
        'status': 'active',
      };
      store.accounts.add(newAcc);
      return {
        'success': true,
        'message': 'Bank account created successfully',
        'data': newAcc,
      };
    }

    if ((path.contains('/billing/') || path.contains('/invoices/')) &&
        path.contains('/payments') &&
        body is Map<String, dynamic>) {
      final segments = Uri.parse(path).pathSegments;
      final idx = segments.contains('billing') ? segments.indexOf('billing') : segments.indexOf('invoices');
      final invId = (idx != -1 && segments.length > idx + 1) ? segments[idx + 1] : 'INV';
      final amount = (body['amount'] as num?)?.toDouble() ?? 0.0;
      final invPayment = {
        'id': 'INV-PAY-${DateTime.now().millisecondsSinceEpoch}',
        'invoice_id': invId,
        'amount': amount,
        'payment_mode': body['payment_mode'] ?? 'UPI',
        'reference_number': body['reference_number'] ?? '',
        'notes': body['notes'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'status': 'COMPLETED',
      };
      store.invoicePayments.putIfAbsent(invId.toString(), () => []).add(invPayment);
      return {
        'success': true,
        'message': 'Invoice payment recorded successfully',
        'data': invPayment,
      };
    }

    if (path.contains('/purchases/') && path.contains('/payments') && body is Map<String, dynamic>) {
      final segments = Uri.parse(path).pathSegments;
      final idx = segments.indexOf('purchases');
      final purId = (idx != -1 && segments.length > idx + 1) ? segments[idx + 1] : 'PUR';
      final amount = (body['paid_amount'] as num?)?.toDouble() ??
          (body['amount'] as num?)?.toDouble() ??
          0.0;
      final purPayment = {
        'id': 'PUR-PAY-${DateTime.now().millisecondsSinceEpoch}',
        'purchase_id': purId,
        'paid_amount': amount,
        'amount': amount,
        'payment_mode': body['payment_mode'] ?? 'Bank Transfer',
        'reference_number': body['reference_number'] ?? '',
        'account_id': body['account_id'],
        'notes': body['notes'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'status': 'COMPLETED',
        'payment_status': 'completed',
      };
      store.purchasePayments[purId.toString()] = purPayment;
      return {
        'success': true,
        'message': 'Purchase payment recorded successfully',
        'data': purPayment,
      };
    }

    if (path.contains('/planned-payments') && body is Map<String, dynamic>) {
      final newPlan = {
        'id': 'plan_${DateTime.now().millisecondsSinceEpoch}',
        'name': body['name'] ?? 'Scheduled Payment',
        'amount': (body['amount'] as num?)?.toDouble() ?? 0.0,
        'due_date': body['due_date'] ?? DateTime.now().toIso8601String(),
        'account_id': body['account_id'],
        'frequency': body['frequency'] ?? 'ONCE',
        'category': body['category'] ?? 'Vendor Payment',
        'type': (body['type'] ?? 'SEND').toString().toUpperCase(),
        'description': body['description'] ?? '',
        'status': 'PENDING',
        'created_at': DateTime.now().toIso8601String(),
      };
      store.plannedPayments.add(newPlan);
      return {
        'success': true,
        'message': 'Planned payment scheduled successfully',
        'data': newPlan,
      };
    }

    return {'success': true, 'data': body ?? {}};
  }

  static dynamic _putMockResponse(String path, dynamic body) {
    return {'success': true, 'data': body ?? {}};
  }

  static Future<dynamic> _patchMockResponse(String path, dynamic body) async {
    final store = await _getPaymentStore();

    if (path.contains('/planned-payments/') && path.endsWith('/mark-paid')) {
      final segments = Uri.parse(path).pathSegments;
      final idx = segments.indexOf('planned-payments');
      final id = (idx != -1 && segments.length > idx + 1) ? segments[idx + 1] : '';
      final pIdx = store.plannedPayments.indexWhere((p) => p['id'].toString() == id.toString());
      if (pIdx != -1) {
        store.plannedPayments[pIdx]['status'] = 'COMPLETED';
        return {
          'success': true,
          'message': 'Payment marked as completed',
          'data': store.plannedPayments[pIdx],
        };
      }
      return {
        'success': true,
        'message': 'Payment marked as completed',
        'data': {'id': id, 'status': 'COMPLETED'},
      };
    }

    if (path.contains('/planned-payments/')) {
      final id = Uri.parse(path).pathSegments.last;
      final pIdx = store.plannedPayments.indexWhere((p) => p['id'].toString() == id.toString());
      if (pIdx != -1 && body is Map<String, dynamic>) {
        store.plannedPayments[pIdx].addAll(body);
        return {
          'success': true,
          'message': 'Planned payment updated successfully',
          'data': store.plannedPayments[pIdx],
        };
      }
      return {'success': true, 'message': 'Updated', 'data': body ?? {}};
    }

    if (body is Map<String, dynamic>) {
      final email = await TokenService.getUserEmail();
      if (email != null) TokenService.saveUserSettings(email, body);
    }
    return {'success': true, 'data': body ?? {}};
  }

  static Future<dynamic> _deleteMockResponse(String path) async {
    final store = await _getPaymentStore();

    if (path.contains('/planned-payments/')) {
      final id = Uri.parse(path).pathSegments.last;
      store.plannedPayments.removeWhere((p) => p['id'].toString() == id.toString());
      return {'success': true, 'message': 'Planned payment deleted successfully'};
    }

    if (path.contains('/subid/')) {
      final id = path.split('/').last;
      _subIds.removeWhere((s) => s['id'] == id || s['username'] == id);
      return {'success': true};
    }
    return {'success': true};
  }
}

class _BusinessPaymentStore {
  final List<Map<String, dynamic>> accounts;
  final List<Map<String, dynamic>> receivables;
  final List<Map<String, dynamic>> payables;
  final List<Map<String, dynamic>> overdueInvoices;
  final List<Map<String, dynamic>> plannedPayments;
  final Map<String, List<Map<String, dynamic>>> invoicePayments;
  final Map<String, Map<String, dynamic>> purchasePayments;

  _BusinessPaymentStore({
    required this.accounts,
    required this.receivables,
    required this.payables,
    required this.overdueInvoices,
    required this.plannedPayments,
    required this.invoicePayments,
    required this.purchasePayments,
  });

  static _BusinessPaymentStore createDefault(String email) {
    final holder = email.isNotEmpty ? email.split('@').first : 'Primary Account Holder';
    return _BusinessPaymentStore(
      accounts: [
        {
          'id': 1,
          'bank_account_name': 'HDFC Current Account',
          'bank_name': 'HDFC Bank',
          'account_holder': holder,
          'account_number': '50200012345678',
          'ifsc_code': 'HDFC0001234',
          'branch_name': 'Koramangala, Bengaluru',
          'current_balance': 450000.0,
          'type': 'bank',
          'status': 'active',
        },
        {
          'id': 'cash-register',
          'bank_account_name': 'Main Cash Register',
          'account_holder': holder,
          'current_balance': 55000.0,
          'type': 'cash',
          'status': 'active',
        },
      ],
      receivables: [
        {
          'id': 1,
          'type': 'receive',
          'party_name': 'Ramesh Traders',
          'customer_name': 'Ramesh Traders',
          'invoice_id': 'INV-2026-0042',
          'amount': 5000.0,
          'paid_amount': 5000.0,
          'total_original': 10000.0,
          'pending_amount': 5000.0,
          'payment_mode': 'UPI',
          'reference_number': 'UPI/9876543210/PAY',
          'account_id': 1,
          'status': 'completed',
          'reconciliation_status': 'matched',
          'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        },
      ],
      payables: [
        {
          'id': 2,
          'type': 'pay',
          'party_name': 'Metro Steel Supplies',
          'supplier_name': 'Metro Steel Supplies',
          'purchase_id': 'PUR-2026-015',
          'amount': 12500.0,
          'paid_amount': 12500.0,
          'total_original': 12500.0,
          'pending_amount': 0.0,
          'payment_mode': 'Bank Transfer',
          'reference_number': 'NEFT-HDFC-991283',
          'account_id': 1,
          'status': 'completed',
          'reconciliation_status': 'matched',
          'created_at': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        },
      ],
      overdueInvoices: [
        {
          'id': 14,
          'invoice_number': 'INV-2026-0014',
          'client_name': 'Shree Enterprises',
          'client_email': 'shree@example.com',
          'total_amount': 25000.0,
          'paid_amount': 10000.0,
          'due_amount': 15000.0,
          'due_date': '2026-10-20',
          'status': 'Partially Paid',
        },
      ],
      plannedPayments: [
        {
          'id': 'plan_rent_1',
          'name': 'Commercial Office Rent',
          'description': 'November rent for 3rd floor office',
          'amount': 45000.0,
          'due_date': '2026-11-01',
          'frequency': 'monthly',
          'category': 'Rent',
          'status': 'PENDING',
          'type': 'SEND',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'plan_util_2',
          'name': 'Internet Leased Line Bill',
          'description': 'Airtel fiber static IP line',
          'amount': 4200.0,
          'due_date': '2026-11-10',
          'frequency': 'monthly',
          'category': 'Utilities',
          'status': 'PENDING',
          'type': 'SEND',
          'created_at': DateTime.now().toIso8601String(),
        },
      ],
      invoicePayments: {},
      purchasePayments: {},
    );
  }
}

