# Nhật ký làm việc — Lab 3 TeamUp EXE

> File này ghi lại **những gì đã làm, vì sao làm, và cách kiểm chứng lại**, để
> thành viên khác (hoặc chính bạn, sau này) hiểu được dự án đang ở đâu và phần
> nào còn thiếu.
>
> **Cập nhật lần cuối:** 12/11/2026 · commit `1a89f81`

---

## 0. Tóm tắt nhanh

| Hạng mục | Trạng thái | Cách kiểm chứng |
|---|---|---|
| `flutter analyze` | ✅ **No issues found** | `flutter analyze` |
| Unit + widget test | ✅ **150/150 pass** | `flutter test` |
| Firestore rules test | ✅ **21/21 pass** | `npx firebase-tools@15.35.0 emulators:exec --only firestore --project demo-teamup-data "node --test firestore.rules.test.mjs"` |
| Luật layer (MVVM) | ✅ **Layers OK** | `bash tool/check_layers.sh` |
| Bộ test ARTEMIS | ✅ 19 test, API khớp SDK thật | `cd e2e_test && pytest --collect-only -q` |
| AI code review | ✅ **10 finding / 5 commit sửa** | `docs/code-review.md` |
| Report PDF | ✅ 10 trang (yêu cầu 8–12) | `report/Lab03_group6.pdf` |
| Slides PDF | ✅ 19 trang = 15 main + 4 phụ lục | `slides/Lab03_group6_slides.pdf` |
| `google-services.json` | ❌ **CHƯA CÓ** | xem mục 5 |
| ARTEMIS chạy trên thiết bị | ❌ **CHƯA CHẠY LẦN NÀO** | `docs/test-plan.md` §6 |
| `evidence/` | ❌ **RỖNG** (10 thư mục chỉ có `.gitkeep`) | xem mục 5 |
| Video demo 5–10 phút | ❌ **CHƯA CÓ** | xem mục 5 |

---

## 1. Phiên làm việc 12/11/2026 — phần 1: dựng bộ bài nộp

Mục tiêu: dựng đủ **4 sản phẩm bàn giao** mà đề Lab 3 yêu cầu, từ một repo vốn
chỉ có code.

### 1.1 Bốn sản phẩm đã tạo

| Sản phẩm | Vị trí | Nội dung |
|---|---|---|
| Bộ test E2E | `e2e_test/` | 18 ca ARTEMIS + 1 phiên khám phá, theo 3 flow A/B/C |
| Bản ghi AI code review | `docs/code-review.md` | Bảng finding + quyết định + lý do + commit |
| Báo cáo | `report/Lab03_report.md` → `.pdf` | 10 trang, 9 mục |
| Slide | `slides/Lab03_slides.md` → `.pdf` | 15 slide chính + 4 slide dự phòng |

Kèm: `docs/test-plan.md` (kế hoạch test §1–§7), `docs/workflow.md` (đặc tả 7
thành phần cho 3 workflow), `docs/data-model.md`, `evidence/README.md` (danh
mục ảnh cần chụp).

### 1.2 Công cụ dựng PDF

`tool/build_report.py` — chạy 1 lệnh ra cả report lẫn slides:

```bash
python tool/build_report.py --student-id <MSSV>
```

Cơ chế: Markdown → HTML có print stylesheet → headless Chromium in PDF.
Mermaid được render qua `mmdc` thành SVG nhúng base64 nên PDF **tự chứa**
(không phụ thuộc file ngoài).

> **Lưu ý khi dùng:** `--student-id` mặc định là `group6`. Khi nộp thật phải
> đổi thành MSSV để ra đúng tên file `report/Lab03_<MSSV>.pdf` và
> `slides/Lab03_<MSSV>_slides.pdf` như đề yêu cầu.

### 1.3 Sửa lỗi trung thực trong tài liệu

Trước khi dựng, `docs/test-plan.md` §6 có bảng kết quả điền sẵn `3/3` pass rate
trong khi `evidence/artemis/` **hoàn toàn rỗng**. Đây là bằng chứng bịa — đề
§11 xử lý "fabricated evidence" theo quy chế liêm chính học thuật.

Đã đổi thành "chưa chạy" + ghi rõ lệnh lặp 3 lần để tự điền sau khi chạy thật.

### 1.4 Các commit

