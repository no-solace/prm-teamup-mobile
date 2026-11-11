# Analytics event plan — TeamUp EXE

> Theo mẫu Appendix A của đề Lab 3 §6. Kế hoạch được viết **trước** khi viết
> code tracking; mỗi event gắn với đúng bước trong flow Lab 2 để biết người
> dùng rời ở bước nào.

**Nguyên tắc bắt buộc**

1. **Không có dữ liệu cá nhân** trong tham số: không e-mail, không tên, không
   họ tên sinh viên. Chỉ dùng ID hệ thống (MSSV, classId, teamId, proposalId)
   và số đếm.
2. Analytics là **best effort**: lỗi tracking không được làm hỏng luồng người
   dùng (xem `lib/viewmodels/instrumentation.dart`).
3. Mỗi event phải trả lời được **một câu hỏi sản phẩm** cụ thể.
4. User ID được set sau khi đăng nhập (`AnalyticsService.setUser(uid)`), nên các
   event sau đó gom được theo phiên mà không cần e-mail.

---

## 1. Bảng event

| Event (tên) | Trigger | Parameters (kiểu) | Flow / bước Lab 2 | Câu hỏi sản phẩm |
|---|---|---|---|---|
| `login` | Đăng nhập thành công | `method` (string: `google` \| `email` \| `phone`) | S1 → S2 (Flow A) | Mentor quay lại hằng tuần; phương thức đăng nhập nào phổ biến nhất? |
| `logout` | Người dùng bấm Sign out | *(không có)* | S6 → S1 | Phiên làm việc trung bình dài bao lâu trước khi mentor thoát? |
| `class_import` | Nhập danh sách lớp thành công (ghi Firestore xong) | `row_count` (int), `available_count` (int) | S22 → S23 (Flow A) | Mentor import bao nhiêu sinh viên mỗi lần, và bao nhiêu người còn "available" để ghép? Tỉ lệ `available_count / row_count` thấp có phải do dữ liệu lớp đã có nhóm sẵn? |
| `view_item` | Mở một màn chi tiết | `item_category` (string: `class` \| `student` \| `proposal`), `item_id` (string) | S3, S7, S10/S20 | Mentor xem nhiều nhất lớp / sinh viên / đề xuất nào? Đề xuất nào được mở nhiều nhưng bị bỏ? |
| `ai_match_start` | Bắt đầu một lần ghép bằng AI | `student_count` (int), `team_count` (int) | S3 → S8 (Flow A, C) | Kích thước lớp nào khiến AI được gọi nhiều nhất? |
| `ai_match_result` | Lần ghép kết thúc (kể cả khi không ra đề xuất) | `proposal_count` (int), `no_match` (int 0/1), `duration_ms` (int) | S8 → S9 / S15 (Flow A, C) | Tỉ lệ lần ghép không ra kết quả (`no_match = 1`) là bao nhiêu, và độ trễ có làm mentor bỏ giữa chừng không? |
| `proposal_approve` | Duyệt một nhóm | `member_count` (int), `major_count` (int), `source` (string: `ai` \| `manual`), `edited` (int 0/1) | S10 → S14 (Flow B) | Mentor duyệt nhóm do AI hay tự ghép tay? Nhóm duyệt có đạt 3 ngành (`major_count ≥ 3`) không? |
| `proposal_discard` | Bỏ một đề xuất | `source` (string: `ai` \| `manual`) | S10 → S17 (Flow C) | Đề xuất AI nào bị bỏ nhiều nhất — gợi ý của thuật toán có chất lượng kém ở đâu? |
| `member_change_blocked` | Thao tác bị chặn vì giới hạn 6 thành viên | `reason` (string: `max_6`) | S13 (Flow B) | Mentor có thường xuyên cố thêm người thứ 7 không (tức đề xuất AI chưa đủ 6 người)? |
| `report_export` | File PDF đã sinh **và** upload thành công | `team_count` (int), `file_size_kb` (int) | S6 demo (Export) | Sau khi duyệt, mentor có thực sự xuất báo cáo không? `team_count` so với số đề xuất cho biết chất lượng kết quả ghép. |

**Tổng: 10 event** (yêu cầu tối thiểu 7), phủ đủ: sign-in, sign-out, hành động
chính (`ai_match_start` / `ai_match_result`), mở màn chi tiết (`view_item`) và
xuất/upload file (`report_export`).

**Tên chuẩn của Firebase được dùng khi phù hợp**: `login` (Firebase
recommended), `logout`, `view_item`. Tên custom còn lại dùng `snake_case`:
`class_import`, `ai_match_start`, `ai_match_result`, `proposal_approve`,
`proposal_discard`, `member_change_blocked`, `report_export`.

---

## 2. Ánh xạ event → bước trong flow (để thấy người dùng rời ở đâu)

