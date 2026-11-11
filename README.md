# TeamUp EXE (PRM393 Lab 3, nhóm 6)

Ứng dụng Flutter + Firebase giúp mentor môn EXE ghép nhóm 5–6 sinh viên đủ ngành (SE / AI / MKT / GD), duyệt đề xuất và xuất báo cáo PDF. Phạm vi Lab 3: **Flow A, B, C** với **25 màn** của Lab 2 (xem [docs/PROPOSAL.md](docs/PROPOSAL.md) và [docs/workflow.md](docs/workflow.md)).

| | |
|---|---|
| **Đề tài** | Lab 2 — *TeamUp EXE* (AI-Assisted UI/UX Design) |
| **Nguồn dữ liệu** | Cloud Firestore (dữ liệu lớp của chính mentor) + Cloud Storage cho báo cáo PDF |
| **Nền tảng** | Android — Flutter 3.47.9 (stable) · Material 3 |
| **Cấu trúc** | MVVM + Riverpod 3 · 4 lớp · phụ thuộc chỉ đi xuống |

## Môi trường (phiên bản đã ghim)

| Công cụ | Phiên bản |
|---|---|
| Flutter | 3.47.9 (stable) |
| Dart | 3.13.7 |
| JDK cho Gradle | 17 hoặc 21 (JDK 25 có thể làm Gradle lỗi: `flutter config --jdk-dir <đường dẫn JDK 17>`) |
| Android | minSdk 23, máy thật hoặc emulator có Google Play |
| Firebase CLI / FlutterFire CLI | 15.x / 1.4.x |
| Google ARTEMIS | commit ghim trong `e2e_test/pyproject.toml` |
| AI code review | GitHub Copilot Code Review (pull request `feature/lab3-complete-gaps`) |

Phiên bản package Flutter đã ghim trong `pubspec.yaml`; phiên bản SDK Dart trong `e2e_test/pyproject.toml`.

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
bash tool/check_layers.sh        # Windows: "C:\Program Files\Git\bin\bash.exe" tool/check_layers.sh
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
3. Deploy rules:
   ```bash
   firebase deploy --only firestore:rules,storage
   ```

## Chạy bộ test E2E (Google ARTEMIS)

```bash
cd e2e_test
pip install -e ".[artemis]"
export ARTEMIS_API_KEY=<model api key>     # không commit
export ARTEMIS_DEVICE=emulator-5554        # serial từ `adb devices`
pytest -m "not exploratory" -v              # Flash profile, regression
ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory
```

Chi tiết: [e2e_test/README.md](e2e_test/README.md) và [docs/test-plan.md](docs/test-plan.md).

## Dựng lại báo cáo và slide

```bash
pip install markdown
python tool/build_report.py --student-id <StudentID>
```

Kết quả: `report/Lab03_<StudentID>.pdf` và `slides/Lab03_<StudentID>_slides.pdf`. Cần có `mmdc` (mermaid CLI) và một Chromium để in PDF.

## Bản đồ tài liệu nộp bài

| Tài liệu | Đường dẫn | Nội dung |
|---|---|---|
| Truy vết thiết kế | [docs/design-traceability.md](docs/design-traceability.md) | 25 màn Lab 2 → route, widget, nguồn dữ liệu; 5 sai lệch kèm lý do; ma trận component và token |
| Kiến trúc | [docs/architecture.md](docs/architecture.md) | Cây thư mục, sơ đồ layer, sequence diagram Flow A, bảng ViewModel → Service, trạng thái 7 dịch vụ Firebase |
| Đặc tả workflow | [docs/workflow.md](docs/workflow.md) | 3 workflow lõi đủ 7 thành phần, activity diagram, state machine, registry BR-01…BR-07 |
| Kế hoạch Analytics | [docs/analytics-plan.md](docs/analytics-plan.md) | 10 event: trigger, tham số có kiểu, câu hỏi sản phẩm, ánh xạ flow, quy tắc không PII |
| Kế hoạch kiểm thử | [docs/test-plan.md](docs/test-plan.md) | 18 ca ARTEMIS + 1 phiên khám phá, bảng kết quả, giải thích ca flaky |
| Rà soát mã AI | [docs/code-review.md](docs/code-review.md) | 8 phát hiện (tool, file:line, loại, quyết định, lý do, commit) + công bố công cụ |
| Bộ test E2E | [e2e_test/](e2e_test/) | `conftest.py`, `pyproject.toml`, 5 module test + phiên khám phá |
| Bằng chứng | [evidence/](evidence/) | Checklist và danh mục ảnh Console / DebugView / Crashlytics / ARTEMIS |
| Báo cáo | [report/](report/) | `Lab03_<StudentID>.pdf` (nguồn Markdown + script dựng) |
| Slide | [slides/](slides/) | `Lab03_<StudentID>_slides.pdf` (nguồn Markdown + script dựng) |
| Bằng chứng AI review | [evidence/code-review/](evidence/code-review/) | Output gốc của GitHub Copilot Code Review |

## Công cụ AI đã dùng trong lab này

| Công cụ | Mục đích |
|---|---|
| Cursor Agent (Claude Opus 4.5) | Rà soát yêu cầu Lab 3, phân tích gap giữa đề và mã nguồn, viết lại code và tài liệu |
| Claude Code trong Cursor | Sinh `docs/*.md`, `e2e_test/*.py`, `report/`, `slides/`, commit theo mã phát hiện |
| GitHub Copilot Chat | Gợi ý refactor trong `lib/viewmodels/` |
| GitHub Copilot Code Review | Rà soát pull request, sinh danh sách phát hiện (CR-01…CR-08) |
| Mermaid CLI (`mmdc`) | Vẽ sơ đồ activity / state / sequence / layer cho báo cáo và slide |

Chi tiết và quyết định cho từng phát hiện: [docs/code-review.md](docs/code-review.md) §5.

## Không commit

Service account, file `.env`, keystore, khóa ARTEMIS. `.gitignore` đã chặn các mẫu này. `google-services.json` và `firebase_options.dart` **được** commit (đề Lab 3 §9 cho phép).
