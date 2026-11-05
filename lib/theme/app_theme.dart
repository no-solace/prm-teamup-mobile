import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// The single ThemeData of the app (light only, handoff "Quy ước chung").
/// Component themes carry the 48dp / colour rules so screens can use plain
/// Material widgets (via lib/widgets) without any hard-coded values.
ThemeData buildAppTheme() {
  const scheme = lightColorScheme;
  final shape = RoundedRectangleBorder(borderRadius: radius(kRadiusMd));
  const minSize = Size(kTouchTarget, kButtonHeight);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: appTextTheme,
    fontFamily: kFontFamily,
    scaffoldBackgroundColor: scheme.surface,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: appTextTheme.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: minSize, shape: shape, textStyle: appTextTheme.labelLarge),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: minSize, shape: shape, textStyle: appTextTheme.labelLarge),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: minSize, shape: shape, textStyle: appTextTheme.labelLarge),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(kTouchTarget, kTouchTarget)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius(kRadiusMd),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(borderRadius: radius(kRadiusSm)),
      errorBorder: OutlineInputBorder(
        borderRadius: radius(kRadiusSm),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: kSpaceMd, vertical: kSpaceMd),
    ),
    chipTheme: ChipThemeData(
      labelStyle: appTextTheme.labelLarge,
      shape: RoundedRectangleBorder(borderRadius: radius(kRadiusSm)),
      padding: const EdgeInsets.symmetric(horizontal: kSpaceSm, vertical: kSpaceSm),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(appTextTheme.labelLarge),
    ),
    listTileTheme: ListTileThemeData(
      minVerticalPadding: kSpaceSm,
      minTileHeight: 56,
      titleTextStyle: appTextTheme.bodyLarge,
      subtitleTextStyle: appTextTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: radius(kRadiusLg)),
      titleTextStyle: appTextTheme.titleLarge,
      contentTextStyle: appTextTheme.bodyMedium,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}
