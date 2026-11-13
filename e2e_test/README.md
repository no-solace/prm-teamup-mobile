# ARTEMIS end-to-end suite (Lab 3 §7)

Bộ test end-to-end tự động dùng **Google ARTEMIS** điều khiển thiết bị
Android thật (hoặc emulator) theo hướng dẫn bằng ngôn ngữ tự nhiên.

## 1. Yêu cầu

| Thành phần | Phiên bản / ghi chú |
|---|---|
| Python | **3.10+** (khuyến nghị 3.12) |
| ARTEMIS daemon | commit `351ca8422f7b5b54e80a9c1ce03a222e02415b6b` (pinned trong `pyproject.toml`) |
| ARTEMIS client SDK | `artemis-client` — gói con trong repo ARTEMIS, dùng `subdirectory=packages/artemis-client` |
| ADB | ARTEMIS start script cài sẵn; cần `adb devices` thấy thiết bị |
| Model API key | Gemini / Claude / GPT-4o / Qwen-VL |
| ARTEMIS host | mặc định `http://127.0.0.1:8000` |

> **Lưu ý về kiến trúc.** `artemis-client` là client **remote-only**: nó gọi
> HTTP tới một ARTEMIS daemon, không import ADB hay LLM provider. Vì vậy
> `pytest --collect-only` chạy được trên máy không có thiết bị, và lỗi khi
> không có daemon là `NetworkError` rõ ràng chứ không phải lỗi import.

## 2. Cài đặt

```bash
cd e2e_test
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -e ".[artemis]"
```

Biến môi trường (không commit):

```bash
export ARTEMIS_API_KEY=<model api key>
export ARTEMIS_DEVICE=emulator-5554      # serial từ `adb devices`
export ARTEMIS_PROFILE=flash              # flash: regression, pro: exploratory
export ARTEMIS_BASE_URL=http://127.0.0.1:8000   # ARTEMIS host
export ARTEMIS_TOKEN=<token>              # chỉ khi host yêu cầu Bearer token
```

Tài khoản Google dùng để test được cấu hình sẵn trên thiết bị; **không** đưa
thông tin đăng nhập vào repo này.

## 3. Khởi động ARTEMIS host

Theo README chính thức của ARTEMIS:

```bash
git clone https://github.com/google/artemis.git
cd artemis
uv sync
uv run artemis start            # daemon lắng nghe 127.0.0.1:8000
```

Kiểm tra daemon còn sống:

```bash
curl http://127.0.0.1:8000/api/status
```

## 4. Chạy

```bash
# Toàn bộ regression (Flash profile)
pytest -m "not exploratory" -v

# Chạy lại một nhóm
pytest test_auth.py

# Phiên khám phá (Pro profile, 15–30 phút, không kịch bản)
ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory
```

## 5. Quy tắc viết test (theo Lab 3 §7)

1. **Một test = một chỉ dẫn**. Chỉ dẫn nêu rõ: điểm bắt đầu, các bước, và
   **điều gì phải hiển thị ở cuối**.
2. **Không chỉ kiểm `status == "SUCCESS"`**. Mỗi test yêu cầu agent trả về
   **giá trị** nó nhìn thấy (số thẻ đề xuất, tên nhóm, giá trị Remote Config,
   số KB, số hàng…) và so sánh với giá trị mong đợi — xem `Observed.number()` và
   `Observed.contains()` trong `conftest.py`.
3. **Test không phụ thuộc thứ tự**: mỗi test nêu precondition của riêng nó.
4. Chạy **mỗi test ít nhất 3 lần** và báo cáo pass rate (bảng trong
   `docs/test-plan.md`).
5. Test có native interaction: TC-01 (Google account picker), TC-16 (notification
   shade), TC-18 (Crashlytics test crash).

## 6. Semantics labels

ARTEMIS đọc cây accessibility trước rồi mới dùng ảnh. Vì vậy các widget chính
đã có `Semantics`:

| Widget | Nhãn |
|---|---|
| `AppButton` | nhãn nút + trạng thái disabled |
| `StudentRow` | "Student: {tên}, {ngành}" (+ ", in a team" nếu bị khoá) |
| `MajorSlot` | "Member, SE" / "Proposed member, AI" / "Open slot" |
| `ErrorBanner` | "Error: {message}" (liveRegion) |
| `StatusView` | tiêu đề + message + action |
| `AppCard` | `semanticsLabel` tuỳ màn (S5, S9) |
| `ProposalsBadge` | "{n} pending proposals" |

Thêm nhãn mới = sửa widget trong `lib/widgets/`, không sửa test.

## 7. Bằng chứng

* Screenshot / trace của mỗi lần chạy: `evidence/artemis/`.
* Báo cáo phiên khám phá: `evidence/artemis/exploratory/`.
* Bảng kết quả (test ID, số lần chạy, pass rate, thời gian trung bình):
  `docs/test-plan.md` §6.
