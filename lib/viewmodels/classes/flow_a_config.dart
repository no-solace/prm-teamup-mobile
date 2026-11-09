import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';
import '../../services/config_service.dart';

/// UI observes the existing ConfigService interface, including fake changes.
final flowAConfigProvider = StreamProvider.autoDispose<AppConfig>(
  (ref) => ref.watch(configServiceProvider).watch(),
);
final flowAMatchingEnabledProvider = Provider.autoDispose<bool>(
  (ref) =>
      (ref.watch(flowAConfigProvider).value ??
              ref.watch(configServiceProvider).current)
          .aiMatchingEnabled,
);
