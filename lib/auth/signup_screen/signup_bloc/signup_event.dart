import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class UsernameChanged extends SignupEvent {
  final String username;

  const UsernameChanged(this.username);

  @override
  List<Object> get props => [username];
}

class MobileNumberChanged extends SignupEvent {
  final String mobileNumber;

  const MobileNumberChanged(this.mobileNumber);

  @override
  List<Object> get props => [mobileNumber];
}

class EmailChanged extends SignupEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class PasswordChanged extends SignupEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class TogglePasswordVisibility extends SignupEvent {}
