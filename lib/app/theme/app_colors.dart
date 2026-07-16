import 'package:flutter/material.dart';

/// TallyJie 配色系统 — 莫兰迪色系
/// 设计关键词: 低饱和度、柔和、克制、温暖
class AppColors {
  AppColors._();

  // 背景色
  static const Color primaryBg = Color(0xFFF8F8F8); // 极浅灰
  static const Color card = Color(0xFFFFFFFF); // 纯白卡片
  static const Color secondaryBg = Color(0xFFF2F2F2); // 浅灰底

  // 文字色
  static const Color primaryText = Color(0xFF2B2B2B);
  static const Color secondaryText = Color(0xFF9CA3AF);

  // 分割线 / 边框
  static const Color divider = Color(0xFFF0F0F0);

  // 莫兰迪功能色
  static const Color sageGreen = Color(0xFFA3B89B); // 豆沙绿 — 消费/收入
  static const Color dustyBlue = Color(0xFF7B9EBF); // 雾霾蓝 — 运动
  static const Color dustyRose = Color(0xFFD4B5BE); // 浅藕粉 — 小幸运
  static const Color warmBeige = Color(0xFFC4A882); // 暖驼色 — 小进步
  static const Color accent = Color(0xFF8E9DAE); // 莫兰迪蓝灰 — 通用强调

  // 功能色（保留原有语义）
  static const Color success = Color(0xFFA3B89B);
  static const Color expense = Color(0xFFC96C5C);
  static const Color income = Color(0xFFA3B89B);

  // 导航胶囊
  static const Color navSelected = Color(0xFF2B2B2B);
  static const Color navUnselectedText = Color(0xFF9CA3AF);
  static const Color navSelectedText = Colors.white;
  static const Color white = Colors.white;

  // 快捷入口背景
  static const Color luckyBg = Color(0xFFFBF0F2); // 浅藕粉底
  static const Color progressBg = Color(0xFFF5F0E8); // 浅驼色底
}
