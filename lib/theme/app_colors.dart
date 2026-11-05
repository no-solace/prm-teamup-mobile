import 'package:flutter/material.dart';

/// Colour tokens from Lab 2 `design/DESIGN.md` (handoff Table 1).
/// Screens never use these directly: read them through `Theme.of(context).colorScheme`.
abstract final class AppColors {
  static const primary = Color(0xFFB23E00);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFE2D2);
  static const onPrimaryContainer = Color(0xFF3B1400);

  static const secondary = Color(0xFF2F2E2A);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE9E7E2);
  static const onSecondaryContainer = Color(0xFF1C1B18);

  static const tertiary = Color(0xFF1B6B3C);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFD6F0DD);
  static const onTertiaryContainer = Color(0xFF07301A);

  static const error = Color(0xFFB3261E);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFF9DEDC);
  static const onErrorContainer = Color(0xFF410E0B);

  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F2EF);
  static const surfaceContainer = Color(0xFFE9E7E2);
  static const onSurface = Color(0xFF1C1B18);
  static const onSurfaceVariant = Color(0xFF55534D);
  static const outline = Color(0xFF77756F);
  static const outlineVariant = Color(0xFFD6D4CE);

  /// Logo only (DESIGN.md): never for text or buttons.
  static const brandOrange = Color(0xFFF37021);
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  primaryContainer: AppColors.primaryContainer,
  onPrimaryContainer: AppColors.onPrimaryContainer,
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  secondaryContainer: AppColors.secondaryContainer,
  onSecondaryContainer: AppColors.onSecondaryContainer,
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onTertiary,
  tertiaryContainer: AppColors.tertiaryContainer,
  onTertiaryContainer: AppColors.onTertiaryContainer,
  error: AppColors.error,
  onError: AppColors.onError,
  errorContainer: AppColors.errorContainer,
  onErrorContainer: AppColors.onErrorContainer,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  onSurfaceVariant: AppColors.onSurfaceVariant,
  surfaceContainerLow: AppColors.surfaceContainerLow,
  surfaceContainer: AppColors.surfaceContainer,
  outline: AppColors.outline,
  outlineVariant: AppColors.outlineVariant,
);
