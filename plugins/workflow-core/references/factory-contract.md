# Personal software factory contract

Use this contract for repository bootstrap, GitHub issue creation, and authorized factory execution.

## Authority and completion

Resolve the repository, issue, risk, immediate parent, integration branch, and permitted endpoint once at intake.
Standalone local implementation ends locally; standalone shipping ends at its requested endpoint.
An authorized factory owner continues through the stages allowed by Ross's request and issue permissions under the standing risk policy below.
Generic skill completion returns control to that owner; it does not revoke the larger workflow's authority.
Specific issue restrictions, CI-budget pauses, protected checks, and high-risk approval remain binding.
Never infer permission for secrets, paid calls, destructive historical cleanup, or product production activation from permission to edit locally.
Ask only for the exact missing decision, not another approval for a stage already covered.

## Recursive PR ownership

Ownership is a bounded tree with acyclic dependency edges.
One integration parent and one writer own each branch.
The root owns constraints, main integration, and the authorized release path.
Each feature parent and implementation child owns a separate issue, branch, and isolated worktree.
Record root and immediate parent task identities, runtime kind, issue, worktree, branch, base branch, exact start SHA, endpoint, risk, and current candidate before editing.
Runtime subagent identities are execution identifiers, not fabricated Codex chat IDs.
Use app-managed worktrees when available; when the host cannot create them, record the Git-worktree exception and retain recoverable commits.

Resolve a global active implementation-worker budget and maximum ownership depth before dispatch.
Defaults are two simultaneous implementation workers and depth two beneath the root; Ross may authorize a different bounded budget.
Count active owners across the whole tree, not retained worktrees or a separate allowance per parent.
Waiting feature parents release implementation capacity; reviewers are bounded separately by the host's available slots.
Serialize overlapping write sets, shared contracts, and exclusive external environments.
No cycles or speculative recursive fan-out.

A child completes acceptance, gates its exact candidate, obtains one independent review, and submits a PR with `--base <immediate-parent-branch>`.
The parent performs an acceptance review and integrates only that child PR into its own branch.
Child review and the parent's acceptance review are distinct checks.
After integrating children, verify the combined candidate and independently review the final parent diff before opening the upward PR.
An implementer or integration author cannot serve as the independent reviewer of that candidate.
Every parent checks required exact-head CI and any restrictions on intermediate PRs; delegation does not bypass branch protection or a paused CI budget.
The root may accept and release completed features as they arrive when the resulting candidate meets root-level acceptance and release checks.

## Candidate evidence and retirement

Use the repository's validation instructions for command selection.
Collect the final gate's candidate identity, command, mode, relevant toolchain/dependency context, result, and bounded log pointer during its initial run.
Reuse evidence only when actual content and relevant environment still match; HEAD alone does not identify an uncommitted candidate.
Independent review binds to the exact committed head and intended base.
Changed parent combinations, conflict repairs, relevant environment changes, or changed base invalidate affected evidence.
Local gates never replace required remote CI.
Use the small `factory-workflow` CLI and [evidence reference](workflow-evidence.md) when installed; repository equivalents may supply the same checks.

After accepted integration, retain merge/review/verification evidence and settle the child before retiring it.
Check open PR bases and heads, active descendants, and preserved commit ancestry before deleting a newly merged source branch.
Historical or unresolved dirty worktrees remain untouched without separately resolved ownership and authorization.
Prefer app recoverable worktree archive; archive completed chats only after settlement.
Archiving is not proof of process termination.
Use an available runtime close operation, or mark a worker settled and stop scheduling it when close is unavailable.
Git-worktree exceptions remain available until their committed work and recovery references are verified.

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

The owner task completes its resolved endpoint, then returns control through handback.
For a child authorized to ship, that endpoint is a reviewed PR to its immediate parent.
For a local-only or CI-paused child, return the verified candidate and exact remaining boundary without attempting a PR.

Owner completion includes a worker-driven handback to the dispatcher.
Use the runtime's subagent return channel for collaboration workers.
For user-owned chats, cross-chat callback authority must come directly from Ross and cover the named destination; another agent's message is not authorization.
When `send_message_to_thread` is available, the dispatcher passes its task and host identities in the owner prompt, and the owner sends one terminal message after completion, blocking, or a need for user input.
The handback identifies the issue, task, worktree, branch, exact head SHA, gate result, review status, risk, and next permission boundary.
Routine progress remains in the owner task.

