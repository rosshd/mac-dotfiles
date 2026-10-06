# Workflow evidence

Use `factory-workflow` for exact-candidate checks, parent/child receipt validation, resumed state, and read-only workspace inventory.
GitHub Issues, PRs, and Git remain canonical.
This CLI does not dispatch agents, execute gates, grant authority, merge, or delete anything.
Receipts are caller attestations, not cryptographic proof that a review or command ran.
Confirm their supporting issue, review, and CI evidence before acting.

## Candidate and gate evidence

Supply a context JSON containing exactly `environment` and `toolchain` identifiers or configuration hashes.
Include every relevant provider, dependency lock, runtime, and test-configuration change in these identifiers or hashes.
Use `--mode` to distinguish mock/live and other materially different verification modes.
Never include secret values.
The CLI also hashes the running Python/Git versions and platform.
It hashes HEAD, tracked index/worktree deltas, and nonignored untracked file bytes and modes.
Ignored resources and external services are outside its evidence boundary; include relevant configuration hashes in the explicit context.
Submodules fail closed because their dirty content requires separate evidence.

Store snapshots, gate evidence, and the receipt ledger outside the candidate worktree.
Capture the snapshot before the command, then record its actual exit code afterward.
Recording fails if the candidate changed during the command.
The tool refuses to overwrite gate evidence.

```sh
factory-workflow candidate --repo "$repo" --mode mock --context "$context" > "$before"
if (cd "$repo" && make check); then gate_status=0; else gate_status=$?; fi
factory-workflow gate-record --repo "$repo" --mode mock --context "$context" \
  --candidate "$before" --evidence "$gate" --exit-code "$gate_status"
factory-workflow gate-reuse --repo "$repo" --mode mock --context "$context" --evidence "$gate"
```

Reuse requires identical HEAD, content, explicit context, detected toolchain, mode, and gate command, plus a recorded pass.
A new commit, integration, dirty edit, or context change invalidates that evidence.
`make check` is the completed receipt's canonical gate.
Gate reuse never replaces required CI, independent review, or installed/deployed verification.

## Receipt version 1

Each receipt is a closed JSON object with these exact fields.

| Field | Contract |
| --- | --- |
| `schema_version` | Integer `1` |
| `receipt_id` | Unique stable event identifier; retry with the same payload |
| `root_task_id`, `task_id` | Root and owner identities |
| `parent_task_id` | Immediate parent; `null` only for the root |
| `issue` | Canonical GitHub issue URL |
| `worktree` | Absolute owner worktree path |
| `branch`, `base_branch`, `base_sha` | Owner branch, immediate parent's integration branch, exact starting SHA |
| `candidate` | Candidate command's complete JSON: `sha`, `content_hash`, `context_hash`, `mode`, `digest` |
| `authority` | Exactly `endpoint` and boolean `human_verified`; supplied from actual issue/user permission |
| `endpoint` | Reached endpoint: `local`, `pr`, `merge`, or `release` |
| `risk` | `low`, `medium`, or `high` |
| `ci` | Exactly `status` (`passed`, `paused`, `not-run`, `failed`) and `sha` |
| `gate` | Exactly `command`, `status` (`passed`, `failed`, `not-run`), and candidate digest or `null` |
| `review` | Exactly `status`, candidate digest or `null`, and `reviewer_task_id` or `null` |
| `state` | `local-complete`, `pr-ready`, `merged`, `released`, or `blocked` |

Completed states match their reached endpoint and require a passing canonical gate on the candidate.
PR and later endpoints require independent review of that same candidate.
Merge/release require passing CI at the exact candidate HEAD.
High-risk merge/release also require actual human verification recorded in authority.
The reached endpoint cannot exceed the granted endpoint.
`ci.status=paused` requires the local endpoint, including when blocked, because opening a PR may trigger CI.
Return a reviewed local candidate under a budget pause; inspect any preexisting PR directly in GitHub rather than using this receipt to authorize PR creation.
`released` is the caller's attestation that the required installed/deployed check passed; record concrete release evidence on the issue before emitting it.
Blocked receipts can carry incomplete evidence but cannot claim an unauthorized endpoint.
Root receipts use their release integration branch as `base_branch`.

```sh
factory-workflow validate --receipt "$receipt"
factory-workflow consume --receipt "$receipt" --ledger "$ledger" \
  --repo "$child_worktree" --mode mock --context "$context" \
  --root-task "$root_task" --parent-task "$parent_task" --parent-branch "$parent_branch"
factory-workflow state --ledger "$ledger"
factory-workflow inventory --repo "$repo" --ledger "$ledger"
```

Omit `--parent-task` only when consuming a root receipt.
The receiving parent independently supplies expected root, parent, and target branch, rather than trusting the sender's fields.
Consumption checks the current worktree, branch, candidate, and starting-SHA ancestry.
The append-only ledger rejects duplicate-ID collisions, ownership changes, reused branches/worktrees, cycles, and endpoint regressions.
An identical retry is a no-op while its candidate remains current.
Resumed state comes from the latest accepted receipt per task, not a second queue.
POSIX advisory locking serializes ledger readers/writers; keep it on a local filesystem.

## Workspace retirement

Inventory reports `external`, `owned`, `unresolved-dirty`, `unresolved`, or `settled`.
Settlement requires a clean recorded owner, merged/released receipt, preserved HEAD ancestry in the integration branch, and no unsettled recorded children targeting its branch.
A settled entry is only a retirement proposal.
Check current GitHub downstream PRs and running owners before archiving the worktree or deleting its branch.
Squash/rebase merges without preserved ancestry remain unresolved for retirement; verify preservation separately.
This tool never deletes branches, removes worktrees, terminates agents, or changes unowned work.
It does not scan private messages or environment values.
