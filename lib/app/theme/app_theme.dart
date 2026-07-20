import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font_family.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// TallyJie 主题
class AppTheme {
  AppTheme._();

  static ButtonStyle get primaryFilledButtonStyle => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.buttonPressed;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.buttonHover;
      }
      return AppColors.btnPrimary;
    }),
    foregroundColor: WidgetStateProperty.all(AppColors.white),
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: AppRadius.sm),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: AppFontFamily.currentFamily,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.light(
      surface: AppColors.bg,
      onSurface: AppColors.text,
      primary: AppColors.btnPrimary,
      onPrimary: AppColors.white,
      secondary: AppColors.textSecondary,
      error: AppColors.expense,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.title,
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide(color: AppColors.accent, width: 1),
      ),
      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16),
    ),

    filledButtonTheme: FilledButtonThemeData(style: primaryFilledButtonStyle),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryFilledButtonStyle.copyWith(
        shadowColor: WidgetStateProperty.all(AppColors.shadowColor),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.buttonPressed;
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.buttonHover;
          }
          return AppColors.btnPrimary;
        }),
        overlayColor: WidgetStateProperty.all(AppColors.accentLight),
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
    ),

    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
      space: 0,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.text,
      contentTextStyle: const TextStyle(color: AppColors.white, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static const Curve easeOutQuart = Cubic(0.25, 1.0, 0.5, 1.0);
}
