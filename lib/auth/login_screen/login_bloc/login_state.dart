import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String mobileNumber;
  final String password;
  final bool isMobileNumberValid;
  final bool isPasswordValid;
  final bool isPasswordVisible;

  const LoginState({
    this.mobileNumber = '',
    this.password = '',
    this.isMobileNumberValid = true,
    this.isPasswordValid = true,
    this.isPasswordVisible = false,
  });

  LoginState copyWith({
    String? mobileNumber,
    String? password,
    bool? isMobileNumberValid,
    bool? isPasswordValid,
    bool? isPasswordVisible,
  }) {
    return LoginState(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      password: password ?? this.password,
      isMobileNumberValid: isMobileNumberValid ?? this.isMobileNumberValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  @override
  List<Object> get props => [
    mobileNumber,
    password,
    isMobileNumberValid,
    isPasswordValid,
    isPasswordVisible,
  ];
}
