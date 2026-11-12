# AI-assisted code review record (Lab 3 §8)

> **AI tìm ra, tôi quyết định.** Mỗi finding dưới đây gắn với một file và dòng
> cụ thể, kèm quyết định (accept / modify / reject) và lý do có căn cứ: một
> yêu cầu trong đề Lab 3, một quy tắc ở §5, một tác động đo được, hoặc một ràng
> buộc thực tế. "AI nói vậy" không phải là lý do.
>
> Hồ sơ này gộp **hai lần review** của nhóm:
>
> * **Lần 1 — CR-01 … CR-12**: review của nhánh `feature/lab3-complete-gaps`
>   (khối tài liệu và bộ ARTEMIS), chạy bằng GitHub Copilot Code Review,
>   Cursor Agent và Copilot Chat.
> * **Lần 2 — F1 … F10**: review của nhánh `integration/lab3-complete` so với
>   `origin/main` (Flow D/E/F, matching transaction, Rules), chạy bằng skill
>   `/code-review` của Claude Code.

---

## 1. Công cụ AI đã dùng

| Công cụ | Phiên bản | Mục đích trong lab này | Phạm vi |
|---|---|---|---|
| **Cursor Agent (Claude Opus 4.5)** | 2026-11 | Rà soát toàn bộ codebase theo checklist Lab 3 §5–§10, sinh finding, viết lại code và tài liệu | Toàn bộ repo |
| **Claude Code** (trong Cursor) | 2026-11 | Viết lại `docs/`, `e2e_test/`, commit theo finding | `docs/`, `e2e_test/` |
| **Claude Code** (skill `/code-review`) | Claude Sonnet 5.5, mức `medium` | Review diff của nhánh `integration/lab3-complete` so với `origin/main` | Nhánh integration |
| **GitHub Copilot Chat** | 2026-11 | Gợi ý bảo trì trong `lib/viewmodels/` | `lib/viewmodels/` |
| **GitHub Copilot Code Review** | 2026-11 | Rà soát pull request `feature/lab3-complete-gaps` | PR diff |
| **Codex (OpenAI)** | 2026-11 | Phần lớn mã app: matching service, `matching_drafts.dart`, Firestore rules và test rules, tích hợp Firebase | `lib/`, `firebase/` |
| **Google ARTEMIS** | 2026-11 | Kiểm thử E2E theo yêu cầu của đề | `e2e_test/` |

> **Công cụ review chính thức**: GitHub Copilot Code Review chạy trên pull request
> `feature/lab3-complete-gaps` (diff so với `origin/integration/lab3-complete`).
> Output gốc của lần review 2 được lưu tại
> [`evidence/code-review/ai-review-2026-11-12.json`](../evidence/code-review/ai-review-2026-11-12.json).

Ghi chú trung thực:
- ID F1 đến F10 do nhóm gán khi chép kết quả; thứ tự trong tệp JSON được sắp lại theo ID, nội dung giữ nguyên.
- Đề khuyến nghị review **một pull request**. Lần review 1 chạy trên diff của nhánh; lần review 2 cũng chạy trên diff của nhánh. Khi mở PR cần chạy thêm một công cụ gắn vào PR (Copilot code review, CodeRabbit...) và lưu đầu ra ở `evidence/code-review/`. *(Đã có từ lần 1.)*
- Mỗi finding được đối chiếu với code trước khi quyết định. Công cụ chỉ đoán ở F3 ("probably exceeds"), nên F3 được kiểm chứng bằng test thay vì tin.

---

## 2. Bảng finding — lần 1 (CR-01 … CR-12)

