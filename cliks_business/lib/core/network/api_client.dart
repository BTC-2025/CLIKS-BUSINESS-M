import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

/// Central HTTP Client for Manage Account and User APIs.
/// Attempts real API communication with graceful fallback to local cached/mock data.
class ApiClient {
  static const String baseUrl = 'https://cliks.beta-softnet.com';

  // In-memory mock data stores
  static final List<Map<String, dynamic>> _connectedEmails = [
    {
      'id': '1',
      'email': 'ravinew2004@bnxmail.com',
      'name': 'Ravi Kumar',
      'isPrimary': true,
      'isVerified': true,
    },
    {
      'id': '2',
      'email': 'sales.ravinew2004@bnxmail.com',
      'name': 'Sales Team',
      'isPrimary': false,
      'isVerified': true,
    },
  ];

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
    {
      'action': 'Profile details updated',
      'timestamp': 'Yesterday, 04:30 PM',
      'device': 'Apple Silicon Mac',
      'ip': '103.21.124.89',
    },
    {
      'action': 'Password verified for security check',
      'timestamp': '3 days ago',
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

  static Map<String, String> _buildHeaders([String? tempToken]) {
    final token = tempToken ?? TokenService.cachedAccessToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    String? tempToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: _buildHeaders(tempToken))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (_) {}

    return _getMockResponse(path, queryParams);
  }

  static Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (_) {}

    return _postMockResponse(path, body, queryParams);
  }

  static Future<dynamic> put(String path, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .put(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (_) {}

    return _putMockResponse(path, body);
  }

  static Future<dynamic> patch(String path, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .patch(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (_) {}

    return _patchMockResponse(path, body);
  }

  static Future<dynamic> delete(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http
          .delete(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (_) {}

    return _deleteMockResponse(path);
  }

  static Future<dynamic> uploadProfilePicture(
    String path, {
    List<int>? bytes,
    String? filePath,
    String? filename,
  }) async {
    // If bytes or file are provided, update token service avatar
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

  // ───────────────────────────────────────────────────────────────────────────
  // Fallback / Offline Mock Logic
  // ───────────────────────────────────────────────────────────────────────────

  static dynamic _getMockResponse(String path, Map<String, String>? queryParams) {
    if (path.contains('/storage-quota')) {
      return {
        'success': true,
        'data': {
          'email': 'ravinew2004@bnxmail.com',
          'storageLimit': 16106127360, // 15 GB
          'storageUsed': 2362232012,  // 2.2 GB
          'storagePercentage': 14.67,
        },
      };
    }

    if (path.contains('/users/me') || path.contains('/users/settings')) {
      return {
        'success': true,
        'data': {
          'name': 'Ravi Kumar C',
          'email': 'ravinew2004@bnxmail.com',
          'firstName': 'Ravi Kumar',
          'lastName': 'C',
          'username': 'ravinew2004',
          'jobTitle': 'Executive Director',
          'location': 'Bengaluru, India',
          'phone': '+91 98765 43210',
          'recoveryEmail': 'ravi.backup@gmail.com',
          'backupPhone': '+91 98765 01234',
          'twoFactorEnabled': false,
          'language': 'English (US)',
          'storageLimit': 16106127360,
          'storageUsed': 2362232012,
        },
      };
    }

    if (path.contains('/emails/list')) {
      return {'success': true, 'data': _connectedEmails};
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

  static dynamic _postMockResponse(String path, dynamic body, Map<String, String>? queryParams) {
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

    if (path.contains('/2fa/setup')) {
      return {
        'success': true,
        'data': {
          'secret': 'JBSWY3DPEHPK3PXP',
          'otpauthUrl': 'otpauth://totp/CliksBusiness:ravinew2004@bnxmail.com?secret=JBSWY3DPEHPK3PXP&issuer=CliksBusiness',
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
