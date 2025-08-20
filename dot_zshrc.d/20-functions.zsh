function set_terminal {
	if [[ -z "${TERMINAL:-}" ]]; then

		# |
		# | Check for the terminal name (depening on os)
		# |
		OS="$(uname)"
		if [[ "$OS" = "Darwin" ]]; then
			export TERMINAL=$TERM_PROGRAM
			# test whether ~/.iterm2_profile_check_v2 doesn't exist
			if [[ ! -e "${HOME}/.iterm2_profile_check_v2" ]]; then
        rm -f "${HOME}/.iterm2_profile_check"
        if gum confirm "Do you want to use NeoPilot's bundled iTerm2 colors/font profile?"; then
					# install iterm2 profile
					cp ~/assets/iterm2_gruvbox.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/
					# execute the script
					pip3 install iterm2 && python3 ~/assets/iterm2_default.py && touch "${HOME}/.iterm2_profile_check_v2" || (echo; echo; echo "Failed to install iTerm2 profile. You might need to enable Python API within iTerm2 preferences (under Magic tab). Press Enter to continue." && read)
          # ask about wallpaper
          if gum confirm "Do you want to use matching wallpaper?"; then
  					# set the wallpaper to ~/assets/apple_gruvbox.heic
						osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$HOME/assets/apple_gruvbox.heic\""
          fi
        else
					echo "no" > "${HOME}/.iterm2_profile_check_v2"
				fi
			fi
      return
    fi

    # Other OS'es
		if [[ "${OS#CYGWIN}" != "${OS}" ]]; then
			export TERMINAL="mintty"
		elif [[ "$TERM" = "xterm-kitty" ]]; then
			export TERMINAL="kitty"
		else
			# |
			# | Depending on how the script was invoked, we need
			# | to loop until pid is no longer a subshell
			# |
			pid="$$"
			export TERMINAL="$(ps -h -o comm -p $pid)"
			while [[ "${TERMINAL:(-2)}" == "sh" ]]; do
				pid="$(ps -h -o ppid -p $pid)"
				export TERMINAL="$(ps -h -o comm -p $pid)"
			done
		fi
	fi
}


# check whether tmux command exists
if [[ -x "$(command -v tmux)" ]]; then
  if $START_TMUX; then
    export START_TMUX=false
    set_terminal
    DETACHED_SESSIONS=$(tmux ls 2&>/dev/null | grep -v attached)
    # check whether tmux has sessions that are in detached state
    if [[ -n "$DETACHED_SESSIONS" ]]; then
      # get the list of detached sessions
      DETACHED_SESSIONS=$(tmux ls | grep -v attached)
      # Add "New Session" to the list of detached sessions
      DETACHED_SESSIONS="New Session\n$DETACHED_SESSIONS"
      #local PREVIEW="TOKEN={} && echo 'token: $TOKEN'"
      # use fzf to select a session
      SESSION_NAME=$(echo "$DETACHED_SESSIONS" |
        fzf --header="== Attach to a detached session ==" \
        --ansi --color="dark" \
        --preview="$HOME/assets/.session_preview {}")
      # if the user selected a session, attach to it
      # otherwise, create a new session
      if [[ $SESSION_NAME == "New Session" ]]; then
        tmux -u new-session
      else
        # extract session name
        SESSION_NAME=$(echo "$SESSION_NAME" |  cut -d':' -f1)
        tmux -u attach -t $SESSION_NAME
      fi
    else
      tmux -u new-session
    fi
    exit
  fi
fi

source ~/assets/utils.zsh

# See https://unix.stackexchange.com/q/150649/126543
function expand-command-aliases() {
	cmd="$1"
	functions[expandaliasestmp]="${cmd}"
	print -rn -- "${functions[expandaliasestmp]#$'	'}"
	unset 'functions[expandaliasestmp]'
}

_brew_completion_update=false

func preexec() {
  export LAST_COMMAND="$(expand-command-aliases "$1")"
  # Do nothing at all if we are not in tmux, second test is needed in
  # case of an ssh session being run from within tmux, which could result
  # in $TMUX from the parent session being set without tmux being
  # connected.
  if [ -n "$TMUX" ] && tmux ls >/dev/null 2>/dev/null; then
    eval "$(tmux show-environment -s | grep -v \'^unset')"
    local uuid="$(tmux show-environment -g TMUX_UUID 2>/dev/null)"
    # check whether $LAST_TMUX_UUID is set
    if [[ -z "$LAST_TMUX_UUID" ]]; then
      export LAST_TMUX_UUID="$uuid"
    else
      # check whether $LAST_TMUX_UUID is the same as $uuid
      if [ "$LAST_TMUX_UUID" != "$uuid" ]; then
        export LAST_TMUX_UUID="$uuid"
        echo -e "${BLUE_BRIGHT} == Autoupdate detected | Zsh reloading == ${RESET}"
        # tmux respawn pane and new login shell to reload zsh
        # cd to the current directory
        # run the LAST_COMMAND
        tmux respawn-pane -k -t "$TMUX_PANE" "cd \"$PWD\" && $LAST_COMMAND && zsh --login"
        echo
        echo -e "${BLUE_BRIGHT} == Zsh reloaded == ${RESET}"
        echo
      fi
    fi
  fi

  # if last command contained "brew install" or "brew upgrade" or "brew uninstall" or "brew reinstall" the set _brew_completion_update=1
  if [[ "$LAST_COMMAND" =~ "brew install" ]] || [[ "$LAST_COMMAND" =~ "brew upgrade" ]] || [[ "$LAST_COMMAND" =~ "brew uninstall" ]] || [[ "$LAST_COMMAND" =~ "brew reinstall" ]]; then
    
    _brew_completion_update=true
  fi
}

