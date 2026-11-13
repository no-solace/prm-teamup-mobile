# Quyết định cho bộ khung dự án

> Ngày lập: 05/11/2026. Mục đích: chốt mọi lựa chọn kỹ thuật **trước khi** tạo khung, để 4 người code song song từ ngày 2 mà không phải sửa lại cấu trúc.
> Cách dùng: đọc mục 1 (ràng buộc cứng), sau đó đi qua các quyết định ở mục 3. Mỗi quyết định có các phương án, đề xuất và lý do. Nhóm chỉ cần duyệt bảng tóm tắt ở mục 4 (khoảng 15 phút), đánh dấu chỗ không đồng ý, rồi Ken dựng khung theo mục 5.

## 1. Nguyên tắc cơ sở (ràng buộc cứng, không bàn lại)

Đây là những điều được chấm điểm hoặc ghi rõ trong đề. Mọi quyết định ở mục 3 phải thỏa mãn các điều này.

| # | Ràng buộc | Nguồn | Ảnh hưởng tới khung |
|---|---|---|---|
| C1 | MVVM với Provider hoặc Riverpod; phụ thuộc chỉ đi xuống, lớp dưới không import lớp trên | Lab 3 mục 5 | Cấu trúc thư mục theo lớp, có quy tắc import |
| C2 | Widget không gọi `FirebaseAuth.instance`, `FirebaseAnalytics.instance` hay SDK nào khác; mọi lời gọi ra ngoài đi qua service | Lab 3 mục 5, rubric "Layer separation" 0.5 | Interface service + bản cài đặt Firebase tách riêng |
| C3 | Logic (lọc, xếp hạng, gộp, kiểm tra) nằm ở ViewModel hoặc service, không nằm trong `build()` | Lab 3 mục 5 | ViewModel giữ toàn bộ logic màn |
| C4 | Mỗi màn tải dữ liệu có state model rõ (sealed class hoặc enum: loading, empty, error, data) do ViewModel sở hữu | Lab 3 mục 5, rubric "State management" 0.25 | Kiểu state dùng chung |
| C5 | Service được inject qua Riverpod, để test ViewModel bằng service fake; không có state toàn cục thay đổi được, không gọi singleton từ widget | Lab 3 mục 5, rubric | Provider cho từng service, override được |
| C6 | Token nằm ở một chỗ (`lib/theme/`): `ColorScheme`, `TextTheme`, hằng spacing/radius/elevation. Màu, cỡ chữ, padding hard-code trong màn bị tính là lỗi | Lab 3 mục 5 | Theme hoàn chỉnh ngay trong khung |
| C7 | Mỗi component Lab 2 là một widget dùng lại trong `widgets/`, có biến thể và trạng thái là tham số | Lab 3 mục 5, rubric "Fidelity" 0.5 | Thư viện widget là một phần của khung |
| C8 | Giữ cấu trúc điều hướng Lab 2: 3 tab Classes / Proposals / Profile, các màn lồng nhau đẩy lên trên tab; Back chạy đúng ở mọi màn | Lab 3 mục 3, handoff | `go_router` + `StatefulShellRoute` |
| C9 | Truy cập: vùng chạm ≥ 48 dp, chữ ≥ 14 sp, không truyền thông tin chỉ bằng màu, kiểm ở 360 và 412 dp | Lab 3 mục 5, handoff | Giá trị mặc định trong theme và widget |
| C10 | Bản nộp không có dữ liệu cứng hay dữ liệu giả | Lab 3 mục 3, rubric "Data and content" | Fake không được nối vào bản chạy chính |
| C11 | Cấu trúc repo: `lib/`, `e2e_test/`, `android/`, `firebase/`, `docs/`, `evidence/`, `report/`, `slides/` | Lab 3 mục 9 | Vị trí thư mục |
| C12 | Ghim phiên bản trong `pubspec.yaml` và `README.md` | Lab 3 mục 3 | Không dùng `^` |
| C13 | Không commit service account, API secret, keystore; được commit `google-services.json` | Lab 3 mục 9 | `.gitignore` |
| C14 | Chạy trên thiết bị Android thật | Ghi chú giảng viên | SHA-1, quyền Android 13+ |
| C15 | Final: model và service Firestore dùng chung trong `packages/core/`, thêm client web | Đề Final mục 6 | Model/service không phụ thuộc Flutter UI để sau này tách được |

