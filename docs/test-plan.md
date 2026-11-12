# Test plan — TeamUp EXE (Lab 3 §7)

> Bộ test E2E dùng **Google ARTEMIS**. Mỗi test là một hàm pytest gửi **một**
> chỉ dẫn bằng ngôn ngữ tự nhiên và **kiểm tra trên giá trị agent báo lại**,
> không chỉ kiểm `status == "SUCCESS"`.
> Mã nguồn: [`e2e_test/`](../e2e_test/). Bằng chứng chạy: [`evidence/artemis/`](../evidence/artemis/).

---

## 1. Các flow quan trọng và màn hình dùng

| Flow | Mục tiêu (từ `ux/user-flow.md` của Lab 2) | Màn hình dùng | Nhánh lỗi |
|---|---|---|---|
| **A** | Mentor nhập danh sách lớp và duyệt gợi ý AI cho một lớp | S1, S2, S22, S23, S3, S8, S9, S10, S12, S14 | S19 (email sai), S18 (mất mạng khi AI chạy) |
| **B** | Mentor thêm / bỏ thành viên trong một đề xuất rồi duyệt nhóm | S9, S10, S11, S12, S13, S24, S25 | S13 (vượt 6 người), S25 (dưới 5 người) |
| **C** | AI không ghép được → mentor ghép tay | S3, S5, S15, S16, S21, S20, S17 | S21 (không tìm ra SV), SV đã có nhóm bị khoá, S17 (discard) |
| **Tab** | Điều hướng 3 tab | S2, S9, S6 | — |
| **Auth** | Đăng nhập / đăng xuất | S1, S6 | S19 |
| **Export** | Sinh PDF và upload | S6 (demo) | — |

---

## 2. Danh sách test case

