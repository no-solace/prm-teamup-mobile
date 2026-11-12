# Bàn giao & hướng dẫn nộp bài — PRM393 Lab 3 (TeamUp EXE)

> **Đọc file này trước khi nộp.** Đây là bản tóm tắt ngắn gọn: **đã làm được
> gì**, **còn phải làm gì**, và **làm như thế nào** (kèm lệnh cụ thể).
>
> Bản ghi đầy đủ, có lý do từng quyết định: [`docs/WORKLOG.md`](WORKLOG.md).
>
> **Cập nhật:** 12/11/2026

---

## 1. Trạng thái trong 30 giây

| Hạng mục | Trạng thái | Kiểm chứng bằng lệnh |
|---|---|---|
| `flutter analyze` | ✅ **0 issue** | `flutter analyze` |
| Unit + widget test | ✅ **150/150 pass** | `flutter test` |
| Firestore rules test | ✅ **21/21 pass** | xem §5.1 |
| Luật layer MVVM | ✅ **Layers OK** | `bash tool/check_layers.sh` |
| Bộ test E2E | ✅ 19 test · **TC-02 đã chạy thật (pass 110.82s)** | `tool/run_e2e.ps1` |
| ARTEMIS host + agent | ✅ **đã dựng & chạy thật** (12 phiên, 22 ảnh) | xem §4 |
| AI code review | ✅ **12 finding / 5 commit sửa** | `docs/code-review.md` |
| Report PDF | ✅ **10 trang** (yêu cầu 8–12) | `report/Lab03_group6.pdf` |
| Slides PDF | ✅ **20 trang** = 15 main + 5 phụ lục | `slides/Lab03_group6_slides.pdf` |
| Evidence ARTEMIS | ✅ **đã có ảnh + log thật** | `evidence/artemis/` |
| `google-services.json` | ❌ **CÒN — cần đăng nhập Firebase** | xem §3 |
| Ảnh Console (6 dịch vụ) | ❌ **CÒN — cần project thật** | xem §3 |
| Video demo 5–10 phút | ❌ **CÒN — cần thiết bị thật** | xem §3 |

**Tóm lại:** phần **code, test, tài liệu, PDF** đã xong và đã kiểm chứng bằng lệnh
thật. Phần **còn lại đều là việc cần tài khoản/thiết bị** — không thể làm thay
bạn, nhưng đã được rút gọn xuống ~2–3 giờ với đúng lệnh dưới đây.

---

## 2. Những gì đã làm trong phiên này (để bạn hiểu)

Phiên này tập trung vào **chạy thật** phần hạ tầng E2E thay vì chỉ viết code.

### 2.1 Dựng được ARTEMIS host chạy thật

| Việc | Kết quả |
|---|---|
| Clone `google/artemis` @ `351ca842` | Khớp đúng commit đã ghim trong `e2e_test/pyproject.toml` |
| `uv sync` | 195 package cài xong |
| `.env` (đã gitignore) | Key lấy từ biến môi trường, **không** nằm trong repo |
| `artemis doctor` | **Status: Ready** — Gemini key active, device detected |
| Emulator `TestPixel` | `emulator-5554`, Android 14, có Google Play |
| `artemis helper install` | Accessibility helper v1.2.0, service enabled |
| `artemis ui --port 8000` | Daemon sống, `/api/status` → 200 |

### 2.2 Sửa 4 lỗi thật — chi tiết ở `docs/WORKLOG.md` §5b.2

**(a) Model mặc định của ARTEMIS không dùng được với key này.**
`gemini-3.8-flash` trả HTTP 503 → task timeout 180s. Đã đổi sang
`gemini-3.6-flash` (fallback `gemini-3.5-flash`) trong 8 file cấu hình.

**(b) App crash ngay khi khởi động — `PrintFileProvider` ClassNotFound.**
Provider có trong manifest nhưng class không có trong dex. Nguyên nhân gốc:
**build bằng JDK 26** làm AGP 9.1.0 fail ở bước `jlink`, để lại build tổn còng.
Sửa: dùng **JDK 24** + `flutter clean` → app khởi động bình thường.

