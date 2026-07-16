import 'package:intl/intl.dart';

/// 货币格式化工具
class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _formatter = NumberFormat('#,##0.00');

  /// 格式化为人民币显示: "¥1,234.56"
  static String format(double amount) {
    return '¥${_formatter.format(amount)}';
  }

  /// 格式化为支出显示: "-¥42.50"
  static String formatExpense(double amount) {
    return '-${format(amount)}';
  }

  /// 格式化为收入显示: "+¥42.50"
  static String formatIncome(double amount) {
    return '+${format(amount)}';
  }

  /// 仅格式化数字部分: "1,234.56"
  static String formatAmount(double amount) {
    return _formatter.format(amount);
  }
}
