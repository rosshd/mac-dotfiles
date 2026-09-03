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

## openlearn defaults

For `/Users/ross/Developer/projects/openlearn`, prefer:

```bash
.venv/bin/python -m unittest
.venv/bin/python -m pytest -q
OPENLEARN_MOCK=1 OPENLEARN_HOME=$(mktemp -d) .venv/bin/openlearn chat ai
```

Slow AI-judge tests require explicit intent.
