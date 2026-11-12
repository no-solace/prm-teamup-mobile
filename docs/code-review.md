# AI-assisted code review

AI tìm, người quyết định. Mỗi finding dưới đây có quyết định và lý do tham chiếu yêu cầu của đề, quy tắc kiến trúc, hoặc hệ quả đo được.

## 1. Cách đã review

| Mục | Nội dung |
|---|---|
| Công cụ | Skill `/code-review` của Claude Code (model Claude Sonnet 5.5), mức `medium` |
| Phạm vi | Toàn bộ thay đổi của nhánh `integration/lab3-complete` so với `origin/main` (commit `c4999a6` trở về trước) |
| Ngày | 12/11/2026 |
| Đầu ra gốc | [evidence/code-review/ai-review-2026-11-12.json](../evidence/code-review/ai-review-2026-11-12.json) |

Ghi chú trung thực:
- ID F1 đến F10 do nhóm gán khi chép kết quả; thứ tự trong tệp JSON được sắp lại theo ID, nội dung giữ nguyên.
- Đề khuyến nghị review **một pull request**. Lần review này chạy trên diff của nhánh; khi mở PR cần chạy thêm một công cụ gắn vào PR (Copilot code review, CodeRabbit...) và lưu đầu ra ở `evidence/code-review/`. *(Chưa làm.)*
- Mỗi finding được đối chiếu với code trước khi quyết định. Công cụ chỉ đoán ở F3 ("probably exceeds"), nên F3 được kiểm chứng bằng test thay vì tin.

## 2. Finding và quyết định

Loại: bug, security, architecture, performance, test gap, maintainability.

| ID | Loại | File:dòng | Finding (rút gọn) | Quyết định | Lý do |
|---|---|---|---|---|---|
| F1 | bug | `lib/firebase/firebase_auth_service.dart:67` | `profiles.ensure()` chạy ở mỗi `userChanges()`; lỗi tạm thời (offline) thành lỗi stream phiên, người dùng kẹt ở màn đăng nhập dù Firebase còn phiên | **Chấp nhận, đã sửa** | Ảnh hưởng yêu cầu "Authentication: auth-state routing". Lỗi mạng hoặc timeout giữ phiên; tài khoản không phải mentor bị đăng xuất khỏi Firebase và vẫn bị chặn định tuyến. Commit `110e795`, 2 test mới. Chưa thử với Auth thật trên thiết bị |
| F2 | bug | `lib/firebase/fcm_notification_service.dart:194` | Đồng bộ token FCM chạy trước khi `users/{uid}` được tạo ở lần đăng nhập đầu, bị rules từ chối và không thử lại | **Chấp nhận, đã sửa** | Xác nhận trong code: FCM nghe `FirebaseAuth.authStateChanges()` thô, phát trước `profiles.ensure()`. Ảnh hưởng yêu cầu FCM. Thử lại tối đa 3 lần (1, 2, 4 giây) khi phiên còn hiệu lực. Commit `a1e8b43` (và `182b59a` sửa lint), 2 test mới. Cách thủ công vẫn dùng được: Enable / check notifications |
| F3 | performance / bug | `lib/firebase/firestore_class_service.dart:139` | Một batch import vượt giới hạn truy cập tài liệu của Rules với lớp thật (30–40 SV) | **Bác bỏ** | Không tái hiện: test `import of a 42-student class...` và `...12-student demo class...` đều commit thành công trên emulator (commit `aac27ba`). Giữ hai test làm hồi quy. Lưu ý: kết luận dựa trên emulator, chưa thử trên dự án Firebase thật |
| F4 | bug | `lib/firebase/firestore_proposal_service.dart:369` | Cửa sổ Undo 5 giây so với đồng hồ thiết bị, trong khi Rules dùng giờ máy chủ | **Chấp nhận, chưa sửa** | Rules là nơi quyết định cuối nên không gây sai dữ liệu; chỉ làm trải nghiệm Undo lệch khi đồng hồ máy sai > 5 giây. Mức ưu tiên thấp so với thời gian còn lại |
| F5 | bug | `lib/firebase/firebase_storage_service.dart:50` | Upload để lại tệp mồ côi khi `getDownloadURL` lỗi; lỗi Firebase thô; không kiểm tra `classId` | **Chấp nhận một phần, đã sửa phần mồ côi** | Tệp mồ côi vi phạm quy tắc dọn dẹp Storage của chính service. Phần "lỗi thô" không sửa vì `ReportDemoPanel` đã chuyển lỗi qua `toAppError` khi hiển thị; `classId` được kiểm tra ngay ở bước đọc tài liệu lớp. Commit `45a3229`. Không có test tự động (không mock được `UploadTask` nếu không có emulator Storage). *Cập nhật 12/11: dự án chuyển sang gói Spark, file này được thay bằng `firestore_report_storage.dart`. Metadata và bytes PDF ghi trong cùng một batch, nên không còn tệp mồ côi; có test rules trên emulator* |
| F6 | performance | `lib/firebase/firestore_proposal_service.dart:100` | `_locate` đọc 1 + N tài liệu mỗi thao tác đề xuất | **Chấp nhận, chưa sửa** | Mentor trong phạm vi Lab 3 chỉ có vài lớp, nên chi phí chấp nhận được; sửa cần đổi route để mang `classId` |
| F7 | bug | `lib/viewmodels/classes/matching_view_model.dart:71` | Sau timeout/hủy, `savePending` đang chạy vẫn commit, UI báo lỗi nhưng danh sách thay đổi | **Bác bỏ** | `savePending` là giao dịch idempotent theo ID ổn định (`docs/matching-service.md`): kết quả muộn hội tụ về cùng trạng thái, lần thử lại đối chiếu lại. Không có hỏng dữ liệu. Chỉ có khác biệt hiển thị tạm thời, chấp nhận được |
| F8 | bug | `lib/firebase/firestore_proposal_service.dart:62` | Một đề xuất hỏng làm lỗi cả danh sách Proposals | **Chấp nhận, đã sửa** | Vi phạm yêu cầu "loading/empty/error trên mọi màn tải dữ liệu" theo hướng làm cả tab chết vì một bản ghi. Commit `77d01d1`, test `firestore_proposal_list_test.dart` (fail khi bỏ fix, pass khi có fix) |
| F9 | bug | `lib/viewmodels/auth/sign_in_view_model.dart:148` | Sau đăng nhập SĐT, bộ đếm resend 60 giây vẫn chạy | **Chấp nhận, đã sửa** | Tái hiện được bằng test (state còn `resendSeconds = 60`, `codeSent = true` sau đăng nhập). Commit `55908aa`. Nửa sau của finding (`cancelPhone` thoát sớm) không đổi vì chưa có tình huống tái hiện |
| F10 | maintainability | `lib/services/rule_based_matching_service.dart:38` | SV có MSSV rỗng bị bỏ qua âm thầm, mâu thuẫn "bản ghi xung đột bị cách ly" | **Sửa đổi: ghi tài liệu, không đổi code** | Bỏ qua là đúng vì Rules chỉ chấp nhận ID `^[A-Za-z0-9]...` nên bản ghi như vậy không tồn tại trên Firestore. Ghi rõ trong `docs/matching-service.md` |

