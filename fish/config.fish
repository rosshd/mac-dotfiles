# Suppress greeting
set -U fish_greeting ''

# Keep standalone setup usable; Home Manager also declares these paths.
fish_add_path --global --move $HOME/.local/bin /opt/homebrew/bin /opt/homebrew/sbin

# Nix/Lix + nix-darwin profile
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

# pyenv
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path --global --move $PYENV_ROOT/bin $PYENV_ROOT/shims

# SSH agent
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
end

# Starship prompt
starship init fish | source

# Zoxide (smart cd)
zoxide init fish | source

# fzf key bindings (Ctrl-T files, Alt-C cd; Ctrl-R is handed to atuin below)
fzf --fish | source

# atuin (sqlite shell history; owns Ctrl-R, loaded after fzf so it wins the bind)
atuin init fish | source

# direnv (per-project env, e.g. pyenv/uv)
direnv hook fish | source

# Editor defaults
set -gx EDITOR nvim
set -gx VISUAL nvim

# Navigation
alias dev='cd ~/Developer/projects'
alias school='cd ~/School'
alias sandbox='cd ~/Developer/sandbox'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -15'
alias gd='git diff'

# General
alias ll='eza -lah --git --group-directories-first'
alias la='eza -la --git --group-directories-first'
alias cat='bat'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias py='python3'
alias vi='nvim'
alias fastfetch='command fastfetch'

# AI coding agents
alias oc='opencode'
alias cdx='codex'
alias cc='claude'

alias main='ship'
alias agents='agent'
alias a='agent'
alias cr='clean-reboot'
alias rebuild='rebuild-mac'
alias vocab='voice-vocab'
alias plan='plan-artifact'
alias people='networking'