```
669d377  docs(lab3): add the four required deliverables and the ARTEMIS suite
7bb2932  docs(lab3): add workflow spec, AI code review record, report/slides PDFs and evidence checklist
7623f35  docs(lab3): add the missing data model, correct the unverified claims
f3e0590  docs: correct the report page count and service count in the README map
7a60aca  docs: correct the Firebase CLI commands to what actually works on this machine
```

---

## 2. Phiên làm việc 12/11/2026 — phần 2: sửa 2 lỗi nghiêm trọng

Đây là phần **quan trọng nhất** của phiên. Cả hai lỗi đều là loại "mồi lỗi" —
không có test Dart nào bắt được, và chỉ lộ ra khi đối chiếu với tài liệu gốc.

### 2.1 CR-09 — Bộ test ARTEMIS gọi một API không tồn tại

**Triệu chứng.** Khi chạy `pytest` với biến môi trường đầy đủ, **18/18 test
fail** với `TypeError`/`AttributeError` — không phải lỗi của app, mà lỗi của
chính bộ test. Nếu giảng viên clone repo và chạy, họ sẽ thấy toàn bộ phần
E2E (một mục chấm điểm lớn) sập.

**Nguyên nhân.** Bộ test được viết theo trực giác, không theo API thật:

```python
# TRƯỚC — không tồn tại trong SDK ARTEMIS
ArtemisClient(device_serial=…, profile=…, api_key=…, output_dir=…)
result = artemis.run(instruction)      # gọi đồng bộ
```

**SDK thật** (đọc từ `google/artemis` @ `351ca842`):

| Điểm | Đúng như bộ test viết | SDK thật |
|---|---|---|
| Tên gói | `artemis` | **`artemis-client`** (gói con trong `packages/`) |
| Kiến trúc | chạy cục bộ, tự điều khiển thiết bị | **remote-only** — gọi HTTP tới một ARTEMIS daemon |
| `run()` | hàm đồng bộ | **coroutine** (`await client.run(...)`) |
| Tham số | `api_key`, `output_dir` | **không có**; key thuộc về phía daemon |
| Base URL | — | `base_url` / `ARTEMIS_BASE_URL` (mặc định `http://127.0.0.1:8000`) |

Thêm nữa `APP_PACKAGE` trong `conftest.py` là `com.example.teamup_exe`, còn
`applicationId` trong `android/app/build.gradle.kts` là
`com.group6.teamup_exe` → `adb shell pm clear` và `monkey` sẽ không nhắm đúng
app.

**Cách sửa (commit `668ce5f`):**

1. `e2e_test/pyproject.toml` — ghim **đúng commit** ARTEMIS:
   ```
   artemis-client @ git+https://github.com/google/artemis.git@351ca8422f7b5b54e80a9c1ce03a222e02415b6b#subdirectory=packages/artemis-client
   ```
   `requires-python` hạ từ `>=3.12` xuống `>=3.10` (SDK hỗ trợ từ 3.10, máy
   đang chạy 3.11).
2. `e2e_test/conftest.py`:
   - import `from artemis_client import ArtemisClient`;
   - dựng client: `ArtemisClient(base_url=…, token=…, device_serial=…, default_profile=…)`;
   - `run()` gọi qua `asyncio.run(...)` kèm `locked_app_package=APP_PACKAGE`;
   - `Observed.ok` so đúng tập trạng thái cuối của ARTEMIS (`completed`/`success`)
     thay vì so chuỗi `"SUCCESS"`;
   - `APP_PACKAGE` → `com.group6.teamup_exe`.
3. Biến môi trường mới: `ARTEMIS_BASE_URL`, `ARTEMIS_TOKEN`, `ARTEMIS_TIMEOUT`.
4. `e2e_test/README.md` viết lại phần cài đặt + khởi động daemon.

**Kiểm chứng:**

```bash
cd e2e_test
pip install -e ".[artemis]"          # cài được, không lỗi
pytest --collect-only -q             # 19 test collected
ARTEMIS_DEVICE=emulator-5554 ARTEMIS_API_KEY=x pytest -m "not exploratory" -q
# → NetworkError: Could not reach Artemis host at http://127.0.0.1:8000/api/run
```

Lỗi cuối cùng là **đúng**: nghĩa là code đã đi đúng đường, chỉ còn thiếu
daemon + thiết bị. Trước đây nó là `TypeError` — sai ngay ở tầng API.