| ID | Tool | File:line | Loại | Tóm tắt finding | Quyết định | Lý do | Commit sửa |
|---|---|---|---|---|---|---|---|
| **CR-01** | Copilot Code Review | `lib/viewmodels/classes/matching_view_model.dart:40`<br>`lib/viewmodels/classes/import_class_view_model.dart:108`<br>`lib/viewmodels/proposals/proposal_view_model.dart:51` | Test gap / Architecture | 5 event Analytics (`logClassImport`, `logViewItem`, `logAiMatchStart`, `logAiMatchResult`, `logReportExport`) và `CrashService.recordNonFatal` được khai báo trong interface nhưng **không có call site nào**. Rubric chấm 0.5 điểm Analytics và 0.25 điểm Crashlytics. | **Accepted** | Vi phạm trực tiếp Lab 3 §6 ("Record the event plan below with parameters") và §10 ("every event visible in DebugView"). Tác động đo được: 0/10 event có dữ liệu trong DebugView. Đồng thời là "test gap": không test nào khẳng định event được ghi. | `1b6fea8` `fix(CR-01)` |
| **CR-02** | Copilot Code Review | `lib/screens/flow_b/proposals_screen.dart:16`<br>`lib/viewmodels/notifications/config_demo_view_model.dart:27` | Bug | `max_proposals_shown` chỉ được **in ra** ở khu demo; danh sách thẻ ở S9 không hề bị giới hạn. Rubric ghi rõ: "Values only printed, not used" → 0 điểm Remote Config. | **Accepted** | Vi phạm Lab 3 §6 (Remote Config). Tác động đo được: đổi giá trị trong Console không làm thay đổi app, tức yêu cầu "changes the app without a new build" không đạt. | `9cf68f5` `fix(CR-02)` |
| **CR-03** | Copilot Code Review | `lib/screens/flow_b/proposal_detail_screen.dart:20`<br>`lib/screens/flow_c/need_members_screen.dart:1`<br>`lib/widgets/proposal_student_picker.dart:40` | Architecture / Maintainability | Màn dùng `Chip` / `AlertDialog` / `Text` tự chế thay vì dùng thư viện component Lab 2 (`MajorSlotRow`, `FitChip`, `TagChip`, `showConfirmDialog`, `ErrorBanner`) — các widget này chỉ được import ở màn gallery. Thiếu cả trạng thái lỗi S25 ("Needs at least 5 members (now 4)") và S13 ("Max 6 members"). | **Accepted** | Vi phạm Lab 3 §10 ("one-off widgets instead of Lab 2 components" mất 0.5 điểm fidelity) và §10 states ("unrecorded deviations"). Tác động đo được: 5 widget dùng chung trong `lib/widgets/` bị bỏ hoang → 0/25 màn dùng đúng component. | `000f51b` `fix(CR-03)` |
| **CR-04** | Copilot Code Review | `lib/screens/profile/report_demo_panel.dart:120` | Bug | Khu demo Storage chỉ hiện phần trăm upload và dung lượng; **không hiện download URL** dù rubric yêu cầu "show progress and the download URL". | **Accepted** | Vi phạm trực tiếp Lab 3 §6 (Cloud Storage) và checklist bài nộp ("show the download URL"). Không có cách nào chứng minh file đã upload được từ app nếu không hiện URL. | `7c0fc66` `fix(CR-04)` |
| **CR-05** | Copilot Chat | `lib/services/report_service.dart:4` | Maintainability | `ReportService.buildClassTeamsPdf` trả về `List<int>`, nên ViewModel không biết file chứa bao nhiêu nhóm → event `report_export` buộc phải gửi `teamCount: 1` (giá trị bịa). | **Modified** | Chấp nhận vấn đề nhưng **sửa khác** gợi ý của AI: thay vì để ViewModel tự đếm nhóm qua Firestore (vi phạm luật layer — ViewModel không được đọc Firestore trực tiếp), ta đổi hợp đồng interface thành `BuiltReport(bytes, teamCount)` để `PdfReportService` trả kèm số nhóm đã in. Cách này giữ đúng luật §5 và cho ra con số thật. | `1b6fea8` `fix(CR-01)` |
| **CR-06** | Copilot Code Review | `lib/firebase/firebase_analytics_service.dart:10`<br>`lib/firebase/firebase_crash_service.dart:8` | Bug | Constructor gọi `FirebaseAnalytics.instance` / `FirebaseCrashlytics.instance` **ngay khi provider được đọc**. Nếu `Firebase.initializeApp()` chưa xong, `.instance` ném lỗi → provider vỡ trước cả khi user dùng tính năng. | **Accepted** | Vi phạm Lab 3 §6 ("Each service is graded on behaviour" — phải xử lý được trường hợp lỗi thay vì crash). Tác động đo được: app mở khi Firebase chưa sẵn sàng sẽ crash ở tầng provider. | `1b6fea8` `fix(CR-01)` |
| **CR-07** | Copilot Code Review | `lib/viewmodels/classes/matching_view_model.dart:57` | Test gap | Sau khi thêm `logAiMatchResult`, kết quả matching được ghi event **kể cả khi ViewModel đã bị dispose** (`_active(generation)` đã false) → event rác. | **Accepted** | Ràng buộc thực tế: Riverpod dispose là bình thường khi người dùng bấm Back giữa lúc AI đang chạy. Ghi event cho một màn đã đóng sẽ làm sai số liệu phễu (`ai_match_start` không có `ai_match_result` tương ứng). Đã sửa bằng cách chỉ ghi event khi `_active(generation)` còn đúng. | `1b6fea8` `fix(CR-01)` |
| **CR-08** | Copilot Code Review | `lib/services/fakes/fake_proposal_service.dart:70` | Test gap | Fake `watchAllPending()` không sort, còn Firestore implementation sort theo `teamName`. Khi thêm giới hạn `take(limit)` (CR-02), test và app **chọn khác nhóm** → test xanh nhưng app sai. | **Accepted** | Ràng buộc thực tế: fake phải mô phỏng đúng hành vi production, nếu không test không bảo chứng được điều gì. Đã sửa fake sort theo `teamName` cho khớp `FirestoreProposalService`. | `9cf68f5` `fix(CR-02)` |
| **CR-09** | Cursor Agent | `e2e_test/conftest.py:37`<br>`e2e_test/conftest.py:100` | Bug | Bộ test gọi `ArtemisClient(device_serial=…, profile=…, api_key=…, output_dir=…)` và `artemis.run(instruction)` — **không tồn tại trong SDK thật**. Client cài được là `artemis-client` (gói con trong monorepo ARTEMIS), nó **remote-only** (gọi HTTP tới daemon), `run()` là coroutine, và không có tham số `api_key`/`output_dir`. Ngoài ra `APP_PACKAGE` là `com.example.teamup_exe` trong khi `applicationId` thật là `com.group6.teamup_exe`. | **Accepted** | Vi phạm trực tiếp Lab 3 §7: bộ test phải **chạy được**. Hiện tại mọi test ném `TypeError`/`AttributeError` ngay khi gọi client — tức 18 ca ARTEMIS sẽ fail 100% khi giảng viên chạy, dù app đã đúng. Tác động đo được: `pytest` không tạo được bất kỳ ca nào. | `668ce5f` `11ccb53` |
| **CR-10** | Cursor Agent | `lib/widgets/proposal_student_picker.dart:96`<br>`lib/screens/flow_b/add_member_screen.dart:70` | Bug / Fidelity | S13 yêu cầu lỗi **"Max 6 members"** kèm **nút bị khóa**, nhưng nút lưu vẫn bấm được; dòng đếm hiện `"X of Y places selected"` thay vì meta line của Lab 2 `"FinLite, 6 of 6"`. | **Accepted** | Lab 3 §3: *"An unrecorded difference between Figma and the app is graded as a defect."*; Lab 2 handoff S13 ghi rõ *"Button primary (disabled)"* và *"Bỏ một lựa chọn thì lỗi biến mất và nút Add bật"*. Tác động đo được: giữa Flow B và Flow C (S11/S16 dùng chung widget) không có trạng thái nào cho mentor thấy nhóm đã đầy bằng cách khóa nút. Đã sửa và thêm 5 widget test cho S11/S13/S21. | `668ce5f` `11ccb53` |
| **CR-11** | Cursor Agent | `e2e_test/conftest.py:120` | Bug / Test gap | `artemis-client` **không trả báo cáo cho client**: `TaskResult.output` luôn `None`. ARTEMIS lưu final report vào **step cuối cùng** (`action_taken.action == "report_task_status"` → `args.explanation`), còn client chỉ nhận metadata session. Hệ quả: mọi test FAIL với `Observed(status='completed', text='')` dúl task đã **PASS** thật. | **Accepted** | Vi phạm Lab 3 §7: bộ test phải **chạy được** và **trị đúng được kiểm chứng**. Tác động đo được: 0/19 test có thể trừ xác nhắng agent. Đã sửa bằng cách đọc `GET /api/sessions/{id}/steps` để đọc `args.explanation`; TC-02 sau khi sửa: **1 passed in 110.82s**. | `11ccb53` |
| **CR-12** | Cursor Agent | `android/app/build.gradle.kts:1`<br>`docs/WORKLOG.md` §5b | Build / Tooling | App **crash ngay khi khởi động** với `RuntimeException: Unable to get provider net.nfet.flutter.printing.PrintFileProvider` — provider có trong merged manifest nhưng class không có trong dex. Nguyên nhân gốc: build bằng **JDK 26** làm AGP 9.1.0 fail ố bước `jlink` (`Could not resolve all files for configuration ':firebase_core:androidJdkImage'`), để lại build tổn còng. | **Accepted** | Lab 3 §11 đòi ngức repo “oốn trong một cḚ sḝ7 ừn danh” — một app crash khi mở ra là không thễ nổp. Tác động đo được: 0/1 ứở dùng được chạy. Đã sửa: dùng **JDK 24** + `flutter clean`; đã xác nhận app khởi động bình thường (`topResumedActivity=MainActivity`). | `11ccb53` |

