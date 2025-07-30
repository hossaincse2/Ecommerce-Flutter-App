import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/hero_image.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';
// import '../widgets/common/bottom_nav_widget.dart';
import '../widgets/common/loading_widgets.dart';
import '../widgets/common/shared_widgets.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ================ STATE VARIABLES ================
  List<Product> products = [];
  List<Category> categories = [];
  List<HeroImage> heroImages = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMoreProducts = true;

  // ================ CONTROLLERS ================
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
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
    _scrollController.dispose();
    _pageController.dispose();
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
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: isLoading
          ? LoadingWidgets.buildLoadingScreen()
          : _buildBody(),
      // bottomNavigationBar: BottomNavigationWidget(currentIndex: 0),
    );
  }

  // ================ APP BAR ================

  PreferredSizeWidget _buildAppBar() {
    return SharedWidgets.buildAppBar(
      title: 'Karbar Shop',
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Color(0xFF2E86AB)),
          onPressed: () => UIUtils.onSearchTap(context),
        ),
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
            SizedBox(height: 80), // Bottom padding for navigation bar
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

  // ================ CATEGORIES SECTION ================

  Widget _buildCategoriesSection() {
    if (categories.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SharedWidgets.buildSectionHeader('Shop by Categories'),
        SizedBox(height: 12),
        _buildCategoriesGrid(),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return Container(
      height: 280,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        physics: AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length > 9 ? 9 : categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category);
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
              () => UIUtils.onViewAllProductsTap(context),
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
        childAspectRatio: 0.7,
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
      onTap: () => UIUtils.onProductTap(context, product.name),
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
          children: [
            Text(
              product.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
            Spacer(),
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