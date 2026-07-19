import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemePalette {
  final String label;
  final String description;

  /// 对应 CSS Token:
  /// --bg-primary / --card-bg / --btn-primary / --text-primary /
  /// --text-secondary / --text-placeholder / --border-divider / --nav-bg /
  /// --tab-active / --tab-inactive / --shadow-rgb + --shadow-alpha
  final Color bgPrimary;
  final Color cardBg;
  final Color btnPrimary;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textPlaceholder;
  final Color borderDivider;
  final Color navBg;
  final Color tabActive;
  final Color tabInactive;
  final int shadowR;
  final int shadowG;
  final int shadowB;
  final double shadowAlpha;

  const AppThemePalette({
    required this.label,
    required this.description,
    required this.bgPrimary,
    required this.cardBg,
    required this.btnPrimary,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.borderDivider,
    required this.navBg,
    required this.tabActive,
    required this.tabInactive,
    required this.shadowR,
    required this.shadowG,
    required this.shadowB,
    required this.shadowAlpha,
  });

  Color get shadowColor =>
      Color.fromRGBO(shadowR, shadowG, shadowB, shadowAlpha);

  // 兼容现有页面中的旧命名，实际值均来自上面的 11 类主题变量。
  Color get bg => bgPrimary;
  Color get card => cardBg;
  Color get surface => Color.lerp(bgPrimary, borderDivider, 0.42)!;
  Color get text => textPrimary;
  Color get textHint => textPlaceholder;
  Color get divider => borderDivider;
  Color get accent => accentColor;
  Color get accentLight => Color.lerp(cardBg, accentColor, 0.14)!;
  Color get income => AppColors.incomeGreen;
  Color get expense => AppColors.expenseRed;
  Color get tagPink => Color.lerp(cardBg, const Color(0xFFE8A0B4), 0.18)!;
  Color get tagBlue => Color.lerp(cardBg, const Color(0xFF8CB5A8), 0.18)!;
  Color get tagWarm => Color.lerp(cardBg, btnPrimary, 0.14)!;
  Color get tagGreen => Color.lerp(cardBg, accentColor, 0.14)!;
}

class AppColors {
  AppColors._();

  static const String _themeStorageKey = 'tallyjie_theme_palette';
  static const Color incomeGreen = Color(0xFF5D7A6B);
  static const Color expenseRed = Color(0xFFD27165);
  static final ValueNotifier<int> themeVersion = ValueNotifier(0);

  static const List<AppThemePalette> palettes = [
    AppThemePalette(
      label: '奶油纸感/温润豆沙/日常记录',
      description: '暖白米色 / 温润豆沙 / 日常记录',
      bgPrimary: Color(0xFFFDF8F0),
      cardBg: Color(0xFFFFFFFF),
      btnPrimary: Color(0xFFD8A47F),
      accentColor: Color(0xFFD8A47F),
      textPrimary: Color(0xFF3D2C1E),
      textSecondary: Color(0xFF8A7A6B),
      textPlaceholder: Color(0xFFC5B5A5),
      borderDivider: Color(0xFFF0E8DD),
      navBg: Color(0xFFFDF8F0),
      tabActive: Color(0xFFD8A47F),
      tabInactive: Color(0xFFC5B5A5),
      shadowR: 180,
      shadowG: 150,
      shadowB: 120,
      shadowAlpha: 0.08,
    ),
    AppThemePalette(
      label: '风雅青色/汝窑天青/玉石灰绿/清雅轻奢',
      description: '极浅青白 / 汝窑天青 / 玉石灰绿',
      bgPrimary: Color(0xFFF2F7F2),
      cardBg: Color(0xFFFFFFFF),
      btnPrimary: Color(0xFF8CB5A8),
      accentColor: Color(0xFF8CB5A8),
      textPrimary: Color(0xFF2D3E3A),
      textSecondary: Color(0xFF7A948A),
      textPlaceholder: Color(0xFFB2C8BE),
      borderDivider: Color(0xFFE6EFEA),
      navBg: Color(0xFFF2F7F2),
      tabActive: Color(0xFF8CB5A8),
      tabInactive: Color(0xFFB2C8BE),
      shadowR: 120,
      shadowG: 160,
      shadowB: 140,
      shadowAlpha: 0.08,
    ),
    AppThemePalette(
      label: '经典黑白/暖白灰阶/墨色线条/极简高级',
      description: '暖白灰阶 / 墨色线条 / 极简高级',
      bgPrimary: Color(0xFFF5F5F5),
      cardBg: Color(0xFFFFFFFF),
      btnPrimary: Color(0xFF3D3D3D),
      accentColor: Color(0xFF3D3D3D),
      textPrimary: Color(0xFF1A1A1A),
      textSecondary: Color(0xFF6B6B6B),
      textPlaceholder: Color(0xFFA0A0A0),
      borderDivider: Color(0xFFE8E8E8),
      navBg: Color(0xFFF5F5F5),
      tabActive: Color(0xFF3D3D3D),
      tabInactive: Color(0xFFA0A0A0),
      shadowR: 0,
      shadowG: 0,
      shadowB: 0,
      shadowAlpha: 0.06,
    ),
  ];

