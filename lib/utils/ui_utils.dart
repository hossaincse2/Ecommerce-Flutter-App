// utils/ui_utils.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

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

  static void showErrorSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        action: action,
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        action: action,
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF2E86AB),
        duration: Duration(seconds: 2),
        action: action,
      ),
    );
  }

  // ================ ENHANCED SNACKBAR UTILITIES ================

  static void showSnackBar(BuildContext context, String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (!_isContextValid(context)) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white, size: 20),
              SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.grey[800],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
        action: action,
      ),
    );
  }

  static void showWarningSnackBar(BuildContext context, String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange[600],
      textColor: Colors.white,
      icon: Icons.warning_outlined,
      duration: duration,
      action: action,
    );
  }

  // ================ CART SPECIFIC UTILITIES ================

  static void showCartAddedSnackBar(BuildContext context, String productName, {
    VoidCallback? onViewCart,
  }) {
    showSnackBar(
      context,
      '$productName added to cart!',
      backgroundColor: Colors.green[600],
      textColor: Colors.white,
      icon: Icons.check_circle_outline,
      action: onViewCart != null
          ? SnackBarAction(
        label: 'VIEW CART',
        textColor: Colors.white,
        onPressed: onViewCart,
      )
          : null,
    );
  }

  static void showCartRemovedSnackBar(BuildContext context, String productName) {
    showSnackBar(
      context,
      '$productName removed from cart',
      backgroundColor: Colors.blue[600],
      textColor: Colors.white,
      icon: Icons.info_outline,
    );
  }

  static void showCartUpdatedSnackBar(BuildContext context, String message) {
    showSuccessSnackBar(context, message);
  }

  static void showOutOfStockSnackBar(BuildContext context, {String? productName}) {
    showSnackBar(
      context,
      productName != null
          ? '$productName is out of stock'
          : 'Product is out of stock',
      backgroundColor: Colors.red[600],
      textColor: Colors.white,
      icon: Icons.error_outline,
    );
  }

  static void showVariantSelectionSnackBar(BuildContext context) {
    showWarningSnackBar(
      context,
      'Please select product options before adding to cart',
    );
  }

  // ================ LOADING UTILITIES ================

  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    if (!_isContextValid(context)) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    if (_isContextValid(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // ================ DIALOG UTILITIES ================

  static Future<bool?> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
        Color? confirmColor,
        IconData? icon,
      }) async {
    if (!_isContextValid(context)) return null;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 28, color: confirmColor ?? Colors.red),
                SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                confirmText,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showCartClearConfirmation(
      BuildContext context,
      VoidCallback onConfirm,
      ) async {
    final result = await showConfirmationDialog(
      context,
      title: 'Clear Cart',
      message: 'Are you sure you want to remove all items from your cart?',
      confirmText: 'Clear',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      icon: Icons.shopping_cart_outlined,
    );

    if (result == true) {
      onConfirm();
    }
  }

  static Future<void> showRemoveFromCartConfirmation(
      BuildContext context,
      String productName,
      VoidCallback onConfirm,
      ) async {
    final result = await showConfirmationDialog(
      context,
      title: 'Remove Item',
      message: 'Remove "$productName" from your cart?',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      icon: Icons.delete_outline,
    );

    if (result == true) {
      onConfirm();
    }
  }

  // ================ BOTTOM SHEET UTILITIES ================

  static Future<T?> showBottomSheet<T>(
      BuildContext context, {
        required Widget child,
        bool isScrollControlled = false,
        bool isDismissible = true,
        bool enableDrag = true,
      }) {
    if (!_isContextValid(context)) return Future.value(null);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: child,
      ),
    );
  }

  static Future<void> showCartOptionsBottomSheet(
      BuildContext context,
      String productName, {
        VoidCallback? onViewDetails,
        VoidCallback? onRemove,
        VoidCallback? onMoveToWishlist,
      }) {
    return showBottomSheet(
      context,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),

            Text(
              productName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 24),

            if (onViewDetails != null)
              _buildBottomSheetOption(
                icon: Icons.visibility_outlined,
                label: 'View Details',
                onTap: onViewDetails,
              ),

            if (onMoveToWishlist != null)
              _buildBottomSheetOption(
                icon: Icons.favorite_outline,
                label: 'Move to Wishlist',
                onTap: onMoveToWishlist,
              ),

            if (onRemove != null)
              _buildBottomSheetOption(
                icon: Icons.delete_outline,
                label: 'Remove from Cart',
                color: Colors.red,
                onTap: onRemove,
              ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // ================ NAVIGATION HANDLERS ================

  static void onCategoryTap(BuildContext context, String slug) {
    Navigator.pushNamed(context, '/category-products', arguments: slug);
  }

  static void onProductTap(BuildContext context, String productSlug) {
    Navigator.pushNamed(
      context,
      '/product-details',
      arguments: productSlug,
    );
  }

  static void onSearchTap(BuildContext context) {
    Navigator.pushNamed(context, '/search');
  }

  static void onCartTap(BuildContext context) {
    // Open cart drawer if available, otherwise navigate to cart screen
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null && scaffoldState.hasEndDrawer) {
      scaffoldState.openEndDrawer();
    } else {
      Navigator.pushNamed(context, '/cart');
    }
  }

  static void onViewAllProductsTap(BuildContext context) {
    Navigator.pushNamed(context, '/shop');
  }

  static void onBottomNavTap(BuildContext context, int index) {
    // Handle bottom navigation based on index
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

  static void onCheckoutTap(BuildContext context) {
    Navigator.pushNamed(context, '/checkout');
  }

  // ================ CART INTEGRATION UTILITIES ================

  static Future<void> addToCartWithFeedback(
      BuildContext context,
      String productSlug, {
        int quantity = 1,
        Map<String, String>? selectedVariant,
      }) async {
    try {
      showLoadingDialog(context, message: 'Adding to cart...');

      final cartService = Provider.of<CartService>(context, listen: false);

      // In a real implementation, you would:
      // 1. Fetch product details if needed
      // 2. Add to cart with variant selection
      // 3. Show appropriate feedback

      hideLoadingDialog(context);

      showCartAddedSnackBar(
        context,
        'Product', // Replace with actual product name
        onViewCart: () => onCartTap(context),
      );

    } catch (e) {
      hideLoadingDialog(context);
      showErrorSnackBar(context, 'Failed to add to cart: ${e.toString()}');
    }
  }

  // ================ UTILITY METHODS ================

  static String formatCartItemCount(int count) {
    if (count <= 0) return '';
    if (count > 99) return '99+';
    return count.toString();
  }

  static String formatPrice(double price, {String currency = 'BDT'}) {
    return '৳${price.toStringAsFixed(0)}';
  }

  static String formatPriceWithDiscount(
      double originalPrice,
      double discountedPrice, {
        String currency = 'BDT',
      }) {
    if (discountedPrice >= originalPrice) {
      return formatPrice(originalPrice, currency: currency);
    }

    return '${formatPrice(discountedPrice, currency: currency)} ${formatPrice(originalPrice, currency: currency)}';
  }

  static int calculateDiscountPercentage(double originalPrice, double discountedPrice) {
    if (discountedPrice >= originalPrice) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round();
  }

  // ================ VALIDATION UTILITIES ================

  static bool _isContextValid(BuildContext context) {
    return context.mounted;
  }

  static String? validateQuantity(String? value, {int maxStock = 999}) {
    if (value == null || value.isEmpty) {
      return 'Please enter quantity';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    if (quantity > maxStock) {
      return 'Maximum $maxStock items available';
    }

    return null;
  }

  // ================ THEME UTILITIES ================

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ================ DEVICE UTILITIES ================

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isTablet(BuildContext context) {
    return getScreenWidth(context) >= 768;
  }

  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < 768;
  }

  // ================ ACCESSIBILITY UTILITIES ================

  static void announceForAccessibility(BuildContext context, String message) {
    if (_isContextValid(context)) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(milliseconds: 100),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }
}
