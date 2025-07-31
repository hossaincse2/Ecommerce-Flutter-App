// models/models.dart - Barrel file for all order-related models

// Export all order models
import 'dart:ui';

import 'package:flutter/material.dart';

export 'order.dart';
export 'order_details.dart';
export 'order_item.dart';
export 'order_tracking.dart';
export 'customer.dart';
export 'orders_response.dart';

// Customer model (if not already created)
class Customer {
  final String name;
  final String phone;
  final String address;

  Customer({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  // Helper methods
  bool get hasPhone => phone.isNotEmpty;
  bool get hasAddress => address.isNotEmpty;

  String get displayAddress {
    if (address.isEmpty) return 'No address provided';
    return address;
  }

  String get displayPhone {
    if (phone.isEmpty) return 'No phone provided';
    return phone;
  }
}

// Order Status Helper
class OrderStatus {
  static const String pending = 'Pending';
  static const String processed = 'Processed';
  static const String delivered = 'Delivered';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  static const List<String> allStatuses = [
    pending,
    processed,
    delivered,
    completed,
    cancelled,
  ];

  static String getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Processing';
      case 'processed':
        return 'Shipped';
      case 'delivered':
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  static String getFilterStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'processing';
      case 'processed':
        return 'shipped';
      case 'delivered':
      case 'completed':
        return 'delivered';
      case 'cancelled':
        return 'cancelled';
      default:
        return status.toLowerCase();
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processed':
        return Colors.blue;
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Color getStatusBackgroundColor(String status) {
    return getStatusColor(status).withOpacity(0.1);
  }
}