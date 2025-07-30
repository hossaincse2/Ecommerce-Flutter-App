// utils/network_utils.dart
import 'package:flutter/material.dart';
import '/constants/app_constants.dart';

class NetworkUtils {
  
  // ================ NETWORK IMAGE WIDGET ================
  
  static Widget buildNetworkImage({
    required String imageUrl,
    required BoxFit fit,
    required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
    BorderRadius? borderRadius,
    double? width,
    double? height,
    Map<String, String>? customHeaders,
  }) {
    Widget imageWidget = Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      headers: customHeaders ?? AppConstants.networkHeaders,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
  
  // ================ HERO IMAGE WIDGET ================
  
  static Widget buildHeroImage({
    required String imageUrl,
    required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
  }) {
    return buildNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
    );
  }
  
  // ================ PRODUCT IMAGE WIDGET ================
  
  static Widget buildProductImage({
    required String imageUrl,
    required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
  }) {
    return buildNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.defaultRadius)),
      width: double.infinity,
    );
  }
  
  // ================ CATEGORY IMAGE WIDGET ================
  
  static Widget buildCategoryImage({
    required String imageUrl,
    required Widget Function(BuildContext, Object, StackTrace?) errorBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
    double size = AppConstants.categoryImageSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: buildNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
        ),
      ),
    );
  }
  
  // ================ CACHED NETWORK IMAGE (if you want to add caching later) ================
  
  // Note: This would require adding cached_network_image package
  // static Widget buildCachedNetworkImage({
  //   required String imageUrl,
  //   required BoxFit fit,
  //   Widget? placeholder,
  //   Widget? errorWidget,
  //   BorderRadius? borderRadius,
  //   double? width,
  //   double? height,
  // }) {
  //   Widget imageWidget = CachedNetworkImage(
  //     imageUrl: imageUrl,
  //     fit: fit,
  //     width: width,
  //     height: height,
  //     placeholder: (context, url) => placeholder ?? LoadingWidgets.buildSmallLoadingIndicator(),
  //     errorWidget: (context, url, error) => errorWidget ?? SharedWidgets.buildProductImageErrorBuilder(context, error, null),
  //     httpHeaders: AppConstants.networkHeaders,
  //   );

  //   if (borderRadius != null) {
  //     return ClipRRect(
  //       borderRadius: borderRadius,
  //       child: imageWidget,
  //     );
  //   }

  //   return imageWidget;
  // }
}