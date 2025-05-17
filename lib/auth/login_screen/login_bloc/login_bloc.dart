import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<MobileNumberChanged>((event, emit) {
      final isValid = event.mobileNumber.length == 10;
      emit(state.copyWith(
        mobileNumber: event.mobileNumber,
        isMobileNumberValid: isValid,
      ));
    });

    on<PasswordChanged>((event, emit) {
      final isValid = event.password.length < 4;
      emit(state.copyWith(
        password: event.password,
        isPasswordValid: isValid,
      ));
    });

    on<TogglePasswordVisibility>((event, emit) {
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
    });
  }
}
