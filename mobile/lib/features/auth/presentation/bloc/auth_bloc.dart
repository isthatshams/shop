import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:shop_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:shop_mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<Auth2FAVerifyRequested>(_on2FAVerifyRequested);
    on<Auth2FAEnableRequested>(_on2FAEnableRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthResetRequested>(_onResetRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.getCurrentUser();

    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await _authRepository.login(event.email, event.password);

    if (result.success) {
      if (result.requiresOtp) {
        emit(
          state.copyWith(
            status: AuthStatus.requiresOtpVerification,
            pendingEmail: result.pendingEmail,
            message: result.message,
          ),
        );
      } else if (result.requires2FA) {
        emit(state.copyWith(status: AuthStatus.requires2FA));
      } else {
        emit(
          state.copyWith(status: AuthStatus.authenticated, user: result.user),
        );
      }
    } else {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, error: result.error),
      );
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await _authRepository.register(
      event.name,
      event.email,
      event.password,
    );

    if (result.success) {
      if (result.requiresOtp) {
        emit(
          state.copyWith(
            status: AuthStatus.requiresOtpVerification,
            pendingEmail: result.pendingEmail ?? event.email,
          ),
        );
      } else {
        emit(
          state.copyWith(status: AuthStatus.authenticated, user: result.user),
        );
      }
    } else {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, error: result.error),
      );
    }
  }

  Future<void> _onOtpVerifyRequested(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await _authRepository.verifyOtp(event.email, event.otp);

    if (result.success) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: result.user));
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.requiresOtpVerification,
          error: result.error,
          pendingEmail: event.email,
        ),
      );
    }
  }

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.resendOtp(event.email);

    if (result.success) {
      emit(
        state.copyWith(
          status: AuthStatus.requiresOtpVerification,
          pendingEmail: event.email,
          message: 'OTP sent successfully',
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.requiresOtpVerification,
          pendingEmail: event.email,
          error: result.error,
        ),
      );
    }
  }

  Future<void> _on2FAVerifyRequested(
    Auth2FAVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    final result = await _authRepository.verify2FA(event.code);

    if (result.success) {
      if (result.user != null) {
        emit(
          state.copyWith(status: AuthStatus.authenticated, user: result.user),
        );
      } else {
        final user = await _authRepository.getCurrentUser();
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      }
    } else {
      emit(state.copyWith(status: AuthStatus.requires2FA, error: result.error));
    }
  }

  Future<void> _on2FAEnableRequested(
    Auth2FAEnableRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authRepository.enable2FA();

    if (result.success) {
      emit(
        state.copyWith(
          status: AuthStatus.twoFactorSetup,
          twoFactorSecret: result.secret,
          twoFactorQrUrl: result.qrCodeUrl,
        ),
      );
    } else {
      emit(
        state.copyWith(status: AuthStatus.authenticated, error: result.error),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onResetRequested(AuthResetRequested event, Emitter<AuthState> emit) {
    // Simply reset to unauthenticated without API call
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
