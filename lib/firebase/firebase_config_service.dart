import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../services/config_service.dart';

/// Owner: Dan. Keys and defaults must match firebase/remote-config-template.json.
class FirebaseConfigService implements ConfigService {
  FirebaseConfigService({FirebaseRemoteConfig? rc}) : _rc = rc ?? FirebaseRemoteConfig.instance;

  static const kAiMatchingEnabled = 'ai_matching_enabled';
  static const kMaxProposalsShown = 'max_proposals_shown';

  final FirebaseRemoteConfig _rc;
  final _controller = StreamController<AppConfig>.broadcast();
  StreamSubscription<RemoteConfigUpdate>? _realtime;
  bool _ready = false;

  /// Called once from main.dart after runApp (D10): offline never blocks startup.
  Future<void> init() async {
    await _rc.setDefaults({
      kAiMatchingEnabled: AppConfig.defaults.aiMatchingEnabled,
      kMaxProposalsShown: AppConfig.defaults.maxProposalsShown,
    });
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      // Short interval for the demo; explain fetch/caching on the slide.
      minimumFetchInterval: const Duration(minutes: 1),
    ));
    _ready = true;
    await refresh();
    // Realtime updates: a change published in the console shows without restarting.
    _realtime = _rc.onConfigUpdated.listen((_) async {
      await _rc.activate();
      _controller.add(current);
    }, onError: (_) {});
  }

  @override
  AppConfig get current => !_ready
      ? AppConfig.defaults
      : AppConfig(
          aiMatchingEnabled: _rc.getBool(kAiMatchingEnabled),
          maxProposalsShown: _rc.getInt(kMaxProposalsShown),
        );

  @override
  Stream<AppConfig> watch() async* {
    yield current;
    yield* _controller.stream;
  }

  @override
  Future<void> refresh() async {
    try {
      await _rc.fetchAndActivate();
    } catch (_) {
      // Offline: keep cached or default values (Lab 3 failure case).
    }
    _controller.add(current);
  }

  @override
  String get lastFetchStatus => _ready ? _rc.lastFetchStatus.name : 'default';

  Future<void> dispose() async => _realtime?.cancel();
}
