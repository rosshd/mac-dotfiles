---
name: ce-debug
description: Diagnose one bug, regression, failing test, or unexplained behavior through reproduction and root-cause evidence. Apply a fix only when the user asks to fix it; use manual-test-fixes for a batch of QA findings.
---

# Debug

Reproduce or closely understand the user-visible failure before changing code.

## Workflow

1. Read repository instructions and capture the exact symptom, environment, and expected behavior.
2. Reproduce the failure or establish a deterministic mechanism that explains it.
3. Trace the causal chain to the root cause, distinguishing evidence from hypotheses.
4. Explain the root cause with precise file and line references when the request is diagnosis-only.
5. When a fix is authorized, choose the smallest coherent correction and add focused regression coverage where practical.
6. Run the failing check red before the fix when feasible, then verify it green and run proportionate adjacent checks.
7. Report the cause, change, evidence, and residual risk.

Do not treat a diagnosis request as permission to edit files.

Do not commit, push, open a PR, or monitor it unless the user explicitly requests that action.

Work solo unless the user explicitly requests delegation.
