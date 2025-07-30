import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_details.dart'; // Add this import
import '../services/api_service.dart'; // Add this import

class ProductDetailsScreen extends StatefulWidget {
  final String slug;

  const ProductDetailsScreen({Key? key, required this.slug}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductDetails? productData; // Changed type to ProductDetails
  bool isLoading = true;
  String? errorMessage;
  int currentImageIndex = 0;
  final TextEditingController _reviewController = TextEditingController();
  double userRating = 5.0;
  String currentSlug = '';

  @override
  void initState() {
    super.initState();
    currentSlug = widget.slug;
    // Use post frame callback to ensure widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProductDetails();
    });
  }

  @override
  void didUpdateWidget(ProductDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      currentSlug = widget.slug;
      fetchProductDetails();
    }
  }

  Future<void> fetchProductDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get slug from arguments if available, otherwise use widget slug
      String slug = currentSlug;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String && args.isNotEmpty) {
        slug = args;
      } else if (args != null && args is int) {
        slug = args.toString();
      }

      print('Fetching product with slug: $slug');

      // Use the new API service method
      final productDetails = await ApiService.getProductDetails(slug);

      if (mounted) {
        setState(() {
          productData = productDetails;
          currentSlug = slug;
          isLoading = false;
        });
      }

    } catch (e) {
      print('Error fetching product: $e');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      _showSnackBar('Please write a review');
      return;
    }

    if (productData == null) {
      _showSnackBar('Product not loaded');
      return;
    }

    try {
      await ApiService.submitProductReview(
        productId: productData!.id,
        rating: userRating.toInt(),
        review: _reviewController.text.trim(),
      );

      _reviewController.clear();
      setState(() {
        userRating = 5.0;
      });
      _showSnackBar('Review submitted successfully!');

      // Optionally refresh product details to show new review
      fetchProductDetails();

    } catch (e) {
      _showSnackBar('Error submitting review: ${ApiService.getErrorMessage(e)}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void shareProduct(String platform) {
    if (productData == null) return;

    final url = 'https://demo.karbar.shop/products/${currentSlug}';
    final title = productData!.name;

    switch (platform) {
      case 'whatsapp':
        final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent('Check out this amazing product: $title\n$url')}';
        launchUrl(Uri.parse(whatsappUrl));
        break;
      case 'facebook':
        final facebookUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
        launchUrl(Uri.parse(facebookUrl));
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: url));
        _showSnackBar('Link copied to clipboard!');
        break;
    }
  }

  void _navigateToRelatedProduct(String slug) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(slug: slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Product...'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading product: $currentSlug'),
              const SizedBox(height: 8),
              const Text('Please wait...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (productData == null || errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Not Found'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Product not found', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Slug: $currentSlug', style: const TextStyle(color: Colors.grey)),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchProductDetails,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          productData!.name,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            _buildImageCarousel(),

            // Product Info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    productData!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // SKU and Category
                  Row(
                    children: [
                      Text(
                        'SKU: ${productData!.skuCode}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          productData!.category,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    children: [
                      Text(
                        '৳${productData!.unitPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: productData!.salePrice > 0 ? Colors.grey : Colors.green[700],
                          decoration: productData!.salePrice > 0 ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (productData!.salePrice > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '৳${productData!.salePrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${((productData!.unitPrice - productData!.salePrice) / productData!.unitPrice * 100).round()}% OFF',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock Status
                  Row(
                    children: [
                      Icon(
                        productData!.stock > 0 ? Icons.check_circle : Icons.cancel,
                        color: productData!.stock > 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        productData!.stock > 0 ? 'In Stock (${productData!.stock} available)' : 'Out of Stock',
                        style: TextStyle(
                          color: productData!.stock > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Description (if available)
                  if (productData!.description != null && productData!.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      productData!.description!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],

                  // Summary (if available)
                  if (productData!.summary != null && productData!.summary!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      productData!.summary!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Attributes Section
            _buildAttributesSection(),

            const SizedBox(height: 8),

            // Share Section
            _buildShareSection(),

            const SizedBox(height: 8),

            // Reviews Section
            _buildReviewsSection(),

            const SizedBox(height: 8),

            // Related Products
            _buildRelatedProducts(),

            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImageCarousel() {
    final images = productData!.productImages;

    if (images.isEmpty) {
      return Container(
        height: 400,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('No images available', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 400,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  currentImageIndex = index;
                });
              },
            ),
            items: images.map((image) {
              return Container(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: image.originalUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 400,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('Image loading error: $error for URL: $url');
                    return Container(
                      height: 400,
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text('Image not available', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {}); // Retry loading
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  },
                  memCacheWidth: 800,
                  memCacheHeight: 800,
                ),
              );
            }).toList(),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentImageIndex == entry.key
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttributesSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Attributes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAttributeRow('Category', productData!.category),
          _buildAttributeRow('SKU Code', productData!.skuCode),
          _buildAttributeRow('Stock', '${productData!.stock} ${productData!.productUnit}s'),
          _buildAttributeRow('Currency', productData!.currency.toUpperCase()),
          if (productData!.freeDelivery)
            _buildAttributeRow('Delivery', 'Free Delivery Available'),
          if (productData!.preOrder)
            _buildAttributeRow('Order Type', 'Pre-order Available'),
          if (productData!.videoLink != null && productData!.videoLink!.isNotEmpty)
            _buildAttributeRow('Video', 'Product video available'),
        ],
      ),
    );
  }

  Widget _buildAttributeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share This Product',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareButton(
                'WhatsApp',
                Icons.message,
                Colors.green,
                    () => shareProduct('whatsapp'),
              ),
              _buildShareButton(
                'Facebook',
                Icons.facebook,
                Colors.blue,
                    () => shareProduct('facebook'),
              ),
              _buildShareButton(
                'Copy Link',
                Icons.link,
                Colors.grey[700]!,
                    () => shareProduct('copy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (productData!.totalRatings > 0) ...[
                Icon(Icons.star, color: Colors.amber[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  '${productData!.averageRating.toStringAsFixed(1)} (${productData!.totalRatings})',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Rating Distribution
          if (productData!.totalRatings > 0) ...[
            _buildRatingBar(5, productData!.totalFiveStars, productData!.totalRatings),
            _buildRatingBar(4, productData!.totalFourStars, productData!.totalRatings),
            _buildRatingBar(3, productData!.totalThreeStars, productData!.totalRatings),
            _buildRatingBar(2, productData!.totalTwoStars, productData!.totalRatings),
            _buildRatingBar(1, productData!.totalOneStars, productData!.totalRatings),
            const SizedBox(height: 20),
          ],

          // Display existing reviews
          if (productData!.reviews.isNotEmpty) ...[
            const Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productData!.reviews.length,
              itemBuilder: (context, index) {
                final review = productData!.reviews[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < review.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber[600],
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.review,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],

          // Write Review
          const Text(
            'Write a Review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Rating Input
          Row(
            children: [
              const Text('Your Rating: '),
              RatingBar.builder(
                initialRating: userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 25,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber[600],
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    userRating = rating;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Review Text Input
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your review here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$stars'),
          const SizedBox(width: 8),
          Icon(Icons.star, color: Colors.amber[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count'),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    final relatedProducts = productData!.relatedProducts;

    if (relatedProducts.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Related Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedProducts.length,
              itemBuilder: (context, index) {
                final product = relatedProducts[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: CachedNetworkImage(
                            imageUrl: product.previewImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 120,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return Container(
                                height: 120,
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, color: Colors.grey),
                                    Text('No Image', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              );
                            },
                            memCacheWidth: 300,
                            memCacheHeight: 300,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '৳${product.unitPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: product.salePrice > 0 ? Colors.grey : Colors.green[700],
                                    decoration: product.salePrice > 0 ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                if (product.salePrice > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '৳${product.salePrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _navigateToRelatedProduct(product.slug),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'View Details',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: productData!.stock > 0 ? () {
                // Add to cart functionality
                _showSnackBar('Added to cart!');
              } : null,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: productData!.stock > 0 ? () {
                // Buy now functionality
                _showSnackBar('Proceeding to checkout!');
              } : null,
              icon: const Icon(Icons.flash_on),
              label: const Text('Buy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Product',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareButton(
                    'WhatsApp',
                    Icons.message,
                    Colors.green,
                        () {
                      Navigator.pop(context);
                      shareProduct('whatsapp');
                    },
                  ),
                  _buildShareButton(
                    'Facebook',
                    Icons.facebook,
                    Colors.blue,
                        () {
                      Navigator.pop(context);
                      shareProduct('facebook');
                    },
                  ),
                  _buildShareButton(
                    'Copy Link',
                    Icons.link,
                    Colors.grey[700]!,
                        () {
                      Navigator.pop(context);
                      shareProduct('copy');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}