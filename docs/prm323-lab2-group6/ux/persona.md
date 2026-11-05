# Persona và vấn đề

> Đề tài: **TeamUp EXE** (tên tạm) - ứng dụng giúp **mentor/giảng viên EXE** ghép sinh viên FPT chưa có nhóm vào các nhóm còn thiếu người, để mỗi nhóm khởi nghiệp nhỏ có **5-6 người** thuộc nhiều ngành. AI đề xuất, mentor duyệt.
>
> Trạng thái tài liệu (13/10/2026): **Proto-Persona**, chưa có phỏng vấn thật. Bản này đã sửa sau phản biện theo `persona-guideline` (xem `ai/ai-critique-3.md`).

## 0. Quy tắc nghiệp vụ và dữ liệu đầu vào (chốt ngày 13/10/2026)

**Quy tắc nhóm:** tối thiểu **5**, tối đa **6** thành viên.

| Số thành viên | Trạng thái nhóm | App xử lý |
|---|---|---|
| 0-4 | Thiếu người (Need members) | Là đích ưu tiên của AI; hiện ở "Teams needing members" |
| 5 | Đủ tối thiểu | Hợp lệ, mentor có thể thêm 1 người nữa |
| 6 | Đầy (Full) | Khóa: không nhận thêm, không là đích đề xuất; thêm nữa báo "Max 6 members" |

**Dữ liệu mentor import** (file bảng tính cho từng lớp):

| Cột | Ví dụ | Dùng để |
|---|---|---|
| MSSV | (mã sinh viên) | Khóa duy nhất, tránh trùng người |
| Họ tên | (tên) | Hiển thị |
| Class name | (tên lớp) | Chia theo lớp mentor phụ trách |
| Group | (tên nhóm hoặc trống) | Cột này quyết định ai còn "chưa có nhóm" |
| Major | SE, AI, MKT, GD | Cân bằng ngành trong nhóm |

**Lọc tự động sau khi import:**
1. Sinh viên đã có Group: **bị loại** khỏi danh sách "No team" và khỏi pool AI (trên màn thêm sinh viên hiện khóa "In a team").
2. Nhóm đủ 6: bị loại khỏi danh sách đích; nhóm 5 vẫn nhận 1 người nếu mentor muốn.
3. AI chỉ đề xuất sinh viên **chưa có nhóm** vào nhóm **còn chỗ**, ưu tiên nhóm thiếu ngành.

**Quyết định của chủ dự án (13/10/2026):** "kỹ năng" chỉ là **ngành (Major: SE, AI, MKT, GD...)**; không phân tích kỹ năng cụ thể hay lịch rảnh. Việc ghép gợi ý chỉ dựa trên **ngành còn thiếu của nhóm, lớp và trạng thái nhóm**; nhãn mức phù hợp ("Strong fit" ...) phản ánh mức bù ngành. Màn Import chưa nằm trong 21 màn hiện có: đã đề xuất bổ sung ở `ai/ai-critique-3.md` mục 7 (chờ duyệt). Không xác minh sinh viên có thật hay không (ngoài phạm vi).

## 1. Persona chính P01: Cô Lan