## 2. Hiện trạng môi trường (máy Cuong, 05/11/2026)

| Công cụ | Phiên bản | Ghi chú |
|---|---|---|
| Flutter | 3.47.9 stable | Cả nhóm nên dùng **cùng bản**; ghi vào README |
| Dart | 3.13.7 | Có sẵn sealed class và pattern matching (dùng cho C4) |
| JDK | 25.0.5 | **Rủi ro:** Gradle/AGP của Android thường chưa hỗ trợ JDK mới nhất. Nên trỏ Flutter về JDK 17 hoặc 21 (JBR của Android Studio): `flutter config --jdk-dir <đường dẫn>` |
| Firebase CLI | **15.35.0** (chạy qua `npx firebase-tools@15.35.0`) | Cần cho `firebase deploy` rules và Emulator: `npm i -g firebase-tools` hoặc dùng `npx` |
| FlutterFire CLI | **chưa cài** | Cần cho `flutterfire configure`: `dart pub global activate flutterfire_cli` |

Mỗi thành viên kiểm tra lại máy mình bằng `flutter doctor -v` trước ngày 1.

## 3. Các quyết định

### D1. App nằm ở đâu trong repo

| Phương án | Ưu | Nhược |
|---|---|---|
| **A. `lib/`, `android/` ở gốc repo** | Khớp đúng cấu trúc đề Lab 3 yêu cầu (C11); lệnh `flutter` chạy ngay ở gốc | Final cần `mobile/` và `packages/core/`, nên phải chuyển thư mục |
| B. `mobile/` ngay từ bây giờ | Không phải chuyển ở Final | Lệch cấu trúc đề Lab 3, phải giải thích; người chấm có thể tìm `lib/` ở gốc |
| C. `app/` (như PROPOSAL bản cũ) | — | Lệch cả Lab 3 lẫn Final |

**Đề xuất: A.** Lab 3 được chấm theo cấu trúc trong đề. Đến Final dùng `git mv` để chuyển, và lịch sử commit vẫn giữ nguyên. Để việc chuyển dễ, model và service không import gì từ `screens/` hay `widgets/` (C15).

### D2. Tên package và applicationId

Đổi sau khi đã đăng ký app trên Firebase thì phải đăng ký lại và tạo lại `google-services.json`, nên **chốt một lần**.

**Đã chốt (05/11/2026):** tên Dart package `teamup_exe`, applicationId và namespace `com.group6.teamup_exe` (Flutter sinh từ `--org com.group6`). Tên hiển thị "TeamUp EXE".

### D3. Cách viết Riverpod

| Phương án | Ưu | Nhược |
|---|---|---|
| **A. `Notifier` / `AsyncNotifier` viết tay, không sinh mã** | Không cần `build_runner`; dễ đọc, dễ giải thích ở buổi kiểm tra 5 phút; ít lỗi môi trường | Viết dài hơn một chút |
| B. `riverpod_generator` (`@riverpod`) | Gọn | Phải chạy `build_runner`, file `.g.dart` hay gây conflict khi merge giữa 4 người; mất thời gian khi chỉ có 7 ngày |

**Đề xuất: A**, dùng `flutter_riverpod`, không dùng code generation.

### D4. State model của màn (C4)

| Phương án | Ưu | Nhược |
|---|---|---|
| A. `AsyncValue<T>` của Riverpod | Có sẵn | Không có trạng thái **empty**; đề yêu cầu state model rõ ràng có empty |
| **B. Sealed class dùng chung `ViewState<T>`** gồm `Loading`, `Empty`, `Data(T)`, `Failure(AppError)` | Khớp đúng chữ trong đề; `switch` bắt buộc xử lý đủ 4 nhánh nên không màn nào quên trạng thái | Phải tự chuyển từ Future/Stream sang |

