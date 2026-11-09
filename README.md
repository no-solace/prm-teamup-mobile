# TeamUp EXE (PRM393 Lab 3, nhóm 6)

Ứng dụng Flutter + Firebase giúp mentor môn EXE ghép nhóm 5-6 sinh viên đủ ngành (SE / AI / MKT / GD), duyệt đề xuất và xuất báo cáo. Phạm vi Lab 3: Flow A, B, C với 25 màn của Lab 2 (xem [docs/PROPOSAL.md](docs/PROPOSAL.md)).

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
3. Deploy rules: `firebase deploy --only firestore:rules,storage`.

## Cấu trúc

Xem [docs/architecture.md](docs/architecture.md) và [docs/skeleton-decisions.md](docs/skeleton-decisions.md). Tóm tắt: `screens` → `viewmodels` (Riverpod Notifier) → `services` (interface) ← `firebase` (bản cài đặt). Chỉ `lib/providers/service_providers.dart` nối interface với bản cài đặt.

## Không commit

Service account, file `.env`, keystore, khóa ARTEMIS. `.gitignore` đã chặn các mẫu này.
