import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../utils/gradient_text.dart';
import '../../utils/theam_manager.dart';
import '../../utils/toast_massage.dart';
import '../../utils/want_text.dart';
import '../../utils/widget/custom_text_formfield/custom_text_form_field.dart';
import '../../utils/widget/general_button/general_button.dart';
import '../login_screen/login_screen.dart';
import 'forgot_password_bloc/forgot_password_bloc.dart';
import 'forgot_password_bloc/forgot_password_event.dart';
import 'forgot_password_bloc/forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailText = TextEditingController();
  bool _passwordVisible = false;
  final TextEditingController confirmPassText = TextEditingController();
  String? otpFromServer;  bool _confirmPasswordVisible = false;

  final TextEditingController newPasswordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocProvider(
        create: (_) => ForgotPasswordBloc(),
        child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state.isPasswordReset) {
              showToast("Password updated successfully!", colorBlack);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreeen()));
            } else if (state.isFailure) {
              showToast("An error occurred. Please try again.", colorSubTittle);
            }
          },
          child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
            builder: (context, state) {
              return Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.1),
                        GradientText(
                          "Forgot\nPassword",
                          width * 0.08,
                          FontWeight.bold,
                        ),
                        SizedBox(height: width * 0.01),
                        WantText("Reset Your Password", width * 0.035,
                            FontWeight.bold,colorSubTittle),
                        SizedBox(height: height * 0.04),

                        CustomTextFormField(
                          controller: emailText,
                          hint: "Email",
                          input: TextInputType.emailAddress,
                          icon: Icons.email,
                          condition: (value) => state.isEmailValid == false,
                          errorText: "Enter a valid email",
                          onChanged: (value) {
                            context
                                .read<ForgotPasswordBloc>()
                                .add(EmailChanged(email: value));
                          },
                        ),
                        if (state.isOTPSent) ...[ SizedBox(height: width * 0.04),
                          CustomTextFormField(
                            controller: newPasswordText,
                            hint: "New Password",
                            input: TextInputType.text,
                            icon: Icons.lock,obscureText: !_passwordVisible,
                            // obscureText: !state.isPasswordVisible,
                            onChanged: (value) {
                              // context
                              //     .read<SignupBloc>()
                              //     .add(PasswordChanged(value));
                            },
                            condition: (value) => value.length < 4, suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              child: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: colorBlack,
                                size: width * 0.06,
                              )),

                            errorText: "Enter at least 4 characters",
                          ),SizedBox(
                            height: width * 0.04,
                          ),
                          CustomTextFormField(
                            controller: confirmPassText,
                            hint: "Confirm Password",
                            errorText: "Passwords do not match",
                            input: TextInputType.text,
                            icon: (Icons.lock),obscureText: !_confirmPasswordVisible,
                            // obscureText: !state.isPasswordVisible,

                            suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _confirmPasswordVisible = !_confirmPasswordVisible;
                                  });
                                },
                                child: Icon(
                                  _confirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: colorBlack,
                                  size: width * 0.06,
                                )),
                            // obscureText: true, // Hide the confirm password
                            onChanged: (value) {}, condition: (String ) { return confirmPassText.text != newPasswordText.text; },
                            // Validation for mismatch
                          ),
                          SizedBox(height: width * 0.06),
                          Center(
                            child: VerificationCode(
                              textStyle: GoogleFonts.dmSans(
                                color: colorBlack,
                                fontSize: width * 0.048,
                                fontWeight: FontWeight.w500,
                              ),
                              digitsOnly: true,
                              fullBorder: true,
                              itemSize: width * 0.1,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02),
                              margin:
                              EdgeInsets.only(right: width * 0.02),
                              keyboardType: TextInputType.number,
                              length: 4,
                              onCompleted: (String value) {
                                otpFromServer = value;
                              },
                              onEditing: (bool value) {
                                // setState(() {
                                // _onEditing = value;
                                // });
                                // if (!_onEditing) FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                        ],
                        SizedBox(height: width * 0.06),
                        if (state.isSubmitting)
                          Center(
                            child: LoadingAnimationWidget.progressiveDots(
                              color: colorBlack,
                              size: width * 0.12,
                            ),
                          )
                        else    GeneralButton(
                          isBoarderRadiusLess: true,
                          Width: width,
                          onTap: () {
                            if (!state.isOTPSent) {
                              if (emailText.text.isEmpty) {
                                showToast("Please enter email ID", colorSubTittle);
                              } else if (state.isEmailValid) {
                                context.read<ForgotPasswordBloc>().add(ResetPasswordSubmitted());
                              } else {
                                showToast("Please enter a valid email", colorSubTittle);
                              }
                            } else {
                              if (otpFromServer == null || otpFromServer!.isEmpty) {
                                showToast("Please enter OTP", colorSubTittle);
                              } else if (newPasswordText.text.isEmpty) {
                                showToast("Please enter new password", colorSubTittle);
                              } else if (confirmPassText.text.isEmpty) {
                                showToast("Please confirm your password", colorSubTittle);
                              } else {
                                // Verify OTP & Update Password Button Logic
                                context.read<ForgotPasswordBloc>().add(
                                  VerifyOtpAndUpdatePassword(
                                    otp: otpFromServer!,
                                    newPassword: newPasswordText.text,
                                  ),
                                );
                              }
                            }
                          },
                          label: state.isOTPSent ? "Verify OTP & Update Password" : "Send OTP",
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WantText("Remember your password?   ",
                                width * 0.035, FontWeight.w500, colorBlack),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreeen(),
                                    ));
                              },
                              child: GradientText(
                                "Log In ",
                                width * 0.036,
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // ] else
                        //   SizedBox(height: width * 0.06),
                        //   GeneralButton(Width:width ,isBoarderRadiusLess: true,
                        //     label: "Send OTP",
                        //     onTap: () {
                        //       context
                        //           .read<ForgotPasswordBloc>()
                        //           .add(ResetPasswordSubmitted());
                        //     },
                        //   ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
