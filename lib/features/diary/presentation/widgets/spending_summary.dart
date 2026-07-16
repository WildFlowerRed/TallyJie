import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/constants.dart';

/// 今日消费摘要卡片
class SpendingSummary extends ConsumerWidget {
  const SpendingSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual data from provider
    final todayExpense = 68.0;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to ledger tab
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.card,
          boxShadow: const [AppShadows.card],
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.expense,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),

            // 标签
            Text(
              AppStrings.diaryTodaySpending,
              style: AppTypography.body17,
            ),

            const Spacer(),

            // 金额
            Text(
              '¥${todayExpense.toStringAsFixed(0)}',
              style: AppTypography.amount34.copyWith(
                color: AppColors.expense,
              ),
            ),

            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
