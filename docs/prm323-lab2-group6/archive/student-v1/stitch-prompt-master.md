# Stitch master prompt (all 22 frames, one run)

Thay thế các prompt rời trong `stitch-prompts-v2.md`: chạy MỘT lần, tạo mới toàn bộ màn với chữ đã giảm, bảng màu bản 2 (không xanh dương, nền trắng, thẻ viền), đủ màn và state còn thiếu.

Rủi ro đã gặp: lần đầu Stitch chỉ ra 1 màn khi prompt liệt kê 10 màn. Nếu lần này ra thiếu, dán lại cùng phần HEADER + một đoạn FRAME LIST (A: 1-6, B: 7-12, C: 13-22) rồi ghi trung thực vào log rằng bạn tách prompt. Nên xóa các màn cũ trước khi chạy để khỏi lẫn phiên bản.

## Prompt (dán nguyên văn, ghi vào ai-design-log.md)

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

## Cách xử lý kết quả

| Tình huống | Việc cần làm |
|---|---|
| Ra đủ 22 frame | Chụp toàn project và từng frame vào `assets/stitch/v4-*.png`, ghi một run mới trong log |
| Ra thiếu | Dán lại HEADER + đoạn FRAME LIST còn thiếu (A: 1-6, B: 7-12, C: 13-22), ghi trung thực việc tách prompt |
| Còn xanh dương hoặc nền xám | Chạy prompt chỉnh một dòng: "Recolor with the palette in the DESIGN SYSTEM section only, remove every blue. Change nothing else." |
| Chữ nhỏ hơn 14 sp | "Keep all text at 14 sp or larger. Change nothing else." |
| Dialog không phủ mờ nền | Không sao: Figma sẽ dựng dialog thành overlay riêng |

## Gợi ý cho decision record

Lý do hợp lệ để chạy lại toàn bộ: bản v2 cũ có nhiều chữ thừa (persona Minh dùng một tay, H8 và H6), bảng màu cũ có tông xanh và độ tách lớp thấp (thẻ so với nền 1.07:1), và thiếu 10 frame cần cho 3 flow. Nhớ ghi quyết định theo lời bạn, không chép nguyên.
