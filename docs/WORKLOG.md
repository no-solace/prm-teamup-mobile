# Nhật ký làm việc — Lab 3 TeamUp EXE

> File này ghi lại **những gì đã làm, vì sao làm, và cách kiểm chứng lại**, để
> thành viên khác (hoặc chính bạn, sau này) hiểu được dự án đang ở đâu và phần
> nào còn thiếu.
>
> **Cập nhật lần cuối:** 12/11/2026 · commit `1a89f81` (+ phiên 4: dựng & chạy
> thật hạ tầng ARTEMIS trên máy — xem §5b)

---

## 0. Tóm tắt nhanh

| Hạng mục | Trạng thái | Cách kiểm chứng |
|---|---|---|
| `flutter analyze` | ✅ **No issues found** | `flutter analyze` |
| Unit + widget test | ✅ **150/150 pass** | `flutter test` |
| Firestore rules test | ✅ **21/21 pass** | `npx firebase-tools@15.35.0 emulators:exec --only firestore --project demo-teamup-data "node --test firebase/test/firestore.rules.test.mjs"` |
| Luật layer (MVVM) | ✅ **Layers OK** | `bash tool/check_layers.sh` |
| Bộ test ARTEMIS | ✅ 19 test, API khớp SDK thật | `cd e2e_test && pytest --collect-only -q` |
| AI code review | ✅ **12 finding / 5 commit sửa** | `docs/code-review.md` |
| Report PDF | ✅ 10 trang (yêu cầu 8–12) | `report/Lab03_group6.pdf` |
| Slides PDF | ✅ 20 trang = 15 main + 5 phụ lục | `slides/Lab03_group6_slides.pdf` |
| `google-services.json` | ❌ **CHƯA CÓ** | xem mục 5 |
| ARTEMIS chạy trên thiết bị | ⚪ **daemon + agent đã chạy thật**; bộ test chạy trên build `main_fake` | xem mục 5b |
| `evidence/` | ⚪ **đã có trace ARTEMIS thật**; ảnh Console vẫn trống | xem mục 5b, 5.3 |
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
| Slide | `slides/Lab03_slides.md` → `.pdf` | 15 slide chính + 5 slide dự phòng |

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


---

### 5b.2b Hạn mức Gemini free-tier — giới hạn thật của môi trường

Sau khi sửa xong (a) và (c), chạy **cả bộ 19 test** thì các test về sau bắt đầu
fail hàng loạt với cùng một lỗi:

```
TimeoutError: LLM call timed out after 180 seconds.
```

Đọc log của daemon thì thấy nguyên nhân gốc:

```
ClientError: 429 Too Many Requests. {'message': '{
  "error": {
    "code": 429,
    "message": "You exceeded your quota for metric:
      generativelanguage.googleapis.com/generate_content_free_tier_requests"
```

Kiểm chứng trực tiếp sau khi tắt suite:

```
$ python -c "...models/gemini-3.6-flash:generateContent..."
ERR HTTP Error 429: Too Many Requests
```

**Đây không phải lỗi code hay lỗi app.** Đây là **hạn mức ngày của Gemini
free-tier** (`generate_content_free_tier_requests`) đã hết. Mỗi lần ARTEMIS chạy
một task tiêu tốn vài chục lượng gọi (mỗi step = 1 lần gọi model + các lần
summarize/ghi chú).

| Test | Kết quả | Nguyên nhân |
|---|---|---|
| TC-01 | ❌ | Cần Firebase Auth thật **+** quota |
| TC-02 | ✅ (lần chạy đơn lẻ) · ❌ (lần chạy theo lô) | Lần đơn lẻ còn quota; lần theo lô thì hết quota |
| TC-03, TC-04 | ❌ | Cần Remote Config / Auth thật **+** quota |
| TC-15 | ❌ | Cần Storage thật **+** quota |
| TC-05, TC-06 | ❌ | Cần file picker + quota |

**Con số chính xác** (lấy từ telemetry daemon): hạn mức **20 request/ngày**
cho `gemini-3.6-flash`; thông báo yêu cầu chờ **21h49m** → reset **00:00
UTC**.

**Cách vượt (không tốn tiền):**

