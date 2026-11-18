if command -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR vim
end
set -gx VISUAL $EDITOR

set -gx GOPATH $HOME/go
set -gx GOTMPDIR $HOME/.cache/go-tmp
test -d $GOTMPDIR; or mkdir -p $GOTMPDIR
# -g keeps it out of universal vars, -P edits $PATH directly, -m moves existing
# entries to the front (same effect as the typeset -U dedupe in zsh)
fish_add_path -gPm ~/bin ~/.local/bin $GOPATH/bin /usr/local/bin /usr/local/go/bin

set -gx npm_config_ignore_scripts true
set -gx npm_config_min_release_age 7
set -gx pnpm_config_minimum_release_age 10080

if status is-interactive
    set -g fish_greeting
    # fish_prompt shows the venv itself, stop activate.fish wrapping it
    set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

    if command -q nvim
        alias vim nvim
        alias vimvim /usr/bin/vim
    end

    abbr -a k kubectl
    abbr -a gco git checkout
    abbr -a gp git push
    abbr -a gpu git push --set-upstream origin

    set -gx FZF_DEFAULT_COMMAND "rg --files --hidden -g '!.git'"
    set -gx FZF_DEFAULT_OPTS "
  --color=bg:#1d1c19,bg+:#282727,fg:#a6a69c,fg+:#c5c9c5,gutter:#1d1c19
  --color=hl:#c5c9c5,hl+:#8ba4b0
  --color=prompt:#c4b28a,pointer:#8ba4b0,marker:#8a9a7b,spinner:#c4b28a
  --color=info:#737c73,header:#737c73,border:#393836,label:#a6a69c,separator:#393836,scrollbar:#393836
  --color=preview-bg:#1d1c19,preview-border:#393836
  --prompt='> ' --pointer='▌' --marker='+'
  --layout=reverse --info=inline-right --no-separator"
    command -q fzf; and fzf --fish | source

    # event handlers have to be defined up front, autoloading won't register them
    function _pkg_cooldown --on-event fish_prompt
        set -gx PIP_UPLOADED_PRIOR_TO (date -d '7 days ago' +%Y-%m-%dT%H:%M:%S)
        set -gx npm_config_before $PIP_UPLOADED_PRIOR_TO
    end
end

if test -r ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
