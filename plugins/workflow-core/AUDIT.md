# Workflow Core audit index

This plugin is the manually auditable replacement for the broad Compound Engineering plugin.

Each active workflow has one short `SKILL.md` entrypoint.

Supporting references are loaded only when the selected task needs them.

## Global behavior

- `unslop` keeps the upstream `Must always apply` trigger and runs as the final check over authored user-facing prose.
- The user's request, repository instructions, required formats, exact quotations, and technical accuracy take precedence over style transformations.
- Ordinary implementation ends after local verification unless the user explicitly requests a commit, push, PR, deployment, or monitoring.
- Shipping requires repository-owned validation and one visible, bounded independent review at the exact commit being pushed.
- Subagents, outside models, and parallel delegation require an explicit request.
- Markdown is the default durable planning format.
- Substantial repository-backed discovery can preserve exact vocabulary in `CONTEXT.md` and hard-to-reverse decisions in ADRs.
- Plans that exceed one focused task use dependency-aware vertical work items, one fresh task per item.
- Code review keeps engineering quality and spec fidelity as separate judgments.
- GitHub issues remain the durable task briefs, and dispatch proposes at most two independent Ready issues before asking for task-creation authorization.
- Dispatched owner tasks send one terminal handback to the dispatcher; bounded dispatcher waiting is the fallback when cross-task messaging is unavailable.

## Skills

| Skill | Invocation | Source lineage | Local resolution |
|---|---|---|---|
| `unslop` | Always implicit | PStack | Preserves the broad trigger but exempts exact and machine-readable content. |
| `writing-for-agents` | Implicit for agent documentation | Matt Pocock | Official Codex mechanics and concise positive pointers take precedence. |
| `typescript-best-practices` | Implicit for substantive TypeScript work | PStack | Self-contained and subordinate to repository conventions. |
| `blast-radius` | Explicit only | PStack | Removes missing skill dependencies and respects read-only scope. |
| `security-best-practices` | Explicit only | OpenAI | Preserves upstream framework references and narrows activation. |
| `ce-brainstorm` | Implicit for vague product work | Compound Engineering lineage | Requirements plus selective durable vocabulary and decision records, with no automatic delegation. |
| `ce-plan` | Implicit for genuinely multi-step planning | Compound Engineering lineage | One Markdown plan, split into fresh-task vertical work items only when needed. |
| `ce-work` | Implicit for concrete implementation | Compound Engineering lineage | One selected work item through local verification unless shipping is requested. |
| `ce-debug` | Implicit for one bug or failure | Compound Engineering lineage | Diagnosis does not authorize a fix. |
| `ce-simplify-code` | Implicit when simplification is requested | Compound Engineering lineage | One integrated pass by default. |
| `ce-code-review` | Implicit when review is requested | Compound Engineering lineage | Separate engineering-quality and spec-fidelity findings, report-only and single-agent by default. |
| `ce-commit` | Implicit for commit requests | Compound Engineering lineage | Local commits only with named files. |
| `ce-commit-push-pr` | Implicit for shipping or PR requests | Compound Engineering lineage | Requires current-head validation and bounded visible review, with no automatic babysitting. |
| `ce-resolve-pr-feedback` | Implicit for existing PR feedback | Compound Engineering lineage | Fixes only accepted feedback and never merges. |
| `ce-babysit-pr` | Implicit for ongoing PR monitoring | Compound Engineering lineage | Plain status labels and no merge authority. |
| `ce-pov` | Implicit for adoption verdicts | Compound Engineering lineage | Solo, grounded recommendation unless an oracle is requested. |
| `factory-bootstrap` | Implicit for repository adoption | Local | Adds only the minimum repository-owned factory contract. |
| `factory-dispatch` | Implicit for Ready-work selection | Local | Proposes at most two issues, creates authorized owner tasks, and requires worker-driven handback. |

## Trigger ownership

| Request | Owner |
|---|---|
| Vague idea | `ce-brainstorm` |
| Multi-step plan | `ce-plan` |
| Clear implementation | `ce-work` |
| Single bug | `ce-debug` |
| Batch manual QA findings | Existing `manual-test-fixes` skill |
| Simplification | `ce-simplify-code` |
| Defect review | `ce-code-review` |
| Cross-boundary risk proof | `blast-radius` |
| Security review | `security-best-practices` |
| Local validation evidence | Existing `repo-validation` skill |
| Commit | `ce-commit` |
| Validated push or PR | `ce-commit-push-pr` |
| PR feedback | `ce-resolve-pr-feedback` |
| PR monitoring | `ce-babysit-pr` |
| Repository bootstrap or adoption | `factory-bootstrap` |
| Propose or dispatch Ready work | `factory-dispatch` |

## Upstream sources

- PStack skills: <https://github.com/cursor/plugins/tree/main/pstack/skills>
- Matt Pocock skills: <https://github.com/mattpocock/skills>
- OpenAI skills: <https://github.com/openai/skills>
- Compound Engineering: <https://github.com/EveryInc/compound-engineering-plugin>

## Files to inspect

Start with `.codex-plugin/plugin.json`, then read the table above and open `skills/<name>/SKILL.md`.

Invocation policy is recorded in `skills/<name>/agents/openai.yaml` when it differs from normal implicit selection.

The OpenAI security references remain under `skills/security-best-practices/references/` and the TypeScript examples remain under `skills/typescript-best-practices/references/`.
