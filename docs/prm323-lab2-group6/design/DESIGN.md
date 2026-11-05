---
name: TeamUp EXE
description: Android app for EXE mentors and lecturers. AI suggests how to place students without a team into teams missing 1-2 specialist members, so each small startup team reaches 5-6 members across majors. The mentor reviews and approves.
colors:
  primary: "#B23E00"
  on-primary: "#FFFFFF"
  primary-container: "#FFE2D2"
  on-primary-container: "#3B1400"
  brand-orange: "#F37021"
  secondary: "#2F2E2A"
  on-secondary: "#FFFFFF"
  secondary-container: "#E9E7E2"
  on-secondary-container: "#1C1B18"
  tertiary: "#1B6B3C"
  on-tertiary: "#FFFFFF"
  tertiary-container: "#D6F0DD"
  on-tertiary-container: "#07301A"
  error: "#B3261E"
  on-error: "#FFFFFF"
  error-container: "#F9DEDC"
  on-error-container: "#410E0B"
  surface: "#FFFFFF"
  surface-container-low: "#F3F2EF"
  surface-container: "#E9E7E2"
  on-surface: "#1C1B18"
  on-surface-variant: "#55534D"
  outline: "#77756F"
  outline-variant: "#D6D4CE"
typography:
  headline-small:
    fontFamily: "Be Vietnam Pro, Roboto, sans-serif"
    fontSize: "24sp"
    fontWeight: 700
    lineHeight: "32sp"
  title-large:
    fontFamily: "Be Vietnam Pro, Roboto, sans-serif"
    fontSize: "20sp"
    fontWeight: 600
    lineHeight: "28sp"
  title-medium:
    fontFamily: "Be Vietnam Pro, Roboto, sans-serif"
    fontSize: "16sp"
    fontWeight: 600
    lineHeight: "24sp"
  body-large:
    fontFamily: "Be Vietnam Pro, Roboto, sans-serif"
    fontSize: "16sp"
    fontWeight: 400
    lineHeight: "24sp"
  body-medium:
    fontFamily: "Be Vietnam Pro, Roboto, sans-serif"
    fontSize: "14sp"
    fontWeight: 400
    lineHeight: "20sp"
  label-large:
    fontFamily: "Be Vietnam Pro, Roboto, sans-serif"
    fontSize: "14sp"
    fontWeight: 600
    lineHeight: "20sp"
rounded:
  sm: "8dp"
  md: "12dp"
  lg: "16dp"
  full: "999dp"
spacing:
  xs: "4dp"
  sm: "8dp"
  md: "16dp"
  lg: "24dp"
  xl: "32dp"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-large}"
    rounded: "{rounded.full}"
    height: "48dp"
    padding: "0 24dp"
  button-tonal:
    backgroundColor: "{colors.secondary-container}"
    textColor: "{colors.on-secondary-container}"
    typography: "{typography.label-large}"
    rounded: "{rounded.full}"
    height: "48dp"
  text-field:
    backgroundColor: "{colors.surface-container-low}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-large}"
    rounded: "{rounded.sm}"
    height: "56dp"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: "16dp"
  major-slot-open:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface-variant}"
    rounded: "{rounded.md}"
    size: "40dp"
  major-slot-filled:
    backgroundColor: "{colors.tertiary-container}"
    textColor: "{colors.on-tertiary-container}"
    rounded: "{rounded.md}"
    size: "40dp"
  major-slot-proposed:
    backgroundColor: "{colors.primary-container}"
    textColor: "{colors.on-primary-container}"
    rounded: "{rounded.md}"
    size: "40dp"
  navigation-bar:
    backgroundColor: "{colors.surface-container-low}"
    textColor: "{colors.on-surface-variant}"
    height: "80dp"
---

# Design System: TeamUp EXE (mentor app)

## Overview

**Creative North Star: "The Team Sheet"**

A team sheet pinned up before a match: every team is a row of places, some already taken, some still open. A mentor reads the sheet in two seconds and knows which team lacks which major, and which student the AI proposes for it. The product is a working tool used one-handed between classes, so layout, navigation and controls stay standard Material 3. The world contributes only type, palette, density and one signature move. Professional and modern here means restraint: few elements, tabular numbers, one accent, plain words.

