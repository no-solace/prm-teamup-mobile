# Analytics event plan

Persona: mentor môn EXE (Cô Lan). Mục tiêu sản phẩm (Lab 2): ghép xong các nhóm 5–6 sinh viên đủ ngành mà không phải xếp tay.
Giao diện analytics: [`lib/services/analytics_service.dart`](../lib/services/analytics_service.dart). Bản cài đặt: [`lib/firebase/firebase_analytics_service.dart`](../lib/firebase/firebase_analytics_service.dart).

## 1. Câu hỏi sản phẩm cần trả lời

| # | Câu hỏi | Sự kiện trả lời |
|---|---|---|
| Q1 | Mentor có tin gợi ý AI không, hay sửa/hủy nhiều? | `proposal_approve` (`edited`, `source`), `proposal_discard` |
| Q2 | Thuật toán có hay không tìm được nhóm, và mất bao lâu? | `ai_match_start`, `ai_match_result` |
| Q3 | Mentor thường vướng quy tắc 5–6 người ở đâu? | `member_change_blocked` |
| Q4 | Lớp nhập vào lớn cỡ nào, còn bao nhiêu sinh viên chưa có nhóm? | `class_import` |
| Q5 | Mentor mở màn chi tiết nào nhiều nhất trước khi quyết định? | `view_item` |
| Q6 | Mentor xuất báo cáo cho lớp lớn hay nhỏ? | `report_export` |
| Q7 | Đăng nhập bằng cách nào, và phiên kết thúc ra sao? | `login`, `logout` |

## 2. Danh sách sự kiện (10 sự kiện + user ID)

Quy ước: tên theo [sự kiện khuyến nghị của Firebase](https://support.google.com/analytics/answer/9267735) khi có (`login`, `view_item`), còn lại là `snake_case`. Analytics chỉ nhận `String` và `num`, nên giá trị boolean gửi dạng `0/1`.
**Không có tham số nào chứa email, tên hay số điện thoại.** `item_id` là ID tài liệu (MSSV hoặc ID nội bộ), không phải tên.

| # | Sự kiện | Màn / lúc ghi | Tham số (kiểu) | Câu hỏi | Nơi gọi trong code |
|---|---|---|---|---|---|
| 1 | `login` | S1, sau khi đăng nhập xong | `method` (string: `google` \| `password` \| `phone`) | Q7 | `SignInViewModel._recordLogin` |
| 2 | `logout` | S6, nhấn Sign out | không có | Q7 | `ProfileViewModel` (đăng xuất) |
| 3 | `class_import` | S22 → S23, sau khi ghi thành công | `row_count` (int, số SV đã nhập), `available_count` (int, số SV chưa có nhóm) | Q4 | `ImportClassViewModel.importClass` |
| 4 | `view_item` | S3, S7, S10, lần hiển thị dữ liệu đầu tiên | `item_category` (string: `class` \| `student` \| `proposal`), `item_id` (string) | Q5 | `ClassDetailViewModel`, `StudentDetailViewModel`, `proposalDetailProvider` |
| 5 | `ai_match_start` | S8, khi bắt đầu ghép | `student_count` (int), `team_count` (int) | Q2 | `MatchingViewModel.start` |
| 6 | `ai_match_result` | S8, khi có kết quả | `proposal_count` (int), `no_match` (int 0/1), `duration_ms` (int) | Q2 | `MatchingViewModel.start` |
| 7 | `proposal_approve` | S12, xác nhận Approve | `member_count` (int), `major_count` (int), `source` (string: `ai` \| `manual`), `edited` (int 0/1) | Q1 | `ProposalActionViewModel.approve` |
| 8 | `proposal_discard` | S17, xác nhận Discard | `source` (string: `ai` \| `manual`) | Q1 | `ProposalActionViewModel.discard` |
| 9 | `member_change_blocked` | S13 chạm giới hạn; S25 sau khi sửa làm nhóm dưới 5 người | `reason` (string: `max_6` \| `min_5`) | Q3 | `ProposalActionViewModel.logMemberLimit` (`max_6`), `ProposalActionViewModel.updateMembers` (`min_5`) |
| 10 | `report_export` | S6, upload PDF thành công | `team_count` (int), `file_size_kb` (int) | Q6 | `ReportDemoActions.logExported` |

**User ID:** `setUserId(uid)` sau khi đăng nhập (`SignInViewModel._recordLogin`), `setUserId(null)` khi đăng xuất. Cùng `uid` được gắn vào Crashlytics.

### Điểm chưa đầy đủ (ghi rõ để không bị hiểu nhầm)

- `member_change_blocked` với `min_5` ghi khi một lần sửa thành viên kết thúc ở dưới 5 người (cả khi bỏ lẫn khi thêm), không ghi lúc người dùng chỉ mở màn có sẵn nhóm dưới 5.
- `ai_match_start` ghi cả khi mentor bấm Try again, nên một lần mở S8 có thể sinh nhiều cặp start/result.
- `view_item` ghi một lần mỗi lần mở màn (lúc dữ liệu đầu tiên về), không ghi lại khi dữ liệu realtime thay đổi.

## 3. Kiểm chứng

| Lớp | Cách | Trạng thái |
|---|---|---|
| Có nơi gọi và tham số đúng | [`test/telemetry/telemetry_wiring_test.dart`](../test/telemetry/telemetry_wiring_test.dart) (dùng `FakeAnalyticsService`); `sign_in_view_model_test.dart` cho `login` | 153 test pass (12/11/2026) |
| Hiện trong DebugView | Xem hướng dẫn dưới, ảnh lưu ở `evidence/analytics/` | **Chưa chụp** |

### Bật DebugView trên thiết bị

```bash
adb shell setprop debug.firebase.analytics.app com.group6.teamup_exe
# tắt khi xong:
adb shell setprop debug.firebase.analytics.app .none.
```

Mở Firebase Console → Analytics → DebugView, chọn thiết bị, rồi lần lượt kích hoạt từng sự kiện theo bảng ở mục 2 và chụp màn hình có thấy tên sự kiện và tham số. Ảnh đặt tên `evidence/analytics/<n>_<event>.png`.
Project ID trong ảnh phải là `prm-lab3-cc39e`, khớp `android/app/google-services.json`.
