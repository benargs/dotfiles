function _git_nl() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function prompt_seg_ssh() {
  if [[ -n $SSH_CONNECTION || -n $SSH_CLIENT || -n $SSH_TTY ]]; then
    echo "%F{red}ssh@%m%f "
  fi
}

function _prompt_git_status() {
  local raw line ab
  raw=$(_git_nl status --porcelain=v2 --branch 2> /dev/null) || return
  branch= dirty= ahead=0 behind=0
  while IFS= read -r line; do
    case $line in
      '# branch.head '*) branch=${line#'# branch.head '} ;;
      '# branch.ab '*)
        ab=${line#'# branch.ab '}
        ahead=${ab%% *}; ahead=${ahead#+}
        behind=${ab##* }; behind=${behind#-}
        ;;
      '#'*) ;;
      *) dirty="*" ;;
    esac
  done <<< "$raw"
  [[ -z $branch ]] && return 1
  if [[ $branch == '(detached)' ]]; then
    branch=$(_git_nl describe --tags --exact-match HEAD 2> /dev/null) \
      || branch=$(_git_nl rev-parse --short HEAD 2> /dev/null) \
      || return 1
  fi
}

function prompt_seg_git() {
  local branch dirty ahead behind
  _prompt_git_status || return
  echo "%F{red}git:(${branch}${dirty})%f "
}

function prompt_seg_git_detailed() {
  local branch dirty ahead behind
  _prompt_git_status || return
  local out="%F{red}git:(${branch}${dirty})%f"
  [[ $ahead -gt 0 ]] && out+=" %F{cyan}⇡${ahead}%f"
  [[ $behind -gt 0 ]] && out+=" %F{cyan}⇣${behind}%f"
  echo "${out} "
}

function prompt_seg_venv() {
  local name
  if [[ -n $VIRTUAL_ENV ]]; then
    name=${VIRTUAL_ENV:t}
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
