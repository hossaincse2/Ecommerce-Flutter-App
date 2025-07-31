// constants/order_api_constants.dart
class OrderApiConstants {
  // API Endpoints
  static const String orderStatusEndpoint = '/api/order-status';
  static const String userOrdersEndpoint = '/api/user/user-orders';
  static const String orderDetailsEndpoint = '/api/user/user-order-details';
  static const String cancelOrderEndpoint = '/api/user/cancel-order';
  static const String reorderEndpoint = '/api/user/reorder';
  static const String orderReviewEndpoint = '/api/user/order-review';
  static const String reportProblemEndpoint = '/api/user/report-problem';
  
  // Query Parameters
  static const String filterParam = 'filter';
  static const String pageParam = 'page';
  static const String perPageParam = 'perPage';
  
  // Filter Values
  static const String filterAll = 'all';
  static const String filterPending = 'pending';
  static const String filterProcessed = 'processed';
  static const String filterDelivered = 'delivered';
  static const String filterCompleted = 'completed';
  static const String filterCancelled = 'cancelled';
  
  // Status Values
  static const String statusPending = 'Pending';
  static const String statusProcessed = 'Processed';
  static const String statusDelivered = 'Delivered';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';
  
  // Default Values
  static const int defaultPage = 1;
  static const int defaultPerPage = 10;
  static const int maxPerPage = 100;
  static const int minPerPage = 1;
  
  // Error Messages
  static const String invalidOrderIdError = 'Invalid order ID';
  static const String orderNotFoundError = 'Order not found';
  static const String cancelOrderError = 'Unable to cancel order';
  static const String networkError = 'Network connection error';
  static const String unknownError = 'An unknown error occurred';
  static const String emptySearchQueryError = 'Search query cannot be empty';
  static const String invalidPageError = 'Page number must be greater than 0';
  static const String invalidPerPageError = 'Items per page must be between 1 and 100';
  
  // Success Messages
  static const String orderCancelledSuccess = 'Order cancelled successfully';
  static const String reorderSuccess = 'Items added to cart successfully';
  static const String reviewSubmittedSuccess = 'Review submitted successfully';
  static const String problemReportedSuccess = 'Problem reported successfully';
  
  // Cache Keys (if implementing caching)
  static const String ordersListCacheKey = 'orders_list';
  static const String orderDetailsCachePrefix = 'order_details_';
  static const String orderStatusCacheKey = 'order_status_list';
  
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 15);
  static const Duration longTimeout = Duration(minutes: 2);
  
  // Pagination
  static const int maxItemsToLoadAtOnce = 50;
  static const int preloadThreshold = 5; // Load more when 5 items from end
  
  // Rating Constraints
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int minReviewLength = 10;
  static const int maxReviewLength = 500;
  
  // Phone number validation
  static const String phoneRegexPattern = r'^[\+]?[0-9]{10,15}$';
  
  // Order number validation
  static const String orderNumberRegexPattern = r'^[0-9]{8,15}$';
  
  // Helper methods for validation
  static bool isValidOrderId(int? orderId) {
    return orderId != null && orderId > 0;
  }
  
  static bool isValidPage(int page) {
    return page >= 1;
  }
  
  static bool isValidPerPage(int perPage) {
    return perPage >= minPerPage && perPage <= maxPerPage;
  }
  
  static bool isValidRating(int rating) {
    return rating >= minRating && rating <= maxRating;
  }
  
  static bool isValidReviewText(String review) {
    final trimmed = review.trim();
    return trimmed.length >= minReviewLength && trimmed.length <= maxReviewLength;
  }
  
  static bool isValidSearchQuery(String query) {
    return query.trim().length >= 2;
  }
  
  static bool isValidPhoneNumber(String phone) {
    return RegExp(phoneRegexPattern).hasMatch(phone);
  }
  
  static bool isValidOrderNumber(String orderNumber) {
    return RegExp(orderNumberRegexPattern).hasMatch(orderNumber);
  }
  
  // Status mapping helpers
  static String mapStatusToFilter(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return filterPending;
      case 'shipped':
        return filterProcessed;
      case 'delivered':
        return filterCompleted;
      case 'cancelled':
        return filterCancelled;
      default:
        return filterAll;
    }
  }
  
  static String mapFilterToStatus(String filter) {
    switch (filter.toLowerCase()) {
      case filterPending:
        return statusPending;
      case filterProcessed:
        return statusProcessed;
      case filterDelivered:
      case filterCompleted:
        return statusCompleted;
      case filterCancelled:
        return statusCancelled;
      default:
        return '';
    }
  }
  
  // Build query parameters helper
  static Map<String, String> buildOrdersQuery({
    String filter = filterAll,
    int page = defaultPage,
    int perPage = defaultPerPage,
  }) {
    return {
      filterParam: filter,
      pageParam: page.toString(),
      perPageParam: perPage.toString(),
    };
  }
}