import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../books/data/models/book_models.dart';

/// Cart item = book + quantity
class CartItem {
  final Book book;
  final int quantity;

  const CartItem({required this.book, this.quantity = 1});

  double get subtotal => book.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(book: book, quantity: quantity ?? this.quantity);
  }
}

/// Cart state notifier
final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addBook(Book book) {
    final index = state.indexWhere((item) => item.book.id == book.id);
    if (index >= 0) {
      // Already in cart — increment quantity
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = updated;
    } else {
      state = [...state, CartItem(book: book)];
    }
  }

  void removeBook(int bookId) {
    state = state.where((item) => item.book.id != bookId).toList();
  }

  void updateQuantity(int bookId, int quantity) {
    if (quantity <= 0) {
      removeBook(bookId);
      return;
    }
    state = [
      for (final item in state)
        if (item.book.id == bookId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void clear() {
    state = [];
  }
}

/// Convenience providers
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});
