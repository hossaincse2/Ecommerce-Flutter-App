import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';
import '../utils/network_utils.dart';
import '../constants/app_constants.dart';
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
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
              (route) => false,
        ),
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
      // bottomNavigationBar: BottomNavigationWidget(currentIndex: 1),
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