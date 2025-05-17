import 'dart:ui';

import 'package:dancebuddy/utils/theam_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message, Color backgroundColor) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    backgroundColor: backgroundColor,
    textColor: colorWhite,  // Assuming this is defined in `theam_manager.dart`
    fontSize: 16.0,
  );
}