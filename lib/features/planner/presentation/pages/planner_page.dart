import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/constants.dart';
import '../../../../core/utils/date_helpers.dart';

/// 周计划页
class PlannerPage extends ConsumerStatefulWidget {
  const PlannerPage({super.key});

  @override
  ConsumerState<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends ConsumerState<PlannerPage> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = DateHelpers.weekStart(DateTime.now());
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                AppStrings.plannerTitle,
                style: AppTypography.title32,
              ),
            ),

            const SizedBox(height: 16),

            // 周导航
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navButton(Icons.chevron_left, _previousWeek),
                  Text(
                    DateHelpers.formatWeekRange(_weekStart),
                    style: AppTypography.h1_26,
                  ),
                  _navButton(Icons.chevron_right, _nextWeek),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 周网格
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final date = _weekStart.add(Duration(days: dayIndex));
                    final isToday = DateHelpers.isToday(date);

                    return Expanded(
                      child: _DayColumn(
                        date: date,
                        dayIndex: dayIndex,
                        isToday: isToday,
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [AppShadows.card],
        ),
        child: Icon(icon, color: AppColors.primaryText, size: 22),
      ),
    );
  }
}

/// 每一天的列
class _DayColumn extends StatelessWidget {
  final DateTime date;
  final int dayIndex;
  final bool isToday;

  const _DayColumn({
    required this.date,
    required this.dayIndex,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          // 星期标签
          Text(
            weekdayLabels[dayIndex],
            style: AppTypography.caption14.copyWith(
              color: isToday ? AppColors.navSelected : AppColors.secondaryText,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),

          // 日期数字
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isToday ? AppColors.navSelected : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: AppTypography.caption14.copyWith(
                color: isToday ? AppColors.white : AppColors.primaryText,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 占位内容区
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.divider,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
