# Kiến trúc TeamUp EXE — MVVM + Riverpod + Firebase

> Tài liệu kiến trúc theo Lab 3 §5: cấu trúc thư mục, sơ đồ layer, một sơ đồ
> sequence cho một flow đầy đủ, và bảng ViewModel → Service.
> Các quyết định khung vẫn nằm ở [skeleton-decisions.md](skeleton-decisions.md) (D3–D6).
>
> **Cập nhật 12/11/2026**: hợp nhất với nhánh `integration/lab3-complete`
> (Flow D/E/F, vai sinh viên, gói Firebase Spark, lưu PDF trong Firestore).
> Các quyết định khung vẫn nằm ở [skeleton-decisions.md](skeleton-decisions.md) (D3–D6).

## 1. Mô hình

MVVM + Riverpod 3 (Notifier viết tay, không codegen).

```mermaid
flowchart LR
  subgraph UI["UI layer"]
    S["screens/"] --> W["widgets/"]
  end
  S -->|ref.watch| VM["viewmodels/<br/>Notifier + ViewState"]
  VM -->|ref.read| P["providers/<br/>service_providers.dart"]
  P --> I["services/<br/>interface + AppError"]
  F["firebase/<br/>Firebase SDK"] -. implements .-> I
  K["services/fakes/"] -. implements .-> I
  M["models/"] --- VM
  M --- I
```

Quy tắc bắt buộc (kiểm bằng `tools/check_layers.sh`, chạy trước mỗi PR):

| Quy tắc | Công cụ kiểm |
|---|---|
| `screens/` và `widgets/` **không** import Firebase SDK | `check "screens/widgets import Firebase"` |
| `viewmodels/` **không** import Firebase SDK | `check "viewmodels import Firebase"` |
| `viewmodels/` **không** import `screens/` hay `widgets/` | `check "viewmodels import screens/widgets"` |
| `screens/` **không** import `providers/` (chỉ qua ViewModel) | `check "screens/widgets import providers"` |
| `services/` và `models/` thuần Dart, không import UI | `check "services/models import Flutter UI"` |
| Màn không hard-code màu / cỡ chữ / padding | `check "screens hard-code …"` |

- **View** (`screens/`, `widgets/`): chỉ dựng UI từ `ViewState`, không gọi service
  trực tiếp. Nghiệp vụ (lọc, sắp xếp, tổng hợp, kiểm tra) **không** nằm trong
  `build()`.
- **ViewModel** (`viewmodels/`): mỗi màn một `Notifier`, giữ `ViewState<T>`
  (`Loading` / `Empty` / `Data<T>` / `Failure<T>` — `viewmodels/view_state.dart`).
  Chỉ import `providers/service_providers.dart` để lấy service.
- **Service** (`services/`): interface thuần Dart. Lỗi luôn là `AppError`.
- **Firebase** (`firebase/`): bản cài đặt thật. **Fake** (`services/fakes/`): chỉ
  nối trong `main_fake.dart` và test.

> Hai helper telemetry cùng tồn tại và **cùng được dùng**:
>
> * `viewmodels/instrumentation.dart` — extension `InstrumentationRef` với
>   `trackAnalytics(...)` (gọi event kèm tham số thật) và `trackNonFatal(...)`
>   (ghi lỗi đã xử lý vào Crashlytics). Được dùng ở các ViewModel của
>   Flow A/B/C sau khi sửa CR-01.
> * `viewmodels/telemetry.dart` — `bestEffort(...)` và
>   `reportHandledError(...)` (lọc `ValidationError` / `CancelledError`).
>   Được dùng ở các ViewModel mới của Flow D/E/F.
>
> Cả hai đều nằm đúng layer `viewmodels/`, không phụ thuộc lẫn nhau, và cùng
> tuân theo nguyên tắc "lỗi telemetry không được làm hỏng luồng người dùng".

## 2. Cây thư mục

