# Evidence — bằng chứng Lab 3

> Mọi ảnh trong thư mục này phải chụp từ **project Firebase của nhóm**:
> project ID `prm-lab3-cc39e` — phải khớp với `android/app/google-services.json`
> (đề Lab 3 §11: "the project ID in console screenshots must match the one in
> your google-services.json").
>
> **Không** dùng ảnh mẫu của ai khác, **không** dùng ảnh chụp màn hình từ máy ảo.

## 1. Cấu trúc thư mục

```
evidence/
├── README.md                  ← file này: danh mục + checklist chụp
├── auth/                      ← Console → Authentication → Users
├── firestore/                 ← ảnh dữ liệu lớp / nhóm / đề xuất
├── storage/                   ← (Spark: không có bucket) lưu PDF trong Firestore
├── fcm/                       ← thông báo ở 3 trạng thái app
├── analytics/                 ← DebugView: từng event + tham số
├── crashlytics/               ← non-fatal + test crash + custom key + user ID
├── remote-config/             ← giá trị Console + ảnh app trước/sau
├── artemis/                   ← trace + screenshot từng lần chạy E2E
│   ├── TC-01/ … TC-23/
│   └── exploratory/           ← báo cáo phiên khám phá 15–30 phút
└── code-review/               ← output gốc của công cụ AI code review
```

## 2. Checklist bằng chứng theo từng dịch vụ

| # | Dịch vụ | Ảnh cần chụp | Rubric yêu cầu | Trạng thái |
|---|---|---|---|---|
| 1 | **Authentication** | ① Console → Authentication → **Users** (có mentor đã đăng nhập)<br>② Màn Sign in trước khi đăng nhập<br>③ Màn "My classes" sau khi đăng nhập<br>④ S19 — thông báo hủy đăng nhập | "Screenshots of both states; Users tab in the console" | ☐ |
| 2 | **Cloud Firestore** | ① Console → Firestore: `classes/{id}/students`, `teams`, `proposals` (1 `approved`)<br>② Màn S23 (3 số sau import)<br>③ Màn S14 (empty "All matched") | Dữ liệu thật, không mock | ☐ |
| 3 | **Lưu file (Firestore)** | ① Console → Firestore: tài liệu `reports/{id}/files/pdf` (bytes)<br>② Màn S6 demo hiện **đường dẫn file** (`reports/{id}/files/pdf`) + kích thước KB<br>③ Tiến độ upload | Gói **Spark** không có Cloud Storage bucket → file nằm trong Firestore. Rubric cần "the storage path of the uploaded file must be visible" | ☐ |
| 4 | **Cloud Messaging** | ① Thông báo khi app **đang mở** (foreground)<br>② Thông báo khi app **chạy nền** (background)<br>③ Thông báo khi app **đã đóng** (terminated) → mở app, chạm thông báo<br>④ Trung tâm thông báo trong app<br>⑤ Hộp thoại xin quyền Android 13+ | "Test message from the console received in each state" | ☐ |
| 5 | **Analytics** | DebugView: **một ảnh cho mỗi event** (10 event), nhìn thấy tên event **và** tham số<br>Logcat khi chạy ARTEMIS (test TC-17) | "DebugView screenshots for every event" | ☐ |
| 6 | **Crashlytics** | ① Non-fatal từ đường lỗi thật (loại "Non-fatal")<br>② Test crash (loại "Fatal") + stack trace<br>③ Ảnh hiển thị **custom key** `role` / `class_id`<br>④ Ảnh hiển thị **user ID**<br>⑤ Màn S6 vẫn hiện thông báo lỗi cho người dùng | "Non-fatal from a real error path and test crash both visible, with user ID and custom key" | ☐ |
| 7 | **Remote Config** | ① Console → Remote Config: giá trị `ai_matching_enabled` và `max_proposals_shown`<br>② Ảnh app **trước** khi đổi<br>③ Ảnh app **sau** khi đổi (nút Match with AI biến mất / S9 hiện N thẻ)<br>④ Ảnh app khi **mất mạng** → dùng giá trị mặc định | "Before/after screenshots and console values" | ☐ |
| 8 | **Rules (bảo mật)** | Ảnh Console Firestore: mỗi mentor chỉ thấy `classes` của mình; ghi chú kết quả thử truy cập trái phép | "rules restrict access" | ☐ |
| 9 | **ARTEMIS** | Lệnh chạy, `session.json` + `report.md` + ảnh từng lần chạy, báo cáo exploratory | "test results" | ☐ (1 ca pass) |
| 10 | **Code review** | Output gốc của công cụ review | "AI review" | ✅ `code-review/ai-review-2026-11-12.json` |

## 3. Cách tạo từng bằng chứng

**Crashlytics:** thu thập tắt ở bản debug. Chạy `flutter run --release` hoặc `flutter run --dart-define=CRASHLYTICS_DEBUG=true`.
- *Non-fatal từ đường lỗi thật:* bật Airplane mode rồi mở một lớp, bấm **Match with AI** (S8 báo lỗi, gửi `ai_matching_failed`), hoặc bấm **Generate and upload PDF** khi mất mạng (gửi `report_upload_failed`). Cần xác nhận trên thiết bị: Firestore có thể trả dữ liệu từ bộ nhớ đệm khi offline.
- *Crash thử:* Profile → **Test crash**, rồi mở lại app để báo cáo được gửi.

**Analytics DebugView:**
```bash
adb shell setprop debug.firebase.analytics.app com.group6.teamup_exe
```

**Remote Config:** sửa giá trị ở Firebase Console → Remote Config → Publish, đợi app cập nhật theo realtime (không cần build lại), chụp trước và sau.

**FCM:** tin thử từ Console **phải có data** `uid` = UID của tài khoản đang đăng nhập (xem ở Firebase Console → Authentication → Users) và tùy chọn `route` (ví dụ `/proposals`); app bỏ qua tin không có `uid` khớp (`_receive` trong `fcm_notification_service.dart`).
**FCM terminated:** vuốt tắt app rồi gửi tin thử từ Console tới token hiện ở Profile → Notifications. Nhớ nhấn **Enable / check notifications** sau lần đăng nhập đầu tiên (xem finding F2 trong [code-review.md](../docs/code-review.md)).

> Gói **Spark** không có Cloud Functions nên app **không tự gửi push** khi có thay đổi
> trên Firestore. Thông báo do Flow D/E/F được sinh ở **client** (`activity_messages.dart`).
> Bằng chứng FCM vì vậy tập trung vào: tin thử từ Console ở 3 trạng thái app,
> và thông báo "có hoạt động" sinh trong app.

## 4. Checklist ARTEMIS

| Mục | Nội dung |
|---|---|
| Lệnh đã dùng | `tools/run_e2e.ps1` (bọc `pytest -m "not exploratory" -v`, Flash) và `ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory` |
| Trace mỗi lần chạy | `evidence/artemis/<session-id>/` — `session.json` + `report.md` + `screenshots/step-NN-before/after.jpg` |
| Bảng kết quả | `docs/test-plan.md` §6 — test ID, số lần chạy, pass rate, thời gian TB |
| Ca flaky / fail | `docs/test-plan.md` §7 — nguyên nhân và cách xử lý |
| Phiên khám phá | `evidence/artemis/exploratory/` — báo cáo 15–30 phút, Pro profile |

> **Đã có sẵn:** 12 phiên chạy thật (4 completed, 8 failed) với **22 ảnh chụp thật**
> trong `evidence/artemis/`. `TC-02` **pass** (110.82s) — xem `evidence/artemis/README.md`
> để biết vì sao các ca còn lại failed (hạn mức Gemini free-tier, không phải lỗi app).

## 5. Checklist AI code review

| Mục | Nội dung |
|---|---|
| Output gốc của công cụ | `evidence/code-review/` — copy nguyên văn output của GitHub Copilot Code Review trên pull request |
| Quyết định và lý do | `docs/code-review.md` §2 (CR-01…CR-12) và §3 (F1…F10) |
| Commit sửa | 5 commit: `1b6fea8` (CR-01, CR-05, CR-06, CR-07) · `9cf68f5` (CR-02, CR-08) · `000f51b` (CR-03) · `7c0fc66` (CR-04) · `668ce5f` (CR-09, CR-10) |
| Tổng số finding | **22** (12 + 10, vượt mức tối thiểu 5 của đề §8) — xem `docs/code-review.md` §2 và §3 |

## 6. Quy tắc

1. **Ảnh phải tự chụp**, từ project Firebase của nhóm, có project ID khớp.
2. **Không** chụp ảnh màn hình đã edit (không thêm mũi tên, không ghép ảnh).
3. Ảnh màn hình app chụp trên **thiết bị thật** (đề bảo hiểm: "Phần upload, team có thể sử dụng cloudinary hoặc AWS S3... thay thế" và "Chấm bài phải chạy trên device thật").
4. Tên file: `<service>-<mô tả ngắn>-<timestamp>.png`, ví dụ
   `analytics-ai_match_result-20261112-1430.png`.
5. `evidence/` **không** được chứa API key, service account hay credential nào.
