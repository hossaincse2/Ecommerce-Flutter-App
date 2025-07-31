import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/common/loading_widgets.dart';
import '../widgets/common/shared_widgets.dart';

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // ================ STATE VARIABLES ================
  List<Product> products = [];
  List<Category> categories = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isSearchLoading = false; // New loading state for search/filter operations
  int currentPage = 1;
  bool hasMoreProducts = true;

  // ================ FILTER VARIABLES ================
  String searchQuery = '';
  String selectedCategory = '';
  String selectedBrand = '';
  String selectedSortBy = '';
  bool showClearSearch = false;
  int totalProductCount = 0;

  List<String> availableBrands = [];
  List<String> sortOptions = [
    'name_asc',
    'name_desc',
    'price_low_high',
    'price_high_low',
    'newest',
    'oldest'
  ];

  // ================ CONTROLLERS ================
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;
  int _currentIndex = 0;

  // ================ LIFECYCLE METHODS ================

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ================ EVENT HANDLERS ================

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoadingMore && hasMoreProducts) {
        _loadMoreProducts();
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      showClearSearch = value.isNotEmpty;
    });

    // Cancel previous timer if exists
    if (_searchTimer != null) {
      _searchTimer!.cancel();
    }

    // Start new timer
    _searchTimer = Timer(Duration(milliseconds: 800), () {
      if (mounted && searchQuery == _searchController.text) {
        _applyFilters();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
      showClearSearch = false;
    });
    _applyFilters();
  }

  void _debounceSearch() {
    // This method is now handled in _onSearchChanged
  }

  void _applyFilters() {
    setState(() {
      currentPage = 1;
      hasMoreProducts = true;
    });
    _loadProductsWithFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  // ================ API METHODS ================

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        currentPage = 1;
        hasMoreProducts = true;
      });

      final results = await Future.wait([
        ApiService.getProducts(perPage: 12, page: 1),
        ApiService.getCategories(),
      ]);

      final productsList = results[0] as List<Product>;
      final categoriesList = results[1] as List<Category>;

      // Extract unique brands from products
      Set<String> brandsSet = {};
      for (var product in productsList) {
        if (product.brand.isNotEmpty) {
          brandsSet.add(product.brand);
        }
      }

      setState(() {
        products = productsList;
        categories = categoriesList;
        availableBrands = brandsSet.toList()..sort();
        totalProductCount = productsList.length;
        isLoading = false;
        hasMoreProducts = productsList.length >= 12;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      UIUtils.showErrorSnackBar(context, 'Error loading data: $e');
    }
  }

  Future<void> _loadProductsWithFilters() async {
    try {
      setState(() {
        isSearchLoading = true; // Use search loading instead of main loading
      });

      final productsList = await ApiService.getProducts(
        perPage: 12,
        page: 1,
        search: searchQuery.isNotEmpty ? searchQuery : null,
        category: selectedCategory.isNotEmpty ? selectedCategory : null,
        brand: selectedBrand.isNotEmpty ? selectedBrand : null,
        sortBy: selectedSortBy.isNotEmpty ? selectedSortBy : null,
      );

      setState(() {
        products = productsList;
        currentPage = 1;
        totalProductCount = productsList.length;
        isSearchLoading = false; // Clear search loading
        hasMoreProducts = productsList.length >= 12;
      });
    } catch (e) {
      setState(() {
        isSearchLoading = false; // Clear search loading on error
      });
      UIUtils.showErrorSnackBar(context, 'Error loading products: $e');
    }
  }

  Future<void> _loadMoreProducts() async {
    if (isLoadingMore || !hasMoreProducts) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final newProducts = await ApiService.getProducts(
        perPage: 12,
        page: currentPage + 1,
        search: searchQuery.isNotEmpty ? searchQuery : null,
        category: selectedCategory.isNotEmpty ? selectedCategory : null,
        brand: selectedBrand.isNotEmpty ? selectedBrand : null,
        sortBy: selectedSortBy.isNotEmpty ? selectedSortBy : null,
      );

      setState(() {
        if (newProducts.isNotEmpty) {
          products.addAll(newProducts);
          currentPage++;
          totalProductCount = products.length;
          hasMoreProducts = newProducts.length >= 12;
        } else {
          hasMoreProducts = false;
        }
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      UIUtils.showErrorSnackBar(context, 'Error loading more products: $e');
    }
  }

  // ================ BUILD METHODS ================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(), // Search bar will always be visible now
    );
  }

  // ================ APP BAR ================

  PreferredSizeWidget _buildAppBar() {
    return SharedWidgets.buildAppBar(
      title: 'Karbar Shop',
      actions: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFF2E86AB)),
          onPressed: () => UIUtils.onCartTap(context),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  // ================ MAIN BODY ================

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Color(0xFF2E86AB),
      child: Column(
        children: [
          _buildSearchAndFilterSection(), // Always visible search section
          Expanded(
            child: isLoading
                ? LoadingWidgets.buildLoadingScreen() // Only for initial loading
                : SingleChildScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductsSection(), // This will handle search loading internally
                  if (isLoadingMore) LoadingWidgets.buildLoadingMoreIndicator(),
                  SizedBox(height: 100), // Bottom padding for navigation bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================ SEARCH AND FILTER SECTION ================

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF2E86AB)),
                      suffixIcon: showClearSearch
                          ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: _clearSearch,
                      )
                          : null,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2E86AB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.filter_list, color: Colors.white),
                      if (_hasActiveFilters())
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _showFilterBottomSheet,
                ),
              ),
            ],
          ),
          if (searchQuery.isNotEmpty || _hasActiveFilters()) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalProductCount products found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_hasActiveFilters())
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = '';
                        selectedBrand = '';
                        selectedSortBy = '';
                      });
                      _applyFilters();
                    },
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E86AB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedCategory.isNotEmpty ||
        selectedBrand.isNotEmpty ||
        selectedSortBy.isNotEmpty;
  }

  // ================ FILTER BOTTOM SHEET ================

  Widget _buildFilterBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = '';
                          selectedBrand = '';
                          selectedSortBy = '';
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: Text('Clear All'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryFilter(),
                      SizedBox(height: 20),
                      _buildBrandFilter(),
                      SizedBox(height: 20),
                      _buildSortByFilter(),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E86AB),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Apply Filters',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('All', selectedCategory.isEmpty, () {
              setState(() {
                selectedCategory = '';
              });
            }),
            ...categories.map((category) {
              return _buildFilterChip(
                category.name,
                selectedCategory == category.slug,
                    () {
                  setState(() {
                    selectedCategory = selectedCategory == category.slug ? '' : category.slug;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('All', selectedBrand.isEmpty, () {
              setState(() {
                selectedBrand = '';
              });
            }),
            ...availableBrands.map((brand) {
              return _buildFilterChip(
                brand,
                selectedBrand == brand,
                    () {
                  setState(() {
                    selectedBrand = selectedBrand == brand ? '' : brand;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildSortByFilter() {
    final sortLabels = {
      'name_asc': 'Name (A-Z)',
      'name_desc': 'Name (Z-A)',
      'price_low_high': 'Price (Low to High)',
      'price_high_low': 'Price (High to Low)',
      'newest': 'Newest First',
      'oldest': 'Oldest First',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('Default', selectedSortBy.isEmpty, () {
              setState(() {
                selectedSortBy = '';
              });
            }),
            ...sortOptions.map((sortOption) {
              return _buildFilterChip(
                sortLabels[sortOption] ?? sortOption,
                selectedSortBy == sortOption,
                    () {
                  setState(() {
                    selectedSortBy = selectedSortBy == sortOption ? '' : sortOption;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2E86AB) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF2E86AB) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(0xFF2E86AB).withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ================ PRODUCTS SECTION ================

  // ================ PRODUCTS SECTION ================

  Widget _buildProductsSection() {
    // Show search loading overlay
    if (isSearchLoading) {
      return Container(
        height: 400,
        child: Stack(
          children: [
            // Show previous products with opacity if they exist
            if (products.isNotEmpty)
              Opacity(
                opacity: 0.3,
                child: _buildProductsGrid(),
              ),
            // Loading overlay
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Searching products...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                searchQuery.isNotEmpty || _hasActiveFilters()
                    ? 'No products found matching your criteria'
                    : 'No products found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (searchQuery.isNotEmpty || _hasActiveFilters()) ...[
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                      selectedCategory = '';
                      selectedBrand = '';
                      selectedSortBy = '';
                      showClearSearch = false;
                    });
                    _applyFilters();
                  },
                  child: Text(
                    'Clear all filters',
                    style: TextStyle(color: Color(0xFF2E86AB)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductsGrid(),
      ],
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        if (product.id != null) {
          Navigator.pushNamed(context, '/product-details', arguments: product.slug.toString());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product),
            _buildProductInfo(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    final hasDiscount = product.salePrice > 0 && product.salePrice < product.unitPrice;
    final discountPercentage = hasDiscount
        ? ((product.unitPrice - product.salePrice) / product.unitPrice * 100).round()
        : 0;

    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              width: double.infinity,
              child: Image.network(
                product.previewImage,
                fit: BoxFit.cover,
                headers: {
                  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                  'Accept': 'image/webp,image/apng,image/*,q=0.8',
                },
                loadingBuilder: LoadingWidgets.buildImageLoadingBuilder,
                errorBuilder: SharedWidgets.buildProductImageErrorBuilder,
              ),
            ),
          ),
          if (hasDiscount) SharedWidgets.buildDiscountBadge(discountPercentage),
          if (product.freeDelivery) SharedWidgets.buildFreeDeliveryBadge(),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    final hasDiscount = product.salePrice > 0 && product.salePrice < product.unitPrice;
    final displayPrice = hasDiscount ? product.salePrice : product.unitPrice;

    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                product.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 2),
            Text(
              product.brand,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            _buildProductPrice(product, displayPrice, hasDiscount),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPrice(Product product, double displayPrice, bool hasDiscount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '৳${displayPrice.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E86AB),
          ),
        ),
        if (hasDiscount)
          Text(
            '৳${product.unitPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}