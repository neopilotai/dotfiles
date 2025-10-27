# Environment variables and exports
# This file contains basic environment setup

# Source .zprofile if not already sourced
if [[ -z "$ZPROFILE_SOURCED" ]]; then
  source ~/.zprofile
fi

# Color tools
export LS_COLORS="$(vivid generate gruvbox-dark)"
export BAT_THEME="gruvbox-dark"

# FZF theme
source $HOME/scripts/assets/base16-gruvbox-dark-medium.config

# Pager configuration
export LESSOPEN="|$(brew --prefix)/bin/lesspipe.sh %s"
export LESSCOLORIZER="bat --color=always"
export LESS="-R"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Editor
export EDITOR=nvim

# Terminal colors (can be overridden in .zshrc_local)
export SET_TERMINAL_COLORS=true
