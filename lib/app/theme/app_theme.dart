import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// TallyJie 主题
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          surface: AppColors.bg,
          onSurface: AppColors.text,
          primary: AppColors.accent,
          onPrimary: AppColors.white,
          secondary: AppColors.textSecondary,
          error: AppColors.expense,
        ),

        appBarTheme: const AppBarTheme(
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
            borderSide: const BorderSide(color: AppColors.accent, width: 1),
          ),
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16),
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        ),

        dividerTheme: const DividerThemeData(
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
