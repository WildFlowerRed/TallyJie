import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_theme.dart';

/// 胶囊顶部导航 — 3 Tab + 设置入口
class CapsuleNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final VoidCallback onSettingsTap;

  const CapsuleNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.onSettingsTap,
  });

  static const _tabs = [
    _Tab(Icons.menu_book_outlined, '日记'),
    _Tab(Icons.edit_note, '记账'),
    _Tab(Icons.pie_chart_outline, '统计'),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppColors.themeVersion,
      builder: (context, themeVersion, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.navBg.withValues(alpha: 0.72),
                AppColors.navBg,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 14),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _SettingsButton(onTap: onSettingsTap),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Container(
                      height: 74,
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(37),
                        border: Border.all(
                          color: AppColors.borderDivider.withValues(
                            alpha: 0.72,
                          ),
                        ),
                        boxShadow: AppShadows.nav,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: 1,
        duration: AppDurations.short,
        curve: AppTheme.easeOutQuart,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            Icons.settings_outlined,
            size: 30,
            color: AppColors.navUnselected,
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
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.navSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab.icon,
                  size: 27,
                  color: selected ? AppColors.navText : AppColors.text,
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: AppDurations.short,
                  curve: AppTheme.easeOutQuart,
                  style: AppTypography.navLabel.copyWith(
                    color: selected ? AppColors.navText : AppColors.text,
                    fontSize: 19,
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
