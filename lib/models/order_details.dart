// models/order_details.dart
import 'customer.dart';
import 'order.dart';
import 'order_item.dart';
import 'order_tracking.dart';

class OrderDetails {
  final int id;
  final String orderNumber;
  final String orderAt;
  final String paymentMethod;
  final double subTotal;
  final double deliveryFee;
  final int totalQuantity;
  final double totalAmount;
  final double vatAmount;
  final String status;
  final String deliveryLocation;
  final Customer customer;
  final List<OrderItem> orderItems;
  final List<OrderTracking> orderTracking;

  OrderDetails({
    required this.id,
    required this.orderNumber,
    required this.orderAt,
    required this.paymentMethod,
    required this.subTotal,
    required this.deliveryFee,
    required this.totalQuantity,
    required this.totalAmount,
    required this.vatAmount,
    required this.status,
    required this.deliveryLocation,
    required this.customer,
    required this.orderItems,
    required this.orderTracking,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      orderAt: json['order_at'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      subTotal: (json['sub_total'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      totalQuantity: json['total_quantity'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      vatAmount: (json['vat_amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      deliveryLocation: json['delivery_location'] ?? '',
      customer: Customer.fromJson(json['customer'] ?? {}),
      orderItems: (json['order_items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      orderTracking: (json['order_tracking'] as List<dynamic>? ?? [])
          .map((tracking) => OrderTracking.fromJson(tracking))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'order_at': orderAt,
      'payment_method': paymentMethod,
      'sub_total': subTotal,
      'delivery_fee': deliveryFee,
      'total_quantity': totalQuantity,
      'total_amount': totalAmount,
      'vat_amount': vatAmount,
      'status': status,
      'delivery_location': deliveryLocation,
      'customer': customer.toJson(),
      'order_items': orderItems.map((item) => item.toJson()).toList(),
      'order_tracking': orderTracking.map((tracking) => tracking.toJson()).toList(),
    };
  }

  // Helper methods
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Processing';
      case 'processed':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get canBeCancelled => status.toLowerCase() == 'pending';
  bool get canBeTracked => ['processed', 'delivered', 'completed'].contains(status.toLowerCase());
  bool get isDelivered => ['delivered', 'completed'].contains(status.toLowerCase());
}