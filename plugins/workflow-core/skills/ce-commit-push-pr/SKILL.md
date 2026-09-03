---
name: ce-commit-push-pr
description: Commit scoped changes, push the current branch, and open or update a GitHub PR when the user asks to ship, push, or create a PR. Do not monitor or merge automatically.
---

# Commit, push, and PR

Ship the requested branch without including unrelated work.

## Workflow

1. Inspect repository instructions, status, branch, remotes, divergence, existing PR state, and authentication.
2. Confirm that the user's request authorizes the required external actions.
3. Preserve unrelated files and commits, and stop on ambiguous branch ownership or dirty-state overlap.
4. Create scoped commits with named files when uncommitted task work remains.
5. Resolve the repository's canonical local gate from its instructions, build files, and CI configuration.
   Stop if the gate is missing, ambiguous, or cannot exercise the change adequately.
6. Record the current commit SHA, run the full local gate at that SHA, and keep its command and result visible in the task transcript.
7. Resolve the intended base branch and run one read-only `codex review --base <base>` pass over the branch diff.
   Keep the review output visible in the task transcript instead of redirecting, summarizing away, or replacing it with a private result.
8. Apply at most one repair cycle automatically when actionable findings remain inside the issue outcome and permissions and do not increase risk.
   Create the repair commit, rerun the full local gate, and run one targeted rereview of only those fixes.
   Stop for changed scope, new authority, increased risk, or findings that survive the targeted rereview.
9. Immediately before pushing, prove that `HEAD` still equals the SHA covered by the latest passing gate and review, then recheck branch, remote, and existing PR state.
10. Push without force and open or update the matching PR.
11. Write a concise PR description covering purpose, important decisions, exact validation evidence, independent review result, and remaining risk.
12. Return the PR URL, pushed SHA, gate command and result, review result, risk, and exact shipping outcome to the caller.

Do not add branding or a teaching section unless requested.

Do not force-push, rebase published work, or start `ce-babysit-pr` automatically.

This skill ends at the pull request.
The factory dispatcher may continue through CI, merge, and release verification only under the factory contract's standing risk policy and the issue permissions.

PR monitoring requires a separate explicit request.

Run no more than one full independent review and one targeted rereview for a shipping request.

Any unreviewed change to `HEAD` invalidates the shipping evidence and blocks the push.
