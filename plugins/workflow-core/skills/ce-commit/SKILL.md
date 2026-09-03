---
name: ce-commit
description: Create one or more clear local git commits when the user asks to commit or save changes. Never push or open a PR; use ce-commit-push-pr for shipping.
---

# Commit

Create local commits that contain only the work the user intended to save.

## Workflow

1. Inspect repository instructions, status, staged changes, unstaged changes, untracked files, and recent commit conventions.
2. Preserve unrelated user work and never assume every changed file belongs to the task.
3. Group only clearly distinct logical changes, with two or three commits as a practical upper bound.
4. Stage named files rather than `git add .` or `git add -A`.
5. Use imperative subjects that describe the outcome, with a body only when motivation or tradeoffs are not obvious.
6. Commit with explicit path limits so unrelated staged work cannot ride along.
7. Re-read status and report the commits and anything intentionally left uncommitted.

Do not create or switch branches unless repository policy or the user requests it.

Do not push, open a PR, or start monitoring.
