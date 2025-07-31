import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/shared_widgets.dart';
import '../../models/order_details.dart';
import '../../models/order_tracking.dart';
import '../../models/order_item.dart';
import '../../services/order_api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool isLoading = true;
  OrderDetails? orderData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderTracking();
  }

  Future<void> _loadOrderTracking() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: SharedWidgets.buildAppBar(
        title: 'Track Order',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: AppConstants.primaryColor),
            onPressed: () => _shareTracking(),
          ),
          SizedBox(width: AppConstants.smallPadding),
        ],
      ),
      body: isLoading
          ? LoadingWidgets.buildLoadingScreen(message: 'Loading tracking info...')
          : errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
        onRefresh: _loadOrderTracking,
        color: AppConstants.primaryColor,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildOrderHeader(),
              _buildTrackingInfo(),
              _buildTrackingTimeline(),
              _buildOrderItems(),
              _buildDeliveryAddress(),
              SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load tracking info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadOrderTracking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    if (orderData == null) return SizedBox.shrink();

    final order = orderData!;

    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      padding: EdgeInsets.all(AppConstants.defaultPadding),
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
                'Order #${order.orderNumber}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              _buildStatusChip(order.displayStatus),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Placed on ${order.orderAt}',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Total: \$${order.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo() {
    if (orderData == null) return SizedBox.shrink();

    final order = orderData!;
    final hasTrackingNumber = order.orderNumber.isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          if (hasTrackingNumber) ...[
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Number',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _copyTrackingNumber(order.orderNumber),
                  icon: Icon(
                    Icons.copy,
                    color: AppConstants.primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppConstants.primaryColor,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDeliveryLocation(order.deliveryLocation),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.payment,
                color: AppConstants.primaryColor,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      order.paymentMethod.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDeliveryLocation(String location) {
    return location.replaceAll('_', ' ').split(' ').map((word) =>
    word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  Widget _buildTrackingTimeline() {
    if (orderData == null || orderData!.orderTracking.isEmpty) {
      return _buildDefaultTimeline();
    }

    final order = orderData!;

    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
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
          SizedBox(height: 16),
          _buildTimelineFromTracking(order.orderTracking),
        ],
      ),
    );
  }

  Widget _buildDefaultTimeline() {
    if (orderData == null) return SizedBox.shrink();

    final order = orderData!;
    final currentStatus = order.status.toLowerCase();

    // Create default timeline based on current status
    final List<Map<String, dynamic>> defaultSteps = [
      {
        'title': 'Order Placed',
        'subtitle': 'Your order has been placed successfully',
        'time': order.orderAt,
        'isCompleted': true,
        'icon': Icons.shopping_cart,
      },
    ];

    // Add steps based on current status
    if (['processed', 'delivered', 'completed'].contains(currentStatus)) {
      defaultSteps.add({
        'title': 'Order Confirmed',
        'subtitle': 'Your order has been confirmed and is being prepared',
        'time': order.orderAt,
        'isCompleted': true,
        'icon': Icons.check_circle,
      });
    }

    if (['delivered', 'completed'].contains(currentStatus)) {
      defaultSteps.add({
        'title': 'Delivered',
        'subtitle': 'Your order has been delivered successfully',
        'time': 'Delivered',
        'isCompleted': true,
        'icon': Icons.done_all,
      });
    } else if (currentStatus == 'processed') {
      defaultSteps.add({
        'title': 'Out for Delivery',
        'subtitle': 'Your order is out for delivery',
        'time': 'In Progress',
        'isCompleted': false,
        'icon': Icons.delivery_dining,
      });
    } else if (currentStatus == 'cancelled') {
      defaultSteps.add({
        'title': 'Cancelled',
        'subtitle': 'Your order has been cancelled',
        'time': 'Cancelled',
        'isCompleted': true,
        'icon': Icons.cancel,
      });
    }

    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
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
          SizedBox(height: 16),
          _buildTimeline(defaultSteps),
        ],
      ),
    );
  }

  Widget _buildTimelineFromTracking(List<OrderTracking> trackingList) {
    final steps = trackingList.map((tracking) => {
      'title': tracking.status,
      'subtitle': tracking.note,
      'time': tracking.displayTime,
      'isCompleted': true,
      'icon': _getIconForStatus(tracking.status),
    }).toList();

    return _buildTimeline(steps);
  }

  IconData _getIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.shopping_cart;
      case 'processed':
        return Icons.check_circle;
      case 'delivered':
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.radio_button_checked;
    }
  }

  Widget _buildTimeline(List<Map<String, dynamic>> steps) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step['isCompleted']
                        ? AppConstants.primaryColor
                        : AppConstants.textSecondaryColor.withOpacity(0.2),
                  ),
                  child: Icon(
                    step['icon'],
                    size: 14,
                    color: step['isCompleted'] ? Colors.white : AppConstants.textSecondaryColor,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: step['isCompleted']
                        ? AppConstants.primaryColor
                        : AppConstants.textSecondaryColor.withOpacity(0.2),
                  ),
              ],
            ),
            SizedBox(width: 16),
            // Timeline content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: step['isCompleted']
                            ? AppConstants.textPrimaryColor
                            : AppConstants.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      step['subtitle'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      step['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderItems() {
    if (orderData == null || orderData!.orderItems.isEmpty) return SizedBox.shrink();

    final order = orderData!;

    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${order.orderItems.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: order.orderItems.map<Widget>((item) {
              return _buildOrderItem(item);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
              image: item.productImage.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(item.productImage),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: item.productImage.isEmpty
                ? Icon(Icons.shopping_bag_outlined, color: Colors.grey.shade400)
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
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    if (orderData == null) return SizedBox.shrink();

    final customer = orderData!.customer;

    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppConstants.primaryColor,
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      customer.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                        height: 1.4,
                      ),
                    ),
                    if (customer.phone.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        displayText = 'Processing';
        break;
      case 'shipped':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        displayText = 'Shipped';
        break;
      case 'delivered':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        displayText = 'Delivered';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        displayText = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _copyTrackingNumber(String orderNumber) {
    Clipboard.setData(ClipboardData(text: orderNumber));
    UIUtils.showSuccessSnackBar(context, 'Order number copied to clipboard');
  }

  void _shareTracking() {
    if (orderData != null) {
      final trackingInfo = 'Order #${orderData!.orderNumber}\nStatus: ${orderData!.displayStatus}';
      // Implement actual sharing functionality here
      UIUtils.showInfoSnackBar(context, 'Sharing tracking information...');
    }
  }
}