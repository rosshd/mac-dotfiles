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

Before task creation, resolve the current dispatcher task ID and host ID when the Codex app exposes cross-task messaging.
Pass those identities to each owner task with the handback instructions below.

For each authorized issue:

1. Re-read the issue and repository state immediately before dispatch.
2. Create one Codex owner task in one managed worktree for that issue.
3. Put the issue URL and number, repository, outcome, acceptance checks, constraints, permissions, verification, and stop condition in the owner-task prompt.
4. Keep the GitHub issue as the durable brief.
   Do not create `.artifacts/fleet`, a copied plan, or a second issue body.
5. After task creation succeeds, replace `status:ready` with `status:active` and record the task identifier on the issue.
6. If task creation or label reconciliation fails, stop and report the exact partial state.

Record the authorized tasks as one active batch in the dispatcher context.

## Worker handback

Dispatch is complete only when the owner has a return path.

When `send_message_to_thread` is available, tell the owner task to send exactly one handback message to the dispatcher task when one of these conditions occurs:

- local implementation and required verification complete;
- work is blocked;
- user input or new authority is required.

Routine progress stays in the owner task.
The terminal handback includes the issue, owner task, worktree, branch, exact head SHA, local gate result, review status, risk, and next permission boundary.
An attention handback replaces the completion result with the exact blocker or decision needed.

After confirming that callback instruction is present, the dispatcher may end its turn.
The worker message wakes the dispatcher, which reads the owner result, revalidates the exact head, reconciles the issue status, and continues only work already authorized by the user.
Creating the task is not a completed factory run.
The user should not have to announce that the worker finished.

On each handback, mark that owner settled in the active batch.
If other owners remain, retain the result and return to sleep.
When the final owner settles, aggregate every result and follow the contract's risk and continuation policy.
Continue authorized low- and medium-risk shipping without a routine user verification stop.
For high-risk work, prepare the exact verification packet and stop before merge or production activation.
If another permission is missing, ask one direct question naming the blocked action.
Never terminate a settled batch with only a passive statement that no push or pull request occurred.

If cross-task messaging is unavailable, keep the dispatcher turn active and use the bounded task-wait capability until the owner completes or needs attention.
Carry forward the wait cursor, remain quiet on unchanged snapshots, and consume the terminal result directly.
Do not replace handback with a scheduled poller, heartbeat, daemon, or queue.

Dispatch no more than two write-owning tasks in one request.

Use subagents only when the user explicitly requests delegation.
Keep delegated parallel work read-heavy and independently bounded unless the user specifically authorizes parallel writes.

Dispatch creates no authority by itself.
Apply the issue permissions and the factory contract's standing risk policy to every continuation action.
Force-pushing, branch-protection changes, destructive cleanup, new secrets, purchases, and permissions beyond the issue always require separate authority.
