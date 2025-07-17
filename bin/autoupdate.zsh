#!/usr/bin/env zsh

# Check whether the script is being sourced or executed
[[ $0 =~ "autoupdate.zsh" ]] && sourced=0 || sourced=1

# Configuration
SYSTEM_UPDATE_DAYS=${SYSTEM_UPDATE_DAYS:-7}
SYSTEM_RECEIPT_F=${SYSTEM_RECEIPT_F:-$HOME/local/system_lastupdate}
day_seconds=86400
system_seconds=$((day_seconds * SYSTEM_UPDATE_DAYS))
tp='success'
declare -a update_errors

# Utilities
function update_error() {
  local error_cmd=$1
  local error_code=$2
  if [ $error_code -ne 0 ]; then
    update_errors+=("$error_cmd: $error_code")
  fi
}

function show_errors() {
  if [ ${#update_errors[@]} -ne 0 ]; then
    tp='error'
    echo "Errors occurred during update:"
    for error in "${update_errors[@]}"; do
      echo "  $error"
    done
  fi

  if [ $sourced -eq 1 ]; then
    term-notify $tp $interval <<<"autoupdate.zsh"
  else
    [[ $tp == 'success' ]] && exit 0 || exit 1
  fi
}

function check_interval() {
  local now=$(date +%s)
  local last_update=0
  [[ -f $1 ]] && last_update=$(<$1)
  echo $((now - last_update))
}

function revolver_start() {
  if command -v revolver >/dev/null 2>&1; then
    tput civis
    revolver --style dots2 "echo $1" &
    REVOLVER_PID=$!
  fi
}

function revolver_update() {
  if command -v revolver >/dev/null 2>&1; then
    revolver --style dots2 "echo $1" &
    REVOLVER_PID=$!
  fi
}

function revolver_stop() {
  if [ -n "$REVOLVER_PID" ]; then
    kill "$REVOLVER_PID" 2>/dev/null
  fi
  tput cnorm
}

# Handle force update
force_update=0
[[ $1 == "--force" ]] && force_update=1

# Main logic
last_system=$(check_interval $SYSTEM_RECEIPT_F)
if [ $last_system -gt $system_seconds ] || [ $force_update -eq 1 ]; then
  start_time=$(date +%s)
  date +%s > $SYSTEM_RECEIPT_F
  echo "It has been $((last_system / day_seconds)) days since system was updated"
  echo "Updating system... Please open a new terminal to continue your work in parallel..."

  revolver_start "Pulling latest dotfiles..."
  cd ~ && chezmoi --force update -v
  update_error dotfiles $?

  revolver_stop

  revolver_update "Running personal autoupdates..."
  [[ -f $HOME/local/autoupdate_local.zsh ]] && eval "$(<$HOME/local/autoupdate_local.zsh)"
  update_error local_autoupdate $?
  revolver_stop

  $HOME/bin/sync_brews.sh
  update_error sync_brews $?

  revolver_update "Updating zinit..."
  source $HOME/.local/share/zinit/zinit.git/zinit.zsh && \
    zinit self-update && \
    zinit update --quiet --parallel 8 && \
    zinit cclear
  update_error zinit $?
  revolver_stop

  revolver_update "Updating nvim..."
  nvim +PlugUpgrade +PlugClean! +PlugUpdate +PlugInstall +CocUpdateSync +TSUpdateSync +qall
  update_error nvim $?
  revolver_stop

  revolver_update "Updating npm packages..."
  npm update && npm upgrade && npm audit fix --force && npm prune --production --force
  update_error npm $?
  revolver_stop

  revolver_update "Updating pip packages..."
  pip3 install --quiet --upgrade pip setuptools wheel && \
    pip3 freeze --local | grep -v '^-e' | cut -d = -f 1 | \
    xargs -n1 pip3 install --quiet --upgrade
  update_error pip $?
  revolver_stop

  revolver_update "Updating tldr cache..."
  tldr --update
  revolver_stop

  revolver_update "Syncing Vale styles in notes..."
  pushd $HOME/styles && vale sync && popd
  revolver_stop

  $HOME/bin/sync_neopilotai.sh
  $HOME/bin/sync_fluxninja.sh

  [[ $TERM == *"tmux"* || -n $TMUX ]] && tmux source-file $HOME/dotfiles/tmux.conf

  stop_time=$(date +%s)
  interval=$((stop_time - start_time))
  echo "It took $interval seconds to update the system."
  show_errors
fi

# Cleanup
unset SYSTEM_RECEIPT_F SYSTEM_UPDATE_DAYS day_seconds last_system system_seconds
unset start_time stop_time interval force_update update_errors check_interval error_code error_cmd tp
unset -f update_error show_errors check_interval revolver_stop revolver_start revolver_update
