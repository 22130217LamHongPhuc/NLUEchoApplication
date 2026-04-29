import 'package:echo_nlu/core/providers/core_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exception/app_exception.dart';
import '../../../repositories/auth_repository.dart';
import '../models/AuthValidator.dart';

enum AuthStatus {
  initial,
  submitting,
  authenticated,
  unauthenticated,
  success,
  failure,
}

class AuthState {
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;

  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? fullNameError;
  final String? generalError;

  final AuthStatus status;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  const AuthState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.fullName = '',
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.fullNameError,
    this.generalError,
    this.status = AuthStatus.initial,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  AuthState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? fullName,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? fullNameError,
    String? generalError,
    AuthStatus? status,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearConfirmPasswordError = false,
    bool clearFullNameError = false,
    bool clearGeneralError = false,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      emailError: clearEmailError ? null : emailError,
      passwordError: clearPasswordError ? null : passwordError,
      confirmPasswordError: clearConfirmPasswordError
          ? null : confirmPasswordError,
      fullNameError: clearFullNameError ? null : fullNameError,
      generalError: clearGeneralError ? null :generalError,
      status: status ?? this.status,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
      obscureConfirmPassword ?? this.obscureConfirmPassword,
    );
  }

  bool get isLoading => status == AuthStatus.submitting;

  @override
  String toString() {
    return 'AuthState{email: $email, password: $password, confirmPassword: $confirmPassword, fullName: $fullName, emailError: $emailError, passwordError: $passwordError, confirmPasswordError: $confirmPasswordError, fullNameError: $fullNameError, generalError: $generalError, status: $status, obscurePassword: $obscurePassword, obscureConfirmPassword: $obscureConfirmPassword}';
  }


}



class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
     _repository = ref.read(authRepositoryProvider);
    return const AuthState();
  }

  void onEmailChanged(String value) {
    state = state.copyWith(
      email: value,
      emailError: AuthValidator.validateEmail(value),
      clearGeneralError: true,
      status: AuthStatus.initial,
    );
  }

  // void onPasswordChanged(String value) {
  //
  //   state = state.copyWith(
  //     password: value,
  //     passwordError: AuthValidator.validatePassword(value),
  //     confirmPasswordError: state.confirmPassword.isEmpty
  //         ? null
  //         : AuthValidator.validateConfirmPassword(value, state.confirmPassword),
  //     clearGeneralError: true,
  //     status: AuthStatus.initial,
  //   );
  // }
  void onPasswordChanged(String value) {
    final passwordError = AuthValidator.validatePassword(value);
    final confirmPasswordError = state.confirmPassword.isEmpty
        ? null
        : AuthValidator.validateConfirmPassword(value, state.confirmPassword);
    state = state.copyWith(
      password: value,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      clearGeneralError: true,
      status: AuthStatus.initial,
    );
  }

  void onConfirmPasswordChanged(String value) {
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordError:
      AuthValidator.validateConfirmPassword(state.password, value),
      clearGeneralError: true,
      status: AuthStatus.initial,
    );
  }

  void onFullNameChanged(String value) {
    state = state.copyWith(
      fullName: value,
      fullNameError: AuthValidator.validateFullName(value),
      clearGeneralError: true,
      status: AuthStatus.initial,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(
      obscurePassword: !state.obscurePassword,
    );
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  bool validateLoginForm() {
    final emailError = AuthValidator.validateEmail(state.email);
    final passwordError = AuthValidator.validatePassword(state.password);

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      status: AuthStatus.initial,
    );

    return emailError == null && passwordError == null;
  }

  bool validateRegisterForm() {
    final fullNameError = AuthValidator.validateFullName(state.fullName);
    final emailError = AuthValidator.validateEmail(state.email);
    final passwordError = AuthValidator.validatePassword(state.password);
    final confirmPasswordError = AuthValidator.validateConfirmPassword(
      state.password,
      state.confirmPassword,
    );

    state = state.copyWith(
      fullNameError: fullNameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      status: AuthStatus.initial,
    );

    return fullNameError == null &&
        emailError == null &&
        passwordError == null ;
        confirmPasswordError == null;
  }

  Future<void> submitLogin() async {
    if (!validateLoginForm()) return;
    if (state.isLoading) return;

    state = state.copyWith(
      status: AuthStatus.submitting,
      clearGeneralError: true,
    );

   final response = await _repository.login(
      email: state.email.trim(),
      password: state.password,
    );

   if(response.success) {

     state = state.copyWith(
       status: AuthStatus.authenticated,
       clearGeneralError: true
     );
   } else {
     state = state.copyWith(
       status: AuthStatus.failure,
       generalError: response.message,
     );
   }



  }

  Future<void> submitRegister() async {
    if (!validateRegisterForm()) return;
    if (state.isLoading) return;

    state = state.copyWith(
      status: AuthStatus.submitting,
      clearGeneralError: true,
    );
    final response = await _repository.register(
      fullName: state.fullName.trim(),
      email: state.email.trim(),
      password: state.password,
    );

    if(response.success) {
      state = state.copyWith(
        status: AuthStatus.success,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.failure,
        generalError: response.message
      );
    }
  }

  Future<void> logout() async {
    debugPrint('logout with refresh token : ${ref.read(localStorageProvider).refreshToken}');
    final response = await _repository.logout(ref.read(localStorageProvider).refreshToken);
    ref.read(localStorageProvider).resetAuth();

    if(response.success) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearGeneralError: true,
      );
    } else {
      state = state.copyWith(
        generalError: response.message,
      );
    }
  }

  void resetStatus() {
    state = state.copyWith(status: AuthStatus.initial);
  }
}