---
name: domain-modeling
description: How to build a pure, universal domain layer — zod schemas as the single source of truth, types inferred (never hand-declared), entity classes that wrap plain data and expose a rich interface via derived getters, value objects, discriminated unions, named factories with one parse door, immutability, and fail-loud misuse. Apply when creating or reviewing domain schemas/entities/value objects, deciding what belongs on an entity vs a boundary, or keeping a domain package free of persistence/transport concerns. Pairs with the domain-boundary skill (where mapping lives). Part of the project-architecture set.
---

# Domain Modeling

How to build the entities inside a pure `domain` package. Its companion,
**domain-boundary**, covers where the persistence/transport mapping lives; this
skill covers how the entity itself is shaped. See **project-architecture** for
the big picture.

## The layering inside `domain`

```
src/schemas/*.ts   zod schemas — the single source of truth for shape
src/entities/*.ts  classes wrapping schema-validated plain data
src/values/*.ts    value objects (Money, Weight, Duration, …)
src/index.ts       flat barrel re-exporting the public surface
```

The package depends on **`zod` and nothing else** (plus `xstate` only if a
machine lives here). No `cfg`, no transport types, no DB row types, no
`fromRow`/`toColumns` factories. If the domain knows how it's stored or
transmitted, the boundary has leaked inward.

## Schema is the source of truth

Define the shape once in zod; **infer every type** — never hand-declare a
parallel `interface`. Extract enums as their own schemas so they're reusable
and inferrable:

```ts
export const GoalCategorySchema = z.enum(['strength', 'skill', 'mobility'])
export const GoalSchema = z.object({
  id: z.string().uuid().nullable(),
  category: GoalCategorySchema,
  createdAt: z.coerce.date().nullable(),   // coerce at the schema so entities hold real Dates
})
export type GoalData = z.infer<typeof GoalSchema>
```

Use `z.coerce.date()` (or equivalent) in the schema so parsing yields real
`Date`s and the entity never deals in date strings.

## Entities: plain data in, rich interface out

The constructor takes **domain-shaped plain data** (a `z.infer` type), not a
persistence or wire shape. It exposes behavior and derived state through
getters — never stored, always computed:

```ts
export class Goal {
  readonly data: GoalData
  constructor(data: GoalData, levels: Level[] = []) {
    this.data = data
    this.levels = levels
  }
  get isAchieved(): boolean { return this.progressFraction >= 1 }   // rule as getter
  get progressFraction(): number { /* derive from levels */ }
}
```

Recurring conventions:

- **Derived getters, not stored computed state.** `isLocked`, `status`,
  `parStatus`, `total` — all computed from the data each read. Storing them
  invites staleness.
- **Named factories, not raw `new` at call sites.** `Goal.fromData(...)`,
  `SessionEvent.fromJSON(...)`. A discriminated-union entity uses a **private
  constructor** plus static factories per arm, and a single `fromJSON` switch is
  the **only** parse door:

  ```ts
  static fromJSON(raw: unknown): SessionEvent {
    const data = SessionEventDataSchema.parse(raw)   // the one place we parse
    switch (data.event) {
      case 'snapshot':        return SessionEvent.snapshot(data.signals, data.stamp)
      case 'web_navigation':  return SessionEvent.webNavigation(data.url, data.stamp)
    }
  }
  ```

- **Raw columns private, value objects public.** Keep a `private readonly
  targetWeightKg: number` and expose `get targetWeight(): Weight | null`.
  Callers get rich, comparable values; the unit-suffixed backing field never
  leaks. Model absence honestly — bodyweight is `null`, not `0`.
- **The rule lives on the thing that prescribes it.** A `LevelExercise` owns
  `satisfiedBy(measurements)`; a `LoggedAttempt.cleared` delegates to it. Don't
  scatter the same predicate across call sites.
- **Immutability with copy-on-write.** Mutations return new instances via a
  private `copy(patch)`: `session.completed(at)`, `session.withSet(...)`.
- **Fail loud on misuse.** If an entity can be partial (a `summary` vs `full`
  mode), accessors that need the full data **throw** rather than return
  `undefined` — silent nulls hide bugs; a throw surfaces them at the call site.

## Value objects

A value + type merged under one name, immutable, with comparison and unit
accessors:

```ts
export type Weight = WeightValue
export function Weight(input: { kg: number }): Weight { return new WeightValue(input.kg) }
class WeightValue {
  constructor(readonly kg: number) {}
  gte(o: Weight) { return this.kg >= o.kg }
  get lbs() { return this.kg * 2.2046 }
}
```

Callers write `Weight({ kg })` and annotate `: Weight`. Rich types (money,
durations, ranges, measurements) are **derived on the entity, never stored in
the schema and never known by the wire** — that asymmetry is the heart of the
**domain-boundary** skill.

## One shape across layers (when the transport allows)

With PostGraphile + `zod-to-gql`, an entity can `implements` its computed-view
schema so the server-computed getters travel over the wire as a real type and
the client consumes them directly — the same shape flows domain → GraphQL →
client. Model discriminated unions as **real output unions** on reads (mapped
once at the boundary), not a bag of nullable fields. Details in
**domain-boundary**.

## Review red flags

- A hand-written `interface` mirroring a schema instead of `z.infer`.
- Computed state stored on the entity (and kept in sync by hand).
- `fromRow` / `toColumns` / `*GqlShape` / DB row types inside `domain`.
- `domain` importing `cfg`, a transport client, or `firebase`.
- Public raw unit fields (`weightKg`) instead of a value-object getter.
- Accessors that return `undefined` on misuse instead of throwing.
- Multiple parse points for one type instead of a single `fromJSON` door.

## Concrete instances (illustration)

`circadian-os` `packages/domain/src/entities/Study.ts` (constructor takes domain
types, `isLocked` getter) and `.../Session/SessionEvent.ts` (private ctor,
`fromJSON` as the single parse door, `#data` private backing). `notched.fit`
`packages/domain/src/values/Weight.ts` (value/type merge) and `entities/Goal.ts`
(`requireFull` fail-loud, copy-on-write `Session`). `stacked.bar`
`entities/Inventory.ts` (`implements InventorySummary` so one shape spans
layers).
