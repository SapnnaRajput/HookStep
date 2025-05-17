import 'package:bloc/bloc.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(const SignupState()) {
    on<UsernameChanged>((event, emit) {
      final isValid = event.username.isNotEmpty;
      emit(state.copyWith(
        username: event.username,
        isUsernameValid: isValid,
      ));
    });

    on<MobileNumberChanged>((event, emit) {
      final isValid = event.mobileNumber.length <7;
      emit(state.copyWith(
        mobileNumber: event.mobileNumber,
        isMobileNumberValid: isValid,
      ));
    });

    on<EmailChanged>((event, emit) {
      final isValid = event.email.contains('@');
      emit(state.copyWith(
        email: event.email,
        isEmailValid: isValid,
      ));
    });

    on<PasswordChanged>((event, emit) {
      final isValid = event.password.length >= 4;
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