| # | Trường | Nội dung |
|---|---|---|
| 01 | Identity & Archetype | **Cô Lan**, 38 tuổi, giảng viên và mentor khởi nghiệp. Nhãn hành vi: *"mentor chịu trách nhiệm cuối cùng về nhóm, quyết định nhanh giữa các tiết, không tin hoàn toàn vào tự động hóa"*. |
| 02 | Persona Priority | **Primary.** Lý do: là người duy nhất thao tác trong app (import, xem đề xuất, duyệt) và chịu trách nhiệm cuối cùng về kết quả nhóm; sinh viên chỉ là đối tượng được ghép, không dùng app trong phạm vi lab. |
| 03 | Usage Context | Điện thoại Android, thường **một tay**, vài phút giữa các tiết hoặc lúc di chuyển; hành lang sáng; wifi trường đôi lúc chập chờn. Dùng nhiều nhất ở **tuần chốt nhóm** đầu kỳ, mỗi lớp khoảng 40 sinh viên, 3 lớp. |
| 04 | Goals | (1) Mọi nhóm đạt **5-6 người**, đủ ngành cho một dự án nhỏ. (2) Không còn sinh viên "lẻ" khi chốt nhóm. (3) Giữ quyền quyết định cuối cùng. |
| 05 | Job to Be Done | *Khi* vừa có danh sách lớp mới và còn nhiều bạn chưa có nhóm, *tôi muốn* thấy ngay ai chưa có nhóm, nhóm nào còn chỗ và gợi ý ghép hợp lý *để* chốt nhóm cả lớp trong một lần ngồi ngắn mà không lệch ngành. |
| 06 | Current Behaviors | Chép danh sách ra bảng tính, tô màu tay những bạn đã có nhóm, nhắn tin từng bạn hoặc từng nhóm để hỏi tình trạng, đếm người bằng mắt. Làm lặp lại mỗi lần có người đổi nhóm (giả định, `A1`). |
| 07 | Pain Points | (1) **Lọc tay**: khó biết bạn nào đã có nhóm, nhóm nào đã đủ 6 hay còn thiếu dưới 5, nên dễ bỏ sót hoặc ghép trùng. (2) **Lệch ngành**: ghép vội thì nhóm toàn một ngành, lộ ra giữa kỳ. (3) **Thời gian**: chỉ có vài phút mỗi lần, cần quyết định nhanh nhưng vẫn muốn hiểu lý do gợi ý. |
| 08 | Motivations | **Nhanh** (vài phút), **kiểm soát** (AI chỉ đề xuất, không tự đổi), **công bằng** (không ai bị bỏ lại), **an tâm** (hiểu lý do). |
| 09 | Constraints | Thiết bị: điện thoại một tay, mạng chập chờn (cần trạng thái offline và thử lại). Năng lực số: dùng bảng tính tốt, không rành công cụ phức tạp. Quyền hạn: chỉ sửa nhóm của lớp mình. Dữ liệu: chỉ có MSSV, lớp, nhóm, ngành; không dùng kỹ năng hay lịch. Accessibility: tương phản cao ngoài hành lang sáng, chữ thân bài 16 sp, nút 48 dp. |
| 10 | Key Scenarios | Xem mục 3. |
| 11 | Success Criteria | Xem mục 4. |
| 12 | Evidence & Status | **Proto-Persona, chưa kiểm chứng.** Mọi mục 03, 06, 07 là `Assumed` (giả định của nhóm), chưa có phỏng vấn; mã bằng chứng: `A1` đến `A6` trong mục 6. Nguồn duy nhất hiện có: yêu cầu nghiệp vụ do chủ dự án (đóng vai mentor) nêu ngày 13/10/2026 (`R1`, nhóm 5-6, import, lọc tự động). |

**Vấn đề (1 câu):** Mentor có sinh viên chưa có nhóm và nhóm còn thiếu người hoặc thiếu ngành, nhưng phải lọc và ghép thủ công qua bảng tính nên mất nhiều thời gian và dễ lệch ngành.

**Giải pháp ở mức sản phẩm:** sau khi import, app tự ẩn sinh viên đã có nhóm và nhóm đã đủ 6; AI gợi ý ghép sinh viên chưa có nhóm vào nhóm còn chỗ, mỗi gợi ý có nhãn mức phù hợp và lý do ngắn. Mentor xem, thêm hoặc bớt thành viên rồi mới duyệt. Chưa duyệt thì dữ liệu không đổi.

## 2. Số persona: vì sao chỉ có 1 persona chính

Lab 2 chỉ bắt buộc 1 Primary đủ 12 trường. Với đồ án nhóm, guideline yêu cầu giải thích vì sao không có phân khúc khác:

