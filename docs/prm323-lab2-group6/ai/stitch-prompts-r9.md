# Stitch prompts R9 (mentor app): 18 frame, 3 prompt, mỗi prompt 6 frame

Một file duy nhất. Chạy lần lượt Prompt 1, 2, 3 trong cùng project Stitch (đã có sẵn design system v2). Mỗi prompt tạo đúng 6 frame, chờ xong rồi mới chạy prompt kế.

Lưu ý khi ghi log (`ai/ai-design-log.md`): ghi mỗi prompt là một lần chạy, dán nguyên văn đúng chữ bạn đã chạy, và ghi trung thực nếu bạn sửa chữ trước khi chạy.

Kiểm sau mỗi prompt: đúng 6 frame; không có từ lineup/roster/squad/board/capstone/position; không xanh dương; chữ không nhỏ hơn 14 sp; mỗi màn tối đa 1 nút đặc (filled).

## Prompt 1 - frame 1-6

```text
HEADER
Generate EXACTLY the 6 frames listed below (no more, no fewer), each as its own separate 360 x 800 dp Android frame (Material 3, light theme), for the app "TeamUp EXE": a tool for a university mentor (lecturer) of the EXE startup course. AI suggests how to place students who have no team into small startup teams that miss 1-2 specialist members, so each team reaches 4-6 members from different majors. The mentor reviews and approves. Keep the visual style of this project's existing design system. Ignore the older student-facing frames. Use ONLY the text given. Do not invent text, names, dates, banners, badges, helper sentences or extra sections. Never use the words lineup, roster, squad, board, capstone, position.

DESIGN SYSTEM (follow exactly)
Colors: screen and cards white #FFFFFF; cards have a 1 dp border #D6D4CE, no tinted fill, no shadow; text #1C1B18; secondary text #55534D; filled button and active indicator burnt orange #B23E00 with white text; selected chip and active navigation pill #FFE2D2 with text #3B1400; unselected chips and tonal buttons fill #E9E7E2 with text #1C1B18 and a 1 dp border #D6D4CE; error #B3261E on #F9DEDC; success and filled #1B6B3C on #D6F0DD; text fields fill #F3F2EF with a 1 dp border #77756F; snackbar #2F2E2A with white text. NO blue anywhere, no gradients, no shadows on cards, no colored side borders, no nested cards, no glass, no emoji icons.
Major row (signature component): one row of square slots, 40 dp on cards and 48 dp on detail screens, maximum 6, no captions under slots. Filled slot: fill #D6F0DD, 1 dp border #1B6B3C, the major code (SE, AI, MKT, GD) in #07301A. Open slot: white, 2 dp dashed outline #77756F, a small major icon. Proposed slot (what the AI suggests): fill #FFE2D2, 2 dp solid outline #B23E00, the major code in #3B1400, a small plus mark in the corner.
Type: Be Vietnam Pro. Headline 24 sp bold, title 20 sp semibold, card title 16 sp semibold, body 16 sp, metadata 14 sp, button and chip 14 sp semibold. Nothing smaller than 14 sp. Sentence case, no all caps, no arrows in button text. Numbers use tabular figures.
Layout: 16 dp side margins, 4 dp spacing scale, cards radius 12, fields radius 8, buttons and chips pill, buttons 48 dp high, touch targets 48 dp, one icon set (Material Symbols Rounded, outlined).
Components: top app bar with a left-aligned title only (nested screens: back arrow and title); no logo, no subtitle, no status bar mock, no help icon. Bottom navigation bar with 3 tabs Classes, Proposals, Profile, the current tab with a pill indicator, filled icon and bold label; nested screens, dialogs and the loading screen have no bottom navigation unless stated. At most one filled primary button per screen. Every status uses icon plus text label, never color alone. Fit chips: "Strong fit" with a check icon (green), "Good fit" with a half-circle icon (stone). Dialogs are Material 3 dialogs centered over a dimmed copy of the screen behind.
Copy rule: screen title max 3 words, button max 3 words, list row = one main line plus at most one short secondary line, no helper sentences, errors max 5 words.

FRAME LIST
1. "Sign in": no navigation. Title "Sign in". Text "Build balanced teams". Field label "Email", placeholder "you@gmail.com". Button "Continue".
2. "My classes": tab Classes, title "My classes". 3 tappable cards, each with the class name, the student count and two status lines with an icon: "Class A" - "42 students" - "12 without team" and "5 teams need members"; "Class B" - "38 students" - "0 without team" and a check icon with "All matched"; "Class C" - "45 students" - "9 without team" and "3 teams need members".
3. "Class detail": back arrow, title "Class A", no navigation. One row of three plain stats separated by hairlines, number 24 sp bold with a 14 sp label: "42" "students", "12" "without team", "5" "need members". Two plain list rows with a chevron: "Students without team" and "Teams needing members". Sticky filled button "Match with AI".
4. "No team": back arrow, title "No team", no navigation. Filter chips "All", "SE", "AI", "MKT", "GD" with "All" selected. 5 plain rows with an initials avatar, name, and a secondary line: "Mai Pham" "MKT, S5"; "Minh Anh" "GD, S5"; "Khoa Tran" "SE, S5"; "Lan Vo" "AI, S6"; "An Do" "MKT, S5". Sticky filled button "Match with AI".
5. "Need members": back arrow, title "Need members", no navigation. 3 cards. "Tutor Match": major row of 5 slots at 40 dp, 4 filled (SE, SE, AI, SE) and 1 open (design icon); line "Needs Design". "GreenLoop": 3 filled (SE, AI, GD), 2 open (marketing icon, SE icon); line "Needs MKT, SE". "FinLite": 4 filled (SE, SE, MKT, GD), 1 open (AI icon); line "Needs AI".
6. "Profile": tab Profile, title "Profile". Initials avatar LN, name "Lan Nguyen", line "Mentor, 3 classes". Two plain rows: "Notifications" with a switch, "Language" with the value "English". Tonal button "Sign out".
```