### 2.2 CR-10 — S13 hiện lỗi nhưng nút vẫn bấm được

**Triệu chứng.** Mở màn S11 (Add member), tick quá số thành viên cho phép:
dòng lỗi "Max 6 members" hiện đúng, nhưng **nút lưu vẫn bấm được**. Dòng đếm
hiện `"1 of 2 places selected"` thay vì meta line của Lab 2.

**Vì sao đây là lỗi.** Lab 2 handoff (`docs/prm323-lab2-group6/handoff/flutter-handoff.md`)
mô tả S13 rất cụ thể:

> **Components:** Checkbox row, error text, **Button primary (disabled)**
> **User interactions:** Bỏ một lựa chọn thì lỗi biến mất và nút Add bật.

và Lab 2 user-flow:

> 6 = đầy (Full) → Khóa: không nhận thêm, không là đích đề xuất; thêm nữa báo
> "Max 6 members"

Đề Lab 3 §3 nói thẳng: *"An unrecorded difference between Figma and the app is
graded as a defect."*

**Cách sửa (commit `668ce5f`):**

| File | Thay đổi |
|---|---|
| `lib/widgets/proposal_student_picker.dart` | Thêm `onValidityChanged` để báo trạng thái hợp lệ; thêm `teamName` + `currentSize`; meta line đổi thành `<tên nhóm>, N of 6` (N = kích thước nhóm **sau** khi áp dụng lựa chọn); nhóm đầy ngay từ frame đầu cũng báo lỗi |
| `lib/screens/flow_b/add_member_screen.dart` | Nút "Save selection" **khoá đúng lúc** dòng lỗi đang hiện, tự mở lại khi người dùng bỏ chọn một SV |
| `lib/screens/flow_c/add_student_screen.dart` | Truyền `teamName`/`currentSize` (S16 dùng chung widget) |
| `test/widgets/proposal_student_picker_test.dart` | **File mới**, 5 ca test |

**Bất biến được chốt trong code:** *nút xác nhận bật ⇔ dòng lỗi đang tắt.*

**5 test mới:**

| Test | Kiểm chứng |
|---|---|
| S11 hiện meta line `"FinLite, 5 of 6"` | đúng handoff Lab 2 |
| S13 từ chối lựa chọn vượt 6 + hiện lỗi | `onValidityChanged(false)` |
| S13 gỡ lỗi khi bỏ chọn | lỗi biến mất, nút mở lại |
| Nhóm đầy ngay từ frame đầu | lỗi hiện, nút khoá |
| S21 empty state khi không tìm thấy SV | đúng màn Add student |

### 2.3 Commit

```
668ce5f  fix(lab3): correct the ARTEMIS client API and enforce the S13 capacity lock
```

---

## 3. Phiên làm việc 12/11/2026 — phần 3: cập nhật hồ sơ AI review

**Vấn đề:** hai fix ở mục 2 đã được commit nhưng **chưa được ghi vào
`docs/code-review.md`**. Hồ sơ vẫn ghi "8 phát hiện, 4 commit" trong khi repo
thực tế đã có 10 và 5. Đề §8 chấm điểm "≥ 5 findings, ≥ 3 fixes in commits" —
số liệu trong hồ sơ phải khớp với git history, nếu không là **mất uy tín
bằng chứng**.

**Đã làm (commit `1a89f81`):**

- `docs/code-review.md`: thêm CR-09 và CR-10 vào bảng finding (kèm file:line,
  quyết định, lý do, commit) + thêm mục giải thích chi tiết §3 cho cả hai;
  tổng kết đổi thành "10 finding, 4 nhóm loại".
- `report/Lab03_report.md` và `slides/Lab03_slides.md`: thêm 2 dòng CR-09/CR-10,
  đổi số commit sửa 4 → 5, đổi số test 145 → 150.
- `README.md`, `evidence/README.md`: cập nhật số liệu.
- Dựng lại 2 file PDF.

**Một chỉnh sửa về hình thức:** slide 14 trước đó liệt kê cả 10 finding → tràn
sang trang 20 (deck thành 20 trang, mất "1 slide = 1 trang"). Đã sửa: slide 14
chỉ trình bày đầy đủ **2 finding mới** (đều là loại "mồi lỗi", đáng kể nhất) và
trỏ sang **slide dự phòng A3** cho bảng đầy đủ 10 dòng. Deck về lại **19 trang
= 15 main + 4 phụ lục**, mỗi trang đúng 1 slide (đã kiểm bằng PyMuPDF: mỗi
trang PDF chỉ có đúng 1 heading `NN ·`).

