---
name: Executive Coordination System
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
  secondary: '#6f5a4e'
  on-secondary: '#ffffff'
  secondary-container: '#faddcd'
  on-secondary-container: '#756053'
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
  secondary-fixed: '#faddcd'
  secondary-fixed-dim: '#dcc1b2'
  on-secondary-fixed: '#27180f'
  on-secondary-fixed-variant: '#564337'
  tertiary-fixed: '#a5f4b8'
  tertiary-fixed-dim: '#8ad79e'
  on-tertiary-fixed: '#00210d'
  on-tertiary-fixed-variant: '#005229'
  background: '#fdf9f3'
  on-background: '#1c1b18'
  surface-variant: '#e6e2dd'
typography:
  headline:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: 0px
  title:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: 0px
  card-title:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0px
  body:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0px
  metadata:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.1px
  button:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.1px
  chip:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-field:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.1px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes a high-clarity, utility-first operational environment built specifically for high-stakes team assembly, role provisioning, and administrative coordination. The personality is disciplined, grounded, and decisive. It avoids decorative fluff, tech-clichés, and consumer-grade gamification in favor of an ergonomic, paper-and-slate utilitarian aesthetic.

The visual execution relies on an authentic tactile minimalism: stark white operational canvases punctuated by high-contrast burnt orange accents, purposeful state-based outlines, and dedicated occupancy signaling (such as filled versus vacant team slots). Every interaction emphasizes direct manipulation, clear affordance boundaries, and zero ambiguity.

Core aesthetic guardrails:
- Strictly no blue tones across any interactive or informative element.
- Absolutely zero gradients, frosted glass effects, or fuzzy drop shadows.
- No nested cards or colored side borders. Hierarchy is asserted strictly through clean borders and structural spacing.
- Text must consistently use sentence case; all-caps styling and decorative directional glyphs (such as trailing arrows in action labels) are strictly forbidden.
- Iconography is restricted to standard outlined Material Symbols Rounded; emoji characters are never permitted as interface iconography.

## Colors

The palette employs warm, neutral masonry tones anchored by an assertive burnt orange primary tone and high-legibility dark slate typography. State signaling is discrete and unambiguous.

### Core Canvas & Typography
- **Screen & Card Base:** `#FFFFFF` (pure white canvas for maximum clarity and structural contrast).
- **Primary Text:** `#1C1B18` (deep charcoal-ink for primary hierarchy and high legibility).
- **Secondary Text:** `#55534D` (grounded warm slate for supporting metadata and secondary labels).
- **Subtle Surface Outline:** `#D6D4CE` (used for 1dp card borders, unselected chip outlines, and default component dividers).
- **Input & Inactive Fill:** `#F3F2EF` for text field surfaces; `#E9E7E2` for tonal buttons and unselected chips.

### Functional & Interaction Colors
- **Primary Action & Active Indicators:** `#B23E00` (burnt orange for filled primary buttons, floating focal actions, and active tab indicator lines). Text on primary fills is always `#FFFFFF`.
- **Selected Accent Surfaces:** `#FFE2D2` (warm peach tint for selected chips and active navigation pills), paired strictly with `#3B1400` text for maximum accessibility.
- **Tonal Controls:** `#E9E7E2` fill paired with `#1C1B18` text and a 1dp `#D6D4CE` border.

### Team Role Slot Semantics
- **Occupied / Filled Role Slot:** `#D6F0DD` fill, bounded by a 1dp solid `#1B6B3C` border with `#07301A` deep green text/monogram.
- **Vacant / Open Role Slot:** `#FFFFFF` fill bounded by a 2dp dashed border in `#77756F`, paired with centered outlined role iconography in `#77756F`.

### Feedback & Notifications
- **Error Container:** `#F9DEDC` with high-contrast `#B3261E` foreground text and icons.
- **Snackbar Surface:** `#2F2E2A` solid charcoal fill with `#FFFFFF` text.
- **Prohibited:** No blue tones under any circumstances, even for informational or hyperlink states.

