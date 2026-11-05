# Stitch prompts v2 (one screen per prompt)

Dùng sau khi đã thấy output v0. Dán CONTEXT trước mỗi prompt màn hình. Mỗi prompt chạy trong cùng một project Stitch. Ghi nguyên văn từng prompt vào `ai-design-log.md`.

## CONTEXT (paste before every screen)

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

## Screen 1 - Discover (Flow B, start)

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

## Screen 2 - Team detail (Flow B)

```text
Design the Team detail screen for "Tutor Match". Top app bar with back arrow and title "Tutor Match", no other actions. No bottom navigation on this screen; instead a sticky filled button at the bottom: "Request to join".
Content, in this order, as plain sections separated by spacing and thin dividers (not boxes):
1. Idea: "A peer tutoring marketplace where FU students offer and book short study sessions." (3 lines of body text)
2. Members (3 list rows, initials avatar, name, major): "Hoang Nguyen, Software Engineering", "Quoc Bao, Software Engineering", "Thao Linh, AI".
3. Open roles (2 list rows, dashed role icon, role name, one line): "Marketing - grow the first 100 users", "Graphic Design - app screens and brand".
The role row (5 slots, 48 dp, role name under each) sits directly under the app bar. Only one button on the screen.
```

## Screen 3 - Invitations (Flow B, end)

```text
Design the Invitations screen, "Invitations" tab selected. Top app bar: title "Invitations". Tabs: "Received" and "Sent", with "Sent" active.
List of exactly 3 rows (list tiles, no cards): 
- "Tutor Match", "Applied as Software Engineering", status chip "Pending" with a clock icon.
- "AgriSense IoT", "Applied as Mobile", status chip "Accepted" with a check icon.
- "EduQuest AR", "Applied as AI", status chip "Declined" with a close icon.
At the bottom, above the navigation bar, one snackbar: "Request sent" with the action "Undo".
No banner, no nested boxes, no buttons other than the snackbar action.
```

## Next batch (same CONTEXT)

```text
Create profile: app bar "Create profile". Fields in order: "Major" (dropdown), "Semester" (dropdown), "Skills" (choose 3 to 5 chips), "Role I want" (dropdown), "Availability" (text field). Sticky filled button "Save profile". Show the empty-required-field error state under "Skills": "Choose at least 3 skills".
```

```text
My team, "Team" tab selected: app bar "My team". Team name "Tutor Match". Text "3 of 5 members". The role row with 3 filled and 2 open slots (48 dp, role names under). Filled button "Find a Marketing teammate".
```

```text
States (one frame each, Discover): (a) loading: 3 skeleton cards; (b) empty: line icon, "No teams match your filters", button "Loosen filters"; (c) error: "You are offline. Your changes are saved." with the button "Try again".
```

## Iteration 2 - role row labels collide (edit prompt, run on Team detail and My team)

```text
On this screen, remove all text captions under the role slots. Keep one row of square role slots (48 dp) and nothing under it. The member names and open role names are already written in the lists below, so no text is lost. Do not change anything else and do not add new text.
```

## Iteration 3 - inconsistent app bar and invented extra metadata (edit prompt, run on every screen)

```text
Make the top of this screen follow one pattern. Tab screens (Discover, Team, Invitations, Profile): left-aligned title only, no logo icon, no subtitle line, no status bar mock; only Discover has a search icon. Nested screens: back arrow and title only.
Remove these elements if present: the chip "EXE 2025", the chip "Cached team profiles ready", the chip "Teams require 4-6 members with open roles", every "FPT University" label, the small line "EXE Entrepreneurship" above the team name, and the pill "3 of 5 members" (write it as plain title text "3 of 5 members" instead).
Replace "Fall 2024" and "Spring 2025" with "Fall 2026". Remove the arrow from the button "Save profile".
Change nothing else.
```

## Remaining screens (paste CONTEXT first)

```text
Sign in, no bottom navigation. Text: app name "TeamUp EXE", one line "Find teammates from other majors for your EXE team.". Field labeled "FPT email". Filled button "Continue". Also draw the error state under the field: "Use your @fpt.edu.vn email".
```

```text
Student detail, nested screen: back arrow and title "Thao Linh". Initials avatar "TL", "AI, Semester 5". Section "Skills": chips "Python", "Machine learning", "Data analysis". Section "Availability": "10 hours per week". Section "Role I want": "AI Engineer". Sticky filled button "Invite to my team". No bottom navigation.
```

```text
Create team, nested screen: back arrow and title "Create team". Fields: "Team name", "Idea" (multi-line). Section "Roles needed": chips "Marketing", "Design", "AI", "Mobile", "Backend". Sticky filled button "Post team". Also draw the error state under the chips: "Choose at least 1 role".
```

