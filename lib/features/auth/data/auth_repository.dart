import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import 'models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

class AuthRepository {
  final Dio _dio;
  const AuthRepository(this._dio);

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }
}
