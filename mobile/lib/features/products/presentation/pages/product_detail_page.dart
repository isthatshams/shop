import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/features/products/data/models/product_model.dart';
import 'package:shop_mobile/features/products/data/repositories/product_repository.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductRepository _repository = ProductRepository();
  Product? _product;
  bool _isLoading = true;
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await _repository.getProduct(widget.productId);
    if (mounted) {
      setState(() {
        _product = product;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text('Product not found', style: TextStyle(fontSize: 18.sp)),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 350.h,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.arrow_back_ios_new),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(Icons.favorite_border),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _buildImageGallery()),
          ),

          // Product details
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -20.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Rating row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_product!.categoryName != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                _product!.categoryName!,
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _product!.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              Text(
                                ' (${_product!.reviewsCount})',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Product name
                      Text(
                        _product!.name,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Price section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${_product!.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          if (_product!.hasDiscount) ...[
                            SizedBox(width: 12.w),
                            Text(
                              '\$${_product!.originalPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '-${_product!.discountPercent.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Stock status
                      Row(
                        children: [
                          Icon(
                            _product!.isInStock
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _product!.isInStock
                                ? Colors.green
                                : Colors.red,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _product!.isInStock
                                ? 'In Stock (${_product!.stock} available)'
                                : 'Out of Stock',
                            style: TextStyle(
                              color: _product!.isInStock
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Description
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _product!.description ?? 'No description available.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          height: 1.6,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Quantity selector
                      Row(
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _quantity > 1
                                      ? () => setState(() => _quantity--)
                                      : null,
                                  icon: const Icon(Icons.remove),
                                ),
                                SizedBox(
                                  width: 40.w,
                                  child: Text(
                                    '$_quantity',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _quantity < _product!.stock
                                      ? () => setState(() => _quantity++)
                                      : null,
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 100.h), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom bar with Add to Cart button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Total price
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                    Text(
                      '\$${(_product!.price * _quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Add to cart button
              Expanded(
                child: SizedBox(
                  height: 56.h,
                  child: ElevatedButton.icon(
                    onPressed: _product!.isInStock
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added $_quantity ${_product!.name} to cart',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = _product!.images.isNotEmpty
        ? _product!.images
        : ['https://via.placeholder.com/400'];

    return Stack(
      children: [
        // Main image
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() => _selectedImageIndex = index);
          },
          itemBuilder: (context, index) {
            return Container(
              color: Colors.grey[200],
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64.sp,
                    color: Colors.grey,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        ),

        // Image indicators
        if (images.length > 1)
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _selectedImageIndex == index ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _selectedImageIndex == index
                        ? AppTheme.primaryColor
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
