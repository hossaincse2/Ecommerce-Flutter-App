// utils/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {

  // ================ APP INFO ================
  static const String appName = 'Karbar Shop';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your trusted marketplace';

  // ================ API CONSTANTS ================
  static const String baseUrl = 'https://admin.karbar.shop/api';
  static const String productDetailsEndpoint = '/en/product';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String heroImagesEndpoint = '/hero-images';
  static const String reviewsEndpoint = '/product-reviews';

  // ================ TIMEOUT CONSTANTS ================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ================ COLORS ================

  static const Color primaryColor = Color(0xFF2E86AB);
  static const Color primaryColorLight = Color(0xFF5BA3C7);
  static const Color primaryColorDark = Color(0xFF1E5F7A);

  static const Color secondaryColor = Color(0xFFF24236);
  static const Color accentColor = Color(0xFFF6AE2D);

  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  static const Color textPrimaryColor = Color(0xFF2C2C2C);
  static const Color textSecondaryColor = Color(0xFF6B6B6B);
  static const Color textDisabledColor = Color(0xFF9E9E9E);

  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0x1A000000);

  // ================ TEXT STYLES ================

  static const TextStyle appBarTitleStyle = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 22,
  );

  static const TextStyle sectionHeaderStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle productNameStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle productBrandStyle = TextStyle(
    fontSize: 9,
    color: textSecondaryColor,
  );

  static const TextStyle productPriceStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle productOriginalPriceStyle = TextStyle(
    fontSize: 9,
    color: textDisabledColor,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle categoryNameStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );

  static const TextStyle loadingTextStyle = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
  );

  static const TextStyle loadingMoreTextStyle = TextStyle(
    color: textSecondaryColor,
    fontSize: 14,
  );

  // ================ DIMENSIONS ================

  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultMargin = 16.0;
  static const double smallMargin = 8.0;
  static const double largeMargin = 24.0;

  static const double defaultRadius = 12.0;
  static const double smallRadius = 6.0;
  static const double largeRadius = 16.0;

  static const double cardElevation = 2.0;
  static const double appBarElevation = 0.0;

  // ================ GRID DIMENSIONS ================

  static const int productGridCrossAxisCount = 3;
  static const double productGridAspectRatio = 0.7;
  static const double productGridCrossAxisSpacing = 8.0;
  static const double productGridMainAxisSpacing = 12.0;

  static const int categoryGridCrossAxisCount = 3;
  static const double categoryGridAspectRatio = 0.85;
  static const double categoryGridCrossAxisSpacing = 12.0;
  static const double categoryGridMainAxisSpacing = 12.0;

  // ================ HERO SECTION ================

  static const double heroSectionHeight = 200.0;
  static const double heroIndicatorSize = 8.0;
  static const double heroIndicatorSpacing = 4.0;

  // ================ CATEGORY SECTION ================

  static const double categoryImageSize = 50.0;
  static const double categorySectionHeight = 280.0;
  static const int maxVisibleCategories = 9;

  // ================ LOADING INDICATORS ================

  static const double loadingIndicatorSize = 20.0;
  static const double loadingIndicatorStrokeWidth = 2.0;

  // ================ NETWORK HEADERS ================

  static const Map<String, String> networkHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
  };

  // ================ PAGINATION ================

  static const int defaultPerPage = 12;
  static const int initialPage = 1;
  static const int maxPageSize = 50;
  static const int minPageSize = 1;

  // ================ CART CONSTANTS ================
  static const String cartStorageKey = 'shopping_cart';
  static const int maxQuantityPerItem = 99;
  static const int minQuantityPerItem = 1;
  static const double freeDeliveryThreshold = 1000.0;
  static const double standardDeliveryFee = 60.0;

  // ================ ANIMATION DURATIONS ================

  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration shortSnackBarDuration = Duration(seconds: 2);
  static const Duration loadingDelay = Duration(milliseconds: 300);
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ================ BOX SHADOWS ================

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> heroShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> categoryShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // ================ APP STRINGS ================

  static const String loadingMessage = 'Loading amazing products...';
  static const String loadingMoreMessage = 'Loading more products...';
  static const String noImageText = 'No Image';
  static const String bannerUnavailableText = 'Banner image unavailable';

  // Navigation Labels
  static const String homeLabel = 'Home';
  static const String categoriesLabel = 'Categories';
  static const String wishlistLabel = 'Wishlist';
  static const String profileLabel = 'Profile';

  // Section Headers
  static const String shopByCategoriesHeader = 'Shop by Categories';
  static const String featuredProductsHeader = 'Featured Products';
  static const String viewAllText = 'View All';

  // Coming Soon Messages
  static const String searchComingSoon = 'Search feature coming soon!';
  static const String cartComingSoon = 'Cart feature coming soon!';
  static const String viewAllComingSoon = 'View All Products - Coming Soon!';

  // Badge Text
  static const String freeDeliveryText = 'FREE';

  // Error Messages
  static const String dataLoadError = 'Error loading data';
  static const String moreProductsLoadError = 'Error loading more products';
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String serverErrorMessage = 'Server error occurred. Please try again later';
  static const String unknownErrorMessage = 'An unexpected error occurred';
  static const String cartEmptyMessage = 'Your cart is empty';
  static const String outOfStockMessage = 'This item is out of stock';
  static const String variantRequiredMessage = 'Please select product options';

  // Success Messages
  static const String addToCartSuccessMessage = 'Product added to cart successfully';
  static const String removeFromCartSuccessMessage = 'Product removed from cart';
  static const String cartClearedMessage = 'Cart cleared successfully';
  static const String orderPlacedMessage = 'Order placed successfully';
  static const String reviewSubmittedMessage = 'Review submitted successfully';

  // ================ CURRENCY CONSTANTS ================
  static const String defaultCurrency = 'BDT';
  static const String currencySymbol = '৳';

  // ================ BUSINESS CONSTANTS ================
  static const String defaultBusinessCategory = 'default';
  static const List<String> supportedLanguages = ['en', 'bn'];
  static const String defaultLanguage = 'en';

  static const String websiteUrl = 'https://demo.karbar.shop';
  static const String facebookUrl = 'https://facebook.com/karbarshop';
  static const String whatsappNumber = '+8801234567890';

  // ================ IMAGE CONSTANTS ================
  static const String placeholderImageUrl = 'https://via.placeholder.com/300x300.png';
  static const int imageCacheWidth = 800;
  static const int imageCacheHeight = 800;
  static const int thumbnailCacheWidth = 300;
  static const int thumbnailCacheHeight = 300;

  // ================ VALIDATION CONSTANTS ================
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int minAddressLength = 10;
  static const int maxAddressLength = 500;
  static const int minReviewLength = 10;
  static const int maxReviewLength = 1000;

  // ================ STORAGE KEYS ================
  static const String userPreferencesKey = 'user_preferences';
  static const String searchHistoryKey = 'search_history';
  static const String wishlistKey = 'wishlist';
  static const String recentlyViewedKey = 'recently_viewed';

  // ================ FEATURES FLAGS ================
  static const bool enableGoogleAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePushNotifications = true;
  static const bool enableBiometricAuth = false;
  static const bool enableDarkMode = true;
  static const bool enableOfflineMode = false;

  // ================ LIMITS ================
  static const int maxSearchHistoryItems = 20;
  static const int maxRecentlyViewedItems = 50;
  static const int maxWishlistItems = 100;
  static const int maxCartItems = 50;

  // ================ HELPER METHODS ================

  /// Get formatted currency string
  static String formatCurrency(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(0)}';
  }

  /// Get product URL
  static String getProductUrl(String slug) {
    return '$websiteUrl/products/$slug';
  }

  /// Get category URL
  static String getCategoryUrl(String categorySlug) {
    return '$websiteUrl/categories/$categorySlug';
  }

  /// Get WhatsApp share URL
  static String getWhatsAppShareUrl(String message) {
    return 'https://wa.me/?text=${Uri.encodeComponent(message)}';
  }

  /// Get Facebook share URL
  static String getFacebookShareUrl(String url) {
    return 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
  }

  /// Check if quantity is valid
  static bool isValidQuantity(int quantity) {
    return quantity >= minQuantityPerItem && quantity <= maxQuantityPerItem;
  }

  /// Check if price qualifies for free delivery
  static bool qualifiesForFreeDelivery(double totalPrice) {
    return totalPrice >= freeDeliveryThreshold;
  }

  /// Get delivery fee based on total price
  static double getDeliveryFee(double totalPrice) {
    return qualifiesForFreeDelivery(totalPrice) ? 0.0 : standardDeliveryFee;
  }

  /// Calculate discount percentage
  static int calculateDiscountPercentage(double originalPrice, double discountedPrice) {
    if (discountedPrice >= originalPrice) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round();
  }

  /// Get platform-specific settings
  static Map<String, dynamic> getPlatformSettings() {
    return {
      'android': {
        'enableHapticFeedback': true,
        'useNativeSharing': false,
      },
      'ios': {
        'enableHapticFeedback': true,
        'useNativeSharing': true,
      },
      'web': {
        'enableHapticFeedback': false,
        'useNativeSharing': false,
      },
    };
  }

  /// Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentConfig() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    return {
      'isProduction': isProduction,
      'enableLogging': !isProduction,
      'enableDebugMode': !isProduction,
      'apiBaseUrl': isProduction ? baseUrl : baseUrl, // Use same for now
      'enableAnalytics': isProduction,
    };
  }

  /// Get supported image formats
  static List<String> getSupportedImageFormats() {
    return ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
  }

  /// Get supported video formats
  static List<String> getSupportedVideoFormats() {
    return ['.mp4', '.webm', '.avi', '.mov'];
  }

  /// Get cache configuration
  static Map<String, dynamic> getCacheConfig() {
    return {
      'maxCacheSize': 100 * 1024 * 1024, // 100MB
      'maxCacheAge': Duration(days: 7),
      'enableImageCache': true,
      'enableApiCache': true,
    };
  }

  /// Get notification configuration
  static Map<String, dynamic> getNotificationConfig() {
    return {
      'enableOrderUpdates': true,
      'enablePromotions': true,
      'enableNewProducts': false,
      'enablePriceDrops': true,
      'enableBackInStock': true,
    };
  }

  /// Get social media links
  static Map<String, String> getSocialMediaLinks() {
    return {
      'facebook': facebookUrl,
      'instagram': 'https://instagram.com/karbarshop',
      'twitter': 'https://twitter.com/karbarshop',
      'youtube': 'https://youtube.com/karbarshop',
      'linkedin': 'https://linkedin.com/company/karbarshop',
    };
  }

  /// Get customer support info
  static Map<String, String> getCustomerSupportInfo() {
    return {
      'phone': whatsappNumber,
      'email': 'support@karbar.shop',
      'whatsapp': whatsappNumber,
      'hours': '9 AM - 9 PM (Daily)',
      'address': 'Dhaka, Bangladesh',
    };
  }

  /// Get app metadata
  static Map<String, dynamic> getAppMetadata() {
    return {
      'name': appName,
      'version': appVersion,
      'description': appDescription,
      'developer': 'Karbar Shop Ltd.',
      'website': websiteUrl,
      'privacy_policy': '$websiteUrl/privacy',
      'terms_of_service': '$websiteUrl/terms',
    };
  }
}