```text
lib/
├── main.dart            bản nộp: Firebase, Crashlytics, FCM nền
├── main_fake.dart       bản dev trên fake (không nộp)
├── app.dart             MaterialApp.router + theme
├── firebase_options.dart  sinh bởi flutterfire configure
├── models/              DTO thuần Dart: ClassRoom, Student, Team, Proposal, Report,
│                        AppUser, AppNotification, ProjectTopic, MentorSlot,
│                        MeetingBooking, MeetingMinutes
├── services/            interface + AppError + rule-based matching + csv importer
│   └── fakes/           bản giả lập cho test và main_fake.dart
├── firebase/            bản cài Firebase: auth, firestore, fcm, analytics,
│                        crashlytics, remote config, pdf report service
│                        (không có Storage — gói Spark lưu PDF trong Firestore)
├── providers/           service_providers.dart (nơi DUY NHẤT bind interface →
│                        implementation) + fake_overrides.dart
├── viewmodels/          Notifier theo từng miền: auth, classes, proposals,
│                        notifications, profile, config, topics, schedule,
│                        my_team + instrumentation.dart, telemetry.dart
├── screens/             theo flow: sign_in, onboarding, my_classes, flow_a, flow_b,
│                        flow_c, flow_d, flow_e, flow_f, my_team, profile,
│                        notifications, gallery
├── widgets/             thư viện component Lab 2 (AppButton, AppCard, MajorSlotRow,
│                        FitChip, TagChip, ErrorBanner, showConfirmDialog, StatusView,
│                        ActionFeedback, StatusChip…)
├── router/              routes.dart (hằng số route) + app_router.dart (go_router)
└── theme/               app_colors, app_typography, app_spacing, app_theme
firebase/                firestore.rules, indexes, remote-config-defaults.json,
                         remote-config-template.json, storage.rules (chỉ dùng khi bật Storage)
firebase.json  .firebaserc
tools/                    check_layers.sh, fixtures/ (CSV mẫu)
test/                    unit + widget test dùng fake service
e2e_test/                ARTEMIS pytest suite (Lab 3 §7)
docs/                    tài liệu Lab 3: design-traceability, architecture,
                         analytics-plan, test-plan, code-review
evidence/                ảnh console, DebugView, Crashlytics, ARTEMIS trace
report/  slides/         báo cáo PDF và slide PDF nộp
```

## 3. Điều hướng

`go_router` + `StatefulShellRoute.indexedStack`. Hằng số route ở `lib/router/routes.dart`
— màn điều hướng bằng helper (`Routes.proposal(id)`), không dùng chuỗi thô,
nên đổi tên route sẽ lỗi compile.

| Vai | Tab (`screens/app_shell.dart`) |
|---|---|
| Mentor | Classes, Proposals, Topics, Schedule, Profile |
| Trưởng nhóm / thành viên | My team (nhánh `/classes`), Topics, Schedule, Profile |

Redirect theo `sessionProvider`, theo thứ tự:

1. Chưa đăng nhập thì chỉ vào được `/sign-in`.
2. Đã đăng nhập nhưng chưa có vai (`role == null`) thì về `/onboarding`.
3. Route chỉ dành cho mentor (`Routes.isMentorOnly`: proposals, chi tiết lớp,
   import…) hoặc chỉ dành cho sinh viên (`Routes.isStudentOnly`: nộp đề tài,
   đặt lịch) bị đưa về `/classes`.

Chạm thông báo gọi `router.go(route)` **chỉ** khi route nằm trong
`Routes.isAllowedDeepLink()` (allow-list chống deep-link tới màn ngoài phạm vi).

## 4. ViewModel → Service

