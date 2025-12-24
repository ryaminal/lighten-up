# Design System Reference

A comprehensive design system for building consistent, accessible applications. This guide is framework-agnostic and can be adapted to any technology stack (React, Vue, Svelte, etc.).

## UI Framework

**shadcn-svelte** - https://shadcn-svelte.com/

We will use shadcn-svelte as our component library for future UI development. This provides:

- Accessible, customizable components
- Built on Radix UI primitives
- Tailwind CSS styling
- Full TypeScript support
- Copy-paste components (not a package dependency)

---

## Table of Contents

1. [Color Palette](#color-palette)
2. [Typography](#typography)
3. [Spacing & Layout](#spacing--layout)
4. [Components](#components)
5. [Responsive Design](#responsive-design)
6. [Animation](#animation)
7. [Implementation Examples](#implementation-examples)

---

## Color Palette

### Primary Colors

```css
--color-primary: #137fec;
--color-primary-light: #4a9fff;
--color-primary-dark: #0b4e96;
```

### Background Colors

```css
--color-bg-light: #f6f7f8;
--color-bg-dark: #101922;
--color-surface-dark: #111a22;
--color-surface-card: #233648;
--color-surface-active: #1f2b3a;
```

### Text Colors

```css
--color-text-primary: #ffffff;
--color-text-secondary: #92adc9;
--color-text-muted: #586e84;
--color-text-light: #dbe6f0;
```

### Status/Alert Colors

```css
--color-alert-red: #ef4444;
--color-alert-amber: #f59e0b;
--color-alert-green: #10b981;
--color-alert-blue: #3b82f6;
--color-alert-purple: #a855f7;
```

### Border Colors

```css
--color-border-dark: #233648;
--color-border-light: #324d67;
--color-border-active: #4b6a88;
```

### Semantic Colors

```css
--color-success: #22c55e;
--color-error: #ef4444;
--color-warning: #f59e0b;
--color-info: #3b82f6;
```

### Grayscale

```css
--color-gray-50: #f9fafb;
--color-gray-100: #f3f4f6;
--color-gray-200: #e5e7eb;
--color-gray-300: #d1d5db;
--color-gray-400: #9ca3af;
--color-gray-500: #6b7280;
--color-gray-600: #4b5563;
--color-gray-700: #374151;
--color-gray-800: #1f2937;
--color-gray-900: #111827;
```

---

## Typography

### Font Family

**Primary**: Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif

**Monospace**: 'Monaco', 'Courier New', monospace

### Font Scale

#### Display Styles (Hero text, page titles)

```css
--font-display-large: 34px / 1.2 / 900 / -0.5px letter-spacing --font-display-medium: 28px / 1.2 /
  800 / -0.5px letter-spacing --font-display-small: 24px / 1.3 / 700;
```

#### Heading Styles

```css
--font-heading-large: 20px / 1.4 / 700 --font-heading-medium: 18px / 1.4 / 600
  --font-heading-small: 16px / 1.4 / 600;
```

#### Body Styles

```css
--font-body-large: 16px / 1.5 / 400 --font-body-medium: 14px / 1.5 / 400 --font-body-small: 12px /
  1.5 / 400;
```

#### Label Styles

```css
--font-label-large: 14px / 1.4 / 600 --font-label-medium: 12px / 1.4 / 600
  --font-label-small: 10px / 1.4 / 600 / 0.5px letter-spacing;
```

#### Button Styles

```css
--font-button-large: 16px / 1.2 / 700 --font-button-medium: 14px / 1.2 / 700
  --font-button-small: 12px / 1.2 / 600;
```

#### Utility Styles

```css
--font-caption: 11px / 1.4 / 400 --font-overline: 10px / 1.2 / 700 / 1.5px letter-spacing
  (uppercase) --font-mono: 14px / 1.4 / 500 (monospace family);
```

---

## Spacing & Layout

### Spacing Scale

```css
--space-4xs: 2px;
--space-3xs: 4px;
--space-2xs: 6px;
--space-xs: 8px;
--space-sm: 12px;
--space-md: 16px;
--space-lg: 24px;
--space-xl: 32px;
--space-2xl: 48px;
--space-3xl: 64px;
```

### Border Radius

```css
--radius-xs: 4px;
--radius-sm: 6px;
--radius-md: 8px;
--radius-lg: 12px;
--radius-xl: 16px;
--radius-2xl: 24px;
--radius-full: 9999px;
```

### Icon Sizes

```css
--icon-xs: 16px;
--icon-sm: 20px;
--icon-md: 24px;
--icon-lg: 32px;
--icon-xl: 40px;
```

### Component Heights

```css
/* Buttons */
--button-height-sm: 32px;
--button-height-md: 40px;
--button-height-lg: 48px;

/* Inputs */
--input-height-sm: 32px;
--input-height-md: 40px;
--input-height-lg: 48px;
```

### Layout Constraints

```css
--max-content-width: 1400px;
--sidebar-width: 280px;
--dock-width: 320px;
--nav-rail-width: 80px;
```

### Breakpoints

```css
--breakpoint-mobile: 600px;
--breakpoint-tablet: 1024px;
--breakpoint-desktop: 1440px;
```

---

## Components

### Button Variants

#### Primary Button

- Background: `--color-primary`
- Text: `#FFFFFF`
- Border radius: `--radius-md`
- Padding: `12px 24px` (medium)
- Font: `--font-button-medium`

#### Secondary Button

- Background: `--color-surface-card`
- Text: `--color-text-primary`
- Border radius: `--radius-md`
- Same padding/font as primary

#### Outline Button

- Background: `transparent`
- Border: `1px solid --color-border-light`
- Text: `--color-text-primary`

#### Text Button

- Background: `transparent`
- No border
- Text: `--color-text-secondary`
- Padding: `8px 16px`

#### Danger Button

- Background: `--color-error`
- Text: `#FFFFFF`

### Status Badge

Small colored labels for status indicators:

```css
/* Container */
padding: 4px 8px;
border-radius: --radius-sm (6px);
font: --font-label-small;

/* Variants */
success: green background/border, green text
warning: amber background/border, amber text
error: red background/border, red text
info: blue background/border, blue text
neutral: gray background/border, gray text
```

### Card

```css
background: --color-surface-card;
border: 1px solid --color-border-dark;
border-radius: --radius-lg (12px);
padding: 16px;
```

### Input Field

```css
background: --color-surface-card;
border: 1px solid --color-border-dark;
border-radius: --radius-md (8px);
padding: 12px 16px;
font: --font-body-medium;

/* Focus state */
border: 2px solid --color-primary;

/* Error state */
border: 1px solid --color-error;
```

---

## Responsive Design

### Device Types

- **Mobile**: < 600px
- **Tablet**: 600px - 1023px
- **Desktop**: ≥ 1024px

### Responsive Patterns

#### Container

```css
max-width: var(--max-content-width);
margin: 0 auto;
padding: 0 var(--space-md);

@media (min-width: 768px) {
  padding: 0 var(--space-lg);
}
```

#### Grid Layout

```css
display: grid;
gap: var(--space-lg);

/* Mobile: 1 column */
grid-template-columns: 1fr;

/* Tablet: 2 columns */
@media (min-width: 768px) {
  grid-template-columns: repeat(2, 1fr);
}

/* Desktop: 3+ columns */
@media (min-width: 1024px) {
  grid-template-columns: repeat(3, 1fr);
}
```

---

## Animation

### Duration

```css
--duration-fast: 150ms;
--duration-normal: 250ms;
--duration-slow: 350ms;
```

### Easing

```css
--ease-default: cubic-bezier(0.4, 0, 0.2, 1);
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
```

### Common Transitions

```css
/* Fade in/out */
transition: opacity var(--duration-normal) var(--ease-default);

/* Scale */
transition: transform var(--duration-fast) var(--ease-out);

/* Color change */
transition: background-color var(--duration-normal) var(--ease-default);
```

---

## Shadow Styles

```css
/* Small shadow (cards) */
--shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);

/* Medium shadow (dropdowns) */
--shadow-md: 0 4px 8px rgba(0, 0, 0, 0.1);

/* Large shadow (modals) */
--shadow-lg: 0 8px 16px rgba(0, 0, 0, 0.15);

/* Glow effects */
--shadow-glow-primary: 0 0 15px rgba(19, 127, 236, 0.3);
--shadow-glow-red: 0 0 15px rgba(239, 68, 68, 0.3);
```

---

## Implementation Examples

### CSS Custom Properties

Create a global stylesheet with all design tokens:

```css
:root {
  /* Colors */
  --color-primary: #137fec;
  --color-bg-dark: #101922;

  /* Typography */
  --font-family: Inter, -apple-system, sans-serif;
  --font-body-medium: 14px/1.5;

  /* Spacing */
  --space-md: 16px;
  --space-lg: 24px;

  /* Radius */
  --radius-md: 8px;

  /* Shadows */
  --shadow-md: 0 4px 8px rgba(0, 0, 0, 0.1);
}
```

### TypeScript/JavaScript

```typescript
// colors.ts
export const colors = {
  primary: '#137FEC',
  bgDark: '#101922',
  textPrimary: '#FFFFFF',
  // ...
};

// spacing.ts
export const spacing = {
  xs: '8px',
  sm: '12px',
  md: '16px',
  lg: '24px',
  xl: '32px',
};

// typography.ts
export const typography = {
  bodyMedium: {
    fontSize: '14px',
    lineHeight: '1.5',
    fontWeight: '400',
  },
  headingLarge: {
    fontSize: '20px',
    lineHeight: '1.4',
    fontWeight: '700',
  },
};
```

### Tailwind Config

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    colors: {
      primary: '#137FEC',
      'bg-dark': '#101922',
      'surface-card': '#233648',
      // ...
    },
    spacing: {
      xs: '8px',
      sm: '12px',
      md: '16px',
      lg: '24px',
      // ...
    },
    borderRadius: {
      sm: '6px',
      md: '8px',
      lg: '12px',
      // ...
    },
  },
};
```

### Svelte Component Example

```svelte
<script lang="ts">
  export let type: 'primary' | 'secondary' | 'outline' = 'primary';
</script>

<button class="btn btn-{type}">
  <slot />
</button>

<style>
  .btn {
    padding: 12px 24px;
    border-radius: var(--radius-md);
    font-size: 14px;
    font-weight: 700;
    transition: all var(--duration-normal);
  }

  .btn-primary {
    background: var(--color-primary);
    color: white;
  }

  .btn-secondary {
    background: var(--color-surface-card);
    color: var(--color-text-primary);
  }

  .btn-outline {
    background: transparent;
    border: 1px solid var(--color-border-light);
    color: var(--color-text-primary);
  }
</style>
```

---

## Accessibility Guidelines

### Color Contrast

- Text on primary backgrounds must have at least 4.5:1 contrast ratio
- Large text (18px+) can use 3:1 contrast ratio
- Interactive elements should have clear focus states

### Focus States

```css
button:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

### Typography

- Base font size should be at least 14px
- Line height should be 1.5 or greater for body text
- Interactive text should have min 16px font size

### Touch Targets

- Minimum 44x44px for mobile tap targets
- Adequate spacing between interactive elements

---

## Usage Tips

1. **Start with design tokens**: Define all colors, spacing, and typography as variables/constants
2. **Build component library**: Create reusable components based on these patterns
3. **Use semantic names**: Prefer `--color-primary` over `--color-blue`
4. **Document variants**: Each component should have clear variant options
5. **Test across devices**: Ensure responsive patterns work on all screen sizes
6. **Maintain consistency**: Stick to the defined scale for spacing, typography, etc.

---

## Version

Design System v1.0.0 - Initial Release
Last Updated: 2025-12-24
