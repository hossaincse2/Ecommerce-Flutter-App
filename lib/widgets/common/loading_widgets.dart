// widgets/common/loading_widgets.dart
import 'package:flutter/material.dart';

class LoadingWidgets {
  
  // ================ LOADING MORE INDICATOR ================
  
  static Widget buildLoadingMoreIndicator({
    String message = 'Loading more products...',
    Color color = const Color(0xFF2E86AB),
    double strokeWidth = 2.0,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ================ FULL SCREEN LOADING ================
  
  static Widget buildLoadingScreen({
    String message = 'Loading amazing products...',
    Color color = const Color(0xFF2E86AB),
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  // ================ SMALL LOADING INDICATOR ================
  
  static Widget buildSmallLoadingIndicator({
    Color color = const Color(0xFF2E86AB),
    double size = 20.0,
    double strokeWidth = 2.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
  
  // ================ IMAGE LOADING BUILDER ================
  
  static Widget buildImageLoadingBuilder(
    BuildContext context, 
    Widget child, 
    ImageChunkEvent? loadingProgress
  ) {
    if (loadingProgress == null) return child;
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
        ),
      ),
    );
  }
  
  // ================ CATEGORY IMAGE LOADING BUILDER ================
  
  static Widget buildCategoryImageLoadingBuilder(
    BuildContext context, 
    Widget child, 
    ImageChunkEvent? loadingProgress
  ) {
    if (loadingProgress == null) return child;
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: buildSmallLoadingIndicator(size: 20),
      ),
    );
  }
}