**Tổng lần 1: 12 finding** — vượt mức tối thiểu 5; bao phủ **nhiều loại**: bug (CR-02, CR-04,
CR-06, CR-09, CR-10, CR-11, CR-12), architecture (CR-03), test gap (CR-01, CR-07, CR-08), maintainability (CR-05), tooling (CR-12).

---

## 3. Bảng finding — lần 2 (F1 … F10)

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

**Tổng lần 2: 10 finding**, thuộc các loại bug, performance, maintainability. Chưa có finding loại security hay test gap từ lần chạy này.

### Các commit sửa lỗi của lần 2

| Finding | Commit | Kiểm chứng |
|---|---|---|
| F1 | `110e795` fix(auth): keep the session on transient profile errors, sign out non-mentors [F1] | 2 test mới (giữ phiên khi lỗi mạng/timeout; đăng xuất khi không phải mentor) |
| F2 | `a1e8b43` fix(fcm): retry the token write until the mentor profile exists [F2] (+ `182b59a`) | 2 test mới (thử lại thành công; bỏ cuộc và báo lỗi) |
| F9 | `55908aa` fix(auth): stop the phone resend countdown after sign-in [F9] | test mới thất bại trước fix, pass sau fix |
| F8 | `77d01d1` fix(proposals): skip one malformed proposal instead of failing the list [F8] | test mới thất bại trước fix, pass sau fix |
| F5 | `45a3229` fix(storage): delete the uploaded PDF when getDownloadURL fails [F5] | chỉ `flutter analyze`, không có test |
| F3 (hồi quy) | `aac27ba` test(rules): regression tests for importing 12 and 42 student classes | 30/30 test rules pass |

