---
name: ce-code-review
description: Review code, a local diff, or a PR for concrete defects, regressions, missing tests, and repository-standard violations. Report findings by default; apply them only when the user explicitly asks.
---

# Code review

Find actionable defects rather than narrating the diff.

## Workflow

1. Resolve the review scope and read repository instructions, intent, tests, and relevant surrounding code.
   When domain vocabulary or prior decisions affect the change, read [`durable-context.md`](../../references/durable-context.md) and the project context it identifies.
2. Review engineering quality: correctness, edge cases, compatibility, state transitions, error handling, security boundaries, performance risks, regression coverage, and repository standards.
3. Review spec fidelity separately: trace the implementation against the stated intent, acceptance criteria, constraints, and non-goals.
   If no reliable spec or intent exists, say that this axis is unavailable instead of inventing requirements.
4. Confirm each finding against actual code and avoid speculative or stylistic noise.
5. Group findings by axis, rank them by user impact within each axis, and include precise file and line references.
6. State coverage limits and verification performed for each axis.
7. Return no findings when nothing actionable survives review.

Keep the two axes distinct so passing one cannot mask failure in the other.
Do not collapse them into a combined score or verdict.

Use one full local review pass by default.

After the user accepts and applies findings, allow at most one targeted rereview of those fixes.

Do not restart a full review loop.

Dispatch subagents or outside models only when the user explicitly requests a panel, oracle, parallel review, or external review.

Review is report-only unless the user asks to apply the findings.

Never push, open PRs, file tickets, or switch branches as part of review.