| Màn / Luồng | ViewModel | Service dùng | Nguồn dữ liệu thật |
|---|---|---|---|
| S1, S19 Sign in | `viewmodels/auth/sign_in_view_model.dart` → `SignInViewModel` | `AuthService`, `AnalyticsService`, `CrashService` | `FirebaseAuthService` (Google/email/phone) |
| (định tuyến) | `viewmodels/auth/session_view_model.dart` → `sessionProvider` | `AuthService`, `AnalyticsService`, `CrashService` | Firebase session + `users/{uid}` |
| (vai trò) | `viewmodels/auth/onboarding_view_model.dart` → `OnboardingViewModel` | `AuthService` | `users/{uid}.role` |
| S2 My classes | `viewmodels/classes/my_classes_view_model.dart` → `MyClassesViewModel` | `ClassService` | Firestore `classes` |
| S3, S23 Class detail | `viewmodels/classes/class_detail_view_model.dart` → `ClassDetailViewModel` | `ClassService`, `AnalyticsService`, `CrashService` | Firestore `classes/{id}` |
| S4 No team | `viewmodels/classes/no_team_view_model.dart` → `NoTeamViewModel` | `ClassService` | Firestore `classes/{id}/students` |
| S5 Need members | `viewmodels/proposals/proposal_view_model.dart` → `proposalTeamsProvider` | `ProposalService`, `ClassService` | Firestore `classes/{id}/teams` |
| S7 Student detail | `viewmodels/classes/student_detail_view_model.dart` → `StudentDetailViewModel` | `ClassService`, `AnalyticsService`, `CrashService` | Firestore `classes/{id}/students/{mssv}` |
| S8, S18 AI matching | `viewmodels/classes/matching_view_model.dart` → `MatchingViewModel` | `ClassService`, `MatchingService`, `ProposalService`, `AnalyticsService`, `CrashService` | Firestore + `RuleBasedMatchingService` |
| S9, S14 Proposals | `viewmodels/proposals/proposal_view_model.dart` → `visibleProposalsProvider`, `pendingProposalsProvider` | `ProposalService`, `ConfigService` | Firestore `collectionGroup('proposals')` + Remote Config |
| S10, S12, S13, S17, S20, S24, S25 Proposal detail | `viewmodels/proposals/proposal_view_model.dart` → `ProposalActionViewModel` | `ProposalService`, `AnalyticsService`, `CrashService` | Firestore transaction approve/undo/discard |
| S11 Add member | `viewmodels/proposals/proposal_view_model.dart` → `proposalStudentsProvider`, `ProposalActionViewModel` | `ClassService`, `ProposalService`, `AnalyticsService` | Firestore |
| S15 No match | `viewmodels/classes/matching_view_model.dart` (state `Empty`) | `MatchingService` | — |
| S16, S21 Add student | `viewmodels/proposals/proposal_view_model.dart` → `ProposalActionViewModel.createManual` | `ClassService`, `ProposalService`, `CrashService` | Firestore transaction |
| S22 Import class list | `viewmodels/classes/import_class_view_model.dart` → `ImportClassViewModel` | `ClassService`, `AnalyticsService`, `CrashService` | `CsvClassImporter` + Firestore batch |
| S23 Import result | `viewmodels/classes/import_class_view_model.dart` (`ImportClassState.result`) | `ClassService` | Firestore `classes/{id}` |
| S6 Profile | `viewmodels/profile/profile_view_model.dart` → `ProfileViewModel` | `AuthService`, `AnalyticsService`, `CrashService` | Firebase session |
| S6 demo: export PDF | `viewmodels/profile/report_demo_view_model.dart` → `ReportDemoActions` | `ReportService`, `StorageService`, `AnalyticsService`, `CrashService` | `pdf` package → Firestore `reports/{id}/files/pdf` |
| S6 demo: Remote Config | `viewmodels/config/app_config_view_model.dart`, `viewmodels/notifications/config_demo_view_model.dart` | `ConfigService` | Firebase Remote Config (realtime) |
| S6 demo: notification center | `viewmodels/notifications/inbox_view_model.dart`, `notification_taps_view_model.dart` | `NotificationService`, `NotificationStore` | Firestore `users/{uid}/notifications` + FCM |
| My team (sinh viên) | `viewmodels/classes/my_team_view_model.dart` → `myTeamProvider` | `ClassService` | Firestore `classes/{id}/teams` |
| D: danh sách / nộp / duyệt đề tài | `viewmodels/topics/topic_view_model.dart` → `mentorTopicsProvider`, `myTopicProvider`, `topicProvider`, `TopicActionViewModel` | `TopicService`, `ConfigService` | Firestore `topics/{classId}_{teamId}` |
| E: khung giờ / đặt lịch / xác nhận | `viewmodels/schedule/schedule_view_model.dart` → `slotsProvider`, `bookingsProvider`, `bookingProvider`, `ScheduleActionViewModel` | `BookingService` | Firestore `mentors/{uid}/slots`, `bookings` |
| F: biên bản / ký / xuất PDF | `viewmodels/schedule/schedule_view_model.dart` → `minutesProvider` | `MeetingService` | Firestore `minutes/{bookingId}` |
| (toàn cục) | `viewmodels/instrumentation.dart` | `AnalyticsService`, `CrashService` | Firebase Analytics / Crashlytics |
| (toàn cục) | `viewmodels/telemetry.dart` | `CrashService` | Firebase Crashlytics |

## 5. Firebase

