class ProductDetails {
  final int id;
  final String uuid;
  final String name;
  final String slug;
  final String skuCode;
  final double unitPrice;
  final double salePrice;
  final int stock;
  final String? description;
  final String? summary;
  final String category;
  final List<Review> reviews;
  final List<ProductVariant> variants;
  final List<ProductImage> productImages;
  final String previewImage;
  final int totalRatings;
  final double averageRating;
  final int totalFiveStars;
  final int totalFourStars;
  final int totalThreeStars;
  final int totalTwoStars;
  final int totalOneStars;
  final Campaign? campaign;
  final String currency;
  final String? videoLink;
  final String productUnit;
  final bool freeDelivery;
  final bool preOrder;
  final List<RelatedProduct> relatedProducts;
  final String imagePreviewStyle;

  ProductDetails({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    required this.skuCode,
    required this.unitPrice,
    required this.salePrice,
    required this.stock,
    this.description,
    this.summary,
    required this.category,
    required this.reviews,
    required this.variants,
    required this.productImages,
    required this.previewImage,
    required this.totalRatings,
    required this.averageRating,
    required this.totalFiveStars,
    required this.totalFourStars,
    required this.totalThreeStars,
    required this.totalTwoStars,
    required this.totalOneStars,
    this.campaign,
    required this.currency,
    this.videoLink,
    required this.productUnit,
    required this.freeDelivery,
    required this.preOrder,
    required this.relatedProducts,
    required this.imagePreviewStyle,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      skuCode: json['sku_code'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      description: json['description'],
      summary: json['summary'],
      category: json['category'] ?? '',
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((item) => Review.fromJson(item))
          .toList(),
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((item) => ProductVariant.fromJson(item))
          .toList(),
      productImages: (json['product_images'] as List<dynamic>? ?? [])
          .map((item) => ProductImage.fromJson(item))
          .toList(),
      previewImage: json['preview_image'] ?? '',
      totalRatings: json['total_ratings'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalFiveStars: json['total_five_stars'] ?? 0,
      totalFourStars: json['total_four_stars'] ?? 0,
      totalThreeStars: json['total_three_stars'] ?? 0,
      totalTwoStars: json['total_two_stars'] ?? 0,
      totalOneStars: json['total_one_stars'] ?? 0,
      campaign: json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      currency: json['currency'] ?? 'bdt',
      videoLink: json['video_link'],
      productUnit: json['product_unit'] ?? 'piece',
      freeDelivery: json['free_delivery'] ?? false,
      preOrder: json['pre_order'] ?? false,
      relatedProducts: (json['related_products'] as List<dynamic>? ?? [])
          .map((item) => RelatedProduct.fromJson(item))
          .toList(),
      imagePreviewStyle: json['image_preview_style'] ?? 'portrait',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'slug': slug,
      'sku_code': skuCode,
      'unit_price': unitPrice,
      'sale_price': salePrice,
      'stock': stock,
      'description': description,
      'summary': summary,
      'category': category,
      'reviews': reviews.map((item) => item.toJson()).toList(),
      'variants': variants.map((item) => item.toJson()).toList(),
      'product_images': productImages.map((item) => item.toJson()).toList(),
      'preview_image': previewImage,
      'total_ratings': totalRatings,
      'average_rating': averageRating,
      'total_five_stars': totalFiveStars,
      'total_four_stars': totalFourStars,
      'total_three_stars': totalThreeStars,
      'total_two_stars': totalTwoStars,
      'total_one_stars': totalOneStars,
      'campaign': campaign?.toJson(),
      'currency': currency,
      'video_link': videoLink,
      'product_unit': productUnit,
      'free_delivery': freeDelivery,
      'pre_order': preOrder,
      'related_products': relatedProducts.map((item) => item.toJson()).toList(),
      'image_preview_style': imagePreviewStyle,
    };
  }
}

class ProductImage {
  final String previewUrl;
  final String originalUrl;

  ProductImage({
    required this.previewUrl,
    required this.originalUrl,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      previewUrl: json['preview_url'] ?? '',
      originalUrl: json['original_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preview_url': previewUrl,
      'original_url': originalUrl,
    };
  }
}

class RelatedProduct {
  final int id;
  final String uuid;
  final String name;
  final String slug;
  final int salesCount;
  final String skuCode;
  final double unitPrice;
  final double salePrice;
  final int stock;
  final String category;
  final Campaign? campaign;
  final String categorySlug;
  final String previewImage;

  RelatedProduct({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    required this.salesCount,
    required this.skuCode,
    required this.unitPrice,
    required this.salePrice,
    required this.stock,
    required this.category,
    this.campaign,
    required this.categorySlug,
    required this.previewImage,
  });

  factory RelatedProduct.fromJson(Map<String, dynamic> json) {
    return RelatedProduct(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      salesCount: json['sales_count'] ?? 0,
      skuCode: json['sku_code'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      campaign: json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
      categorySlug: json['category_slug'] ?? '',
      previewImage: json['preview_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'slug': slug,
      'sales_count': salesCount,
      'sku_code': skuCode,
      'unit_price': unitPrice,
      'sale_price': salePrice,
      'stock': stock,
      'category': category,
      'campaign': campaign?.toJson(),
      'category_slug': categorySlug,
      'preview_image': previewImage,
    };
  }
}

class Review {
  final int id;
  final int productId;
  final String customerName;
  final String customerEmail;
  final int rating;
  final String review;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.customerName,
    required this.customerEmail,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      rating: json['rating'] ?? 0,
      review: json['review'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ProductVariant {
  final int id;
  final String name;
  final String value;
  final double? priceAdjustment;

  ProductVariant({
    required this.id,
    required this.name,
    required this.value,
    this.priceAdjustment,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      priceAdjustment: json['price_adjustment']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'price_adjustment': priceAdjustment,
    };
  }
}

class Campaign {
  final int id;
  final String name;
  final String? description;
  final double? discountPercentage;
  final double? discountAmount;
  final DateTime? startDate;
  final DateTime? endDate;

  Campaign({
    required this.id,
    required this.name,
    this.description,
    this.discountPercentage,
    this.discountAmount,
    this.startDate,
    this.endDate,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      discountPercentage: json['discount_percentage']?.toDouble(),
      discountAmount: json['discount_amount']?.toDouble(),
      startDate: DateTime.tryParse(json['start_date'] ?? ''),
      endDate: DateTime.tryParse(json['end_date'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}