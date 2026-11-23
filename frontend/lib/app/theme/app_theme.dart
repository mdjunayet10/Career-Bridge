import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = base.textTheme.apply(
      fontFamily: 'Sora',
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.blue,
        secondary: AppColors.purple,
        surface: AppColors.card,
        error: AppColors.red,
      ),
      textTheme: textTheme,
      dividerColor: AppColors.borderMuted,
      splashFactory: InkSparkle.splashFactory,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.hovered)
              ? AppColors.borderStrong
              : AppColors.border;
        }),
        thickness: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.hovered) ? 8 : 6;
        }),
        radius: const Radius.circular(999),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.mutedSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        actionTextColor: AppColors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blueStrong,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: const BorderSide(color: AppColors.borderStrong),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSubtle),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}
