---
name: ce-work
description: Implement a clear build request, specification, or accepted plan through local verification. Use for concrete code changes; use ce-debug for open-ended failures and stop before commit, push, PR, or deployment unless requested.
---

# Work

Implement the selected bounded change completely while preserving unrelated work and existing behavior outside the stated scope.

## Workflow

1. Read repository instructions and inspect status, relevant code, tests, and established patterns.
   When domain vocabulary or prior decisions affect the work, read [`durable-context.md`](../../references/durable-context.md) and the project context it identifies.
2. Resolve the selected work item, its dependencies, bounded scope, and observable acceptance criteria from available context.
3. When a plan defines fresh-task work items, handle exactly one ready item in the current task.
   Use the first ready item only when the ordering is unambiguous; otherwise ask which item to take.
4. Use the current checkout unless the user or repository workflow selected a branch or worktree.
5. Preserve unrelated user changes and avoid dependency churn or broad refactoring.
6. Implement the smallest coherent solution, adding focused regression coverage where practical.
7. Run narrow checks first and broaden according to the change's reach.
8. Use the repository's validation skill when available and report exact evidence.
9. For a multi-task plan, stop after the selected item and name the next ready item.

Ask only when a missing choice changes product behavior, scope, or an irreversible action.

Flag conflicts with durable project context instead of changing that context during implementation.

Do not dispatch subagents or outside models unless the user explicitly requests delegation.

Do not create the next Codex task unless the user explicitly asks.

Local implementation and verification complete this skill.

Commit, push, open a PR, deploy, or monitor only when the user requested that external or repository action.
