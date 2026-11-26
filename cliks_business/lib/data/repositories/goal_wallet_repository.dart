import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/goal_wallet_models.dart';

/// Central repository for Payments -> Segregation / Purpose Wallets.
/// Directly interacts with backend route prefix `/api/v1/goal-wallets/*`.
class GoalWalletRepository {
  /// 3.1 List All Goal Wallets
  /// Endpoint: `GET /api/v1/goal-wallets`
  static Future<List<GoalWallet>> getGoalWallets({String? email}) async {
    final res = await ApiClient.get('/api/v1/goal-wallets', email: email);
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['status'] == 'error' || map['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message:
              map['message']?.toString() ??
              map['error']?['message']?.toString() ??
              'Failed to retrieve goal wallets',
        );
      }
      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => GoalWallet.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => GoalWallet.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// 3.2 Create Goal Wallet
  /// Endpoint: `POST /api/v1/goal-wallets`
  static Future<GoalWallet> createGoalWallet(
    CreateGoalWalletRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/goal-wallets',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['status'] == 'error' || map['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message:
              map['message']?.toString() ??
              map['error']?['message']?.toString() ??
              'Failed to create goal wallet',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return GoalWallet.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from goal wallet creation',
    );
  }

  /// 3.3 Get Goal Wallet Details
  /// Endpoint: `GET /api/v1/goal-wallets/:id`
  static Future<GoalWallet?> getGoalWalletDetails(
    dynamic id, {
    String? email,
  }) async {
    try {
      final res = await ApiClient.get('/api/v1/goal-wallets/$id', email: email);
      if (res is Map) {
        final map = Map<String, dynamic>.from(res);
        final data = map['data'];
        if (data is Map && data.isNotEmpty) {
          return GoalWallet.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      // Fallback: search in list if direct GET returned error
      final list = await getGoalWallets(email: email);
      try {
        return list.firstWhere((w) => w.id == id.toString());
      } catch (_) {
        rethrow;
      }
    }
    return null;
  }

  /// 3.4 Update Goal Wallet
  /// Endpoint: `PATCH /api/v1/goal-wallets/:id`
  static Future<GoalWallet> updateGoalWallet(
    dynamic id,
    UpdateGoalWalletRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.patch(
      '/api/v1/goal-wallets/$id',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['status'] == 'error' || map['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message:
              map['message']?.toString() ??
              map['error']?['message']?.toString() ??
              'Failed to update goal wallet',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return GoalWallet.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from goal wallet update',
    );
  }

  /// 3.5 Add Money / Isolate Funds
  /// Endpoint: `POST /api/v1/goal-wallets/:id/add-money`
  static Future<GoalWallet> addMoney(
    dynamic id,
    AddMoneyGoalWalletRequest req, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/goal-wallets/$id/add-money',
      body: req.toJson(),
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['status'] == 'error' || map['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message:
              map['message']?.toString() ??
              map['error']?['message']?.toString() ??
              'Failed to add money to goal wallet',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return GoalWallet.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from add money operation',
    );
  }

  /// 3.6 Claim / Release Segregated Vault Funds
  /// Endpoint: `POST /api/v1/goal-wallets/:id/claim`
  static Future<Map<String, dynamic>> claimGoalWallet(
    dynamic id, {
    String? email,
  }) async {
    final res = await ApiClient.post(
      '/api/v1/goal-wallets/$id/claim',
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['status'] == 'error' || map['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message:
              map['message']?.toString() ??
              map['error']?['message']?.toString() ??
              'Failed to claim goal wallet',
        );
      }
      final data = map['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return map;
    }
    throw ApiException(
      statusCode: 500,
      message: 'Invalid response from claim operation',
    );
  }

  /// 3.7 Delete Goal Wallet
  /// Endpoint: `DELETE /api/v1/goal-wallets/:id`
  static Future<bool> deleteGoalWallet(dynamic id, {String? email}) async {
    final res = await ApiClient.delete(
      '/api/v1/goal-wallets/$id',
      email: email,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      if (map['status'] == 'error' || map['success'] == false) {
        throw ApiException(
          statusCode: 400,
          message:
              map['message']?.toString() ??
              map['error']?['message']?.toString() ??
              'Failed to delete goal wallet',
        );
      }
      return true;
    }
    return true;
  }
}
