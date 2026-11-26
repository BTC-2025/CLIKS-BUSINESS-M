import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/token_service.dart';
import '../account_provider.dart';

/// Model representing mailbox storage quota from GET /api/mail/storage-quota
class StorageQuota {
  final String email;
  final int storageLimit;
  final int storageUsed;
  final double storagePercentage;

  const StorageQuota({
    required this.email,
    required this.storageLimit,
    required this.storageUsed,
    required this.storagePercentage,
  });

  // Getters for compatibility
  int get storageLimitBytes => storageLimit;
  int get storageUsedBytes => storageUsed;

  factory StorageQuota.fromJson(Map<String, dynamic> json) {
    int limit = 5368709120; // 5 GB default
    final limitRaw = json['storageLimit'];
    if (limitRaw is num) {
      limit = limitRaw.toInt();
    } else if (limitRaw != null) {
      limit = int.tryParse(limitRaw.toString()) ??
          (double.tryParse(limitRaw.toString())?.toInt() ?? 5368709120);
    }

    int used = 0;
    final usedRaw = json['storageUsed'];
    if (usedRaw is num) {
      used = usedRaw.toInt();
    } else if (usedRaw != null) {
      used = int.tryParse(usedRaw.toString()) ??
          (double.tryParse(usedRaw.toString())?.toInt() ?? 0);
    }

    double pct;
    final pctRaw = json['storagePercentage'];
    if (pctRaw is num) {
      pct = pctRaw.toDouble();
    } else if (pctRaw != null) {
      pct = double.tryParse(pctRaw.toString()) ??
          (limit > 0 ? ((used / limit) * 100) : 0.0);
    } else {
      pct = limit > 0 ? ((used / limit) * 100) : 0.0;
    }

    // Clamp between 0.0 and 100.0, protect against NaN / Infinity / negative.
    if (pct.isNaN || pct.isInfinite || pct < 0.0) {
      pct = 0.0;
    } else if (pct > 100.0) {
      pct = 100.0;
    }

    return StorageQuota(
      email: json['email']?.toString() ?? '',
      storageLimit: limit,
      storageUsed: used,
      storagePercentage: pct,
    );
  }

