import 'package:flutter/widgets.dart';

/// LifeOS 圆角规范
/// 整个 App 只允许四种圆角
class AppRadius {
  AppRadius._();

  /// Tag 标签 - 8
  static const BorderRadius tag = BorderRadius.all(Radius.circular(8));

  /// 输入框 - 16
  static const BorderRadius input = BorderRadius.all(Radius.circular(16));

  /// Card 卡片 - 20
  static const BorderRadius card = BorderRadius.all(Radius.circular(20));

  /// Bottom Sheet - 28
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(28),
  );
}