| Flow | Bước | Event đo được | Ý nghĩa |
|---|---|---|---|
| A | S1 → S2 | `login` | Có vào được app không? |
| A | S22 → S23 | `class_import` | Có nạp được dữ liệu lớp không? |
| A | S3 → S8 | `ai_match_start` | Có bấm "Match with AI" không? |
| A | S8 → S9 / S15 | `ai_match_result` | AI có ra kết quả không (`no_match`)? |
| A/C | S9 → S10 | `view_item` (proposal) | Mentor có mở đề xuất không? |
| B | S10 → S12 → S14 | `proposal_approve` | Có duyệt không? |
| B | S11 (vượt 6) | `member_change_blocked` | Có gặp trần 6 người không? |
| B/C | S10 → S17 | `proposal_discard` | Có bỏ đề xuất không? |
| — | S6 → Export PDF | `report_export` | Có lấy báo cáo về không? |
| — | S6 → S1 | `logout` | Phiên kết thúc ở đâu? |

**Success criterion của Lab 2** (mentor "Lan Nguyen" cần ghép được lớp 5–6 người
đa ngành trong một lần ghép): phễu `ai_match_start` → `ai_match_result`
(`no_match = 0`) → `proposal_approve` → `report_export` là chuỗi đo trực tiếp việc
đạt được tiêu chí đó. Tỉ lệ rớt nhiều nhất ở bước nào là bước cần sửa.

---

## 3. Nơi gọi event (mã nguồn)

| Event | ViewModel / nơi gọi | Ghi chú |
|---|---|---|
| `login` | `viewmodels/auth/sign_in_view_model.dart` → `_recordLogin` | Sau khi có `AppUser`. |
| `logout` | `viewmodels/auth/session_view_model.dart` | Khi session bị xoá. |
| `class_import` | `viewmodels/classes/import_class_view_model.dart` → `importClass()` | Sau khi Firestore ghi xong. |
| `view_item` | `class_detail_view_model.dart` (category `class`), `student_detail_view_model.dart` (`student`), `proposal_view_model.dart` → `proposalViewTrackerProvider` (`proposal`) | Mỗi lần mở 1 event; proposal dùng cờ chống ghi lặp vì stream phát nhiều snapshot. |
| `ai_match_start` | `viewmodels/classes/matching_view_model.dart` | Khi đã biết `studentCount`/`teamCount`. |
| `ai_match_result` | cùng file | Sau khi có `proposalCount`, kèm `durationMs`. |
| `proposal_approve` | `viewmodels/proposals/proposal_view_model.dart` → `approve()` | Sau khi transaction thành công. |
| `proposal_discard` | cùng file → `discard()` | |
| `member_change_blocked` | cùng file → `logMemberLimit()` | Gọi từ `add_member_screen.dart` khi chạm giới hạn 6. |
| `report_export` | `viewmodels/profile/report_demo_view_model.dart` → `upload()` | Sau khi `UploadDone`, dùng `teamCount` của file vừa sinh. |

Tất cả đều gọi qua `lib/viewmodels/instrumentation.dart` (`trackAnalytics`), bọc
try/catch để lỗi tracking không làm hỏng luồng chính.

---

## 4. Quy tắc tham số

| Quy tắc | Cách thực hiện |
|---|---|
| Chỉ `String` và `num` | `FirebaseAnalytics.logEvent` chỉ nhận 2 kiểu đó. Bool được chuyển thành `0/1` bởi `FirebaseAnalyticsService._b()`. |
| Không dữ liệu cá nhân | Chỉ dùng MSSV (`190401`), `classId`, `teamId`, `proposalId` — đều là mã hệ thống, không phải tên/email. |
| Giá trị số nhất quán | `row_count`, `available_count`, `student_count`, `team_count`, `proposal_count`, `member_count`, `major_count`, `team_count`, `file_size_kb` đều là `int`. `duration_ms` là `int`. |
| Tên tham số `snake_case` | Đúng như Firebase convention. |
| `item_category` là enum đóng | `class` \| `student` \| `proposal` — tránh cardinality tăng vô hạn. |
| `source` là enum đóng | `ai` \| `manual`. |

---

## 5. Bằng chứng (evidence)

* **DebugView** (Firebase Console → Analytics → DebugView): bật chế độ debug trên
  thiết bị, chạy lần lượt các hành động, chụp màn hình từng event có đủ tham số.
  Ảnh lưu tại `evidence/analytics/`.
* **Logcat** (`adb logcat | grep "Analytics"`): dùng cho bằng chứng kèm ARTEMIS.
* Danh sách ảnh: `evidence/analytics/README.md`.

---

## 6. Câu hỏi sản phẩm mà kế hoạch này trả lời được

1. Mentor có thực sự dùng app để ghép nhóm, hay chỉ đăng nhập rồi thoát?
   → `login` vs `logout`, `ai_match_start`.
2. Tỉ lệ lần ghép thất bại là bao nhiêu, và việc đó có phụ thuộc kích thước lớp?
   → `ai_match_start` + `ai_match_result` (`no_match`, `student_count`).
3. Đề xuất nào mentor bỏ nhiều nhất — tức thuật toán ghép sai ở trường hợp nào?
   → `proposal_discard` + `view_item` (proposal).
4. Mentor có dùng hết kết quả AI không, hay thường ghép tay?
   → so sánh `proposal_approve.source` (`ai` vs `manual`).
5. Có bao giờ mentor không lấy được báo cáo dù đã duyệt nhóm không?
   → `proposal_approve` không đi kèm `report_export`.
