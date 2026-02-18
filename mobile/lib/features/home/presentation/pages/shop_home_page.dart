import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/core/theme/theme_cubit.dart';
import 'package:shop_mobile/features/notifications/data/repositories/notification_repository.dart';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  final PageController _sliderController = PageController();
  int _currentSlide = 0;
  Timer? _autoScrollTimer;
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  int _unreadCount = 0;

  // Sample data - replace with real data from API
  final List<Map<String, dynamic>> _banners = [
    {
      'image': 'https://picsum.photos/800/400?random=1',
      'title': 'Summer Sale',
      'subtitle': 'Up to 50% Off',
    },
    {
      'image': 'https://picsum.photos/800/400?random=2',
      'title': 'New Arrivals',
      'subtitle': 'Check out the latest',
    },
    {
      'image': 'https://picsum.photos/800/400?random=3',
      'title': 'Free Shipping',
      'subtitle': 'On orders over \$50',
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.phone_iphone,
      'name': 'Electronics',
      'color': const Color(0xFF6366F1),
    },
    {
      'icon': Icons.checkroom,
      'name': 'Fashion',
      'color': const Color(0xFFEC4899),
    },
    {'icon': Icons.home, 'name': 'Home', 'color': const Color(0xFF10B981)},
    {
      'icon': Icons.sports_basketball,
      'name': 'Sports',
      'color': const Color(0xFFF59E0B),
    },
    {'icon': Icons.book, 'name': 'Books', 'color': const Color(0xFF8B5CF6)},
    {'icon': Icons.toys, 'name': 'Toys', 'color': const Color(0xFFEF4444)},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'image': 'https://picsum.photos/200/200?random=10',
      'name': 'Wireless Headphones',
      'price': 99.99,
      'rating': 4.5,
    },
    {
      'image': 'https://picsum.photos/200/200?random=11',
      'name': 'Smart Watch',
      'price': 199.99,
      'rating': 4.8,
    },
    {
      'image': 'https://picsum.photos/200/200?random=12',
      'name': 'Running Shoes',
      'price': 129.99,
      'rating': 4.3,
    },
    {
      'image': 'https://picsum.photos/200/200?random=13',
      'name': 'Backpack',
      'price': 79.99,
      'rating': 4.6,
    },
    {
      'image': 'https://picsum.photos/200/200?random=14',
      'name': 'Sunglasses',
      'price': 59.99,
      'rating': 4.2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadNotificationCount();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _sliderController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_sliderController.hasClients) {
        final nextPage = (_currentSlide + 1) % _banners.length;
        _sliderController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadNotificationCount() async {
    final result = await _notificationRepository.getNotifications();
    if (!mounted) return;
    setState(() => _unreadCount = result.unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            await _loadNotificationCount();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back! 👋',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Find your style',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontSize: 22.sp),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSurface
                                : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: _unreadCount > 0
                              ? Badge(
                                  label: Text('$_unreadCount'),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: isDark
                                        ? AppTheme.darkTextPrimary
                                        : AppTheme.lightTextPrimary,
                                  ),
                                )
                              : Icon(
                                  Icons.notifications_outlined,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.lightTextPrimary,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Search products...',
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),

              // Hero Slider
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160.h,
                  child: PageView.builder(
                    controller: _sliderController,
                    onPageChanged: (index) {
                      setState(() => _currentSlide = index);
                    },
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            image: DecorationImage(
                              image: NetworkImage(banner['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withAlpha(180),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner['title'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  banner['subtitle'],
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 13.sp,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    'Shop Now',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Slider Indicators
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _banners.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 6.h,
                        width: _currentSlide == index ? 20.w : 6.w,
                        decoration: BoxDecoration(
                          color: _currentSlide == index
                              ? AppTheme.primaryColor
                              : (isDark
                                    ? AppTheme.darkCard
                                    : AppTheme.lightCard),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),

              // Categories Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories List
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 90.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Column(
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                color: (category['color'] as Color).withAlpha(
                                  30,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                category['icon'] as IconData,
                                color: category['color'] as Color,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              category['name'] as String,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 11.sp),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 16.h)),

              // New Arrivals Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Arrivals',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Products Grid
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Container(
                          width: 150.w,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSurface
                                : AppTheme.lightSurface,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20.r),
                                    ),
                                    child: Image.network(
                                      product['image'] as String,
                                      height: 120.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 120.h,
                                        color: isDark
                                            ? AppTheme.darkCard
                                            : AppTheme.lightCard,
                                        child: Icon(Icons.image, size: 36.sp),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8.h,
                                    right: 8.w,
                                    child: Container(
                                      padding: EdgeInsets.all(5.w),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.darkSurface
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.favorite_border,
                                        size: 16.sp,
                                        color: AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Product Details
                              Padding(
                                padding: EdgeInsets.all(10.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontSize: 13.sp),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: const Color(0xFFFBBF24),
                                          size: 14.sp,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          '${product['rating']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(fontSize: 11.sp),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '\$${product['price']}',
                                          style: TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
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
              ),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }
}
