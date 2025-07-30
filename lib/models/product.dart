class Product {
  final int id;
  final String name;
  final String slug;
  final double unitPrice;
  final double salePrice;
  final int stock;
  final String category;
  final String brand;
  final String previewImage;
  final bool freeDelivery;
  final bool preOrder;
  final String lastMonthSoldItem;
  final double productRating;
  final String totalRating;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.unitPrice,
    required this.salePrice,
    required this.stock,
    required this.category,
    required this.brand,
    required this.previewImage,
    required this.freeDelivery,
    required this.preOrder,
    required this.lastMonthSoldItem,
    required this.productRating,
    required this.totalRating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      previewImage: json['preview_image'] ?? '',
      freeDelivery: json['free_delivery'] ?? false,
      preOrder: json['pre_order'] ?? false,
      lastMonthSoldItem: json['last_month_sold_item'] ?? '',
      productRating: (json['product_rating'] ?? 0).toDouble(),
      totalRating: json['total_rating'] ?? '0',
    );
  }
}