# Test plan

Hai lớp kiểm thử:

| Lớp | Công cụ | Số lượng | Chạy ở đâu |
|---|---|---|---|
| Unit, ViewModel, widget | `flutter test` | 170 test (pass hết ngày 12/11/2026) | CI và máy dev, không cần thiết bị |
| Rules Firestore | `@firebase/rules-unit-testing` trên emulator | 25 test | `firebase/test` |
| **E2E trên thiết bị** | **Google ARTEMIS** + pytest | **14 ca** (13 chạy tự động, 1 cần người gửi push) | thiết bị/emulator Android |

> **Trạng thái 13/11/2026: bộ ARTEMIS đã chạy trên emulator Pixel 7 (Android, Google Play): lượt 1 đủ 13 ca, lượt 2 được 11 ca, lượt 3 chưa chạy vì hết hạn mức Gemini API.** Kết quả và lý do ở mục 5.
> Mục 6 (exploratory) vẫn chưa làm.

## 1. Luồng quan trọng → màn hình

| Luồng | Màn |
|---|---|
| Đăng nhập, đăng xuất | S1, S19, S6 |
| Flow A: nhập lớp rồi ghép AI và duyệt | S2, S22, S23, S3, S8, S9, S10, S12, S14 |
| Flow B: sửa thành viên đề xuất (đường lỗi: dưới 5 người) | S10, S24, S25 (S11, S13) |
| Flow C: hủy đề xuất, ghép tay (đường lỗi: không tìm thấy) | S17, S5, S16, S21 |
| Màn chi tiết | S3 (lớp), S7 (sinh viên), S10 (đề xuất) |
| Điều hướng các tab (mentor 5, sinh viên 4) | S2, S9, Topics, Schedule, S6 |
| Xuất PDF và lưu (Firestore) | S6 (vùng Firebase demo) |
| Mở rộng D/E/F (chưa có ca ARTEMIS; đã có widget test `test/flow_def/` và test rules) | Onboarding, Topics, Schedule, biên bản |
| Remote Config đổi hành vi | S3 (nút Match with AI), S6, S9 |
| Mất mạng | S18 |
| Thông báo đẩy | trung tâm thông báo, deep link |

## 2. Ca kiểm thử (ARTEMIS)

Mỗi ca là một hàm pytest trong `e2e_test/`, gửi **một** chỉ dẫn qua `ArtemisClient.run`. Chỉ dẫn nêu điểm xuất phát, các bước và **các giá trị phải báo lại** dưới dạng một dòng JSON; test so sánh giá trị đó với kỳ vọng, không chỉ tin `status == SUCCESS` (xem `conftest.py`).

**Tiền điều kiện chung:** thiết bị Android 13+ đã thêm tài khoản Google **test riêng**; app bản Firebase thật đã cài (`flutter run`); `tool/fixtures/lab3-demo.csv` được push vào `/sdcard/Download` (fixture `fixture_on_device` làm việc này). Các ca cần dữ liệu **tự nhập lớp `EXE101 Demo` lúc đầu ca** (mỗi lần nhập tạo một lớp mới với ID mới), nên không ca nào phụ thuộc thứ tự chạy hay dữ liệu ca khác để lại.

