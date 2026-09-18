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

export EDITOR=nvim
export VISUAL=vim

autoload -U colors; colors
autoload -U compinit; compinit
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

# binds for completing/navigating history
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for k in "^[[A" "^[OA" "$terminfo[kcuu1]"; do
  [[ -n "$k" ]] && bindkey "$k" up-line-or-beginning-search
done
for k in "^[[B" "^[OB" "$terminfo[kcud1]"; do
  [[ -n "$k" ]] && bindkey "$k" down-line-or-beginning-search
done

alias vim=nvim
alias vimvim=/usr/bin/vim
alias ls='ls --color=auto'
alias grep='grep --color=auto'

export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!.git'"
export FZF_DEFAULT_OPTS="
  --color=bg:#1d1c19,bg+:#282727,fg:#a6a69c,fg+:#c5c9c5,gutter:#1d1c19
  --color=hl:#c5c9c5,hl+:#8ba4b0
  --color=prompt:#c4b28a,pointer:#8ba4b0,marker:#8a9a7b,spinner:#c4b28a
  --color=info:#737c73,header:#737c73,border:#393836,label:#a6a69c,separator:#393836,scrollbar:#393836
  --color=preview-bg:#1d1c19,preview-border:#393836
  --prompt='> ' --pointer='▌' --marker='+'
  --layout=reverse --info=inline-right --no-separator"
source <(fzf --zsh)
bindkey -s ^f "sessioniser\n"

# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
source "$HOME/.config/zsh/prompt.zsh"

export GOPATH=$HOME/go
export GOTMPDIR=$HOME/.cache/go-tmp; mkdir -p "$GOTMPDIR"
[[ -d /usr/local/go/bin ]] && PATH=/usr/local/go/bin:$PATH
export PATH=$HOME/bin:$HOME/.local/bin:$GOPATH/bin:/usr/local/bin:$PATH
typeset -U PATH path  # dedupe on nested shells
