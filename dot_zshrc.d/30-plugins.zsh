zinit ice wait'!0' atload'source "$yazpt_default_preset_file"; configure_yazpt;yazpt_precmd' nocd lucid
zinit light jakshin/yazpt

# install git-extras via zinit instead of brew
zinit lucid wait'0a' for as"program" pick"$ZPFX/bin/git- கருவ" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX" tj/git-extras


# install direnv via zinit instead of brew
zinit from"gh-r" as"program" mv"direnv* -> direnv" atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' pick"direnv" src="zhook.zsh" for direnv/direnv

# zinit light zdharma-continuum/zui
# zinit light zdharma-continuum/zbrowse # use '^B' to open zbrowse
# zinit wait lucid for zdharma-continuum/zinit-console

zinit snippet OMZ::lib/key-bindings.zsh

zinit light MichaelAquilina/zsh-you-should-use

# install brew's completions except for git
zinit id-as='brew-completions' wait as='completion' lucid atclone='print Installing Brew completions...; rm -rf $ZPFX/brew_comps_others 2>/dev/null; mkdir -p $ZPFX/brew_comps_others; rm -rf $ZPFX/brew_comps_zsh 2>/dev/null; mkdir -p $ZPFX/brew_comps_zsh; command cp -f $(brew --prefix)/share/zsh/site-functions/^_* $ZPFX/brew_comps_others; command cp -f $(brew --prefix)/share/zsh/site-functions/_* $ZPFX/brew_comps_zsh; command rm $ZPFX/brew_comps_zsh/_git; zinit creinstall -q $ZPFX/brew_comps_zsh; zinit cclear; enable-fzf-tab' atload='fpath=( ${(u)fpath[@]:#$(brew --prefix)/share/zsh/site-functions/*} ); fpath+=( $ZPFX/brew_comps_others )' atpull='%atclone' nocompile run-atpull for zdharma-continuum/null

zinit id-as='system-completions' wait as='completion' lucid atclone='print Installing system completions...; mkdir -p $ZPFX/zsh_comps; command cp -f $(brew --prefix)/share/zsh/functions/^_* $ZPFX/zsh_comps; zinit creinstall -q $(brew --prefix)/share/zsh/functions; zinit cclear; enable-fzf-tab' atload='fpath=( ${(u)fpath[@]:#$(brew --prefix)/share/zsh/functions/*} ); fpath+=( $ZPFX/zsh_comps )' atpull="%atclone" nocompile run-atpull for zdharma-continuum/null

zinit id-as='fn-completions' wait as='completion' lucid atclone='print Installing FN completions...; zinit creinstall -q $HOME/.completions; zinit cclear; enable-fzf-tab' atload='fpath=( ${(u)fpath[@]:#$HOME/.completions/*} )' atpull="%atclone" nocompile run-atpull for zdharma-continuum/null


zinit ice wait as'completion' lucid
zinit snippet https://github.com/sainnhe/zsh-completions/blob/master/src/custom/_fzf

#zinit ice wait'0' lucid
#zinit light sainnhe/zsh-completions

zinit ice wait blockf atpull'zinit creinstall -q .' lucid
zinit light zsh-users/zsh-completions

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

