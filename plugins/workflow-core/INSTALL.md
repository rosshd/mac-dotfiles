# Workflow Core installation

This directory is the canonical Workflow Core source.

The personal marketplace entry at `~/.agents/plugins/marketplace.json` points to `./mac-dotfiles/plugins/workflow-core`, resolved from the home directory.

After changing the plugin, update its source manifest cachebuster with the Codex plugin-creator helper when available, validate this source, and run `codex plugin add workflow-core@personal`.
When that helper is absent, change only the source manifest version using the existing semantic-version-plus-Codex-timestamp scheme.
Never edit an installed cache.

Treat the installed copy under `~/.codex/plugins/cache/personal/workflow-core/` as generated state.

Compare the source and installed file manifests after every reinstall.
An active chat may retain its already-loaded skill text; verify discovery in a new chat before treating the updated instructions as active there.
