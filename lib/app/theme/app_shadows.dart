import 'package:flutter/widgets.dart';

/// LifeOS 阴影规范
/// 非常轻的阴影：Blur 12, Opacity 5%
class AppShadows {
  AppShadows._();

  /// 卡片阴影 - 适用于 Card 组件
  static const BoxShadow card = BoxShadow(
    color: Color(0x0D000000), // black 5% opacity
    blurRadius: 12,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  /// 底部导航阴影 - 稍微明显的阴影
  static const BoxShadow nav = BoxShadow(
    color: Color(0x08000000), // black ~3% opacity
    blurRadius: 16,
    offset: Offset(0, -2),
    spreadRadius: 0,
  );

  /// 无阴影
  static const BoxShadow none = BoxShadow(
    color: Color(0x00000000),
    blurRadius: 0,
    offset: Offset.zero,
  );
}
