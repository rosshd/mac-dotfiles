---
name: visual-planning-artifact
description: Use when a complex plan, product option, UI decision, architecture comparison, or workflow design would be easier to review as a small local HTML artifact instead of a wall of terminal text.
---

# Visual Planning Artifact

Create a local, self-contained HTML artifact for complex planning discussions.

## When to use

Use this skill for:

- Product or UX options.
- Architecture comparisons.
- Multi-phase implementation plans.
- Workflow maps.
- Decision matrices.

Do not use it for tiny tasks or direct code edits.

## Rules

- Write the artifact to a project-local scratch path such as `.artifacts/plans/<slug>.html` unless the user asks for another location.
- Match the target project's existing style when the artifact represents an app or product.
- Keep the artifact portable: inline CSS and no build step.
- Include clear decision points and tradeoffs.
- Do not install or run external visualization tools unless the user explicitly approves.
- After writing the artifact, tell the user the file path and summarize the decisions it supports.
