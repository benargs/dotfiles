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

if (( $+commands[nvim] )); then
  export EDITOR=nvim
else
  export EDITOR=vim
fi
export VISUAL=$EDITOR

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

if (( $+commands[nvim] )); then
  alias vim=nvim
  alias vimvim=/usr/bin/vim
fi
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias k=kubectl

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

export npm_config_ignore_scripts=true npm_config_min_release_age=7
export pnpm_config_minimum_release_age=10080

# I would love to do the above for `uv` carte blanche but it edits the lockfile
# (and re-resolves deps) if the exclude newer is on. I don't want to be breaking
# existing repo locks so this wrapper seems like a reasonable middle ground.
uv() { [[ $1 == (pip|tool) ]] && local -x UV_EXCLUDE_NEWER="7 days"; command uv "$@"; }
uvx() { UV_EXCLUDE_NEWER="7 days" command uvx "$@"; }
zmodload zsh/datetime
_pkg_cooldown() {
  strftime -s PIP_UPLOADED_PRIOR_TO '%Y-%m-%dT%H:%M:%S' $(( EPOCHSECONDS - 7 * 86400 ))
  export PIP_UPLOADED_PRIOR_TO npm_config_before=$PIP_UPLOADED_PRIOR_TO
}
precmd_functions+=(_pkg_cooldown)

# fresh <cmd>: run one command with the cooldowns off, e.g.
# `fresh npm i @thing`
# `fresh pip install -r requirements.txt`
fresh() {
  env -u PIP_UPLOADED_PRIOR_TO -u npm_config_before npm_config_min_release_age=0 \
    UV_EXCLUDE_NEWER=false pnpm_config_minimum_release_age=0 "$@"
}

if [[ -r ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
