# Workflow Core installation

This directory is the canonical Workflow Core source.

The personal marketplace entry at `~/.agents/plugins/marketplace.json` points to `./mac-dotfiles/plugins/workflow-core`, resolved from the home directory.

After changing the plugin, update its cachebuster with the Codex plugin-creator helper, validate this source, and run `codex plugin add workflow-core@personal`.

Treat the installed copy under `~/.codex/plugins/cache/personal/workflow-core/` as generated state.

Compare the source and installed file manifests after every reinstall.