## Prompt 2 - frame 7-12

```text
HEADER
Generate EXACTLY the 6 frames listed below (no more, no fewer), each as its own separate 360 x 800 dp Android frame (Material 3, light theme), for the app "TeamUp EXE": a tool for a university mentor (lecturer) of the EXE startup course. AI suggests how to place students who have no team into small startup teams that miss 1-2 specialist members, so each team reaches 4-6 members from different majors. The mentor reviews and approves. Keep the visual style of this project's existing design system. Ignore the older student-facing frames. Use ONLY the text given. Do not invent text, names, dates, banners, badges, helper sentences or extra sections. Never use the words lineup, roster, squad, board, capstone, position.

DESIGN SYSTEM (follow exactly)
Colors: screen and cards white #FFFFFF; cards have a 1 dp border #D6D4CE, no tinted fill, no shadow; text #1C1B18; secondary text #55534D; filled button and active indicator burnt orange #B23E00 with white text; selected chip and active navigation pill #FFE2D2 with text #3B1400; unselected chips and tonal buttons fill #E9E7E2 with text #1C1B18 and a 1 dp border #D6D4CE; error #B3261E on #F9DEDC; success and filled #1B6B3C on #D6F0DD; text fields fill #F3F2EF with a 1 dp border #77756F; snackbar #2F2E2A with white text. NO blue anywhere, no gradients, no shadows on cards, no colored side borders, no nested cards, no glass, no emoji icons.
Major row (signature component): one row of square slots, 40 dp on cards and 48 dp on detail screens, maximum 6, no captions under slots. Filled slot: fill #D6F0DD, 1 dp border #1B6B3C, the major code (SE, AI, MKT, GD) in #07301A. Open slot: white, 2 dp dashed outline #77756F, a small major icon. Proposed slot (what the AI suggests): fill #FFE2D2, 2 dp solid outline #B23E00, the major code in #3B1400, a small plus mark in the corner.
Type: Be Vietnam Pro. Headline 24 sp bold, title 20 sp semibold, card title 16 sp semibold, body 16 sp, metadata 14 sp, button and chip 14 sp semibold. Nothing smaller than 14 sp. Sentence case, no all caps, no arrows in button text. Numbers use tabular figures.
Layout: 16 dp side margins, 4 dp spacing scale, cards radius 12, fields radius 8, buttons and chips pill, buttons 48 dp high, touch targets 48 dp, one icon set (Material Symbols Rounded, outlined).
Components: top app bar with a left-aligned title only (nested screens: back arrow and title); no logo, no subtitle, no status bar mock, no help icon. Bottom navigation bar with 3 tabs Classes, Proposals, Profile, the current tab with a pill indicator, filled icon and bold label; nested screens, dialogs and the loading screen have no bottom navigation unless stated. At most one filled primary button per screen. Every status uses icon plus text label, never color alone. Fit chips: "Strong fit" with a check icon (green), "Good fit" with a half-circle icon (stone). Dialogs are Material 3 dialogs centered over a dimmed copy of the screen behind.
Copy rule: screen title max 3 words, button max 3 words, list row = one main line plus at most one short secondary line, no helper sentences, errors max 5 words.

FRAME LIST
7. "Student detail": back arrow, title "Mai Pham", no navigation. Initials avatar MP, line "MKT, S5", status chip "No team" with a person-off icon. Section "Skills": chips "Social media", "Branding", "Writing". Section "Availability": "12 h/week". Sticky filled button "Add to team".
8. "AI matching": title "Matching" with a back arrow, no navigation. Centered circular progress indicator, headline "Finding teammates", line "Class A, 12 students". Text button "Cancel".
9. "Proposals": tab Proposals with a badge "3", title "Proposals". 3 tappable cards. "Tutor Match": major row of 5 slots at 40 dp, 4 filled (SE, SE, AI, SE) and 1 proposed (GD); chip "Strong fit" with check icon. "GreenLoop": 3 filled (SE, AI, GD) and 2 proposed (MKT, SE); chip "Good fit" with half-circle icon. "FinLite": 4 filled (SE, SE, MKT, GD) and 1 proposed (AI); chip "Strong fit" with check icon. No filled button.
10. "Proposal detail": back arrow, title "Tutor Match", no navigation. Major row of 5 slots at 48 dp: 4 filled (SE, SE, AI, SE) and 1 proposed (GD); chip "Strong fit" with check icon. Section "Why": two plain lines with a check icon: "Fills the Design gap", "Same 12 h/week as team". Section "New member": row "Minh Anh, GD" with a text button "Add member". Section "Members": rows "Hoang Nguyen, SE", "Quoc Bao, SE", "Thao Linh, AI", "Duc Pham, SE". Sticky filled button "Approve" and below it a text button "Discard" in the error color.
11. "Add member": back arrow, title "Add member", no navigation. Line "Tutor Match, 5 of 6". Filter chips "All", "GD", "MKT", "AI". 4 plain rows with a checkbox, name and "major, semester": "Minh Anh" "GD, S5" (checked); "Linh Phan" "GD, S5"; "Bao Le" "GD, S6"; "Khoa Tran" "SE, S5". Sticky filled button "Add".
12. "Approve dialog": frame 10 dimmed, dialog "Approve team?", body "Students will be notified.", buttons "Cancel" (text) and "Approve" (filled).
```