> ⚠️ **Đặt `JAVA_HOME` trỏ JDK 24 trước khi build**, nếu không sẽ gặp lại lỗi này.

**(c) Bộ test đọc `Observed.text` rỗng dù task đã PASS.**
`artemis_client` không trả báo cáo cho client — ARTEMIS lưu nó ở step cuối
(`report_task_status`). Đã thêm `_fetch_session_steps()` + `_extract_final_report()`
vào `e2e_test/conftest.py`.

**(d) Hạn mức Gemini free-tier đã cần đặt — đây là giối hạn
thừt, không phải lỗi code.**

Khi chạy cả bộ 19 test, các test về sau bắt đầu fail hàng loạt:

```
TimeoutError: LLM call timed out after 180 seconds.
```

Log của daemon cho ra nguyên nhân gốc:

```
429 Too Many Requests — quota exceeded for metric:
  generativelanguage.googleapis.com/generate_content_free_tier_requests
```

Hạn mức Gemini free-tier **reset 00:00 theo giờ UTC**. Cách vượt:
chờ ngày mới, hoặc dùng key/project khác, hoặc nâng cấp gói trả
phí.

> **Kinh nghiệm cho nhóm:** chạy 1 test để đo chi phí trước khi
> chạy cả bộ — một lần chạy đệ đụ tiêu tốn đặ hạn
> mức cả ngày. Chuẩn bề sẵn CSV + tài khoản Google + Analytics
> debug mode **trước**, rồi chạy 1 lỗt cho cả bộ.

### 2.3 Bằng chứng thật đã thu được

| Số lượng | Nội dung |
|---|---|
| **12 phiên** ARTEMIS | 4 `completed`, 8 `failed` (chi tiết: `evidence/artemis/README.md`) |
| **22 ảnh chụp thật** | `evidence/artemis/<session-id>/screenshots/step-NN-before/after.jpg` |
| **1 test pass** | TC-02 — `1 passed in 110.82s` |

Agent đọc đúng màn hình `My classes`:

```
Class A: 17 students
Class B: 0 students
Class C: 0 students
```

Và đi 3 tab dưới đúng thứ tự:

```
Proposals, Profile, My classes
```

Ảnh + log từng bước đã nằm trong `evidence/artemis/<session-id>/`.

### 2.4 Script mới để dùng lại

| File | Tác dụng |
|---|---|
| `tool/run_e2e.ps1` | Kiểm tra đủ kiện → chạy pytest, báo lỗi rõ ràng |
| `tool/run_e2e.py` | Bản Python cho CI / Git Bash |
| `tool/collect_artemis_evidence.py` | Tải ảnh + log + summary từ daemon vào `evidence/artemis/` |

### 2.5 Tài liệu đã cập nhật cho khớp với thực tế

Sau khi có kết quả chạy thật, **không còn chỗ nào trong repo nói "chưa chạy"**
trong khi thực tế đã chạy — mọi con số đã được cập nhật đúng:

| File | Đã cập nhật |
|---|---|
| `docs/code-review.md` | thêm **CR-11** (client không nhận báo cáo) và **CR-12** (app crash vì JDK 26) + phần quyết định chi tiết |
| `docs/test-plan.md` §6 | TC-02 → **1/1 pass, 110.82s**; TC-01 → fail có lý do |
| `docs/test-plan.md` §7 | ghi rõ nguyên nhân **hạn mức Gemini 429** |
| `report/Lab03_report.md` | §7.3 ghi kết quả thật; §8 lên **12 phát hiện** |
| `slides/Lab03_slides.md` | slide 14 + A3 + A3b + A4 cập nhật; tách A3 thành 2 slide để **mỗi trang PDF đúng 1 slide** |
| `evidence/artemis/README.md` | danh mục 12 phiên + 22 ảnh + lý do `failed` |
| `README.md` | bảng trạng thái, lệnh chạy E2E, công cụ AI vòng 3 |
| `docs/WORKLOG.md` | §5b.4, §5b.5, môi trường (JDK 24), checklist bài nộp |