The mood is calm, precise and trustworthy: a tool a lecturer relies on to make a decision, not a social feed. Density is medium: roomy enough to tap with a thumb, compact enough to compare proposals without scrolling far. Light theme only for this lab (used in bright hallways and outdoors; a dark theme is optional and out of scope).

**Signature move: the major row.** Each team shows its places as one row of major slots (no more than 6, never scrolling sideways). A filled slot is a solid green-tint square with the member's major code (SE, AI, MKT, GD). An open slot is a dashed-outline square with a major icon. A proposed slot (what the AI suggests) is a peach square with a solid orange outline, the major code and a small plus mark. On cards the slots are 40 dp and the gap is named in one text line ("Needs Design"). On detail screens the slots are 48 dp, in one row, with no text under them; names are in the Members list below. State is carried by shape (solid, dashed, solid with plus), icon and text, never by color alone.

**AI principle.** AI proposes, the mentor decides. Every proposal shows a fit label with icon ("Strong fit", "Good fit") and at most two plain reasons. Nothing changes for students until the mentor approves. The AI in this lab is a design concept with sample data, not a trained model.

**UI vocabulary rule.** "Team sheet" and "major row" are design-team words. They never appear as screen copy. The UI says "team", "members", "needs". It never says lineup, roster, squad, board or capstone. The course is "EXE".

**Key Characteristics:**
- Material 3 structure, navigation and components; brand lives in theme roles.
- One primary action per screen, filled button in `primary`.
- White screens and outlined cards, ink-black text, one orange for action and one green for "filled". No blue anywhere in the palette.
- The major row is the only custom component, built from plain Containers and Icons so Flutter can reproduce it.
- Vietnamese-ready: every label tolerates +30% length and diacritics.

**Anti-references (do not produce):** purple or blue gradients, blue chips or blue-grey panels, gradient text, identical icon-heading-text card grids, stock illustrations of people at laptops, emoji used as icons, colored left borders on cards, glassmorphism, hard offset shadows.

## Colors

Three voices and a neutral: ink for text and secondary actions, burnt orange for the one thing to do next, green for "taken". White screens with outlined cards. There is deliberately no blue: orange plus blue on grey-blue panels is the stock look of generated apps.