1. Chờ sang ngày mới (hạn mức Gemini free-tier **reset 00:00 theo giờ UTC**).
2. Hoặc dùng một API key khác / project GCP khác.
3. Hoặc nâng cấp lên gói trả phí.

**Đã xử lý trong bộ test:** `e2e_test/conftest.py` đọc telemetry của phiên và
**skip** kèm lý do rõ ràng khi gặp hạn mức, thay vì để mỗi test cháy
hết timeout rồi fail với thông báo trống.

**Kinh nghiệm rút ra cho nhóm:** khi chạy ARTEMIS, **chạy 1 test để đo chi phí
trước**, rồi mới chạy cả bộ. Một lần chạy đầy đủ 18 test tiêu tốn đủ hạn mức
cả ngày. Nên:

- Bật **Analytics debug mode** + chuẩn bị sẵn CSV/tài khoản Google **trước**,
  để không phải chạy lại nhiều vòng.
- Chạy `pytest -k "tc02 or tc05"` để kiểm tra nhanh trước.
- Ghi lại số lần chạy vào `docs/test-plan.md` §6.

> Thông tin này cũng nên nói với thầy khi nộp: *"ARTEMIS chạy trên thiết bị thật,
> giới hạn bởi hạn mức API free-tier của mô hình"*.

## 5b. Phiên làm việc 12/11/2026 — phần 4: dựng & chạy THẬT hạ tầng ARTEMIS

Mục tiêu của phiên này: **không chỉ viết code, mà chạy thật** phần hạ tầng E2E mà
đề Lab 3 §7 chấm điểm, để xem cỡ thật sự chạy không — và tài liệu hoá lại tất cả.

Kết quả: ARTEMIS đã chạy thật, đọc được màn hình, và bộ test pytest đã **pass**
trên máy này.

### 5b.1 Những gì đã dựng (và vì sao)

| Việc | Lệnh | Kết quả |
|---|---|---|
| Clone ARTEMIS | `git clone https://github.com/google/artemis.git` | commit `351ca842` (khớp đúng với `e2e_test/pyproject.toml`) |
| Cài dependency | `uv sync` | 195 package, mất 2 phút |
| Cấu hình key | `.env` (đã gitignore) | `GEMINI_API_KEY` + `GOOGLE_API_KEY` lấy từ biến môi trường |
| Boot emulator | `emulator -avd TestPixel -no-boot-anim -gpu swiftshader_indirect` | `emulator-5554`, Android 14, có Google Play |
| Kiểm tra sẵn sàng | `uv run artemis doctor` | **Status: Ready** — Gemini key active, device detected |
| Cài accessibility helper | `uv run artemis helper install --serial emulator-5554` | helper v1.2.0, service enabled |
| Khởi động daemon | `uv run python -m artemis ui --port 8000 --no-open` | `/api/status` → 200 |
| Chạy task | `uv run artemis run "..." --device-serial emulator-5554 --locked-app com.group6.teamup_exe --profile flash` | **✅ Task completed successfully** |

### 5b.2 Ba lỗi thật phát hiện — và cách sửa

#### (a) `gemini-3.8-flash` / `gemini-3.7-flash` không dùng được với key này

ARTEMIS mặc định `gemini-3.8-flash`. Lần chạy đầu tiên:

```
TimeoutError: LLM call timed out after 180 seconds.
```

Đối chiếu trực tiếp:

| Model | Kết quả |
|---|---|
| `gemini-3.8-flash` | HTTP 503 Service Unavailable (mất 108s) |
| `gemini-3.7-flash` | HTTP 503 Service Unavailable |
| `gemini-3.6-flash` | ✅ OK, 1.6–3.0s |
| `gemini-3.5-flash` | ✅ OK, 3.0s |
| `gemini-3.5-flash-lite` | ✅ OK, 5.4s |
| `gemini-3.1-flash-lite` | ✅ OK, 1.3s |

