import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/fake_overrides.dart';
import 'router/app_router.dart';

/// DEV ONLY (D6): the whole app on fake services, no Firebase.
///   flutter run -t lib/main_fake.dart
/// The submitted build, ARTEMIS and the video use main.dart.
/// Widget gallery: open /_gallery (for example from the debug route list).
void main() {
  runApp(ProviderScope(
    overrides: [
      ...fakeOverrides(),
      galleryEnabledProvider.overrideWithValue(true),
    ],
    child: const TeamUpApp(),
  ));
}
