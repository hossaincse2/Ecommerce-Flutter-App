import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/category.dart';
import '../models/hero_image.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../models/product_details.dart';
import '../services/api_client.dart';
import '../utils/logger.dart';

class ApiService {
  static final ApiClient _apiClient = ApiClient();

  // ================ PRODUCTS API ================

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

      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }

      if (brand != null && brand.isNotEmpty && brand != 'all') {
        queryParams['brand'] = brand;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Build the URL
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.productsEndpoint}')
          .replace(queryParameters: queryParams);


      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'Karbar-Shop-App/1.0.0',
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

        return productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load products: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getProducts: $e');
      throw Exception('Failed to load products: $e');
    }
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

          // Set default headers in ApiClient initialization or modify the get() method
          final response = await _apiClient.get(
            path,
            // If your ApiClient.get() doesn't support headers, you'll need to:
            // 1. Either modify the ApiClient to support headers
            // 2. Or set default headers when initializing the ApiClient
          );

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

  // ================ SEARCH API ================

  static Future<List<Product>> searchProducts(
      String searchQuery, {
        String category = ApiConstants.defaultCategory,
        int page = AppConfig.defaultPage,
        int perPage = AppConfig.defaultPerPage,
        String sortBy = AppConfig.defaultSortBy,
      }) async {
    if (searchQuery.trim().isEmpty) {
      throw ApiException('Search query cannot be empty');
    }

    return getProducts(
      search: searchQuery.trim(),
      category: category,
      page: page,
      perPage: perPage,
      sortBy: sortBy,
    );
  }

  // ================ CATEGORY PRODUCTS API ================

  static Future<List<Product>> getProductsByCategory(
      String categorySlug, {
        int page = AppConfig.defaultPage,
        int perPage = AppConfig.defaultPerPage,
        String sortBy = AppConfig.defaultSortBy,
      }) async {
    if (categorySlug.trim().isEmpty) {
      throw ApiException('Category slug cannot be empty');
    }

    return getProducts(
      category: categorySlug,
      page: page,
      perPage: perPage,
      sortBy: sortBy,
    );
  }

  // ================ HELPER METHODS ================

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

  // ================ UTILITY METHODS ================

  static void initialize() {
    _apiClient.initialize();
    Logger.logInfo('ApiService initialized');
  }

  static void dispose() {
    _apiClient.dispose();
    Logger.logInfo('ApiService disposed');
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
}