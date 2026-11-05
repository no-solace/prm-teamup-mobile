# Stitch prompts R8: 16 frame còn lại (7-22), chạy theo 3 lượt

Đã có 6 frame (1-6) từ R7. Chạy lần lượt Lượt 0 (tùy chọn, sửa chữ), Lượt 1, 2, 3. Mỗi lượt là một prompt riêng; ghi từng lượt vào log như một run, kể cả việc bạn tách prompt.

## Lượt 0 - sửa Sign in và Empty (chạy trên 2 màn đã có)

```text
Edit only these two existing screens, change nothing else.
Sign in: headline "Find your team". One line under it: "Sign in with any email." Delete the box with the lock icon and its text.
Discover - Empty: title "No teams found". One line: "Try fewer filters." Keep the Clear filters button.
Do not use the words roster, squad, lineup, position.
```

## Lượt 1 - frame 7-12

```text
HEADER
Generate EXACTLY the frames listed below (no more, no fewer) and add them to this project next to the existing screens. Do not touch the existing screens. Match their exact look. Each frame is its own separate 360 x 800 dp Android frame (Material 3, light theme), for the app "TeamUp EXE": students from different majors find and complete a 4-6 person EXE team. Use ONLY the text given. Do not invent text, names, dates, banners, badges, helper sentences or extra sections. Never use the words lineup, roster, squad, board, capstone.

DESIGN SYSTEM (follow exactly)
Colors: screen and cards white #FFFFFF; cards have a 1 dp border #D6D4CE and no tinted fill and no shadow; text #1C1B18; secondary text #55534D; filled button and active tab indicator burnt orange #B23E00 with white text; selected chip and active navigation pill #FFE2D2 with text #3B1400; unselected chips and tonal buttons fill #E9E7E2 with text #1C1B18 and a 1 dp border #D6D4CE; filled role slot fill #D6F0DD with initials #07301A and a 1 dp border #1B6B3C; open role slot white with a 2 dp dashed outline #77756F and a role icon; text fields fill #F3F2EF with a 1 dp border #77756F; error #B3261E on #F9DEDC; snackbar #2F2E2A with white text. NO blue anywhere, no gradients, no shadows on cards, no colored side borders, no nested cards, no glass, no emoji icons.
Type: Be Vietnam Pro. Headline 24 sp bold, title 20 sp semibold, card title 16 sp semibold, body 16 sp, metadata 14 sp, button and chip 14 sp semibold. Nothing smaller than 14 sp. Sentence case, no all caps, no arrows in button text.
Layout: 16 dp side margins, 4 dp spacing scale, cards radius 12, fields radius 8, buttons and chips pill, buttons 48 dp high, touch targets 48 dp, one icon set (Material Symbols Rounded, outlined).
Components: top app bar with a left-aligned title only (nested screens: back arrow and title); no logo, no subtitle, no status bar mock, no help icon. Bottom navigation bar with 4 tabs Discover, Team, Invitations, Profile, the current tab with a pill indicator, filled icon and bold label; nested screens and dialogs have no bottom navigation unless stated. Exactly one filled primary button per screen. Every status uses icon plus text label, never color alone. Role row = one row of 40 dp square role slots on cards (48 dp on detail screens), maximum 5, no captions under slots. Dialogs are Material 3 dialogs centered on a dimmed copy of the screen behind.
Copy rule: screen title max 3 words, button max 3 words, list row = one main line plus at most one short secondary line, no helper sentences, errors max 5 words. Majors may be shortened to SE, AI, MKT, GD.

FRAME LIST
7. "Team detail": back arrow, title "Tutor Match", no navigation. Role row of 5 slots at 48 dp (HN, QB, TL filled; marketing and design open). One idea line "Peer tutoring where FU students book short sessions". Section "Members": rows with initials avatar, name, short major: "Hoang Nguyen, SE", "Quoc Bao, SE", "Thao Linh, AI". Section "Open roles": rows with dashed icon and role name: "Marketing", "Graphic Design". Sticky filled button "Request to join".
8. "Team detail - Join dialog": frame 7 dimmed, dialog "Send request?", body "They will see your profile.", buttons "Cancel" (text) and "Send" (filled).
9. "Team detail - Team full": back arrow, title "FinLite". Role row of 5 filled slots (HQ, LN, TM, PA, NB). Alert icon with "Team is full". Line "Try these instead". 3 plain list rows: "Tutor Match - Marketing, Design", "GreenLoop - AI, Marketing, Design", "RecycleChain - Marketing". Disabled sticky button "Full".
10. "Student detail": back arrow, title "Mai Pham", no navigation. Initials avatar MP, "MKT, S5". Section "Skills": chips "Social media", "Branding", "Writing". Section "Availability": "12 h/week". Section "Role": "Marketing Lead". Sticky filled button "Invite".
11. "Student detail - Invite dialog": frame 10 dimmed, dialog "Send invite?", body "They will see your team.", buttons "Cancel" and "Send".
12. "Create team": back arrow, title "Create team", no navigation. Fields "Team name" and "One-line idea" (multi-line), section "Roles needed" with chips "Marketing", "Design", "AI", "Mobile", "Backend". Error under chips: "Pick a role". Sticky filled button "Post team".
```

