// screens/example_categories_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';
import '../constants/app_constants.dart';
import '../utils/network_utils.dart';
import '../widgets/common/bottom_nav_widget.dart';
import '../widgets/common/loading_widgets.dart';
import '../widgets/common/shared_widgets.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        isLoading = true;
      });

      final categoriesList = await ApiService.getCategories();

      setState(() {
        categories = categoriesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      UIUtils.showErrorSnackBar(context, '${AppConstants.dataLoadError}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: SharedWidgets.buildAppBar(
        title: AppConstants.categoriesLabel,
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppConstants.primaryColor),
            onPressed: () => UIUtils.onSearchTap(context),
          ),
          SizedBox(width: AppConstants.smallPadding),
        ],
      ),
      body: isLoading 
          ? LoadingWidgets.buildLoadingScreen(
              message: 'Loading categories...',
            )
          : _buildBody(),
      bottomNavigationBar: BottomNavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildBody() {
    if (categories.isEmpty) {
      return SharedWidgets.buildEmptyState(
        message: 'No categories found',
        icon: Icons.category_outlined,
        actionText: 'Refresh',
        onActionPressed: _loadCategories,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: AppConstants.primaryColor,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppConstants.defaultPadding),
            SharedWidgets.buildSectionHeader('All Categories'),
            SizedBox(height: AppConstants.defaultPadding),
            _buildCategoriesGrid(),
            SizedBox(height: 80), // Bottom navigation padding
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppConstants.categoryGridCrossAxisCount,
          childAspectRatio: AppConstants.categoryGridAspectRatio,
          crossAxisSpacing: AppConstants.categoryGridCrossAxisSpacing,
          mainAxisSpacing: AppConstants.categoryGridMainAxisSpacing,
        ),
        itemCount: categories.length,
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
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          boxShadow: AppConstants.categoryShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NetworkUtils.buildCategoryImage(
              imageUrl: category.categoryImage,
              loadingBuilder: LoadingWidgets.buildCategoryImageLoadingBuilder,
              errorBuilder: SharedWidgets.buildCategoryImageErrorBuilder,
            ),
            SizedBox(height: AppConstants.smallPadding),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: AppConstants.categoryNameStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================ EXAMPLE USAGE DOCUMENTATION ================

/*
HOW TO USE THESE UTILITIES IN YOUR SCREENS:

1. UI UTILITIES (utils/ui_utils.dart):
   - UIUtils.showErrorSnackBar(context, 'Error message');
   - UIUtils.showSuccessSnackBar(context, 'Success message');
   - UIUtils.onProductTap(context, product.name);
   - UIUtils.onCategoryTap(context, category.name);

2. SHARED WIDGETS (widgets/common/shared_widgets.dart):
   - SharedWidgets.buildSectionHeader('Title');
   - SharedWidgets.buildAppBar(title: 'Screen Title');
   - SharedWidgets.buildEmptyState(message: 'No data found');
   - SharedWidgets.buildDiscountBadge(15);

3. LOADING WIDGETS (widgets/common/loading_widgets.dart):
   - LoadingWidgets.buildLoadingScreen();
   - LoadingWidgets.buildLoadingMoreIndicator();
   - LoadingWidgets.buildSmallLoadingIndicator();

4. BOTTOM NAVIGATION (widgets/common/bottom_navigation_widget.dart):
   - BottomNavigationWidget(currentIndex: 0);
   - BottomNavigationWidget(currentIndex: 1, onTap: customHandler);

5. CONSTANTS (utils/app_constants.dart):
   - AppConstants.primaryColor
   - AppConstants.defaultPadding
   - AppConstants.cardShadow
   - AppConstants.networkHeaders

6. NETWORK UTILS (utils/network_utils.dart):
   - NetworkUtils.buildProductImage(imageUrl: url, ...);
   - NetworkUtils.buildCategoryImage(imageUrl: url, ...);
   - NetworkUtils.buildHeroImage(imageUrl: url, ...);

FOLDER STRUCTURE:
lib/
├── utils/
│   ├── ui_utils.dart
│   ├── app_constants.dart
│   └── network_utils.dart
├── widgets/
│   └── common/
│       ├── bottom_navigation_widget.dart
│       ├── loading_widgets.dart
│       └── shared_widgets.dart
├── screens/
│   ├── home_screen.dart
│   └── categories_screen.dart
├── models/
├── services/
└── main.dart

BENEFITS:
✅ Reusable components across all screens
✅ Consistent UI/UX throughout the app
✅ Easy maintenance and updates
✅ Centralized styling and constants
✅ Clean and organized code structure
✅ Easy to customize and extend
*/