Tổng: 10 finding, thuộc các loại bug, performance, maintainability. Chưa có finding loại security hay test gap từ lần chạy này.

## 3. Các commit sửa lỗi

| Finding | Commit | Kiểm chứng |
|---|---|---|
| F1 | `110e795` fix(auth): keep the session on transient profile errors, sign out non-mentors [F1] | 2 test mới (giữ phiên khi lỗi mạng/timeout; đăng xuất khi không phải mentor) |
| F2 | `a1e8b43` fix(fcm): retry the token write until the mentor profile exists [F2] (+ `182b59a`) | 2 test mới (thử lại thành công; bỏ cuộc và báo lỗi) |
| F9 | `55908aa` fix(auth): stop the phone resend countdown after sign-in [F9] | test mới thất bại trước fix, pass sau fix |
| F8 | `77d01d1` fix(proposals): skip one malformed proposal instead of failing the list [F8] | test mới thất bại trước fix, pass sau fix |
| F5 | `45a3229` fix(storage): delete the uploaded PDF when getDownloadURL fails [F5] | chỉ `flutter analyze`, không có test |
| F3 (hồi quy) | `aac27ba` test(rules): regression tests for importing 12 and 42 student classes | 25/25 test rules pass |

Liên kết đầy đủ khi đã push: `https://github.com/no-solace/prm-teamup-mobile/commit/<hash>`.

## 4. Việc còn lại

- [ ] Mở PR và chạy thêm một công cụ review gắn vào PR; lưu đầu ra.
- [ ] Thử F1 và F2 trên máy thật (đăng nhập lần đầu, rồi tắt mạng và mở lại app).
- [ ] Hai finding loại security và test gap: lần review sau nên yêu cầu công cụ tập trung vào Rules và độ phủ test.

## 5. Công cụ AI đã dùng trong Lab 3

| Công cụ | Dùng để |
|---|---|
| Codex (OpenAI) | Viết phần lớn mã app: dịch vụ matching, đối chiếu bản nháp (`matching_drafts.dart`), Firestore rules và test rules, tích hợp Firebase |
| Claude Code (Claude Sonnet 5.5) | Nối sự kiện Analytics và Crashlytics non-fatal, viết test cho chúng, bộ ARTEMIS (`e2e_test/`), các tài liệu trong `docs/`, chạy review ở mục 1 và sửa F1, F2, F5, F8, F9 |
| Google ARTEMIS | Công cụ kiểm thử E2E theo yêu cầu của đề (chưa chạy, xem `docs/test-plan.md`) |

*Bổ sung ở đây mọi công cụ AI khác nhóm đã dùng cho Lab 3 (làm slide, báo cáo, thiết kế). Đề coi việc không khai báo là vi phạm.*