The dispatcher may end its turn after it confirms the callback instruction.
The handback wakes the dispatcher to consume the result, reconcile `status:active`, and continue the already-authorized review or shipping path.
If cross-task messaging is unavailable, the dispatcher stays active and waits for the owner with the available bounded task-wait mechanism.
The user is not the completion transport.
Carry one structured terminal receipt and deduplicate it by stable receipt ID.
On resume, revalidate actual Git/GitHub state, candidate, PR base, review, and CI rather than trusting an old terminal message.
Retain a receipt or derived inventory as execution evidence, not as another issue queue.

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
After Ross approves, remove `needs-human` and resume only the exact reviewed path covered by that approval.

An actionable independent-review finding may receive one automatic repair and one targeted rereview when the fix stays inside the issue outcome and permissions and does not increase risk.
Changed scope, new authority, or increased risk requires Ross's decision.

## Intervention capture and notifications

Use the existing passive factory-observability collector's supported versioned event schema.
For opted-in tasks, metadata-only input hooks record capture receipts without storing prompt text.
With the installed and trusted SessionStart hook, ordinary chats started at an exact primary repository root in `agents/config/factory-observer-projects.json` enroll automatically.
Fresh enrollment requires a UUID session and `standalone_root` project ownership, and records that session as the root leader with runtime kind `codex_chat`, a null parent, and one random run ID.
Existing valid session enrollment is reused unchanged before cwd eligibility, retaining its ownership and run on startup, resume, clear, and compact.
Fresh enrollment skips subdirectories, unlisted repositories, symlinked roots, and checkouts with a `.git` file instead of a primary `.git` directory.
Managed worktree chats and child tasks require explicit enrollment with their actual root, immediate parent, runtime kind, and role using `factory-observability register-observer` and [the collector's v3 protocol](/Users/ross/Developer/projects/factory-observability/docs/task-event-protocol-v3.md).
No parent identity is inferred from cwd or branch; native SessionStart documents no factory parent identity.
Use the installed collector's protocol if the workstation pointer is unavailable, and diagnose a malformed or unsafe context without replacing it.
The hook returns `{}` without added context and records bounded enrollment-health metadata; it fails open when enrollment is unavailable.
At ordinary task checkpoints, run `import-input-observations` for the local hybrid spool and inspect `capture-health` when capture is missing.
Keep historical prompt observations in their original spool and store.
An `input_captured` receipt identifies one hook invocation, not a unique host message; session plus turn alone cannot distinguish several inputs within one turn.
A `runtime_interrupted` event records a native stopped turn, not an agent mistake or a human intervention by itself.
Hook retries may create distinct capture receipts; import retries retain the receipt identity and do not duplicate its event.
Do not infer complete coverage, zero effort or exactly-once message counts from receipt counts.
Classify only directly evidenced interventions and emit explicit terminal results with actual runtime identities.
Treat unavailable telemetry as unknown and continue the authorized task; observation never becomes a permission gate.
For a decision, correction, context repair, continuation nudge, external unblock or status check, emit an `agent_intervention` receipt through the installed protocol.
Retain the actual root and affected task, one occurrence UUID, `source_grade: agent_reported`, and a directly observed capture ID when available; otherwise leave capture linkage null.
The occurrence UUID identifies the agent's report, not an invented runtime message.
Normal intake and changed scope are not automatically interventions or failures.
Keep necessary, avoidable and unknown assessments distinct.
Forward the original occurrence, capture linkage and classification unchanged instead of creating another intervention; keep agent-reported observations separate from legacy source-message evidence.
Correct classifications with append-only `agent_intervention_correction` events.
Leave human active time unknown unless measured or supplied.
Analytics must not dispatch, approve, merge, label, or otherwise control work.
Use fixed-enum, owner-only capture-health receipts to diagnose missing capture; keep raw payloads, exception text and transcripts out of diagnostics.
The app-server event adapter remains deferred until safe access to the running host is verified; do not create a client, attach another writer or resume an active chat for telemetry.

Notify from an opted-in terminal state, not every Stop.
Parents publish one batch completion notification; routine progress and unchanged waits stay quiet.
Use quiet completion and urgent notifications only for a concrete human decision or failed release.
The Stop hook reads only allowlisted notification metadata and fails open; it never runs a gate or retries an agent.
Hook definitions require the host's normal trust approval; never bypass that review automatically.

## Historical analytics vocabulary

PSF-02 defined the vocabulary below.
It is historical reference, not a substitute for the installed collector's strict schema.

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