| ID | Tên | Flow / mục đề | Tiền điều kiện | Kết quả mong đợi (giá trị agent báo, test so sánh) | Đánh dấu | Đã chạy |
|---|---|---|---|---|---|---|
| TC01 | Đăng nhập Google bằng account picker | Đăng nhập | Đã đăng xuất, tài khoản mentor | `signed_in = true`; tab = Classes, Proposals, Topics, Schedule, Profile; logcat có `login` | native, analytics | 2/2 pass |
| TC02 | Đăng xuất | Sign-out | Đã đăng nhập | Hiện nút Continue with Google; không còn thanh tab; mở lại app vẫn ở màn đăng nhập | | 2/2 pass |
| TC03 | Email sai | Flow A, S19 (lỗi) | Đã đăng xuất | `error_text = "Enter a valid email"`; không vào My classes | error_path | 2/2 pass |
| TC04 | Nhập CSV | Flow A, S22, S23 | Đã đăng nhập | Nút `Import 12 students`; kết quả 12 / 9 / 3; logcat có `class_import` | analytics | 2/2 pass |
| TC05 | Ghép AI rồi duyệt | Flow A, hành động chính | Đã đăng nhập | Có thẻ Group 2; sau khi thêm có 6 thành viên; snackbar `Team approved`; số thẻ Group 2 giảm 1; logcat có `ai_match_start`, `ai_match_result`, `proposal_approve` | analytics | 2/2 pass |
| TC06 | Bỏ thành viên, nhóm dưới 5 | Flow B, S24, S25 (lỗi) | Đã đăng nhập | Banner `Needs at least 5 members (now 4)`; Approve bị khóa; ca tự Discard để dọn | error_path | 0/2 (fail, xem mục 5) |
| TC07 | Hủy đề xuất rồi ghép tay, tìm không ra | Flow C, S17, S21 (lỗi) | Đã đăng nhập | Số thẻ Group 2 giảm 1; tiêu đề rỗng `No student results` | error_path | 2/2 pass |
| TC08 | Chi tiết lớp và sinh viên | màn chi tiết | Đã đăng nhập | 3 SV chưa có nhóm, 1 nhóm thiếu người; ID `AI000012`, `GD000011`, `MK000010`; SV Dương Yến có ngành AI | | 2/2 pass |
| TC09 | 3 tab và Back | điều hướng | Đã đăng nhập | Tiêu đề Proposals, Profile đúng; Back về đúng My classes | | 1/2 (harness, xem mục 5) |
| TC10 | Remote Config đổi hành vi | Remote Config | Đã đăng nhập | `ai_matching_enabled` và `max_proposals_shown` khớp giá trị console; nút Match with AI hiện/ẩn theo cờ | | 2/2 pass |
| TC11 | Xuất PDF và lưu | export/upload | Đã đăng nhập | Thấy tiến độ `% uploaded`; thông báo bắt đầu bằng `Uploaded`; danh sách Saved reports có mục; logcat có `report_export`. Gói Spark: PDF lưu trong Firestore (`reports/{id}/files/pdf`) | analytics | 2/2 pass |
| TC12 | Hộp thoại quyền thông báo | native | Đã thu hồi `POST_NOTIFICATIONS` | Hộp thoại hệ thống xuất hiện; sau khi Allow app hiện trạng thái đã cho phép | native | 1/1 pass |
| TC13 | Mất mạng khi ghép | Flow A, S18 (lỗi) | Đã đăng nhập, có mạng lúc nhập | Hiện lỗi và nút `Try again`; tắt Airplane rồi thử lại thì phục hồi | error_path | 1/1 pass |
| TC14 | Chạm thông báo đẩy từ notification shade | native, FCM | Cần người gửi tin từ console, `TEAMUP_PUSH_READY=1` | Mở màn Proposals; thông báo có trong danh sách | native | Mặc định bỏ qua |

### Đối chiếu yêu cầu của đề (mục 7)

| Yêu cầu | Ca |
|---|---|
| Mỗi flow Lab 2 từ đầu đến cuối, gồm đường phụ và đường lỗi | A: TC04, TC05, TC03, TC13. B: TC06. C: TC07 |
| Đăng nhập | TC01 |
| Hành động chính | TC05 |
| Mỗi tab cấp cao | TC09 |
| Mỗi loại màn chi tiết | TC08 (lớp, sinh viên), TC05/TC06 (đề xuất) |
| Export và upload | TC11 |
| Remote Config hiện trên màn | TC10 |
| Đăng xuất | TC02 |
| ≥ 1 đường lỗi | TC03, TC06, TC07, TC13 |
| ≥ 1 tương tác native | TC01 (account picker), TC12 (quyền), TC14 (notification shade) |
| ≥ 1 ca kiểm tra sự kiện Analytics | TC01, TC04, TC05, TC11 (qua logcat) |
| Phiên exploratory (Pro, 15–30 phút) | Mục 6, **chưa làm** |

