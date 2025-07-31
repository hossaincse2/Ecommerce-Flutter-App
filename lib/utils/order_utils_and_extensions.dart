// utils/order_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import '../models/order_details.dart';
import '../models/order_item.dart';
import '../constants/app_constants.dart';

class OrderUtils {
  // ================ DATE FORMATTING ================
  
  static String formatOrderDate(String dateString) {
    try {
      // Try parsing different date formats
      DateTime? date;
      
      // Try parsing "Jul 31, 2025, 10:03 PM" format
      try {
        date = DateFormat('MMM dd, yyyy, hh:mm a').parse(dateString);
      } catch (e) {
        // Try other formats if needed
        try {
          date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
        } catch (e) {
          try {
            date = DateTime.parse(dateString);
          } catch (e) {
            return dateString; // Return original if can't parse
          }
        }
      }
      
      if (date != null) {
        return DateFormat('MMM dd, yyyy').format(date);
      }
      
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
  
  static String formatOrderDateTime(String dateString) {
    try {
      DateTime? date;
      
      try {
        date = DateFormat('MMM dd, yyyy, hh:mm a').parse(dateString);
      } catch (e) {
        try {
          date = DateTime.parse(dateString);
        } catch (e) {
          return dateString;
        }
      }
      
      if (date != null) {
        return DateFormat('MMM dd, yyyy at hh:mm a').format(date);
      }
      
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
  
  static String getRelativeTime(String dateString) {
    try {
      DateTime? date;
      
      try {
        date = DateFormat('MMM dd, yyyy, hh:mm a').parse(dateString);
      } catch (e) {
        try {
          date = DateTime.parse(dateString);
        } catch (e) {
          return dateString;
        }
      }
      
      if (date != null) {
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays > 7) {
          return DateFormat('MMM dd, yyyy').format(date);
        } else if (difference.inDays > 0) {
          return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
        } else {
          return 'Just now';
        }
      }
      
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
  
  // ================ CURRENCY FORMATTING ================
  
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }
  
  static String formatCurrencyCompact(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatCurrency(amount, symbol: symbol);
    }
  }
  
  // ================ STATUS HELPERS ================
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'processed':
      case 'shipped':
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
  
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
        return Icons.schedule;
      case 'processed':
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.radio_button_checked;
    }
  }
  
  // ================ VALIDATION HELPERS ================
  
  static bool canCancelOrder(String status) {
    return status.toLowerCase() == 'pending';
  }
  
  static bool canTrackOrder(String status) {
    return ['processed', 'shipped', 'delivered', 'completed'].contains(status.toLowerCase());
  }
  
  static bool canReorder(String status) {
    return ['delivered', 'completed', 'cancelled'].contains(status.toLowerCase());
  }
  
  static bool canReview(String status) {
    return ['delivered', 'completed'].contains(status.toLowerCase());
  }
  
  // ================ ORDER SUMMARY HELPERS ================
  
  static String getOrderSummary(OrderDetails order) {
    final items = order.orderItems.length;
    final total = formatCurrency(order.totalAmount);
    return '$items item${items > 1 ? 's' : ''} • $total';
  }
  
  static String getOrderItemsSummary(List<OrderItem> items) {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) return items.first.productName;
    
    final first = items.first.productName;
    final remaining = items.length - 1;
    return '$first + $remaining more item${remaining > 1 ? 's' : ''}';
  }
  
  // ================ DELIVERY LOCATION FORMATTING ================
  
