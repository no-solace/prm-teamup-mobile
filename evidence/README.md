# Evidence

Đề: *work that cannot be shown is graded as missing.* Thư mục này giữ bằng chứng. **Chỉ những mục có dấu ✅ đã có file thật.** Tất cả ảnh console phải thấy project ID `prm-lab3-cc39e` (khớp `android/app/google-services.json`).

| Dịch vụ / mục | Cần chụp | Lưu vào | Trạng thái |
|---|---|---|---|
| Authentication | Màn đăng nhập và màn sau đăng nhập; tab Users trong Firebase Console có tài khoản test | `auth/` | ☐ |
| Cloud Storage | Danh sách tệp `reports/{uid}/…` trong console; ảnh thanh tiến độ upload và Saved reports trong app; `firebase/storage.rules` đã deploy | `storage/` | ☐ |
| Cloud Messaging | Tin nhắn thử từ console nhận được ở 3 trạng thái: foreground, background, terminated | `fcm/` | ☐ |
| Analytics | DebugView thấy đủ 10 sự kiện và tham số; user ID đã được đặt (xem [analytics-plan.md](../docs/analytics-plan.md)) | `analytics/` | ☐ |
| Crashlytics | Dashboard có 1 non-fatal từ đường lỗi thật (`ai_matching_failed`, `class_import_failed` hoặc `report_export_failed`) và 1 crash thử, kèm user ID và key `class_id` | `crashlytics/` | ☐ |
| Remote Config | Ảnh trước/sau của `ai_matching_enabled` và `max_proposals_shown`: giá trị trên console, giá trị trong app, hành vi thay đổi (nút Match with AI ẩn, số thẻ ở Proposals) | `remote-config/` | ☐ |
| ARTEMIS | Lệnh chạy, `runs/runs.jsonl`, `runs/results.md`, trace ID hoặc ảnh từng lần chạy, báo cáo exploratory | `artemis/` | ☐ |
| Code review | Đầu ra công cụ review | `code-review/` | ✅ `ai-review-2026-11-12.json` (chưa có đầu ra từ review trên PR) |

## Cách tạo từng bằng chứng

**Crashlytics:** thu thập tắt ở bản debug. Chạy `flutter run --release` hoặc `flutter run --dart-define=CRASHLYTICS_DEBUG=true`.
- *Non-fatal từ đường lỗi thật:* bật Airplane mode rồi mở một lớp, bấm **Match with AI** (S8 báo lỗi, gửi `ai_matching_failed`), hoặc bấm **Generate and upload PDF** khi mất mạng (gửi `report_export_failed`). Cần xác nhận trên thiết bị: Firestore có thể trả dữ liệu từ bộ nhớ đệm khi offline.
- *Crash thử:* Profile → **Test crash**, rồi mở lại app để báo cáo được gửi.

**Analytics DebugView:**
```bash
adb shell setprop debug.firebase.analytics.app com.group6.teamup_exe
```

**Remote Config:** sửa giá trị ở Firebase Console → Remote Config → Publish, đợi app cập nhật theo realtime (không cần build lại), chụp trước và sau.

**FCM terminated:** vuốt tắt app rồi gửi tin thử từ Console tới token hiện ở Profile → Notifications. Nhớ nhấn **Enable / check notifications** sau lần đăng nhập đầu tiên (xem finding F2 trong [code-review.md](../docs/code-review.md)).
