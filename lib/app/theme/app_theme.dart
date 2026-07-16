import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_durations.dart';

/// TallyJie 主题配置
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.primaryBg,
        colorScheme: const ColorScheme.light(
          surface: AppColors.primaryBg,
          onSurface: AppColors.primaryText,
          primary: AppColors.accent,
          onPrimary: AppColors.white,
          secondary: AppColors.secondaryText,
          error: AppColors.expense,
        ),

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.title32,
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          margin: EdgeInsets.zero,
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.primaryBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
          hintStyle: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 17,
          ),
        ),

        // BottomSheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.sheet,
          ),
          modalBarrierColor: Color(0x33000000),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 0.5,
          space: 0,
        ),

        // FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.navSelected,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: CircleBorder(),
        ),

        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.success;
            }
            return AppColors.divider;
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.navSelected,
          contentTextStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  /// easeOutQuart 曲线
  static const Curve easeOutQuart = Cubic(0.25, 1.0, 0.5, 1.0);

  /// 页面转场动画时长
  static const Duration pageTransitionDuration = AppDurations.medium;
}