**PDF đã dựng lại:** report **10 trang** (yêu cầu 8–12), slides **20 trang**
(15 main + 5 phụ lục) — kiểm bằng PyMuPDF, mỗi trang slides đúng 1 heading.

---

## 3. Việc CÒN LẠI — làm theo thứ tự này

### 3.0 ⛔ Chốt Project ID Firebase trước tiên (5 phút)

`.firebaserc` trỏ `prm-lab3-cc39e`, còn `docs/skeleton-decisions.md` nhắc dự án
`teamup-exe-group6`. **Hai tên không khớp.**

Đề §11: *"the project ID in console screenshots must match the one in your
google-services.json"*. Chụp sai project = mất điểm toàn bộ mục bằng chứng.

→ **Chốt với thầy trước khi làm 3.1.**

### 3.1 Firebase thật (1–2 giờ) → mở ~4–5 điểm

```bash
# 1. Đăng nhập (mở trình duyệt, chọn Google account của nhóm)
npx firebase-tools@15.35.0 login

# 2. Sinh google-services.json + firebase_options.dart
dart pub global activate flutterfire_cli
flutterfire configure --project <PROJECT-ID> \
    --platforms android --android-package-name com.group6.teamup_exe

# 3. Deploy rules
npx firebase-tools@15.35.0 deploy \
    --only firestore:rules,storage --project <PROJECT-ID>
```

Trong Firebase Console, làm thêm:

- **Authentication** → bật provider **Google**.
- **Project settings** → thêm **SHA-1** của máy sẽ chạy test:
  ```bash
  cd android && ./gradlew signingReport
  ```
  (thêm cả SHA-1 debug lẫn release).
- **Storage** → tạo bucket ở `us-central1`.
- **Crashlytics** → bật + đổi `com.group6.teamup_exe` thành app **không** debug
  để nhận symbol.
- **Remote Config** → tạo 2 tham số `ai_matching_enabled` (bool) và
  `max_proposals_shown` (số).
- **Billing** → đặt budget alert 1 USD.

> ⚠️ `lib/firebase_options.dart` hiện là **placeholder cố tình** — `main.dart` báo
> lỗi rõ ràng nếu chưa cấu hình. `flutterfire configure` sẽ ghi đè file này, và
> file được commit (đề §9 cho phép).

### 3.2 Chạy lại ARTEMIS trên build thật (1–2 giờ) → mở ~2 điểm

Sau khi có `google-services.json`:

```bash
# Build bản nộp (KHÔNG dùng main_fake)
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Chạy suite 3 lần để có pass rate
tool/run_e2e.ps1 -Mark "not exploratory"     # lặp 3 lần
tool/run_e2e.ps1 -Mark exploratory -TestPath e2e_test/test_exploratory.py

# Gom bằng chứng
python tool/collect_artemis_evidence.py
```

**Cần chuẩn bị trước:**

- CSV `tool/fixtures/lab3-demo.csv` **đẩy lên thiết bị** (TC-05/TC-06 dùng
  file picker).
- Tài khoản Google test **đã đăng nhập sẵn** trên thiết bị.
- Bật **Analytics debug mode** (Console → Analytics → Settings → DebugView).
- Ba test cần bật biến môi trường để chạy:
  | Test | Biến | Khi nào bật |
  |---|---|---|
  | TC-16 (FCM) | `ARTEMIS_FCM_TRIGGER=1` | Sau khi gửi test message từ Console |
  | TC-17 (Analytics) | `ARTEMIS_ANALYTICS_DEBUG=1` | Sau khi bật Analytics debug mode |
  | TC-18 (Crashlytics) | `ARTEMIS_CRASHLYTICS=1` | Chạy riêng, test này gây crash |

Rồi điền `docs/test-plan.md` §6 (test ID · số lần chạy · pass rate · thời gian
TB) và §7 (ca flaky).

> ⚠️ **Chạy 1 ca để đo chi phí trước khi chạy cả bộ.** Một lần chạy đệ đụ tiêu
> tốn đặt hạn mức Gemini free-tier cả ngày (reset 00:00 UTC).

