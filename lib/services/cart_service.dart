// services/cart_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../models/product_details.dart';
import '../utils/logger.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static const String _cartKey = 'shopping_cart';
  Cart _cart = Cart();
  bool _isLoading = false;
  bool _isInitialized = false;
  // Getters
  Cart get cart => _cart;
  List<CartItem> get items => _cart.items;
  int get totalItems => _cart.totalItems;
  double get totalPrice => _cart.totalPrice;
  double get totalSavings => _cart.totalSavings;
  bool get isEmpty => _cart.isEmpty;
  bool get isNotEmpty => _cart.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  // Initialize cart service
  Future<void> initialize() async {
    try {
      await _loadCartFromStorage();
      Logger.logInfo('CartService initialized successfully');
    } catch (e) {
      Logger.logError('Error initializing CartService', e);
    }
  }
  
  // Load cart from local storage
  Future<void> _loadCartFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final cartData = json.decode(cartJson);
        _cart = Cart.fromJson(cartData);
        Logger.logInfo('Cart loaded from storage: ${_cart.totalItems} items');
      } else {
        _cart = Cart();
        Logger.logInfo('No cart found in storage, initialized empty cart');
      }
    } catch (e) {
      Logger.logError('Error loading cart from storage', e);
      _cart = Cart();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save cart to local storage
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_cart.toJson());
      await prefs.setString(_cartKey, cartJson);
      Logger.logInfo('Cart saved to storage: ${_cart.totalItems} items');
    } catch (e) {
      Logger.logError('Error saving cart to storage', e);
    }
  }

  // Add product to cart
  Future<bool> addToCart(
    ProductDetails product, {
    ProductVariant? selectedVariant,
    int quantity = 1,
  }) async {
    try {
      // Validate input
      if (quantity <= 0) {
        Logger.logWarning('Invalid quantity: $quantity');
        return false;
      }

      if (product.stock <= 0) {
        Logger.logWarning('Product out of stock: ${product.name}');
        return false;
      }

      // Check variant stock if applicable
      if (selectedVariant != null && !selectedVariant.isAvailable) {
        Logger.logWarning('Selected variant out of stock: ${selectedVariant.displayText}');
        return false;
      }

      // Create cart item
      final cartItem = CartItem.fromProduct(
        product,
        variant: selectedVariant,
        quantity: quantity,
      );

      // Check if adding this quantity would exceed stock
      int currentQuantity = getProductQuantity(product.id, variant: selectedVariant);
      int totalQuantity = currentQuantity + quantity;

      if (totalQuantity > product.stock) {
        Logger.logWarning('Not enough stock. Available: ${product.stock}, Requested: $totalQuantity');
        return false;
      }

      // Add to cart
      _cart = _cart.addItem(cartItem);
      await _saveCartToStorage();
      notifyListeners();

      Logger.logSuccess('Added to cart: ${product.name} x$quantity');
      return true;

    } catch (e) {
      Logger.logError('Error adding product to cart', e);
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String uniqueId) async {
    try {
      final item = _cart.getItem(uniqueId);
      if (item == null) {
        Logger.logWarning('Item not found in cart: $uniqueId');
        return false;
      }

      _cart = _cart.removeItem(uniqueId);
      await _saveCartToStorage();
      notifyListeners();

      Logger.logSuccess('Removed from cart: ${item.productName}');
      return true;

    } catch (e) {
      Logger.logError('Error removing item from cart', e);
      return false;
    }
  }

  // Update item quantity
  Future<bool> updateQuantity(String uniqueId, int newQuantity) async {
    try {
      final item = _cart.getItem(uniqueId);
      if (item == null) {
        Logger.logWarning('Item not found in cart: $uniqueId');
        return false;
      }

      if (newQuantity <= 0) {
        return await removeFromCart(uniqueId);
      }

      _cart = _cart.updateItemQuantity(uniqueId, newQuantity);
      await _saveCartToStorage();
      notifyListeners();

      Logger.logSuccess('Updated quantity for ${item.productName}: $newQuantity');
      return true;

    } catch (e) {
      Logger.logError('Error updating item quantity', e);
      return false;
    }
  }

  // Increase item quantity by 1
  Future<bool> increaseQuantity(String uniqueId) async {
    final item = _cart.getItem(uniqueId);
    if (item == null) return false;

    return await updateQuantity(uniqueId, item.quantity + 1);
  }

  // Decrease item quantity by 1
  Future<bool> decreaseQuantity(String uniqueId) async {
    final item = _cart.getItem(uniqueId);
    if (item == null) return false;

    if (item.quantity <= 1) {
      return await removeFromCart(uniqueId);
    }

    return await updateQuantity(uniqueId, item.quantity - 1);
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    try {
      _cart = _cart.clear();
      await _saveCartToStorage();
      notifyListeners();

      Logger.logSuccess('Cart cleared');
      return true;

    } catch (e) {
      Logger.logError('Error clearing cart', e);
      return false;
    }
  }

  // Check if product is in cart
  bool isInCart(int productId, {ProductVariant? variant}) {
    return _cart.containsProduct(productId, variant: variant);
  }

  // Get quantity of specific product in cart
  int getProductQuantity(int productId, {ProductVariant? variant}) {
    return _cart.getProductQuantity(productId, variant: variant);
  }

  // Get cart item by unique ID
  CartItem? getCartItem(String uniqueId) {
    return _cart.getItem(uniqueId);
  }

  // Refresh cart (reload from storage)
  Future<void> refreshCart() async {
    await _loadCartFromStorage();
  }

  // Get cart summary for checkout
  Map<String, dynamic> getCartSummary() {
    return {
      'total_items': totalItems,
      'total_price': totalPrice,
      'total_savings': totalSavings,
      'currency': items.isNotEmpty ? items.first.currency : 'bdt',
      'items': items.map((item) => {
        'product_id': item.productId,
        'product_name': item.productName,
        'quantity': item.quantity,
        'unit_price': item.effectivePrice,
        'total_price': item.totalPrice,
        'variant': item.selectedVariant?.toJson(),
      }).toList(),
    };
  }

  // Validate cart before checkout
  Future<Map<String, dynamic>> validateCart() async {
    List<String> errors = [];
    List<String> warnings = [];

    if (isEmpty) {
      errors.add('Cart is empty');
      return {
        'isValid': false,
        'errors': errors,
        'warnings': warnings,
      };
    }

    // In a real app, you would validate stock availability with the server
    for (var item in items) {
      if (item.quantity <= 0) {
        errors.add('Invalid quantity for ${item.productName}');
      }

      // Check if prices are reasonable (basic validation)
      if (item.effectivePrice <= 0) {
        errors.add('Invalid price for ${item.productName}');
      }
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
    };
  }

  // Export cart data (for backup or sharing)
  Future<String> exportCart() async {
    try {
      final cartData = _cart.toJson();
      return json.encode(cartData);
    } catch (e) {
      Logger.logError('Error exporting cart', e);
      throw Exception('Failed to export cart: $e');
    }
  }

  // Import cart data (from backup or sharing)
  Future<bool> importCart(String cartJson) async {
    try {
      final cartData = json.decode(cartJson);
      _cart = Cart.fromJson(cartData);
      await _saveCartToStorage();
      notifyListeners();

      Logger.logSuccess('Cart imported successfully: ${_cart.totalItems} items');
      return true;

    } catch (e) {
      Logger.logError('Error importing cart', e);
      return false;
    }
  }

  // Calculate estimated delivery cost (placeholder)
  double calculateDeliveryFee() {
    // This would typically be calculated based on location, weight, etc.
    if (totalPrice >= 1000) return 0.0; // Free delivery over 1000 BDT
    return 60.0; // Standard delivery fee
  }

  // Calculate tax (placeholder)
  double calculateTax() {
    // This would typically be calculated based on location and product types
    return totalPrice * 0.0; // No tax for now
  }

  // Get final checkout total
  double getFinalTotal() {
    return totalPrice + calculateDeliveryFee() + calculateTax();
  }

  // Dispose resources
  @override
  void dispose() {
    Logger.logInfo('CartService disposed');
    super.dispose();
  }
}