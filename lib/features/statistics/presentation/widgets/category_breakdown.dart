import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/constants.dart';

/// 消费分类占比
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key});

  static const _data = [
    {'icon': '🍜', 'name': '餐饮', 'percentage': 0.42, 'color': Color(0xFFE8B4A2)},
    {'icon': '🛒', 'name': '购物', 'percentage': 0.30, 'color': Color(0xFFC4D4A2)},
    {'icon': '🚗', 'name': '交通', 'percentage': 0.10, 'color': Color(0xFFA2C4D9)},
    {'icon': '🎮', 'name': '娱乐', 'percentage': 0.08, 'color': Color(0xFFD4A2C4)},
    {'icon': '📚', 'name': '学习', 'percentage': 0.05, 'color': Color(0xFFA2D4C4)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.statsCategoryBreakdown,
            style: AppTypography.h1_26,
          ),
          const SizedBox(height: 20),

          // 条形图
          ..._data.map((item) {
            final percentage = item['percentage']! as double;
            final color = item['color']! as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标签行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(item['icon'] as String,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(item['name'] as String,
                              style: AppTypography.body17),
                        ],
                      ),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: AppTypography.body17.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 进度条
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: percentage),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: AppColors.secondaryBg,
                          valueColor: AlwaysStoppedAnimation(color),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
