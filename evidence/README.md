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
├── storage/                   ← Console → Storage: danh sách file PDF + URL
├── fcm/                       ← thông báo ở 3 trạng thái app
├── analytics/                 ← DebugView: từng event + tham số
├── crashlytics/               ← non-fatal + test crash + custom key + user ID
├── remote-config/             ← giá trị Console + ảnh app trước/sau
├── artemis/                   ← trace + screenshot từng lần chạy E2E
│   ├── TC-01/ … TC-18/
│   └── exploratory/           ← báo cáo phiên khám phá 15–30 phút
└── code-review/               ← output gốc của công cụ AI code review
```

## 2. Checklist bằng chứng theo từng dịch vụ

| # | Dịch vụ | Ảnh cần chụp | Rubric yêu cầu |
|---|---|---|---|
| 1 | **Authentication** | ① Console → Authentication → **Users** (có mentor đã đăng nhập)<br>② Màn Sign in trước khi đăng nhập<br>③ Màn "My classes" sau khi đăng nhập<br>④ S19 — thông báo hủy đăng nhập | "Screenshots of both states; Users tab in the console" |
| 2 | **Cloud Firestore** | ① Console → Firestore: `classes/{id}/students`, `teams`, `proposals` (1 `approved`)<br>② Màn S23 (3 số sau import)<br>③ Màn S14 (empty "All matched") | Dữ liệu thật, không mock |
| 3 | **Cloud Storage** | ① Console → Storage: file trong `reports/{uid}/`<br>② Màn S6 demo hiện **download URL** + storage path + kích thước KB | "console file list" + "show progress and the download URL" |
| 4 | **Cloud Messaging** | ① Thông báo khi app **đang mở** (foreground)<br>② Thông báo khi app **chạy nền** (background)<br>③ Thông báo khi app **đã đóng** (terminated) → mở app, chạm thông báo<br>④ Trung tâm thông báo trong app<br>⑤ Hộp thoại xin quyền Android 13+ | "Test message from the console received in each state" |
| 5 | **Analytics** | DebugView: **một ảnh cho mỗi event** (10 event), nhìn thấy tên event **và** tham số<br>Logcat khi chạy ARTEMIS (test TC-17) | "DebugView screenshots for every event" |
| 6 | **Crashlytics** | ① Non-fatal từ đường lỗi thật (loại "Non-fatal")<br>② Test crash (loại "Fatal") + stack trace<br>③ Ảnh hiển thị **custom key** `role` / `class_id`<br>④ Ảnh hiển thị **user ID**<br>⑤ Màn S6 vẫn hiện thông báo lỗi cho người dùng | "Non-fatal from a real error path and test crash both visible, with user ID and custom key" |
| 7 | **Remote Config** | ① Console → Remote Config: giá trị `ai_matching_enabled` và `max_proposals_shown`<br>② Ảnh app **trước** khi đổi<br>③ Ảnh app **sau** khi đổi (nút Match with AI biến mất / S9 hiện N thẻ)<br>④ Ảnh app khi **mất mạng** → dùng giá trị mặc định | "Before/after screenshots and console values" |
| 8 | **Storage security** | Ảnh Console Storage chỉ thấy thư mục `reports/{uid}/` của mentor đang đăng nhập<br>Ghi chú kết quả thử truy cập trái phép | "rules restrict access" |

## 3. Checklist ARTEMIS

| Mục | Nội dung |
|---|---|
| Lệnh đã dùng | `pytest -m "not exploratory" -v` (Flash) và `ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory` |
| Trace mỗi lần chạy | `evidence/artemis/TC-xx/run-1..3/` (ảnh chụp + log agent) |
| Bảng kết quả | `docs/test-plan.md` §6 — test ID, số lần chạy, pass rate, thời gian TB |
| Ca flaky / fail | `docs/test-plan.md` §7 — nguyên nhân và cách sửa |
| Phiên khám phá | `evidence/artemis/exploratory/` — báo cáo 15–30 phút, Pro profile |

## 4. Checklist AI code review

| Mục | Nội dung |
|---|---|
| Output gốc của công cụ | `evidence/code-review/` — copy nguyên văn output của GitHub Copilot Code Review trên pull request |
| Quyết định và lý do | `docs/code-review.md` §2 và §3 |
| Commit sửa | 4 commit: `1b6fea8` (CR-01, CR-05, CR-06, CR-07) · `9cf68f5` (CR-02, CR-08) · `000f51b` (CR-03) · `7c0fc66` (CR-04) |

## 5. Quy tắc

1. **Ảnh phải tự chụp**, từ project Firebase của nhóm, có project ID khớp.
2. **Không** chụp ảnh màn hình đã edit (không thêm mũi tên, không ghép ảnh).
3. Ảnh màn hình app chụp trên **thiết bị thật** (đề bảo hiểm: "Phần upload, team có thể sử dụng cloudinary hoặc AWS S3... thay thế" và "Chấm bài phải chạy trên device thật").
4. Tên file: `<service>-<mô tả ngắn>-<timestamp>.png`, ví dụ
   `analytics-ai_match_result-20261112-1430.png`.
5. `evidence/` **không** được chứa API key, service account hay credential nào.
