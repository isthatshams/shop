import 'package:flutter/material.dart';
import 'package:shop_mobile/features/settings/data/models/customer_settings_model.dart';

class AddressesPage extends StatefulWidget {
  final List<Address> addresses;

  const AddressesPage({super.key, required this.addresses});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  late List<Address> _addresses;

  @override
  void initState() {
    super.initState();
    _addresses = List.of(widget.addresses);
  }

  void _addAddress() {
    showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddressFormSheet(),
    ).then((address) {
      if (address != null) {
        setState(() {
          _addresses = _addresses.map((a) {
            if (address.isDefault) {
              return Address(
                label: a.label,
                line1: a.line1,
                line2: a.line2,
                city: a.city,
                state: a.state,
                zip: a.zip,
                country: a.country,
                isDefault: false,
              );
            }
            return a;
          }).toList();
          _addresses.add(address);
        });
      }
    });
  }

  void _removeAddress(int index) {
    setState(() => _addresses.removeAt(index));
  }

  void _save() {
    Navigator.pop(context, _addresses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        child: const Icon(Icons.add),
      ),
      body: _addresses.isEmpty
          ? const Center(child: Text('No addresses added'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return ListTile(
                  title: Text(address.label),
                  subtitle: Text(
                    '${address.line1}, ${address.city}, ${address.country}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeAddress(index),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _addresses.length,
            ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  const _AddressFormSheet();

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _labelController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = Address(
      label: _labelController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim().isEmpty
          ? null
          : _line2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      zip: _zipController.text.trim().isEmpty
          ? null
          : _zipController.text.trim(),
      country: _countryController.text.trim(),
      isDefault: _isDefault,
    );

    Navigator.pop(context, address);
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
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Label'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Label is required'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _line1Controller,
                decoration: const InputDecoration(labelText: 'Address Line 1'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Address line is required'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _line2Controller,
                decoration: const InputDecoration(labelText: 'Address Line 2'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => value == null || value.isEmpty
                    ? 'City is required'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _zipController,
                decoration: const InputDecoration(labelText: 'ZIP Code'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Country is required'
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
                  child: const Text('Add address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
