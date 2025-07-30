import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiConstants {
  // Base Configuration
  static const String charset = 'utf-8';
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration connectTimeout = Duration(seconds: 10);

  // HTTP Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=$charset',
    'Accept': 'application/json; charset=$charset',
    'User-Agent': 'KarbarShop/1.0.0', // Use your actual app name
    'Accept-Language': 'en-US,en;q=0.9',
    'Connection': 'keep-alive',
    // Removed Accept-Encoding to avoid automatic compression
  };

  static const Map<String, String> imageHeaders = {
    'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
    // Removed Accept-Encoding for images
  };

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;

  // Query Parameters
  static const String searchParam = 'search';
  static const String categoryParam = 'category';
  static const String subCategoryParam = 'sub_category';
  static const String pageParam = 'page';
  static const String perPageParam = 'perPage';
  static const String sortByParam = 'sort_by';
  static const String brandIdParam = 'brand_id';
  static const String businessCategoryParam = 'business_category';
  static const String featuredParam = 'featured';
  static const String mostSubCatParam = 'most_sub_cat';

  // Default Parameter Values
  static const String defaultCategory = 'all';
  static const String defaultBrandId = 'all';
  static const String defaultSubCategory = '';
  static const String defaultSearch = '';
  static const bool defaultFeatured = false;
  static const bool defaultMostSubCat = true;

  // Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String timeoutErrorMessage = 'Request timeout. Please try again.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String dataParsingErrorMessage = 'Error parsing server response.';
  static const String imageLoadErrorMessage = 'Failed to load image.';

  // Error messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorUnknown = 'Something went wrong. Please try again.';
  static const String errorNoData = 'No data available.';
  static const String errorLoadMore = 'Failed to load more items.';

  // Response Validator
  static dynamic validateResponse(http.Response response) {
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';

    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (contentType.contains('image')) {
          return response.bodyBytes;
        } else if (contentType.contains('json')) {
          return jsonDecode(utf8.decode(response.bodyBytes));
        }
        return response.body;
      } else {
        throw HttpException(
          'Request failed with status: ${response.statusCode}',
          uri: response.request?.url,
        );
      }
    } on FormatException {
      throw FormatException(dataParsingErrorMessage);
    }
  }
  // Default values
  static const String defaultBusinessCategory = 'default';
  static const String defaultSortBy = 'new_arrival';
  static const int defaultPage = 1;
  static const int defaultPerPage = 6;
  // Query parameter keys
  static const String paramPage = 'page';
  static const String paramPerPage = 'per_page';
  static const String paramCategory = 'category';
  static const String paramBrand = 'brand';
  static const String paramSortBy = 'sort_by';
  static const String paramSearch = 'search';
  static const String paramBusinessCategory = 'business_category';

  // Filter parameter values
  static const Map<String, String> sortByValues = {
    'new_arrival': 'new_arrival',
    'popular': 'popular',
    'price_low': 'price_low',
    'price_high': 'price_high',
    'discount': 'discount',
  };
  // Pagination constants
  static const int minPage = 1;
  static const int maxPerPage = 100;
  static const int minPerPage = 1;

  // Image constants
  static const String imagePlaceholder = 'assets/images/placeholder.png';
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Product constants
  static const double minPrice = 0.0;
  static const double maxDiscount = 100.0;

  // Utility methods
  static String buildProductsUrl(String baseUrl, {
    int page = defaultPage,
    int perPage = defaultPerPage,
    String category = defaultCategory,
    String brand = defaultBrandId,
    String sortBy = defaultSortBy,
    String businessCategory = defaultBusinessCategory,
    String? search,
  }) {
    final uri = Uri.parse('$baseUrl/en/products');
    final queryParams = <String, String>{
      paramPage: page.toString(),
      paramPerPage: perPage.toString(),
      paramBusinessCategory: businessCategory,
    };

    if (category != defaultCategory) {
      queryParams[paramCategory] = category;
    }

    if (brand != defaultBrandId) {
      queryParams[paramBrand] = brand;
    }

    if (sortBy != defaultSortBy) {
      queryParams[paramSortBy] = sortBy;
    }

    if (search != null && search.isNotEmpty) {
      queryParams[paramSearch] = search;
    }

    return uri.replace(queryParameters: queryParams).toString();
  }

  static String buildCategoriesUrl(String baseUrl) {
    return '$baseUrl/en/categories';
  }

  static String buildBrandsUrl(String baseUrl) {
    return '$baseUrl/brands';
  }

  static String buildProductDetailsUrl(String baseUrl, String productSlug) {
    return '$baseUrl/en/product/$productSlug';
  }

  static String buildHeroImagesUrl(String baseUrl) {
    return '$baseUrl/hero-images';
  }

  // Validation methods
  static bool isValidPage(int page) {
    return page >= minPage;
  }

  static bool isValidPerPage(int perPage) {
    return perPage >= minPerPage && perPage <= maxPerPage;
  }

  static bool isValidPrice(double price) {
    return price >= minPrice;
  }

  static bool isValidDiscount(double discount) {
    return discount >= 0 && discount <= maxDiscount;
  }
  // Helper methods for error handling
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case statusBadRequest:
        return 'Invalid request. Please check your input.';
      case statusUnauthorized:
        return 'Authentication required. Please log in.';
      case statusForbidden:
        return 'Access denied. You don\'t have permission.';
      case statusNotFound:
        return 'Requested data not found.';
      case statusInternalServerError:
        return errorServer;
      default:
        return errorUnknown;
    }
  }

  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  static bool isServerError(int statusCode) {
    return statusCode >= 500;
  }
  // Endpoint Specific Headers
  static Map<String, String> headersForEndpoint(String endpoint) {
    if (endpoint.contains('/hero-images') ||
        endpoint.contains('/images') ||
        endpoint.endsWith('.jpg') ||
        endpoint.endsWith('.png')) {
      return imageHeaders;
    }
    return defaultHeaders;
  }
}