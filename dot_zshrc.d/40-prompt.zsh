PS1="$(pwd) > "
PROMPT_LAYOUT='<excuse><cheers><vcs><nl>[<cwd><? ><exit>] <char> '

if [[ -z "$ITERM2_INTEGRATION_DETECTED" ]]; then
  ITERM2_INTEGRATION_DETECTED=false
fi

if [[ $OSTYPE == 'darwin'* ]]; then
  # check whether $TERMINAL is iTerm.app
  if [[ $TERMINAL == "iTerm.app" ]]; then
    export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=true
    # iterm2 prompt mark doesn't work under tmux for some reason
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" && \
      ITERM2_INTEGRATION_DETECTED=true && PROMPT_LAYOUT="%{$(iterm2_prompt_mark)%} $PROMPT_LAYOUT%{$(iterm2_prompt_end)%}"
    # read $HOME/.iterm2_profile_check_v2 file and check if it contains "no"
    if [[ $(cat "${HOME}/.iterm2_profile_check_v2") == "no" ]]; then
      SET_TERMINAL_COLORS=true
    else
      SET_TERMINAL_COLORS=false
    fi
  ## if the terminal is ghostty don't set terminal colors
  elif [[ $TERMINAL == "ghostty" ]]; then
    SET_TERMINAL_COLORS=false
  fi
fi