**Đề xuất: B.** Thêm widget `ViewStateBuilder` nhận `ViewState` và 4 builder. Loading, empty và error mặc định dùng `StatusView` của Lab 2, nên mọi màn hiện trạng thái giống nhau. Các màn tự chuyển trạng thái theo thiết kế (S4 rỗng thì chuyển S14, S8 lỗi mạng thì chuyển S18) xử lý trong ViewModel.

### D5. Cấu trúc thư mục

| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Theo lớp, đúng gợi ý của đề**, bên trong chia theo màn | Khớp đề, không phải giải thích; dễ chỉ ra "View không gọi SDK" | Một tính năng nằm rải ở nhiều thư mục |
| B. Theo tính năng (`features/flow_a/...`) | Mỗi người làm gọn trong thư mục của mình | Phải giải thích trong `architecture.md`; dễ để service lọt vào thư mục UI |

**Đề xuất: A.** Để 4 người ít đụng file của nhau, `screens/` và `viewmodels/` chia thư mục con theo màn:

```text
lib/
├── main.dart               # khởi tạo Firebase, Crashlytics, handler FCM nền, ProviderScope, chạy bản thật
├── main_fake.dart          # chỉ dùng khi dev: override mọi service bằng bản fake (D6)
├── app.dart                # MaterialApp.router + theme
├── models/                 # dữ liệu thuần Dart: ClassRoom, Student, Team, Proposal, Report, AppNotification
├── services/               # interface (abstract class) + AppError; không import Firebase
│   └── fakes/              # bản fake của từng service, dùng cho test và main_fake.dart
├── firebase/               # bản cài đặt dùng Firebase SDK: FirebaseAuthService, FirestoreClassService…
├── providers/              # provider cho từng service (nơi duy nhất nối interface với bản cài đặt)
├── viewmodels/             # mỗi màn một Notifier, giữ ViewState
│   ├── auth/  classes/  proposals/  manual_match/  profile/
├── screens/                # mỗi màn một thư mục, chỉ dựng UI từ ViewState
│   ├── sign_in/  my_classes/  import_class/  class_detail/ …
├── widgets/                # component Lab 2 dùng lại (D9)
├── router/                 # app_router.dart, route names
├── theme/                  # colors, typography, spacing, radius, app_theme.dart
└── utils/                  # định dạng, đọc CSV, hằng số
```

**Quy tắc import (kiểm bằng script, D14):**

| Thư mục | Được import | Không được import |
|---|---|---|
| `screens/`, `widgets/` | `viewmodels/`, `models/`, `theme/`, `widgets/`, `router/` | `firebase/`, `package:firebase_*`, `package:cloud_firestore` |
| `viewmodels/` | `services/`, `models/`, `providers/` | `screens/`, `widgets/`, `firebase/`, `package:flutter/material.dart` (trừ khi thật cần) |
| `services/`, `models/` | `models/` | Flutter UI, `firebase/` |
| `firebase/` | `services/`, `models/`, SDK Firebase | `screens/`, `viewmodels/` |

### D6. Service fake nằm đâu (C5 và C10 kéo về hai phía)

Fake cần cho hai việc: (1) dev chạy màn khi Firestore chưa có dữ liệu (ngày 2-3), (2) unit test ViewModel. Nhưng bản nộp không được có dữ liệu giả (C10).

| Phương án | Ưu | Nhược |
|---|---|---|
| A. Fake chỉ ở `test/` | Bản nộp chắc chắn sạch | Không chạy app trên fake được trong ngày 2-3 |
| **B. Fake ở `lib/services/fakes/`, chỉ được nối trong `main_fake.dart`** | Vừa dev vừa test được; `main.dart` (bản nộp) chỉ dùng Firebase | Phải giải thích trong `architecture.md` và README rằng bản nộp chạy `main.dart` |
| C. Cờ `if (kDebugMode) useFake` | — | Dễ lọt dữ liệu giả vào bản demo; người chấm có thể coi là mock |

