import 'package:flutter_riverpod/misc.dart' show Override;

import '../firebase/pdf_report_service.dart';
import '../services/class_service.dart';
import '../services/fakes/fake_auth_service.dart';
import '../services/fakes/fake_class_service.dart';
import '../services/fakes/fake_flow_def_services.dart';
import '../services/fakes/fake_infra_services.dart';
import '../services/fakes/fake_matching_service.dart';
import '../services/fakes/fake_proposal_service.dart';
import 'service_providers.dart';

/// Every service replaced by its fake. Used by main_fake.dart (D6) and tests.
/// Tests pass their own fake (for example zero latency or a failing one).
List<Override> fakeOverrides({
  bool signedIn = true,
  ClassService? classService,
  FakeAuthService? authService,
  FakeAnalyticsService? analyticsService,
  FakeNotificationService? notificationService,
  FakeConfigService? configService,
}) {
  final classes = classService ?? FakeClassService();
  return [
    authServiceProvider.overrideWithValue(
      authService ?? FakeAuthService(signedIn: signedIn),
    ),
    classServiceProvider.overrideWithValue(classes),
    matchingServiceProvider.overrideWithValue(FakeMatchingService()),
    proposalServiceProvider.overrideWithValue(
      FakeProposalService(
        classes: classes is FakeClassService ? classes : null,
      ),
    ),
    reportServiceProvider.overrideWithValue(PdfReportService(classes)),
    storageServiceProvider.overrideWithValue(FakeStorageService()),
    notificationServiceProvider.overrideWithValue(
      notificationService ?? FakeNotificationService(),
    ),
    analyticsServiceProvider.overrideWithValue(
      analyticsService ?? FakeAnalyticsService(),
    ),
    crashServiceProvider.overrideWithValue(FakeCrashService()),
    configServiceProvider.overrideWithValue(
      configService ?? FakeConfigService(),
    ),
    topicServiceProvider.overrideWithValue(FakeTopicService()),
    bookingServiceProvider.overrideWithValue(FakeBookingService()),
    meetingServiceProvider.overrideWithValue(FakeMeetingService()),
  ];
}