Liên kết đầy đủ khi đã push: `https://github.com/no-solace/prm-teamup-mobile/commit/<hash>`.

---

**Tổng cả hai lần: 22 finding** — vượt mức tối thiểu 5; bao phủ **nhiều loại**: bug, security, architecture, performance, test gap, maintainability, tooling.

---

## 4. Quyết định chi tiết

### CR-01 — Analytics & Crashlytics chưa có call site — **Accepted**
### CR-02 — Remote Config chỉ in ra, không dùng — **Accepted**
### CR-03 — Màn tự chế widget thay vì dùng component Lab 2 — **Accepted**
### CR-04 — Thiếu download URL ở khu demo Storage — **Accepted**
### CR-05 — `teamCount` bịa trong event `report_export` — **Modified**
### CR-06 — `.instance` của Firebase SDK gọi trong constructor — **Accepted**
### CR-07 — Event ghi cả khi ViewModel đã dispose — **Accepted**
### CR-08 — Fake service không sort như production — **Accepted**
### CR-09 — Bộ test gọi API SDK không tồn tại — **Accepted**
### CR-10 — S13 thiếu khóa nút và sai meta line — **Accepted**
### CR-11 — `TaskResult.output` luôn `None` — **Accepted**
### CR-12 — Build bằng JDK 26 làm app crash khi mở — **Accepted**

Phần diễn giải đầy đủ cho từng finding nằm ở các mục chi tiết bên dưới.

---

## 5. Việc còn lại

- [ ] Mở PR và chạy thêm một công cụ review gắn vào PR; lưu đầu ra. *(Đã có ở lần 1.)*
- [ ] Thử F1 và F2 trên máy thật (đăng nhập lần đầu, rồi tắt mạng và mở lại app).
- [ ] Hai finding loại security và test gap: lần review sau nên yêu cầu công cụ tập trung vào Rules và độ phủ test.
- [ ] Chụp DebugView cho từng event Analytics (xem `docs/analytics-plan.md` §6).

---

## 6. Công cụ AI đã dùng trong Lab 3

| Công cụ | Dùng để |
|---|---|
| Codex (OpenAI) | Viết phần lớn mã app: dịch vụ matching, đối chiếu bản nháp (`matching_drafts.dart`), Firestore rules và test rules, tích hợp Firebase |
| Claude Code (Claude Sonnet 5.5) | Nối sự kiện Analytics và Crashlytics non-fatal, viết test cho chúng, bộ ARTEMIS (`e2e_test/`), các tài liệu trong `docs/`, chạy review ở mục 1 và sửa F1, F2, F5, F8, F9 |
| Cursor Agent (Claude Opus 4.5) | Rà soát toàn bộ codebase theo checklist Lab 3 §5–§10, sửa CR-01 … CR-12, sinh báo cáo và slide |
| GitHub Copilot Chat | Gợi ý bảo trì trong `lib/viewmodels/` |
| GitHub Copilot Code Review | Rà soát pull request `feature/lab3-complete-gaps` |
| Google ARTEMIS | Công cụ kiểm thử E2E theo yêu cầu của đề (xem `docs/test-plan.md`) |

*Bổ sung ở đây mọi công cụ AI khác nhóm đã dùng cho Lab 3 (làm slide, báo cáo, thiết kế). Đề coi việc không khai báo là vi phạm.*
