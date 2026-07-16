/// TallyJie 动效时间规范
/// 全部 250~350ms，禁止快速动画
class AppDurations {
  AppDurations._();

  /// 按钮缩放反馈 - 250ms
  static const Duration short = Duration(milliseconds: 250);

  /// 页面转场 - 300ms
  static const Duration medium = Duration(milliseconds: 300);

  /// 卡片入场 - 350ms
  static const Duration long = Duration(milliseconds: 350);
}