```text
Team chat, nested screen: back arrow and title "Tutor Match chat". 3 messages: "Welcome to the team, Linh!", "Thanks! I can start this week.", "Great, let's meet Thursday after class." Message field with placeholder "Message" and a send icon button. No filled text button, no bottom navigation.
```

```text
Profile, "Profile" tab selected: title "Profile". Initials avatar "MN", "Minh Nguyen", "Software Engineering, Semester 5". Chips "Flutter", "Figma", "Python". Line "15 hours per week". Filled button "Edit profile".
```

## Iteration 4 - sign-in assumes an email domain students no longer have (edit prompt)

> OBSOLETE: Student ID field was dropped (decision: no MSSV in the app). Do not run the prompt below. Email-only part of this iteration was applied (R6).

Run on the Sign in screen, then on Create profile.

```text
Change the Sign in screen: the field label becomes "Email" with helper text "Any email works, for example Gmail. We will send you a 6-digit code." The button becomes "Send code". The error state under the field reads "Enter a valid email address". Remove every mention of FPT email and of @fpt.edu.vn. Change nothing else.
```

```text
On the Create profile screen add a first field above "Major": "Student ID" with helper text "So teammates know you study at FPT". Remove the chip "FPT University" if present. Change nothing else.
```

## Iteration 5 - low figure/ground contrast and blue tint (edit prompt, run on every screen)

First re-import the updated `design/DESIGN.md` into the Stitch design system (the existing tile is still named "The Lineup Board" and holds the old blue palette), then run:

```text
Recolor this screen with this palette only and remove every blue.
Screen background white #FFFFFF. Cards white with a 1 dp border #D6D4CE and no tinted fill. Text #1C1B18, secondary text #55534D (idea text is also #55534D, never colored).
Filled button and the active navigation indicator: burnt orange #B23E00 with white text. Selected chip and the selected navigation pill: fill #FFE2D2 with text #3B1400. Unselected chips and tonal buttons: fill #E9E7E2, text #1C1B18, 1 dp border #D6D4CE.
Filled role slot: fill #D6F0DD, initials #07301A, 1 dp border #1B6B3C. Open role slot: white with a 2 dp dashed outline #77756F.
Status chips, always with icon and text and a 1 dp border #D6D4CE: Pending is #E9E7E2 with a clock icon; Accepted is #D6F0DD with a check icon; Declined is #F9DEDC with a close icon.
Text fields: fill #F3F2EF, 1 dp border #77756F; error border #B3261E with the message below in #B3261E.
Snackbar background #2F2E2A with white text. Skeleton blocks #F3F2EF on a white card.
Change nothing except colors.
```

## Batch 3 - missing frames (keep the existing v2 look)

Chạy từng prompt một trong cùng project Stitch. Dán CONTEXT-B trước mỗi prompt. Tất cả đều khớp bảng "Frame còn thiếu" khi kiểm tra file Figma ngày 06/10/2026. Sau khi chạy, đặt tên frame đúng theo cột "Tên frame" để khớp prototype về sau.

### CONTEXT-B (paste before every prompt below)

```text
Add one screen to the existing "TeamUp EXE" Android app project (Material 3, 360 x 800 dp). Match the existing screens in this project exactly: same colors, same Be Vietnam Pro type roles, same card style, same role slots (filled = mint square with initials, open = dashed square with a role icon), same top app bar and bottom navigation pattern with the four tabs Discover, Team, Invitations, Profile. One filled primary button per screen at most; sentence case; smallest text 14 sp; touch targets 48 dp; status is always icon plus text. Use only the text given below. Invent nothing and never use the words lineup, roster, squad or capstone. Standard Flutter Material 3 parts only.
```

### Flow B

**Tên frame: `Team Detail - Join Dialog`**

```text
Create the Team detail screen for "Tutor Match" exactly like the existing one, dimmed behind a scrim, with a centered Material 3 confirmation dialog on top. Dialog title: "Send join request?". Body: "Tutor Match will see your profile and the role you want." Buttons: a text button "Cancel" and a filled button "Send request".
```

**Tên frame: `Team Detail - Team Full`**

```text
Create the Team detail screen for "FinLite" in the state where the team is full. App bar: back arrow and title "FinLite". Under it one row of 5 filled role slots (HQ, LN, TM, PA, NB). Then an error block with an alert icon: "This team is already full", and below it in body text "Another student took the last open role. Try one of these teams instead." Then exactly 3 plain tappable list rows: "Tutor Match - Needs Marketing and Design", "GreenLoop - Needs AI, Marketing and Design", "RecycleChain - Needs Marketing". The sticky bottom button is disabled and reads "Team is full". No bottom navigation.
```

