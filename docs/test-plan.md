# Test plan

Hai lớp kiểm thử:

| Lớp | Công cụ | Số lượng | Chạy ở đâu |
|---|---|---|---|
| Unit, ViewModel, widget | `flutter test` | 159 test | CI và máy dev, không cần thiết bị |
| Rules Firestore | `@firebase/rules-unit-testing` trên emulator | 25 test | `firebase/test` |
| **E2E trên thiết bị** | **Google ARTEMIS** + pytest | **14 ca** (13 chạy tự động, 1 cần người gửi push) | thiết bị/emulator Android |

> **Trạng thái 12/11/2026: bộ ARTEMIS đã viết và thu thập được 14 ca (`pytest --collect-only`), nhưng chưa chạy lần nào trên thiết bị.**
> Mục 5 (kết quả) và mục 6 (exploratory) còn trống có chủ đích: chỉ điền sau khi chạy thật, kèm trace.

## 1. Luồng quan trọng → màn hình

| Luồng | Màn |
|---|---|
| Đăng nhập, đăng xuất | S1, S19, S6 |
| Flow A: nhập lớp rồi ghép AI và duyệt | S2, S22, S23, S3, S8, S9, S10, S12, S14 |
| Flow B: sửa thành viên đề xuất (đường lỗi: dưới 5 người) | S10, S24, S25 (S11, S13) |
| Flow C: hủy đề xuất, ghép tay (đường lỗi: không tìm thấy) | S17, S5, S16, S21 |
| Màn chi tiết | S3 (lớp), S7 (sinh viên), S10 (đề xuất) |
| Điều hướng 3 tab | S2, S9, S6 |
| Xuất PDF và upload | S6 (vùng Firebase demo) |
| Remote Config đổi hành vi | S3 (nút Match with AI), S6, S9 |
| Mất mạng | S18 |
| Thông báo đẩy | trung tâm thông báo, deep link |

## 2. Ca kiểm thử (ARTEMIS)

Mỗi ca là một hàm pytest trong `e2e_test/`, gửi **một** chỉ dẫn qua `ArtemisClient.run`. Chỉ dẫn nêu điểm xuất phát, các bước và **các giá trị phải báo lại** dưới dạng một dòng JSON; test so sánh giá trị đó với kỳ vọng, không chỉ tin `status == SUCCESS` (xem `conftest.py`).

**Tiền điều kiện chung:** thiết bị Android 13+ đã thêm tài khoản Google **test riêng**; app bản Firebase thật đã cài (`flutter run`); `tool/fixtures/lab3-demo.csv` được push vào `/sdcard/Download` (fixture `fixture_on_device` làm việc này). Các ca cần dữ liệu **tự nhập lớp `EXE101 Demo` lúc đầu ca** (mỗi lần nhập tạo một lớp mới với ID mới), nên không ca nào phụ thuộc thứ tự chạy hay dữ liệu ca khác để lại.

| ID | Tên | Flow / mục đề | Tiền điều kiện | Kết quả mong đợi (giá trị agent báo, test so sánh) | Đánh dấu | Đã chạy |
|---|---|---|---|---|---|---|
| TC01 | Đăng nhập Google bằng account picker | Đăng nhập | Đã đăng xuất | `signed_in = true`; tab = Classes, Proposals, Profile; logcat có `login` | native, analytics | Chưa |
| TC02 | Đăng xuất | Sign-out | Đã đăng nhập | Hiện nút Continue with Google; không còn thanh tab; mở lại app vẫn ở màn đăng nhập | | Chưa |
| TC03 | Email sai | Flow A, S19 (lỗi) | Đã đăng xuất | `error_text = "Enter a valid email"`; không vào My classes | error_path | Chưa |
| TC04 | Nhập CSV | Flow A, S22, S23 | Đã đăng nhập | Nút `Import 12 students`; kết quả 12 / 9 / 3; logcat có `class_import` | analytics | Chưa |
| TC05 | Ghép AI rồi duyệt | Flow A, hành động chính | Đã đăng nhập | Có thẻ Group 2; sau khi thêm có 6 thành viên; snackbar `Team approved`; số thẻ Group 2 giảm 1; logcat có `ai_match_start`, `ai_match_result`, `proposal_approve` | analytics | Chưa |
| TC06 | Bỏ thành viên, nhóm dưới 5 | Flow B, S24, S25 (lỗi) | Đã đăng nhập | Banner `Needs at least 5 members (now 4)`; Approve bị khóa; ca tự Discard để dọn | error_path | Chưa |
| TC07 | Hủy đề xuất rồi ghép tay, tìm không ra | Flow C, S17, S21 (lỗi) | Đã đăng nhập | Số thẻ Group 2 giảm 1; tiêu đề rỗng `No student results` | error_path | Chưa |
| TC08 | Chi tiết lớp và sinh viên | màn chi tiết | Đã đăng nhập | 3 SV chưa có nhóm, 1 nhóm thiếu người; ID `AI000012`, `GD000011`, `MK000010`; SV Dương Yến có ngành AI | | Chưa |
| TC09 | 3 tab và Back | điều hướng | Đã đăng nhập | Tiêu đề Proposals, Profile đúng; Back về đúng My classes | | Chưa |
| TC10 | Remote Config đổi hành vi | Remote Config | Đã đăng nhập | `ai_matching_enabled` và `max_proposals_shown` khớp giá trị console; nút Match with AI hiện/ẩn theo cờ | | Chưa |
| TC11 | Xuất PDF và upload | export/upload | Đã đăng nhập | Thấy tiến độ `% uploaded`; thông báo bắt đầu bằng `Uploaded`; danh sách Saved reports có mục; logcat có `report_export` | analytics | Chưa |
| TC12 | Hộp thoại quyền thông báo | native | Đã thu hồi `POST_NOTIFICATIONS` | Hộp thoại hệ thống xuất hiện; sau khi Allow app hiện trạng thái đã cho phép | native | Chưa |
| TC13 | Mất mạng khi ghép | Flow A, S18 (lỗi) | Đã đăng nhập, có mạng lúc nhập | Hiện lỗi và nút `Try again`; tắt Airplane rồi thử lại thì phục hồi | error_path | Chưa |
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

*Chưa có. Điền sau khi chạy `run_suite.sh`:*

| Test | Runs | Passed | Pass rate | Avg time (s) | Verdict |
|---|---|---|---|---|---|
| (chưa chạy) | | | | | |

Giải thích từng ca flaky/fail/bỏ qua: *(chưa có)*

## 6. Phiên exploratory (Pro, 15–30 phút)

*Chưa thực hiện.* Chạy:

```bash
uv run artemis run "Explore the TeamUp EXE app freely for 20 minutes. Try every tab, import a class, run matching, edit and approve proposals, and report anything that looks broken, confusing or inconsistent." --profile pro
```

Danh sách vấn đề tìm được: *(chưa có)*
