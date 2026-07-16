---
name: state-machines
description: How and when to model a flow with an xstate v5 state machine — reach for one when a flow is committed/irreversible or needs recovery/resume; keep the machine module thin (setup().createMachine wiring named guards/actors/actions that live in sibling modules); let the machine own the domain entity in context and rebuild it through the domain (the entity IS the state); inject actors and a clock so the machine stays pure, resumable, and testable. Apply when designing or reviewing a lifecycle/session/provisioning flow, or when a tangle of booleans and effects is really a state chart. Part of the project-architecture set.
---

# State Machines

When a flow deserves a state chart, and how to build one that stays pure and
testable. See **project-architecture** for the big picture.

## When to reach for one

A state machine earns its weight when:

- The flow is **committed / irreversible** — once it starts it runs to an end,
  and mid-flight editing should be *impossible by construction*, not by
  discipline (a session runner, a checkout, a provisioning sequence).
- It has a **real lifecycle** with recovery/resume — it can be interrupted, cold
  re-hydrated from persistence, and must land in the right state.
- You find yourself modeling that lifecycle with a **tangle of booleans and
  effects** (`isStarting && !isDone && hasError`) — that's a chart asking to
  exist.

Don't reach for one for simple server-state + local UI state; graphcache +
React state is enough there.

## The entity is the state

The defining convention: **the machine's `context` owns the domain entity, and
every guard/delay/derivation is a pure read off that entity.** The statechart
*orchestrates*; the domain entity *computes*. There is exactly one place the
entity is constructed — a `rebuildFromEvents(context)` action — so a machine
cold-started from fetched data resumes exactly where a never-unmounted one
would.

```ts
guards: {
  isCompleted: ({ context }) => context.session !== null && context.session.reachedTargetExact,
  isResting:   ({ context }) => context.session.restingUntil(context.now()) != null,
},
```

Nothing accumulates in context that the entity can't rebuild from its ledger.
That's what makes resume-from-persistence free.

## Keep the machine module thin

Use xstate v5 `setup({...}).createMachine({...})`. The machine file wires
**named** guards/actors/actions; their implementations live in **sibling
modules**, funneled through a barrel:

```
src/state/<machine>/
  machine.ts     setup().createMachine — wiring only
  actors.ts      invoked effects (fromPromise)
  recovery.ts    rebuild/resume logic
  helpers.ts  types.ts
  index.ts       barrel
```

```ts
export const lightSessionMachine = setup({
  types: { context: {} as Ctx, events: {} as Ev, input: {} as In,
           output: {} as { outcome: 'completed' | 'canceled' } },
  guards:  { isCompleted, isPastEnd },
  actors:  { initSession, appendEvents, finalizeSession, tickerActor },
  actions: { rebuildSession: assign(({ context }) => rebuildFromEvents(context)) },
}).createMachine({ id: 'lightSession', initial: 'initializing', /* states */ })
```

## Inject effects and time

- **Actors are injected**, declared via `fromPromise` with a **throwing
  default** (`'provide the persistSet actor'`). The machine itself performs no
  I/O; the app injects real persistence. This keeps the chart pure and makes
  tests trivial.
- **Inject the clock** (`now: () => Date`) rather than calling `new Date()`
  inside guards/delays. Time becomes a test input.
- **Terminal states set `outcome`** as a fail-safe, so every end is legible to
  the parent.

## Where it lives

- **In `domain`** if the machine is pure with injected actors + clock (the
  entity and its machine ship together). The domain then depends on `xstate`.
- **In the app** if the machine orchestrates app-level effects (navigation,
  device APIs). Either way, its `context` owns the **domain entity**, and it
  rebuilds state through the domain — never re-derives business rules itself.

## Testing

`node:test`, register `mock.module(...)` **before** importing the machine, then
dynamic-`import` the machine and `xstate`. Drive real actors with `createActor`
+ `waitFor`; feed **real domain instances** (`SessionEvent.fromJSON`, `new
Patient(...)`) and a `SimulatedClock` / `createTestClock`. No DB, no network, no
real timers — because the effects and the clock are injected. See the
**testability** skill.

## Review red flags

- A lifecycle modeled as interlocking booleans + effects instead of a chart.
- A machine that re-derives business rules instead of reading them off the
  entity in `context`.
- The domain entity constructed in more than one place instead of a single
  `rebuild` action.
- Actors calling I/O directly in the machine instead of injected `fromPromise`
  actors with a throwing default.
- `new Date()` inside a guard/delay instead of an injected clock.
- Non-terminal-safe ends (no `outcome` on final states).
