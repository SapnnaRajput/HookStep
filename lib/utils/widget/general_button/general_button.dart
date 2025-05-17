import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theam_manager.dart';

class GeneralButton extends StatelessWidget {
  const GeneralButton(
      {Key? key,
        required this.Width,
        required this.onTap,
        this.isSelected = false,this.isBoarderRadiusLess=false,
        required this.label})
      : super(key: key);

  final double Width;
  final Function()? onTap;
  final String label;
  final bool isSelected;final bool isBoarderRadiusLess;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height * 0.055,
        width: Width,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.withOpacity(0.4) : colorBlack,
            borderRadius: BorderRadius.circular(isBoarderRadiusLess?width * 0.03:width * 0.1333),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                  fontSize: width * 0.045,
                  color: colorWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
