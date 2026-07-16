import 'package:flutter/widgets.dart';

/// TallyJie 圆角 — 大圆角卡片风格
class AppRadius {
  AppRadius._();

  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(24));
  static const BorderRadius capsule = BorderRadius.all(Radius.circular(20));
  static const BorderRadius sheet = BorderRadius.vertical(top: Radius.circular(24));

  // 兼容旧引用
  static const BorderRadius card = lg;
  static const BorderRadius tag = capsule;
  static const BorderRadius input = md;
}
