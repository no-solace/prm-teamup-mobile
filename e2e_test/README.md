# ARTEMIS end-to-end suite (Lab 3 §7)

Bộ test end-to-end tự động dùng **Google ARTEMIS** điều khiển thiết bị
Android thật (hoặc emulator) theo hướng dẫn bằng ngôn ngữ tự nhiên.

## 1. Yêu cầu

| Thành phần | Phiên bản / ghi chú |
|---|---|
| Python | 3.12+ |
| `uv` | theo hướng dẫn chính thức của ARTEMIS |
| ADB | ARTEMIS start script cài sẵn; cần `adb devices` thấy thiết bị |
| ARTEMIS | commit đã ghim — xem `pyproject.toml` và `README.md` |
| Model API key | Gemini / Claude / GPT-4o / Qwen-VL |

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
```

Tài khoản Google dùng để test được cấu hình sẵn trên thiết bị; **không** đưa
thông tin đăng nhập vào repo này.

## 3. Chạy

```bash
# Toàn bộ regression (Flash profile)
pytest -m "not exploratory"

# Chạy lại một nhóm
pytest test_auth.py

# Phiên khám phá (Pro profile, 15–30 phút, không kịch bản)
ARTEMIS_PROFILE=pro pytest test_exploratory.py -s -m exploratory
```

## 4. Quy tắc viết test (theo Lab 3 §7)

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

## 5. Semantics labels

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

## 6. Bằng chứng

* Screenshot / trace của mỗi lần chạy: `evidence/artemis/`.
* Báo cáo phiên khám phá: `evidence/artemis/exploratory/`.
* Bảng kết quả (test ID, số lần chạy, pass rate, thời gian trung bình):
  `docs/test-plan.md` §6.
