// models/cart.dart
import '../models/product_details.dart';

class CartItem {
  final int productId;
  final String productName;
  final String productSlug;
  final String productImage;
  final String brand;
  final double unitPrice;
  final double salePrice;
  final String currency;
  final ProductVariant? selectedVariant;
  int quantity;
  final DateTime addedAt;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productSlug,
    required this.productImage,
    required this.brand,
    required this.unitPrice,
    required this.salePrice,
    required this.currency,
    this.selectedVariant,
    required this.quantity,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // Create CartItem from ProductDetails
  factory CartItem.fromProduct(
    ProductDetails product, {
    ProductVariant? variant,
    int quantity = 1,
  }) {
    return CartItem(
      productId: product.id,
      productName: product.name,
      productSlug: product.slug,
      productImage: product.previewImage,
      brand: product.category, // Using category as brand for now
      unitPrice: product.unitPrice,
      salePrice: product.salePrice,
      currency: product.currency,
      selectedVariant: variant,
      quantity: quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productSlug: json['product_slug'] ?? '',
      productImage: json['product_image'] ?? '',
      brand: json['brand'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'bdt',
      selectedVariant: json['selected_variant'] != null 
          ? ProductVariant.fromJson(json['selected_variant']) 
          : null,
      quantity: json['quantity'] ?? 1,
      addedAt: DateTime.tryParse(json['added_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_slug': productSlug,
      'product_image': productImage,
      'brand': brand,
      'unit_price': unitPrice,
      'sale_price': salePrice,
      'currency': currency,
      'selected_variant': selectedVariant?.toJson(),
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }

  // Get effective price (sale price if available, otherwise unit price)
  double get effectivePrice {
    double basePrice = salePrice > 0 ? salePrice : unitPrice;
    
    // Add variant additional price if available
    if (selectedVariant?.additionalPrice != null) {
      basePrice += selectedVariant!.additionalPrice!;
    }
    
    return basePrice;
  }

  // Get total price for this cart item (price * quantity)
  double get totalPrice => effectivePrice * quantity;

  // Check if item has discount
  bool get hasDiscount => salePrice > 0 && salePrice < unitPrice;

  // Get discount percentage
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return ((unitPrice - salePrice) / unitPrice * 100).round();
  }

  // Get unique identifier for cart item (includes variant)
  String get uniqueId {
    String baseId = productId.toString();
    if (selectedVariant != null) {
      baseId += '_${selectedVariant!.productVariantId}';
    }
    return baseId;
  }

  // Get variant display text
  String get variantDisplayText {
    return selectedVariant?.displayText ?? '';
  }

  // Check if two cart items are the same (same product and variant)
  bool isSameItem(CartItem other) {
    return productId == other.productId && 
           selectedVariant?.productVariantId == other.selectedVariant?.productVariantId;
  }

  // Create a copy of this cart item with updated quantity
  CartItem copyWith({
    int? quantity,
    ProductVariant? selectedVariant,
  }) {
    return CartItem(
      productId: productId,
      productName: productName,
      productSlug: productSlug,
      productImage: productImage,
      brand: brand,
      unitPrice: unitPrice,
      salePrice: salePrice,
      currency: currency,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt,
    );
  }
}

class Cart {
  final List<CartItem> items;
  final DateTime lastUpdated;

  Cart({
    List<CartItem>? items,
    DateTime? lastUpdated,
  }) : items = items ?? [],
        lastUpdated = lastUpdated ?? DateTime.now();

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Get total number of items in cart
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Get total price of all items in cart
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Get total savings (discount amount)
  double get totalSavings {
    return items.fold(0.0, (sum, item) {
      if (item.hasDiscount) {
        return sum + ((item.unitPrice - item.salePrice) * item.quantity);
      }
      return sum;
    });
  }

  // Check if cart is empty
  bool get isEmpty => items.isEmpty;

  // Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  // Add item to cart or update quantity if exists
  Cart addItem(CartItem newItem) {
    List<CartItem> updatedItems = List.from(items);
    
    // Check if item already exists
    int existingIndex = updatedItems.indexWhere((item) => item.isSameItem(newItem));
    
    if (existingIndex >= 0) {
      // Update quantity of existing item
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + newItem.quantity,
      );
    } else {
      // Add new item
      updatedItems.add(newItem);
    }
    
    return Cart(
      items: updatedItems,
      lastUpdated: DateTime.now(),
    );
  }

  // Remove item from cart
  Cart removeItem(String uniqueId) {
    List<CartItem> updatedItems = items.where((item) => item.uniqueId != uniqueId).toList();
    
    return Cart(
      items: updatedItems,
      lastUpdated: DateTime.now(),
    );
  }

  // Update item quantity
  Cart updateItemQuantity(String uniqueId, int newQuantity) {
    if (newQuantity <= 0) {
      return removeItem(uniqueId);
    }
    
    List<CartItem> updatedItems = items.map((item) {
      if (item.uniqueId == uniqueId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
    
    return Cart(
      items: updatedItems,
      lastUpdated: DateTime.now(),
    );
  }

  // Clear all items from cart
  Cart clear() {
    return Cart(
      items: [],
      lastUpdated: DateTime.now(),
    );
  }

  // Get item by unique ID
  CartItem? getItem(String uniqueId) {
    try {
      return items.firstWhere((item) => item.uniqueId == uniqueId);
    } catch (e) {
      return null;
    }
  }

  // Check if product exists in cart (with or without variant)
  bool containsProduct(int productId, {ProductVariant? variant}) {
    return items.any((item) {
      if (item.productId != productId) return false;
      
      if (variant == null) {
        return item.selectedVariant == null;
      } else {
        return item.selectedVariant?.productVariantId == variant.productVariantId;
      }
    });
  }

  // Get quantity of specific product in cart
  int getProductQuantity(int productId, {ProductVariant? variant}) {
    try {
      CartItem item = items.firstWhere((item) {
        if (item.productId != productId) return false;
        
        if (variant == null) {
          return item.selectedVariant == null;
        } else {
          return item.selectedVariant?.productVariantId == variant.productVariantId;
        }
      });
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}