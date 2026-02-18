import 'package:flutter/material.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/features/admin/data/repositories/admin_product_repository.dart';
import 'package:shop_mobile/features/products/data/models/product_model.dart';
import 'package:shop_mobile/features/products/data/repositories/product_repository.dart';

class AdminProductFormPage extends StatefulWidget {
  final int? productId;

  const AdminProductFormPage({super.key, this.productId});

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _ratingController = TextEditingController(text: '0');
  final _reviewsController = TextEditingController(text: '0');

  final AdminProductRepository _repository = AdminProductRepository();
  final ProductRepository _catalogRepository = ProductRepository();

  bool _isLoading = false;
  bool _isFeatured = false;
  bool _isActive = true;
  int? _categoryId;
  List<Category> _categories = [];
  List<TextEditingController> _imageControllers = [TextEditingController()];

  bool get isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (isEdit) {
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _ratingController.dispose();
    _reviewsController.dispose();
    for (final controller in _imageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _catalogRepository.getCategories();
    if (!mounted) return;
    setState(() => _categories = categories);
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    final product = await _repository.getProduct(widget.productId!);
    if (!mounted) return;
    if (product != null) {
      _nameController.text = product.name;
      _slugController.text = product.slug;
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toString();
      _originalPriceController.text = product.originalPrice?.toString() ?? '';
      _stockController.text = product.stock.toString();
      _ratingController.text = product.rating.toString();
      _reviewsController.text = product.reviewsCount.toString();
      _isFeatured = product.isFeatured;
      _isActive = product.isActive;
      _categoryId = product.categoryId;
      _imageControllers = product.images.isEmpty
          ? [TextEditingController()]
          : product.images.map((img) => TextEditingController(text: img)).toList();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final payload = ProductPayload(
      name: _nameController.text.trim(),
      slug: _slugController.text.trim().isEmpty
          ? null
          : _slugController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      originalPrice: _originalPriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_originalPriceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      isActive: _isActive,
      isFeatured: _isFeatured,
      images: _imageControllers
          .map((c) => c.text.trim())
          .where((url) => url.isNotEmpty)
          .toList(),
      categoryId: _categoryId,
      rating: double.tryParse(_ratingController.text.trim()) ?? 0,
      reviewsCount: int.tryParse(_reviewsController.text.trim()) ?? 0,
    );

    final result = isEdit
        ? await _repository.updateProduct(widget.productId!, payload)
        : await _repository.createProduct(payload);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.error ?? 'Failed to save product'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _addImageField() {
    setState(() => _imageControllers.add(TextEditingController()));
  }

  void _removeImageField(int index) {
    if (_imageControllers.length == 1) return;
    final controller = _imageControllers.removeAt(index);
    controller.dispose();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _slugController,
                      decoration: const InputDecoration(labelText: 'Slug'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Original Price (optional)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final original = double.tryParse(value);
                        final price = double.tryParse(_priceController.text);
                        if (original == null) return 'Enter a valid number';
                        if (price != null && original < price) {
                          return 'Original price must be >= price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid stock number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _categoryId,
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _categoryId = value),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ratingController,
                            decoration: const InputDecoration(labelText: 'Rating'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return null;
                              final rating = double.tryParse(value);
                              if (rating == null) return 'Enter a valid rating';
                              if (rating < 0 || rating > 5) {
                                return 'Rating must be 0-5';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _reviewsController,
                            decoration:
                                const InputDecoration(labelText: 'Reviews'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    SwitchListTile(
                      title: const Text('Featured'),
                      value: _isFeatured,
                      onChanged: (value) => setState(() => _isFeatured = value),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Images',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._imageControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: 'Image URL ${index + 1}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeImageField(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addImageField,
                        icon: const Icon(Icons.add),
                        label: const Text('Add image'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isLoading ? 'Saving...' : 'Save Product',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
