import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_theme.dart';

/// 胶囊底部导航 — 4 Tab
class CapsuleNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CapsuleNavBar({super.key, required this.selectedIndex, required this.onTap});

  static const _tabs = [
    _Tab(Icons.menu_book_outlined, '日记'),
    _Tab(Icons.edit_note, '记账'),
    _Tab(Icons.pie_chart_outline, '统计'),
    _Tab(Icons.settings_outlined, '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        boxShadow: [AppShadows.nav],
      ),
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_tabs.length, (i) {
            final sel = selectedIndex == i;
            return _NavItem(tab: _tabs[i], selected: sel, onTap: () => onTap(i));
          }),
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

  const _NavItem({required this.tab, required this.selected, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.navSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 20, color: selected ? AppColors.navText : AppColors.navUnselected),
              if (selected) ...[
                const SizedBox(width: 5),
                AnimatedOpacity(
                  opacity: selected ? 1.0 : 0.0,
                  duration: AppDurations.short,
                  child: Text(tab.label, style: AppTypography.navLabel.copyWith(
                    color: AppColors.navText, fontWeight: FontWeight.w600,
                  )),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
