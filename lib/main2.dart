import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(KarbarShopApp());
}

class KarbarShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karbar Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF2E86AB),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

// ================ MODELS ================

class Product {
  final int id;
  final String name;
  final String slug;
  final double unitPrice;
  final double salePrice;
  final int stock;
  final String category;
  final String brand;
  final String previewImage;
  final bool freeDelivery;
  final bool preOrder;
  final String lastMonthSoldItem;
  final double productRating;
  final String totalRating;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.unitPrice,
    required this.salePrice,
    required this.stock,
    required this.category,
    required this.brand,
    required this.previewImage,
    required this.freeDelivery,
    required this.preOrder,
    required this.lastMonthSoldItem,
    required this.productRating,
    required this.totalRating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      previewImage: json['preview_image'] ?? '',
      freeDelivery: json['free_delivery'] ?? false,
      preOrder: json['pre_order'] ?? false,
      lastMonthSoldItem: json['last_month_sold_item'] ?? '',
      productRating: (json['product_rating'] ?? 0).toDouble(),
      totalRating: json['total_rating'] ?? '0',
    );
  }
}

class Category {
  final int id;
  final String name;
  final String slug;
  final bool isFeatured;
  final String categoryImage;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.isFeatured,
    required this.categoryImage,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var subCatList = json['sub_category'] as List? ?? [];
    List<SubCategory> subCategories = subCatList
        .map((subCat) => SubCategory.fromJson(subCat))
        .toList();

    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      isFeatured: json['is_featured'] ?? false,
      categoryImage: json['category_image'] ?? '',
      subCategories: subCategories,
    );
  }
}

class SubCategory {
  final int id;
  final String name;
  final String slug;
  final bool isFeatured;

  SubCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.isFeatured,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      isFeatured: json['is_featured'] ?? false,
    );
  }
}

class HeroImage {
  final int id;
  final String title;
  final String url;
  final String imageUrl;

  HeroImage({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
  });

  factory HeroImage.fromJson(Map<String, dynamic> json) {
    return HeroImage(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

// ================ API SERVICE ================

class ApiService {
  static const String baseUrl = 'https://admin.karbar.shop/api';

  static Future<List<Product>> getProducts({
    String search = '',
    String category = 'all',
    String subCategory = '',
    int page = 1,
    int perPage = 12,
    String sortBy = 'new_arrival',
    String brandId = 'all',
    String businessCategory = 'default',
  }) async {
    try {
      final url = '$baseUrl/en/products?search=$search&category=$category&sub_category=$subCategory&page=$page&perPage=$perPage&sort_by=$sortBy&brand_id=$brandId&business_category=$businessCategory';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsList = data['data'] ?? [];
        return productsList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/en/categories?business_category=default&featured=false&most_sub_cat=true'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesList = data['data'] ?? [];
        return categoriesList.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  static Future<List<HeroImage>> getHeroImages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hero-images'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> imagesList = data['data'] ?? [];
        return imagesList.map((json) => HeroImage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hero images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching hero images: $e');
    }
  }
}

// ================ HOME SCREEN ================

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables
  List<Product> products = [];
  List<Category> categories = [];
  List<HeroImage> heroImages = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMoreProducts = true;

  // Controllers
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

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

  // ================ SCROLL LISTENER ================

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoadingMore && hasMoreProducts) {
        _loadMoreProducts();
      }
    }
  }

  // ================ API CALLS ================

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
      _showErrorSnackBar('Error loading data: $e');
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
      _showErrorSnackBar('Error loading more products: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ================ BUILD METHODS ================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingScreen() : _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        'Karbar Shop',
        style: TextStyle(
          color: Color(0xFF2E86AB),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Color(0xFF2E86AB)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Search feature coming soon!')),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: Color(0xFF2E86AB)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cart feature coming soon!')),
            );
          },
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading amazing products...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
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
            if (isLoadingMore) _buildLoadingMoreIndicator(),
            SizedBox(height: 80),
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
                    heroImages[index].imageUrl,
                    fit: BoxFit.cover,
                    headers: {
                      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                      'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                            SizedBox(height: 8),
                            Text(
                              'Banner image unavailable',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
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
          ),
        ],
      ),
    );
  }

  // ================ CATEGORIES SECTION ================

  Widget _buildCategoriesSection() {
    if (categories.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Shop by Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
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
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped on ${category.name} category')),
        );
      },
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
            Container(
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
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.category,
                        color: Color(0xFF2E86AB),
                        size: 25,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
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
            ),
          ],
        ),
      ),
    );
  }

  // ================ PRODUCTS SECTION ================

  Widget _buildFeaturedProductsSection() {
    if (products.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (hasMoreProducts)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('View All Products - Coming Soon!')),
                    );
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF2E86AB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
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
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final hasDiscount = product.salePrice > 0 && product.salePrice < product.unitPrice;
    final displayPrice = hasDiscount ? product.salePrice : product.unitPrice;
    final discountPercentage = hasDiscount
        ? ((product.unitPrice - product.salePrice) / product.unitPrice * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped on ${product.name}')),
        );
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
            Expanded(
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 24,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-$discountPercentage%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (product.freeDelivery)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FREE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
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
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E86AB)),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading more products...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================ BOTTOM NAVIGATION ================

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2E86AB),
      unselectedItemColor: Colors.grey[400],
      currentIndex: 0,
      onTap: (index) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation item $index tapped')),
        );
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}