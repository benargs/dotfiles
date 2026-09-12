function _git_nl() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function prompt_seg_ssh() {
  if [[ -n $SSH_CONNECTION || -n $SSH_CLIENT || -n $SSH_TTY ]]; then
    echo "%F{red}ssh@%m%f "
  fi
}

function _prompt_git_branch() {
  _git_nl symbolic-ref --short HEAD 2> /dev/null \
    || _git_nl describe --tags --exact-match HEAD 2> /dev/null \
    || _git_nl rev-parse --short HEAD 2> /dev/null
}

function _prompt_git_dirty() {
  [[ -n "$(_git_nl status --porcelain 2> /dev/null)" ]] && echo "*"
}

function prompt_seg_git() {
  _git_nl rev-parse --git-dir &> /dev/null || return
  local branch=$(_prompt_git_branch)
  [[ -z $branch ]] && return
  echo "%F{red}git:(${branch}$(_prompt_git_dirty))%f "
}

function prompt_seg_git_detailed() {
  _git_nl rev-parse --git-dir &> /dev/null || return
  local branch=$(_prompt_git_branch)
  [[ -z $branch ]] && return
  local dirty=$(_prompt_git_dirty)
  local counts=$(_git_nl rev-list --left-right --count 'HEAD...@{upstream}' 2> /dev/null)
  local ahead behind
  if [[ -n $counts ]]; then
    ahead=${counts%%$'\t'*}
    behind=${counts##*$'\t'}
  fi
  local out="%F{red}git:(${branch}${dirty})%f"
  [[ -n $ahead && $ahead -gt 0 ]] && out+=" %F{cyan}⇡${ahead}%f"
  [[ -n $behind && $behind -gt 0 ]] && out+=" %F{cyan}⇣${behind}%f"
  echo "${out} "
}

function prompt_seg_venv() {
  local name
  if [[ -n $VIRTUAL_ENV ]]; then
    name=$(basename "$VIRTUAL_ENV")
  elif [[ -n $CONDA_DEFAULT_ENV && $CONDA_DEFAULT_ENV != base ]]; then
    name=$CONDA_DEFAULT_ENV
  else
    return
  fi
  echo "%F{blue}(${name})%f "
}

function prompt_seg_aws() {
  local profile=${AWS_VAULT:-${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}}
  [[ -z $profile ]] && return
  echo "%F{yellow}aws:${profile}%f "
}

function prompt_seg_exit() {
  echo "%(?::%F{red}✗%?%f )"
}

function prompt_seg_dir() {
  if [[ $1 == full ]]; then
    echo "%F{magenta}[%~]%f "
  else
    echo "%F{magenta}[%${1:-2}c]%f "
  fi
}
