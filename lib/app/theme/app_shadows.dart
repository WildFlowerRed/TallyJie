import 'package:flutter/widgets.dart';
import 'app_colors.dart';

/// TallyJie 阴影 — 柔和纸片感
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 16,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get nav => [
    BoxShadow(
      color: Color.fromRGBO(
        AppColors.shadowR,
        AppColors.shadowG,
        AppColors.shadowB,
        AppColors.shadowAlpha * 0.72,
      ),
      blurRadius: 12,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const BoxShadow none = BoxShadow(
    color: Color(0x00000000),
    blurRadius: 0,
    offset: Offset.zero,
  );
}
