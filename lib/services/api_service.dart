// services/api_service.dart - Updated to include order integration
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/category.dart';
import '../models/hero_image.dart';
import '../models/order.dart';
import '../models/order_details.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../models/product_details.dart';
import '../services/api_client.dart';
import '../services/order_api_service.dart';
import '../utils/logger.dart';

class ApiService {
  static final ApiClient _apiClient = ApiClient();

  // ================ INITIALIZATION ================

  static void initialize() {
    _apiClient.initialize();
    OrderApiService.initialize();
    Logger.logInfo('ApiService initialized with Order integration');
  }

  static void dispose() {
    _apiClient.dispose();
    OrderApiService.dispose();
    Logger.logInfo('ApiService disposed');
  }

  // ================ PRODUCTS API ================
  // [Keep all existing product methods as they were]

  static Future<List<Product>> getProducts({
    int perPage = 12,
    int page = 1,
    String? category,
    String? brand,
    String? sortBy,
    String? search,
    String businessCategory = 'default',
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'per_page': perPage.toString(),
        'page': page.toString(),
        'business_category': businessCategory,
      };

      // Add search parameter if provided
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      // Add category filter if provided and not 'all'
      if (category != null && category.trim().isNotEmpty && category.toLowerCase() != 'all') {
        queryParams['category'] = category.trim();
      }

      // Add brand filter if provided and not 'all'
      if (brand != null && brand.trim().isNotEmpty && brand.toLowerCase() != 'all') {
        queryParams['brand'] = brand.trim();
      }

      // Add sort parameter if provided
      if (sortBy != null && sortBy.trim().isNotEmpty) {
        queryParams['sort_by'] = _mapSortByValue(sortBy.trim());
      }

      // Build the URL
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.productsEndpoint}')
          .replace(queryParameters: queryParams);

      Logger.logInfo('Fetching products with URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'Karbar-Shop-App/1.0.0',
          'Cache-Control': 'no-cache',
        },
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different API response structures
        List<dynamic> productsJson = [];

        if (data is Map) {
          productsJson = data['data'] ??
              data['products'] ??
              data['results'] ??
              [];
        } else if (data is List) {
          productsJson = data;
        }

