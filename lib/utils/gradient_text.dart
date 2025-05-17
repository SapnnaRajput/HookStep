import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientText extends StatelessWidget {
  final String text;final double fontSize;final FontWeight fontWeight;


  GradientText(this.text,this.fontSize,this.fontWeight);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Color(0xFF000000), // Instagram gradient colors
            Color(0xFF000000),
            Color(0xFF000000),
            Color(0xFF000000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: Text(
        text,
        style: GoogleFonts.dmSans(color: Colors.white,fontSize: fontSize,fontWeight:fontWeight,), // Set default text color as white
      ),
    );
  }
}