function _git_nl() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function prompt_git() {
  local raw line ab branch dirty ahead=0 behind=0
  raw=$(_git_nl status --porcelain=v2 --branch 2> /dev/null) || return
  while IFS= read -r line; do
    case $line in
      '# branch.head '*) branch=${line#'# branch.head '} ;;
      '# branch.ab '*)
        ab=${line#'# branch.ab '}
        ahead=${ab%% *}; ahead=${ahead#+}
        behind=${ab##* }; behind=${behind#-}
        ;;
      '#'*) ;;
      *) dirty='*' ;;
    esac
  done <<< "$raw"
  [[ -z $branch ]] && return
  if [[ $branch == '(detached)' ]]; then
    branch=$(_git_nl describe --tags --exact-match HEAD 2> /dev/null) \
      || branch=$(_git_nl rev-parse --short HEAD 2> /dev/null) \
      || return
  fi
  local out="%F{red}git:(${branch}${dirty})%f"
  [[ $ahead -gt 0 ]] && out+=" %F{cyan}⇡${ahead}%f"
  [[ $behind -gt 0 ]] && out+=" %F{cyan}⇣${behind}%f"
  echo "${out} "
}

function prompt_venv() {
  [[ -n $VIRTUAL_ENV ]] && echo "%F{blue}(${VIRTUAL_ENV:t})%f "
}

function prompt_aws() {
  local profile=${AWS_VAULT:-${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}}
  [[ -n $profile ]] && echo "%F{yellow}aws:${profile}%f "
}

function prompt_ssh() {
  [[ -n $SSH_CONNECTION || -n $SSH_TTY ]] && echo "%F{red}ssh@%m%f "
}

PROMPT='$(prompt_ssh)%F{magenta}[%~]%f
$(prompt_venv)$(prompt_git)$(prompt_aws)%(?..%F{red}✗%?%f )%F{magenta}❯%f '
RPROMPT='%F{8}%*%f'
