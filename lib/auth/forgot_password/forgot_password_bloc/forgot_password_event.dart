import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends ForgotPasswordEvent {
  final String email;

  const EmailChanged({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordSubmitted extends ForgotPasswordEvent {}

class VerifyOtpAndUpdatePassword extends ForgotPasswordEvent {
  final String otp;
  final String newPassword;

  const VerifyOtpAndUpdatePassword({
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object> get props => [otp, newPassword];
}