### 3.3 Chụp ảnh bằng chứng Console (1–2 giờ) → mở ~4 điểm

Theo checklist chi tiết trong [`evidence/README.md`](../evidence/README.md) §2.
Tóm tắt:

| # | Dịch vụ | Ảnh cần chụp |
|---|---|---|
| 1 | Authentication | Console → Users (có mentor đã đăng nhập); màn trước/sau đăng nhập |
| 2 | Firestore | Console → `classes/{id}/students`, `teams`, `proposals` (1 `approved`) |
| 3 | Storage | Console → file trong `reports/{uid}/`; màn S6 hiện download URL + size |
| 4 | FCM | Thông báo ở 3 trạng thái (foreground / background / terminated) |
| 5 | Analytics | DebugView: **một ảnh cho mỗi event** (10 event), thấy tên + tham số |
| 6 | Crashlytics | Non-fatal + test crash + custom key `role`/`class_id` + user ID |
| 7 | Remote Config | Console giá trị + ảnh app **trước/sau** đổi + ảnh mất mạng |
| 8 | Storage security | Ảnh chỉ thấy thư mục `reports/{uid}/` của mentor đang đăng nhập |

Quy tắc: tự chụp · project ID khớp · **không** chỉnh ảnh · ảnh app chụp trên
**thiết bị thật**.

### 3.4 Video demo (1 giờ) → mở ~2 điểm