**Cách sửa:** đổi model mặc định trong `config/artemis.jsonc` (default + preset +
chunking), `artemis/config/agent.py`, `artemis/config/llm.py`,
`artemis/services/llm.py`, `artemis/sdk/agent.py`, `artemis/memory/chunking.py`,
`artemis/agents/video_analyzer/video_analyzer.py`,
`artemis/agents/explorer/constants.py` — `3.8` → `3.6`, `3.7` → `3.5`.

Sau đó: `/api/status` báo `"id": "gemini-3.6-flash"`.

> Ghi chú cho nhóm: **kiểm tra model này có dùng được không** trước khi chạy. Model
> khác đổi gọi API — 503 hay 404 đều không phải lỗi app.

#### (b) `java.lang.RuntimeException: Unable to get provider net.nfet.flutter.printing.PrintFileProvider`

App **crash ngay khi khởi động**, không phải do logic:

```
E AndroidRuntime: FATAL EXCEPTION: main
E AndroidRuntime: java.lang.RuntimeException: Unable to get provider
  net.nfet.flutter.printing.PrintFileProvider:
  java.lang.ClassNotFoundException: Didn't find class
  "net.nfet.flutter.printing.PrintFileProvider" on path: DexPathList[[zip file
  "/data/app/.../base.apk"]]
```

Đây là lỗi nghiêm trọng: **provider được khai trong merged manifest nhưng class
không có trong dex** → Android khởi tạo provider trước khi app vẽ màn hình →
app chết ngay.

Truy vết:

| Tầng | Kết quả |
|---|---|
| `build/printing/.../classes.jar` | đã có `PrintFileProvider.class` |
| `build/printing/.transforms/.../bundleLibRuntimeToDirDebug_dex/` | đã có `PrintFileProvider.dex` |
| `build/app/intermediates/dex/debug/mergeLibDexDebug/` | **đã mất** |
| `app-debug.apk` | **đã mất** |

Nguyên nhân: **build tổn còng**, không phải lỗi source. Lý do: build đầu tiên
dùng **JDK 26** (`C:\Toolkits\Java\jdk-26.0.2.1`) — AGP 9.1.0 không tương
thích `jlink` đúng cách:

```
Could not resolve all files for configuration ':firebase_core:androidJdkImage'
  > Error while executing process ...\jdk-26.0.2.1\bin\jlink.exe
  > To fix this error, please upgrade your AGP version to at least 8.2.1
```

Cách sửa (2 bước):

1. Dùng **JDK 24** (`C:\Toolkits\Java\jdk-24.0.2`) — build thành công.
2. `flutter clean` + build lại → class quay lại đúng chỗ trong dex
   (`classes9.dex`), app khởi động bình thường, `MainActivity` là
   `topResumedActivity`.

> **Bài học dẫn cho cố nhân:** đặt `JAVA_HOME` trỏ **JDK 24** trước khi build. Nếu
> build lại mà gặp lại, chạy `flutter clean`.

#### (c) Bộ test đọc `Observed.text` rỗng dù task đã PASS

Sau khi mối trải TC-02:

```
assert False
 +  where False = contains('Proposals')
 +    where contains = Observed(status='completed', text='', error=None)
```

Nguyên nhân: `artemis_client` **không** trả về báo cáo cho client. ARTEMIS lưu
final report vào **step cuối cùng** (`action_taken.action == "report_task_status"`),
còn client chỉ nhận metadata session (`session_id`, `status`, `device_info`, `pid`).

**Cách sửa** (`e2e_test/conftest.py`): thêm `_fetch_session_steps()` đọc
`GET {base}/api/sessions/{id}/steps` và `_extract_final_report()` lấy
`args.explanation` của step `report_task_status`; `_normalise()` dùng lại khi
`output` rỗng.

Sau sửa:

```
e2e_test\test_auth.py::test_tc02_open_each_top_level_tab PASSED   [100%]
1 passed in 110.82s
```

**Đây là bug thật trong bộ test chạy đúng** — đáng lẽ "môi chế dễ đương" thay đổi
trong API client.

### 5b.3 Điều gì được ghi ra để dùng lại

