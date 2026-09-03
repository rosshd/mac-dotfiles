# Remaining work

## Complete in source

- GitHub Issues define the durable factory work contract.
- One Codex owner task and one managed worktree own each implementation.
- Repository gates, one bounded independent review, exact-head CI, and risk-gated merge control shipping.
- Workflow Core provides the shared planning, implementation, review, shipping, bootstrap, and dispatch skills.
- WezTerm, tmux, Neovim, direct agent CLIs, `gh dash`, notifications, and phone access remain available.
- The rebuild source excludes the superseded orchestration packages, links, hooks, aliases, keybindings, configs, and helper entry points.
- Existing installed state and rollback artifacts remain preserved until a later authorized cleanup.

## Post-merge verification

The source pull request does not apply workstation configuration.
After merge, the release owner must record:

1. The merged commit and merge timestamp.
2. `rebuild-mac check` before any live apply.
3. An explicitly authorized installed-state cutover.
4. Exact managed links and Codex hooks.
5. `codex plugin list`, `doctor`, and a fresh Codex discovery check.
6. `gh dash`, direct dispatch, generic notification, terminal, and phone smoke tests.
7. The start of the 14-day stability window.

## Manual steps

- Set Fish as the login shell when needed.
- Import existing shell history with `atuin import auto`.
- Review Login Items and keep only required quiet helpers.
- Decide whether VS Code needs repository-owned configuration.

Secrets, SSH keys, API keys, private notification topics, and tool sign-ins remain manual.
