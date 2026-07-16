import 'package:intl/intl.dart';

/// 日期工具类
class DateHelpers {
  DateHelpers._();

  static const _weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  /// 格式化日期为 "7月16日"
  static String formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  /// 格式化日期为 "今天" / "昨天" / "7月16日"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    return formatDate(date);
  }

  /// 获取星期几的中文名称
  static String weekdayName(DateTime date) {
    // DateTime.weekday: 1=Mon, 7=Sun
    return _weekdayNames[date.weekday - 1];
  }

  /// 格式化完整日期头: "2026.7.16"
  static String formatFullDate(DateTime date) {
    return '${date.year}.${date.month}.${date.day}';
  }

  /// 格式化时间: "09:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// 获取今天的日期 (不含时间)
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 获取本周一的日期
  static DateTime weekStart(DateTime date) {
    final weekday = date.weekday; // 1=Mon
    return DateTime(date.year, date.month, date.day - weekday + 1);
  }

  /// 获取本周日的日期
  static DateTime weekEnd(DateTime date) {
    final start = weekStart(date);
    return start.add(const Duration(days: 6));
  }

  /// 判断两个日期是否为同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 判断是否为今天
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// 格式化周范围: "7月13日 - 7月19日"
  static String formatWeekRange(DateTime weekStartDate) {
    final end = weekEnd(weekStartDate);
    return '${weekStartDate.month}月${weekStartDate.day}日 - ${end.month}月${end.day}日';
  }

  /// 获取月的第一天
  static DateTime monthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 获取月的最后一天
  static DateTime monthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// 格式化月份: "2026年7月"
  static String formatMonth(DateTime date) {
    return '${date.year}年${date.month}月';
  }
}