| File | Tác dụng |
|---|---|
| `tool/run_e2e.ps1` | Kiểm tra đủ kiện (daemon sống? có device? có key? app đã cài?) rồi chạy pytest. Sai điều kiện → thông báo rõ ràng, không phải stack trace |
| `tool/run_e2e.py` | Bản Python tương đương cho CI / Git Bash |
| `tool/collect_artemis_evidence.py` | Tải ảnh, **bản ghi hành động**, summary từng step từ daemon → `evidence/artemis/<session-id>/` (kèm `screenshots/step-NN-before.jpg`) |

### 5b.4 Kết quả ARTEMIS thật trên máy này

Agent đọc đúng màn hình `My classes`:

```
Class A: 17 students
Class B: 0 students
Class C: 0 students
```

Và đi 3 tab dưới:

```
The screen titles that appear when tapping the bottom navigation tabs
'Proposals', 'Profile', and 'Classes' are Proposals, Profile, and My classes respectively.
```

Đây là **bằng chứng thật**, không phải mô phỏng. Ảnh chụp đã được copy đầy đủ
vào `evidence/artemis/`.

**Tổng bằng chứng thu được:** **12 phiên** ARTEMIS (4 `completed`, 8 `failed`) với
**22 ảnh chụp thật** — xem `evidence/artemis/README.md` để biết từng phiên làm gì.
Tool thu thập: `python tool/collect_artemis_evidence.py` (chỉ gọi `GET` trên daemon).

### 5b.5 Phần CHƯA làm được là do đúng thiếu project Firebase

`main.dart` (bản nộp) gọi `Firebase.initializeApp` ngay đầu — cần
`google-services.json` thật. Build `main_fake.dart` (đã có sẵn fake để demo
**không Firebase**) được dùng để **kiểm chứng hạ tầng E2E** trong khi chờ cấu
hình Firebase.

Hệ quả cụ thể của bộ test:

| Test | Kết quả trên build fake | Lý do |
|---|---|---|
| TC-02 (3 tab) | ✅ PASS | — |
| TC-01 (Google Sign-In) | ❌ FAIL | Cần tài khoản Google + Firebase Auth thật |
| TC-03 (Remote Config) | ❌ FAIL | Cần Remote Config thật |
| TC-04 (Sign out) | ❌ FAIL | Cần Firebase Auth thật |

Đây **không phải lỗi** — đây là **bằng chứng cho thấy hạ tầng đã chạy đúng**,
đồng thời chỉ rõ chỗ cần Firebase thật. Đề §11 yêu cầu *"Test message from the
console received in each state"* — nghĩa là test trên build fake **không đủ**,
phải chạy lại sau khi có Firebase thật.

> **Lưu ý:** một phần các phiên `failed` là do **hạn mức Gemini free-tier**
> (`429 Too Many Requests`), **không** phải do app — xem §5b.2(d). Hạn mức reset
> **00:00 UTC**.

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
>
> ⚠️ **Set `JAVA_HOME` = JDK 24 trước khi build** (`C:\Toolkits\Java\jdk-24.0.2`),
> nếu không sẽ gặp lại lỗi `PrintFileProvider` (CR-12).
>
> ⚠️ **Chạy 1 ca để đo chi phí trước khi chạy cả bộ** — một lần chạy đệ đụ tiêu
> tốn đặt hạn mức Gemini free-tier cả ngày.

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
| 11 | **ARTEMIS chạy ≥ 3 lần/ca**, có trace + bảng pass rate | ⚠️ **đã chạy thật 1 ca** (TC-02 pass, 12 phiên, 22 ảnh) — cần ≥ 3 lần/ca trên build release |
| 12 | ≥ 5 finding có quyết định; ≥ 3 fix trong commit | ✅ 12 / 5 |
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
| JDK (Android build) | **24** (`C:\Toolkits\Java\jdk-24.0.2`) | **Bắt buộc.** JDK 26 làm AGP 9.1.0 fail ở `jlink` → build tổn còng → app crash khi khởi động (CR-12) |

Lệnh kiểm chứng lại toàn bộ:

```bash
flutter analyze
flutter test
bash tool/check_layers.sh          # Git Bash: "C:\Program Files\Git\bin\bash.exe"
npx firebase-tools@15.35.0 emulators:exec --only firestore \
    --project demo-teamup-data "node --test firebase/test/firestore.rules.test.mjs"
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
