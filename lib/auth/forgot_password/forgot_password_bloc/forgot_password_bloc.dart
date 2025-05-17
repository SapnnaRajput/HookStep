import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../utils/app_const.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordState.initial()) {
    on<EmailChanged>(_onEmailChanged);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<VerifyOtpAndUpdatePassword>(_onVerifyOtpAndUpdatePassword);
  }

  void _onEmailChanged(EmailChanged event, Emitter<ForgotPasswordState> emit) {
    final isValidEmail = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
        .hasMatch(event.email);

    emit(state.copyWith(
      email: event.email,
      isEmailValid: isValidEmail,
    ));
  }

  Future<void> _onResetPasswordSubmitted(
      ResetPasswordSubmitted event, Emitter<ForgotPasswordState> emit) async {
    if (!state.isEmailValid || state.email.isEmpty) {
      emit(state.copyWith(isFailure: true));
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      final response = await http.post(
        Uri.parse(
            "$baseUrl/api/user/sendOTPEmail"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": state.email}),
      );

      print("Send OTP ::::: ${response.body}");
      print("Send OTP ::::: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          emit(state.copyWith(
            isSubmitting: false,
            isOTPSent: true,
          ));
        } else {
          emit(state.copyWith(isSubmitting: false, isFailure: true));
        }
      } else {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    } catch (_) {
      emit(state.copyWith(isSubmitting: false, isFailure: true));
    }
  }

  Future<void> _onVerifyOtpAndUpdatePassword(VerifyOtpAndUpdatePassword event,
      Emitter<ForgotPasswordState> emit) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      final response = await http.post(
        Uri.parse(
            "$baseUrl/api/user/resetPassword"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": state.email,
          "otp": event.otp,
          "newPassword": event.newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          emit(state.copyWith(
            isSubmitting: false,
            isPasswordReset: true,
          ));
        } else {
          emit(state.copyWith(isSubmitting: false, isFailure: true));
        }
      } else {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    } catch (_) {
      emit(state.copyWith(isSubmitting: false, isFailure: true));
    }
  }
}