| Dịch vụ | Bản cài đặt | Trạng thái | Xử lý lỗi |
|---|---|---|---|
| Authentication (Google/email/SĐT) | `firebase/firebase_auth_service.dart` | xong | `auth_error_mapper.dart` → `AppError`; hủy → `CancelledError` + thông báo. Giữ phiên khi lỗi mạng tạm thời (F1), đăng xuất khi tài khoản không phải mentor. |
| Cloud Firestore | `firebase/firestore_class_service.dart`, `firestore_proposal_service.dart`, `firestore_mentor_profile_service.dart`, `firestore_notification_store.dart`, `firestore_topic_service.dart`, `firestore_booking_service.dart`, `firestore_meeting_service.dart` | xong | `permission-denied` → `PermissionDeniedError`, `unavailable` → `NetworkError`, `deadline-exceeded` → `TimeoutAppError`. Duyệt nhóm dùng **transaction** (chống gán trùng SV). Bỏ qua một bản ghi hỏng thay vì làm hỏng cả danh sách (F8). |
| Lưu file (Firestore) | `firebase/firestore_report_storage.dart`, `firestore_topic_service.dart` | xong | Gói **Spark** không có Cloud Storage: bytes nằm trong 1 tài liệu Firestore (`reports/{id}/files/pdf`, `topics/{id}/files/outline`), ≤ 900 KB (dưới trần 1 MiB của Firestore). Rules chỉ cho chủ sở hữu / nhóm và mentor đọc. PDF biên bản tạo lại trên máy, không lưu. |
| Analytics | `firebase/firebase_analytics_service.dart` | xong | Gọi qua `trackAnalytics` (best effort), không chặn luồng. |
| Crashlytics | `firebase/firebase_crash_service.dart` + `main.dart` | xong | `FlutterError.onError` + `PlatformDispatcher.onError` cho fatal; `recordNonFatal` cho lỗi đã xử lý (import, AI timeout, upload). Custom key `role`, `class_id`. Lọc `ValidationError`/`CancelledError`. |
| Remote Config | `firebase/firebase_config_service.dart` | xong | Realtime `onConfigUpdated`; mặc định bundle `firebase/remote-config-defaults.json`; lỗi fetch → giữ giá trị cache/default. |
| FCM | `firebase/fcm_notification_service.dart`, `background_notification_handler.dart`, `activity_messages.dart` | xong | Xử lý foreground/background/terminated; đăng ký token vào `users/{uid}/fcmTokens` (thử lại tối đa 3 lần — F2); deep-link qua allow-list. Gói Spark không có Cloud Functions nên thông báo Flow D/E/F do `activityMessages()` sinh ở client. |
| PDF generation | `firebase/pdf_report_service.dart` | xong | Sinh PDF từ **cùng** stream Firestore mà mentor đang xem → file phản ánh đúng màn hình. |

**Schema Firestore chi tiết** (từng trường, ràng buộc, state machine của
`Proposal`, index) nằm ở **[docs/data-model.md](data-model.md)** — đó là hợp
đồng tích hợp giữa app và `firebase/firestore.rules`.

## 6. Sơ đồ sequence — Flow A đầy đủ (nhập lớp → AI ghép → duyệt → xuất PDF)

