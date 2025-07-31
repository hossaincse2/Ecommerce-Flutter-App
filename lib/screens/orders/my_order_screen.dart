import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/shared_widgets.dart';
import '../../models/order.dart';
import '../../services/order_api_service.dart';

class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;

  // API data
  List<Order> allOrders = [];
  int currentPage = 1;
  bool hasMoreData = true;

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

  Future<void> _loadOrders({bool refresh = false}) async {
    try {
      if (refresh) {
        setState(() {
          currentPage = 1;
          hasMoreData = true;
          errorMessage = null;
        });
      }

      if (!refresh && !hasMoreData) return;

      setState(() {
        if (refresh) {
          isLoading = true;
        } else {
          isLoadingMore = true;
        }
      });

      final response = await OrderApiService.getUserOrders(
        page: currentPage,
        perPage: 10,
      );

      setState(() {
        if (refresh) {
          allOrders = response.data;
        } else {
          allOrders.addAll(response.data);
        }

        hasMoreData = currentPage < response.meta.lastPage;
        currentPage++;
        isLoading = false;
        isLoadingMore = false;
        errorMessage = null;
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
        errorMessage = OrderApiService.getErrorMessage(e);
      });

      if (mounted) {
        UIUtils.showErrorSnackBar(context, errorMessage!);
      }
    }
  }

  Future<void> _loadMoreOrders() async {
    if (!isLoadingMore && hasMoreData) {
      await _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: isLoading
                ? LoadingWidgets.buildLoadingScreen(message: 'Loading orders...')
                : errorMessage != null
                ? _buildErrorState()
                : _buildTabBarView(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppConstants.textPrimaryColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'My Orders',
        style: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.search,
              color: AppConstants.primaryColor,
              size: 20,
            ),
          ),
          onPressed: () => _showSearchDialog(),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: EdgeInsets.all(4),
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
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          _buildTab('All', allOrders.length),
          _buildTab('Processing', _filterOrdersByStatus('processing').length),
          _buildTab('Shipped', _filterOrdersByStatus('shipped').length),
          _buildTab('Delivered', _filterOrdersByStatus('delivered').length),
          _buildTab('Cancelled', _filterOrdersByStatus('cancelled').length),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int count) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            if (count > 0) ...[
              SizedBox(width: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _tabController.index == _getTabIndex(text)
                      ? Colors.white.withOpacity(0.3)
                      : AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _tabController.index == _getTabIndex(text)
                        ? Colors.white
                        : AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getTabIndex(String tabName) {
    switch (tabName) {
      case 'All': return 0;
      case 'Processing': return 1;
      case 'Shipped': return 2;
      case 'Delivered': return 3;
      case 'Cancelled': return 4;
      default: return 0;
    }
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

  List<Order> _filterOrdersByStatus(String status) {
    return allOrders.where((order) => order.filterStatus == status).toList();
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrders(refresh: true),
      color: AppConstants.primaryColor,
      backgroundColor: Colors.white,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreOrders();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
          itemCount: orders.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == orders.length) {
              return _buildLoadingMoreIndicator();
            }
            final order = orders[index];
            return _buildOrderCard(order, index);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: AppConstants.primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
                  (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Start Shopping',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadOrders(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildOrderHeader(order),
            Container(
              height: 1,
              color: Colors.grey.shade100,
            ),
            _buildOrderContent(order),
            Container(
              height: 1,
              color: Colors.grey.shade100,
            ),
            _buildOrderActions(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 16,
                      color: AppConstants.primaryColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Order #${order.orderNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppConstants.textSecondaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Placed on ${order.createdAt}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusChip(order.displayStatus),
        ],
      ),
    );
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderContent(Order order) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: AppConstants.textSecondaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${order.totalQuantity} item${order.totalQuantity > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Total: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (order.deliveryFee > 0) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Delivery: \$${order.deliveryFee.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(Order order) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewOrderDetails(order),
              icon: Icon(
                Icons.visibility_outlined,
                size: 18,
                color: AppConstants.primaryColor,
              ),
              label: Text(
                'View Details',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppConstants.primaryColor, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          if (order.filterStatus == 'shipped' || order.filterStatus == 'delivered')
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _trackOrder(order),
                icon: Icon(
                  Icons.track_changes,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Track Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (order.filterStatus == 'processing')
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _cancelOrder(order),
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
        String searchQuery = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.search, color: AppConstants.primaryColor),
              SizedBox(width: 8),
              Text(
                'Search Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: TextField(
            onChanged: (value) => searchQuery = value,
            decoration: InputDecoration(
              hintText: 'Enter order number',
              prefixIcon: Icon(Icons.receipt_long, color: AppConstants.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppConstants.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (searchQuery.trim().isNotEmpty) {
                  await _searchOrders(searchQuery.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Search',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchOrders(String query) async {
    try {
      setState(() => isLoading = true);

      final searchResults = await OrderApiService.searchOrders(query);

      setState(() {
        allOrders = searchResults;
        isLoading = false;
      });

      if (searchResults.isEmpty) {
        UIUtils.showInfoSnackBar(context, 'No orders found matching "$query"');
      }

    } catch (e) {
      setState(() => isLoading = false);
      UIUtils.showErrorSnackBar(context, OrderApiService.getErrorMessage(e));
    }
  }

  void _viewOrderDetails(Order order) {
    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: {'orderId': order.id.toString()},
    );
  }

  void _trackOrder(Order order) {
    Navigator.pushNamed(
      context,
      '/order-tracking',
      arguments: {'orderId': order.id.toString()},
    );
  }

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
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
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Keep Order',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performCancelOrder(order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Yes, Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCancelOrder(Order order) async {
    try {
      await OrderApiService.cancelOrder(order.id);

      // Refresh orders list
      await _loadOrders(refresh: true);

      UIUtils.showSuccessSnackBar(context, 'Order cancelled successfully');

    } catch (e) {
      UIUtils.showErrorSnackBar(context, OrderApiService.getErrorMessage(e));
    }
  }
}