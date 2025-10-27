# Zsh prompt configuration using yazpt
# Custom segments and prompt layout

# Prompt layout configuration
PS1="$(pwd) > "
PROMPT_LAYOUT='<excuse><cheers><vcs><nl>[<cwd><? ><exit>] <char> '

# Custom prompt segments
function @yazpt_segment_nl() {
  # Check if GitHub status should be displayed
  local last_yazpt_vcs="$yazpt_state[vcs]"
  yazpt_state[nl]=""

  # Read GitHub checks status if available
  if [[ -e "/tmp/gh_$$" ]]; then
    local check="$(cat /tmp/gh_$$")"
    if [ -n "$check" ]; then
      if [ -n "$yazpt_state[vcs]" ]; then
        yazpt_state[nl]+=" | "
      fi
      yazpt_state[nl]+=" GitHub checks $check"
    fi
  fi

  # Add sleep reminder for late hours
  local hour=$(date +%H)
  if (( 23 <= hour || hour <= 6 )); then
    if [ -n "$yazpt_state[nl]" ] || [ -n "$yazpt_state[vcs]" ]; then
      yazpt_state[nl]+=" | "
    fi
    yazpt_state[nl]+="%F{$YAZPT_CWD_COLOR}it's late, yo - get some sleep!%f"
  fi

  # Add newline if content exists
  if [ -n "$yazpt_state[nl]" ] || [ -n "$yazpt_state[vcs]" ]; then
    yazpt_state[nl]+=$'\n'
  fi
}

function @yazpt_segment_excuse() {
  local code="$yazpt_state[exit_code]"
  local excuse_msg=''

  if [[ $code -ne 0 && $code -ne 127 && "$yazpt_state[exit_code]" -ne 130 ]] && $INSULTS_ENABLED; then
    excuse_msg='💥uh-ho💥 '
    excuse_msg+="$(excuse)"
    excuse_msg+=$'\n'
  fi

  yazpt_state[excuse]=$excuse_msg
}

# Cheers patterns for successful commands
APP_CHEERS_PATTERNS=(
  "git push"
  "git_ship"
)

function @yazpt_segment_cheers() {
  local do_cheers=false
  local cheers_msg=''

  if $CHEERS_ENABLED && [ "$yazpt_state[exit_code]" -eq 0 ]; then
    for pattern in "${APP_CHEERS_PATTERNS[@]}"; do
      if [[ "$LAST_COMMAND" == *"$pattern"* ]]; then
        do_cheers=true
        break
      fi
    done
  fi

  if $do_cheers; then
    cheers_msg=' 🍻🎉🍻 '
    cheers_msg+="$(compliment)"
    cheers_msg+=$'\n'

    # iTerm2 fireworks integration
    if [[ $OSTYPE == 'darwin'* ]] && $ITERM2_INTEGRATION_DETECTED; then
      $HOME/.iterm2/it2attention fireworks
    fi
  fi

  yazpt_state[cheers]=$cheers_msg
}

# Configure yazpt
function configure_yazpt {
  YAZPT_LAYOUT=$PROMPT_LAYOUT
  YAZPT_CWD_COLOR=6 # cyan
  YAZPT_EXECTIME_MIN_SECONDS=1
}
