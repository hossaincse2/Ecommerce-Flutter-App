import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.salePrice != null &&
        product.salePrice! > 0 &&
        product.salePrice! < product.unitPrice;
    final discountPercentage = hasDiscount
        ? ((product.unitPrice - product.salePrice!) / product.unitPrice * 100).round()
        : 0;
    final displayPrice = hasDiscount ? product.salePrice! : product.unitPrice;

    return GestureDetector(
      onTap: () {
        // Add null check for product slug
        if (product.slug != null && product.slug!.isNotEmpty) {
          Navigator.pushNamed(context, '/product-details', arguments: product.slug);
        } else {
          // Fallback to product ID if slug is not available
          Navigator.pushNamed(context, '/product-details', arguments: product.id.toString());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: _buildProductImage(),
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
                            colors: [Colors.red[600]!, Colors.red[400]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$discountPercentage% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Expanded(
                      flex: 2,
                      child: Text(
                        product.name ?? 'Product Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 4),

                    // Price section
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          // Current price
                          Text(
                            '৳${displayPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),

                          if (hasDiscount) ...[
                            SizedBox(width: 6),
                            Text(
                              '৳${product.unitPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
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

  Widget _buildProductImage() {
    // Handle different image URL formats
    String? imageUrl = product.previewImage;

    // Check if the image URL needs base URL prefix
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl = 'https://admin.karbar.shop$imageUrl';
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'image/webp,image/apng,image/jpeg,image/png,image/*,*/*;q=0.8',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: double.infinity,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported,
              color: Colors.grey[400], size: 32),
          SizedBox(height: 4),
          Text('No Image',
              style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        ],
      ),
    );
  }
}