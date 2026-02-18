import 'package:flutter/material.dart';
import 'package:shop_mobile/features/settings/data/models/customer_settings_model.dart';

class ProfilePage extends StatefulWidget {
  final CustomerProfile profile;

  const ProfilePage({super.key, required this.profile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _avatarController = TextEditingController(text: widget.profile.avatar ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updated = CustomerProfile(
      name: _nameController.text.trim(),
      email: widget.profile.email,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      avatar: _avatarController.text.trim().isEmpty
          ? null
          : _avatarController.text.trim(),
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Padding(
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
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _avatarController,
                decoration: const InputDecoration(labelText: 'Avatar URL'),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
