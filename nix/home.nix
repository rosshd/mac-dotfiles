{ config, pkgs, username, homeDirectory, ... }:

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
  home.file.".config/herdr/config.toml".source = ../herdr/config.toml;
  home.file.".no-mistakes/config.yaml".source = ../no-mistakes/config.yaml;
  home.file.".local/bin/agent".source = ../bin/agent;
  home.file.".local/bin/captain" = {
    source = ../bin/captain;
    force = true;
  };
  home.file.".local/bin/clean-reboot".source = ../bin/clean-reboot;
  home.file.".local/bin/crew".source = ../bin/crew;
  home.file.".local/bin/doctor".source = ../bin/doctor;
  home.file.".local/bin/firstmate".source = ../bin/firstmate;
  home.file.".local/bin/fleet" = {
    source = ../bin/fleet;
    force = true;
  };
  home.file.".local/bin/notify".source = ../bin/notify;
  home.file.".local/bin/plan-artifact".source = ../bin/plan-artifact;
  home.file.".local/bin/rebuild-mac".source = ../bin/rebuild-mac;
  home.file.".local/bin/ship".source = ../bin/ship;
  home.file.".local/bin/tmux-resurrect-clean".source = ../bin/tmux-resurrect-clean;
  home.file.".local/bin/voice-vocab".source = ../bin/voice-vocab;
  home.file.".local/bin/wt".source = ../bin/wt;
  home.file.".codex/AGENTS.md".source = ../agents/AGENTS.md;
  home.file.".codex/hooks.json".source = ../agents/config/codex-hooks.json;
  home.file.".codex/skills" = {
    source = ../agents/skills;
    recursive = true;
    force = true;
  };
  home.file.".claude/CLAUDE.md".source = ../agents/AGENTS.md;
  home.file.".claude/skills" = {
    source = ../agents/skills;
    recursive = true;
    force = true;
  };
  home.file.".config/opencode/AGENTS.md".source = ../agents/AGENTS.md;
  home.file.".config/opencode/skills" = {
    source = ../agents/skills;
    recursive = true;
    force = true;
  };
  home.file.".copilot/copilot-instructions.md".source = ../agents/AGENTS.md;
  home.file.".gemini/GEMINI.md".source = ../agents/AGENTS.md;
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
