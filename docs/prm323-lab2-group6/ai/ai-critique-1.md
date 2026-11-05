# AI critique 1 (Claude, from Stitch screenshots)

- Reviewer: Claude, reading 9 screenshots exported from Stitch v2 (Discover, Team detail, Invitations, Create profile, My team, Discover loading, offline, empty, plus one older Discover).
- Basis: Nielsen's 10 heuristics, WCAG 2.1 (1.4.3 contrast, 1.4.4 resize/legibility, 2.5.5 target size, 1.4.1 use of color), persona Minh (SE, one-handed, between classes, flaky wifi).
- Limits: low-resolution screenshots, so font sizes and contrast ratios are visual estimates. Verify numerically in Figma.
- Save the exact prompt you gave the reviewer and this full answer in `ai-design-log.md` section 2 when you use it as your critique.

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

## Decision record (you fill this in; reasons must cite persona, a heuristic or a real constraint)

| # | Accepted / modified / rejected | Your reason |
|---|---|---|
| 1 | `TODO` | `TODO` |
| 2 | `TODO` | `TODO` |
| 3 | `TODO` | `TODO` |
| 4 | `TODO` | `TODO` |
| 5 | `TODO` | `TODO` |
| 6 | `TODO` | `TODO` |
| 7 | `TODO` | `TODO` |
