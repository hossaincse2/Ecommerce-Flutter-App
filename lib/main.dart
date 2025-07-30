import 'package:flutter/material.dart';
import 'package:karbar_shop/screens/categories_screen.dart';
import 'package:karbar_shop/screens/home_screen.dart';
// import 'package:karbar_shop/screens/wishlist_screen.dart';
// import 'package:karbar_shop/screens/profile_screen.dart';
import 'services/api_service.dart';
import 'utils/logger.dart';
import 'config/app_config.dart';

void main() {
  // Initialize services
  _initializeApp();

  runApp(KarbarShopApp());
}

void _initializeApp() {
  // Initialize API service
  ApiService.initialize();

  // Log app initialization
  Logger.logInfo('App initialized with environment: ${AppConfig.environment}');
  Logger.logInfo('Base URL: ${AppConfig.baseUrl}');
}

class KarbarShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF2E86AB),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define your routes
      routes: {
        '/': (context) => MainNavigationWrapper(),
        '/home': (context) => HomeScreen(),
        '/categories': (context) => CategoriesScreen(),
        // '/wishlist': (context) => WishlistScreen(),
        // '/profile': (context) => ProfileScreen(),
        // '/shop': (context) => ShopScreen(),
        // '/category-products': (context) {
        //   final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        //   return CategoryProductsScreen(categoryId: args['categoryId']!);
        // },
        // '/product-details': (context) {
        //   final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        //   return ProductDetailsScreen(productId: args['productId']!);
        // },
      },
      initialRoute: '/',
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

  final List<Widget> _screens = [
    HomeScreen(),
    CategoriesScreen(),
    // WishlistScreen(),
    // ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      // bottomNavigationBar:BottomNavigationWidget(currentIndex: 0,_pageController)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2E86AB),
        unselectedItemColor: Colors.grey[400],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
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
            icon: Icon(Icons.person_outline),
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Logger.logInfo('App resumed');
        break;
      case AppLifecycleState.paused:
        Logger.logInfo('App paused');
        break;
      case AppLifecycleState.detached:
        Logger.logInfo('App detached');
        ApiService.dispose();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}