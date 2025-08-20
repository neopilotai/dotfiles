export LS_COLORS="$(vivid generate gruvbox-dark)"

export BAT_THEME="gruvbox-dark"

# FZF theme -- See https://github.com/fnune/base16-fzf
source $HOME/assets/base16-gruvbox-dark-medium.config

export LESSOPEN="|$(brew --prefix)/bin/lesspipe.sh %s"
export LESSCOLORIZER="bat --color=always"
export LESS="-R"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export EDITOR=nvim
export SET_TERMINAL_COLORS=true

if [[ -z "$START_TMUX" ]]; then
  export START_TMUX=true
fi

# Set LANGTOOL env to empty values
export LANGTOOL_USERNAME=""
export LANGTOOL_API_KEY=""
export LANGTOOL_HTTP_URI=""

# FluxNinja Aperture Tilt Env Vars
export TILT_APERTURE_SSH_KEY_PUB=$HOME/.ssh/id_ed25519.pub
export TILT_GRAFANA_REPO=$HOME/Work/fluxninja/grafana

if [[ $OSTYPE == 'linux'* ]]; then
  export QT_QPA_FONTDIR=~/.local/share/fonts
fi
