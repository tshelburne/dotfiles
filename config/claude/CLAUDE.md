# Global Claude Code Configuration

## Feature Documentation

Features follow a stepwise workflow in `.claude/features/YYMMDD-feature-name/`:

1. **Scope** (`/scope` command) - Interactive scoping session creates `scope.md` with problem statement, goals, approach, success criteria
2. **Spec** - Once scope is agreed, write `spec.md` with technical architecture, code patterns, usage examples
3. **Implement** - Build the feature and document in `completed.md` (what was built, files changed, key decisions)

**Important**: Do not auto-generate all three files at once. This is an interactive process requiring user approval between each step.

User-facing READMEs should stay concise and practical. Feature docs in `.claude/features/` preserve implementation details for AI context.

## Testing

### Node / Typescript

- Use native Node.js test runner (`node:test`) - no external frameworks
- Use tsx for TypeScript - run with `--import tsx`
- Collocate tests - `foo.test.ts` next to `foo.ts`
- Test script pattern - `"test": "node --import tsx --test 'src/**/*.test.ts'"`
- Import with `.js` extension - `import { foo } from './bar.js'` (ESM requirement)
- Write tests for critical logic - utilities, security-sensitive code, complex algorithms
- Skip tests for UI components, trivial code, one-off scripts (unless requested)

## Code Style

### Philosophy

Code should be clear, minimal, and composable.
Structure should read top-down like a story: main logic first, helpers last.

### Structure & Layout

- Main logic at the top — helpers hoisted from the bottom of the file.
  - In React: callbacks come *after* the `return`.
  - In normal modules: support functions, local type definitions after the primary exports
- Maximize locality — define at the narrowest scope where used. Don't hoist schemas, constants, or helpers to module level unless shared across multiple functions.
- Imports sorted alphabetically, with:
  1. External / library imports first
  2. Relative imports second
- Single-purpose modules — split files if they grow beyond their core.
- State comes last. Derive before mutating.

### Conditionals & Flow

- Prefer inline conditionals (`&&`, ternaries) for short logic.
- Use early `return` or `break` to flatten nesting.
- Favor guard clauses over deep blocks.
- When mapping across discriminated unions, prefer `switch` statements with exhaustive `default` checks.
- For optional functions, call directly with optional chaining:
  `opts?.onComplete?.(value)`
  not `opts.onComplete ? opts.onComplete(value) : null`
- When assigning defaults, use nullish coalescing (`??`) rather than ternary checks.

### Functions & Naming

- Use function declarations for reusable logic.
- Use arrow functions for inline callbacks (`map`, `filter`, `reduce`, etc.).
- Prefer composable functions (FP style) over big "behavior chunks."
- Keep functions short (~15–20 lines is best), but extract "helper" functions only for clarity or when they are reusable. Two short but intimately related functions doing one job is worse that one long function.
- **React components must be defined with `function Component()` syntax, never `const Component = ()`**
- Naming:
  - React callbacks: **ALWAYS `onSomething`, NEVER `handleSomething`**
  - Functions: verbs (`buildRequest`)
  - Booleans: `isX`, `hasX`, `shouldX`
  - Components: `PascalCase`
  - Constants: `SCREAMING_SNAKE_CASE`
- In React components, define a `ComponentProps` interface outside the function and use it in the argument instead of inline prop types.

### TypeScript

- Never use `any`.
- `unknown` is allowed — forces explicit typing before use.
- Narrow early, avoid loose unions.
- Prefer discriminated unions with exhaustive `switch` cases for clarity and safety.

### Async Flow

- Use `async` / `await` with `try` / `catch`.
- Leverage composable promise helpers for complex chains.
- Keep error handling explicit and centralized.

### Imports

- Centralized imports for libraries of common functions.
- Explicit imports for components and feature-specific code.
- No star imports unless using a clear namespace pattern.

### Hygiene & Maintenance

- Always remove dead code.
- Extract reusable code in the same module first, move out only when shared.
- Keep return types consistent.
- Comments explain why, not what.

### Style Biases

- Readability over cleverness.
- Never mutate in `Array.prototype.reduce`; always return a new value.
- Prefer composition over abstraction.
- Avoid optional behavior in shared helpers — split instead.
- Keep functions focused and small.

### Examples

#### React Component with `ComponentProps` interface

```tsx
import React, { useState } from 'react';
import { formatName } from '@/lib/formatters';

interface UserCardProps {
  user: User;
}

export function UserCard({ user }: UserCardProps) {
  const [expanded, setExpanded] = useState(false);

  if (!user) return null;

  return (
    <div className="user-card">
      <h2>{formatName(user)}</h2>
      <button onClick={onToggleExpanded}>
        {expanded ? 'Hide' : 'Show'} details
      </button>
      {expanded && <div>{user.email}</div>}
    </div>
  );

  function onToggleExpanded() {
    setExpanded(prev => !prev);
  }
}
```

#### Discriminated Union with `switch`

```ts
type Status =
  | { kind: 'pending' }
  | { kind: 'success'; message: string }
  | { kind: 'error'; code: number };

export function getStatusSummary(status: Status): string {
  switch (status.kind) {
    case 'pending':
      return 'Waiting...';
    case 'success':
      return `✅ ${status.message}`;
    case 'error':
      return `❌ Error code: ${status.code}`;
    default:
      const exhaustiveCheck: never = status;
      return exhaustiveCheck;
  }
}
```

#### Composable Reduce (no mutation)

```ts
const nums = [1, 2, 3, 4];

const doubled = nums.reduce<number[]>((acc, n) => {
  return [...acc, n * 2];
}, []);
```

#### Optional Function Call + Default Assignment

```ts
function runTask(value: string | null, opts?: { onComplete?: (val: string) => void }) {
  const output = value ?? 'default';
  opts?.onComplete?.(output);
}
```

#### Composable Helper Extraction

```ts
export function buildUserGreeting(user: User): string {
  const greeting = buildGreeting(user);
  const name = formatName(user);
  return `${greeting}, ${name}!`;
}

function buildGreeting(user: User) {
  return user.isAdmin ? 'Welcome back, boss' : 'Hello';
}
```

#### Maximize Locality

```ts
// Bad: hoisted when used once
const UserSchema = z.object({ name: z.string() })

export function validateUser(data: unknown) {
  return UserSchema.parse(data)
}

// Good: defined at narrowest scope
export function validateUser(data: unknown) {
  const UserSchema = z.object({ name: z.string() })
  return UserSchema.parse(data)
}

// Exception: hoist when shared
const UserSchema = z.object({ name: z.string() })

export function validateUser(data: unknown) {
  return UserSchema.parse(data)
}

export function createUser(data: unknown) {
  return UserSchema.parse(data)
}
```

### Do / Don't

| Do | Don't |
|----|-------|
| `function Component() {}` | `const Component = () => {}` |
| `function onSomething()` | `function handleSomething()` |
| `opts?.onComplete?.(val)` | `opts.onComplete ? opts.onComplete(val) : null` |
| `const x = y ?? fallback` | `const x = y ? y : fallback` |
| `interface ComponentProps {}` | inline `{ prop: Type }` |
| Early return guards | Nested conditionals |
| Inline ternaries for simple cases | Verbose `if`/`else` chains |
| Composable helpers | Giant procedural blocks |
| Extract helpers locally first | Premature abstraction |
| Define at narrowest scope | Hoist to module level unnecessarily |

## Project Context
This is a personal configuration that should be applied across all projects unless overridden by project-specific CLAUDE.md files.
