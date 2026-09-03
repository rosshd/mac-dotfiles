{ config, pkgs, username, homeDirectory, ... }:

let
  managedSkill = source: {
    inherit source;
    recursive = true;
    force = true;
  };
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.file.".config/fish/config.fish".source = ../fish/config.fish;
  home.file.".config/starship.toml".source = ../starship.toml;
  home.file.".tmux.conf".source = ../.tmux.conf;
  home.file.".config/wezterm/wezterm.lua".source = ../wezterm/wezterm.lua;
  home.file."Library/Application Support/Firefox/Profiles/bsa8ntkn.default-release/user.js".source =
    ../firefox/user.js;
  home.file."Library/Application Support/Firefox/Profiles/bsa8ntkn.default-release/chrome/userChrome.css".source =
    ../firefox/userChrome.css;
  home.file."Library/Application Support/Firefox/Profiles/bsa8ntkn.default-release/chrome/userContent.css".source =
    ../firefox/userContent.css;
  home.file.".config/karabiner/karabiner.json".source = ../karabiner/karabiner.json;
  home.file.".config/nvim" = {
    source = ../nvim;
    recursive = true;
    force = true;
  };
  home.file.".config/voice/vocabulary.md".source = ../voice/vocabulary.md;
  home.file.".config/gh-dash/config.yml".source = ../gh-dash/config.yml;
  home.file.".local/bin/agent".source = ../bin/agent;
  home.file.".local/bin/agent-doctor".source = ../bin/agent-doctor;
  home.file.".local/bin/clean-reboot".source = ../bin/clean-reboot;
  home.file.".local/bin/doctor".source = ../bin/doctor;
  home.file.".local/bin/notify".source = ../bin/notify;
  home.file.".local/bin/networking".source = ../bin/networking;
  home.file.".local/bin/networking-mcp".source = ../bin/networking-mcp;
  home.file.".local/bin/plan-artifact".source = ../bin/plan-artifact;
  home.file.".local/bin/rebuild-mac".source = ../bin/rebuild-mac;
  home.file.".local/bin/ship".source = ../bin/ship;
  home.file.".local/bin/spotify-popup".source = ../bin/spotify-popup;
  home.file.".local/bin/focus-app".source = ../bin/focus-app;
  home.file.".local/bin/spotify-mute".source = ../bin/spotify-mute;
  home.file.".local/bin/tmux-resurrect-clean".source = ../bin/tmux-resurrect-clean;
  home.file.".local/bin/voice-vocab".source = ../bin/voice-vocab;
  home.file.".codex/AGENTS.md".source = ../agents/AGENTS.md;
  home.file.".codex/hooks.json".source = ../agents/config/codex-hooks.json;
  home.file.".codex/skills/axi" = managedSkill ../agents/skills/axi;
  home.file.".codex/skills/babysit-prs" = managedSkill ../agents/skills/babysit-prs;
  home.file.".codex/skills/home-setups" = managedSkill ../agents/skills/home-setups;
  home.file.".codex/skills/manual-test-fixes" = managedSkill ../agents/skills/manual-test-fixes;
  home.file.".codex/skills/networking" = managedSkill ../agents/skills/networking;
  home.file.".codex/skills/repo-validation" = managedSkill ../agents/skills/repo-validation;
  home.file.".codex/skills/visual-planning-artifact" = managedSkill ../agents/skills/visual-planning-artifact;
  home.file.".claude/CLAUDE.md".source = ../agents/AGENTS.md;
  home.file.".claude/skills/axi" = managedSkill ../agents/skills/axi;
  home.file.".claude/skills/babysit-prs" = managedSkill ../agents/skills/babysit-prs;
  home.file.".claude/skills/home-setups" = managedSkill ../agents/skills/home-setups;
  home.file.".claude/skills/manual-test-fixes" = managedSkill ../agents/skills/manual-test-fixes;
  home.file.".claude/skills/networking" = managedSkill ../agents/skills/networking;
  home.file.".claude/skills/repo-validation" = managedSkill ../agents/skills/repo-validation;
  home.file.".claude/skills/visual-planning-artifact" = managedSkill ../agents/skills/visual-planning-artifact;
  home.file.".config/opencode/AGENTS.md".source = ../agents/AGENTS.md;
  home.file.".config/opencode/skills/axi" = managedSkill ../agents/skills/axi;
  home.file.".config/opencode/skills/babysit-prs" = managedSkill ../agents/skills/babysit-prs;
  home.file.".config/opencode/skills/home-setups" = managedSkill ../agents/skills/home-setups;
  home.file.".config/opencode/skills/manual-test-fixes" = managedSkill ../agents/skills/manual-test-fixes;
  home.file.".config/opencode/skills/networking" = managedSkill ../agents/skills/networking;
  home.file.".config/opencode/skills/repo-validation" = managedSkill ../agents/skills/repo-validation;
  home.file.".config/opencode/skills/visual-planning-artifact" = managedSkill ../agents/skills/visual-planning-artifact;
  home.file.".copilot/copilot-instructions.md".source = ../agents/AGENTS.md;
  home.file.".gemini/GEMINI.md".source = ../agents/AGENTS.md;
  home.file."Library/Application Support/Raycast/scripts/networking-capture.sh".source =
    ../agents/integrations/raycast/networking-capture.sh;
  home.file."Library/Application Support/Raycast/scripts/networking-calendar.sh".source =
    ../agents/integrations/raycast/networking-calendar.sh;
  home.file."agents".source =
    config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/mac-dotfiles/agents";
  home.file."STYLE.md".source = ../STYLE.md;
  home.file."VOICE.md".source = ../agents/VOICE.md;

  home.sessionPath = [
    "${homeDirectory}/.local/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
