import 'package:equatable/equatable.dart';
import 'package:shop_mobile/features/auth/data/models/user_model.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  requires2FA,
  twoFactorSetup,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? twoFactorSecret;
  final String? twoFactorQrUrl;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.twoFactorSecret,
    this.twoFactorQrUrl,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? twoFactorSecret,
    String? twoFactorQrUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      twoFactorSecret: twoFactorSecret ?? this.twoFactorSecret,
      twoFactorQrUrl: twoFactorQrUrl ?? this.twoFactorQrUrl,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    error,
    twoFactorSecret,
    twoFactorQrUrl,
  ];
}
