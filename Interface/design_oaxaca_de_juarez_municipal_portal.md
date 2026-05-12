---
name: Oaxaca de Juárez Municipal Portal
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#574145'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#8a7174'
  outline-variant: '#ddbfc3'
  surface-tint: '#a93154'
  primary: '#7a0933'
  on-primary: '#ffffff'
  primary-container: '#9a2649'
  on-primary-container: '#ffb3c1'
  inverse-primary: '#ffb2bf'
  secondary: '#5e5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e4e2e2'
  on-secondary-container: '#646464'
  tertiary: '#735c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#cba72f'
  on-tertiary-container: '#4e3d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9de'
  primary-fixed-dim: '#ffb2bf'
  on-primary-fixed: '#3f0016'
  on-primary-fixed-variant: '#89173d'
  secondary-fixed: '#e4e2e2'
  secondary-fixed-dim: '#c8c6c6'
  on-secondary-fixed: '#1b1c1c'
  on-secondary-fixed-variant: '#474747'
  tertiary-fixed: '#ffe088'
  tertiary-fixed-dim: '#e9c349'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#574500'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  h1:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  h2:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  h3:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-mono:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  sidebar-width: 280px
  container-max: 1440px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 32px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style
The brand personality of this design system is institutional, reliable, and strictly professional. Designed for the municipality of Oaxaca de Juárez, it balances the cultural heritage of the region with the efficiency of modern infrastructure management. The UI evokes a sense of civic duty and administrative precision, ensuring that public officials feel equipped with an authoritative tool.

The chosen style is **Corporate / Modern**. It utilizes a structured information hierarchy, a refined use of the municipal burgundy, and high-density data layouts. The interface avoids unnecessary flourishes, focusing instead on clarity, speed of information retrieval, and the gravity of public service.

## Colors
The palette is led by the institutional #9A2649 (Burgundy), used for primary actions, navigation headers, and branding elements. This color signifies authority and historical continuity.

- **Primary:** Used for the sidebar, primary buttons, and active states.
- **Neutrals:** A range of cool grays provides the foundation for the administrative interface, with #F8F9FA used for the main background to reduce eye strain during long periods of data entry.
- **Functional:** Colors are saturated to ensure immediate recognition. Success green is used for completed maintenance; Warning yellow for scheduled works; and Urgent red for reported potholes requiring immediate intervention.

## Typography
This design system utilizes **Inter** for all layers of the interface. Inter’s tall x-height and exceptional legibility make it ideal for data-heavy administrative tables and map labels.

For numerical data—crucial in pothole tracking and coordinate management—the "tabular numbers" feature of Inter should be enabled to ensure that columns of figures align perfectly. Headlines are kept tight and bold to establish a clear hierarchy, while labels use a slightly increased letter spacing and uppercase styling to differentiate metadata from primary content.

## Layout & Spacing
The layout follows a **Fixed Grid** model for administrative clarity, centered on a 12-column system. 

1.  **Sidebar:** A fixed 280px navigation sits on the left, housing the primary municipal modules (Map, Dashboard, Reports, Registry).
2.  **Main Content:** The workspace utilizes a white background with a max-width of 1440px. 
3.  **Map Interface:** For the road maintenance module, the map should be "Edge-to-Edge" within its container, utilizing floating control panels for filters and layers.
4.  **Responsive Behavior:** On tablet, the sidebar collapses into an icon-only rail. On mobile, the sidebar becomes a bottom-sheet navigation or a hidden drawer, and margins reduce to 16px to maximize data visibility.

## Elevation & Depth
Depth is conveyed through **Tonal Layers** and **Low-contrast outlines** rather than aggressive shadows. This maintains a "flat" professional aesthetic that feels like a physical ledger or official document.

- **Level 0 (Base):** #F8F9FA (Background).
- **Level 1 (Cards/Panels):** White surface with a 1px border of #E9ECEF.
- **Level 2 (Active/Floating):** White surface with a soft, 8% opacity black shadow (4px blur) to indicate interactive elements like pop-up map tooltips or dropdown menus.
- **Level 3 (Modals):** Centered overlays with a 16% opacity backdrop dimming the interface.

## Shapes
This design system uses **Soft** roundedness (0.25rem). This subtle rounding takes the edge off the "industrial" feel of the system without making it appear consumer-grade or "bubbly."

- **Buttons & Inputs:** 0.25rem (4px) corner radius.
- **Cards & Map Overlays:** 0.5rem (8px) corner radius for a more structural appearance.
- **Status Badges:** Fully rounded (pill) to distinguish them from interactive buttons.

## Components
- **Sidebar Navigation:** Use a dark theme (#9A2649) for the sidebar. Icons should be minimalist line-art. Active states are indicated by a high-contrast white left-accent bar.
- **Data Cards:** Cards should feature a 4px top-border color-coded to the status (e.g., a red top-border for "Urgent" pothole reports).
- **Map Interface:** Use custom markers—circles with white borders and functional color fills (#9A2649 for ongoing work, #D90429 for reported).
- **Buttons:** 
    - *Primary:* Solid #9A2649 with white text. 
    - *Secondary:* Transparent with a 1px #9A2649 border. 
    - *Functional:* Solid red/green for destructive or confirming actions.
- **Inputs:** High-contrast fields with 1px #D1D5DB borders, turning #9A2649 on focus. Labels must always be visible above the field.
- **Executive Reports:** Use clear, large-format typography for KPIs (e.g., "Total Potholes Repaired") with small sparkline charts next to the figures to show trends.