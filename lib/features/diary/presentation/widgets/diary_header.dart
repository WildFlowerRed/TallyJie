import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/constants.dart';
import '../../../../core/utils/date_helpers.dart';

/// 日记页头部 - 日期、星期、心情、天气
class DiaryHeader extends StatelessWidget {
  final DateTime date;
  final String? weather;
  final int? mood;
  final ValueChanged<String> onWeatherChanged;
  final ValueChanged<int> onMoodChanged;

  const DiaryHeader({
    super.key,
    required this.date,
    this.weather,
    this.mood,
    required this.onWeatherChanged,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "今天"
          Text(
            AppStrings.diaryToday,
            style: AppTypography.caption14.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),

          // 日期行
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 大号日期
              Text(
                '${date.day}',
                style: AppTypography.date42,
              ),
              const SizedBox(width: 8),

              // 星期 + 日期
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateHelpers.weekdayName(date),
                      style: AppTypography.body17.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      DateHelpers.formatFullDate(date),
                      style: AppTypography.caption14,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 心情 & 天气
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    // 心情
                    GestureDetector(
                      onTap: () => _showMoodPicker(context),
                      child: Text(
                        mood != null
                            ? AppStrings.moods[mood!]
                            : '😊',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 天气
                    GestureDetector(
                      onTap: () => _showWeatherPicker(context),
                      child: Text(
                        weather != null
                            ? (AppStrings.weathers[weather] ?? '☀️')
                            : '☀️',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMoodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '今天心情如何？',
                style: AppTypography.h1_26,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  AppStrings.moods.length,
                  (index) => GestureDetector(
                    onTap: () {
                      onMoodChanged(index);
                      Navigator.pop(context);
                    },
                    child: AnimatedScale(
                      scale: mood == index ? 1.3 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        AppStrings.moods[index],
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showWeatherPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final weatherEntries = AppStrings.weathers.entries.toList();
        return Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '今天天气如何？',
                style: AppTypography.h1_26,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: weatherEntries.map((entry) {
                  final isSelected = weather == entry.key;
                  return GestureDetector(
                    onTap: () {
                      onWeatherChanged(entry.key);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondaryBg
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: AppColors.accent, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