## Typography

Typography is governed exclusively by **Be Vietnam Pro**. The type system strictly enforces an absolute minimum size floor of 14sp across the entire product; no captions or microcopy are permitted below this threshold to ensure complete accessibility on dense Android displays.

Rules of execution:
- **Capitalization:** Use standard sentence case universally across headers, navigation labels, chips, and actions. Never employ uppercase/all-caps styling.
- **Clarity in Action Labels:** Text labels must be explicit and self-contained (e.g., "Confirm roster", "Assign teammate"). Never append unicode or glyph arrows (like `→` or `>`) to button copy.
- **Hierarchy:** 
  - `headline` (24sp Bold) anchors page titles.
  - `title` (20sp Semibold) defines primary section transitions.
  - `card-title` (16sp Semibold) and `body` (16sp Regular) govern component-level reading flow.
  - `metadata` (14sp Regular) handles timestamps, role statuses, and contextual helpers.
  - `button` and `chip` (14sp Semibold) provide high-contrast legibility inside compact interactive containers.

## Layout & Spacing

Layout geometry is optimized around a fixed 360 x 800 dp mobile frame standard for modern handheld interfaces, scaling fluidly across viewport widths via a disciplined 4dp base module.

### Canvas Grid & Margins
- **Global Lateral Inset:** Strictly 16dp (`1rem`) screen margins on left and right borders. All persistent content and standard cards conform to this boundary.
- **Internal Column Grid:** Single-column layout on mobile with 16dp horizontal gutters between split controls or multi-column role lists.
- **Spacing Steps:**
  - `space-xs` (4dp): Intra-component micro-spacing (icon-to-text gaps, tight tag padding).
  - `space-sm` (8dp): Element stacking within grouped fields, vertical margins between related meta items.
  - `space-md` (16dp): Standard internal container padding for cards and sections.
  - `space-lg` (24dp): Gaps separating discrete content blocks or modular card stacks.
  - `space-xl` (32dp): Major topical category breaks and bottom safe-area offsets.

### Touch Boundaries
Every clickable target must adhere to a strict minimum touch envelope of 48dp x 48dp, even if the visible element itself (such as a 32dp chip or a standalone icon) occupies a smaller visual footprint.

## Elevation & Depth

This system intentionally eliminates traditional shadow-based elevation and simulated physical skeuomorphism. Depth is strictly planar, communicated through crisp boundaries, intentional surface fills, and structural contrast.

Key architectural rules:
- **Shadow Elimination:** No cards, dialogs, or dropdowns may utilize ambient or directional drop shadows (`box-shadow: none`). Surfaces sit completely flat against the base white viewport.
- **Boundary Construction:** Cards are delineated by an explicit 1dp outline in `#D6D4CE`.
- **No Side Borders:** Cards must have a uniform 1dp border on all four sides. Accentuated colored vertical or horizontal side stripes are prohibited.
- **No Nested Card Structures:** A card cannot sit inside another card. If content within a card requires secondary grouping, use plain horizontal divider rules (`#D6D4CE`, 1dp height) or flat contrast panels (such as `#F3F2EF` field boxes).
- **Z-Index Layering:** Overlays, navigation bars, and snackbars rely on flat z-axis positioning:
  - Persistent Bottom Bar: Sits flush with base `#FFFFFF`, framed by a solid 1dp top divider in `#D6D4CE`.
  - Floating Snackbar: High-contrast opaque `#2F2E2A` slab with no shadow, positioned 16dp above the base navigation target.

## Shapes

The design uses a clean geometry of three distinct corner radius tiers:

