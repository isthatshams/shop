import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shop_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:shop_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:shop_mobile/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:shop_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:shop_mobile/features/auth/presentation/pages/two_factor_page.dart';
import 'package:shop_mobile/features/cart/presentation/pages/cart_page.dart';
import 'package:shop_mobile/features/categories/presentation/pages/categories_page.dart';
import 'package:shop_mobile/features/home/presentation/pages/shop_home_page.dart';
import 'package:shop_mobile/features/items/presentation/pages/items_page.dart';
import 'package:shop_mobile/features/products/presentation/pages/product_detail_page.dart';
import 'package:shop_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:shop_mobile/features/settings/presentation/pages/settings_page.dart';
import 'package:shop_mobile/features/shell/main_shell.dart';
import 'package:shop_mobile/features/admin/presentation/pages/admin_login_page.dart';
import 'package:shop_mobile/features/admin/presentation/pages/admin_products_page.dart';
import 'package:shop_mobile/features/admin/presentation/pages/admin_product_form_page.dart';
import 'package:shop_mobile/features/admin/presentation/pages/admin_notifications_page.dart';

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;

  AppRouter({required this.authBloc}) {
    router = GoRouter(
      initialLocation: '/home',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState.status == AuthStatus.authenticated;
        final isAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/2fa' ||
            state.matchedLocation == '/verify-otp';
        final isAdminRoute = state.matchedLocation.startsWith('/admin');

        // If requires OTP verification, go to OTP page
        if (authState.status == AuthStatus.requiresOtpVerification &&
            state.matchedLocation != '/verify-otp') {
          return '/verify-otp?email=${Uri.encodeComponent(authState.pendingEmail ?? '')}';
        }

        // If requires 2FA, go to 2FA page
        if (authState.status == AuthStatus.requires2FA &&
            state.matchedLocation != '/2fa') {
          return '/2fa';
        }

        if (isAdminRoute) {
          return null;
        }

        // If not authenticated and not on auth route, redirect to login
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // If authenticated and on auth route, redirect to home
        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: '/verify-otp',
          pageBuilder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return CustomTransitionPage(
              key: state.pageKey,
              child: OtpVerificationPage(email: email),
              transitionsBuilder: _slideTransition,
            );
          },
        ),
        GoRoute(
          path: '/2fa',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const TwoFactorPage(),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Product detail page (outside shell - no bottom nav)
        GoRoute(
          path: '/product/:id',
          pageBuilder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return CustomTransitionPage(
              key: state.pageKey,
              child: ProductDetailPage(productId: id),
              transitionsBuilder: _slideTransition,
            );
          },
        ),

        // Items page (outside shell - no bottom nav)
        GoRoute(
          path: '/items',
          pageBuilder: (context, state) {
            final categoryName = state.uri.queryParameters['category'];
            final categoryId =
                int.tryParse(state.uri.queryParameters['category_id'] ?? '');
            return CustomTransitionPage(
              key: state.pageKey,
              child: ItemsPage(
                categoryName: categoryName,
                categoryId: categoryId,
              ),
              transitionsBuilder: _slideTransition,
            );
          },
        ),

        // Notifications
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const NotificationsPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Admin routes
        GoRoute(
          path: '/admin/login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AdminLoginPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: '/admin/products',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AdminProductsPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: '/admin/products/create',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AdminProductFormPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: '/admin/products/:id/edit',
          pageBuilder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return CustomTransitionPage(
              key: state.pageKey,
              child: AdminProductFormPage(productId: id),
              transitionsBuilder: _slideTransition,
            );
          },
        ),
        GoRoute(
          path: '/admin/notifications',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AdminNotificationsPage(),
            transitionsBuilder: _slideTransition,
          ),
        ),

        // Main app shell with bottom navigation
        ShellRoute(
          builder: (context, state, child) {
            // Determine current tab index from location
            int index = 0;
            final location = state.matchedLocation;
            if (location.startsWith('/categories')) {
              index = 1;
            } else if (location.startsWith('/cart')) {
              index = 2;
            } else if (location.startsWith('/settings')) {
              index = 3;
            }

            return MainShell(
              currentIndex: index,
              onNavigate: (idx) {
                switch (idx) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/categories');
                    break;
                  case 2:
                    context.go('/cart');
                    break;
                  case 3:
                    context.go('/settings');
                    break;
                }
              },
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ShopHomePage(),
                transitionsBuilder: _fadeTransition,
              ),
            ),
            GoRoute(
              path: '/categories',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const CategoriesPage(),
                transitionsBuilder: _fadeTransition,
              ),
            ),
            GoRoute(
              path: '/cart',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const CartPage(),
                transitionsBuilder: _fadeTransition,
              ),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SettingsPage(),
                transitionsBuilder: _fadeTransition,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );
  }
}

// Helper class to convert BLoC stream to Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
