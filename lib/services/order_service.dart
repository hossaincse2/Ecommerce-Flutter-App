// services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/cart.dart';
import '../models/place_order.dart';
import '../utils/logger.dart';

class OrderService {
  static const String baseUrl = 'https://admin.karbar.shop/api';
  static const String orderEndpoint = '/product-order';

  // Enhanced method for authenticated users
  static Future<OrderResponse> placeOrderWithAuth({
    required Map<String, dynamic> orderData,
    String? authToken,
  }) async {
    try {
      // Prepare headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'KarbarShop-Mobile/1.0',
      };

      // Add auth token if provided
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
        Logger.logInfo('Placing order with authentication');
      } else {
        Logger.logInfo('Placing order as guest');
      }

      // Convert cart items to proper format
      List<Map<String, dynamic>> products = (orderData['cart_items'] as List).map((item) {
        return {
          'product_name': item['product_name'],
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
          'product_variant_id': item['variant']?['id'], // Include variant ID if available
          'total': item['total_price'],
        };
      }).toList();

      // Calculate total quantity
      int totalQuantity = (orderData['cart_items'] as List).fold<int>(0, (int sum, dynamic item) {
        return sum + (item['quantity'] as int);
      });

      // Build the final order payload
      Map<String, dynamic> orderPayload = {
        'name': orderData['name'],
        'phone': orderData['phone'],
        'email': orderData['email'],
        'address': orderData['address'],
        'special_instruction': orderData['special_instruction'] ?? '',
        'payment_method': _convertPaymentMethod(orderData['payment_method']),
        'products': products,
        'delivery_fee': orderData['delivery_fee'],
        'total_quantity': totalQuantity,
        'total_amount': orderData['total_amount'],
        'delivery_location': orderData['delivery_location'] ?? 'inside_dhaka',
        'currency': 'bdt',
        'discount_amount': orderData['discount_amount'] ?? 0,
        'sub_total': orderData['sub_total'],
        'create_account': false,
      };

      Logger.logInfo('Placing order with payload: ${json.encode(orderPayload)}');

      final response = await http.post(
        Uri.parse('$baseUrl$orderEndpoint'),
        headers: headers,
        body: json.encode(orderPayload),
      );