### Primary
- **Burnt Signal Orange** (#B23E00): filled buttons, active tab indicator, text links, focus ring. White text on it is 5.9:1; as text on white 5.9:1; as a control boundary 5.9:1.
- **Peach Wash** (#FFE2D2) with **Deep Umber** (#3B1400) text: selected chips and the active navigation pill (13.3:1).
- **FPT Orange** (#F37021): logo and splash only. Never text with white on it (2.9:1) and never the only boundary of a control (2.8:1).

### Secondary (neutral graphite, replaces blue)
- **Graphite** (#2F2E2A): outlined and tonal button text, filter chip text, snackbar background (white on it 13.6:1).
- **Stone** (#E9E7E2) with **Ink** (#1C1B18): tonal buttons, unselected filter chips, "Pending" chips with a clock icon (13.9:1).

### Tertiary
- **Filled Green** (#1B6B3C) / **Mint** (#D6F0DD) with **Forest** (#07301A): role filled, request accepted, team complete (12.0:1).

### Error
- **Alert Red** (#B3261E) / **Rose Tint** (#F9DEDC) with **Deep Wine** (#410E0B): inline field errors, "team is full", "Declined", destructive dialog confirm.

### Neutral
- **White** (#FFFFFF): screen background and cards.
- **Paper Stone** (#F3F2EF): text field fill, navigation bar, skeleton blocks. **Stone** (#E9E7E2): disabled fills.
- **Ink** (#1C1B18): primary text (17.2:1). **Soft Ink** (#55534D): secondary text (7.7:1).
- **Outline** (#77756F): field borders, dashed open slots (4.6:1 on white, so it meets the 3:1 control rule).
- **Hairline** (#D6D4CE): 1 dp card border and dividers only.

### Extra values kept from the Stitch output

The final screens come from Stitch and are kept as generated. Besides the roles above they use these values, which exist as `color/stitch/*` Variables in Figma so no colour on any screen is an unbound hex:

| Variable | Value | Where it appears |
|---|---|---|
| stitch/text-secondary | #6F5A4E | secondary text and icons |
| stitch/on-surface-variant | #584239 | muted text on warm surfaces |
| stitch/primary-container | #8A2E00 | pressed primary button, a few accents |
| stitch/on-primary-fixed | #370E00 | text on peach |
| stitch/primary-fixed | #FADDCD, #FFDBCE | peach tints |
| stitch/tertiary-dark | #00592D | green text |
| stitch/background | #FDF9F3 | warm page background on some screens |
| stitch/surface-lowest | #F8F3ED | info panels |
| stitch/surface-container-low | #F2EDE8 | field fill, banners |
| stitch/surface-container | #ECE7E2 | chips, disabled |
| stitch/outline-variant | #E6E2DD, #DED9D4, #E0C0B4 | hairlines and borders |

`scrim` (#000000 at 40%) is used behind dialogs. Contrast of every text pair on page 04 of the Figma file was recomputed and passes 4.5:1 (outline on surface 4.6:1 passes the 3:1 control rule).

### Named Rules
**The Needs-You Rule.** Orange appears on at most about 10% of any screen: the primary button, the active tab and open-role highlights. Its rarity is how the eye finds the next action.

**The Never-Color-Alone Rule.** Every status (filled, open, pending, accepted, declined, full) has an icon and a text label as well as a color.

**The Separation Rule.** Passing text contrast is not enough. Cards, chips and fields must be separable from their ground: cards have a 1 dp Hairline border on white; every tonal chip also carries a 1 dp Hairline border; fields use the Outline color. Never place a pale tint on a pale tint.

## Typography

**Display / Body Font:** Be Vietnam Pro (fallback Roboto). Designed for Vietnamese diacritics; one family across all roles keeps the system simple.

**Character:** Rounded, humane, slightly informal; weight steps (400 / 600 / 700) do the hierarchy work instead of many sizes. Minimum size anywhere is 14 sp.

### Hierarchy
- **Headline Small** (700, 24/32 sp): screen titles on My classes, Proposals, sign-in.
- **Title Large** (600, 20/28 sp): app bar title, dialog title.
- **Title Medium** (600, 16/24 sp): card titles (team name, student name), section headers.
- **Body Large** (400, 16/24 sp): idea summaries, form input text. Keep lines under about 40 characters per line on a 360 dp screen.
- **Body Medium** (400, 14/20 sp): metadata (major, semester, role names), helper and error text.
- **Label Large** (600, 14/20 sp): buttons, chips, tab labels. Sentence case, no all-caps.

### Named Rules
**The Four-Steps Rule.** Only these six styles exist. Screens map text to a role and never pick sizes by hand.

## Layout

Compact width first: 360 dp design width, checked at 412 dp. Screen side margin 16 dp. Vertical rhythm on a 4 dp base; groups inside a card use 8 dp, separate cards use 16 dp, sections use 24 dp. Lists scroll vertically; headers and the bottom navigation bar stay fixed. Primary button sits at the bottom of the content area on form screens (sticky, 16 dp above the nav bar or keyboard).

Touch targets are at least 48 x 48 dp with at least 8 dp between targets. Layout uses constraints and Auto Layout so it reflows between 360 and 412 dp. On 600 dp and wider (not designed, specified in the handoff): swap the bottom navigation bar for a navigation rail and show Classes as list plus detail panes.

Spacing tokens: xs 4, sm 8, md 16, lg 24, xl 32.

### Content budget per screen

Fewer things, bigger. A list screen shows at most 3 cards or 5 plain rows in the first viewport. A detail screen has at most 3 plain sections separated by spacing and dividers, not by boxes. One filter row only. No banners, no badge rows, no section icons, no inline links such as "Tap to view". Every screen uses the same app bar style and the same three bottom destinations with the same labels (Classes, Proposals, Profile).

## Elevation & Depth

Flat and outlined at rest. Depth comes from 1 dp Hairline borders on white and the single step to Paper Stone, not from shadows. Shadows appear only on the dialog scrim surface and the snackbar, using a soft offset (0 / 2 dp / 8 dp blur at low opacity).

### Named Rules
**The Flat-By-Default Rule.** Cards have no shadow at rest. Pressed state fills the card with Paper Stone and shows a ripple.

## Shapes

Rounded but disciplined: 8 dp fields and small chips, 12 dp cards and role slots, 16 dp bottom sheets and dialogs, full pill for buttons and filter chips. Open major slots use a 2 dp dashed outline in Outline color; filled slots use a solid tonal fill. No arbitrary clipping masks.

## Components

All components are Material 3 equivalents, themed by the tokens above. Every component below must exist with its states in Figma.

- **Button.** Filled (`button-primary`), tonal (`button-tonal`), outlined and text variants, 48 dp height, pill shape. States: default, pressed (one tonal step darker + ripple), disabled (Panel Deep fill, Slate-at-60% text, label unchanged), loading (label replaced by a 20 dp circular indicator, width fixed).
- **Text field.** Filled style, 56 dp, label above the value, helper text below. States: default, focused (2 dp primary border), filled, error (Alert Red border + error icon + message that names the problem and the fix), disabled.
- **Card.** White fill, 1 dp Hairline border, 12 dp radius, 16 dp padding (Flutter: outlined Card). States: default, pressed when tappable. A team card holds: team name (Title Medium), the major row, a fit chip when it is a proposal, and one text line "Needs Design". A card has no button inside; the whole card is the tap target.
- **Major slot (custom).** Square, 40 dp on cards and 48 dp on detail screens. Open: dashed outline + major icon. Filled: tonal green fill + major code. Proposed: Peach Wash fill, 2 dp Burnt Orange outline, major code, plus mark. Names are always 14 sp text in a list, never captions under the slots (they collide at 360 dp). Slots are not individually tappable on cards.
- **Navigation bar.** 3 destinations: Classes, Proposals, Profile. Selected state shows a pill indicator in Peach Wash plus a filled icon and bold label; unselected uses outlined icons. Proposals shows a numeric badge when proposals are waiting.
- **App bar.** Small top app bar with title and back arrow where nested. Variants: default and with actions (search, filter).
- **Dialog.** Material dialog, 16 dp radius. Variants: confirmation (e.g. "Approve team?", filled primary + text Cancel) and destructive (e.g. "Discard proposal?", Alert Red confirm button, text Cancel).
- **Loading state.** Circular progress with one line while the AI matches ("Finding teammates"), and skeleton rows on lists (Paper Stone blocks).
- **Empty state.** 48 dp line icon, one sentence, one action button (e.g. "All matched" / "View teams").
- **Error state.** Plain-language message, the cause, and a retry action (e.g. "You're offline" / "Try again").
- **Snackbar.** Transient feedback with one action (e.g. "Approved. Undo", 5 seconds).

### Named Rules
**The One Primary Rule.** Each screen has exactly one filled primary button. Everything else is tonal, outlined or text.

**The Honest Copy Rule.** Buttons name their action ("Match with AI", "Approve"). Errors name the problem and the recovery.

## Do's and Don'ts

**Do**
- Use real EXE content: majors (SE, AI, MKT, GD), class labels, team names and student names from the prompt only.
- Pair every color status with an icon and a label.
- Keep body text at 14 sp or larger and touch targets at 48 dp or larger.
- Show loading, empty and error states on the AI matching flow (matching, all matched, offline).

**Don't**
- Don't put white text on FPT Orange (#F37021) or use it as the only border of a control.
- Don't use more than one filled primary button per screen.
- Don't use ALL CAPS anywhere, small labels above headings, or arrow glyphs inside button text.
- Don't use blue anywhere, or put one pale tint on another pale tint.
- Don't stack tag pills (course, campus, status, mentor) on a card. One status chip at most.
- Don't invent institutions, campuses, advisors, rooms, dates or years. Use only the content the prompt gives.
- Don't put a card inside a card, a second button inside a tappable card, or text smaller than 14 sp.
- Don't use emoji as icons; use one consistent outlined icon set (Material Symbols Outlined, 24 dp, weight 400; the Stitch output uses Outlined, filled glyph for the selected tab).
- Don't nest cards, add colored side borders, gradients, glass effects or drop shadows on cards.
- Don't hand-pick font sizes outside the six type roles.
