---
name: code-style
description: Code style guidelines for writing, reviewing, and fixing code. Applies to structure, naming conventions, conditionals, functions, hooks, and general patterns.
---

# Code Style Guidelines

Apply these guidelines when writing, reviewing, or fixing code in this codebase.

## Philosophy

Code should be clear, minimal, and composable. Structure should read top-down like a story: main logic first, helpers last.

## Structure & Layout

- Main logic at the top — helpers hoisted from the bottom of the file, including but not limited to:
  - helper functions
  - graphql queries
  - helper components
- In components: callbacks come _after_ the `return`
- In modules: support functions, local type definitions after the primary exports
- Maximize locality — define at the narrowest scope where used
- Don't hoist schemas, constants, or helpers to module level unless shared across multiple functions
- State comes last. Derive before mutating.

## Functions & Naming

- Use function declarations for reusable logic
- Use arrow functions for inline callbacks (`map`, `filter`, `reduce`, etc.)
- Keep functions short (~15–20 lines), but don't split intimately related logic unnecessarily
- **Components must use `function Component()` syntax, never `const Component = ()`**
- Naming:
  - Callbacks: **ALWAYS `onSomething`, NEVER `handleSomething`**
  - Functions: verbs (`buildRequest`)
  - Booleans: `isX`, `hasX`, `shouldX`
  - Components: `PascalCase`
  - Constants: `SCREAMING_SNAKE_CASE`
- Define `ComponentProps` interface outside the function, not inline

## Hooks

### useCallback

Define the handler as a hoisted function after the `return`, then wrap with `useCallback` if memoization is needed:

```ts
const onClickMemo = useCallback(onClick, [deps])
return <button onClick={onClickMemo} />

function onClick() { /* logic */ }
```

### useEffect

Use named function expressions inline for clarity:

```ts
useEffect(
  function syncDataWithServer() {
    // effect logic
  },
  [deps],
)
```

## Conditionals & Flow

- Prefer inline conditionals (`&&`, ternaries) for short logic
- Use early `return` or `break` to flatten nesting
- Favor guard clauses over deep blocks
- For discriminated unions, use `switch` with exhaustive `default` checks
- Optional function calls: `opts?.onComplete?.(value)` not ternary
- Defaults: use `??` not ternary

## Types

- Never use `any`
- `unknown` is allowed — forces explicit typing before use
- Narrow early, avoid loose unions
- Prefer discriminated unions with exhaustive `switch` cases

## Quick Reference

| Do                                             | Don't                                           |
| ---------------------------------------------- | ----------------------------------------------- |
| `function Component() {}`                      | `const Component = () => {}`                    |
| `function onSomething()`                       | `function handleSomething()`                    |
| `opts?.onComplete?.(val)`                      | `opts.onComplete ? opts.onComplete(val) : null` |
| `const x = y ?? fallback`                      | `const x = y ? y : fallback`                    |
| `interface ComponentProps {}`                  | inline `{ prop: Type }`                         |
| `useEffect(function name() {...}, [])`         | anonymous arrow for complex effects             |
| `useCallback(onClick, [deps])` with hoisted fn | inline callback in useCallback                  |
| Early return guards                            | Nested conditionals                             |
| Define at narrowest scope                      | Hoist unnecessarily                             |

## Testing

- Use native Node.js test runner (`node:test`) - no external frameworks
- Use tsx for TypeScript - run with `--import tsx`
- Collocate tests - `foo.test.ts` next to `foo.ts`
- Import with `.js` extension in test files (ESM requirement)
- Write tests for critical logic - utilities, security-sensitive code, complex algorithms
- Skip tests for UI components, trivial code, one-off scripts (unless requested)

## When Reviewing Code

Look for these common issues:

1. `const Component = () =>` instead of `function Component()`
2. `handleX` naming instead of `onX`
3. Anonymous useEffect callbacks that should be named
4. Inline useCallback bodies instead of hoisted functions
5. Ternaries for optional calls or defaults instead of `?.` or `??`
6. Unnecessarily hoisted constants/schemas used only once
7. Deep nesting instead of early returns