      Logger.logInfo('Order API Response Status: ${response.statusCode}');
      Logger.logInfo('Order API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final orderResponse = OrderResponse.fromJson(responseData);

        if (orderResponse.success) {
          Logger.logSuccess('Order placed successfully');
          return orderResponse;
        } else {
          Logger.logError('Order failed: ${orderResponse.message}');
          return OrderResponse(
            success: false,
            message: orderResponse.message.isNotEmpty
                ? orderResponse.message
                : 'Failed to place order',
          );
        }
      } else {
        Logger.logError('Order API error: ${response.statusCode} - ${response.reasonPhrase}');

        // Try to parse error message from response
        try {
          final errorData = json.decode(response.body);
          String errorMessage = errorData['message'] ?? 'Failed to place order';

          // Handle specific auth errors
          if (response.statusCode == 401) {
            errorMessage = 'Session expired. Please login again.';
          }

          return OrderResponse(success: false, message: errorMessage);
        } catch (e) {
          return OrderResponse(
            success: false,
            message: 'Failed to place order. Please try again.',
          );
        }
      }
    } catch (e) {
      Logger.logError('Error placing order', e);
      return OrderResponse(
        success: false,
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }

  // Get user orders (for authenticated users)
  static Future<List<dynamic>> getUserOrders(String authToken) async {
    try {
      Logger.logInfo('Fetching user orders');

      final response = await http.get(
        Uri.parse('$baseUrl/user/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
          'User-Agent': 'KarbarShop-Mobile/1.0',
        },
      );

      Logger.logInfo('User orders response status: ${response.statusCode}');
      Logger.logInfo('User orders response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          Logger.logSuccess('Successfully fetched user orders');
          return responseData['orders'] ?? responseData['data'] ?? [];
        } else {
          Logger.logError('Failed to fetch orders: ${responseData['message']}');
          return [];
        }
      } else if (response.statusCode == 401) {
        Logger.logError('Unauthorized - Invalid or expired token');
        throw Exception('Session expired. Please login again.');
      } else {
        Logger.logError('Orders API error: ${response.statusCode}');
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
      Logger.logError('Error fetching user orders', e);
      rethrow;
    }
  }

  // Get order details by ID (for authenticated users)
  static Future<Map<String, dynamic>?> getOrderDetails(String authToken, String orderId) async {
    try {
      Logger.logInfo('Fetching order details for ID: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/user/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
          'User-Agent': 'KarbarShop-Mobile/1.0',
        },
      );

      Logger.logInfo('Order details response status: ${response.statusCode}');
      Logger.logInfo('Order details response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          Logger.logSuccess('Successfully fetched order details');
          return responseData['order'] ?? responseData['data'];
        } else {
          Logger.logError('Failed to fetch order details: ${responseData['message']}');
          return null;
        }
      } else if (response.statusCode == 401) {
        Logger.logError('Unauthorized - Invalid or expired token');
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        Logger.logError('Order not found');
        throw Exception('Order not found');
      } else {
        Logger.logError('Order details API error: ${response.statusCode}');
        throw Exception('Failed to fetch order details');
      }
    } catch (e) {
      Logger.logError('Error fetching order details', e);
      rethrow;
    }
  }

  // Legacy method for backward compatibility (guest orders)
  static Future<OrderResponse> placeOrder({
    required String name,
    required String phone,
    required String email,
    required String address,
    String specialInstruction = '',
    required String paymentMethod,
    required List<CartItem> cartItems,
    required double deliveryFee,
    required double subTotal,
    required double totalAmount,
    String deliveryLocation = 'inside_dhaka',
    String currency = 'bdt',
    double discountAmount = 0,
    bool createAccount = false,
  }) async {
    try {
      // Convert cart items to order products
      List<OrderProduct> products = cartItems.map((item) {
        return OrderProduct(
          productName: item.productName,
          productId: item.productId,
          quantity: item.quantity,
          price: item.effectivePrice,
          // Set variant ID to null for now - update this when you know the correct property name
          productVariantId: null, // item.selectedVariant?.correctPropertyName,
          total: item.totalPrice,
        );
      }).toList();

      // Create order request
      OrderRequest orderRequest = OrderRequest(
        name: name,
        phone: phone,
        email: email,
        address: address,
        specialInstruction: specialInstruction,
        paymentMethod: _convertPaymentMethod(paymentMethod),
        products: products,
        deliveryFee: deliveryFee,
        totalQuantity: cartItems.fold(0, (sum, item) => sum + item.quantity),
        totalAmount: totalAmount,
        deliveryLocation: deliveryLocation,
        currency: currency,
        discountAmount: discountAmount,
        subTotal: subTotal,
        createAccount: createAccount,
      );

      Logger.logInfo('Placing guest order with payload: ${json.encode(orderRequest.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl$orderEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'KarbarShop-Mobile/1.0',
        },
        body: json.encode(orderRequest.toJson()),
      );

      Logger.logInfo('Order API Response Status: ${response.statusCode}');
      Logger.logInfo('Order API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final orderResponse = OrderResponse.fromJson(responseData);

        if (orderResponse.success) {
          Logger.logSuccess('Order placed successfully');
          return orderResponse;
        } else {
          Logger.logError('Order failed: ${orderResponse.message}');
          return OrderResponse(
            success: false,
            message: orderResponse.message.isNotEmpty
                ? orderResponse.message
                : 'Failed to place order',
          );
        }
      } else {
        Logger.logError('Order API error: ${response.statusCode} - ${response.reasonPhrase}');

        // Try to parse error message from response
        try {
          final errorData = json.decode(response.body);
          String errorMessage = errorData['message'] ?? 'Failed to place order';
          return OrderResponse(success: false, message: errorMessage);
        } catch (e) {
          return OrderResponse(
            success: false,
            message: 'Failed to place order. Please try again.',
          );
        }
      }
    } catch (e) {
      Logger.logError('Error placing order', e);
      return OrderResponse(
        success: false,
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }

  // Convert payment method to API format
  static String _convertPaymentMethod(String paymentMethod) {
    switch (paymentMethod) {
      case 'cash_on_delivery':
        return 'cash';
      case 'mobile_banking':
        return 'online';
      default:
        return 'cash';
    }
  }

  // Validate order data before placing
  static Map<String, dynamic> validateOrderData({
    required String name,
    required String phone,
    required String address,
    required List<CartItem> cartItems,
  }) {
    List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add('Name is required');
    }

    if (phone.trim().isEmpty) {
      errors.add('Phone number is required');
    } else if (!_isValidPhoneNumber(phone)) {
      errors.add('Please enter a valid phone number');
    }

    if (address.trim().isEmpty) {
      errors.add('Delivery address is required');
    }

    if (cartItems.isEmpty) {
      errors.add('Cart is empty');
    }

    // Validate cart items
    for (var item in cartItems) {
      if (item.quantity <= 0) {
        errors.add('Invalid quantity for ${item.productName}');
      }
      if (item.effectivePrice <= 0) {
        errors.add('Invalid price for ${item.productName}');
      }
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  // Simple phone number validation for Bangladesh
  static bool _isValidPhoneNumber(String phone) {
    // Remove spaces and special characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Bangladesh phone number patterns
    // Mobile: 01xxxxxxxxx (11 digits)
    // With country code: 8801xxxxxxxxx (13 digits)
    return cleanPhone.length == 11 && cleanPhone.startsWith('01') ||
        cleanPhone.length == 13 && cleanPhone.startsWith('8801');
  }

  // Helper methods for auth error handling
  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }

  static bool isNetworkError(dynamic error) {
    return error.toString().contains('Network') ||
        error.toString().contains('connection') ||
        error.toString().contains('timeout');
  }

  static bool isAuthError(dynamic error) {
    return error.toString().contains('Session expired') ||
        error.toString().contains('Unauthorized') ||
        error.toString().contains('Invalid token');
  }
}