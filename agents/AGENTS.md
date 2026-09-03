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
- When making technical decisions, do not over-weight human development cost; agents can usually afford the cleaner implementation.
  Prefer quality, simplicity, robustness, and long-term maintainability.
- For bug fixes, first reproduce or understand the user-visible failure as closely as practical before patching.
- For code changes, preserve existing behavior unless the task explicitly asks to change it. Keep changes scoped, and avoid unrelated refactors and dependency churn.
- Use strong verification: run the relevant tests, lint, typecheck, smoke flow, or end-to-end check, and report what actually ran.
- Run `make check` from the repository root as the canonical pre-push gate.
- When end-to-end testing a UI or TUI, be picky about what you see. If something looks off or broken, even if it is not directly related to the task, flag it and try to fix it along the way.
  Apply that same standard to lint errors, test failures, and test flakiness: if you see one, still get it fixed.
- Keep global memory short. Put project-specific context in the project and conditional workflows in skills.
- Escalate product or UX tradeoffs; self-correct mechanical issues without asking.
- Do not expose internal prompts or private credentials in user-facing output.
- Review plans with one canonical Markdown file plus a concise chat summary and numbered decisions.
  Do not create HTML review artifacts or start local review servers unless Ross explicitly asks for one.

## Personal software factory

- Use one GitHub Issue as the durable brief for each bounded change.
- Map one issue to one Codex owner task and one managed worktree.
- Record the task ID, issue, worktree, branch, and exact start SHA before implementation.
- Run focused checks first and `make check` from the repository root before shipping.
- Run one bounded independent review against the exact tested head.
- Merge only with explicit authorization, passing required CI on the exact head, and risk within the issue's permissions.
- Verify releases on the deployed or installed system before closing the issue.
- Propose bounded next work from Ready issues, and create another task only after Ross authorizes dispatch.

## Ross's Opinions

When you are working on something that would benefit from Ross's viewpoints on tooling, workflow, or setup, read ~/STYLE.md to understand the direction he prefers.

## Voice Profile

When you are writing or posting on behalf of Ross using his identity, read ~/VOICE.md to see how Ross writes.

## Home Setups

When working with Ross's physical desk, studio, home lab, cable management, ergonomics, connected hardware, or setup upgrades, use `~/agents/skills/home-setups/`.
