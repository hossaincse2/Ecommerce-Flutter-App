class AppConfig {
  // Environment configurations
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://admin.karbar.shop/api',
  );
  static const int requestTimeout = 30; // seconds
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // API Configuration
  static String get baseUrl => _baseUrl;
  static String get environment => _environment;

  // API Endpoints
  static const String productsEndpoint = '/en/products';
  static const String productDetailsEndpoint = '/en/product'; // Added for product details
  static const String categoriesEndpoint = '/en/categories';
  static const String heroImagesEndpoint = '/hero-images';
  static const String brandsEndpoint = '/brands';

  // Default Parameters
  static const String defaultBusinessCategory = 'default';
  static const String defaultSortBy = 'new_arrival';
  static const String defaultCategory = 'all'; // Added for shop page
  static const String defaultBrandId = 'all'; // Added for shop page
  static const int defaultPerPage = 12;
  static const int shopPerPage = 2; // Specific for shop page
  static const int defaultPage = 1;

  // Shop Page Specific Configurations
  static const int shopGridColumns = 3; // 3 products per row
  static const double shopItemAspectRatio = 0.58; // Width/Height ratio
  static const double shopGridSpacing = 8.0; // Space between items
  static const int shopInitialLoadCount = 20; // Initial products to load
  static const int shopLoadMoreCount = 20; // Products to load on scroll

  // Shop Filter Options
  static const Map<String, String> sortOptions = {
    'new_arrival': 'New Arrivals',
    'popular': 'Most Popular',
    'price_low': 'Price: Low to High',
    'price_high': 'Price: High to Low',
    'discount': 'Best Discounts',
  };

  // Add these new properties for the shop filters
  static const List<String> categories = [
    'all',
    'electronics',
    'fashion',
    'home',
    'beauty',
    'sports',
    'books',
    'toys',
  ];

  static const Map<String, List<String>> subCategories = {
    'electronics': ['mobile', 'laptop', 'accessories', 'audio'],
    'fashion': ['men', 'women', 'kids', 'footwear'],
    'home': ['furniture', 'decor', 'kitchen', 'appliances'],
    'all': [],
  };

  static const List<String> brands = [
    'all',
    'samsung',
    'apple',
    'xiaomi',
    'nike',
    'adidas',
    'puma',
  ];
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration shopScrollDebounce = Duration(milliseconds: 300); // For scroll events

  // App Info
  static const String appName = 'Karbar Shop';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableCaching = true;
  static const bool enableShopFilters = true; // For shop page filter feature

  // Pagination
  static const int maxItemsPerPage = 50;
  static const int minItemsPerPage = 5;
  static const int itemsPerPage = 20;


  // Environment checks
  static bool get isProduction => _environment == 'production';
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';

  // Currency Configuration (for product prices)
  static const String currencySymbol = '৳';
  static const int priceDecimalDigits = 0;
}