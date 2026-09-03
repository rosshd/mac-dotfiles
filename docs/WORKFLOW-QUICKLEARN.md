# Personal software factory quick reference

## Daily loop

```text
GitHub Issue
  -> one Codex owner task
  -> one managed worktree
  -> focused checks
  -> repository gate
  -> scoped commit
  -> one independent review
  -> linked pull request
  -> exact-head CI
  -> authorized merge
  -> release verification
  -> issue closure
```

## Before editing

Record:

- Permanent Codex task ID.
- Issue number and URL.
- Repository and managed worktree path.
- Branch and exact start SHA.
- Competing issue, task, branch, worktree, and pull-request check.
- Authorized risk and external actions.

## Issue body

Use `agents/prompts/templates/factory-issue.md` or the repository issue form.
The issue needs Outcome, Acceptance checks, Constraints, Non-goals, Evidence, Risk, Permissions, Dependencies, and Verification.
Update the issue when those facts change.

## Implementation

```bash
git status --short --branch
git rev-parse HEAD
make check
git diff --check <base>...HEAD
```

Add a regression test or contract first when practical.
Run focused checks before `make check`.
Preserve unrelated work and avoid unapproved external changes.

## Review and shipping

```bash
codex review --base <base-branch>
git rev-parse HEAD
git push -u origin <branch>
gh pr create
gh pr checks <number> --watch
```

The gate, review, push, and CI must cover the exact head.
Use one full independent review and at most one targeted rereview after fixes.
Never force-push as part of the normal path.

The pull request records the issue link, task ID, branch, worktree, start SHA, pushed SHA, validation, review result, risk, rollback, and remaining release checks.
Use `References #<issue>` while post-merge verification remains.

## Merge and release

Merge low- and medium-risk work under issue, current-request, or standing factory authorization only after required CI and a clean exact-head review.
High-risk work may reach a reviewed pull request, then stops for Ross before merge or production activation.
After Ross approves, resume only the exact reviewed path covered by that approval.
Verify the installed or deployed system after merge.
Keep the issue open until its release checks pass.

For workstation configuration, run `rebuild-mac check` before any authorized apply.

## Direct tools

```bash
ship
codex
gh dash
nvim
doctor
rebuild-mac check
notify "Review ready" "The task finished"
```

tmux keeps the workspace available.
GitHub and the Codex app show durable task state.

## Stop conditions

Stop before an action that exceeds permissions.
For high-risk work, stop before merge or production activation and ask one exact approval question.
Stop shipping when the gate, review, or exact-head CI fails.
Stop issue closure when release verification is incomplete.
Ask Ross before product tradeoffs, destructive changes, secrets, purchases, or production actions outside the issue.

## Next work

Inspect Ready issues after verified completion.
Propose bounded non-conflicting work.
Dispatch only after Ross authorizes another Codex task.