**Đề xuất: B.** Chạy dev: `flutter run -t lib/main_fake.dart`. Bản nộp, ARTEMIS và video dùng `flutter run` (tức `main.dart`).

### D7. Điều hướng (C8)

- `go_router` với `StatefulShellRoute.indexedStack`, 3 nhánh: `/classes`, `/proposals`, `/profile`. Mỗi tab giữ stack riêng.
- `redirect` theo trạng thái đăng nhập, lắng nghe `authStateChanges` qua `refreshListenable`: chưa đăng nhập thì về `/sign-in`, đã đăng nhập thì không vào lại `/sign-in`.
- **Không phải màn nào cũng là route.** Trong 25 màn có:

| Loại | Màn | Cách làm |
|---|---|---|
| Route | S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S15, S16, S22, S23 | `GoRoute` |
| Trạng thái của route khác | S19 (S1), S13 (S11), S14 (S9), S18 (S8), S20 (S10, `source: manual`), S21 (S16), S25 (S10) | Một màn, nhiều `ViewState` |
| Dialog | S12, S17, S24 | `showDialog` (widget `ConfirmDialog`) |

- Bảng route đề xuất:

```text
/sign-in                                   S1/S19
/classes                                   S2
/classes/import                            S22 → /classes/import/result (S23)
/classes/:classId                          S3
/classes/:classId/no-team                  S4
/classes/:classId/need-members             S5
/classes/:classId/students/:studentId      S7
/classes/:classId/matching                 S8 (S18)
/classes/:classId/no-match                 S15
/classes/:classId/add-student              S16 (S21)
/proposals                                 S9 (S14)
/proposals/:proposalId                     S10 (S20, S25)
/proposals/:proposalId/add-member          S11 (S13)
/profile                                   S6 + mục Firebase demo
```

- FCM gửi route trong `data.route` (ví dụ `/proposals`). Khi người dùng chạm thông báo, app gọi `router.go(route)`. Chỉ chấp nhận route có trong danh sách trên.

### D8. Theme và font (C6, C9)

- Token lấy nguyên từ Bảng 1 của `flutter-handoff.md`, tách thành `app_colors.dart`, `app_typography.dart`, `app_spacing.dart` (`kSpaceXs…Xl` = 4/8/16/24/32, `kRadiusSm…Full` = 8/12/16/999), `app_theme.dart`. Chỉ có theme sáng.
- Đặt luôn `componentTheme` (FilledButton, Card, InputDecoration, Chip, NavigationBar) trong `ThemeData`. Như vậy màn chỉ cần dùng widget mặc định là đã đúng 48 dp, đúng màu.

| Font Be Vietnam Pro | Ưu | Nhược |
|---|---|---|
| `google_fonts` | Không phải tải file | Tải font qua mạng lúc chạy; mất mạng (S18) thì font lệch, ảnh hưởng ảnh chụp |
| **Đóng gói TTF trong `assets/fonts/`** | Chạy offline, ổn định | Thêm vài trăm KB |

**Đề xuất:** đóng gói TTF (Regular 400, SemiBold 600, Bold 700). Font có license OFL nên được phép.

### D9. Thư viện widget (C7)

Theo Bảng 2 của handoff. Khung tạo sẵn các widget có chữ ký (signature) cố định để mọi người dùng ngay:

