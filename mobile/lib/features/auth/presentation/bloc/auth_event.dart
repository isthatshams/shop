import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class AuthOtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthOtpVerifyRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class AuthOtpResendRequested extends AuthEvent {
  final String email;

  const AuthOtpResendRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class Auth2FAVerifyRequested extends AuthEvent {
  final String code;

  const Auth2FAVerifyRequested({required this.code});

  @override
  List<Object?> get props => [code];
}

class Auth2FAEnableRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

// Used for canceling OTP flow without calling logout API
class AuthResetRequested extends AuthEvent {}