**Khoảng trống đã biết:** chưa có ca cho S11/S13 (thêm thành viên, lỗi vượt 6 người) và S15 (AI không tìm được nhóm); hai màn này mới được phủ bằng widget/ViewModel test.

## 3. Luật chạy

- Mỗi ca chạy **≥ 3 lần**. Ca không đạt 3/3 là flaky: xác định nguyên nhân (app, thời gian hay chỉ dẫn mơ hồ) và ghi cách sửa ở mục 5.
- Hồ sơ **Flash** cho hồi quy; **Pro** chỉ cho phiên exploratory.
- Ca độc lập thứ tự: ca nào cần dữ liệu thì tự nhập lớp; các ca sửa dữ liệu (TC05, TC06, TC07) tự dọn, nên không để lại đề xuất `pending`.
- Khóa API của mô hình nằm ở `.env` của máy chủ ARTEMIS; tài khoản Google test lấy từ thiết bị, **không** có trong repo.
- Thêm `Semantics` cho nút và hàng danh sách để ARTEMIS đọc cây trợ năng nhanh hơn (hiện `AppButton` có tham số `semanticsLabel`).

## 4. Cách chạy

```bash
# 1) ARTEMIS host (repo google/artemis, commit đã ghim trong e2e_test/pyproject.toml)
git clone https://github.com/google/artemis.git && cd artemis && ./start.sh   # Windows: .\start.bat
# 2) Cài app lên thiết bị
flutter run --release            # hoặc: flutter install
# 3) Chạy bộ test 3 lần và in bảng kết quả
cd e2e_test && export ARTEMIS_DEVICE=<adb serial> && bash run_suite.sh
# Remote Config before/after (TC10): đổi giá trị ở console rồi chạy lại với kỳ vọng mới
EXPECT_RC_AI_ENABLED=false EXPECT_RC_MAX_PROPOSALS=1 uv run pytest test_profile.py -k tc10
```

ARTEMIS commit đã ghim: `351ca8422f7b5b54e80a9c1ce03a222e02415b6b` (đã dùng để cài `artemis-client` và thu thập ca ngày 12/11/2026).
Lệnh chạy, trace ID và ảnh chụp của từng lần chạy lưu ở `evidence/artemis/`.

## 5. Kết quả chạy

Chạy ngày 13/11/2026 trên emulator Pixel 7 (`emulator-5554`), bản debug, Firebase thật (`prm-lab3-cc39e`), hồ sơ ARTEMIS **flash**. Bằng chứng: `evidence/artemis/2026-11-13/` (`runs.jsonl` có trace ID và giá trị agent báo của từng lần, `run1.xml`, `runs_suite.log`).

| Test | Runs | Passed | Pass rate | Avg time (s) | Verdict |
|---|---|---|---|---|---|
| TC01 Đăng nhập Google (account picker) | 2 | 2 | 100% | 66 | OK |
| TC02 Đăng xuất | 2 | 2 | 100% | 68 | OK |
| TC03 Email sai | 2 | 2 | 100% | 85 | OK |
| TC04 Nhập CSV | 2 | 2 | 100% | 72 | OK |
| TC05 Ghép AI rồi duyệt | 2 | 2 | 100% | 155 | OK |
| TC06 Bỏ thành viên, nhóm dưới 5 | 2 | 0 | 0% | 193 | **FAILED** (app lệch spec) |
| TC07 Hủy đề xuất, ghép tay | 2 | 2 | 100% | 149 | OK |
| TC08 Chi tiết lớp và sinh viên | 2 | 2 | 100% | 143 | OK |
| TC09 Tab và Back | 2 | 1 | 50% | 55 | FLAKY (lỗi harness, đã sửa) |
| TC10 Remote Config | 2 | 2 | 100% | 112 | OK |
| TC11 Xuất PDF và lưu | 2 | 2 | 100% | 140 | OK |
| TC12 Hộp thoại quyền thông báo | 1 | 1 | 100% | 117 | OK (thiếu 2 lần chạy) |
| TC13 Mất mạng khi ghép | 1 | 1 | 100% | 124 | OK (thiếu 2 lần chạy) |
| TC14 Chạm thông báo đẩy | 0 | 0 | n/a | n/a | SKIPPED |

