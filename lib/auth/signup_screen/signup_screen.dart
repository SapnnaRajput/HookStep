import 'dart:convert';
import 'dart:math';
import 'package:dancebuddy/auth/login_screen/login_screen.dart';
import 'package:dancebuddy/auth/signup_screen/signup_bloc/signup_bloc.dart';
import 'package:dancebuddy/auth/signup_screen/signup_bloc/signup_event.dart';
import 'package:dancebuddy/auth/signup_screen/signup_bloc/signup_state.dart';
import 'package:dancebuddy/utils/app_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/gradient_text.dart';
import '../../utils/theam_manager.dart';
import '../../utils/toast_massage.dart';
import '../../utils/want_text.dart';
import '../../utils/widget/custom_text_formfield/custom_text_form_field.dart';
import '../../utils/widget/general_button/general_button.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameText = TextEditingController();

  final TextEditingController mobileText = TextEditingController();

  final TextEditingController countryCodeText = TextEditingController();

  final TextEditingController emailText = TextEditingController();
  final TextEditingController passText = TextEditingController();
  final TextEditingController confirmPassText = TextEditingController();

  bool passwordVisible = false;
  String countryCode = '+1';
  final _formKey = GlobalKey<FormState>();

  bool isOTPVerify = false;
  bool isOTPSent = false;
  bool isOTPSend = false;
  bool isPasswordMismatch = false;
  String? otpFromServer;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? verificationId;
  bool isPhoneNumberValid = false;
  PhoneNumber number = PhoneNumber(isoCode: 'US');

  Future<void> sendOTP({
    required String email,
    required String mobile,
    required String mobileCode,
  }) async {
    const url = "$baseUrl/api/user/newSignup";

    try {
      setState(() {
        isOTPSend = true;
      });
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {"email": email, "mobile": mobile, "mobileCode": mobileCode}),
      );

      final data = jsonDecode(response.body);
      print("response send otp signup : ${response.statusCode}");
      print("response send otp signup : ${response.body}");
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          isOTPSend = false;
        });
        // Show success message
        print(data['message']);
        return;
      } else {
        setState(() {
          isOTPSend = false;
        });
        // Handle API error
        throw (data['message']);
      }
    } catch (e) {
      setState(() {
        isOTPSend = false;
      });
      // Handle error
      print("Error sending OTP: $e");
      rethrow;
    }
  }

  Future<void> verifyOTP({
    required String email,
    required String otp,
    required String password,
    required String name,
    required String mobile,
    required String mobileCode,
  }) async {
    const url =
        "$baseUrl/api/user/newSignupVerify";

    try {
      setState(() {
        isOTPVerify = true;
      });
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "password": password,
          "name": name,
          "mobile": mobile,
          "mobileCode": mobileCode,
        }),
      );

      final data = jsonDecode(response.body);
      print("response verify otp signup : ${response.statusCode}");
      print("response verify otp signup : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isOTPVerify = false;
        });
        // Save token and ID to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('id', data['user']['_id']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreeen(),
          ),
        );

        print("Account created successfully!");
        print("Token saved: ${data['token']}");
        return;
      } else {
        setState(() {
          isOTPVerify = false;
        });
        // Handle API error
        throw (data['message']);
      }
    } catch (e) {
      setState(() {
        isOTPVerify = false;
      });
      // Handle error
      print("Error verifying OTP: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (_) => SignupBloc(),
      child: BlocBuilder<SignupBloc, SignupState>(builder: (context, state) {
        return Scaffold(
          body: Container(
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
                    "Create  ",
                    width * 0.08,
                    FontWeight.bold,
                  ),
                  Row(
                    children: [
                      GradientText(
                        "Account ",
                        width * 0.08,
                        FontWeight.bold,
                      ),
                      // SizedBox(
                      //   width: width * 0.07,
                      //   child: GestureDetector(
                      //       onTap: () => showContactDialog(context),
                      //       child: Image.asset("assets/images/contact_us.png")),
                      // )
                    ],
                  ),
                  SizedBox(
                    height: width * 0.01,
                  ),
                  WantText("Register Your Account", width * 0.035,
                      FontWeight.w600, colorSubTittle),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // WantText("User Name", width * 0.035, FontWeight.w500,
                          //     colorBlack),
                          SizedBox(
                            height: width * 0.03,
                          ),
                          CustomTextFormField(
                            controller: usernameText,
                            hint: "Full Name",
                            input: TextInputType.name,
                            icon: Icons.person,
                            condition: (value) => value.length < 4,
                            errorText: "Enter a valid username",
                            onChanged: (value) {
                              context
                                  .read<SignupBloc>()
                                  .add(UsernameChanged(value));
                            },
                          ),
                          // SizedBox(
                          //   height: height * 0.025,
                          // ), WantText("Country Code", width * 0.035, FontWeight.w500,
                          //     colorBlack),
                          SizedBox(
                            height: width * 0.04,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Container(
                              //   height: height * 0.06,
                              //   width: double.infinity,
                              //   padding: EdgeInsets.only(left: width * 0.02),
                              //   decoration: BoxDecoration(
                              //     borderRadius:
                              //         BorderRadius.circular(width * 0.0266),
                              //     border: Border.all(
                              //         width: 1, color: colorGrey),
                              //   ),
                              //   child: InternationalPhoneNumberInput(
                              //     textAlignVertical: TextAlignVertical.center,
                              //     scrollPadding: EdgeInsets.zero,
                              //     selectorConfig: SelectorConfig(
                              //       setSelectorButtonAsPrefixIcon: true,
                              //       selectorType:
                              //           PhoneInputSelectorType.DIALOG,
                              //       useEmoji: false,
                              //       trailingSpace: false,
                              //       showFlags: true,
                              //     ),
                              //     selectorTextStyle: GoogleFonts.inter(
                              //       color: colorBlack,
                              //       fontSize: width * 0.03733,
                              //       fontWeight: FontWeight.w500,
                              //     ),
                              //     onInputChanged: (PhoneNumber number) {
                              //       setState(() {
                              //         countryCode = number.phoneNumber ?? '';
                              //       });
                              //     },
                              //     onInputValidated: (bool value) {
                              //       setState(() {
                              //         isPhoneNumberValid = value;
                              //       });
                              //     },
                              //     ignoreBlank: false,
                              //     autoValidateMode: AutovalidateMode.disabled,
                              //     initialValue: number,
                              //     textFieldController: mobileText,
                              //     formatInput: false,
                              //     keyboardType: TextInputType.numberWithOptions(
                              //       signed: true,
                              //       decimal: true,
                              //     ),
                              //     inputDecoration: InputDecoration(
                              //       hintStyle: GoogleFonts.inter(
                              //         color: colorGrey,
                              //         fontSize: width * 0.03733,
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //       hintText: 'Phone Number',
                              //       contentPadding: EdgeInsets.symmetric(
                              //           vertical: height * 0.016),
                              //       border: InputBorder.none,
                              //       isDense: true,
                              //     ),
                              //     inputBorder: OutlineInputBorder(
                              //       borderSide: BorderSide.none,
                              //       borderRadius: BorderRadius.circular(5),
                              //     ),
                              //     onSaved: (PhoneNumber number) {
                              //       String formattedNumber = number.phoneNumber
                              //               ?.replaceFirst('+', '') ??
                              //           '';
                              //       print('On Saved: $formattedNumber');
                              //     },
                              //     cursorColor: colorMainTheme,
                              //     textStyle: GoogleFonts.inter(
                              //       color: colorMainTheme,
                              //       fontSize: width * 0.03733,
                              //       fontWeight: FontWeight.w500,
                              //     ),
                              //   ),
                              // ),
                              Container(
                                height: height * 0.06,
                                width: width * 0.92,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(width * 0.02),
                                  ),
                                  border: Border.all(color: colorGrey),
                                  image: DecorationImage(
                                    opacity: 0.6,
                                    image: AssetImage(
                                        "assets/images/textFormFieldBG.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    setState(() {
                                      countryCode = number.dialCode ?? '+1';
                                    });
                                  },
                                  onInputValidated: (bool value) {
                                    setState(() {
                                      isPhoneNumberValid = value;
                                    });
                                    print(value ? 'Valid' : 'Invalid');
                                  },
                                  selectorConfig: SelectorConfig(
                                    leadingPadding: width * 0.04,
                                    trailingSpace: false,
                                    setSelectorButtonAsPrefixIcon: true,
                                    selectorType: PhoneInputSelectorType.DIALOG,
                                    useEmoji: false,
                                  ),
                                  selectorTextStyle: GoogleFonts.dmSans(
                                    color: colorBlack,
                                    fontSize: width * 0.04,
                                    // Set font size for the country code
                                    fontWeight: FontWeight.w500,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  initialValue: number,
                                  textFieldController: mobileText,
                                  formatInput: false,
                                  keyboardType: TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onSaved: (PhoneNumber number) {
                                    String formattedNumber = number.phoneNumber
                                            ?.replaceFirst('+', '') ??
                                        '';
                                    print('On Saved: $formattedNumber');
                                  },
                                  cursorColor: colorBlack,
                                  textStyle: GoogleFonts.dmSans(
                                    textStyle: TextStyle(
                                      fontSize: width * 0.04,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  inputDecoration: InputDecoration(
                                    fillColor: colorWhite,
                                    isDense: true,
                                    hintText: 'Enter Phone Number',
                                    hintStyle: GoogleFonts.dmSans(
                                      textStyle: TextStyle(
                                        fontSize: height * 0.01566,
                                        fontWeight: FontWeight.w400,
                                        color: colorGrey,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 5,
                                    ),
                                    prefixIconConstraints: BoxConstraints(
                                      minWidth: 0,
                                      minHeight: 0,
                                    ),
                                    suffixIconConstraints: BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                    errorMaxLines: 3,
                                    counterText: "",
                                  ),
                                ),
                              ),

                            ],
                          ),
                          SizedBox(
                            height: width * 0.04,
                          ),

                          // SizedBox(
                          //   height: width * 0.04,
                          // ),
                          CustomTextFormField(
                            controller: emailText,
                            hint: "Email",
                            errorText: "Enter a valid email",
                            input: TextInputType.text,
                            icon: (Icons.email),
                            // obscureText: !state.isPasswordVisible,
                            onChanged: (value) {
                              context
                                  .read<SignupBloc>()
                                  .add(PasswordChanged(value));
                            },
                            condition: (value) => value.length < 4,
                          ),

                          SizedBox(
                            height: width * 0.04,
                          ),
                          CustomTextFormField(
                            controller: passText,
                            hint: "Password",
                            errorText: "Enter a valid password",
                            input: TextInputType.text,
                            icon: (Icons.lock),
                            obscureText: !_passwordVisible,
                            // obscureText: !state.isPasswordVisible,

                            condition: (value) => value.length < 4,
                            suffixIcon: GestureDetector(
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
                            // obscureText: true, // Hide the password
                            onChanged: (value) {
                              context
                                  .read<SignupBloc>()
                                  .add(PasswordChanged(value));
                            },
                          ),
                          SizedBox(
                            height: width * 0.04,
                          ),
                          CustomTextFormField(
                            controller: confirmPassText,
                            hint: "Confirm Password",
                            errorText: "Passwords do not match",
                            input: TextInputType.text,
                            icon: (Icons.lock),
                            obscureText: !_confirmPasswordVisible,
                            // obscureText: !state.isPasswordVisible,

                            suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
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
                            onChanged: (value) {
                              if (passText.text != value) {
                                // Display error if passwords do not match
                                setState(() {
                                  isPasswordMismatch = true;
                                });
                              } else {
                                setState(() {
                                  isPasswordMismatch = false;
                                });
                              }
                              context
                                  .read<SignupBloc>()
                                  .add(PasswordChanged(value));
                            },
                            condition: (value) =>
                                passText.text !=
                                value, // Validation for mismatch
                          ),

                          isOTPSent
                              ? SizedBox(
                                  height: width * 0.06,
                                )
                              : SizedBox(
                                  height: width * 0.01,
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isOTPSent
                                  ? VerificationCode(
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
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(
                            height: width * 0.06,
                          ),
                          isOTPVerify == true || isOTPSend == true
                              ? Center(
                                  child: LoadingAnimationWidget.progressiveDots(
                                    color: colorBlack,
                                    size: width * 0.12,
                                  ),
                                )
                              : GeneralButton(
                                  isBoarderRadiusLess: true,
                                  Width: width,
                                  onTap: () async {
                                    if (usernameText.text.isNotEmpty &&
                                        mobileText.text.isNotEmpty &&
                                        emailText.text.isNotEmpty &&
                                        passText.text.isNotEmpty &&
                                        confirmPassText.text.isNotEmpty) {
                                      if (!isOTPSent) {
                                        if (passText.text !=
                                            confirmPassText.text) {
                                          showToast("Passwords do not match",
                                              Colors.red);
                                          return; // Stop further execution
                                        }
                                        try {
                                          if (isPhoneNumberValid) {
                                            await sendOTP(
                                              email: emailText.text.trim(),
                                              mobile: mobileText.text.trim(),
                                              mobileCode:
                                              countryCode, // Pass the selected country code
                                            );
                                            setState(() {
                                              isOTPSent =
                                              true; // Update state to show OTP input
                                            });
                                            showToast("OTP sent successfully!",
                                                colorBlack);
                                          } else {
                                            showToast("Please enter a valid mobile number", colorSubTittle);
                                          }
                                        } catch (e) {
                                          showToast("$e", colorSubTittle);
                                        }
                                      } else {
                                        if (otpFromServer != null &&
                                            otpFromServer!.isNotEmpty) {
                                          try {
                                            await verifyOTP(
                                              email: emailText.text.trim(),
                                              otp: otpFromServer!,
                                              password: passText.text.trim(),
                                              name: usernameText.text.trim(),
                                              mobile: mobileText.text.trim(),
                                              mobileCode:
                                                  countryCode, // Pass the selected country code
                                            );
                                            // showToast("Account created successfully!", colorBlack);
                                            // Navigate to the login or home screen
                                          } catch (e) {
                                            showToast("$e", colorSubTittle);
                                          }
                                        } else {
                                          showToast("Please enter the OTP",
                                              colorSubTittle);
                                        }
                                      }
                                    } else {
                                      showToast("Please fill all the fields",
                                          colorSubTittle);
                                    }
                                  },
                                  label: isOTPSent
                                      ? "Verify & Signup"
                                      : "Send OTP At Email",
                                ),

                          SizedBox(
                            height: height * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              WantText("Already Have An Account?   ",
                                  width * 0.035, FontWeight.w500, colorBlack),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
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
                          SizedBox(
                            height: width * 0.06,
                          ),
                        ],
                      )),
                ],
              )),
            ),
          ),
        );
      }),
    );
  }
}
