# UI / UX DESIGN GUIDELINES — DHOLERA REAL ESTATE

---

## 1. Design Philosophy & Principles

The Dholera Real Estate mobile app is designed for modern property investors and real estate administrators.
- **Aesthetic:** Clean, modern, high-contrast, premium real-estate corporate theme.
- **Tone:** Professional, reliable, minimal, fast.
- **Typography:** Modern Google Fonts (e.g. `Inter` or `Outfit`).
- **Simplicity:** High scannability, zero unnecessary animations or clutter.

---

## 2. Color Palette & Token System

| Design Token | Hex Code | Purpose |
| :--- | :--- | :--- |
| `primary` | `#0A2540` | Deep Navy Blue (Primary Brand & App Bar) |
| `primaryAccent` | `#00D4B2` | Teal Accent (Highlights, Badges, CTAs) |
| `secondary` | `#1A1F36` | Dark Slate (Headings & Primary Text) |
| `surface` | `#FFFFFF` | Card & Sheet Backgrounds |
| `background` | `#F8F9FC` | Main Page Background |
| `textSecondary` | `#697386` | Subtitles, Field Labels, Captions |
| `border` | `#E3E8EE` | Input borders & card outlines |
| `success` | `#0E9F6E` | Active user status, success snackbars |
| `error` | `#F05252` | Deactive status, error banners, destructive actions |

---

## 3. Standard UI Components & Layout Specs

### Property Card (`PropertyCard`)
- Elevated white card (`elevation: 2`, `borderRadius: 16.0`).
- **Top:** 16:9 aspect-ratio image thumbnail with subtle gradient overlay showing area badge (`500 Sq Yard`).
- **Body:**
  - `Village Name` in Bold 18sp.
  - Subtitle: `Survey No: 102/A | Zone: Residential`.
  - Chips / Tags for `Road: 24 Mtr` and `TP: TP-1`.
  - `Reference` tag at bottom right.

### Input Fields (`CustomTextField`)
- Rounded border (`borderRadius: 12.0`).
- Outlined style with subtle grey border `#E3E8EE`.
- Active focus highlight with `primaryAccent` `#00D4B2`.
- Clear error message feedback under field.

### Buttons (`CustomButton`)
- Height: 52px (Full touch area).
- Border radius: 12px.
- Loading state: Replaces button text with centered `CircularProgressIndicator` (white/accent).

---

## 4. Branding & Logo Guidelines

- Logo file: `assets/images/logo.png`.
- **STRICT RULE:** Never redraw, modify proportions, adjust colors, or generate substitute logos.
- Displayed prominently on:
  - Splash Screen
  - Login Screen Header
  - Navigation Drawer / App Bar Header
