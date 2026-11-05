# Design decisions

> Bản nháp để bạn sửa bằng lời của mình trước khi nộp. Mỗi quyết định ghi rõ nguồn gốc (AI đề xuất hay tôi tự quyết) và liên kết với `ai/ai-design-log.md`. Đừng nộp nguyên văn nếu lý do không phải của bạn.

## 10 quyết định quan trọng nhất

| # | Quyết định | Lý do | Nguồn | Thể hiện trong UI |
|---|---|---|---|---|
| 1 | Người dùng chính là mentor/giảng viên, không phải sinh viên | Mentor chịu trách nhiệm cuối về nhóm của lớp và có nhiều sinh viên chưa có nhóm hoặc nhóm thiếu chuyên môn; công cụ ghép tập trung giúp tiết kiệm thời gian hơn để từng sinh viên tự tìm | Tôi quyết định (R8, log mục 6 dòng 10) | Toàn bộ 18 màn |
| 2 | AI chỉ đề xuất, mentor duyệt; mỗi đề xuất có nhãn mức phù hợp và lý do ngắn | Heuristic H3 (quyền kiểm soát của người dùng) và nhu cầu hiểu lý do của persona Cô Lan | AI gợi ý, tôi giữ | S9, S10, S12 |
| 3 | Bỏ hẳn màu xanh dương, dùng cam đậm làm màu hành động, xanh lá cho "đã có người" | Bản đầu giống giao diện sinh tự động; tôi đo thẻ so với nền chỉ 1.07:1 | Tôi tự phát hiện (log dòng 9) | Mọi màn, trang Variables |
| 4 | Hàng ngành (major row) làm thành phần đặc trưng: ô đầy, ô trống nét đứt, ô đề xuất có dấu + | Mentor cần thấy nhóm thiếu ngành nào trong 2 giây; trạng thái mang bằng hình dạng, biểu tượng và chữ | AI đề xuất, tôi chỉnh | S5, S9, S10 |
| 5 | Không có chú thích dưới ô ngành | Chữ chồng nhau ở 360 dp (lỗi ở bản đầu) | Tôi phát hiện từ ảnh Stitch | S5, S9, S10 |
| 6 | Mỗi màn tối đa 1 nút chính (filled) | Phân cấp rõ, heuristic H8 | AI đề xuất, tôi giữ | Mọi màn có hành động |
| 7 | Giảm chữ: tiêu đề tối đa 3 từ, nút tối đa 3 từ, không câu hướng dẫn | Mentor dùng một tay giữa các tiết, chỉ có vài phút | Tôi yêu cầu | Mọi màn |
| 8 | Đăng nhập bằng email bất kỳ, không bắt buộc email edu và không có trường MSSV | Từ khóa của tôi không còn email edu; xác minh sinh viên ngoài phạm vi lab | Tôi tự phát hiện (log dòng 8) | S1 |
| 9 | Thanh điều hướng 3 tab: Classes, Proposals, Profile | Ba đích đến cấp cao đủ cho các tác vụ chính của mentor | AI đề xuất, tôi duyệt | S2, S6, S9 |
| 10 | Dialog xác nhận cho Approve, dialog đỏ cho Discard, cả hai không nằm ngoài luồng | Hành động Discard khó hoàn tác nên cần xác nhận; Approve gửi thông báo cho sinh viên | AI đề xuất, tôi giữ | S12, S17 |

## Quyết định chưa áp dụng (từ chối)

| Đề xuất | Lý do từ chối |
|---|---|
| Dùng màu cam FPT #F37021 cho nút | Chữ trắng trên cam chỉ 2.9:1, không đạt 4.5:1; chỉ dùng cho logo |
| Giao diện riêng cho sinh viên | Vượt phạm vi lab; sinh viên là dữ liệu |

## Checklist accessibility và responsive

Kết quả của từng mục. Số đo là tính từ mã màu trong `DESIGN.md` (công thức WCAG 2.x). Mục nào chưa kiểm trong Figma thì ghi `TODO`, đừng tick khi chưa kiểm.

| Mục | Kết quả | Ghi chú |
|---|---|---|
| Chữ thường ≥ 4.5:1 | Đạt | on-surface/surface 17.22; on-surface-variant/surface 7.69; on-primary/primary 5.86; on-primary-container/primary-container 13.27; on-tertiary-container/tertiary-container 12.0; error/error-container 5.14; on-secondary-container/secondary-container 13.94; trắng/error 6.54; trắng/snackbar 13.59 |
| Chữ lớn và control ≥ 3:1 | Đạt một phần | outline/surface 4.61 (viền ô nhập, ô trống nét đứt); tertiary/surface 6.53; primary/primary-container 4.76 (viền ô đề xuất). **Ngoại lệ:** viền thẻ Hairline #D6D4CE chỉ 1.48:1, dùng để phân tách chứ không phải viền điều khiển; thẻ chạm được luôn có tiêu đề và chip kèm theo. Đã cải thiện từ 1.07:1 ở bản đầu. |
| Touch target ≥ 48 x 48 dp | Đạt một phần | Button, text field, thanh điều hướng ở Page 05 và các vùng chạm của prototype (hotspot) đều ≥ 48 dp. Chip trong Final UI cao 36 dp, vùng chạm 48 dp chỉ được đặc tả trong handoff; chưa đo từng layer. |
| Chữ thân ≥ 14 sp | Đạt | Kiểm 21 frame Final UI trong Figma bằng script (11/10/2026): 0 chữ nhỏ hơn 14 sp, mọi chữ dùng text style. Badge S9 10 sp và chữ 12 sp của S17 cũ không còn |
| Không truyền thông tin chỉ bằng màu | Đạt theo thiết kế | Ô đầy/trống/đề xuất khác nhau về hình dạng và biểu tượng; chip fit có biểu tượng + chữ; lỗi có biểu tượng + chữ |
| Auto Layout, kiểm ở 360 và 412 dp | Đạt một phần; `TODO` 412 dp | 14 component set ở Page 05 dùng Auto Layout; Final UI là khung 360 x 800 cố định. Chưa kiểm ở 412 dp |
| Mô tả màn rộng (≥ 600 dp) | Đạt | `handoff/flutter-handoff.md`, mục "Màn rộng" |
| Màn cao hơn 800 dp | Đạt | Bản xuất Stitch từng có S2, S12, S13 cao 884, 906, 884; trong Figma hiện cả 21 frame Final UI đều 360 x 800 (kiểm bằng script) |
