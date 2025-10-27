# Zsh key bindings and completion configuration
# This file contains fzf-tab and completion settings

# zvm_config configures zsh-vi-mode by setting the terminal type and cursor styles for insertion, normal, and append modes.
zvm_config() {
  # Always identify as xterm-256color to zsh-vi-mode plugin
  ZVM_TERM=xterm-256color
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
}

# zvm_after_init configures zsh completion, integrates zoxide and fzf/fzf-tab previews, applies extensive zstyle rules for git, processes, files, env vars, and tools, and finally loads fast-syntax-highlighting and autosuggestions.
zvm_after_init() {
  zicompinit
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # Zoxide integration
  zinit wait lucid atinit'eval "$(zoxide init zsh --cmd cd)"' nocd for /dev/null
  zicdreplay

  # Fzf-tab configuration
  zinit light Aloxaf/fzf-tab

  # Use tmux popups in tmux
  if [ -n "$TMUX" ]; then
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  fi

  # Git completion previews
  zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
  zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:git-(add|diff|restore):*' popup-pad 50 50

  zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
  zstyle ':fzf-tab:complete:git-log:*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:git-log:*' popup-pad 50 50

  zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help $word | bat -plman --color=always'
  zstyle ':fzf-tab:complete::*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete::*' popup-pad 50 50

  zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
    'case "$group" in
    "commit tag") git show --color=always $word ;;
    *) git show --color=always $word | delta ;;
    esac'
  zstyle ':fzf-tab:complete:git-show:*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:git-show:*' popup-pad 50 50

  zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
    'case "$group" in
    "modified file") git diff $word | delta ;;
    "recent commit object name") git show --color=always $word | delta ;;
    *) git log --color=always $word ;;
    esac'
  zstyle ':fzf-tab:complete:git-checkout:*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:git-checkout:*' popup-pad 50 50

  # General completion settings
  zstyle ':completion::complete:*:*:files' ignored-patterns '.DS_Store' 'Icon?'
  zstyle ':completion::complete:*:*:globbed-files' ignored-patterns '.DS_Store' 'Icon?'
  zstyle ':completion::complete:rm:*:globbed-files' ignored-patterns

  zstyle ':completion:*:git-checkout:*' sort false
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':fzf-tab:*' switch-group 'F1' 'F2'

  # Process completion
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
  zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
  zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
  zstyle ':fzf-tab:complete:(kill|ps):*' popup-pad 0 3

  # Environment variable completion
  zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'
  zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' popup-pad 0 1
  zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' fzf-flags --preview-window=down:1:wrap

  # File/directory operations
  zstyle ':fzf-tab:complete:(cd|eza|ls|fd|find|cp|mv|rm):argument-rest' fzf-preview 'eza --git -a -1 --color=always --icons $realpath'
  zstyle ':fzf-tab:complete:(cd|eza|ls|fd|find|cp|mv|rm):argument-rest' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:(cd|eza|ls|fd|find|cp|mv|rm):argument-rest' popup-pad 50 50

  # Content preview
  zstyle ':fzf-tab:complete:(cat|bat|vim|nvim|vimr|nvim-qt):argument-rest' fzf-preview 'LESSOPEN="|~/scripts/assets/lessfilter %s" less ${(Q)realpath}'
  zstyle ':fzf-tab:complete:(cat|bat|vim|nvim|vimr|nvim-qt):argument-rest' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:(cat|bat|vim|nvim|vimr|nvim-qt):argument-rest' popup-pad 50 50

  # System-specific completions
  if [[ $OSTYPE == 'linux'* ]]; then
    zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
    zstyle ':fzf-tab:complete:systemctl-*:*' popup-pad 50 50
  fi

  # Tool-specific completions
  zstyle ':fzf-tab:complete:tldr:argument-1' fzf-preview 'tldr --color always $word'
  zstyle ':fzf-tab:complete:tldr:argument-1' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:tldr:argument-1' popup-pad 50 50

  zstyle ':fzf-tab:complete:man:' fzf-preview 'batman --color=always $word'
  zstyle ':fzf-tab:complete:man:' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:man:' popup-pad 50 50

  zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
    '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || (out=$(batman --color=always "$word") 2>/dev/null && echo $out) || (out=$(source ~/.zprofile && which "$word") && echo $out) || echo "${(P)word}"'
  zstyle ':fzf-tab:complete:-command-:*' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:-command-:*' popup-pad 50 50

  zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word'
  zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-flags --preview-window=right:70%:wrap
  zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' popup-pad 50 50

  # Fast syntax highlighting (must be last)
  FAST_WORK_DIR=~/.config/fsh
  zinit wait lucid light-mode for \
      zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions
}

# Load zsh-vi-mode
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode