import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String serifFont = 'DMSerifDisplay';
  static const String sansFont  = 'DMSans';

  static TextStyle heading(double size, {Color color = AppColors.text}) =>
      TextStyle(
        fontFamily: serifFont,
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: -0.03 * size,
      );

  static TextStyle screenTitle({Color color = AppColors.text}) =>
      TextStyle(
        fontFamily: serifFont,
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: -0.8,
        height: 1.0,
      );

  static TextStyle body(double size, {Color? color, FontWeight weight = FontWeight.w400}) =>
      TextStyle(fontFamily: sansFont, fontSize: size, fontWeight: weight, color: color ?? AppColors.text);

  static TextStyle label({Color color = AppColors.textSec, double size = 10, FontWeight weight = FontWeight.w500}) =>
      TextStyle(fontFamily: sansFont, fontSize: size, fontWeight: weight, color: color, letterSpacing: 0.04 * size, height: 1.0);

  static TextStyle caption({Color color = AppColors.textDim, double size = 10}) =>
      TextStyle(fontFamily: sansFont, fontSize: size, color: color);

  static EdgeInsets get sectionLabelPadding => const EdgeInsets.only(bottom: 8);
}
