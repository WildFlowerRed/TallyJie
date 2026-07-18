import 'package:flutter/widgets.dart';

/// TallyJie 阴影 — 柔和纸片感
class AppShadows {
  AppShadows._();

  static const BoxShadow card = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 16,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  static const BoxShadow nav = BoxShadow(
    color: Color(0x05000000),
    blurRadius: 12,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  static const BoxShadow none = BoxShadow(
    color: Color(0x00000000),
    blurRadius: 0,
    offset: Offset.zero,
  );
}
