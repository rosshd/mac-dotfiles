---
name: factory-bootstrap
description: Bring a new or existing repository to Ross's minimum personal software factory contract. Use when asked to bootstrap, adopt, or audit a repository for agent-ready work; do not install project-specific orchestration.
---

# Factory bootstrap

Create the smallest repository-owned workflow that can plan, implement, validate, review, ship, and verify work without a separate orchestration service.

Read [`factory-contract.md`](../../references/factory-contract.md) before changing the repository.

## Workflow

1. Inspect repository instructions, status, toolchain, local checks, CI, issue and pull-request templates, default-branch policy, deployment path, and rollback documentation.
2. Classify each factory-contract item as present, incomplete, missing, or not applicable.
3. Preserve the repository's language and package choices.
   Add only the missing contract pieces and avoid project-specific agent runners, queue databases, background services, or duplicate planning systems.
4. Establish one canonical local gate that covers the checks required before push.
   Make CI invoke the same gate or prove command-level parity when the CI environment needs a thin wrapper.
5. Add the factory issue form, minimal labels, pull-request template, concise agent instructions, deployment verification, and rollback guidance when applicable.
6. Create durable context only when stable vocabulary or hard-to-reverse decisions justify it under [`durable-context.md`](../../references/durable-context.md).
7. Run the local gate and validate every added configuration file.
8. Report the contract matrix, exact changes, commands run, external settings still pending, and rollback path.

Prepare GitHub label and branch-protection changes for review and apply them only when the user explicitly authorizes those external mutations.

Treat secrets, purchases, destructive cleanup, production deployment, and permission expansion as separate authorization boundaries.

Do not weaken an existing repository gate or protection rule to make the audit pass.

The repository remains the source of truth.
Do not create `.artifacts/fleet`, a project-specific dispatcher, or a duplicate task brief.
