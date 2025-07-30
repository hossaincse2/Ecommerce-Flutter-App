import 'package:flutter/material.dart';
class CategoryProductsScreen extends StatelessWidget {
  final String categoryId;

  const CategoryProductsScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category Products')),
      body: Center(child: Text('Products for category $categoryId')),
    );
  }
}