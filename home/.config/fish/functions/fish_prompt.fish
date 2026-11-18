# Same layout as ~/.config/zsh/prompt.zsh:
#   ssh@host [~/path]
#   (venv) git:(branch*) ⇡1 ⇣2 aws:profile ✗1 ❯
function fish_prompt
    set -l last_status $status

    if set -q SSH_CONNECTION; or set -q SSH_TTY
        echo -n (set_color red)ssh@(prompt_hostname)(set_color normal)' '
    end
    echo (set_color magenta)'['(prompt_pwd --dir-length=0)']'(set_color normal)

    if set -q VIRTUAL_ENV
        echo -n (set_color blue)'('(path basename $VIRTUAL_ENV)')'(set_color normal)' '
    end
    _prompt_git
    set -l profile $AWS_VAULT $AWS_PROFILE $AWS_DEFAULT_PROFILE
    if set -q profile[1]
        echo -n (set_color yellow)aws:$profile[1](set_color normal)' '
    end
    if test $last_status -ne 0
        echo -n (set_color red)✗$last_status(set_color normal)' '
    end
    echo -n (set_color magenta)'❯'(set_color normal)' '
end

function _prompt_git
    set -l raw (GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v2 --branch 2>/dev/null)
    or return
    set -l branch
    set -l dirty
    set -l ahead 0
    set -l behind 0
    for line in $raw
        switch $line
            case '# branch.head *'
                set branch (string replace '# branch.head ' '' -- $line)
            case '# branch.ab *'
                set -l ab (string split ' ' -- $line)
                set ahead (string trim -l -c + -- $ab[3])
                set behind (string trim -l -c - -- $ab[4])
            case '#*'
            case '*'
                set dirty '*'
        end
    end
    test -n "$branch"; or return
    if test "$branch" = '(detached)'
        set branch (GIT_OPTIONAL_LOCKS=0 command git describe --tags --exact-match HEAD 2>/dev/null)
        or set branch (GIT_OPTIONAL_LOCKS=0 command git rev-parse --short HEAD 2>/dev/null)
        or return
    end
    echo -n (set_color red)"git:($branch$dirty)"(set_color normal)' '
    test $ahead -gt 0; and echo -n (set_color cyan)⇡$ahead(set_color normal)' '
    test $behind -gt 0; and echo -n (set_color cyan)⇣$behind(set_color normal)' '
end
