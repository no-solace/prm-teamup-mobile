---
name: TeamUp EXE Mentor
colors:
  surface: '#fdf9f3'
  surface-dim: '#ded9d4'
  surface-bright: '#fdf9f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f3ed'
  surface-container: '#f2ede8'
  surface-container-high: '#ece7e2'
  surface-container-highest: '#e6e2dd'
  on-surface: '#1c1b18'
  on-surface-variant: '#584239'
  inverse-surface: '#32302d'
  inverse-on-surface: '#f5f0eb'
  outline: '#8c7168'
  outline-variant: '#e0c0b4'
  surface-tint: '#a73a00'
  primary: '#8a2e00'
  on-primary: '#ffffff'
  primary-container: '#b23e00'
  on-primary-container: '#ffdbcf'
  inverse-primary: '#ffb59a'
  secondary: '#605e59'
  on-secondary: '#ffffff'
  secondary-container: '#e3dfd9'
  on-secondary-container: '#64625e'
  tertiary: '#00592d'
  on-tertiary: '#ffffff'
  tertiary-container: '#247242'
  on-tertiary-container: '#a5f4b8'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbce'
  primary-fixed-dim: '#ffb59a'
  on-primary-fixed: '#370e00'
  on-primary-fixed-variant: '#802a00'
  secondary-fixed: '#e6e2dc'
  secondary-fixed-dim: '#c9c6c0'
  on-secondary-fixed: '#1c1c18'
  on-secondary-fixed-variant: '#484742'
  tertiary-fixed: '#a5f4b8'
  tertiary-fixed-dim: '#8ad79e'
  on-tertiary-fixed: '#00210d'
  on-tertiary-fixed-variant: '#005229'
  background: '#fdf9f3'
  on-background: '#1c1b18'
  surface-variant: '#e6e2dd'
typography:
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  title-md:
    fontFamily: Be Vietnam Pro
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 24px
  title-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 18px
  label-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 18px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-2xl: 3rem
---

## Brand & Style

This design system is tailored for an operational mentor workspace where academic and industry mentorship converges. The personality is grounded, authoritative, purposeful, and sharp. It strips away ornamental distractions to provide mentors with clarity, structured review cadences, and immediate actionable insights.

The design movement combines **Minimalism** with **Structured Editorial Utility**:
- Zero drop shadows or diffused ambient lighting effects.
- Depth and division achieved strictly through structural tonal planes (`Paper Stone` vs `White`) and crisp 1dp hairline borders.
- Absolute avoidance of any blue hues across all states, accents, links, and system indicators.
- High editorial legibility driven by utilitarian typography, tabular numerical readouts, and signature major row components tailored for swift mentorship evaluations.

## Colors

The color palette centers around warm terracotta, earthy neutrals, and dense foliage accents. Cold blues and slate tones are strictly excluded from the entire interface.

### Color Tokens & Assignments
- **Primary (`#B23E00`, Burnt Signal Orange)**: Main action drivers, active selection states, high-priority mentorship CTAs.
  - `on-primary`: `#FFFFFF`
  - `primary-container`: `#FFE2D2` (Peach Wash)
  - `on-primary-container`: `#3B1400` (Deep Umber)
- **Brand Accent (`#F37021`, FPT Orange)**: Reserved exclusively for application splash screens, primary brand marks, and unread milestone badges. Never used for standard text links or body backgrounds.
- **Secondary (`#2F2E2A`, Graphite)**: Structured controls, secondary tabs, high-level headers, and neutral active chips.
  - `on-secondary`: `#FFFFFF`
  - `secondary-container`: `#E9E7E2` (Stone)
  - `on-secondary-container`: `#1C1B18` (Ink)
- **Tertiary (`#1B6B3C`, Filled Green)**: Project approval, validated deliverables, meeting milestones, success states.
  - `on-tertiary`: `#FFFFFF`
  - `tertiary-container`: `#D6F0DD` (Mint)
  - `on-tertiary-container`: `#07301A` (Forest)
- **Error (`#B3261E`, Alert Red)**: Blockers, rejected submissions, urgent critical actions.
  - `on-error`: `#FFFFFF`
  - `error-container`: `#F9DEDC` (Rose Tint)
  - `on-error-container`: `#410E0B` (Deep Wine)
- **Surfaces & Neutral Structural Layers**:
  - `surface`: `#FFFFFF` (Card base, focused input fill)
  - `surface-container-low`: `#F3F2EF` (Paper Stone canvas background)
  - `surface-container`: `#E9E7E2` (Stone dividers, secondary surfaces)
  - `on-surface`: `#1C1B18` (Ink text, heavy data values)
  - `on-surface-variant`: `#55534D` (Soft Ink, descriptive metadata, secondary labels)
  - `outline`: `#77756F` (Active borders, focused outlines)
  - `outline-variant`: `#D6D4CE` (Hairline rules, structural 1dp borders)

### Enforced Rule
Blue values (RGB components dominated by blue, indigo, sky, or azure) are banned across all interface elements, links, charts, badges, and focus rings.

## Typography

The design system enforces **Be Vietnam Pro** universally across all textual elements.

