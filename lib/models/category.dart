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