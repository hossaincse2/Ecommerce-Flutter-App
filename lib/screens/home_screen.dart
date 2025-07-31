import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/hero_image.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/common/loading_widgets.dart';
import '../widgets/common/shared_widgets.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ================ STATE VARIABLES ================
  List<Product> products = [];
  List<Category> categories = [];
  List<HeroImage> heroImages = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMoreProducts = true;

  // Cart state
  List<CartItem> cartItems = [];
  int cartItemCount = 0;
  double cartTotal = 0.0;

  // ================ CONTROLLERS ================
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  ScrollController _categoryScrollController = ScrollController();
  AnimationController? _categoryAnimationController;
  Animation<double>? _categorySlideAnimation;
  int _currentIndex = 0;

  // Drawer key for cart sidebar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ================ LIFECYCLE METHODS ================

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
    _initializeAnimations();
    _loadCartData();
  }

  void _initializeAnimations() {
    _categoryAnimationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );

    _categorySlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _categoryAnimationController!,
      curve: Curves.linear,
    ));

    // Start auto-scroll for categories
    _categoryAnimationController!.addListener(() {
      if (_categoryScrollController.hasClients && categories.isNotEmpty) {
        final maxScroll = _categoryScrollController.position.maxScrollExtent;
        final currentScroll = maxScroll * _categorySlideAnimation!.value;
        _categoryScrollController.jumpTo(currentScroll);
      }
    });

    _categoryAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _categoryAnimationController!.reset();
            _categoryAnimationController!.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _categoryScrollController.dispose();
    _categoryAnimationController?.dispose();
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

  // ================ CART METHODS ================

  void _loadCartData() {
    // Simulate loading cart data - replace with actual cart service
    setState(() {
      cartItems = [
        CartItem(
          product: Product(
            id: 1,
            name: "Sample Product 1",
            slug: "sample-product-1",
            unitPrice: 150.0,
            salePrice: 120.0,
            stock: 50,
            category: "Electronics",
            brand: "Brand A",
            previewImage: "https://via.placeholder.com/150",
            freeDelivery: true,
            preOrder: false,
            lastMonthSoldItem: '25',
            productRating: 4.5,
            totalRating: '120',
          ),
          quantity: 2,
        ),
        CartItem(
          product: Product(
            id: 2,
            name: "Sample Product 2",
            slug: "sample-product-2",
            unitPrice: 200.0,
            salePrice: 0.0,
            stock: 30,
            category: "Fashion",
            brand: "Brand B",
            previewImage: "https://via.placeholder.com/150",
            freeDelivery: false,
            preOrder: true,
            lastMonthSoldItem: '15',
            productRating: 4.2,
            totalRating: '85',
          ),
          quantity: 1,
        ),
      ];
      _updateCartSummary();
    });
  }

  void _updateCartSummary() {
    cartItemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
    cartTotal = cartItems.fold(0.0, (sum, item) {
      final price = item.product.salePrice > 0 ? item.product.salePrice : item.product.unitPrice;
      return sum + (price * item.quantity);
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
      _updateCartSummary();
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    setState(() {
      cartItems[index].quantity = newQuantity;
      _updateCartSummary();
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
        ApiService.getProducts(perPage: 12, page: 1),
        ApiService.getCategories(),
        ApiService.getHeroImages(),
      ]);

      final productsList = results[0] as List<Product>;
      final categoriesList = results[1] as List<Category>;
      final heroImagesList = results[2] as List<HeroImage>;

      setState(() {
        products = productsList;
        categories = categoriesList;
        heroImages = heroImagesList;
        isLoading = false;
        hasMoreProducts = productsList.length >= 12;
      });

      // Start category animation after data loads
      if (categories.isNotEmpty) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            _categoryAnimationController!.forward();
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      UIUtils.showErrorSnackBar(context, 'Error loading data: $e');
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
      );

      setState(() {
        if (newProducts.isNotEmpty) {
          products.addAll(newProducts);
          currentPage++;
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
      endDrawer: _buildCartDrawer(),
      body: isLoading
          ? LoadingWidgets.buildLoadingScreen()
          : _buildBody(),
    );
  }

  // ================ ENHANCED APP BAR ================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E86AB),
              Color(0xFF47A3C7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2E86AB).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.storefront,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Karbar Shop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Your trusted marketplace',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Search Icon
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: () => UIUtils.onSearchTap(context),
          ),
        ),
        // Cart Icon with Badge
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              if (cartItemCount > 0)
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
                      cartItemCount > 99 ? '99+' : cartItemCount.toString(),
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
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  // ================ CART DRAWER ================

  Widget _buildCartDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildCartHeader(),
            Expanded(
              child: cartItems.isEmpty ? _buildEmptyCart() : _buildCartItems(),
            ),
            if (cartItems.isNotEmpty) _buildCartFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E86AB), Color(0xFF47A3C7)],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_cart, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shopping Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${cartItemCount} items',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E86AB),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        final product = cartItem.product;
        final price = product.salePrice > 0 ? product.salePrice : product.unitPrice;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.previewImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        product.brand,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '৳${price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Color(0xFF2E86AB),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (product.salePrice > 0)
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                '৳${product.unitPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _updateQuantity(index, cartItem.quantity - 1),
                          icon: Icon(Icons.remove_circle_outline),
                          color: Color(0xFF2E86AB),
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.all(4),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            cartItem.quantity.toString(),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _updateQuantity(index, cartItem.quantity + 1),
                          icon: Icon(Icons.add_circle_outline),
                          color: Color(0xFF2E86AB),
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.all(4),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _removeFromCart(index),
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartFooter() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${cartItemCount} items):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '৳${cartTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E86AB),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to checkout
                Navigator.pushNamed(context, '/checkout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E86AB),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================ MAIN BODY ================

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Color(0xFF2E86AB),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            SizedBox(height: 20),
            _buildCategoriesSection(),
            SizedBox(height: 20),
            _buildFeaturedProductsSection(),
            if (isLoadingMore) LoadingWidgets.buildLoadingMoreIndicator(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ================ HERO BANNER SECTION ================

  Widget _buildHeroSection() {
    if (heroImages.isEmpty) return SizedBox.shrink();

    return Container(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: heroImages.length,
            itemBuilder: (context, index) {
              return _buildHeroBanner(heroImages[index]);
            },
          ),
          _buildHeroIndicators(),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(HeroImage heroImage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          heroImage.imageUrl,
          fit: BoxFit.cover,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          },
          loadingBuilder: LoadingWidgets.buildImageLoadingBuilder,
          errorBuilder: SharedWidgets.buildHeroImageErrorBuilder,
        ),
      ),
    );
  }

  Widget _buildHeroIndicators() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: heroImages.asMap().entries.map((entry) {
          return Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == entry.key
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================ ENHANCED CATEGORIES SECTION ================

  Widget _buildCategoriesSection() {
    if (categories.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SharedWidgets.buildSectionHeader('Shop by Categories'),
        SizedBox(height: 12),
        _buildCategoriesSlider(),
      ],
    );
  }

  Widget _buildCategoriesSlider() {
    return Container(
      height: 120,
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 90,
            margin: EdgeInsets.only(right: 12),
            child: _buildCategoryCard(category),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () => UIUtils.onCategoryTap(context, category.name),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryImage(category),
            SizedBox(height: 8),
            _buildCategoryName(category),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryImage(Category category) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.network(
          category.categoryImage,
          fit: BoxFit.cover,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
          loadingBuilder: LoadingWidgets.buildCategoryImageLoadingBuilder,
          errorBuilder: SharedWidgets.buildCategoryImageErrorBuilder,
        ),
      ),
    );
  }

  Widget _buildCategoryName(Category category) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        category.name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ================ PRODUCTS SECTION ================

  Widget _buildFeaturedProductsSection() {
    if (products.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SharedWidgets.buildSectionHeaderWithAction(
          'Featured Products',
          'View All',
              () => Navigator.pushNamed(context, '/shop'),
        ),
        SizedBox(height: 12),
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
                  'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
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

// ================ CART ITEM MODEL ================
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}