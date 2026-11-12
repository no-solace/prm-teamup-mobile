# TeamUp EXE (PRM393 Lab 3, nhóm 6)

Ứng dụng Flutter + Firebase giúp mentor môn EXE ghép nhóm 5-6 sinh viên đủ ngành (SE / AI / MKT / GD), duyệt đề xuất và xuất báo cáo. Phạm vi Lab 3: Flow A, B, C với 25 màn của Lab 2, cộng phần mở rộng D/E/F cho sinh viên (nộp đề tài, đặt lịch họp, biên bản). Xem [docs/PROPOSAL.md](docs/PROPOSAL.md).

Dự án chạy trên **gói Spark (miễn phí)**: không dùng Cloud Storage và Cloud Functions.
- File (PDF báo cáo, outline đề tài) lưu trong Firestore, tối đa 900 KB mỗi file.
- Thông báo D/E/F do app tự sinh. Xem `docs/PROPOSAL.md` mục 10.

## Môi trường

| Công cụ | Phiên bản |
|---|---|
| Flutter | 3.47.9 (stable) |
| Dart | 3.13.7 |
| JDK cho Gradle | 17 hoặc 21 (JDK 25 có thể làm Gradle lỗi: `flutter config --jdk-dir <đường dẫn JDK 17>`) |
| Android | minSdk 23, máy thật hoặc emulator có Google Play |
| Firebase CLI / FlutterFire CLI | 15.x / 1.4.x |

## Chạy app

```bash
flutter pub get

# Bản dev trên dữ liệu giả, không cần Firebase (có trang /_gallery trong Profile)
flutter run -t lib/main_fake.dart

# Bản nộp: Firebase thật (cần đã chạy flutterfire configure)
flutter run
```

Bản fake mặc định đăng nhập là mentor. Muốn thử vai sinh viên:
1. Sửa `lib/main_fake.dart` để truyền `FakeAuthService(user: FakeAuthService.leader)` vào `fakeOverrides(...)`. Đây là trưởng nhóm có sẵn: lớp `class-a`, MSSV `190501`, nhóm Tutor Match.
2. Muốn thử onboarding thì thay bằng một `AppUser` có `role: null`, rồi nhập mã lớp `class-a` và MSSV `190501`.

Trên Firebase thật, mentor copy **mã lớp** ở màn chi tiết lớp (S3) để gửi cho sinh viên.

Trước mỗi PR:

```bash
flutter analyze
flutter test
bash tool/check_layers.sh
```

## Cấu hình Firebase (làm một lần)

1. Dự án: `prm-lab3-cc39e` (khớp `.firebaserc`). Cấu hình app Android:
   ```bash
   flutterfire configure --project prm-lab3-cc39e --platforms android \
     --android-package-name com.group6.teamup_exe
   ```
   Lệnh này ghi đè `lib/firebase_options.dart` và sinh `android/app/google-services.json`. Commit cả hai file (đây không phải secret).
2. **Thêm SHA-1 của máy bạn** (bắt buộc để Google Sign-In chạy):
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy dòng `SHA1` của biến thể `debug`, dán vào Firebase Console → Project settings → app Android → Add fingerprint. Sau đó tải lại `google-services.json`.
3. Test rules trên emulator (cần JDK 21 trong `JAVA_HOME`):
   ```bash
   npm --prefix firebase/test install
   firebase emulators:exec --only firestore "npm --prefix firebase/test test"
   ```
4. Deploy: `firebase deploy --only firestore:rules,remoteconfig`. Lưu ý: lệnh này ghi đè Remote Config trên Console bằng `firebase/remote-config-template.json`. Gói Spark là đủ.

## Cấu trúc

Xem [docs/architecture.md](docs/architecture.md) và [docs/skeleton-decisions.md](docs/skeleton-decisions.md). Tóm tắt: `screens` → `viewmodels` (Riverpod Notifier) → `services` (interface) ← `firebase` (bản cài đặt). Chỉ `lib/providers/service_providers.dart` nối interface với bản cài đặt.

## Kiểm thử tự động trên thiết bị (ARTEMIS)

Bộ pytest nằm ở [e2e_test/](e2e_test/), kế hoạch và kết quả ở [docs/test-plan.md](docs/test-plan.md).

| Công cụ | Phiên bản ghim |
|---|---|
| Google ARTEMIS | commit `351ca8422f7b5b54e80a9c1ce03a222e02415b6b` |
| Python | 3.12 (qua `uv`) |
| firebase-tools (test rules) | 14.27.0 trở lên (bản 15 đòi JDK 21) |

```bash
cd e2e_test && export ARTEMIS_DEVICE=<adb serial> && bash run_suite.sh
```

Khóa API của mô hình nằm ở `.env` của máy chủ ARTEMIS và tài khoản Google test lấy từ thiết bị; không có thứ nào trong repo.

## Bản đồ tài liệu nộp

| Yêu cầu của đề | Vị trí | Tình trạng |
|---|---|---|
| Truy vết thiết kế | [docs/design-traceability.md](docs/design-traceability.md) | Có; chưa cập nhật Figma cho các khác biệt |
| Kiến trúc | [docs/architecture.md](docs/architecture.md) | Có |
| Kế hoạch analytics | [docs/analytics-plan.md](docs/analytics-plan.md) | Có; chưa chụp DebugView |
| Kế hoạch test và ARTEMIS | [docs/test-plan.md](docs/test-plan.md), [e2e_test/](e2e_test/) | Có; **chưa chạy trên thiết bị** |
| Review bằng AI | [docs/code-review.md](docs/code-review.md) | Có 10 finding, 3 fix, chưa review trên PR |
| Bằng chứng | [evidence/](evidence/) | Mới có đầu ra review; còn lại cần chụp trên thiết bị |
| Báo cáo PDF | `report/Lab03_<MSSV>.pdf` | **Chưa có** |
| Slide PDF | `slides/Lab03_<MSSV>_slides.pdf` | **Chưa có** |
| Video demo (5–10 phút) | *(chèn link tại đây)* | **Chưa có** |

## Công cụ AI đã dùng

Codex (viết phần lớn mã app), Claude Code (telemetry, test, tài liệu, review), xem danh sách đầy đủ ở mục 5 của [docs/code-review.md](docs/code-review.md).

## Không commit

Service account, file `.env`, keystore, khóa ARTEMIS. `.gitignore` đã chặn các mẫu này.
