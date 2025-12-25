import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trailo/utility/app_colors.dart';

class CustomFlushbar {
  static void flushBarErrorMessage(
    String title,
    String message,
    BuildContext context,
  ) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        flushbarPosition: FlushbarPosition.TOP,
        padding: EdgeInsets.all(15),
        forwardAnimationCurve: Curves.decelerate,
        message: message,
        title: title,
        reverseAnimationCurve: Curves.easeInOut,
        duration: Duration(seconds: 3),
        backgroundColor: AppColors.error,
        positionOffset: 20.0,
        borderRadius: BorderRadius.circular(10),
        icon: Icon(Icons.error, size: 28, color: Colors.white),
      )..show(context),
    );
  }

  static void flushBarSuccessMessage(
    String title,
    String message,
    BuildContext context,
  ) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        flushbarPosition: FlushbarPosition.TOP,
        padding: EdgeInsets.all(15),
        forwardAnimationCurve: Curves.decelerate,
        title: title,
        message: message,
        reverseAnimationCurve: Curves.easeInOut,
        duration: Duration(seconds: 3),
        backgroundColor: AppColors.success,
        positionOffset: 20.0,
        borderRadius: BorderRadius.circular(10),
        icon: Icon(Icons.check_circle, size: 28, color: Colors.white),
      )..show(context),
    );
  }
}
