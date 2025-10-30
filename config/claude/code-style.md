## Philosophy

Code should be clear, minimal, and composable.  
Structure should read top-down like a story: main logic first, helpers last.

---

## Structure & Layout

- Main logic at the top — helpers hoisted to the bottom of the file.  
  - In React: callbacks come *after* the `return`.
- Imports sorted alphabetically, with:
  1. External / library imports first  
  2. Relative imports second
- Single-purpose modules — split files if they grow beyond their core.
- State comes last. Derive before mutating.

---

## Conditionals & Flow

- Prefer inline conditionals (`&&`, ternaries) for short logic.
- Use early `return` or `break` to flatten nesting.
- Favor guard clauses over deep blocks.
- When mapping across discriminated unions, prefer `switch` statements with exhaustive `default` checks.
- For optional functions, call directly with optional chaining:  
  `opts?.onComplete?.(value)`  
  not `opts.onComplete ? opts.onComplete(value) : null`
- When assigning defaults, use nullish coalescing (`??`) rather than ternary checks.

---

## Functions & Naming

- Use function declarations for reusable logic.
- Use arrow functions for inline callbacks (`map`, `filter`, `reduce`, etc.).
- Prefer composable functions (FP style) over big “behavior chunks.”
- Keep functions short (~15–20 lines max).
- Naming:
  - React callbacks: `onSomething`
  - Functions: verbs (`buildRequest`)
  - Booleans: `isX`, `hasX`, `shouldX`
  - Components: `PascalCase`
  - Constants: `SCREAMING_SNAKE_CASE`
- In React components, define a `ComponentProps` interface outside the function and use it in the argument instead of inline prop types.

---

## TypeScript

- Never use `any`.
- `unknown` is allowed — forces explicit typing before use.
- Narrow early, avoid loose unions.
- Prefer discriminated unions with exhaustive `switch` cases for clarity and safety.

---

## Async Flow

- Use `async` / `await` with `try` / `catch`.
- Leverage composable promise helpers for complex chains.
- Keep error handling explicit and centralized.

---

## Imports

- Centralized imports for libraries of common functions.
- Explicit imports for components and feature-specific code.
- No star imports unless using a clear namespace pattern.

---

## Hygiene & Maintenance

- Always remove dead code.
- Extract reusable code in the same module first, move out only when shared.
- Keep return types consistent.
- Comments explain why, not what.

---

## Style Biases

- Readability over cleverness.
- Never mutate in `Array.prototype.reduce`; always return a new value.
- Prefer composition over abstraction.
- Avoid optional behavior in shared helpers — split instead.
- Keep functions focused and small.

---

## Examples

### React Component with `ComponentProps` interface

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

---

### Discriminated Union with `switch`

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

---

### Composable Reduce (no mutation)

```ts
const nums = [1, 2, 3, 4];

const doubled = nums.reduce<number[]>((acc, n) => {
  return [...acc, n * 2];
}, []);
```

---

### Optional Function Call + Default Assignment

```ts
function runTask(value: string | null, opts?: { onComplete?: (val: string) => void }) {
  const output = value ?? 'default';
  opts?.onComplete?.(output);
}
```

---

### Composable Helper Extraction

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

---

## Do / Don’t

| Do | Don’t |
|----|-------|
| `opts?.onComplete?.(val)` | `opts.onComplete ? opts.onComplete(val) : null` |
| `const x = y ?? fallback` | `const x = y ? y : fallback` |
| `interface ComponentProps {}` | inline `{ prop: Type }` |
| Early return guards | Nested conditionals |
| Inline ternaries for simple cases | Verbose `if`/`else` chains |
| Composable helpers | Giant procedural blocks |
| Extract helpers locally first | Premature abstraction |
