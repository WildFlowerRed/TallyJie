import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_theme.dart';

/// 胶囊顶部导航 — 3 Tab + 设置入口
class CapsuleNavBar extends StatefulWidget {
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
  State<CapsuleNavBar> createState() => _CapsuleNavBarState();
}

class _CapsuleNavBarState extends State<CapsuleNavBar> {
  int _liquidDirection = 1;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant CapsuleNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _lastIndex) {
      _liquidDirection = widget.selectedIndex > _lastIndex ? 1 : -1;
      _lastIndex = widget.selectedIndex;
    }
  }

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
                    child: _SettingsButton(onTap: widget.onSettingsTap),
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth =
                              constraints.maxWidth / CapsuleNavBar._tabs.length;
                          return Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 360),
                                curve: Curves.easeOutQuart,
                                left: itemWidth * widget.selectedIndex,
                                top: 0,
                                bottom: 0,
                                width: itemWidth,
                                child: _LiquidSelection(
                                  key: ValueKey<String>(
                                    '${widget.selectedIndex}_$_liquidDirection',
                                  ),
                                  direction: _liquidDirection,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  CapsuleNavBar._tabs.length,
                                  (i) {
                                    final sel = widget.selectedIndex == i;
                                    return Expanded(
                                      child: _NavItem(
                                        tab: CapsuleNavBar._tabs[i],
                                        selected: sel,
                                        onTap: () => widget.onTap(i),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
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

class _LiquidSelection extends StatelessWidget {
  final int direction;

  const _LiquidSelection({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return CustomPaint(
          painter: _LiquidPillPainter(
            color: AppColors.navSelected,
            progress: value,
            direction: direction,
          ),
          child: child,
        );
      },
      child: const SizedBox.expand(),
    );
  }
}

class _LiquidPillPainter extends CustomPainter {
  final Color color;
  final double progress;
  final int direction;

  const _LiquidPillPainter({
    required this.color,
    required this.progress,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(size.height / 2),
    );
    final paint = Paint()..color = color;
    canvas.save();
    canvas.clipRRect(rrect);

    final fill = (size.width * (0.12 + 0.88 * progress)).clamp(
      size.height,
      size.width,
    );
    final wave = math.sin(progress * math.pi) * 10;
    final path = Path();
    if (direction >= 0) {
      final x = fill;
      path
        ..moveTo(0, 0)
        ..lineTo((x - wave).clamp(0, size.width).toDouble(), 0)
        ..cubicTo(
          x + wave,
          size.height * 0.22,
          x - wave,
          size.height * 0.72,
          x + wave * 0.3,
          size.height,
        )
        ..lineTo(0, size.height)
        ..close();
    } else {
      final x = size.width - fill;
      path
        ..moveTo(size.width, 0)
        ..lineTo((x + wave).clamp(0, size.width).toDouble(), 0)
        ..cubicTo(
          x - wave,
          size.height * 0.22,
          x + wave,
          size.height * 0.72,
          x - wave * 0.3,
          size.height,
        )
        ..lineTo(size.width, size.height)
        ..close();
    }
    canvas.drawPath(path, paint);

    final wobble = math.sin(progress * math.pi);
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 * wobble)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      Offset(size.width * (0.24 + 0.1 * wobble), size.height * 0.36),
      size.height * (0.18 + 0.05 * wobble),
      glowPaint,
    );
    canvas.drawCircle(
      Offset(size.width * (0.72 - 0.06 * wobble), size.height * 0.66),
      size.height * (0.13 + 0.04 * wobble),
      glowPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidPillPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.progress != progress ||
        oldDelegate.direction != direction;
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
        scale: selected ? 1.0 : 0.94,
        duration: AppDurations.short,
        curve: AppTheme.easeOutQuart,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: AppTheme.easeOutQuart,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(color: Colors.transparent),
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
