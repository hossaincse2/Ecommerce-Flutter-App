// utils/ui_utils.dart
import 'package:flutter/material.dart';

class UIUtils {

  // ================ SNACKBAR UTILITIES ================


  static void showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF2E86AB),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ================ NAVIGATION HANDLERS ================

  static void onCategoryTap(BuildContext context, String categoryName) {
     showInfoSnackBar(context, 'Tapped on $categoryName category');
    // TODO: Navigate to category screen
    // Navigator.pushNamed(context, '/category', arguments: categoryName);
  }

  static void onProductTap(BuildContext context, String productName) {
    showInfoSnackBar(context, 'Tapped on $productName');
    // TODO: Navigate to product detail screen
    // Navigator.pushNamed(context, '/product-detail', arguments: productName);
  }

  static void onSearchTap(BuildContext context) {
    showInfoSnackBar(context, 'Search feature coming soon!');
    // TODO: Navigate to search screen
    // Navigator.pushNamed(context, '/search');
  }

  static void onCartTap(BuildContext context) {
    showInfoSnackBar(context, 'Cart feature coming soon!');
    // TODO: Navigate to cart screen
    // Navigator.pushNamed(context, '/cart');
  }

  static void onViewAllProductsTap(BuildContext context) {
    showInfoSnackBar(context, 'View All Products - Coming Soon!');
    // TODO: Navigate to all products screen
    // Navigator.pushNamed(context, '/all-products');
  }

  static void onBottomNavTap(BuildContext context, int index) {
   // showInfoSnackBar(context, 'Navigation item $index tapped');
    // TODO: Handle bottom navigation based on index
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
              (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/categories',
              (route) => false,
        );
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/wishlist',
              (route) => false,
        );
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/profile',
              (route) => false,
        );
        break;
    }
  }
}