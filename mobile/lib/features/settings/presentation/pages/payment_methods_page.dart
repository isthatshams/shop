import 'package:flutter/material.dart';
import 'package:shop_mobile/features/settings/data/models/customer_settings_model.dart';

class PaymentMethodsPage extends StatefulWidget {
  final List<PaymentMethod> methods;

  const PaymentMethodsPage({super.key, required this.methods});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  late List<PaymentMethod> _methods;

  @override
  void initState() {
    super.initState();
    _methods = List.of(widget.methods);
  }

  void _addMethod() {
    showModalBottomSheet<PaymentMethod>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _PaymentFormSheet(),
    ).then((method) {
      if (method != null) {
        setState(() {
          _methods = _methods.map((m) {
            if (method.isDefault) {
              return PaymentMethod(
                brand: m.brand,
                last4: m.last4,
                expMonth: m.expMonth,
                expYear: m.expYear,
                isDefault: false,
              );
            }
            return m;
          }).toList();
          _methods.add(method);
        });
      }
    });
  }

  void _removeMethod(int index) {
    setState(() => _methods.removeAt(index));
  }

  void _save() {
    Navigator.pop(context, _methods);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMethod,
        child: const Icon(Icons.add),
      ),
      body: _methods.isEmpty
          ? const Center(child: Text('No payment methods added'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final method = _methods[index];
                return ListTile(
                  title: Text('${method.brand.toUpperCase()} •••• ${method.last4}'),
                  subtitle: Text('Exp ${method.expMonth}/${method.expYear}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeMethod(index),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _methods.length,
            ),
    );
  }
}

class _PaymentFormSheet extends StatefulWidget {
  const _PaymentFormSheet();

  @override
  State<_PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<_PaymentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _last4Controller = TextEditingController();
  final _expMonthController = TextEditingController();
  final _expYearController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _brandController.dispose();
    _last4Controller.dispose();
    _expMonthController.dispose();
    _expYearController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final method = PaymentMethod(
      brand: _brandController.text.trim(),
      last4: _last4Controller.text.trim(),
      expMonth: int.parse(_expMonthController.text.trim()),
      expYear: int.parse(_expYearController.text.trim()),
      isDefault: _isDefault,
    );

    Navigator.pop(context, method);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Brand is required'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _last4Controller,
                decoration: const InputDecoration(labelText: 'Last 4 digits'),
                maxLength: 4,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.length != 4
                    ? 'Enter last 4 digits'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expMonthController,
                decoration: const InputDecoration(labelText: 'Exp Month'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Month is required'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expYearController,
                decoration: const InputDecoration(labelText: 'Exp Year'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Year is required'
                    : null,
              ),
              SwitchListTile(
                title: const Text('Set as default'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Add method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
