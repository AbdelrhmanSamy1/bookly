import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_repository.dart';
import '../data/models/order_models.dart';

/// Orders for a specific user
final userOrdersProvider =
    FutureProvider.family<List<OrderResponse>, int>((ref, userId) {
  return ref.read(orderRepositoryProvider).getByUser(userId);
});

/// Single order detail
final orderDetailProvider =
    FutureProvider.family<OrderResponse, int>((ref, orderId) {
  return ref.read(orderRepositoryProvider).getById(orderId);
});
