import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../providers/service_providers.dart';

/// Signed-in mentor, or null. The router redirect listens to this (D7).
final sessionProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges();
});
