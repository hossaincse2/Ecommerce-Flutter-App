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
  static const String categoriesEndpoint = '/en/categories';
  static const String heroImagesEndpoint = '/hero-images';

  // Default Parameters
  static const String defaultBusinessCategory = 'default';
  static const String defaultSortBy = 'new_arrival';
  static const int defaultPerPage = 12;
  static const int defaultPage = 1;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // App Info
  static const String appName = 'Karbar Shop';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableLogging = true;
  static const bool enableCaching = true;

  // Pagination
  static const int maxItemsPerPage = 50;
  static const int minItemsPerPage = 5;

  // Environment checks
  static bool get isProduction => _environment == 'production';
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
}