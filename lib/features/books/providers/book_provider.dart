import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/book_repository.dart';
import '../data/models/book_models.dart';

/// All books (for Home screen)
final booksProvider = FutureProvider<List<Book>>((ref) {
  return ref.read(bookRepositoryProvider).getAll();
});

/// Single book by ID
final bookDetailProvider =
    FutureProvider.family<Book, int>((ref, id) {
  return ref.read(bookRepositoryProvider).getById(id);
});

/// All categories
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(bookRepositoryProvider).getCategories();
});

/// All authors
final authorsProvider = FutureProvider<List<Author>>((ref) {
  return ref.read(bookRepositoryProvider).getAuthors();
});

/// Search filter state (Riverpod 3.x — Notifier instead of StateProvider)
final bookFilterProvider =
    NotifierProvider<BookFilterNotifier, BookFilter>(BookFilterNotifier.new);

class BookFilterNotifier extends Notifier<BookFilter> {
  @override
  BookFilter build() => const BookFilter();

  void update(BookFilter Function(BookFilter current) updater) {
    state = updater(state);
  }
}

/// Search results (reactive to filter changes)
final bookSearchProvider = FutureProvider<PageResponse<Book>>((ref) {
  final filter = ref.watch(bookFilterProvider);
  return ref.read(bookRepositoryProvider).search(filter);
});
