// models/place_order.dart
class OrderRequest {
  final String name;
  final String phone;
  final String email;
  final String address;
  final String specialInstruction;
  final String paymentMethod;
  final List<OrderProduct> products;
  final double deliveryFee;
  final int totalQuantity;
  final double totalAmount;
  final String deliveryLocation;
  final String currency;
  final double discountAmount;
  final double subTotal;
  final bool createAccount;

  OrderRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.specialInstruction,
    required this.paymentMethod,
    required this.products,
    required this.deliveryFee,
    required this.totalQuantity,
    required this.totalAmount,
    required this.deliveryLocation,
    required this.currency,
    required this.discountAmount,
    required this.subTotal,
    required this.createAccount,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'spacial_instruction': specialInstruction,
      'payment_method': paymentMethod,
      'products': products.map((p) => p.toJson()).toList(),
      'delivery_fee': deliveryFee,
      'total_quantity': totalQuantity,
      'total_amount': totalAmount,
      'delivery_location': deliveryLocation,
      'currency': currency,
      'discount_amount': discountAmount,
      'sub_total': subTotal,
      'create_account': createAccount,
    };
  }
}

class OrderProduct {
  final String productName;
  final int productId;
  final int quantity;
  final double price;
  final int? productVariantId;
  final double total;

  OrderProduct({
    required this.productName,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productVariantId,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'product_variant_id': productVariantId,
      'total': total,
    };
  }
}

class OrderResponse {
  final bool success;
  final String message;
  final OrderData? data;

  OrderResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    // Handle both boolean and string values for success
    bool isSuccess = false;
    String message = '';

    // Check if success is a boolean
    if (json['success'] is bool) {
      isSuccess = json['success'];
      message = json['message'] ?? '';
    }
    // If success is a string, treat non-empty strings as success
    else if (json['success'] is String) {
      String successString = json['success'] as String;
      isSuccess = successString.isNotEmpty;
      message = successString;
    }
    // Handle case where success field might be missing
    else {
      // If there's an order_number, consider it successful
      isSuccess = json['order_number'] != null;
      message = json['message'] ?? (isSuccess ? 'Order placed successfully' : 'Unknown error');
    }

    return OrderResponse(
      success: isSuccess,
      message: message,
      data: json['data'] != null ? OrderData.fromJson(json['data']) :
      (json['order_number'] != null ? OrderData.fromJson(json) : null),
    );
  }
}

class OrderData {
  final String? orderId;
  final String? orderNumber;
  final String? status;

  OrderData({
    this.orderId,
    this.orderNumber,
    this.status,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orderId: json['order_id']?.toString(),
      orderNumber: json['order_number']?.toString(),
      status: json['status']?.toString(),
    );
  }
}