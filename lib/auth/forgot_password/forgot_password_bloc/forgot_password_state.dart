import 'package:equatable/equatable.dart';

class ForgotPasswordState extends Equatable {
  final String email;
  final bool isEmailValid;
  final bool isSubmitting;
  final bool isOTPSent;
  final bool isPasswordReset;
  final bool isFailure;

  const ForgotPasswordState({
    required this.email,
    required this.isEmailValid,
    required this.isSubmitting,
    required this.isOTPSent,
    required this.isPasswordReset,
    required this.isFailure,
  });

  factory ForgotPasswordState.initial() {
    return ForgotPasswordState(
      email: '',
      isEmailValid: true,
      isSubmitting: false,
      isOTPSent: false,
      isPasswordReset: false,
      isFailure: false,
    );
  }

  ForgotPasswordState copyWith({
    String? email,
    bool? isEmailValid,
    bool? isSubmitting,
    bool? isOTPSent,
    bool? isPasswordReset,
    bool? isFailure,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isOTPSent: isOTPSent ?? this.isOTPSent,
      isPasswordReset: isPasswordReset ?? this.isPasswordReset,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  List<Object> get props =>
      [email, isEmailValid, isSubmitting, isOTPSent, isPasswordReset, isFailure];
}
