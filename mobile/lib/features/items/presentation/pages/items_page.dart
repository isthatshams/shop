import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/core/theme/theme_cubit.dart';
import 'package:shop_mobile/features/products/data/models/product_model.dart';
import 'package:shop_mobile/features/products/data/repositories/product_repository.dart';

class ItemsPage extends StatefulWidget {
  final String? categoryName;
  final int? categoryId;

  const ItemsPage({super.key, this.categoryName, this.categoryId});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final ProductRepository _repository = ProductRepository();

  String _sortBy = 'Popular';
  String _sortField = 'created_at';
  String _sortOrder = 'desc';

  final List<String> _sortOptions = [
    'Popular',
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
    'Rating',
  ];

  final List<Product> _products = [];
  int _page = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _products.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    setState(() {
      _error = null;
      _isLoading = _page == 1;
      _isLoadingMore = _page > 1;
    });

    final result = await _repository.getProducts(
      page: _page,
      perPage: 20,
      categoryId: widget.categoryId,
      sortBy: _sortField,
      sortOrder: _sortOrder,
    );

    if (!mounted) return;

    setState(() {
      _products.addAll(result.products);
      _hasMore = result.hasMore;
      _isLoading = false;
      _isLoadingMore = false;
      _page += 1;
      if (result.products.isEmpty && _products.isEmpty) {
        _error = 'No products found';
      }
    });
  }

  void _applySort(String sortOption) {
    switch (sortOption) {
      case 'Newest':
        _sortField = 'created_at';
        _sortOrder = 'desc';
        break;
      case 'Price: Low to High':
        _sortField = 'price';
        _sortOrder = 'asc';
        break;
      case 'Price: High to Low':
        _sortField = 'price';
        _sortOrder = 'desc';
        break;
      case 'Rating':
        _sortField = 'rating';
        _sortOrder = 'desc';
        break;
      default:
        _sortField = 'created_at';
        _sortOrder = 'desc';
    }

    setState(() {
      _sortBy = sortOption;
    });
    _loadProducts(refresh: true);
  }

  void _showSortBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            ..._sortOptions.map((option) {
              return ListTile(
                title: Text(option),
                trailing: _sortBy == option
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _applySort(option);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurface
                            : AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 18.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      widget.categoryName ?? 'All Products',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 20.sp),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurface
                            : AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.search, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),

            // Filter & Sort Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightCard,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  ),
                  bottom: BorderSide(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_products.length} items',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showSortBottomSheet(context, isDark),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          size: 18.sp,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _sortBy,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Products Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : GridView.builder(
                          padding: EdgeInsets.all(16.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.h,
                            crossAxisSpacing: 16.w,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: _products.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _products.length) {
                              if (!_isLoadingMore) {
                                _loadProducts();
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final product = _products[index];
                            return GestureDetector(
                              onTap: () => context.push('/product/${product.id}'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.darkSurface
                                      : AppTheme.lightCard,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(6),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16.r),
                                      ),
                                      child: Image.network(
                                        product.primaryImage,
                                        height: 150.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          SizedBox(height: 6.h),
                                          Row(
                                            children: [
                                              Text(
                                                '\$${product.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              if (product.hasDiscount) ...[
                                                SizedBox(width: 6.w),
                                                Text(
                                                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12.sp,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                product.rating
                                                    .toStringAsFixed(1),
                                                style: TextStyle(fontSize: 12.sp),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
