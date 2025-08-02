// main.dart
import 'package:flutter/material.dart';
import 'package:karbar_shop/screens/orders/order_success_screen.dart';
import 'package:provider/provider.dart';
import 'package:karbar_shop/screens/account/my_account_screen.dart';
import 'package:karbar_shop/screens/auth/forgot_password_screen.dart';
import 'package:karbar_shop/screens/auth/login_screen.dart';
import 'package:karbar_shop/screens/auth/registration_screen.dart';
import 'package:karbar_shop/screens/cart/cart_screen.dart';
import 'package:karbar_shop/screens/categories_screen.dart';
import 'package:karbar_shop/screens/category_products_screen.dart';
import 'package:karbar_shop/screens/checkout/checkout_screen.dart';
import 'package:karbar_shop/screens/home_screen.dart';
import 'package:karbar_shop/screens/orders/my_order_screen.dart';
import 'package:karbar_shop/screens/orders/order_details_screen.dart';
import 'package:karbar_shop/screens/orders/order_tracking_screen.dart';
import 'package:karbar_shop/screens/product_details_screen.dart';
import 'package:karbar_shop/screens/auth/profile_screen.dart';
import 'package:karbar_shop/screens/settings/settings_screen.dart';
import 'package:karbar_shop/screens/shop_screen.dart';
import 'package:karbar_shop/screens/wishlist_screen.dart';
import 'package:karbar_shop/screens/splash_screen.dart';
import 'package:karbar_shop/screens/auth/profile_update_screen.dart';

import 'services/api_service.dart';
import 'services/order_api_service.dart';
import 'services/auth_manager.dart';
import 'services/cart_service.dart';
import 'utils/logger.dart';
import 'config/app_config.dart';

void main() async {
  // Ensure binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeApp();

  runApp(KarbarShopApp());
}

Future<void> _initializeApp() async {
  try {
    // Initialize API service
    ApiService.initialize();

    // Initialize Order API service with authentication
    await OrderApiService.initialize();

    // Initialize CartService
    await CartService().initialize();

    // Log app initialization
    Logger.logInfo('App initialized with environment: ${AppConfig.environment}');
    Logger.logInfo('Base URL: ${AppConfig.baseUrl}');
    Logger.logSuccess('API services initialized successfully');
  } catch (e) {
    Logger.logError('Failed to initialize app services', e);
  }
}

class KarbarShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartService>(
          create: (_) => CartService(),
        ),
        // Add other providers here as needed
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Color(0xFF2E86AB),
          fontFamily: 'Roboto',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF2E86AB),
            elevation: 1,
          ),
        ),
        // Define your routes
        routes: {
          '/': (context) => SplashScreen(),
          '/home': (context) => MainNavigationWrapper(),
          '/categories': (context) => CategoriesScreen(),
          '/wishlist': (context) => WishlistScreen(),
          '/profile': (context) => ProfileScreen(),
          '/shop': (context) => ShopScreen(),
          '/category-products': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return CategoryProductsScreen(slug: args['slug']!);
          },
          '/product-details': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            String slug;

            if (args is Map<String, dynamic>) {
              slug = args['slug']?.toString() ?? 'default_id';
            } else if (args is String) {
              slug = args;
            } else {
              slug = 'default_id';
            }

            return ProductDetailsScreen(slug: slug);
          },
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegistrationScreen(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
          '/cart': (context) => CartScreen(),
          '/checkout': (context) => CheckoutScreen(),
          '/my-account': (context) => MyAccountScreen(),
          '/my-orders': (context) => MyOrdersScreen(),
          '/order-tracking': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return OrderTrackingScreen(orderId: args['orderId']);
          },
          '/order-details': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return OrderDetailsScreen(orderId: args['orderId']);
          },
          '/order-success': (context) => OrderSuccessScreen(),
          '/update-profile': (context) => ProfileUpdateScreen(),
          '/profile-update': (context) => ProfileUpdateScreen(),
          '/settings': (context) => SettingsScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  @override
  _MainNavigationWrapperState createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final AuthManager _authManager = AuthManager();
  bool _isInitialized = false;

  final List<Widget> _screens = [
    HomeScreen(),
    CategoriesScreen(),
    ShopScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Categories',
    'Shop',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      await _authManager.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      Logger.logError('Error initializing auth in navigation', e);
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // Check if user is trying to access profile
    if (index == 3) {
      if (!_isInitialized) {
        // Still initializing, show loading
        return;
      }

      if (!_authManager.isLoggedIn || !_authManager.hasValidToken()) {
        // Not logged in, navigate to login screen
        Navigator.pushNamed(context, '/login').then((_) {
          // After returning from login, check if user is now logged in
          if (_authManager.isLoggedIn) {
            setState(() {
              _currentIndex = 3;
              _pageController.jumpToPage(3);
            });
          }
        });
        return;
      }
    }

    // Normal navigation for other tabs or authenticated profile access
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2E86AB),
        unselectedItemColor: Colors.grey[400],
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.person_outline),
                // Show a small indicator if not logged in
                if (_isInitialized && !_authManager.isLoggedIn)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({Key? key, required this.child}) : super(key: key);

  @override
  _AppLifecycleManagerState createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ApiService.dispose();
    OrderApiService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Logger.logInfo('App resumed');
        // Check token validity when app resumes
        _checkTokenValidity();
        break;
      case AppLifecycleState.paused:
        Logger.logInfo('App paused');
        break;
      case AppLifecycleState.detached:
        Logger.logInfo('App detached');
        ApiService.dispose();
        OrderApiService.dispose();
        break;
      default:
        break;
    }
  }

  Future<void> _checkTokenValidity() async {
    try {
      final authManager = AuthManager();
      await authManager.validateToken();
    } catch (e) {
      Logger.logError('Token validation error on app resume', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}