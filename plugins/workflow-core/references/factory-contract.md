# Personal software factory contract

Use this contract for repository bootstrap, GitHub issue creation, and bounded dispatch.

## Minimum repository contract

A repository in the factory has:

- A `README.md` that identifies the product, setup path, development entry point, and canonical local gate.
- A concise `AGENTS.md` that names entry points, the local gate, generated files, protected boundaries, and deployment or release rules.
- Optional `CONTEXT.md` or ADRs only when the durable-context write threshold is met.
- One canonical local gate that fails on any check required before push.
- CI that invokes the canonical gate or a documented command-equivalent wrapper.
- A factory work issue form and the six labels defined below.
- A pull-request template that links the issue and records the gate, independent review, risk, and deployment or rollback evidence.
- Default-branch protection that requires a pull request and the canonical CI check when the hosting plan permits it.
- Deployment verification and rollback documentation when the repository deploys a product or service.

The contract does not require a project-specific orchestrator, daemon, queue database, or agent framework.

## Issue contract

The GitHub issue is the durable task brief.

Every dispatchable issue contains these sections:

1. `Outcome`: one observable result.
2. `Acceptance checks`: at least one testable checkbox.
3. `Constraints`: behavior, compatibility, data, UX, or operational limits that must remain true.
4. `Non-goals`: nearby work excluded from the issue.
5. `Evidence`: current source locations, failures, measurements, screenshots, issue links, or external facts that justify the work.
6. `Risk`: `low`, `medium`, or `high`, with the failure impact and recovery path.
7. `Permissions`: allowed repository writes and any separately authorized external, destructive, secret, paid, or production action.
8. `Dependencies`: blocking issue links or `None`.
9. `Verification`: exact commands and observable evidence required before completion.

Evidence should name likely files, components, contracts, migrations, or external environments when known.
The dispatcher revalidates that likely write set against the current repository rather than trusting it blindly.

An issue with missing acceptance checks, ambiguous permissions, or an unresolved dependency is not dispatchable.

Issue creation remains part of normal brainstorming and planning.
Do not create an issue daemon or duplicate the issue in a local planning artifact.

## Labels

Use only these factory labels unless the repository already needs additional product labels:

- `status:ready`: complete brief with resolved dependencies and no active owner.
- `status:active`: one owner task currently holds the work.
- `status:blocked`: work cannot proceed without an external change or decision.
- `status:verify`: implementation exists and awaits named verification.
- `needs-human`: a human decision or action is required.
- `risk:high`: failure could materially affect data, security, production, money, or difficult rollback.

Treat the four `status:*` labels as mutually exclusive.
Treat unlabeled open issues as ideas or backlog, not dispatchable work.

`status:verify` means that implementation exists and a named verification step remains.
It does not by itself require human action.
Add `needs-human` only when a concrete human decision or action blocks progress, and pair it with one direct question.

Risk is authoritative in the issue body.
Use `risk:high` as the visible exception label; low and medium do not require risk labels.

## Freshness and independence

Age alone does not make an issue stale.

Reject or return an issue to planning when its named branch, SHA, failure, dependency, API, deployment, or product assumption no longer matches current evidence and cannot be revalidated before dispatch.

Two issues are independent only when they have no dependency edge and do not contend for the same likely files, schemas, migrations, generated artifacts, shared contracts, tests, or exclusive external environment.

Unknown independence means one owner task, not two speculative tasks.

## Owner-task contract

One dispatched issue maps to one Codex owner task and one managed worktree.

The task prompt links the issue and carries only the execution-critical fields needed to start safely.
The issue remains canonical when details change.

The owner task stops after the issue acceptance checks and local verification are complete, then returns control through handback.

Owner completion includes a worker-driven handback to the dispatcher.
When `send_message_to_thread` is available, the dispatcher passes its task and host identities in the owner prompt, and the owner sends one terminal message after completion, blocking, or a need for user input.
The handback identifies the issue, task, worktree, branch, exact head SHA, gate result, review status, risk, and next permission boundary.
Routine progress remains in the owner task.

The dispatcher may end its turn after it confirms the callback instruction.
The handback wakes the dispatcher to consume the result, reconcile `status:active`, and continue the already-authorized review or shipping path.
If cross-task messaging is unavailable, the dispatcher stays active and waits for the owner with the available bounded task-wait mechanism.
The user is not the completion transport.

A locally completed handback replaces `status:active` with `status:verify` while review, shipping, CI, or release verification remains.
A blocked handback replaces `status:active` with `status:blocked`.
Add `needs-human` only when that blocked state needs Ross's decision or action.
A high-risk pull request awaiting Ross uses `status:verify` plus `needs-human`.
After every release check passes, close the issue instead of leaving an ownerless active status.

## Batch settlement

The dispatcher initializes the batch before creating its first task and records each owner immediately after task creation, before label reconciliation or another task creation.
Each terminal handback settles exactly one owner.
While owners remain, the dispatcher records the result and returns to sleep without asking the user to relay progress.
When the last owner settles, the dispatcher aggregates the results and continues every already-authorized path.
If new authority is required, it asks one exact next-action question.
A passive statement that nothing was pushed is not a terminal batch result.

## Risk and continuation

Automated tests, the repository gate, independent review, required CI, and agent-run release verification apply at every risk level.

Ross's standing authorization permits push, pull-request creation, CI monitoring, merge, and release verification for low- and medium-risk work when the issue permissions cover those actions.
The dispatcher continues that path without asking Ross to verify routine behavior.

High-risk work may be pushed and opened as a reviewed pull request when the issue permissions allow it.
Before merge or production activation, mark the issue `status:verify` and `needs-human`, then give Ross one verification packet with the exact behavior to inspect, the relevant risk evidence, rollback path, and one direct approval question.
Ross verifies the high-risk product or operational boundary, not the agent's test commands.

An actionable independent-review finding may receive one automatic repair and one targeted rereview when the fix stays inside the issue outcome and permissions and does not increase risk.
Changed scope, new authority, or increased risk requires Ross's decision.

## Draft analytics events

PSF-02 defines event vocabulary only.
It does not install a collector or permit analytics to change workflow state.

Event names:

- `issue.ready`
- `dispatch.proposed`
- `dispatch.authorized`
- `task.created`
- `work.blocked`
- `gate.completed`
- `review.completed`
- `pr.opened`
- `ci.completed`
- `merge.completed`
- `deployment.verified`

Every future event uses `schema_version`, `event_id`, `occurred_at`, `event_name`, `repository_id`, and `actor_type`.

Attach `issue_id`, `issue_number`, `task_id`, `worktree_id`, `head_sha`, `pr_id`, `pr_number`, `command`, `result`, `duration_ms`, and `reason` only when the event has that identity or measurement.

Use GitHub node IDs for `issue_id` and `pr_id`, the Codex thread ID for `task_id`, the commit SHA for `head_sha`, and a stable checkout identifier for `worktree_id`.

Allowed `result` values are `passed`, `failed`, `blocked`, `canceled`, and `skipped`.

Analytics remains passive and append-only.
