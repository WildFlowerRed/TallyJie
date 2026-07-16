import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/date_helpers.dart';

/// 日记页头部 — 大日期 + 周数仪式感
class DiaryHeader extends StatelessWidget {
  final DateTime date;
  final String? weather;
  final int? mood;
  final int weekNumber;
  final ValueChanged<String> onWeatherChanged;
  final ValueChanged<int> onMoodChanged;

  const DiaryHeader({
    super.key,
    required this.date,
    this.weather,
    this.mood,
    this.weekNumber = 30,
    required this.onWeatherChanged,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          // 第一行：时间 + 电量（左）  |  今日标签（右）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeRow(),
              _buildTodayTag(),
            ],
          ),

          const SizedBox(height: 20),

          // 第二行：大号日期
          Center(
            child: Text(
              '${date.year}年${date.month}月${date.day}日 ${DateHelpers.weekdayName(date)}',
              style: AppTypography.title32.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // 第三行：周数仪式感副标题
          Center(
            child: Text(
              '第$weekNumber周 · 年中冲刺',
              style: AppTypography.caption14.copyWith(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 第四行：心情 + 天气
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showMoodPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mood != null ? _moods[mood!] : '😊',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mood != null ? _moodLabels[mood!] : '开心',
                        style: AppTypography.caption14.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showWeatherPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        weather != null ? _weatherIcons[weather]! : '☀️',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        weather != null ? _weatherLabels[weather]! : '晴',
                        style: AppTypography.caption14.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return Text(
      '$hour:$minute',
      style: AppTypography.body17.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildTodayTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navSelected,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '今日',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.card,
        ),
      ),
    );
  }

  static const _moods = ['😫', '😟', '😐', '😊', '😄'];
  static const _moodLabels = ['糟糕', '不好', '一般', '开心', '超棒'];

  static const _weatherIcons = {
    'sunny': '☀️', 'cloudy': '⛅', 'rainy': '🌧️', 'snowy': '❄️', 'windy': '💨'
  };
  static const _weatherLabels = {
    'sunny': '晴', 'cloudy': '多云', 'rainy': '雨', 'snowy': '雪', 'windy': '风'
  };

  void _showMoodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('今天心情如何？', style: AppTypography.h1_26),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_moods.length, (i) => GestureDetector(
                onTap: () {
                  onMoodChanged(i);
                  Navigator.pop(ctx);
                },
                child: Column(
                  children: [
                    Text(_moods[i], style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 4),
                    Text(_moodLabels[i], style: AppTypography.caption14),
                  ],
                ),
              )),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showWeatherPicker(BuildContext context) {
    final entries = _weatherIcons.entries.toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('今天天气如何？', style: AppTypography.h1_26),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: entries.map((e) => GestureDetector(
                onTap: () {
                  onWeatherChanged(e.key);
                  Navigator.pop(ctx);
                },
                child: Column(
                  children: [
                    Text(e.value, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 4),
                    Text(_weatherLabels[e.key]!, style: AppTypography.caption14),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