## Prompt 3 - frame 13-18

```text
HEADER
Generate EXACTLY the 6 frames listed below (no more, no fewer), each as its own separate 360 x 800 dp Android frame (Material 3, light theme), for the app "TeamUp EXE": a tool for a university mentor (lecturer) of the EXE startup course. AI suggests how to place students who have no team into small startup teams that miss 1-2 specialist members, so each team reaches 4-6 members from different majors. The mentor reviews and approves. Keep the visual style of this project's existing design system. Ignore the older student-facing frames. Use ONLY the text given. Do not invent text, names, dates, banners, badges, helper sentences or extra sections. Never use the words lineup, roster, squad, board, capstone, position.

DESIGN SYSTEM (follow exactly)
Colors: screen and cards white #FFFFFF; cards have a 1 dp border #D6D4CE, no tinted fill, no shadow; text #1C1B18; secondary text #55534D; filled button and active indicator burnt orange #B23E00 with white text; selected chip and active navigation pill #FFE2D2 with text #3B1400; unselected chips and tonal buttons fill #E9E7E2 with text #1C1B18 and a 1 dp border #D6D4CE; error #B3261E on #F9DEDC; success and filled #1B6B3C on #D6F0DD; text fields fill #F3F2EF with a 1 dp border #77756F; snackbar #2F2E2A with white text. NO blue anywhere, no gradients, no shadows on cards, no colored side borders, no nested cards, no glass, no emoji icons.
Major row (signature component): one row of square slots, 40 dp on cards and 48 dp on detail screens, maximum 6, no captions under slots. Filled slot: fill #D6F0DD, 1 dp border #1B6B3C, the major code (SE, AI, MKT, GD) in #07301A. Open slot: white, 2 dp dashed outline #77756F, a small major icon. Proposed slot (what the AI suggests): fill #FFE2D2, 2 dp solid outline #B23E00, the major code in #3B1400, a small plus mark in the corner.
Type: Be Vietnam Pro. Headline 24 sp bold, title 20 sp semibold, card title 16 sp semibold, body 16 sp, metadata 14 sp, button and chip 14 sp semibold. Nothing smaller than 14 sp. Sentence case, no all caps, no arrows in button text. Numbers use tabular figures.
Layout: 16 dp side margins, 4 dp spacing scale, cards radius 12, fields radius 8, buttons and chips pill, buttons 48 dp high, touch targets 48 dp, one icon set (Material Symbols Rounded, outlined).
Components: top app bar with a left-aligned title only (nested screens: back arrow and title); no logo, no subtitle, no status bar mock, no help icon. Bottom navigation bar with 3 tabs Classes, Proposals, Profile, the current tab with a pill indicator, filled icon and bold label; nested screens, dialogs and the loading screen have no bottom navigation unless stated. At most one filled primary button per screen. Every status uses icon plus text label, never color alone. Fit chips: "Strong fit" with a check icon (green), "Good fit" with a half-circle icon (stone). Dialogs are Material 3 dialogs centered over a dimmed copy of the screen behind.
Copy rule: screen title max 3 words, button max 3 words, list row = one main line plus at most one short secondary line, no helper sentences, errors max 5 words.

FRAME LIST
13. "Add member - Error": same as frame 11 but "FinLite, 6 of 6" and two rows checked ("Minh Anh" "GD, S5" and "Linh Phan" "GD, S5"). Under the list an error row with an error icon and "Max 6 members" on #F9DEDC. The sticky button "Add" is disabled.
14. "Proposals - All matched": tab Proposals (no badge), title "Proposals". Centered check icon in a green circle, headline "All matched", filled button "View teams". Snackbar above the navigation bar: "Approved" with action "Undo".
15. "No match": back arrow, title "No match", no navigation. Centered alert icon, headline "No Design student found", filled button "Add manually", text button "See teams".
16. "Add student": back arrow, title "Add student", no navigation. Search field "Search students". Filter chips "All", "SE", "AI", "MKT", "GD". 4 plain rows with a checkbox, name, "major, semester": "Mai Pham" "MKT, S5"; "An Do" "MKT, S5"; "Lan Vo" "AI, S6"; and a disabled greyed row "Khoa Tran" "SE, S5" with a chip "In a team" with a lock icon and no checkbox. Sticky filled button "Add".
17. "Discard dialog": frame 10 dimmed, destructive dialog "Discard proposal?", body "AI will not suggest it again.", buttons "Cancel" (text) and "Discard" (filled, error color #B3261E).
18. "Offline": back arrow, title "Matching", no navigation. Centered offline icon, headline "You're offline", filled button "Try again".
```

