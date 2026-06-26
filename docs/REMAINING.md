# Remaining Work

## Done

- Health check script (`bin/doctor`): verifies binaries, Fish/tmux/Neovim/WezTerm
  configs, tool versions, and warns on legacy background processes.
- Installed the external orchestration stack and wired it into `setup.sh`:
  `treehouse`, `no-mistakes` (real installer command), `gnhf`, `firstmate`,
  `lavish-axi`, `opensuperwhisper`. See [Tools](TOOLS.md) for what each replaces.
- Made the repo the single source of truth: all configs and agent files are
  symlinked into place. `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md` point at
  the same `agents/AGENTS.md`.
- Shell efficiency: fzf keybindings, atuin history, direnv, and tmux session
  persistence (tpm + resurrect + continuum).
- Committed the legacy-to-terminal-first migration and pushed the branch.

## Manual steps (need your password / one-time)

- Set fish as the login shell:
  `echo "$(command -v fish)" | sudo tee -a /etc/shells && chsh -s "$(command -v fish)"`
- Import existing shell history into atuin: `atuin import auto`

## Medium Priority

1. Add project templates for common agent workflows.

   Useful templates:

   - new repo setup
   - review pass
   - validation pass
   - worktree branch setup

## Low Priority

2. Decide whether Aerial should remain a Login Item.

3. Decide whether VS Code needs any dotfiles at all or stays outside this workflow.
