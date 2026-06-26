# Remaining Work

## Done

- Health check script (`bin/doctor`): verifies binaries, Fish/tmux/Neovim/WezTerm
  configs, tool versions, and warns on legacy background processes.
- Installed the external orchestration stack and wired it into `setup.sh`:
  `treehouse`, `no-mistakes`, `gnhf`, `firstmate`, `lavish-axi`. See
  [Tools](TOOLS.md) for what each replaces.

## High Priority

1. Review existing dirty dotfiles changes before committing.

   The repo had pre-existing changes before this cleanup, especially in:

   - `karabiner/karabiner.json`
   - deleted legacy files from the previous workflow

## Medium Priority

2. Add project templates for common agent workflows.

   Useful templates:

   - new repo setup
   - review pass
   - validation pass
   - worktree branch setup

## Low Priority

3. Decide whether Aerial should remain a Login Item.

4. Decide whether VS Code needs any dotfiles at all or stays outside this workflow.
