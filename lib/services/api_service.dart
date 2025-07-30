import '../models/product.dart';
import '../models/category.dart';
import '../models/hero_image.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../services/api_client.dart';
import '../utils/logger.dart';

class ApiService {
  static final ApiClient _apiClient = ApiClient();

  // ================ PRODUCTS API ================

  static Future<List<Product>> getProducts({
    String search = ApiConstants.defaultSearch,
    String category = ApiConstants.defaultCategory,
    String subCategory = ApiConstants.defaultSubCategory,
    int page = AppConfig.defaultPage,
    int perPage = AppConfig.defaultPerPage,
    String sortBy = AppConfig.defaultSortBy,
    String brandId = ApiConstants.defaultBrandId,
    String businessCategory = AppConfig.defaultBusinessCategory,
  }) async {
    try {
      // Validate parameters
      _validatePaginationParams(page, perPage);

      final queryParameters = _buildProductsQueryParams(
        search: search,
        category: category,
        subCategory: subCategory,
        page: page,
        perPage: perPage,
        sortBy: sortBy,
        brandId: brandId,
        businessCategory: businessCategory,
      );

      Logger.logInfo('Fetching products with params: $queryParameters');

      final response = await _apiClient.get(
        AppConfig.productsEndpoint,
        queryParameters: queryParameters,
      );

      final List<dynamic> productsList = response['data'] ?? [];
      final products = productsList.map((json) => Product.fromJson(json)).toList();

      Logger.logSuccess('Successfully fetched ${products.length} products');
      return products;

    } on ApiException {
      rethrow;
    } catch (e) {
      Logger.logError('Error fetching products', e);
      throw ApiException('Failed to fetch products: $e');
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
        String subCategory = ApiConstants.defaultSubCategory,
        int page = AppConfig.defaultPage,
        int perPage = AppConfig.defaultPerPage,
        String sortBy = AppConfig.defaultSortBy,
      }) async {
    if (categorySlug.trim().isEmpty) {
      throw ApiException('Category slug cannot be empty');
    }

    return getProducts(
      category: categorySlug,
      subCategory: subCategory,
      page: page,
      perPage: perPage,
      sortBy: sortBy,
    );
  }

  // ================ HELPER METHODS ================

  static Map<String, String> _buildProductsQueryParams({
    required String search,
    required String category,
    required String subCategory,
    required int page,
    required int perPage,
    required String sortBy,
    required String brandId,
    required String businessCategory,
  }) {
    final params = <String, String>{};

    if (search.isNotEmpty) params[ApiConstants.searchParam] = search;
    if (category.isNotEmpty) params[ApiConstants.categoryParam] = category;
    if (subCategory.isNotEmpty) params[ApiConstants.subCategoryParam] = subCategory;
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