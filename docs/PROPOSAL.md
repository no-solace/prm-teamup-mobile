# Proposal dự án Lab 3: TeamUp EXE

> PRM393 Lab 3 (Flutter & Firebase), nhóm 6, 4 thành viên. Ngày lập: 31/10/2026; sửa lần 2: 05/11/2026.
> Đặc tả là thiết kế Lab 2 bản cuối: [`prm323-lab2-group6`](https://github.com/Kenn0679/prm323-lab2-group6) (commit `766ad06`, bản sao ở `docs/prm323-lab2-group6/`). Gồm persona, 3 flow, 25 màn, `design/DESIGN.md`, `design/screen-spec.md`, `handoff/flutter-handoff.md` và Figma.

**Thay đổi so với bản 31/10:** bản trước lấy các luồng mới D/E/F (proposal đề tài, đặt lịch, họp và biên bản) làm trọng tâm. Các luồng này không có trong Lab 2, và Lab 2 không có giao diện cho sinh viên. Đề Lab 3 lại chấm trên "mọi màn và cả 3 flow của Lab 2". Vì vậy bản này lấy **3 flow A/B/C của Lab 2 (25 màn)** làm phạm vi chính. D/E/F chuyển xuống mục 9 và chỉ làm khi giảng viên đồng ý.

**Cập nhật 12/11/2026 (sửa lần 3):**
- A/B/C đã xong. Nhóm làm thêm **D/E/F** và **vai sinh viên** (trưởng nhóm, thành viên), xem mục 9.
- Dự án ở **gói Spark (miễn phí)**, không nâng Blaze. Vì vậy:
  - không dùng Cloud Storage: file lưu ngay trong Firestore, tối đa 900 KB/file;
  - không dùng Cloud Functions: thông báo D/E/F do app tự sinh từ Firestore.

  Xem mục 5 và 10.

## 1. Tóm tắt

TeamUp EXE là app Android (Flutter) cho **mentor/giảng viên môn EXE** (persona Cô Lan). App giúp ghép sinh viên chưa có nhóm vào các nhóm còn thiếu người, để mỗi nhóm có 5-6 người thuộc nhiều ngành:

1. Mentor **import danh sách lớp** (MSSV, họ tên, lớp, nhóm, ngành). App tự ẩn sinh viên đã có nhóm và nhóm đã đủ 6.
2. Mentor xem **sinh viên chưa có nhóm** và **nhóm còn thiếu người**.
3. Bấm **Match with AI**: app đề xuất ghép theo ngành còn thiếu, mỗi đề xuất có nhãn mức phù hợp và lý do.
4. Mentor **thêm/bớt thành viên** rồi **duyệt**, hoặc **ghép tay** khi AI không ghép được.
5. Mentor **xuất PDF** danh sách nhóm đã duyệt của lớp.

Ở A/B/C, sinh viên chỉ là dữ liệu (đúng thiết kế Lab 2). Phần mở rộng D/E/F (mục 9) cho sinh viên dùng app:
- trưởng nhóm nộp đề tài, đặt lịch họp với mentor;
- cả nhóm xem kết quả và viết biên bản họp.

## 2. Người dùng

| Vai | Ai | Dùng app ở Lab 3? |
|---|---|---|
| **Mentor / giảng viên** | Persona Cô Lan (P01, Primary) | Có: A/B/C và phía mentor của D/E/F |
| Sinh viên (trưởng nhóm / thành viên) | P02, Supporting | Có, chỉ ở D/E/F. Tự onboard bằng **mã lớp + MSSV** (phải có trong danh sách lớp đã import và đã có nhóm) |
| Điều phối khoa | P03 (giả định trong persona Lab 2) | Không ở Lab 3; dự kiến là vai web admin ở Final (mục 8) |

## 3. Phạm vi: 3 flow và 25 màn của Lab 2

| Flow | Mục tiêu | Màn | Đường lỗi bắt buộc |
|---|---|---|---|
| **A** | Duyệt gợi ý AI cho một lớp (nhánh phụ: import lớp) | S1, S19, S2, S22, S23, S3, S4, S7, S8, S18, S9, S10, S12, S14 | Email sai hoặc hủy đăng nhập (S19); mất mạng khi AI chạy (S18); file import sai định dạng (S22, cần bổ sung) |
| **B** | Thêm/bớt thành viên trong đề xuất | S9, S10, S11, S13, S24, S25, S7, S12, S14 | Vượt 6 người (S13); dưới 5 người thì khóa Approve (S25) |
| **C** | AI không ghép được, mentor ghép tay | S3, S5, S8, S15, S16, S21, S20, S17, S12, S14 | SV đã có nhóm bị khóa (S16); tìm không ra (S21); hủy đề xuất (S17) |
| (tab) | Profile và khu vực Demo Firebase | S6 | — |

Quy tắc nghiệp vụ lấy nguyên từ Lab 2 (`ux/persona.md` mục 0, `ux/user-flow.md` mục 5):

| Mã | Quy tắc |
|---|---|
| R1 | Nhóm tối thiểu 5, tối đa 6. 0-4 người là thiếu; 5 người duyệt được và còn thêm được 1; 6 người là đầy, khóa thêm ("Max 6 members"). |
| R2 | Sau import: SV đã có Group bị loại khỏi "No team" và pool AI; nhóm đủ 6 bị loại khỏi danh sách đích. |
| R3 | Ghép chỉ dựa trên ngành (SE, AI, MKT, GD); ưu tiên nhóm thiếu ngành. Không dùng kỹ năng hay lịch rảnh. |
| R4 | Chưa bấm Approve thì dữ liệu nhóm không đổi. Approve có Undo 5 giây (S14). Discard thì AI không đề xuất lại (S17). |
| R5 | Mentor chỉ sửa nhóm thuộc lớp mình đã import. |

**"AI" ở Lab 3:** dùng logic theo ngành trong `MatchingService` (không có mô hình thật, như Lab 2). Interface được thiết kế để Final thay bằng Gemini (mục 8).

### Chỗ khác thiết kế Lab 2 (ghi vào `docs/design-traceability.md` và cập nhật Figma)

| Màn | Thay đổi | Lý do |
|---|---|---|
| S1, S19 | Ô email + Continue đổi thành nút **Sign in with Google**. S19 đổi thành thông báo hủy đăng nhập / mất mạng / tài khoản không hợp lệ | Lab 3 bắt buộc Google Sign-In |
| S6 | Thêm mục **Firebase demo**: trung tâm thông báo, xuất và upload PDF, giá trị Remote Config, nút crash thử | Lab 3 yêu cầu khu vực demo |
| S22 | Bổ sung trạng thái lỗi "sai định dạng / thiếu cột" (Lab 2 ghi "thiết kế sau") | Đường lỗi thật cho Crashlytics non-fatal |
| S2 | Thêm trạng thái empty "Chưa có lớp, hãy import" | Dữ liệu thật từ Firestore, lần đầu dùng sẽ rỗng |
| Toàn app | Dữ liệu mẫu cố định đổi thành Firestore | Lab 3 cấm dữ liệu cứng trong bản nộp |

## 4. Công nghệ và kiến trúc

| Hạng mục | Lựa chọn |
|---|---|
| App | Flutter stable, Material 3, Android, chạy trên **thiết bị thật** |
| Kiến trúc | **MVVM + Riverpod**: View → ViewModel → Service → Firebase SDK. View không gọi SDK. Mỗi ViewModel có state model rõ (sealed class loading / data / empty / error). Mỗi Service có interface và bản fake. |
| Điều hướng | `go_router` + `StatefulShellRoute`. Mentor: 5 tab **Classes / Proposals / Topics / Schedule / Profile** (3 tab của Lab 2 + 2 tab D/E/F). Sinh viên: 4 tab **My team / Topics / Schedule / Profile**. Chặn route theo đăng nhập, onboarding và vai |
| Design system | Token từ `flutter-handoff.md` (Bảng 1) vào `lib/theme/`; component (Bảng 2) vào `lib/widgets/` |
| Dữ liệu | Cloud Firestore + `firebase/firestore.rules` |
| Import | Đọc `.xlsx`/`.csv` bằng `file_picker` + `excel`/`csv` |
| PDF | `pdf` + `printing` |
| Cấu trúc thư mục | `lib/` gồm `models/`, `services/`, `firebase/`, `viewmodels/`, `screens/`, `widgets/`, `theme/`, `utils/`. Model và service Firestore viết sao cho tách được thành `packages/core/` ở Final |

**Service:** `AuthService`, `ClassService` (import, lớp, sinh viên), `TeamService`, `MatchingService`, `ProposalService` (đề xuất ghép nhóm), `ReportService` (tạo PDF), `StorageService` (lưu PDF báo cáo), `NotificationService`, `AnalyticsService`, `CrashService`, `ConfigService`. D/E/F thêm `TopicService`, `BookingService`, `MeetingService`.

**Collection Firestore (bản đang chạy; chi tiết ở `docs/architecture.md` mục 7 và `firebase/firestore.rules`):**

| Collection | Nội dung chính |
|---|---|
| `users/{uid}` | `role` (mentor / leader / member), `displayName`; sinh viên thêm `classId`, `teamId`, `studentId`, `mentorUid` (không đổi sau onboarding) |
| `classes/{classId}` | `mentorUid`, `name`, thống kê |
| `classes/{classId}/students/{mssv}` | `fullName`, `major`, `teamId` hoặc null |
| `classes/{classId}/teams/{teamId}` | `name`, `memberIds`, `majors`, `status` |
| `classes/{classId}/proposals/{id}` | `teamId`, `addStudentIds`, `fit`, `reason`, `status` (pending / approved / discarded), `source` (ai / manual) |
| `reports/{id}` | `ownerUid`, `classId`, `sizeKb`, `createdAt`; bytes PDF ở `reports/{id}/files/pdf` |
| `users/{uid}/notifications/{id}` | Thông báo đã nhận (trung tâm thông báo) |
| `topics/{classId}_{teamId}` | D: đề tài của nhóm, `status` (pending / approved / rejected / revision_requested), `revisionCount`; file outline ở `files/outline` |
| `mentors/{uid}/slots/{id}` | E: khung giờ rảnh, `status` (available / booked) |
| `bookings/{id}` | E/F: lịch hẹn, `status` (requested / confirmed / cancelled / completed), `meetUrl` (Google Meet) |
| `minutes/{bookingId}` | F: biên bản, việc cần làm, đánh giá 1-5 sao, `isSignedByMentor` |

## 5. Tích hợp 6 dịch vụ Firebase

| Dịch vụ | Dùng ở đâu | Đường lỗi và bằng chứng |
|---|---|---|
| **Authentication** | Google Sign-In (S1); `authStateChanges` điều hướng S1 ↔ S2; Sign out ở S6 xóa state cục bộ | Hủy đăng nhập, mất mạng (S19); ảnh Console → Users |
| **Lưu file** (thay Cloud Storage) | Gói Spark không tạo được bucket Storage, nên file lưu trong Firestore dạng `bytes`, mỗi file một tài liệu ≤ 900 KB: PDF danh sách nhóm (`reports/{id}/files/pdf`), outline đề tài (`topics/{id}/files/outline`). PDF biên bản tạo lại trên máy, không lưu | `firestore.rules` chỉ cho chủ sở hữu (báo cáo) hoặc nhóm + mentor (outline); chặn file > 900 KB và sai kiểu; test trên emulator. Cần giảng viên xác nhận cách thay thế này (mục 11) |
| **Cloud Messaging** | Xin quyền Android 13+; nhận ở 3 trạng thái app; lưu vào trung tâm thông báo (S6); payload `route` mở đúng màn (ví dụ `/proposals` → S9, `/classes/{id}` → S3). Thông báo D/E/F (đề tài mới, kết quả duyệt, lịch hẹn) do app tự sinh khi theo dõi Firestore, đi cùng đường xử lý với push | Gửi thử từ Console; từ chối quyền; giải thích token trên slide (ai cấp, lưu ở đâu, gửi bằng gì). Không có Cloud Functions: thông báo D/E/F chỉ đến khi app đang mở hoặc chạy nền |
| **Analytics** | ≥ 7 sự kiện (bảng dưới); `setUserId` sau đăng nhập; không đưa email hay tên vào tham số | Ảnh DebugView cho từng sự kiện |
| **Crashlytics** | `FlutterError.onError` + `PlatformDispatcher.onError`; non-fatal khi import lỗi (S22) và AI quá 30 giây (S8 → S18); `setUserIdentifier`; khóa `role`, `class_id`; nút crash thử ở S6 | Ảnh dashboard có non-fatal, crash, khóa, user ID |
| **Remote Config** | `ai_matching_enabled` ẩn/hiện nút Match with AI (S3, S4, S5); `max_proposals_shown` giới hạn số thẻ ở S9; `max_topic_revisions` (số lần nộp lại đề tài, mặc định 3); `default_meeting_duration_minutes` (độ dài khung giờ, mặc định 30); mặc định trong app và `firebase/remote-config-defaults.json` | Ảnh trước/sau; mất mạng thì dùng mặc định; giải thích fetch interval và cache |

### Kế hoạch Analytics (bản nháp, chốt ở `docs/analytics-plan.md`)

| Sự kiện | Khi nào | Tham số (kiểu) | Câu hỏi sản phẩm |
|---|---|---|---|
| `login` | Đăng nhập thành công | `method` (string) | Bao nhiêu mentor quay lại mỗi tuần? |
| `logout` | Đăng xuất | — | Phiên kéo dài bao lâu? |
| `class_import` | Import xong (S23) | `row_count` (int), `available_count` (int) | Mỗi lớp còn bao nhiêu SV lẻ khi bắt đầu? |
| `view_item` | Mở S3, S7, S10 | `item_category` (class / student / proposal), `item_id` (string) | Mentor xem gì trước khi duyệt? |
| `ai_match_start` | Bấm Match with AI | `student_count` (int), `team_count` (int) | AI được dùng ở lớp cỡ nào? |
| `ai_match_result` | AI xong (S9 hoặc S15) | `proposal_count` (int), `no_match` (bool), `duration_ms` (int) | Tỉ lệ AI không ghép được? |
| `proposal_approve` | Duyệt (S12) | `member_count` (int), `major_count` (int), `source` (ai / manual), `edited` (bool) | Mentor có phải sửa đề xuất AI nhiều không? Tiêu chí 2 Lab 2 |
| `proposal_discard` | Discard (S17) | `source` (string) | Đề xuất nào bị bỏ? |
| `member_change_blocked` | Gặp S13 hoặc S25 | `reason` (max_6 / min_5) | Quy tắc 5-6 có gây vướng không? |
| `report_export` | PDF lưu xong | `team_count` (int), `file_size_kb` (int) | Tính năng xuất có được dùng không? |

## 6. Tiêu chí thành công (từ Lab 2)

| # | Tiêu chí | Cách đo ở Lab 3 |
|---|---|---|
| 1 | Duyệt xong gợi ý AI cho một lớp dưới 5 phút | ARTEMIS + bấm giờ; `ai_match_start` → `proposal_approve` cuối |
| 2 | Mọi nhóm sau duyệt có 5-6 người, ≥ 3 ngành | Truy vấn Firestore; tham số `major_count` |
| 3 | Thêm hoặc đổi một thành viên và duyệt dưới 60 giây | ARTEMIS (Flow B) |
| 4 | 100% SV đã có nhóm không xuất hiện ở "No team" / pool AI | Unit test `MatchingService` + ARTEMIS |
| 5 | Không nhóm nào vượt 6; thêm vào nhóm đầy luôn báo rõ | Unit test + ARTEMIS (S13) |
| 6 | Mọi màn tải dữ liệu có đủ 4 trạng thái; 6 dịch vụ đều có ca lỗi | Review mã, ARTEMIS, ảnh Console |

## 7. Kiểm thử và rà soát

- **Unit test:** ViewModel với Service fake; `MatchingService` (R1-R3) chạy trên dữ liệu mẫu cố định.
- **ARTEMIS (`e2e_test/`, `docs/test-plan.md`):** ≥ 10 ca, phủ A/B/C cùng đường lỗi, sign-in, mỗi tab, mỗi loại màn chi tiết, xuất và upload, Remote Config, sign-out. Có ≥ 1 tương tác Android gốc (bảng chọn tài khoản Google, hộp quyền thông báo, trình chọn file import). Mỗi ca chạy ≥ 3 lần; kiểm giá trị agent báo về, không chỉ kiểm `SUCCESS`. Thêm `Semantics` cho widget chính. 1 phiên khám phá 15-30 phút (Pro profile).
- **AI code review (`docs/code-review.md`):** 1 PR; ≥ 5 phát hiện gắn dòng, thuộc ≥ 2 nhóm; ghi quyết định kèm lý do; ≥ 3 commit sửa có mã phát hiện.

## 8. Hướng tới Final Assignment

Đề Final yêu cầu mobile cho persona Lab 2, web admin cho vai khác, rules phân quyền có test, 1 luồng liên vai và 1 tính năng Gemini. Phạm vi A/B/C nối sang Final như sau:

- **Mobile:** giữ nguyên app mentor; thêm inbox cho thông báo (`announcements`).
- **Web admin:** vai **Điều phối khoa** (P03). Có các màn quản lý lớp, hàng duyệt (review queue), dashboard (số SV lẻ, số nhóm đủ 5-6, tỉ lệ duyệt) và form thông báo.
- **Luồng liên vai (dự kiến):** mentor duyệt nhóm trên mobile → điều phối khoa xác nhận hoặc trả lại trên web → app mentor cập nhật realtime và nhận thông báo.
- **AI mức 2:** S8 gọi Gemini qua Firebase AI Logic, trả JSON đề xuất (Dart model), mentor xác nhận và chỉnh sửa; S15/S18 là đường dự phòng; model, prompt và cờ bật/tắt lấy từ Remote Config.
- **Lưu ý:** Final để Cloud Storage và Cloud Functions ngoài phạm vi. PDF ở Final lưu trên máy, metadata lưu Firestore.

## 9. Mở rộng D/E/F (đã làm sau khi A/B/C xong)

Các luồng của bản 31/10 không có trong Lab 2, nên được ghi là "mở rộng ở Lab 3". Đề Final ghi "New features earn no points", vì vậy nhóm chỉ làm sau khi A/B/C và 6 dịch vụ đã xong.

**Vai sinh viên:**
- Đăng nhập Google, rồi onboard bằng **mã lớp** (mentor copy ở S3) + **MSSV** và chọn trưởng nhóm hoặc thành viên.
- Rules kiểm MSSV có trong lớp và đúng nhóm. Vai và liên kết lớp/nhóm không đổi được sau đó.

**D. Đề tài dự án** (đổi tên từ "Proposal" để không trùng S9/S10):
- Trưởng nhóm nộp tên đề tài, tóm tắt, tech stack và outline PDF/DOCX (≤ 900 KB).
- Mentor duyệt, từ chối hoặc yêu cầu sửa (bắt buộc góp ý).
- Nộp lại sau khi bị trả về thì tính 1 lần sửa, tối đa theo Remote Config `max_topic_revisions`.

**E. Lịch rảnh và đặt lịch:**
- Mentor mở khung giờ (không được trùng hoặc chồng nhau).
- Trưởng nhóm đặt một khung và chọn mục đích: duyệt đề tài, review sprint hoặc hướng dẫn kỹ thuật.
- Mentor xác nhận và dán link Google Meet (kiểm đúng dạng `meet.google.com/xxx-xxxx-xxx`), hoặc từ chối.
- Đặt lịch và giữ khung giờ diễn ra trong cùng một giao dịch, nên không đặt trùng được.

**F. Họp và biên bản:**
- Sau buổi họp đã xác nhận, cả hai bên viết biên bản: tóm tắt và tối đa 20 việc cần làm, mỗi việc có người phụ trách và hạn.
- Mentor đánh giá 1-5 sao và ký; sau khi ký thì biên bản bị khóa.
- Xuất PDF tiếng Việt và chia sẻ.

**Không làm:** Google Calendar API (link Meet do mentor dán).

## 10. Rủi ro và xử lý

| Rủi ro | Mức | Xử lý |
|---|---|---|
| Giảng viên muốn giữ D/E/F làm trọng tâm | Trung bình | Hỏi ngay (mục 11); nếu có thì chia lại việc, A/B/C vẫn phải đủ |
| 25 màn trong 7 ngày | Cao | Chia đều theo flow, làm song song từ ngày 1; widget dùng chung xong trưa ngày 2; nhiều màn là trạng thái của cùng một màn (S13/S11, S19/S1, S21/S16, S25/S10); hạn chót tính năng cuối ngày 4; thứ tự cắt khi trễ ở `PHAN_CONG.md` mục 5 |
| Google Sign-In lỗi trên máy thành viên khác | Trung bình | Thêm SHA-1 debug của cả 4 máy vào Firebase ở tuần 0 |
| Không nâng được Blaze (cần giữ thẻ ~700k đồng) | Đã xảy ra | Ở lại gói Spark:<br>• File lưu trong Firestore, quyền theo `uid` vẫn do `firestore.rules` kiểm. Không dùng Cloudinary vì không giới hạn được quyền theo `uid` khi không có server.<br>• Thông báo D/E/F do app tự sinh.<br>Giới hạn: file ≤ 900 KB; app đã tắt hẳn thì không nhận thông báo D/E/F. Nếu sau này có Blaze: chuyển file sang Storage và gửi push bằng Cloud Functions (định dạng thông báo giữ nguyên) |
| Sinh viên nhận nhầm MSSV của người khác | Trung bình | Rules chỉ kiểm MSSV có trong lớp và đúng nhóm; ai biết mã lớp + MSSV đều nhận được. Bản Final cần mentor xác nhận hoặc mời qua email |
| Crashlytics chậm hiện trên Console | Thấp | Demo trước buổi chấm; mở lại app sau crash để báo cáo được gửi |
| Lộ khóa bí mật | Trung bình | Không commit key ARTEMIS, service account, keystore; `google-services.json` được phép commit |

## 11. Cần giảng viên xác nhận

1. Phạm vi Lab 3 là 3 flow A/B/C (25 màn) của Lab 2; D/E/F không bắt buộc. Có đúng không?
2. Ghi chú "admin phải dùng web" áp dụng cho Lab 3 hay chỉ Final?
3. Đặt tên repo, báo cáo và slide (`<StudentID>`) thế nào khi làm theo nhóm?
4. Lưu file trong Firestore (gói Spark) có được tính thay cho Cloud Storage không?
