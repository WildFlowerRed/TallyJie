import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants.dart';
import '../widgets/life_value_gauge.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/monthly_summary.dart';

/// 统计页面
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        title: Text(AppStrings.statsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 生活值
            const LifeValueGauge(),
            const SizedBox(height: 24),

            // 消费分类
            const CategoryBreakdown(),
            const SizedBox(height: 24),

            // 月度总结
            const MonthlySummary(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
