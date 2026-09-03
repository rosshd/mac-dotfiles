# Personal software factory workflow

This is the canonical day-to-day workflow.
GitHub Issues hold durable work state, Codex managed tasks own implementation, and each repository owns its quality gate.

## Normal path

```text
intake
  -> create or refine one GitHub Issue
  -> confirm dependencies, ownership, and risk
  -> dispatch one Codex owner task into one managed worktree
  -> implement with focused checks
  -> run the repository gate
  -> commit the scoped change
  -> review the exact tested head once
  -> push without force and open a linked pull request
  -> require exact-head CI and the authorized risk boundary
  -> verify the release or installed state
  -> close the issue only after verification
  -> inspect Ready issues and propose bounded next work
```

GitHub is the source of truth for issue, pull-request, review, CI, and merge state.
Codex tasks are execution records, not a second task database.
Local tmux windows remain a convenient workspace, but they do not prove task status.

## Workspace

Open WezTerm when you are ready to work.
Fish runs `ship`, which attaches to the persistent tmux session named `main`.
tmux restores the last saved session when a new server starts.
If no snapshot exists, `ship` creates the `home` and `notes` windows.

```bash
ship
ship --save
doctor
rebuild-mac check
gh dash
```

Use Neovim for direct editing and Git inspection.
Launch Codex from the repository that owns the work.

```bash
cd <repository>
codex
```

The tmux `Ctrl-y` binding opens Codex in a side pane rooted at the current pane directory.

## GitHub Issue contract

Create one issue for each bounded change.
Use `agents/prompts/templates/factory-issue.md` when the repository does not provide its own issue form.

Every dispatchable issue records:

1. One observable outcome.
2. Testable acceptance checks.
3. Constraints that must remain true.
4. Nearby non-goals.
5. Current evidence and source locations.
6. Low, medium, or high risk with the recovery path.
7. Authorized repository and external actions.
8. Dependencies or `None`.
9. Focused, repository-wide, review, CI, and release verification.

The issue body remains canonical if scope changes.
Update it before continuing when new evidence changes the outcome, permissions, risk, or dependencies.

## Ownership and dispatch

One issue maps to one Codex owner task and one managed worktree.
Before editing, the owner records the permanent task ID, issue number, repository, worktree, branch, and exact start SHA.
The owner also checks for a competing issue, task, branch, worktree, or pull request.
Unknown overlap means one owner until the boundary is clear.

Dispatch requires explicit authorization.
Use the Codex app to create the task and select the saved repository project.
Git repositories should use a managed worktree unless Ross explicitly requests the saved checkout.
The issue body supplies the durable scope, and the task prompt carries only the execution-critical constraints.

Do not create a copied task brief in the repository.
Do not split one issue across concurrent implementers who can touch the same files or state.

## Implementation

Start from the issue's verified base commit.
Read repository instructions and preserve unrelated user changes.
Add a focused failing test or contract before implementation when practical.
Make the smallest coherent source change that satisfies the acceptance checks.
Keep external mutations within the issue's permissions.

Run the narrowest meaningful check first.
Then run the canonical repository gate from the repository root.

```bash
make check
```

If a repository uses another command, its `AGENTS.md` and README must name it.
Do not claim completion from a partial check when the canonical gate is available.

## Independent review

Run one bounded, read-only review after the scoped commit and full gate pass.
Review the branch diff against its intended base.
The reviewed SHA must equal the exact head covered by the latest successful gate.

```bash
git rev-parse HEAD
codex review --base <base-branch>
```

Resolve concrete defects before shipping.
Any change after review invalidates the evidence and requires a new commit, a fresh gate, and at most one targeted rereview.
Escalate product or UX tradeoffs instead of silently choosing them.

## Shipping and merge

Immediately before pushing, confirm the branch, remote, existing pull-request state, and exact tested SHA.
Push without force.
Open or update one pull request that links the issue and records the task ID, branch, worktree, start SHA, pushed SHA, validation, review result, risk, rollback, and remaining release checks.

Use `References #<issue>` when release verification remains after merge.
Use a closing keyword only when merge itself completes the issue and no installed or deployed verification remains.

A merge requires:

- Merge authorization in the issue, current request, or Ross's standing low- and medium-risk factory policy.
- Risk that remains within the authorized low or medium boundary.
- A passing canonical gate for the exact head.
- One bounded independent review with no unresolved finding.
- Required CI passing for the exact pull-request head.
- A documented rollback path.

High-risk work may be pushed and opened as a reviewed pull request when issue permissions allow it.
It stops for Ross before merge or production activation with one exact verification packet and direct approval question.
Do not weaken required checks to make a pull request mergeable.

## Release verification

Merge is not release verification.
Verify the actual deployed or installed system through the closest user-visible path.
Check the final revision, health signal, key workflow, and rollback readiness.
Record exact commands, results, and timestamps in the issue or pull request.

For workstation configuration, prefer `rebuild-mac check` before any apply.
Run an activating rebuild only when the issue explicitly authorizes it.
Inspect managed links, hooks, plugin inventory, `doctor`, `gh dash`, Codex discovery, generic notifications, and terminal or phone access after an authorized cutover.

Close the issue only after every acceptance check and required release check is recorded.

## Notifications and monitoring

The shared Codex Stop hook sends one generic completion notification.
Use `notify` directly for an explicit local or phone alert.

```bash
notify "Review ready" "The Codex task finished"
notify --sound Glass --volume normal --repeat 1 "Notification test" "The notification path works"
```

Use recurring task monitoring only when Ross asks to watch a pull request or other changing state.
Keep quiet while state is unchanged and report completion, failure, or required action.

## Phone access

Phone access uses Tailscale plus normal macOS Remote Login.
The phone can open the same terminal workflow through SSH and inspect GitHub state with `gh`.
Prefer the Tailscale MagicDNS hostname over a raw address.

```bash
/bin/zsh -lc 'cd <repository> && gh issue list && gh pr list'
/bin/zsh -lc 'cd <repository> && codex'
```

Keep Remote Login limited to Ross's user account.
Treat the phone as another direct terminal client, not a separate dispatch system.

## Next work

After verified completion, inspect open issues and their dependencies.
Propose only Ready issues whose write sets and external state do not conflict.
Rank the smallest bounded work that moves the product forward.
Create another Codex task only after Ross authorizes that dispatch.

## Failure handling

If a focused test fails, keep the loop local until the cause is understood.
If the repository gate fails, fix the failure or report a real blocker before review.
If review finds an in-scope defect that preserves permissions and risk, apply one repair cycle, rerun the full gate, and run one targeted rereview.
Stop for findings that change scope, need new authority, raise risk, or survive the targeted rereview.
If CI fails on the exact head, inspect the failing job and reproduce it locally when practical.
If risk expands beyond the issue's permission, stop before the higher-risk action.
If release verification fails, preserve rollback state and keep the issue open.