        final products = productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        Logger.logSuccess('Successfully fetched ${products.length} products');
        return products;
      } else {
        Logger.logError('Failed to load products: HTTP ${response.statusCode}', null);
        throw Exception('Failed to load products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      Logger.logError('Error in getProducts', e);
      throw Exception('Failed to load products: $e');
    }
  }

  // ================ ENHANCED SEARCH API ================

  static Future<List<Product>> searchProducts(
      String searchQuery, {
        String? category,
        String? brand,
        String? sortBy,
        int page = 1,
        int perPage = 12,
        String businessCategory = 'default',
      }) async {

    if (searchQuery.trim().isEmpty) {
      throw ApiException('Search query cannot be empty');
    }

    Logger.logInfo('Searching products with query: "$searchQuery"');

    return getProducts(
      search: searchQuery.trim(),
      category: category,
      brand: brand,
      sortBy: sortBy,
      page: page,
      perPage: perPage,
      businessCategory: businessCategory,
    );
  }

  // ================ CATEGORY PRODUCTS API ================

  static Future<List<Product>> getProductsByCategory(
      String categorySlug, {
        String? brand,
        String? sortBy,
        String? search,
        int page = 1,
        int perPage = 12,
        String businessCategory = 'default',
      }) async {

    if (categorySlug.trim().isEmpty) {
      throw ApiException('Category slug cannot be empty');
    }

    Logger.logInfo('Fetching products for category: "$categorySlug"');

    return getProducts(
      category: categorySlug,
      brand: brand,
      sortBy: sortBy,
      search: search,
      page: page,
      perPage: perPage,
      businessCategory: businessCategory,
    );
  }

  // ================ BRAND PRODUCTS API ================

  static Future<List<Product>> getProductsByBrand(
      String brandName, {
        String? category,
        String? sortBy,
        String? search,
        int page = 1,
        int perPage = 12,
        String businessCategory = 'default',
      }) async {

    if (brandName.trim().isEmpty) {
      throw ApiException('Brand name cannot be empty');
    }

    Logger.logInfo('Fetching products for brand: "$brandName"');

    return getProducts(
      brand: brandName,
      category: category,
      sortBy: sortBy,
      search: search,
      page: page,
      perPage: perPage,
      businessCategory: businessCategory,
    );
  }

  // ================ FILTERED PRODUCTS API ================

  static Future<List<Product>> getFilteredProducts({
    String? search,
    String? category,
    String? brand,
    String? sortBy,
    int page = 1,
    int perPage = 12,
    String businessCategory = 'default',
  }) async {

    Logger.logInfo('Fetching filtered products - Search: "$search", Category: "$category", Brand: "$brand", Sort: "$sortBy"');

    return getProducts(
      search: search,
      category: category,
      brand: brand,
      sortBy: sortBy,
      page: page,
      perPage: perPage,
      businessCategory: businessCategory,
    );
  }

  // ================ PRODUCT DETAILS API ================

  static Future<ProductDetails> getProductDetails(String slug) async {
    try {
      if (slug.trim().isEmpty) {
        throw ApiException('Product slug cannot be empty');
      }

      Logger.logInfo('Fetching product details for slug: $slug');

      // Try different endpoint patterns
      final List<String> possibleEndpoints = [
        '${AppConfig.baseUrl}/en/product/$slug'
      ];

      ApiException? lastException;

      for (String endpoint in possibleEndpoints) {
        try {
          Logger.logInfo('Trying endpoint: $endpoint');

          // Remove base URL as it's handled by ApiClient
          final path = endpoint.replaceFirst(AppConfig.baseUrl, '');

          final response = await _apiClient.get(path);

          // Handle both direct data and wrapped data responses
          final productData = response['data'] ?? response;
          final productDetails = ProductDetails.fromJson(productData);

          Logger.logSuccess('Successfully fetched product details for: $slug');
          return productDetails;

        } on ApiException catch (e) {
          Logger.logWarning('Endpoint $endpoint failed: ${e.message}');
          lastException = e;
          continue;
        } catch (e) {
          Logger.logWarning('Endpoint $endpoint failed: $e');
          lastException = ApiException('Failed to fetch from $endpoint: $e');
          continue;
        }
      }

      // If all endpoints failed, throw the last exception
      throw lastException ?? ApiException('Product not found with slug: $slug');

    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.logError('Error fetching product details', e);
      throw ApiException('Failed to fetch product details: $e');
    }
  }

  // ================ SUBMIT REVIEW API ================

  static Future<bool> submitProductReview({
    required int productId,
    required int rating,
    required String review,
    String? customerName,
    String? customerEmail,
  }) async {
    try {
      if (review.trim().isEmpty) {
        throw ApiException('Review text cannot be empty');
      }

      if (rating < 1 || rating > 5) {
        throw ApiException('Rating must be between 1 and 5');
      }

      Logger.logInfo('Submitting review for product: $productId');

      final reviewData = {
        'product_id': productId,
        'rating': rating,
        'review': review.trim(),
        if (customerName != null && customerName.isNotEmpty) 'customer_name': customerName,
        if (customerEmail != null && customerEmail.isNotEmpty) 'customer_email': customerEmail,
      };

      final response = await _apiClient.post(
        '/api/product-reviews',
        body: reviewData,
      );

      Logger.logSuccess('Successfully submitted review for product: $productId');
      return true;

    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.logError('Error submitting product review', e);
      throw ApiException('Failed to submit review: $e');
    }
  }

  // ================ CATEGORIES API ================

  static Future<List<Category>> getCategories({
    String businessCategory = AppConfig.defaultBusinessCategory,
    bool featured = ApiConstants.defaultFeatured,
    bool mostSubCat = ApiConstants.defaultMostSubCat,
  }) async {
    try {
      final queryParameters = _buildCategoriesQueryParams(
        businessCategory: businessCategory,
        featured: featured,
        mostSubCat: mostSubCat,
      );

      Logger.logInfo('Fetching categories with params: $queryParameters');

      final response = await _apiClient.get(
        AppConfig.categoriesEndpoint,
        queryParameters: queryParameters,
      );

      final List<dynamic> categoriesList = response['data'] ?? [];
      final categories = categoriesList.map((json) => Category.fromJson(json)).toList();

      Logger.logSuccess('Successfully fetched ${categories.length} categories');
      return categories;

    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.logError('Error fetching categories', e);
      throw ApiException('Failed to fetch categories: $e');
    }
  }

  // ================ HERO IMAGES API ================

  static Future<List<HeroImage>> getHeroImages() async {
    try {
      Logger.logInfo('Fetching hero images');

      final response = await _apiClient.get(AppConfig.heroImagesEndpoint);

      final List<dynamic> imagesList = response['data'] ?? [];
      final heroImages = imagesList.map((json) => HeroImage.fromJson(json)).toList();

      Logger.logSuccess('Successfully fetched ${heroImages.length} hero images');
      return heroImages;

    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.logError('Error fetching hero images', e);
      throw ApiException('Failed to fetch hero images: $e');
    }
  }

  // ================ BRANDS API ================

  static Future<List<String>> getAvailableBrands({
    String? category,
    String businessCategory = 'default',
  }) async {
    try {
      Logger.logInfo('Fetching available brands');

      // First get all products to extract brands
      final products = await getProducts(
        perPage: 100, // Get more products to collect all brands
        page: 1,
        category: category,
        businessCategory: businessCategory,
      );

      // Extract unique brands
      Set<String> brandsSet = {};
      for (var product in products) {
        if (product.brand.trim().isNotEmpty) {
          brandsSet.add(product.brand.trim());
        }
      }

      final brands = brandsSet.toList()..sort();
      Logger.logSuccess('Successfully fetched ${brands.length} brands');
      return brands;

    } catch (e) {
      Logger.logError('Error fetching brands', e);
      throw ApiException('Failed to fetch brands: $e');
    }
  }

  // ================ ORDER API INTEGRATION ================

  /// Get user orders using OrderApiService
  static Future<List<Order>> getUserOrders({
    String filter = 'all',
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await OrderApiService.getUserOrders(
        filter: filter,
        page: page,
        perPage: perPage,
      );
      return response.data;
    } catch (e) {
      Logger.logError('Error fetching user orders via ApiService', e);
      rethrow;
    }
  }

  /// Get order details using OrderApiService
  static Future<OrderDetails> getOrderDetails(int orderId) async {
    try {
      return await OrderApiService.getOrderDetails(orderId);
    } catch (e) {
      Logger.logError('Error fetching order details via ApiService', e);
      rethrow;
    }
  }

  /// Cancel order using OrderApiService
  static Future<bool> cancelOrder(int orderId) async {
    try {
      return await OrderApiService.cancelOrder(orderId);
    } catch (e) {
      Logger.logError('Error cancelling order via ApiService', e);
      rethrow;
    }
  }

  /// Search orders using OrderApiService
  static Future<List<Order>> searchOrders(String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      return await OrderApiService.searchOrders(query, page: page, perPage: perPage);
    } catch (e) {
      Logger.logError('Error searching orders via ApiService', e);
      rethrow;
    }
  }

  // ================ HELPER METHODS ================

  static String _mapSortByValue(String sortBy) {
    // Map frontend sort values to backend expected values
    final sortMapping = {
      'name_asc': 'name_asc',
      'name_desc': 'name_desc',
      'price_low_high': 'price_asc',
      'price_high_low': 'price_desc',
      'newest': 'created_desc',
      'oldest': 'created_asc',
      'popular': 'popular',
      'rating': 'rating_desc',
    };

    return sortMapping[sortBy] ?? sortBy;
  }

  static Map<String, String> _buildProductsQueryParams({
    required String search,
    required String category,
    required int page,
    required int perPage,
    required String sortBy,
    required String brandId,
    required String businessCategory,
  }) {
    final params = <String, String>{};

    if (search.isNotEmpty) params[ApiConstants.searchParam] = search;
    if (category.isNotEmpty) params[ApiConstants.categoryParam] = category;
    params[ApiConstants.pageParam] = page.toString();
    params[ApiConstants.perPageParam] = perPage.toString();
    if (sortBy.isNotEmpty) params[ApiConstants.sortByParam] = sortBy;
    if (brandId.isNotEmpty) params[ApiConstants.brandIdParam] = brandId;
    if (businessCategory.isNotEmpty) params[ApiConstants.businessCategoryParam] = businessCategory;

    return params;
  }

  static Map<String, String> _buildCategoriesQueryParams({
    required String businessCategory,
    required bool featured,
    required bool mostSubCat,
  }) {
    final params = <String, String>{};

    if (businessCategory.isNotEmpty) params[ApiConstants.businessCategoryParam] = businessCategory;
    params[ApiConstants.featuredParam] = featured.toString();
    params[ApiConstants.mostSubCatParam] = mostSubCat.toString();

    return params;
  }

  static void _validatePaginationParams(int page, int perPage) {
    if (page < 1) {
      throw ApiException('Page number must be greater than 0');
    }

    if (perPage < AppConfig.minItemsPerPage || perPage > AppConfig.maxItemsPerPage) {
      throw ApiException(
          'Items per page must be between ${AppConfig.minItemsPerPage} and ${AppConfig.maxItemsPerPage}'
      );
    }
  }

  static void _validateSearchQuery(String? query) {
    if (query != null && query.trim().length < 2) {
      throw ApiException('Search query must be at least 2 characters long');
    }
  }

  static void _validateCategorySlug(String? slug) {
    if (slug != null && slug.trim().isEmpty) {
      throw ApiException('Category slug cannot be empty');
    }
  }

  static void _validateBrandName(String? brand) {
    if (brand != null && brand.trim().isEmpty) {
      throw ApiException('Brand name cannot be empty');
    }
  }

  // ================ CACHE MANAGEMENT ================

  static void clearCache() {
    // Clear both product and order caches
    Logger.logInfo('Cache cleared for products and orders');
    OrderApiService.refreshOrders(); // Also refresh order cache
  }

  static Future<void> refreshData() async {
    try {
      clearCache();
      await OrderApiService.refreshOrders();
      Logger.logInfo('Data refresh initiated for all services');
    } catch (e) {
      Logger.logError('Error refreshing data', e);
      throw ApiException('Failed to refresh data: $e');
    }
  }

  // ================ ERROR HANDLING ================

  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return ApiConstants.unknownErrorMessage;
  }

  static bool isNetworkError(dynamic error) {
    if (error is ApiException) {
      return error.message.contains('Network') ||
          error.message.contains('connection') ||
          error.message.contains('timeout');
    }
    return false;
  }

  static bool isValidationError(dynamic error) {
    if (error is ApiException) {
      return error.message.contains('must be') ||
          error.message.contains('cannot be empty') ||
          error.message.contains('invalid');
    }
    return false;
  }

  // ================ COMPREHENSIVE ERROR HANDLING ================

  static bool isAuthenticationError(dynamic error) {
    return OrderApiService.isAuthenticationError(error);
  }

  static bool isOrderRelatedError(dynamic error) {
    return OrderApiService.isOrderNotFoundError(error);
  }

  // ================ UNIFIED ERROR RESPONSE ================

  static Map<String, dynamic> getErrorDetails(dynamic error) {
    return {
      'message': getErrorMessage(error),
      'isNetwork': isNetworkError(error),
      'isValidation': isValidationError(error),
      'isAuth': isAuthenticationError(error),
      'isOrderRelated': isOrderRelatedError(error),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// ================ CUSTOM EXCEPTION CLASS ================

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;

  ApiException(this.message, {this.statusCode, this.endpoint});

  @override
  String toString() => 'ApiException: $message';
}