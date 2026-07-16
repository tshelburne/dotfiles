---
name: design-system
description: How to build and evolve a design system — a FOUNDATIONS doc of perceptual rules, closed role-named token sets (color as valence/identity, a grid-based spacing scale, closed typography presets), primitives that lock spacing so callers can't fork the rhythm, and consumption rules that ban raw hex/px/fontSize in screens. Crucially, keep the design system IN-APP at apps/<app>/src/lib/design-system with Storybook until 2+ apps share it, then promote to a package with platform-split exports. Apply when creating tokens/primitives, reviewing UI for token discipline, or deciding whether a design system has earned its own package. Part of the project-architecture set.
---

# Design System

How to structure UI tokens and primitives, and — importantly — **where** the
design system should live as it matures. See **project-architecture** for the
big picture.

## Where it lives: in-app until it's shared

Start the design system **inside the app that needs it**:

```
apps/<app>/src/lib/design-system/
  FOUNDATIONS.md   the perceptual rules the tokens encode
  README.md        conventions + how to run Storybook
  tokens.ts  tokens.css
  components/      primitives, each with a colocated *.stories.tsx
  index.ts
```

Treat it as a **staging ground**: reusable, presentational components with
Storybook coverage, written to be liftable. **Promote to a shared
`@scope/design-system` package only once a second app needs it.** A package
extracted for a single consumer is premature — it adds a build step, a
publish/version boundary, and cross-package churn to buy nothing. Let the
second consumer pull the abstraction out.

When you do promote: split by platform via `exports` subpaths (`./web`,
`./ios`, `./mobile`, `./tokens`) — a **shared token module** with **parallel
component trees** per platform that expose the **same prop API** (`onPress`,
`variant`), not one renderer trying to serve both.

## FOUNDATIONS: rules before tokens

Write a `FOUNDATIONS.md` (or philosophy doc) that states the perceptual
constraints in prose, then implement those constraints as the token set. It
opens with a vibe statement and a "what this is NOT," then lays down the rules
for color, space, and type. The tokens are the enforcement; the doc is the
"why" an LLM or teammate honors when a case isn't explicitly covered.

## Tokens are roles, not looks

A **closed set** of role-named tokens. The name says what it's *for*, never what
it looks like.

- **Color = valence + identity, kept separate.** One **valence palette** carries
  every judgment — `positive / caution / negative / info / neutral`, each a
  `solid / surface / text` trio. If a color answers "how is this going?" it
  comes from here. **Identity palettes** (chart series, categories) merely
  *differentiate* and must never read as a judgment. A lone stat is not a
  series — it renders in default ink, not a decorative hue. Retire ambiguous
  hues from status duty.
- **Spacing = a grid scale.** An 8px grid with a 4px fine step (or a 4-based
  scale with whole-number ratios). Every value is a multiple; the fine step is
  for micro-detail (icon-to-text gaps) only, never gaps between elements.
  Quarantine unavoidable one-off literals inside the scale module so they never
  appear in a screen.
- **Typography = closed presets.** Every piece of text is exactly one preset.
  If a screen reaches for a raw `fontSize`, the preset it needs is missing and
  belongs in the type module. Convention: prose is sans, data is mono
  (tabular-nums).

The only sanctioned dynamic-color path is a helper like `withAlpha(hex, alpha)`
that validates its input is a real token hex.

## Primitives lock the rhythm

A primitive owns its internal spacing and padding; callers get **non-spacing**
overrides only. Every `Card` shares one internal rhythm — callers don't get to
fork it. Consumption rules for screens:

- No raw hex, no raw px, no raw `fontSize` — tokens/presets only.
- No raw color name (Mantine/RN) carrying a **status** meaning — use a
  `StatusBadge tone=…` / `toneSolid()` / `--ds-*` var.
- No bespoke `Modal`/`Switch`/pickers — use the primitive.
- If a pattern recurs, extract it into the design system (with a story) rather
  than re-hand-rolling it.

For React Native, author raw token values at a fixed design width and **scale at
consumption** (`scaledSheet` / `scaled()`), never pre-scale the tokens.

## Evergreen docs

Component doc comments are surfaced verbatim in Storybook autodocs, so they must
describe the component **as it stands** — no migration notes, no "used to be",
no dates, no "currently/recently". That context is true only the day it's
written. Put migration notes in the PR/commit.

> Bad: `Replaces the hand-rolled <Text> pattern from ~14 call sites.`
> Good: `Dimmed, uppercase, letter-spaced section label.`

## Review red flags

- A `@scope/design-system` package with a single consuming app (premature).
- Raw hex/px/`fontSize` in a screen.
- A raw color name carrying status meaning instead of a valence token.
- Identity color used as judgment (a lone value tinted decoratively).
- A primitive that accepts spacing/padding overrides and forks the rhythm.
- Pre-scaled RN tokens, or a `scaled()` result spread into `scaledSheet`
  (double-scale bug).
- Anachronistic migration prose in an artifact-able component's doc comment.

## Concrete instances (illustration)

`circadian-os` `apps/web/src/lib/design-system` is the in-app staging ground —
`FOUNDATIONS.md` (valence vs identity palettes, 8px+4px grid, on-air-red for
live sessions), tokens + components + colocated stories, explicitly "to be
lifted into `@circadian/design-system`." The shared `packages/design-system`
serves the iOS app with `./web` + `./ios` exports and the `scaledSheet` scaling
convention. `notched.fit` `packages/design-system` is a closed token set
("roles, not looks"; `Card` locks spacing). `stacked.bar` shares one `tokens.ts`
→ RN StyleSheet values on mobile, CSS custom props on web, via `./web`/`./mobile`
/`./tokens` exports.