function precmd() {
  # if _brew_completion_update is set to true, run "zinit update brew-completions"
  if $_brew_completion_update; then
    zinit update brew-completions
    _brew_completion_update=false
  fi
}

func zshexit() {
#remove gh status
rm /tmp/gh_$$ &>/dev/null
# remove watch on home directory
watchman watch-del $HOME >/dev/null 
figlet -w 80 NeoPilot zsh
cowsay -d "zsh exiting... see you later..."
sleep 0.5
}

# configure zsh to show hidden files in auto-completion
setopt globdots
setopt interactivecomments

eval $(thefuck --alias)

function @yazpt_segment_nl() {
# check whether $last_yazpt_vcs is not equal to $yazpt_state[vcs]
#if [[ "$last_yazpt_vcs" != "$yazpt_state[vcs]" ]]; then
#  spinner -q -s "timeout 2 $HOME/bin/gh_checks_status.sh > /tmp/gh_$$"
#fi
last_yazpt_vcs="$yazpt_state[vcs]"
yazpt_state[nl]=""
# read from /tmp/gh_"$$" if it exists
if [[ -e "/tmp/gh_$$" ]]; then
  local check="$(cat /tmp/gh_$$"
  # check whether check is empty
  if [ -n "$check" ]; then
    if [ -n "$yazpt_state[vcs]" ]; then
      yazpt_state[nl]+=" | "
    fi
    yazpt_state[nl]+=" GitHub checks $check"
  fi
fi

local hour=$(date +%H)
if (( 23 <= $hour || $hour <= 6 )); then
  if [ -n "$yazpt_state[nl]" ] ||  [ -n "$yazpt_state[vcs]" ]; then
    yazpt_state[nl]+=" | "
  fi
  yazpt_state[nl]+="%F{$YAZPT_CWD_COLOR}it's late, yo - get some sleep!%f"
fi
# check whether $yazpt_state[nl] or $yazpt_state[vcs] is not empty and add a new line if it is not empty
if [ -n "$yazpt_state[nl]" ] || [ -n "$yazpt_state[vcs]" ]; then
  yazpt_state[nl]+=$'\n'
fi
}

function @yazpt_segment_excuse() {
# check whether exit code of last command was not 0 or 127 or 130
local code="$yazpt_state[exit_code]"
local excuse_msg=''
if [[ $code -ne 0 && $code -ne 127 && "$yazpt_state[exit_code]" -ne 130 ]] && $INSULTS_ENABLED; then
  local excuse_msg='💥uh-ho💥 '
  excuse_msg+="$(excuse)"
  excuse_msg+=$'\n'
fi
yazpt_state[excuse]=$excuse_msg
}

APP_CHEERS_PATTERNS=(
  "git push"
  "git_ship"
)

function @yazpt_segment_cheers() {
local do_cheers=false
local cheers_msg=''
# check whether exit code of last command was 0
if $CHEERS_ENABLED && [ "$yazpt_state[exit_code]" -eq 0 ] ; then
  # check whether $LAST_COMMAND contained any of the APP_CHEERS_PATTERNS
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
  if [[ $OSTYPE == 'darwin'* ]]; then
    # call fireworks if $ITERM2_INTEGRATION_DETECTED is true
    if $ITERM2_INTEGRATION_DETECTED; then
      $HOME/.iterm2/it2attention fireworks
    fi
  fi
fi
yazpt_state[cheers]=$cheers_msg
}

function configure_yazpt {
  YAZPT_LAYOUT=$PROMPT_LAYOUT
  YAZPT_CWD_COLOR=6 # cyan
  YAZPT_EXECTIME_MIN_SECONDS=1
}

zvm_config() {
  # always identify as xterm-256color to zsh-vi-mode plugin
  ZVM_TERM=xterm-256color
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
}

