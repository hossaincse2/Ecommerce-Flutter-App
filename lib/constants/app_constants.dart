// utils/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  
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
  
  // ================ ANIMATION DURATIONS ================
  
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration shortSnackBarDuration = Duration(seconds: 2);
  static const Duration loadingDelay = Duration(milliseconds: 300);
  
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
  
  static const String appName = 'Karbar Shop';
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
}