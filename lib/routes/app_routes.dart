import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

// Auth Screens
import '../views/auth/login_screen.dart';

// Layout
import '../views/common/layout.dart';

// Dashboard
import '../views/dashboard/dashboard_screen.dart';

// Users
import '../views/users/user_list_screen.dart';
import '../views/users/user_details_screen.dart';

// Categories
import '../views/categories/category_list_screen.dart';
import '../views/categories/add_category_screen.dart';
import '../views/categories/edit_category_screen.dart';

// Products
import '../views/products/product_list_screen.dart';
import '../views/products/add_product_screen.dart';
import '../views/products/edit_product_screen.dart';
import '../views/products/product_details_screen.dart';

// Bookings
import '../views/bookings/booking_list_screen.dart';
import '../views/bookings/booking_details_screen.dart';
import '../views/bookings/update_booking_status_screen.dart';

// Routes
import 'route_names.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: RouteNames.dashboard,
    redirect: (ctx, state) {
      final auth = ctx.read<AuthProvider>();
      final isLoggedIn = auth.isLoggedIn;
      final isLoginRoute = state.matchedLocation == RouteNames.login;

      if (!isLoggedIn && !isLoginRoute) return RouteNames.login;
      if (isLoggedIn && isLoginRoute) return RouteNames.dashboard;

      return null;
    },
    routes: [
      // Login Route
      GoRoute(
        path: RouteNames.login,
        builder: (ctx, state) => const LoginScreen(),
      ),

      // Admin Shell (layout)
      ShellRoute(
        builder: (ctx, state, child) => AdminLayout(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: RouteNames.dashboard,
            builder: (ctx, state) => const DashboardScreen(),
          ),

          // Users
          GoRoute(
            path: RouteNames.users,
            builder: (ctx, state) => const UserListScreen(),
          ),
          GoRoute(
            path: RouteNames.userDetails,
            builder: (ctx, state) => UserDetailsScreen(
              userId: state.pathParameters['id']!,
            ),
          ),

          // Categories
          GoRoute(
            path: RouteNames.categories,
            builder: (ctx, state) => const CategoryListScreen(),
          ),
          GoRoute(
            path: RouteNames.addCategory,
            builder: (ctx, state) => const AddCategoryScreen(),
          ),
          GoRoute(
            path: RouteNames.editCategory,
            builder: (ctx, state) => EditCategoryScreen(
              categoryId: state.pathParameters['id']!,
            ),
          ),

          // Products
          GoRoute(
            path: RouteNames.products,
            builder: (ctx, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: RouteNames.addProduct,
            builder: (ctx, state) => const AddProductScreen(),
          ),
          GoRoute(
            path: RouteNames.editProduct,
            builder: (ctx, state) => EditProductScreen(
              productId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: RouteNames.productDetails,
            builder: (ctx, state) => ProductDetailsScreen(
              productId: state.pathParameters['id']!,
            ),
          ),

          // Bookings
          GoRoute(
            path: RouteNames.bookings,
            builder: (ctx, state) => const BookingListScreen(),
          ),
          GoRoute(
            path: RouteNames.bookingDetails,
            builder: (ctx, state) => BookingDetailsScreen(
              bookingId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: RouteNames.updateBookingStatus,
            builder: (ctx, state) => UpdateBookingStatusScreen(
              bookingId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
}