---

## 4. Phiên làm việc trước đó (tóm tắt)

Các commit trước đó đã ổn định, không cần sửa:

| Commit | Nội dung |
|---|---|
| `dc83598` | Initial commit |
| `268f998` | Persona + user-flow (Lab 2) |
| `1ecc7a7` | PROPOSAL.md mở rộng, skeleton-decisions.md |
| `670a8bb` | Khung dự án: pubspec, test ViewModel, script check layer |
| `e00efd8` | Hoàn thiện demo flow end-to-end |
| `1b6fea8` `9cf68f5` `000f51b` `7c0fc66` | 4 commit sửa CR-01 → CR-04 (kèm CR-05..CR-08) |

---

## 5. Việc CÒN LẠI — theo thứ tự nên làm

### 5.0 ⚠️ Chốt project ID Firebase TRƯỚC TIÊN

`.firebaserc` trỏ `prm-lab3-cc39e`, còn `docs/skeleton-decisions.md` mục
"Việc cần làm" lại nhắc dự án GCP **`teamup-exe-group6`** (số 409603737127).
Hai tên không khớp.

**Phải chốt trước khi làm bước 5.1**, vì đề §11 yêu cầu:
*"the project ID in console screenshots must match the one in your
google-services.json"*. Chụp ảnh sai project = mất điểm toàn bộ mục bằng chứng.

### 5.1 Firebase thật (1–2 giờ) → mở ~4–5 điểm

```bash
npx firebase-tools@15.35.0 login
flutterfire configure --project <project-id> \
    --platforms android --android-package-name com.group6.teamup_exe
npx firebase-tools@15.35.0 deploy --only firestore:rules,storage --project <project-id>
```

Kèm: bật Google Sign-In, thêm SHA-1 debug của 4 máy
(`cd android && ./gradlew signingReport`), tạo bucket Storage `us-central1`,
đặt budget alert 1 USD.

Lưu ý: `lib/firebase_options.dart` hiện là **placeholder** cố tình
(`main.dart` báo lỗi rõ ràng nếu chưa cấu hình). `flutterfire configure` sẽ
ghi đè file này — và file được commit (đề §9 cho phép).

### 5.2 Chạy ARTEMIS trên thiết bị (2–3 giờ) → mở ~2 điểm

```bash
git clone https://github.com/google/artemis.git && cd artemis
uv sync && uv run artemis start          # daemon ở 127.0.0.1:8000
curl http://127.0.0.1:8000/api/status    # kiểm tra daemon sống

cd <repo>/e2e_test
pip install -e ".[artemis]"
export ARTEMIS_API_KEY=... ARTEMIS_DEVICE=emulator-5554
for i in 1 2 3; do pytest -m "not exploratory" -v; done
ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory
```

Rồi điền `docs/test-plan.md` §6 (test ID · số lần chạy · pass rate · thời gian
TB) và chụp trace vào `evidence/artemis/TC-xx/run-1..3/`.

> **Cần chuẩn bị trước:** APK release (`flutter build apk`), CSV
> `tool/fixtures/lab3-demo.csv` **đẩy lên thiết bị** (TC-05/TC-06 chọn file
> qua file picker), tài khoản Google test **đã đăng nhập sẵn** trên thiết bị,
> bật Analytics debug mode.

### 5.3 Chụp ảnh bằng chứng (1–2 giờ) → mở ~4 điểm

Theo checklist chi tiết trong `evidence/README.md` §2. Tóm tắt:

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

Quy tắc: tự chụp, project ID khớp, **không** chỉnh ảnh, ảnh app chụp trên
**thiết bị thật**.

### 5.4 Video demo + dựng lại PDF (1 giờ) → mở ~2 điểm

Thứ tự quay theo `docs/test-plan.md` §5 / slide 13:

> đăng nhập → 3 flow (kèm đường lỗi) → xuất & upload PDF → nhận thông báo →
> đổi Remote Config không build lại → demo Crashlytics → chạy 1 ca ARTEMIS
> trên thiết bị → 1 phát hiện AI review kèm fix.

