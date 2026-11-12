import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../services/config_service.dart';

/// Bundled defaults -> activated cache -> fetch/activate -> realtime updates.
class FirebaseConfigService implements ConfigService {
  FirebaseConfigService({
    FirebaseRemoteConfig? rc,
    Future<String> Function()? loadDefaults,
  }) : _rc = rc ?? FirebaseRemoteConfig.instance,
       _loadDefaults =
           loadDefaults ??
           (() =>
               rootBundle.loadString('firebase/remote-config-defaults.json'));

  static const kAiMatchingEnabled = 'ai_matching_enabled';
  static const kMaxProposalsShown = 'max_proposals_shown';
  static const kMaxTopicRevisions = 'max_topic_revisions';
  static const kMeetingDuration = 'default_meeting_duration_minutes';
  final FirebaseRemoteConfig _rc;
  final Future<String> Function() _loadDefaults;
  final _controller = StreamController<AppConfig>.broadcast();
  StreamSubscription<RemoteConfigUpdate>? _realtime;
  Future<void>? _initializing;
  AppConfig _active = AppConfig.defaults;
  String _status = 'default';
  bool _ready = false, _disposed = false;

  Future<void> init() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    try {
      _active = AppConfig.fromValues(
        jsonDecode(await _loadDefaults()) as Map<String, dynamic>,
      );
    } catch (_) {
      _status = 'fallback: bundled defaults unavailable';
    }
    try {
      await _rc.setDefaults({
        kAiMatchingEnabled: _active.aiMatchingEnabled,
        kMaxProposalsShown: _active.maxProposalsShown,
        kMaxTopicRevisions: _active.maxTopicRevisions,
        kMeetingDuration: _active.defaultMeetingDurationMinutes,
      });
      await _rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 1)
              : const Duration(hours: 12),
        ),
      );
      _ready = true;
      _readActivated(); // Includes values cached by an earlier launch.
      _realtime = _rc.onConfigUpdated.listen(
        (_) => unawaited(_activate()),
        onError: (Object _) {
          _status = 'fallback: realtime unavailable';
          _emit();
        },
      );
      await _fetch();
    } catch (_) {
      _status = 'fallback: setup failed';
      _emit();
      _initializing = null; // A later refresh may retry setup.
    }
  }

  void _readActivated() {
    _active = AppConfig.fromValues({
      kAiMatchingEnabled: _rc.getBool(kAiMatchingEnabled),
      kMaxProposalsShown: _rc.getInt(kMaxProposalsShown),
      kMaxTopicRevisions: _rc.getInt(kMaxTopicRevisions),
      kMeetingDuration: _rc.getInt(kMeetingDuration),
    });
  }

  void _emit() {
    if (!_disposed) _controller.add(_active);
  }

  Future<void> _activate() async {
    try {
      await _rc.activate();
      if (_disposed) return;
      _readActivated();
      _status = 'remote: realtime activated';
    } catch (_) {
      _status = 'fallback: activation failed';
    }
    _emit();
  }

  Future<void> _fetch() async {
    try {
      await _rc.fetchAndActivate();
      if (_disposed) return;
      _readActivated();
      _status = _rc.lastFetchStatus.name;
    } catch (_) {
      // Never read unactivated or SDK static-zero values on a failed fetch.
      _status = 'fallback: fetch failed (cached/default values retained)';
    }
    _emit();
  }

  @override
  AppConfig get current => _active;
  @override
  Stream<AppConfig> watch() async* {
    yield current;
    yield* _controller.stream;
  }

  @override
  Future<void> refresh() async {
    if (!_ready) {
      await init();
    } else {
      await _fetch();
    }
  }

  @override
  String get lastFetchStatus => _status;

  Future<void> dispose() async {
    _disposed = true;
    await _realtime?.cancel();
    await _controller.close();
  }
}
