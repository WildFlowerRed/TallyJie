import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_durations.dart';

/// TallyJie 主题配置 — 莫兰迪色系
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.card,
        colorScheme: const ColorScheme.light(
          surface: AppColors.card,
          onSurface: AppColors.primaryText,
          primary: AppColors.accent,
          onPrimary: AppColors.card,
          secondary: AppColors.secondaryText,
          error: AppColors.expense,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.title32,
        ),

        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.secondaryBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.card,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.card,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.card,
            borderSide: const BorderSide(
              color: AppColors.accent,
              width: 1,
            ),
          ),
          hintStyle: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 15,
          ),
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.sheet,
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 0.5,
          space: 0,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.navSelected,
          foregroundColor: AppColors.card,
          elevation: 0,
          shape: CircleBorder(),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.navSelected,
          contentTextStyle: const TextStyle(
            color: AppColors.card,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  static const Curve easeOutQuart = Cubic(0.25, 1.0, 0.5, 1.0);
  static const Duration pageTransitionDuration = AppDurations.medium;
}
