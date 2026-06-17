
# Suppress greeting
set -U fish_greeting ''

# Homebrew + local bin (local first so wrappers take priority)
fish_add_path ~/.local/bin /opt/homebrew/bin /opt/homebrew/sbin

# pyenv
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
pyenv init - | source

# SSH agent
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
end

# Starship prompt
starship init fish | source

# Show startup animation once per tmux session, only in a roomy first pane.
if status is-interactive; and set -q TMUX
    set -l shown (tmux show-option -gqv @startup_animation_done)
    set -l panes (tmux display-message -p "#{window_panes}" 2>/dev/null)
    set -l cols (tput cols 2>/dev/null)
    set -l rows (tput lines 2>/dev/null)

    if test "$shown" != "1"; and test "$panes" = "1"; and test "$cols" -ge 88; and test "$rows" -ge 24
        tmux set-option -gq @startup_animation_done 1
        command python3 ~/.config/fish/launch.py
        clear
    end
end

# Aliases — navigation
alias dev='cd ~/Developer/projects'
alias school='cd ~/School'
alias sandbox='cd ~/Developer/sandbox'

# Aliases — git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -15'
alias gd='git diff'

# Aliases — general
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Aliases — tools
alias fastfetch='python3 ~/.config/fish/launch.py --no-timeout'
alias py='python3'
alias vi='nvim'
alias matrix='cmatrix -a -C cyan'
alias pipes='pipes.sh -t 0'
alias spaceship='python3 ~/.config/fish/spaceship.py'

# iTerm2 shell integration
source ~/.config/fish/iterm2_shell_integration.fish