- **Cards & Primary Modules:** 12dp corner radius. Uniform on all four corners.
- **Interactive Form Fields:** 8dp corner radius. Applied to text inputs, textareas, and selection menus.
- **Pills (Interactive Tokens):** Full pill radius (9999dp) applied to all buttons (primary, tonal, secondary), filtering chips, occupancy status tags, and bottom navigation indicators.
- **Avatars & Monogram Badges:** Fully circular (50% / pill radius) for standard circular portrait thumbnails and occupied role initials.

## Components

### Buttons
- **Primary Filled Button:** 
  - Height: Exactly 48dp.
  - Fill: `#B23E00`.
  - Typography: 14sp Semibold `#FFFFFF`. Sentence case only. No trailing arrows.
  - Shape: Pill (full radius).
  - Padding: 16dp horizontal.
- **Tonal Button:** 
  - Height: Exactly 48dp.
  - Fill: `#E9E7E2`.
  - Border: 1dp solid `#D6D4CE`.
  - Typography: 14sp Semibold `#1C1B18`.
  - Shape: Pill.

### Chips & Filters
- **Unselected Chip:**
  - Height: 32dp (within a 48dp minimum touch target).
  - Fill: `#E9E7E2`.
  - Border: 1dp solid `#D6D4CE`.
  - Text: 14sp Semibold `#1C1B18`.
  - Shape: Pill.
- **Selected Chip:**
  - Height: 32dp.
  - Fill: `#FFE2D2`.
  - Border: None (or flush 1dp matching `#FFE2D2`).
  - Text: 14sp Semibold `#3B1400`.
  - Shape: Pill.

### Cards
- **Base Style:** `#FFFFFF` background, strictly 1dp solid `#D6D4CE` outline, 12dp corner radius.
- **Prohibitions:** Absolutely no drop shadows, no tinted full fills, no nested cards inside cards, and no colored edge accents.
- **Internal Padding:** 16dp uniform.
- **Header:** 16sp Semibold `#1C1B18`.

### Role Slots (Team Coordination Modules)
- **Filled Role Slot:**
  - Background: `#D6F0DD`.
  - Border: 1dp solid `#1B6B3C`.
  - Shape: 12dp radius or full pill depending on layout role list presentation.
  - Content: User initials in 14sp Semibold `#07301A` alongside user name and assigned operational designation.
- **Open / Vacant Role Slot:**
  - Background: `#FFFFFF`.
  - Border: 2dp dashed outline in `#77756F`.
  - Shape: 12dp radius or pill matching slot grid.
  - Content: Centered outlined Material Symbol Rounded icon in `#77756F` paired with 14sp metadata indicating "Open Slot".

### Form Input Fields
- **Container:** Height 48dp (single line) or minimum 96dp (multiline), fill `#F3F2EF`.
- **Border:** 1dp solid `#77756F`, corner radius 8dp.
- **Text:** 16sp regular `#1C1B18`. Placeholder text in `#55534D`.
- **Label:** 14sp semibold `#1C1B18` placed above the field with 8dp vertical separation.

### Selection Controls (Checkboxes & Radios)
- **Checkbox:** 20dp square, 4dp radius, bounded by `#77756F` outline. When checked: `#B23E00` solid fill with white checkmark icon.
- **Radio:** 20dp outer circle, `#77756F` outline. When checked: `#B23E00` outline with centered 10dp filled circle in `#B23E00`.

### Navigation & Feedback
- **Bottom Navigation Pill:** Active tab indicator displays as a `#FFE2D2` pill containing `#3B1400` icon and text. Inactive tabs display `#55534D`. The bar features an active tab indicator underline in `#B23E00`.
- **Snackbar:**
  - Container: Flat `#2F2E2A` fill with 8dp corner radius. No shadow.
  - Text: 14sp Regular `#FFFFFF`.
  - Action: 14sp Semibold `#FFE2D2`.
- **Alert Banner:**
  - Container: `#F9DEDC` fill with 8dp radius.
  - Content: `#B3261E` 14sp semibold text accompanied by outlined alert icon.