| Widget | Dùng ở | Tham số chính |
|---|---|---|
| `AppButton` | mọi màn | `variant` (primary / tonal / text / destructive), `loading`, `onPressed` |
| `AppTextField` | S1, S16 | `label`, `errorText`, `keyboardType` |
| `AppCard` | S2, S5, S9 | `onTap`, `child` |
| `MajorSlotRow` / `MajorSlot` | S5, S9, S10, S20, S25 | danh sách ngành, `size` 40/48, ô trống nét đứt, ô đề xuất có dấu + |
| `FitChip` | S9, S10 | `strong` / `good` (icon + chữ, không chỉ màu) |
| `MajorFilterChips` | S4, S11, S16 | ngành đang chọn |
| `StudentRow` | S4, S11, S16 | `selectable`, `locked` ("In a team"), `checked` |
| `StatTriple` | S3, S23 | 3 số + nhãn |
| `StatusView` | loading / empty / error | `icon`, `title`, `message`, `action` |
| `ConfirmDialog` | S12, S17, S24 | `destructive` |
| `ErrorBanner` | S13, S25 | `message` (icon + chữ) |
| `ViewStateBuilder` | mọi màn tải dữ liệu | D4 |

Mọi widget bấm được đều bọc `Semantics(label: …)` sẵn (D16).

### D10. Firebase: dự án và cấu hình

- **Một** dự án Firebase cho cả nhóm. Ken tạo. SHA-1 debug của **4 máy** được thêm vào app Android. *(12/11: không nâng Blaze; dự án ở gói Spark, file lưu trong Firestore, không có Cloud Storage và Cloud Functions. Xem `docs/PROPOSAL.md` mục 10.)*
- `flutterfire configure` sinh `lib/firebase_options.dart` và `android/app/google-services.json`. **Commit cả hai** (C13), để ai clone về cũng chạy được.
- Thư mục `firebase/`: `firebase.json`, `firestore.rules`, `remote-config-defaults.json`, `firestore.indexes.json`. Deploy rules bằng Firebase CLI.
- Khởi tạo trong `main.dart`, theo thứ tự: `Firebase.initializeApp` → gắn `FlutterError.onError` và `PlatformDispatcher.onError` vào Crashlytics → đăng ký `FirebaseMessaging.onBackgroundMessage` (phải là hàm top-level) → `runApp`. Remote Config fetch **sau** `runApp`, để mất mạng không chặn màn đầu.

### D11. Mô hình dữ liệu Firestore (C15)

| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Sub-collection dưới `classes/{classId}`** (`students`, `teams`, `proposals`) | Rules đơn giản: chỉ cần kiểm `mentorUid` ở document lớp; truy vấn theo lớp tự nhiên | Truy vấn chéo lớp cần `collectionGroup` (Lab 3 không cần) |
| B. Collection phẳng, mỗi document có `classId` | Linh hoạt cho dashboard web ở Final | Rules phải kiểm `classId` ở mọi document; dễ hở |

**Đề xuất: A.** Các con số ở S2, S3 (số SV, số chưa có nhóm, số nhóm thiếu) **tính trên client** từ stream (mỗi lớp khoảng 40 SV) thay vì lưu sẵn, để tránh dữ liệu lệch nhau. Ở Final, dashboard web dùng aggregation query. Chi tiết trường ghi ở `docs/data-model.md`.

- Ghi các thay đổi liên quan nhiều document (Approve: cập nhật `teams` + `students` + `proposals`) bằng **`WriteBatch`/transaction** trong service, để không bao giờ có nhóm vượt 6 do ghi dở.
- Undo 5 giây ở S14: giữ thao tác ghi trong ViewModel 5 giây rồi mới commit, hoặc ghi ngay và Undo bằng một batch đảo ngược. **Đề xuất:** ghi ngay rồi đảo ngược, vì nếu app bị tắt trong 5 giây đó thì dữ liệu vẫn đúng.

### D12. Mô hình lỗi

- Service bắt exception của SDK và trả về `AppError` (sealed): `Network`, `PermissionDenied`, `Cancelled`, `NotFound`, `Validation(message)`, `Unknown`. Widget không bao giờ thấy `FirebaseException`.
- Mỗi `AppError` có câu thông báo cho người dùng, lấy đúng chữ Figma (ví dụ "You're offline" ở S18).
- Lỗi thật đáng ghi lại (import sai định dạng, AI quá 30 giây, upload lỗi) gửi `CrashService.recordNonFatal(error, reason)` **ở service**, không ở UI.

