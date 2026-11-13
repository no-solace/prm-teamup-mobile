# TeamUp EXE — PRM393 Lab 3 (Nhóm 6)

TeamUp EXE là ứng dụng Android hỗ trợ mentor môn EXE quản lý lớp, ghép nhóm đa ngành từ 5–6 sinh viên, duyệt đề xuất nhóm và theo dõi hoạt động đồ án. Dự án được phát triển bằng Flutter, Riverpod và Firebase theo kiến trúc MVVM.

Ứng dụng kế thừa 25 màn hình và ba luồng nghiệp vụ A/B/C từ Lab 2, đồng thời mở rộng thêm luồng đề xuất đề tài, đặt lịch và biên bản họp (D/E/F). Dự án có hai chế độ chạy: dữ liệu giả để phát triển offline và Firebase thật cho bản demo/nộp bài.

## Mục lục

- [Tính năng chính](#tính-năng-chính)
- [Công nghệ và kiến trúc](#công-nghệ-và-kiến-trúc)
- [Yêu cầu môi trường](#yêu-cầu-môi-trường)
- [Khởi chạy nhanh](#khởi-chạy-nhanh)
- [Cấu hình Firebase](#cấu-hình-firebase)
- [Dữ liệu demo và tài khoản](#dữ-liệu-demo-và-tài-khoản)
- [Kiểm thử và kiểm tra chất lượng](#kiểm-thử-và-kiểm-tra-chất-lượng)
- [Build và triển khai](#build-và-triển-khai)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Tài liệu dự án](#tài-liệu-dự-án)
- [Trạng thái bài nộp](#trạng-thái-bài-nộp)
- [Xử lý sự cố thường gặp](#xử-lý-sự-cố-thường-gặp)
- [Thành viên và phân công](#thành-viên-và-phân-công)

## Tính năng chính

### Vai trò mentor

- Đăng nhập bằng Google, email/mật khẩu hoặc số điện thoại; đăng xuất và quản lý hồ sơ.
- Import danh sách lớp từ CSV, xem lớp, sinh viên, nhóm và số liệu tổng hợp.
- Ghép nhóm theo luật 5–6 thành viên và độ phủ các ngành SE, AI, MKT, GD.
- Tạo, chỉnh sửa, duyệt, hoàn tác hoặc hủy đề xuất ghép nhóm.
- Ghép thủ công sinh viên chưa có nhóm và xử lý trường hợp không tìm được kết quả.
- Duyệt/từ chối đề tài, mở lịch tư vấn và xem biên bản họp.
- Xuất báo cáo PDF và lưu nội dung PDF trong Firestore.
- Theo dõi thông báo, Analytics, lỗi Crashlytics và các giá trị Remote Config.

### Vai trò sinh viên

- Liên kết tài khoản với lớp và MSSV đã được mentor import.
- Xem nhóm, đề tài và lịch họp của chính mình.
- Trưởng nhóm có thể nộp/chỉnh sửa đề tài, đặt lịch và ghi biên bản họp.
- Thành viên chỉ được xem dữ liệu thuộc nhóm; quyền truy cập được kiểm soát bằng Firestore Rules.

### Luồng nghiệp vụ

| Luồng | Nội dung |
|---|---|
| **A** | Import lớp → xem sinh viên chưa có nhóm → ghép theo luật → duyệt kết quả |
| **B** | Xem đề xuất → thêm/xóa thành viên → kiểm tra giới hạn 5–6 người → duyệt/hoàn tác |
| **C** | Tìm nhóm thiếu người → chọn sinh viên → ghép thủ công hoặc hủy đề xuất |
| **D** | Trưởng nhóm nộp đề tài → mentor duyệt/từ chối → nộp lại theo giới hạn cấu hình |
| **E** | Mentor mở khung giờ → trưởng nhóm đặt lịch → hai phía theo dõi lịch hẹn |
| **F** | Ghi và xem biên bản cho buổi họp đã đặt |

Đặc tả chi tiết nằm trong [workflow](docs/workflow.md), [proposal](docs/PROPOSAL.md) và [truy vết thiết kế](docs/design-traceability.md).

## Công nghệ và kiến trúc

| Thành phần | Công nghệ |
|---|---|
| Mobile | Flutter 3.47.9, Dart 3.13.7, Material 3 |
| Quản lý trạng thái | Riverpod 3 (`Notifier`, không code generation) |
| Điều hướng | `go_router` với shell 5 tab và phân quyền theo vai trò |
| Backend | Firebase Authentication, Cloud Firestore, Remote Config, Analytics, Crashlytics, Cloud Messaging |
| Báo cáo | `pdf` + `printing`; bytes PDF lưu trong Firestore để dùng gói Spark |
| Unit/widget test | `flutter_test`, `mocktail` |
| E2E | `pytest` + Google ARTEMIS trên thiết bị Android/emulator |
| CI | GitHub Actions: analyze, test và kiểm tra ranh giới layer |

Dự án dùng gói Firebase **Spark**. Vì vậy không có Cloud Functions và không dùng Cloud Storage bucket; thông báo hoạt động được tạo phía client, còn file PDF được lưu tại `reports/{id}/files/pdf` trong Firestore.

Luồng phụ thuộc chính:

```text
screens / widgets
        ↓
viewmodels (Riverpod Notifier + ViewState)
        ↓
services (interface thuần Dart)
        ↑
firebase implementations  hoặc  fake implementations
```

Chỉ [service_providers.dart](lib/providers/service_providers.dart) ánh xạ interface sang implementation. UI và ViewModel không gọi Firebase SDK trực tiếp. Xem sơ đồ layer, bảng ViewModel → Service và sequence diagram trong [docs/architecture.md](docs/architecture.md).

## Yêu cầu môi trường

| Công cụ | Phiên bản / ghi chú |
|---|---|
| Flutter | **3.47.9 stable** |
| Dart | **3.13.7** (đi kèm Flutter) |
| JDK | **17 hoặc 21**; không khuyến nghị JDK 25/26 với cấu hình Gradle hiện tại |
| Android | minSdk 23; emulator hoặc máy thật có Google Play Services |
| Node.js/npm | Cần cho Firebase CLI và test Firestore Rules |
| Firebase CLI | Dùng bản ghim: `npx firebase-tools@15.35.0` |
| FlutterFire CLI | 1.4.x, chỉ cần khi đổi/tạo lại cấu hình Firebase |
| Python | 3.10+, khuyến nghị 3.12 cho bộ test ARTEMIS |

Kiểm tra môi trường trước khi chạy:

```bash
flutter doctor -v
flutter --version
adb devices
java -version
node --version
python --version
```

Nếu Flutter đang dùng sai JDK:

```bash
flutter config --jdk-dir <duong-dan-jdk-17-hoac-21>
```

## Khởi chạy nhanh

### 1. Lấy dependencies

```bash
flutter pub get
```

### 2. Chạy bản fake — khuyến nghị khi phát triển UI

Bản này không cần mạng, tài khoản hay Firebase:

```bash
flutter run -t lib/main_fake.dart
```

`main_fake.dart` thay toàn bộ service thật bằng fake, đăng nhập sẵn với vai trò mentor và bật route gallery `/_gallery`.

### 3. Chạy bản Firebase thật

```bash
flutter run -t lib/main.dart
```

Bản thật khởi tạo Firebase, Crashlytics, Remote Config, FCM và các implementation Firestore. Thiết bị cần có cấu hình Google Play Services hợp lệ; Google Sign-In yêu cầu SHA-1 của debug keystore đã được đăng ký trong Firebase Console.

## Cấu hình Firebase

Repo đang trỏ tới project `prm-lab3-cc39e` trong [.firebaserc](.firebaserc). Hai file cấu hình client `lib/firebase_options.dart` và `android/app/google-services.json` được commit có chủ đích; chúng là định danh client, không phải service-account secret.

### Dùng project hiện tại

1. Đăng nhập Firebase CLI bằng tài khoản đã được cấp quyền:

   ```bash
   npx firebase-tools@15.35.0 login
   npx firebase-tools@15.35.0 use prm-lab3-cc39e
   ```

2. Lấy SHA-1 của debug keystore:

   ```powershell
   Set-Location android
   .\gradlew.bat signingReport
   Set-Location ..
   ```

   Trên macOS/Linux dùng `./gradlew signingReport`. Thêm SHA-1 vào Firebase Console → Project settings → Android app `com.group6.teamup_exe`, sau đó tải lại `google-services.json` nếu Console yêu cầu.

3. Trong Firebase Console, bật các dịch vụ cần dùng:

   - Authentication: Google, Email/Password và Phone (nếu demo đăng nhập SMS).
   - Cloud Firestore.
   - Analytics, Crashlytics, Cloud Messaging và Remote Config.

4. Deploy rules, indexes, Remote Config và trang admin:

   ```bash
   npx firebase-tools@15.35.0 deploy --only firestore,remoteconfig,hosting
   ```

   Lệnh deploy Remote Config sẽ dùng [remote-config-template.json](firebase/remote-config-template.json) và có thể ghi đè cấu hình hiện tại trên Console; hãy kiểm tra diff trước khi deploy.

### Chuyển sang Firebase project khác

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project <project-id> --platforms android --android-package-name com.group6.teamup_exe
```

Sau đó cập nhật `.firebaserc`, cấu hình Firebase của [admin-web/index.html](admin-web/index.html), project ID trong các script gửi FCM, đăng ký SHA-1 và deploy lại rules/indexes/Remote Config.

### Remote Config mặc định

| Tham số | Mặc định | Ý nghĩa |
|---|---:|---|
| `ai_matching_enabled` | `true` | Bật/tắt hành động ghép nhóm tự động |
| `max_proposals_shown` | `3` | Số đề xuất hiển thị |
| `max_topic_revisions` | `3` | Số lần trưởng nhóm được nộp lại đề tài |
| `default_meeting_duration_minutes` | `30` | Thời lượng khung giờ tư vấn |

Khi không lấy được cấu hình từ mạng, app dùng [remote-config-defaults.json](firebase/remote-config-defaults.json).

### Trang admin

`admin-web/` là trang Firebase Hosting chỉ dành cho tài khoản có document `admins/{uid}`. Trang hiển thị tối đa 100 crash report và 100 báo cáo PDF gần nhất. Document admin phải được tạo bởi người quản trị qua Firebase Console hoặc môi trường tin cậy; Firestore Rules không cho client tự cấp quyền admin.

## Dữ liệu demo và tài khoản

### Bản fake

- Mentor mặc định: `Lan Nguyen`.
- Dữ liệu lớp mẫu: `class-a`.
- Trưởng nhóm mẫu: `FakeAuthService.leader`, MSSV `190501`, nhóm `Tutor Match`.
- Muốn chạy bằng vai trưởng nhóm, truyền `FakeAuthService(user: FakeAuthService.leader)` vào `fakeOverrides(...)` trong `lib/main_fake.dart`.
- Muốn kiểm tra onboarding, truyền một `AppUser` có `role: null`, sau đó nhập class code `class-a` và MSSV `190501`.

### Bản Firebase thật

Mentor import một trong các file sau ngay trong ứng dụng:

- `demo-data/EXE101-demo.csv`: dữ liệu demo hợp lệ.
- `demo-data/EXE101-loi-de-demo-bao-loi.csv`: dữ liệu cố ý sai để demo validation.

Sau khi import, mentor lấy mã lớp ở màn chi tiết lớp và gửi cho sinh viên. Tài khoản sinh viên chỉ onboarding được khi cặp mã lớp/MSSV tồn tại và sinh viên đã thuộc một nhóm.

## Kiểm thử và kiểm tra chất lượng

### Kiểm tra bắt buộc trước pull request

```bash
flutter analyze
flutter test
bash tools/check_layers.sh
```

Trên Windows, nếu `bash` chưa có trong `PATH`:

```powershell
& "C:\Program Files\Git\bin\bash.exe" tools/check_layers.sh
```

CI chạy lại ba bước trên cho mọi pull request và mỗi lần push vào `main`.

### Firestore Rules trên emulator

```bash
npm --prefix firebase/test install
npx firebase-tools@15.35.0 emulators:exec --only firestore --project demo-teamup-data "node --test firebase/test/firestore.rules.test.mjs"
```

Test dùng project giả `demo-teamup-data`, không chạm dữ liệu Firebase thật và không cần đăng nhập Firebase CLI.

### End-to-end với Google ARTEMIS

1. Tạo môi trường Python và cài client đã ghim commit:

   ```bash
   cd e2e_test
   python -m venv .venv
   # PowerShell: .\.venv\Scripts\Activate.ps1
   # macOS/Linux: source .venv/bin/activate
   pip install -e ".[artemis]"
   ```

2. Khởi động ARTEMIS host, kết nối thiết bị Android và cài bản app cần test.

3. Khai báo biến môi trường. Ví dụ PowerShell:

   ```powershell
   $env:ARTEMIS_API_KEY = "<model-api-key>"
   $env:ARTEMIS_DEVICE = "emulator-5554"
   $env:ARTEMIS_PROFILE = "flash"
   ```

4. Chạy regression hoặc exploratory:

   Từ thư mục gốc của repo, dùng script PowerShell (script tự kiểm tra daemon,
   thiết bị, API key và app đã cài):

   ```powershell
   .\tools\run_e2e.ps1
   .\tools\run_e2e.ps1 -TestPath e2e_test/test_auth.py
   ```

   Hoặc chạy `pytest` trực tiếp trong `e2e_test/`:

   ```bash
   cd e2e_test
   pytest -m "not exploratory" -v
   ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory
   ```

5. Thu thập ảnh và log:

   ```bash
   python tools/collect_artemis_evidence.py
   ```

Chi tiết về daemon, biến môi trường, semantics và quy tắc viết test nằm trong [e2e_test/README.md](e2e_test/README.md). Không commit API key, token hoặc tài khoản test.

### Kết quả đã ghi nhận

| Hạng mục | Kết quả gần nhất được lưu trong repo |
|---|---|
| `flutter analyze` | Không có issue |
| Flutter unit/widget test | 175/175 pass |
| Firestore Rules test | 30/30 pass |
| Kiểm tra ranh giới layer | `Layers OK` |
| ARTEMIS | 24 lượt chạy, 21 pass; còn ca cần chạy lại và đủ ba vòng |

Số liệu chi tiết, nguyên nhân fail/flaky/skip và trace từng lượt chạy được lưu trong [docs/test-plan.md](docs/test-plan.md) và [evidence/artemis/](evidence/artemis/). Không nên hiểu bảng trên là trạng thái realtime của mọi môi trường; hãy chạy lại các lệnh kiểm tra trước khi nộp.

## Build và triển khai

### APK debug/release

```bash
flutter build apk --debug -t lib/main_fake.dart
flutter build apk --release -t lib/main.dart
```

APK nằm trong `build/app/outputs/flutter-apk/`. Build release hiện dùng debug signing để thuận tiện demo; trước khi phát hành thật phải tạo keystore riêng và thay `signingConfig` trong `android/app/build.gradle.kts`.

### Gửi FCM phục vụ demo

Sau khi đăng nhập Firebase CLI và người dùng đã cho phép thông báo để app ghi FCM token:

```bash
cd tools
npm install
node send_fcm_cli.mjs <uid> "TeamUp EXE" "Bạn có cập nhật mới" /proposals
```

Script này chỉ dùng trên máy tin cậy. Không đưa service account hoặc access token vào repo.

### Dựng lại báo cáo và slide

```bash
pip install markdown
python tools/build_report.py --student-id <MSSV>
```

Đầu ra là `report/Lab03_<MSSV>.pdf` và `slides/Lab03_<MSSV>_slides.pdf`. Máy dựng cần Chrome/Chromium và Mermaid CLI (`mmdc`); script có thể dùng `npx @mermaid-js/mermaid-cli` khi chưa cài global.

## Cấu trúc thư mục

```text
.
├── android/                 Cấu hình ứng dụng Android
├── admin-web/               Trang quản trị deploy bằng Firebase Hosting
├── assets/                  Font Be Vietnam Pro
├── demo-data/               CSV hợp lệ và CSV lỗi dùng khi demo
├── docs/                    Đặc tả, kiến trúc, test plan và nhật ký
├── e2e_test/                Bộ pytest điều khiển ARTEMIS
├── evidence/                Ảnh, log và bằng chứng code review/E2E
├── firebase/                Firestore Rules, indexes, Remote Config và rule tests
├── lib/
│   ├── firebase/            Implementation dùng Firebase SDK
│   ├── models/              Entity và value object thuần Dart
│   ├── providers/           Dependency injection và fake overrides
│   ├── router/              Route, redirect và deep-link allow-list
│   ├── screens/             UI theo từng flow
│   ├── services/            Interface, nghiệp vụ và fake services
│   ├── theme/               Color, spacing, typography, Material theme
│   ├── viewmodels/          Riverpod Notifier + ViewState
│   └── widgets/             Component dùng chung và semantics
├── report/                  Báo cáo Lab 3 và nguồn Markdown/HTML
├── slides/                  Slide thuyết trình và nguồn Markdown/HTML
├── test/                    Unit test và widget test
└── tools/                   Script E2E, FCM, kiểm layer và dựng tài liệu
```

Hai entry point:

- `lib/main.dart`: Firebase thật, dùng cho bản nộp, video và ARTEMIS.
- `lib/main_fake.dart`: fake services, dùng cho phát triển UI và test thủ công offline.

## Tài liệu dự án

| Tài liệu | Nội dung |
|---|---|
| [Đề xuất dự án](docs/PROPOSAL.md) | Người dùng, phạm vi, công nghệ, tiêu chí thành công và rủi ro |
| [Đặc tả workflow](docs/workflow.md) | Happy path, decision, exception và business rules A/B/C |
| [Kiến trúc](docs/architecture.md) | Layer, cây thư mục, router, ViewModel → Service và sequence diagram |
| [Data model](docs/data-model.md) | Collections, field, state machine, ràng buộc và indexes |
| [Truy vết thiết kế](docs/design-traceability.md) | Màn Lab 2 → route/widget/dữ liệu và các sai lệch có lý do |
| [Kế hoạch Analytics](docs/analytics-plan.md) | Event, tham số và quy tắc không ghi PII |
| [Kế hoạch kiểm thử](docs/test-plan.md) | Unit/widget/E2E cases, kết quả ARTEMIS và phân tích flaky |
| [AI code review](docs/code-review.md) | Phát hiện, quyết định, cách sửa và commit liên quan |
| [Worklog](docs/WORKLOG.md) | Lịch sử triển khai, lệnh kiểm chứng và việc còn lại |
| [Bàn giao nộp bài](docs/BAN_GIAO_HUONG_DAN_NOP_BAI.md) | Checklist thao tác Firebase, bằng chứng, video và nộp bài |
| [Kịch bản demo](docs/KICH_BAN_DEMO.md) | Trình tự demo ứng dụng và Firebase |
| [Phân công](docs/PHAN_CONG.md) | Chủ sở hữu từng flow/dịch vụ và trách nhiệm chung |

## Trạng thái bài nộp

| Hạng mục | Trạng thái trong repo | Việc cần xác nhận trước khi nộp |
|---|---|---|
| Mã nguồn A–F, mentor + sinh viên | Hoàn thành | Chạy smoke test trên bản Firebase thật |
| Firebase client config | Đã commit | Kiểm tra project ID và SHA-1 từng máy demo |
| Rules, indexes, Remote Config | Có source và test | Deploy đúng project, chụp bằng chứng Console |
| Unit/widget/rules tests | Có kết quả pass đã ghi nhận | Chạy lại trên commit nộp bài |
| ARTEMIS | Có suite, log và ảnh | Chạy đủ số vòng còn thiếu, cập nhật pass rate |
| Báo cáo và slide | Có PDF và source | Dựng lại với MSSV/tên chính thức nếu cần |
| Video demo | Chưa có link trong repo | Quay, upload và điền link bên dưới |

**Demo video:** _chưa cập nhật_

Checklist ưu tiên và hướng dẫn bàn giao chi tiết: [docs/BAN_GIAO_HUONG_DAN_NOP_BAI.md](docs/BAN_GIAO_HUONG_DAN_NOP_BAI.md).

## Xử lý sự cố thường gặp

| Lỗi | Cách xử lý |
|---|---|
| Gradle lỗi do JDK mới | Chuyển Flutter sang JDK 17/21 bằng `flutter config --jdk-dir ...`, rồi chạy `flutter clean` và `flutter pub get` |
| Google Sign-In bị hủy hoặc báo lỗi cấu hình | Kiểm tra package `com.group6.teamup_exe`, SHA-1 debug/release, provider Google và tải lại `google-services.json` |
| App chạy fake nhưng không có Firebase | Đây là hành vi đúng của `main_fake.dart`; dùng `flutter run -t lib/main.dart` để chạy Firebase thật |
| Remote Config không đổi | Publish template trên Console, kiểm tra mạng; app vẫn dùng defaults khi fetch thất bại |
| FCM không tới | Cho phép notification, mở app để ghi token, kiểm tra đúng UID/project và route nằm trong allow-list |
| Firestore báo `permission-denied` | Kiểm tra document `users/{uid}`, role, `mentorUid`, class/team link và rules đã deploy |
| ARTEMIS không kết nối | Kiểm tra `/api/status`, `adb devices`, package đã cài và các biến `ARTEMIS_*` |
| PDF quá lớn | Firestore Rules giới hạn payload file; giảm nội dung/ảnh trước khi upload |

## Thành viên và phân công

| Thành viên | Phụ trách chính |
|---|---|
| Ken | Khung ứng dụng, đăng nhập, kiến trúc, rules và tài liệu nền |
| Dan | Flow A, import CSV, matching, Remote Config, FCM và video |
| Cuong | Flow B, PDF/Firestore, Crashlytics và trang demo |
| Khang | Flow C, Analytics, ARTEMIS, QA, báo cáo và slide |

Chi tiết phạm vi và sản phẩm bàn giao của từng thành viên nằm trong [docs/PHAN_CONG.md](docs/PHAN_CONG.md).

## Bảo mật và quy ước commit

Không commit service account, `.env`, keystore, khóa ARTEMIS, API token hoặc tài khoản test. `.gitignore` đã chặn các mẫu phổ biến. Firebase client config (`google-services.json`, `firebase_options.dart`) được giữ trong repo theo yêu cầu bài lab; chúng không cấp quyền quản trị Firebase.

Mọi thay đổi nên qua pull request, chạy đủ quality gate và giữ đúng chiều phụ thuộc MVVM. License của dự án: [MIT](LICENSE).
