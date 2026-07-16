import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';

/// 四宫格数据快捷卡片
class DiaryGridCards extends StatelessWidget {
  final double todayExpense;
  final int exerciseMinutes;
  final String luckyThing;
  final String progress;
  final VoidCallback onExpenseTap;
  final VoidCallback onExerciseTap;
  final VoidCallback onLuckyTap;
  final VoidCallback onProgressTap;

  const DiaryGridCards({
    super.key,
    this.todayExpense = 0,
    this.exerciseMinutes = 0,
    this.luckyThing = '',
    this.progress = '',
    required this.onExpenseTap,
    required this.onExerciseTap,
    required this.onLuckyTap,
    required this.onProgressTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _GridCard(
                  icon: Icons.receipt_long_outlined,
                  label: '今日消费',
                  value: '¥${todayExpense.toStringAsFixed(0)}',
                  color: AppColors.sageGreen,
                  onTap: onExpenseTap,
                ),
                const SizedBox(height: 10),
                _GridCard(
                  icon: Icons.auto_awesome_outlined,
                  label: '今日小幸运',
                  value: luckyThing.isNotEmpty ? luckyThing : '记录一件小事',
                  color: AppColors.dustyRose,
                  isText: luckyThing.isNotEmpty,
                  onTap: onLuckyTap,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _GridCard(
                  icon: Icons.directions_run_outlined,
                  label: '今日运动',
                  value: '$exerciseMinutes 分钟',
                  color: AppColors.dustyBlue,
                  onTap: onExerciseTap,
                ),
                const SizedBox(height: 10),
                _GridCard(
                  icon: Icons.trending_up_outlined,
                  label: '今日小进步',
                  value: progress.isNotEmpty ? progress : '记录一点成长',
                  color: AppColors.warmBeige,
                  isText: progress.isNotEmpty,
                  onTap: onProgressTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isText;
  final VoidCallback onTap;

  const _GridCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isText = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.card,
          boxShadow: const [AppShadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),

            // 标签
            Text(
              label,
              style: AppTypography.caption14.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 4),

            // 数值
            Flexible(
              child: Text(
                value,
                style: isText
                    ? AppTypography.caption14.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                        height: 1.3,
                      )
                    : AppTypography.amount34.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