### D13. Danh sách package (ghim phiên bản, C12)

| Mục đích | Package |
|---|---|
| State, DI | `flutter_riverpod` |
| Điều hướng | `go_router` |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `firebase_analytics`, `firebase_crashlytics`, `firebase_remote_config` |
| Đăng nhập | `google_sign_in` |
| Thông báo khi app đang mở | `flutter_local_notifications` (FCM không tự hiện banner khi app ở foreground) |
| Import | `file_picker`, `csv` (`excel` chỉ thêm nếu còn thời gian, xem PHAN_CONG mục 5) |
| PDF | `pdf`, `printing` |
| Ô nét đứt | `dotted_border` |
| Test | `flutter_test`, `mocktail` (nếu cần) |

Cách ghim: chạy `flutter pub add …` để lấy bản mới nhất tương thích, rồi **bỏ dấu `^`** trong `pubspec.yaml` và commit cả `pubspec.lock`. (`.gitignore` cũ là bản của repo Flutter framework và bỏ qua `*.lock`; đã thay bằng `.gitignore` cho app.)

### D14. Lint và kiểm lớp

- `flutter_lints` (mặc định) + `analysis_options.yaml` bật thêm: `prefer_const_constructors`, `avoid_print`, `require_trailing_commas`.
- Script `tools/check_layers.sh` dùng grep để báo lỗi nếu `lib/screens/` hoặc `lib/widgets/` có `import 'package:firebase_` / `cloud_firestore`, hoặc nếu `lib/screens/` có `Color(0x` / `fontSize:` / `EdgeInsets.all(<số>)` hard-code. Chạy trước mỗi PR. Đây cũng là bằng chứng tốt cho tiêu chí "Layer separation".
- **Đề xuất thêm:** GitHub Actions chạy `flutter analyze`, `flutter test`, `tools/check_layers.sh` cho mỗi PR. Mất khoảng 15 phút để cài, nhưng đỡ được lỗi khi merge.

### D15. Quy ước Git

- Nhánh: `feature/skeleton`, `feature/flow-a`, `feature/flow-b`, `feature/flow-c`, `feature/auth-profile`. Mỗi PR cần 1 người review và phải qua CI.
- Commit: `feat(flow-b): S10 proposal detail`, `fix(CR-03): …` (mã phát hiện code review, đúng yêu cầu Lab 3 mục 8), `docs: …`, `test: …`.
- Thứ tự giai đoạn trong lịch sử Git (Lab 3 mục 4): commit đầu là `docs/design-traceability.md` + `architecture.md`, sau đó mới đến khung và tính năng.

### D16. Chuẩn bị cho kiểm thử

- `test/` chứa unit test ViewModel (dùng fake ở D6) và test `MatchingService`.
- `e2e_test/` là dự án Python riêng (`pyproject.toml`, `conftest.py`). Không đặt trong `test/` của Flutter.
- **Quy ước nhãn `Semantics`:** dùng đúng chữ hiện trên màn (ví dụ `Match with AI`, `Approve`). Hàng danh sách có nhãn theo mẫu `Student: <tên>, <ngành>`. ARTEMIS đọc cây accessibility trước, nên đặt nhãn thống nhất từ đầu sẽ giúp test ổn định.

### D17. Service quan sát (Analytics, Crashlytics, Remote Config)

- `AnalyticsService` có **một hàm cho mỗi sự kiện** (`logProposalApprove(memberCount:, majorCount:, source:, edited:)`) thay vì `logEvent(String, Map)`. Cách này tránh gõ sai tên sự kiện và không cho phép truyền email hay tên (đề cấm PII).
- `ConfigService` trả về giá trị đã có kiểu (`bool aiMatchingEnabled`, `int maxProposalsShown`) và stream thay đổi. Dùng `onConfigUpdated` (Remote Config realtime) để giá trị đổi trên Console hiện ngay khi demo, không cần mở lại app.
- `CrashService.setUser(uid, role, classId)` được gọi khi đăng nhập và khi mở lớp.

