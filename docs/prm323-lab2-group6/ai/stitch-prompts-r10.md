# Stitch prompts R10 (mentor app): 3 frame bổ sung để khớp flow

Chạy trong cùng project Stitch với R9 (đã có design system). Một prompt, đúng 3 frame. Ghi vào `ai/ai-design-log.md` như một lần chạy mới (R10), dán nguyên văn đúng chữ bạn đã chạy.

## Vì sao cần 3 frame này (đối chiếu flow và 18 màn hiện có)

| Chỗ lệch | Cách xử lý | Cần gen? |
|---|---|---|
| Flow A có nhánh "Email sai" nhưng không có màn lỗi của S1 | Frame 1 "Sign in - error" | Có |
| Flow C: S16 Add student, bấm Add, sang S10 "Nhóm đã thêm tay", nhưng S10 hiện có mục lý do của AI (Why) và nhóm Tutor Match | Frame 2 "Proposal detail - hand-built" cho nhóm FinLite, không có Why | Có |
| `screen-spec.md` có trạng thái "empty (không có kết quả)" cho S16 mà chưa có màn | Frame 3 "Add student - no results" | Tùy chọn (nên có nếu cần đủ trạng thái) |
| Flow A: "Nhập email, nhận mã" nhưng không có màn nhập mã | Sửa flow và `persona.md`: bỏ bước mã, chỉ nhập email | Không |
| Flow B: S11 là "Tutor Match, 5 of 6" nhưng S13 (lỗi vượt 6) là "FinLite, 6 of 6" | Sửa chữ trong Figma và S13 thành "Tutor Match, 6 of 6" | Không |
| S14 "All matched" sau khi duyệt một nhóm trong khi còn 2 đề xuất | Đổi flow: S14 là bước cuối khi duyệt nhóm cuối cùng, hoặc ghi chú trong flow | Không |
| S16 không nói đang thêm vào nhóm nào | Thêm dòng "FinLite, 4 of 6" trong Figma (hoặc ghi chú trong flow) | Không |
| Flow C: S15 "See teams" chưa có đích rõ | Sửa flow: nối tới S5 | Không |

Sau khi có 3 frame: thêm S19, S20, S21 vào `ux/user-flow.md` (danh sách, cây điều hướng, bảng phủ), `design/screen-spec.md`, và sửa `assets/flows/build_flows.py` rồi chạy lại.

Kiểm sau khi chạy: đúng 3 frame; không có từ lineup/roster/squad/board/capstone/position; không xanh dương; chữ không nhỏ hơn 14 sp; mỗi màn tối đa 1 nút đặc (filled).

## Prompt R10 - frame 19-21

```text
HEADER
Generate EXACTLY the 3 frames listed below (no more, no fewer), each as its own separate 360 x 800 dp Android frame (Material 3, light theme), for the app "TeamUp EXE": a tool for a university mentor (lecturer) of the EXE startup course. AI suggests how to place students who have no team into small startup teams that miss 1-2 specialist members, so each team reaches 4-6 members from different majors. The mentor reviews and approves. Keep the visual style of this project's existing design system. Ignore the older student-facing frames. Use ONLY the text given. Do not invent text, names, dates, banners, badges, helper sentences or extra sections. Never use the words lineup, roster, squad, board, capstone, position.

DESIGN SYSTEM (follow exactly)
Colors: screen and cards white #FFFFFF; cards have a 1 dp border #D6D4CE, no tinted fill, no shadow; text #1C1B18; secondary text #55534D; filled button and active indicator burnt orange #B23E00 with white text; selected chip and active navigation pill #FFE2D2 with text #3B1400; unselected chips and tonal buttons fill #E9E7E2 with text #1C1B18 and a 1 dp border #D6D4CE; error #B3261E on #F9DEDC; success and filled #1B6B3C on #D6F0DD; text fields fill #F3F2EF with a 1 dp border #77756F; snackbar #2F2E2A with white text. NO blue anywhere, no gradients, no shadows on cards, no colored side borders, no nested cards, no glass, no emoji icons.
Major row (signature component): one row of square slots, 40 dp on cards and 48 dp on detail screens, maximum 6, no captions under slots. Filled slot: fill #D6F0DD, 1 dp border #1B6B3C, the major code (SE, AI, MKT, GD) in #07301A. Open slot: white, 2 dp dashed outline #77756F, a small major icon. Proposed slot (what the AI suggests): fill #FFE2D2, 2 dp solid outline #B23E00, the major code in #3B1400, a small plus mark in the corner.
Type: Be Vietnam Pro. Headline 24 sp bold, title 20 sp semibold, card title 16 sp semibold, body 16 sp, metadata 14 sp, button and chip 14 sp semibold. Nothing smaller than 14 sp. Sentence case, no all caps, no arrows in button text. Numbers use tabular figures.
Layout: 16 dp side margins, 4 dp spacing scale, cards radius 12, fields radius 8, buttons and chips pill, buttons 48 dp high, touch targets 48 dp, one icon set (Material Symbols Rounded, outlined).
Components: top app bar with a left-aligned title only (nested screens: back arrow and title); no logo, no subtitle, no status bar mock, no help icon. Bottom navigation bar with 3 tabs Classes, Proposals, Profile, the current tab with a pill indicator, filled icon and bold label; nested screens, dialogs and the loading screen have no bottom navigation unless stated. At most one filled primary button per screen. Every status uses icon plus text label, never color alone. Fit chips: "Strong fit" with a check icon (green), "Good fit" with a half-circle icon (stone). Dialogs are Material 3 dialogs centered over a dimmed copy of the screen behind.
Copy rule: screen title max 3 words, button max 3 words, list row = one main line plus at most one short secondary line, no helper sentences, errors max 5 words.


FRAME LIST
1. "Sign in - error": no navigation. Same layout as the existing "Sign in" frame, in its error state. Title "Sign in". Text "Build balanced teams". Field label "Email" with the typed value "lan@gmail"; the field has a 2 dp border #B3261E and an error icon at its right end; below the field the error text "Enter a valid email" in #B3261E with a small error icon. Button "Continue".
2. "Proposal detail - hand-built": back arrow, title "FinLite", no navigation. One row of 5 filled slots at 48 dp (SE, SE, MKT, GD, AI) with no captions under them. A stone chip "Added by you" with a person icon. Section "New member": one plain row "Lan Vo, AI" with a tonal button "Change". Section "Members": 4 plain rows "Hoang Nguyen, SE", "Quoc Bao, SE", "Thao Linh, MKT", "Duc Pham, GD". Sticky filled button "Approve" and below it a text button "Discard" in #B3261E.
3. "Add student - no results": back arrow, title "Add student", no navigation. Search field with the typed text "Zed" and a clear icon. Filter chips "All", "SE", "AI", "MKT", "GD" with "All" selected. Centered in the empty area: a 48 dp search-off icon, the text "No student found", and a tonal button "Clear search".
```
