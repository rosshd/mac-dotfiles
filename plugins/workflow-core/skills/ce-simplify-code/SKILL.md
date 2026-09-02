---
name: ce-simplify-code
description: Simplify settled, recently changed code when the user requests a cleanup or simplification pass. Preserve behavior and scope; use ce-debug for failures and do not activate for documentation-only or generated changes.
---

# Simplify code

Improve clarity, reuse, and efficiency without changing observable behavior.

## Workflow

1. Resolve the user-named scope, otherwise use the current task's changed code.
2. Read surrounding patterns and identify duplication, needless indirection, unclear naming, awkward control flow, and avoidable work.
3. Run one integrated review pass by default.
4. Use separate reviewers only when the user explicitly requests a thorough, parallel, or multi-agent pass.
5. Apply only changes whose behavior preservation can be established.
6. Preserve safety checks, validation, accessibility, ordering, errors, and public contracts.
7. Run proportionate tests, type checking, and lint through the repository validation workflow.

Do not broaden into unrelated cleanup.

Skip suggestions whose benefit is marginal or whose safety depends on an unverified assumption.
