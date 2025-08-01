// screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/cart.dart';
import '../../services/cart_service.dart';
import '../../utils/ui_utils.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.isLoading) {
            return _buildLoadingState();
          }

          if (cartService.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(child: _buildCartList(cartService)),
              _buildBottomSummary(cartService),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<CartService>(
        builder: (context, cartService, child) {
          return Text(
            'Shopping Cart (${cartService.totalItems})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        Consumer<CartService>(
          builder: (context, cartService, child) {
            return cartService.isEmpty
                ? SizedBox.shrink()
                : TextButton(
              onPressed: () => _showClearCartDialog(cartService),
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your cart...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Looks like you haven\'t added\nanything to your cart yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E86AB), Color(0xFF47A3C7)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2E86AB).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                    (route) => false,
              ),
              icon: Icon(Icons.shopping_bag_outlined),
              label: Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartService cartService) {
    return RefreshIndicator(
      onRefresh: () async {
        await cartService.refreshCart();
      },
      color: Color(0xFF2E86AB),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: cartService.items.length,
        itemBuilder: (context, index) {
          final cartItem = cartService.items[index];
          return _buildCartItemCard(cartService, cartItem, index);
        },
      ),
    );
  }

  Widget _buildCartItemCard(CartService cartService, CartItem cartItem, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildProductImage(cartItem),
                SizedBox(width: 16),
                Expanded(child: _buildProductInfo(cartItem)),
                _buildQuantityControls(cartService, cartItem),
              ],
            ),
            Divider(height: 24, color: Colors.grey[300]),
            _buildItemActions(cartService, cartItem),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItem cartItem) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: cartItem.productImage,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(CartItem cartItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cartItem.productName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          cartItem.brand,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        if (cartItem.selectedVariant != null) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF2E86AB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cartItem.variantDisplayText,
              style: TextStyle(
                color: Color(0xFF2E86AB),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 12),
        _buildPriceInfo(cartItem),
      ],
    );
  }

  Widget _buildPriceInfo(CartItem cartItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '৳${cartItem.effectivePrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E86AB),
              ),
            ),
            if (cartItem.hasDiscount) ...[
              SizedBox(width: 8),
              Text(
                '৳${cartItem.unitPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${cartItem.discountPercentage}% OFF',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Total: ৳${cartItem.totalPrice.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(CartService cartService, CartItem cartItem) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: () => _decreaseQuantity(cartService, cartItem),
          ),
          Container(
            width: 50,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              cartItem.quantity.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => _increaseQuantity(cartService, cartItem),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(0xFF2E86AB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: Color(0xFF2E86AB),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildItemActions(CartService cartService, CartItem cartItem) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _viewProductDetails(cartItem),
            icon: Icon(Icons.visibility_outlined, size: 18),
            label: Text('View Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF2E86AB),
              side: BorderSide(color: Color(0xFF2E86AB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _removeFromCart(cartService, cartItem),
            icon: Icon(Icons.delete_outline, size: 18),
            label: Text('Remove'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[600],
              side: BorderSide(color: Colors.red[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSummary(CartService cartService) {
    final deliveryFee = cartService.calculateDeliveryFee();
    final tax = cartService.calculateTax();
    final finalTotal = cartService.getFinalTotal();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary rows
            _buildSummaryRow('Subtotal', '৳${cartService.totalPrice.toStringAsFixed(0)}'),
            if (deliveryFee > 0)
              _buildSummaryRow('Delivery', '৳${deliveryFee.toStringAsFixed(0)}'),
            if (deliveryFee == 0)
              _buildSummaryRow('Delivery', 'FREE', valueColor: Colors.green),
            if (tax > 0)
              _buildSummaryRow('Tax', '৳${tax.toStringAsFixed(0)}'),
            if (cartService.totalSavings > 0)
              _buildSummaryRow(
                'You Saved',
                '-৳${cartService.totalSavings.toStringAsFixed(0)}',
                valueColor: Colors.green,
              ),

            Divider(thickness: 1, height: 24, color: Colors.grey[300]),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  '৳${finalTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E86AB),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Checkout button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E86AB), Color(0xFF47A3C7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2E86AB).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _proceedToCheckout(cartService),
                icon: Icon(Icons.shopping_bag_outlined),
                label: Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // ================ ACTION METHODS ================

  void _increaseQuantity(CartService cartService, CartItem cartItem) async {
    final success = await cartService.increaseQuantity(cartItem.uniqueId);
    if (!success) {
      UIUtils.showErrorSnackBar(context, 'Failed to update quantity');
    }
  }

  void _decreaseQuantity(CartService cartService, CartItem cartItem) async {
    final success = await cartService.decreaseQuantity(cartItem.uniqueId);
    if (!success) {
      UIUtils.showErrorSnackBar(context, 'Failed to update quantity');
    }
  }

  void _removeFromCart(CartService cartService, CartItem cartItem) async {
    final success = await cartService.removeFromCart(cartItem.uniqueId);
    if (success) {
      UIUtils.showCartRemovedSnackBar(context, cartItem.productName);
    } else {
      UIUtils.showErrorSnackBar(context, 'Failed to remove item');
    }
  }

  void _viewProductDetails(CartItem cartItem) {
    Navigator.pushNamed(
      context,
      '/product-details',
      arguments: cartItem.productSlug,
    );
  }

  void _showClearCartDialog(CartService cartService) {
    UIUtils.showCartClearConfirmation(
      context,
          () async {
        final success = await cartService.clearCart();
        if (success) {
          UIUtils.showSuccessSnackBar(context, 'Cart cleared successfully');
        } else {
          UIUtils.showErrorSnackBar(context, 'Failed to clear cart');
        }
      },
    );
  }

  void _proceedToCheckout(CartService cartService) async {
    // Validate cart before checkout
    final validation = await cartService.validateCart();

    if (!validation['isValid']) {
      String errorMessage = validation['errors'].join('\n');
      UIUtils.showErrorSnackBar(context, errorMessage);
      return;
    }

    // Navigate to checkout
    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: cartService.getCartSummary(),
    );
  }
}