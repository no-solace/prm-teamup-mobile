# AI Design Log - TeamUp EXE

> Nguyên tắc ghi log: prompt chép **nguyên văn**; chỗ nào chưa chạy thật hoặc chưa có bằng chứng thì đánh dấu `TODO`, không điền trước. Quyết định và lý do là của người làm bài. Ghi chú: file template Appendix A của đề không có trong PDF, nên cấu trúc dưới đây tự xây theo rubric (prompt, output, critique, decision, iteration, disclosure).

| Mục | Nội dung |
|---|---|
| Sinh viên / MSSV | `TODO` |
| Đề tài | TeamUp EXE: ứng dụng cho mentor/giảng viên EXE, AI gợi ý ghép sinh viên chưa có nhóm vào nhóm đang thiếu 1-2 thành viên chuyên môn (nhóm 5-6 người, nhiều ngành); mentor duyệt. Từ 06/10/2026 (R8) đổi từ hướng sinh viên sang hướng mentor, xem mục 6 dòng 10. Giảng viên duyệt đề tài: `TODO` |
| Stitch project | `TODO` dán link (link riêng tư, giảng viên có thể không mở được; ảnh trong `assets/stitch/` là bằng chứng chính) |
| Tài liệu đầu vào cho Stitch | `design/DESIGN.md` **bản 1** (palette cam và xanh dương, North Star "The Lineup Board" ở lần đầu; đã chỉnh tên và luật nội dung trước R1). Bản 2 (bỏ xanh dương, nền trắng, thẻ viền) soạn ngày 05/10/2026 sau khi xem output; được đưa thẳng vào master prompt P16 (R7) nên chỉ áp dụng cho Stitch khi R7 được chạy. Xem mục 6, dòng 9 |

## Trạng thái hiện tại (06/10/2026)

