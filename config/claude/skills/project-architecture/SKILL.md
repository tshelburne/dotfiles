---
name: project-architecture
description: The playbook for standing up a new TypeScript project or reviewing an existing one — the layered philosophy (a pure domain at the center, thin apps at the edges), the standard monorepo + package taxonomy, and an init checklist plus a review rubric. Start here when scaffolding a repo, auditing structure/architecture/testability, or deciding where a piece of code belongs; then follow the focused skills it links (monorepo-structure, domain-modeling, domain-boundary, design-system, state-machines, testability, code-style).
---

# Project Architecture

The overview that ties the focused skills together. Read this first when
**initializing** a new project or **reviewing** an existing one; drop into a
spoke skill for the depth on any one dimension.

The standard described here is deliberately strict. It is the shape a mature
project should converge on — not every repo starts there, but every decision
should move toward it, never away.

## The one idea

**A pure domain sits at the center. Everything else is a boundary around it.**

The domain knows the business rules and nothing about how data is stored or
transmitted. Apps are thin: they authenticate, they map persistence/transport
shapes to and from domain entities, and they render. All the interesting logic
lives in a package that could be lifted into any runtime unchanged.

```
        zod schema  ── the single source of truth for shape
             │        (validate here; infer every type from here)
             ▼
        entity class ── rich interface: derived getters, value objects, behavior
             │
   ┌─────────┴─────────┐
server boundary     client boundary
 (DB → schema →      (wire → plain data
  transport)          → entity)
```

Mapping happens **only** at the two app boundaries. The space in between is
domain-shaped. This is the through-line of every spoke skill.

## Standard shape

A pnpm monorepo: thin `apps/*` over a reusable `packages/*` core, with a
version **catalog** in `pnpm-workspace.yaml` as the single source of version
truth. Packages are consumed as **raw TypeScript** (no build step) except UI/
asset packages. Details in the **monorepo-structure** skill.

Package taxonomy (add only what a project needs):

| Package | Responsibility |
|---|---|
| `domain` | Pure business logic: zod schemas + entity classes. Depends only on `zod`. Zero persistence/transport imports. |
| `cfg` | Env-var resolution, platform-prefix aware, split server/client entry points. |
| `design-system` | Tokens + primitives + components. **Lives in-app until 2+ apps share it** (see design-system skill). |
| `log` | One logging standard (namespaces + levels) so every package/app logs the same way. |
| `testing` | Shared test helpers (clocks, jsdom setup, scenarios). `private: true`. |
| `email` | Templates. One of the few packages that actually builds. |
| transport client | The client + the mapping boundary (e.g. `graphql` for PostGraphile, or `api-client` for an HTTP/Firestore stack). |

Apps are **simply named** for what they are: `api`, `web`, `ios`/`mobile`,
`pwa`. No cleverness, no product codenames.

## Transport preference

**Prefer PostGraphile + `zod-to-gql`**: the domain zod schemas surface
directly as the GraphQL schema (objects, enums, and discriminated unions), so
there is one source of truth and the wire stays domain-shaped. Reach for a
Firestore-repository + HTTP stack only when a constraint demands it — e.g.
**HIPAA / compliance** requirements met by a managed store. That is a
deliberate, justified fallback, not the default. The **domain-boundary** skill
covers both realized stacks.

## Initializing a new project

1. `pnpm-workspace.yaml` with `apps/*` + `packages/*` and a **catalog**; root
   `package.json` is scripts-only, orchestrating with `pnpm -r`.
2. Create `packages/domain` first — zod schemas + entity classes, depends only
   on `zod`. Model the core before building any app. → **domain-modeling**
3. Create `packages/cfg` for env parsing. Add `log` when more than one place
   needs to log.
4. Stand up the transport (PostGraphile preferred) and put **all** mapping at
   the app boundary. → **domain-boundary**
5. Build the first app. Keep the design system **in-app** at
   `apps/<app>/src/lib/design-system` with Storybook. → **design-system**
6. Wire the test runner (`node:test` via `tsx`), colocate tests, add a
   typecheck + lint + test pre-push gate. → **testability**
7. Enforce **code-style** with ESLint (`onX` callbacks, named effect
   callbacks, function-declaration components). → **code-style**
8. Reach for a state machine only when a flow is committed/irreversible or
   needs recovery/resume. → **state-machines**

## Reviewing an existing project

Walk the layers outside-in and look for leaks. The fast rubric:

- **Structure** — Are apps thin and simply named? Does `domain` depend on
  anything but `zod`? Does any package import from an app? Is there an
  accidental build step? → **monorepo-structure**
- **Domain** — Are types hand-declared instead of `z.infer`red? Is computed
  state stored instead of derived in a getter? Do mapping factories
  (`fromRow`, `toColumns`) live inside the domain? → **domain-modeling** +
  **domain-boundary**
- **Design system** — Raw hex/px/`fontSize` in screens? Status meaning carried
  by a raw color name? A design system prematurely extracted to a package with
  only one consumer? → **design-system**
- **State** — A tangle of booleans/effects modeling a lifecycle that wants to
  be a machine? A machine that rebuilds domain state instead of owning the
  entity? → **state-machines**
- **Testability** — `as unknown as` casts in tests? Exports that exist only for
  a test? Host-local `new Date()` in assertions? Jest/Vitest where `node:test`
  would do? → **testability**
- **Style** — `handleX` names, anonymous complex effects, `const Component =`.
  → **code-style**

Report findings against the strict standard, and name the tradeoff wherever a
project has deliberately relaxed it (compliance-driven transport, an in-app
design system that hasn't earned a package yet — these are fine and stated as
such).

## The spokes

- **monorepo-structure** — apps/packages split, naming, catalogs, no-build, workspace wiring, dependency direction.
- **domain-modeling** — schema→entity, value objects, unions, purity, fail-loud.
- **domain-boundary** — where persistence/transport mapping lives; the seam.
- **design-system** — tokens as roles, primitives that lock rhythm, in-app-until-2-apps.
- **state-machines** — xstate, entity-as-state, injected actors/clock, when to use one.
- **testability** — node:test, factories over casts, injected clocks, tiers, pre-push gate.
- **code-style** — naming, functions, hooks, conditionals, structure.
