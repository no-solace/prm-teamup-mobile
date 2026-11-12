import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/activity_messages.dart';
import '../firebase/fcm_notification_service.dart';
import '../firebase/firebase_analytics_service.dart';
import '../firebase/firebase_auth_service.dart';
import '../firebase/firebase_config_service.dart';
import '../firebase/firebase_crash_service.dart';
import '../firebase/firestore_booking_service.dart';
import '../firebase/firestore_class_service.dart';
import '../firebase/firestore_meeting_service.dart';
import '../firebase/firestore_proposal_service.dart';
import '../firebase/firestore_report_storage.dart';
import '../firebase/firestore_topic_service.dart';
import '../firebase/pdf_report_service.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/class_service.dart';
import '../services/config_service.dart';
import '../services/crash_service.dart';
import '../services/matching_service.dart';
import '../services/meeting_service.dart';
import '../services/notification_service.dart';
import '../services/proposal_service.dart';
import '../services/report_service.dart';
import '../services/rule_based_matching_service.dart';
import '../services/storage_service.dart';
import '../services/topic_service.dart';

// The ONLY place where interfaces are bound to implementations (C5).
// main.dart uses these defaults (Firebase). main_fake.dart and tests override
// them with fakes via ProviderScope(overrides: ...).
// When you replace a stub with a real implementation, change it here.

final authServiceProvider = Provider<AuthService>(
  (ref) => FirebaseAuthService(),
);

final classServiceProvider = Provider<ClassService>(
  (ref) => FirestoreClassService(),
);

final matchingServiceProvider = Provider<MatchingService>(
  (ref) => RuleBasedMatchingService(),
);

final proposalServiceProvider = Provider<ProposalService>(
  (ref) => FirestoreProposalService(),
);

final reportServiceProvider = Provider<ReportService>(
  (ref) => PdfReportService(ref.watch(classServiceProvider)),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => FirestoreReportStorage(),
);

// FCM pushes plus Flow D/E activity found by watching Firestore (no Cloud
// Functions on the Spark plan; see activity_messages.dart).
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final auth = ref.watch(authServiceProvider);
  return FcmNotificationService(
    foregroundMessages: mergeMessages([
      FirebaseMessaging.onMessage,
      activityMessages(
        auth is FirebaseAuthService ? auth.profileChanges() : auth.authStateChanges(),
      ),
    ]),
  );
});

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => FirebaseAnalyticsService(),
);

final crashServiceProvider = Provider<CrashService>(
  (ref) => FirebaseCrashService(),
);

final configServiceProvider = Provider<ConfigService>(
  (ref) => FirebaseConfigService(),
);

final topicServiceProvider = Provider<TopicService>(
  (ref) => FirestoreTopicService(),
);

final bookingServiceProvider = Provider<BookingService>(
  (ref) => FirestoreBookingService(),
);

final meetingServiceProvider = Provider<MeetingService>(
  (ref) => FirestoreMeetingService(),
);
