import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/shared_widgets.dart';


class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;

  // Mock orders data - replace with actual data model
  final List<Map<String, dynamic>> allOrders = [
    {
      'id': 'ORD001',
      'date': '2024-01-15',
      'status': 'delivered',
      'total': 299.99,
      'items': 3,
      'image': 'https://example.com/product1.jpg',
      'title': 'Wireless Headphones + 2 more items',
    },
    {
      'id': 'ORD002',
      'date': '2024-01-20',
      'status': 'processing',
      'total': 149.50,
      'items': 1,
      'image': 'https://example.com/product2.jpg',
      'title': 'Smart Watch',
    },
    {
      'id': 'ORD003',
      'date': '2024-01-25',
      'status': 'shipped',
      'total': 89.99,
      'items': 2,
      'image': 'https://example.com/product3.jpg',
      'title': 'Phone Case + Screen Protector',
    },
    {
      'id': 'ORD004',
      'date': '2024-01-28',
      'status': 'cancelled',
      'total': 199.99,
      'items': 1,
      'image': 'https://example.com/product4.jpg',
      'title': 'Bluetooth Speaker',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    // TODO: Implement API call to fetch orders
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
        title: 'My Orders',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppConstants.primaryColor),
            onPressed: () => _showSearchDialog(),
          ),
          SizedBox(width: AppConstants.smallPadding),
        ],
      ),
      body: isLoading
          ? LoadingWidgets.buildLoadingScreen(message: 'Loading orders...')
          : Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Processing'),
          Tab(text: 'Shipped'),
          Tab(text: 'Delivered'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersList(allOrders),
        _buildOrdersList(_filterOrdersByStatus('processing')),
        _buildOrdersList(_filterOrdersByStatus('shipped')),
        _buildOrdersList(_filterOrdersByStatus('delivered')),
        _buildOrdersList(_filterOrdersByStatus('cancelled')),
      ],
    );
  }

  List<Map<String, dynamic>> _filterOrdersByStatus(String status) {
    return allOrders.where((order) => order['status'] == status).toList();
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return SharedWidgets.buildEmptyState(
        message: 'No orders found',
        icon: Icons.shopping_bag_outlined,
        actionText: 'Start Shopping',
        onActionPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
              (route) => false,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        children: [
          _buildOrderHeader(order),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildOrderContent(order),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildOrderActions(order),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> order) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order['id']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Placed on ${order['date']}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
          _buildStatusChip(order['status']),
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

  Widget _buildOrderContent(Map<String, dynamic> order) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppConstants.primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${order['items']} item${order['items'] > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '\$${order['total'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
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

  Widget _buildOrderActions(Map<String, dynamic> order) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _viewOrderDetails(order),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppConstants.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View Details',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          if (order['status'] == 'shipped' || order['status'] == 'delivered')
            Expanded(
              child: ElevatedButton(
                onPressed: () => _trackOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Track Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (order['status'] == 'processing')
            Expanded(
              child: ElevatedButton(
                onPressed: () => _cancelOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          title: Text('Search Orders'),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Enter order ID or product name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement search functionality
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    // TODO: Navigate to order details screen
    Navigator.pushNamed(context, '/order-details', arguments: order['id']);
  }

  void _trackOrder(Map<String, dynamic> order) {
    // TODO: Navigate to order tracking screen
    Navigator.pushNamed(context, '/order-tracking', arguments: order['id']);
  }

  void _cancelOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          title: Text('Cancel Order'),
          content: Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement cancel order API call
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