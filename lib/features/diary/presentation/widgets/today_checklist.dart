import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_durations.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/todo_item.dart';

/// 今日完成清单
class TodayChecklist extends StatefulWidget {
  const TodayChecklist({super.key});

  @override
  State<TodayChecklist> createState() => _TodayChecklistState();
}

class _TodayChecklistState extends State<TodayChecklist> {
  final List<TodoItem> _items = [
    TodoItem(title: '学习'),
    TodoItem(title: '运动'),
    TodoItem(title: '阅读'),
    TodoItem(title: '记账'),
    TodoItem(title: '冥想'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _items.length - 1;

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _items[index] = item.copyWith(
                      isCompleted: !item.isCompleted,
                      completedAt: item.isCompleted ? null : DateTime.now(),
                    );
                  });
                },
                child: AnimatedContainer(
                  duration: AppDurations.short,
                  curve: AppTheme.easeOutQuart,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      // 勾选框
                      AnimatedContainer(
                        duration: AppDurations.short,
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: item.isCompleted
                              ? AppColors.success
                              : Colors.transparent,
                          border: Border.all(
                            color: item.isCompleted
                                ? AppColors.success
                                : AppColors.divider,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: item.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),

                      // 文字
                      Expanded(
                        child: Text(
                          item.isCompleted ? '✓ ${item.title}' : '○ ${item.title}',
                          style: AppTypography.body17.copyWith(
                            color: item.isCompleted
                                ? AppColors.success
                                : AppColors.primaryText,
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: item.isCompleted
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(left: 36),
                  child: Divider(
                    height: 1,
                    color: AppColors.divider,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
