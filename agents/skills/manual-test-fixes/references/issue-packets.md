# Issue Ledger and Work Packages

Load this reference when converting a large manual-test run-through into a canonical ledger or delegated work packages.

## Contents

- [Preserve Run Evidence](#preserve-run-evidence)
- [Ledger Record](#ledger-record)
- [Package Formation](#package-formation)
- [Worker Brief](#worker-brief)
- [Package Acceptance](#package-acceptance)

## Preserve Run Evidence

Prefer the repository's existing artifact convention.
Otherwise use a temporary directory or a clearly ignored path such as `.artifacts/manual-test-runs/<timestamp>-<slug>/`.
Do not add generated captures to version control unless the repository explicitly treats them as fixtures.

Keep:

```text
raw-notes.md   immutable reporter input
ledger.md      canonical issue state
evidence/      logs, screenshots, and replay output
```

Scope IDs such as `MT-001` to one run.
Turn durable behavior into tests or maintained manual-test documentation instead of relying on the ignored ledger.

## Ledger Record

Record these fields for each issue:

```markdown
## MT-001: <short user-visible summary>

- Source: <run, scenario, and step>
- Baseline: <commit and environment>
- Reporter wording: <verbatim observation or link>
- Expected: <observable behavior>
- Observed: <observable behavior>
- Reproduction: <setup, exact inputs or commands, and cleanup>
- Evidence: <artifact path or captured output>
- Classification: <defect|regression|polish|product-decision|test-gap|duplicate|expected|cannot-reproduce|intermittent>
- Severity: <impact, not implementation difficulty>
- Status: <captured|triaged|reproduced|assigned|implemented|batch-reviewed|integrated|replayed|closed|blocked|deferred|duplicate|wont-fix>
- Duplicate of: <IDs or none>
- Ownership: <subsystem, predicted files, and confidence>
- Dependencies: <IDs or none>
- Conflicts: <IDs, files, contracts, or none>
- Acceptance criteria:
  1. <original user-visible outcome>
  2. <edge or negative behavior>
  3. <compatibility, persistence, or safety behavior when relevant>
- Verification: <focused automated command and manual replay>
- Package: <name and assignee>
- Branch/worktree/commit: <integration evidence>
- Resolution: <before-and-after evidence>
- Residual risk: <remaining uncertainty>
```

Keep observations separate from hypotheses.
Only the coordinator changes `integrated`, `replayed`, or `closed` state.

## Package Formation

Group issues together when they share any of:

- One likely root cause.
- The same central implementation or test files.
- A storage, schema, provider, prompt, routing, or configuration contract.
- A prerequisite or consumer relationship.
- One manual journey that cannot be verified independently.

Run packages separately only when their outcomes, ownership surfaces, contracts, tests, and verification are independent.
Build an overlap matrix from predicted files before dispatch and actual files before integration.
Land shared foundations first, then rebase or recreate dependent work from the new integration head.

## Worker Brief

Use this shape:

```text
Implement only: <one coherent package outcome>.
Issue ledger: <path and run ID>.
Assigned IDs: <IDs>.

User-visible failure:
<observed behavior>

Expected behavior:
<unambiguous outcome>

Baseline and reproduction:
Start from <commit>.
Use <isolated state, fixtures, provider mode, terminal or browser conditions>.
Run <exact steps>.
Observe <evidence>.
Reproduce or explain the failure before editing.
Create or use the assigned non-main branch and isolated worktree before editing.
Never implement or commit a package directly on main.

Scope:
Owned behavior and files: <paths or subsystem>.
Shared files: <paths requiring coordinator approval>.
Dependencies: <IDs or commits>.
Conflicts with: <packages, files, or contracts>.

Technical constraints:
- Preserve <repository invariants>.
- Do not use real user data, credentials, or external side effects.
- Do not change an undeclared interface, schema, prompt policy, dependency, or owned surface.
- Stop and report if the fix requires work outside this contract.

Acceptance criteria:
1. <original reproduction now produces the expected result>.
2. <edge or negative path remains correct>.
3. <compatibility, persistence, or safety rule>.
4. <focused regression coverage where practical>.

Verification:
- Run <focused command>.
- Run <package gate or smoke flow>.
- Run git diff --check.

Out of scope:
Unrelated refactors, opportunistic nearby fixes, dependency churn, merge, push, PR, deployment, and unnamed QA modes.
Return new observations to the coordinator instead of fixing them.

Stop when:
All acceptance criteria hold and named verification passes, or the first repeated agent/tool failure occurs.
Stop immediately for ambiguity, ownership overlap, shared-contract changes, destructive-data risk, or an invalid reproduction assumption.

Commit:
Create one scoped, value-focused commit without an agent co-author.

Handoff:
Report issue disposition, branch and worktree, commit hash and message, dirty files, changed files, reproduction before and after, exact commands and results, skipped coverage, failures or retries, residual risk, and the exact next review command.
```

## Package Acceptance

Accept a package for independent review only when:

- The user-visible failure was reproduced or its mechanism was deterministically proven.
- Every acceptance criterion has evidence.
- The regression test or manual replay targets the original symptom.
- The diff stays within declared ownership and contains no unrelated cleanup.
- Focused and package-level checks pass.
- The repository-required package gate passes.
- The commit exists and the worktree is clean.
- Uncertainty and skipped coverage are explicit.

Do not accept speculative patches for intermittent behavior.
Do not accept a passing test as proof when it does not exercise the original journey.