### D18. Cấu hình Android (C14)

- `minSdk` 23 trở lên (yêu cầu của Firebase), `targetSdk` theo bản Flutter đang dùng.
- `AndroidManifest.xml`: quyền `POST_NOTIFICATIONS` (Android 13+), notification channel mặc định cho FCM.
- Trỏ Flutter về JDK 17/21 (mục 2) nếu build Gradle báo lỗi phiên bản Java.

### D19. Ngôn ngữ

- Chữ trên giao diện: **tiếng Anh**, lấy đúng như Figma (Lab 2 dùng tiếng Anh). Không dịch, vì mỗi chỗ khác Figma đều phải ghi lại.
- Tên trong code: tiếng Anh. Comment và tài liệu: tiếng Việt.

## 4. Bảng tóm tắt để nhóm duyệt

| # | Quyết định | Đề xuất | Đồng ý? |
|---|---|---|---|
| D1 | Vị trí app | `lib/` ở gốc repo, chuyển sang `mobile/` ở Final | ☐ |
| D2 | Package / applicationId | `teamup_exe` / `com.group6.teamup_exe` | ☑ |
| D3 | Riverpod | `Notifier` viết tay, không code generation | ☐ |
| D4 | State model | Sealed `ViewState<T>` + `ViewStateBuilder` | ☐ |
| D5 | Thư mục | Theo lớp (đúng gợi ý đề), chia thư mục con theo màn | ☐ |
| D6 | Fake | `lib/services/fakes/`, chỉ nối trong `main_fake.dart` | ☐ |
| D7 | Điều hướng | `go_router` + `StatefulShellRoute`, 15 route, 7 màn là trạng thái, 3 dialog | ☐ |
| D8 | Font | Đóng gói TTF Be Vietnam Pro | ☐ |
| D9 | Widget | 12 widget dùng chung có sẵn trong khung | ☐ |
| D10 | Firebase | 1 dự án, commit `firebase_options.dart` + `google-services.json` | ☐ |
| D11 | Firestore | Sub-collection dưới `classes`, tính số liệu trên client, ghi bằng batch | ☐ |
| D12 | Lỗi | `AppError` sealed, non-fatal ghi ở service | ☐ |
| D13 | Package | Danh sách ở D13, ghim phiên bản, commit `pubspec.lock` | ☐ |
| D14 | Lint | `flutter_lints` + `check_layers.sh` + CI | ☐ |
| D15 | Git | Nhánh theo flow, commit `fix(CR-xx)` | ☐ |
| D16 | Kiểm thử | Fake cho unit test, nhãn `Semantics` theo chữ trên màn | ☐ |
| D17 | Quan sát | Mỗi sự kiện một hàm; Remote Config realtime | ☐ |
| D18 | Android | minSdk 23+, `POST_NOTIFICATIONS`, JDK 17/21 | ☐ |
| D19 | Ngôn ngữ | UI tiếng Anh như Figma | ☐ |

## 5. Khung phải có những gì khi bàn giao (hạn trưa ngày 2)

