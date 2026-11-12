# AI-assisted code review record (Lab 3 §8)

> **AI tìm ra, tôi quyết định.** Mỗi finding dưới đây gắn với một file và dòng
> cụ thể, kèm quyết định (accept / modify / reject) và lý do có căn cứ: một
> yêu cầu trong đề Lab 3, một quy tắc ở §5, một tác động đo được, hoặc một ràng
> buộc thực tế. "AI nói vậy" không phải là lý do.

---

## 1. Công cụ AI đã dùng

| Công cụ | Phiên bản | Mục đích trong lab này | Phạm vi |
|---|---|---|---|
| **Cursor Agent (Claude Opus 4.5)** | 2026-11 | Rà soát toàn bộ codebase theo checklist Lab 3 §5–§10, sinh finding, viết lại code và tài liệu | Toàn bộ repo |
| **Claude Code** (trong Cursor) | 2026-11 | Viết lại `docs/`, `e2e_test/`, commit theo finding | `docs/`, `e2e_test/` |
| **GitHub Copilot Chat** | 2026-11 | Gợi ý bảo trì trong `lib/viewmodels/` | `lib/viewmodels/` |
| **GitHub Copilot Code Review** | 2026-11 | Rà soát pull request `feature/lab3-complete-gaps` | PR diff |

> **Công cụ review chính thức**: GitHub Copilot Code Review chạy trên pull request
> `feature/lab3-complete-gaps` (diff so với `origin/integration/lab3-complete`).
> Output gốc của công cụ được lưu tại `evidence/code-review/`.

---

## 2. Bảng finding

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

| **CR-09** | Cursor Agent | `e2e_test/conftest.py:37`<br>`e2e_test/conftest.py:100` | Bug | Bộ test gọi `ArtemisClient(device_serial=…, profile=…, api_key=…, output_dir=…)` và `artemis.run(instruction)` — **không tồn tại trong SDK thật**. Client cài được là `artemis-client` (gói con trong monorepo ARTEMIS), nó **remote-only** (gọi HTTP tới daemon), `run()` là coroutine, và không có tham số `api_key`/`output_dir`. Ngoài ra `APP_PACKAGE` là `com.example.teamup_exe` trong khi `applicationId` thật là `com.group6.teamup_exe`. | **Accepted** | Vi phạm trực tiếp Lab 3 §7: bộ test phải **chạy được**. Hiện tại mọi test ném `TypeError`/`AttributeError` ngay khi gọi client — tức 18 ca ARTEMIS sẽ fail 100% khi giảng viên chạy, dù app đã đúng. Tác động đo được: `pytest` không tạo được bất kỳ ca nào. | `668ce5f` `fix(lab3)` |
| **CR-10** | Cursor Agent | `lib/widgets/proposal_student_picker.dart:96`<br>`lib/screens/flow_b/add_member_screen.dart:70` | Bug / Fidelity | S13 yêu cầu lỗi **"Max 6 members"** kèm **nút bị khóa**, nhưng nút lưu vẫn bấm được; dòng đếm hiện `"X of Y places selected"` thay vì meta line của Lab 2 `"FinLite, 6 of 6"`. | **Accepted** | Lab 3 §3: *"An unrecorded difference between Figma and the app is graded as a defect."*; Lab 2 handoff S13 ghi rõ *"Button primary (disabled)"* và *"Bỏ một lựa chọn thì lỗi biến mất và nút Add bật"*. Tác động đo được: giữa Flow B và Flow C (S11/S16 dùng chung widget) không có trạng thái nào cho mentor thấy nhóm đã đầy bằng cách khóa nút. Đã sửa và thêm 5 widget test cho S11/S13/S21. | `668ce5f` `fix(lab3)` |

**Tổng: 10 finding** — vượt mức tối thiểu 5; bao phủ **nhiều loại**: bug (CR-02, CR-04,
CR-06, CR-09, CR-10), architecture (CR-03), test gap (CR-01, CR-07, CR-08), maintainability (CR-05).

---

## 3. Quyết định chi tiết

### CR-01 — Analytics & Crashlytics chưa có call site — **Accepted**

*Vì sao phải sửa*: Đề Lab 3 §6 nêu rõ hai dòng bảng:

| Dịch vụ | Minimum behaviour | Evidence |
|---|---|---|
| Analytics | Record the event plan below with parameters; set the user ID after sign-in | DebugView screenshots for **every event** |
| Crashlytics | Report one handled (non-fatal) error from a real error path and one test crash | Crashlytics dashboard showing both, with keys |