**Chưa đạt luật ≥ 3 lần chạy (mục 3).** Lượt 2 dừng ở TC12 vì key Gemini hết credit trả trước (`402 Payment Required`). Thử key miễn phí thì bị chặn ở 20 request/ngày/model (`429`, quota `GenerateRequestsPerDayPerProjectPerModel-FreeTier`), mà mỗi ca cần khoảng 13–26 lần gọi. Còn thiếu: TC12 và TC13 của lượt 2, cả lượt 3. Chạy bù: `bash run_suite.sh` khi có key còn hạn mức.

Giải thích từng ca fail/flaky/bỏ qua:

- **TC06 – fail thật, cả 2 lần, cùng giá trị.** Logic đúng: bỏ 2 thành viên thì nút Approve bị khóa (`approve_enabled = false`). Nhưng màn S25 hiện dòng chữ tĩnh `Approval needs at least 5 and at most 6 members.` (`lib/screens/flow_b/proposal_detail_screen.dart:178`), không phải `ErrorBanner` `Needs at least 5 members (now 4)` như spec S25. Câu đúng spec chỉ có trong `FakeProposalService.approve`, nên widget test bản fake không bắt được lỗi này. **Cách sửa:** đổi dòng chữ tĩnh thành `ErrorBanner` dùng `proposal.resultingSize`.
- **TC09 – flaky do harness, không phải app.** Lần 2 agent báo đúng (`back_title = "My classes"`, trace `5d42bec7…`). Nhưng host ARTEMIS ở commit đã ghim để trống `output` và đánh dấu session xong *trước* khi ghi bước cuối, nên `conftest.py` đọc kết quả quá sớm và nhận `null`. Đã sửa: `final_report()` đọc lại `report_task_status` từ `/api/sessions/{id}/steps` và thử lại tối đa khoảng 15 giây. Đọc lại trace đó bằng bản sửa thì ra đúng 4 giá trị.
- **TC12, TC13 – mới chạy 1 lần** vì hết hạn mức API (xem trên). Lần chạy đó pass.
- **TC14 – bỏ qua có chủ đích** (`TEAMUP_PUSH_READY` không bật), cần người gửi push từ console.

Ghi chú môi trường (để chạy lại cho giống):

- Host ARTEMIS cài bằng `uv sync --python 3.13` (Python 3.15 không có wheel `grpcio`). Không dùng `start.bat`, chạy `uv run python -m artemis ui --port 8000 --no-open`.
- `config/artemis.jsonc` của host sửa ở máy chạy: model mặc định `gemini-3.6-flash` (dự phòng `3.5-flash`), vì key dùng lúc đó gọi `3.8-flash`/`3.7-flash` bị treo. Lượt 1 và 2 chạy với `step_summarizer` **bật**. Bộ này đã được tắt sau đó để giảm khoảng một nửa số lần gọi, nhưng chưa đo được vì hết hạn mức.
- TC01 sửa chỉ dẫn: tự đăng xuất trước nếu đang đăng nhập, để không phụ thuộc thứ tự chạy.
- Đăng nhập Google trên máy chạy cần SHA-1 debug key của máy đó trong Firebase (`google-services.json` hiện có 2 SHA-1). Thiếu thì báo `UNREGISTERED_ON_API_CONSOLE`.

## 6. Phiên exploratory (Pro, 15–30 phút)

*Chưa thực hiện.* Chạy:

```bash
uv run artemis run "Explore the TeamUp EXE app freely for 20 minutes. Try every tab, import a class, run matching, edit and approve proposals, and report anything that looks broken, confusing or inconsistent." --profile pro
```

Danh sách vấn đề tìm được: *(chưa có)*
