import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../models/proposal.dart';
import '../../providers/service_providers.dart';
import '../../services/config_service.dart';
import '../auth/session_view_model.dart';
import '../config/app_config_view_model.dart';

export '../config/app_config_view_model.dart'
    show appConfigProvider, aiMatchingEnabledProvider, maxProposalsShownProvider;

final demoClassesProvider = StreamProvider.autoDispose<List<ClassRoom>>((ref) {
  if (ref.watch(sessionProvider).value == null) return Stream.value(const []);
  return ref.watch(classServiceProvider).watchMyClasses();
});

final demoProposalsProvider = StreamProvider.autoDispose<List<Proposal>>((ref) {
  if (ref.watch(sessionProvider).value == null) return Stream.value(const []);
  return ref.watch(proposalServiceProvider).watchAllPending();
});

/// A shared projection for the Profile demo panel; filtering lives outside UI.
final configuredProposalsProvider =
    Provider.autoDispose<AsyncValue<List<Proposal>>>((ref) {
      final limit = ref.watch(maxProposalsShownProvider);
      return ref
          .watch(demoProposalsProvider)
          .whenData((items) => items.take(limit).toList(growable: false));
    });

class ConfigDemoActions {
  const ConfigDemoActions(this._service);

  final ConfigService _service;

  String get lastFetchStatus => _service.lastFetchStatus;

  Future<void> refresh() => _service.refresh();
}

final configDemoActionsProvider = Provider<ConfigDemoActions>(
  (ref) => ConfigDemoActions(ref.watch(configServiceProvider)),
);
