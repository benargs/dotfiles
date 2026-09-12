# Usage:
#   prompt-list            list available prompts
#   prompt-current          show the active one
#   prompt-set <name>       switch for this and future sessions

typeset -g PROMPT_ROOT="${HOME}/.config/zsh/prompt"
typeset -g PROMPT_STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh-prompt"

source "$PROMPT_ROOT/lib.zsh"

function prompt-list() {
  local f
  for f in "$PROMPT_ROOT"/prompts/*.zsh(N); do
    if [[ ${f:t:r} == $ZSH_PROMPT_NAME ]]; then
      print -r -- "* ${f:t:r}"
    else
      print -r -- "  ${f:t:r}"
    fi
  done
}

function prompt-current() {
  print -r -- "${ZSH_PROMPT_NAME:-<none>}"
}

function prompt-set() {
  local name=$1
  if [[ -z $name ]]; then
    echo "usage: prompt-set <name>  (available: $(prompt-list | tr -d '*' | tr '\n' ' '))" >&2
    return 1
  fi
  local file="$PROMPT_ROOT/prompts/${name}.zsh"
  if [[ ! -f $file ]]; then
    echo "no such prompt: $name (available: $(prompt-list | tr -d '*' | tr '\n' ' '))" >&2
    return 1
  fi
  RPROMPT=
  source "$PROMPT_ROOT/lib.zsh"
  source "$file"
  typeset -g ZSH_PROMPT_NAME=$name
  mkdir -p "${PROMPT_STATE_FILE:h}"
  echo "$name" > "$PROMPT_STATE_FILE"
}

function _prompt_load_saved() {
  local saved
  [[ -f $PROMPT_STATE_FILE ]] && saved=$(<$PROMPT_STATE_FILE)
  prompt-set "${saved:-standard}"
}
_prompt_load_saved
