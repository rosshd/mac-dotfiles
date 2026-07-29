---
name: babysit-prs
description: >
  Check Ross's open GitHub PRs across active repos, fix CI failures on their branches,
  and surface unresolved review comments. Use when asked to babysit, watch, or check on
  open PRs, or as the recurring body of a /loop (e.g. `/loop 15m /babysit-prs`).
---

# Babysit Open PRs

Sweep open pull requests, get red CI back to green, and surface anything that needs Ross.
This skill is the cloud-lane PR babysitter from the captain workflow (docs/WORKFLOW.md in mac-dotfiles).

## Repos to sweep

Ross's active repos under `~/Developer/projects/` plus `~/mac-dotfiles`.
For each repo with a GitHub remote:

```bash
gh pr list --author "@me" --json number,title,headRefName,statusCheckRollup,reviewDecision,mergeable
```

## For each open PR

1. **CI red?** Inspect the exact failing job and logs (`gh run view --log-failed`).
   Reproduce locally in a worktree for that branch when practical.
   Fix clear mechanical causes (test breakage, lint, flaky retry) on the same branch and push.
   Do not force-push, do not weaken or skip checks, do not merge.
2. **Review comments?** List unresolved threads and changes-requested reviews.
   Apply requested changes only when they are mechanical and unambiguous; otherwise surface them.
3. **Merge conflicts?** Report them; rebasing a PR is Ross's call unless he asked for it.

## Escalation and notification

- Never merge, close, or force-push a PR.
- Product or design feedback in reviews is surfaced, not implemented.
- After the sweep, send one summary notification only if something changed or needs Ross:

```bash
notify "PR babysitter" "<one-line summary>" --tag eyes
```

- If everything is green and quiet, end silently (no notification, no changes).

## Loop usage

Recurring invocation from a Claude Code session:

```text
/loop 15m /babysit-prs
```

Keep the interval at 15 minutes or longer; CI rarely changes faster and GitHub rate limits apply.
