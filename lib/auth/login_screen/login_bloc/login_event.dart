import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class MobileNumberChanged extends LoginEvent {
  final String mobileNumber;

  const MobileNumberChanged(this.mobileNumber);

  @override
  List<Object> get props => [mobileNumber];
}

class PasswordChanged extends LoginEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class TogglePasswordVisibility extends LoginEvent {}
