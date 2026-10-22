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

  Future<void> _checkInitialState() async {
    final loggedIn = await TokenService.isLoggedIn();
    if (state.isLoggedIn != loggedIn) {
      state = state.copyWith(isLoggedIn: loggedIn);
    }
  }

  void login() {
    state = state.copyWith(isLoggedIn: true);
  }

  Future<void> logout() async {
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
