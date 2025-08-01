import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../constants/app_constants.dart';
import '../../models/customer.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/shared_widgets.dart';
import '../../models/order_details.dart';
import '../../models/order_item.dart';
import '../../services/order_api_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool isLoading = true;
  OrderDetails? orderData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  // ==========================================================================
  // API METHODS
  // ==========================================================================

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final orderId = int.tryParse(widget.orderId);
      if (orderId == null) {
        throw Exception('Invalid order ID');
      }

      final details = await OrderApiService.getOrderDetails(orderId);

      setState(() {
        orderData = details;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = OrderApiService.getErrorMessage(e);
      });

      if (mounted) {
        UIUtils.showErrorSnackBar(context, errorMessage!);
      }
    }
  }

  // ==========================================================================
  // BUILD METHODS
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: isLoading
          ? LoadingWidgets.buildLoadingScreen(message: 'Loading order details...')
          : errorMessage != null
          ? _buildErrorState()
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppConstants.textPrimaryColor,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long,
              color: AppConstants.primaryColor,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '#${widget.orderId}',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.share_outlined,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
            onPressed: () => _shareOrder(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 16),
          child: PopupMenuButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.more_vert,
                color: AppConstants.textPrimaryColor,
                size: 20,
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'invoice',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20, color: AppConstants.primaryColor),
                    SizedBox(width: 12),
                    Text('Download Invoice'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'support',
                child: Row(
                  children: [
                    Icon(Icons.support_agent, size: 20, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Contact Support'),
                  ],
                ),
              ),
              if (orderData?.canBeCancelled == true)
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Cancel Order'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Failed to load order details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadOrderDetails,
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (orderData == null) return SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadOrderDetails,
      color: AppConstants.primaryColor,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ORDER STATUS CARD
  // ==========================================================================

  Widget _buildOrderStatusCard() {
    final order = orderData!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryColor.withOpacity(0.1),
                  AppConstants.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'Track your order progress',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.displayStatus),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(Icons.calendar_today, 'Order Date', order.orderAt),
                SizedBox(height: 12),
                _buildInfoRow(Icons.receipt_long, 'Order Number', order.orderNumber),
                SizedBox(height: 12),
                _buildInfoRow(Icons.location_on, 'Delivery Location', _formatDeliveryLocation(order.deliveryLocation)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeliveryLocation(String location) {
    return location.replaceAll('_', ' ').split(' ').map((word) =>
    word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'processing':
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.hourglass_empty;
        break;
      case 'shipped':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        icon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppConstants.primaryColor),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ORDER ITEMS CARD
  // ==========================================================================

  Widget _buildOrderItemsCard() {
    final items = orderData!.orderItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      Text(
                        '${items.length} item${items.length > 1 ? 's' : ''} in this order',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildOrderItem(item),
                if (index < items.length - 1)
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.grey.shade100,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              image: item.productImage.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(item.productImage),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: item.productImage.isEmpty
                ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor.withOpacity(0.1),
                    AppConstants.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: AppConstants.primaryColor,
                size: 32,
              ),
            )
                : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                if (item.attributes.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.attributes.join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: AppConstants.primaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '\$${item.price.toStringAsFixed(2)} each',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.productUrl.isNotEmpty)
                      InkWell(
                        onTap: () => _viewProduct(item.productUrl),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.open_in_new,
                                color: Colors.blue.shade600,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'View Product',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(),
                    Text(
                      '\$${item.total.toStringAsFixed(2)}',
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
    );
  }

  // ==========================================================================
  // ORDER SUMMARY CARD
  // ==========================================================================

  Widget _buildOrderSummaryCard() {
    final order = orderData!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow(Icons.shopping_cart, 'Subtotal', '\$${order.subTotal.toStringAsFixed(2)}'),
                SizedBox(height: 12),
                _buildSummaryRow(Icons.local_shipping, 'Delivery Fee', '\$${order.deliveryFee.toStringAsFixed(2)}'),
                if (order.vatAmount > 0) ...[
                  SizedBox(height: 12),
                  _buildSummaryRow(Icons.receipt_long, 'VAT', '\$${order.vatAmount.toStringAsFixed(2)}'),
                ],
                SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
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
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppConstants.textSecondaryColor),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
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
  // SHIPPING ADDRESS CARD
  // ==========================================================================

  Widget _buildShippingAddressCard() {
    final customer = orderData!.customer;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.purple.shade600,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
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
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: _buildAddressInfoBox(customer),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfoBox(Customer customer) {
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: AppConstants.primaryColor,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Text(
                customer.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.home_outlined,
                color: AppConstants.textSecondaryColor,
                size: 18,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  customer.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textPrimaryColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (customer.phone.isNotEmpty) ...[
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: AppConstants.textSecondaryColor,
                  size: 18,
                ),
                SizedBox(width: 12),
                Text(
                  customer.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                _buildCallButton(customer.phone),
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.call,
              color: Colors.green.shade600,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Call',
              style: TextStyle(
                color: Colors.green.shade600,
                fontSize: 12,
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
    final order = orderData!;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              order.paymentMethod.toLowerCase() == 'cash' ? Icons.money : Icons.credit_card,
              color: Colors.amber.shade600,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              Text(
                order.paymentMethod.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
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
    final order = orderData!;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.touch_app,
                  color: AppConstants.primaryColor,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Primary action buttons
          Row(
            children: [
              if (order.canBeTracked)
                Expanded(
                  child: _buildPrimaryButton(
                    onPressed: () => _trackOrder(),
                    icon: Icons.track_changes,
                    label: 'Track Order',
                    backgroundColor: AppConstants.primaryColor,
                  ),
                ),
              if (order.canBeTracked) SizedBox(width: 12),
              Expanded(
                child: _buildPrimaryButton(
                  onPressed: () => _reorderItems(),
                  icon: Icons.refresh,
                  label: 'Order Again',
                  backgroundColor: Colors.green.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Secondary action buttons
          if (order.isDelivered) ...[
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
                    borderColor: Colors.orange.shade600,
                    textColor: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ],
          if (order.canBeCancelled) ...[
            if (order.isDelivered) SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildSecondaryButton(
                onPressed: () => _cancelOrder(),
                icon: Icons.cancel_outlined,
                label: 'Cancel Order',
                borderColor: Colors.red.shade600,
                textColor: Colors.red.shade600,
              ),
            ),
          ],
        ],
      ),
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
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
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
      icon: Icon(icon, size: 18, color: textColor),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor, width: 1.5),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ==========================================================================
  // ACTION METHODS
  // ==========================================================================

  Future<void> _shareOrder() async {
    try {
      if (orderData == null) return;

      final order = orderData!;

      // Format order details as text
      final orderText = _formatOrderDetailsForSharing(order);

      // Share the order details
      await Share.share(
        orderText,
        subject: 'Order Details - #${order.orderNumber}',
      );

    } catch (e) {
      UIUtils.showErrorSnackBar(context, 'Failed to share order details');
    }
  }

  String _formatOrderDetailsForSharing(OrderDetails order) {
    final buffer = StringBuffer();

    buffer.writeln('📋 ORDER DETAILS');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🆔 Order Number: #${order.orderNumber}');
    buffer.writeln('📅 Order Date: ${order.orderAt}');
    buffer.writeln('📊 Status: ${order.displayStatus}');
    buffer.writeln('💳 Payment: ${order.paymentMethod.toUpperCase()}');
    buffer.writeln();

    buffer.writeln('🛍️ ITEMS (${order.orderItems.length})');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    for (final item in order.orderItems) {
      buffer.writeln('• ${item.productName}');
      buffer.writeln('  Qty: ${item.quantity} × \${item.price.toStringAsFixed(2)} = \${item.total.toStringAsFixed(2)}');
      if (item.attributes.isNotEmpty) {
        buffer.writeln('  Attributes: ${item.attributes.join(', ')}');
      }
      buffer.writeln();
    }

    buffer.writeln('💰 SUMMARY');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Subtotal: \${order.subTotal.toStringAsFixed(2)}');
    buffer.writeln('Delivery Fee: \${order.deliveryFee.toStringAsFixed(2)}');
    if (order.vatAmount > 0) {
      buffer.writeln('VAT: \${order.vatAmount.toStringAsFixed(2)}');
    }
    buffer.writeln('TOTAL: \${order.totalAmount.toStringAsFixed(2)}');
    buffer.writeln();

    buffer.writeln('📍 DELIVERY ADDRESS');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('👤 ${order.customer.name}');
    buffer.writeln('🏠 ${order.customer.address}');
    if (order.customer.phone.isNotEmpty) {
      buffer.writeln('📞 ${order.customer.phone}');
    }

    buffer.writeln();
    buffer.writeln('Generated from KarbarShop App');

    return buffer.toString();
  }

  Future<void> _downloadInvoice() async {
    try {
      if (orderData == null) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Generating Invoice...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait while we create your invoice',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Check permissions for Android
      bool hasPermission = true;
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        hasPermission = status.isGranted;
      }

      if (!hasPermission) {
        Navigator.pop(context); // Close loading dialog
        UIUtils.showErrorSnackBar(context, 'Storage permission is required to download invoice');
        return;
      }

      // Generate PDF
      final pdf = await _generateInvoicePDF(orderData!);

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        Navigator.pop(context);
        UIUtils.showErrorSnackBar(context, 'Could not access storage directory');
        return;
      }

      // Create file path
      final fileName = 'Invoice_${orderData!.orderNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Write PDF to file
      await file.writeAsBytes(pdf);

      // Close loading dialog
      Navigator.pop(context);

      // Show success dialog with options
      _showInvoiceDownloadedDialog(file.path, fileName);

    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      UIUtils.showErrorSnackBar(context, 'Failed to generate invoice: ${e.toString()}');
    }
  }

  Future<Uint8List> _generateInvoicePDF(OrderDetails order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'INVOICE',
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'KarbarShop',
                            style: pw.TextStyle(
                              fontSize: 16,
                              color: PdfColors.blue600,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Order #${order.orderNumber}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Date: ${order.orderAt}',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            'Status: ${order.displayStatus}',
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Customer Information
            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Bill To:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(order.customer.name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text(order.customer.address, style: pw.TextStyle(fontSize: 10)),
                  if (order.customer.phone.isNotEmpty)
                    pw.Text('Phone: ${order.customer.phone}', style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Items Table
            pw.Text(
              'Order Items',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Product', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                // Items
                ...order.orderItems.map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(item.productName, style: pw.TextStyle(fontSize: 10)),
                          if (item.attributes.isNotEmpty)
                            pw.Text(
                              'Attributes: ${item.attributes.join(', ')}',
                              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                            ),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('${item.quantity}', style: pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('\${item.price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('\${item.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                )).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('\${order.subTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Delivery Fee:', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('\${order.deliveryFee.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                      if (order.vatAmount > 0) ...[
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('VAT:', style: pw.TextStyle(fontSize: 12)),
                            pw.Text('\${order.vatAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                      pw.Container(
                        margin: pw.EdgeInsets.symmetric(vertical: 8),
                        height: 1,
                        color: PdfColors.grey400,
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'TOTAL:',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '\${order.totalAmount.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Payment Method: ${order.paymentMethod.toUpperCase()}',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Thank you for shopping with KarbarShop!',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.blue600),
                  ),
                  pw.Text(
                    'Generated on: ${DateTime.now().toString().split('.')[0]}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  void _showInvoiceDownloadedDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Invoice Downloaded',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your invoice has been successfully downloaded.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.file_present, color: AppConstants.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _shareFile(filePath, fileName);
              },
              icon: Icon(Icons.share, size: 18),
              label: Text('Share'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.check, size: 18),
              label: Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareFile(String filePath, String fileName) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Invoice for Order #${orderData?.orderNumber}',
        subject: 'Invoice - ${orderData?.orderNumber}',
      );
    } catch (e) {
      UIUtils.showErrorSnackBar(context, 'Failed to share invoice file');
    }
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


  void _contactSupport() {
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
    Navigator.pushNamed(
      context,
      '/write-review',
      arguments: {'orderId': widget.orderId, 'items': orderData?.orderItems},
    );
  }

  void _reportProblem() {
    Navigator.pushNamed(
      context,
      '/report-problem',
      arguments: {'orderId': widget.orderId},
    );
  }

  Future<void> _reorderItems() async {
    try {
      final orderId = int.tryParse(widget.orderId);
      if (orderId == null) return;

      await OrderApiService.reorderItems(orderId);

      UIUtils.showSuccessSnackBar(context, 'Items added to cart successfully');

    } catch (e) {
      UIUtils.showErrorSnackBar(context, OrderApiService.getErrorMessage(e));
    }
  }

  void _callCustomer(String phoneNumber) {
    UIUtils.showSuccessSnackBar(context, 'Opening dialer...');
  }

  void _viewProduct(String productUrl) {
    UIUtils.showSuccessSnackBar(context, 'Opening product page...');
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Cancel Order',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to cancel this order? This action cannot be undone.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Keep Order',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _performCancelOrder();
              },
              icon: Icon(Icons.cancel, size: 18),
              label: Text('Yes, Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCancelOrder() async {
    try {
      final orderId = int.tryParse(widget.orderId);
      if (orderId == null) return;

      await OrderApiService.cancelOrder(orderId);

      // Refresh order details
      await _loadOrderDetails();

      UIUtils.showSuccessSnackBar(context, 'Order cancelled successfully');

    } catch (e) {
      UIUtils.showErrorSnackBar(context, OrderApiService.getErrorMessage(e));
    }
  }
}