import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';

/// Routes from tapped push notifications. The router listens and calls go().
/// Owner: Dan.
final notificationTapsProvider = StreamProvider<String>((ref) {
  return ref.watch(notificationServiceProvider).tappedRoutes;
});
