import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/token_storage.dart';
import '../data/auth_repository.dart';
import '../data/models/auth_models.dart';

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserInfo>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserInfo> {
  @override
  Future<UserInfo> build() async {
    return _loadFromStorage();
  }

  Future<UserInfo> _loadFromStorage() async {
    final hasToken = await TokenStorage.hasToken();
    if (!hasToken) return UserInfo.guest;

    final info = await TokenStorage.getUserInfo();
    return UserInfo(
      email: info['email'] ?? '',
      role: info['role'] ?? '',
      firstName: info['firstName'] ?? '',
      lastName: info['lastName'] ?? '',
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.login(LoginRequest(
        email: email,
        password: password,
      ));
      await _saveAuth(response);
      return UserInfo(
        email: response.email,
        role: response.role,
        firstName: response.firstName,
        lastName: response.lastName,
      );
    });
  }

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.register(RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      ));
      await _saveAuth(response);
      return UserInfo(
        email: response.email,
        role: response.role,
        firstName: response.firstName,
        lastName: response.lastName,
      );
    });
  }

  Future<void> logout() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
    } on DioException catch (_) {
      // Ignore — server might reject if token already expired
    }
    await TokenStorage.clearAll();
    state = const AsyncData(UserInfo.guest);
  }

  Future<void> _saveAuth(AuthResponse response) async {
    await TokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      email: response.email,
      role: response.role,
      firstName: response.firstName,
      lastName: response.lastName,
    );
  }
}

/// Convenience provider to check if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.value?.isLoggedIn ?? false;
});
