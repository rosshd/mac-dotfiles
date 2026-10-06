---
name: repo-validation
description: Use when finishing code changes, preparing review, or validating agent-produced work with concrete evidence instead of only saying it is done.
---

# Repo Validation

Validate changes with the repo's own commands and report evidence.

## Workflow

1. Identify the relevant project instructions: `AGENTS.md`, `CLAUDE.md`, README, or development docs.
2. Check the diff scope with `git diff --stat` and inspect the changed files.
3. Run the narrowest meaningful checks first, then broaden if the change touches shared behavior.
4. Prefer end-to-end or user-visible smoke checks for behavior changes.
5. Report exact commands and results.
6. If a finding is mechanical and safe, fix it. If it changes product intent, ask the user.

## Repository authority

The repository's own validation skill and Makefile select commands.
For OpenLearn, use `.claude/skills/openlearn-validate/SKILL.md`.
Its pytest lane includes unittest cases; do not run a duplicate suite.
Run focused checks while iterating and the canonical gate once on the final candidate.
Reuse recorded evidence only while candidate content, test mode, and relevant environment still match.
Mock and isolate any learner flow.
Slow AI-judge tests require explicit intent.
