---
name: factory-dispatch
description: Inspect GitHub issues and propose or start the next bounded factory work. Use when asked what is Ready or to dispatch the next tasks; require explicit authorization before creating Codex tasks.
---

# Factory dispatch

Select work from GitHub without introducing a queue service or copying the issue into another planning artifact.

Read [`factory-contract.md`](../../references/factory-contract.md) before querying candidates.

## Read-only proposal

1. Resolve the exact repository, default branch, current work, open pull requests, and active owner tasks.
2. Query GitHub directly through an available GitHub tool or `gh` for open issues labeled `status:ready`.
3. Read each candidate issue and referenced dependency in full.
4. Reject a candidate when acceptance checks are absent, a dependency is unresolved, current evidence contradicts the issue, required permissions are unclear, or another task already owns the work.
5. Inspect the current repository to estimate each candidate's write set and shared contracts.
6. Treat candidates as independent only when their write sets, migrations, generated artifacts, shared contracts, tests, and exclusive external environments do not overlap.
   When independence is uncertain, propose one item.
7. Rank the remaining candidates by dependency leverage, user impact, risk, and verification cost.
8. Propose at most two independent issues with rejection reasons for close alternatives.

The proposal is read-only.
It must include the issue links, acceptance checks, likely write sets, risk, required permissions, dependencies, and why the pair is independent.

For a named dry-run fixture, evaluate the supplied synthetic issues with the same rejection and independence rules and make no GitHub or task mutation.

## Authorized dispatch

Create tasks only after the user explicitly authorizes the proposed issue numbers.

For each authorized issue:

1. Re-read the issue and repository state immediately before dispatch.
2. Create one Codex owner task in one managed worktree for that issue.
3. Put the issue URL and number, repository, outcome, acceptance checks, constraints, permissions, verification, and stop condition in the owner-task prompt.
4. Keep the GitHub issue as the durable brief.
   Do not create `.artifacts/fleet`, a copied plan, or a second issue body.
5. After task creation succeeds, replace `status:ready` with `status:active` and record the task identifier on the issue.
6. If task creation or label reconciliation fails, stop and report the exact partial state.

Dispatch no more than two write-owning tasks in one request.

Use subagents only when the user explicitly requests delegation.
Keep delegated parallel work read-heavy and independently bounded unless the user specifically authorizes parallel writes.

Dispatch does not authorize merging, force-pushing, branch-protection changes, production deployment, destructive cleanup, new secrets, purchases, or broader repository permissions.