Quay **trực tiếp**, 5–10 phút (đề §11 trừ điểm "edited-in results instead of live
runs"). Thứ tự quay theo `docs/test-plan.md` §5 / slide 13:

> đăng nhập → 3 flow (kèm đường lỗi) → xuất & upload PDF → nhận thông báo →
> đổi Remote Config không build lại → demo Crashlytics → chạy 1 ca ARTEMIS trên
> thiết bị → 1 phát hiện AI review kèm fix.

Upload YouTube/Drive, dán link vào `README.md`.

### 3.5 Dựng lại PDF với MSSV thật (5 phút)

```bash
python tool/build_report.py --student-id <MSSV>
```

Ra `report/Lab03_<MSSV>.pdf` và `slides/Lab03_<MSSV>_slides.pdf` đúng tên đề
yêu cầu. **Kiểm tra lại số trang** sau khi dựng (report 8–12 trang, slides đúng
20 trang = 15 main + 5 phụ lục).

### 3.6 Cập nhật Figma (30 phút)

Đề §3: sai lệch Figma ↔ app **không ghi** = lỗi. Còn D1–D4 chưa cập nhật (xem
`docs/design-traceability.md` §5).

### 3.7 Mở pull request & nộp (10 phút)

```bash
git push origin feature/lab3-complete-gaps
gh pr create --base main --title "Lab 3: Firebase + ARTEMIS + AI code review"
```

---

## 4. Cách chạy lại hạ tầng ARTEMIS trên máy này

```bash
# 1. Terminal 1 — daemon
cd C:/Workspace/PRM393/artemis
uv run python -m artemis ui --port 8000 --no-open

# 2. Terminal 2 — kiểm tra
curl http://127.0.0.1:8000/api/status

# 3. Terminal 3 — chạy test
cd C:/Workspace/PRM393/prm-teamup-mobile
export ARTEMIS_DEVICE=emulator-5554
export ARTEMIS_API_KEY=<key>
export ARTEMIS_BASE_URL=http://127.0.0.1:8000
tool/run_e2e.ps1
```

Các biến môi trường ARTEMIS đã dùng:

| Biến | Ý nghĩa |
|---|---|
| `ARTEMIS_BASE_URL` | Địa chỉ host (mặc định `http://127.0.0.1:8000`) |
| `ARTEMIS_DEVICE` | Serial của thiết bị (`emulator-5554`) |
| `ARTEMIS_API_KEY` | Key của mô hình đa phương thức |
| `ARTEMIS_PROFILE` | `flash` (hồi quy) hoặc `pro` (khám phá) |
| `ARTEMIS_TIMEOUT` | Timeout mỗi task (giây, mặc định 1800) |

---

## 5. Kiểm chứng toàn bộ trước khi nộp

### 5.1 Chạy lại mọi kiểm tra tự động

```bash
flutter analyze
flutter test
bash tool/check_layers.sh          # Git Bash: "C:\Program Files\Git\bin\bash.exe"
npx firebase-tools@15.35.0 emulators:exec --only firestore \
    --project demo-teamup-data "node --test firebase/test/firestore.rules.test.mjs"
cd e2e_test && pytest --collect-only -q
python tool/build_report.py --student-id <MSSV>
```

### 5.2 Checklist bài nộp theo đề §11

| # | Mục | Trạng thái |
|---|---|---|
| 1 | Topic và API được giảng viên duyệt | ☐ cần xác nhận |
| 2 | `design-traceability.md` + `architecture.md` viết **trước** khi làm feature | ✅ có |
| 3 | Quy tắc MVVM + design system giữ xuyên suốt | ✅ `Layers OK` |
| 4 | Tất cả màn Lab 2 đều được trace | ✅ 25/25 |
| 5 | Cả 6 dịch vụ Firebase chạy, mỗi cái có ca lỗi | ✅ code · ❌ chưa có ảnh |
| 6 | Storage rules giới hạn mỗi user ở thư mục riêng | ✅ 21/21 test |
| 7 | Analytics event plan; **mọi event thấy trong DebugView** | ✅ code 10 event · ❌ chưa có ảnh |
| 8 | Crashlytics có non-fatal + test crash + custom key | ✅ code · ❌ chưa có ảnh |
| 9 | **2** giá trị Remote Config đổi app không cần build | ✅ code · ❌ chưa có ảnh |
| 10 | Test plan ≥ 10 ca, có error path + native + exploratory | ✅ 18 + 1 |
| 11 | **ARTEMIS chạy ≥ 3 lần/ca**, có trace + bảng pass rate | ⚠️ **đã chạy thật 1 ca (TC-02 pass)** — cần ≥ 3 lần/ca trên build release |
| 12 | ≥ 5 finding có quyết định; ≥ 3 fix trong commit | ✅ 12 / 5 |
| 13 | Không commit bí mật | ✅ `.gitignore` |
| 14 | README liệt kê phiên bản, công cụ AI, link video | ⚠️ thiếu link video |
| 15 | Repo, report, slides, video mở được ở cửa sổ ẩn danh | ☐ kiểm cuối |

---

## 6. Câu hỏi cần chốt với nhóm

1. **Project ID Firebase nào là thật?** `prm-lab3-cc39e` hay `teamup-exe-group6`?
   → **Chặn 3.1 → 3.3**
2. **Ai có máy Android thật?** Cần tối thiểu 1 máy có Google Play + tài khoản
   Google test đã đăng nhập (để chạy ARTEMIS 3 lần + quay video).
3. **MSSV từng thành viên** để đặt tên file PDF đúng quy định.
4. **Link video demo** — ai upload, đăng ở đâu.
5. **Figma file** — ai có quyền sửa 4 frame D1–D4.
6. **Kiểm tra lại `JAVA_HOME`**: build bằng JDK 24, không phải JDK 26.

---

## 7. Nếu có gì hỏng

| Triệu chứng | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| `TimeoutError: LLM call timed out` | Model mặc định 503 với key đó | Đổi sang `gemini-3.6-flash` trong `config/artemis.jsonc` |
| `Unable to get provider ...PrintFileProvider` | Build bằng JDK 26 | Đặt `JAVA_HOME` = JDK 24, `flutter clean`, build lại |
| `Could not reach Artemis host` | Daemon chưa chạy | `uv run python -m artemis ui --port 8000 --no-open` |
| `Set ARTEMIS_DEVICE ... to the device serial` | Chưa có thiết bị | `adb devices` rồi set biến |
| Test FAIL với `Observed(text='')` | Bản cũ của `conftest.py` | Đã sửa trong commit này — `git pull` |
| `adb: no devices/emulators found` | Emulator tắt | `flutter emulators --launch TestPixel` |
