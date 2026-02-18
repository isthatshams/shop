import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/core/theme/theme_cubit.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Sample cart data - replace with real state management
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': 1,
      'name': 'Wireless Headphones',
      'price': 99.99,
      'quantity': 1,
      'image': 'https://picsum.photos/100/100?random=20',
    },
    {
      'id': 2,
      'name': 'Smart Watch Pro',
      'price': 199.99,
      'quantity': 2,
      'image': 'https://picsum.photos/100/100?random=21',
    },
    {
      'id': 3,
      'name': 'Running Shoes',
      'price': 129.99,
      'quantity': 1,
      'image': 'https://picsum.photos/100/100?random=22',
    },
  ];

  double get _subtotal => _cartItems.fold(
    0,
    (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
  );

  double get _shipping => _subtotal > 100 ? 0 : 9.99;
  double get _total => _subtotal + _shipping;

  void _updateQuantity(int index, int change) {
    setState(() {
      final newQty = (_cartItems[index]['quantity'] as int) + change;
      if (newQty > 0) {
        _cartItems[index]['quantity'] = newQty;
      } else {
        _cartItems.removeAt(index);
      }
    });
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
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Cart',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        '${_cartItems.length} items',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (_cartItems.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() => _cartItems.clear());
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                ],
              ),
            ),

            // Cart Items
            Expanded(
              child: _cartItems.isEmpty
                  ? _buildEmptyCart(context, isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Dismissible(
                          key: Key(item['id'].toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            setState(() => _cartItems.removeAt(index));
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkSurface
                                  : AppTheme.lightSurface,
                              borderRadius: BorderRadius.circular(20),
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
                            child: Row(
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item['image'] as String,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: isDark
                                          ? AppTheme.darkCard
                                          : AppTheme.lightCard,
                                      child: const Icon(Icons.image),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] as String,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item['price']}',
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity Controls
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.darkCard
                                        : AppTheme.lightCard,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _updateQuantity(index, -1),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '${item['quantity']}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18),
                                        onPressed: () =>
                                            _updateQuantity(index, 1),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
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

            // Checkout Section
            if (_cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${_subtotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            _shipping == 0
                                ? 'Free'
                                : '\$${_shipping.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: _shipping == 0
                                  ? AppTheme.successColor
                                  : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '\$${_total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  Widget _buildEmptyCart(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightCard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () {}, child: const Text('Start Shopping')),
        ],
      ),
    );
  }
}