5–10 phút, **quay trực tiếp** (đề §11 trừ điểm "edited-in results instead of
live runs"). Upload YouTube/Drive và dán link vào `README.md`.

Rồi dựng lại PDF với MSSV thật:

```bash
python tool/build_report.py --student-id <MSSV>
```

### 5.5 Cập nhật Figma (30 phút)

Đề §3: sai lệch Figma ↔ app **không ghi** = lỗi. Hiện còn D1–D4 chưa cập
nhật (đã ghi ở `docs/design-traceability.md` §5). Sửa 4 frame đó cho khớp.

### 5.6 Mở pull request và nộp (10 phút)

```bash
git push origin feature/lab3-complete-gaps
gh pr create --base main --title "Lab 3: Firebase + ARTEMIS + AI code review"
```

---

## 6. Danh sách kiểm tra bài nộp (theo đề §11)

| # | Mục | Trạng thái |
|---|---|---|
| 1 | Topic và API được giảng viên duyệt | ☐ cần xác nhận |
| 2 | `design-traceability.md` + `architecture.md` viết **trước** khi làm feature | ✅ có |
| 3 | Quy tắc MVVM + design system giữ xuyên suốt | ✅ `Layers OK` |
| 4 | Tất cả màn Lab 2 đều được trace | ✅ 25/25 |
| 5 | Cả 6 dịch vụ Firebase chạy, mỗi cái có ca lỗi | ✅ code · ❌ chưa có ảnh |
| 6 | Storage rules giới hạn mỗi user ở thư mục riêng | ✅ 21/21 test |
| 7 | Analytics event plan viết; **mọi event thấy trong DebugView** | ✅ code 10 event · ❌ chưa có ảnh |
| 8 | Crashlytics có non-fatal + test crash + custom key | ✅ code · ❌ chưa có ảnh |
| 9 | **2** giá trị Remote Config đổi app không cần build | ✅ code · ❌ chưa có ảnh |
| 10 | Test plan ≥ 10 ca, có error path + native + exploratory | ✅ 18 + 1 |
| 11 | **ARTEMIS chạy ≥ 3 lần/ca**, có trace + bảng pass rate | ❌ **chưa chạy** |
| 12 | ≥ 5 finding có quyết định; ≥ 3 fix trong commit | ✅ 10 / 5 |
| 13 | Không commit bí mật | ✅ `.gitignore` |
| 14 | README liệt kê phiên bản, công cụ AI, link video | ⚠️ thiếu link video |
| 15 | Repo, report, slides, video mở được ở cửa sổ ẩn danh | ☐ cần kiểm cuối |

---

## 7. Môi trường đã xác minh

| Công cụ | Phiên bản | Ghi chú |
|---|---|---|
| Flutter | 3.47 | `pubspec.yaml` đã ghim phiên bản package |
| Dart | 3.13.7 | |
| Python | 3.11.9 | `artemis-client` cần ≥ 3.10 — OK |
| Firebase CLI | 15.35.0 | **chạy qua `npx firebase-tools@15.35.0`** (chưa cài global) |
| ARTEMIS | `351ca842` | ghim trong `e2e_test/pyproject.toml` |
| FlutterFire CLI | 1.4.x | `dart pub global activate flutterfire_cli` — **chưa cài** |
| Chrome/Edge | — | dùng để in PDF |

Lệnh kiểm chứng lại toàn bộ:

```bash
flutter analyze
flutter test
bash tool/check_layers.sh          # Git Bash: "C:\Program Files\Git\bin\bash.exe"
npx firebase-tools@15.35.0 emulators:exec --only firestore \
    --project demo-teamup-data "node --test firestore.rules.test.mjs"
cd e2e_test && pytest --collect-only -q
python tool/build_report.py --student-id group6
```

---

## 8. Câu hỏi cần thành viên trong nhóm chốt

1. **Project ID Firebase nào là thật?** `prm-lab3-cc39e` hay `teamup-exe-group6`?
   (chặn bước 5.1 → 5.3)
2. **Ai có máy Android thật để chạy ARTEMIS + quay video?** Cần tối thiểu 1 máy
   có Google Play và tài khoản Google test.
3. **MSSV của từng thành viên** để đặt tên file `report/Lab03_<MSSV>.pdf` và
   `slides/Lab03_<MSSV>_slides.pdf` đúng quy định.
4. **Link video demo** — ai upload, đăng ở đâu (không để public nếu đề yêu cầu
   "private browser window").
5. **Figma file** — ai có quyền sửa 4 frame D1–D4.
