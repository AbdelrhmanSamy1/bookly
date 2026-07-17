import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/book_provider.dart';
import '../widgets/book_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(bookSearchProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ━━ Search Bar ━━
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _search,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search books, authors...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textHint),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.textHint, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    _search('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded,
                          color: AppColors.background),
                      onPressed: () => _showFilterSheet(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ━━ Results ━━
            Expanded(
              child: searchResults.when(
                data: (page) {
                  if (page.content.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 64,
                              color: AppColors.textHint.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try a different search term',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${page.totalElements} results',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Page ${page.currentPage + 1} of ${page.totalPages}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: page.content.length,
                          itemBuilder: (context, index) {
                            final book = page.content[index];
                            return BookCard(
                              book: book,
                              onTap: () => context.go('/book/${book.id}'),
                            );
                          },
                        ),
                      ),
                    ],
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
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      const Text('Search failed'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(bookSearchProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _search(String query) {
    setState(() {});
    ref.read(bookFilterProvider.notifier).update((current) => current.copyWith(
      title: query.isNotEmpty ? query : null,
      page: 0,
    ));
  }

  void _showFilterSheet(BuildContext context) {
    final filter = ref.read(bookFilterProvider);
    String? sortBy = filter.sortBy;
    bool? inStock = filter.inStock;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textHint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Filters',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),

                  // Sort by
                  Text('Sort by',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['title', 'price', 'publishedYear'].map((s) {
                      final selected = sortBy == s;
                      return ChoiceChip(
                        label: Text(s == 'publishedYear' ? 'Year' : s.toUpperCase()),
                        selected: selected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        onSelected: (v) =>
                            setModalState(() => sortBy = v ? s : 'title'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // In stock
                  SwitchListTile(
                    title: const Text('In Stock Only'),
                    value: inStock ?? false,
                    activeTrackColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setModalState(() => inStock = v ? true : null),
                  ),
                  const SizedBox(height: 20),

                  // Apply
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(bookFilterProvider.notifier).update(
                              (f) => f.copyWith(
                            sortBy: sortBy,
                            inStock: inStock,
                            page: 0,
                          ));
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