### Key Rules
- **Minimum Type Size**: Absolute minimum of `14px` (`14sp`) across all functional states, including captions, chips, helper notes, and micro-labels. No smaller type scale is permitted.
- **Letter Casing**: Strict Sentence case for all headings, labels, button texts, table headers, and status badges. Never use full UPPERCASE.
- **Figure Alignment**: Apply `font-variant-numeric: tabular-nums` (tabular figures) across all numerical evaluations, timestamps, team progress percentages, and score matrices to ensure strict vertical rhythm.

## Layout & Spacing

The layout model utilizes a fluid responsive column grid:
- **Mobile (<768px)**: 4-column layout with `16px` (`margin`) outer screen padding and `16px` (`gutter`) gutters between elements.
- **Tablet (768px - 1024px)**: 8-column layout with `24px` (`margin-tablet`) outer margins and `16px` gutters.
- **Desktop (>1024px)**: 12-column layout capped at `1280px` maximum viewport width, using `40px` (`margin-desktop`) outer padding and `24px` (`gutter-desktop`) gutters.

Spacing relies on an 8pt base grid with a 4pt sub-step (`space-xs`). Whitespace is balanced and dense to suit data-heavy mentoring workflows.

## Elevation & Depth

Visual hierarchy is maintained without drop shadows, glows, or blurred backdrops.

### Rules
- **No Drop Shadows**: CSS `box-shadow` is prohibited throughout all components, modals, dropdowns, and cards (`box-shadow: none !important`).
- **Surface Layering**: The global canvas uses `surface-container-low` (`#F3F2EF`). Content cards sit on pure `surface` (`#FFFFFF`).
- **Hairline Borders**: Every white card, sheet, modal, and popover is circumscribed by a crisp `1dp` border using `outline-variant` (`#D6D4CE`).
- **Active & Focus Hierarchy**: Enhanced through color fill shifts (e.g., `surface-container-low` to `primary-container`) and outline weight shifts (1dp `#D6D4CE` transitioning to 1.5dp `#B23E00` or `#77756F`).

## Shapes

The geometric framework favors a structured, architectural aesthetic (`roundedness: 1`):
- Standard elements (inputs, badges, cards, buttons) use soft, subtle corners (`4px` / `0.25rem`).
- Large structural cards and dialog modals expand to `8px` (`0.5rem`).
- Full pill radii are prohibited to avoid a playful or casual tone, keeping controls functional and precise.

## Components

### 1. Cards
- **Background**: `surface` (`#FFFFFF`).
- **Border**: Exactly `1dp` solid `outline-variant` (`#D6D4CE`).
- **Padding**: `16px`.
- **Shadow**: None.

### 2. Signature Major Row
The signature layout pattern for project rosters, student submissions, and feedback items:
- **In Cards / Overviews**: Fixed height of `40dp`. Items are horizontally aligned with icon or status pill on the left, primary metadata in the middle, and quick-action icon or score on the far right.
- **In Detail Screens**: Fixed height of `48dp`. Provides generous hit areas for row interactions, deep metadata review, and inline scoring tools.
- **Dividers**: Separated by `1dp` bottom borders in `outline-variant` (`#D6D4CE`).

### 3. Buttons
- **Primary Button**: Background `primary` (`#B23E00`), text `on-primary` (`#FFFFFF`), `4px` corner radius. Height `40dp` (standard) or `48dp` (large). Active feedback shifts background to `#933300`.
- **Secondary Button**: Background `secondary-container` (`#E9E7E2`), text `on-secondary-container` (`#1C1B18`), border `1dp` solid `outline-variant` (`#D6D4CE`).
- **Tertiary / Success Button**: Background `tertiary` (`#1B6B3C`), text `on-tertiary` (`#FFFFFF`).
- **Destructive Button**: Background `error-container` (`#F9DEDC`), text `error` (`#B3261E`), border `1dp` solid `error` (`#B3261E`).

### 4. Chips & Badges
- **Status Mint**: Background `tertiary-container` (`#D6F0DD`), text `on-tertiary-container` (`#07301A`).
- **Status Alert**: Background `error-container` (`#F9DEDC`), text `on-error-container` (`#410E0B`).
- **Status Progress**: Background `primary-container` (`#FFE2D2`), text `on-primary-container` (`#3B1400`).
- **Rules**: Text size minimum `14px`, `4px` radius, sentence case.

### 5. Input Fields
- **Container**: Background `surface` (`#FFFFFF`), `1dp` border using `outline` (`#77756F`).
- **Focus State**: Border shifts to `1.5dp` solid `primary` (`#B23E00`).
- **Typography**: Minimum `14px` Be Vietnam Pro.
- **Height**: `40dp` or `48dp`.

### 6. Lists
- List rows conform to the `40dp` or `48dp` standard. Alternating rows remain white or tint to `surface-container-low` (`#F3F2EF`) during hover/press.

### 7. Checkboxes & Radio Buttons
- Selected state fills with `primary` (`#B23E00`) or `secondary` (`#2F2E2A`).
- Unselected outline uses `outline` (`#77756F`).
- Hit target strictly minimum `40dp x 40dp`.