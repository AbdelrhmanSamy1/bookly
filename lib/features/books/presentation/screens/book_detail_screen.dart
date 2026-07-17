import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../providers/book_provider.dart';

class BookDetailScreen extends ConsumerWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailProvider(bookId));

    return Scaffold(
      body: bookAsync.when(
        data: (book) {
          return CustomScrollView(
            slivers: [
              // ━━ Hero Cover ━━
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'book-${book.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _coverColors(book.id),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 72,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              book.title,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ━━ Content ━━
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Author
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'by ${book.authorName}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      // ━━ Stats Row ━━
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.attach_money_rounded,
                              label: 'Price',
                              value: '\$${book.price.toStringAsFixed(2)}',
                              valueColor: AppColors.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            _StatItem(
                              icon: Icons.inventory_2_outlined,
                              label: 'Stock',
                              value: '${book.stockQuantity}',
                              valueColor: book.inStock
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            _StatItem(
                              icon: Icons.calendar_today_outlined,
                              label: 'Year',
                              value: book.publishedYear?.toString() ?? '—',
                              valueColor: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ━━ Info Chips ━━
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.category_outlined,
                            label: book.categoryName,
                          ),
                          _InfoChip(
                            icon: Icons.qr_code,
                            label: book.isbn,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ━━ Description ━━
                      if (book.description != null &&
                          book.description!.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          book.description!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                              ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child:
              CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Failed to load book details'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(bookDetailProvider(bookId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),

      // ━━ Bottom Add to Cart ━━
      bottomNavigationBar: bookAsync.whenOrNull(
        data: (book) => Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            children: [
              // Price
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '\$${book.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Add to cart button
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: book.inStock
                          ? AppColors.primaryGradient
                          : null,
                      color: book.inStock ? null : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: book.inStock
                          ? () {
                              ref.read(cartProvider.notifier).addBook(book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${book.title} added to cart'),
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    textColor: AppColors.primary,
                                    onPressed: () => context.go('/cart'),
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                      ),
                      icon: Icon(
                        book.inStock
                            ? Icons.shopping_cart_outlined
                            : Icons.remove_shopping_cart_outlined,
                        color: book.inStock
                            ? AppColors.background
                            : AppColors.textHint,
                      ),
                      label: Text(
                        book.inStock ? 'Add to Cart' : 'Out of Stock',
                        style: TextStyle(
                          color: book.inStock
                              ? AppColors.background
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _coverColors(int id) {
    final palettes = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
      [const Color(0xFFfccb90), const Color(0xFFd57eeb)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
    ];
    return palettes[id % palettes.length];
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textHint, size: 18),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