  static String formatBytes(int bytes) {
    if (bytes >= 1073741824) {
      final gb = bytes / 1073741824;
      return gb == gb.roundToDouble()
          ? '${gb.toInt()} GB'
          : '${gb.toStringAsFixed(2)} GB';
    } else if (bytes >= 1048576) {
      final mb = bytes / 1048576;
      return mb == mb.roundToDouble()
          ? '${mb.toInt()} MB'
          : '${mb.toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      final kb = bytes / 1024;
      return kb == kb.roundToDouble()
          ? '${kb.toInt()} KB'
          : '${kb.toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }

  String get usedFormatted => formatBytes(storageUsed);
  String get limitFormatted => formatBytes(storageLimit);
  int get availableBytes => math.max(0, storageLimit - storageUsed);
  String get availableFormatted => formatBytes(availableBytes);

  double get fraction => (storagePercentage / 100.0).clamp(0.0, 1.0);
  double get progress => fraction;

  String get percentageFormatted {
    if (storagePercentage <= 0) return '0%';
    if (storagePercentage < 0.01) {
      return '${storagePercentage.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}%';
    }
    return '${storagePercentage.toStringAsFixed(2)}%';
  }

  String get status {
    if (storagePercentage < 70.0) return 'Normal';
    if (storagePercentage < 85.0) return 'Warning';
    if (storagePercentage < 95.0) return 'High';
    return 'Critical';
  }

  Color get statusColor {
    if (storagePercentage < 70.0) return const Color(0xFF10B981);
    if (storagePercentage < 85.0) return const Color(0xFFF59E0B);
    if (storagePercentage < 95.0) return const Color(0xFFEA580C);
    return const Color(0xFFEF4444);
  }

  String get statusDescription {
    if (storagePercentage < 70.0) {
      return 'STORAGE HEALTHY.\nWITHIN ALLOCATED QUOTA.';
    } else if (storagePercentage < 85.0) {
      return 'STORAGE USAGE ELEVATED.\nMONITOR CAPACITY.';
    } else if (storagePercentage < 95.0) {
      return 'STORAGE RUNNING LOW.\nCLEANUP RECOMMENDED.';
    } else {
      return 'STORAGE CRITICALLY FULL.\nACTION REQUIRED.';
    }
  }
}

/// Typedef for backwards compatibility
typedef StorageQuotaModel = StorageQuota;

class StorageDebug {
  static final List<String> logs = [];
  static void log(String s) {
    logs.add(s);
    print(s);
  }
}

/// Repository for handling real-time storage quota APIs.
class StorageRepository {
  static final Map<String, Future<StorageQuota>> _inFlightRequests = {};
  static final Map<String, StorageQuota> _cachedQuotas = {};

  /// Backward-compatibility getter for cached quota
  static StorageQuota? get cachedQuota =>
      _cachedQuotas.isNotEmpty ? _cachedQuotas.values.last : null;

  /// Returns cached quota for a specific email
  static StorageQuota? getCachedQuota(String? email) {
    if (email == null || email.trim().isEmpty) return null;
    final clean = email.trim().toLowerCase();
    if (_cachedQuotas.containsKey(clean)) {
      return _cachedQuotas[clean];
    }
    // Check synchronous settings fallback
    final settings = TokenService.getUserSettingsSync(clean);
    if (settings != null) {
      final used = settings['storageUsed'] is num
          ? (settings['storageUsed'] as num).toInt()
          : 0;
      final limit = settings['storageLimit'] is num
          ? (settings['storageLimit'] as num).toInt()
          : 5368709120;
      final pct = limit > 0 ? (used / limit * 100) : 0.0;
      final fallback = StorageQuota(
        email: clean,
        storageLimit: limit,
        storageUsed: used,
        storagePercentage: pct,
      );
      _cachedQuotas[clean] = fallback;
      return fallback;
    }
    return null;
  }

  /// Resets in-flight request guard and cache (used on account switch).
  static void resetInFlight([String? email]) {
    if (email != null && email.trim().isNotEmpty) {
      final clean = email.trim().toLowerCase();
      _inFlightRequests.remove(clean);
      _cachedQuotas.remove(clean);
    } else {
      _inFlightRequests.clear();
      _cachedQuotas.clear();
    }
  }

  /// Fetches real-time mailbox quota from GET /api/mail/storage-quota
  /// Deduplicates concurrent requests per email so only one HTTP request is active per account.
  static Future<StorageQuota> fetchStorageQuota([String? targetEmail]) async {
    final email = (targetEmail != null && targetEmail.trim().isNotEmpty)
        ? targetEmail.trim().toLowerCase()
        : (await TokenService.getUserEmail() ?? '').trim().toLowerCase();

    if (_inFlightRequests.containsKey(email)) {
      StorageDebug.log('[STORAGE] Duplicate request prevented for $email');
      return _inFlightRequests[email]!;
    }

    final future = _performFetch(email);
    _inFlightRequests[email] = future;
    try {
      final result = await future;
      _cachedQuotas[email] = result;
      return result;
    } finally {
      _inFlightRequests.remove(email);
    }
  }

  static Future<StorageQuota> _performFetch(String email) async {
    StorageDebug.log('[STORAGE] Fetching storage quota for $email...');
    final token = await TokenService.getTokenForAccount(email);
    try {
      final res = await ApiClient.get(
        '/api/mail/storage-quota',
        queryParams: email.isNotEmpty ? {'email': email} : null,
        tempToken: token,
      );
      Map<String, dynamic>? dataMap;

      if (res is Map) {
        if (res['data'] is Map) {
          dataMap = Map<String, dynamic>.from(res['data'] as Map);
        } else if (res['storageLimit'] != null) {
          dataMap = Map<String, dynamic>.from(res);
        }
      }

      if (dataMap == null || dataMap['storageLimit'] == null) {
        // Fallback to user settings
        return await _buildFallbackQuota(email);
      }

      final quota = StorageQuota.fromJson(dataMap);
      final resolvedQuota = StorageQuota(
        email: email.isNotEmpty ? email : quota.email,
        storageLimit: quota.storageLimit,
        storageUsed: quota.storageUsed,
        storagePercentage: quota.storagePercentage,
      );

      _cachedQuotas[email] = resolvedQuota;
      StorageDebug.log('[STORAGE] Quota loaded for $email');
      StorageDebug.log('[STORAGE] Email: ${resolvedQuota.email}');
      StorageDebug.log('[STORAGE] Used: ${resolvedQuota.storageUsed} bytes');
      StorageDebug.log('[STORAGE] Limit: ${resolvedQuota.storageLimit} bytes');
      StorageDebug.log('[STORAGE] Percentage: ${resolvedQuota.storagePercentage}%');
      return resolvedQuota;
    } catch (e) {
      StorageDebug.log('[STORAGE ERROR] Failed to fetch storage quota for $email: $e');
      if (_cachedQuotas.containsKey(email)) {
        return _cachedQuotas[email]!;
      }
      return await _buildFallbackQuota(email);
    }
  }

  static Future<StorageQuota> _buildFallbackQuota(String email) async {
    final settings =
        email.isNotEmpty ? await TokenService.getUserSettings(email) : null;
    final used = settings?['storageUsed'] is num
        ? (settings!['storageUsed'] as num).toInt()
        : 0;
    final limit = settings?['storageLimit'] is num
        ? (settings!['storageLimit'] as num).toInt()
        : 5368709120; // 5 GB default
    final pct = limit > 0 ? (used / limit * 100) : 0.0;
    final fallback = StorageQuota(
      email: email,
      storageLimit: limit,
      storageUsed: used,
      storagePercentage: pct,
    );
    if (email.isNotEmpty) {
      _cachedQuotas[email] = fallback;
    }
    return fallback;
  }

  /// Backward compatibility alias
  static Future<StorageQuota> getStorageQuota([String? targetEmail]) =>
      fetchStorageQuota(targetEmail);
}

/// Global Riverpod Provider for real-time Storage Quota scoped to active account
final storageQuotaProvider = FutureProvider<StorageQuota>((ref) async {
  final activeAccount = ref.watch(activeAccountProvider);
  final email = activeAccount.email.trim().toLowerCase();
  return StorageRepository.fetchStorageQuota(email);
});
