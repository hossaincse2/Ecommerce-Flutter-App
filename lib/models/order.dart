class Order {
  final int id;
  final String orderNumber;
  final int totalQuantity;
  final double totalAmount;
  final double deliveryFee;
  final String deliveryLocation;
  final double vatAmount;
  final String status;
  final String createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.totalQuantity,
    required this.totalAmount,
    required this.deliveryFee,
    required this.deliveryLocation,
    required this.vatAmount,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      totalQuantity: json['total_quantity'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      deliveryLocation: json['delivery_location'] ?? '',
      vatAmount: (json['vat_amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'total_quantity': totalQuantity,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'delivery_location': deliveryLocation,
      'vat_amount': vatAmount,
      'status': status,
      'created_at': createdAt,
    };
  }

  // Helper method to get display status
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

  // Helper method to get status for filtering
  String get filterStatus {
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
}