  static String formatDeliveryLocation(String location) {
    return location
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
  
  // ================ SEARCH HELPERS ================
  
  static bool matchesSearchQuery(Order order, String query) {
    final lowercaseQuery = query.toLowerCase();
    return order.orderNumber.toLowerCase().contains(lowercaseQuery) ||
           order.status.toLowerCase().contains(lowercaseQuery) ||
           order.deliveryLocation.toLowerCase().contains(lowercaseQuery);
  }
  
  static bool matchesOrderDetailsSearchQuery(OrderDetails order, String query) {
    final lowercaseQuery = query.toLowerCase();
    return order.orderNumber.toLowerCase().contains(lowercaseQuery) ||
           order.status.toLowerCase().contains(lowercaseQuery) ||
           order.customer.name.toLowerCase().contains(lowercaseQuery) ||
           order.orderItems.any((item) => 
               item.productName.toLowerCase().contains(lowercaseQuery));
  }
  
  // ================ SORTING HELPERS ================
  
  static List<Order> sortOrders(List<Order> orders, String sortBy) {
    final sortedOrders = List<Order>.from(orders);
    
    switch (sortBy.toLowerCase()) {
      case 'date_desc':
        sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'date_asc':
        sortedOrders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'amount_desc':
        sortedOrders.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'amount_asc':
        sortedOrders.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case 'status':
        sortedOrders.sort((a, b) => a.status.compareTo(b.status));
        break;
      default:
        // Default sort by date descending
        sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return sortedOrders;
  }
  
  // ================ ANALYTICS HELPERS ================
  
  static Map<String, int> getOrderStatusCounts(List<Order> orders) {
    final counts = <String, int>{};
    
    for (final order in orders) {
      final status = order.filterStatus;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    
    return counts;
  }
  
  static double getTotalOrderValue(List<Order> orders) {
    return orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }
  
  static double getAverageOrderValue(List<Order> orders) {
    if (orders.isEmpty) return 0.0;
    return getTotalOrderValue(orders) / orders.length;
  }
  
  // ================ EXPORT HELPERS ================
  
  static Map<String, dynamic> orderToMap(Order order) {
    return {
      'Order Number': order.orderNumber,
      'Date': formatOrderDate(order.createdAt),
      'Status': order.displayStatus,
      'Items': order.totalQuantity,
      'Total Amount': formatCurrency(order.totalAmount),
      'Delivery Fee': formatCurrency(order.deliveryFee),
      'Location': formatDeliveryLocation(order.deliveryLocation),
    };
  }
  
  static Map<String, dynamic> orderDetailsToMap(OrderDetails order) {
    return {
      'Order Number': order.orderNumber,
      'Date': formatOrderDateTime(order.orderAt),
      'Status': order.displayStatus,
      'Customer': order.customer.name,
      'Phone': order.customer.phone,
      'Address': order.customer.address,
      'Items Count': order.orderItems.length,
      'Subtotal': formatCurrency(order.subTotal),
      'Delivery Fee': formatCurrency(order.deliveryFee),
      'VAT': formatCurrency(order.vatAmount),
      'Total': formatCurrency(order.totalAmount),
      'Payment Method': order.paymentMethod.toUpperCase(),
    };
  }
}

// ================ EXTENSIONS ================

extension OrderExtensions on Order {
  String get formattedDate => OrderUtils.formatOrderDate(createdAt);
  String get formattedDateTime => OrderUtils.formatOrderDateTime(createdAt);
  String get relativeTime => OrderUtils.getRelativeTime(createdAt);
  String get formattedTotal => OrderUtils.formatCurrency(totalAmount);
  String get formattedDeliveryFee => OrderUtils.formatCurrency(deliveryFee);
  String get formattedDeliveryLocation => OrderUtils.formatDeliveryLocation(deliveryLocation);
  
  Color get statusColor => OrderUtils.getStatusColor(status);
  Color get statusBackgroundColor => OrderUtils.getStatusBackgroundColor(status);
  IconData get statusIcon => OrderUtils.getStatusIcon(status);
  
  bool get canBeCancelled => OrderUtils.canCancelOrder(status);
  bool get canBeTracked => OrderUtils.canTrackOrder(status);
  bool get canBeReordered => OrderUtils.canReorder(status);
  bool get canBeReviewed => OrderUtils.canReview(status);
  
  String get itemsSummary => '$totalQuantity item${totalQuantity > 1 ? 's' : ''}';
  
  bool matchesSearch(String query) => OrderUtils.matchesSearchQuery(this, query);
  
  Map<String, dynamic> toExportMap() => OrderUtils.orderToMap(this);
}

extension OrderDetailsExtensions on OrderDetails {
  String get formattedDate => OrderUtils.formatOrderDate(orderAt);
  String get formattedDateTime => OrderUtils.formatOrderDateTime(orderAt);
  String get relativeTime => OrderUtils.getRelativeTime(orderAt);
  
  String get formattedSubTotal => OrderUtils.formatCurrency(subTotal);
  String get formattedDeliveryFee => OrderUtils.formatCurrency(deliveryFee);
  String get formattedVatAmount => OrderUtils.formatCurrency(vatAmount);
  String get formattedTotal => OrderUtils.formatCurrency(totalAmount);
  String get formattedDeliveryLocation => OrderUtils.formatDeliveryLocation(deliveryLocation);
  
  Color get statusColor => OrderUtils.getStatusColor(status);
  Color get statusBackgroundColor => OrderUtils.getStatusBackgroundColor(status);
  IconData get statusIcon => OrderUtils.getStatusIcon(status);
  
  String get orderSummary => OrderUtils.getOrderSummary(this);
  String get itemsSummary => OrderUtils.getOrderItemsSummary(orderItems);
  
  bool matchesSearch(String query) => OrderUtils.matchesOrderDetailsSearchQuery(this, query);
  
  Map<String, dynamic> toExportMap() => OrderUtils.orderDetailsToMap(this);
}

extension OrderItemExtensions on OrderItem {
  String get formattedPrice => OrderUtils.formatCurrency(price);
  String get formattedTotal => OrderUtils.formatCurrency(total);
  
  String get quantityText => 'Qty: $quantity';
  String get priceText => 'Unit: ${formattedPrice}';
  String get totalText => 'Total: ${formattedTotal}';
  
  bool get hasImage => productImage.isNotEmpty;
  bool get hasAttributes => attributes.isNotEmpty;
  bool get hasValidUrl => productUrl.isNotEmpty;
  
  String get attributesText => attributes.join(', ');
}

extension OrderListExtensions on List<Order> {
  List<Order> sortBy(String sortBy) => OrderUtils.sortOrders(this, sortBy);
  
  List<Order> filterByStatus(String status) {
    return where((order) => order.filterStatus == status.toLowerCase()).toList();
  }
  
  List<Order> search(String query) {
    return where((order) => order.matchesSearch(query)).toList();
  }
  
  Map<String, int> get statusCounts => OrderUtils.getOrderStatusCounts(this);
  double get totalValue => OrderUtils.getTotalOrderValue(this);
  double get averageValue => OrderUtils.getAverageOrderValue(this);
  
  List<Order> get pendingOrders => filterByStatus('processing');
  List<Order> get shippedOrders => filterByStatus('shipped');
  List<Order> get deliveredOrders => filterByStatus('delivered');
  List<Order> get cancelledOrders => filterByStatus('cancelled');
}