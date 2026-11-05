# AI critique 2 (Claude, trên 18 frame hướng mentor đã xuất sang Figma)

- Người review: Claude. Căn cứ: đọc trực tiếp file Figma (đếm chữ, cỡ chữ, kích thước, màu từng frame bằng script chỉ đọc) và xem ảnh chụp S4 và S17 sau khi sửa. Không xem ảnh của 16 frame còn lại, nên các nhận xét về hình ảnh chỉ áp dụng cho S4 và S17.
- Cơ sở: 10 heuristic của Nielsen, WCAG 2.1 (1.4.1, 1.4.3, 1.4.11), luật của lab (chữ ≥ 14 sp, 360 dp), persona Cô Lan (mentor, một tay, vài phút giữa các tiết).
- Ngày chạy: 07/10/2026. Prompt tôi gửi cho Claude (nguyên văn): `check các screen này, chỉ rõ lại cho tôi screen flow` rồi `tôi đã xóa page 1, hãy chỉnh sửa s4 và s17 cho phù hợp với đề`. `TODO` bổ sung nếu bạn hỏi lại bằng prompt khác.

| # | Màn | Phát hiện | Tiêu chí | Mức độ |
|---|---|---|---|---|
| 1 | S4 No team | Stitch tự thêm chữ không có trong prompt: banner "Unassigned students / Phase 1" kèm đoạn "These candidates are currently awaiting assignment into functional modules...", số "5 available" trên app bar và khối "Allocation balance / Target composition ratio suggests 2 technical candidates and 2 domain specialists...". Làm danh sách bị đẩy xuống và nói điều không đúng với dữ liệu. | H8 Aesthetic and minimalist design; H2 Match with real world; persona chỉ có vài phút | Cao |
| 2 | S17 Discard dialog | Màn nền của dialog là một "Proposal detail" sai: tiêu đề "EXE Startup Course", "AI Match 94%", "Generated yesterday", tên sinh viên Minh Tran / Anh Nguyen với vai "Product Lead", "Fullstack Engineer", "UI/UX Designer" (chữ 12 sp), "2 of 3 filled". Không khớp S10 là màn mà dialog mở ra. | H4 Consistency and standards; H1 Visibility of system status (người dùng thấy nhóm khác nhóm đang xét); lab 14 sp | Cao |
| 3 | S9 Proposals | Badge số "3" trên tab Proposals cỡ 10 sp, nhỏ hơn mức tối thiểu 14 sp. Đây là con số mentor cần thấy để biết có gì chờ duyệt. | WCAG 1.4.4 và luật 14 sp của lab; H1 | Trung bình |
| 4 | S2, S12, S13 (và mọi frame) | Frame S2, S12, S13 cao 884, 906, 884 thay vì 800 dp, và mọi frame ngoài rộng 390 dp bọc khung 360. Khi đưa vào Figma Final UI cần 360 × 800, chưa nói rõ phần nào cuộn. | Yêu cầu 360 × 800 của lab; H4 | Trung bình |
| 5 | Toàn bộ 18 frame | Tên layer là cả đoạn prompt ("Main Content Area: Exactly 3 tappable cards"). Người dựng Flutter không dò được màn nào là màn nào. | Khả năng bàn giao (handoff); H4 | Thấp |
| 6 | Mọi thẻ (S2, S5, S9) | Viền thẻ Hairline #D6D4CE trên nền trắng đo được 1.48:1. Đã tốt hơn bản đầu (1.07:1) nhưng vẫn yếu khi đọc ngoài hành lang sáng. Thẻ chạm được vẫn có tiêu đề, chip, hàng ngành nên không chỉ dựa vào viền. | WCAG 1.4.11 (cần đo lại trên ảnh Figma); persona đọc ngoài trời | Cần xác minh |
| 7 | 18 frame | Điểm tốt: không có từ cấm (lineup, roster, squad, board, capstone), không có tông xanh dương, chữ hầu hết ≥ 14 sp. Master prompt và danh sách từ cấm đã có tác dụng. | H4; luật của lab | Tích cực |

## Decision record cho critique 2

Cột quyết định và lý do được soạn giúp theo nội dung critique; cần đọc lại và sửa nếu không đúng ý. Trạng thái "Đã làm" là việc đã thực hiện trong Figma (7/10 và 11/10/2026).

| # | Phát hiện | Accepted / modified / rejected | Lý do của tôi | Trạng thái trong Figma |
|---|---|---|---|---|
| 1 | S4 chữ bịa | Accepted | Chữ không có trong dữ liệu làm mentor đọc sai (H8); màn chỉ cần danh sách và nút Match with AI. | Đã làm: xóa banner, "5 available" và khối "Allocation balance", ép khung về 800 dp (node 50:351) |
| 2 | S17 màn nền sai | Accepted | Dialog phải mở trên đúng màn S10 (H4). | Đã làm: thay nền bằng bản sao S10 Proposal detail, giữ dialog nguyên (node 50:1012) |
| 3 | S9 badge 10 sp | Accepted | Luật 14 sp của lab; con số này là thứ mentor cần thấy. | Đã làm: Final UI dựng lại từ code Stitch, kiểm 21 frame: 0 chữ dưới 14 sp (11/10/2026) |
| 4 | Chiều cao và chiều rộng frame | Accepted | Lab yêu cầu 360 x 800. | Đã làm: cả 21 frame Final UI đều 360 x 800 |
| 5 | Tên layer | Accepted | Dev Flutter cần dò được màn và nút khi bàn giao. | Đã làm: frame tên `Sxx · Tên màn`; layer tương tác tên `btn/...`, `row/...`, `app bar`, `nav/bottom` |
| 6 | Viền thẻ | Modified | Giữ #D6D4CE làm ngoại lệ: 1.48:1, chỉ để phân tách; thẻ chạm được luôn có tiêu đề và chip. | Đã đo từ mã màu (1.48:1); chưa đo lại trên ảnh ngoài trời |

## Bằng chứng cần lưu

- Ảnh S4 và S17 **trước** khi sửa: lấy từ Figma version history hoặc project Stitch, lưu vào `assets/stitch/` (`mentor-v2/s04-no-team/screen.png`, `mentor-v2/s17-discard-dialog/screen.png` (đã có sẵn: là output gốc của Stitch)). `TODO`
- Ảnh **sau** khi sửa: xuất từ Figma, lưu ở `assets/figma/03-final-ui/` (`s04-no-team.png`, `s17-discard-dialog.png`).
