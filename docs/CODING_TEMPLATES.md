# Coding Templates

Use these templates to keep the workflow repeatable without making every task a bespoke plan.
Pick the narrowest template that matches the job.

## Tool Map

| Workflow part | Tool | Why |
| --- | --- | --- |
| Daily terminal workspace | `ship` + tmux | Creates one persistent cockpit with only `home` and `notes` by default. |
| Editing | Neovim | Keeps code, search, Git signs, LSP, and formatting on the keyboard. |
| Narrow repo inspection | Codex | Best default for local files, terminal commands, tests, and implementation. |
| Alternate model opinion | Claude Code | Useful for consequential second opinions or when Codex is stuck. |
| Model-agnostic agent trial | OpenCode | Useful when testing another provider or TUI without changing the core workflow. |
| Isolated implementation | `fleet` + Treehouse | Leases a separate worktree so the main checkout stays clean. |
| Long bounded loop | `gnhf` through `fleet` | Keeps the agent running until the brief reaches done or blocked. |
| Review and ship gate | `no-mistakes` | Handles validation, review, push, PR, and CI gate behavior. |
| Planning surface | `lavish-axi` / `plan-artifact` | Turns complex choices into reviewable local HTML instead of long chat. |
| Status and notification | `captain` + `notify` | Surfaces done, blocked, and gate events without progress noise. |
| GitHub triage | `gh dash` | Shows PRs and issues without leaving the terminal. |

## Template: New Repo Setup

Use when creating or adopting a repo.

```text
Goal:
Set up <repo> so it can be edited, tested, validated, and handed to agents from the terminal workflow.

Tools:
- Neovim for first-pass inspection and config edits.
- Codex for repo mapping and setup implementation.
- `doctor` only for global toolchain issues.
- Project-native checks for verification.

Steps:
1. Identify language, package manager, test command, lint command, and typecheck command.
2. Add or update `AGENTS.md` with entry points, checks, generated files, and non-negotiables.
3. Add a `make check` or equivalent green gate if the repo does not have one.
4. Add `.env.example` only if configuration is required.
5. Run the focused setup checks and the green gate.

Stop condition:
The repo has documented agent instructions, a green local check command, and no secrets or local state committed.
```

## Template: Bug Fix

Use when behavior is wrong or a test is failing.

```text
Goal:
Fix <user-visible failure> while preserving unrelated behavior.

Tools:
- Codex for reproduction, implementation, and focused tests.
- Neovim for manual inspection when the change is small.
- `fleet` if the fix needs an isolated worktree or can run unattended.
- `no-mistakes` only after the focused fix is green.

Steps:
1. Reproduce or reason from the closest practical user-visible path.
2. Find the narrowest owner module.
3. Add or update a regression test first when practical.
4. Patch the smallest behavior surface that explains the failure.
5. Run the focused regression test.
6. Run the project green gate.

Stop condition:
The failure is covered by a focused check, the check fails before or would have failed before the fix, and the green gate passes.
```

## Template: Review Pass

Use before trusting a branch or PR.

```text
Goal:
Find correctness, regression, UX, security, and test gaps in <branch/PR>.

Tools:
- Codex review mode for diff-aware findings.
- Claude Code only for high-consequence second review.
- `make review` when the repo provides it.
- `gh dash` or GitHub PR view for PR state.

Steps:
1. Inspect status and diff.
2. Read the touched owner modules.
3. Prioritize findings over summaries.
4. Verify suspicious behavior with a focused command when possible.
5. Report file and line references for every actionable issue.

Stop condition:
Findings are either fixed, explicitly accepted, or documented as remaining risk.
```

## Template: Validation Pass

Use after implementation and before handoff.

```text
Goal:
Prove <change> works with the strongest practical local evidence.

Tools:
- Focused test command for the changed behavior.
- Project green gate, usually `make check`.
- `make review` before a PR when available.
- `no-mistakes` when shipping or pushing through the full gate.

Steps:
1. Run the narrowest test that exercises the changed behavior.
2. Run the repo green gate.
3. Run typecheck if the repo treats it as useful, even when non-blocking.
4. Record exact commands and outcomes.
5. Fix lint, flaky tests, or unrelated failures encountered in the touched area.

Stop condition:
The handoff names the exact checks run, their results, and any residual risk.
```

## Template: Worktree Branch Setup

Use when a task should not touch the main working tree.

```text
Goal:
Create an isolated checkout for <task> and keep ownership boundaries clear.

Tools:
- `fleet brief <slug>` for unattended agent work.
- `fleet start <slug>` for Treehouse-leased worktrees and gnhf execution.
- `wt get` / `wt return` for manual Treehouse worktree leases.
- Git only for explicit branch inspection and cleanup.

Steps:
1. Choose a slug that names the deliverable, not the implementation guess.
2. Write objective, scope in/out, conflicts, verification, and escalation rules.
3. Start the fleet lane if the stop condition is clear.
4. Use an interactive worktree if product direction is still unsettled.
5. Return or remove the worktree only after the branch is merged or abandoned.

Stop condition:
The worktree has one owner, one stop condition, and no untracked user data.
```

## Template: Planning Artifact

Use when the decision is visual, comparative, or likely to need feedback.

```text
Goal:
Create a reviewable decision surface for <problem>.

Tools:
- `plan-artifact` for simple local HTML plans.
- `lavish-axi` when comments, annotations, or a feedback loop are useful.
- Codex for repo-grounded options and tradeoffs.

Steps:
1. State the decision and the options.
2. Map tradeoffs, risks, and recommended next action.
3. Keep implementation details out unless they change the decision.
4. Open the artifact for review.
5. Convert the chosen direction into a fleet brief or interactive task.

Stop condition:
The artifact makes the decision obvious enough to approve, reject, or redirect.
```