- Hướng sinh viên (R0 đến R7): đã chạy trong Stitch R0 đến R5 (13 màn), R6 (sửa email), R7 (master prompt 22 frame; ban đầu Stitch chỉ ra 6 frame: Create profile, Discover, Sign in, Loading, Empty, Offline; bản export cuối trong `assets/stitch/student-v1/` có đủ 22 màn, `TODO` ghi lại bạn chạy tiếp các frame còn lại bằng cách nào và ngày nào). Các prompt và tài liệu hướng này đã chuyển vào `archive/student-v1/`.
- **R8 (06/10/2026): tôi đổi hướng** sang app cho mentor/giảng viên, có AI gợi ý ghép sinh viên vào nhóm thiếu người. Persona, user flow, `DESIGN.md` đã viết lại theo hướng mới. Design system (bảng màu, font, component) được giữ.
- R9 (đã chạy): 3 prompt, mỗi prompt 6 frame, tổng 18 frame, trong `ai/stitch-prompts-r9.md`; bản export gồm 18 màn trong `assets/stitch/mentor-v2/`. Còn lại: dán prompt nguyên văn vào mục 3 và điền ngày chạy thật.
- R10 (đã chạy, ảnh thêm vào repo ngày 11/10/2026): 1 prompt 3 frame trong `ai/stitch-prompts-r10.md` (Sign in - error, Proposal detail - hand-built, Add student - no results) để flow và màn khớp nhau; 3 màn nằm ở `assets/stitch/mentor-v2/s19`-`s21`. Nhờ đó tôi bỏ bước "nhận mã" khỏi Flow A và persona, và đổi S13 thành "Tutor Match, 6 of 6" cho khớp S11.
- Figma (11/10/2026): tôi cho Claude dựng file Figma mới (https://www.figma.com/design/X5WcaK4s20AYF53cvRdouV) qua công cụ Figma. Cách làm: render code HTML của 21 màn Stitch rồi chuyển thành layer Figma (không vẽ lại bằng tay); giữ bảng màu của Stitch và sửa `DESIGN.md`, handoff cho khớp. **Wireframe (page 02) được suy ra từ layout Final UI sau khi Stitch sinh ra**, không phải bản phác trước khi dùng AI. Prototype có hai tương tác mô phỏng: chạm tiêu đề "Finding teammates" để giả lập mất mạng (S18), và loading tự chuyển sang kết quả sau 3-4 giây. PNG đã xuất vào `assets/figma/01-…06-` (11/10/2026).
- 13/10/2026: tôi nhờ Claude phản biện `ux/persona.md` theo persona-guideline và yêu cầu nghiệp vụ mới (nhóm tối thiểu 5, tối đa 6; mentor import MSSV, class name, group, major; app tự lọc sinh viên đã có nhóm); xem Critique C ở mục 5 và `ai/ai-critique-3.md`.
- 14/10/2026: tôi duyệt phản biện và Claude dựng thêm 4 màn S22-S25 (tổng 25 màn) trong Figma, sửa chữ S02, S03, S05, S07, S10 (bỏ skills, availability); xem `ai/ai-critique-3.md` mục 9.
- Cần hoàn thiện trước khi nộp: ảnh trong `assets/stitch/`, các ô `TODO`, mục 6 và checklist mục 8.

## 1. Khai báo công cụ AI

| Công cụ | Dùng để | Kết quả | Tôi đã làm gì với kết quả |
|---|---|---|---|
| Claude (Anthropic) | Phân tích đề lab, soạn persona, IA và user flow, draft `DESIGN.md`, soạn prompt Stitch, phản biện ảnh Stitch | `ux/*.md`, `design/DESIGN.md`, `ai/stitch-prompts-v2.md`, `ai/ai-critique-1.md` | `TODO` ghi rõ phần bạn đã đọc, sửa, bác bỏ |
| Skill `diagram-skill` (qua Claude) | Sinh file draw.io và PNG cho 3 user flow | `assets/flows/flow-a|b|c.drawio, .png` | `TODO` mở trong app.diagrams.net và kiểm tra |
| Skills `impeccable`, `design-taste-frontend` (qua Claude) | Nguyên tắc thiết kế khi viết `DESIGN.md` và khi chẩn đoán ảnh Stitch (Material 3 Android, tránh mẫu AI, tương phản) | Các luật trong `DESIGN.md` | `TODO` |
| Google Stitch | Sinh UI ban đầu và các lần chỉnh sửa | Ảnh trong `assets/stitch/` | Chọn màn, chạy lại, loại bản cũ |
| Figma (qua Claude) | Dựng file Figma mới https://www.figma.com/design/X5WcaK4s20AYF53cvRdouV: 21 màn từ code HTML của Stitch, Variables và text style, 14 component set, wireframe, user flow, prototype 3 flow | 6 page theo đề | `TODO` ghi phần tôi đã mở, kiểm và sửa |
| Công cụ AI khác | `TODO` nếu có | | |

## 2. Dòng thời gian các lần chạy

| Run | Ngày | Công cụ | Đầu vào | Bằng chứng |
|---|---|---|---|---|
| R0 | 05/10/2026 | Stitch | Prompt P0 (+ `DESIGN.md` bản 1) | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` |
| R1 | 05/10/2026 | Stitch | CONTEXT + P1, P2, P3 | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` |
| R2 | 05/10/2026 | Stitch | CONTEXT + P4, P5, P6 | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` |
| R3 | 05/10/2026 (theo lời tôi, `TODO` xác nhận bằng ảnh) | Stitch | Iteration 2 (P7) | `TODO` |
| R4 | 05/10/2026 (theo lời tôi, `TODO` xác nhận bằng ảnh) | Stitch | Iteration 3 (P8) | `TODO` |
| R5 | 05/10/2026 | Stitch | P9 đến P13 (5 màn còn thiếu): Sign in, Student detail, Create team, Chat, Profile | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` |
| R6 | 05/10/2026 | Stitch | Sửa ô nhập email ở màn Sign in (cách làm: `TODO` ghi "prompt" hoặc "sửa tay") | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` |
| R7 | 06/10/2026 | Stitch | Master prompt P16 (hướng sinh viên, 22 frame). Lần đầu Stitch chỉ tạo 6 frame (Create profile, Discover, Sign in, Loading, Empty, Offline); export cuối có 22 màn (`TODO` ghi cách chạy tiếp các frame còn lại) | `assets/stitch/student-v1/` (22 màn) |
| R8 | 06/10/2026 | Không dùng công cụ AI sinh UI | Quyết định đổi hướng sang app mentor (yêu cầu mới của tôi); Claude viết lại persona, flow, `DESIGN.md` | `ux/persona.md`, `ux/user-flow.md`, `assets/flows/` |
| R9 | 07/10/2026 (theo lời tôi; `TODO` xác nhận bằng ảnh) | Stitch | `ai/stitch-prompts-r9.md`: Prompt 1 (frame 1-6), Prompt 2 (7-12), Prompt 3 (13-18), mỗi prompt một lần chạy (tôi tách vì Stitch chỉ ra khoảng 6 frame mỗi lần) | `assets/stitch/mentor-v2/` `TODO` |

Toàn bộ R0 đến R6 diễn ra trong một ngày. Giữ lịch sử commit và Figma version history trải ra nhiều ngày thật; không gộp commit.

Đặt tên file ảnh theo cột bằng chứng để người chấm truy ngược được từ log sang ảnh.

## 3. Prompt (nguyên văn)

### P0 - Initial UI (R0)

> Xác nhận: đây có phải đúng prompt bạn đã dán vào Stitch không? Nếu bạn dán bản khác (ví dụ bản đầu tiên trong chat, dùng `#F37021` và nền `#FAF7F2`) thì thay bằng bản đó. `TODO`

```text
Design a mobile app for Android, Material 3, 360 x 800 dp, portrait, light theme. App name: "TeamUp EXE". Follow the attached DESIGN.md exactly for colors, typography, spacing, shapes and component rules.

USER: FPT University students aged 20-22 from different majors (Software Engineering, AI, Marketing, International Business, Graphic Design). They must form a 4-6 person cross-major team for the EXE entrepreneurship course before the team-formation deadline. They use the phone one-handed, between classes, often on unreliable campus wifi.

PROBLEM: Students have ideas but do not know classmates from other majors who still have room in their team, so they end up in unbalanced teams or a random last-minute assignment.

CORE TASK: A student (1) creates a skills-and-availability profile, (2) discovers teams that still need their role, (3) sends a join request, (4) as a team leader, creates a team, invites candidates and sees whether the team is complete.

SIGNATURE ELEMENT: every team is shown as a "Lineup": a row of role slots. A filled slot is a solid mint square with the member's initials and a check icon. An open slot is a dashed-outline square with a role icon and the role name underneath. Status is always shown by shape, icon and text label, never color alone.

NAVIGATION: bottom navigation bar with 4 destinations: Discover, Team, Invitations, Profile (selected tab has a pill indicator, filled icon and bold label). Exactly one filled primary button per screen.

GENERATE THESE 10 SCREENS (main flow first):
1. Onboarding + sign in: short value statement, email field for FPT email, inline error "Use your @fpt.edu.vn email" when the domain is wrong.
2. Create profile: major dropdown, semester, 3-5 skill chips, role I want, availability, idea status ("I have an idea" / "Looking for an idea"). Sticky "Save profile" button.
3. Discover (tab): search/filter bar by major and missing role, list of team cards, each with team name, one-line idea, the Lineup row and the line "Needs: Marketing, Design". Include a skeleton-loading version and a "No teams match" empty state with a "Loosen filters" button.
4. Team detail: idea summary, members, Lineup with open slots, one primary button "Request to join". Include the error state "This team is already full" with 3 alternative teams.
5. Student detail: avatar initials, major, semester, skills, availability, one primary button "Invite to my team".
6. Create team: team name, idea description, "Roles needed" multi-select, primary button "Post team".
7. Invitations (tab): Received / Sent tabs, Accept and Decline on received rows, status chips with icons (Pending, Accepted, Declined). Include an empty state "No invitations yet" with a "Browse teams" button, and a snackbar "Request sent. Undo".
8. My team (tab): completeness "3 of 5 members", Lineup, missing roles, button "Find a Marketing teammate". Include the confirmation dialog "Leave this team?" with a red destructive confirm.
9. Chat: team chat with message list and input field.
10. Profile (tab): own profile summary and an "Edit profile" button.

CONTENT: use realistic Vietnamese-student data (names like Minh, Linh, Huy; majors SE, AI, Marketing, IB, Graphic Design; ideas such as "Tutor marketplace for FU students"). English UI labels. Text must tolerate Vietnamese strings that are 30% longer.

CONSTRAINTS: text contrast at least 4.5:1 (3:1 for large text and controls); touch targets at least 48 x 48 dp with 8 dp gaps; body text at least 14 sp; type roles and the 4 dp spacing scale from DESIGN.md only; one consistent outlined icon set (Material Symbols Rounded).

AVOID: purple or blue gradients, gradient text, identical icon-heading-text card grids, stock illustrations of people at laptops, emoji as icons, colored left borders on cards, shadows on cards, glassmorphism, beige or cream backgrounds, tiny text.
```

### CONTEXT (dán trước mỗi prompt màn hình, R1 đến R5)

```text
Screen for "TeamUp EXE", an Android app (360 x 800 dp, portrait, light theme) that helps FPT University students from different majors form a 4-6 person team for the EXE entrepreneurship course. Follow the attached DESIGN.md exactly.

BUILD RULES
- Use only standard Material 3 parts that Flutter has: top app bar, search bar, filter chips, filled card, list tile, tabs, navigation bar, filled button, snackbar, dialog, text field. No custom clipped shapes, no overlapping layers, no horizontal scrolling inside a card.
- Same app bar style and the same bottom navigation on every screen: Discover, Team, Invitations, Profile. The current tab is selected with a pill indicator.
- Exactly one filled button per screen, in burnt orange. Cards that open a screen have no button inside.
- Sentence case everywhere. No all-caps text, no small label above a heading, no arrows inside button text.
- Smallest text is 14 sp. Touch targets 48 dp. Spacing from the 4 dp scale only.
- Status is never color alone: always icon plus text.
- Each team shows a role row: one row of square role slots, 40 dp on cards. A filled slot is a solid mint square with the member's initials. An open slot is a dashed-outline square with a role icon. The open roles are named in one text line under the row, for example "Needs Marketing and Design". Maximum 6 slots, they must fit the card width.
- Use ONLY the text and data given in this prompt. Do not invent campuses, advisors, rooms, dates, years, badges or extra sections.
- Never use the words lineup, roster, squad, board or capstone in the UI. The course is called EXE.
- No gradients, no shadows on cards, no colored side borders, no nested cards, no emoji icons, no stock illustrations, no beige background.
```

### P1 - Discover (R1)

```text
Design the Discover screen, "Discover" tab selected.
Top app bar: title "Find a team".
Under it: a search bar with placeholder "Search teams or ideas", then one row of two filter chips: "Major" and "Role needed".
Then exactly 3 team cards in a vertical list, each tappable as a whole:
1. "Tutor Match" - "Peer tutoring marketplace for FU students". Role row: 3 filled slots (HN, QB, TL) and 2 open slots (marketing icon, design icon). Text: "Needs Marketing and Design".
2. "GreenLoop" - "Rewards for recycling in dorms". Role row: 2 filled slots (VB, KH) and 3 open slots (AI icon, marketing icon, design icon). Text: "Needs AI, Marketing and Design".
3. "FinLite" - "Budgeting app for students who live away from home". Role row: 4 filled slots (HQ, LN, TM, PA) and 1 open slot (design icon). Text: "Needs Design".
Nothing else on the screen: no banner, no counters, no tags, no buttons inside cards.
```

### P2 - Team detail (R1)

```text
Design the Team detail screen for "Tutor Match". Top app bar with back arrow and title "Tutor Match", no other actions. No bottom navigation on this screen; instead a sticky filled button at the bottom: "Request to join".
Content, in this order, as plain sections separated by spacing and thin dividers (not boxes):
1. Idea: "A peer tutoring marketplace where FU students offer and book short study sessions." (3 lines of body text)
2. Members (3 list rows, initials avatar, name, major): "Hoang Nguyen, Software Engineering", "Quoc Bao, Software Engineering", "Thao Linh, AI".
3. Open roles (2 list rows, dashed role icon, role name, one line): "Marketing - grow the first 100 users", "Graphic Design - app screens and brand".
The role row (5 slots, 48 dp, role name under each) sits directly under the app bar. Only one button on the screen.
```

### P3 - Invitations (R1)

```text
Design the Invitations screen, "Invitations" tab selected. Top app bar: title "Invitations". Tabs: "Received" and "Sent", with "Sent" active.
List of exactly 3 rows (list tiles, no cards): 
- "Tutor Match", "Applied as Software Engineering", status chip "Pending" with a clock icon.
- "AgriSense IoT", "Applied as Mobile", status chip "Accepted" with a check icon.
- "EduQuest AR", "Applied as AI", status chip "Declined" with a close icon.
At the bottom, above the navigation bar, one snackbar: "Request sent" with the action "Undo".
No banner, no nested boxes, no buttons other than the snackbar action.
```

### P4 - Create profile (R2)

```text
Create profile: app bar "Create profile". Fields in order: "Major" (dropdown), "Semester" (dropdown), "Skills" (choose 3 to 5 chips), "Role I want" (dropdown), "Availability" (text field). Sticky filled button "Save profile". Show the empty-required-field error state under "Skills": "Choose at least 3 skills".
```

### P5 - My team (R2)

```text
My team, "Team" tab selected: app bar "My team". Team name "Tutor Match". Text "3 of 5 members". The role row with 3 filled and 2 open slots (48 dp, role names under). Filled button "Find a Marketing teammate".
```

### P6 - Discover states (R2)

```text
States (one frame each, Discover): (a) loading: 3 skeleton cards; (b) empty: line icon, "No teams match your filters", button "Loosen filters"; (c) error: "You are offline. Your changes are saved." with the button "Try again".
```

### P7 - Iteration 2 (R3)

```text
On this screen, remove all text captions under the role slots. Keep one row of square role slots (48 dp) and nothing under it. The member names and open role names are already written in the lists below, so no text is lost. Do not change anything else and do not add new text.
```

### P8 - Iteration 3 (R4)

```text
Make the top of this screen follow one pattern. Tab screens (Discover, Team, Invitations, Profile): left-aligned title only, no logo icon, no subtitle line, no status bar mock; only Discover has a search icon. Nested screens: back arrow and title only.
Remove these elements if present: the chip "EXE 2025", the chip "Cached team profiles ready", the chip "Teams require 4-6 members with open roles", every "FPT University" label, the small line "EXE Entrepreneurship" above the team name, and the pill "3 of 5 members" (write it as plain title text "3 of 5 members" instead).
Replace "Fall 2024" and "Spring 2025" with "Fall 2026". Remove the arrow from the button "Save profile".
Change nothing else.
```

### P9 đến P13 - Màn còn thiếu (R5)

Sign in:

```text
Sign in, no bottom navigation. Text: app name "TeamUp EXE", one line "Find teammates from other majors for your EXE team.". Field labeled "FPT email". Filled button "Continue". Also draw the error state under the field: "Use your @fpt.edu.vn email".
```

Student detail:

```text
Student detail, nested screen: back arrow and title "Thao Linh". Initials avatar "TL", "AI, Semester 5". Section "Skills": chips "Python", "Machine learning", "Data analysis". Section "Availability": "10 hours per week". Section "Role I want": "AI Engineer". Sticky filled button "Invite to my team". No bottom navigation.
```

Create team:

```text
Create team, nested screen: back arrow and title "Create team". Fields: "Team name", "Idea" (multi-line). Section "Roles needed": chips "Marketing", "Design", "AI", "Mobile", "Backend". Sticky filled button "Post team". Also draw the error state under the chips: "Choose at least 1 role".
```

Team chat:

```text
Team chat, nested screen: back arrow and title "Tutor Match chat". 3 messages: "Welcome to the team, Linh!", "Thanks! I can start this week.", "Great, let's meet Thursday after class." Message field with placeholder "Message" and a send icon button. No filled text button, no bottom navigation.
```

Profile:

```text
Profile, "Profile" tab selected: title "Profile". Initials avatar "MN", "Minh Nguyen", "Software Engineering, Semester 5". Chips "Flutter", "Figma", "Python". Line "15 hours per week". Filled button "Edit profile".
```

### P14 - Sửa email màn Sign in (R6)

`TODO` Nếu bạn dùng prompt: chép nguyên văn vào đây (nếu bạn dùng đúng P14a trong `ai/stitch-prompts-v2.md` thì chép bản đó). Nếu bạn sửa tay trong Stitch: ghi "sửa tay, không dùng prompt" và nêu chữ nhãn, chữ gợi ý và thông báo lỗi mới của ô email.

### P16 - Master prompt, tạo lại toàn bộ 22 frame (R7, chưa chạy)

Nguồn: `ai/stitch-prompt-master.md`. Chép lại đúng bản bạn dán vào Stitch (nếu bạn tách thành 3 đoạn, ghi từng đoạn). Danh sách frame: 1 Sign in, 2 Create profile, 3 Discover, 4 Discover - Loading, 5 Discover - Empty, 6 Discover - Offline, 7 Team detail, 8 Team detail - Join dialog, 9 Team detail - Team full, 10 Student detail, 11 Student detail - Invite dialog, 12 Create team, 13 My team, 14 My team - Empty, 15 My team - Complete, 16 My team - Leave dialog, 17 Invitations - Sent, 18 Invitations - Received, 19 Invitations - Accepted, 20 Invitations - Declined, 21 Team chat, 22 Profile.

```text
HEADER
Generate ALL of the frames listed below in this project, each as its own separate 360 x 800 dp Android frame (Material 3, light theme), for the app "TeamUp EXE": students from different majors find and complete a 4-6 person EXE team. Replace any previous version of these screens. Use ONLY the text given. Do not invent text, names, dates, banners, badges, helper sentences or extra sections. Never use the words lineup, roster, squad, board, capstone.

DESIGN SYSTEM (follow exactly)
Colors: screen and cards white #FFFFFF; cards have a 1 dp border #D6D4CE and no tinted fill and no shadow; text #1C1B18; secondary text #55534D; filled button and active tab indicator burnt orange #B23E00 with white text; selected chip and active navigation pill #FFE2D2 with text #3B1400; unselected chips and tonal buttons fill #E9E7E2 with text #1C1B18 and a 1 dp border #D6D4CE; filled role slot fill #D6F0DD with initials #07301A and a 1 dp border #1B6B3C; open role slot white with a 2 dp dashed outline #77756F and a role icon; text fields fill #F3F2EF with a 1 dp border #77756F; error #B3261E on #F9DEDC; snackbar #2F2E2A with white text. NO blue anywhere, no gradients, no shadows on cards, no colored side borders, no nested cards, no glass, no emoji icons.
Type: Be Vietnam Pro. Headline 24 sp bold, title 20 sp semibold, card title 16 sp semibold, body 16 sp, metadata 14 sp, button and chip 14 sp semibold. Nothing smaller than 14 sp. Sentence case, no all caps, no arrows in button text.
Layout: 16 dp side margins, 4 dp spacing scale, cards radius 12, fields radius 8, buttons and chips pill, buttons 48 dp high, touch targets 48 dp, one icon set (Material Symbols Rounded, outlined).
Components: top app bar with a left-aligned title only (nested screens: back arrow and title); no logo, no subtitle, no status bar mock, no help icon. Bottom navigation bar with 4 tabs Discover, Team, Invitations, Profile, the current tab with a pill indicator, filled icon and bold label; nested screens and dialogs have no bottom navigation unless stated. Exactly one filled primary button per screen. Every status uses icon plus text label, never color alone. Role row = one row of 40 dp square role slots on cards (48 dp on detail screens), maximum 5, no captions under slots. Dialogs are Material 3 dialogs centered on a dimmed copy of the screen behind.
Copy rule: screen title max 3 words, button max 3 words, list row = one main line plus at most one short secondary line, no helper sentences, errors max 5 words. Majors may be shortened to SE, AI, MKT, GD.

FRAME LIST
1. "Sign in": no navigation. Title "Sign in". Text "Find teammates across majors". Field label "Email", placeholder "you@gmail.com". Button "Continue".
2. "Create profile": back arrow, title "Create profile". Fields: "Major" (Software Engineering), "Semester" (Fall 2026), "Skills" (chips Flutter selected, Figma, Marketing, Node.js, Python), "Role" (Mobile), "Availability" (15 h/week). Error under Skills: "Pick 3 skills". Sticky button "Save profile". No navigation.
3. "Discover": tab Discover, title "Find a team" with a search icon. Search field "Search teams". Filter chips "Major", "Role". Exactly 3 tappable team cards, each with team name, one idea line of at most 6 words, the role row, and a line with a small add-person icon and the open roles. Cards: "Tutor Match" - "Peer tutoring for FU students" - 3 filled (HN, QB, TL), 2 open (marketing icon, design icon) - "Marketing, Design". "GreenLoop" - "Rewards for recycling in dorms" - 2 filled (VB, KH), 3 open (AI, marketing, design icons) - "AI, Marketing, Design". "FinLite" - "Budgeting for students away from home" - 4 filled (HQ, LN, TM, PA), 1 open (design icon) - "Design".
4. "Discover - Loading": same app bar, search and chips as frame 3, then 3 skeleton cards (blocks #F3F2EF on white bordered cards).
5. "Discover - Empty": same app bar and search with the text "EdTech" and two active filter chips "AI", "Marketing" with a close icon each. Centered line icon, headline "No teams found", button "Clear filters".
6. "Discover - Offline": same app bar and search. Centered offline icon, headline "You're offline", button "Try again".
7. "Team detail": back arrow, title "Tutor Match", no navigation. Role row of 5 slots at 48 dp (HN, QB, TL filled; marketing and design open). One idea line "Peer tutoring where FU students book short sessions". Section "Members": rows with initials avatar, name, short major: "Hoang Nguyen, SE", "Quoc Bao, SE", "Thao Linh, AI". Section "Open roles": rows with dashed icon and role name: "Marketing", "Graphic Design". Sticky filled button "Request to join".
8. "Team detail - Join dialog": frame 7 dimmed, dialog "Send request?", body "They will see your profile.", buttons "Cancel" (text) and "Send" (filled).
9. "Team detail - Team full": back arrow, title "FinLite". Role row of 5 filled slots (HQ, LN, TM, PA, NB). Alert icon with "Team is full". Line "Try these instead". 3 plain list rows: "Tutor Match - Marketing, Design", "GreenLoop - AI, Marketing, Design", "RecycleChain - Marketing". Disabled sticky button "Full".
10. "Student detail": back arrow, title "Mai Pham", no navigation. Initials avatar MP, "MKT, S5". Section "Skills": chips "Social media", "Branding", "Writing". Section "Availability": "12 h/week". Section "Role": "Marketing Lead". Sticky filled button "Invite".
11. "Student detail - Invite dialog": frame 10 dimmed, dialog "Send invite?", body "They will see your team.", buttons "Cancel" and "Send".
12. "Create team": back arrow, title "Create team", no navigation. Fields "Team name" and "One-line idea" (multi-line), section "Roles needed" with chips "Marketing", "Design", "AI", "Mobile", "Backend". Error under chips: "Pick a role". Sticky filled button "Post team".
13. "My team": tab Team, title "My team". Card with "Tutor Match" and "3 of 5". Role row of 5 slots at 48 dp (HN, QB, TL filled; marketing and design open). Section "Members": rows "Hoang Nguyen, SE" with a "Leader" chip, "Quoc Bao, SE", "Thao Linh, AI". Filled button "Find Marketing". A text button "Leave team" in the error color at the bottom of the content.
14. "My team - Empty": tab Team, title "My team". Centered line icon, headline "No team yet", filled button "Create team", text button "Browse".
15. "My team - Complete": tab Team, title "My team". Card "Tutor Match" and "5 of 5". Role row of 5 filled slots (HN, QB, TL, MP, MA). Check icon with "Complete". Members rows: "Hoang Nguyen, SE", "Quoc Bao, SE", "Thao Linh, AI", "Mai Pham, MKT", "Minh Anh, GD". Filled button "Open chat".
16. "My team - Leave dialog": frame 13 dimmed, destructive dialog "Leave team?", body "You can request again later.", buttons "Stay" (text) and "Leave" (filled, error color).
17. "Invitations - Sent": tab Invitations, title "Invitations", tabs "Received" and "Sent" with Sent active. 3 plain list rows (no cards): "Tutor Match", "SE", chip "Pending" with clock icon; "AgriSense IoT", "Mobile", chip "Accepted" with check icon; "EduQuest AR", "AI", chip "Declined" with close icon. Snackbar above the navigation bar: "Sent" with action "Undo".
18. "Invitations - Received": same header with Received active and a badge "2" on the tab. 2 plain rows: "GreenLoop", "AI"; "FinLite", "Design". Each row has a text button "Decline" and a tonal button "Accept". No filled button.
19. "Invitations - Accepted": Sent tab. 2 rows: "Mai Pham", "MKT", chip "Accepted" with check icon; "Minh Anh", "GD", chip "Pending" with clock icon. Snackbar "Accepted" with action "Chat".
20. "Invitations - Declined": Sent tab. 2 rows: "Mai Pham", "MKT", chip "Declined" with close icon; "Minh Anh", "GD", chip "Pending" with clock icon. Snackbar "Declined" with action "Find".
21. "Team chat": back arrow, title "Tutor Match chat", no navigation. 3 message bubbles: incoming "Welcome to the team, Mai!", outgoing (burnt orange, white text) "Thanks! I can start this week.", incoming "Great, let's meet Thursday.". Bottom message field with placeholder "Message" and a send icon button.
22. "Profile": tab Profile, title "Profile". Initials avatar MN, "Minh Nguyen", "SE, S5". Chips "Flutter", "Figma", "Python". "15 h/week". Filled button "Edit".
```

## 4. Output của Stitch (quan sát từ ảnh chụp)

**R0 (P0).** Stitch sinh được 4 màn: Discover, Find a team, Team detail "Tutor Match", Invitations. Vấn đề quan sát được: ngôn ngữ nội bộ "Lineup", "Roster", "Squad", "capstone" xuất hiện trong chữ trên UI; năm "Spring 2025"; dữ liệu không có trong prompt (cố vấn, số phòng, "Binh Thuan"); nhãn IN HOA và chữ rất nhỏ; thanh trên cùng và nhãn tab khác nhau giữa 4 màn ("My Team" thay vì "Team"); nhiều nút cạnh tranh nhau; thẻ lồng thẻ, viền màu bên trái; ô vai trò bị cắt ở mép.

**R1 (P1 đến P3).** Discover có 3 thẻ, hàng ô vai trò vừa chiều rộng, dòng "Needs ...". Team detail có nút "Request to join" duy nhất, nhưng chú thích dưới ô vai trò đè lên nhau. Invitations có chip trạng thái kèm icon, snackbar "Request sent / Undo".

**R2 (P4 đến P6).** Create profile có lỗi "Choose at least 3 skills" (icon và chữ), nhưng có chip "FPT University", học kỳ "Fall 2024", nút "Save profile" kèm mũi tên. My team có dòng nhỏ "EXE Entrepreneurship", pill "3 of 5 members", chú thích ô bị cắt ("Lead...", "Full St..."). Loading dùng 3 skeleton. Offline và empty có thông điệp, nguyên nhân và nút hành động, nhưng có thêm chip thừa ("EXE 2025", "Cached team profiles ready", "Teams require 4-6 members with open roles").

**Sau R5 (13 màn trong project, ảnh chụp toàn project ngày 05/10/2026).** Project có thêm 5 màn: Sign in, Student detail ("Thao Linh"), Create team, Chat ("Tutor Match chat"), Profile ("Minh Nguyen"). Stitch cũng tự tạo một tile design system tên "The Lineup Board" (tên cũ của North Star trong `DESIGN.md` bản 1) và vẫn giữ một màn Discover cũ có chữ "Explore Lineup Boards". Cần nhập lại `DESIGN.md` bản 2 và xóa màn cũ.

**R6.** Ô nhập email ở màn Sign in không còn yêu cầu tên miền `@fpt.edu.vn`. Chữ mới trên màn hình: `TODO` (nhãn, gợi ý, thông báo lỗi).

**R7 (P16).** `TODO` sau khi chạy: số frame Stitch tạo được / 22, frame nào thiếu, còn tông xanh dương hay không, chữ có dưới 14 sp không, mỗi màn còn đúng một nút chính không.

**R10 (một prompt trong `ai/stitch-prompts-r10.md`).** Sau khi đối chiếu flow với 18 màn, tôi thấy thiếu 3 trạng thái (email sai ở Flow A; nhóm ghép tay và tìm không ra SV ở Flow C). Prompt dùng lại khối HEADER + DESIGN SYSTEM của R9 và yêu cầu đúng 3 frame. Prompt nguyên văn nằm trong file đó. Kết quả: 3 màn S19-S21 đã đưa vào Figma (page 02, 03, 06) và flow. `TODO` ghi nhận xét sau khi xem ảnh Stitch: chip và nút bị xuống dòng trên ảnh S20, S21 (bản dựng Figma không bị).

**R9 (ba prompt trong `ai/stitch-prompts-r9.md`).** Tôi xuất project Stitch sang Figma bằng plugin; file Figma có 18 frame đúng S1-S18 (tên frame trùng danh sách). Quan sát khi đọc file bằng script (ngày 07/10/2026): không có từ cấm, không có tông xanh dương, chữ hầu hết ≥ 14 sp. Lỗi: S4 có banner, "5 available" và khối "Allocation balance" không có trong prompt; S17 có màn nền sai (tiêu đề "EXE Startup Course", tên và vai trò bịa, chữ 12 sp); S9 badge "3" cỡ 10 sp; S2, S12, S13 cao hơn 800 dp. Chi tiết ở `ai/ai-critique-2.md`. Bằng chứng ảnh: `assets/stitch/mentor-v2/` `TODO`.

Số màn khác nhau trước R5: 5 (Discover, Team detail, Invitations, Create profile, My team) cộng 3 state. Cần tối thiểu 8 màn khác nhau, nên R5 là bắt buộc.

## 5. AI critique

### Critique A - trên ảnh R0

- Yêu cầu của tôi (nguyên văn): `these image feel every AI slop, using /impeccable:impeccable to design another promt help me fixing these look that working well with flutter app`
- Người trả lời: Claude, theo quy trình `critique` của skill `impeccable`, chạy ở chế độ một ngữ cảnh (không có sub-agent, không chạy được detector trên ảnh). Câu trả lời đầy đủ, chép lại:

| Nhóm | Lỗi |
|---|---|
| Không nhất quán | 4 màn có 4 kiểu app bar khác nhau. Tab ghi "My Team" thay vì "Team". Kích thước khung không đều. |
| Quá tải nội dung | Banner "MAJOR MATCHED", dải "Spring 2025 Roster Status", hàng tag (Mentor Approved, FPT Da Nang, Education Tech), khối Advisor có số phòng. |
| Chữ | Nhiều nhãn IN HOA, chữ rất nhỏ (trái quy tắc 14 sp), nút "REQUEST TO JOIN" viết hoa kèm mũi tên. |
| Phân cấp | Nhiều nút cạnh tranh trên một màn: Quick apply, View Lineup, Tap to view team, Open Chat, Undo. |
| Cấu trúc | Thẻ lồng thẻ ("Squad Composition" trong thẻ ứng tuyển), thẻ "Looking For" có viền màu bên trái. |
| Sai nghiệp vụ | Dùng "capstone" thay vì EXE, "Spring 2025" trong khi hiện tại là tháng 10/2026. |
| Khó dựng bằng Flutter | Hàng ô vai trò bị cắt ở mép phải thẻ, snackbar đè lên nội dung. |

Hạn chế: Critique A không gắn tên heuristic Nielsen cho từng lỗi. Dùng Critique B làm bản chính cho rubric.

### Critique B - trên ảnh R1 và R2

- Yêu cầu của tôi: gửi ảnh R1 và R2 để Claude đánh giá (không có chữ kèm). `TODO` thay bằng prompt bạn thực sự dùng nếu bạn hỏi lại bằng một prompt rõ hơn, ví dụ "Review these screens against Nielsen's 10 heuristics, WCAG 2.1 and my persona. List at least 5 findings, each tied to a named screen."
- Người trả lời: Claude. Câu trả lời đầy đủ (cùng nội dung `ai/ai-critique-1.md`):

| # | Screen | Finding | Criterion | Severity |
|---|---|---|---|---|
| 1 | Team detail | Captions under the role slots overlap and collide ("Software Engineering" overprints its neighbour, "Marketing" touches "Graphic Design"). | H8 Aesthetic and minimalist design; WCAG 1.4.4 legibility; persona reads in seconds | High |
| 2 | My team | Slot captions are truncated ("Lead...", "Full St...") and use role titles that were not defined. A small line "EXE Entrepreneurship" sits above the team name and a pill repeats "3 of 5 members". | H2 Match with real world; H8 | Medium |
| 3 | Discover, Invitations, Create profile, offline, empty | The top of the screen changes between screens: logo icon, subtitle line, status bar mock, search icon only on some tab screens. | H4 Consistency and standards | High |
| 4 | Discover loading, offline, empty, Create profile | Extra metadata chips nobody asked for: "EXE 2025", "Cached team profiles ready", "Teams require 4-6 members with open roles", "FPT University". Stale years: "Fall 2024", "Spring 2025". | H8; H2 | Medium |
| 5 | Create profile | The button label carries an arrow glyph ("Save profile"). Six fields plus helper text make the form long for one-handed use. | H4; H7 Flexibility and efficiency; persona goal: profile under 90 s | Medium |
| 6 | Invitations | List rows give no sign that they open anything, and the Received tab shows no count, so the user cannot see what needs action. | H1 Visibility of system status; H6 Recognition rather than recall | Medium |
| 7 | Discover cards, tabs, captions | Idea text is blue on a blue-grey card and several captions look under 14 sp. | WCAG 1.4.3 and lab rule 14 sp minimum (needs measuring) | To verify |
| 8 | Offline, empty, Create profile error | Strength: each message states the problem, the cause and a recovery action, and the error pairs an icon with text. | H9 Help users recover from errors | Positive |

Lưu ý: dòng 7 là ước lượng bằng mắt, cần đo số trong Figma (tương phản 4.5:1 cho chữ thường, 3:1 cho chữ lớn và control).

### Critique C - phản biện persona (13/10/2026)

- Yêu cầu của tôi (nguyên văn): xem `ai/ai-critique-3.md`, mục đầu.
- Claude chấm persona cũ khoảng 41/100 theo checklist của guideline, sau khi sửa khoảng 67/100 (ước lượng, chưa có giảng viên chấm). Phát hiện chính: nhóm phải là 5-6 chứ không phải 4-6, thiếu import và lọc tự động, AI không có dữ liệu kỹ năng và lịch, thiếu 5/12 trường lõi, chưa có bằng chứng thật.
- Tôi giữ: 1 persona chính (kèm giải trình), quy tắc 5-6, dữ liệu import 5 cột; "kỹ năng" chỉ là ngành (Major), bỏ kỹ năng và lịch.
- Vòng 2 (13/10/2026, mục 6-8 của `ai/ai-critique-3.md`): Claude rà màn hình, tự phản biện 8 phát hiện nháp, giữ lại đề xuất **thêm 4 màn** (S22 Import, S23 Import result, S24 Remove member dialog, S25 Approve blocked) và **sửa 4 màn** (S03, S05, S07, S10: bỏ chữ skills/availability, thêm chip trạng thái, nút bỏ thành viên). Chưa dựng gì trong Figma; chờ tôi duyệt và xác nhận cách hiểu "không cần AI".
- Tôi chưa làm: phỏng vấn, Affinity Board, dựng 4 màn mới.

## 6. Decision record

Điền cột 2 và 3 bằng suy nghĩ của bạn. Lý do hợp lệ phải nhắc tới persona (Minh), một heuristic, hoặc một ràng buộc thật (phạm vi, thời gian, nền tảng). Cột "Gợi ý lý do" chỉ là bản nháp để bạn tham khảo, giữ lại chỉ khi bạn đồng ý.

| # | Finding | Accepted / modified / rejected | Lý do của tôi | Gợi ý lý do (nháp) | Thể hiện trong Figma ở đâu |
|---|---|---|---|---|---|
| 1 | Chú thích ô vai trò đè chữ (Team detail) | `TODO` | `TODO` | Minh đọc nhanh bằng một tay, chữ chồng nhau làm mất thông tin (H8, WCAG 1.4.4); tên đã có ở danh sách bên dưới nên bỏ chú thích không mất nội dung. | `TODO` |
| 2 | Chữ bị cắt, nhãn thừa ở My team | `TODO` | `TODO` | Dùng đúng tên vai trò đã định nghĩa (H2); giảm nhiễu để thấy ngay "còn thiếu ai". | `TODO` |
| 3 | Thanh trên cùng không nhất quán | `TODO` | `TODO` | H4 nhất quán; app bar giống nhau giúp component App bar trong Figma chỉ cần hai biến thể. | `TODO` |
| 4 | Chip và năm thừa | `TODO` | `TODO` | H8 tối giản; dữ liệu không có thật (năm cũ) làm người dùng nghi ngờ độ tin cậy. | `TODO` |
| 5 | Nút kèm mũi tên, form dài | `TODO` | `TODO` | H4; mục tiêu tạo hồ sơ dưới 90 giây (tiêu chí thành công trong persona). | `TODO` |
| 6 | Hàng Invitations thiếu tín hiệu bấm được, tab thiếu số lượng | `TODO` | `TODO` | H1 hiển thị trạng thái; Minh cần biết lời mời nào chờ mình. Ràng buộc: thêm badge số ở tab trong phạm vi lab. | `TODO` |
| 7 | Tương phản chữ ý tưởng và caption | `TODO` | `TODO` | Lab yêu cầu 4.5:1 và 14 sp; đo trong Figma rồi quyết định. | `TODO` |
| 8 | **Do tôi tự phát hiện (không phải của AI):** màn Sign in yêu cầu email `@fpt.edu.vn`, trong khi sinh viên FPT từ khóa của tôi không còn được cấp email edu | Áp dụng (đã sửa ở R6) | Từ khóa nhập học của tôi, sinh viên FPT không còn email edu, nên yêu cầu `@fpt.edu.vn` không dùng được với người dùng thật (ràng buộc thực tế; thông tin từ tôi, chưa xác minh độc lập). `TODO` bổ sung heuristic: H2 Match between system and real world | Lấy từ lời tôi | Màn Sign in `TODO` |
| 9 | **Do tôi tự phát hiện:** màu xanh dương làm UI giống sản phẩm sinh tự động; tôi đo lại thì nền thẻ so với nền màn hình chỉ 1.07:1, chip xanh trên thẻ khoảng 1.1:1 | Áp dụng qua P16 (R7), `TODO` xác nhận sau khi chạy | `TODO` | Lý do nháp: persona Minh đọc ngoài trời nên cần tách lớp rõ (WCAG 1.4.11 cho viền control); bảng màu cũ có tông xanh khác thương hiệu cam; bảng bản 2 giữ chữ đạt 1.4.3. Nếu R7 không chạy hoặc kết quả kém hơn, đổi thành "không áp dụng" và ghi lý do thật. | Variables màu ở Figma page 04, mọi màn hình |

| 10 | **Do tôi quyết định:** đổi người dùng chính từ sinh viên sang mentor/giảng viên; AI ghép sinh viên chưa có nhóm vào nhóm thiếu 1-2 thành viên chuyên môn | Áp dụng (R8, 06/10/2026) | Lý do theo lời tôi: các lớp của giảng viên có nhiều sinh viên chưa có nhóm hoặc nhóm thiếu chuyên môn, mentor cần công cụ ghép nhanh. `TODO` bổ sung 1-2 câu của bạn (đã hỏi giảng viên chưa?). Gợi ý: persona mới là Cô Lan, tiêu chí duyệt một lớp dưới 5 phút. | Persona, 3 flow, 18 màn, `DESIGN.md` (thanh điều hướng 3 tab, hàng ngành, nhãn mức phù hợp) |

| 11 | S4 chữ bịa (critique 2, #1) | Accepted | Mentor chỉ có vài phút; chữ không có trong dữ liệu làm hiểu sai (soạn giúp, cần đọc lại). | H8; mentor chỉ có vài phút, không cần chữ giải thích không có trong dữ liệu | Đã sửa trong Figma 07/10/2026 |
| 12 | S17 màn nền sai (critique 2, #2) | Accepted | Dialog phải mở trên đúng màn S10 (soạn giúp, cần đọc lại). | H4 nhất quán với S10; dialog phải mở trên đúng màn | Đã sửa trong Figma 07/10/2026 |
| 13 | S9 badge 10 sp, frame sai kích thước, tên layer (critique 2, #3-5) | Accepted | Là luật của lab và cần cho handoff (soạn giúp, cần đọc lại). | Luật 14 sp và 360 × 800 của lab | Đã sửa khi dựng lại Final UI (11/10/2026): 21 frame 360 × 800, 0 chữ dưới 14 sp, layer có tên |

## 7. Iteration

Mỗi iteration phải nhắm một vấn đề có tên, khác các lần khác, có ảnh trước và sau.

| Iter | Vấn đề có tên | Prompt | Before | After | Kết quả và quyết định của tôi |
|---|---|---|---|---|---|
| 1 (đã làm, R0 sang R1) | Quá tải nội dung, không nhất quán, chữ nhỏ, từ vựng nội bộ lọt vào UI, dữ liệu bịa | CONTEXT + P1 đến P3 | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` | Nguyên nhân một phần nằm ở prompt P0 của tôi: dùng ẩn dụ "Lineup" và yêu cầu 10 màn trong một lần, nên Stitch đưa từ nội bộ lên UI và nén quá nhiều nội dung. `TODO` kết luận của bạn |
| 2 (R3, theo lời tôi đã chạy; `TODO` xác nhận ảnh) | Chú thích dưới ô vai trò đè và cắt chữ | P7 | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") | `TODO` | `TODO`. Ghi chú: một phần do prompt R1 yêu cầu "role name under each" với 5 ô 48 dp, không vừa chiều rộng nội dung khoảng 296 dp |
| 3 (R4, theo lời tôi đã chạy; `TODO` xác nhận ảnh) | Thanh trên cùng không nhất quán và metadata thừa | P8 | `TODO` | `TODO` | `TODO` |
| 4 (R6) | Email `@fpt.edu.vn` không còn đúng thực tế (sinh viên không có email edu) | P14 `TODO` | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` | Vấn đề do tôi tự phát hiện. `TODO` kết luận |
| 5 (R7, chạy một phần) | Quá nhiều chữ trên mỗi màn (persona Minh một tay, H8, H6), tông xanh dương và độ tách lớp thấp, thiếu 10 frame cho 3 flow | P16 | (ảnh vòng này không còn trong repo; `TODO` tìm lại từ Stitch hoặc ghi "không lưu") `TODO` | `assets/stitch/student-v1/` `TODO` | `TODO` kết luận sau khi chạy. Nguyên nhân phía tôi: bảng màu bản 1 chỉ kiểm tra tương phản chữ, bỏ qua tương phản giữa các lớp |
| 6 (R8-R9) | Đổi hướng sang mentor, cần 18 frame mới theo 3 flow | `ai/stitch-prompts-r9.md` (3 prompt) | `assets/stitch/student-v1/` (hướng sinh viên) | `assets/stitch/mentor-v2/` `TODO` | `TODO` kết luận. Ghi rõ AI trong lab chỉ là thiết kế với dữ liệu mẫu, không có mô hình thật |
| 7 (R9 → Figma) | S4 có chữ Stitch tự thêm (banner, số lượng, khối cân bằng) | Không dùng prompt: sửa tay trong Figma do Claude thực hiện theo yêu cầu của tôi | `assets/stitch/mentor-v2/s04-no-team/screen.png` | `assets/figma/03-final-ui/s04-no-team.png` | Xóa 3 khối, danh sách còn 5 hàng đúng prompt |
| 8 (R9 → Figma) | S17 nền dialog sai | Sửa tay trong Figma (thay bằng bản sao S10) | `assets/stitch/mentor-v2/s17-discard-dialog/screen.png` | `assets/figma/03-final-ui/s17-discard-dialog.png` | Dialog đúng chữ prompt, nền khớp S10 |

## 8. Kiểm tra trung thực trước khi nộp

- [ ] Mọi prompt trong mục 3 đúng là thứ tôi đã dán vào Stitch (P0 đã xác nhận).
- [ ] Mỗi run có ảnh trong `assets/stitch/` và tên file khớp mục 2.
- [ ] Các ô `TODO` đã được điền bằng kết quả thật hoặc xóa kèm lý do.
- [ ] Decision record có lý do của riêng tôi, không chép nguyên cột "Gợi ý".
- [ ] Tôi giải thích được ít nhất 2 quyết định và demo được 1 flow nếu bị hỏi 5 phút.
- [ ] `design/DESIGN.md`, `ux/user-flow.md`, 3 flow và UI Stitch (v5, R9, R10) khớp nhau (21 màn S1-S21). Không có trường MSSV ở màn đăng nhập; MSSV chỉ nằm trong dữ liệu import giả định (xem `ux/persona.md`); xác minh sinh viên ngoài phạm vi lab.
- [ ] Log nói rõ AI ghép nhóm trong lab chỉ là thiết kế giao diện với dữ liệu mẫu, không phải mô hình đã huấn luyện.
- [ ] Bảng khai báo công cụ đã gồm mọi AI tôi dùng, kể cả ngoài Stitch.
