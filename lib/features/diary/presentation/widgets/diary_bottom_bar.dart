import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_shadows.dart';

/// 底部毛玻璃双按钮栏
class DiaryBottomBar extends StatelessWidget {
  final VoidCallback onPreview;
  final VoidCallback onCalendar;

  const DiaryBottomBar({
    super.key,
    required this.onPreview,
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.85),
        boxShadow: const [AppShadows.frost],
        border: Border(
          top: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // 预览日记
              Expanded(
                child: GestureDetector(
                  onTap: onPreview,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.primaryText,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '预览日记',
                          style: AppTypography.body17.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 日记日历
              Expanded(
                child: GestureDetector(
                  onTap: onCalendar,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.navSelected,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 18,
                          color: AppColors.card,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '日记',
                          style: AppTypography.body17.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.card,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