  static String currentTheme = palettes.first.label;

  static Color bgPrimary = palettes.first.bgPrimary;
  static Color cardBg = palettes.first.cardBg;
  static Color btnPrimary = palettes.first.btnPrimary;
  static Color accentColor = palettes.first.accentColor;
  static Color textPrimary = palettes.first.textPrimary;
  static Color textSecondary = palettes.first.textSecondary;
  static Color textPlaceholder = palettes.first.textPlaceholder;
  static Color borderDivider = palettes.first.borderDivider;
  static Color navBg = palettes.first.navBg;
  static Color tabActive = palettes.first.tabActive;
  static Color tabInactive = palettes.first.tabInactive;
  static int shadowR = palettes.first.shadowR;
  static int shadowG = palettes.first.shadowG;
  static int shadowB = palettes.first.shadowB;
  static double shadowAlpha = palettes.first.shadowAlpha;

  static Color bg = palettes.first.bg;
  static Color card = palettes.first.card;
  static Color surface = palettes.first.surface;
  static Color text = palettes.first.text;
  static Color textHint = palettes.first.textHint;
  static Color divider = palettes.first.divider;
  static Color accent = palettes.first.accent;
  static Color accentLight = palettes.first.accentLight;
  static Color income = incomeGreen;
  static Color expense = expenseRed;
  static Color navSelected = palettes.first.tabActive;
  static Color navUnselected = palettes.first.tabInactive;
  static const Color navText = Color(0xFFFFFFFF);
  static Color tagPink = palettes.first.tagPink;
  static Color tagBlue = palettes.first.tagBlue;
  static Color tagWarm = palettes.first.tagWarm;
  static Color tagGreen = palettes.first.tagGreen;
  static const Color white = Colors.white;
  static Color success = incomeGreen;

  static Color get shadowColor =>
      Color.fromRGBO(shadowR, shadowG, shadowB, shadowAlpha);

  static Color get buttonHover => _shiftLightness(btnPrimary, 0.10);
  static Color get buttonPressed => _shiftLightness(btnPrimary, -0.10);

  static Color get categoryFood => expense;
  static Color get categoryTransit => Color.lerp(accent, textSecondary, 0.34)!;
  static Color get categoryShopping => Color.lerp(accent, expense, 0.48)!;
  static Color get categoryHome => Color.lerp(text, accent, 0.48)!;
  static Color get categoryUtility => Color.lerp(expense, income, 0.42)!;
  static Color get categoryDigital => Color.lerp(accent, textSecondary, 0.18)!;
  static Color get categoryFun => Color.lerp(textSecondary, expense, 0.42)!;
  static Color get categoryStudy => income;
  static Color get categoryOther => textSecondary;

  static Future<void> restoreSavedPalette() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeStorageKey);
    if (savedTheme == null) return;

    final palette = _paletteByLabel(savedTheme);
    if (palette != null) applyPalette(palette, persist: false);
  }

  static void applyPalette(AppThemePalette palette, {bool persist = true}) {
    currentTheme = palette.label;
    bgPrimary = palette.bgPrimary;
    cardBg = palette.cardBg;
    btnPrimary = palette.btnPrimary;
    accentColor = palette.accentColor;
    textPrimary = palette.textPrimary;
    textSecondary = palette.textSecondary;
    textPlaceholder = palette.textPlaceholder;
    borderDivider = palette.borderDivider;
    navBg = palette.navBg;
    tabActive = palette.tabActive;
    tabInactive = palette.tabInactive;
    shadowR = palette.shadowR;
    shadowG = palette.shadowG;
    shadowB = palette.shadowB;
    shadowAlpha = palette.shadowAlpha;

    bg = palette.bg;
    card = palette.card;
    surface = palette.surface;
    text = palette.text;
    textHint = palette.textHint;
    divider = palette.divider;
    accent = palette.accent;
    accentLight = palette.accentLight;
    income = incomeGreen;
    expense = expenseRed;
    navSelected = palette.tabActive;
    navUnselected = palette.tabInactive;
    tagPink = palette.tagPink;
    tagBlue = palette.tagBlue;
    tagWarm = palette.tagWarm;
    tagGreen = palette.tagGreen;
    success = incomeGreen;
    themeVersion.value++;

    if (persist) {
      unawaited(_savePaletteLabel(palette.label));
    }
  }

  static AppThemePalette? _paletteByLabel(String label) {
    final legacyLabels = {
      '默认浅色': palettes[0].label,
      '奶油纸感': palettes[0].label,
      '流心粉色': palettes[0].label,
      '流心粉色/雾粉柔光/轻甜手账': palettes[0].label,
      '风雅青色': palettes[1].label,
      '经典黑白': palettes[2].label,
    };
    final normalized = legacyLabels[label] ?? label;
    for (final palette in palettes) {
      if (palette.label == normalized) return palette;
    }
    return null;
  }

  static Color _shiftLightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Future<void> _savePaletteLabel(String label) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeStorageKey, label);
  }
}
