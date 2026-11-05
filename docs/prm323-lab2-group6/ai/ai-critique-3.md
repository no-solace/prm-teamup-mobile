# AI critique 3 (Claude, phản biện `ux/persona.md` theo persona-guideline)

- Người review: Claude, đóng vai người phản biện. Căn cứ: yêu cầu nghiệp vụ của tôi (đóng vai mentor) và tài liệu `persona-guideline` của môn (https://prm393-material.web.app/persona-guideline): 12 trường lõi, checklist 10 mục (100 điểm), quy tắc số persona, nhãn Observed/Reported/Inferred/Assumed.
- Ngày chạy: 13/10/2026. Prompt tôi gửi cho Claude (nguyên văn):
  1. `Đứng trên cương vị là 1 người mentor tôi expect là, app này là app được tôi import danh sách sinh viên, cho rằng sẽ có mssv, classname, group, major... sẽ filter và tự động filter những học sinh đã có đủ nhóm hoặc danh sách thành viên, tối đa cho 6 thành viên 1 nhóm, min là 5. hãy phân tích file persona hiện tại xem đã đủ chưa. Bạn sẽ là người phản biện lại file đó dựa trên các tiêu chí trên và sau:https://prm393-material.web.app/persona-guideline`
  2. `hãy bổ sung các tiêu chí còn thiếu, log quá trình phản biện này vào log`
- Phạm vi: chỉ đọc `ux/persona.md` và `design/screen-spec.md` trước khi sửa; phần còn lại của repo và Figma chưa đối chiếu hết khi phản biện (xem mục "Chưa làm").
- Lưu ý trung thực: điểm bên dưới là **ước lượng của Claude**, không phải điểm của giảng viên; các dòng "Reported" chỉ là yêu cầu do tôi nêu, không phải phỏng vấn người dùng thật.

## 1. Phát hiện chính

| # | Phát hiện | Tiêu chí | Mức độ |
|---|---|---|---|
| 1 | Persona ghi nhóm **4-6**; yêu cầu thật là **tối thiểu 5, tối đa 6**. Số 4-6 còn ở README, DESIGN.md, slide, log. | Đúng yêu cầu nghiệp vụ | Cao |
| 2 | Persona không nhắc **import** và các cột MSSV, Class name, Group, Major; còn ghi "xác minh sinh viên ngoài phạm vi". | Constraints, Evidence | Cao |
| 3 | Tự lọc sinh viên đã có nhóm và nhóm đã đủ 6 chỉ ngầm có ở S16; persona chưa nêu thành nhu cầu hay tiêu chí thành công. | Pain, Success criteria | Cao |
| 4 | Persona nói AI ghép theo "ngành, kỹ năng, lịch rảnh", nhưng dữ liệu import **không có kỹ năng và lịch**. AI không thể ghép theo hai thứ đó. | Tính khả thi, giả định | Cao |
| 5 | Thiếu 5 trong 12 trường lõi: Priority, Job to Be Done, Motivations, Key Scenarios, Evidence & Status (Archetype và Current Behaviors chỉ có một phần). | 12 trường lõi | Cao (Critical) |
| 6 | Chỉ 1 persona và **không có giải trình** vì sao không có phân khúc khác; không có User/Stakeholder Map. | Số persona, Map | Trung bình |
| 7 | Không có Affinity Board, Coverage Matrix, Assumption & Research Backlog; không có bảng Persona → Need → UI → Test. | Đầu ra bắt buộc | Trung bình |
| 8 | "Giải pháp" lẫn tính năng với nhu cầu; pain (1) trộn tình huống và hậu quả; pain có 4 mục (guideline 2-3). | Nhu cầu là kết quả | Thấp |
| 9 | Tiêu chí "≥ 3 ngành mỗi nhóm" có thể không đạt khi lớp lệch ngành; chưa nêu cách xử lý. | Success criteria | Thấp |
| 10 | Điểm tốt cần giữ: bối cảnh hành vi cụ thể (một tay, wifi chập chờn), problem statement 1 câu, tiêu chí đo bằng thời gian, ghi rõ persona là giả định. | - | Điểm tốt |

## 2. Chấm theo checklist 10 mục (ước lượng, mỗi mục 10 điểm)

| # | Mục | Trước | Sau |
|---|---|---|---|
| 1 | Phạm vi, tác vụ, nhóm người dùng | 8 | 9 |
| 2 | User/Stakeholder Map | 3 | 7 |
| 3 | Số persona phù hợp, có lý giải | 5 | 6 |
| 4 | Persona khác nhau thực sự | 3 | 5 (vẫn chỉ 1 persona) |
| 5 | Đủ 12 trường lõi | 5 | 9 |
| 6 | Nhu cầu là kết quả, không ngụy trang tính năng | 7 | 8 |
| 7 | Bằng chứng hoặc nhãn giả định | 3 | 7 (có nhãn, chưa có phỏng vấn) |
| 8 | Affinity Board / tổng hợp pattern | 0 | 0 (chưa làm) |
| 9 | Scenario và success criteria cho Primary | 4 | 8 |
| 10 | Liên kết persona với quyết định UI và cách kiểm chứng | 3 | 8 |
| | **Tổng** | **41** | **67** |

67 điểm vẫn ở mức "Cần cải thiện" (70-79 đạt mức tiếp theo). Muốn ≥ 80 cần dữ liệu thật: phỏng vấn mentor (6-12 theo gợi ý của môn, tối thiểu 1-2 cho lab), Affinity Board có mã nguồn bằng chứng, và quyết định có giữ 1 persona hay tách thêm.

## 3. Đã sửa trong `ux/persona.md`

- Thêm mục 0: quy tắc nhóm **5-6** (bảng trạng thái 0-4 / 5 / 6), dữ liệu import (MSSV, Họ tên, Class name, Group, Major), 3 bước lọc tự động, giới hạn "không có kỹ năng, lịch".
- Viết lại persona thành bảng **12 trường lõi** đủ; thêm Priority, JTBD, Motivations, Constraints (có nguồn dữ liệu), Evidence & Status.
- Thêm giải trình số persona, **User/Stakeholder Map**, 3 kịch bản (S-A, S-B, S-C ứng với Flow A, B, C).
- Sửa tiêu chí thành công: 5-6 người, thêm tiêu chí lọc 100% và không vượt 6; mỗi tiêu chí có cách đo.
- Thêm bảng Persona → Need → quyết định UI → cách kiểm chứng.
- Thêm Assumption & Research Backlog (`A1`-`A6`, `Q1`-`Q5`) với nhãn Reported/Assumed/Open.
- Đồng bộ chữ "4-6" thành "5-6" ở `README.md`, `design/DESIGN.md` (dòng mô tả), mục Đề tài của `ai/ai-design-log.md`, và slide 2 trong PPTX. Các prompt Stitch cũ trong log và thư mục `archive/` giữ nguyên vì là bản ghi lịch sử.

## 4. Quyết định của tôi sau phản biện

| Điểm | Quyết định | Lý do |
|---|---|---|
| Quy tắc nhóm | Đổi sang 5-6 | Yêu cầu của tôi với vai mentor |
| Kỹ năng, lịch rảnh | Bỏ khỏi đầu vào AI; ghi giới hạn | File import không có cột này; thêm cột nằm ở backlog `A6`, `Q4` |
| Màn Import | Không thêm vào 21 màn | Ngoài phạm vi lab; prototype coi dữ liệu mẫu là đã import |
| Số persona | Giữ 1 Primary, kèm giải trình và map | Lab chỉ có luồng mentor; chưa có dữ liệu để tách |
| Trường MSSV | Chỉ dùng trong dữ liệu import; vẫn **không** có trường MSSV ở màn đăng nhập (quyết định số 8 trong `design/design-decisions.md`) | Hai việc khác nhau: đăng nhập của mentor và dữ liệu sinh viên |

## 5. Chưa làm (cần tôi quyết định hoặc làm)

- UI Figma và các màn Stitch vẫn có thể còn chữ liên quan 4-6 hoặc "n of 6" chưa đối chiếu hết với quy tắc "tối thiểu 5" (ví dụ S05, S11, S13, S14, S19-S21); cần rà từng màn.
- Chưa phỏng vấn mentor; mọi mục `Assumed` vẫn chưa kiểm chứng.
- Chưa làm Affinity Board và Persona Coverage Matrix đầy đủ (chỉ có bảng Stakeholder Map và backlog).
- Chưa cập nhật `design/screen-spec.md`, `ux/user-flow.md`, handoff cho quy tắc tối thiểu 5 (trạng thái nhóm 0-4 / 5 / 6).

## 6. Vòng 2: rà soát màn hình còn thiếu (13/10/2026)

- Prompt tôi gửi cho Claude (nguyên văn): `không cần AI đâu, về kĩ năng chỉ cần filter theo major như SE, GD.., hãy rà soát lại cá screen xem còn thiếu screen nào không... Bạn hãy tự phản biện lại trước khi trình bày cho tôi và đưa vào log`
- Cách hiểu của Claude (nêu rõ để tôi sửa nếu sai): "không cần AI" áp dụng cho **kỹ năng**: ghép chỉ cần lọc theo **Major**, không phân tích kỹ năng hay lịch. Claude **không** hiểu là bỏ hẳn tính năng gợi ý ghép (S8, S9, S15); nếu tôi muốn bỏ hẳn thì phải đổi lại cả 3 flow (xem mục 8, câu hỏi 1).
- Phạm vi đọc: `ux/user-flow.md`, `design/screen-spec.md` và nội dung chữ trong Figma page 03 (S02, S03, S07, S10), chỉ đọc, chưa sửa Figma.

### 6.1 Bản nháp phát hiện (trước khi tự phản biện)

| Mã | Phát hiện |
|---|---|
| G1 | Không có màn **Import** danh sách sinh viên (MSSV, Class name, Group, Major). |
| G2 | Không có màn **kết quả import** (tổng, đã có nhóm, chưa có nhóm, nhóm đủ 6, dòng lỗi). |
| G3 | Không có màn **tổng quan nhóm** theo trạng thái (thiếu / đủ 5 / đầy 6). |
| G4 | Không có màn **chi tiết nhóm hiện có** và không có thao tác **bỏ thành viên**. |
| G5 | Không có **xuất** danh sách nhóm cuối. |
| G6 | Không có tìm sinh viên toàn lớp theo MSSV. |
| G7 | Không có frame cho trạng thái rỗng của S2 (lớp chưa import). |
| G8 | Không có màn **cài đặt** min/max nhóm. |

### 6.2 Tự phản biện từng phát hiện

| Mã | Phản biện của Claude | Kết luận |
|---|---|---|
| G1, G2 | Import là **tiền đề** tôi nêu cho app, nên thiếu là lỗi thật, không phải thêm cho đủ. Nhưng 1 màn Import chưa đủ: sau import mentor cần biết kết quả lọc có đúng không, nên cần màn kết quả. Phản biện ngược: màn Import là upload file, rủi ro làm lab phình; giữ **tối thiểu 2 màn**, đặt ngay đầu Flow A (S2 → Import → Kết quả → S3), **không mở flow thứ 4**. | **Thêm** S22 Import, S23 Import result |
| G3 | S5 chỉ hiện nhóm thiếu, nhóm đủ bị ẩn theo ý "tự lọc". Mentor vẫn cần kiểm tra. Nhưng thêm cả màn Teams là thừa: đủ khi S5 có chip trạng thái. | **Không thêm màn**; sửa S5 (chip Need / Ready 5 / Full 6) |
| G4 | Phát hiện này **tự bắt lỗi của chính Claude**: kịch bản S-B trong persona ghi "bỏ một bạn khác rồi thêm", nhưng S10 chỉ có 4 hàng thành viên **không có nút bỏ** (đã kiểm Figma). Persona hứa thao tác mà UI không có. Màn "chi tiết nhóm hiện có" thì S10 và S20 đã gần đủ; chỉ thiếu thao tác bỏ. | **Thêm** S24 Remove member dialog; thêm nút bỏ ở S10; không thêm màn chi tiết riêng |
| (mới) | Quy tắc **tối thiểu 5** chưa có màn nào báo: S13 chỉ báo vượt 6. Duyệt nhóm 4 người hiện không bị chặn. Đây là quy tắc tôi nhấn mạnh, nên cần trạng thái lỗi. | **Thêm** S25 Approve blocked (cần ≥ 5) |
| G5 | Xuất file không nằm trong tiêu chí thành công nào của persona; nhưng mentor cần nộp danh sách nhóm. Hiếm bị hỏi khi bảo vệ lab. | **Hoãn**, ghi backlog |
| G6 | S16 đã có ô tìm kiếm; S4 lọc theo ngành. Đủ cho lab. | Bỏ |
| G7 | Trạng thái rỗng là state, không cần frame riêng cho lab; đã có empty ở S14, S15, S21. | Bỏ |
| G8 | Min/max cố định 5-6, không cần cài đặt. Thêm sẽ phình phạm vi. | Bỏ |
| Chữ cũ | Không phải màn thiếu mà là **chữ mâu thuẫn quyết định "chỉ theo ngành"**: S07 có mục *Skills* (Social media, Branding, Writing) và *Availability (12 h/week)*; S10 có lý do "Same 12 h/week as team"; S03 ghi "AI matching balances skills and team size". | **Sửa chữ** trên Figma và tài liệu, không thêm màn |

### 6.3 Kết quả sau phản biện

| Loại | Nội dung |
|---|---|
| Thêm màn (4) | S22 Import, S23 Import result, S24 Remove member dialog, S25 Approve blocked (cần ≥ 5). Tổng 25 màn. |
| Sửa màn có sẵn (4) | S03 (chữ "skills"), S05 (chip trạng thái), S07 (bỏ Skills, Availability; thay bằng Class, MSSV, Group), S10 (bỏ "Same 12 h/week", thêm nút bỏ thành viên). |
| Hoãn | Xuất danh sách nhóm; màn tổng quan nhóm riêng. |

## 7. Bảng màn mới (đề xuất ban đầu; bản đã dựng ở mục 9)

| Màn | Nội dung chính | Flow | Ghi chú |
|---|---|---|---|
| S22 Import | Chọn lớp, nút Choose file (cột cần có: MSSV, Name, Class name, Group, Major), nút Import | A (trước S3) | Nút chính 1 |
| S23 Import result | "120 students imported", 87 đã có nhóm (ẩn), 33 chưa có nhóm, 5 nhóm đủ 6, dòng cảnh báo lỗi (nếu có), nút Continue | A | Thể hiện lọc tự động |
| S24 Remove member dialog | "Remove Duc Pham from Tutor Match?", Cancel, Remove (đỏ) | B | Dialog mặc định |
| S25 Approve blocked | S10 với "Tutor Match, 4 of 6", dòng lỗi "Needs at least 5 members", nút Approve khóa | B | Trạng thái lỗi của S10 |

Việc cần làm nếu duyệt (đã làm ngày 14/10/2026, xem mục 9): viết prompt Stitch cho 4 màn (hoặc dựng trực tiếp trong Figma), thêm vào pages 02, 03, 06, 01, cập nhật `ux/user-flow.md`, `design/screen-spec.md`, handoff, slide, README (21 màn thành 25), sửa chữ S03, S05, S07, S10.

## 8. Điểm yếu còn lại của chính bản phản biện này

1. **Cách hiểu "không cần AI":** nếu tôi muốn bỏ hẳn AI khỏi sản phẩm thì ngoài 4 màn mới còn phải đổi S3, S4, S5 (nút Match with AI), S8, S9, S10, S15, S17, toàn bộ 3 flow và slide. Đây là khác biệt lớn, cần tôi xác nhận. Các màn S22-S25 vẫn dùng được trong cả hai trường hợp.
2. **Chưa kiểm đủ:** Claude chỉ đọc chữ của S02, S03, S07, S10 trên Figma; chưa duyệt trực quan toàn bộ 21 màn theo từng quy tắc 5-6.
3. **Chưa có người dùng thật:** việc cần màn Import và tối thiểu 5 đều dựa trên yêu cầu của tôi, không phải phỏng vấn mentor.
4. **Ước lượng công sức** (4 màn × 3 trang Figma + prototype + tài liệu + slide) chưa tính; lab đã đủ 21 màn, việc thêm màn là để khớp tiền đề của tôi chứ không bắt buộc theo rubric.

## 9. Kết quả dựng (14/10/2026)

Tôi duyệt phạm vi ở mục 6.3 ("có, bạn có thể thoải mái dùng token, nên hãy đảm bảo các bước kĩ càng"). Claude đã dựng trong Figma và cập nhật tài liệu:

| Hạng mục | Đã làm |
|---|---|
| Page 03 | Thêm S22 Import class list, S23 Import result, S24 Remove member dialog, S25 Approve blocked (nhân bản từ S07, S03, S17, S10 nên giữ Variables và text style). Sửa S02 (nút Import class list), S03 (chữ ghép theo ngành, nhóm 5-6), S05 (số thành viên, "Needs ... to reach 5"), S07 (thẻ Student info thay Skills và Availability), S10, S12, S17, S20 (dòng "Team reaches 3 majors", nút bỏ thành viên 48dp mỗi hàng). |
| Page 02 | W22-W25 và các sửa tương ứng ở W02, W03, W05, W07, W10, W12, W17, W20. |
| Page 06 | Thêm A12 (S22), A13 (S23), B8 (S24), B9 (S25); áp các sửa lên bản prototype; nút Import ở S02, nút bỏ thành viên ở S10 và S20 đều bấm được. Đã chạy lại kiểm tra: 35 frame đều đến được từ 3 điểm bắt đầu, không có liên kết trỏ vào frame không tồn tại. |
| Page 01 | Thêm S22-S25 vào cây IA, nhánh phụ Flow A (S22, S23) và Flow B (S24, S25), bảng phủ 25 màn. |
| Tài liệu | `ux/user-flow.md`, `design/screen-spec.md`, `handoff/flutter-handoff.md`, `assets/flows/` (vẽ lại 3 flow), README, slide. |

Khác với bảng đề xuất ở mục 7:

- S23 dùng số liệu của Class A (42 imported, 30 in a group, 12 available) để khớp S02 và S03, không dùng "120 students".
- S24 ghi "Team will have 4 members." (không nêu tên người) vì mọi nút bỏ thành viên trong prototype dẫn tới cùng một dialog.
- S25 là nhóm Tutor Match còn 4 người kể cả người mới đề xuất (3 thành viên + Minh Anh); Approve bị khóa.

Điểm yếu còn lại sau khi dựng:

1. Trong prototype, bấm bỏ bất kỳ thành viên nào cũng dẫn tới cùng cặp S24, S25 (S25 luôn thiếu Duc Pham); đây là giới hạn của prototype, không phải của thiết kế.
2. S22 mới có trạng thái mặc định; trạng thái lỗi (sai định dạng, thiếu cột) và loading chỉ được mô tả trong `design/screen-spec.md`.
3. S22-S25 không có bản Stitch; chúng được dựng trực tiếp trong Figma, nên không có ảnh "before" như S04 và S17.
4. Số liệu 42, 30, 12 và 5 nhóm còn thiếu là dữ liệu mẫu; chưa kiểm tra chéo với tổng 125, 104, 21 của 3 lớp ở từng chi tiết.
5. Page 05 (Components) và page 04 không đổi: nút Import dùng lại Button tonal, banner lỗi dùng lại mẫu của S13, nút bỏ thành viên là icon button mới nhưng chưa thành component riêng.
6. Page 01 chưa vẽ cạnh quay lại S25 → S10 (đã có trong `flow-b.png`).
