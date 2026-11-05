import 'package:flutter/material.dart';

import 'app_colors.dart';

const String kFontFamily = 'BeVietnamPro';

/// Type scale from handoff Table 1. Body text is never below 14sp (C9).
final appTextTheme = const TextTheme(
  headlineSmall: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700),
  titleLarge: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600),
  titleMedium: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600),
  bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400),
  bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400),
  labelLarge: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600),
  // Not in DESIGN.md; mapped to the nearest token so nothing falls under 14sp.
  bodySmall: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400),
  labelMedium: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600),
  labelSmall: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600),
).apply(
  fontFamily: kFontFamily,
  bodyColor: AppColors.onSurface,
  displayColor: AppColors.onSurface,
);

/// Numbers in stat rows (S3, S23): 24sp, tabular figures (S2 constraint).
const statNumberStyle = TextStyle(
  fontFamily: kFontFamily,
  fontSize: 24,
  height: 32 / 24,
  fontWeight: FontWeight.w700,
  fontFeatures: [FontFeature.tabularFigures()],
);
