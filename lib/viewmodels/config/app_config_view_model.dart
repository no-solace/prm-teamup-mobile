import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';
import '../../services/config_service.dart';

/// The live Remote Config values.
///
/// Lab 3 rubric: at least two parameters must change visible behaviour, with
/// in-app defaults, and the change must apply without a new build.
///
/// * `ai_matching_enabled` hides the "Match with AI" action.
/// * `max_proposals_shown` caps how many proposal cards S9 shows.
final appConfigProvider = StreamProvider<AppConfig>(
  (ref) => ref.watch(configServiceProvider).watch(),
);

/// Whether the "Match with AI" action is available.
final aiMatchingEnabledProvider = Provider<bool>(
  (ref) =>
      ref.watch(appConfigProvider).value?.aiMatchingEnabled ??
      AppConfig.defaults.aiMatchingEnabled,
);

/// How many proposal cards S9 shows.
final maxProposalsShownProvider = Provider<int>(
  (ref) =>
      ref.watch(appConfigProvider).value?.maxProposalsShown ??
      AppConfig.defaults.maxProposalsShown,
);
