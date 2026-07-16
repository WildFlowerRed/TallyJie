import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_theme.dart';

/// 胶囊式底部导航栏
class CapsuleNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CapsuleNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _tabs = [
    _NavTab(icon: Icons.edit_note, label: '日记'),
    _NavTab(icon: Icons.calendar_month_outlined, label: '周计划'),
    _NavTab(icon: Icons.checklist_outlined, label: '清单'),
    _NavTab(icon: Icons.receipt_long_outlined, label: '记账'),
    _NavTab(icon: Icons.person_outline, label: '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBg,
        boxShadow: [AppShadows.nav],
      ),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
        top: 8,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_tabs.length, (index) {
            final isSelected = selectedIndex == index;
            return _NavItem(
              tab: _tabs[index],
              isSelected: isSelected,
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;

  const _NavTab({required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.95,
        duration: AppDurations.short,
        curve: AppTheme.easeOutQuart,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: AppTheme.easeOutQuart,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tab.icon,
                size: 20,
                color: isSelected
                    ? AppColors.navSelectedText
                    : AppColors.navUnselectedText,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.0,
                  duration: AppDurations.short,
                  child: Text(
                    tab.label,
                    style: AppTypography.navLabel.copyWith(
                      color: AppColors.navSelectedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
