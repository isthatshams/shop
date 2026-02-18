import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/core/theme/theme_cubit.dart';
import 'package:shop_mobile/features/admin/data/repositories/admin_auth_repository.dart';
import 'package:shop_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shop_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:shop_mobile/features/settings/data/models/customer_settings_model.dart';
import 'package:shop_mobile/features/settings/data/repositories/settings_repository.dart';
import 'package:shop_mobile/features/settings/presentation/pages/addresses_page.dart';
import 'package:shop_mobile/features/settings/presentation/pages/payment_methods_page.dart';
import 'package:shop_mobile/features/settings/presentation/pages/profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsRepository _repository = SettingsRepository();
  final AdminAuthRepository _adminAuthRepository = AdminAuthRepository();
  bool _loading = true;
  SettingsPayload? _payload;
  bool _adminLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkAdmin();
  }

  Future<void> _loadSettings() async {
    final payload = await _repository.getSettings();
    if (!mounted) return;
    setState(() {
      _payload = payload;
      _loading = false;
    });

    final theme = payload?.settings.theme;
    if (theme == 'dark' && !context.read<ThemeCubit>().isDarkMode) {
      context.read<ThemeCubit>().toggleTheme();
    }
    if (theme == 'light' && context.read<ThemeCubit>().isDarkMode) {
      context.read<ThemeCubit>().toggleTheme();
    }
  }

  Future<void> _checkAdmin() async {
    final loggedIn = await _adminAuthRepository.isAuthenticated();
    if (!mounted) return;
    setState(() => _adminLoggedIn = loggedIn);
  }

  Future<void> _updateSettings({
    CustomerProfile? profile,
    CustomerSettings? settings,
  }) async {
    final result = await _repository.updateSettings(
      profile: profile,
      settings: settings,
    );
    if (!mounted) return;
    if (result.success) {
      setState(() => _payload = result.payload);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to update settings'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  CustomerSettings _mergeSettings({
    String? language,
    String? theme,
    bool? notificationsEnabled,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
  }) {
    final current = _payload?.settings ??
        CustomerSettings(
          language: 'en',
          theme: 'system',
          notificationsEnabled: true,
          addresses: const [],
          paymentMethods: const [],
        );

    return CustomerSettings(
      language: language ?? current.language,
      theme: theme ?? current.theme,
      notificationsEnabled: notificationsEnabled ?? current.notificationsEnabled,
      addresses: addresses ?? current.addresses,
      paymentMethods: paymentMethods ?? current.paymentMethods,
    );
  }

  Future<void> _editProfile() async {
    final profile = _payload?.profile;
    if (profile == null) return;

    final updated = await Navigator.of(context).push<CustomerProfile>(
      MaterialPageRoute(builder: (_) => ProfilePage(profile: profile)),
    );

    if (updated != null) {
      await _updateSettings(profile: updated);
    }
  }

  Future<void> _editAddresses() async {
    final settings = _payload?.settings;
    if (settings == null) return;

    final updated = await Navigator.of(context).push<List<Address>>(
      MaterialPageRoute(
        builder: (_) => AddressesPage(addresses: settings.addresses),
      ),
    );

    if (updated != null) {
      await _updateSettings(settings: _mergeSettings(addresses: updated));
    }
  }

  Future<void> _editPaymentMethods() async {
    final settings = _payload?.settings;
    if (settings == null) return;

    final updated = await Navigator.of(context).push<List<PaymentMethod>>(
      MaterialPageRoute(
        builder: (_) => PaymentMethodsPage(methods: settings.paymentMethods),
      ),
    );

    if (updated != null) {
      await _updateSettings(
        settings: _mergeSettings(paymentMethods: updated),
      );
    }
  }

  Future<void> _chooseLanguage() async {
    final current = _payload?.settings.language ?? 'en';
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: current == 'en' ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, 'en'),
            ),
            ListTile(
              title: const Text('Arabic'),
              trailing: current == 'ar' ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, 'ar'),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      await _updateSettings(settings: _mergeSettings(language: selected));
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    await _updateSettings(settings: _mergeSettings(notificationsEnabled: enabled));
  }

  Future<void> _toggleTheme(bool enabled) async {
    context.read<ThemeCubit>().toggleTheme();
    await _updateSettings(settings: _mergeSettings(theme: enabled ? 'dark' : 'light'));
  }

  Future<void> _openAdmin() async {
    await _checkAdmin();
    if (_adminLoggedIn) {
      context.go('/admin/products');
    } else {
      context.go('/admin/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final profile = _payload?.profile;
    final settings = _payload?.settings;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),

              // Profile Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.name ?? 'Guest User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.email ?? 'Not logged in',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _editProfile,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Preferences Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.dark_mode,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Dark Mode',
                subtitle: isDark ? 'On' : 'Off',
                trailing: Switch.adaptive(
                  value: isDark,
                  onChanged: _toggleTheme,
                  activeColor: AppTheme.primaryColor,
                ),
              ),

              _SettingsTile(
                icon: Icons.notifications,
                iconColor: const Color(0xFFF59E0B),
                title: 'Notifications',
                subtitle: settings?.notificationsEnabled == true
                    ? 'Enabled'
                    : 'Disabled',
                trailing: Switch.adaptive(
                  value: settings?.notificationsEnabled ?? true,
                  onChanged: _toggleNotifications,
                  activeColor: AppTheme.primaryColor,
                ),
              ),

              _SettingsTile(
                icon: Icons.language,
                iconColor: const Color(0xFF10B981),
                title: 'Language',
                subtitle: settings?.language == 'ar' ? 'Arabic' : 'English',
                onTap: _chooseLanguage,
              ),

              _SettingsTile(
                icon: Icons.notifications_active,
                iconColor: const Color(0xFF38BDF8),
                title: 'Notification Center',
                subtitle: 'View all notifications',
                onTap: () => context.push('/notifications'),
              ),

              const SizedBox(height: 24),

              // Account Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.security,
                iconColor: const Color(0xFF6366F1),
                title: 'Security',
                subtitle: '2FA',
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.location_on,
                iconColor: const Color(0xFFEC4899),
                title: 'Addresses',
                subtitle: 'Manage shipping addresses',
                onTap: _editAddresses,
              ),

              _SettingsTile(
                icon: Icons.credit_card,
                iconColor: const Color(0xFF14B8A6),
                title: 'Payment Methods',
                subtitle: 'Manage cards',
                onTap: _editPaymentMethods,
              ),

              const SizedBox(height: 24),

              // Admin Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Admin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.admin_panel_settings,
                iconColor: const Color(0xFF0EA5E9),
                title: _adminLoggedIn ? 'Admin Panel' : 'Admin Login',
                subtitle: _adminLoggedIn
                    ? 'Manage products'
                    : 'Sign in as admin',
                onTap: _openAdmin,
              ),

              const SizedBox(height: 24),

              // Support Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Support',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              _SettingsTile(
                icon: Icons.help_outline,
                iconColor: const Color(0xFF64748B),
                title: 'Help Center',
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF64748B),
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      context.go('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  )
                : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
