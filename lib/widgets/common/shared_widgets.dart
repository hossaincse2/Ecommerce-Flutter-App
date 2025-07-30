// widgets/common/shared_widgets.dart
import 'package:flutter/material.dart';

class SharedWidgets {
  
  // ================ SECTION HEADER ================
  
  static Widget buildSectionHeader(
    String title, {
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
    Color? textColor,
  }) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor ?? Colors.grey[800],
        ),
      ),
    );
  }
  
  // ================ SECTION HEADER WITH ACTION BUTTON ================
  
  static Widget buildSectionHeaderWithAction(
    String title,
    String actionText,
    VoidCallback onActionPressed, {
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    double titleFontSize = 20,
    FontWeight titleFontWeight = FontWeight.bold,
    Color? titleColor,
    Color actionColor = const Color(0xFF2E86AB),
    FontWeight actionFontWeight = FontWeight.w600,
  }) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: titleFontWeight,
              color: titleColor ?? Colors.grey[800],
            ),
          ),
          TextButton(
            onPressed: onActionPressed,
            child: Text(
              actionText,
              style: TextStyle(
                color: actionColor,
                fontWeight: actionFontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ================ ERROR BUILDERS ================
  
  static Widget buildProductImageErrorBuilder(
    BuildContext context, 
    Object error, 
    StackTrace? stackTrace
  ) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 24,
            color: Colors.grey[400],
          ),
          SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
  
  static Widget buildCategoryImageErrorBuilder(
    BuildContext context, 
    Object error, 
    StackTrace? stackTrace
  ) {
    return Container(
      color: Colors.grey[100],
      child: Icon(
        Icons.category,
        color: Color(0xFF2E86AB),
        size: 25,
      ),
    );
  }
  
  static Widget buildHeroImageErrorBuilder(
    BuildContext context, 
    Object error, 
    StackTrace? stackTrace
  ) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            'Banner image unavailable',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  // ================ BADGE WIDGETS ================
  
  static Widget buildDiscountBadge(int discountPercentage) {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '-$discountPercentage%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  static Widget buildFreeDeliveryBadge() {
    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'FREE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // ================ EMPTY STATE WIDGETS ================
  
  static Widget buildEmptyState({
    required String message,
    IconData? icon,
    String? actionText,
    VoidCallback? onActionPressed,
    Color iconColor = const Color(0xFF2E86AB),
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
            SizedBox(height: 16),
          ],
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onActionPressed != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E86AB),
              ),
              child: Text(actionText),
            ),
          ],
        ],
      ),
    );
  }
  
  // ================ COMMON APP BAR ================
  
  static PreferredSizeWidget buildAppBar({
    required String title,
    List<Widget>? actions,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
    Color backgroundColor = Colors.white,
    Color titleColor = const Color(0xFF2E86AB),
    double elevation = 0,
    double titleFontSize = 22,
    FontWeight titleFontWeight = FontWeight.bold,
  }) {
    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: titleColor),
              onPressed: onBackPressed,
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: titleFontWeight,
          fontSize: titleFontSize,
        ),
      ),
      actions: actions,
    );
  }
}