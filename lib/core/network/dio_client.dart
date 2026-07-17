import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(AuthInterceptor(dio));
  return dio;
});

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth header for public endpoints
    final publicPaths = ['/auth/login', '/auth/register', '/auth/refresh'];
    final isPublic = publicPaths.any((p) => options.path.contains(p));

    if (!isPublic) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/')) {
      // Try to refresh the token
      try {
        final refreshToken = await TokenStorage.getRefreshToken();
        if (refreshToken == null) {
          return handler.next(err);
        }

        final refreshDio = Dio(BaseOptions(baseUrl: kBaseUrl));
        final response = await refreshDio.post('/auth/refresh', data: {
          'refreshToken': refreshToken,
        });

        if (response.statusCode == 200) {
          final data = response.data;
          await TokenStorage.saveTokens(
            accessToken: data['accessToken'],
            refreshToken: data['refreshToken'],
            email: data['email'],
            role: data['role'],
            firstName: data['firstName'],
            lastName: data['lastName'],
          );

          // Retry the original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${data['accessToken']}';
          final retryResponse = await _dio.fetch(opts);
          return handler.resolve(retryResponse);
        }
      } catch (_) {
        await TokenStorage.clearAll();
      }
    }
    handler.next(err);
  }
}
