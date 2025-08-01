// widgets/cart/cart_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/cart_service.dart';
import '../../../models/cart.dart';
import '../../../utils/ui_utils.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Consumer<CartService>(
        builder: (context, cartService, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
            ),
            child: Column(
              children: [
                _buildCartHeader(context, cartService),
                Expanded(
                  child: cartService.isEmpty 
                      ? _buildEmptyCart(context) 
                      : _buildCartItems(context, cartService),
                ),
                if (cartService.isNotEmpty) 
                  _buildCartFooter(context, cartService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context, CartService cartService) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E86AB), Color(0xFF47A3C7)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shopping Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${cartService.totalItems} ${cartService.totalItems == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (cartService.totalSavings > 0)
                  Text(
                    'You saved ৳${cartService.totalSavings.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.green[200],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
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
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, CartService cartService) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: cartService.items.length,
      itemBuilder: (context, index) {
        final cartItem = cartService.items[index];
        return _buildCartItemCard(context, cartService, cartItem);
      },
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartService cartService, CartItem cartItem) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
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
        child: Row(
          children: [
            _buildProductImage(cartItem),
            SizedBox(width: 12),
            Expanded(
              child: _buildProductInfo(cartItem),
            ),
            SizedBox(width: 8),
            _buildQuantityControls(context, cartService, cartItem),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItem cartItem) {
    return Container(
      width: 70,
      height: 70,
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            return Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey[400],
                size: 30,
              ),
            );
          },
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
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey[800],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          cartItem.brand,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        if (cartItem.selectedVariant != null) ...[
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xFF2E86AB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cartItem.variantDisplayText,
              style: TextStyle(
                color: Color(0xFF2E86AB),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              '৳${cartItem.effectivePrice.toStringAsFixed(0)}',
              style: TextStyle(
                color: Color(0xFF2E86AB),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (cartItem.hasDiscount) ...[
              SizedBox(width: 8),
              Text(
                '৳${cartItem.unitPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${cartItem.discountPercentage}% OFF',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 9,
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
            color: Colors.green[700],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartService cartService, CartItem cartItem) {
    return Column(
      children: [
        Container(
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
                onPressed: () => _decreaseQuantity(context, cartService, cartItem),
              ),
              Container(
                width: 40,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  cartItem.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add,
                onPressed: () => _increaseQuantity(context, cartService, cartItem),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _removeItem(context, cartService, cartItem),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline,
                  color: Colors.red[600],
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Color(0xFF2E86AB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: Color(0xFF2E86AB),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildCartFooter(BuildContext context, CartService cartService) {
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
      child: Column(
        children: [
          // Cart Summary
          _buildSummaryRow('Subtotal', '৳${cartService.totalPrice.toStringAsFixed(0)}'),
          if (deliveryFee > 0) 
            _buildSummaryRow('Delivery', '৳${deliveryFee.toStringAsFixed(0)}'),
          if (deliveryFee == 0)
            _buildSummaryRow('Delivery', 'FREE', color: Colors.green),
          if (tax > 0)
            _buildSummaryRow('Tax', '৳${tax.toStringAsFixed(0)}'),
          if (cartService.totalSavings > 0)
            _buildSummaryRow('You Saved', '-৳${cartService.totalSavings.toStringAsFixed(0)}', color: Colors.green),
          
          Divider(thickness: 1, color: Colors.grey[300]),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${cartService.totalItems} items):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '৳${finalTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E86AB),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Checkout Button
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
            child: ElevatedButton(
              onPressed: () => _proceedToCheckout(context, cartService),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
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
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _increaseQuantity(BuildContext context, CartService cartService, CartItem cartItem) async {
    final success = await cartService.increaseQuantity(cartItem.uniqueId);
    if (!success) {
      UIUtils.showErrorSnackBar(context, 'Failed to update quantity');
    }
  }

  void _decreaseQuantity(BuildContext context, CartService cartService, CartItem cartItem) async {
    final success = await cartService.decreaseQuantity(cartItem.uniqueId);
    if (!success) {
      UIUtils.showErrorSnackBar(context, 'Failed to update quantity');
    }
  }

  void _removeItem(BuildContext context, CartService cartService, CartItem cartItem) async {
    final success = await cartService.removeFromCart(cartItem.uniqueId);
    if (success) {
      UIUtils.showSuccessSnackBar(context, '${cartItem.productName} removed from cart');
    } else {
      UIUtils.showErrorSnackBar(context, 'Failed to remove item');
    }
  }

  void _proceedToCheckout(BuildContext context, CartService cartService) async {
    // Validate cart before checkout
    final validation = await cartService.validateCart();
    
    if (!validation['isValid']) {
      String errorMessage = validation['errors'].join('\n');
      UIUtils.showErrorSnackBar(context, errorMessage);
      return;
    }

    // Close drawer
    Navigator.of(context).pop();
    
    // Navigate to checkout
    Navigator.pushNamed(
      context, 
      '/checkout',
      arguments: cartService.getCartSummary(),
    );
  }
}