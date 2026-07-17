import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../orders/data/models/order_models.dart';
import '../../../orders/data/order_repository.dart';
import '../../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: const Text('Clear All',
                  style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.textHint.withValues(alpha: 0.4)),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse books and add them to your cart',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Browse Books'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        item: item,
                        onQuantityChanged: (qty) => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.book.id, qty),
                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .removeBook(item.book.id),
                      );
                    },
                  ),
                ),

                // ━━ Summary & Checkout ━━
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Items',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('$itemCount',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed:
                                _isPlacingOrder ? null : () => _placeOrder(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: _isPlacingOrder
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.background,
                                    ),
                                  )
                                : const Text('Place Order'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _placeOrder() async {
    final auth = ref.read(authProvider).value;
    if (auth == null || !auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to place an order'),
          action: SnackBarAction(
            label: 'LOGIN',
            textColor: AppColors.primary,
            onPressed: () => context.go('/login'),
          ),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final cartItems = ref.read(cartProvider);
      final orderRepo = ref.read(orderRepositoryProvider);

      // We need the user ID — for now use a dummy approach
      // The API expects a userId. We'll pass 0 and let the backend resolve via token
      // or you can store userId from login response
      await orderRepo.create(CreateOrderRequest(
        userId: 1, // TODO: store userId from auth response
        items: cartItems
            .map((e) =>
                OrderItemRequest(bookId: e.book.id, quantity: e.quantity))
            .toList(),
      ));

      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${_extractError(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  String _extractError(Object error) {
    final msg = error.toString();
    if (msg.contains('400')) return 'Insufficient stock';
    if (msg.contains('404')) return 'Book or user not found';
    if (msg.contains('SocketException') || msg.contains('DioException')) {
      return 'Network error';
    }
    return 'Something went wrong';
  }
}
