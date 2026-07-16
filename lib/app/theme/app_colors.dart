import 'package:flutter/material.dart';

/// LifeOS 配色系统
/// 设计关键词: Minimal, Paper, Warm, Soft, Nature, Notebook, Diary
class AppColors {
  AppColors._();

  // 背景色
  static const Color primaryBg = Color(0xFFF7F3EE);
  static const Color card = Color(0xFFFFFDFB);
  static const Color secondaryBg = Color(0xFFF3EEE8);

  // 文字色
  static const Color primaryText = Color(0xFF2B2B2B);
  static const Color secondaryText = Color(0xFF757575);

  // 分割线 / 边框
  static const Color divider = Color(0xFFE8E1D8);

  // 强调色
  static const Color accent = Color(0xFF8E7C66);

  // 功能色
  static const Color success = Color(0xFF86B66E);
  static const Color expense = Color(0xFFC96C5C);
  static const Color income = Color(0xFF6B9D78);

  // 导航胶囊
  static const Color navSelected = Color(0xFF2B2B2B);
  static const Color navUnselectedText = Color(0xFF757575);
  static const Color navSelectedText = Colors.white;

  // 白色
  static const Color white = Colors.white;
  static const Color black = Color(0xFF2B2B2B);

  // 分类颜色
  static const List<Color> categoryColors = [
    Color(0xFFE8B4A2), // 餐饮 - warm coral
    Color(0xFFA2C4D9), // 交通 - soft blue
    Color(0xFFC4D4A2), // 购物 - sage green
    Color(0xFFD4A2C4), // 娱乐 - soft purple
    Color(0xFFA2D4C4), // 学习 - mint
    Color(0xFFD4C4A2), // 医疗 - warm yellow
    Color(0xFFB4A2D4), // 住房 - lavender
    Color(0xFFA2D4B4), // 收入 - light green
  ];
}
