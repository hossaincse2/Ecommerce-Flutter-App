class OrderItem {
  final int quantity;
  final double price;
  final double total;
  final String productName;
  final List<dynamic> attributes;
  final String productUrl;
  final String productImage;

  OrderItem({
    required this.quantity,
    required this.price,
    required this.total,
    required this.productName,
    required this.attributes,
    required this.productUrl,
    required this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      productName: json['product_name'] ?? '',
      attributes: json['attributes'] ?? [],
      productUrl: json['product_url'] ?? '',
      productImage: json['product_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'price': price,
      'total': total,
      'product_name': productName,
      'attributes': attributes,
      'product_url': productUrl,
      'product_image': productImage,
    };
  }
}