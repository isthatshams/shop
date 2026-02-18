import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/core/theme/theme_cubit.dart';
import 'package:shop_mobile/features/products/data/models/product_model.dart';
import 'package:shop_mobile/features/products/data/repositories/product_repository.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final ProductRepository _repository = ProductRepository();
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final categories = await _repository.getCategories();
    if (!mounted) return;

    setState(() {
      _categories = categories;
      _isLoading = false;
      if (categories.isEmpty) {
        _error = 'No categories found';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : CustomScrollView(
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categories',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 24.sp),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Browse by category',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Categories Grid
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14.h,
                            crossAxisSpacing: 14.w,
                            childAspectRatio: 1.1,
                          ),
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final category = _categories[index];
                            final color = _colorFromHex(category.color) ??
                                AppTheme.primaryColor;

                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkSurface
                                    : AppTheme.lightSurface,
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(8),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context.push(
                                    '/items?category=${Uri.encodeComponent(category.name)}&category_id=${category.id}',
                                  ),
                                  borderRadius: BorderRadius.circular(18.r),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.w),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 50.w,
                                          height: 50.w,
                                          decoration: BoxDecoration(
                                            color: color.withAlpha(30),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.category,
                                            color: color,
                                            size: 24.sp,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          category.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontSize: 13.sp),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          '${category.productsCount} items',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(fontSize: 11.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }, childCount: _categories.length),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                    ],
                  ),
      ),
    );
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceAll('#', '');
    if (normalized.length != 6) return null;
    return Color(int.parse('FF$normalized', radix: 16));
  }
}
