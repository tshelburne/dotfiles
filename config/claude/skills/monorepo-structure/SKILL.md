---
name: monorepo-structure
description: How to lay out a pnpm TypeScript monorepo — the apps/*-vs-packages/* split, simply-named apps, single-responsibility packages, a version catalog, raw-TS packages with no build step, workspace wiring (workspace:* + subpath # imports), and the dependency direction that keeps the domain pure. Apply when scaffolding a repo, adding a package or app, deciding where code belongs, or reviewing the physical structure and package boundaries. Part of the project-architecture set.
---

# Monorepo Structure

The physical shape of the repo. For the layered philosophy and the init/review
workflows, see the **project-architecture** skill.

## Layout

```
pnpm-workspace.yaml        # apps/*, packages/*, scripts; + a version catalog
package.json               # scripts-only root (private), orchestrates with pnpm -r
apps/
  api  web  ios|mobile  pwa    # thin, simply named for what they are
packages/
  domain  cfg  design-system  log  testing  email  <transport-client>
```

**Apps are thin and simply named** — `api`, `web`, `ios`, `mobile`, `pwa`. They
are the only things that compile to a bundle. Name them for the platform, never
a product codename.

**Packages carry the reusable core**, each with one responsibility. See the
taxonomy table in **project-architecture**. The rule of thumb: if two apps
would both want it, or it embodies a rule that must not drift, it's a package.

## Version catalog

Pin shared versions once in `pnpm-workspace.yaml` under `catalogs`, grouped by
concern (`types`, `react`, `vite`, `graphql`, `testing`, …). Packages reference
them symbolically:

```jsonc
// package.json
"dependencies": { "zod": "catalog:types", "react": "catalog:react" }
```

One place to bump a version; no drift across packages.

## No build step (the default)

Pure-logic packages are consumed as **raw TypeScript source**. `main` points
straight at `src/index.ts`; `tsc` is `--noEmit` (typecheck only); the app's
bundler (Vite / Metro / tsx / esbuild) compiles everything.

```jsonc
// packages/domain/package.json
"main": "src/index.ts",
"exports": { ".": "./src/index.ts" },
"imports": { "#*": "./src/*.ts" }
```

Only **UI/asset packages build** — a `design-system` that emits CSS, an `email`
package that ships templates. If a pure package grows a `dist/`, that's a smell:
ask why the bundler can't consume its source.

## Workspace wiring

- Cross-package: depend via `"@scope/domain": "workspace:*"` and import by the
  scoped name + an `exports` subpath: `import { Study } from '@scope/domain'`.
- Intra-package: use **subpath `#` imports** instead of `../../` chains. Declare
  `"imports": { "#*": "./src/*.ts" }` and import `#entities/Study`,
  `#schemas/session`. This is the standard — it keeps refactors from churning
  relative paths. (Some repos wire only `exports` subpaths and skip `#`; prefer
  `#` for new work.)
- **Multi-entry `exports`** when one package serves several consumers or
  runtimes: `firebase` exposes `./client` + `./admin`; `cfg` exposes `./server`
  + `./client`; `design-system` exposes `./web` + `./ios`. The subpath is the
  seam that keeps a server-only dep out of a client bundle.

## Dependency direction

The single invariant that keeps the architecture honest:

- `domain` depends on **nothing** but `zod` (and `xstate` if a machine lives
  there). No `cfg`, no transport, no app.
- Packages may depend on other packages **downward** (`design-system` →
  `domain` for formatting; `services` → `cfg` + `domain`).
- **No package ever imports from an app.** Apps are leaves. If a package needs
  something an app has, that something is in the wrong place — push it down into
  a package.

A quick `grep` for an app's scope name inside `packages/` should return nothing.

## Root orchestration

Root `package.json` is scripts-only and fans out with `pnpm -r`:

- `dev` — `pnpm -r --parallel dev`
- `typecheck` / `lint` / `test` — `pnpm -r --no-bail <x>` (report every failure,
  don't stop at the first)
- `dist` (build packages) → `build` (build apps) → `generate` (codegen) encode
  the dependency ordering; a `reset` that chains clean→install→dist→generate→
  build is the canonical full rebuild.

## Review red flags

- An app with a codename instead of `api`/`web`/`mobile`.
- `domain` importing `cfg`, a transport client, or anything app-shaped.
- A package importing from `apps/*`.
- A pure package with a `dist/` build for consumption.
- Literal versions scattered across packages instead of a catalog entry.
- `../../../` relative imports where a `#` subpath would read cleanly.

## Concrete instances (illustration)

All three of `circadian-os`, `stacked.bar`, and `notched.fit` (`@exercise`)
share this skeleton — `apps/*` + `packages/*`, a catalog, raw-TS packages,
`node:test`. `circadian-os` uses `#` imports across every package (the strict
end); `stacked.bar` wires only `exports` subpaths (looser). `email` is the one
package that builds in circadian; `design-system` + `email` build in stacked.