## Lượt 2 - frame 13-18

```text
HEADER
Generate EXACTLY the frames listed below (no more, no fewer) and add them to this project next to the existing screens. Do not touch the existing screens. Match their exact look. Each frame is its own separate 360 x 800 dp Android frame (Material 3, light theme), for the app "TeamUp EXE": students from different majors find and complete a 4-6 person EXE team. Use ONLY the text given. Do not invent text, names, dates, banners, badges, helper sentences or extra sections. Never use the words lineup, roster, squad, board, capstone.

DESIGN SYSTEM (follow exactly)
Colors: screen and cards white #FFFFFF; cards have a 1 dp border #D6D4CE and no tinted fill and no shadow; text #1C1B18; secondary text #55534D; filled button and active tab indicator burnt orange #B23E00 with white text; selected chip and active navigation pill #FFE2D2 with text #3B1400; unselected chips and tonal buttons fill #E9E7E2 with text #1C1B18 and a 1 dp border #D6D4CE; filled role slot fill #D6F0DD with initials #07301A and a 1 dp border #1B6B3C; open role slot white with a 2 dp dashed outline #77756F and a role icon; text fields fill #F3F2EF with a 1 dp border #77756F; error #B3261E on #F9DEDC; snackbar #2F2E2A with white text. NO blue anywhere, no gradients, no shadows on cards, no colored side borders, no nested cards, no glass, no emoji icons.
Type: Be Vietnam Pro. Headline 24 sp bold, title 20 sp semibold, card title 16 sp semibold, body 16 sp, metadata 14 sp, button and chip 14 sp semibold. Nothing smaller than 14 sp. Sentence case, no all caps, no arrows in button text.
Layout: 16 dp side margins, 4 dp spacing scale, cards radius 12, fields radius 8, buttons and chips pill, buttons 48 dp high, touch targets 48 dp, one icon set (Material Symbols Rounded, outlined).
Components: top app bar with a left-aligned title only (nested screens: back arrow and title); no logo, no subtitle, no status bar mock, no help icon. Bottom navigation bar with 4 tabs Discover, Team, Invitations, Profile, the current tab with a pill indicator, filled icon and bold label; nested screens and dialogs have no bottom navigation unless stated. Exactly one filled primary button per screen. Every status uses icon plus text label, never color alone. Role row = one row of 40 dp square role slots on cards (48 dp on detail screens), maximum 5, no captions under slots. Dialogs are Material 3 dialogs centered on a dimmed copy of the screen behind.
Copy rule: screen title max 3 words, button max 3 words, list row = one main line plus at most one short secondary line, no helper sentences, errors max 5 words. Majors may be shortened to SE, AI, MKT, GD.

FRAME LIST
13. "My team": tab Team, title "My team". Card with "Tutor Match" and "3 of 5". Role row of 5 slots at 48 dp (HN, QB, TL filled; marketing and design open). Section "Members": rows "Hoang Nguyen, SE" with a "Leader" chip, "Quoc Bao, SE", "Thao Linh, AI". Filled button "Find Marketing". A text button "Leave team" in the error color at the bottom of the content.
14. "My team - Empty": tab Team, title "My team". Centered line icon, headline "No team yet", filled button "Create team", text button "Browse".
15. "My team - Complete": tab Team, title "My team". Card "Tutor Match" and "5 of 5". Role row of 5 filled slots (HN, QB, TL, MP, MA). Check icon with "Complete". Members rows: "Hoang Nguyen, SE", "Quoc Bao, SE", "Thao Linh, AI", "Mai Pham, MKT", "Minh Anh, GD". Filled button "Open chat".
16. "My team - Leave dialog": frame 13 dimmed, destructive dialog "Leave team?", body "You can request again later.", buttons "Stay" (text) and "Leave" (filled, error color).
17. "Invitations - Sent": tab Invitations, title "Invitations", tabs "Received" and "Sent" with Sent active. 3 plain list rows (no cards): "Tutor Match", "SE", chip "Pending" with clock icon; "AgriSense IoT", "Mobile", chip "Accepted" with check icon; "EduQuest AR", "AI", chip "Declined" with close icon. Snackbar above the navigation bar: "Sent" with action "Undo".
18. "Invitations - Received": same header with Received active and a badge "2" on the tab. 2 plain rows: "GreenLoop", "AI"; "FinLite", "Design". Each row has a text button "Decline" and a tonal button "Accept". No filled button.
```

