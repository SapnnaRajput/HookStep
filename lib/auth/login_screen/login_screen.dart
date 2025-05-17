import 'dart:convert';
import 'package:dancebuddy/auth/forgot_password/forgot_password_screen.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart' as http;
import 'package:dancebuddy/auth/signup_screen/signup_screen.dart';
import 'package:dancebuddy/utils/theam_manager.dart';
import 'package:dancebuddy/utils/want_text.dart';
import 'package:dancebuddy/utils/widget/custom_text_formfield/custom_text_form_field.dart';
import 'package:dancebuddy/utils/widget/general_button/general_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/gradient_text.dart';
import '../../masterpage/masterpage.dart';
import '../../utils/app_const.dart';
import '../../utils/toast_massage.dart';
import 'login_bloc/login_bloc.dart';
import 'login_bloc/login_state.dart';

class LoginScreeen extends StatefulWidget {
  LoginScreeen({super.key});

  @override
  State<LoginScreeen> createState() => _LoginScreeenState();
}

class _LoginScreeenState extends State<LoginScreeen> {
  final TextEditingController emailText = TextEditingController();
  final TextEditingController passText = TextEditingController();
  bool _passwordVisible = false;
  bool isLoading = false;

  // bool isOTPSend = false;
  // bool isOtpVerify = false;
  // bool isOTPVerify = false;
  // bool isOTPSent = false;
  // String countryCode = '+1';

  final _formKey = GlobalKey<FormState>();
  bool isLoadingGoogle = false;

  String? otpFromServer; // New loading state for Google login

  Future<void> login() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Determine the platform (Android or iOS)
      String device = foundation.defaultTargetPlatform == TargetPlatform.android ? "Android" : "iOS";

      final response = await http.post(
        Uri.parse('$baseUrl/api/user/newLogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": emailText.text.trim(),
          "password": passText.text.trim(),
          "loginDevice": device,
        }),
      );
      print("response login : ${response.statusCode}");
      print("response login : ${response.body}");
      if (response.statusCode == 200||response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Save the token and ID in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('id', data['user']['_id']);

          // showToast("Login Successful", colorSubTittle);
          setState(() {
            isLoading = false;
          });

          // Navigate to the next screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MasterPage()), // Replace with your home screen
          );
        } else {
          setState(() {
            isLoading = false;
          });
          showToast(data['message'], colorSubTittle);
        }
      } else { final data = jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });
      showToast(data['message'], colorSubTittle);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showToast("An error occurred: $e", colorSubTittle);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocProvider(
        create: (_) => LoginBloc(),
        child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
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
                    SizedBox(
                      height: height * 0.1,
                    ),
                    GradientText(
                      "Welcome",
                      width * 0.08,
                      FontWeight.bold,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GradientText(
                          "Back!  ",
                          width * 0.08,
                          FontWeight.bold,
                        ),

                      ],
                    ),
                    SizedBox(
                      height: width * 0.01,
                    ),
                    WantText("We missed you", width * 0.035, FontWeight.w600,
                        colorSubTittle),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [


                            CustomTextFormField(
                              controller: emailText,
                              hint: "Email",
                              errorText: "Enter a valid email",
                              input: TextInputType.text,
                              icon: (Icons.email),
                              // obscureText: !state.isPasswordVisible,
                              onChanged: (value) {
                                },
                              condition: (value) => value.length < 4,
                            ),
                            SizedBox(
                              height: width * 0.04,
                            ),
                            CustomTextFormField(
                              controller: passText,
                              hint: "Password",
                              errorText: "Enter a valid Password",
                              input: TextInputType.text,
                              icon: (Icons.lock), obscureText: !_passwordVisible,
                              // obscureText: !state.isPasswordVisible,
                              onChanged: (value) {

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
                            ),
                            SizedBox(
                              height: width * 0.025,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(onTap:(){Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen(),));},
                                  child:GradientText(
                                    "Forgot Password?",
                                    width * 0.036,
                                    FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: width * 0.06,
                            ),

                            isLoading
                                ? Center(
                              child:
                              LoadingAnimationWidget.progressiveDots(
                                color: colorBlack,
                                size: width * 0.12,
                              ),
                            )
                                : GeneralButton(
                              isBoarderRadiusLess: true,
                              // isSelected: !isOtpVerify,
                              Width: width,
                              onTap: () {
                                if (emailText.text.length <= 4 ||
                                    passText.text.isEmpty) {
                                  showToast(
                                      "Please enter valid credentials",
                                      colorSubTittle);
                                } else {
                                  login();

                                  // loginWithEmailOrPhone(context);
                                  // Proceed with the sign-up process
                                  // showToast("Log In Successful",colorSubTittle);
                                }
                              },
                              label: "Log In",
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                WantText("Don't Have An Account?   ",
                                    width * 0.035, FontWeight.w500, colorBlack),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignupScreen(),
                                        ));
                                  },
                                  child: GradientText(
                                    "Create Account",
                                    width * 0.036,
                                    FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
