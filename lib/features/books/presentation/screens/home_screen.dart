import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/book_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(booksProvider);
            ref.invalidate(categoriesProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ━━ Header ━━
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bookly',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primaryLight,
                                          ],
                                        ).createShader(
                                            const Rect.fromLTWH(0, 0, 150, 40)),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discover your next read',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.search_rounded,
                                  color: AppColors.textSecondary),
                              onPressed: () => context.go('/search'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // ━━ Categories ━━
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: categoriesAsync.when(
                        data: (categories) => ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length + 1,
                          separatorBuilder: (context2, index2) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CategoryChip(
                                label: 'All',
                                isSelected: _selectedCategory == null,
                                onTap: () =>
                                    setState(() => _selectedCategory = null),
                              );
                            }
                            final cat = categories[index - 1];
                            return CategoryChip(
                              label: cat.name,
                              isSelected: _selectedCategory == cat.name,
                              onTap: () => setState(
                                  () => _selectedCategory = cat.name),
                            );
                          },
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2),
                        ),
                        error: (e, s) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Failed to load categories',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ━━ Books Header ━━
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory ?? 'All Books',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      booksAsync.whenOrNull(
                        data: (books) {
                          final filtered = _filterBooks(books);
                          return Text(
                            '${filtered.length} books',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ) ?? const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ━━ Books Grid ━━
              booksAsync.when(
                data: (books) {
                  final filtered = _filterBooks(books);
                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_rounded,
                                size: 64,
                                color:
                                    AppColors.textHint.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('No books found',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = filtered[index];
                          return BookCard(
                            book: book,
                            onTap: () => context.go('/book/${book.id}'),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  ),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text('Failed to load books',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(booksProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  List<dynamic> _filterBooks(List<dynamic> books) {
    if (_selectedCategory == null) return books;
    return books
        .where((b) =>
            b.categoryName.toLowerCase() ==
            _selectedCategory!.toLowerCase())
        .toList();
  }
}