## Lượt 3 - frame 19-22

```text
HEADER
Generate EXACTLY the frames listed below (no more, no fewer) and add them to this project next to the existing screens. Do not touch the existing screens. Match their exact look. Each frame is its own separate 360 x 800 dp Android frame (Material 3, light theme), for the app "TeamUp EXE": students from different majors find and complete a 4-6 person EXE team. Use ONLY the text given. Do not invent text, names, dates, banners, badges, helper sentences or extra sections. Never use the words lineup, roster, squad, board, capstone.

DESIGN SYSTEM (follow exactly)
Colors: screen and cards white #FFFFFF; cards have a 1 dp border #D6D4CE and no tinted fill and no shadow; text #1C1B18; secondary text #55534D; filled button and active tab indicator burnt orange #B23E00 with white text; selected chip and active navigation pill #FFE2D2 with text #3B1400; unselected chips and tonal buttons fill #E9E7E2 with text #1C1B18 and a 1 dp border #D6D4CE; filled role slot fill #D6F0DD with initials #07301A and a 1 dp border #1B6B3C; open role slot white with a 2 dp dashed outline #77756F and a role icon; text fields fill #F3F2EF with a 1 dp border #77756F; error #B3261E on #F9DEDC; snackbar #2F2E2A with white text. NO blue anywhere, no gradients, no shadows on cards, no colored side borders, no nested cards, no glass, no emoji icons.
Type: Be Vietnam Pro. Headline 24 sp bold, title 20 sp semibold, card title 16 sp semibold, body 16 sp, metadata 14 sp, button and chip 14 sp semibold. Nothing smaller than 14 sp. Sentence case, no all caps, no arrows in button text.
Layout: 16 dp side margins, 4 dp spacing scale, cards radius 12, fields radius 8, buttons and chips pill, buttons 48 dp high, touch targets 48 dp, one icon set (Material Symbols Rounded, outlined).
Components: top app bar with a left-aligned title only (nested screens: back arrow and title); no logo, no subtitle, no status bar mock, no help icon. Bottom navigation bar with 4 tabs Discover, Team, Invitations, Profile, the current tab with a pill indicator, filled icon and bold label; nested screens and dialogs have no bottom navigation unless stated. Exactly one filled primary button per screen. Every status uses icon plus text label, never color alone. Role row = one row of 40 dp square role slots on cards (48 dp on detail screens), maximum 5, no captions under slots. Dialogs are Material 3 dialogs centered on a dimmed copy of the screen behind.
Copy rule: screen title max 3 words, button max 3 words, list row = one main line plus at most one short secondary line, no helper sentences, errors max 5 words. Majors may be shortened to SE, AI, MKT, GD.

FRAME LIST
19. "Invitations - Accepted": Sent tab. 2 rows: "Mai Pham", "MKT", chip "Accepted" with check icon; "Minh Anh", "GD", chip "Pending" with clock icon. Snackbar "Accepted" with action "Chat".
20. "Invitations - Declined": Sent tab. 2 rows: "Mai Pham", "MKT", chip "Declined" with close icon; "Minh Anh", "GD", chip "Pending" with clock icon. Snackbar "Declined" with action "Find".
21. "Team chat": back arrow, title "Tutor Match chat", no navigation. 3 message bubbles: incoming "Welcome to the team, Mai!", outgoing (burnt orange, white text) "Thanks! I can start this week.", incoming "Great, let's meet Thursday.". Bottom message field with placeholder "Message" and a send icon button.
22. "Profile": tab Profile, title "Profile". Initials avatar MN, "Minh Nguyen", "SE, S5". Chips "Flutter", "Figma", "Python". "15 h/week". Filled button "Edit".
```