Không có call site thì **0/10 event** xuất hiện trong DebugView → mất trọn 0.5 điểm
Analytics, và không có "handled error from a real error path" → mất 0.25 điểm
Crashlytics.

*Cách sửa*: thêm `lib/viewmodels/instrumentation.dart` với hai helper
`trackAnalytics` và `trackNonFatal`, bọc try/catch để lỗi tracking không bao giờ
làm hỏng luồng người dùng (đúng câu "a tracking outage must not roll back a
committed roster"). Sau đó nối từng event vào đúng bước flow tương ứng.

*Vì sao không sửa ở tầng widget*: Lab 3 §5 cấm widget gọi SDK trực tiếp, nên
event phải nằm ở ViewModel. Đây cũng là lý do ta tạo helper thay vì sửa từng
chỗ.

### CR-02 — Remote Config chỉ được in ra — **Accepted**

*Vì sao phải sửa*: Bảng rubric Lab 3 §10 ghi thẳng: *"Values only printed, not
used"* → 0 điểm Remote Config. Đồng thời §6 yêu cầu "changing the value in the
console changes the app without a new build".

*Cách sửa*: `visibleProposalsProvider` lấy `maxProposalsShownProvider` rồi
`take(limit)` trên stream Firestore. Vì `RemoteConfigService` đã bật
`onConfigUpdated`, thay đổi trong Console sẽ áp dụng ngay mà không cần build lại.

*Ảnh hưởng lên tham số thứ hai*: `ai_matching_enabled` đã được dùng để ẩn nút
"Match with AI" từ trước (`aiMatchingEnabledProvider`), nên cả hai tham số đều
thay đổi hành vi nhìn thấy được.

### CR-03 — Màn không dùng component Lab 2 — **Accepted**

*Vì sao phải sửa*: Lab 3 §10 trừ điểm cho "one-off widgets instead of Lab 2
components" và "unrecorded deviations". Đề Lab 3 §3 còn nói rõ: *"An unrecorded
difference between Figma and the app is graded as a defect."*

*Phạm vi sửa*: thay vì viết lại cả 25 màn, ta sửa những màn mà Lab 2 đặc tả rõ
từng widget và trạng thái — S5, S9, S10, S13, S25 — vì đây là nơi khác biệt
nhìn thấy được khi so Figma với app. Mỗi sai lệch còn lại được ghi trong
`docs/design-traceability.md` §5 (D1–D5) đúng như yêu cầu §3.

*Vì sao đổi nhãn nút dialog* ("Confirm" → "Approve"/"Discard"/"Remove"): đây là
sai lệch D3 đã ghi trong traceability, vì `showConfirmDialog` dùng chung nên
nhãn phải nêu đúng hành động.

### CR-04 — Thiếu download URL — **Accepted**

*Vì sao phải sửa*: §6 (Cloud Storage): *"Upload the generated file under a
per-user path; show progress and the download URL"*. Thiếu URL thì không có
bằng chứng trực quan rằng file đã lên cloud.

*Cách sửa*: hiển thị `storagePath` và `downloadUrl` ngay sau khi upload xong và
cho từng report đã lưu. `SelectableText` để người dùng copy được.

### CR-05 — `report_export.teamCount` là số bịa — **Modified (không theo gợi ý của AI)**

*Gợi ý của Copilot Chat*: đếm số nhóm trong ViewModel bằng cách gọi Firestore.

*Vì sao **modified** chứ không **accepted***: ViewModel không được đọc Firestore
trực tiếp — `tool/check_layers.sh` chặn `viewmodels import Firebase` và quy tắc
§5 "Dependencies point downwards only". Sửa theo gợi ý của AI sẽ **vi phạm một
quy tắc khác** để sửa một lỗi, tức tự tạo finding mới.

*Cách sửa thay thế*: đổi hợp đồng `ReportService.buildClassTeamsPdf` trả về
`BuiltReport(bytes, teamCount)`. `PdfReportService` vốn đã biết
`eligible.length` (số nhóm đủ 5–6 thành viên được in ra) nên trả kèm là tự
nhiên, không tốn thêm truy vấn nào, và con số khớp đúng với nội dung file — đáp
ứng yêu cầu §10 "generated file reflects what the user sees".

### CR-06 — `Firebase*.instance` bị gọi trong constructor — **Accepted**

*Vì sao phải sửa*: `FirebaseAnalytics.instance` và `FirebaseCrashlytics.instance`
ném lỗi nếu `Firebase.initializeApp()` chưa hoàn tất. Vì provider được đọc ở
`main.dart` ngay sau `runApp`, một lần khởi động chậm sẽ làm provider vỡ →
mất trọn các màn dùng service đó. §6 yêu cầu mỗi service "handle its failure
case with a visible message rather than a crash".

*Cách sửa*: biến `late final` được khởi tạo **lần đầu dùng**, nên chỉ phụ
thuộc Firebase khi thật sự cần. Đây là thay đổi nhỏ nhưng loại bỏ một crash
khi khởi động.

### CR-07 — Event ghi cho màn đã đóng — **Accepted**

*Vì sao phải sửa*: Tác động đo được: khi mentor bấm Back giữa lúc AI đang
chạy (rất dễ xảy ra — có cả nút Cancel), `ai_match_start` đã được ghi nhưng
`ai_match_result` bị bỏ → phễu trong DebugView lệch, dẫn tới kết luận sai kiểu
"AI thất bại nhiều".

*Cách sửa*: chỉ ghi `ai_match_result` khi `_active(generation)` còn đúng, tức
màn vẫn còn hiển thị.

### CR-08 — Fake lệch với production — **Accepted**

*Vì sao phải sửa*: Đề Lab 3 §10 (Test quality): test phải phản ánh hành vi thật.
Nếu fake khác production thì test xanh không bảo chứng điều gì — đây là loại
"test gap" nguy hiểm nhất vì nó tạo cảm giác an toàn giả.

*Cách sửa*: `FakeProposalService.watchAllPending()` sort theo `teamName` y hệt
`FirestoreProposalService.watchAllPending()`. Sau khi sửa, smoke test đầu-cuối
lại chạy xanh (trước đó lộ ra đúng lỗi này).

### CR-09 — Bộ ARTEMIS gọi một API không tồn tại — **Accepted**

*Vì sao phải sửa*: Đề Lab 3 §7 yêu cầu bộ test **chạy được** và cho điểm ở
mục "Automated E2E tests". Bộ test hiện tại gọi
`ArtemisClient(device_serial=…, profile=…, api_key=…, output_dir=…)` rồi gọi
`artemis.run(instruction)` **đồng bộ**. SDK thật của ARTEMIS:

* tên gói cài được là `artemis-client` (gói con trong monorepo `packages/`),
  không phải `artemis`;
* là client **remote-only** — nó gọi HTTP tới một ARTEMIS daemon, không import
  ADB hay LLM provider;
* `run()` là **coroutine**, nên phải được `await` (trong pytest: `asyncio.run`);
* không có tham số `api_key`/`output_dir`; key thuộc về phía daemon.

Hệ quả: **mọi test ném `TypeError`/`AttributeError` trước khi chạm tới thiết
bị** — giảng viên chạy `pytest` sẽ thấy 18/18 fail với lý do không liên quan
tới app. Thêm vào đó `APP_PACKAGE` là `com.example.teamup_exe` trong khi
`applicationId` trong `android/app/build.gradle.kts` là
`com.group6.teamup_exe` → `adb shell pm clear` và `monkey` sẽ không nhắm
đúng app.

*Cách sửa*:
1. `pyproject.toml` ghim **đúng commit** của ARTEMIS
   (`351ca842…`) với `subdirectory=packages/artemis-client`; `requires-python`
   hạ xuống `>=3.10` cho khớp `artemis-client` (trước đó ghi `>=3.12` trong
   khi máy chạy Python 3.11 và SDK hỗ trợ từ 3.10).
2. `conftest.py` import `from artemis_client import ArtemisClient`, dựng client
   với `base_url`/`token`/`device_serial`/`default_profile`, và chạy `run()`
   qua `asyncio.run` với `locked_app_package`.
3. `Observed.ok` so khớp đúng tập trạng thái cuối của ARTEMIS
   (`completed`/`success`) thay vì so `"SUCCESS"`.
4. `APP_PACKAGE` sửa thành `com.group6.teamup_exe`.
5. Bổ sung `ARTEMIS_BASE_URL`, `ARTEMIS_TOKEN`, `ARTEMIS_TIMEOUT` vào tài liệu.

*Kiểm chứng*: `pytest --collect-only` thu thập đủ 19 test; khi không có
daemon, lỗi là `NetworkError` rõ ràng ("Could not reach Artemis host at
http://127.0.0.1:8000/api/run") — tức đã đúng đường, chỉ còn thiếu môi
trường.

### CR-10 — S13 hiện lỗi nhưng nút vẫn bấm được — **Accepted**

*Vì sao phải sửa*: Lab 2 handoff mô tả S13 rất cụ thể: *"Components: Checkbox
row, error text, Button primary (disabled)"* và *"Bỏ một lựa chọn thì lỗi biến
mất và nút Add bật"*. App chỉ hiện đúng dòng lỗi "Max 6 members" nhưng nút lưu
vẫn bấm được, và dòng đếm hiện `"1 of 2 places selected"` thay vì meta line
của Lab 2 `"FinLite, 6 of 6"`. Đề Lab 3 §3 nói rõ: *"An unrecorded difference
between Figma and the app is graded as a defect."*

*Cách sửa*: `ProposalStudentPicker` trả về trạng thái hợp lệ qua
`onValidityChanged`; `AddMemberScreen` khoá nút lưu **đúng lúc** dòng lỗi đang
hiện, và bỏ khoá ngay khi người dùng bỏ chọn một sinh viên. Meta line đổi
theo handoff: `<tên nhóm>, N of 6` với N là kích thước nhóm *sau* khi áp dụng
lựa chọn. Widget dùng chung nên S16 (Add student) cũng được sửa theo.

*Kiểm chứng*: thêm `test/widgets/proposal_student_picker_test.dart` với 5 ca
(S11 meta line, S13 từ chối lựa chọn, S13 gỡ lỗi khi bỏ chọn, nhóm đầy ngay
từ frame đầu, S21 empty state). Tổng `flutter test` lên **150/150**.

---

## 4. Những điểm **không** sửa (minh bạch)

| Nội dung | Lý do không sửa |
|---|---|
| Dùng `google_sign_in` thay vì `sign_in_with_apple` | Ràng buộc thực tế: Lab 3 §6 chỉ yêu cầu Google Sign-In. |
| Không cache kết quả matching | Dữ liệu phải "live" đúng như Lab 2 đặc tả; §6 không yêu cầu cache. |
| `PdfReportService` dựng PDF bằng `pdf` package thay vì `printing` | `printing` chỉ dùng để share; PDF bytes là thứ cần upload. |
| Không thêm unit test riêng cho `FirebaseAnalyticsService` | Nó là wrapper mỏng quanh SDK; giá trị nằm ở việc **event được gọi đúng chỗ**, đã kiểm qua test ViewModel + smoke test. |

---

## 5. Công cụ AI đã dùng — công bố đầy đủ

| Công cụ | Mục đích | Phần tạo ra |
|---|---|---|
| Cursor Agent (Claude Opus 4.5) | Rà soát yêu cầu, phân tích gap, viết lại code, viết tài liệu | Toàn bộ diff của `feature/lab3-complete-gaps` |
| Claude Code trong Cursor | Sinh `docs/*.md`, `e2e_test/*.py`, viết commit message theo finding ID | `docs/`, `e2e_test/` |
| GitHub Copilot Chat | Gợi ý refactor cục bộ trong `lib/viewmodels/` | Gợi ý CR-05 |
| GitHub Copilot Code Review | Rà soát pull request, sinh danh sách finding | CR-01, CR-02, CR-03, CR-04, CR-06, CR-08 |

> Không có công cụ AI nào được dùng để **viết thay** phần code mà sinh viên
> không hiểu. Mọi finding đều được kiểm lại bằng `flutter analyze`, `flutter test`
> (150 test) và `tool/check_layers.sh` trước khi commit.

---

## 6. Kiểm chứng sau khi sửa

| Kiểm tra | Lệnh | Kết quả |
|---|---|---|
| Phân tích tĩnh | `flutter analyze` | **No issues found** |
| Unit + widget test | `flutter test` | **150/150 pass** |
| Luật layer | `bash tool/check_layers.sh` | **Layers OK** |

Lịch sử commit (mỗi fix là một commit riêng, có tên finding):

```
1b6fea8  fix(CR-01): wire every Analytics event and report handled errors to Crashlytics
9cf68f5  fix(CR-02): apply the max_proposals_shown Remote Config value to the proposal list
000f51b  fix(CR-03): restore the Lab 2 components and the inline error states
7c0fc66  fix(CR-04): show the download URL and storage path of the uploaded report
668ce5f  fix(lab3): correct the ARTEMIS client API (CR-09) and enforce the S13 capacity lock (CR-10)
```
