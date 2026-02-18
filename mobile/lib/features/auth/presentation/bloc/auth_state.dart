import 'package:equatable/equatable.dart';
import 'package:shop_mobile/features/auth/data/models/user_model.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  requiresOtpVerification,
  requires2FA,
  twoFactorSetup,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? pendingEmail;
  final String? twoFactorSecret;
  final String? twoFactorQrUrl;
  final String? message;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.pendingEmail,
    this.twoFactorSecret,
    this.twoFactorQrUrl,
    this.message,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? pendingEmail,
    String? twoFactorSecret,
    String? twoFactorQrUrl,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      twoFactorSecret: twoFactorSecret ?? this.twoFactorSecret,
      twoFactorQrUrl: twoFactorQrUrl ?? this.twoFactorQrUrl,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    error,
    pendingEmail,
    twoFactorSecret,
    twoFactorQrUrl,
    message,
  ];
}
