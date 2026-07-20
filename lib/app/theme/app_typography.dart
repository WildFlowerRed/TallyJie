import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font_family.dart';

/// TallyJie 字体
class AppTypography {
  AppTypography._();

  static TextStyle get title => TextStyle(
    fontSize: 24,
    fontFamily: AppFontFamily.currentFamily,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.3,
  );
  static TextStyle get subtitle => TextStyle(
    fontSize: 18,
    fontFamily: AppFontFamily.currentFamily,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.3,
  );
  static TextStyle get body => TextStyle(
    fontSize: 16,
    fontFamily: AppFontFamily.currentFamily,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.6,
  );
  static TextStyle get caption => TextStyle(
    fontSize: 13,
    fontFamily: AppFontFamily.currentFamily,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  static TextStyle get amount => TextStyle(
    fontSize: 36,
    fontFamily: AppFontFamily.currentFamily,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.2,
    letterSpacing: -0.5,
  );
  static TextStyle get amountLarge => TextStyle(
    fontSize: 48,
    fontFamily: AppFontFamily.currentFamily,
    fontWeight: FontWeight.w300,
    color: AppColors.text,
    height: 1.1,
    letterSpacing: -1,
  );
  static TextStyle get navLabel => TextStyle(
    fontSize: 11,
    fontFamily: AppFontFamily.currentFamily,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // 兼容旧引用
  static TextStyle get title32 => title;
  static TextStyle get h1_26 => subtitle;
  static TextStyle get body17 => body;
  static TextStyle get caption14 => caption;
  static TextStyle get amount34 => amount;
  static TextStyle get date42 => TextStyle(
    fontSize: 42,
    fontFamily: AppFontFamily.currentFamily,
    fontWeight: FontWeight.w300,
    color: AppColors.text,
    height: 1.1,
  );
}
