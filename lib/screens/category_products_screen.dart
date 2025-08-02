import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/common/cart_drawer_widget.dart';
import '../widgets/common/loading_widgets.dart';
import '../widgets/common/shared_widgets.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String slug;

  const CategoryProductsScreen({Key? key, required this.slug}) : super(key: key);

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> with TickerProviderStateMixin {
  // ================ STATE VARIABLES ================
  List<Product> products = [];
  Category? category;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isSearchLoading = false;
  int currentPage = 1;
  bool hasMoreProducts = true;
  Set<int> wishlistItems = {}; // Track wishlist items

  // ================ SEARCH VARIABLES ================
  String searchQuery = '';
  bool showClearSearch = false;
  int totalProductCount = 0;

  // ================ CONTROLLERS ================
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;
  late AnimationController _animationController;

  // Drawer key for cart sidebar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ================ LIFECYCLE METHODS ================

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _loadData();
    _scrollController.addListener(_onScroll);
    // Initialize cart when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartService>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
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
        _applySearch();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
      showClearSearch = false;
    });
    _applySearch();
  }

  void _applySearch() {
    setState(() {
      currentPage = 1;
      hasMoreProducts = true;
    });
    _loadProductsWithSearch();
  }

  void _toggleWishlist(int productId) {
    setState(() {
      if (wishlistItems.contains(productId)) {
        wishlistItems.remove(productId);
        UIUtils.showSnackBar(context, 'Removed from wishlist');
      } else {
        wishlistItems.add(productId);
        UIUtils.showSnackBar(context, 'Added to wishlist');
      }
    });
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
        ApiService.getProducts(
          perPage: 12,
          page: 1,
          category: widget.slug,
        ),
        ApiService.getCategories(),
      ]);

      final productsList = results[0] as List<Product>;
      final categoriesList = results[1] as List<Category>;

      // Find the current category
      Category? currentCategory;
      try {
        currentCategory = categoriesList.firstWhere(
              (cat) => cat.slug == widget.slug,
        );
      } catch (e) {
        // Category not found, create a default one
        currentCategory = Category(
          id: 0,
          name: 'Category Products',
          slug: widget.slug,
          isFeatured: false,
          categoryImage: '',
          subCategories: [],
        );
      }

      setState(() {
        products = productsList;
        category = currentCategory;
        totalProductCount = productsList.length;
        isLoading = false;
        hasMoreProducts = productsList.length >= 12;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      UIUtils.showErrorSnackBar(context, 'Error loading products: $e');
    }
  }

  Future<void> _loadProductsWithSearch() async {
    try {
      setState(() {
        isSearchLoading = true;
      });

      final productsList = await ApiService.getProducts(
        perPage: 12,
        page: 1,
        category: widget.slug,
        search: searchQuery.isNotEmpty ? searchQuery : null,
      );

      setState(() {
        products = productsList;
        currentPage = 1;
        totalProductCount = productsList.length;
        isSearchLoading = false;
        hasMoreProducts = productsList.length >= 12;
      });
    } catch (e) {
      setState(() {
        isSearchLoading = false;
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
        category: widget.slug,
        search: searchQuery.isNotEmpty ? searchQuery : null,
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
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      endDrawer: const CartDrawer(), // Using the provided CartDrawer widget
      body: _buildBody(),
    );
  }

  // ================ APP BAR ================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF2E86AB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF2E86AB),
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        category?.name ?? 'Category Products',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          child: Consumer<CartService>(
            builder: (context, cartService, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E86AB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: Color(0xFF2E86AB),
                        size: 18,
                      ),
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                  if (cartService.totalItems > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cartService.totalItems > 99 ? '99+' : cartService.totalItems.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ================ MAIN BODY ================

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
        // Refresh cart as well
        await Provider.of<CartService>(context, listen: false).refreshCart();
      },
      color: Color(0xFF2E86AB),
      child: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: isLoading
                ? LoadingWidgets.buildLoadingScreen()
                : SingleChildScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductsSection(),
                  if (isLoadingMore) LoadingWidgets.buildLoadingMoreIndicator(),
                  SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================ SEARCH SECTION ================

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search in ${category?.name ?? 'category'}...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Container(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.search, color: Color(0xFF2E86AB), size: 20),
                ),
                suffixIcon: showClearSearch
                    ? IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.clear, color: Colors.grey[600], size: 16),
                  ),
                  onPressed: _clearSearch,
                )
                    : null,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          if (searchQuery.isNotEmpty) ...[
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
                GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E86AB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Clear Search',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E86AB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (products.isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                SizedBox(width: 6),
                Text(
                  '$totalProductCount products available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

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
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Searching products...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
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
        height: 400,
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No products found'
                      : 'No products available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  searchQuery.isNotEmpty
                      ? 'Try different keywords or clear your search'
                      : 'This category doesn\'t have any products yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (searchQuery.isNotEmpty) ...[
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _clearSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E86AB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: Text('Clear Search'),
                  ),
                ],
              ],
            ),
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildProductCard(products[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isWishlisted = wishlistItems.contains(product.id);

    return GestureDetector(
      onTap: () {
        if (product.id != null) {
          Navigator.pushNamed(context, '/product-details', arguments: product.slug.toString())
              .then((_) {
            // Refresh cart when returning from product details
            Provider.of<CartService>(context, listen: false).refreshCart();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product, isWishlisted),
            _buildProductInfo(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product, bool isWishlisted) {
    final hasDiscount = product.salePrice > 0 && product.salePrice < product.unitPrice;
    final discountPercentage = hasDiscount
        ? ((product.unitPrice - product.salePrice) / product.unitPrice * 100).round()
        : 0;

    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
          // Gradient overlay
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          // Wishlist button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _toggleWishlist(product.id ?? 0),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isWishlisted ? Colors.red : Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.white : Colors.grey[600],
                  size: 16,
                ),
              ),
            ),
          ),
          // Discount badge
          if (hasDiscount)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.red[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '-$discountPercentage%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Free delivery badge
          if (product.freeDelivery)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Free Delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  product.brand,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '৳${displayPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E86AB),
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(width: 6),
                      Text(
                        '৳${product.unitPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E86AB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2E86AB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}