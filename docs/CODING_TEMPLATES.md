# Coding templates

Use the narrowest template that matches the work.
The GitHub Issue remains the durable brief.

## Tool map

| Workflow part | Tool | Why |
| --- | --- | --- |
| Daily terminal workspace | `ship` and tmux | Restores the keyboard-first workspace. |
| Editing | Neovim | Keeps code, search, Git, language tools, and formatting on the keyboard. |
| Implementation owner | Codex managed task | Gives one issue a durable execution record and isolated worktree. |
| Planning | Markdown plan and concise chat review | Keeps one canonical plan and exposes only real decisions. |
| Local quality gate | Repository-owned `make check` | Defines the checks required before push. |
| Independent review | `codex review --base <base>` | Reviews the exact tested branch diff once. |
| GitHub state | GitHub Issues, pull requests, CI, and `gh dash` | Keeps durable work and shipping state in one system. |
| Notification | `notify` | Sends an explicit generic local or phone alert. |
| Rebuild readiness | `rebuild-mac check` | Checks package and Nix inputs without applying them. |

## New repository

```text
Outcome:
Make <repository> satisfy the personal software factory contract.

Acceptance checks:
- README names setup, development entry point, and local gate.
- AGENTS.md names entry points, checks, generated files, and release boundaries.
- One canonical gate covers every required pre-push check.
- CI runs the same gate or a documented equivalent.
- Issue and pull-request templates record risk, verification, and rollback.

Constraints:
- Preserve current product behavior.
- Keep secrets and local state out of version control.

Verification:
- Run focused configuration checks.
- Run the canonical repository gate.
- Review the exact tested head.
```

Use the Workflow Core `factory-bootstrap` skill for this case.

## Bug fix

```text
Outcome:
Fix <user-visible failure> while preserving unrelated behavior.

Evidence:
- Record the closest practical reproduction.
- Identify the smallest owner module.

Implementation:
1. Add or update a regression test first when practical.
2. Run the test and confirm it exposes the failure.
3. Patch the smallest behavior surface that explains the failure.
4. Run the focused regression test.
5. Run the repository gate.

Stop condition:
The failure is covered, the focused check passes, and the repository gate passes.
```

Use one Codex owner task and one managed worktree when the issue is ready.

## Feature

```text
Outcome:
Deliver <observable capability>.

Acceptance checks:
- Describe user-visible success.
- Name compatibility and failure behavior.
- Name required tests and release checks.

Constraints:
- Preserve existing behavior outside the feature.
- Keep external actions within explicit permissions.

Verification:
- Run focused tests for the new behavior.
- Run the repository gate.
- Run one independent review on the exact tested head.
- Require exact-head CI before merge.
- Verify the deployed or installed result after merge.
```

Resolve product choices before dispatch.

## Validation pass

```text
Outcome:
Prove <change> works with the strongest practical evidence.

Steps:
1. Confirm the branch and exact head.
2. Run the narrowest behavior check.
3. Run the canonical repository gate.
4. Run repository-specific smoke or end-to-end checks.
5. Run git diff --check against the intended base.
6. Record commands, results, skipped coverage, and remaining risk.

Stop condition:
Every required check covers the same head and any residual risk is explicit.
```

## Review pass

```text
Outcome:
Find concrete defects, regressions, missing tests, and repository-rule violations in <branch or pull request>.

Steps:
1. Inspect status and the complete diff.
2. Read each touched owner module and its tests.
3. Verify suspicious behavior with a focused command when possible.
4. Report actionable findings with file and line references.
5. State that no findings were found when the review is clean.

Stop condition:
The review covers the exact tested head and every finding has a disposition.
```

Use one full independent review.
After accepted fixes, run the full gate again and permit at most one targeted rereview.

## Managed worktree dispatch

```text
Outcome:
Give one Ready issue one implementation owner.

Before dispatch:
1. Confirm the issue body is current.
2. Confirm dependencies are complete.
3. Confirm no competing task, branch, worktree, or pull request exists.
4. Record the verified base commit.
5. Confirm authorized risk and external actions.

Task prompt:
- Link the issue as canonical scope.
- Name the repository and managed worktree.
- Name the branch and exact start SHA.
- Carry only execution-critical constraints.
- Name the required focused and full gates.

Stop condition:
One permanent Codex task ID maps to the issue and worktree.
```

Create the task only after Ross authorizes dispatch.

## Pull request

```text
Purpose:
<One paragraph describing the shipped source change.>

Issue:
References #<number>

Ownership:
- Task ID: <permanent Codex task ID>
- Branch: <branch>
- Worktree: <path>
- Start SHA: <sha>
- Pushed SHA: <sha>

Validation:
- <focused command and result>
- <canonical gate and result>
- <diff check and result>
- <independent review and result>
- <exact-head CI and result>

Risk:
<Low, medium, or high with reasoning.>

Rollback:
<Concrete recovery path.>

Post-merge checks:
- <Installed or deployed state check.>
- <User-visible smoke check.>
```

Use a non-closing issue reference while post-merge checks remain.

## Plan review

```text
Outcome:
Produce one implementation-ready Markdown plan for <problem>.

Steps:
1. Inspect the current repository and constraints.
2. State the recommended direction and real alternatives.
3. Save one canonical Markdown file.
4. Summarize the result and numbered decisions in chat.
5. Update the same file after feedback.
6. Convert the approved outcome into a GitHub Issue.

Stop condition:
The issue can be written without inventing product behavior or scope.
```

Keep each full sentence on its own physical line in long Markdown files.
