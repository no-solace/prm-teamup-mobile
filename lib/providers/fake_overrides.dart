import 'package:flutter_riverpod/misc.dart' show Override;

import '../services/class_service.dart';
import '../services/fakes/fake_auth_service.dart';
import '../services/fakes/fake_class_service.dart';
import '../services/fakes/fake_infra_services.dart';
import '../services/fakes/fake_matching_service.dart';
import '../services/fakes/fake_proposal_service.dart';
import 'service_providers.dart';

/// Every service replaced by its fake. Used by main_fake.dart (D6) and tests.
/// Tests pass their own fake (for example zero latency or a failing one).
List<Override> fakeOverrides({bool signedIn = true, ClassService? classService}) => [
      authServiceProvider.overrideWithValue(FakeAuthService(signedIn: signedIn)),
      classServiceProvider.overrideWithValue(classService ?? FakeClassService()),
      matchingServiceProvider.overrideWithValue(FakeMatchingService()),
      proposalServiceProvider.overrideWithValue(FakeProposalService()),
      reportServiceProvider.overrideWithValue(FakeReportService()),
      storageServiceProvider.overrideWithValue(FakeStorageService()),
      notificationServiceProvider.overrideWithValue(FakeNotificationService()),
      analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      crashServiceProvider.overrideWithValue(FakeCrashService()),
      configServiceProvider.overrideWithValue(FakeConfigService()),
    ];
