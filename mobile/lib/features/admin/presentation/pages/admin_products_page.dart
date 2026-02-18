import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/features/admin/data/repositories/admin_auth_repository.dart';
import 'package:shop_mobile/features/admin/data/repositories/admin_product_repository.dart';
import 'package:shop_mobile/features/products/data/models/product_model.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final AdminProductRepository _repository = AdminProductRepository();
  final AdminAuthRepository _authRepository = AdminAuthRepository();
  final List<Product> _products = [];
  int _page = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final authenticated = await _authRepository.isAuthenticated();
    if (!mounted) return;
    if (!authenticated) {
      context.go('/admin/login');
      return;
    }
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
      _isLoading = _page == 1;
      _isLoadingMore = _page > 1;
    });

    final result = await _repository.getProducts(page: _page, perPage: 20);
    if (!mounted) return;

    setState(() {
      _products.addAll(result.products);
      _hasMore = result.hasMore;
      _isLoading = false;
      _isLoadingMore = false;
      _page += 1;
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _repository.deleteProduct(product.id);
    if (!mounted) return;

    if (success) {
      setState(() => _products.removeWhere((p) => p.id == product.id));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete product'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/admin/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await context.push<bool>('/admin/products/create');
          if (changed == true && mounted) {
            _loadProducts(refresh: true);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProducts(refresh: true),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  if (index == _products.length) {
                    if (_hasMore && !_isLoadingMore) {
                      _loadProducts();
                    }
                    return _isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }

                  final product = _products[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    tileColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      '${product.isActive ? "Active" : "Inactive"} • Stock: ${product.stock}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context
                              .push<bool>('/admin/products/${product.id}/edit')
                              .then((changed) {
                                if (changed == true && mounted) {
                                  _loadProducts(refresh: true);
                                }
                              });
                        } else if (value == 'delete') {
                          _deleteProduct(product);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () {
                      context
                          .push<bool>('/admin/products/${product.id}/edit')
                          .then((changed) {
                            if (changed == true && mounted) {
                              _loadProducts(refresh: true);
                            }
                          });
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _products.length + 1,
              ),
      ),
    );
  }
}
