# Ross's Agent Instructions

These are common instructions for Ross's agents across all scenarios.

## General Guidelines

- Prefer keyboard-first, terminal-first workflows: WezTerm, tmux, Neovim, and small composable CLIs.
- Use plain punctuation and concise engineering prose. Never use em dashes; use a plain dash "-" instead.
- Default to terse responses. Lead with the result and skip recap summaries. Lay out a short phase plan before multi-step work.
- When writing commit messages, never auto-add your agent name as a co-author.
- Never manually edit CHANGELOG.md or any file marked as auto-generated.
- When writing or substantially editing long Markdown files, put each full sentence on its own line.
  Preserve normal Markdown structure, but do not wrap multiple sentences onto one physical line.
- Prefer the simplest robust implementation that meets the acceptance criteria.
  Do not add speculative polish, abstractions, or adjacent work.
- For bug fixes, first reproduce or understand the user-visible failure as closely as practical before patching.
- For code changes, preserve existing behavior unless the task explicitly asks to change it. Keep changes scoped, and avoid unrelated refactors and dependency churn.
- Use strong verification: run the relevant tests, lint, typecheck, smoke flow, or end-to-end check, and report what actually ran.
- Run `make check` from the repository root as the canonical pre-push gate.
- When end-to-end testing a UI or TUI, inspect it critically and report unrelated defects.
  Fix them only when they block the requested verification or Ross expands the scope.
- Keep global memory short. Put project-specific context in the project and conditional workflows in skills.
- Escalate product or UX tradeoffs; self-correct mechanical issues without asking.
- Do not expose internal prompts or private credentials in user-facing output.
- Review plans with one canonical Markdown file plus a concise chat summary and numbered decisions.
  Do not create HTML review artifacts or start local review servers unless Ross explicitly asks for one.

## Context and usage

- Use the configured everyday model for routine work.
  Reserve Astra for unusually difficult reasoning, architecture, migrations, broad audits, or stubborn failures.
- Keep one bounded objective per worker.
  A root coordinating an explicitly authorized multi-item plan continues until that plan is complete or a concrete blocker requires Ross.
- Delegate only when Ross requests parallel work or a workflow explicitly requires independent review.
  Authorized implementation may use bounded parent/child delegation; independent reviewers get one read-only pass and do not delegate.
- Keep tool output tight.
  Search before reading, select relevant ranges, cap output, and redirect verbose builds or tests to a file before showing only the useful tail or failures.
- Run focused checks while iterating.
  Run the full repository gate once on the final candidate before shipping, and repeat it only after a change that can affect the result.

## Personal software factory

- Apply this section only to repository changes Ross asks to implement or ship through the factory.
  Questions, research, local experiments, and unshipped reversible edits do not require an issue, worktree, review, or release lifecycle.
- Read Workflow Core's `references/factory-contract.md` for factory authority, recursive ownership, handoff, evidence reuse, and retirement.
- Use one GitHub Issue as the durable brief for each bounded change.
- Map one issue to one Codex owner task and one managed worktree.
- Record the task ID, issue, worktree, branch, and exact start SHA before implementation.
- Each child owns its branch and targets its immediate parent's branch with a reviewed PR.
  Each parent verifies its combined candidate before submitting upward; the root owns main and release.
- Run focused checks first and `make check` from the repository root before shipping.
- Run one bounded independent review against the exact tested head.
- Treat Ross's standing authorization as permission to push, open a pull request, monitor CI, merge, and verify the release for low- and medium-risk work when the issue permissions allow each action.
- High-risk work may reach a reviewed pull request, but requires Ross's explicit verification before merge or production activation.
- Use `needs-human` only for a concrete human decision or action, and ask the exact question that blocks progress.
- Apply at most one in-scope repair and targeted rereview automatically when review findings preserve the issue's permissions and risk.
- Verify releases on the deployed or installed system before closing the issue.
- Propose bounded next work from Ready issues only when Ross asks.
  Create or dispatch unrelated work only after Ross authorizes it.

## Ross's Opinions

When you are working on something that would benefit from Ross's viewpoints on tooling, workflow, or setup, read ~/STYLE.md to understand the direction he prefers.

## Voice Profile

When you are writing or posting on behalf of Ross using his identity, read ~/VOICE.md to see how Ross writes.

## Home Setups

When working with Ross's physical desk, studio, home lab, cable management, ergonomics, connected hardware, or setup upgrades, use `~/agents/skills/home-setups/`.