- **Sinh viên (P02, Supporting, không thiết kế riêng):** là đối tượng được ghép, không dùng app mentor. Nhu cầu của họ (biết mình vào nhóm nào) được phục vụ qua thông báo ngoài app, ngoài phạm vi lab. Nếu mở rộng, đây sẽ là persona thứ hai.
- **Điều phối khoa / giảng viên khác (P03, giả định):** có thể xem báo cáo toàn lớp; chưa có bằng chứng nên chưa tách, ghi vào backlog (`Q3`).
- Lý do giữ 1 persona: lab chỉ có luồng mentor; chưa có dữ liệu cho thấy nhóm mentor chia thành các kiểu hành vi khác nhau (ví dụ mentor mới và mentor lâu năm). Cần phỏng vấn mới kết luận (`Q2`).

**User / Stakeholder Map:**

| Bên liên quan | Vai trò | Dùng app? | Quan tâm chính |
|---|---|---|---|
| Mentor/giảng viên (P01) | Người quyết định và duyệt | Có (trực tiếp) | Nhanh, đúng ngành, kiểm soát |
| Sinh viên chưa có nhóm | Đối tượng được ghép | Không (lab) | Không bị bỏ lại, nhóm hợp ngành |
| Sinh viên đã có nhóm | Bị loại khỏi pool | Không | Không bị ghép nhầm hoặc kéo đi |
| Điều phối khoa | Xem tổng hợp | Chưa | Báo cáo lớp đủ nhóm |
| Hệ thống AI | Đề xuất | Hệ thống | Cần dữ liệu đúng, đủ cột |

## 3. Kịch bản chính

**S-A (liên quan Flow A): chốt nhóm một lớp.** Tác nhân: cuối tuần đăng ký nhóm, lớp EXE1 còn nhiều bạn chưa có nhóm. Cô Lan mở app giữa hai tiết, chọn lớp, thấy danh sách "No team" và "Teams needing members" đã được lọc sẵn, bấm "Match with AI", xem đề xuất kèm lý do, duyệt. Kết quả: mọi nhóm của lớp đạt 5-6 người trong dưới 5 phút.

**S-B (Flow B): điều chỉnh khi nhóm đầy.** Tác nhân: một nhóm đã có 6 người nhưng Cô Lan muốn thêm một bạn. Cô thử thêm, app báo "Max 6 members" và nút Add bị vô hiệu; cô bỏ một bạn khác rồi thêm. Kết quả: nhóm vẫn đúng quy tắc, thao tác dưới 60 giây.

**S-C (Flow C): AI không ghép được.** Tác nhân: còn 2 bạn cùng ngành, không nhóm nào thiếu ngành đó. App báo "No match", Cô Lan ghép tay, có thể tìm sinh viên (kể cả khi không có kết quả). Kết quả: không còn bạn lẻ, quyết định cuối thuộc mentor.

## 4. Tiêu chí thành công (đo được)

| # | Tiêu chí | Cách đo |
|---|---|---|
| 1 | Duyệt xong gợi ý AI cho một lớp **dưới 5 phút** (từ mở lớp đến duyệt nhóm cuối). | Bấm giờ theo kịch bản S-A trên prototype |
| 2 | **Mọi nhóm sau khi duyệt có 5-6 người và ít nhất 3 ngành khác nhau.** | Kiểm trên dữ liệu mẫu sau khi duyệt |
| 3 | Thêm hoặc đổi một thành viên và duyệt **dưới 60 giây**. | Bấm giờ theo kịch bản S-B |
| 4 | **100% sinh viên đã có nhóm không xuất hiện** trong danh sách chưa có nhóm và pool AI; không nhóm nào đủ 6 nằm trong danh sách đích. | Đối chiếu dữ liệu mẫu với cột Group sau import |
| 5 | Không nhóm nào vượt 6; thêm vào nhóm đầy luôn có thông báo rõ. | Kịch bản S-B |

Cảnh báo giới hạn: tiêu chí 2 chỉ đạt được khi lớp có ít nhất 3 ngành đủ người; nếu không, app phải cho mentor biết (ghi chú `Q5`).

