---
name: manual-test-fixes
description: Triage and fix a batch of findings from a human or agent manual test run, coordinate independent fixes across subagents or worktrees, integrate completed changes into local main, and perform one holistic final review. Use when the user provides multiple manual QA issues, a run-through report, a punch list, or asks to fan out test fixes and merge them locally. Do not use for a single bug, test execution without findings, review-only requests, or ordinary PR shipping.
---

# Manual Test Fixes

Turn one run-through into verified, locally integrated fixes without losing provenance or hiding conflicts.
Use staged fan-out: normalize and reproduce first, delegate only independent packages, integrate serially, replay the original journey, then review the combined result.

## Establish the Baseline

1. Read the repository instructions and any long-run, testing, worktree, or shipping documentation.
2. Inspect the current branch, status, worktrees, local branches, and local-main versus remote-main divergence.
3. Preserve unrelated user changes and generated artifacts.
4. Stop if dirty or divergent state cannot be classified safely.
5. Record the baseline commit, environment, test mode, fixtures, and repository verification commands.
6. Use isolated test data and deterministic providers where possible.
7. Confirm the requested authority separately for subagents, local-main integration, and remote shipping.
8. Do not infer push, PR, or deployment authority from permission to merge locally.

## Normalize the Run-Through

1. Preserve the raw observations and evidence without rewriting their meaning.
2. Assign stable IDs such as `MT-001`.
3. Separate observed behavior, expected behavior, reproduction, evidence, impact, and suspected cause.
4. Classify each item as defect, regression, polish, product decision, test gap, duplicate, expected behavior, cannot reproduce, or intermittent.
5. Link duplicates to one canonical issue instead of silently discarding them.
6. Reproduce each actionable issue on the baseline or establish a deterministic test that exposes its mechanism.
7. Require two consistent attempts or a deterministic mechanism before fixing an intermittent issue.
8. Stop for a product decision when more than one reasonable expected behavior exists.

Read [references/issue-packets.md](references/issue-packets.md) when normalizing a long list or preparing delegated assignments.

## Build Safe Work Packages

1. Cluster issues by root cause, ownership surface, and dependency graph instead of screen order or equal issue counts.
2. Keep dependent issues, shared contracts, overlapping files, and overlapping tests under one owner.
3. Declare owned files, shared files, dependencies, conflicts, and integration order for every package.
4. Delegate implementation only when the user explicitly authorized subagents or parallel agent work.
5. Obey the repository's worktree and concurrency limits.
6. Use read-only agents for reproduction or research when implementation worktrees are at capacity.
7. Give each worker exact issue IDs, user-visible behavior, reproduction evidence, technical constraints, scope, acceptance criteria, verification commands, stop conditions, and handoff requirements.
8. Tell workers not to merge, push, broaden scope, or edit an undeclared shared surface.
9. Keep one coordinator responsible for the ledger, integration order, and closure state.

Never assign one agent per raw bullet without first checking duplication, dependencies, and ownership overlap.

## Execute and Review Each Package

1. Reproduce or explain the failure before editing.
2. Implement the smallest coherent root-cause fix.
3. Add focused regression coverage where practical.
4. Run narrow checks followed by the package-level gate.
5. Commit only the scoped package and leave its worktree clean.
6. Require a handoff containing the issue IDs, branch, worktree, commit, changed files, before-and-after evidence, exact checks, skipped coverage, and remaining risk.
7. Inspect the actual diff and handoff independently before integration.
8. Require `git diff --check`, focused verification, and a lightweight semantic review for every package.
9. Return incomplete, dirty, failed, stale, or unreviewed work for rework.

A final combined review never replaces these per-package gates.

## Integrate into Local Main

Read [references/integration-review.md](references/integration-review.md) before merging multiple packages or performing the final review.

1. Merge only when the user explicitly authorized local-main integration.
2. Keep the integration checkout on clean local `main`.
3. Review each package against the current integration head, not only its original base.
4. Merge serially in dependency order.
5. Recheck later issues after each merge because an earlier root-cause fix may resolve them.
6. Resolve conflicts by understanding both intents.
7. Stop rather than improvising through an ambiguous semantic conflict.
8. Run both packages' focused checks after resolving a conflict.
9. Run affected smoke checks after shared-core or high-risk merges.
10. Leave local `main` clean and do not push unless separately authorized.

## Replay and Perform One Holistic Review

1. Replay the original manual steps from fresh isolated state on the exact integrated head.
2. Exercise adjacent workflows affected by shared fixes.
3. Review the complete baseline-to-main diff against every finding ID.
4. Check cross-fix interactions, duplicated logic, inconsistent UX, storage and security boundaries, missing regression coverage, debug artifacts, and documentation drift.
5. Run the repository's full review or green gate without changing the reviewed head afterward.
6. Put any review-driven code change on an authorized remediation branch and worktree.
7. Apply the normal package gate and independent review to that remediation package before merging it serially.
8. Replay affected scenarios and repeat the final gate after merging remediation.
9. Escalate product tradeoffs instead of silently selecting behavior.
10. Close an issue only after its original acceptance criteria pass on integrated `main`.
11. Clean merged worktrees and branches with the repository lifecycle command when authorized.
12. Otherwise preserve them and report the exact cleanup commands.
13. Report fixed, duplicate, invalid, deferred, blocked, and unresolved items explicitly.
14. Report the final main commit, dirty state, exact verification, skipped coverage, remaining risks, and cleanup performed.

Use the repository's established review and validation skills for their existing responsibilities.
Do not automatically invoke a PR or CI shipping pipeline for a local-main-only request.

## Hard Stops

Stop integration when any of these conditions holds:

- Local and remote `main` have diverged and the repository policy does not define the resolution.
- Dirty or unrelated state cannot be preserved safely.
- Reproduction contradicts the requested behavior or exposes a product decision.
- A worker touches undeclared shared files or changes a shared contract.
- A branch is dirty, failed, capped, stale, partially committed, or independently unreviewed.
- A focused check, required smoke flow, or full review gate is red.
- A merge conflict has ambiguous product or architectural intent.
- Work risks real user data, credentials, destructive migration, or an external side effect.
- The same agent or tool failure repeats once.

Never weaken tests, overwrite unrelated work, hide deferred findings, or mark an issue fixed solely because a unit test passes.
