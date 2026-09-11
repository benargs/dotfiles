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

function _git_nl() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function git_prompt() {
  if ! _git_nl rev-parse --git-dir &> /dev/null; then
    return 0
  fi
  local BRANCH STATUS
  BRANCH=$(_git_nl symbolic-ref --short HEAD 2> /dev/null) \
    || BRANCH=$(_git_nl describe --tags --exact-match HEAD 2> /dev/null) \
    || BRANCH=$(_git_nl rev-parse --short HEAD 2> /dev/null) \
    || return
  if [[ -n "$(_git_nl status --porcelain 2> /dev/null)" ]]; then
    STATUS="*"
  else
    STATUS=""
  fi
  echo "%F{red}git:(${BRANCH}${STATUS})%f "
}

function ssh_prompt() {
  if [[ -n $SSH_CONNECTION || -n $SSH_CLIENT || -n $SSH_TTY ]]; then
    echo "%F{red}@%m %f"
  else
    echo ""
  fi
}

alias vim=nvim
alias vimvim=/usr/bin/vim

source <(fzf --zsh)
bindkey -s ^f "sessioniser\n"

# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
PROMPT='$(ssh_prompt)%F{magenta}[%2c]%f $(git_prompt)%F{yellow}%(?::{%?})%f
%F{magenta}>%f%{$reset_color%} '

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
