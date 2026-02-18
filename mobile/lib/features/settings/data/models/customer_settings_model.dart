class CustomerProfile {
  final String name;
  final String email;
  final String? phone;
  final String? avatar;

  CustomerProfile({
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }
}

class Address {
  final String label;
  final String line1;
  final String? line2;
  final String city;
  final String? state;
  final String? zip;
  final String country;
  final bool isDefault;

  Address({
    required this.label,
    required this.line1,
    this.line2,
    required this.city,
    this.state,
    this.zip,
    required this.country,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      label: json['label'] ?? '',
      line1: json['line1'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'],
      zip: json['zip'],
      country: json['country'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'is_default': isDefault,
    };
  }
}

class PaymentMethod {
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  PaymentMethod({
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      brand: json['brand'] ?? '',
      last4: json['last4'] ?? '',
      expMonth: json['exp_month'] ?? 1,
      expYear: json['exp_year'] ?? 2024,
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
      'is_default': isDefault,
    };
  }
}

class CustomerSettings {
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;

  CustomerSettings({
    required this.language,
    required this.theme,
    required this.notificationsEnabled,
    required this.addresses,
    required this.paymentMethods,
  });

  factory CustomerSettings.fromJson(Map<String, dynamic> json) {
    return CustomerSettings(
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'system',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      addresses: (json['addresses'] as List? ?? [])
          .map((a) => Address.fromJson(a))
          .toList(),
      paymentMethods: (json['payment_methods'] as List? ?? [])
          .map((p) => PaymentMethod.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notifications_enabled': notificationsEnabled,
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'payment_methods': paymentMethods.map((p) => p.toJson()).toList(),
    };
  }
}

class SettingsPayload {
  final CustomerProfile profile;
  final CustomerSettings settings;

  SettingsPayload({required this.profile, required this.settings});

  factory SettingsPayload.fromJson(Map<String, dynamic> json) {
    return SettingsPayload(
      profile: CustomerProfile.fromJson(json['profile'] ?? {}),
      settings: CustomerSettings.fromJson(json['settings'] ?? {}),
    );
  }
}