zvm_after_init() {
  zicompinit

  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # zoxide
  zinit wait lucid atinit'eval "$(zoxide init zsh --cmd cd)"' nocd for /dev/null

  zicdreplay

  # fzf-tab needs to be loaded after compinit, but before fast-syntax-highlighting
  zinit light Aloxaf/fzf-tab
  # use tmux popups in case we are in tmux
  if [ -n "$TMUX" ]; then
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  fi

  ### NOTE: In order to generate previews, context is needed. The trick to find the context is to type the commmand to the point where completion is needed and press "C-x h". You will need to call "enable-fzf-tab" after this to reenable fzf-tab.

  # preview git -- these don't work with homebrew completions so we make a copy of zsh's version at ~/.completions/_git
  # zsh version - https://github.com/zsh-users/zsh/blob/master/Completion/Unix/Command/_git
  zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 
    'git diff $word | delta'
  zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:git-(add|diff|restore):*' popup-pad 50 50

  zstyle ':fzf-tab:complete:git-log:*' fzf-preview 
    'git log --color=always $word'
  zstyle ':fzf-tab:complete:git-log:*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:git-log:*' popup-pad 50 50

  zstyle ':fzf-tab:complete:git-help:*' fzf-preview 
    'git help $word | bat -plman --color=always'
  zstyle ':fzf-tab:complete::*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete::*' popup-pad 50 50

  zstyle ':fzf-tab:complete:git-show:*' fzf-preview 
    'case "$group" in
    "commit tag") git show --color=always $word ;; 
    *) git show --color=always $word | delta ;; 
  esac'
  zstyle ':fzf-tab:complete:git-show:*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:git-show:*' popup-pad 50 50

  zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 
    'case "$group" in
    "modified file") git diff $word ;; 
    "recent commit object name") git show --color=always $word ;; 
    *) git log --color=always $word ;; 
  esac'
  zstyle ':fzf-tab:complete:git-checkout:*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:git-checkout:*' popup-pad 50 50

  # ignore some patterns
  zstyle ':completion::complete:*:*:files' ignored-patterns '.DS_Store' 'Icon?'
  zstyle ':completion::complete:*:*:globbed-files' ignored-patterns '.DS_Store' 'Icon?'
  zstyle ':completion::complete:rm:*:globbed-files' ignored-patterns

  # disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # set descriptions format to enable group support
  zstyle ':completion:*:descriptions' format '[%d]'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # switch group using `,` and `.`
  zstyle ':fzf-tab:*' switch-group 'F1' 'F2'
  # give a preview of commandline arguments when completing `kill`
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
  zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview 
    '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
  zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
  zstyle ':fzf-tab:complete:(kill|ps):*' popup-pad 0 3

  # preview environment variables
  zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' 
    fzf-preview 'echo ${(P)word}'
  zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' popup-pad 0 1
  zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' fzf-flags --preview-window=down:1:wrap

  # use eza for previewing commands that work at directory/path level
  zstyle ':fzf-tab:complete:(cd|eza|ls|fd|find|cp|mv|rm):argument-rest' fzf-preview 'eza --git -a -1 --color=always --icons $realpath'
  zstyle ':fzf-tab:complete:(cd|eza|ls|fd|find|cp|mv|rm):argument-rest' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:(cd|eza|ls|fd|find|cp|mv|rm):argument-rest' popup-pad 50 50

  # use lessfilter to preview content files, directories etc.
  zstyle ':fzf-tab:complete:(cat|bat|vim|nvim|vimr|nvim-qt):argument-rest' fzf-preview 'LESSOPEN="|~/assets/lessfilter %s" less ${(Q)realpath}'
  zstyle ':fzf-tab:complete:(cat|bat|vim|nvim|vimr|nvim-qt):argument-rest' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:(cat|bat|vim|nvim|vimr|nvim-qt):argument-rest' popup-pad 50 50

  if [[ $OSTYPE == 'linux'* ]]; then
    zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
    zstyle ':fzf-tab:complete:systemctl-*:*' popup-pad 50 50
  fi

  zstyle ':fzf-tab:complete:tldr:argument-1' fzf-preview 'tldr --color always $word'
  zstyle ':fzf-tab:complete:tldr:argument-1' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:tldr:argument-1' popup-pad 50 50

  zstyle ':fzf-tab:complete:man:' fzf-preview 'batman --color=always $word'
  zstyle ':fzf-tab:complete:man:' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:man:' popup-pad 50 50

  zstyle ':fzf-tab:complete:-command-:*' fzf-preview 
    '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || (out=$(batman --color=always "$word") 2>/dev/null && echo $out) || (out=$(source ~/.zprofile && which "$word") && echo $out) || echo "${(P)word}"'
  zstyle ':fzf-tab:complete:-command-:*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:-command-:*' popup-pad 50 50


  zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word'
  zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' popup-pad 50 50

  # these should be the last zinit plugins
  FAST_WORK_DIR=~/.config/fsh
  zinit wait lucid light-mode for \
      zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions
}
