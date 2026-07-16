import 'package:flutter/widgets.dart';

/// TallyJie 圆角规范 — 统一 12px
class AppRadius {
  AppRadius._();

  /// 通用卡片圆角
  static const BorderRadius card = BorderRadius.all(Radius.circular(12));

  /// 标签 / 徽章
  static const BorderRadius tag = BorderRadius.all(Radius.circular(12));

  /// 输入框
  static const BorderRadius input = BorderRadius.all(Radius.circular(12));

  /// Bottom Sheet
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(12),
  );

  /// 胶囊按钮
  static const BorderRadius capsule = BorderRadius.all(Radius.circular(20));
}
