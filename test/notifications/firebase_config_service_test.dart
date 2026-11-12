import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teamup_exe/firebase/firebase_config_service.dart';
import 'package:teamup_exe/services/config_service.dart';

class RemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  late RemoteConfig rc;
  late StreamController<RemoteConfigUpdate> updates;
  late FirebaseConfigService service;
  late bool enabled;
  late int limit;

  setUpAll(
    () => registerFallbackValue(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    ),
  );
  setUp(() {
    rc = RemoteConfig();
    updates = StreamController.broadcast();
    enabled = true;
    limit = 3;
    when(() => rc.setDefaults(any())).thenAnswer((_) async {});
    when(() => rc.setConfigSettings(any())).thenAnswer((_) async {});
    when(() => rc.getBool('ai_matching_enabled')).thenAnswer((_) => enabled);
    when(() => rc.getInt('max_proposals_shown')).thenAnswer((_) => limit);
    when(() => rc.getInt('max_topic_revisions')).thenAnswer((_) => 3);
    when(() => rc.getInt('default_meeting_duration_minutes')).thenAnswer((_) => 30);
    when(() => rc.fetchAndActivate()).thenAnswer((_) async => true);
    when(() => rc.activate()).thenAnswer((_) async => true);
    when(() => rc.lastFetchStatus).thenReturn(RemoteConfigFetchStatus.success);
    when(() => rc.onConfigUpdated).thenAnswer((_) => updates.stream);
    service = FirebaseConfigService(
      rc: rc,
      loadDefaults: () =>
          File('firebase/remote-config-defaults.json').readAsString(),
    );
  });
  tearDown(() async {
    await service.dispose();
    await updates.close();
  });

  test(
    'bundled JSON, Dart fallback and publish template stay aligned',
    () async {
      final defaults = jsonDecode(
        await File('firebase/remote-config-defaults.json').readAsString(),
      ) as Map<String, dynamic>;
      final template = jsonDecode(
        await File('firebase/remote-config-template.json').readAsString(),
      ) as Map<String, dynamic>;
      expect(
        defaults['ai_matching_enabled'],
        AppConfig.defaults.aiMatchingEnabled,
      );
      expect(
        defaults['max_proposals_shown'],
        AppConfig.defaults.maxProposalsShown,
      );
      expect(
        template['parameters']['ai_matching_enabled']['defaultValue']['value'],
        defaults['ai_matching_enabled'].toString(),
      );
      expect(
        template['parameters']['max_proposals_shown']['defaultValue']['value'],
        defaults['max_proposals_shown'].toString(),
      );
      expect(defaults['max_topic_revisions'], AppConfig.defaults.maxTopicRevisions);
      expect(
        defaults['default_meeting_duration_minutes'],
        AppConfig.defaults.defaultMeetingDurationMinutes,
      );
      for (final key in ['max_topic_revisions', 'default_meeting_duration_minutes']) {
        expect(
          template['parameters'][key]['defaultValue']['value'],
          defaults[key].toString(),
        );
      }
      await service.init();
      verify(() => rc.setDefaults(defaults)).called(1);
    },
  );

  test('fetch+activate publishes both values without rebuild', () async {
    await service.init();
    final seen = <AppConfig>[];
    final sub = service.watch().listen(seen.add);
    await pumpEventQueue();
    enabled = false;
    limit = 1;
    await service.refresh();
    await pumpEventQueue();
    expect(seen.last.aiMatchingEnabled, isFalse);
    expect(seen.last.maxProposalsShown, 1);
    expect(service.lastFetchStatus, 'success');
    await sub.cancel();
  });

  test(
    'failed first fetch keeps defaults, later failure keeps activated cache',
    () async {
      when(() => rc.fetchAndActivate()).thenThrow(StateError('offline'));
      await service.init();
      expect(service.current.maxProposalsShown, 3);
      expect(service.lastFetchStatus, startsWith('fallback'));
      when(() => rc.fetchAndActivate()).thenAnswer((_) async => true);
      enabled = false;
      limit = 2;
      await service.refresh();
      when(() => rc.fetchAndActivate()).thenThrow(StateError('offline'));
      enabled = true;
      limit = 9;
      await service.refresh();
      expect(service.current.aiMatchingEnabled, isFalse);
      expect(service.current.maxProposalsShown, 2);
    },
  );

  test(
    'realtime activates updates and failure retains current values',
    () async {
      await service.init();
      enabled = false;
      limit = 4;
      updates.add(
        RemoteConfigUpdate({'ai_matching_enabled', 'max_proposals_shown'}),
      );
      await pumpEventQueue();
      expect(service.current.aiMatchingEnabled, isFalse);
      expect(service.current.maxProposalsShown, 4);
      when(() => rc.activate()).thenThrow(StateError('offline'));
      enabled = true;
      limit = 1;
      updates.add(RemoteConfigUpdate({'max_proposals_shown'}));
      await pumpEventQueue();
      expect(service.current.maxProposalsShown, 4);
      expect(service.lastFetchStatus, contains('activation failed'));
    },
  );

  test('broken asset and SDK setup retain usable Dart defaults', () async {
    await service.dispose();
    service = FirebaseConfigService(
      rc: rc,
      loadDefaults: () async => 'bad-json',
    );
    when(() => rc.setDefaults(any())).thenThrow(StateError('not ready'));
    await service.init();
    expect(service.current.aiMatchingEnabled, isTrue);
    expect(service.current.maxProposalsShown, 3);
    expect(service.lastFetchStatus, contains('setup failed'));
  });

  test('remote limit cannot remove all cards or request an unbounded list', () {
    expect(
      AppConfig.fromValues({'max_proposals_shown': -4}).maxProposalsShown,
      1,
    );
    expect(
      AppConfig.fromValues({'max_proposals_shown': 100000}).maxProposalsShown,
      20,
    );
    expect(
      AppConfig.fromValues({'max_proposals_shown': 'oops'}).maxProposalsShown,
      3,
    );
  });
}
