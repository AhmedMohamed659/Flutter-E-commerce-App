import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/manage_categories_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/search_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/category_products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? '/login'
          : '/home',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/product': (_) => const ProductDetailsScreen(),
        '/wishlist': (_) => const WishlistScreen(),
        '/cart': (_) => const CartScreen(),
        '/orders': (_) => const OrdersScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/edit_profile': (_) => const EditProfileScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
        '/search': (_) => const SearchScreen(),
        '/category_products': (_) => const CategoryProductsScreen(),
        '/help': (_) => const HelpSupportScreen(),
        '/manage_categories': (context) => const ManageCategoriesScreen(),
      },
    );
  }
}
