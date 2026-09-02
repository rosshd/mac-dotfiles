---
name: ce-brainstorm
description: Turn a vague or ambitious idea into right-sized requirements and a recommended direction. Use before planning when product behavior, scope, or success criteria remain unsettled; do not use for clear implementation or debugging.
---

# Brainstorm

Clarify what to build without implementing it.

## Workflow

1. Inspect the available product, repository, and prior-decision context before asking questions.
   For repository-backed work with meaningful domain vocabulary or prior decisions, read [`durable-context.md`](../../references/durable-context.md) and follow its brainstorm role.
2. State the problem, intended user, desired outcome, constraints, and explicit non-goals.
3. Ask only for decisions that cannot be resolved from evidence, one focused question at a time.
4. Develop distinct approaches when a real tradeoff exists, then recommend one with concrete reasons.
5. Pressure-test scope, failure modes, and missing acceptance criteria.
6. Update durable project context only for vocabulary and decisions that cross the reference's write threshold.
7. Produce a concise requirements summary with settled decisions, open questions, and readiness for planning.

When the user explicitly asks to create a GitHub issue, read [`factory-contract.md`](../../references/factory-contract.md), use its issue contract, and keep the issue as the only durable task brief.

Create one canonical requirements artifact only when the work is substantial or the user asks to save it.

`CONTEXT.md` and ADRs are project memory, not duplicate requirements artifacts.

Follow the repository's planning location, otherwise use `plans/`.

Do not create HTML, prototypes, issues, code changes, or external artifacts unless the user explicitly requests them.

Work solo unless the user explicitly requests subagents, parallel research, or outside models.
