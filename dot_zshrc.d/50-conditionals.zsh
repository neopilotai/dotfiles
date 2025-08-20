if [[ $OSTYPE == 'darwin'* ]]; then
  source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
  source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

periodic() { silent_background timeout 2 $HOME/bin/gh_checks_status.sh > /tmp/gh_$$ }
PERIOD=10

# source .zshrc_local if it exists
if [ -f ~/.zshrc_local ]; then
  source ~/.zshrc_local
fi

if [ -z "$CHEERS_ENABLED" ]; then
  CHEERS_ENABLED=true
fi

if [ -z "$INSULTS_ENABLED" ]; then
  INSULTS_ENABLED=true
fi

if [ -z "$INSULTS_OFFENSIVE_ENABLED" ]; then
  INSULTS_OFFENSIVE_ENABLED=false
fi

if $INSULTS_ENABLED; then
  source $HOME/assets/insults.zsh
fi

if [ -z "$CNF_TF_ENABLED" ]; then
  CNF_TF_ENABLED=true
fi

if $CNF_TF_ENABLED; then
  source $HOME/bin/zsh_cnf.zsh
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

if $AUTO_CLEAR_CACHES; then
  # ask the user if they want to clear go installation as it bloats over time
  printf "Go installation grows over time and it\'s recommended to clear it periodically.\n"
  if gum confirm "Do you want to clear the go installation?"; then
    echo "Clearing go installation..."
    sudo rm -rf $HOME/go
    echo "Go installation cleared."
    echo "Sync FluxNinja repos..."
    $HOME/bin/sync_fluxninja.sh
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

# check timestamp when welcome was last displayed and if it's less than ASCII_WELCOME_SNOOZE then disable ascii art. Also update the timestamp if ascii art is going to be displayed.
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

# check whether ascii art is enabled
if $ASCII_WELCOME_ENABLED; then
  # print a random cowsay using fortune using only *.cow files located at $(brew --prefix)/share/cows
  fortune | cowsay -f $(find $(brew --prefix)/share/cowsay/cows/ -name "*.cow" | shuf -n 1)
  (timeout 2 WTTR_PARAMS="1" ~/bin/wttr.sh ;
    echo; echo -e "${CYAN_BRIGHT}  ==================================  GitHub Status ================================== ${RESET}"; echo;
    timeout 2 gh status --org neopilotai) 2&>/dev/null
fi

unset ASCII_WELCOME_ENABLED
unset ASCII_WELCOME_SNOOZE
unset CNF_TF_ENABLED

# run $HOME/bin/executable_autoupdate.zsh by eval it's content
eval "$(cat $HOME/bin/executable_autoupdate.zsh)"

source $HOME/.aliases

if [[ $TERM == *"tmux"* || $TERM == *"screen"* || -n $TMUX ]]; then
  echo -e "${YELLOW_BRIGHT} Welcome to ${CYAN_BRIGHT}tmux${RESET}"
  echo -e "${YELLOW_BRIGHT} Press ${CYAN_BRIGHT}<C-a C-Space>${YELLOW_BRIGHT} for fuzzy menu - look for additional commands under ${CYAN_BRIGHT}menu${YELLOW_BRIGHT} selection${RESET}"
  echo -e "${YELLOW_BRIGHT} Press ${CYAN_BRIGHT}F12${YELLOW_BRIGHT} for tmux menu${RESET}"
else 
  sessions=$(tmux list-sessions 2&> /dev/null | cut -d ":" -f1)
  # check whether $sessions is not empty
  if [ -n "$sessions" ]; then
    echo -e "\n${BOLD}${CYAN_BRIGHT}  == Active tmux Sessions ==${RESET}";
    for i in $sessions ; do
        echo -e "${BOLD}${YELLOW_BRIGHT}     [*] $i"
    done;
  fi
  echo -e "${CYAN_BRIGHT}  == Run tms to create and select tmux sessions == ${RESET}"
  echo -e "${RESET}"
fi

echo -e "${YELLOW_BRIGHT} Press ${CYAN_BRIGHT}<TAB>${YELLOW_BRIGHT} to invoke auto-complete menu for commands, arguments and options${RESET}"
echo

# override terminal profile colors using escape codes
if $SET_TERMINAL_COLORS; then
  $HOME/assets/set_colors.zsh
fi
