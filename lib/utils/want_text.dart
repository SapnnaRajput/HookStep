import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WantText extends StatelessWidget { final String text;final double fontSize;final FontWeight fontWeight;final Color textColor;
   WantText(this.text,this.fontSize,this.fontWeight,this.textColor);

  @override
  Widget build(BuildContext context) {
    return Text(overflow: TextOverflow.ellipsis,
      text,
      style: GoogleFonts.dmSans(color: textColor,fontSize: fontSize,fontWeight:fontWeight,), // Set default text color as white
    );
  }
}
