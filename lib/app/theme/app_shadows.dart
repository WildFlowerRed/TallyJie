import 'package:flutter/widgets.dart';

/// TallyJie 阴影规范 — 极度柔和
class AppShadows {
  AppShadows._();

  /// 卡片阴影: 0 2px 8px rgba(0,0,0,0.04)
  static const BoxShadow card = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  /// 导航栏阴影
  static const BoxShadow nav = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 12,
    offset: Offset(0, -1),
    spreadRadius: 0,
  );

  /// 毛玻璃底部栏阴影
  static const BoxShadow frost = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 16,
    offset: Offset(0, -4),
    spreadRadius: 0,
  );
}
