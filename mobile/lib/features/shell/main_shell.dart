import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/core/theme/theme_cubit.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavigate;

  const MainShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: widget.currentIndex == 0,
                  onTap: () => widget.onNavigate(0),
                ),
                _NavItem(
                  icon: Icons.category_rounded,
                  label: 'Categories',
                  isSelected: widget.currentIndex == 1,
                  onTap: () => widget.onNavigate(1),
                ),
                _NavItem(
                  icon: Icons.shopping_cart_rounded,
                  label: 'Cart',
                  isSelected: widget.currentIndex == 2,
                  onTap: () => widget.onNavigate(2),
                  badge: 3, // TODO: Connect to cart state
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: widget.currentIndex == 3,
                  onTap: () => widget.onNavigate(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final inactiveColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 10.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.primaryColor : inactiveColor,
                  size: 22.sp,
                ),
                if (badge != null && badge! > 0)
                  Positioned(
                    right: -6.w,
                    top: -3.h,
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14.w,
                        minHeight: 14.w,
                      ),
                      child: Text(
                        badge! > 9 ? '9+' : badge.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1 : 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
