---
name: testability
description: How to make code testable and how to test it — the native node:test + node:assert runner (no Jest/Vitest), colocated tests, tiers (unit / integration / acceptance / e2e), factory functions with Partial overrides, injected clocks, and the hard rule to NEVER typecast a mock (build a real instance or a typed factory instead — casts leave class members undefined and hang at runtime). Also: never export solely for a test (use module mocks or restructure), and a pre-push gate of typecheck + lint + test. Apply when writing or reviewing tests, setting up a test harness, or diagnosing why the domain is hard to test. Part of the project-architecture set.
---

# Testability

The test harness and the disciplines that keep code testable. A pure domain
(see **domain-modeling**) and injected effects (see **state-machines**) are what
make the tests below cheap — most transferable conventions here are downstream
of that.

## Runner

Node's **built-in** test runner — `node:test` + `node:assert/strict`. No Jest,
no Vitest. Run TypeScript through `tsx`:

```jsonc
"test": "node --import tsx --test 'src/**/*.test.ts'"
```

Root aggregates with `pnpm -r --no-bail run test`. Add
`--experimental-test-module-mocks` where a package uses `mock.module`.

## Colocation and tiers

- Tests sit **next to source**: `Study.ts` ↔ `Study.test.ts`. Put a new case in
  the existing test file for the unit under test — don't spawn a parallel file.
- Name by tier so scripts can split them:
  - `*.test.ts` — unit (domain logic, pure functions). No services.
  - `*.integration.test.ts` — integration, still no live services.
  - `*.acceptance.test.ts` — full-stack against a real DB (`pretest:acceptance`
    resets it).
  - `e2e/` at the **repo root** (not per-app) — Playwright.

## Factories over casts — the load-bearing rule

**Never typecast a mock**, especially `as unknown as`. A cast to satisfy a type
is a signal the fixture should build a **real instance** or use a **typed
factory**. Production code reading a class member off a cast mock silently sees
`undefined` and can hang at runtime.

- Prefer a real instance: `new Study(...)`, `SessionEvent.fromJSON({...})`.
  Because the domain takes plain data and validates, real objects are cheap.
- When a collaborator must be mocked, build a **typed factory** — `mock.fn<T>()`
  per method, accepting a `DeepPartial<T>` of overrides, returning the real
  interface with no cast:

  ```ts
  export function makeMockDeviceApi(overrides: DeepPartial<DeviceApi> = {}): DeviceApi {
    const base: DeviceApi = {
      study: mock.fn<DeviceApi['study']>(async () => ({ study: null })),
      sessions: { appendEvents: mock.fn<DeviceApi['sessions']['appendEvents']>(async (_t, _s, e) => ({ received: e.length })) },
    }
    return { ...base, ...overrides, sessions: { ...base.sessions, ...(overrides.sessions ?? {}) } }
  }
  ```

- Simple fixtures are **local factory functions with `Partial` overrides** —
  one per test file, not a shared fixtures library:

  ```ts
  function makeGoal(overrides: Partial<GoalData> = {}): Goal {
    return Goal.fromData({ id: crypto.randomUUID(), category: 'strength', ...overrides })
  }
  ```

## Inject time

Never assert against host-local `new Date(Y, M, D)`. Inject a clock and express
test dates as **wall-clock in the domain's timezone** via a shared helper
(`createTestClock(tz)` in the `testing` package). Machines and entities that
take an injected `now()` are testable without fake timers.

## Never export just for a test

If a test needs an internal, don't `export` it solely to reach it. Use
`mock.module(...)` (registered **before** importing the unit) or restructure the
code into a smaller, independently-testable module. Exporting for tests widens
the public surface and couples tests to internals.

## What to test

Cover critical logic — domain rules, security-sensitive code, complex
algorithms, state machines. Skip trivial UI, one-off scripts, and glue. The
payoff of the pure-domain architecture is that the code worth testing is exactly
the code that's cheapest to test: no mocks, no I/O, just real entities.

## The pre-push gate

`pnpm typecheck && pnpm lint && pnpm test` — **all green** before pushing (add
`test:e2e` where it exists). When a test fails, **fix the source, never weaken
the test** to make failing code pass. A lint/typecheck error is never "pre-
existing, leave it" — fix it. An e2e suite that fails the run on any console
error keeps the bar honest.

## Review red flags

- `as unknown as` (or any cast) to make a mock satisfy a type.
- An `export` whose only consumer is a test.
- Assertions against host-local `new Date(...)` instead of an injected clock.
- Jest/Vitest pulled in where `node:test` would do.
- A parallel `*.spec` file duplicating the colocated test.
- A weakened/rewritten test smuggling a source bug past the gate.
