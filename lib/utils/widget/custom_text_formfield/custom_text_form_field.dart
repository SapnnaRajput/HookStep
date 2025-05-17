import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theam_manager.dart';
import 'custom_text_formfield_bloc/custom_container_bloc.dart';
import 'custom_text_formfield_bloc/custom_container_event.dart';
import 'custom_text_formfield_bloc/custom_container_state.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType input;
  final IconData icon;  final bool obscureText;
  final bool Function(String) condition;
  final String errorText;
  final Function(String) onChanged;
  final double? fontSize;
  final Widget? suffixIcon;
  final Function(bool)? onSuffixIconPressed;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool readOnly; // New readOnly parameter

  CustomTextFormField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.input,
    required this.icon,
    required this.condition,
    required this.errorText,
    this.fontSize,  this.obscureText = false,
    this.suffixIcon,
    this.onSuffixIconPressed,
    required this.onChanged,
    this.enabled = true,
    this.readOnly = false, // Default to false
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) =>
          FormFieldBloc(validator: condition, errorMessage: errorText),
      child: BlocBuilder<FormFieldBloc, FormFieldBlocState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height * 0.06,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(width * 0.02)),
                  border: Border.all(color: colorGrey),
                  image: DecorationImage(
                    opacity: 0.6,
                    image: AssetImage("assets/images/textFormFieldBG.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: TextFormField(obscureText: obscureText,
                  inputFormatters: inputFormatters ?? [],
                  onChanged: readOnly
                      ? null // Disable onChanged if read-only
                      : (value) {
                    onChanged(value);
                    context
                        .read<FormFieldBloc>()
                        .add(FormFieldChanged(value: value));
                  },
                  style: GoogleFonts.dmSans(
                    textStyle: TextStyle(
                      fontSize: fontSize != null ? fontSize : width * 0.04,
                      color: enabled
                          ? colorBlack
                          : colorGrey, // Dim text color if disabled
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  cursorColor: readOnly ? Colors.transparent : colorMainTheme,
                  controller: controller,
                  keyboardType: input,
                  enabled: enabled, // Allows toggling full disable
                  readOnly: readOnly, // New property to toggle read-only mode
                  decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: 0),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    hintText: hint,
                    hintStyle: GoogleFonts.dmSans(
                      textStyle: TextStyle(
                        fontSize: height * 0.01566,
                        fontWeight: FontWeight.w400,
                        color: colorGrey,
                      ),
                    ),
                    prefixIcon: Icon(
                      icon,
                      size: width * 0.05,
                      color: colorBlack,
                    ),
                    suffixIcon: suffixIcon,
                  ),
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: EdgeInsets.only(top: width * 0.02, left: width * 0.01),
                  child: Text(
                    state.error!,
                    style: GoogleFonts.dmSans(
                      textStyle:
                      TextStyle(color: colorSubTittle, fontSize: width * 0.035),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}