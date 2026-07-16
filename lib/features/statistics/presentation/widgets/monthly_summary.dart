import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';

/// 月度总结卡片 - 温暖的文字总结
class MonthlySummary extends StatelessWidget {
  const MonthlySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 引用符号
          Text(
            '"',
            style: AppTypography.date42.copyWith(
              color: AppColors.accent,
              height: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // 总结文字
          Text(
            '这个月奶茶喝得有点多。\n不过每天都有在认真学习，\n生活节奏保持得还不错。\n下个月继续加油 ✨',
            style: AppTypography.body17.copyWith(
              height: 1.8,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: 16),

          // 底部装饰
          Row(
            children: [
              Container(
                width: 32,
                height: 2,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'TallyJie · 月度总结',
                style: AppTypography.caption14.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
