import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TallyJie 字体
class AppTypography {
  AppTypography._();

  static const TextStyle title = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.3,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.3,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.text, height: 1.6,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.4,
  );
  static const TextStyle amount = TextStyle(
    fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.2, letterSpacing: -0.5,
  );
  static const TextStyle amountLarge = TextStyle(
    fontSize: 48, fontWeight: FontWeight.w300, color: AppColors.text, height: 1.1, letterSpacing: -1,
  );
  static const TextStyle navLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, height: 1.2,
  );

  // 兼容旧引用
  static const TextStyle title32 = title;
  static const TextStyle h1_26 = subtitle;
  static const TextStyle body17 = body;
  static const TextStyle caption14 = caption;
  static const TextStyle amount34 = amount;
  static const TextStyle date42 = TextStyle(
    fontSize: 42, fontWeight: FontWeight.w300, color: AppColors.text, height: 1.1,
  );
}
