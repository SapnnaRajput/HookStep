import 'package:equatable/equatable.dart';

class SignupState extends Equatable {
  final String username;
  final String mobileNumber;
  final String email;
  final String password;
  final bool isUsernameValid;
  final bool isMobileNumberValid;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isPasswordVisible;

  const SignupState({
    this.username = '',
    this.mobileNumber = '',
    this.email = '',
    this.password = '',
    this.isUsernameValid = true,
    this.isMobileNumberValid = true,
    this.isEmailValid = true,
    this.isPasswordValid = true,
    this.isPasswordVisible = false,
  });

  SignupState copyWith({
    String? username,
    String? mobileNumber,
    String? email,
    String? password,
    bool? isUsernameValid,
    bool? isMobileNumberValid,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isPasswordVisible,
  }) {
    return SignupState(
      username: username ?? this.username,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      isUsernameValid: isUsernameValid ?? this.isUsernameValid,
      isMobileNumberValid: isMobileNumberValid ?? this.isMobileNumberValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  @override
  List<Object> get props => [
    username,
    mobileNumber,
    email,
    password,
    isUsernameValid,
    isMobileNumberValid,
    isEmailValid,
    isPasswordValid,
    isPasswordVisible,
  ];
}
