import 'package:flutter/material.dart';

/// TallyJie 配色 — 奶油白 + 低饱和主题色
/// 参考: Notion, Apple Journal, iOS 原生
class AppColors {
  AppColors._();

  // 背景
  static const Color bg = Color(0xFFFAF8F5);      // 奶油白
  static const Color card = Color(0xFFFFFFFF);      // 纯白卡片
  static const Color surface = Color(0xFFF5F3F0);   // 浅灰底

  // 文字
  static const Color text = Color(0xFF1C1C1E);      // 主文字
  static const Color textSecondary = Color(0xFF8E8E93); // 次文字
  static const Color textHint = Color(0xFFC7C7CC);  // 占位文字

  // 分割线
  static const Color divider = Color(0xFFE5E5EA);

  // 主题色
  static const Color accent = Color(0xFF5E7A6B);    // 深豆沙绿
  static const Color accentLight = Color(0xFFE8F0EB);

  // 收支
  static const Color income = Color(0xFF5E7A6B);    // 收入绿
  static const Color expense = Color(0xFFD4786E);   // 支出橙红

  // 导航
  static const Color navSelected = Color(0xFF1C1C1E);
  static const Color navUnselected = Color(0xFF8E8E93);
  static const Color navText = Color(0xFFFFFFFF);

  // 莫兰迪标签色
  static const Color tagPink = Color(0xFFF0E5E8);     // 浅藕粉
  static const Color tagBlue = Color(0xFFE5ECF3);     // 浅雾蓝
  static const Color tagWarm = Color(0xFFF3EFE5);     // 浅暖驼
  static const Color tagGreen = Color(0xFFE8F0EB);    // 浅豆沙绿

  static const Color white = Colors.white;
  static const Color success = Color(0xFF5E7A6B);
}
