---
name: baseline-ui
description: Enforces an opinionated UI baseline to prevent AI-generated interface slop.
---

# Baseline UI

Enforces an opinionated UI baseline to prevent AI-generated interface slop.

## How to use

- `/baseline-ui`
  Apply these constraints to any UI work in this conversation.

- `/baseline-ui <file>`
  Review the file against all constraints below and output:
  - violations (quote the exact line/snippet)
  - why it matters (1 short sentence)
  - a concrete fix (code-level suggestion)

## Stack

### SvelteKit

- MUST use Tailwind CSS defaults unless custom values already exist or are explicitly requested
- MUST use Svelte's built-in transition and animation system (`svelte/transition`, `svelte/animate`, `svelte/motion`) for standard enter/exit and reorder animations
- SHOULD reach for `svelte-motion` only when layout animations, shared layout transitions, or gesture-driven motion are required
- SHOULD use `tw-animate-css` for entrance and micro-animations in Tailwind CSS
- MUST use `cn` utility (`clsx` + `tailwind-merge`) for class logic

### React

- MUST use Tailwind CSS defaults unless custom values already exist or are explicitly requested
- MUST use `motion/react` (formerly `framer-motion`) when JavaScript animation is required
- SHOULD use `tw-animate-css` for entrance and micro-animations in Tailwind CSS
- MUST use `cn` utility (`clsx` + `tailwind-merge`) for class logic

## Components

### SvelteKit

- MUST use accessible component primitives for anything with keyboard or focus behavior (`Bits UI`, `Melt UI`)
- MUST use the project's existing component primitives first
- NEVER mix primitive systems within the same interaction surface
- SHOULD prefer [`Bits UI`](https://bits-ui.com/) for new primitives — it wraps Melt UI with an ergonomic compound component API (`<Component.Root>`, `<Component.Trigger>`, etc.)
- SHOULD use [`shadcn-svelte`](https://www.shadcn-svelte.com/) when pre-styled Tailwind components are acceptable
- MUST add an `aria-label` to icon-only buttons
- NEVER rebuild keyboard or focus behavior by hand unless explicitly requested
- MUST use Svelte 5 runes (`$state`, `$derived`, `$props`) — do not use legacy `export let` or `$:` syntax in new code

### React

- MUST use accessible component primitives for anything with keyboard or focus behavior (`Base UI`, `React Aria`, `Radix`)
- MUST use the project's existing component primitives first
- NEVER mix primitive systems within the same interaction surface
- SHOULD prefer [`Base UI`](https://base-ui.com/react/components) for new primitives if compatible with the stack
- MUST add an `aria-label` to icon-only buttons
- NEVER rebuild keyboard or focus behavior by hand unless explicitly requested

## Interaction

- MUST use an `AlertDialog` for destructive or irreversible actions (Bits UI `AlertDialog` for SvelteKit, Radix `AlertDialog` for React)
- SHOULD use structural skeletons for loading states
- NEVER use `h-screen`, use `h-dvh`
- MUST respect `safe-area-inset` for fixed elements
- MUST show errors next to where the action happens
- NEVER block paste in `input` or `textarea` elements
- (SvelteKit) SHOULD use `use:enhance` on forms for progressive enhancement
- (SvelteKit) MUST use SvelteKit form actions for form submissions where applicable

## Animation

### SvelteKit

- NEVER add animation unless it is explicitly requested
- MUST prefer Svelte's built-in `transition:` directives (`fade`, `fly`, `slide`, `scale`, `blur`, `draw`) for enter/exit motion
- MUST use `animate:flip` for reorder animations in keyed `{#each}` blocks
- MUST use `spring()` or `tweened()` from `svelte/motion` for interpolated reactive values
- MUST animate only compositor props (`transform`, `opacity`)
- NEVER animate layout properties (`width`, `height`, `top`, `left`, `margin`, `padding`)
- SHOULD avoid animating paint properties (`background`, `color`) except for small, local UI (text, icons)
- SHOULD use `ease-out` on entrance (or Svelte's `quintOut` / `cubicOut` easing)
- NEVER exceed `200ms` for interaction feedback
- MUST pause looping animations when off-screen
- SHOULD respect `prefers-reduced-motion`
- NEVER introduce custom easing curves unless explicitly requested
- SHOULD avoid animating large images or full-screen surfaces

### React

- NEVER add animation unless it is explicitly requested
- MUST animate only compositor props (`transform`, `opacity`)
- NEVER animate layout properties (`width`, `height`, `top`, `left`, `margin`, `padding`)
- SHOULD avoid animating paint properties (`background`, `color`) except for small, local UI (text, icons)
- SHOULD use `ease-out` on entrance
- NEVER exceed `200ms` for interaction feedback
- MUST pause looping animations when off-screen
- SHOULD respect `prefers-reduced-motion`
- NEVER introduce custom easing curves unless explicitly requested
- SHOULD avoid animating large images or full-screen surfaces

## Typography

- MUST use `text-balance` for headings and `text-pretty` for body/paragraphs
- MUST use `tabular-nums` for data
- SHOULD use `truncate` or `line-clamp` for dense UI
- NEVER modify `letter-spacing` (`tracking-*`) unless explicitly requested

## Layout

- MUST use a fixed `z-index` scale (no arbitrary `z-*`)
- SHOULD use `size-*` for square elements instead of `w-*` + `h-*`

## Performance

### SvelteKit

- NEVER animate large `blur()` or `backdrop-filter` surfaces
- NEVER apply `will-change` outside an active animation
- NEVER use `$effect` for anything that can be expressed as `$derived` — effects are escape hatches for DOM manipulation, analytics, and third-party integrations, not for derived state
- NEVER update `$state` inside `$effect` when the value can be computed with `$derived` or `$derived.by()`
- SHOULD preload fonts explicitly — SvelteKit auto-preloads `.js` and `.css` but not fonts

### React

- NEVER animate large `blur()` or `backdrop-filter` surfaces
- NEVER apply `will-change` outside an active animation
- NEVER use `useEffect` for anything that can be expressed as render logic

## Design

- NEVER use gradients unless explicitly requested
- NEVER use purple or multicolor gradients
- NEVER use glow effects as primary affordances
- SHOULD use Tailwind CSS default shadow scale unless explicitly requested
- MUST give empty states one clear next action
- SHOULD limit accent color usage to one per view
- SHOULD use existing theme or Tailwind CSS color tokens before introducing new ones
