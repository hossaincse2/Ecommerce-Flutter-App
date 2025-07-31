// services/order_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order.dart';
import '../models/order_details.dart';
import '../models/orders_response.dart';
import '../config/app_config.dart';
import '../services/auth_manager.dart';
import '../utils/logger.dart';

class OrderApiService {
  static final AuthManager _authManager = AuthManager();

  // ================ HELPER METHOD FOR AUTHENTICATED HEADERS ================

  static Future<Map<String, String>> _getAuthHeaders() async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'User-Agent': 'Karbar-Shop-App/1.0.0',
      'Cache-Control': 'no-cache',
    };

    // Get the auth token
    if (_authManager.isLoggedIn && _authManager.hasValidToken()) {
      final token = await _authManager.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ================ ORDER STATUS API ================

  static Future<List<String>> getOrderStatuses() async {
    try {
      Logger.logInfo('Fetching order statuses');

      final uri = Uri.parse('${AppConfig.baseUrl}/order-status');
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers)
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> statusList = data['data'] ?? [];
        final statuses = statusList.map((status) => status.toString()).toList();

        Logger.logSuccess('Successfully fetched ${statuses.length} order statuses');
        return statuses;
      } else if (response.statusCode == 401) {
        Logger.logError('Authentication failed for order statuses', null);
        throw ApiException('Authentication failed. Please login again.', statusCode: 401);
      } else {
        Logger.logError('Failed to load order statuses: HTTP ${response.statusCode}', null);
        throw ApiException('Failed to fetch order statuses: HTTP ${response.statusCode}');
      }

    } catch (e) {
      Logger.logError('Error fetching order statuses', e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch order statuses: $e');
    }
  }

  // ================ USER ORDERS API ================

  static Future<OrdersResponse> getUserOrders({
    String filter = 'all',
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      _validatePaginationParams(page, perPage);

      // Check if user is authenticated
      if (!_authManager.isLoggedIn || !_authManager.hasValidToken()) {
        throw ApiException('User not authenticated. Please login first.', statusCode: 401);
      }

      final queryParameters = {
        'filter': filter,
        'page': page.toString(),
        'perPage': perPage.toString(),
      };

      Logger.logInfo('Fetching user orders with filter: $filter, page: $page');

      final uri = Uri.parse('${AppConfig.baseUrl}/user/user-orders')
          .replace(queryParameters: queryParameters);

      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers)
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ordersResponse = OrdersResponse.fromJson(data);

        Logger.logSuccess('Successfully fetched ${ordersResponse.data.length} orders');
        return ordersResponse;
      } else if (response.statusCode == 401) {
        Logger.logError('Authentication failed for user orders', null);
        // Clear invalid token
        await _authManager.logout();
        throw ApiException('Authentication failed. Please login again.', statusCode: 401);
      } else {
        Logger.logError('Failed to load user orders: HTTP ${response.statusCode}', null);
        throw ApiException('Failed to fetch user orders: HTTP ${response.statusCode}');
      }

    } catch (e) {
      Logger.logError('Error fetching user orders', e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch user orders: $e');
    }
  }

  // ================ FILTERED ORDERS API ================

  static Future<List<Order>> getOrdersByStatus(String status, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final filter = _mapStatusToFilter(status);
      final response = await getUserOrders(
        filter: filter,
        page: page,
        perPage: perPage,
      );

      // Filter orders by status on client side if needed
      final filteredOrders = response.data.where((order) {
        return order.filterStatus == status.toLowerCase();
      }).toList();

      Logger.logInfo('Filtered ${filteredOrders.length} orders with status: $status');
      return filteredOrders;

    } catch (e) {
      Logger.logError('Error fetching orders by status', e);
      throw ApiException('Failed to fetch orders by status: $e');
    }
  }

  // ================ ORDER DETAILS API ================

  static Future<OrderDetails> getOrderDetails(int orderId) async {
    try {
      if (orderId <= 0) {
        throw ApiException('Invalid order ID');
      }

      // Check if user is authenticated
      if (!_authManager.isLoggedIn || !_authManager.hasValidToken()) {
        throw ApiException('User not authenticated. Please login first.', statusCode: 401);
      }

      Logger.logInfo('Fetching order details for ID: $orderId');

      final uri = Uri.parse('${AppConfig.baseUrl}/user/user-order-details/$orderId');
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers)
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orderDetails = OrderDetails.fromJson(data['data']);

        Logger.logSuccess('Successfully fetched order details for ID: $orderId');
        return orderDetails;
      } else if (response.statusCode == 401) {
        Logger.logError('Authentication failed for order details', null);
        await _authManager.logout();
        throw ApiException('Authentication failed. Please login again.', statusCode: 401);
      } else if (response.statusCode == 404) {
        Logger.logError('Order not found: $orderId', null);
        throw ApiException('Order not found', statusCode: 404);
      } else {
        Logger.logError('Failed to load order details: HTTP ${response.statusCode}', null);
        throw ApiException('Failed to fetch order details: HTTP ${response.statusCode}');
      }

    } catch (e) {
      Logger.logError('Error fetching order details', e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch order details: $e');
    }
  }

  // ================ ORDER ACTIONS API ================

  static Future<bool> cancelOrder(int orderId) async {
    try {
      if (orderId <= 0) {
        throw ApiException('Invalid order ID');
      }

      // Check if user is authenticated
      if (!_authManager.isLoggedIn || !_authManager.hasValidToken()) {
        throw ApiException('User not authenticated. Please login first.', statusCode: 401);
      }

      Logger.logInfo('Cancelling order ID: $orderId');

      final uri = Uri.parse('${AppConfig.baseUrl}/user/cancel-order');
      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({'order_id': orderId}),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        Logger.logSuccess('Successfully cancelled order ID: $orderId');
        return true;
      } else if (response.statusCode == 401) {
        Logger.logError('Authentication failed for cancel order', null);
        await _authManager.logout();
        throw ApiException('Authentication failed. Please login again.', statusCode: 401);
      } else {
        Logger.logError('Failed to cancel order: HTTP ${response.statusCode}', null);
        throw ApiException('Failed to cancel order: HTTP ${response.statusCode}');
      }

    } catch (e) {
      Logger.logError('Error cancelling order', e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to cancel order: $e');
    }
  }

  static Future<bool> reorderItems(int orderId) async {
    try {
      if (orderId <= 0) {
        throw ApiException('Invalid order ID');
      }

      // Check if user is authenticated
      if (!_authManager.isLoggedIn || !_authManager.hasValidToken()) {
        throw ApiException('User not authenticated. Please login first.', statusCode: 401);
      }

      Logger.logInfo('Reordering items for order ID: $orderId');

      final uri = Uri.parse('${AppConfig.baseUrl}/user/reorder');
      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({'order_id': orderId}),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        Logger.logSuccess('Successfully reordered items for order ID: $orderId');
        return true;
      } else if (response.statusCode == 401) {
        Logger.logError('Authentication failed for reorder', null);
        await _authManager.logout();
        throw ApiException('Authentication failed. Please login again.', statusCode: 401);
      } else {
        Logger.logError('Failed to reorder items: HTTP ${response.statusCode}', null);
        throw ApiException('Failed to reorder items: HTTP ${response.statusCode}');
      }

    } catch (e) {
      Logger.logError('Error reordering items', e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to reorder items: $e');
    }
  }

  // ================ SEARCH ORDERS API ================

  static Future<List<Order>> searchOrders(String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      if (query.trim().isEmpty) {
        throw ApiException('Search query cannot be empty');
      }

      Logger.logInfo('Searching orders with query: "$query"');

      // Get all orders and filter by order number or product name
      final response = await getUserOrders(page: page, perPage: perPage);

      // Filter orders client-side by order number
      final filteredOrders = response.data.where((order) {
        return order.orderNumber.toLowerCase().contains(query.toLowerCase());
      }).toList();

      Logger.logSuccess('Found ${filteredOrders.length} orders matching query: "$query"');
      return filteredOrders;

    } catch (e) {
      Logger.logError('Error searching orders', e);
      throw ApiException('Failed to search orders: $e');
    }
  }

  // ================ REVIEW AND SUPPORT APIs ================

  static Future<bool> submitOrderReview({
    required int orderId,
    required int rating,
    required String review,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw ApiException('Rating must be between 1 and 5');
      }

      if (review.trim().isEmpty) {
        throw ApiException('Review cannot be empty');
      }

      // Check if user is authenticated
      if (!_authManager.isLoggedIn || !_authManager.hasValidToken()) {
        throw ApiException('User not authenticated. Please login first.', statusCode: 401);
      }

      Logger.logInfo('Submitting review for order ID: $orderId');

      final uri = Uri.parse('${AppConfig.baseUrl}/user/order-review');
      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'order_id': orderId,
          'rating': rating,
          'review': review.trim(),
        }),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        Logger.logSuccess('Successfully submitted review for order ID: $orderId');
        return true;
      } else if (response.statusCode == 401) {
        Logger.logError('Authentication failed for submit review', null);
        await _authManager.logout();
        throw ApiException('Authentication failed. Please login again.', statusCode: 401);
      } else {
        Logger.logError('Failed to submit review: HTTP ${response.statusCode}', null);
        throw ApiException('Failed to submit review: HTTP ${response.statusCode}');
      }

    } catch (e) {
      Logger.logError('Error submitting order review', e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to submit review: $e');
    }
  }

  static Future<bool> reportOrderProblem({
    required int orderId,
    required String problemType,
    required String description,
  }) async {
    try {
      if (description.trim().isEmpty) {
        throw ApiException('Problem description cannot be empty');
      }

      // Check if user is authenticated
      if (!_authManager.isLoggedIn || !_authManager.hasValidToken()) {
        throw ApiException('User not authenticated. Please login first.', statusCode: 401);
      }

      Logger.logInfo('Reporting problem for order ID: $orderId');

      final uri = Uri.parse('${AppConfig.baseUrl}/user/report-problem');
      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'order_id': orderId,
          'problem_type': problemType,
          'description': description.trim(),
        }),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        Logger.logSuccess('Successfully reported problem for order ID: $orderId');
        return true;
      } else if (response.statusCode == 401) {
        Logger.logError('Authentication failed for report problem', null);
        await _authManager.logout();
        throw ApiException('Authentication failed. Please login again.', statusCode: 401);
      } else {
        Logger.logError('Failed to report problem: HTTP ${response.statusCode}', null);
        throw ApiException('Failed to report problem: HTTP ${response.statusCode}');
      }

    } catch (e) {
      Logger.logError('Error reporting order problem', e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to report problem: $e');
    }
  }

  // ================ HELPER METHODS ================

  static String _mapStatusToFilter(String status) {
    // Map display status to API filter value
    final filterMapping = {
      'processing': 'pending',
      'shipped': 'processed',
      'delivered': 'completed',
      'cancelled': 'cancelled',
    };

    return filterMapping[status.toLowerCase()] ?? 'all';
  }

  static String _mapFilterToDisplayStatus(String filter) {
    // Map API filter to display status
    final statusMapping = {
      'pending': 'processing',
      'processed': 'shipped',
      'delivered': 'delivered',
      'completed': 'delivered',
      'cancelled': 'cancelled',
    };

    return statusMapping[filter.toLowerCase()] ?? filter;
  }

  static void _validatePaginationParams(int page, int perPage) {
    if (page < 1) {
      throw ApiException('Page number must be greater than 0');
    }

    if (perPage < 1 || perPage > 100) {
      throw ApiException('Items per page must be between 1 and 100');
    }
  }

  // ================ REFRESH AND SYNC ================

  static Future<void> refreshOrders() async {
    try {
      Logger.logInfo('Refreshing orders data');
      // Clear any cached orders data if you have caching
      // This method can be called to force refresh
    } catch (e) {
      Logger.logError('Error refreshing orders', e);
      throw ApiException('Failed to refresh orders: $e');
    }
  }

  // ================ UTILITY METHODS ================

  static Future<void> initialize() async {
    try {
      await _authManager.initialize();
      Logger.logInfo('OrderApiService initialized with authentication');
    } catch (e) {
      Logger.logError('Failed to initialize OrderApiService', e);
      Logger.logInfo('OrderApiService initialized without authentication');
    }
  }

  static void dispose() {
    Logger.logInfo('OrderApiService disposed');
  }

  // ================ ERROR HANDLING ================

  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'An unknown error occurred';
  }

  static bool isNetworkError(dynamic error) {
    if (error is ApiException) {
      return error.message.contains('Network') ||
          error.message.contains('connection') ||
          error.message.contains('timeout');
    }
    return false;
  }

  static bool isAuthenticationError(dynamic error) {
    if (error is ApiException) {
      return error.statusCode == 401 ||
          error.message.contains('Authentication failed') ||
          error.message.contains('not authenticated');
    }
    return false;
  }

  static bool isOrderNotFoundError(dynamic error) {
    if (error is ApiException) {
      return error.statusCode == 404 ||
          error.message.toLowerCase().contains('not found');
    }
    return false;
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