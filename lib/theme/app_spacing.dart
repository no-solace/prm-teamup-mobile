import 'package:flutter/widgets.dart';

/// Spacing, radius and size tokens (handoff Table 1 and shared constraints).
/// Screens use these names, never raw numbers.
const double kSpaceXs = 4;
const double kSpaceSm = 8;
const double kSpaceMd = 16;
const double kSpaceLg = 24;
const double kSpaceXl = 32;

const double kRadiusSm = 8;
const double kRadiusMd = 12;
const double kRadiusLg = 16;
const double kRadiusFull = 999;

/// Minimum touch target (C9).
const double kTouchTarget = 48;

/// Button height (S1: 48dp) and text field height (S1: 56dp).
const double kButtonHeight = 48;
const double kFieldHeight = 56;

/// Major slot sizes (S5: 40dp, S10: 48dp).
const double kMajorSlotSmall = 40;
const double kMajorSlotLarge = 48;

/// Content width cap for wide screens (handoff "Màn rộng").
const double kMaxContentWidth = 600;

const EdgeInsets kScreenPadding = EdgeInsets.all(kSpaceMd);

BorderRadius radius(double r) => BorderRadius.circular(r);
