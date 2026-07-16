import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/constants.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_helpers.dart';
import 'transaction_tile.dart';

/// 交易时间轴 - 按上午/下午/晚上分组
class TransactionTimeline extends StatefulWidget {
  const TransactionTimeline({super.key});

  @override
  State<TransactionTimeline> createState() => _TransactionTimelineState();
}

class _TransactionTimelineState extends State<TransactionTimeline> {
  // 模拟数据
  final List<Transaction> _transactions = [
    Transaction(
      amount: 18,
      type: TransactionType.expense,
      category: '餐饮',
      categoryIcon: '☕',
      note: '瑞幸',
      timestamp: DateTime(2026, 7, 16, 9, 30),
    ),
    Transaction(
      amount: 26,
      type: TransactionType.expense,
      category: '餐饮',
      categoryIcon: '🍜',
      note: '兰州拉面',
      timestamp: DateTime(2026, 7, 16, 14, 0),
    ),
    Transaction(
      amount: 89,
      type: TransactionType.expense,
      category: '购物',
      categoryIcon: '🛒',
      note: '超市',
      timestamp: DateTime(2026, 7, 16, 19, 0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.divider,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.ledgerEmpty,
              style: AppTypography.body17.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.ledgerEmptySubtitle,
              style: AppTypography.caption14,
            ),
          ],
        ),
      );
    }

    // 按日期和时段分组
    final groups = _groupTransactions(_transactions);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _DayGroup(
          dateLabel: group.dateLabel,
          timeLabel: group.timeLabel,
          transactions: group.transactions,
        );
      },
    );
  }

  List<_TransactionGroup> _groupTransactions(List<Transaction> transactions) {
    // 按日期排序（降序）
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final groups = <_TransactionGroup>[];

    for (final txn in sorted) {
      final dateLabel = DateHelpers.formatDate(txn.timestamp);
      final timeLabel = txn.timeOfDayLabel;

      // 查找现有分组或创建新分组
      var group = groups.cast<_TransactionGroup?>().firstWhere(
            (g) => g?.dateLabel == dateLabel && g?.timeLabel == timeLabel,
            orElse: () => null,
          );

      if (group == null) {
        group = _TransactionGroup(
          dateLabel: dateLabel,
          timeLabel: timeLabel,
          transactions: [],
        );
        groups.add(group);
      }

      group.transactions.add(txn);
    }

    return groups;
  }
}

class _TransactionGroup {
  final String dateLabel;
  final String timeLabel;
  final List<Transaction> transactions;

  _TransactionGroup({
    required this.dateLabel,
    required this.timeLabel,
    required this.transactions,
  });
}

class _DayGroup extends StatelessWidget {
  final String dateLabel;
  final String timeLabel;
  final List<Transaction> transactions;

  const _DayGroup({
    required this.dateLabel,
    required this.timeLabel,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = transactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期头部
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              '$dateLabel · $timeLabel',
              style: AppTypography.caption14.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 时间段标签
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              timeLabel,
              style: AppTypography.h1_26.copyWith(
                fontSize: 20,
              ),
            ),
          ),

          // 交易列表
          ...transactions.map((txn) => TransactionTile(transaction: txn)),

          // 时间段合计
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              '小计: ${CurrencyUtils.formatExpense(totalAmount)}',
              style: AppTypography.caption14.copyWith(
                color: AppColors.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