### Flow C

**Tên frame: `My Team - Empty`**

```text
Create the My team screen, "Team" tab selected, in the state where the user has no team. App bar title "My team". Centered: a line icon, the headline "You have no team yet", the sentence "Create a team or find one that needs your role." One filled button "Create team" and one text button "Browse teams".
```

**Tên frame: `Student Detail - Mai Pham`**

```text
Create the Student detail screen for "Mai Pham", like the existing Student detail. App bar: back arrow and title "Mai Pham". Initials avatar "MP" with the text "Marketing, Semester 5". Section "Skills": chips "Social media", "Branding", "Content writing". Section "Availability": "12 hours per week". Section "Role I want": "Marketing Lead". Sticky filled button "Invite to my team". No bottom navigation.
```

**Tên frame: `Student Detail - Invite Dialog`**

```text
Create the same Student detail screen for "Mai Pham", dimmed behind a scrim, with a centered Material 3 confirmation dialog. Title: "Send invite?". Body: "Mai Pham will get an invitation to join Tutor Match as Marketing." Buttons: a text button "Cancel" and a filled button "Send invite".
```

**Tên frame: `Invitations - Accepted`**

```text
Create the Invitations screen, "Invitations" tab selected, "Sent" tab active. Two plain list rows: "Mai Pham", "Invited as Marketing", status chip "Accepted" with a check icon; and "Minh Anh", "Invited as Design", status chip "Pending" with a clock icon. At the bottom, above the navigation bar, one snackbar: "Mai Pham joined Tutor Match" with the action "Open chat".
```

**Tên frame: `Invitations - Declined`**

```text
Create the Invitations screen, "Invitations" tab selected, "Sent" tab active. Two plain list rows: "Mai Pham", "Invited as Marketing", status chip "Declined" with a close icon; and "Minh Anh", "Invited as Design", status chip "Pending" with a clock icon. At the bottom, above the navigation bar, one snackbar: "Mai Pham declined" with the action "Find another".
```

**Tên frame: `My Team - Complete`**

```text
Create the My team screen, "Team" tab selected, for "Tutor Match" with the team complete. Heading "Tutor Match" and the text "5 of 5 members". One row of 5 filled role slots (HN, QB, TL, MP, MA). A line with a check icon: "Your team is complete". Section "Members": 5 plain list rows with initials, name and major: "Hoang Nguyen, Software Engineering", "Quoc Bao, Software Engineering", "Thao Linh, AI", "Mai Pham, Marketing", "Minh Anh, Graphic Design". One filled button "Open team chat".
```

### Destructive dialog (required by the lab) and Received tab

**Tên frame: `My Team - Leave Dialog`**

```text
Create the My team screen for "Tutor Match" exactly like the existing one with the text "3 of 5 members", dimmed behind a scrim, with a centered Material 3 destructive dialog. Title: "Leave this team?". Body: "You will lose access to Tutor Match and its chat. You can request to join again later." Buttons: a text button "Stay" and a filled button "Leave team" in the error color. Also, on the screen behind the scrim, add a text button "Leave team" in the error color at the bottom of the content.
```

**Tên frame: `Invitations - Received`**

```text
Create the Invitations screen, "Invitations" tab selected with a badge "2", "Received" tab active. Two plain list rows: "GreenLoop", "Invited you as AI Engineer"; and "FinLite", "Invited you as Design". Each row has a text button "Decline" and a tonal button "Accept". No filled buttons on this screen.
```

### Optional (không bắt buộc cho rubric)

```text
Create the Create profile screen in the saving state: all fields disabled and the sticky button shows a circular progress indicator in place of its label, same width.
```

```text
Create the Create profile screen in the offline recovery state: a banner under the app bar with an alert icon and the text "You are offline. Your answers are saved on this phone.", a text button "Try again" in the banner, and the sticky button "Save profile" disabled.
```

```text
Create the Create team screen in the posting state, with Team name "Tutor Match", Idea "A peer tutoring marketplace for FU students", chips Marketing and Design selected, and the sticky button showing a circular progress indicator in place of its label.
```

```text
On the Team chat screen, change the first message to "Welcome to the team, Mai!" and the reply to "Thanks! I can start this week.". Change nothing else.
```

## Batch 4 - Iteration 6: too much copy (edit prompts, one per existing screen)

