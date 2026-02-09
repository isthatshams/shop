import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final bool twoFactorEnabled;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.twoFactorEnabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      twoFactorEnabled: json['two_factor_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'two_factor_enabled': twoFactorEnabled,
    };
  }

  @override
  List<Object?> get props => [id, name, email, twoFactorEnabled];
}