```mermaid
sequenceDiagram
  autonumber
  participant U as Mentor
  participant S as Screens (S22→S23→S3→S8→S9→S10)
  participant VM as ViewModels
  participant SV as Services (interface)
  participant FB as Firebase (Firestore/Analytics)

  U->>S: chọn file CSV
  S->>VM: ImportClassViewModel.chooseFile()
  VM->>SV: ClassService.parseImportFile(fileName, bytes)
  SV->>SV: CsvClassImporter.parse() (validate 5 cột, ≤ 1 MiB)
  SV-->>VM: ImportPreview
  VM-->>S: state = preview (Columns detected)
  U->>S: bấm "Import 42 students"
  S->>VM: importClass()
  VM->>SV: ClassService.importClass(preview)
  SV->>FB: batch: classes/{id}, students/{mssv}, teams/{id}
  FB-->>SV: commit
  SV-->>VM: ImportResult(42, 30, 12)
  VM->>FB: Analytics: class_import(row_count, available_count)
  VM-->>S: S23 hiện 3 số → "Open Class A"
  U->>S: S3 → "Match with AI"
  S->>VM: MatchingViewModel.start()
  VM->>FB: Analytics: ai_match_start(student_count, team_count)
  VM->>SV: MatchingService.propose(classId, students, teams)
  SV-->>VM: List<Proposal> (rule-based, ưu tiên bổ sung ngành còn thiếu)
  VM->>FB: Firestore batch: proposals/{id} (status=pending)
  VM->>FB: Analytics: ai_match_result(proposal_count, no_match, duration_ms)
  VM-->>S: S9 (giới hạn bởi max_proposals_shown)
  U->>S: mở 1 đề xuất → S10
  S->>VM: proposalDetailProvider(id)
  VM->>SV: ProposalService.watchProposal(id)
  SV->>FB: Firestore snapshot
  FB-->>SV: Proposal
  SV-->>VM: Proposal → S10 (MajorSlotRow 48dp, FitChip)
  U->>S: "Approve proposal" → S12
  S->>VM: ProposalActionViewModel.approve(proposal)
  VM->>SV: ProposalService.approve(id)
  SV->>FB: transaction: teams/{id}.memberIds += SV, students/{mssv}.teamId, proposal.status=approved
  FB-->>SV: commit
  VM->>FB: Analytics: proposal_approve(member_count, major_count, source, edited)
  VM-->>S: snackbar "Approved" + Undo (5 s, transaction undoApprove)
  U->>S: S6 → Export PDF
  S->>VM: ReportDemoActions.buildPdf(classId) → upload()
  VM->>SV: ReportService.buildClassTeamsPdf(classId)
  SV->>FB: đọc lại classes/{id}/teams (cùng dữ liệu đang hiển thị)
  SV-->>VM: BuiltReport(bytes, teamCount)
  VM->>SV: StorageService.uploadReport(classId, bytes)
  SV->>FB: Firestore: reports/{id}/files/pdf (bytes ≤ 900 KB)
  SV-->>VM: UploadDone(Report + filePath)
  VM->>FB: Analytics: report_export(team_count, file_size_kb)
  VM-->>S: hiện progress + đường dẫn file trong Firestore
```

## 7. Quyết định thiết kế đáng ghi lại

| # | Quyết định | Lý do |
|---|---|---|
| D-a | `Notifier` viết tay thay vì `@riverpod` codegen | Không sinh code, review diff dễ, đủ cho 4 lớp; tránh phụ thuộc build_runner trong CI của trường. |
| D-b | `ViewState<T>` sealed thay vì `AsyncValue` | Bắt buộc rõ 4 trạng thái (loading/empty/data/error) như rubric Lab 3 §10 "explicit state model per screen"; `Empty` tách riêng khỏi `Data([])`. |
| D-c | Service interface thuần Dart + fake trong `services/fakes/` | ViewModel test được với fake, không cần Firebase. Bắt buộc rubric: "services are injected… a ViewModel can be tested with a fake service". |
| D-d | `RuleBasedMatchingService` thay vì mô hình ML | Lab 3 §3 nói "no ML model, as in Lab 2"; thuật toán quy tắc là giải pháp tốt, giải thích được và test được thuần Dart. |
| D-e | Approve/undo bằng Firestore **transaction** | Roster là dữ liệu dùng chung; transaction chống hai mentor duyệt trùng một sinh viên. |
| D-f | Gói **Spark**: lưu PDF trong Firestore thay vì Cloud Storage | Cloud Storage bucket và Cloud Functions không dùng được trên gói Spark (miễn phí) — đề chỉ yêu cầu "Firebase". Bytes nằm ở `reports/{id}/files/pdf` (≤ 900 KB) và đường dẫn vẫn hiển thị trong UI để rubric "đường dẫn file" vẫn được chứng minh. |
| D-g | `RemoteConfigService` đọc realtime + default bundle | Rubric Remote Config: "changing the value in the console changes the app without a new build" → cần `onConfigUpdated`, không chỉ `fetch()` khi mở app. |
| D-h | `InstrumentationRef` extension thay vì try/catch lặp lại | Một chỗ duy nhất cho best-effort tracking → giảm rủi ro quên bọc try/catch, dễ review. |
| D-i | Hai helper telemetry (`instrumentation.dart` + `telemetry.dart`) cùng tồn tại | Hai nhánh phát triển độc lập (Flow A/B/C và Flow D/E/F) đưa vào cùng một repo; giữ cả hai tránh việc viết lại logic đã được test. Cả hai đều best-effort, không phụ thuộc lẫn nhau. |
| D-j | Vài luồng sinh viên (D/E/F) dùng `collectionGroup` / truy vấn theo `classId` | Mentor chỉ có vài lớp nên chi phí đọc chấp nhận được; sửa cần đổi route để mang `classId` (đã ghi ở F6). |