- [ ] `flutter run` chạy được trên máy thật của cả 4 người; đăng nhập Google được trên cả 4 máy *(chờ cấu hình Firebase, xem 5.1)*
- [x] `flutter run -t lib/main_fake.dart` chạy toàn app trên fake (đã build được APK debug)
- [x] Theme đủ token; 12 widget ở D9 có trang xem thử (một route debug `/_gallery`, chỉ có trong `main_fake.dart`, mở từ Profile)
- [x] Router có đủ route ở D7, mỗi route là một màn trống có tiêu đề và Back đúng; 3 tab giữ stack riêng
- [x] `ViewState`, `ViewStateBuilder`, `AppError` có sẵn
- [x] Interface + fake cho mọi service trong PROPOSAL mục 4; provider nối sẵn
- [x] Firebase khởi tạo trong `main.dart`: Crashlytics bắt lỗi, handler FCM nền, Remote Config sau `runApp` *(chưa chạy thật được vì thiếu `firebase_options.dart`)*
- [x] `firebase/` có rules mặc định **từ chối tất cả** (sau đó mỗi người mở dần cho collection của mình). `firebase.json`, `.firebaserc` đặt ở gốc repo vì Firebase CLI yêu cầu
- [x] `tools/check_layers.sh`, `analysis_options.yaml` xanh; CI đã viết (`.github/workflows/ci.yml`), chạy lần đầu khi push
- [x] `docs/architecture.md` bản đầu: cây thư mục, sơ đồ lớp (Mermaid), bảng ViewModel → Service (để trống, mỗi người điền)
- [x] README: lệnh chạy, phiên bản Flutter/Dart/JDK, cách thêm SHA-1

### 5.1. Trạng thái (cập nhật 05/11/2026)

**Đã kiểm:** `flutter analyze` không lỗi, `flutter test` 3/3 qua, `bash tools/check_layers.sh` báo "Layers OK", `flutter build apk --debug -t lib/main_fake.dart` thành công. Chưa commit.

**Việc còn lại, theo thứ tự:**

| # | Việc | Ai | Ghi chú |
|---|---|---|---|
| 1 | Vào console.firebase.google.com, chấp nhận điều khoản Firebase, thêm Firebase vào dự án GCP **`teamup-exe-group6`** có sẵn (số 409603737127) | Ken | `firebase projects:addfirebase` đang báo 403 vì chưa chấp nhận điều khoản. **Lưu ý:** `.firebaserc` hiện trỏ `prm-lab3-cc39e` — hai tên project không khớp, cần chốt lại một tên trước khi đổi. |
| 2 | `flutterfire configure --project <project-id> --platforms android --android-package-name com.group6.teamup_exe` | Ken | Ghi đè `lib/firebase_options.dart` (hiện là file tạm, `main.dart` sẽ báo lỗi khi mở) và sinh `google-services.json`; commit cả hai |
| 3 | Bật Google Sign-In trong Authentication | Ken | |
| 4 | Thêm SHA-1 debug của 4 máy (`cd android && ./gradlew signingReport`) | Cả nhóm | Tải lại `google-services.json` sau khi thêm |
| 5 | ~~Nâng Blaze, đặt cảnh báo ngân sách, tạo bucket Storage ở `us-central1`~~ (bỏ: ở lại gói Spark, 12/11) | Cuong | |
| 6 | Tạo nhánh `feature/skeleton`, commit, mở PR | Ken | |

**Lưu ý môi trường Windows:**

- `android/gradle.properties` có `kotlin.incremental=false`. **Không xóa.** Pub cache ở ổ C: còn dự án ở ổ D: làm Kotlin incremental compile lỗi ("different roots").
- Dùng Firebase CLI bản npm (`npm i -g firebase-tools`), không dùng bản `.exe` độc lập (lỗi khi chạy trong terminal không tương tác).
- Nếu Gradle báo lỗi phiên bản Java: `flutter config --jdk-dir <JDK 17 hoặc 21>`.

**Cách thay màn tạm:** mỗi màn chưa làm đang là `PlaceholderScreen` trong `lib/router/app_router.dart` (ghi mã màn + người phụ trách). Làm màn thật theo mẫu S2 (`my_classes_view_model.dart` + `my_classes_screen.dart` + test ở `test/viewmodels/`), rồi thay dòng `PlaceholderScreen` tương ứng.

## 6. Câu hỏi còn mở cho nhóm

1. Có cài CI (D14) không, hay chỉ chạy script ở máy trước khi mở PR?
2. Ai trong nhóm đã có máy Android 13 trở lên để thử quyền thông báo? (FCM, Dan)
3. Dùng model nào cho ARTEMIS (Gemini có gói miễn phí), và ai giữ API key?
