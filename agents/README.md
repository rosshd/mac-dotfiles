# Agent Workspace

This directory is the editable source for Ross's global agent configuration.
It is exposed at `~/agents` and linked into each supported agent's discovery paths.

## Structure

- `AGENTS.md` contains concise instructions shared by every agent.
- `VOICE.md` describes Ross's writing voice.
- `config/` contains tool-specific integration configuration.
- `domains/` contains reusable policies for non-code workspaces.
- `integrations/` contains thin entry points for desktop tools.
- `prompts/routines/` contains scheduled and recurring prompts.
- `prompts/templates/` contains issue and planning prompts created on demand.
- `projects/` indexes project-specific agent context without removing it from its repository.
- `skills/` contains reusable, conditionally loaded workflows.

## Placement Rule

Put guidance here when it applies across repositories or tools.
Keep project-specific facts and constraints in the closest project `AGENTS.md`.
Keep private data outside this public repository.
Tool-specific discovery files should link here instead of becoming independent copies.

## Editing

Edit files through `~/agents` or `~/mac-dotfiles/agents`.
They resolve to the same version-controlled source.
Run `doctor` after changing discovery links or integrations.
Run `agent-doctor` for agent discovery, skill drift, networking, MCP, and repository health.
