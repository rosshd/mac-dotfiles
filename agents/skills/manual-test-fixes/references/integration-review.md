# Integration and Holistic Review

Load this reference before integrating multiple work packages or conducting the final combined review.

## Contents

- [Package Eligibility](#package-eligibility)
- [Pre-Merge Inspection](#pre-merge-inspection)
- [Merge Order](#merge-order)
- [Conflict Protocol](#conflict-protocol)
- [Integrated Replay](#integrated-replay)
- [Holistic Diff Review](#holistic-diff-review)
- [Traceability Report](#traceability-report)

## Package Eligibility

Mark a package `GO` only when all conditions hold:

- Its issue IDs and expected behavior are unambiguous.
- Reproduction evidence or deterministic proof exists.
- Dependencies, ownership, shared files, and conflicts are declared.
- Its base and assumptions are compatible with the current integration head.
- Its worktree is clean and its commit is scoped.
- Focused verification and `git diff --check` pass.
- The repository-required package or integration gate passes.
- An independent lightweight diff review records no unresolved finding.
- No product decision, destructive risk, or semantic conflict remains.

Mark it `NO-GO` when any condition is unknown or false.

## Pre-Merge Inspection

For every package:

1. Confirm the integration checkout is clean and on local `main`.
2. Inspect branch status, commits, and the complete diff against the current integration head.
3. Compare actual changed paths with declared ownership.
4. Read the reproduction, verification, skipped coverage, and reviewer disposition.
5. Confirm the repository-required package or integration gate passed.
6. Re-run the focused checks and required gate if the package is stale relative to an earlier merge.
7. Reclassify issues that an earlier package may already have resolved.

Never merge dirty, failed, capped, partially committed, stale-assumption, or unreviewed work.

## Merge Order

Follow the explicit dependency graph.
When no dependency edge exists, prefer:

1. Storage, schema, and foundational contracts.
2. Core behavior and shared services.
3. Consumers, commands, and UI.
4. Tests, fixtures, and documentation that depend on the final contract.

This ordering is a heuristic, not permission to split one coherent package.
Merge one package at a time and record the resulting main commit against its issue IDs.

## Conflict Protocol

1. Identify the user-visible intent of both sides.
2. Determine whether the conflict is mechanical or semantic.
3. Stop and return the package for rework when intent is ambiguous.
4. Resolve mechanical conflicts narrowly without accepting an entire side blindly.
5. Run every affected package's focused tests after the resolution.
6. Re-run the relevant smoke flow when shared behavior changed.
7. Record the conflict and resolution in the ledger.

## Integrated Replay

Use fresh isolated state.
Replay:

- Every original manual reproduction.
- Adjacent paths that share modified state or contracts.
- Negative and cancellation paths.
- Persistence or restart behavior where relevant.
- Security, privacy, and configuration boundaries touched by the fixes.

Record real-provider, hardware, browser, editor, timing, or platform coverage that could not be repeated.
Do not test with real private data merely to complete the checklist.

## Holistic Diff Review

Review the full baseline-to-main diff for:

- An issue without a matching change or explicit disposition.
- Multiple fixes for one root cause.
- Inconsistent terminology, navigation, output, or error handling.
- Cross-package contract mismatches.
- Regressions outside the narrow package tests.
- Missing negative, persistence, or compatibility coverage.
- Test weakening, snapshot laundering, debug output, generated artifacts, secrets, or unrelated edits.
- Storage, provider, prompt, permission, concurrency, and destructive-operation risks.
- Documentation or manual-test drift.

Run the repository's full review gate on the exact final head.
When review finds a needed code change, create or reuse an authorized remediation branch and worktree.
Apply the normal package verification and independent review before merging remediation serially.
Replay affected scenarios and rerun the final gate on the new exact head.
Never edit or commit review fixes directly on `main`.

## Traceability Report

Report:

| Finding | Disposition | Package | Commit | Evidence or check | Residual risk |
| --- | --- | --- | --- | --- | --- |
| MT-001 | fixed | navigation | abc1234 | original replay plus test | none known |

Also report:

- Baseline and final main commits.
- Exact focused, smoke, and full-review commands and results.
- Skipped or environment-blocked coverage.
- Remaining product decisions, deferred issues, and follow-ups.
- Final `git status --short`.
- Merged worktree and branch cleanup.
- Exact cleanup commands for worktrees or branches that could not be removed.
- Whether any remote action occurred.

Completion requires every finding to be fixed, duplicate, invalid, deferred, blocked, or rejected with a reason.
Completion also requires a clean holistic review, a passing full gate, successful original-scenario replay, and a clean local `main`.
Remove merged worktrees and branches with the repository lifecycle command when authorized.
Otherwise preserve them and include the exact cleanup commands in the handoff.
