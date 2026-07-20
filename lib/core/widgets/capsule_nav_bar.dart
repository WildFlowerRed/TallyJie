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

class _CapsuleNavBarState extends State<CapsuleNavBar>
    with SingleTickerProviderStateMixin {
  int _liquidDirection = 1;
  int _lastIndex = 0;
  int _fromIndex = 0;
  late final AnimationController _jellyController;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.selectedIndex;
    _fromIndex = widget.selectedIndex;
    _jellyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant CapsuleNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _lastIndex) {
      _fromIndex = _lastIndex;
      _liquidDirection = widget.selectedIndex > _lastIndex ? 1 : -1;
      _lastIndex = widget.selectedIndex;
      _jellyController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _jellyController.dispose();
    super.dispose();
  }

  double _springProgress(double t) {
    if (t >= 1) return 1;
    return 1 - math.exp(-6.2 * t) * math.cos(13.0 * t);
  }

  double _dampedWobble(double t) {
    if (t >= 1) return 0;
    return math.exp(-5.4 * t) * math.cos(22.0 * t);
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
                          return AnimatedBuilder(
                            animation: _jellyController,
                            builder: (context, child) {
                              final t = _jellyController.value;
                              final progress = _springProgress(t);
                              final wobble = _dampedWobble(t);
                              final fromLeft = itemWidth * _fromIndex;
                              final targetLeft =
                                  itemWidth * widget.selectedIndex;
                              final left =
                                  fromLeft + (targetLeft - fromLeft) * progress;
                              final squeezeX = (1 - 0.15 * wobble).clamp(
                                0.84,
                                1.08,
                              );
                              final stretchY = (1 + 0.09 * wobble).clamp(
                                0.94,
                                1.12,
                              );
                              final textShift =
                                  _liquidDirection *
                                  math.sin(t * math.pi) *
                                  math.exp(-3.2 * t) *
                                  8;
                              return Stack(
                                children: [
                                  Positioned(
                                    left: left.clamp(
                                      -itemWidth * 0.12,
                                      constraints.maxWidth - itemWidth * 0.88,
                                    ),
                                    top: 0,
                                    bottom: 0,
                                    width: itemWidth,
                                    child: Transform.scale(
                                      scaleX: squeezeX.toDouble(),
                                      scaleY: stretchY.toDouble(),
                                      child: _LiquidSelection(
                                        key: ValueKey<String>(
                                          '${widget.selectedIndex}_$_liquidDirection',
                                        ),
                                        direction: _liquidDirection,
                                      ),
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
                                            jellyWobble: sel ? wobble : 0,
                                            jellyShift: sel ? textShift : 0,
                                            onTap: () => widget.onTap(i),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
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
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutBack,
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
  final double jellyWobble;
  final double jellyShift;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.selected,
    this.jellyWobble = 0,
    this.jellyShift = 0,
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
        child: Transform.translate(
          offset: Offset(jellyShift, 0),
          child: Transform.scale(
            scaleX: (1 + 0.035 * jellyWobble).clamp(0.97, 1.04).toDouble(),
            scaleY: (1 - 0.025 * jellyWobble).clamp(0.97, 1.03).toDouble(),
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
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      child: Text(tab.label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
