---
name: domain-boundary
description: How to structure a pure domain layer and keep persistence/transport mapping at the app boundaries. Apply when designing or reviewing domain schemas, entities, value objects, or the seam between the domain and a database/GraphQL/REST/RPC API — deciding where mapping code lives, how to surface domain types over the wire, or how to model discriminated unions across an API.
---

# Domain ↔ Boundary Pattern

Apply when designing or reviewing the layering between a domain model and its persistence/transport — schemas, entities, value objects, and where mapping code lives. Stack-agnostic; the concrete tech at the end is illustration, not the rule.

## The principle

**The domain package stays pure.** It contains exactly two things:

1. **Plain schemas** — scalar payloads, the single source of truth for shape. Validate here; infer types from these.
2. **Entity classes** — take that plain data in the constructor, expose a *rich* interface via getters (value objects, derived fields, behavior). Rich types (money, durations, ranges, measurements…) are **derived on the entity — never stored in the schema, never known by the wire.**

**No mapping code lives in the domain.** No `fromWire` / `fromGql` / `toColumns` / `toRow` factories. No transport or persistence types (`*GqlShape`, DB row types, DTOs) imported or defined there. The domain must not know how it is stored or transmitted.

**Mapping lives at the two app boundaries, and only there:**

- **Server boundary** — persistence rows → plain domain schema; and plain schema → transport types (the wire shape is *surfaced from* the schema, not hand-rolled beside it).
- **Client boundary** — transport payloads → domain entities, built through the entity's public constructor from plain data.

## The seam, end to end

```
plain schema (source of truth)
   → rich entity (constructor takes plain data; getters expose rich + behavior)
server: DB row → plain schema → transport types (generated FROM the schema)
   → network carries domain-shaped types
client: transport payload → plain data → entity (public constructor)
```

Mapping only ever happens at `DB → schema` (server in) and `wire → entity` (client in). Everything in between is domain-shaped.

## Design rules that recur

- **Keep the transport rich — model unions where the language allows.** A discriminated union in the domain should surface as a real transport **output** union on reads, mapped once at the server boundary — not flattened into a bag of nullable fields. Note the asymmetry: many transports (e.g. GraphQL) have **no input unions**, so write/mutation inputs stay flat even when reads are unions.
- **Distinct field names for semantically different arms.** When union arms each carry their own version of "the same" concept (absolute vs relative load, gross vs net amount, etc.), give them **different field names** rather than one shared field. It models the difference honestly *and* sidesteps type-merge conflicts where a shared name collides across arms (required-in-one vs optional-in-another, `T!` vs `T`).
- **Generate the transport schema from the domain schema** rather than maintaining a parallel hand-written one — one source of truth, no drift.

## Working style

- **One PR, no half-work.** Land the whole change; don't leave a feature half-migrated across the boundary.
- **Clean history before pushing:** squash `WIP:` commits; present clean logical commits — the exemplar (one unit proving the pattern) first, then the rest applying it.
- Confirm structural forks in the boundary design before propagating them widely.

## Concrete instance (illustration)

One realized stack: zod plain schemas → `@byside/zod-to-gql` in a PostGraphile v4 `makeExtendSchemaPlugin` surfaces the schema as a GraphQL union; server `db-domain-mappers` map rows → schema (+ `__typename`), computed fields expose it on reads via `@requires` + `__resolveType`; a client `mappers.ts` builds entities from connection nodes (absorbing serialized-number strings and null-tolerant partial fetches). Reference repos that established it: `stacked.bar` (zodToGql plugin) and `circadian-os` (constructor-takes-plain-data entities, mapping in the api-client).