| ID | Flow | Precondition | Bước (chỉ dẫn rút gọn) | Kết quả mong đợi | Loại | File |
|---|---|---|---|---|---|---|
| **TC-01** | Auth | App đã cài, chưa đăng nhập | Mở app → tap "Continue with Google" → chọn tài khoản test trong account picker của hệ thống | Màn "My classes" hiện, bottom navigation có 3 tab. Agent báo cáo số tab = 3 | **Native** (Google account picker) | `test_auth.py` |
| **TC-02** | Tab | Đã đăng nhập | Tap tab Proposals → Profile → Classes | Mỗi tab mở đúng màn của nó; agent báo cáo 3 tiêu đề: Proposals, Profile, Classes | Happy path | `test_auth.py` |
| **TC-03** | Remote Config | Đã đăng nhập | Profile → cuộn xuống khu Remote Config | Dòng `max_proposals_shown` hiện kèm số; agent đọc được số ≥ 1 | Happy path | `test_auth.py` |
| **TC-04** | Auth | Đã đăng nhập | Profile → cuộn xuống → tap "Sign out" | Quay lại màn Sign in, thấy "Continue with Google" | Happy path | `test_auth.py` |
| **TC-05** | A (S22) | Đã đăng nhập, lớp demo chưa nhập | Classes → "Import class list" → "Choose CSV" → chọn `lab3-demo.csv` | Tên file hiện, **5 cột** được đánh dấu detected, nút nhập ghi **12** sinh viên | Happy path | `test_flow_a.py` |
| **TC-06** | A (S23) | Đã đăng nhập | Import `lab3-demo.csv` → tap "Import 12 students" | Ba số: **imported = 12**, **in a group = 9**, **available = 3** | Happy path | `test_flow_a.py` |
| **TC-07** | A (S3→S8→S9) | Đã đăng nhập, lớp demo đã nhập | Mở lớp "EXE101 Demo" → tap "Match with AI" → chờ | Về tab **Proposals**, có **≥ 1** thẻ đề xuất, agent báo tên nhóm đầu tiên | Happy path | `test_flow_a.py` |
| **TC-08** | A/B (S10) | Đã đăng nhập, có đề xuất pending | Proposals → tap thẻ đầu tiên | Màn chi tiết: chip fit ("Strong fit"/"Good fit"), **≥ 1** ô ngành, mục "Why this team?" | Happy path | `test_flow_a.py` |
| **TC-09** | B (S10→S11) | Đã đăng nhập, đề xuất < 6 thành viên | Proposals → thẻ đầu → "Add member" | Dòng meta theo Lab 2 **"Tên nhóm, N of 6"** hiện, **≥ 1** hàng có checkbox | Happy path | `test_flow_b.py` |
| **TC-10** | B — lỗi (S13) | Đã đăng nhập, đề xuất pending có 5 thành viên | Mở đề xuất → "Add member" → tick thêm 1 SV (thành 7) | Lỗi inline **"Max 6 members"** hiện, nút lưu **disabled** | **Error path** | `test_flow_b.py` |
| **TC-11** | B — lỗi (S25) | Đã đăng nhập, đề xuất pending | Mở đề xuất → bấm nút xoá 1 thành viên → xác nhận "Remove" | Banner **"Needs at least 5 members (now N)"**, nút "Approve proposal" **disabled** | **Error path** | `test_flow_b.py` |
| **TC-12** | C (S5) | Đã đăng nhập, lớp demo đã nhập | Mở lớp → hàng "teams needing members" | **≥ 1** thẻ nhóm, hiện số thành viên và dòng "Needs … to reach 5" | Happy path | `test_flow_c.py` |
| **TC-13** | C — lỗi (S21) | Đã đăng nhập, đang ở màn Add student | Gõ "ZZZNOONE" vào ô tìm kiếm | Trạng thái rỗng **"No student results"**, **0** hàng sinh viên | **Error path** | `test_flow_c.py` |
| **TC-14** | C (S17) | Đã đăng nhập, có đề xuất pending | Mở đề xuất → "Discard proposal" | Dialog "Discard proposal?", có nút "Discard" (đỏ) và "Cancel"; test bấm Cancel nên đề xuất còn nguyên | Happy path | `test_flow_c.py` |
| **TC-15** | Export | Đã đăng nhập, lớp demo đã nhập | Profile → "Export PDF to Firebase Storage" → chọn lớp → "Generate and upload PDF" | Hiện **Download URL** (bắt đầu bằng `http`), kích thước **≥ 1 KB**, mục "Saved reports" có file | Happy path | `test_export_and_notifications.py` |
| **TC-16** | FCM | Đã đăng nhập, vừa gửi test message từ Firebase console | Kéo notification shade → tap thông báo TeamUp EXE | App mở màn liên quan ("Proposals"), agent báo được tiêu đề thông báo | **Native** (notification shade) | `test_export_and_notifications.py` |
| **TC-17** | Analytics | Đã đăng nhập, bật Analytics debug mode | Mở lớp → "Match with AI" → chờ xong, đọc Logcat | Logcat chứa `ai_match_start` **và** `ai_match_result` | Happy path | `test_export_and_notifications.py` |
| **TC-18** | Crashlytics | Đã đăng nhập, bật Crashlytics collection | Profile → khu demo Crashlytics → action test crash | App đóng lại, crash hiện trên dashboard Crashlytics | **Native** (deliberate crash) | `test_export_and_notifications.py` |
| **EX-01** | Khám phá | Đã đăng nhập | Phiên 15–30 phút không kịch bản (Pro profile) | Báo cáo: màn đã ghé, chỗ không rõ, lỗi/empty state thấy được (nguyên văn), hành động không làm được, số đề xuất ở tab Proposals | Exploratory | `test_exploratory.py` |

**Tổng: 18 test script + 1 phiên khám phá = 19** (yêu cầu ≥ 10).

### Độ phủ theo yêu cầu §7

