import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual userId from auth
    final ordersAsync = ref.watch(userOrdersProvider(1));

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80,
                      color: AppColors.textHint.withValues(alpha: 0.4)),
                  const SizedBox(height: 20),
                  Text('No orders yet',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Your order history will appear here',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Start Shopping'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async => ref.invalidate(userOrdersProvider(1)),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return GestureDetector(
                  onTap: () => context.go('/order/${order.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Order icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _statusColor(order.status)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _statusIcon(order.status),
                            color: _statusColor(order.status),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${order.items.length} items',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        // Price & Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${order.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(order.status)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.statusLabel,
                                style: TextStyle(
                                  color: _statusColor(order.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Failed to load orders'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(userOrdersProvider(1)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warning;
      case 'CONFIRMED':
        return AppColors.info;
      case 'SHIPPED':
        return AppColors.secondary;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule_rounded;
      case 'CONFIRMED':
        return Icons.check_circle_outline;
      case 'SHIPPED':
        return Icons.local_shipping_outlined;
      case 'DELIVERED':
        return Icons.done_all_rounded;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }
}
