import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/books/presentation/screens/book_detail_screen.dart';
import '../../features/books/presentation/screens/home_screen.dart';
import '../../features/books/presentation/screens/search_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../theme/app_theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.isLoggedIn ?? false;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // If on auth page and already logged in, go home
      if (isAuthRoute && isLoggedIn) return '/';

      return null; // No redirect needed — browsing is public
    },
    routes: [
      // ━━ Shell with bottom nav ━━
      ShellRoute(
        builder: (context, state, child) {
          return _ShellScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrdersScreen(),
            ),
          ),
        ],
      ),

      // ━━ Standalone routes (no bottom nav) ━━
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/book/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BookDetailScreen(bookId: id);
        },
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return OrderDetailScreen(orderId: id);
        },
      ),
    ],
  );
});

class _ShellScreen extends ConsumerWidget {
  final Widget child;
  const _ShellScreen({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final location =
        GoRouterState.of(context).matchedLocation;

    int currentIndex;
    switch (location) {
      case '/search':
        currentIndex = 1;
        break;
      case '/cart':
        currentIndex = 2;
        break;
      case '/orders':
        currentIndex = 3;
        break;
      default:
        currentIndex = 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/search');
                break;
              case 2:
                context.go('/cart');
                break;
              case 3:
                final isLoggedIn = ref.read(isLoggedInProvider);
                if (isLoggedIn) {
                  context.go('/orders');
                } else {
                  context.go('/login');
                }
                break;
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text(
                  '$cartCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text(
                  '$cartCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }
}
