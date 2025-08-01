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

      Logger.logInfo('Placing order with payload: ${json.encode(orderRequest.toJson())}');

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
}