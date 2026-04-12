import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasks/models/user.dart';
import 'package:tasks/services/repository/auth_repository.dart';
import 'package:tasks/core/token_manager.dart';

class AuthController extends AsyncNotifier<User?> {
  late AuthRepository _authRepository;

  @override
  Future<User?> build() async {
    _authRepository = AuthRepository();
    try {
      final tokenExists = await TokenManager.hasToken();
      if (tokenExists) {
        return await _authRepository.getMe();
      }
    } catch (e) {
      await TokenManager.clearAuth();
    }
    return null;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return await _authRepository.getMe();
    });
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.login(email: email, password: password);
      return await _authRepository.getMe();
    });
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> restoreSession() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _authRepository.getMe();
    });
  }
}

final authProvider = AsyncNotifierProvider<AuthController, User?>(
  () => AuthController(),
);