| Yêu cầu | Test đáp ứng |
|---|---|
| Mỗi flow Lab 2 chạy hết từ đầu đến cuối | A: TC-05→TC-08 · B: TC-09→TC-11 · C: TC-12→TC-14 |
| Nhánh thay thế và nhánh lỗi của mỗi flow | A: TC-03, TC-04 · B: TC-10, TC-11 · C: TC-13, TC-14 |
| Đăng nhập | TC-01 |
| Hành động chính (primary action) | TC-07 (Match with AI) |
| Từng tab cấp cao nhất | TC-02 |
| Từng loại màn chi tiết | TC-08 (proposal), TC-09 (add member), TC-12 (need members) |
| Export và upload | TC-15 |
| Giá trị Remote Config hiện trên màn | TC-03 |
| Đăng xuất | TC-04 |
| ≥ 1 test lỗi | TC-10, TC-11, TC-13 |
| ≥ 1 native interaction | TC-01, TC-16, TC-18 |
| 1 phiên khám phá Pro profile | EX-01 |
| ≥ 1 test kiểm analytics event | TC-17 |

---

## 3. Vì sao assert trên **giá trị** chứ không chỉ `SUCCESS`

Agent ARTEMIS là một mô hình ngôn ngữ: nó có thể báo `SUCCESS` dù app hiển thị sai.
Vì vậy mỗi chỉ dẫn bắt agent **trả về giá trị** và test so sánh:

```python
result = run(artemis, "… Report the number of proposal cards that are visible …")
assert result.ok, result.error
assert result.number("cards") >= 1, result.text     # giá trị, không phải chỉ status
```

`Observed.number()` bắt số đầu tiên (hoặc số ngay sau một nhãn) trong báo cáo;
`Observed.contains()` kiểm tra chuỗi. Nếu agent không tìm thấy giá trị, test
**fail với nguyên văn báo cáo** — đây là bằng chứng để điều tra, không phải lỗi
âm thầm.

---

## 4. Quy tắc bất biến của bộ test

| Quy tắc | Cơ chế |
|---|---|
| Test độc lập thứ tự | Mỗi test nêu precondition; `pytest` chạy được theo bất kỳ thứ tự nào. |
| Không phụ thuộc trạng thái test trước | Dữ liệu dùng lại là fixture `tool/fixtures/lab3-demo.csv` (12 SV). Import lại lớp sẽ tạo bản ghi mới, app xử lý trùng lặp an toàn. |
| Không commit bí mật | `ARTEMIS_API_KEY`, `ARTEMIS_DEVICE` đọc từ biến môi trường; tài khoản Google test nằm trên thiết bị. |
| Tài khoản test riêng | Dùng tài khoản Google dành cho test, không dùng tài khoản cá nhân. |
| Test destructive được skip mặc định | TC-16/17/18 chỉ chạy khi bật biến `ARTEMIS_FCM_TRIGGER` / `ARTEMIS_ANALYTICS_DEBUG` / `ARTEMIS_CRASHLYTICS`. |
| Timeout | `pytest-timeout` 900 s / test (Flash profile ~3–5 s mỗi bước). |

---

## 5. Lệnh đã dùng để chạy

```bash
# Regression, Flash profile
cd e2e_test
pytest -m "not exploratory" -v

# Lặp 3 lần mỗi test để đo pass rate (yêu cầu §7)
for i in 1 2 3; do pytest -m "not exploratory" -v; done

# Phiên khám phá
ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory

# Kiểm Semantics trên thiết bị
adb shell uiautomator dump /sdcard/ui.xml && adb pull /sdcard/ui.xml
```

## 6. Bảng kết quả

> **Trạng thái: CHƯA CHẠY.** Bảng này được điền **sau khi chạy thật trên thiết bị
> thật** (emulator có Google Play hoặc máy Android). Cột "Pass rate" = số lần đạt
> / tổng số lần chạy (mỗi test ≥ 3 lần).
>
> Hiện tại bộ test đã **được viết và kiểm tra cú pháp**, nhưng **chưa có lần chạy
> nào trên thiết bị** — vì vậy cột "Kết quả" ghi `chưa chạy` thay vì điền số.
> Số liệu bịa sẽ là điểm trừ lớn hơn là để trống. Ảnh chụp và log thực tế đặt
> ở `evidence/artemis/` kèm `evidence/artemis/README.md`.

