# TeamUp EXE (PRM323 Lab 2)

**Chủ đề:** ứng dụng di động cho mentor/giảng viên môn EXE. AI gợi ý ghép sinh viên chưa có nhóm vào các nhóm đang thiếu 1-2 thành viên chuyên môn để mỗi nhóm khởi nghiệp nhỏ đạt 5-6 người, nhiều ngành; mentor duyệt.

**Persona (1 dòng):** Cô Lan, 38 tuổi, giảng viên và mentor phụ trách 3 lớp EXE, dùng điện thoại một tay giữa các tiết, cần ghép nhóm xong trong dưới 5 phút mỗi lớp.

**GitHub:** https://github.com/Kenn0679/prm323-lab2-group6

**Figma:** https://www.figma.com/design/X5WcaK4s20AYF53cvRdouV/TeamUp-EXE---Mentor--PRM323-Lab-2-?node-id=2-6&t=VPIFaeqdEmKBzDex-1 (6 page theo đề; chế độ chia sẻ: ai có link cũng xem được).


**Công cụ AI đã dùng:** Claude (phân tích đề, persona, luồng, soạn DESIGN.md và prompt, phê bình ảnh Stitch, đọc và chỉnh Figma qua công cụ), Google Stitch (sinh UI), Figma (design system và prototype). Chi tiết ở `ai/ai-design-log.md`. Ghi chú: AI ghép nhóm trong lab chỉ là thiết kế giao diện với dữ liệu mẫu, không có mô hình thật.

## Bản đồ sản phẩm

| Sản phẩm | Ở đâu |
|---|---|
| Persona, vấn đề, tiêu chí thành công | `ux/persona.md` |
| IA, 3 user flow, bảng flow-màn | `ux/user-flow.md` (hình ở `assets/flows/`) |
| Design brief đưa cho Stitch | `design/DESIGN.md` |
| Mục đích và nội dung từng màn | `design/screen-spec.md` |
| 10 quyết định và checklist accessibility | `design/design-decisions.md` |
| Prompt, output, quyết định, iteration | `ai/ai-design-log.md` |
| Phê bình của AI (bản hướng sinh viên) | `ai/ai-critique-1.md` |
| Phê bình của AI (bản hướng mentor, 18 màn) | `ai/ai-critique-2.md` |
| Ảnh chụp mọi bản Stitch (`student-v1/` hướng đầu, `mentor-v2/` hướng cuối, 21 màn; S22-S25 chỉ có trong Figma) | `assets/stitch/` (mục lục ở `assets/stitch/README.md`) |
| PNG màn hình final xuất từ Figma | `assets/figma/` |
| Hướng dẫn dựng app Flutter | `handoff/flutter-handoff.md` |
| Nguồn và file slide (ppt-master) | `slides/` |

Thư mục `archive/` chứa hướng đầu tiên (app cho sinh viên) trước khi tôi đổi sang app cho mentor; đề không yêu cầu, giữ lại để chứng minh quá trình thiết kế.
