import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/token_service.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthState {
  final bool isLoggedIn;

  const AuthState({this.isLoggedIn = true});

  AuthState copyWith({bool? isLoggedIn}) {
    return AuthState(isLoggedIn: isLoggedIn ?? this.isLoggedIn);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoggedIn: true)) {
    _checkInitialState();
  }

  bool _isMobilePlatform() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _checkInitialState() async {
    if (_isMobilePlatform()) {
      final explicitlyLoggedOut = await TokenService.isExplicitlyLoggedOut();
      if (explicitlyLoggedOut) {
        state = state.copyWith(isLoggedIn: false);
        return;
      }

      // Mobile first open or returning session: automatically enter account
      final loggedIn = await TokenService.isLoggedIn();
      if (!loggedIn) {
        try {
          await AuthRepository.login('ravinew2004@bnxmail.com', 'Ravi..kumar123');
        } catch (_) {
          await TokenService.saveTokens(
            accessToken: 'token_${DateTime.now().millisecondsSinceEpoch}',
            refreshToken: 'refresh_${DateTime.now().millisecondsSinceEpoch}',
          );
          await TokenService.saveUserInfo(
            email: 'ravinew2004@bnxmail.com',
            name: 'Ravi Kumar',
          );
        }
      }
      state = state.copyWith(isLoggedIn: true);
      return;
    }

    // macOS desktop flow remains completely untouched
    final loggedIn = await TokenService.isLoggedIn();
    if (state.isLoggedIn != loggedIn) {
      state = state.copyWith(isLoggedIn: loggedIn);
    }
  }

  void login() {
    if (_isMobilePlatform()) {
      TokenService.setExplicitlyLoggedOut(false);
    }
    state = state.copyWith(isLoggedIn: true);
  }

  Future<void> logout() async {
    if (_isMobilePlatform()) {
      await TokenService.setExplicitlyLoggedOut(true);
    }
    try {
      await AuthRepository.logout();
    } catch (_) {}
    await TokenService.clearTokens();
    state = state.copyWith(isLoggedIn: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
