import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TallyJie 字体规范
class AppTypography {
  AppTypography._();

  /// 标题 - 32 SemiBold
  static const TextStyle title32 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.2,
  );

  /// 一级标题 - 26 Medium
  static const TextStyle h1_26 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    height: 1.3,
  );

  /// 正文 - 17 Regular
  static const TextStyle body17 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    height: 1.5,
  );

  /// 辅助文字 - 14 Regular
  static const TextStyle caption14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  /// 金额 - 34 Bold
  static const TextStyle amount34 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// 日期 - 42 Light
  static const TextStyle date42 = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryText,
    height: 1.1,
    letterSpacing: -1.0,
  );

  /// 超大金额（输入用）
  static const TextStyle amountInput = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryText,
    height: 1.2,
    letterSpacing: -1.5,
  );

  /// 导航栏文字 - 12 Medium
  static const TextStyle navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}
