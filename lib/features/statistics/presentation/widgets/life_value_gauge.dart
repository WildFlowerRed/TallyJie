import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/constants.dart';

/// 生活值圆形仪表盘
class LifeValueGauge extends StatelessWidget {
  const LifeValueGauge({super.key});

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
        children: [
          // 标题
          Text(
            '本月 ${AppStrings.statsLifeValue}',
            style: AppTypography.h1_26,
          ),
          const SizedBox(height: 24),

          // 进度环
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景环
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    backgroundColor: AppColors.secondaryBg,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.secondaryBg,
                    ),
                  ),
                ),
                // 进度环
                SizedBox(
                  width: 150,
                  height: 150,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 0.78),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent,
                        ),
                      );
                    },
                  ),
                ),
                // 中心文字
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '78%',
                      style: AppTypography.amount34.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      '生活值',
                      style: AppTypography.caption14,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 进度条说明
          _buildMetricRow('日记连续', 0.85),
          const SizedBox(height: 8),
          _buildMetricRow('任务完成', 0.72),
          const SizedBox(height: 8),
          _buildMetricRow('预算健康', 0.80),
          const SizedBox(height: 8),
          _buildMetricRow('心情均值', 0.75),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, double value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTypography.caption14,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.secondaryBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: AppTypography.caption14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
