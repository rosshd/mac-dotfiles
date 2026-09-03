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

## Freshness and independence

Age alone does not make an issue stale.

Reject or return an issue to planning when its named branch, SHA, failure, dependency, API, deployment, or product assumption no longer matches current evidence and cannot be revalidated before dispatch.

Two issues are independent only when they have no dependency edge and do not contend for the same likely files, schemas, migrations, generated artifacts, shared contracts, tests, or exclusive external environment.

Unknown independence means one owner task, not two speculative tasks.

## Owner-task contract

One dispatched issue maps to one Codex owner task and one managed worktree.

The task prompt links the issue and carries only the execution-critical fields needed to start safely.
The issue remains canonical when details change.

The owner task stops after the issue acceptance checks and local verification are complete unless the user separately authorizes shipping, deployment, monitoring, or another issue.

Owner completion includes a worker-driven handback to the dispatcher.
When `send_message_to_thread` is available, the dispatcher passes its task and host identities in the owner prompt, and the owner sends one terminal message after completion, blocking, or a need for user input.
The handback identifies the issue, task, worktree, branch, exact head SHA, gate result, review status, and next permission boundary.
Routine progress remains in the owner task.

The dispatcher may end its turn after it confirms the callback instruction.
The handback wakes the dispatcher to consume the result, reconcile `status:active`, and continue the already-authorized review or shipping path.
If cross-task messaging is unavailable, the dispatcher stays active and waits for the owner with the available bounded task-wait mechanism.
The user is not the completion transport.

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