## 5. Từ persona đến quyết định thiết kế

| Persona/nhu cầu | Quyết định UI | Màn | Cách kiểm chứng |
|---|---|---|---|
| Chỉ có vài phút, một tay | 1 nút chính mỗi màn, nút 48 dp, chữ ≥ 14 sp | Toàn bộ | Đo 48 dp và 14 sp trong Figma; bấm giờ prototype (tiêu chí 1, 3) |
| Không tự lọc tay | Chip lọc ngành, danh sách "No team" tách riêng, sinh viên đã có nhóm bị khóa "In a team" | S04, S11, S16 | Đối chiếu dữ liệu mẫu (tiêu chí 4) |
| Quy tắc 5-6 | Tiêu đề "n of 6", lỗi "Max 6 members", nút Add vô hiệu | S10, S11, S13 | Kịch bản S-B (tiêu chí 5) |
| Muốn hiểu lý do, giữ quyền quyết định | Nhãn mức phù hợp và lý do ngắn; chỉ lưu khi bấm Approve; dialog Discard | S10, S12, S17 | Hỏi giảng viên có hiểu lý do không (`Q1`) |
| Mạng chập chờn | Trạng thái offline và nút Try again | S18 | Duyệt flow A với lỗi mạng |
| AI có thể không ghép được | Màn No match, ghép tay | S15, S16, S21 | Flow C |

## 6. Giả định cần xác nhận và kế hoạch nghiên cứu (Assumption & Research Backlog)

| Mã | Giả định hoặc câu hỏi | Loại dữ liệu | Cách kiểm |
|---|---|---|---|
| `A1` | Mentor hiện lọc nhóm bằng bảng tính và nhắn tin | Assumed | Phỏng vấn 1-2 giảng viên/mentor EXE |
| `A2` | Mỗi lớp khoảng 40 sinh viên, 3 lớp/mentor | Assumed | Hỏi mentor số lớp, sĩ số |
| `A3` | Mentor dùng một tay, wifi trường chập chờn | Assumed | Quan sát hoặc hỏi |
| `A4` | Nhóm 5-6 người là quy tắc chung của môn | Reported (từ chủ dự án, `R1`) | Đối chiếu đề cương môn |
| `A5` | File import có MSSV, Class name, Group, Major | Reported (`R1`) | Xem file mẫu thật của EXE |
| `A6` | Ghép chỉ cần theo ngành, không cần kỹ năng và lịch | Reported (chủ dự án, 13/10) | Đã chốt; kiểm lại khi phỏng vấn mentor |
| `Q1` | Mentor có hiểu và tin lý do AI đưa ra không? | Open | Cho xem prototype S10 |
| `Q2` | Có kiểu mentor khác (mới, lâu năm) với hành vi khác không? | Open | Hỏi thêm 3-5 mentor |
| `Q3` | Điều phối khoa có cần xem tổng hợp không? | Open | Phỏng vấn 1 điều phối viên |
| `Q4` | Màn Import trong app: một bước hay có bước xem trước kết quả? | Decided (14/10/2026) | Hai bước: S22 chọn file và xem cột nhận diện, S23 xem kết quả lọc |
| `Q5` | Nếu lớp thiếu ngành thì app nên báo thế nào? | Open | Thử với dữ liệu lệch |

Ghi chú: `R1` = yêu cầu nghiệp vụ do chủ dự án (đóng vai mentor) nêu ngày 13/10/2026; đây không phải phỏng vấn người dùng thật. Không có dữ liệu nào ở đây là quan sát thật. Quy trình phản biện: `ai/ai-critique-3.md`.

**Không có trong phạm vi lab:** xác minh danh tính sinh viên, mô hình AI thật (ghép chỉ là thiết kế giao diện với dữ liệu mẫu). Màn Import đã dựng ở S22, S23 (xem `ai/ai-critique-3.md` mục 9).
