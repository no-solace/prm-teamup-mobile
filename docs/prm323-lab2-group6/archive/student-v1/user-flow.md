# Information Architecture và User Flows

## 1. Screen inventory (10 màn hình)

| ID | Màn hình | Cấp | Mô tả ngắn |
|---|---|---|---|
| S1 | Onboarding + nhập email | Ngoài thanh điều hướng | Giới thiệu và đăng nhập bằng email bất kỳ (ví dụ Gmail), nhận mã xác nhận 6 số |
| S2 | Create profile | Ngoài thanh điều hướng | Ngành, kỳ, kỹ năng, vai trò muốn làm, lịch rảnh |
| S3 | Discover | Tab 1 (top-level) | Danh sách nhóm đang thiếu vai trò, có bộ lọc |
| S4 | Team detail | Lồng trong S3 | Ý tưởng, thành viên, slot vai trò còn trống, nút Request to join |
| S5 | Student detail | Lồng trong S3 / S8 | Hồ sơ một sinh viên, nút Invite |
| S6 | Create team | Lồng trong S8 | Đăng ý tưởng và chọn các vai trò cần tuyển |
| S7 | Invitations | Tab 3 (top-level) | Tab Received / Sent, Accept / Decline / Hoàn tác |
| S8 | My team | Tab 2 (top-level) | Tiến độ đủ người (ví dụ 1/5), vai trò còn thiếu |
| S9 | Chat | Lồng trong S8 | Trò chuyện nhóm |
| S10 | Profile | Tab 4 (top-level) | Hồ sơ cá nhân, chỉnh sửa |

Dialog (xác nhận gửi yêu cầu, xác nhận gửi lời mời, xác nhận rời nhóm) và các state (loading, empty, error) **không** tính là màn hình riêng.

## 2. Cấu trúc điều hướng

```text
S1 Onboarding  ->  S2 Create profile  ->  [Bottom navigation]
                                            |- Tab Discover (S3)     -> S4 Team detail -> S5 Student detail
                                            |- Tab Team (S8)         -> S6 Create team, S9 Chat, S5
                                            |- Tab Invitations (S7)
                                            |- Tab Profile (S10)
```

Bottom navigation có 4 destination: Discover, Team, Invitations, Profile.

## 3. Ba user flow

Mỗi flow có điểm bắt đầu (START), đích (GOAL/END), happy path (đường chính, mũi tên liền) và nhánh thay thế (đường đứt nét, ô đỏ). Chú thích: ô xanh lá bo tròn là điểm đầu/cuối, ô xanh dương viền đậm là màn hình, ô trắng là hành động, hình thoi vàng là điều kiện, ô tím là dialog, ô đỏ nét đứt là lỗi/phục hồi.

### Flow A - Onboarding và tạo hồ sơ
Nhánh lỗi/phục hồi: email sai định dạng, thiếu trường bắt buộc, mất mạng khi lưu (giữ dữ liệu, có nút Thử lại).

Ghi chú nghiệp vụ: nhà trường không còn cấp email `@fpt.edu.vn` cho sinh viên (theo sinh viên làm bài; chưa xác minh độc lập), nên app không kiểm tra tên miền. Việc xác minh người dùng là sinh viên FPT (mã sinh viên, đăng nhập Google của trường...) nằm ngoài phạm vi lab và không có trong 10 màn hình.

![Flow A](../assets/flows/flow-a.png)

### Flow B - Tìm nhóm và xin tham gia
Nhánh lỗi/phục hồi: không có kết quả (empty state), nhóm vừa đủ người (gợi ý nhóm khác), hoàn tác yêu cầu trong 5 giây.

![Flow B](../assets/flows/flow-b.png)

### Flow C - Trưởng nhóm tạo nhóm, mời và nhận phản hồi
Nhánh lỗi/phục hồi: thiếu thông tin khi tạo nhóm, ứng viên từ chối hoặc lời mời hết hạn (gợi ý ứng viên khác).

![Flow C](../assets/flows/flow-c.png)

File nguồn chỉnh sửa được: `assets/flows/flow-a.drawio`, `flow-b.drawio`, `flow-c.drawio` (mở bằng app.diagrams.net).

## 4. Bảng flow -> màn hình

| Flow | Mục tiêu | Màn hình sử dụng | Có nhánh lỗi/phục hồi |
|---|---|---|---|
| A | Tạo hồ sơ xong | S1, S2, S10, S3 | Có (3 nhánh) |
| B | Gửi yêu cầu tham gia nhóm | S3, S4, S7 | Có (3 nhánh) |
| C | Ghép đủ vai trò cho nhóm của mình | S8, S6, S5, S7, S9 | Có (2 nhánh) |

## 5. Kiểm tra độ phủ

| Màn hình | Flow dùng |
|---|---|
| S1 | A |
| S2 | A |
| S3 | A, B |
| S4 | B |
| S5 | C |
| S6 | C |
| S7 | B, C |
| S8 | C |
| S9 | C |
| S10 | A |

Mọi màn hình thuộc ít nhất một flow, và đều truy cập được từ bottom navigation hoặc từ màn hình cha.
