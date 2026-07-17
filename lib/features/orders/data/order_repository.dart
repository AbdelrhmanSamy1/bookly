import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import 'models/order_models.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.read(dioProvider));
});

class OrderRepository {
  final Dio _dio;
  const OrderRepository(this._dio);

  Future<List<OrderResponse>> getByUser(int userId) async {
    final response = await _dio.get(ApiEndpoints.ordersByUser(userId));
    final list = response.data as List<dynamic>;
    return list
        .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderResponse> getById(int id) async {
    final response = await _dio.get(ApiEndpoints.orderById(id));
    return OrderResponse.fromJson(response.data);
  }

  Future<OrderResponse> create(CreateOrderRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.orders,
      data: request.toJson(),
    );
    return OrderResponse.fromJson(response.data);
  }
}
