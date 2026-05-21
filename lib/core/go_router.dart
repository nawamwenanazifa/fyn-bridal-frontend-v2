import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart' as home;
import '../screens/gallery_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/bookings_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/conversations_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/collection_screen.dart';
import '../screens/moodboard_screen.dart';
import '../screens/lookbook_screen.dart';
import '../screens/forget_password_screen.dart';
import '../screens/booking_form_screen.dart';
import '../screens/booking_confirmation_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/profile_screen.dart';
// Admin screens
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/products_screen.dart';
import '../screens/admin/add_product_screen.dart';
import '../screens/admin/users_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Page Not Found: ${state.uri.path}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // ── Auth Routes ────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) => const OTPScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgetPasswordScreen(),
      ),

      // ── Main App Routes ────────────────────────────────────────────────────
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const home.HomeScreen(),
      ),
      GoRoute(
        path: '/gallery',
        name: 'gallery',
        builder: (context, state) => const GalleryScreen(),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/lookbook',
        name: 'lookbook',
        builder: (context, state) => const LookbookScreen(),
      ),
      GoRoute(
        path: '/moodboard',
        name: 'moodboard',
        builder: (context, state) => const MoodboardScreen(),
      ),

      // ── Admin Routes (nested) ──────────────────────────────────────────────
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'products',             // /admin/products
            name: 'admin-products',
            builder: (context, state) => const AdminProductsScreen(),
            routes: [
              GoRoute(
                path: 'add',              // /admin/products/add
                name: 'admin-products-add',
                builder: (context, state) => const AddProductScreen(),
              ),
              GoRoute(
                path: 'edit/:id',         // /admin/products/edit/:id
                name: 'admin-products-edit',
                builder: (context, state) => const AddProductScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'users',               // /admin/users
            name: 'admin-users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
        ],
      ),

      // ── Product Routes ─────────────────────────────────────────────────────
      GoRoute(
        path: '/product-detail',
        name: 'product-detail',
        builder: (context, state) => const ProductDetailScreen(),
      ),
      GoRoute(
        path: '/collection',
        name: 'collection',
        builder: (context, state) {
          final category = state.extra as String? ?? 'Gomesi';
          return CollectionScreen(collectionType: category);
        },
      ),

      // ── Booking Routes ─────────────────────────────────────────────────────
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => const BookingsScreen(),
      ),
      GoRoute(
        path: '/booking-form',
        name: 'booking-form',
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>?;
          return BookingFormScreen(product: product);
        },
      ),
      GoRoute(
        path: '/booking-confirmation',
        name: 'booking-confirmation',
        builder: (context, state) {
          final bookingDetails = state.extra as Map<String, dynamic>;
          return BookingConfirmationScreen(bookingDetails: bookingDetails);
        },
      ),

      // ── Chat Routes ────────────────────────────────────────────────────────
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:userId',
        name: 'chat',
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['userId']!);
          final user = state.extra as Map<String, dynamic>?;
          return ChatScreen(userId: userId, user: user);
        },
      ),
    ],
  );
}