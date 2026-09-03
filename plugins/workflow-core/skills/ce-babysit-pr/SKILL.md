---
name: ce-babysit-pr
description: Monitor an open GitHub PR over time and react to CI or review feedback until it looks merge-ready or reaches a real blocker. Use only when the user asks to watch, babysit, or keep following a PR.
---

# Babysit PR

Keep the named PR moving without merging it.

## Loop

1. Resolve the exact PR, repository, head branch, and current head SHA.
2. Snapshot checks, review state, unresolved threads, mergeability, and branch currency.
3. Resolve actionable review feedback through `ce-resolve-pr-feedback` when authorized by the monitoring request.
4. Diagnose real CI failures through `ce-debug`, rerun only clearly flaky failed jobs, and avoid unrelated changes.
5. Refresh state after every push or external change and continue monitoring with the available wait mechanism.
6. Stop when the PR looks merge-ready, an external decision blocks progress, the user stops monitoring, or a stated time budget expires.

Monitoring authorizes scoped fixes, commits, pushes, replies, and thread resolution on the named PR branch.

It does not authorize merging, force-pushing, rebasing published history, approving protected actions, or updating unrelated branches.

Use plain status labels: `Merge-ready`, `Waiting`, `Blocked`, `Stopped`, or `Timed out`.

Report the evidence for the status, fixes made, checks observed, and residual decisions.
