import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_durations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/utils/date_helpers.dart';

/// 单条交易记录 Tile
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;
    final prefix = isExpense ? '-' : '+';

    return Dismissible(
      key: Key('txn_${transaction.id ?? transaction.timestamp.millisecondsSinceEpoch}'),
      onDismissed: (_) => onDelete?.call(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.1),
          borderRadius: AppRadius.card,
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.expense),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.short,
          curve: AppTheme.easeOutQuart,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.card,
            boxShadow: const [AppShadows.card],
          ),
          child: Row(
            children: [
              // 分类图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  transaction.categoryIcon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 14),

              // 标题和备注
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.note ?? transaction.category,
                      style: AppTypography.body17,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          transaction.category,
                          style: AppTypography.caption14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateHelpers.formatTime(transaction.timestamp),
                          style: AppTypography.caption14.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 金额
              Text(
                '$prefix¥${transaction.amount.toStringAsFixed(2)}',
                style: AppTypography.amount34.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
