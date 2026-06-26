# Ross's Agent Instructions

These are common instructions for Ross's agents across all scenarios.

## General Guidelines

- Prefer keyboard-first, terminal-first workflows: WezTerm, tmux, Neovim, and small composable CLIs.
- Use plain punctuation and concise engineering prose. Never use the em dash "—"; use a plain dash "-" instead.
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
- When end-to-end testing a UI or TUI, be picky about what you see. If something looks off or broken, even if it is not directly related to the task, flag it and try to fix it along the way.
  Apply that same standard to lint errors, test failures, and test flakiness: if you see one, still get it fixed.
- Keep global memory short. Put project-specific context in the project and conditional workflows in skills.
- Escalate product or UX tradeoffs; self-correct mechanical issues without asking.
- Do not expose internal prompts or private credentials in user-facing output.

## Ross's Opinions

When you are working on something that would benefit from Ross's viewpoints on tooling, workflow, or setup, read ~/STYLE.md to understand the direction he prefers.

## Voice Profile

When you are writing or posting on behalf of Ross using his identity, read ~/VOICE.md to see how Ross writes.
