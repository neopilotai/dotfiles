# Integration features and utilities
# This file contains integrations, autoupdates, and feature toggles

# Configuration toggles (can be overridden in .zshrc_local)
if [ -z "$CHEERS_ENABLED" ]; then
  CHEERS_ENABLED=true
fi

if [ -z "$INSULTS_ENABLED" ]; then
  INSULTS_ENABLED=true
fi

if [ -z "$INSULTS_OFFENSIVE_ENABLED" ]; then
  INSULTS_OFFENSIVE_ENABLED=false
fi

if [ -z "$CNF_TF_ENABLED" ]; then
  CNF_TF_ENABLED=true
fi

if [ -z "$ASCII_WELCOME_ENABLED" ]; then
  ASCII_WELCOME_ENABLED=true
fi

if [ -z "$ASCII_WELCOME_SNOOZE" ]; then
  ASCII_WELCOME_SNOOZE=43200
fi

if [ -z "$AUTO_CLEAR_CACHES" ]; then
  AUTO_CLEAR_CACHES=true
fi

if [ -z "$AUTO_CLEAR_CACHES_SECONDS" ]; then
  AUTO_CLEAR_CACHES_SECONDS=7890000
fi

# Load feature modules
if $INSULTS_ENABLED; then
  source $HOME/scripts/assets/insults.zsh
fi

if $CNF_TF_ENABLED; then
  source $HOME/scripts/assets/zsh_cnf.zsh
fi

# Cache clearing functionality
if $AUTO_CLEAR_CACHES; then
  if [ -f "$HOME/.auto_clear_caches" ]; then
    if [ "$(($(date +%s) - $(cat $HOME/.auto_clear_caches)))" -lt "$AUTO_CLEAR_CACHES_SECONDS" ]; then
      AUTO_CLEAR_CACHES=false
    else
      echo $(date +%s) > $HOME/.auto_clear_caches
    fi
  else
    echo $(date +%s) > $HOME/.auto_clear_caches
  fi
fi

# Cache clearing prompts
if $AUTO_CLEAR_CACHES; then
  printf "Go installation grows over time and it's recommended to clear it periodically.\n"
  if gum confirm "Do you want to clear the go installation?"; then
    echo "Clearing go installation..."
    sudo rm -rf $HOME/go
    echo "Go installation cleared."
    echo "Sync FluxNinja repos..."
    $HOME/scripts/bin/sync_fluxninja.sh
  fi

  if gum confirm "Do you want to prune docker builder cache?"; then
    echo "Pruning docker builder cache..."
    docker builder prune -f -a
    echo "Docker builder cache pruned."
    echo "Pruning docker system..."
    docker system prune -f -a
    echo "Docker system pruned."
  fi
fi

# ASCII welcome functionality
if $ASCII_WELCOME_ENABLED; then
  if [ -f "$HOME/.ascii_welcome_last_displayed" ]; then
    if [ "$(($(date +%s) - $(cat $HOME/.ascii_welcome_last_displayed)))" -lt "$ASCII_WELCOME_SNOOZE" ]; then
      ASCII_WELCOME_ENABLED=false
    else
      echo $(date +%s) > $HOME/.ascii_welcome_last_displayed
    fi
  else
    echo $(date +%s) > $HOME/.ascii_welcome_last_displayed
  fi
fi

# Display ASCII welcome
if $ASCII_WELCOME_ENABLED; then
  fortune | cowsay -f $(find $(brew --prefix)/share/cowsay/cows/ -name "*.cow" | shuf -n 1)
  (timeout 2 WTTR_PARAMS="1" ~/scripts/bin/wttr.sh ;\
    echo; echo -e "${CYAN_BRIGHT}  ==================================  GitHub Status ================================== ${RESET}"; echo;
    timeout 2 gh status --org neopilotai) 2&>/dev/null
fi

# Cleanup
unset ASCII_WELCOME_ENABLED
unset ASCII_WELCOME_SNOOZE
unset CNF_TF_ENABLED

# Autoupdate integration
eval "$(cat $HOME/scripts/bin/autoupdate.zsh)"

# Source aliases
source $HOME/.aliases