| Test ID | Runs | Pass rate | Thời gian TB | Ghi chú |
|---|---|---|---|---|
| TC-01 | 0 | chưa chạy | — | Native: chọn tài khoản trong account picker |
| TC-02 | 0 | chưa chạy | — | |
| TC-03 | 0 | chưa chạy | — | |
| TC-04 | 0 | chưa chạy | — | |
| TC-05 | 0 | chưa chạy | — | |
| TC-06 | 0 | chưa chạy | — | |
| TC-07 | 0 | chưa chạy | — | |
| TC-08 | 0 | chưa chạy | — | |
| TC-09 | 0 | chưa chạy | — | |
| TC-10 | 0 | chưa chạy | — | |
| TC-11 | 0 | chưa chạy | — | |
| TC-12 | 0 | chưa chạy | — | |
| TC-13 | 0 | chưa chạy | — | |
| TC-14 | 0 | chưa chạy | — | |
| TC-15 | 0 | chưa chạy | — | |
| TC-16 | 0 | chưa chạy | — | Native: notification shade |
| TC-17 | 0 | chưa chạy | — | Kiểm Logcat |
| TC-18 | 0 | chưa chạy | — | Native: deliberate crash |
| EX-01 | 0 | chưa chạy | — | Pro profile, báo cáo trong `evidence/artemis/exploratory/` |

### Cách điền bảng này

```bash
cd e2e_test
pip install -e ".[artemis]"
export ARTEMIS_API_KEY=<model api key>
export ARTEMIS_DEVICE=emulator-5554

# 3 lần mỗi test để đo pass rate
for i in 1 2 3; do pytest -m "not exploratory" -v; done

# Phiên khám phá (Pro profile)
ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory
```

Sau đó: điền số vào bảng trên, chụp Logcat/DebugView vào `evidence/artemis/`, và
ghi nhận xét về ca flaky vào §7.

## 7. Giải thích test flaky / fail / skip

| Test | Trạng thái | Nguyên nhân | Cách xử lý |
|---|---|---|---|
| TC-16 | skip nếu thiếu `ARTEMIS_FCM_TRIGGER` | Cần gửi message từ Firebase console trước khi chạy | Bật biến và gửi message, sau đó chạy lại |
| TC-17 | skip nếu thiếu `ARTEMIS_ANALYTICS_DEBUG` | DebugView/Logcat chỉ có khi bật debug mode | Bật debug mode trong Console |
| TC-18 | skip nếu thiếu `ARTEMIS_CRASHLYTICS` | Crash cố ý phá app, không chạy trong regression | Chạy riêng, ngoài vòng regression |

## 8. Vì sao bộ test này đáng tin (theo yêu cầu §7)

1. **Không kiểm status một mình** — mọi test kiểm một giá trị cụ thể mà agent
   phải đọc từ màn hình.
2. **Chỉ dẫn có điểm bắt đầu, bước và kết quả mong đợi** — không có câu "kiểm
   app có chạy không".
3. **Có đường lỗi thật** — 3 test lỗi (TC-10, TC-11, TC-13) kiểm đúng thông điệp
   mà Lab 2 đã đặc tả ("Max 6 members", "Needs at least 5 members",
   "No student results").
4. **Có native interaction** — 3 test chạm vào hệ thống Android, không chỉ app.
5. **Chạy lặp lại ≥ 3 lần** để đo pass rate; test flaky được giải thích và sửa.
6. **Semantics labels** giúp agent đọc cây accessibility thay vì đoán từ ảnh —
   làm test nhanh hơn và ổn định hơn.
