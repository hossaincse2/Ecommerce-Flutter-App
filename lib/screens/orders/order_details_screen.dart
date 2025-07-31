import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/shared_widgets.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? orderData;

  // Mock order data - replace with actual API call
  final Map<String, dynamic> mockOrderData = {
    'id': 'ORD001',
    'date': '2024-01-15',
    'status': 'delivered',
    'total': 299.99,
    'subtotal': 279.99,
    'tax': 15.00,
    'shipping': 5.00,
    'discount': 0.00,
    'paymentMethod': 'Credit Card',
    'cardLast4': '4321',
    'trackingNumber': 'TRK123456789',
    'estimatedDelivery': '2024-01-18',
    'actualDelivery': '2024-01-17',
    'shippingAddress': {
      'name': 'John Doe',
      'address': '123 Main Street',
      'city': 'New York',
      'state': 'NY',
      'zipCode': '10001',
      'phone': '+1 (555) 123-4567',
    },
    'items': [
      {
        'id': 'ITEM001',
        'name': 'Wireless Bluetooth Headphones',
        'brand': 'Sony',
        'model': 'WH-1000XM4',
        'image': 'https://example.com/headphones.jpg',
        'price': 199.99,
        'quantity': 1,
        'color': 'Black',
        'size': 'One Size',
        'description': 'Premium noise-canceling wireless headphones with 30-hour battery life',
        'warranty': '1 Year International Warranty',
      },
      {
        'id': 'ITEM002',
        'name': 'Phone Case Premium',
        'brand': 'Apple',
        'model': 'Leather Case',
        'image': 'https://example.com/case.jpg',
        'price': 39.99,
        'quantity': 2,
        'color': 'Blue',
        'size': 'iPhone 14',
        'description': 'Genuine leather case with MagSafe compatibility',
        'warranty': '6 Months Limited Warranty',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  // ==========================================================================
  // API METHODS
  // ==========================================================================

  Future<void> _loadOrderDetails() async {
    // TODO: Implement API call to fetch order details
    await Future.delayed(Duration(seconds: 1)); // Simulate API call

    setState(() {
      orderData = mockOrderData;
      isLoading = false;
    });
  }

  // ==========================================================================
  // BUILD METHODS
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: isLoading
          ? LoadingWidgets.buildLoadingScreen(message: 'Loading order details...')
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return SharedWidgets.buildAppBar(
      title: 'Order #${widget.orderId}',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: AppConstants.primaryColor),
          onPressed: () => _shareOrder(),
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: AppConstants.primaryColor),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'invoice', child: Text('Download Invoice')),
            PopupMenuItem(value: 'support', child: Text('Contact Support')),
            if (orderData?['status'] == 'processing')
              PopupMenuItem(value: 'cancel', child: Text('Cancel Order')),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadOrderDetails,
      color: AppConstants.primaryColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(),
            SizedBox(height: 16),
            _buildOrderItemsCard(),
            SizedBox(height: 16),
            _buildOrderSummaryCard(),
            SizedBox(height: 16),
            _buildShippingAddressCard(),
            SizedBox(height: 16),
            _buildPaymentInfoCard(),
            SizedBox(height: 16),
            _buildActionButtons(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ORDER STATUS CARD
  // ==========================================================================

  Widget _buildOrderStatusCard() {
    final status = orderData?['status'] ?? '';
    final orderDate = orderData?['date'] ?? '';
    final estimatedDelivery = orderData?['estimatedDelivery'] ?? '';
    final actualDelivery = orderData?['actualDelivery'];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow('Order Date', orderDate),
          SizedBox(height: 8),
          if (actualDelivery != null)
            _buildInfoRow('Delivered On', actualDelivery)
          else
            _buildInfoRow('Expected Delivery', estimatedDelivery),
          if (orderData?['trackingNumber'] != null) ...[
            SizedBox(height: 8),
            _buildInfoRow('Tracking Number', orderData!['trackingNumber']),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'processing':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        displayText = 'Processing';
        break;
      case 'shipped':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        displayText = 'Shipped';
        break;
      case 'delivered':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        displayText = 'Delivered';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ORDER ITEMS CARD
  // ==========================================================================

  Widget _buildOrderItemsCard() {
    final items = orderData?['items'] as List<dynamic>? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Order Items (${items.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildOrderItem(item),
                if (index < items.length - 1)
                  Divider(height: 1, color: Colors.grey.shade200, indent: 20, endIndent: 20),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppConstants.primaryColor,
                  size: 40,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${item['brand']} • ${item['model']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      item['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppConstants.textSecondaryColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Qty: ${item['quantity']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        Text(
                          '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildProductDetailsBox(item),
        ],
      ),
    );
  }

  Widget _buildProductDetailsBox(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildProductDetail('Color', item['color']),
              ),
              Expanded(
                child: _buildProductDetail('Size', item['size']),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildProductDetail('Unit Price', '\$${item['price'].toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildProductDetail('Warranty', item['warranty']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ORDER SUMMARY CARD
  // ==========================================================================

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow('Subtotal', '\$${orderData?['subtotal']?.toStringAsFixed(2) ?? '0.00'}'),
          _buildSummaryRow('Shipping', '\$${orderData?['shipping']?.toStringAsFixed(2) ?? '0.00'}'),
          _buildSummaryRow('Tax', '\$${orderData?['tax']?.toStringAsFixed(2) ?? '0.00'}'),
          if ((orderData?['discount'] ?? 0) > 0)
            _buildSummaryRow('Discount', '-\$${orderData?['discount']?.toStringAsFixed(2) ?? '0.00'}', color: Colors.green),
          Divider(height: 24, thickness: 1),
          _buildSummaryRow(
            'Total',
            '\$${orderData?['total']?.toStringAsFixed(2) ?? '0.00'}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isTotal ? AppConstants.primaryColor : AppConstants.textPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SHIPPING ADDRESS CARD
  // ==========================================================================

  Widget _buildShippingAddressCard() {
    final address = orderData?['shippingAddress'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppConstants.primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildAddressInfoBox(address),
          SizedBox(height: 12),
          _buildMapViewButton(),
        ],
      ),
    );
  }

  Widget _buildAddressInfoBox(Map<String, dynamic> address) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppConstants.primaryColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                address['name'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.home_outlined,
                color: Colors.grey.shade600,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address['address'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textPrimaryColor,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['zipCode'] ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (address['phone'] != null) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  address['phone'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                _buildCallButton(address['phone']),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCallButton(String phoneNumber) {
    return InkWell(
      onTap: () => _callCustomer(phoneNumber),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.call,
              color: Colors.green,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'Call',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapViewButton() {
    return InkWell(
      onTap: () => _viewOnMap(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              color: AppConstants.primaryColor,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'View on Map',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // PAYMENT INFO CARD
  // ==========================================================================

  Widget _buildPaymentInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.credit_card, color: AppConstants.primaryColor, size: 20),
              SizedBox(width: 12),
              Text(
                '${orderData?['paymentMethod'] ?? ''} ending in ${orderData?['cardLast4'] ?? ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ACTION BUTTONS
  // ==========================================================================

  Widget _buildActionButtons() {
    final status = orderData?['status'] ?? '';

    return Column(
      children: [
        // Primary action buttons
        Row(
          children: [
            Expanded(
              child: _buildPrimaryButton(
                onPressed: () => _trackOrder(),
                icon: Icons.local_shipping_outlined,
                label: 'Track Order',
                backgroundColor: AppConstants.primaryColor,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildPrimaryButton(
                onPressed: () => _reorderItems(),
                icon: Icons.refresh,
                label: 'Order Again',
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Secondary action buttons
        if (status == 'delivered') ...[
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  onPressed: () => _writeReview(),
                  icon: Icons.star_outline,
                  label: 'Write Review',
                  borderColor: AppConstants.primaryColor,
                  textColor: AppConstants.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryButton(
                  onPressed: () => _reportProblem(),
                  icon: Icons.report_outlined,
                  label: 'Report Issue',
                  borderColor: Colors.orange.shade700,
                  textColor: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ],
        if (status == 'processing') ...[
          SizedBox(
            width: double.infinity,
            child: _buildSecondaryButton(
              onPressed: () => _cancelOrder(),
              icon: Icons.cancel_outlined,
              label: 'Cancel Order',
              borderColor: Colors.red.shade700,
              textColor: Colors.red.shade700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color borderColor,
    required Color textColor,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: textColor),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: 1.5),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ==========================================================================
  // ACTION METHODS
  // ==========================================================================

  void _shareOrder() {
    // TODO: Implement share functionality
    UIUtils.showSuccessSnackBar(context, 'Order details shared');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'invoice':
        _downloadInvoice();
        break;
      case 'support':
        _contactSupport();
        break;
      case 'cancel':
        _cancelOrder();
        break;
    }
  }

  void _downloadInvoice() {
    // TODO: Implement invoice download
    UIUtils.showSuccessSnackBar(context, 'Invoice downloaded');
  }

  void _contactSupport() {
    // TODO: Navigate to support screen or show contact options
    UIUtils.showSuccessSnackBar(context, 'Redirecting to support...');
  }

  void _trackOrder() {
    Navigator.pushNamed(
      context,
      '/order-tracking',
      arguments: {'orderId': widget.orderId},
    );
  }

  void _writeReview() {
    // TODO: Navigate to review screen
    Navigator.pushNamed(
      context,
      '/write-review',
      arguments: {'orderId': widget.orderId, 'items': orderData?['items']},
    );
  }

  void _reportProblem() {
    // TODO: Navigate to problem report screen
    Navigator.pushNamed(
      context,
      '/report-problem',
      arguments: {'orderId': widget.orderId},
    );
  }

  void _reorderItems() {
    // TODO: Implement reorder functionality
    UIUtils.showSuccessSnackBar(context, 'Items added to cart');
  }

  void _callCustomer(String phoneNumber) {
    // TODO: Implement phone call functionality
    UIUtils.showSuccessSnackBar(context, 'Opening dialer...');
  }

  void _viewOnMap() {
    // TODO: Implement map view functionality
    UIUtils.showSuccessSnackBar(context, 'Opening map...');
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          title: Text('Cancel Order'),
          content: Text('Are you sure you want to cancel this order? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep Order'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement cancel order API call
                setState(() {
                  orderData?['status'] = 'cancelled';
                });
                UIUtils.showSuccessSnackBar(context, 'Order cancelled successfully');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}