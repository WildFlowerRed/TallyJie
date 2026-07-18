import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_theme.dart';

/// 胶囊顶部导航 — 4 Tab
class CapsuleNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CapsuleNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _tabs = [
    _Tab(Icons.menu_book_outlined, '日记'),
    _Tab(Icons.edit_note, '记账'),
    _Tab(Icons.pie_chart_outline, '统计'),
    _Tab(Icons.settings_outlined, '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Center(
            child: Container(
              height: 58,
              constraints: const BoxConstraints(maxWidth: 560),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(29),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.72),
                ),
                boxShadow: const [AppShadows.nav],
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final sel = selectedIndex == i;
                  return Expanded(
                    child: _NavItem(
                      tab: _tabs[i],
                      selected: sel,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final String label;
  const _Tab(this.icon, this.label);
}

class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.92,
        duration: AppDurations.short,
        curve: AppTheme.easeOutQuart,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: AppTheme.easeOutQuart,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.navSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(21),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab.icon,
                  size: 21,
                  color: selected ? AppColors.navText : AppColors.text,
                ),
                const SizedBox(width: 6),
                AnimatedDefaultTextStyle(
                  duration: AppDurations.short,
                  curve: AppTheme.easeOutQuart,
                  style: AppTypography.navLabel.copyWith(
                    color: selected ? AppColors.navText : AppColors.text,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  child: Text(tab.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
