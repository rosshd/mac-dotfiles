---
name: typescript-best-practices
description: Apply TypeScript-specific modeling and safety guidance while making substantive changes to .ts or .tsx code. Follow established repository conventions and avoid activating for trivial reads.
---

# TypeScript best practices

Use the repository's TypeScript configuration, lint rules, framework patterns, and public contracts as the primary standard.

Improve the changed code without broad cleanup or dependency churn.

## Guidance

- Model meaningful variants with discriminated unions when that removes invalid states.
- Treat external data as `unknown` and validate it at the boundary.
- Prefer narrowing, `satisfies`, derived types, and exhaustive checks over unchecked casts.
- Permit `as const`, framework-required interop, generated bindings, and casts backed by validation or an invariant the code makes explicit.
- Strengthen collection types only when the looser type forces assertions, impossible branches, or unsafe access.
- Reuse schema and function-derived types before declaring parallel copies.
- Prefer object arguments when they materially improve clarity, but keep positional arguments for established APIs and hot paths.
- Use the project's logger and test strategy rather than imposing a universal ban on console output or mocks.
- Prefer real behavior tests when they are reliable and proportionate.

Read [references/patterns.md](references/patterns.md) only when a concrete modeling example is needed.

Preserve behavior unless the task explicitly changes it, and verify with the repository's normal typecheck and tests.