Vấn đề có tên: **mỗi màn có quá nhiều câu mô tả, người dùng phải đọc thay vì nhận ra** (persona Minh dùng một tay giữa các tiết; heuristic H8 tối giản, H6 nhận biết thay vì nhớ). Giảm chữ nhưng giữ nguyên cấu trúc: mọi state, mọi nút chính, ô vai trò, icon kèm nhãn, cỡ chữ từ 14 sp. Trong log, ghi đây là iteration kế tiếp của bạn và chụp before/after từng màn.

### CONTEXT-C (paste before every prompt below)

```text
Edit the existing screen. Reduce the amount of text and keep the structure, hierarchy, components, states, colors and layout exactly as they are. Hierarchy must come from size, weight, spacing, grouping and icons, not from sentences. Rules: screen title at most 3 words; button label at most 3 words; list row = one primary line plus at most one short secondary line (max 4 words); no helper sentences under fields, only a short error (max 5 words) when a field is in error; no descriptive paragraphs, banners or footers; keep one filled primary button per screen; every status and every icon-only element keeps a visible text label of at least 14 sp; keep the 48 dp touch targets and spacing. Majors may be shortened to SE, AI, MKT, GD. Do not add new text, new elements or new screens, and do not change anything not listed below.
```

### Per screen

**Sign in**

```text
Subtitle: "Find teammates across majors". Field label "Email", placeholder "you@gmail.com", error "Enter a valid email". Remove the info box and the footer line. Button "Continue".
```

**Create profile**

```text
Remove the helper line under Availability and the "1 selected" counter. Placeholders and values stay short ("15 h/week"). Skills error: "Pick 3 skills". Labels and button unchanged.
```

**Discover (populated)**

```text
Each card: team name, one idea line of at most 6 words, the role row, and one line with a small add-person icon followed by only the open roles, for example "Marketing, Design". Remove the word "Needs". Search placeholder "Search teams".
```

**Discover loading / empty / error**

```text
Loading: no change except search placeholder "Search teams". Empty: headline "No teams found", button "Clear filters", remove the sentence and any extra chip below the button. Offline: headline "You're offline", button "Try again", remove both sentences and any extra chip.
```

**Team detail**

```text
Remove the "Idea" heading and show the idea in one line of at most 12 words under the role row. Members: avatar, name, short major (SE, AI, MKT, GD). Open roles: dashed icon plus role name only, remove the description lines. Button "Request to join".
```

**Student detail**

```text
Header: avatar, name, short major and semester on one line ("AI, S5"). Keep the sections Skills, Availability and Role, each as a heading with a chip or one short value ("10 h/week"). Button "Invite".
```

**Create team**

```text
Placeholders: "Team name" and "One-line idea". Roles needed: chips with the existing labels. Error "Pick a role". Button "Post team".
```

**Invitations (Sent, Received, Accepted, Declined)**

```text
Each row: team or person name, one short secondary line with the role only ("Backend"), and the status chip with icon and label. Remove "Applied as" and "Invited as". Snackbars: at most 3 words plus the action ("Sent", action "Undo"; "Accepted", action "Chat"; "Declined", action "Find"). Received rows: "Decline" and "Accept" buttons only.
```

**My team (default, empty, complete)**

```text
Default: remove the description sentence and the "Role status / 2 open roles" row. Keep the team name, "3 of 5", the role row and the members list with avatar, name and short major. Button "Find Marketing". Empty: headline "No team yet", buttons "Create team" and "Browse". Complete: "5 of 5", the role row, the members list, button "Open chat"; remove the "Your team is complete" line and keep only a check icon with "Complete".
```

**Dialogs (join, invite, leave)**

```text
Title at most 3 words, body at most 8 words, buttons at most 2 words. Join: "Send request?" / "They will see your profile." / "Cancel", "Send". Invite: "Send invite?" / "They will see your team." / "Cancel", "Send". Leave: "Leave team?" / "You can request again later." / "Stay", "Leave" (Leave in the error color).
```

**Team full**

```text
Headline "Team is full", one line "Try these instead", the 3 list rows showing only the team name and the open roles, disabled bottom button "Full".
```

**Team chat and Profile**

```text
Chat: no change. Profile: keep the avatar, name, short major and semester on one line, the three skill chips, the availability value ("15 h/week") and the button "Edit". Remove everything else.
```

### Kiểm tra sau khi chạy

- Mỗi màn vẫn có đúng một nút chính, ô vai trò, và mọi trạng thái có chữ kèm icon.
- Không có chữ dưới 14 sp. Nếu Stitch thu nhỏ chữ để nhét vừa, chạy lại prompt đó với câu "Keep all text at 14 sp or larger".
- Chữ Việt dài hơn 30% vẫn phải vừa: nhãn ngắn là lợi thế, đừng rút gọn thêm.
