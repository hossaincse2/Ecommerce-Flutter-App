// screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../utils/ui_utils.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialInstructionController = TextEditingController();

  String _paymentMethod = 'cash_on_delivery';
  String _deliveryLocation = 'inside_dhaka';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _specialInstructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.isEmpty) {
            return _buildEmptyCart();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildOrderSummaryCard(cartService),
                _buildShippingFormCard(),
                _buildPaymentMethodCard(),
                _buildSpecialInstructionCard(),
                _buildPriceBreakdownCard(cartService),
                _buildPlaceOrderButton(cartService),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF2E86AB),
      title: Text(
        'Checkout',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E86AB),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2E86AB)),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
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
            'Add some products to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            icon: Icon(Icons.shopping_bag_outlined),
            label: Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E86AB),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartService cartService) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E86AB), Color(0xFF47A3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_long, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${cartService.totalItems} items',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                ...cartService.items.map((item) => Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            item.productImage,
                            fit: BoxFit.cover,
                            headers: {
                              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.selectedVariant != null) ...[
                              SizedBox(height: 4),
                              Text(
                                item.selectedVariant!.displayText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  '৳${item.effectivePrice.toStringAsFixed(0)} each',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '৳${item.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E86AB),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingFormCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E86AB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.local_shipping, color: Color(0xFF2E86AB), size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Shipping Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                isRequired: true,
                validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isRequired: true,
                validator: (value) => value?.isEmpty ?? true ? 'Phone is required' : null,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email (Optional)',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Delivery Address',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                isRequired: true,
                validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
              ),
              SizedBox(height: 16),
              _buildDeliveryLocationSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        prefixIcon: Icon(icon, color: Color(0xFF2E86AB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2E86AB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDeliveryLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _deliveryLocation,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF2E86AB)),
              items: [
                DropdownMenuItem(
                  value: 'inside_dhaka',
                  child: Row(
                    children: [
                      Icon(Icons.location_city, color: Color(0xFF2E86AB), size: 20),
                      SizedBox(width: 8),
                      Text('Inside Dhaka (৳60)'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'outside_dhaka',
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF2E86AB), size: 20),
                      SizedBox(width: 8),
                      Text('Outside Dhaka (৳120)'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _deliveryLocation = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E86AB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.payment, color: Color(0xFF2E86AB), size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildPaymentOption(
              'cash_on_delivery',
              'Cash on Delivery',
              'Pay when your order arrives',
              Icons.money,
              Colors.green,
            ),
            SizedBox(height: 12),
            _buildPaymentOption(
              'mobile_banking',
              'Mobile Banking',
              'bKash, Nagad, Rocket',
              Icons.phone_android,
              Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      String value,
      String title,
      String subtitle,
      IconData icon,
      Color iconColor,
      ) {
    bool isSelected = _paymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2E86AB).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF2E86AB) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value!),
              activeColor: Color(0xFF2E86AB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructionCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E86AB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.note_outlined, color: Color(0xFF2E86AB), size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Special Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _specialInstructionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special delivery instructions? (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2E86AB), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard(CartService cartService) {
    double deliveryFee = _deliveryLocation == 'inside_dhaka' ? 60.0 : 120.0;
    double subTotal = cartService.totalPrice;
    double discount = cartService.totalSavings;
    double finalTotal = subTotal + deliveryFee - discount;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E86AB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.calculate_outlined, color: Color(0xFF2E86AB), size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Price Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildPriceRow('Subtotal', subTotal, false),
            SizedBox(height: 8),
            _buildPriceRow('Delivery Fee', deliveryFee, false),
            if (discount > 0) ...[
              SizedBox(height: 8),
              _buildPriceRow('Discount', -discount, false, isDiscount: true),
            ],
            SizedBox(height: 12),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            SizedBox(height: 12),
            _buildPriceRow('Total', finalTotal, true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, bool isBold, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.grey[800] : Colors.grey[600],
          ),
        ),
        Text(
          isDiscount
              ? '-৳${amount.abs().toStringAsFixed(0)}'
              : '৳${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold
                ? Color(0xFF2E86AB)
                : isDiscount
                ? Colors.green
                : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton(CartService cartService) {
    double deliveryFee = _deliveryLocation == 'inside_dhaka' ? 60.0 : 120.0;
    double finalTotal = cartService.totalPrice + deliveryFee - cartService.totalSavings;

    return Container(
      margin: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _placeOrder(cartService),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2E86AB),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey[300]!;
              }
              return Color(0xFF2E86AB);
            },
          ),
        ),
        child: Container(
          width: double.infinity,
          child: _isProcessing
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Processing Order...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 20),
              SizedBox(width: 8),
              Text(
                'Place Order - ৳${finalTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _placeOrder(CartService cartService) async {
    if (!_formKey.currentState!.validate()) {
      UIUtils.showErrorSnackBar(context, 'Please fill in all required fields');
      return;
    }

    // Validate order data
    final validation = OrderService.validateOrderData(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      cartItems: cartService.items,
    );

    if (!validation['isValid']) {
      List<String> errors = validation['errors'];
      UIUtils.showErrorSnackBar(context, errors.first);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      double deliveryFee = _deliveryLocation == 'inside_dhaka' ? 60.0 : 120.0;
      double subTotal = cartService.totalPrice;
      double finalTotal = subTotal + deliveryFee - cartService.totalSavings;

      final orderResponse = await OrderService.placeOrder(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        specialInstruction: _specialInstructionController.text.trim(),
        paymentMethod: _paymentMethod,
        cartItems: cartService.items,
        deliveryFee: deliveryFee,
        subTotal: subTotal,
        totalAmount: finalTotal,
        deliveryLocation: _deliveryLocation,
        discountAmount: cartService.totalSavings,
      );

      if (orderResponse.success) {
        // Clear cart after successful order
        await cartService.clearCart();

        // Show success dialog
        _showSuccessDialog();
      } else {
        UIUtils.showErrorSnackBar(context, orderResponse.message);
      }
    } catch (e) {
      UIUtils.showErrorSnackBar(context, 'Failed to place order. Please try again.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.green[50]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Thank you for your order. We will contact you soon with delivery details.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF2E86AB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Continue Shopping',
                        style: TextStyle(color: Color(0xFF2E86AB)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate to order success screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/order-success',
                              (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E86AB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'View Orders',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search Screen (unchanged from your original)
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<String> _searchHistory = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
          onSubmitted: _performSearch,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _isSearching
          ? Center(child: CircularProgressIndicator())
          : _buildSearchContent(),
    );
  }

  Widget _buildSearchContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ..._searchHistory.map((query) => ListTile(
            leading: Icon(Icons.history, color: Colors.grey),
            title: Text(query),
            onTap: () => _performSearch(query),
            trailing: IconButton(
              icon: Icon(Icons.close, color: Colors.grey),
              onPressed: () => _removeFromHistory(query),
            ),
          )).toList(),
        ] else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Search for products',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isSearching = true);

    // Add to search history
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.take(10).toList();
      }
    }

    try {
      // Simulate search
      await Future.delayed(Duration(seconds: 1));

      // Navigate to results (in a real app, you'd pass results)
      Navigator.pushNamed(context, '/search-results', arguments: query);
    } catch (e) {
      UIUtils.showErrorSnackBar(context, 'Search failed: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _removeFromHistory(String query) {
    setState(() {
      _searchHistory.remove(query);
    });
  }
}