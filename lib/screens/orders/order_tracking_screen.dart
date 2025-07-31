import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/shared_widgets.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool isLoading = true;

  // Mock order tracking data - replace with actual data model
  Map<String, dynamic> orderData = {
    'id': 'ORD002',
    'status': 'shipped',
    'estimatedDelivery': '2024-02-05',
    'trackingNumber': 'TRK123456789',
    'courier': 'FastDelivery Express',
    'orderDate': '2024-01-20',
    'total': 149.50,
    'shippingAddress': '123 Main St, City, State 12345',
    'items': [
      {
        'name': 'Smart Watch',
        'image': 'https://example.com/watch.jpg',
        'price': 149.50,
        'quantity': 1,
      }
    ],
  };

  List<Map<String, dynamic>> trackingSteps = [
    {
      'title': 'Order Placed',
      'subtitle': 'Your order has been placed successfully',
      'time': '2024-01-20 10:30 AM',
      'isCompleted': true,
      'icon': Icons.shopping_cart,
    },
    {
      'title': 'Order Confirmed',
      'subtitle': 'Your order has been confirmed and is being prepared',
      'time': '2024-01-20 11:15 AM',
      'isCompleted': true,
      'icon': Icons.check_circle,
    },
    {
      'title': 'Shipped',
      'subtitle': 'Your order has been shipped',
      'time': '2024-01-22 02:45 PM',
      'isCompleted': true,
      'icon': Icons.local_shipping,
    },
    {
      'title': 'Out for Delivery',
      'subtitle': 'Your order is out for delivery',
      'time': '2024-02-05 08:00 AM',
      'isCompleted': false,
      'icon': Icons.delivery_dining,
    },
    {
      'title': 'Delivered',
      'subtitle': 'Your order has been delivered',
      'time': 'Expected by 6:00 PM',
      'isCompleted': false,
      'icon': Icons.done_all,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadOrderTracking();
  }

  Future<void> _loadOrderTracking() async {
    // TODO: Implement API call to fetch order tracking data
    await Future.delayed(Duration(seconds: 1)); // Simulate API call

    setState(() {
      isLoading = false;
    });
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

  Widget _buildOrderHeader() {
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
                'Order #${orderData['id']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              _buildStatusChip(orderData['status']),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Placed on ${orderData['orderDate']}',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Total: \$${orderData['total'].toStringAsFixed(2)}',
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
                      'Tracking Number',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      orderData['trackingNumber'],
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
                onPressed: () => _copyTrackingNumber(),
                icon: Icon(
                  Icons.copy,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppConstants.primaryColor,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Delivery',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      orderData['estimatedDelivery'],
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
                Icons.business,
                color: AppConstants.primaryColor,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Courier',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      orderData['courier'],
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

  Widget _buildTrackingTimeline() {
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
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(trackingSteps.length, (index) {
        final step = trackingSteps[index];
        final isLast = index == trackingSteps.length - 1;

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
            'Order Items (${orderData['items'].length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: orderData['items'].map<Widget>((item) {
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
                        image: item['image'] != null
                            ? DecorationImage(
                          image: NetworkImage(item['image']),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: item['image'] == null
                          ? Icon(Icons.image, color: Colors.grey.shade400)
                          : null,
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
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Qty: ${item['quantity']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item['price'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
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
                child: Text(
                  orderData['shippingAddress'],
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.textPrimaryColor,
                  ),
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

  void _copyTrackingNumber() {
    // TODO: Implement copy to clipboard
    UIUtils.showSuccessSnackBar(context, 'Tracking number copied to clipboard');
  }

  void _shareTracking() {
    // TODO: Implement share functionality
    UIUtils.showInfoSnackBar(context, 'Sharing tracking information');
  }
}