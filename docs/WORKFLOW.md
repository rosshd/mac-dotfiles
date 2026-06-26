# Terminal-Centric Agent Workflow

This workflow is designed around one principle: stay on the keyboard, keep the Mac layer boring, and put the real workspace inside the terminal.

## Daily Startup

1. Open WezTerm.
2. WezTerm runs Fish, which runs `ship`.
3. `ship` attaches to the persistent tmux session named `main`.
4. The first launch creates four tmux windows:
   - `code`
   - `agent`
   - `test`
   - `notes`

You can also run:

```bash
ship
main
```

`main` is a Fish alias for `ship`.

## Core Loop

1. Use `nvim` for editing.
2. Use tmux panes for agents and test output.
3. Use `agent codex`, `agent claude`, or `agent opencode` for one-off agent sessions.
4. Use `treehouse` (or the simpler local `wt`) for isolated Git worktrees.
5. Use `firstmate` (or the local `crew`) for an orchestration flow.
6. Use `no-mistakes` for validated change passes; `make validate` still works in repos with a validation lane.
7. Use `gnhf` for long-running bounded agent loops.
8. Use `lavish-axi <html>` (or the local `plan-artifact`) for reviewable planning artifacts.
9. Run `doctor` to confirm the toolchain is healthy.

## Workspace Shape

The terminal is the main workspace:

- WezTerm is only the terminal host.
- tmux is the real desktop.
- Neovim is the editor.
- Git, tests, agents, and notes run in tmux windows or panes.
- macOS Mission Control and Rectangle are fallback window tools, not the primary workflow.

## Agent Model

Agents are crewmates, but the workflow stays agent-agnostic.

Use:

```bash
agent codex
agent claude
agent opencode
```

Aliases:

```bash
cdx   # codex
cc    # claude
oc    # opencode
a     # agent
```

## Worktrees

Use native Git worktrees through the `wt` helper.

```bash
wt new my-task
wt list
wt done /path/to/worktree
wt prune
```

Worktrees live under:

```bash
~/Developer/worktrees/<repo>/<slug>
```

This gives each agent or experiment its own filesystem checkout without adopting heavier orchestration too early.

## Crew Helper

`crew` is a local first-mate-lite helper.

```bash
crew start fix-login codex "Fix the flaky login test and run validation"
crew status
crew done /path/to/worktree
crew brief overnight-audit "Find one user-visible issue and stop with evidence"
```

It creates worktrees, opens tmux windows, and writes bounded task briefs. It is intentionally simpler than Firstmate/GNHF/Treehouse.

## Planning Artifacts

For complex planning, generate a local HTML artifact:

```bash
plan-artifact achievement-system
plan achievement-system
```

Artifacts go under `.artifacts/` and should be ignored by project Git.

Use these for:

- product options
- architecture choices
- UI planning
- multi-phase implementation maps
- decision matrices

## Voice Input

Use `voice-vocab` to print the vocabulary prompt for dictation tools:

```bash
voice-vocab
vocab
```

Paste this into transcription tools that support custom vocabulary or initial prompts.

## Validation

For `openlearn`, use:

```bash
make unit
make pytest
make validate
make smoke
```

General rule: agents should report exact commands, results, evidence, and remaining risk.
