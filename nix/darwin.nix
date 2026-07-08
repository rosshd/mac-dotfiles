{ pkgs, username, homeDirectory, ... }:

{
  nix.package = pkgs.lix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.${username}.home = homeDirectory;
  system.primaryUser = username;

  programs.fish.enable = true;

  environment.shells = [ pkgs.fish ];

  environment.systemPackages = with pkgs; [
    atuin
    bat
    delta
    direnv
    eza
    fastfetch
    fd
    fish
    fzf
    gh
    git
    go
    jq
    lazygit
    lua-language-server
    neovim
    nodejs
    pyright
    ripgrep
    ruff
    starship
    stylua
    tmux
    tree
    uv
    wget
    zoxide
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "none";

    taps = [
      "anomalyco/tap"
    ];

    brews = [
      "herdr"
      "opencode"
      "terminal-notifier"
    ];

    casks = [
      "claude-code"
      "codex"
      "font-jetbrains-mono-nerd-font"
      "karabiner-elements"
      "opensuperwhisper"
      "raycast"
      "rectangle"
      "tailscale-app"
      "wezterm"
    ];
  };

  system.defaults = {
    dock = {
      expose-group-apps = true;
      mru-spaces = true;
    };

    screencapture.location = "${homeDirectory}/Pictures/Screenshots";
  };

  system.stateVersion = 5;
}
