---
name: ce-plan
description: Create a grounded Markdown plan for genuinely multi-step work. Use when asked to plan, break down implementation, or deepen requirements; use ce-brainstorm when product intent is still unsettled and do not implement the plan.
---

# Plan

Create the smallest durable plan that another agent can execute confidently.

Scale detail to the evidence and risk.
Keep hypothetical or repository-free plans brief: state assumptions and the next inspection steps instead of inventing implementation detail.
Expand only when repository evidence, material risk, or the user asks for depth.

## Workflow

1. Read repository instructions, relevant code, tests, existing plans, and established patterns.
   When domain vocabulary or prior decisions affect the plan, read [`durable-context.md`](../../references/durable-context.md) and the project context it identifies.
2. Resolve product intent from the conversation and prior artifacts without re-asking settled decisions.
3. Investigate external facts only when they are current, uncertain, or load-bearing.
4. Define scope, non-goals, constraints, acceptance criteria, affected files, implementation order, verification, and risks.
5. Decide whether the implementation fits one focused agent task.
   If it does not, split it into stable, dependency-aware work items that each fit one fresh task.
6. Separate product decisions from implementation choices and mark genuine unknowns.
7. Review the plan for unsupported assumptions, missing integration steps, and unnecessary expansion.

For multi-task plans, make each work item a vertical slice that proves observable behavior end to end.
Give each item a stable identifier, outcome, scope, acceptance criteria, dependencies, context pointers, and verification.
Use dependencies only where work is genuinely blocked, and mark which items are ready first.
Prefer a coherent slice over separate database, backend, and UI layers.

State that each work item should run in a fresh task and that implementation should stop after the selected item.

Use one canonical Markdown file in the repository's configured planning location, otherwise `plans/`.

Keep repository file references relative inside the plan and use absolute clickable paths only in chat.

Do not create HTML, visual artifacts, tracker issues, prototypes, code, commits, or PRs unless explicitly requested.

Do not force a handoff menu when the user asked only for the plan or the next action is already clear.

Use subagents or outside models only when the user explicitly requests them.
