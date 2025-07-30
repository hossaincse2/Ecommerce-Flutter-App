import 'package:flutter/material.dart';
import 'package:karbar_shop/services/api_service.dart';
import 'package:karbar_shop/screens/widgets/filter_bottom_sheet.dart';
import 'package:karbar_shop/screens/widgets/product_card.dart';
import '../../config/app_config.dart';
import '../../models/product.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // State variables
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _hasMoreData = true;
  int _currentPage = 1;

  // Filter variables
  String _currentCategory = AppConfig.defaultCategory;
  String _currentSortBy = AppConfig.defaultSortBy;
  String _currentBrandId = 'all';
  String _searchQuery = '';

  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _products.clear();
        _hasMoreData = true;
      });
    }

    setState(() {
      _isLoading = refresh || _products.isEmpty;
      _hasError = false;
    });

    try {
      final products = await ApiService.getProducts(
        perPage: AppConfig.shopPerPage,
        page: _currentPage,
        category: _currentCategory == AppConfig.defaultCategory ? null : _currentCategory,
        brand: _currentBrandId == 'all' ? null : _currentBrandId,
        sortBy: _currentSortBy == AppConfig.defaultSortBy ? null : _currentSortBy,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        if (refresh || _currentPage == 1) {
          _products = products;
        } else {
          _products.addAll(products);
        }

        _hasMoreData = products.length == AppConfig.shopPerPage;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final products = await ApiService.getProducts(
        perPage: AppConfig.shopPerPage,
        page: _currentPage,
        category: _currentCategory == AppConfig.defaultCategory ? null : _currentCategory,
        brand: _currentBrandId == 'all' ? null : _currentBrandId,
        sortBy: _currentSortBy == AppConfig.defaultSortBy ? null : _currentSortBy,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _products.addAll(products);
        _hasMoreData = products.length == AppConfig.shopPerPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      _currentPage--; // Revert page increment on error
      setState(() {
        _isLoadingMore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more products'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onFilterTap() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentCategory: _currentCategory,
        currentSortBy: _currentSortBy,
        currentBrandId: _currentBrandId,
      ),
    );

    if (result != null) {
      setState(() {
        _currentCategory = result['category'] ?? _currentCategory;
        _currentSortBy = result['sortBy'] ?? _currentSortBy;
        _currentBrandId = result['brandId'] ?? _currentBrandId;
      });

      _loadProducts(refresh: true);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty || query.length >= 2) {
      _loadProducts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: _onFilterTap,
            tooltip: 'Filters',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProducts(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return _buildLoadingState();
    }

    if (_hasError && _products.isEmpty) {
      return _buildErrorState();
    }

    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return _buildProductGrid();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadProducts(refresh: true),
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentCategory = AppConfig.defaultCategory;
                  _currentSortBy = AppConfig.defaultSortBy;
                  _currentBrandId = 'all';
                  _searchQuery = '';
                  _searchController.clear();
                });
                _loadProducts(refresh: true);
              },
              icon: Icon(Icons.clear_all),
              label: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Column(
      children: [
        // Filter summary (keep your existing code)
        if (_currentCategory != AppConfig.defaultCategory ||
            _currentBrandId != 'all' ||
            _searchQuery.isNotEmpty)
          Container(
            // Your existing filter summary widget
          ),

        // Product grid with improved infinite scroll
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent &&
                  !_isLoadingMore &&
                  _hasMoreData) {
                _loadMoreProducts();
                return true;
              }
              return false;
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppConfig.shopGridColumns,
                childAspectRatio: AppConfig.shopItemAspectRatio,
                crossAxisSpacing: AppConfig.shopGridSpacing,
                mainAxisSpacing: AppConfig.shopGridSpacing,
              ),
              itemCount: _products.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _products.length) {
                  return ProductCard(product: _products[index]);
                } else {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}