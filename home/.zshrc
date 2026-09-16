setopt prompt_subst
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history

[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

export EDITOR=vim
export VISUAL=vim

autoload -U colors; colors
autoload -U compinit; compinit
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

# binds for completing/navigating history
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

alias vim=nvim
alias vimvim=/usr/bin/vim

source <(fzf --zsh)
bindkey -s ^f "sessioniser\n"

# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
source "$HOME/.config/zsh/prompt.zsh"

export PATH=$HOME/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:$PATH
