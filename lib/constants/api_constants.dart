class ApiConstants {
  // HTTP Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Cache-Control': 'no-cache',
  };

  static const Map<String, String> imageHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
    'Accept-Encoding': 'gzip, deflate, br',
    'Cache-Control': 'max-age=3600',
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
}